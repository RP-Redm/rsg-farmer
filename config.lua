Config = Config or {}
Config.FarmPlants = {}

-- start plant settings
Config.GrowthTimer = 60000 -- 60000 = every 1 min / testing 1000 = 1 seconds
Config.StartingThirst = 100.0 -- starting plan thirst percentage
Config.StartingHunger = 100.0 -- starting plan hunger percentage
Config.HungerIncrease = 25.0 -- amount increased when watered
Config.ThirstIncrease = 25.0 -- amount increased when fertilizer is used
Config.Degrade = {min = 3, max = 5}
Config.QualityDegrade = {min = 8, max = 12}
Config.GrowthIncrease = {min = 10, max = 20}
Config.MaxPlantCount = 40 -- maximum plants play can have at any one time
Config.UseFarmingZones = true -- true = use farmzones / false = no farmzones

-- farm plants
Config.FarmItems = {
    {
        planttype = 'corn',
        item = 'corn',
        label = 'Corn',
        -- reward settings
        poorRewardMin = 1,
        poorRewardMax = 2,
        goodRewardMin = 3,
        goodRewardMax = 4,
        exellentRewardMin = 5,
        exellentRewardMax = 6,
    },
    {
        planttype = 'sugar',
        item = 'sugar',
        label = 'Sugar',
        -- reward settings
        poorRewardMin = 1,
        poorRewardMax = 2,
        goodRewardMin = 3,
        goodRewardMax = 4,
        exellentRewardMin = 5,
        exellentRewardMax = 6,
    },
    {
        planttype = 'tobacco',
        item = 'tobacco',
        label = 'Tobacco',
        -- reward settings
        poorRewardMin = 1,
        poorRewardMax = 2,
        goodRewardMin = 3,
        goodRewardMax = 4,
        exellentRewardMin = 5,
        exellentRewardMax = 6,
    },
    {
        planttype = 'carrot',
        item = 'carrot',
        label = 'Carrot',
        -- reward settings
        poorRewardMin = 1,
        poorRewardMax = 2,
        goodRewardMin = 3,
        goodRewardMax = 4,
        exellentRewardMin = 5,
        exellentRewardMax = 6,
    },
    {
        planttype = 'tomato',
        item = 'tomato',
        label = 'Tomato',
        -- reward settings
        poorRewardMin = 1,
        poorRewardMax = 2,
        goodRewardMin = 3,
        goodRewardMax = 4,
        exellentRewardMin = 5,
        exellentRewardMax = 6,
    },
    {
        planttype = 'broccoli',
        item = 'broccoli',
        label = 'Broccoli',
        -- reward settings
        poorRewardMin = 1,
        poorRewardMax = 2,
        goodRewardMin = 3,
        goodRewardMax = 4,
        exellentRewardMin = 5,
        exellentRewardMax = 6,
    },
    {
        planttype = 'potato',
        item = 'potato',
        label = 'Potato',
        -- reward settings
        poorRewardMin = 1,
        poorRewardMax = 2,
        goodRewardMin = 3,
        goodRewardMax = 4,
        exellentRewardMin = 5,
        exellentRewardMax = 6,
    },
}
-- end plant settings

Config.Blip = {
    blipName = 'Farm Shop', -- Config.Blip.blipName
    blipSprite = 'blip_shop_market_stall', -- Config.Blip.blipSprite
    blipScale = 0.2 -- Config.Blip.blipScale
}

-- farm shop
Config.FarmShop = {
     [1] = { name = "carrotseed",   price = 0.10, amount = 500,  info = {}, type = "item", slot = 1, },
     [2] = { name = "cornseed",     price = 0.10, amount = 500,  info = {}, type = "item", slot = 2, },
     [3] = { name = "sugarseed",    price = 0.10, amount = 500,  info = {}, type = "item", slot = 3, },
     [4] = { name = "tobaccoseed",  price = 0.10, amount = 500,  info = {}, type = "item", slot = 4, },
     [5] = { name = "tomatoseed",   price = 0.10, amount = 500,  info = {}, type = "item", slot = 5, },
     [6] = { name = "broccoliseed", price = 0.10, amount = 500,  info = {}, type = "item", slot = 6, },
     [7] = { name = "potatoseed",   price = 0.10, amount = 500,  info = {}, type = "item", slot = 7, },
     [8] = { name = "bucket",       price = 10,   amount = 50,   info = {}, type = "item", slot = 8, },
     [9] = { name = "fertilizer",   price = 0.10, amount = 5000, info = {}, type = "item", slot = 9, },
}

-- farm shop locations
Config.FarmShopLocations = {
    {name = 'Farm Shop', coords = vector3(-249.43, 685.72, 113.33), showblip = true},
}

-- farm shop npc
Config.FarmNpc = {
    [1] = { ["Model"] = "A_M_M_ValFarmer_01", ["Pos"] = vector3(-249.43, 685.72, 113.33 -1), ["Heading"] = 144.27 }, -- farmer market valentine
}

-- farm zone settings
Config.FarmZone = { 
    [1] = {
        zones = { -- example
            vector2(-347.09591674805, 894.11151123047),
            vector2(-390.92279052734, 889.30194091797),
            vector2(-392.01412963867, 911.32104492188),
            vector2(-373.91583251953, 913.11346435547),
            vector2(-369.53713989258, 944.28149414063),
            vector2(-349.36514282227, 941.19653320313)
        },
        name = "farmzone1",
        minZ = 115.78807830811,
        maxZ = 122.06151580811,
        showblip = true,
        blipcoords = vector3(-375.72, 900.24, 116.08)
    },
}
