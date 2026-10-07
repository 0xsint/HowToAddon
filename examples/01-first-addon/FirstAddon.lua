-- FirstAddon.lua
-- Companion code for docs/01-lua-basics.md and the main README.
-- This is the smallest possible addon: it loads, prints a chat message once,
-- and registers a slash command.

FirstAddon = FirstAddon or {}
FirstAddon.name = "FirstAddon"

-- EVENT_ADD_ON_LOADED fires once per addon as it finishes loading.
-- Every addon's handler receives this for every addon, so always check the name.
local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= FirstAddon.name then return end
    EVENT_MANAGER:UnregisterForEvent(FirstAddon.name, EVENT_ADD_ON_LOADED)

    d("|cFFFF00[FirstAddon]|r loaded successfully! Type /firstaddon to say hello.")
end

SLASH_COMMANDS["/firstaddon"] = function()
    d("Hello from FirstAddon!")
end

EVENT_MANAGER:RegisterForEvent(FirstAddon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
