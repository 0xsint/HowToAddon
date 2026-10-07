-- AllInOneExample.lua
--
-- One addon that combines every topic in this repo's docs/ guides:
--   01 Lua Basics                -> namespacing, tables, functions (used throughout)
--   02 XML Reference             -> AllInOneExample.xml (movable window, labels, close button)
--   03 Manifest File             -> AllInOneExample.txt (SavedVariables / DependsOn / OptionalDependsOn)
--   04 LibAddonMenu              -> settings panel + movable-window lock/reset pattern
--   05 LibConsoleDialogs         -> optional gamepad-mode settings fallback
--   06 Logging Ability IDs       -> capped ability-id log buffer from combat/effect events
--   07 SavedVariables            -> ZO_SavedVars defaults + versioned migration + size cap
--   08 Combat/Effect/Power Events-> EVENT_COMBAT_EVENT, EVENT_EFFECT_CHANGED, EVENT_POWER_UPDATE
--   09 Player Stats & Max Stats  -> GetPlayerStat, GetUnitPower, EVENT_STATS_UPDATED refresh
--   10 API Reference Guide      -> (no code; this file is the practical result of following it)

AllInOneExample = AllInOneExample or {}
AllInOneExample.name = "AllInOneExample"

-- =====================================================================================
-- SECTION: SavedVariables -- see docs/07-savedvariables.md
-- =====================================================================================

local CURRENT_SV_VERSION = 1
local MAX_LOG_ENTRIES = 200 -- keep the saved file small and crash-resilient

local defaults = {
    enabled = true,
    locked = false,
    windowPosition = nil,     -- { left = x, top = y }, set once the player drags the window
    updateMs = 500,
    displayMode = "Compact",
    logEntries = {},          -- capped ring buffer of { id, name, kind, time }
}

-- =====================================================================================
-- SECTION: Logging Ability IDs -- see docs/06-ability-id-logging.md
-- =====================================================================================

local function AddLogEntry(abilityId, abilityName, kind)
    if not AllInOneExampleSV.enabled then return end

    table.insert(AllInOneExampleSV.logEntries, {
        id = abilityId,
        name = abilityName,
        kind = kind, -- "combat" or "effect"
        time = GetTimeStamp(),
    })

    while #AllInOneExampleSV.logEntries > MAX_LOG_ENTRIES do
        table.remove(AllInOneExampleSV.logEntries, 1)
    end
end

function AllInOneExample.PrintLog()
    for i, entry in ipairs(AllInOneExampleSV.logEntries) do
        d(string.format("[%d] %s id=%d name=%s", i, entry.kind, entry.id, entry.name))
    end
end

function AllInOneExample.ClearLog()
    AllInOneExampleSV.logEntries = {}
    AllInOneExample.UpdateDisplay()
    d("|cFFFF00[AllInOneExample]|r Log cleared.")
end

-- =====================================================================================
-- SECTION: Combat / Effect / Power Events -- see docs/08-combat-effect-power-events.md
-- =====================================================================================

local function OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic,
                              abilityActionSlotType, sourceName, sourceType, targetName,
                              targetType, hitValue, powerType, damageType, log,
                              sourceUnitId, targetUnitId, abilityId, overflow)
    AddLogEntry(abilityId, abilityName, "combat")
    AllInOneExample.UpdateDisplay()
end

local function OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag,
                                beginTime, endTime, stackCount, iconName, buffType,
                                effectType, abilityType, statusEffectType, unitName,
                                unitId, abilityId, sourceType)
    if changeType == EFFECT_RESULT_GAINED then
        AddLogEntry(abilityId, effectName, "effect")
        AllInOneExample.UpdateDisplay()
    end
end

local function OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    if powerType == COMBAT_MECHANIC_FLAGS_HEALTH then
        AllInOneExample.liveHealth = powerValue
        AllInOneExample.liveHealthMax = powerMax
        AllInOneExample.UpdateDisplay()
    end
end

-- =====================================================================================
-- SECTION: Player Stats & Max Stats -- see docs/09-player-stats.md
-- =====================================================================================

function AllInOneExample.RefreshStats()
    AllInOneExample.maxHealth = GetPlayerStat(STAT_HEALTH_MAX)
    AllInOneExample.maxMagicka = GetPlayerStat(STAT_MAGICKA_MAX)
    AllInOneExample.maxStamina = GetPlayerStat(STAT_STAMINA_MAX)
    AllInOneExample.weaponPower = GetPlayerStat(STAT_WEAPON_POWER)
    AllInOneExample.spellPower = GetPlayerStat(STAT_SPELL_POWER)

    local current, effectiveMax, max = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_HEALTH)
    AllInOneExample.liveHealth = current
    AllInOneExample.liveHealthMax = max

    AllInOneExample.UpdateDisplay()
end

-- =====================================================================================
-- SECTION: XML UI updates -- see docs/02-xml-reference.md
-- =====================================================================================

function AllInOneExample.UpdateDisplay()
    local statsLabel = GetControl(AllInOneExampleWindow, "StatsLabel")
    if statsLabel then
        statsLabel:SetText(string.format(
            "Health: %d / %d\nMax Magicka: %d  Max Stamina: %d\nWeapon Power: %d  Spell Power: %d",
            AllInOneExample.liveHealth or 0, AllInOneExample.liveHealthMax or 0,
            AllInOneExample.maxMagicka or 0, AllInOneExample.maxStamina or 0,
            AllInOneExample.weaponPower or 0, AllInOneExample.spellPower or 0))
    end

    local logLabel = GetControl(AllInOneExampleWindow, "LogLabel")
    if logLabel then
        local entries = AllInOneExampleSV.logEntries
        local lines = {}
        local startIndex = zo_max(1, #entries - 4) -- show the most recent 5 entries
        for i = startIndex, #entries do
            local entry = entries[i]
            table.insert(lines, string.format("[%s] %d: %s", entry.kind, entry.id, entry.name))
        end
        logLabel:SetText(#lines > 0 and table.concat(lines, "\n") or "Log: (no entries yet)")
    end
end

-- =====================================================================================
-- SECTION: Movable window lock/reset pattern -- see docs/04-libaddonmenu.md
-- =====================================================================================

function AllInOneExample.OnWindowMoveStop(control)
    local left, top = control:GetLeft(), control:GetTop()
    AllInOneExampleSV.windowPosition = { left = left, top = top }
end

function AllInOneExample.RestoreWindowPosition()
    local pos = AllInOneExampleSV.windowPosition
    if pos then
        AllInOneExampleWindow:ClearAnchors()
        AllInOneExampleWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, pos.left, pos.top)
    end
end

function AllInOneExample.ResetWindowPosition()
    AllInOneExampleSV.windowPosition = nil
    AllInOneExampleWindow:ClearAnchors()
    AllInOneExampleWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
end

function AllInOneExample.SetWindowLocked(isLocked)
    AllInOneExampleSV.locked = isLocked
    AllInOneExampleWindow:SetMovable(not isLocked)
end

function AllInOneExample.ToggleWindow()
    AllInOneExampleWindow:SetHidden(not AllInOneExampleWindow:IsHidden())
end

-- =====================================================================================
-- SECTION: LibAddonMenu settings panel -- see docs/04-libaddonmenu.md
-- =====================================================================================

local function CreateLAMPanel()
    local LAM = LibAddonMenu2
    if not LAM then
        d("|cFF0000[AllInOneExample]|r LibAddonMenu-2.0 is not installed; PC settings panel skipped.")
        return
    end

    LAM:RegisterAddonPanel("AllInOneExample_LAM", {
        type = "panel",
        name = "All In One Example",
        displayName = "|c00A2FFAll In One Example|r",
        author = "YourName",
        version = "1.0.0",
        registerForRefresh = true,
        registerForDefaults = true,
    })

    LAM:RegisterOptionControls("AllInOneExample_LAM", {
        [1] = { type = "header", name = "General" },
        [2] = {
            type = "checkbox",
            name = "Enable Logging",
            tooltip = "Turns ability/combat logging on or off.",
            getFunc = function() return AllInOneExampleSV.enabled end,
            setFunc = function(value) AllInOneExampleSV.enabled = value end,
            default = defaults.enabled,
        },
        [3] = {
            type = "slider",
            name = "Update Frequency (ms)",
            min = 100, max = 2000, step = 100,
            getFunc = function() return AllInOneExampleSV.updateMs end,
            setFunc = function(value) AllInOneExampleSV.updateMs = value end,
            default = defaults.updateMs,
        },
        [4] = {
            type = "dropdown",
            name = "Display Mode",
            choices = { "Compact", "Full" },
            getFunc = function() return AllInOneExampleSV.displayMode end,
            setFunc = function(value) AllInOneExampleSV.displayMode = value end,
            default = defaults.displayMode,
        },
        [5] = { type = "header", name = "Window" },
        [6] = {
            type = "checkbox",
            name = "Lock Window Position",
            tooltip = "Prevents the window from being dragged.",
            getFunc = function() return AllInOneExampleSV.locked end,
            setFunc = function(value) AllInOneExample.SetWindowLocked(value) end,
            default = defaults.locked,
        },
        [7] = {
            type = "button",
            name = "Reset Window Position",
            func = function() AllInOneExample.ResetWindowPosition() end,
        },
        [8] = { type = "header", name = "Ability Log" },
        [9] = {
            type = "button",
            name = "Print Log to Chat",
            func = function() AllInOneExample.PrintLog() end,
        },
        [10] = {
            type = "button",
            name = "Clear Log",
            func = function() AllInOneExample.ClearLog() end,
        },
    })
end

-- =====================================================================================
-- SECTION: LibConsoleDialogs gamepad fallback -- see docs/05-libconsoledialogs.md
-- =====================================================================================

local function CreateGamepadDialog()
    if not LibConsoleDialogs then
        return -- optional dependency; silently skip on PC-only setups
    end

    local settings = LibConsoleDialogs:Create("All In One Example")

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Enable Logging",
        tooltip = "Turns ability/combat logging on or off.",
        default = defaults.enabled,
        setFunction = function(state) AllInOneExampleSV.enabled = state end,
        getFunction = function() return AllInOneExampleSV.enabled end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Update Frequency",
        tooltip = "This is an example slider",
        min = 100, max = 2000, step = 100,
        format = "%d",
        setFunction = function(value) AllInOneExampleSV.updateMs = value end,
        getFunction = function() return AllInOneExampleSV.updateMs end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Print Log to Chat",
        tooltip = "Prints the ability log to chat",
        clickHandler = function() AllInOneExample.PrintLog() end,
    })

    AllInOneExample.gamepadDialog = settings

    LibConsoleDialogs:RegisterKeybind(
        GAMEPAD_QUEST_JOURNAL_ROOT_SCENE,
        {
            name = "All In One Example",
            tooltip = "Open All In One Example settings",
            alignment = KEYBIND_STRIP_ALIGN_CENTER,
            callback = function(buttonInfo)
                AllInOneExample.gamepadDialog:Show()
            end,
        }
    )
end

-- =====================================================================================
-- SECTION: Startup / wiring everything together
-- =====================================================================================

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= AllInOneExample.name then return end
    EVENT_MANAGER:UnregisterForEvent(AllInOneExample.name, EVENT_ADD_ON_LOADED)

    -- SavedVariables: see docs/07-savedvariables.md
    AllInOneExampleSV = ZO_SavedVars:NewAccountWide("AllInOneExampleSV", CURRENT_SV_VERSION, nil, defaults)

    -- Movable window: restore saved position + lock state
    AllInOneExample.RestoreWindowPosition()
    AllInOneExample.SetWindowLocked(AllInOneExampleSV.locked)

    -- Settings UIs (PC + gamepad)
    CreateLAMPanel()
    CreateGamepadDialog()

    -- Combat / effect / power events: see docs/08-combat-effect-power-events.md
    EVENT_MANAGER:RegisterForEvent(AllInOneExample.name, EVENT_COMBAT_EVENT, OnCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(AllInOneExample.name, EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    EVENT_MANAGER:RegisterForEvent(AllInOneExample.name, EVENT_EFFECT_CHANGED, OnEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(AllInOneExample.name, EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_UNIT_TAG, "player")

    EVENT_MANAGER:RegisterForEvent(AllInOneExample.name, EVENT_POWER_UPDATE, OnPowerUpdate)
    EVENT_MANAGER:AddFilterForEvent(AllInOneExample.name, EVENT_POWER_UPDATE,
        REGISTER_FILTER_UNIT_TAG, "player",
        REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH)

    -- Player stats: see docs/09-player-stats.md
    EVENT_MANAGER:RegisterForEvent(AllInOneExample.name, EVENT_PLAYER_ACTIVATED, AllInOneExample.RefreshStats)
    EVENT_MANAGER:RegisterForEvent(AllInOneExample.name, EVENT_STATS_UPDATED, AllInOneExample.RefreshStats)
    EVENT_MANAGER:RegisterForEvent(AllInOneExample.name, EVENT_LEVEL_UPDATE, AllInOneExample.RefreshStats)

    -- Slash commands tying it all together
    SLASH_COMMANDS["/allinone"] = function(args)
        if args == "log" then
            AllInOneExample.PrintLog()
        elseif args == "reset" then
            AllInOneExample.ResetWindowPosition()
        elseif args == "clear" then
            AllInOneExample.ClearLog()
        else
            AllInOneExample.ToggleWindow()
        end
    end

    AllInOneExample.RefreshStats() -- populate the window immediately on load

    d("|cFFFF00[AllInOneExample]|r loaded. Type /allinone to toggle the window (log | reset | clear).")
end

EVENT_MANAGER:RegisterForEvent(AllInOneExample.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
