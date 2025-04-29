local playerOnCatapult = nil

RegisterCommand("putOnCatapult", function(source, args, raw)
    if args[1] and tonumber(args[1]) then
        playerOnCatapult = args[1]
        TriggerClientEvent('moro_catapult:startCatapult', args[1])
    end
end, Config.adminOnly)

RegisterCommand("catapult", function(source, args, raw)
    if playerOnCatapult then
        TriggerClientEvent('moro_catapult:catapult', playerOnCatapult)
        playerOnCatapult = nil
    end
end, Config.adminOnly)

RegisterCommand("spawnCatapult", function(source, args, raw)
    local _source = source
    TriggerClientEvent('moro_catapult:spawnCatapult', _source)
end, Config.adminOnly)

