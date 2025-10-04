local Core = exports.vorp_core:GetCore()
---@type BCCMapDebugLib
local DBG = BCCMapDebug

local MapControlStarted = false

local function StartMapControl()
    CreateThread(function()
        MapControlStarted = true
        DBG.Info('Map Control Started')

        while true do
            local sleep = 0

            if IsEntityDead(PlayerPedId()) then
                sleep = 1000
                goto END
            end

            -- Check for map key press
            if IsControlJustPressed(0, `INPUT_MAP`) then
                DBG.Info('Player is trying to open the map')

                local hasItem = Core.Callback.TriggerAwait('bcc-map:CheckMapItem')
                if not hasItem then
                    -- Check if map is open, if so close it
                    if Citizen.InvokeNative(0x4E511D093A86AD49, `MAP`) then -- IsUiappRunningByHash
                        Citizen.InvokeNative(0x04428420A248A354, `MAP`)     -- CloseUiappByHashImmediate
                    end
                    Core.NotifyRightTip(_U('noMapItem'), 4000)
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
