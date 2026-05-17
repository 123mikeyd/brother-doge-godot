# Brother Doge HTML → Godot Migration Plan

## Principle

Do not port the full HTML game in one jump. Build it in layers, verify each layer, then add the next system.

## Layer 1 — Movement, camera, arena, player

Status: complete in v0.1.

- One playable Doge.
- WASD/arrow movement.
- Arena bounds.
- Procedural Doge rendering.

## Layer 2 — Enemy, weapon, projectile, collision

Status: complete in v0.1.

- Wicked Paper Hand enemy.
- Diamond Hand variant.
- Auto-targeting bark projectile.
- Projectile/enemy collisions.
- Contact damage.

## Layer 3 — Wave timer, pickups, one upgrade choice

Status: complete in v0.1.

- 60-second wave.
- XP drops.
- Level-up state.
- Upgrade choices: Rapid Bark, Strong Bark, Zoomies.

## Layer 4 — Data-driven Doge breeds

Status: complete in v0.1.

Implemented as a `breed_data` table in `scripts/BrotherDoge.gd`:

- Classic Doge: balanced HP/speed/bark.
- Brother Doge: tankier, slower, stronger bark.
- Zoomie Doge: fast, fragile, lower damage, faster fire rate.

Next refactor: move this table into Godot `.tres` Resources once the first slice is stable.

Suggested future resource layout:

```text
resources/breeds/classic_doge.tres
resources/breeds/brother_doge.tres
resources/weapons/bark.tres
resources/perks/rapid_bark.tres
```

## Layer 5 — Shop between waves

Status: complete in v0.1.

Implemented:

- wave clear opens shop instead of ending the run
- three upgrade cards
- keyboard choice 1/2/3
- Space chooses first option
- selected upgrade applies immediately
- next wave begins with existing build

Next refactor: add rerolls, prices, and more varied perk pools.

## Layer 6 — Boss and telegraphs

Status: complete in v0.1.

Implemented:

- Paper Boss enemy type.
- Boss HP bar.
- Boss spawns automatically from later waves.
- Boss telegraph danger circles appear before damage.
- Telegraph API is covered by the smoke harness.

Next refactor: port a more specific boss pattern from the HTML game and add multiple telegraph shapes.

## Layer 7 — Persistence

Status: complete in v0.1.

Implemented Godot save-file progress at `user://brother_doge_save.json`:

- best wave
- best kill count
- best coins
- run count
- last selected breed

The title screen and HUD show best-run stats. The smoke harness checks save/load/reset APIs.

## Layer 8 — Content expansion / perk pool

Status: complete in v0.1.

Implemented:

- expanded perk pool with categories:
  - weapon: Rapid Bark, Strong Bark
  - movement: Zoomies
  - defense: Thick Fur, Paper Resistance
  - economy: Treat Magnet
- shop rolls three cards from the full pool
- shop reroll via `E` for 2 coins
- discovered-upgrades tracking in save data
- smoke coverage for reroll and new perk stat effects

Next refactor: split upgrades into Godot Resources and add more interesting conditional perks.

## Layer 9 — Enemy variety / wave director

Status: complete in v0.1.

Implemented:

- Runner Hand: fast, fragile, slight weaving movement.
- Tank Hand: slow, durable, larger collision body.
- Splitter Hand: splits into two Runner Hands when defeated.
- Wave director chooses enemy mix by wave:
  - Wave 1: basic Paper Hands.
  - Wave 2+: Runner Hands enter the pool.
  - Wave 4+: Tank Hands enter the pool.
  - Wave 5+: Splitter Hands enter the pool.
- Debug counters for runner/tank/splitter enemies.
- Smoke coverage for variant spawning and Splitter Hand split behavior.

Next layer: progression polish — better wave-complete rewards, named wave banners, and clearer player feedback when the spawn pool changes.

## Notes

Keep the original HTML game intact as reference. The Godot version should become its own clean implementation rather than an embedded browser-code translation.
