Utils = {}
Utils.activeRaycast = false

Utils.PlaceObject = function(objectHash, distance)
    local distance = distance or 10
    local success, model = Utility:RequestEntityModel(objectHash, 5000)


    if not success then
        exports.LGF_Utility:closeInteraction()
        return
    end

    local playerCoords = Utility.Player:Coords()
    local object = CreateObject(model, playerCoords.x, playerCoords.y, playerCoords.z, false, true, true)

    SetEntityAlpha(object, 170, false)
    SetEntityCollision(object, false, false)
    FreezeEntityPosition(object, true)
    SetModelAsNoLongerNeeded(model)
    DisableControlAction(0, 24, true)
    DisableControlAction(0, 25, true)
    DisableControlAction(0, 140, true)
    DisableControlAction(0, 141, true)
    DisableControlAction(0, 142, true)
    Utils.activeRaycast = true

    while true do
        Wait(0)
        local hit, entityHit, coords, surfaceNormal = Utility.RaycastHandler:performRaycast(distance, true, false)
        SetEntityCoords(object, coords.x, coords.y, coords.z)
        PlaceObjectOnGroundProperly(object)
        DisableControlAction(0, 24, true)
        local placingObjectHeading = GetEntityHeading(object)

        if IsControlPressed(0, 38) then SetEntityHeading(object, placingObjectHeading + 1.5) end
        if IsControlPressed(0, 44) then SetEntityHeading(object, placingObjectHeading - 1.5) end

        if IsControlJustPressed(0, 113) then
            PlaceObjectOnGroundProperly(object)
        end

        if IsControlJustPressed(0, 18) then
            DeleteEntity(object)
            Utils.activeRaycast = false
            exports.LGF_Utility:closeInteraction()
            return coords, placingObjectHeading
        end

        if IsControlJustPressed(0, 73) then
            DeleteEntity(object)
            Wait(0)
            Utils.activeRaycast = false
            exports.LGF_Utility:closeInteraction()
            return
        end
    end
end

Utils.isInRaycasting = function() return Utils.activeRaycast end

Utils.StartBinderControl = function()
    exports.LGF_Utility:interactionButton({
        Visible = true,
        Controls = {
            Bind1 = { key = "Q", label = "Rotate Left", description = "Use this key to rotate the Safe to the left." },
            Bind2 = { key = "E", label = "Rotate Right", description = "Use this key to rotate the Safe to the right." },
            Bind3 = { isMouse = true, label = "Place Safe", description = "Use left Click mouse to place the Safe." },
            Bind4 = { key = "X", label = "Cancel Placement", description = "Press this key to cancel the Safe placement." },
            Bind5 = { key = "G", label = "Force Ground", description = "Press to place the object on the ground properly." }
        },
        Schema = {
            Styles = {
                Position  = "bottom",
                Animation = "slide-up",
            },
        },
    })
end

function Utils.StartPlayerAnim(anim, dict, prop)
    local dict = lib.requestAnimDict(dict)
    local model = lib.requestModel(prop)
    local Ped = Utility.Player:Ped()
    local PlayerCoords = Utility.Player:Coords()
    TaskPlayAnim(Ped, dict, anim, 2.0, 2.0, -1, 51, 0, false, false, false)
    local props = CreateObject(model, PlayerCoords.x, PlayerCoords.y, PlayerCoords.z + 0.2, true, true, true)
    AttachEntityToEntity(props, Ped, GetPedBoneIndex(Ped, 28422), 0.0, -0.03, 0.0, 20.0, -90.0, 0.0, true, true, false, true, 1, true)
    return props
end

function Utils.ClearPed(Object)
    if Object and IsEntityPlayingAnim(cache.ped, 'amb@code_human_in_bus_passenger_idles@female@tablet@base', "base", 3) then
        DeleteEntity(Object)
        ClearPedTasks(cache.ped)
        Object = nil
    end
end
