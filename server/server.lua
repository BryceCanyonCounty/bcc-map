local Core = exports.vorp_core:GetCore()
local BccUtils = exports['bcc-utils'].initiate()
---@type BCCMapDebugLib
local DBG = BCCMapDebug

Core.Callback.Register('bcc-map:CheckMapItem', function(source, cb)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('Failed to get user for source: %s', tostring(src)))
        cb(false)
        return
    end

    -- Get the player's full inventory
    local inventory = exports.vorp_inventory:getUserInventoryItems(src)
    if not inventory then
        DBG.Error(string.format('Failed to get inventory for source: %s', tostring(src)))
        cb(false)
        return
    end

    local hasValidItem = false
    local itemToRemove = nil

    -- Check each inventory item against required items
    for _, invItem in pairs(inventory) do
        if invItem.count and invItem.count > 0 then
            -- Check if this inventory item is in our required items list
            for _, requiredItem in pairs(Config.requiredItems) do
                if invItem.name == requiredItem then
                    hasValidItem = true
                    itemToRemove = requiredItem
                    break
                end
            end

            if hasValidItem then
                break
            end
        end
    end

    -- Remove item if configured to do so and player has valid item
    if hasValidItem and Config.removeItem and itemToRemove then
        local success = exports.vorp_inventory:subItem(src, itemToRemove, 1)
        if success then
            DBG.Info(string.format('Removed item %s from player %s for map usage', itemToRemove, tostring(src)))
        else
            DBG.Error(string.format('Failed to remove item %s from player %s', itemToRemove, tostring(src)))
        end
    end

    cb(hasValidItem)
end)

BccUtils.Versioner.checkFile(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-map')
