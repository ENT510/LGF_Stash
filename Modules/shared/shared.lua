Utility = exports['LGF_Utility']:UtilityData()
Context = Utility:GetContext()
local ProviderNotification = "lgf_hud" -- "lgf_hud" "utility" "ox_lib"
Shared = {}

function Shared.matchCoords(coord1, coord2, tolerance)
    local tolerance = tolerance or 0.0001
    return math.abs(coord1.x - coord2.x) < tolerance and math.abs(coord1.y - coord2.y) < tolerance and
        math.abs(coord1.z - coord2.z) < tolerance and
        math.abs(coord1.w - coord2.w) < tolerance
end

function Shared.Debug(...)
    local args = { ... }
    local message = table.concat(args, " ")
    print(("[^5LGF-STASH^7] - %s"):format(message))
end

function Shared.Notification(title, message, position, type, src)
    local notificationType = type or "info"
    local notificationPosition = position or "top-left"
    local duration = 5000

    if Context == "client" then
        if ProviderNotification == "lgf_hud" then
            return exports.LGF_Hud:SendNotification({
                Type = notificationType,
                Message = message,
                Duration = duration,
                Title = title,
                Position = notificationPosition,
                Transition = 'slide-right'
            })
        elseif ProviderNotification == "ox_lib" then
            return lib.notify({
                title = title,
                description = message,
                type = notificationType,
                duration = duration,
                position = notificationPosition
            })
        end
    elseif Context == "server" then
        if not src then
            warn("'src' (target player ID) is required for server notifications.")
            return
        end

        if ProviderNotification == "lgf_hud" then
            return TriggerClientEvent('LGF_HUD:Notify:SendNotification', src, {
                Type = notificationType,
                Message = message,
                Duration = duration,
                Title = title,
                Position = notificationPosition,
                Transition = 'slide-right'
            })
        elseif ProviderNotification == "ox_lib" then
            return TriggerClientEvent('ox_lib:notify', src, {
                title = title,
                description = message,
                type = notificationType,
                duration = duration,
                position = notificationPosition
            })
        end
    end
    warn("Invalid context or provider configuration in Shared.Notification.")
end
