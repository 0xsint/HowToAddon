-- ConsoleDialogExample.lua
-- Companion code for docs/05-libconsoledialogs.md
-- LibConsoleDialogs is optional: the addon still loads on PC/keyboard-mode without it.

ConsoleDialogExample = ConsoleDialogExample or {}
ConsoleDialogExample.name = "ConsoleDialogExample"

local defaults = {
    enabled = false,
    updateMs = 500,
}

local function CreateGamepadDialog()
    if not LibConsoleDialogs then
        d("|cFF0000[ConsoleDialogExample]|r LibConsoleDialogs is not installed; skipping gamepad dialog.")
        return
    end

    local areSettingsDisabled = false
    local settings = LibConsoleDialogs:Create("Console Dialog Example")

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Enable Feature",
        tooltip = "This is an example checkbox",
        default = defaults.enabled,
        setFunction = function(state) ConsoleDialogExampleSV.enabled = state end,
        getFunction = function() return ConsoleDialogExampleSV.enabled end,
        disable = function() return areSettingsDisabled end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Update Frequency",
        tooltip = "This is an example slider",
        min = 100, max = 2000, step = 100,
        format = "%d",
        setFunction = function(value) ConsoleDialogExampleSV.updateMs = value end,
        getFunction = function() return ConsoleDialogExampleSV.updateMs end,
        disable = function() return areSettingsDisabled end,
    })

    ConsoleDialogExample.dialog = settings

    LibConsoleDialogs:RegisterKeybind(
        GAMEPAD_QUEST_JOURNAL_ROOT_SCENE,
        {
            name = "Console Dialog Example",
            tooltip = "Open Console Dialog Example settings",
            alignment = KEYBIND_STRIP_ALIGN_CENTER,
            callback = function(buttonInfo)
                ConsoleDialogExample.dialog:Show()
            end,
        }
    )
end

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= ConsoleDialogExample.name then return end
    EVENT_MANAGER:UnregisterForEvent(ConsoleDialogExample.name, EVENT_ADD_ON_LOADED)

    ConsoleDialogExampleSV = ZO_SavedVars:NewAccountWide("ConsoleDialogExampleSV", 1, nil, defaults)
    CreateGamepadDialog()

    d("|cFFFF00[ConsoleDialogExample]|r loaded.")
end

EVENT_MANAGER:RegisterForEvent(ConsoleDialogExample.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
