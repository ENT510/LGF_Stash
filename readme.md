# LGF Safe System

## Overview

The LGF Safe System is designed to handle in-game safes with features like creating, interacting, moving, and managing stash data. Players can place and interact with safes, which store data and inventory. The system provides interaction menus and mini-games (configured as either `ox_lib` or `bl_ui`), allowing players to interact with safes and manage their contents but is all customizable to improve other Resource.

## Key Features

- **Safe Creation**: Players can create safes at specified coordinates using raycast with models that are loaded dynamically.
- **Safe Interaction**: Players can interact with safes to open or move them, and perform stash-related actions.
- **Stash Management**: The system automatically saves and loads stash data to ensure safes persist across sessions.
- **Mini-Games**: When opening safes, if the player is not the owner of the safe , may be required to complete mini-games to access the contents.
- **Notification System**: The system sends notifications to players when safes are placed, interacted with, or modified.

```lua
-- This export initializes all safes in the world and loads them from the server. (client exports)
exports.LGF_Stash:initializeAllStash()

-- This export clears and deletes all safes registered in the database. (server exports)
---@param source number | Required for checking the executor of the command to prevent exploit
exports.LGF_Stash:deleteAllStashes(source)

-- This export manages and updates the coordinates for a specific safe entity. (server exports)
---@param stashId string | The stash ID
---@param newCoords number | table number | The new coordinates of the safe entity
exports.LGF_Stash:updateStashCoords(stashId, newCoords)

-- This export retrieves all stash data from the database. (server exports)
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
```
