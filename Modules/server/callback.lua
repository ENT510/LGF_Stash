lib.callback.register("LGF_Safe.requestStashId", function(source, vec4)
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
end)


lib.callback.register("LGF_Safe.getAllStashData", function(source)
    return Server.getAllStashData()
end)
