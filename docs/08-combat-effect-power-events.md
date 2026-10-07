# 08 — Combat, Effect, and Power Events

These three events are the backbone of almost every combat-tracking addon: damage/healing meters, buff/debuff trackers, and resource (health/magicka/stamina/ultimate) displays.

**Previous:** [07 — SavedVariables](07-savedvariables.md) · **Next:** [09 — Player Stats & Max Stats](09-player-stats.md) · **Back to:** [README](../README.md)

> As with [06 — Logging Ability IDs](06-ability-id-logging.md), treat the exact parameter lists below as the long-standing, widely-used community-documented signatures. Confirm against the live `wiki.esoui.com` page for each event if you need 100% certainty for a shipping addon, since the automated tooling used to write this guide could not reach that specific site directly (see [10](10-esoui-api-reference-guide.md) for how to check it yourself).

---

## 1. `EVENT_COMBAT_EVENT`

Fires for (almost) every damage, heal, resource-cost, dodge, block, etc. "combat result" in range — both yours and other units'.

```lua
local function OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic,
                              abilityActionSlotType, sourceName, sourceType, targetName,
                              targetType, hitValue, powerType, damageType, log,
                              sourceUnitId, targetUnitId, abilityId, overflow)
    -- result is one of the ACTION_RESULT_* constants, e.g. ACTION_RESULT_DAMAGE, ACTION_RESULT_HEAL, ACTION_RESULT_DODGED
end

EVENT_MANAGER:RegisterForEvent("MyAddon", EVENT_COMBAT_EVENT, OnCombatEvent)

-- Filtering down (recommended -- unfiltered fires constantly in group content):
EVENT_MANAGER:AddFilterForEvent("MyAddon", EVENT_COMBAT_EVENT,
    REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
EVENT_MANAGER:AddFilterForEvent("MyAddon", EVENT_COMBAT_EVENT,
    REGISTER_FILTER_IS_ERROR, false)
```

Typical uses: damage meters, "you were hit for X" alerts, interrupt/block/dodge trackers, and (as covered in [06](06-ability-id-logging.md)) ability-id logging.

## 2. `EVENT_EFFECT_CHANGED`

Fires when a buff or debuff is gained, refreshed, updated (e.g. stack count changed), or fades from a unit.

```lua
local function OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag,
                                beginTime, endTime, stackCount, iconName, buffType,
                                effectType, abilityType, statusEffectType, unitName,
                                unitId, abilityId, sourceType)
    if changeType == EFFECT_RESULT_GAINED then
        d(effectName .. " gained on " .. unitTag)
    elseif changeType == EFFECT_RESULT_FADED then
        d(effectName .. " faded from " .. unitTag)
    end
end

EVENT_MANAGER:RegisterForEvent("MyAddon", EVENT_EFFECT_CHANGED, OnEffectChanged)
EVENT_MANAGER:AddFilterForEvent("MyAddon", EVENT_EFFECT_CHANGED,
    REGISTER_FILTER_UNIT_TAG, "player")
```

`changeType` values: `EFFECT_RESULT_GAINED`, `EFFECT_RESULT_FADED`, `EFFECT_RESULT_UPDATED`, `EFFECT_RESULT_FULL_REFRESH`. `endTime`/`beginTime` are timestamps (seconds) you can use to build a countdown/cooldown display (see `<Cooldown>` in [02 — XML Reference](02-xml-reference.md)).

Typical uses: buff/debuff bars, "Major/Minor X missing" warnings, DoT/HoT uptime tracking.

## 3. `EVENT_POWER_UPDATE`

Fires when a unit's resource pool (health, magicka, stamina, ultimate, werewolf, mount stamina, etc.) changes.

```lua
local function OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    if powerType == COMBAT_MECHANIC_FLAGS_HEALTH then
        d(string.format("Health: %d / %d", powerValue, powerMax))
    end
end

EVENT_MANAGER:RegisterForEvent("MyAddon", EVENT_POWER_UPDATE, OnPowerUpdate)
EVENT_MANAGER:AddFilterForEvent("MyAddon", EVENT_POWER_UPDATE,
    REGISTER_FILTER_UNIT_TAG, "player",
    REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH)
```

Common `powerType` ("power mechanic") constants: `COMBAT_MECHANIC_FLAGS_HEALTH`, `COMBAT_MECHANIC_FLAGS_MAGICKA`, `COMBAT_MECHANIC_FLAGS_STAMINA`, `COMBAT_MECHANIC_FLAGS_ULTIMATE`, `COMBAT_MECHANIC_FLAGS_WEREWOLF`, `COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA`.

Typical uses: custom unit frames, resource bars, low-health warnings, ultimate-ready alerts.

## 4. Pulling Power on Demand (Without Waiting for the Event)

You don't have to wait for `EVENT_POWER_UPDATE` to read a current value — `GetUnitPower` gives you a point-in-time snapshot, useful on addon load or any time you need "the value right now":

```lua
local current, effectiveMax, max = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_HEALTH)
d(string.format("Health now: %d / %d (effective max %d)", current, max, effectiveMax))
```

This pairs naturally with [09 — Player Stats & Max Stats](09-player-stats.md), which covers the broader `GetPlayerStat` family for things that aren't simple "current/max" power pools (spell power, critical chance, resistances, regen rates, etc.).

## 5. Unregistering Cleanly

Always unregister events you no longer need (e.g. when your window is hidden, or on `EVENT_PLAYER_DEACTIVATED` before a loading screen) to avoid wasted work:

```lua
EVENT_MANAGER:UnregisterForEvent("MyAddon", EVENT_COMBAT_EVENT)
```

Continue to [09 — Player Stats & Max Stats](09-player-stats.md), or see the runnable sample in [examples/08-combat-effect-power-events](../examples/08-combat-effect-power-events/).
