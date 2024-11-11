local Config = require("Modules.shared.config")
local ox_inventory = exports["ox_inventory"]
Server = {}

RegisterNetEvent('LGF_Safe:SaveData', function(model, vec4, itemName)
    local SafeModel = model
    local Coords = json.encode({ x = vec4.x, y = vec4.y, z = vec4.z, w = vec4.w })
    local src = source
    local Placer = Utility.Core:GetIdentifier(src)
    local Weight = Config.ModelSafeData[SafeModel].Weight * 1000
    local Slot = Config.ModelSafeData[SafeModel].Slot
    local stashId = SvFunctions.generateUniqueStashId()
    local Label = ("Stash %s"):format(stashId)
    ox_inventory:RegisterStash(stashId, Label, Slot, Weight, nil)
    MySQL.insert('INSERT INTO lgf_stashData (stash_id, placer, coords, stash_prop) VALUES (?, ?, ?, ?)', { stashId, Placer, Coords, SafeModel })
    TriggerClientEvent("LGF_Safe.receiveSyncedObject", -1, Coords, model, stashId)
    print(("Safe stash created with ID %s for player %s"):format(stashId, Placer))
end)

function Server.getAllStashData()
    local result = MySQL.query.await('SELECT * FROM lgf_stashData')
    local StashData = {}
    if result then
        for i = 1, #result do
            local row = result[i]
            local startTime = os.nanotime()

            StashData[#StashData + 1] = {
                stash_id = row.stash_id,
                placer = row.placer,
                coords = row.coords,
                model_safe = row.stash_prop
            }

            local endTime = os.nanotime()
            local timeTaken = (endTime - startTime)
            Shared.Debug(("Execution time for stashID %s: %.3f nanoseconds."):format(row.stash_id, timeTaken))
        end
    end

    return StashData
end

function Server.requestStashID(vec4)
    local receivedCoords = { x = vec4.x, y = vec4.y, z = vec4.z, w = vec4.w }
    local result = MySQL.query.await('SELECT * FROM lgf_stashData')
    if result then
        for i = 1, #result do
            local row = result[i]
            local dbCoords = json.decode(row.coords)
            if Shared.matchCoords(receivedCoords, dbCoords) then
                return row.stash_id
            end
        end
    end
    return nil
end

AddEventHandler("onResourceStart", function(res)
    if GetCurrentResourceName() == res then
        local allStashData = Server.getAllStashData()
        if allStashData and #allStashData > 0 then
            for _, stash in ipairs(allStashData) do
                local stashId = stash.stash_id
                local model = stash.model_safe or "prop_ld_int_safe_01"
                local safeConfig = Config.ModelSafeData[model] or {}
                local Weight = safeConfig.Weight and safeConfig.Weight * 1000 or 5000
                local Slot = safeConfig.Slot or 30
                local Label = ("Stash %s"):format(stashId)
                ox_inventory:RegisterStash(stashId, Label, Slot, Weight, nil)
                -- Shared.Debug(("Recreated safe with ID %s and model %s at coordinates %s"):format(stashId, model, stash.coords))
            end
        else
            print("No stash data found in the database.")
        end
    end
end)

function Server.isOwnerStash(stashId, target)
    local playerIdentifier = Utility.Core:GetIdentifier(target)
    local result = MySQL.query.await('SELECT placer FROM lgf_stashData WHERE stash_id = ?', { stashId })

    if result and result[1] then
        local ownerIdentifier = result[1].placer
        return ownerIdentifier == playerIdentifier
    else
        print(("Stash ID %s not found."):format(stashId))
        return false
    end
end

function Server.updateStashCoords(stashId, newCoords)
    local src = source
    if not stashId or not newCoords then
        print("Invalid input parameters!")
        return
    end
    local coordsJson = json.encode({ x = newCoords.x, y = newCoords.y, z = newCoords.z, w = newCoords.w })
    MySQL.update('UPDATE lgf_stashData SET coords = ? WHERE stash_id = ?', { coordsJson, stashId })
    Shared.Debug(("Coordinates update requested for stash_id %s"):format(stashId))
    Shared.Notification("LGF_Stash", ("Coords Correctly Updated for safe whit stash ID %s"):format(stashId), "top-left",
        "info", src)
end

RegisterNetEvent('LGF_Safe:updateCoords', function(stashId, newCoords, invoker)
    local resourceInvoker = invoker
    if resourceInvoker ~= GetCurrentResourceName() then
        print(("Unauthorized event trigger attempt! Resource mismatch for stash update"))
        return
    end
    Server.updateStashCoords(stashId, newCoords)
end)

function Server.deleteAllStashes(source)
    local PlayerGroup = Utility.Core:GetGroup(source)
    if Config.AllowedGroup[PlayerGroup] then
        MySQL.update('DELETE FROM lgf_stashData', {}, function(error)
            TriggerClientEvent('LGF_Safe:ClearAllStashes', -1)
            Shared.Debug(("Player %s cleared all stashes."):format(Utility.Core:GetName(source)))
        end)
    else
        print(("Unauthorized access attempt: Player %s tried to execute 'clearStashes' without permission."):format(
        Utility.Core:GetName(source)))
    end
end

RegisterCommand(Config.Command.Private.ClearStash, function(source, args, rawCommand)
    Server.deleteAllStashes(source)
end)



ox_inventory:registerHook('swapItems', function(payload)
    local itemName = payload.fromSlot.name
    for _, safeData in pairs(Config.ModelSafeData) do
        if safeData.ItemName == itemName then
            if payload.toType == 'stash' then
                Shared.Debug(("Blocked move: Item '%s' matches a configured safe item and is being moved to a stash.")
                :format(itemName))
                return false
            end
        end
    end
    return true
end, {
    print = true,
})


function Server.deleteStashById(stashId)
    local result = MySQL.query.await('SELECT * FROM lgf_stashData WHERE stash_id = ?', { stashId })
    if result and result[1] then
        MySQL.update('DELETE FROM lgf_stashData WHERE stash_id = ?', { stashId })
        TriggerClientEvent('LGF_Safe:DeleteStash', -1, stashId)
        print(("Safe stash ID %s deleted."):format(stashId))
    else
        print(("Stash ID %s not found."):format(stashId))
    end
end

RegisterNetEvent("LGF_Stash.DeleteStashbyID", function(stashId)
    if not stashId then return end
    Server.deleteStashById(stashId)
end)

exports('deleteAllStashes', Server.deleteAllStashes)
exports("updateStashCoords", Server.updateStashCoords)
exports("getAllStashData", Server.getAllStashData)
exports("isOwnerStash", Server.isOwnerStash)
exports("requestStashID", Server.requestStashID)
exports("deleteStashById", Server.deleteStashById)
