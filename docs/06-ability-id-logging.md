# 06 — Logging Ability IDs ("LibAbilityLogger")

**A transparency note first:** I checked the full public ESOUI add-on catalog (the same JSON feed the Minion add-on manager uses) and there is **no published library actually named `LibAbilityLogger`**. It's possible you saw the term used informally in a forum post/Discord, or it's a private/unlisted tool. Rather than inventing an API for a library that doesn't exist, this guide shows you the **real, verified pattern** every genuine "ability logger" addon (DPS meters, buff trackers, debug tools) actually uses under the hood: ESO's own combat/effect events plus the ability-info API functions. You get the same practical result — a console of every ability ID that fires — built entirely on documented, confirmed-real API.

If you later find the actual library you had in mind, the same event hooks below are almost certainly what it wraps internally.

**Previous:** [05 — LibConsoleDialogs](05-libconsoledialogs.md) · **Next:** [07 — SavedVariables](07-savedvariables.md) · **Back to:** [README](../README.md)

---

## 1. The Core Idea

Every time an ability fires (yours or anyone nearby's), the game raises `EVENT_COMBAT_EVENT` with an `abilityId` parameter. Every time a buff/debuff appears, changes, or fades, `EVENT_EFFECT_CHANGED` fires, also carrying an `abilityId`. Logging IDs is just: register for these events, filter to what you care about, and print/store `abilityId` plus its human-readable name.

> Exact event parameter lists have been stable for years but can occasionally gain new trailing parameters with game updates. Always cross-check the live, authoritative signatures on `wiki.esoui.com` (see [10 — How to Read the ESOUI API Reference](10-esoui-api-reference-guide.md)) if something doesn't line up — `wiki.esoui.com` blocks some automated tools, so open it directly in a browser.

## 2. Minimal Ability ID Logger

```lua
MyAbilityLogger = MyAbilityLogger or {}
local LOG_NAME = "MyAbilityLogger"

local function OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic,
                              abilityActionSlotType, sourceName, sourceType, targetName,
                              targetType, hitValue, powerType, damageType, log,
                              sourceUnitId, targetUnitId, abilityId, overflow)
    -- abilityName already comes formatted from the event, but GetAbilityName()
    -- lets you re-look-it-up any time you only have the id cached.
    d(string.format("[AbilityLog] id=%d name=%s source=%s target=%s result=%d",
        abilityId, abilityName, sourceName or "?", targetName or "?", result))
end

local function OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag,
                                beginTime, endTime, stackCount, iconName, buffType,
                                effectType, abilityType, statusEffectType, unitName,
                                unitId, abilityId, sourceType)
    -- changeType is one of EFFECT_RESULT_GAINED / EFFECT_RESULT_FADED /
    -- EFFECT_RESULT_UPDATED / EFFECT_RESULT_FULL_REFRESH
    if changeType == EFFECT_RESULT_GAINED then
        d(string.format("[AbilityLog] effect GAINED id=%d name=%s on=%s", abilityId, effectName, unitName or unitTag))
    end
end

function MyAbilityLogger.Initialize()
    EVENT_MANAGER:RegisterForEvent(LOG_NAME, EVENT_COMBAT_EVENT, OnCombatEvent)
    -- Only log events where the player is the source, to avoid a firehose of every nearby NPC's abilities:
    EVENT_MANAGER:AddFilterForEvent(LOG_NAME, EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    EVENT_MANAGER:RegisterForEvent(LOG_NAME, EVENT_EFFECT_CHANGED, OnEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(LOG_NAME, EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_UNIT_TAG, "player")
end
```

> `AddFilterForEvent` filter constants (`REGISTER_FILTER_*`) are numerous and specific to each event — only pass filter types that are actually documented as valid for the event you registered. The line above (`REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE`) is the real, commonly used filter for "only events sourced from the player"; cross-check any filter you haven't used before against the live reference before shipping.

## 3. Turning It Into a Reusable Logging Toggle + SavedVariables Buffer

A genuinely useful "ability logger" tool usually (a) lets you turn logging on/off, and (b) stores recent entries so you can review them after combat instead of scrolling chat. Combine with [07 — SavedVariables](07-savedvariables.md):

```lua
function MyAbilityLogger.LogEntry(abilityId, abilityName, extra)
    if not MyAbilityLoggerSV.enabled then return end
    local log = MyAbilityLoggerSV.entries
    table.insert(log, { id = abilityId, name = abilityName, time = GetTimeStamp(), extra = extra })
    -- cap the buffer so SavedVariables doesn't grow forever
    if #log > 500 then
        table.remove(log, 1)
    end
end
```

## 4. Looking Up Ability Info From an ID You Already Have

If you've captured an ID and want details later (tooltip text, icon, whether it's a buff), use the ability-info API:

```lua
local name = GetAbilityName(abilityId)
local icon = GetAbilityIcon(abilityId)
local isBuff = IsAbilityBuff(abilityId)   -- example helper — confirm exact name/availability in the live reference
d(string.format("Ability %d = %s (icon: %s)", abilityId, name, icon))
```

## 5. Why Filtering Matters

Without filters, `EVENT_COMBAT_EVENT` and `EVENT_EFFECT_CHANGED` fire constantly for every unit in combat range — in a crowded trial/PvP fight this can be dozens of events per second. Unfiltered logging will flood chat and can measurably impact FPS. Always filter down to `"player"` / `COMBAT_UNIT_TYPE_PLAYER` first, then widen only as needed.

Continue to [07 — SavedVariables](07-savedvariables.md), or see the runnable sample in [examples/07-ability-id-logger](../examples/07-ability-id-logger/).
