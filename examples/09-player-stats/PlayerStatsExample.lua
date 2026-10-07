-- PlayerStatsExample.lua
-- Companion code for docs/09-player-stats.md

PlayerStatsExample = PlayerStatsExample or {}
PlayerStatsExample.name = "PlayerStatsExample"

function PlayerStatsExample.PrintStats()
    local maxHealth = GetPlayerStat(STAT_HEALTH_MAX)
    local maxMagicka = GetPlayerStat(STAT_MAGICKA_MAX)
    local maxStamina = GetPlayerStat(STAT_STAMINA_MAX)
    local weaponPower = GetPlayerStat(STAT_WEAPON_POWER)
    local spellPower = GetPlayerStat(STAT_SPELL_POWER)

    d(string.format("Max Health: %d | Max Magicka: %d | Max Stamina: %d", maxHealth, maxMagicka, maxStamina))
    d(string.format("Weapon Power: %d | Spell Power: %d", weaponPower, spellPower))

    local current, effectiveMax, max = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_HEALTH)
    d(string.format("Live Health (GetUnitPower): %d / %d", current, max))
end

local function OnStatsChanged()
    PlayerStatsExample.PrintStats()
end

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= PlayerStatsExample.name then return end
    EVENT_MANAGER:UnregisterForEvent(PlayerStatsExample.name, EVENT_ADD_ON_LOADED)

    EVENT_MANAGER:RegisterForEvent(PlayerStatsExample.name, EVENT_PLAYER_ACTIVATED, OnStatsChanged)
    EVENT_MANAGER:RegisterForEvent(PlayerStatsExample.name, EVENT_STATS_UPDATED, OnStatsChanged)
    EVENT_MANAGER:RegisterForEvent(PlayerStatsExample.name, EVENT_LEVEL_UPDATE, OnStatsChanged)

    SLASH_COMMANDS["/mystats"] = PlayerStatsExample.PrintStats

    d("|cFFFF00[PlayerStatsExample]|r loaded. Type /mystats to print your current stats.")
end

EVENT_MANAGER:RegisterForEvent(PlayerStatsExample.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
