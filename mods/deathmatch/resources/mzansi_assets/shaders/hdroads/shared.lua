
vehiclemarker = {
{-1945,273,35,0,0,140,411,"BMW"}, --x,y,z -- кординаты тачки --rx,ry,rz -- поворот тачки -- id -- ид тачки -- shop -- тачка из какого салона
{-1944,266,35,0,0,140,401,"BMW"},
{-1944,259,35,0,0,140,502,"BMW"},
{-1958,257,35,0,0,140,567,"BMW"},
{-1957,264,35,0,0,140,491,"BMW"},
}

vehShopsTable = {
	["BMW"] = {-1989,259,35,0,0,0}, --- салон = {x,y,z,rx,ry,rz} -кординаты тачки при покупке 
}


local Names = {
    {411 , "Range Rover SVR", 7500000}, -- ид , название, цена
	{401 , "Kia Optima GT", 1300000},
	{502 , "Audi TTs", 4800000},
	{567 , "Audi R8", 8500000},
	{491 , "Honda Accord", 1100000},
}

MarkerEnterBy = {
{2843,1287,10}
}

MarkerBY = {
{2829,1293,9}
}

MarkersLift =
{
{5812,-1725,11},
{5812,-1725,30},
{5812,-1725,48},
{5812,-1725,66},
{5812,-1725,85},
{5812,-1725,106},
{5812,-1725,126},
{5812,-1725,17},
{5812,-1725,166},
}

proccentSellCar = 0.5


defaultHandlingTable = -- Здесь просто паста из стандартного handling editor'а
{
	
}

marketPositions = -- Позиции парковочных мест на Б/У рынке
{
{5815,-1717,13,0,0,0},
{5821,-1717,12,1,1,0},
{5828,-1717,12,2,0,0},
{5835,-1717,12,3,0,0},
{5841,-1717,12,4,0,0},
{5847,-1718,12,5,0,0},
{5860,-1717,12,6,0,0},
{5866,-1718,12,7,0,0},
{5866,-1704,12,8,0,0},
}


function getData(str)
	for k,v in pairs(vehiclemarker) do
		if v[7] == str then
			return v
		end
	end
end

function getNames(str)
	for k,v in pairs(Names) do
		if str == v[1] then
			return v
			end
		end
end


function getVehicleByID(id)
	v = false
	for i, veh in ipairs (getElementsByType("vehicle")) do
		if getElementData(veh, "id") == id then
			v = veh
			break
		end
	end
	return v
end