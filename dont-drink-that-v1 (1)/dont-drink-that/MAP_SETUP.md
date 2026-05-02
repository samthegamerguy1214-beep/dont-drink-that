# Don't Drink That Map Setup

The scaffold can generate a placeholder plaza and 20 fountain machines automatically. Use this guide for the polished Studio art pass while keeping object names compatible with the scripts.

## Overall arena

- Style: large open outdoor plaza, bright and cartoony.
- No walls, no ceiling, no rooms.
- Floor: `200 x 200 x 1` studs.
- Floor look: bright green checkered grid.
- Sky: simple bright daytime.
- Players can walk anywhere between duels and naturally watch any active fountain.

## Central matchmaking pad

- Name: `LobbyQueuePad`
- Size: `8 x 1 x 8` studs.
- Position: center of map.
- Material: Neon.
- Color: yellow/gold.
- Add a star decal to the top face.
- Players step on this to queue.

## FountainStations folder

In Workspace, create a Folder named:

```text
FountainStations
```

Inside it, create 20 fountain station Models:

```text
FountainStation_1
FountainStation_2
...
FountainStation_20
```

Layout:

- 4 rows x 5 columns.
- About 20 studs apart each direction.
- Keep aisles open so spectators can walk between fountains.

## Each FountainStation model

Each `FountainStation_N` should contain:

```text
FountainStation_N
  FountainBody (Part)
  ChromeTop (Part)
  Spout_1 (Part)
  Spout_2
  ...
  Spout_10
  PlayerA_Pad (Part)
  PlayerB_Pad (Part)
  SafeBillboardAnchor (Part, transparent, non-collide)
```

### FountainBody

- One soda-fountain machine body.
- Suggested size: `14 x 9 x 5` studs.
- Brown body with chrome top.
- `FountainBody` should be the Model PrimaryPart if possible.

### Spouts

Place `Spout_1` through `Spout_10` lined up across the front face, like a real Coke fountain.

- Suggested size: `0.7 x 0.55 x 1.2` studs.
- Put a BillboardGui/SurfaceGui flavor label on each spout:
  1. Witches Brew
  2. StarBlox
  3. Slushie
  4. Milkshake
  5. Coconut
  6. Bloxiade
  7. Honey
  8. Milk
  9. Lemonade
  10. Pickle Juice

Gameplay note: the spouts are the choices. Players carry their own cup and straw; no cups sit on the fountain.

### Player pads

- `PlayerA_Pad`: one side of fountain.
- `PlayerB_Pad`: opposite side.
- Size: `5 x 0.5 x 5` studs.
- Material: Neon.
- These are where matched players teleport.

### SAFE Billboard anchor

- Name: `SafeBillboardAnchor`.
- Transparent Part above the fountain.
- Anchored: true.
- CanCollide: false.
- The server attaches a BillboardGui here showing `SAFE`, round score, and winner.

## Perimeter stands / shops

Place these around the plaza edge as simple booths, pads, or NPCs. MVP can just be labeled Parts.

### Flavor Unlock Stand

- Name: `FlavorUnlockStand`
- Cosmetic only.
- Unlocks new soda flavor label/appearance sets.
- Start with all 10 base flavors unlocked for MVP.

### Reaction Shop

- Name: `ReactionShop`
- Shows all 20 reactions and win thresholds.
- Reactions unlock through wins.
- Optional Robux bundles must unlock specific named reactions only — no random reaction drops.

### Cup Customizer Booth

- Name: `CupCustomizerBooth`
- Physical version of CustomizerUI.
- Lets players preview/select cup shape, color, pattern, and straw.

### Win Streak Board

- Name: `WinStreakBoard`
- BillboardGui for global top-10 by lifetime wins.
- TODO: connect to OrderedDataStore for production leaderboard.

### Daily Spin Wheel

- Name: `DailySpinWheel`
- One free spin per player per 24 hours.
- Cosmetic-only prizes: cup colors or patterns.
- No reaction drops.
- No paid spins.
- `DailySpinClient.lua` adds a ClickDetector to this object if present.

## Testing shortcut

If you skip map setup initially, `FountainBuilder.lua` creates a placeholder green floor, star pad, and 20 simple fountain machines automatically. Use that for script testing, then replace with your polished art pass using the same names.
