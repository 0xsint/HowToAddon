-- SavedVarsExample.lua
-- Companion code for docs/07-savedvariables.md
-- Demonstrates: defaults, versioned migration, a size-capped log buffer, and a slash-command reset.

SavedVarsExample = SavedVarsExample or {}
SavedVarsExample.name = "SavedVarsExample"

local CURRENT_VERSION = 1
local MAX_LOG_ENTRIES = 200 -- keep the saved file small and crash-resilient

local defaults = {
    enabled = true,
    entries = {},
}

-- Appends an entry and keeps the buffer bounded, see docs/07-savedvariables.md risk table.
function SavedVarsExample.LogEntry(message)
    if not SavedVarsExampleSV.enabled then return end

    table.insert(SavedVarsExampleSV.entries, { text = message, time = GetTimeStamp() })

    while #SavedVarsExampleSV.entries > MAX_LOG_ENTRIES do
        table.remove(SavedVarsExampleSV.entries, 1)
    end
end

function SavedVarsExample.PrintLog()
    for i, entry in ipairs(SavedVarsExampleSV.entries) do
        d(string.format("[%d] (%d) %s", i, entry.time, entry.text))
    end
end

function SavedVarsExample.ResetSavedData()
    SavedVarsExampleSV.entries = {}
    d("|cFFFF00[SavedVarsExample]|r Saved data cleared.")
end

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= SavedVarsExample.name then return end
    EVENT_MANAGER:UnregisterForEvent(SavedVarsExample.name, EVENT_ADD_ON_LOADED)

    SavedVarsExampleSV = ZO_SavedVars:NewAccountWide("SavedVarsExampleSV", CURRENT_VERSION, nil, defaults)

    SLASH_COMMANDS["/svexample"] = function(args)
        if args == "print" then
            SavedVarsExample.PrintLog()
        elseif args == "reset" then
            SavedVarsExample.ResetSavedData()
        else
            SavedVarsExample.LogEntry("manual test entry")
            d("|cFFFF00[SavedVarsExample]|r Logged a test entry. Use /svexample print or /svexample reset.")
        end
    end

    d("|cFFFF00[SavedVarsExample]|r loaded.")
end

EVENT_MANAGER:RegisterForEvent(SavedVarsExample.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
