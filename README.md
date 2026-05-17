# Brother Doge Godot

A Godot 4.5 recreation of `HODL OR DIE: Brother Doge`, built in layers using the smart path.

This is a clean Godot implementation inspired by Mike's original browser game, not a direct browser-code transplant. The goal is to preserve the survivor/shooter spirit while growing it into a maintainable Godot project.

Source reference:

https://github.com/123mikeyd/Brother_Doge_VideoGame

## Status

Current milestone: `v0.1` local/public vertical slice.

This is not a full feature-for-feature port yet. It is the first playable Godot foundation.

## Features

- three selectable Doge breeds: Classic Doge, Brother Doge, Zoomie Doge
- procedural arena and Doge/player drawing
- auto-firing bark projectiles
- XP pickups and level-up upgrades
- 60-second wave structure
- shop between waves with three upgrade cards
- shop reroll for coins
- persistent best-run stats saved in Godot user data
- boss telegraphs and visible danger zones
- enemy variants:
  - Paper Hand
  - Diamond Hand
  - Runner Hand
  - Tank Hand
  - Splitter Hand
  - Paper Boss
- wave director that changes enemy mix by wave
- headless smoke harness for core systems

## Controls

- WASD / Arrow keys: move
- Auto-bark: nearest enemy is targeted automatically
- 1 / 2 / 3 on title: select Classic / Brother / Zoomie Doge
- 1 / 2 / 3: choose upgrade on level-up or shop screen
- E: reroll shop for 2 coins
- Space: start / default upgrade / first shop option
- R: restart
- Q: quit immediately

## Requirements

- Godot 4.5

The local development binary used during creation was `~/bin/godot45` under WSL.

## Run

Open this folder in Godot 4.5 and run the project.

From WSL:

```bash
cd /mnt/c/Users/Mike/Desktop/BrotherDogeGodot
~/bin/godot45 --path .
```

## Verify

```bash
./run_smoke.sh
```

Expected ending:

```text
BROTHER_DOGE_GODOT_SMOKE_PASS
```

The smoke harness checks scene loading plus the gameplay/debug APIs for breeds, enemies, XP, upgrades, shop flow, rerolls, boss telegraphs, persistence, and enemy variant behavior.

## Project structure

```text
project.godot
scenes/BrotherDoge.tscn
scripts/BrotherDoge.gd
tools/smoke_brother_doge.gd
docs/migration-plan.md
```

## Layer plan

See `docs/migration-plan.md`.

Completed layers:

1. movement / arena / player
2. enemy / weapon / projectile / collision
3. wave timer / XP / level-up upgrade
4. selectable Doge breeds
5. shop between waves
6. boss and telegraphs
7. persistence
8. expanded perk pool + reroll
9. enemy variants + wave director

## Notes

This is a prototype/learning port. Names, doge memes, tokens, and other cultural references may need review before any commercial positioning.

## License

MIT. See `LICENSE`.
