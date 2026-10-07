-- LamSettingsExample.lua
-- Companion code for docs/04-libaddonmenu.md
-- Requires LibAddonMenu-2.0 to be installed (see ## DependsOn in the manifest).

LamSettingsExample = LamSettingsExample or {}
LamSettingsExample.name = "LamSettingsExample"

local defaults = {
    enabled = true,
    updateMs = 500,
    displayMode = "Compact",
}

local function CreateSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then
        d("|cFF0000[LamSettingsExample]|r LibAddonMenu-2.0 is not installed.")
        return
    end

    local panelData = {
        type = "panel",
        name = "LAM Settings Example",
        displayName = "|c00A2FFLAM Settings Example|r",
        author = "YourName",
        version = "1.0.0",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel("LamSettingsExample_LAM", panelData)

    local optionsData = {
        [1] = {
            type = "header",
            name = "General",
        },
        [2] = {
            type = "checkbox",
            name = "Enable Addon",
            tooltip = "Turns the addon's features on or off.",
            getFunc = function() return LamSettingsExampleSV.enabled end,
            setFunc = function(value) LamSettingsExampleSV.enabled = value end,
            default = defaults.enabled,
        },
        [3] = {
            type = "slider",
            name = "Update Frequency (ms)",
            min = 100, max = 2000, step = 100,
            getFunc = function() return LamSettingsExampleSV.updateMs end,
            setFunc = function(value) LamSettingsExampleSV.updateMs = value end,
            default = defaults.updateMs,
        },
        [4] = {
            type = "dropdown",
            name = "Display Mode",
            choices = { "Compact", "Full" },
            getFunc = function() return LamSettingsExampleSV.displayMode end,
            setFunc = function(value) LamSettingsExampleSV.displayMode = value end,
            default = defaults.displayMode,
        },
    }
    LAM:RegisterOptionControls("LamSettingsExample_LAM", optionsData)
end

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= LamSettingsExample.name then return end
    EVENT_MANAGER:UnregisterForEvent(LamSettingsExample.name, EVENT_ADD_ON_LOADED)

    LamSettingsExampleSV = ZO_SavedVars:NewAccountWide("LamSettingsExampleSV", 1, nil, defaults)
    CreateSettingsMenu()

    d("|cFFFF00[LamSettingsExample]|r loaded. Open Settings -> Add-Ons -> LAM Settings Example.")
end

EVENT_MANAGER:RegisterForEvent(LamSettingsExample.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
