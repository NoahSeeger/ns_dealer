ESX = exports["es_extended"]:getSharedObject()

local spawnedDealers = {}

RegisterNetEvent('ns_dealer:createDealer')
AddEventHandler('ns_dealer:createDealer', function(location)
    local model = GetHashKey(Config.DealerPedModel)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(100)
    end

    local ped = CreatePed(4, model, location.x, location.y, location.z-1, location.w, false, true)
    -- SetEntityAsMissionEntity(ped, true, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetEntityHeading(ped, location.w)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedDiesWhenInjured(ped, false)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatAttributes(ped, 17, true)

    table.insert(spawnedDealers, ped)
end)

RegisterNetEvent('ns_dealer:deleteDealer')
AddEventHandler('ns_dealer:deleteDealer', function()
    for _, ped in ipairs(spawnedDealers) do
        if DoesEntityExist(ped) then
            DeletePed(ped)
        end
    end
    spawnedDealers = {}
end)

RegisterNetEvent('ns_dealer:markDealer')
AddEventHandler('ns_dealer:markDealer', function(dealerLocation)
    -- Notify the player
    lib.notify({
        title = "Dealer Locator",
        icon = "map",
        position = "bottom-right",
        duration = 6000,
        description = "Ein Dealer hat dir seine ungefähre Position mitgeteilt. Suche Ihn!",
        type = "inform"
    })

    -- Randomize the blip center within a certain radius
    local randomOffset = math.random(-Config.BlipSize / 2, Config.BlipSize / 2)
    local randomX = dealerLocation.x + randomOffset
    local randomY = dealerLocation.y + randomOffset

    -- Create a blip on the map
    local radiusBlip = AddBlipForRadius(randomX, randomY, dealerLocation.z, Config.BlipSize)
    SetBlipColour(radiusBlip, Config.Blip.Color) -- Set the blip color (1 is red)
    SetBlipAlpha(radiusBlip, 128) -- Set the blip transparency

    local blip = AddBlipForCoord(randomX, randomY, dealerLocation.z)
    SetBlipSprite(blip, Config.Blip.Sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, Config.Blip.Color)
    SetBlipAsShortRange(blip, true)
    SetBlipRoute(blip, true)
    SetBlipRouteColour(blip, Config.Blip.Color)


    -- Optionally, add a timer to remove the blip after some time
    Citizen.CreateThread(function()
        Citizen.Wait(Config.BlipLastTime) -- Blip lasts for the configured time
        RemoveBlip(radiusBlip)
        RemoveBlip(blip)
    end)
end)

local wait = 1000

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(wait)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        local isNearDealer = false

        for _, dealer in ipairs(spawnedDealers) do
            local dealerCoords = GetEntityCoords(dealer)
            local distance = #(playerCoords - dealerCoords)

            if distance < 2.0 then
                isNearDealer = true
                DisplayHelpText("Drücke ~INPUT_CONTEXT~ um deine Drogen zu verkaufen")

                if IsControlJustReleased(0, 38) then -- E key
                    ESX.Progressbar("Verkaufen...", Config.SellDuration,{
                        FreezePlayer = true,
                        animation ={
                            type = "Scenario",
                            Scenario = Config.Scenario,
                        },
                        onFinish = function()
                            TriggerServerEvent('ns_dealer:sellDrugs')
                    end, onCancel = function()
                        lib.notify({
                            title = "Verkaufen Abgebrochen!",
                            icon = "dollar-sign",
                            position = "bottom-right",
                            type = "error"
                          })
                    end
                    })
                    
                end
            end
        end
        
        if isNearDealer then
            wait = 0
        else
            wait = 1000
        end
    end
end)

function DisplayHelpText(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end