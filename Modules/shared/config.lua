local Config = {}

-- Notification System, Check shared.shared.lua to add other Custom Notification
Config.ProviderNotification = "ox_lib" -- "lgf_hud" "utility" "ox_lib"

-- This setting controls whether debug information will be printed to the console.
Config.EnableDebug = false

-- Name of the GPS item used to set the GPS on a stash
Config.GpsItemName = "gps_stash"

-- Name of the item used to set the try to steal a safe
Config.HackTool = "safe_cracker"

-- Progress bar configuration (choose between "ox_lib" or "utility")
Config.ProgressBar = "utility"

-- Progress Duration when set or remove a gps from the stash
Config.ProgressTime = 20

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
    Private = {                         -- Commands restricted to specific player groups
        DeleteStash = "clear_allStash", -- Delete all Stash objects and data from the database
        ForceStash = "init_stash",      -- Force and create all Stash objects
        ClearStash = "deinit_stash",    -- Unload all Stash objects and Interaction
    },
    Public = {                          -- Public commands that can be used by any player
        OpenGps = "open_gps",           --Work only if Debug is Enabled
    },
}

-- Mini-game type setting determines which mini-game is played when interacting with the safe.
-- Currently supports 'bl_ui' and 'ox_lib' .
Config.MiniGameType = "ox_lib" -- Change this to 'ox_lib' if you want to use the ox_lib mini-game

-- Specific Category based on Config.MiniGameType
Config.MiniGameSteal = {
    ox_lib = function()
        return lib.skillCheck({ 'easy', 'easy', { areaSize = 60, speedMultiplier = 2 }, 'easy' }, { 'w' })
    end,
    bl_ui = function()
        return exports.bl_ui:LightsOut(3, { level = 2, duration = 5000 })
    end,
}
-- Check if player is death to prevent open o manage the safe
Config.DeathCheck = function(ped)
    return GetResourceState("ars_ambulancejob"):find("start") and LocalPlayer.state.dead or IsPedFatallyInjured(ped)
end

Config.ShopNPCs = {
    {
        PedID = "shop_1",
        Position = vec4(256.2448, -1109.1915, 29.7132, 195.9954),
        Model = "cs_lestercrest",
        ShopName = "Stash Shop",
        ShopItems = {
            { Label = "Small Safe Storage",   ItemName = "little_safe",      Price = 500,  Description = "Small safe for valuables.",            Icon = "fa-lock" },
            { Label = "Medium Safe Storage",  ItemName = "medium_safe",      Price = 1000, Description = "Medium-sized safe for valuables.",     Icon = "fa-lock" },
            { Label = "GPS Tablet for Stash", ItemName = "gps_tablet-stash", Price = 300,  Description = "Tablet for tracking stash locations.", Icon = "fa-tablet" },
            { Label = "Stash GPS Module",     ItemName = "gps_stash",        Price = 100,  Description = "GPS module for stash tracking.",       Icon = "fa-map-marker-alt" },
            { Label = "Safe Cracker Tool",    ItemName = "safe_cracker",     Price = 750,  Description = "Tool used for cracking safes.",        Icon = "fa-wrench" }

        }
    },
}



return Config
