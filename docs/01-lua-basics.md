# 01 — Lua Basics for ESOUI Addons

ESO addons are written in **Lua 5.1** (the version embedded in the game client) plus an XML dialect for layout. This guide covers just enough Lua to read and write addon code. If you already know Lua, skim the "ESO-specific gotchas" section at the end.

**Up next:** [02 — XML Reference](02-xml-reference.md) · **Back to:** [README](../README.md)

---

## 1. Comments

```lua
-- this is a single line comment

--[[
    this is a
    multi-line comment
]]
```

## 2. Variables and Scope

Lua variables are **global by default** unless declared `local`. In addons you should almost always use `local` — leaking globals can collide with other addons or the game client.

```lua
MyGlobal = "visible everywhere"     -- bad: pollutes global namespace
local myLocal = "visible in this file/scope only" -- good
```

Basic types: `nil`, `boolean`, `number`, `string`, `table`, `function`.

```lua
local isEnabled = true          -- boolean
local count = 10                -- number
local name = "Dragonknight"     -- string
local data = {}                 -- table (the only data structure in Lua)
local doSomething = function() end -- function value
```

## 3. Tables

Tables are Lua's single data structure — they work as arrays, dictionaries (maps), and objects (via metatables).

```lua
-- Array-style (1-indexed!)
local abilities = { 12345, 22222, 33333 }
print(abilities[1])        --> 12345
print(#abilities)          --> 3 (length operator)

-- Dictionary-style
local player = {
    name = "Ragnar",
    level = 50,
    class = "Nightblade",
}
print(player.name)         --> Ragnar
print(player["name"])      --> Ragnar (same thing)

-- Nested tables are the backbone of SavedVariables and LibAddonMenu option tables
local settings = {
    window = { top = 100, left = 200 },
    features = { autoLoot = true, showTimers = false },
}
```

Iterating tables:

```lua
-- ipairs: ordered, numeric-index iteration (stops at first nil)
for index, value in ipairs(abilities) do
    d(index .. " = " .. value)
end

-- pairs: unordered iteration over all keys (numeric + string)
for key, value in pairs(player) do
    d(tostring(key) .. " = " .. tostring(value))
end
```

## 4. Functions

```lua
local function AddNumbers(a, b)
    return a + b
end

-- Anonymous function assigned to a variable (very common for event handlers)
local onUpdate = function(eventCode)
    -- ...
end

-- Functions are values -- you can store them in tables
local MyAddon = {}
function MyAddon.OnPlayerActivated(eventCode)
    d("Player activated!")
end
```

Lua functions can return multiple values, and many ESO API functions do:

```lua
local current, effectiveMax, max = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_HEALTH)
```

## 5. Control Flow

```lua
-- if / elseif / else
if level >= 50 then
    d("Max level")
elseif level >= 10 then
    d("Mid level")
else
    d("Low level")
end

-- while loop
local i = 1
while i <= 5 do
    i = i + 1
end

-- numeric for loop
for i = 1, 10 do
    -- runs 10 times
end

-- generic for loop (see pairs/ipairs above)
```

Logical/comparison operators: `==`, `~=` (not equal), `<`, `<=`, `>`, `>=`, `and`, `or`, `not`. String concatenation uses `..` (two dots), not `+`.

```lua
local msg = "Hello " .. playerName .. "!"
local isReady = (count > 0) and (not isPaused)
```

## 6. Namespacing Your Addon

Lua has no built-in module system, so the convention is to create **one global table** per addon to hold everything, keeping the rest `local`:

```lua
MyAddon = MyAddon or {}
MyAddon.name = "MyAddon"
MyAddon.version = "1.0.0"

function MyAddon.Initialize()
    -- setup code
end
```

This single global (`MyAddon`) is safe because it's named uniquely — avoid generic names like `Addon` or `Settings` that other authors might also pick.

## 7. ESO-Specific Gotchas

- **Event callbacks are just functions.** The first parameter passed to every registered event handler is always `eventCode` (a number identifying which event fired), even if you don't use it.
- **`zo_callLater` / `EVENT_MANAGER` / `CALLBACK_MANAGER`** are ESO globals, not standard Lua — they come from the game's own API, documented on the [ESOUI API reference](10-esoui-api-reference-guide.md).
- **Strict mode:** ESO enables a global-variable strict mode in development; accidentally writing to an undeclared global can throw `attempt to create global variable`. Always use `local` unless you intend a real global.
- **No `require`/`import`.** Every `.lua` file listed in your [manifest](03-manifest-file.md) is loaded into one shared Lua environment in the order listed. Order matters.
- **String formatting**: use `zo_strformat` for anything shown to the player (it's locale-aware and handles ESO's special `<<1>>` placeholder syntax), and plain `string.format` / `..` for debug/log text.
- **`d(...)`** prints to chat — the single most useful debugging tool you have.

Continue to [02 — XML Reference](02-xml-reference.md), or jump straight to a working example in [examples/01-first-addon](../examples/01-first-addon/).
