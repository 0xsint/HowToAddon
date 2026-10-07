-- AbilityIdLogger.lua
-- Companion code for docs/06-ability-id-logging.md
-- NOTE: "LibAbilityLogger" is not a real published ESOUI library (verified against the
-- public add-on catalog) -- this is a small, self-contained logger built on the real,
-- documented EVENT_COMBAT_EVENT / EVENT_EFFECT_CHANGED API instead.

AbilityIdLogger = AbilityIdLogger or {}
AbilityIdLogger.name = "AbilityIdLogger"

local MAX_ENTRIES = 300

local defaults = {
    enabled = true,
    entries = {},
}

local function AddEntry(abilityId, abilityName, kind)
    if not AbilityIdLoggerSV.enabled then return end

    table.insert(AbilityIdLoggerSV.entries, {
        id = abilityId,
        name = abilityName,
        kind = kind, -- "combat" or "effect"
        time = GetTimeStamp(),
    })

    while #AbilityIdLoggerSV.entries > MAX_ENTRIES do
        table.remove(AbilityIdLoggerSV.entries, 1)
    end
end

local function OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic,
                              abilityActionSlotType, sourceName, sourceType, targetName,
                              targetType, hitValue, powerType, damageType, log,
                              sourceUnitId, targetUnitId, abilityId, overflow)
    AddEntry(abilityId, abilityName, "combat")
    d(string.format("[AbilityIdLogger] combat id=%d name=%s", abilityId, abilityName))
end

local function OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag,
                                beginTime, endTime, stackCount, iconName, buffType,
                                effectType, abilityType, statusEffectType, unitName,
                                unitId, abilityId, sourceType)
    if changeType == EFFECT_RESULT_GAINED then
        AddEntry(abilityId, effectName, "effect")
        d(string.format("[AbilityIdLogger] effect GAINED id=%d name=%s", abilityId, effectName))
    end
end

function AbilityIdLogger.PrintLog()
    for i, entry in ipairs(AbilityIdLoggerSV.entries) do
        d(string.format("[%d] %s id=%d name=%s", i, entry.kind, entry.id, entry.name))
    end
end

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= AbilityIdLogger.name then return end
    EVENT_MANAGER:UnregisterForEvent(AbilityIdLogger.name, EVENT_ADD_ON_LOADED)

    AbilityIdLoggerSV = ZO_SavedVars:NewAccountWide("AbilityIdLoggerSV", 1, nil, defaults)

    EVENT_MANAGER:RegisterForEvent(AbilityIdLogger.name, EVENT_COMBAT_EVENT, OnCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(AbilityIdLogger.name, EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    EVENT_MANAGER:RegisterForEvent(AbilityIdLogger.name, EVENT_EFFECT_CHANGED, OnEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(AbilityIdLogger.name, EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_UNIT_TAG, "player")

    SLASH_COMMANDS["/abilitylog"] = function(args)
        if args == "print" then
            AbilityIdLogger.PrintLog()
        elseif args == "off" then
            AbilityIdLoggerSV.enabled = false
            d("|cFFFF00[AbilityIdLogger]|r logging disabled.")
        elseif args == "on" then
            AbilityIdLoggerSV.enabled = true
            d("|cFFFF00[AbilityIdLogger]|r logging enabled.")
        else
            d("Usage: /abilitylog on | off | print")
        end
    end

    d("|cFFFF00[AbilityIdLogger]|r loaded. Use /abilitylog on|off|print.")
end

EVENT_MANAGER:RegisterForEvent(AbilityIdLogger.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
