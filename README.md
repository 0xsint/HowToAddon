# How to Build an ESOUI Addon — Full Rundown

A from-scratch walkthrough for writing addons for *The Elder Scrolls Online* (ESOUI framework): Lua basics, the XML UI system, the manifest file, integrating the two most common community libraries ([LibAddonMenu](https://www.esoui.com/downloads/info7-LibAddonMenu-2.0.html) and [LibConsoleDialogs](https://www.esoui.com/downloads/info4106-LibConsoleDialogs.html)), SavedVariables (and how to use them safely), and the combat/effect/power events plus stat APIs you need for any combat-tracking or stat-display addon. Every topic has a matching **runnable example** in [examples/](examples/).

## How to Use This Repo

- Read the guides in [docs/](docs/) in order (01 → 10) if you're starting from zero — each builds on the last.
- Jump straight to a topic using the index below if you already know some of this.
- Every guide links to a working example folder in [examples/](examples/) — copy one into your `AddOns/` folder to see it run in-game.
- [10 — How to Read the ESOUI API Reference](docs/10-esoui-api-reference-guide.md) explains how to look up anything not covered here (`wiki.esoui.com`, the `esoui/esoui` GitHub source mirror, and the addon catalog).

## Guide Index

| # | Guide | Covers |
|---|-------|--------|
| 01 | [Lua Basics](docs/01-lua-basics.md) | Syntax, variables/scope, tables, functions, control flow, namespacing, ESO-specific gotchas |
| 02 | [XML Reference](docs/02-xml-reference.md) | Core control types, anchors, event handlers, virtual templates, connecting XML to Lua |
| 03 | [Manifest File](docs/03-manifest-file.md) | Every `.txt` manifest directive (`Title`, `APIVersion`, `SavedVariables`, `DependsOn`, `IsLibrary`, etc.), file load order |
| 04 | [LibAddonMenu Integration](docs/04-libaddonmenu.md) | Registering a settings panel, all control types, and the drag/lock/reset pattern for movable windows |
| 05 | [LibConsoleDialogs Integration](docs/05-libconsoledialogs.md) | Gamepad/console-mode settings dialogs, verified against the library's real published API |
| 06 | [Logging Ability IDs](docs/06-ability-id-logging.md) | The real, verified pattern for capturing ability IDs (see the honesty note below) |
| 07 | [SavedVariables](docs/07-savedvariables.md) | `ZO_SavedVars`, defaults/versioning, **risks of corruption/schema drift/bloat and how to manage them** |
| 08 | [Combat/Effect/Power Events](docs/08-combat-effect-power-events.md) | `EVENT_COMBAT_EVENT`, `EVENT_EFFECT_CHANGED`, `EVENT_POWER_UPDATE`, filtering, cleanup |
| 09 | [Player Stats & Max Stats](docs/09-player-stats.md) | `GetPlayerStat`, `STAT_*` constants, `GetUnitPower` vs. `GetPlayerStat`, keeping a stats display fresh |
| 10 | [How to Read the ESOUI API Reference](docs/10-esoui-api-reference-guide.md) | `wiki.esoui.com` structure, the `esoui/esoui` GitHub source mirror, the add-on catalog, forums |

## Examples Index

All runnable sample addons live in **[examples/](examples/)** — see [examples/README.md](examples/README.md) for the full table linking each one back to its doc and noting which libraries it needs.

**Want it all in one addon?** [examples/10-all-in-one](examples/10-all-in-one/) combines every guide above into a single, complete addon: a movable XML window, LibAddonMenu settings with a LibConsoleDialogs gamepad fallback, SavedVariables, ability-id logging, combat/effect/power events, and a live player-stats display — fully commented section-by-section against the docs it demonstrates.

## A Note on Accuracy

While building this guide, `wiki.esoui.com` blocked automated access from this tool, so exact event/function signatures in [06](docs/06-ability-id-logging.md), [08](docs/08-combat-effect-power-events.md), and [09](docs/09-player-stats.md) come from long-standing, widely-used community knowledge rather than a live fetch — cross-check anything you ship against the live wiki page (see [10](docs/10-esoui-api-reference-guide.md)). Where things *could* be verified directly — [LibAddonMenu-2.0](https://www.esoui.com/downloads/info7-LibAddonMenu-2.0.html)'s current version, [LibConsoleDialogs](https://www.esoui.com/downloads/info4106-LibConsoleDialogs.html)'s real usage pattern, and the current game API version from the [esoui/esoui](https://github.com/esoui/esoui) source mirror — this guide used the live source. It also turned up that **`LibAbilityLogger` is not an actual published ESOUI library** (checked against the full public add-on catalog) — see [06](docs/06-ability-id-logging.md) for the real, working alternative.

## Quick Links

- ESOUI API Wiki: https://wiki.esoui.com/
- ESOUI Game Source Mirror: https://github.com/esoui/esoui
- Add-on Download Catalog: https://www.esoui.com/downloads/
- LibAddonMenu-2.0: https://www.esoui.com/downloads/info7-LibAddonMenu-2.0.html
- LibConsoleDialogs: https://www.esoui.com/downloads/info4106-LibConsoleDialogs.html
