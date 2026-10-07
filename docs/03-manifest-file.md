# 03 — The Manifest File (`.txt`) and All Its Options

Every ESO addon needs exactly one **manifest file**: a plain-text file named identically to your addon's folder, with a `.txt` extension (e.g. folder `MyAddon/` → manifest `MyAddon/MyAddon.txt`). It tells the game client what your addon is, which API versions it supports, what files to load (and in what order), and what libraries it needs.

**Previous:** [02 — XML Reference](02-xml-reference.md) · **Next:** [04 — LibAddonMenu](04-libaddonmenu.md) · **Back to:** [README](../README.md)

---

## 1. File / Folder Layout Rule

```
AddOns/
  MyAddon/
    MyAddon.addon        <-- manifest, must match folder name exactly
    MyAddon.lua
    MyAddon.xml
```

The manifest's base filename **must** match its containing folder's name. Case matters on some platforms (consoles, and case-sensitive filesystems) even though Windows is forgiving — always match case exactly.

## 2. Directive Syntax

Directives are lines starting with `## `, followed by `Key: Value`. Lines that don't start with `##` are treated as file paths to load (relative to the manifest's folder), one per line.

```text
## Title: My Addon
## Description: Does something useful.

MyAddon.lua
MyAddon.xml
```

## 3. Full Directive Reference

| Directive | Required? | Purpose / Example |
|---|---|---|
| `## Title:` | Yes | Display name shown in the in-game addon list. Supports color codes, e.g. `## Title: \|c00FF00My Addon\|r`. |
| `## Description:` | Recommended | One-line summary shown under the title. |
| `## Author:` | Recommended | Your name / handle. |
| `## Version:` | Recommended | Human-readable version string, e.g. `1.0.0`. Shown to players. |
| `## AddOnVersion:` | Recommended | A plain **integer** used by addon managers (Minion) to detect updates. Increment on every release, e.g. `## AddOnVersion: 7`. |
| `## APIVersion:` | **Yes** | One or more integers identifying which game API version(s) your addon supports. The game refuses to load addons whose APIVersion doesn't match the client. Example (PC): `## APIVersion: 101051`. You can list two values to support both the live and a PTS build simultaneously: `## APIVersion: 101050 101051`. **This number changes with every game update** — check the current value via the in-game addon manager's "out of date" warnings, the [ESOUI source repo](https://github.com/esoui/esoui) (its README states the current API version), or the [ESOUI API reference guide](10-esoui-api-reference-guide.md). |
| `## SavedVariables:` | If you persist data | Declares the **global Lua table name(s)** that should be written to disk / read back as [SavedVariables](07-savedvariables.md). Space-separated for multiple: `## SavedVariables: MyAddonSV MyAddonSV_Char`. The table must exist as a true global (not `local`) for the save system to find it. |
| `## DependsOn:` | If you use libraries | Space-separated list of other addon/library folder names that must be installed and loaded first. Supports version constraints: `## DependsOn: LibAddonMenu-2.0>=35 LibDebugLogger>=2`. If a dependency is missing, your addon is disabled and the player is warned. |
| `## OptionalDependsOn:` | If you *optionally* integrate a library | Same syntax as `DependsOn`, but your addon still loads if missing — you must guard usage with `if LibName then ... end` in Lua. |
| `## IsLibrary:` | Libraries only | Set `true` so the addon manager treats it as a shared library (hidden from the normal addon list, no "enable/disable" toggle shown the same way). |
| `## AllowOutOfDateApiVersion:` | Optional | `true` lets the addon attempt to load even if its `APIVersion` doesn't match current — useful while waiting on an update, risky for correctness. |
| `## Contact:` | Optional | Email/forum/discord contact info. |
| `## Website:` / `## URL:` | Optional | Link to the addon's homepage/download page. |
| `## Icon:` | Optional | Path to a texture shown next to the addon's entry. |
| `## License:` | Optional | License text/identifier. |
| `## Localization:` | Optional (deprecated by some) | Points to a locale sub-manifest system for translated strings, if you split locales into separate files. |
| `## SavedVariables-OpenWorld:` / similar variants | Rare | A handful of addons use specialized/segmented SavedVariables declarations (e.g. for Lua table partitioning) — treat these as advanced/edge-case and confirm current behavior in the API reference before relying on them. |

## 4. File List (Load Order)

Everything below the `##` directives that is **not** a directive is a path to a file to load, one per line, loaded top-to-bottom into one shared Lua/XML environment:

```text
## Title: My Addon
## APIVersion: 101051
## SavedVariables: MyAddonSV

libs/LibAddonMenu-2.0/LibAddonMenu-2.0.lua
libs/LibAddonMenu-2.0/LibAddonMenu-2.0.xml
MyAddon.xml
MyAddon.lua
```

Rules of thumb:
- **Libraries/dependencies your file references must be loaded first** (unless they come from a separate addon folder declared via `DependsOn`, in which case the game loads that whole addon — and therefore its files — before yours).
- **XML before the Lua that references its named controls**, if that Lua runs at load time (most control lookups happen inside `EVENT_ADD_ON_LOADED`, so strict XML-before-Lua ordering is less critical than it used to be, but it remains best practice).
- Only list `.lua` and `.xml` files — everything else (textures, fonts) is referenced by path from within those files, not listed in the manifest.

## 5. A Complete, Realistic Manifest

```text
## Title: |c00A2FFMy Addon|r
## Description: Tracks ability usage and shows a movable stats window.
## Author: YourName
## Version: 1.2.0
## AddOnVersion: 5
## APIVersion: 101051
## SavedVariables: MyAddonSV
## DependsOn: LibAddonMenu-2.0>=35
## OptionalDependsOn: LibConsoleDialogs
## IsLibrary: false
## Contact: you@example.com
## Website: https://www.esoui.com/downloads/info0000-MyAddon.html

MyAddon.xml
MyAddon.lua
```

## 6. Verifying Your Manifest

- The in-game **Add-Ons** menu will show a red warning (and refuse to enable the addon) if `APIVersion` doesn't match, or if a `DependsOn` target is missing/disabled.
- Check `Documents/Elder Scrolls Online/live/AddOns/` (or your platform equivalent) — the client writes load errors to `SavedVariables/../Logs` and to the in-game `/script` error popups if you've enabled Lua error display in **Settings → Addon Settings**.

Continue to [04 — LibAddonMenu Integration](04-libaddonmenu.md), or see a working manifest in [examples/01-first-addon/FirstAddon.txt](../examples/01-first-addon/FirstAddon.txt).
