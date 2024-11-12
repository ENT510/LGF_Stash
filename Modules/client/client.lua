AllSafes = {}
local Initialized = false
local SafeObject = {}
SafeObject.__index = SafeObject
local ox_inventory = exports["ox_inventory"]
local Config = require("Modules.shared.config")
local Anim = "base"
local Dict = "amb@world_human_tourist_map@male@base"
local PropsTablet = "prop_cs_tablet"


AddEventHandler("LGF_Utility:PlayerUnloaded", function(...)
    Shared.Debug("Player unloaded. Initializing stash cleanup.")
    if Initialized then
        initializeStash(false)
    end
end)

AddEventHandler("LGF_Utility:PlayerLoaded", function(...)
    if not Initialized then
        Shared.Debug("Player loaded. Stash initialization will start after a short delay.")
        Wait(3000)
        initializeStash(true)
    end
end)

function SafeObject:new(model, coords, stashId)
    local self = setmetatable({}, SafeObject)
    self.model = model or "prop_ld_int_safe_01"
    self.position = coords or vector4(0, 0, 0, 0)
    self.entity = nil
    self.netID = nil
    self.closest = 2.0
    self.distance = 4.0
    self.stashID = stashId or nil
    local object = self:initializeEntity()
    if not object then return nil end
    self.netID = NetworkGetNetworkIdFromEntity(object)
    self:addInteraction()
    return self
end

function SafeObject:initializeEntity()
    local success, model = Utility:RequestEntityModel(self.model, 5000)
    if not success then
        print("Failed to load model.")
        return nil
    end

    local obj = CreateObjectNoOffset(joaat(model), self.position.x, self.position.y, self.position.z, false, true, false)
    if DoesEntityExist(obj) then
        SetEntityHeading(obj, self.position.w)
        FreezeEntityPosition(obj, true)
        NetworkRegisterEntityAsNetworked(obj)
        SetModelAsNoLongerNeeded(model)
        PlaceObjectOnGroundProperly(obj)
        return obj
    else
        print("Failed to create the object.")
        return nil
    end
end

function SafeObject:updateCoordsForStash()
    local currentCoords = vector4(self.position.x, self.position.y, self.position.z, self.position.w)
    TriggerServerEvent('LGF_Safe:updateCoords', self.stashID, currentCoords, GetCurrentResourceName())
end

function SafeObject:addInteraction()
    local interactionID = exports.LGF_Interaction:addInteractionEntity({
        netID = self.netID,
        closest = self.closest,
        distance = self.distance,
        offsetCoords = vec3(0.0, 0.0, 1.0),
        debug = Config.EnableDebug,
        dataBind = {
            {
                index = 1,
                title = "Open Safe ",
                description = "Click to open the safe.",
                icon = "lock",
                onClick = function()
                    self:dataOpenSafe()
                end,
                canInteract = function(distance)
                    return distance < 3.0 and not Config.DeathCheck(Utility.Player:Ped()) and
                        not LocalPlayer.state.invOpen
                end
            },
            {
                index = 2,
                title = "Move Safe",
                description = "Click to move the safe.",
                icon = "arrows-alt",
                onClick = function(interaction)
                    if DoesEntityExist(NetworkGetEntityFromNetworkId(self.netID)) and NetworkDoesEntityExistWithNetworkId(self.netID) then
                        self:dataMoveSafe()
                    end
                end,
                canInteract = function(distance)
                    local isOwnerStash = lib.callback.await("LGF_Safe.isOwnerStash", false, self.stashID)
                    return distance < 3.0 and not Config.DeathCheck(Utility.Player:Ped()) and
                        not LocalPlayer.state.invOpen and isOwnerStash
                end
            },
            {
                index = 3,
                title = "Delete Safe ",
                description = "Click to delete the safe permanently.",
                icon = "trash",
                onClick = function(interaction)
                    TriggerEvent('LGF_Safe:DeleteStash', self.stashID, true)
                end,
                canInteract = function(distance)
                    local isOwnerStash = lib.callback.await("LGF_Safe.isOwnerStash", false, self.stashID)
                    return distance < 2.0 and isOwnerStash and not Config.DeathCheck(Utility.Player:Ped()) and
                        not LocalPlayer.state.invOpen
                end
            },
            {
                index = 4,
                title = "Show Safe GPS",
                description = "Click to see you safes in the GPS.",
                icon = "earth-americas",
                onClick = function(interaction)
                    local data = lib.callback.await("LGF_Safe.getStashDataOwner", 100)
                    self:GpsData(data)
                end,
                canInteract = function(distance)
                    local isOwnerStash = lib.callback.await("LGF_Safe.isOwnerStash", false, self.stashID)
                    return distance < 2.0 and isOwnerStash and not Config.DeathCheck(Utility.Player:Ped()) and
                        not LocalPlayer.state.invOpen
                end
            },
        },
    })
end

function SafeObject:dataOpenSafe()
    local CurrentStashID = lib.callback.await("LGF_Safe.requestStashId", false, self.position)
    if not CurrentStashID then return end
    local isOwnerStash = lib.callback.await("LGF_Safe.isOwnerStash", false, CurrentStashID)
    if not isOwnerStash then
        if Config.MiniGameType == "ox_lib" then
            local success = Config.MiniGameSteal?.ox_lib()
            if success then
                ox_inventory:openInventory('stash', CurrentStashID)
            end
        elseif Config.MiniGameType == "bl_ui" then
            local success = Config.MiniGameSteal?.bl_ui()
            if success then
                ox_inventory:openInventory('stash', CurrentStashID)
            end
        end
    else
        ox_inventory:openInventory('stash', CurrentStashID)
    end
end

function SafeObject:dataMoveSafe()
    Utils.StartBinderControl()

    local Prop = Utils.StartPlayerAnim(Anim, Dict, PropsTablet)
    SetTimeout(1000, function()
        local newCoords, newHeading = Utils.PlaceObject(self.model, 10.0)
        if newCoords then
            self.position = vector4(newCoords.x, newCoords.y, newCoords.z, newHeading)
            local newObject = self:initializeEntity()
            if newObject then
                
                if self.netID then
                    exports.LGF_Interaction:removeInteractionEntity(self.netID)
                    local entity = NetworkGetEntityFromNetworkId(self.netID)
                    if DoesEntityExist(entity) then DeleteEntity(entity) end
                    self.netID = nil
                end

                self.netID = NetworkGetNetworkIdFromEntity(newObject)
                self:addInteraction()
                self:updateCoordsForStash()

                Utils.ClearPed(Prop)

                if exports.LGF_Utility:getStateInteraction() then
                    exports.LGF_Utility:closeInteraction()
                end
            end
        end
    end)
end

RegisterNetEvent("LGF_Safe.receiveSyncedObject", function(coords, Props, stashId)
    if not coords or not stashId then return end
    if not Props then Props = "prop_ld_int_safe_01" end
    local decodeCoords = json.decode(coords)
    local FormattedCoords = vector4(decodeCoords.x, decodeCoords.y, decodeCoords.z, decodeCoords.w)
    local safe = SafeObject:new(Props, FormattedCoords, stashId)
    if safe then
        table.insert(AllSafes, safe)
        Shared.Notification("LGF_Stash", ("Safe Placed Correctly whit stash ID %s"):format(stashId), "top-left", "info")
    end
end)


exports('setCurrentStash', function(data, slot)
    local reverseConfigLookup = { ["little_safe"] = "prop_ld_int_safe_01", ["medium_safe"] = "p_v_43_safe_s", }
    local propName = reverseConfigLookup[data.name]
    if propName then
        local safeData = Config.ModelSafeData[propName]
        Utils.StartBinderControl()
        if safeData then
            local coords, heading = Utils.PlaceObject(propName, 10.0)
            if coords then
                local formattedCoords = vec4(coords.x, coords.y, coords.z, heading)
                TriggerServerEvent('LGF_Safe:SaveData', propName, formattedCoords, data.name)
                exports.LGF_Utility:closeInteraction()
            end
        end
    end
end)


local function clearStashData()
    for _, safe in ipairs(AllSafes) do
        if safe.netID then
            exports.LGF_Interaction:removeInteractionEntity(safe.netID)
            local entity = NetworkGetEntityFromNetworkId(safe.netID)
            if DoesEntityExist(entity) then
                DeleteEntity(entity)
                print(entity)
            end
        end
    end
    AllSafes = {}
    Initialized = false
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        clearStashData()
        if exports.LGF_Utility:getStateInteraction() then
            exports.LGF_Utility:closeInteraction()
        end
    end
end)


RegisterNetEvent('LGF_Safe:ClearAllStashes', clearStashData)

function initializeStash(state)
    if Initialized and state == true then
        Shared.Debug("Stash initialization attempted, but it has already been initialized. No further action required.")
        return
    end

    if not Initialized and state == false then
        Shared.Debug("Stash initialization attempted, but it has already not initialized. No further action required.")
        return
    end

    if state == true then
        local AllStashData = lib.callback.await("LGF_Safe.getAllStashData", false)
        if AllStashData then
            for i = 1, #AllStashData do
                local stash = AllStashData[i]
                local model = stash.model_safe or "prop_ld_int_safe_01"
                local coords = json.decode(stash.coords) or vector4(0, 0, 0, 0)
                local stashId = stash.stash_id
                Shared.Debug(("Processing stash with ID: %s, Model: %s, Coordinates: %s"):format(stashId, model,
                    json.encode(coords)))
                local safe = SafeObject:new(model, coords, stashId)
                if safe then
                    table.insert(AllSafes, safe)
                end
            end
            Initialized = true
        end
    elseif state == false then
        Shared.Debug("Cleaning up stash data...")
        clearStashData()
        Shared.Debug("Stash data cleared successfully.")
    end
end

RegisterNetEvent('LGF_Safe:DeleteStash', function(stashId, deleteQuery)
    for i, safe in ipairs(AllSafes) do
        if safe.stashID == stashId then
            exports.LGF_Interaction:removeInteractionEntity(safe.netID)
            local entity = NetworkGetEntityFromNetworkId(safe.netID)
            if DoesEntityExist(entity) then DeleteEntity(entity) end
            table.remove(AllSafes, i)
            if deleteQuery then
                TriggerServerEvent('LGF_Stash.DeleteStashbyID', stashId)
            end
            Shared.Notification("LGF_Stash", ("Safe with ID %s has been deleted."):format(stashId), "top-left", "info")
            break
        end
    end
end)

RegisterNetEvent("LGF_Safe.setupInitializedStash", function(state)
    initializeStash(state)
end)

function SafeObject:GpsData(data)
    local StashDatas = {}
    local HaveAGPS = {}
    for I = 1, #data do
        local StashData = data[I]
        local stashId = StashData.stash_id
        local coords = StashData.coords
        local haveGPS = StashData.gps

        HaveAGPS[stashId] = haveGPS
        if haveGPS then
            StashDatas[#StashDatas + 1] = {
                position = { coords.x, coords.y },
                popupText = ("Stash %s"):format(stashId),
                icon =
                "https://cdn.discordapp.com/attachments/1170475401223610490/1305948881795940403/icons8-safe-94.png?ex=6734e32c&is=673391ac&hm=94185bbb7b5946f320ecbb85104dc93a444772a00b3d5c523d48b5bee5a9ac1b&"
            }
        end
    end

    exports['LGF_Utility']:RegisterContextMenu(("stash_gps_%s"):format(GetCurrentResourceName()), "Safe GPS Location", {
        {
            label = "Set GPS for Current Stash",
            description = "Set GPS tracking for this stash.",
            icon = "star",
            labelButton = "Add",
            disabled = HaveAGPS[self.stashID],
            metadata = {
                title = "Stash Data",
                metadataValue = {
                    stashid = ("%s"):format(self.stashID),
                    object = ("%s"):format(self.model),
                    GPS = HaveAGPS[self.stashID] and "true" or "false",
                }
            },
            onSelect = function()
                local countGPS = ox_inventory:GetItemCount(Config.GpsItemName)
                if countGPS > 0 then
                    exports['LGF_Utility']:ShowContextMenu(("stash_gps_%s"):format(GetCurrentResourceName()), false)
                    Wait(300)
                    local Prop = Utils.StartPlayerAnim(Anim, Dict, PropsTablet)
                    exports["LGF_Utility"]:CreateProgressBar({
                        message = ("Placing GPS on stash %s"):format(self.stashID),
                        colorProgress = "rgba(54, 156, 129, 0.381)",
                        position = "bottom",
                        duration = 5000,
                        transition = "fade",
                        disableBind = false,
                        disableKeyBind = { 24, 32, 33, 34, 30, 31, 36, 21 },
                        onFinish = function()
                            TriggerServerEvent("LGF_Stash.setGpsToStash", Config.GpsItemName, self.stashID)
                            Utils.ClearPed(Prop)
                            Shared.Notification("LGF_Stash",
                                ("You have correctly place the gps for the stash with id %s."):format(self.stashID),
                                "top-left", "success")
                        end,
                    })
                else
                    Shared.Notification("LGF_Stash", ("You don't have enough %s."):format(Config.GpsItemName), "top-left",
                        "error")
                end
            end
        },
        {
            label = "Remove GPS from Current Stash",
            labelButton = "Remove",
            description = "Remove GPS tracking from this stash.",
            icon = "close",
            disabled = not HaveAGPS[self.stashID],
            onSelect = function()
                exports['LGF_Utility']:ShowContextMenu(("stash_gps_%s"):format(GetCurrentResourceName()), false)
                Wait(300)
                local Prop = Utils.StartPlayerAnim(Anim, Dict, PropsTablet)
                exports["LGF_Utility"]:CreateProgressBar({
                    message = ("Removing GPS from stash %s"):format(self.stashID),
                    colorProgress = "rgba(255, 0, 0, 0.381)",
                    position = "bottom",
                    duration = 5000,
                    transition = "fade",
                    disableBind = false,
                    disableKeyBind = { 24, 32, 33, 34, 30, 31, 36, 21 },
                    onFinish = function()
                        TriggerServerEvent("LGF_Stash.removeGpsFromStash", self.stashID)
                        Utils.ClearPed(Prop)
                    end,
                })
            end
        },
        {
            label = "View on Map",
            description = "See the stash's location on the map.",
            icon = "map",
            disabled = true,
            map = {
                markers = StashDatas
            }
        }
    })

    exports['LGF_Utility']:ShowContextMenu(("stash_gps_%s"):format(GetCurrentResourceName()), true)
end

local function openTablet(data)
    local StashDatas = {}
    for i = 1, #data do
        local StashData = data[i]
        local stashId = StashData.stash_id
        local coords = StashData.coords
        if StashData.gps then
            StashDatas[#StashDatas + 1] = {
                position = { coords.x, coords.y },
                popupText = ("Stash %s"):format(stashId),
                icon =
                "https://cdn.discordapp.com/attachments/1170475401223610490/1305948881795940403/icons8-safe-94.png?ex=6734e32c&is=673391ac&hm=94185bbb7b5946f320ecbb85104dc93a444772a00b3d5c523d48b5bee5a9ac1b&"
            }
        end
    end

    exports['LGF_Utility']:RegisterContextMenu(("stash_gps_view_%s"):format(GetCurrentResourceName()),
        "All Stash Locations", {
            {
                label = "View on Map",
                description = "See all stashes' locations on the map.",
                icon = "map",
                disabled = true,
                map = {
                    markers = StashDatas
                }
            }
        })

    exports['LGF_Utility']:ShowContextMenu(("stash_gps_view_%s"):format(GetCurrentResourceName()), true)
end

local function openGpsTablet()
    local data = lib.callback.await("LGF_Safe.getStashDataOwner", 100)
    if not data then data = {} end
    local Prop = Utils.StartPlayerAnim(Anim, Dict, PropsTablet)
    openTablet(data)
    while exports['LGF_Utility']:GetContextState() == true do Wait(600) end
    if Prop and DoesEntityExist(Prop) then
        Utils.ClearPed(Prop)
    end
end


exports("openGpsTablet", openGpsTablet)
exports("initializeAllStash", initializeStash)


if Config.EnableDebug then
    RegisterCommand(Config.Command.Public.OpenGps, openGpsTablet)
end
