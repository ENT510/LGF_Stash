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
            return coords, placingObjectHeading
        end

        if IsControlJustPressed(0, 73) then
            DeleteEntity(object)
            Wait(0)
            Utils.activeRaycast = false
            return
        end
    end
end

Utils.isInRaycasting = function() return Utils.activeRaycast end

