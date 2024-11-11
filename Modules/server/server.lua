local Config = require("Modules.shared.config")
local ox_inventory = exports["ox_inventory"]
Server = {}

RegisterNetEvent('LGF_Safe:SaveData', function(model, vec4)
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


function Server.updateStashCoords(stashId, newCoords)
    local coordsJson = json.encode({ x = newCoords.x, y = newCoords.y, z = newCoords.z, w = newCoords.w })
    MySQL.update('UPDATE lgf_stashData SET coords = ? WHERE stash_id = ?', { coordsJson, stashId })
    print(("Coordinates updated successfully for stash_id %s"):format(stashId))
end

RegisterNetEvent('LGF_Safe:updateCoords', function(stashId, newCoords)
    Server.updateStashCoords(stashId, newCoords)
end)

exports("updateStashCoords", Server.updateStashCoords)
exports("getAllStashData", Server.getAllStashData)
