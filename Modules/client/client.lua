AllSafes = {}
local Initialized = false
local SafeObject = {}
SafeObject.__index = SafeObject
local ox_inventory = exports["ox_inventory"]
local Config = require("Modules.shared.config")

AddEventHandler("LGF_Utility:PlayerUnloaded", function(playerId)
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

CreateThread(function()
    initializeStash(true)
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
    if not success then return nil end

    local obj = CreateObject(model, self.position.x, self.position.y, self.position.z, true, false)
    if DoesEntityExist(obj) then
        SetEntityHeading(obj, self.position.w)
        FreezeEntityPosition(obj, true)
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
        dataBind = {
            {
                index = 1,
                title = ("Open Safe %s"):format(self.stashID),
                description = "Click to open the safe.",
                icon = "lock",
                onClick = function()
                    self:dataOpenSafe()
                end,
                canInteract = function(distance)
                    return distance < 3.0
                end
            },
            {
                index = 2,
                title = ("Move Safe %s"):format(self.stashID),
                description = "Click to move the safe.",
                icon = "arrows-alt",
                onClick = function(interaction)
                    if DoesEntityExist(interaction.entity) and NetworkDoesEntityExistWithNetworkId(interaction.netID) then
                        self:dataMoveSafe()
                    end
                end,
                canInteract = function(distance)
                    return distance < 3.0
                end
            },
            {
                index = 3,
                title = ("Delete Safe %s"):format(self.stashID),
                description = "Click to delete the safe permanently.",
                icon = "trash",
                onClick = function(interaction)
                    TriggerEvent('LGF_Safe:DeleteStash', self.stashID, true)
                end,
                canInteract = function(distance)
                    local isOwnerStash = lib.callback.await("LGF_Safe.isOwnerStash", false, self.stashID)
                    print(isOwnerStash)
                    return distance < 2.0 and isOwnerStash
                end
            }
        },
        onEnter = function(self)
            print(self.id)
        end,
        onExit = function(self)
            print(self.id)
        end,

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
    if self.netID then
        exports.LGF_Interaction:removeInteractionEntity(self.netID)
        local entity = NetworkGetEntityFromNetworkId(self.netID)
        if DoesEntityExist(entity) then DeleteEntity(entity) end
        self.netID = nil
    end

    SetTimeout(1000, function()
        local newCoords, newHeading = Utils.PlaceObject(self.model, 10.0)
        if newCoords then
            self.position = vector4(newCoords.x, newCoords.y, newCoords.z, newHeading)
            local newObject = self:initializeEntity()
            if newObject then
                self.netID = NetworkGetNetworkIdFromEntity(newObject)
                self:addInteraction()
                self:updateCoordsForStash()
            end
        end
    end)
end

RegisterNetEvent("LGF_Safe.receiveSyncedObject", function(coords, Props, stashId)
    if not coords or not stashId then return end
    if not Props then Props = "prop_ld_int_safe_01" end
    local decodeCoords = json.decode(coords)
    local FormattedCoords = vector4(decodeCoords.x, decodeCoords.y, decodeCoords.z, decodeCoords.w)
    print(FormattedCoords)
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

        if safeData then
            local coords, heading = Utils.PlaceObject(propName, 10.0)
            local formattedCoords = vec4(coords.x, coords.y, coords.z, heading)
            if coords then
                TriggerServerEvent('LGF_Safe:SaveData', propName, formattedCoords)
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
    end
end)

function initializeStash(state)
    if Initialized and state == true then
        Shared.Debug("Stash initialization attempted, but it has already been initialized. No further action required.")
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


exports("initializeAllStash", initializeStash)
