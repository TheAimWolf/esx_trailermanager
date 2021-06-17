ESX = nil
trailers = {}


Citizen.CreateThread(function ()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    end
    ESX.RegisterServerCallback('esx_jb_trailer:UnlockTrailer', function(source, cb, trailerPlate)
        UnlockTrailer(source, cb, trailerPlate)
    end)
end)

RegisterServerEvent('esx_jb_trailer:AddCarToTrailer')
AddEventHandler('esx_jb_trailer:AddCarToTrailer', function(trailerPlate, car)
    if trailers[trailerPlate] == nil then
        trailers[trailerPlate] = {}
    end
    if not table.contains(trailers[trailerPlate], car) then
        table.insert(trailers[trailerPlate], car)
    end
end)

function UnlockTrailer(source, cb, trailerPlate)
    loadedCars = trailers[trailerPlate]
    trailers[trailerPlate] = {}
    cb(loadedCars)
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function table.contains(table, element)
    for _, value in pairs(table) do
      if value == element then
        return true
      end
    end
    return false
  end