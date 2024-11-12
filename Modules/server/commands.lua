local Config = require("Modules.shared.config")

lib.addCommand(Config.Command.Private.DeleteStash, {
    help = "Delete all stashes for the players.",
    params = {},
}, function(source, args, rawCommand)
    Server.deleteAllStashes(source)
end)

lib.addCommand(Config.Command.Private.ForceStash, {
    help = "Create all stashes for the players.",
    params = {},
}, function(source, args, rawCommand)
    local PlayerGroup = Utility.Core:GetGroup(source)
    if Config.AllowedGroup[PlayerGroup] then
        TriggerClientEvent("LGF_Safe.setupInitializedStash", -1, true)
    end
end)

lib.addCommand(Config.Command.Private.ClearStash, {
    help = "Clear all stashes for the players.",
    params = {},
}, function(source, args, rawCommand)
    local PlayerGroup = Utility.Core:GetGroup(source)
    if Config.AllowedGroup[PlayerGroup] then
        TriggerClientEvent("LGF_Safe.setupInitializedStash", -1, false)
    end
end)
