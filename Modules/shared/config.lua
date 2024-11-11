local Config = {}

Config.ProviderNotification = "lgf_hud" -- "lgf_hud" "utility" "ox_lib"

-- This setting controls whether debug information will be printed to the console.
Config.EnableDebug = true

-- This table defines which player groups are allowed to execute specific commands.
-- 'admin' group can execute certain commands, while 'player' cannot.
Config.AllowedGroup = { ["admin"] = true, ["player"] = false, }

-- This table defines safe models with specific item names, slot, and weight information.
-- It ensures that the correct item is used for each safe model.
Config.ModelSafeData = {
    ["prop_ld_int_safe_01"] = {
        Slot = 30,               -- Number of available slots for this safe model
        Weight = 50,             -- Weight of this safe model
        ItemName = "little_safe" -- Item name used for this safe model and used on ox_inventory
    },
    ["p_v_43_safe_s"] = {
        Slot = 60,
        Weight = 100,
        ItemName = "medium_safe"
    },
}

-- This table defines the commands that players can use to interact with the stash.
-- Private commands can only be used by players with a specific group defined in Config.AllowedGroup.
Config.Command = {
    Private = { -- Commands restricted to specific player groups
        ClearStash = "clear_allStash",
    },
    Public = { -- Public commands that can be used by any player
    },
}

-- Mini-game type setting determines which mini-game is played when interacting with the safe.
-- Currently supports 'bl_ui' for LightsOut and 'ox_lib' for the ox_lib mini-game.
Config.MiniGameType = "bl_ui" -- Change this to 'ox_lib' if you want to use the ox_lib mini-game

-- Specific Category based on Config.MiniGameType
Config.MiniGameSteal = {
    ox_lib = function()
        return lib.skillCheck({ 'easy', 'easy', { areaSize = 60, speedMultiplier = 2 }, 'easy' }, { 'w' })
    end,
    bl_ui = function()
        return exports.bl_ui:LightsOut(3, { level = 2, duration = 5000 })
    end,
}


return Config
