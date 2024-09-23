Config = {}

Config.DealerLocations = {
    vector4(880.9457, -1666.1385, 30.4403, 57.7815),
    vector4(1243.3549, -3196.9897, 6.0282, 267.4636),
    vector4(1436.3353, -2611.7878, 48.1993, 308.7459),
    vector4(1365.2190, -1721.0333, 65.6340, 16.7245),
    vector4(964.0812, -1033.9429, 40.8306, 273.6466),
    vector4(1056.5101, -733.0698, 57.1318, 139.8581),
    vector4(435.8956, 215.5638, 103.1656, 339.1335),
    vector4(-425.7484, 1123.3403, 325.8542, 342.1351),
    -- Add more locations as needed
}

Config.DealerCount = 4 -- Number of dealers to spawn at a time
Config.SwitchDelay = 60000 * 3 -- Delay in milliseconds before respawning dealers
Config.SellDuration = 1000 * 10

Config.DealerPedModel = "a_m_y_stwhi_02" -- Example ped model
Config.DrugItem = "lockpick" -- Item players can sell
Config.BlackMoneyItem = "black_money" -- Currency received
Config.SellPrice = 1500 -- Price per unit of drug
Config.Scenario = "WORLD_HUMAN_DRUG_DEALER"

Config.DealerMarkerItem = "klapphandy"
Config.BlipSize = 100.0
Config.BlipLastTime = 60000 * 15
Config.Blip = {
    Name = "Drogendealer",
    Color = 1,
    Sprite = 42,
}