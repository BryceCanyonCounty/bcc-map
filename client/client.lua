local Core = exports.vorp_core:GetCore()
---@type BCCMapDebugLib
local DBG = BCCMapDebug

local MapControlStarted = false
local hasMapItem = false
local lastItemCheck = 0
local itemCheckInterval = 5000
local lastNotificationTime = 0
local notificationEnabled = Config.notifications.active
local notificationTime = Config.notifications.time
local notificationCooldown = Config.notifications.cooldownTime

local function StartMapControl()
    CreateThread(function()
        MapControlStarted = true
        DBG.Info('Map Control Started')

        while true do
            local sleep = 1000
            local currentTime = GetGameTimer()

            if IsEntityDead(PlayerPedId()) then
                sleep = 2000
                goto END
            end

            -- Check for item every 5 seconds or on first run
            if currentTime - lastItemCheck > itemCheckInterval or lastItemCheck == 0 then
                hasMapItem = Core.Callback.TriggerAwait('bcc-map:CheckMapItem')
                lastItemCheck = currentTime
                DBG.Info('Item check updated: ' .. tostring(hasMapItem))
            end

            -- Always check for map key press
            if IsControlJustPressed(0, `INPUT_MAP`) then
                if not hasMapItem then
                    -- Player doesn't have item - close map immediately and show message
                    DBG.Info('Player is trying to open the map without item')

                    if Citizen.InvokeNative(0x4E511D093A86AD49, `MAP`) then -- IsUiappRunningByHash
                        Citizen.InvokeNative(0x04428420A248A354, `MAP`)     -- CloseUiappByHashImmediate
                    end

                    -- Only show notification if enabled and cooldown has passed
                    if notificationEnabled and currentTime - lastNotificationTime > notificationCooldown then
                        Core.NotifyRightTip(_U('noMapItem'), notificationTime)
                        lastNotificationTime = currentTime
                    end

                    -- Force an immediate item check in case they just got the item
                    hasMapItem = Core.Callback.TriggerAwait('bcc-map:CheckMapItem')
                    lastItemCheck = currentTime

                    sleep = 0
                else
                    DBG.Info('Player has map item and is opening map')
                    sleep = 100 -- Short sleep after successful map open
                end
            end

            -- If player doesn't have item, constantly monitor and close map
            if not hasMapItem then
                sleep = 0
                -- Force close map if it somehow gets opened
                if Citizen.InvokeNative(0x4E511D093A86AD49, `MAP`) then -- IsUiappRunningByHash
                    Citizen.InvokeNative(0x04428420A248A354, `MAP`)     -- CloseUiappByHashImmediate
                end
            end
            ::END::
            Wait(sleep)
        end
    end)
end

RegisterNetEvent('vorp:SelectedCharacter', function(charid)
    StartMapControl()
end)

-- Dev Mode Command to start map control manually after script restart
if Config.devMode.active then
    RegisterCommand(Config.devMode.startCommand, function()
        if not MapControlStarted then
            StartMapControl()
            DBG.Info('Map Control Started via command.')
        else
            DBG.Info('Map Control is already running.')
        end
    end, false)
end

-- Command to list required items in chat
RegisterCommand(Config.commands.listItems, function()
    local items = table.concat(Config.requiredItems, ', ')
    Core.NotifyRightTip(_U('requiredItems') .. items, 10000)
end, false)
