Utility = exports['LGF_Utility']:UtilityData()
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
    if not Config.EnableDebug then return end 
    print(("[^5LGF-STASH^7] - %s"):format(message))
end
