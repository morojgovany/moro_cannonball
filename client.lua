local isOnCatapult = false
local catapult = nil

RegisterNetEvent('moro_cannonball:spawnCatapult')
AddEventHandler('moro_cannonball:spawnCatapult', function()
    function LoadModel(model)
        if IsModelInCdimage(model) then
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(100)
            end
            return true
        else
            print('Error: Model does not exist: ' .. model)
            return false
        end
    end
    if catapult and DoesEntityExist(catapult) then
        DeleteObject(catapult)
        catapult = nil
    else
        local model = Config.cannon.model
        LoadModel(model)
        catapult = CreateObject(model, Config.cannon.coords, true, true, false, false, true)
        SetEntityHeading(catapult, Config.cannon.rotation.z)
        SetEntityRotation(catapult, Config.cannon.rotation.x, Config.cannon.rotation.y, Config.cannon.rotation.z, 2, true)
        SetEntityDynamic(catapult, false)
        SetEntityInvincible(catapult, true)
        SetEntityCanBeDamaged(catapult, false)
        FreezeEntityPosition(catapult, true)
    end
end)

RegisterNetEvent('moro_cannonball:startCatapult')
AddEventHandler('moro_cannonball:startCatapult', function()
    Citizen.CreateThread(function()
        local ped = PlayerPedId()
        function LoadAnim(dict)
            RequestAnimDict(dict)
            while not HasAnimDictLoaded(dict) do
                Wait(10)
            end
        end
        SetEntityCoords(ped, Config.catapultPos.x, Config.catapultPos.y, Config.catapultPos.z, false, false, false, true)
        SetEntityHeading(ped, 59.57)
        LoadAnim("amb_camp@prop_camp_seat_chair@cold@female_b@wip_base")
        TaskPlayAnim(ped, "amb_camp@prop_camp_seat_chair@cold@female_b@wip_base", "wip_base", 1.0, 8.0, -1, 1, 0, true, 0, false, 0, false)
        isOnCatapult = true
        while isOnCatapult do
            ped = PlayerPedId()
            FreezeEntityPosition(PlayerPedId(), true)
            DisableControlAction(0, Config.animationKey, true)
            Wait(1)
        end
    end)
end)

RegisterNetEvent('moro_cannonball:catapult')
AddEventHandler('moro_cannonball:catapult', function()
    local ped = PlayerPedId()
    local playerPos = GetEntityCoords(ped)
    local forwardVector = GetEntityForwardVector(ped)

    ClearPedTasksImmediately(ped)
    isOnCatapult = false
    Wait(50)

    AddExplosion(playerPos.x, playerPos.y, playerPos.z, 26, 0.5, true, false, true)
    ShakeGameplayCam("HAND_SHAKE", 2.5)
    RemoveAnimDict("amb_camp@prop_camp_seat_chair@cold@female_b@wip_base")

    local velocityMultiplier = Config.velocityMultiplier
    local forceMultiplier = Config.forceMultiplier
    local upwardForce = Config.upwardForce

    local initialVelocity = vector3(
            forwardVector.x * velocityMultiplier,
            forwardVector.y * velocityMultiplier,
            upwardForce / 50.0 
    )
    SetEntityVelocity(ped, initialVelocity.x, initialVelocity.y, initialVelocity.z)
    Citizen.InvokeNative(0xAE99FB955581844A, ped, 2000, 2000, 0, 0, 0, "falling")
    Citizen.CreateThread(function()
        local forceTimeMs = Config.duration
        local startTime = GetGameTimer()
        while GetGameTimer() - startTime < forceTimeMs do
            ApplyForceToEntity(
                    ped,
                    1, 
                    forwardVector.x * forceMultiplier,
                    forwardVector.y * forceMultiplier,
                    upwardForce,
                    0.0, 0.0, 0.0,
                    0,
                    false,
                    true,
                    false,
                    false
            )
            Wait(0)
        end
    end)

    ShakeGameplayCam("HAND_SHAKE", 0.0)
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        isOnCatapult = false
        ClearPedTasksImmediately(PlayerPedId())
        if catapult and DoesEntityExist(catapult) then
            DeleteObject(catapult)
            catapult = nil
        end
        ShakeGameplayCam("HAND_SHAKE", 0.0)
    end
end)
