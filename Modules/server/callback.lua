lib.callback.register("LGF_Safe.requestStashId", function(source, vec4)
    if not vec4 then return end
    return Server.requestStashID(vec4)
end)

lib.callback.register("LGF_Safe.getAllStashData", function(source)
    if not source then return end
    return Server.getAllStashData()
end)

lib.callback.register("LGF_Safe.isOwnerStash", function(source, stashid)
    if not source or not stashid then return end
    return Server.isOwnerStash(stashid, source)
end)

lib.callback.register("LGF_Safe.getStashDataOwner", function(source)
    if not source then return end
    return Server.getStashDataOwner(source)
end)

lib.callback.register("LGF_Safe.isStashWithGps", function(source, stashId)
    if not stashId then return end
    return Server.isStashWithGps(stashId)
end)
