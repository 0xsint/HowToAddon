# 10 — How to Read the ESOUI API Reference

There isn't a single official Bethesda/ZeniMax API doc site — the community-maintained **ESOUI Wiki** and the **raw decompiled game UI source** together form the de-facto reference every addon author uses. This guide explains where to look and how to read each source.

**Previous:** [09 — Player Stats & Max Stats](09-player-stats.md) · **Back to:** [README](../README.md)

---

## 1. The Primary Reference: `wiki.esoui.com`

**URL:** https://wiki.esoui.com/

This is a MediaWiki site (like Wikipedia) where every global function, event, and constant has its own page, named exactly as it appears in Lua.

- **Functions:** `https://wiki.esoui.com/GetPlayerStat`, `https://wiki.esoui.com/GetUnitPower`, etc. Each page shows:
  - The **signature** — argument names/types and return value names/types.
  - A **description** of behavior/edge cases.
  - Often a short **example snippet**.
  - A list of **"Used by"** add-ons (handy for seeing real-world usage).
- **Events:** `https://wiki.esoui.com/EVENT_COMBAT_EVENT`, `https://wiki.esoui.com/EVENT_EFFECT_CHANGED`, etc. — shows the full parameter list passed to your handler, in order.
- **Categories:** The wiki groups pages (e.g. "Category:Events", "Category:Constants") — browsing a category page is a fast way to discover everything related to a topic (search the page for `Category:` links at the bottom of any API page).
- **Search box:** Type a partial function/event/constant name — the wiki's search is literal-prefix based, so `GetUnit` will surface every `GetUnit*` function.

**How to read a typical function page**, using `GetUnitPower` as the example pattern:

```
GetUnitPower(string unitTag, CombatMechanicFlags powerType)
Returns: integer powerValue, integer powerEffectiveMax, integer powerMax
```

- The left-hand types (`string`, `CombatMechanicFlags`) tell you what Lua type/constant family to pass in.
- The **order of return values matters** — Lua lets you capture only the ones you need from the left: `local current = GetUnitPower(...)` silently drops the rest.
- Constant-family types like `CombatMechanicFlags` link to a page listing every valid constant (`COMBAT_MECHANIC_FLAGS_HEALTH`, etc.) — always follow that link rather than guessing values.

> **Tooling note:** while researching this guide, automated fetch tools were blocked from `wiki.esoui.com` by its bot protection — open it directly in your own browser; it works fine for normal visitors.

## 2. The Ground Truth: the ESOUI Source Mirror

**URL:** https://github.com/esoui/esoui

ZeniMax ships the game's entire UI (minus a few obfuscated pieces) as readable Lua/XML, and this GitHub repo mirrors it after every patch. This is the actual code the wiki documents — when the wiki is ambiguous or out of date, this is your tie-breaker.

How to use it effectively:
- **Check the current API version.** The repo's README states the latest version, e.g. *"Last update: 12.1.5 (API 101051)"* — this is exactly the number you put in your manifest's `## APIVersion:` (see [03 — Manifest File](03-manifest-file.md)).
- **Use GitHub's code search** (the search box at the top of the repo, or `github.com/search?q=EVENT_COMBAT_EVENT+repo:esoui/esoui&type=code`) to find every file that fires or handles a given event/function — this shows you real parameter usage in context, straight from the base game's own UI code (health bars, unit frames, combat log, etc. all live here).
- **Browse by folder:** `esoui/` (client-side UI, this is almost everything you'll reference), `esoui/libraries/` (shared helper code the base game itself uses —`ZO_SavedVars`, `ZO_CallbackObject`, anchor/animation helpers, etc. are defined here), `esoui/art/` (texture paths you can reference in your own XML).
- Because it's real shipped code (not docs), it reflects **exact** current parameter counts/order — invaluable for events like `EVENT_COMBAT_EVENT` that have gained parameters over the years.

## 3. Add-on Catalog / Library Discovery

**URL:** https://www.esoui.com/downloads/

This is where you find and download addons and libraries (LibAddonMenu, LibConsoleDialogs, etc. — see [04](04-libaddonmenu.md) and [05](05-libconsoledialogs.md)). Each listing's **Change Log** tab is a good way to check a library's current version and API stability. If you want to be certain a library exists before depending on it (rather than relying on a forum mention), the download site's search is the reliable source of truth — this guide's note in [06 — Logging Ability IDs](06-ability-id-logging.md) about `LibAbilityLogger` not existing came from exactly this kind of check.

## 4. The Forums (for Behavior Questions the Wiki Doesn't Answer)

**URL:** https://www.esoui.com/forums/ (particularly the "Lua/XML/Addon Help" sub-forum)

When you hit undocumented behavior, searching the forums (or asking there) is standard practice — many subtleties (event firing order, edge cases around combat event filters, gamepad-mode quirks) were only ever written down in forum threads by addon authors who hit them first.

## 5. Suggested Reading Order When Researching a New API Element

1. Search `wiki.esoui.com` for the exact name (function/event/constant).
2. Read the signature + description + "Used by" list.
3. If anything is unclear or you suspect it's stale, jump to `github.com/esoui/esoui` and search the source for the same identifier to see live, current usage.
4. If you still need real-world integration patterns (not just the raw signature), open one of the "Used by" addons' source — most are open-source on `esoui.com/downloads` or GitHub.

---

This completes the guide set. Jump back to the [README](../README.md) for the full index, or explore the runnable code in [examples/](../examples/).
