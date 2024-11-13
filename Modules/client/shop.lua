local Config = require("Modules.shared.config")
local activeInteractions = {}

for zoneID = 1, #Config.ShopNPCs do
    local data = Config.ShopNPCs[zoneID]
    local dataBind = {}

    for itemIndex = 1, #data.ShopItems do
        local item = data.ShopItems[itemIndex]
        dataBind[#dataBind + 1] = {
            index = itemIndex,
            title = item.Label,
            icon = item.Icon,
            description = item.Description,
            onClick = function(self)
                TriggerServerEvent("LGF_Stash.buyItems", Utility.Player:Index(), item.ItemName, item.Price)
            end,
            canInteract = function(distance, interactionid, myPed)
                return distance < 3.0 and not Config.DeathCheck(Utility.Player:Ped()) and not LocalPlayer.state.invOpen
            end
        }
    end

    local interactionID = exports.LGF_Interaction:addInteractionPed({
        Coords = data.Position,
        model = data.Model,
        pedID = data.PedID,
        dataBind = dataBind,
        offsetCoords = vec3(0, 0, 1.0),
        distance = 10,
        closest = 5.0,
        debug = Config.EnableDebug,
    })

    activeInteractions[data.PedID] = interactionID
end



AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for pedID, interactionID in pairs(activeInteractions) do
            exports.LGF_Interaction:removeInteractionPed(pedID, interactionID)
        end
    end
end)
