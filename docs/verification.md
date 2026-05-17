# Verification

The verification entrypoint is:

```bash
./run_smoke.sh
```

It runs:

```bash
~/bin/godot45 --headless --path . --script res://tools/smoke_brother_doge.gd
```

The smoke harness is intentionally API-driven so core gameplay systems can be checked without GUI input.

It verifies:

- `scenes/BrotherDoge.tscn` loads and instantiates
- run start state
- selectable breeds and stat changes
- enemy spawning
- XP spawning
- level-up upgrade flow
- shop open/choose/reroll flow
- perk stat effects
- boss and telegraph spawning
- enemy variant counters
- Splitter Hand creates Runner Hands
- save/load/reset progress APIs

Expected ending:

```text
BROTHER_DOGE_GODOT_SMOKE_PASS
```

If launched from WSL and the game window cannot be closed normally, press `Q` in the game. `Q` is a hard quit shortcut.
