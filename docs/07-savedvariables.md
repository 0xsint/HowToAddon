# 07 — SavedVariables: Saving Data, Safely

SavedVariables is ESO's persistence system: any **global** Lua table you declare in your [manifest](03-manifest-file.md) under `## SavedVariables:` gets serialized to disk when you log out / reload UI, and deserialized back before your addon's `EVENT_ADD_ON_LOADED` fires on the next load.

**Previous:** [06 — Logging Ability IDs](06-ability-id-logging.md) · **Next:** [08 — Combat/Effect/Power Events](08-combat-effect-power-events.md) · **Back to:** [README](../README.md)

---

## 1. Where the Data Actually Lives

```
Documents/Elder Scrolls Online/live/SavedVariables/MyAddon.lua
```

It's a plain Lua file containing a big table literal, keyed by **account name → @, then character name, then your table name**. You can open it in a text editor while the game is closed (never edit it while the game is running — your changes will be overwritten on next save).

## 2. Declaring It

```text
## SavedVariables: MyAddonSV
```

```lua
MyAddonSV = MyAddonSV or {}   -- must be a real global, not local, for the save system to find it
```

## 3. The Right Way: `ZO_SavedVars`

Don't read/write the raw global table yourself — use the built-in `ZO_SavedVars` wrapper. It handles default-value population, versioning/migration, and account-wide vs. per-character scoping for you, and is what essentially every well-built addon uses.

```lua
local defaults = {
    enabled = true,
    updateMs = 500,
    displayMode = "Compact",
    windowPosition = nil,
    entries = {},
}

function MyAddon.Initialize()
    -- Per-character settings:
    MyAddonSV = ZO_SavedVars:New("MyAddonSV", 1, nil, defaults)
    -- or, for account-wide (shared across all characters on the account):
    -- MyAddonSV = ZO_SavedVars:NewAccountWide("MyAddonSV", 1, nil, defaults)
end
```

Signature: `ZO_SavedVars:New(savedVariableTableName, version, namespace, defaults, profile, displayName)`

| Param | Meaning |
|---|---|
| `savedVariableTableName` | The exact string name of the global declared in your manifest. |
| `version` | An integer you control. Bump it whenever you change the *shape* of your defaults table to trigger a one-time migration (see below). |
| `namespace` | Optional string — lets multiple independent tables share one saved-variable global (rarely needed; usually `nil`). |
| `defaults` | A table of default values; any missing key in the player's saved data is filled in automatically, recursively. |
| `profile` | Optional string to key data by a custom "profile" (e.g. per-spec) instead of just account/character. |
| `displayName` | Optional override for whose data to load (rarely used). |

Use `ZO_SavedVars:NewAccountWide(...)` instead of `:New(...)` when you want the **same** data shared by every character on the account (e.g. global UI preferences), rather than per-character data (e.g. a character-specific ability log).

## 4. Initializing at the Right Time

SavedVariables are **not available** until `EVENT_ADD_ON_LOADED` fires for your addon (the game is still loading data when your top-level `.lua` chunk first executes):

```lua
local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= "MyAddon" then return end
    EVENT_MANAGER:UnregisterForEvent("MyAddon", EVENT_ADD_ON_LOADED)

    MyAddon.Initialize() -- safe to touch MyAddonSV from here on
end
EVENT_MANAGER:RegisterForEvent("MyAddon", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
```

`EVENT_ADD_ON_LOADED` fires once **per addon** as each one finishes loading — always check `addonName` matches your own, since your handler receives this event for every other addon too.

## 5. Risks of SavedVariables (and How to Manage Them)

| Risk | Mitigation |
|---|---|
| **Corruption from a crash mid-save.** ESO writes the full file on logout/reload; a crash during that write can leave a truncated/invalid Lua file, which then fails to load entirely (losing all your data, not just the addon's). | Keep SavedVariables **small**. Don't store huge logs or caches you can regenerate. Cap array sizes (see ability-logger example in [06](06-ability-id-logging.md)) rather than growing unboundedly. |
| **Schema drift** — you ship a new version that expects a different table shape than what's on disk from an older version. Reading a missing/renamed key can `nil`-error. | Always go through `ZO_SavedVars` defaults (never assume a key exists) and bump the `version` parameter + add migration code when you restructure. |
| **Cross-character / cross-account bleed** — e.g. accidentally treating per-character data as account-wide. | Explicitly choose `:New` vs `:NewAccountWide` per-table based on intent, and keep them as separate SavedVariables tables if you need both scopes. |
| **Addon conflicts from name collisions** — if two addons use the same global table name. | Always use a globally-unique, addon-specific name for your SavedVariables global (prefix with your addon name), never something generic like `Settings` or `DB`. |
| **Unbounded growth bloating the save file**, which slows every subsequent save/load and increases corruption risk. | Prune old entries, store only what's needed for the feature to function, and provide a "Clear Data"/"Reset" button in your options UI. |
| **Sensitive/account data exposure.** SavedVariables files are plain, unencrypted text, and are included if a player shares their folder for troubleshooting. | Never store anything beyond gameplay data — no credentials, no real-world personal info — and warn users before you ever write anything resembling a character/account identifier into a log you intend to let them export/share. |
| **Players hand-editing the file** while the game is closed can introduce malformed/unexpected values. | Validate/sanitize values you read back (type-check, range-check) instead of trusting them blindly, especially for anything driving loop bounds or indexing. |

## 6. Simple Manual Migration Example

```lua
local CURRENT_VERSION = 2

function MyAddon.Initialize()
    MyAddonSV = ZO_SavedVars:NewAccountWide("MyAddonSV", CURRENT_VERSION, nil, defaults)

    -- ZO_SavedVars doesn't auto-migrate renamed/restructured keys -- do it yourself:
    if MyAddonSV.oldFieldName ~= nil and MyAddonSV.newFieldName == nil then
        MyAddonSV.newFieldName = MyAddonSV.oldFieldName
        MyAddonSV.oldFieldName = nil
    end
end
```

Continue to [08 — Combat/Effect/Power Events](08-combat-effect-power-events.md), or see the runnable sample in [examples/06-savedvariables](../examples/06-savedvariables/).
