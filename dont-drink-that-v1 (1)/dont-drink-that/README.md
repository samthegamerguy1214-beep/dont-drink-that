# Don't Drink That — Roblox Studio Scaffold v1

Don't Drink That is a 1v1 social-deduction soda-fountain duel for Roblox. This scaffold is designed for a solo developer to get a playable MVP running quickly: open green checkered plaza, 20 public fountain stations, best-of-3 matches, secret spout poisoning, cup filling, visible reaction animations, persistent cup/straw flex, progression, rare straw behaviors, and a cosmetic-only daily spin skeleton.

## Import checklist

1. Create a new Roblox place in Studio.
2. In `ReplicatedStorage`, create ModuleScripts named `CupConfig`, `ReactionRegistry`, and `GameConfig`, then paste the matching files from this zip.
3. In `ReplicatedStorage`, create a Folder named `Remotes`. Add RemoteEvents named `RequestPoison`, `RequestFill`, `ReactionPlayed`, `StateChanged`, `RoundResult`, `RequestDailySpin`, `DailySpinResult`, `RequestEquipCup`, `RequestEquipReaction`, and `ProgressionUpdated`. The server auto-creates missing events, but creating them manually helps debugging.
4. In `ServerScriptService`, add ModuleScripts: `PoisonLogic`, `FountainFillService`, `ProgressionService`, `CupAvatarService`, `FountainBuilder`, `DuelController`.
5. In `ServerScriptService`, add Scripts: `MatchmakingService`, `DailySpinService`, `CupAvatarBootstrap`, `CustomizationService`.
6. In `StarterPlayer > StarterPlayerScripts`, add LocalScripts: `LobbyUI`, `CustomizerUI`, `DuelHUD`, `FountainSpoutController`, `SoundController`, `RoundRevealClient`, `DailySpinClient`.
7. In `StarterPlayer > StarterPlayerScripts`, add ModuleScripts: `ReactionPlayer`, `StrawBehaviors`.
8. Follow `MAP_SETUP.md` to replace the script-generated placeholder plaza/fountains with a polished hand-built version.
9. In Studio, enable DataStore testing: **Game Settings > Security > Enable Studio Access to API Services**.
10. Test with **Start Server** and 2+ players.

## Current gameplay loop

1. Players walk around the open plaza with their equipped cup + straw welded to their left hand.
2. Players step on the central star matchmaking pad.
3. Two queued players are assigned to the next open `FountainStation`.
4. Match starts and both players stand on opposite pads of the same soda fountain.
5. Each best-of-3 round runs:
   - `POISON_SELECT` — each player secretly clicks one of the 10 spouts to poison it.
   - `FILL` — each player clicks one spout to fill their own equipped cup.
   - `SIP` — both sip on a shared countdown.
   - `REVEAL` — poisoned drinkers play their equipped reaction with cup + straw still attached.
   - `ROUND_SCORE` — public SAFE BillboardGui above the fountain shows the score.
6. First player to 2 round wins gets the match win. Progression updates only at match end.
7. Both players teleport back to the central lobby pad, still wearing their cup/straw.

## Rare straw behavior layer

`CupConfig.lua` defines 6 straws with rarity, win unlocks, and reaction-time behavior IDs:

- Straight — Common — `none` — starter
- Bendy — Common — `wiggle` — starter
- Crazy — Uncommon — `twirl` — 3 wins
- Glitter — Rare — `glitter_trail` — 10 wins
- Glow — Epic — `light_streak` — 25 wins
- Loop — Legendary — `spin_wild` — 50 wins

`StrawBehaviors.lua` is called by `ReactionPlayer.lua` during any loss reaction. These effects are cosmetic flex only.

## Important design decisions

- Open-view map: no instanced rooms, no walls, no spectator mode. Anyone can naturally watch any fountain duel.
- There are 20 public `FountainStation` models in a 4x5 grid.
- The 10 labeled spouts are the choices; players carry their own cup the entire time.
- Poison, fill, and win resolution are server-authoritative.
- Reactions and rare straws unlock by wins. There are no random reaction drops.
- Optional Robux skip stubs are exact named items only; no randomness.
- Daily spin is free once per day, cosmetic-only, and has no paid spins.

## MVP limitations / TODOs

- `ReactionPlayer` fully scripts the first 4 reactions. The other 16 are registered in data and print TODO/fallback until animated.
- Sound IDs, disgust-face decal, star decal, logo placeholder, and polished meshes are placeholder `rbxassetid://0` values.
- Daily spin records cooldown and returns a cosmetic prize; merge prizes into `ProgressionService` if you want permanent ownership in one profile store.
- Customizer UI displays unlocks and server save hooks, but it is not a polished selector yet.
- The fallback plaza/fountain creation in `FountainBuilder` is for instant testing. For production, hand-build the plaza from `MAP_SETUP.md` and keep the same object names.

## File map

```text
ReplicatedStorage/
  CupConfig.lua
  ReactionRegistry.lua
  GameConfig.lua
  Remotes/README.md
ServerScriptService/
  MatchmakingService.lua
  DuelController.lua
  PoisonLogic.lua
  FountainFillService.lua
  ProgressionService.lua
  CupAvatarService.lua
  CupAvatarBootstrap.lua
  CustomizationService.lua
  FountainBuilder.lua
  DailySpinService.lua
StarterPlayer/StarterPlayerScripts/
  LobbyUI.lua
  CustomizerUI.lua
  DuelHUD.lua
  FountainSpoutController.lua
  ReactionPlayer.lua
  StrawBehaviors.lua
  SoundController.lua
  RoundRevealClient.lua
  DailySpinClient.lua
```

## Publishing notes

Keep monetization ethical and non-gambling:

- OK: named cup part packs, named reaction skip bundles, named straw skip bundles.
- OK: one free daily spin for cup colors/patterns only.
- Not OK: paid spins, mystery reactions, random paid rewards, random power advantages.
