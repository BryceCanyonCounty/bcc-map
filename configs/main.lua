Config = {

    defaultlang = 'en_lang',
    -----------------------------------------------------

    devMode = {
        active = false, -- Enable Dev Mode for Debugging / Do Not Use in Production
        startCommand = 'startMapControl' -- Start map control after script restart (if devMode is active)
    },
    -----------------------------------------------------

    commands = {
        listItems = 'mapItemsList' -- Command to list required items in chat
    },
    -----------------------------------------------------

    requiredItems = { -- Item name from database required to open map
        'map',
        'book',
    },

    removeItem = false, -- Remove item on map open (if true, one item is consumed each time the map is opened)
    -----------------------------------------------------
}