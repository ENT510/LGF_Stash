# LGF Safe System

The LGF Safe System is designed to handle in-game safes with features like creating, interacting, moving, and managing stash data. Players can place and interact with safes, which store data and inventory. The system provides interaction menus and mini-games (configured as either `ox_lib` or `bl_ui`), allowing players to interact with safes and manage their contents (full customizable).

<p align="center">
  <img src="https://i.ibb.co/zRBTvnL/image.png" alt="Stash Dui" width="45%">
  <img src="https://i.ibb.co/djD0FF0/image.png" alt="Stash Gps" width="45%">
</p>

## Key Features

- **Safe Creation**: Players can create safes at specified coordinates using a raycasting system, with models dynamically loaded based on safe type.
- **Safe Interaction**: Players can interact with safes to open or move them, and perform stash-related actions, enhancing role-play and realism.
- **Stash Management**: The system automatically saves and loads stash data, ensuring safes persist across sessions for continuous gameplay.
- **Mini-Games**: When accessing safes they do not own, players may be required to complete mini-games to access the contents, adding a layer of challenge and security.
- **Notification System**: Players receive notifications for key interactions, such as when a safe is placed, opened, or modified, keeping them informed of stash activity.
- **GPS System**: Players can equip safes with GPS trackers, allowing owners to set or remove GPS tracking on safes to monitor their locations.
- **Inventory Slots and Weight Limits**: Each safe has a unique number of inventory slots and maximum weight capacity, determined by the item's size, adding realistic storage limitations based on the safe's size.

## Dependencies

- **[ox_lib](https://github.com/overextended/ox_lib)**: A library for essential Lua utilities and performance optimizations.
- **[ox_inventory](https://github.com/overextended/ox_inventory)**: A flexible and feature-rich inventory system.
- **[LGF_Utility](https://github.com/LGFScripts/LGF_Utility)**: A utility library to manage framework functions, Context Menu and common interactions.
- **[LGF_Interaction](https://github.com/LGFScripts/LGF_Interaction)**: A module for handling interactions with Dui-based UI elements.

## Compatibility Framework

- **QBCore**
- **Qbox**
- **ESX**
- **LGF**

## Available Exports

```lua
-- This export initializes all safes in the world and loads them from the server. (client exports)
---@param state boolean | true or false (if true load and create all stash and objects retrieved from the database if false unload and delete all props and interaction from the world)
exports.LGF_Stash:initializeAllStash(state)

-- This export open the Context Utility whit personal Stash with Gps. (client exports)
exports.LGF_Stash:openGpsTablet()

-- This export clears and deletes all safes registered in the database. (server exports)
---@param source number | Required for checking the executor of the command to prevent exploit
exports.LGF_Stash:deleteAllStashes(source)

-- This export manages and updates the coordinates for a specific safe entity. (server exports)
---@param stashId string | The stash ID
---@param newCoords number | table number | The new coordinates of the safe entity
exports.LGF_Stash:updateStashCoords(stashId, newCoords)

-- This export retrieves all stash data from the database. (server exports)
---@return StashData | A table containing all stash data from the database
exports.LGF_Stash:getAllStashData()

-- This export checks if the player is the owner of a specific stash. (server exports)
---@param stashId string | The stash ID
---@param target number | The player ID of the target player to check ownership for
exports.LGF_Stash:isOwnerStash(stashId, target)

-- This export requests the Stash ID for the current safe based on the provided coordinates. (server exports)
---@param coords vec4 | The coordinates (x, y, z, heading) of the safe entity
exports.LGF_Stash:requestStashID(coords)

-- This export deletes a specific stash entity/interaction Dui by its ID. (server exports)
---@param stashId string | The stash ID to delete
exports.LGF_Stash:deleteStashById(stashId)

-- This export return all stashes data for the current player registered in database. (server exports)
---@param target number | The Target of the player
exports.LGF_Stash:getStashDataOwner(target)

-- This export return if the current stash based on stashId have a gps installed. (server exports)
---@param stashId string | The stash ID to Check
exports.LGF_Stash:isStashWithGps(stashId)

-- This export set a Gps at a Specific StashID. (server exports)
---@param stashId string | The stash ID to Check
---@param state boolean | if true set the Gps to the current Stash, if False remove The Gps from the Stash
exports.LGF_Stash:setupGps(stashId,state)
```

### Stash Item Name

```lua
return {
    ['little_safe'] = {
        label = 'Little Safe',
        weight = 0,
        stack = true,
        close = true,
        consume = 0,
        description = "A small safe ideal for storing papers or small items.",
        client = {
            export = 'LGF_Stash.setCurrentStash'
        },
    },

    ['medium_safe'] = {
        label = 'Medium Safe',
        weight = 0,
        stack = true,
        close = true,
        consume = 0,
        description = "A medium-sized safe for storing documents and valuables.",
        client = {
            export = 'LGF_Stash.setCurrentStash'
        },
    },

    ['big_safe'] = {
        label = 'Big Safe',
        weight = 10000,
        stack = false,
        close = true,
        consume = 0,
        description = "A large safe used for storing large quantities of valuables and important items.",
        client = {
            export = 'LGF_Stash.setCurrentStash'
        },
    },
}
```

### Stash Gps Item Name

```lua
return {
    ['gps_tablet-stash'] = {
        label = 'GPS Tablet for Stash',
        weight = 50,
        stack = false,
        close = true,
        consume = 0,
        description = "A GPS-enabled tablet, specifically configured for viewing the locations of stashes. Useful for tracking stash locations.",
        client = {
            export = 'LGF_Stash.openGpsTablet'
        },
    },

    ['gps_stash'] = {
        label = 'Stash GPS Module',
        weight = 50,
        stack = true,
        close = false,
        consume = 0,
        description = "A compact GPS module designed for tracking a specific stash. Install it in a stash to monitor its location remotely.",
    },
    ['safe_cracker'] = {
        label = 'Safe Cracker Module',
        weight = 50,
        stack = true,
        close = false,
        consume = 0,
        description = "A compact Tool designed for cracking safes",
    },
}
```
