# 05 — Integrating LibConsoleDialogs

[LibConsoleDialogs](https://www.esoui.com/downloads/info4106-LibConsoleDialogs.html) by **votan** brings a LibAddonMenu-style settings experience to **gamepad mode / console**, where the normal keyboard-and-mouse Settings panel UI doesn't work the same way. It mirrors the control types from `LibHarvensAddonSettings`, so if you've used that library the API will look familiar.

**Previous:** [04 — LibAddonMenu](04-libaddonmenu.md) · **Next:** [06 — Logging Ability IDs](06-ability-id-logging.md) · **Back to:** [README](../README.md)

> The snippets below are taken directly from the library's own published usage example on its ESOUI download page, so the control names/types are verified against the real API rather than guessed.

---

## 1. Install & Declare the Dependency

```text
## OptionalDependsOn: LibConsoleDialogs
```

Use `OptionalDependsOn` (not `DependsOn`) if your addon should still work on PC/keyboard-mode without it — then guard all usage with `if LibConsoleDialogs then ... end`.

## 2. Create a Dialog and Add Settings

```lua
if not LibConsoleDialogs then return end -- gamepad-only library; skip on keyboard-only setups if not installed

local areSettingsDisabled = false

local settings = LibConsoleDialogs:Create("My Addon Settings") -- title; does not need to be unique

local checkbox = {
    type = LibHarvensAddonSettings.ST_CHECKBOX,
    label = "Enable Feature",
    tooltip = "This is an example checkbox",
    default = false,
    setFunction = function(state)
        MyAddonSV.enabled = state
    end,
    getFunction = function()
        return MyAddonSV.enabled
    end,
    disable = function()
        return areSettingsDisabled
    end,
}
settings:AddSetting(checkbox)

local slider = {
    type = LibHarvensAddonSettings.ST_SLIDER,
    label = "Update Frequency",
    tooltip = "This is an example slider",
    min = 100, max = 2000, step = 100,
    format = "%d",
    setFunction = function(value)
        MyAddonSV.updateMs = value
    end,
    getFunction = function()
        return MyAddonSV.updateMs
    end,
    disable = function()
        return areSettingsDisabled
    end,
}
settings:AddSetting(slider)

local dropdown = {
    type = LibHarvensAddonSettings.ST_DROPDOWN,
    label = "Example Dropdown",
    tooltip = "This is an example dropdown",
    items = { "Compact", "Full" },
    setFunction = function(combobox, name, item)
        d("Selected item: " .. name)
        MyAddonSV.displayMode = name
    end,
    getFunction = function()
        return MyAddonSV.displayMode
    end,
}
settings:AddSetting(dropdown)

local MY_DIALOG = settings
```

Other available `LibHarvensAddonSettings` control-type constants used the same way: `ST_BUTTON`, `ST_EDIT`, `ST_LABEL`, `ST_SECTION`, `ST_COLOR`.

## 3. Hook a Keybind to Open the Dialog

The library exposes its dialogs through the gamepad keybind strip on a given scene (e.g. the quest journal root scene):

```lua
LibConsoleDialogs:RegisterKeybind(
    GAMEPAD_QUEST_JOURNAL_ROOT_SCENE,
    {
        name = "My Addon Settings",
        tooltip = "Brief description of option 1",
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
        callback = function(buttonInfo)
            MY_DIALOG:Show()
            -- or: SCENE_MANAGER:ShowScene(yourCustomGamepadScene) for a fully custom gamepad UI
        end,
    }
)
```

## 4. Why a Separate Library Exists for This

Gamepad-mode UI in ESO uses a completely different widget/focus system (scene graph + keybind strip navigation) than keyboard/mouse mode. LibAddonMenu's panels assume mouse interaction, so they don't render correctly for gamepad players — LibConsoleDialogs exists specifically to bridge that gap, which is why many addons declare **both** LibAddonMenu (for PC) and LibConsoleDialogs (for gamepad/console) as optional dependencies and branch based on `IsInGamepadPreferredMode()`.

```lua
local function OpenSettings()
    if IsInGamepadPreferredMode() and LibConsoleDialogs then
        MY_DIALOG:Show()
    elseif LibAddonMenu2 then
        LibAddonMenu2:OpenToPanel(MyAddonLAMPanel)
    end
end
```

Continue to [06 — Logging Ability IDs](06-ability-id-logging.md), or see the runnable sample in [examples/05-libconsoledialogs](../examples/05-libconsoledialogs/).
