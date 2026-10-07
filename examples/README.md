# Examples Index

Each folder below is a small, self-contained ESOUI addon that demonstrates exactly one concept from the [docs/](../docs/) guides. Every folder follows the real addon layout: a manifest `.txt` file plus the `.lua`/`.xml` files it lists (see [03 — Manifest File](../docs/03-manifest-file.md)).

**To try one:** copy the folder into `Documents/Elder Scrolls Online/live/AddOns/`, rename the folder and its manifest to match (the manifest's base filename must equal its folder name), and enable it in-game. A couple of examples declare a dependency on [LibAddonMenu-2.0](https://www.esoui.com/downloads/info7-LibAddonMenu-2.0.html) or [LibConsoleDialogs](https://www.esoui.com/downloads/info4106-LibConsoleDialogs.html) — install those alongside if the example needs them (noted per-folder below).

| # | Example | Demonstrates | Companion doc | Needs a library? |
|---|---------|---------------|----------------|-------------------|
| 01 | [first-addon](01-first-addon/) | The smallest possible addon: manifest + one Lua file, `EVENT_ADD_ON_LOADED`, a slash command | [01 — Lua Basics](../docs/01-lua-basics.md) | No |
| 02 | [xml-ui](02-xml-ui/) | A movable `TopLevelControl` window built in XML, wired to Lua | [02 — XML Reference](../docs/02-xml-reference.md) | No |
| 03 | [libaddonmenu-settings](03-libaddonmenu-settings/) | Registering a LibAddonMenu settings panel (checkbox/slider/dropdown) backed by SavedVariables | [04 — LibAddonMenu](../docs/04-libaddonmenu.md) | LibAddonMenu-2.0 |
| 04 | [movable-window](04-movable-window/) | Drag-to-move window + SavedVariables position + LAM lock/reset controls | [04 — LibAddonMenu](../docs/04-libaddonmenu.md) | LibAddonMenu-2.0 |
| 05 | [libconsoledialogs](05-libconsoledialogs/) | A gamepad-mode settings dialog via LibConsoleDialogs, with a PC-mode-safe fallback | [05 — LibConsoleDialogs](../docs/05-libconsoledialogs.md) | LibConsoleDialogs (optional) |
| 06 | [savedvariables](06-savedvariables/) | `ZO_SavedVars` defaults/versioning + a size-capped log buffer + reset command | [07 — SavedVariables](../docs/07-savedvariables.md) | No |
| 07 | [ability-id-logger](07-ability-id-logger/) | Logging ability IDs from combat/effect events into SavedVariables | [06 — Logging Ability IDs](../docs/06-ability-id-logging.md) | No |
| 08 | [combat-effect-power-events](08-combat-effect-power-events/) | `EVENT_COMBAT_EVENT`, `EVENT_EFFECT_CHANGED`, `EVENT_POWER_UPDATE` side by side | [08 — Combat/Effect/Power Events](../docs/08-combat-effect-power-events.md) | No |
| 09 | [player-stats](09-player-stats/) | `GetPlayerStat`, `GetUnitPower`, refreshing derived stats on `EVENT_STATS_UPDATED` | [09 — Player Stats & Max Stats](../docs/09-player-stats.md) | No |
| 10 | [all-in-one](10-all-in-one/) | **Everything combined into one addon**: movable XML window, LibAddonMenu settings + LibConsoleDialogs gamepad fallback, SavedVariables, ability-id logging, combat/effect/power events, and a live player-stats display | All of the above | LibAddonMenu-2.0 (required), LibConsoleDialogs (optional) |

## The Combined Example

[examples/10-all-in-one](10-all-in-one/) is a single, complete addon that exercises every guide at once — think of it as the "capstone" example. It opens a draggable window (`/allinone`) showing live health/stats and a rolling log of ability IDs captured from combat/effect events, with a full LibAddonMenu settings page (enable toggle, update-frequency slider, display-mode dropdown, lock/reset window controls, print/clear log buttons) and an equivalent LibConsoleDialogs panel for gamepad mode. Read its [AllInOneExample.lua](10-all-in-one/AllInOneExample.lua) top-to-bottom — every section is labeled with the doc it demonstrates.

Back to the [main README](../README.md) for the full guide index, including the [manifest reference](../docs/03-manifest-file.md) and [how to read the ESOUI API reference](../docs/10-esoui-api-reference-guide.md).
