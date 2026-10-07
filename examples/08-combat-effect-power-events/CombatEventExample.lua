-- CombatEventExample.lua
-- Companion code for docs/08-combat-effect-power-events.md

CombatEventExample = CombatEventExample or {}
CombatEventExample.name = "CombatEventExample"

local function OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic,
                              abilityActionSlotType, sourceName, sourceType, targetName,
                              targetType, hitValue, powerType, damageType, log,
                              sourceUnitId, targetUnitId, abilityId, overflow) -- function must match signature for EVENT_COMBAT_EVENT (_ = nil)
    if result == ACTION_RESULT_DAMAGE then
        d(string.format("[Combat] %s hit %s for %d (ability %d: %s)",
            sourceName or "?", targetName or "?", hitValue, abilityId, abilityName))
    elseif result == ACTION_RESULT_HEAL then
        d(string.format("[Combat] %s healed %s for %d (ability %d: %s)",
            sourceName or "?", targetName or "?", hitValue, abilityId, abilityName))
    end
end

local function OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag,
                                beginTime, endTime, stackCount, iconName, buffType,
                                effectType, abilityType, statusEffectType, unitName,
                                unitId, abilityId, sourceType) -- function must match signature for EVENT_EFFECT_CHANGED (_ = nil)
    if changeType == EFFECT_RESULT_GAINED then
        d(string.format("[Effect] %s GAINED on %s (ability %d)", effectName, unitTag, abilityId))
    elseif changeType == EFFECT_RESULT_FADED then
        d(string.format("[Effect] %s FADED from %s (ability %d)", effectName, unitTag, abilityId))
    end
end

local function OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax) -- function must match signature for EVENT_POWER_UPDATE ( _ = nil)
    if powerType == COMBAT_MECHANIC_FLAGS_HEALTH then
        d(string.format("[Power] Health: %d / %d", powerValue, powerMax))
    end
end

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= CombatEventExample.name then return end
    EVENT_MANAGER:UnregisterForEvent(CombatEventExample.name, EVENT_ADD_ON_LOADED)

    EVENT_MANAGER:RegisterForEvent(CombatEventExample.name, EVENT_COMBAT_EVENT, OnCombatEvent)
    --[[
    EVENT "String", EVENT_COMBAT_EVENT (EVENT_ID) OnCombatEvent (Combat Function)
    ]]
    EVENT_MANAGER:AddFilterForEvent(CombatEventExample.name, EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    EVENT_MANAGER:RegisterForEvent(CombatEventExample.name, EVENT_EFFECT_CHANGED, OnEffectChanged)
    --[[
    EVENT "String", EVENT_EFFECT_CHANGED (EVENT_ID) OnEffectChanged (Effect Function)
    ]]
    EVENT_MANAGER:AddFilterForEvent(CombatEventExample.name, EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_UNIT_TAG, "player")

    EVENT_MANAGER:RegisterForEvent(CombatEventExample.name, EVENT_POWER_UPDATE, OnPowerUpdate)
    --[[
    EVENT "String", EVENT_POWER_UPDATE (EVENT_ID) OnPowerUpdate (Power Function)
    ]]
    EVENT_MANAGER:AddFilterForEvent(CombatEventExample.name, EVENT_POWER_UPDATE,
        REGISTER_FILTER_UNIT_TAG, "player",
        REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH)

    d("|cFFFF00[CombatEventExample]|r loaded. Enter combat to see events in chat.")
end

EVENT_MANAGER:RegisterForEvent(CombatEventExample.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
