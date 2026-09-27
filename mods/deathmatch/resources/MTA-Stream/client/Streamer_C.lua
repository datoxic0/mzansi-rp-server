debug.sethook(nil)

-- Tables --
cache = {}
resource = {}
local definitionRows = {}
local vcElements = {}
local pendingPlacements = {}
local allocatedModelsByResource = {}

function onResourceStart(resourcea)
	triggerServerEvent ( "onResourceLoad", resourceRoot, getResourceName(resourcea))
end
addEventHandler( "onClientResourceStart", getRootElement( ),onResourceStart)


-- MZANSI PATCH: cache definition metadata only. Do NOT engineReplaceModel /
-- engineImportTXD / engineReplaceCOL on stock SA IDs — SA RP world stays loaded.
function loadMap ( Proccessed,resourceName )
	startTickCount = getTickCount ()
	resource[resourceName] = {}
	definitionRows[resourceName] = Proccessed
	if pendingPlacements[resourceName] then
		local placements = pendingPlacements[resourceName]
		pendingPlacements[resourceName] = nil
		createClientPlacements(resourceName, placements)
	end
	loadedFunction(resourceName)
end
addEvent( "MTAStream_Client", true )
addEventHandler( "MTAStream_Client", localPlayer, loadMap )

function createClientPlacements(resourceName, placements)
	if type(placements) ~= "table" then return end
	if vcElements[resourceName] then
		for _, el in ipairs(vcElements[resourceName]) do
			if isElement(el) then destroyElement(el) end
		end
	end
	vcElements[resourceName] = {}

	local defByModel = {}
	for defId, row in pairs(definitionRows[resourceName] or {}) do
		if type(row) == "table" then
			defByModel[tostring(defId)] = row
		end
	end

	local created, missing = 0, 0
	local requestedModelByName = {}
	allocatedModelsByResource[resourceName] = requestedModelByName

	for _, p in ipairs(placements) do
		local model = tostring(p.model)
		local def = defByModel[model]
		local objId = nil
		local doubleSided = false

		if def then
			objId = requestedModelByName[model]
			if not objId then
				objId = engineRequestModel("object")
				if objId then
					requestedModelByName[model] = objId
					local txdPath = (":%s/Content/textures/%s.txd"):format(resourceName, tostring(def[2]))
					local colPath = (":%s/Content/coll/%s.col"):format(resourceName, tostring(def[3]))
					local dffPath = (":%s/Content/models/%s.dff"):format(resourceName, tostring(def[1]))
					if fileExists(txdPath) then
						local txd = cache[txdPath] or engineLoadTXD(txdPath)
						cache[txdPath] = txd
						if txd then engineImportTXD(txd, objId) end
					end
					if fileExists(colPath) then
						local col = cache[colPath] or engineLoadCOL(colPath)
						cache[colPath] = col
						if col then engineReplaceCOL(col, objId) end
					end
					if fileExists(dffPath) then
						local dff = cache[dffPath] or engineLoadDFF(dffPath)
						cache[dffPath] = dff
						if dff then engineReplaceModel(dff, objId, def[5]) end
					end
					engineSetModelLODDistance(objId, math.max(tonumber(def[4]) or 270, 270))
				end
			end
			doubleSided = def[6] and true or false
		else
			-- Native SA model name that has no custom definition: leave stock model alone.
			objId = tonumber(model) or nil
			if not objId then missing = missing + 1 end
		end

		if objId then
			local el = createObject(objId, p.x, p.y, p.z, p.xr, p.yr, p.zr)
			if isElement(el) then
				setElementInterior(el, p.interior or 0)
				setElementDimension(el, p.dimension or 0)
				setElementData(el, "id", model, false)
				pcall(setElementID, el, model)
				setElementFrozen(el, true)
				if doubleSided then setElementDoubleSided(el, true) end
				table.insert(vcElements[resourceName], el)
				created = created + 1
			end
		end
	end
	outputDebugString(("[MTA-Stream] %s: created %d/%d client placements (unresolved models: %d)"):format(
		resourceName, created, #placements, missing))
end

addEvent("MTAStream_Placements", true)
addEventHandler("MTAStream_Placements", localPlayer, function(resourceName, placements)
	if type(placements) ~= "table" then return end
	if not definitionRows[resourceName] then
		-- Definitions not received yet — buffer until MTAStream_Client arrives.
		pendingPlacements[resourceName] = placements
		return
	end
	createClientPlacements(resourceName, placements)
end)

function loadedFunction (resourceName)
	local endTickCount = getTickCount ()-startTickCount
	triggerServerEvent ( "onPlayerLoad", root, tostring(endTickCount),resourceName )
	createTrayNotification( 'You have finished loading : '..resourceName, "info" )
end

function requestTextureArchive(path)
	if path then
		cache[path] = cache[path] or engineLoadTXD(path)
		return cache[path],path
	end
end

function requestCollision(path)
	if path then
		cache[path] = cache[path] or engineLoadCOL(path)
		return cache[path],path
	end
end

function requestModel(path)
	if path then
		cache[path] = cache[path] or engineLoadDFF(path)
		return cache[path],path
	end
end

function restore(model)
	engineRestoreModel ( model )
	engineRestoreCOL( model )
	engineSetModelLODDistance(model, 170)
	if engineSetModelVisibleTime then
		engineSetModelVisibleTime(model,0,0)
	end
end
addEvent( "restoreModel", true )
addEventHandler( "restoreModel", localPlayer, restore )


function forceLoad()
	-- MZANSI PATCH: loadModel event no longer replaces stock SA IDs.
end
addEvent( "loadModel", true )
addEventHandler( "loadModel", localPlayer, forceLoad )

function onResourceStop(name)
	resource[name] = nil
	definitionRows[name] = nil
	if vcElements[name] then
		for _, el in ipairs(vcElements[name]) do
			if isElement(el) then destroyElement(el) end
		end
		vcElements[name] = nil
	end
	if allocatedModelsByResource[name] then
		for _, id in pairs(allocatedModelsByResource[name]) do
			if engineFreeModel then pcall(engineFreeModel, id) end
		end
		allocatedModelsByResource[name] = nil
	end
end
addEvent( "resourceStop", true )
addEventHandler( "resourceStop", localPlayer, onResourceStop )

function getMaps()
	local tempTable = {}
	for i,v in pairs(resource) do
		table.insert(tempTable,i)
	end
	return tempTable
end
