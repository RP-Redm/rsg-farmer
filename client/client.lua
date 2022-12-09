local QRCore = exports['qr-core']:GetCoreObject()
local isBusy = false
local hash = {}
local SpawnedPlants = {}
local InteractedPlant = nil
local HarvestedPlants = {}
local canHarvest = true
local closestPlant = nil
local isDoingAction = false
local Zones = {}
local zonename = NIL
local inFarmZone = false
isLoggedIn = false
PlayerJob = {}

RegisterNetEvent('QRCore:Client:OnPlayerLoaded')
AddEventHandler('QRCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    PlayerJob = QRCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('QRCore:Client:OnJobUpdate')
AddEventHandler('QRCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

-- create farm zones
CreateThread(function() 
    if Config.UseFarmingZones == true then
        for k=1, #Config.FarmZone do
            Zones[k] = PolyZone:Create(Config.FarmZone[k].zones, {
                name = Config.FarmZone[k].name,
                minZ = Config.FarmZone[k].minz,
                maxZ = Config.FarmZone[k].maxz,
                debugPoly = false,
            })
            Zones[k]:onPlayerInOut(function(isPointInside)
                if isPointInside then
                    inFarmZone = true
                    zonename = Zones[k].name
                    QRCore.Functions.Notify('you have entered a farm zone', 'primary')
                else
                    inFarmZone = false
                end
            end)
        end
    end
end)

-- create farmzone blips
Citizen.CreateThread(function()
    if Config.UseFarmingZones == true then
        for farmzone, v in pairs(Config.FarmZone) do
            if v.showblip == true then
                local FarmZoneBlip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, v.blipcoords)
                SetBlipSprite(FarmZoneBlip, 669307703, true)
                SetBlipScale(FarmZoneBlip, 0.2)
                Citizen.InvokeNative(0x9CB1A1623062F402, FarmZoneBlip, 'Farming Zone')
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
    Wait(150)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local inRange = false
        for i = 1, #Config.FarmPlants do
            local dist = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.FarmPlants[i].x, Config.FarmPlants[i].y, Config.FarmPlants[i].z, true)
            if dist < 50.0 then
                inRange = true
                local hasSpawned = false
                for z = 1, #SpawnedPlants do
                    local p = SpawnedPlants[z]
                    if p.id == Config.FarmPlants[i].id then
                        hasSpawned = true
                    end
                end
                if not hasSpawned then
                    local planthash = Config.FarmPlants[i].hash
                    local hash = GetHashKey(planthash)
                    while not HasModelLoaded(hash) do
                        Wait(10)
                        RequestModel(hash)
                    end
                    RequestModel(hash)
                    local data = {}
                    data.id = Config.FarmPlants[i].id
                    data.obj = CreateObject(hash, Config.FarmPlants[i].x, Config.FarmPlants[i].y, Config.FarmPlants[i].z -1.2, false, false, false) 
                    SetEntityAsMissionEntity(data.obj, true)
                    FreezeEntityPosition(data.obj, true)
                    table.insert(SpawnedPlants, data)
                    hasSpawned = false
                end
            end
        end
        if not InRange then
            Wait(5000)
        end
    end
end)

-- destroy plant
function DestroyPlant()
    local plant = GetClosestPlant()
    local hasDone = false
    for k, v in pairs(HarvestedPlants) do
        if v == plant.id then
            hasDone = true
        end
    end
    if not hasDone then
        table.insert(HarvestedPlants, plant.id)
        local ped = PlayerPedId()
        isDoingAction = true
        TriggerServerEvent('rsg-farmer:server:plantHasBeenHarvested', plant.id)
        TaskStartScenarioInPlace(ped, `WORLD_HUMAN_CROUCH_INSPECT`, 0, true)
        Wait(5000)
        ClearPedTasks(ped)
        SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
        TriggerServerEvent('rsg-farmer:server:destroyPlant', plant.id)
        isDoingAction = false
        canHarvest = true
    else
        QRCore.Functions.Notify('error', 'error')
    end
end

-- havest plants
function HarvestPlant()
    local plant = GetClosestPlant()
    local hasDone = false
    for k, v in pairs(HarvestedPlants) do
        if v == plant.id then
            hasDone = true
        end
    end
    if not hasDone then
        table.insert(HarvestedPlants, plant.id)
        local ped = PlayerPedId()
        isDoingAction = true
        TriggerServerEvent('rsg-farmer:server:plantHasBeenHarvested', plant.id)
        TaskStartScenarioInPlace(ped, `WORLD_HUMAN_CROUCH_INSPECT`, 0, true)
        Wait(10000)
        ClearPedTasks(ped)
        SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
        TriggerServerEvent('rsg-farmer:server:harvestPlant', plant.id)
        isDoingAction = false
        canHarvest = true
    else
        QRCore.Functions.Notify('error', 'error')
    end
end

function RemovePlantFromTable(plantId)
    for k, v in pairs(Config.FarmPlants) do
        if v.id == plantId then
            table.remove(Config.FarmPlants, k)
        end
    end
end

-- trigger actions
Citizen.CreateThread(function()
    while true do
        Wait(0)
        local InRange = false
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        for k, v in pairs(Config.FarmPlants) do
            if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, v.x, v.y, v.z, true) < 1.3 and not isDoingAction and not v.beingHarvested and not IsPedInAnyVehicle(PlayerPedId(), false) then
                if PlayerJob.name == 'police' then
                    local plant = GetClosestPlant()
                    DrawText3D(v.x, v.y, v.z, 'Thirst: ' .. v.thirst .. '% - Hunger: ' .. v.hunger .. '%')
                    DrawText3D(v.x, v.y, v.z - 0.18, 'Growth: ' ..  v.growth .. '% -  Quality: ' .. v.quality.. '%')
                    DrawText3D(v.x, v.y, v.z - 0.36, 'Destroy Plant [G]')
                    if IsControlJustPressed(0, QRCore.Shared.Keybinds['G']) then
                        if v.id == plant.id then
                            DestroyPlant()
                        end
                    end
                else
                    if v.growth < 100 then
                        local plant = GetClosestPlant()
                        DrawText3D(v.x, v.y, v.z, 'Thirst: ' .. v.thirst .. '% - Hunger: ' .. v.hunger .. '%')
                        DrawText3D(v.x, v.y, v.z - 0.18, 'Growth: ' ..  v.growth .. '% -  Quality: ' .. v.quality.. '%')
                        DrawText3D(v.x, v.y, v.z - 0.36, 'Water [G] : Feed [J]')
                        if IsControlJustPressed(0, QRCore.Shared.Keybinds['G']) then
                            if v.id == plant.id then
                                TriggerEvent('rsg-farmer:client:waterPlant')
                            end
                        elseif IsControlJustPressed(0, QRCore.Shared.Keybinds['J']) then
                            if v.id == plant.id then
                                TriggerEvent('rsg-farmer:client:feedPlant')
                            end
                        end
                    else
                        DrawText3D(v.x, v.y, v.z, '[Quality: ' .. v.quality .. ']')
                        DrawText3D(v.x, v.y, v.z - 0.18, 'Harvest [E]')
                        if IsControlJustReleased(0, QRCore.Shared.Keybinds['E']) and canHarvest then
                            local plant = GetClosestPlant()
                            local callpolice = math.random(1,100)
                            if v.id == plant.id then
                                HarvestPlant()
                                if callpolice > 95 then
                                    local coords = GetEntityCoords(PlayerPedId())
                                    -- alert police action here
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

function GetClosestPlant()
    local dist = 1000
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local plant = {}
    for i = 1, #Config.FarmPlants do
        local xd = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.FarmPlants[i].x, Config.FarmPlants[i].y, Config.FarmPlants[i].z, true)
        if xd < dist then
            dist = xd
            plant = Config.FarmPlants[i]
        end
    end
    return plant
end

-- remove plant object
RegisterNetEvent('rsg-farmer:client:removePlantObject')
AddEventHandler('rsg-farmer:client:removePlantObject', function(plant)
    for i = 1, #SpawnedPlants do
        local o = SpawnedPlants[i]
        if o.id == plant then
            SetEntityAsMissionEntity(o.obj, false)
            FreezeEntityPosition(o.obj, false)
            DeleteObject(o.obj)
        end
    end
end)

-- water plants
RegisterNetEvent('rsg-farmer:client:waterPlant')
AddEventHandler('rsg-farmer:client:waterPlant', function()
    local entity = nil
    local plant = GetClosestPlant()
    local ped = PlayerPedId()
    isDoingAction = true
    for k, v in pairs(SpawnedPlants) do
        if v.id == plant.id then
            entity = v.obj
        end
    end
    local hasItem1 = QRCore.Functions.HasItem('water', 1)
    local hasItem2 = QRCore.Functions.HasItem('bucket', 1)
    if hasItem1 and hasItem2 then
        Citizen.InvokeNative(0x5AD23D40115353AC, ped, entity, -1)
        TaskStartScenarioInPlace(ped, `WORLD_HUMAN_BUCKET_POUR_LOW`, 0, true)
        Wait(10000)
        ClearPedTasks(ped)
        SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
        TriggerServerEvent('rsg-farmer:server:waterPlant', plant.id)
        isDoingAction = false
    else
        QRCore.Functions.Notify('You don\'t have the required items!', 'error')
        Wait(5000)
        isDoingAction = false
    end
end)

-- feed plants
RegisterNetEvent('rsg-farmer:client:feedPlant')
AddEventHandler('rsg-farmer:client:feedPlant', function()
    local entity = nil
    local plant = GetClosestPlant()
    local ped = PlayerPedId()
    isDoingAction = true
    for k, v in pairs(SpawnedPlants) do
        if v.id == plant.id then
            entity = v.obj
        end
    end
    local hasItem1 = QRCore.Functions.HasItem('fertilizer', 1)
    local hasItem2 = QRCore.Functions.HasItem('bucket', 1)
    if hasItem1 and hasItem2 then
        Citizen.InvokeNative(0x5AD23D40115353AC, ped, entity, -1)
        TaskStartScenarioInPlace(ped, `WORLD_HUMAN_FEED_PIGS`, 0, true)
        Wait(14000)
        ClearPedTasks(ped)
        SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
        TriggerServerEvent('rsg-farmer:server:feedPlant', plant.id)
        isDoingAction = false
    else
        QRCore.Functions.Notify('You don\'t have the required items!', 'error')
        Wait(5000)
        isDoingAction = false
    end
end)

RegisterNetEvent('rsg-farmer:client:updatePlantData')
AddEventHandler('rsg-farmer:client:updatePlantData', function(data)
    Config.FarmPlants = data
end)

-- plant seeds
RegisterNetEvent('rsg-farmer:client:plantNewSeed')
AddEventHandler('rsg-farmer:client:plantNewSeed', function(planttype, hash, seed)
    -- if farming zones are on (true)
    if Config.UseFarmingZones == true then
        if Config.EnableJob == true then
            local PlayerJob = QRCore.Functions.GetPlayerData().job.name
            if PlayerJob == Config.JobRequired then
                if inFarmZone == true then
                    local pos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, 0.0)
                    local ped = PlayerPedId()
                    if CanPlantSeedHere(pos) and not IsPedInAnyVehicle(PlayerPedId(), false) and isBusy == false then
                        isBusy = true
                        TaskStartScenarioInPlace(ped, `WORLD_HUMAN_FARMER_RAKE`, 0, true)
                        Wait(10000)
                        ClearPedTasks(ped)
                        SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
                        TaskStartScenarioInPlace(ped, `WORLD_HUMAN_FARMER_WEEDING`, 0, true)
                        Wait(20000)
                        ClearPedTasks(ped)
                        SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
                        TriggerServerEvent('rsg-farmer:server:removeitem', seed, 1)
                        TriggerServerEvent('rsg-farmer:server:plantNewSeed', planttype, pos, hash)
                        isBusy = false
                    else
                        QRCore.Functions.Notify('too close to another plant!', 'error')
                    end
                else
                    QRCore.Functions.Notify('you are not in a farming zone!', 'error')
                end
            else
                QRCore.Functions.Notify('only farmers can plant seeds!', 'error')
            end
        else
            if inFarmZone == true then
                local pos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, 0.0)
                local ped = PlayerPedId()
                if CanPlantSeedHere(pos) and not IsPedInAnyVehicle(PlayerPedId(), false) and isBusy == false then
                    isBusy = true
                    TaskStartScenarioInPlace(ped, `WORLD_HUMAN_FARMER_RAKE`, 0, true)
                    Wait(10000)
                    ClearPedTasks(ped)
                    SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
                    TaskStartScenarioInPlace(ped, `WORLD_HUMAN_FARMER_WEEDING`, 0, true)
                    Wait(20000)
                    ClearPedTasks(ped)
                    SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
                    TriggerServerEvent('rsg-farmer:server:removeitem', seed, 1)
                    TriggerServerEvent('rsg-farmer:server:plantNewSeed', planttype, pos, hash)
                    isBusy = false
                else
                    QRCore.Functions.Notify('too close to another plant!', 'error')
                end
            else
                QRCore.Functions.Notify('you are not in a farming zone!', 'error')
            end
        end
    else
        -- if farming zones are off (false)
        if Config.EnableJob == true then
            local PlayerJob = QRCore.Functions.GetPlayerData().job.name
            if PlayerJob == Config.JobRequired then
                local pos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, 0.0)
                local ped = PlayerPedId()
                if CanPlantSeedHere(pos) and not IsPedInAnyVehicle(PlayerPedId(), false) and isBusy == false then
                    isBusy = true
                    TaskStartScenarioInPlace(ped, `WORLD_HUMAN_FARMER_RAKE`, 0, true)
                    Wait(10000)
                    ClearPedTasks(ped)
                    SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
                    TaskStartScenarioInPlace(ped, `WORLD_HUMAN_FARMER_WEEDING`, 0, true)
                    Wait(20000)
                    ClearPedTasks(ped)
                    SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
                    TriggerServerEvent('rsg-farmer:server:removeitem', seed, 1)
                    TriggerServerEvent('rsg-farmer:server:plantNewSeed', planttype, pos, hash)
                    isBusy = false
                else
                    QRCore.Functions.Notify('too close to another plant!', 'error')
                end
            end
        else
            local pos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, 0.0)
            local ped = PlayerPedId()
            if CanPlantSeedHere(pos) and not IsPedInAnyVehicle(PlayerPedId(), false) and isBusy == false then
                isBusy = true
                TaskStartScenarioInPlace(ped, `WORLD_HUMAN_FARMER_RAKE`, 0, true)
                Wait(10000)
                ClearPedTasks(ped)
                SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
                TaskStartScenarioInPlace(ped, `WORLD_HUMAN_FARMER_WEEDING`, 0, true)
                Wait(20000)
                ClearPedTasks(ped)
                SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
                TriggerServerEvent('rsg-farmer:server:removeitem', seed, 1)
                TriggerServerEvent('rsg-farmer:server:plantNewSeed', planttype, pos, hash)
                isBusy = false
            else
                QRCore.Functions.Notify('too close to another plant!', 'error')
            end
        end
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)
    SetTextScale(0.25, 0.25)
    SetTextFontForCurrentCommand(9)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str,_x,_y)
end

function CanPlantSeedHere(pos)
    local canPlant = true
    for i = 1, #Config.FarmPlants do
        if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.FarmPlants[i].x, Config.FarmPlants[i].y, Config.FarmPlants[i].z, true) < 1.3 then
            canPlant = false
        end
    end
    return canPlant
end

-- start farm shop
Citizen.CreateThread(function()
    if Config.EnableJob == true then
        local PlayerJob = QRCore.Functions.GetPlayerData().job.name
        if PlayerJob == Config.JobRequired then
            for farmshop, v in pairs(Config.FarmShopLocations) do
                exports['qr-core']:createPrompt(v.name, v.coords, 0xF3830D8E, 'Open ' .. v.name, {
                    type = 'client',
                    event = 'rsg-farmer:client:OpenFarmShop',
                })
                if v.showblip == true then
                    local FarmShopBlip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, v.coords)
                    SetBlipSprite(FarmShopBlip, GetHashKey(Config.Blip.blipSprite), true)
                    SetBlipScale(FarmShopBlip, Config.Blip.blipScale)
                    Citizen.InvokeNative(0x9CB1A1623062F402, FarmShopBlip, Config.Blip.blipName)
                end
            end
        end
    else
        for farmshop, v in pairs(Config.FarmShopLocations) do
            exports['qr-core']:createPrompt(v.name, v.coords, 0xF3830D8E, 'Open ' .. v.name, {
                type = 'client',
                event = 'rsg-farmer:client:OpenFarmShop',
            })
            if v.showblip == true then
                local FarmShopBlip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, v.coords)
                SetBlipSprite(FarmShopBlip, GetHashKey(Config.Blip.blipSprite), true)
                SetBlipScale(FarmShopBlip, Config.Blip.blipScale)
                Citizen.InvokeNative(0x9CB1A1623062F402, FarmShopBlip, Config.Blip.blipName)
            end
        end
    end
end)

-- draw marker if set to true in config
CreateThread(function()
    while true do
        local sleep = 0
        if Config.EnableJob == true and LocalPlayer.state.isLoggedIn then
            local PlayerJob = QRCore.Functions.GetPlayerData().job.name
            if PlayerJob == Config.JobRequired then
                for farmshop, v in pairs(Config.FarmShopLocations) do
                    if v.showmarker == true then
                        Citizen.InvokeNative(0x2A32FAA57B937173, 0x07DCE236, v.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 215, 0, 155, false, false, false, 1, false, false, false)
                    end
                end
            end
        else
            for farmshop, v in pairs(Config.FarmShopLocations) do
                if v.showmarker == true then
                    Citizen.InvokeNative(0x2A32FAA57B937173, 0x07DCE236, v.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 215, 0, 155, false, false, false, 1, false, false, false)
                end
            end
        end
        Wait(sleep)
    end
end)

RegisterNetEvent('rsg-farmer:client:OpenFarmShop')
AddEventHandler('rsg-farmer:client:OpenFarmShop', function()
    local ShopItems = {}
    ShopItems.label = "Farm Shop"
    ShopItems.items = Config.FarmShop
    ShopItems.slots = #Config.FarmShop
    TriggerServerEvent("inventory:server:OpenInventory", "shop", "FarmShop_"..math.random(1, 99), ShopItems)
end)
-- end farm shop
