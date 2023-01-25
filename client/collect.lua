local RSGCore = exports['rsg-core']:GetCoreObject()

local promptPressed = false
---------------------------------------------------------------------------------

-- collect water
Citizen.CreateThread(function()
    while true do
        Wait(0)
        local pos, awayFromObject = GetEntityCoords(PlayerPedId()), true

        if promptPressed then
            Wait(5000)
            promptPressed = false
        end

        for i = 1, #Config.WaterProps do
            local waterObject = GetClosestObjectOfType(pos, 5.0, GetHashKey(Config.WaterProps[i]), false, false, false)

            if waterObject == 0 then goto continue end

            local objectPos = GetEntityCoords(waterObject)

            if #(pos - objectPos) >= 2.0 then goto continue end

            awayFromObject = false
            DrawText3Ds(objectPos.x, objectPos.y, objectPos.z + 1.0,  Lang:t('text.collect_water'))

            if not IsControlJustReleased(0, RSGCore.Shared.Keybinds['J']) then goto continue end

            TriggerEvent('rsg-farmer:client:collectwater')
            promptPressed = true

            ::continue::
        end

        if awayFromObject then
            Citizen.Wait(1000)
        end
    end
end)

---------------------------------------------------------------------------------

-- collect poo
Citizen.CreateThread(function()
    while true do
        Wait(0)
        local pos, awayFromObject = GetEntityCoords(PlayerPedId()), true

        if promptPressed then
            Wait(5000)
            promptPressed = false
        end

        for i = 1, #Config.FertilizerProps do
            local pooObject = GetClosestObjectOfType(pos, 5.0, GetHashKey(Config.FertilizerProps[i]), false, false, false)

            if pooObject == 0 then goto continue end

            local objectPos = GetEntityCoords(pooObject)

            if #(pos - objectPos) >= 2.0 then goto continue end

            awayFromObject = false

            DrawText3Ds(objectPos.x, objectPos.y, objectPos.z + 0.3, Lang:t('text.pickup_poo'))

            if not IsControlJustReleased(0, RSGCore.Shared.Keybinds['J']) then goto continue end

            TriggerEvent('rsg-farmer:client:collectpoo')
            promptPressed = true

            ::continue::
        end

        if awayFromObject then
            Citizen.Wait(3000)
        end
    end
end)

---------------------------------------------------------------------------------

-- do collecting water
RegisterNetEvent('rsg-farmer:client:collectwater')
AddEventHandler('rsg-farmer:client:collectwater', function()
    local hasItem = RSGCore.Functions.HasItem('bucket', 1)
    local PlayerJob = RSGCore.Functions.GetPlayerData().job.name

    -- Job required
    if Config.EnableJob and PlayerJob ~= Config.JobRequired and LocalPlayer.state.isLoggedIn then
        RSGCore.Functions.Notify( Lang:t('error.only_farmers_can_collect_water'), 'error', 3000)
        return
    end

    if not hasItem then
        RSGCore.Functions.Notify(Lang:t('error.you_need_bucket_collect_water'), 'error', 3000)
        return
    end

    RSGCore.Functions.Progressbar("collecting-water", Lang:t('progressbar.collecting_water'), Config.CollectWaterTime, false, true, {
        disableMovement = true,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        TriggerServerEvent('rsg-farmer:server:giveitem', 'water', 1)
        RSGCore.Functions.Notify(Lang:t('success.youve_got_bucketful_water'), 'success', 3000)
    end)
end)

-- do collecting poo
RegisterNetEvent('rsg-farmer:client:collectpoo')
AddEventHandler('rsg-farmer:client:collectpoo', function()
    local hasItem = RSGCore.Functions.HasItem('bucket', 1)
    local PlayerJob = RSGCore.Functions.GetPlayerData().job.name

    -- Job required
    if Config.EnableJob and PlayerJob ~= Config.JobRequired and LocalPlayer.state.isLoggedIn then
        RSGCore.Functions.Notify(Lang:t('error.only_farmers_can_collect_poo'), 'error', 3000)
        return
    end

    if not hasItem then
        RSGCore.Functions.Notify(Lang:t('error.you_need_a_bucket_collect_fertilizer'), 'error', 3000)
        return
    end

    RSGCore.Functions.Progressbar("collecting-poo", Lang:t('progressbar.collecting_poo'), Config.CollectPooTime, false, true, {
        disableMovement = true,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        TriggerServerEvent('rsg-farmer:server:giveitem', 'fertilizer', 1)
        RSGCore.Functions.Notify(Lang:t('success.youve_got_bucketful_fertilizer'), 'success', 3000)
    end)
end)

---------------------------------------------------------------------------------

function DrawText3Ds(x, y, z, text)
    local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)
    SetTextScale(0.30, 0.30)
    SetTextFontForCurrentCommand(9)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str,_x,_y)
end

---------------------------------------------------------------------------------
