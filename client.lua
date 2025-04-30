local isOnCatapult = false
local catapult = nil
local promptGroup = GetRandomIntInRange(0, 0xffffff)
local sitPrompt = nil
local firePrompt = nil
local playerInCatapult = false

function LoadPrompts()
    local str = Config.prompts.sit
    sitPrompt = PromptRegisterBegin()
    PromptSetControlAction(sitPrompt, Config.sitPromptKey)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(sitPrompt, str)
    PromptSetEnabled(sitPrompt, 1)
    PromptSetVisible(sitPrompt, 1)
	PromptSetStandardMode(sitPrompt,1)
	PromptSetGroup(sitPrompt, promptGroup)
	Citizen.InvokeNative(0xC5F428EE08FA7F2C, sitPrompt,true)
	PromptRegisterEnd(sitPrompt)

    str = Config.prompts.fire
    firePrompt = PromptRegisterBegin()
    PromptSetControlAction(firePrompt, Config.firePromptKey)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(firePrompt, str)
    PromptSetEnabled(firePrompt, 0)
    PromptSetVisible(firePrompt, 1)
	PromptSetStandardMode(firePrompt,1)
	PromptSetGroup(firePrompt, promptGroup)
	Citizen.InvokeNative(0xC5F428EE08FA7F2C, firePrompt,true)
	PromptRegisterEnd(firePrompt)
end

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
        SetModelAsNoLongerNeeded(model)
    end
end)

RegisterNetEvent('moro_cannonball:sitInCatapult')
AddEventHandler('moro_cannonball:sitInCatapult', function()
    playerInCatapult = true
    Citizen.CreateThread(function()
        local ped = PlayerPedId()
        function LoadAnim(dict)
            RequestAnimDict(dict)
            while not HasAnimDictLoaded(dict) do
                Wait(10)
            end
        end
        SetEntityCoords(ped, Config.sitPosition.x, Config.sitPosition.y, Config.sitPosition.z, false, false, false, true)
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

RegisterNetEvent('moro_cannonball:playerInCatapult')
AddEventHandler('moro_cannonball:playerInCatapult', function(playerSit)
    if playerSit then
        PromptSetEnabled(sitPrompt, false)
        PromptSetEnabled(firePrompt, true)
    else
        PromptSetEnabled(sitPrompt, true)
        PromptSetEnabled(firePrompt, false)
    end
    playerInCatapult = playerSit
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

Citizen.CreateThread(function()
    LoadPrompts()
    while true do
        local t = 1000
        local ped = PlayerPedId()
        if GetDistanceBetweenCoords(GetEntityCoords(ped), Config.sitPrompt, true) < 2.0 and not playerInCatapult then
            t = 0
            PromptSetActiveGroupThisFrame(promptGroup, Config.promptGroupName)
            PromptSetEnabled(sitPrompt, true)
            PromptSetEnabled(firePrompt, false)
            if Citizen.InvokeNative(0xC92AC953F0A982AE, sitPrompt) then -- PromptHasStandardModeCompleted
                TriggerServerEvent('moro_cannonball:sitInCatapult')
                Wait(1000)
            end
        elseif GetDistanceBetweenCoords(GetEntityCoords(ped), Config.firePrompt, true) < 2.0 and playerInCatapult then
            t = 0
            PromptSetActiveGroupThisFrame(promptGroup, Config.promptGroupName)
            PromptSetEnabled(sitPrompt, false)
            PromptSetEnabled(firePrompt, true)
            if Citizen.InvokeNative(0xC92AC953F0A982AE, firePrompt) then -- PromptHasStandardModeCompleted
                TriggerServerEvent('moro_cannonball:catapult')
                Wait(1000)
            end
        elseif Config.AllowPlayerInCannonToFire and playerInCatapult and isOnCatapult then
            t = 0
            PromptSetActiveGroupThisFrame(promptGroup, Config.promptGroupName)
            PromptSetEnabled(sitPrompt, false)
            PromptSetEnabled(firePrompt, true)
            if Citizen.InvokeNative(0xC92AC953F0A982AE, firePrompt) then -- PromptHasStandardModeCompleted
                TriggerServerEvent('moro_cannonball:catapult')
                Wait(1000)
            end
        end
        Wait(t)
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        isOnCatapult = false
        ClearPedTasksImmediately(PlayerPedId())
        if catapult and DoesEntityExist(catapult) then
            DeleteObject(catapult)
            catapult = nil
        end
        PromptDelete(sitPrompt)
        PromptDelete(firePrompt)
        ShakeGameplayCam("HAND_SHAKE", 0.0)
    end
end)
