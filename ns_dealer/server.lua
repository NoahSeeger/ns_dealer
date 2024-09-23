ESX = exports["es_extended"]:getSharedObject()

local activeDealers = {}
local alreadyMarkedDealer = {}

local Item = Config.DealerMarkerItem
ESX.RegisterUsableItem(Item, function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerIdentifier = xPlayer.getIdentifier()

    if not alreadyMarkedDealer[playerIdentifier] then
                    -- Check if there are any active dealers
        if #activeDealers > 0 then
            -- Select a random dealer
            local randomIndex = math.random(1, #activeDealers)
            local dealerLocation = activeDealers[randomIndex]

            -- Trigger a client event to create the blip
            TriggerClientEvent('ns_dealer:markDealer', source, dealerLocation)
            alreadyMarkedDealer[playerIdentifier] = true
        else
            -- Notify the player if no dealers are active
            TriggerClientEvent('ox_lib:notify', source, {
                title = "Dealer Locator",
                icon = "map",
                position = "bottom-right",
                description = "No active dealers found.",
                type = "error"
            })
        end
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = "Dealer Locator",
            icon = "map",
            position = "bottom-right",
            description = "Du hast schon einen Tipp geholt.",
            type = "error"
        })
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    while true do

        -- Clear existing dealers
        TriggerClientEvent('ns_dealer:deleteDealer', -1)
        activeDealers = {}
        alreadyMarkedDealer = {}

        -- Randomly select dealer locations
        local selectedLocations = {}
        while #selectedLocations < Config.DealerCount do
            local randomIndex = math.random(1, #Config.DealerLocations)
            local location = Config.DealerLocations[randomIndex]

            if not selectedLocations[randomIndex] then
                selectedLocations[randomIndex] = true
                table.insert(activeDealers, location)
                print("Spawn Dealer at "..location)
                TriggerClientEvent('ns_dealer:createDealer', -1, location)
            end
        end

        Citizen.Wait(Config.SwitchDelay) -- Wait for the configured delay
    end
end)

RegisterServerEvent('ns_dealer:sellDrugs')
AddEventHandler('ns_dealer:sellDrugs', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local drugCount = xPlayer.getInventoryItem(Config.DrugItem).count

    if drugCount > 0 then
        local sellAmount = drugCount * Config.SellPrice
        xPlayer.removeInventoryItem(Config.DrugItem, drugCount)
        xPlayer.addAccountMoney(Config.BlackMoneyItem, sellAmount)

        TriggerClientEvent('ox_lib:notify', _source, {
            title = "Drogen Dealer",
            icon = "dollar-sign",
            position = "bottom-right",
            duration=9000,
            description = "Du hast " .. drugCount .. " " .. Config.DrugItem .. " für $" .. sellAmount .. " Schwarzgeld verkauft. ".."($"..Config.SellPrice.."/"..Config.DrugItem..")",
            type = "success"
        })
    else
        TriggerClientEvent('ox_lib:notify', _source, {
            title = "Drug Dealer",
            icon = "dollar-sign",
            position = "bottom-right",
            description = "You have no drugs to sell.",
            type = "error"
        })
    end
end)
