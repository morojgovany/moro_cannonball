local playerOnCatapult = nil

RegisterNetEvent('moro_cannonball:sitInCatapult')
AddEventHandler('moro_cannonball:sitInCatapult', function()
    local _source = source
    if playerOnCatapult == nil then
        playerOnCatapult = _source
        TriggerClientEvent('moro_cannonball:sitInCatapult', _source)
        TriggerClientEvent('moro_cannonball:playerInCatapult', -1, true)
    end
end)

RegisterNetEvent('moro_cannonball:catapult')
AddEventHandler('moro_cannonball:catapult', function()
    if playerOnCatapult then
        TriggerClientEvent('moro_cannonball:catapult', playerOnCatapult)
        TriggerClientEvent('moro_cannonball:playerInCatapult', -1, false)
        playerOnCatapult = nil
    end
end)

if Config.useSpawnCommand then
    RegisterCommand("spawnCatapult", function(source, args, raw)
        local _source = source
        TriggerClientEvent('moro_cannonball:spawnCatapult', _source)
    end, Config.adminOnly)
end
