-- MovableWindowExample.lua
-- Companion code for docs/04-libaddonmenu.md section 4 "Moving Your Addon's UI Window"
-- Requires LibAddonMenu-2.0.

MovableWindowExample = MovableWindowExample or {}
MovableWindowExample.name = "MovableWindowExample"

local defaults = {
    locked = false,
    windowPosition = nil, -- { left = x, top = y } once the player drags it
}

function MovableWindowExample.OnWindowMoveStop(control)
    local left, top = control:GetLeft(), control:GetTop()
    MovableWindowExampleSV.windowPosition = { left = left, top = top }
end

function MovableWindowExample.RestoreWindowPosition()
    local pos = MovableWindowExampleSV.windowPosition
    if pos then
        MovableWindowExampleWindow:ClearAnchors()
        MovableWindowExampleWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, pos.left, pos.top)
    end
end

function MovableWindowExample.ResetWindowPosition()
    MovableWindowExampleSV.windowPosition = nil
    MovableWindowExampleWindow:ClearAnchors()
    MovableWindowExampleWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
end

function MovableWindowExample.SetWindowLocked(isLocked)
    MovableWindowExampleSV.locked = isLocked
    MovableWindowExampleWindow:SetMovable(not isLocked)
end

local function CreateSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then
        d("|cFF0000[MovableWindowExample]|r LibAddonMenu-2.0 is not installed.")
        return
    end

    LAM:RegisterAddonPanel("MovableWindowExample_LAM", {
        type = "panel",
        name = "Movable Window Example",
        displayName = "Movable Window Example",
        author = "YourName",
        version = "1.0.0",
        registerForRefresh = true,
        registerForDefaults = true,
    })

    LAM:RegisterOptionControls("MovableWindowExample_LAM", {
        [1] = {
            type = "checkbox",
            name = "Lock Window Position",
            tooltip = "Prevents the window from being dragged.",
            getFunc = function() return MovableWindowExampleSV.locked end,
            setFunc = function(value) MovableWindowExample.SetWindowLocked(value) end,
            default = defaults.locked,
        },
        [2] = {
            type = "button",
            name = "Reset Window Position",
            tooltip = "Moves the window back to the center of the screen.",
            func = function() MovableWindowExample.ResetWindowPosition() end,
        },
    })
end

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= MovableWindowExample.name then return end
    EVENT_MANAGER:UnregisterForEvent(MovableWindowExample.name, EVENT_ADD_ON_LOADED)

    MovableWindowExampleSV = ZO_SavedVars:NewAccountWide("MovableWindowExampleSV", 1, nil, defaults)

    MovableWindowExample.RestoreWindowPosition()
    MovableWindowExample.SetWindowLocked(MovableWindowExampleSV.locked)
    CreateSettingsMenu()

    d("|cFFFF00[MovableWindowExample]|r loaded. Drag the window, then check Settings -> Add-Ons to lock it.")
end

EVENT_MANAGER:RegisterForEvent(MovableWindowExample.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
