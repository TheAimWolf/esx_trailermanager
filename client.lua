ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

local GotTrailer = 0
local TrailerHandle = 0
local oldtrailer = 0
local oldtrailermodel = 0

Citizen.CreateThread(function()
	while true do

		Wait(0)
		local myPed = GetPlayerPed(-1)
		local myCoord = GetEntityCoords(myPed)
		local currentVehicle = GetVehiclePedIsIn(myPed, 0)
		
		local GotTrailer, TrailerHandle = GetVehicleTrailerVehicle(GetVehiclePedIsIn(myPed, 1))
		if TrailerHandle ~= 0 then
			oldtrailer = TrailerHandle
			oldtrailermodel = GetEntityModel(oldtrailer)
		end

		local trailercoords = GetEntityCoords(oldtrailer)
		if oldtrailermodel == 2078290630 then -- bigtrailer
			if currentVehicle == 0 then
				if oldtrailer ~= 0 then
					local coords = GetOffsetFromEntityInWorldCoords(oldtrailer, -2.0, -6.0, -1.1)
					local dist = GetDistanceBetweenCoords(myCoord.x, myCoord.y, myCoord.z, coords.x, coords.y, coords.z, true)
					if dist < 5 then
						DrawMarker(1, coords.x, coords.y, coords.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.3, 255, 0, 0, 200, 0, 0, 0, 0)
						if dist < 2 then
							SetTextComponentFormat("STRING")
							AddTextComponentString(_U("open_tow_menu"))
							DisplayHelpTextFromStringLabel(0, 0, 1, -1)
							if IsControlJustPressed(0, Config.Key) then
								OpenVehiculeMenu(oldtrailer, coords2)
							end
						else
							ESX.UI.Menu.CloseAll()
						end
					end
				end
			end
		end
		if IsControlJustPressed(0, Config.DetachTrailerKey) then
			local playerVeh = GetVehiclePedIsIn(myPed, true)
			GotTrailer, TrailerHandle = GetVehicleTrailerVehicle(playerVeh)
			DetachVehicleFromTrailer(playerVeh)
		end
	end
end)




function OpenVehiculeMenu(oldtrailer, coords2)

	ESX.UI.Menu.CloseAll()
	local elements = {}
	
	
	if upperRampDown then
		table.insert(elements, {label = _U("close_plateau"),	value = 'ClosePlateau'})
	else
		table.insert(elements, {label = _U("open_plateau"),		value = 'OpenPlateau'})
	end
	
	if rampOpen then
		table.insert(elements, {label = _U("close_rampe"), value = 'CloseRamp'})
	else
		table.insert(elements, {label = _U("open_rampe"), value = 'OpenRamp'})
	end	
	
	table.insert(elements, {label = _U("lock_cars"), value = 'lock'})
	table.insert(elements, {label = _U("unlock_cars"), value = 'unlock'})

	

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'menuperso_vehicule',
		{
			img    = 'menu_vehicule',
			align    = 'bottom-right',
			elements = elements
		},
		function(data, menu)


-------------------------------------------------------------
--------------------------- Open ----------------------------
-------------------------------------------------------------
			if data.current.value == 'OpenPlateau' then
				upperRampDown = true
				SetVehicleDoorOpen(oldtrailer, 4, false, false)
				OpenVehiculeMenu(oldtrailer, coords2)
			elseif data.current.value == 'OpenRamp' then
				rampOpen = true
				SetVehicleDoorOpen(oldtrailer, 5, false, false)
				OpenVehiculeMenu(oldtrailer, coords2)

-------------------------------------------------------------
--------------------------- Close ---------------------------
-------------------------------------------------------------
			elseif data.current.value == 'ClosePlateau' then
				upperRampDown = false
				SetVehicleDoorShut(oldtrailer, 4, false, false)
				OpenVehiculeMenu(oldtrailer, coords2)
			elseif data.current.value == 'CloseRamp' then
				rampOpen = false
				SetVehicleDoorShut(oldtrailer, 5, false, false)
				OpenVehiculeMenu(oldtrailer, coords2)
-------------------------------------------------------------
---------------- Secure vehicles on trailer -----------------
-------------------------------------------------------------
			elseif data.current.value == 'lock' then
				for car in EnumerateVehicles() do
					if IsEntityTouchingEntity(oldtrailer, car) then
						local vehCoords = GetEntityCoords(car)
						local vehRotation = GetEntityRotation(car)

						AttachVehicleOnToTrailer(car, oldtrailer, 0.0, 0.0, 0.0, GetOffsetFromEntityGivenWorldCoords(oldtrailer, vehCoords), vehRotation.x, vehRotation.y, 0.0, false)
						TriggerServerEvent('esx_jb_trailer:AddCarToTrailer', GetVehicleNumberPlateText(oldtrailer), car)
						Citizen.Wait(10)
					end
				end
			elseif data.current.value == 'unlock' then
				ESX.TriggerServerCallback('esx_jb_trailer:UnlockTrailer', function(loadedCars)
					for i, car in pairs(loadedCars) do
						DetachEntity(car, true, false)
					end
				end, GetVehicleNumberPlateText(oldtrailer))
			end
		end,
		function(data, menu)
			menu.close()
		end
	)
end

-------------------------------------------------------------
-------------------------- Util -----------------------------
-------------------------------------------------------------
local entityEnumerator = {
	__gc = function(enum)
	    if enum.destructor and enum.handle then
		    enum.destructor(enum.handle)
	    end
	    enum.destructor = nil
	    enum.handle = nil
	end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
	    local iter, id = initFunc()
	    if not id or id == 0 then
	        disposeFunc(iter)
		    return
	    end
	  
	    local enum = {handle = iter, destructor = disposeFunc}
	    setmetatable(enum, entityEnumerator)
	  
	    local next = true
	    repeat
		    coroutine.yield(id)
		    next, id = moveFunc(iter)
	    until not next
	  
	    enum.destructor, enum.handle = nil, nil
	    disposeFunc(iter)
	end)
end

function EnumerateVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end
