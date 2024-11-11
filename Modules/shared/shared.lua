if not lib.checkDependency('LGF_Utility', '1.0.7') or not GetResourceState("LGF_Utility"):find("start") then
    error("Missing or inactive LGF_Utility resource. Please ensure min version 1.0.7 is installed and started.")
    return
end

local Config = require("Modules.shared.config")
Utility = exports['LGF_Utility']:UtilityData()
Context = Utility:GetContext()
local ProviderNotification = Config.ProviderNotification
Shared = {}

function Shared.matchCoords(coord1, coord2, tolerance)
    local tolerance = tolerance or 0.0001
    return math.abs(coord1.x - coord2.x) < tolerance and math.abs(coord1.y - coord2.y) < tolerance and
        math.abs(coord1.z - coord2.z) < tolerance and
        math.abs(coord1.w - coord2.w) < tolerance
end

function Shared.Debug(...)
    local message = table.concat({ ... }, " ")
    print(("[^5LGF-STASH^7] - %s"):format(message))
end

function Shared.Notification(title, message, position, type, src)
    local notificationType = type or "info"
    local notificationPosition = position or "top-left"
    local duration = 5000

    if Context == "client" then
        if ProviderNotification == "utility" then
            exports.LGF_Utility:SendNotification({
                id = math.random(100000, 333333),
                title = title,
                message = message,
                icon = notificationType,
                duration = duration,
                position = notificationPosition,
            })
        elseif ProviderNotification == "lgf_hud" then
            exports.LGF_Hud:SendNotification({
                Type = notificationType,
                Message = message,
                Duration = duration,
                Title = title,
                Position = notificationPosition,
                Transition = 'slide-right'
            })
        elseif ProviderNotification == "ox_lib" then
            lib.notify({
                title = title,
                description = message,
                type = notificationType,
                duration = duration,
                position = notificationPosition
            })
        end
    elseif Context == "server" then

        if not src then warn("'src' (target player ID) is required for server notifications.")  return end

        if ProviderNotification == "utility" then
            TriggerClientEvent('LGF_Utility:SendNotification', src, {
                id = math.random(100000, 333333),
                title = title,
                message = message,
                icon = notificationType,
                duration = duration,
                position = notificationPosition,
            })
        elseif ProviderNotification == "lgf_hud" then
            TriggerClientEvent('LGF_HUD:Notify:SendNotification', src, {
                Type = notificationType,
                Message = message,
                Duration = duration,
                Title = title,
                Position = notificationPosition,
                Transition = 'slide-right'
            })
        elseif ProviderNotification == "ox_lib" then
            TriggerClientEvent('ox_lib:notify', src, {
                title = title,
                description = message,
                type = notificationType,
                duration = duration,
                position = notificationPosition
            })
        end
    end
end
