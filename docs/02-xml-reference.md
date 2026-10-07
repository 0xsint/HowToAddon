# 02 — XML Reference for ESOUI Elements

ESO addon UI is normally built with XML control definitions, then wired up to Lua with handlers and `GetControl()` lookups. This is a practical reference to the elements you'll use constantly. For the exhaustive, authoritative list of every control type and every inherited virtual template, use the [ESOUI API reference](10-esoui-api-reference-guide.md) and the game's own `esoui/` source (see that guide for how to search it).

**Previous:** [01 — Lua Basics](01-lua-basics.md) · **Next:** [03 — Manifest File](03-manifest-file.md) · **Back to:** [README](../README.md)

---

## 1. Document Root

Every XML file starts with:

```xml
<GuiXml>
    <Controls>
        <!-- your controls go here -->
    </Controls>
</GuiXml>
```

`<Controls>` is the top-level container for every control definition in the file. `<GuiXml>` is just the file wrapper and has no other purpose.

## 2. The Core Control Types

| Element | Purpose |
|---|---|
| `<TopLevelControl>` | A window/frame that can be shown, hidden, and (optionally) dragged. Most addon windows start here. |
| `<Control>` | A generic, invisible container used purely for layout/anchoring groups of children. |
| `<Backdrop>` | A rectangle with a background texture/edge — the classic "panel" look. |
| `<Label>` | Text. |
| `<Texture>` | An image (icon, border, background art). |
| `<Button>` | A clickable button (supports `normal`/`pressed`/`mouseOver`/`disabled` textures). |
| `<EditBox>` | Single or multi-line text input. |
| `<Slider>` | A draggable value slider. |
| `<Checkbox>` | Boolean toggle control. |
| `<Cooldown>` | Radial/clock-style cooldown swipe overlay, used for ability icons. |
| `<StatusBar>` | A fill bar — health/magicka/stamina bars, progress bars, etc. |

## 3. Common Attributes

Every control supports:

```xml
<Control name="$(parent)MyControl" ... >
```

- `name` — the control's identifier. `$(parent)` is replaced with the parent control's name at creation time — this is how you build unique names for nested/templated controls.
- `virtual="true"` — marks a control as a **template**: it is never instantiated directly, only inherited via `inherits="TemplateName"`.
- `inherits="SomeTemplate"` — copies all properties/anchors/children from another (usually virtual) control.
- `hidden="true"` — starts invisible (toggle later with `control:SetHidden(false)`).
- `mouseEnabled="true"`, `movable="true"`, `clampedToScreen="true"` — interaction flags, mainly on `TopLevelControl`.

### Dimensions

```xml
<Dimensions x="300" y="200" />
```

### Anchors

Anchors position a control relative to another control (or its own parent). This is the single most important layout mechanism in ESOUI XML — there is no flow/grid layout, everything is anchor-based.

```xml
<Anchor point="TOPLEFT" relativeTo="$(parent)" relativePoint="TOPLEFT" offsetX="10" offsetY="10" />
```

- `point` — the point on **this** control being anchored.
- `relativeTo` — name of the other control (omit/"" to anchor relative to the parent).
- `relativePoint` — the point on the **target** control to anchor to.
- `offsetX` / `offsetY` — pixel offsets.

Valid points: `TOPLEFT`, `TOP`, `TOPRIGHT`, `LEFT`, `CENTER`, `RIGHT`, `BOTTOMLEFT`, `BOTTOM`, `BOTTOMRIGHT`.

## 4. Event Handlers in XML

Controls can wire Lua functions directly to lifecycle/input events:

```xml
<TopLevelControl name="MyAddonWindow">
    <Dimensions x="300" y="200" />
    <Anchor point="CENTER" />
    <OnInitialized>
        MyAddon.OnWindowInitialized(self)
    </OnInitialized>
</TopLevelControl>

<Button name="$(parent)CloseButton" inherits="ZO_CloseButton">
    <Anchor point="TOPRIGHT" />
    <OnClicked>
        MyAddon.OnCloseClicked(self)
    </OnClicked>
</Button>
```

Common handler tags: `OnInitialized`, `OnShow`, `OnHide`, `OnClicked`, `OnMouseEnter`, `OnMouseExit`, `OnMouseUp`, `OnMouseDown`, `OnEffectivelyShown`, `OnMoveStop` (after a drag). Inside a handler, `self` refers to the control itself.

## 5. A Full Minimal Example

```xml
<GuiXml>
    <Controls>
        <TopLevelControl name="MyAddonWindow" mouseEnabled="true" movable="true" clampedToScreen="true">
            <Dimensions x="320" y="120" />
            <Anchor point="CENTER" />
            <Controls>
                <Backdrop name="$(parent)Bg" inherits="ZO_DefaultBackdrop">
                    <AnchorFill />
                </Backdrop>
                <Label name="$(parent)Title" font="ZoFontWinH3" text="My Addon">
                    <Anchor point="TOP" offsetY="8" />
                </Label>
                <Button name="$(parent)CloseButton" inherits="ZO_CloseButton">
                    <Anchor point="TOPRIGHT" offsetX="-4" offsetY="4" />
                    <OnClicked>
                        MyAddonWindow:SetHidden(true)
                    </OnClicked>
                </Button>
            </Controls>
        </TopLevelControl>
    </Controls>
</GuiXml>
```

`<AnchorFill />` is shorthand that anchors all four corners of a control to its parent, making it fill the available space — very common for `Backdrop` layers.

## 6. Virtual Templates (Reusing Layout)

```xml
<Button name="MyAddonIconButtonTemplate" virtual="true">
    <Dimensions x="32" y="32" />
    <Textures normal="EsoUI/Art/Buttons/icon_up.dds" pressed="EsoUI/Art/Buttons/icon_down.dds" />
</Button>

<Button name="$(parent)Button1" inherits="MyAddonIconButtonTemplate">
    <Anchor point="TOPLEFT" />
</Button>
```

Templates let you define a control's look once and stamp out many copies — the same pattern the base game uses extensively (you'll see `virtual="true"` all over `esoui/` source).

## 7. Connecting XML to Lua: the Manifest

XML files must be listed in your addon's [manifest file](03-manifest-file.md) just like `.lua` files, and are loaded in order. Once loaded, any named control becomes accessible from Lua globally by its exact `name`, or via `GetControl(parent, "ChildName")`:

```lua
local window = MyAddonWindow        -- top-level named control is a direct global
local closeButton = GetControl(window, "CloseButton")
```

Next: see the manifest file reference in [03 — Manifest File](03-manifest-file.md), or a runnable XML UI sample in [examples/02-xml-ui](../examples/02-xml-ui/).
