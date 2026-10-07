# 09 — Player Stats & Max Stats (`GetPlayerStat` and Friends)

Beyond the three "live resource pool" power types covered in [08](08-combat-effect-power-events.md), ESO exposes a much larger family of derived combat stats — spell/weapon power, critical chance, resistances, regeneration rates, and more — through `GetPlayerStat` and related `STAT_*` constants.

**Previous:** [08 — Combat/Effect/Power Events](08-combat-effect-power-events.md) · **Next:** [10 — ESOUI API Reference Guide](10-esoui-api-reference-guide.md) · **Back to:** [README](../README.md)

---

## 1. `GetPlayerStat`

```lua
local value = GetPlayerStat(statType, statBonusOption)
```

- `statType` — one of the `STAT_*` constants (see table below).
- `statBonusOption` — optional flag selecting *which* contribution to the stat you want (e.g. base only vs. base+buffs). Pass nothing / omit it for the normal "fully buffed, as shown on the character sheet" value in most cases.

```lua
local maxHealth = GetPlayerStat(STAT_HEALTH_MAX)
local maxMagicka = GetPlayerStat(STAT_MAGICKA_MAX)
local maxStamina = GetPlayerStat(STAT_STAMINA_MAX)
local weaponPower = GetPlayerStat(STAT_WEAPON_POWER)
local spellPower = GetPlayerStat(STAT_SPELL_POWER)
local critChance = GetPlayerStat(STAT_CRITICAL_STRIKE) -- raw rating; convert to % with the game's own formula/helper where needed
```

## 2. Common `STAT_*` Constants

| Constant | Meaning |
|---|---|
| `STAT_HEALTH_MAX` | Maximum Health |
| `STAT_MAGICKA_MAX` | Maximum Magicka |
| `STAT_STAMINA_MAX` | Maximum Stamina |
| `STAT_HEALTH_REGEN_COMBAT` / `STAT_HEALTH_REGEN_IDLE` | Health regeneration, in vs. out of combat |
| `STAT_MAGICKA_REGEN_COMBAT` / `STAT_MAGICKA_REGEN_IDLE` | Magicka regeneration |
| `STAT_STAMINA_REGEN_COMBAT` / `STAT_STAMINA_REGEN_IDLE` | Stamina regeneration |
| `STAT_WEAPON_POWER` | Weapon Damage rating |
| `STAT_SPELL_POWER` | Spell Damage rating |
| `STAT_CRITICAL_STRIKE` | Weapon Critical rating |
| `STAT_SPELL_CRITICAL` | Spell Critical rating |
| `STAT_PHYSICAL_RESIST` | Physical Resistance |
| `STAT_SPELL_RESIST` | Spell Resistance |
| `STAT_POWER_STAT_BONUS_*` | Family of bonus-only variants used for tooltip breakdowns |

This list is representative, not exhaustive — the authoritative, complete enumeration lives in the live API reference (see [10](10-esoui-api-reference-guide.md)); search it for `STAT_` to see every constant for the game version you're targeting.

## 3. Max Stats via `GetUnitPower` vs. `GetPlayerStat`

These two overlap but aren't interchangeable:

| | `GetUnitPower(unitTag, powerType)` | `GetPlayerStat(STAT_*_MAX)` |
|---|---|---|
| Works on | Any valid unit tag (`"player"`, `"reticleover"`, `"group1"`, etc.) | Only the local player |
| Returns | current, effectiveMax, max (3 values) | A single derived stat value |
| Best for | Live resource bars (health/magicka/stamina/ultimate) for any unit, including party/target frames | Character-sheet-style display, tooltips, build calculators, stat comparisons |

```lua
-- Any unit's current/max health (works on allies, bosses, etc. within visibility rules):
local current, effectiveMax, max = GetUnitPower("reticleover", COMBAT_MECHANIC_FLAGS_HEALTH)

-- Only works for the local player, but exposes the full breadth of derived stats:
local maxMagicka = GetPlayerStat(STAT_MAGICKA_MAX)
```

## 4. Keeping a Stats Display Up to Date

Stats change from gear swaps, buffs, CP (Champion Point) changes, and leveling — not just combat events. The reliable way to keep a custom stat display fresh is to recompute on a small set of events rather than only on `EVENT_POWER_UPDATE`:

```lua
local function RefreshStats()
    MyAddon.maxHealth = GetPlayerStat(STAT_HEALTH_MAX)
    MyAddon.weaponPower = GetPlayerStat(STAT_WEAPON_POWER)
    MyAddon.spellPower = GetPlayerStat(STAT_SPELL_POWER)
    MyAddon.UpdateDisplay()
end

EVENT_MANAGER:RegisterForEvent("MyAddon", EVENT_PLAYER_ACTIVATED, RefreshStats)
EVENT_MANAGER:RegisterForEvent("MyAddon", EVENT_STATS_UPDATED, RefreshStats) -- fires on most stat-affecting changes
EVENT_MANAGER:RegisterForEvent("MyAddon", EVENT_LEVEL_UPDATE, RefreshStats)
```

`EVENT_STATS_UPDATED` is the general-purpose "something about the player's stats changed" signal used by the built-in character sheet UI itself — it's the most reliable single hook for "recompute my derived stats now."

## 5. Putting It Together With Power Events

A combined health+stats panel typically:

1. Calls `RefreshStats()` once at startup (`EVENT_ADD_ON_LOADED` → `EVENT_PLAYER_ACTIVATED`) and on `EVENT_STATS_UPDATED`, for the slow-changing derived numbers.
2. Registers `EVENT_POWER_UPDATE` (see [08](08-combat-effect-power-events.md)) for the fast-changing live resource bar values.

This avoids re-querying every stat on every tiny health tick, while still keeping resource bars perfectly live.

Continue to [10 — How to Read the ESOUI API Reference](10-esoui-api-reference-guide.md), or see the runnable sample in [examples/09-player-stats](../examples/09-player-stats/).
