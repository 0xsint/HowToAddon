-- XmlUiExample.lua
-- Companion code for docs/02-xml-reference.md
-- Shows the window defined in XmlUiExample.xml and adds a slash command to toggle it.

XmlUiExample = XmlUiExample or {}
XmlUiExample.name = "XmlUiExample"

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= XmlUiExample.name then return end
    EVENT_MANAGER:UnregisterForEvent(XmlUiExample.name, EVENT_ADD_ON_LOADED)

    SLASH_COMMANDS["/xmlui"] = function()
        -- XmlUiExampleWindow is a global because it is a named top-level XML control.
        XmlUiExampleWindow:SetHidden(not XmlUiExampleWindow:IsHidden())
    end

    d("|cFFFF00[XmlUiExample]|r loaded. Type /xmlui to toggle the window.")
end

EVENT_MANAGER:RegisterForEvent(XmlUiExample.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
