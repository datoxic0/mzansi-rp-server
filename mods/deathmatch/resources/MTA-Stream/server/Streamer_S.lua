debug.sethook(nil)

-- MZANSI PATCH: do NOT wipe SA world or override water.
-- SA must stay intact for Mzansi RP (removeDefaultMap=false + dim-isolated expansions).

-- Events --
events = {'onPlayerLoad','onElementBreak','onPlayerFailedLoad','fetchID','prepOriginals'}
for i = 1,#events do
	addEvent( events[i], true )
end

-- Tables --
data = {id={},resourceObjects={},globalObjects = {},resourceData={},globalData = {}}
pendingPlacements = {}
suffixList = {'gta3','mta'}

blacklist = {}
 -- ID defines the assigned SA ID, objects are the objects per SID, resource defines objects per resource.
 
 -- Functions --
 
 function blackList(model)
	-- MZANSI PATCH: never restore/reassign stock SA models.
end

function loadStreamerMap( resource )																	 -- // On map start, if it has the 'Streamer' or 'cStream' tag load it.
	if getResourceInfo ( resource, 'Streamer') or getResourceInfo ( resource, 'cStream') then
		loadMap(resource)
	end
end 
addEventHandler ( "onResourceStart", root,loadStreamerMap)

function toBoolean(input)
	return (string.count(input,'tru') > 0)
end

function fetchPlacement(dictonary,sufix)																		 -- // Allows backwards compatability
	if fileExists(':'..dictonary..'/'..sufix..'.CSP') then
		return fileOpen(':'..dictonary..'/'..sufix..'.CSP')
	elseif fileExists(':'..dictonary..'/'..sufix..'.JSP') then
		return fileOpen(':'..dictonary..'/'..sufix..'.JSP')
	elseif fileExists(':'..dictonary..'/'..sufix..'.MSP') then
		return fileOpen(':'..dictonary..'/'..sufix..'.MSP')
	else
		return false
	end
end

function fetchDefintion(dictonary,sufix)																		 -- // Allows backwards compatability
	if fileExists(':'..dictonary..'/'..sufix..'.CSD') then
		return fileOpen(':'..dictonary..'/'..sufix..'.CSD')
	elseif fileExists(':'..dictonary..'/'..sufix..'.JSD') then
		return fileOpen(':'..dictonary..'/'..sufix..'.JSD')
	elseif fileExists(':'..dictonary..'/'..sufix..'.MSD') then
		return fileOpen(':'..dictonary..'/'..sufix..'.MSD')
	else
		return false
	end
end


function loadMap (resource)																				 -- // Load the map
	local tickCount = getTickCount()
	local resourceName = getResourceName(resource)
	data.resourceObjects[resourceName] = {}
	data.resourceData[resourceName] = {}
	
	for _,suffix in pairs(suffixList) do
		local File = fetchPlacement(resourceName,suffix)
		
		if File then
			local Data = fileRead(File, fileGetSize(File))
			local ProccessedA = split(Data,10)
			fileClose (File)
			
			for i,vA in pairs(ProccessedA) do
				if not (i == 1) then
					local SplitB = split(vA,",")
					if not (SplitB[1] == '!') then -- If the first character is equal to # then ignore, used for debugging.
						local model = (SplitB[1])
						if model then
							if getModelFromID(model) then
								blackList(model)
							end
						end
					end
				end
			end
			
			
			local File = fetchDefintion(resourceName,suffix)
			
			local Data =  fileRead(File, fileGetSize(File))
			local Proccessed = split(Data,10)
			fileClose (File)

			iA = 0
			
			Async:setPriority("medium")

			Async:foreach(Proccessed, function(vA)
				iA = iA + 1
				local SplitA = split(vA,",")
				if (type(SplitA) == 'table') then
					if not (SplitA[1] == '!') then -- If the first character is equal to # then ignore, used for debugging.
						for i=1,8 do
							if not SplitA[i] then
								print(SplitA[1],'| Object definition load error','| Row '..i)					-- // If there is any missing information inform the server, added 'Row' information for better debugging.
								return
							end
						end
						defineDefintion(SplitA,resourceName) -- ## 
					end
				end
			end)
			
			
			XA,YA,ZA = 0,0,0
			iA = 0
			
			Async:setPriority("medium")
	
			-- MZANSI PATCH: send placements to clients for local creation with
			-- engineRequestModel IDs. Server-side createObject + SA-ID replace
			-- would globally corrupt SA models while removeDefaultMap=false.
			local placements = {}
			Async:foreach(ProccessedA, function(vA)
				iA = iA + 1
				if (iA == 1) then
					local x,y,z = split(vA,",")[1],split(vA,",")[2],split(vA,",")[3]
					XA,YA,ZA = tonumber(x),tonumber(y),tonumber(z)
				else
					local SplitB = split(vA,",")
					if not (SplitB[1] == '!') then
						for i=1,9 do
							if not SplitB[i] then
								print(SplitB[1],'| Object placement load error','| Row '..i)
								return
							end
						end
						table.insert(placements, {
							model = SplitB[1],
							interior = tonumber(SplitB[2]) or 0,
							dimension = tonumber(SplitB[3]) or 0,
							x = tonumber(SplitB[4]) + XA,
							y = tonumber(SplitB[5]) + YA,
							z = tonumber(SplitB[6]) + ZA,
							xr = tonumber(SplitB[7]) or 0,
							yr = tonumber(SplitB[8]) or 0,
							zr = tonumber(SplitB[9]) or 0,
						})
					end
				end
			end)
			data.resourceObjects[resourceName] = placements
			-- Hold placements until client requests definitions (onResourceLoad),
			-- so definitions arrive first and IDs never touch stock SA models.
			pendingPlacements[resourceName] = placements
			-- Race fix: if a client already requested onResourceLoad before this
			-- finished, push definitions+placements now (client rebuild is safe).
			for _, player in ipairs(getElementsByType("player")) do
				triggerClientEvent(player, "MTAStream_Client", player, data.resourceData[resourceName], resourceName)
				triggerClientEvent(player, "MTAStream_Placements", player, resourceName, placements)
			end
		end
	end
	
	local endTick = getTickCount()
	print(resourceName,'Loaded In : '..tonumber(endTick-tickCount),'Milisecounds')
end

function defineDefintion(dTable,resourceName) -- Define definition metadata only (client allocates real IDs)
	local ID,model,texture,collision,draw,alpha,backface,lod,turnOn,turnOff = unpack(dTable)
	data.resourceData[resourceName][ID] = {model,texture,collision,draw,toBoolean(alpha),toBoolean(backface),toBoolean(lod),turnOn,turnOff,0,resourceName}
	data.globalData[ID] = data.resourceData[resourceName][ID]
end

function getData(name)
	if data.globalData[name] then
		local _,_,_,_,_,cull,lod,_,_,id = unpack(data.globalData[name])
		return cull,lod,id,true
	else
		return false,false,getModelFromID(name)
	end
end


function streamObject()
	-- MZANSI PATCH: object creation is client-side (MTAStream_Placements).
	return false
end

function changeObjectModel(name,newModel)
	if data.globalData[name] then
		print(name,'Revoked')
		data.globalData[name][10] = newModel
		data.resourceData[data.globalData[name][11]][name][10] = newModel
		
		
		for i,v in pairs(getElementsByType('object')) do
			if (getElementData(v,'id') == name) then
				setElementModel(v,newModel)
			end
		end
		triggerClientEvent ("loadModel",root,data.globalData[name],data.globalData[name][11])
	end
end

function onResourceLoad ( resource )
	local resource = getResourceFromName(resource)
	if getResourceInfo ( resource, 'Streamer') or getResourceInfo ( resource, 'cStream') then
		local name = getResourceName(resource)
		-- Definitions first, then placements (client creates objects locally).
		triggerClientEvent("MTAStream_Client",client,data.resourceData[name],name )
		if pendingPlacements[name] then
			triggerClientEvent("MTAStream_Placements",client,name,pendingPlacements[name])
		end
	end
end
addEvent( "onResourceLoad", true )
addEventHandler( "onResourceLoad", resourceRoot, onResourceLoad )

function playerLoaded ( loadTime,resource )
	print(getPlayerName(client),'Loaded '..resource..' In : '..(tonumber(loadTime)*0.01),'Secounds')
end
addEventHandler( "onPlayerLoad", resourceRoot, playerLoaded )


function onElementDestroy()
	if getElementType(source) == "object" then
		if getLowLODElement(source) then
			destroyElement(getLowLODElement(source))
		end
	end
end
addEventHandler("onElementDestroy",resourceRoot,onElementDestroy)


function onResourceStop(resource)
	if getResourceInfo ( resource, 'Streamer') or getResourceInfo ( resource, 'cStream') then
		local name = getResourceName(resource)
		triggerClientEvent ( root, "resourceStop",name)
		if data.resourceData[name] then
			for i,v in pairs(data.resourceData[name]) do
				data.id[v[10]] = nil
				idused[v[10]] = nil
			end
		end
		data.resourceData[name] = nil
		data.resourceObjects[name] = nil
		pendingPlacements[name] = nil
	end
end
addEventHandler( "onResourceStop", root,onResourceStop)

function getMaps()
	local tempTable = {}
	for i,v in pairs(data.resourceObjects) do
		table.insert(tempTable,i)
	end
	return tempTable
end

function getMapElements(map)
	return data.resourceObjects[map]
end
