ESX = nil 

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) 

RegisterServerEvent("guille_storevehicle")
AddEventHandler("guille_storevehicle", function(plate, properties, headings)
    local xPlayer = ESX.GetPlayerFromId(source)
    local h = headings
    local pos = json.encode(xPlayer.getCoords())
    local plate = plate
    local vehprop = json.encode(properties)
    print(plate)
    print(properties)

    MySQL.Async.execute("UPDATE owned_vehicles SET position=@position WHERE plate=@plate", {
        ['@position'] = pos,
        ['@plate'] = plate,
    })
    MySQL.Async.execute("UPDATE owned_vehicles SET heading=@heading WHERE plate=@plate", {
        ['@heading'] = h,
        ['@plate'] = plate,
    })
    MySQL.Async.execute("UPDATE owned_vehicles SET vehicle=@vehicle WHERE plate=@plate", {
        ['@vehicle'] = vehprop,
        ['@plate'] = plate,
    })

end)

ESX.RegisterServerCallback('guille_getvehicles', function(source,cb) 
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    MySQL.Async.fetchAll("SELECT vehicle, position, heading FROM owned_vehicles WHERE owner=@identifier AND state=0", {
        ['@identifier'] = xPlayer.getIdentifier()
    }, function(result)
        local vehicles = {}
        if result[1] ~= nil then
            for i = 1, #result, 1 do
                print("test")
                table.insert(vehicles, { ["position"] = json.decode(result[i]["position"]), ["h"] = json.decode(result[i]["heading"]), ["vehProps"] = json.decode(result[i]["vehicle"]) })
            end
        end
        cb(vehicles)
    end)

end)

ESX.RegisterServerCallback('getvehiclescommand', function(source,cb)

	local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.fetchAll("SELECT position FROM owned_vehicles", {}, function(result)
        local pos = {}
        for i = 1, #result, 1 do
            table.insert(pos, { ["position"] = json.decode(result[i]["position"]) })
        end
        cb(pos)
    end)
end)

ESX.RegisterServerCallback('guille_nogarages:getOutVehicles', function(source, cb)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local veh = {}

    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner=@identifier', {
        ['@identifier'] = xPlayer.getIdentifier()
    }, function(data)
        for _, v in pairs(data) do
            local vehicle = json.decode(v.vehicle)
            table.insert(veh, vehicle)
        end

        cb(veh)
    end)
end)

ESX.RegisterServerCallback('guille_nogarages:checkMoney', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    if(xPlayer.getMoney() >= Config.moneytoretrieve) then
        xPlayer.removeMoney(100)
        cb(true)
    else
        cb(false)
    end
end)
