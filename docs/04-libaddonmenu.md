# 04 — Integrating LibAddonMenu (LAM) + Making a Movable Window

[LibAddonMenu-2.0](https://www.esoui.com/downloads/info7-LibAddonMenu-2.0.html) ("LAM") by sirinsidiator is the de-facto standard settings-panel library for ESO addons — it renders a page inside the game's own **Settings → Add-Ons** menu, so you don't have to build your own options UI. As of this writing it is at **2.0 r43**; check the download page for the latest.

**Previous:** [03 — Manifest File](03-manifest-file.md) · **Next:** [05 — LibConsoleDialogs](05-libconsoledialogs.md) · **Back to:** [README](../README.md)

---

## 1. Install & Declare the Dependency

1. Download LibAddonMenu-2.0 and place its folder next to your addon, e.g. `AddOns/LibAddonMenu-2.0/`, **or** bundle its files inside your own addon folder (common for single-file distribution — just keep its own internal manifest/structure intact if bundling the whole lib folder).
2. Declare it in your [manifest](03-manifest-file.md):

```text
## DependsOn: LibAddonMenu-2.0>=35
```

Using `DependsOn` (not `OptionalDependsOn`) means your addon won't load at all if LAM is missing — simplest option if your settings UI is core to the addon.

## 2. Register a Settings Panel

```lua
local LAM = LibAddonMenu2

local panelData = {
    type = "panel",
    name = "My Addon",
    displayName = "|c00A2FFMy Addon|r",
    author = "YourName",
    version = "1.2.0",
    registerForRefresh = true,   -- panel refreshes live if SavedVariables change elsewhere
    registerForDefaults = true,  -- enables the "Defaults" button
    website = "https://www.esoui.com/downloads/info0000-MyAddon.html",
}
LAM:RegisterAddonPanel("MyAddon_LAM", panelData)
```

## 3. Register Option Controls

Controls are plain Lua tables in an ordered array. Every control needs `getFunc`/`setFunc` pairs that read/write your [SavedVariables](07-savedvariables.md).

```lua
local optionsData = {
    [1] = {
        type = "header",
        name = "General",
    },
    [2] = {
        type = "checkbox",
        name = "Enable Addon",
        tooltip = "Turns the addon's features on or off.",
        getFunc = function() return MyAddonSV.enabled end,
        setFunc = function(value) MyAddonSV.enabled = value end,
        default = true,
    },
    [3] = {
        type = "slider",
        name = "Update Frequency (ms)",
        min = 100, max = 2000, step = 100,
        getFunc = function() return MyAddonSV.updateMs end,
        setFunc = function(value) MyAddonSV.updateMs = value end,
        default = 500,
    },
    [4] = {
        type = "dropdown",
        name = "Display Mode",
        choices = { "Compact", "Full" },
        getFunc = function() return MyAddonSV.displayMode end,
        setFunc = function(value) MyAddonSV.displayMode = value end,
        default = "Compact",
    },
    [5] = {
        type = "colorpicker",
        name = "Text Color",
        getFunc = function() return unpack(MyAddonSV.textColor) end,
        setFunc = function(r, g, b, a) MyAddonSV.textColor = { r, g, b, a } end,
        default = { r = 1, g = 1, b = 1, a = 1 },
    },
    [6] = {
        type = "button",
        name = "Reset Window Position",
        tooltip = "Moves the window back to the center of the screen.",
        func = function() MyAddon.ResetWindowPosition() end,
    },
}
LAM:RegisterOptionControls("MyAddon_LAM", optionsData)
```

Other common `type` values: `description`, `submenu`, `editbox`, `texture`, `custom`. Every control accepts `disabled`, `width = "full"/"half"`, and a `tooltip`.

## 4. Moving Your Addon's UI Window (Lock/Unlock Pattern)

LAM doesn't move windows for you — instead, the standard pattern is: make your own `TopLevelControl` draggable, store its position in SavedVariables, and expose a LAM **checkbox** to lock/unlock dragging and a **button** to reset position. This is the pattern used by almost every ESO addon with a custom window (unit frames, timers, trackers, etc.).

**XML** (see also [02 — XML Reference](02-xml-reference.md)):

```xml
<TopLevelControl name="MyAddonWindow" mouseEnabled="true" movable="true" clampedToScreen="true">
    <Dimensions x="300" y="100" />
    <Anchor point="CENTER" />
    <OnMoveStop>
        MyAddon.OnWindowMoveStop(self)
    </OnMoveStop>
</TopLevelControl>
```

**Lua:**

```lua
function MyAddon.OnWindowMoveStop(control)
    local left, top = control:GetLeft(), control:GetTop()
    MyAddonSV.windowPosition = { left = left, top = top }
end

function MyAddon.RestoreWindowPosition()
    local pos = MyAddonSV.windowPosition
    if pos then
        MyAddonWindow:ClearAnchors()
        MyAddonWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, pos.left, pos.top)
    end
end

function MyAddon.ResetWindowPosition()
    MyAddonSV.windowPosition = nil
    MyAddonWindow:ClearAnchors()
    MyAddonWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
end

function MyAddon.SetWindowLocked(isLocked)
    MyAddonSV.locked = isLocked
    MyAddonWindow:SetMovable(not isLocked)
    MyAddonWindow:SetMouseEnabled(not isLocked == false or true) -- keep mouse enabled for the lock toggle itself
end
```

Add the lock checkbox to your LAM options:

```lua
[7] = {
    type = "checkbox",
    name = "Lock Window Position",
    getFunc = function() return MyAddonSV.locked end,
    setFunc = function(value) MyAddon.SetWindowLocked(value) end,
    default = false,
},
```

Call `MyAddon.RestoreWindowPosition()` once, during your `EVENT_ADD_ON_LOADED` handler (see [07 — SavedVariables](07-savedvariables.md)), so the window reappears where the player left it.

## 5. Panel Callbacks (Advanced)

LAM fires `CALLBACK_MANAGER` events you can hook for diagnostics or lazy work: `"LAM-PanelOpened"`, `"LAM-PanelClosed"`, `"LAM-RefreshPanel"`, `"LAM-PanelControlsCreated"`.

```lua
CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panelControl)
    d("Settings panel opened")
end)
```

Continue to [05 — LibConsoleDialogs](05-libconsoledialogs.md), or see the full runnable sample in [examples/03-libaddonmenu-settings](../examples/03-libaddonmenu-settings/) and [examples/04-movable-window](../examples/04-movable-window/).
