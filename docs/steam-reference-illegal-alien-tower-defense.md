# Steam Reference Notes — Illegal Alien Tower Defense

Source:
https://store.steampowered.com/app/4571190/Illegal_Alien_Tower_Defense/

App ID: `4571190`

## Store facts pulled from Steam API

- Title: `Illegal Alien Tower Defense`
- Developer/publisher: `Forbidden Knowledge`
- Genre: Strategy
- Platform: Windows only
- Release date shown: May 25, 2026
- Status shown by Steam API: coming soon
- Single-player
- Store description positions it as a tower defense game focused on strategy and tower placement.
- The page lists four tower types, with one tower type upgradeable.
- The page lists four enemy classes.
- The protected objective is a central structure with HP; if it takes too many hits, the game ends.

## Design observations from Steam media

Neutral mechanics worth studying:

- Isometric/angled 3D tower-defense board.
- A visible route/path line shows enemy travel clearly.
- White outlined build squares communicate legal tower placement spots.
- Bottom HUD is large and readable: currency, base HP, wave counter.
- Tower card UI shows tower name, icon, cost, and range circle.
- Red zones appear to communicate entry/exit or danger/objective locations.
- Strong contrast between beige map, cyan path, white build pads, and bold UI text.
- The map uses chunky low-poly environmental props to establish theme without needing high-detail art.

## Caution

The store page uses a politically charged/dehumanizing parody frame. For our projects, borrow only the clean game-design ideas: tower-defense readability, path clarity, build pads, wave/base HP loop, tower cards, and low-poly readability. Do not copy the exact political premise, phrasing, identity targets, tower names, or artwork.

## Useful takeaways for Brother Doge / future Godot work

Brother Doge is currently a survivor shooter, not a tower defense game. Still, this reference suggests a possible separate prototype or future mode:

- `Doge Defense` mode: protect a Doge House / Daycare-style base from Paper Hands.
- Build pads around a fixed path.
- Currency earned by defeating enemies.
- Three or four tower cards.
- Base HP displayed prominently.
- Wave counter and clear wave progression.
- Strong visual lane/path readability.

Recommended next action if we pursue this idea:

Create a separate Godot prototype rather than mixing tower defense into Brother Doge immediately. Keep Brother Doge focused on the Brotato/survivor loop.
