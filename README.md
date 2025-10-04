# BCC-Map

A RedM script that restricts access to the in-game map based on inventory items. Players must have a required item in their inventory to open the world map.

## Features

- **Simple Map Access Control**: Players need specific items to open the world map
- **Configurable Required Items**: Support for multiple item types in the config
- **Item Consumption Option**: Optional feature to consume items when opening the map
- **Player Commands**: Built-in command to list required items
- **Automatic Character Detection**: Starts when player selects a character
- **Debug Mode**: Development tools for testing and manual control

## Dependencies

- [vorp_core](https://github.com/VORPCORE/vorp-core-lua)
- [vorp_character](https://github.com/VORPCORE/vorp_character)
- [vorp_inventory](https://github.com/VORPCORE/vorp_inventory-lua)
- [bcc-utils](https://github.com/BryceCanyonCounty/bcc-utils)

## Installation

1. Download and place the script in your `resources` folder
2. Add `ensure bcc-map` to your `server.cfg`
3. Configure the required items in `configs/main.lua`
4. Restart your server

## Configuration

### Main Settings (`configs/main.lua`)

```lua
Config = {
    defaultlang = 'en_lang',
    
    devMode = {
        active = false, -- Enable Dev Mode for Debugging / Do Not Use in Production
        startCommand = 'startMapControl' -- Manual start command in dev mode
    },
    
    commands = {
        listItems = 'mapItemsList' -- Command to list required items in chat
    },
    
    requiredItems = { -- Items required to open map
        'map',
        'book',
    },
    
    removeItem = false, -- Remove item on map open (if true, one item is consumed each time the map is opened)
}
```

## How It Works

### Player Experience

1. Player attempts to open the map (M key by default)
2. Script checks if player has any of the required items in inventory
3. If player has a required item:
   - Map opens normally
   - If `removeItem = true`: One item is consumed from inventory
   - If `removeItem = false`: Item remains in inventory
4. If player lacks required items: Map is immediately closed and notification is shown

### Item Consumption

When `removeItem = true` in the config:

- Each time a player opens the map, one required item is consumed
- Players need to continuously obtain items to use the map
- Useful for creating a consumable map economy

When `removeItem = false` (default):

- Items are only checked but not consumed
- Players only need to obtain the item once
- More traditional approach for permanent map access

## Usage

### For Players

- Obtain one of the required items (`map`, `book`, etc.) from shops, other players, or events
- Press M (or your configured map key) to open the world map
- Without a required item, the map will close automatically with a notification
- Use `/mapItemsList` command to see what items are required for map access

### For Admins/Developers

#### Player Commands

- **`/mapItemsList`** - Lists all required items for map access (configurable command name)

#### Dev Mode Commands

When `devMode.active = true`:

- **`/startMapControl`** - Manually start map control (useful after script restarts)

#### Adding New Required Items

Add item names to the `requiredItems` array in the config:

```lua
requiredItems = {
    'map',
    'book',
    'compass',
    'your_custom_item'
}
```

#### Enabling Item Consumption

To make map usage consume items, set `removeItem = true`:

```lua
removeItem = true, -- Players will lose one item each time they open the map
```

#### Customizing Commands

Change the command name in the config:

```lua
commands = {
    listItems = 'mymapitems' -- Players can use /mymapitems instead
}
```

## GitHub

- [bcc-map](https://github.com/BryceCanyonCounty/bcc-map)
