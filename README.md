# Don't Drink That

**Don't Drink That** is a Roblox 1v1 soda-fountain poisoning duel game. Two players face off in a best-of-3 match, secretly poison/fill/sip drinks, and try to out-bluff each other while everyone else can watch the reactions.

## Game highlights

- **1v1 best-of-3 duels** on a central matchmaking pad
- **Soda-fountain arena** with 20 fountains around an open green checkered plaza
- **20 reaction concepts** registered in code, with starter animated reactions like Spin-Fling, Puddle, Balloon, and Ragdoll Flop
- **6 straw tiers**: Straight, Bendy, Crazy, Glitter, Glow, and Loop
- **Cup + straw customization** that carries from the lobby into duels
- **Progression-first rewards** with no paid random-reward loops

## Workflow: VS Code + Codex + Roblox Studio Script Sync

This repo is intentionally **Rojo-free**. It is laid out to mirror Roblox services directly so it works with a one-way Script Sync workflow:

1. Clone this repo locally.
2. Open the cloned folder in VS Code.
3. Use Codex in VS Code to help edit the Lua scripts and docs.
4. Open your Roblox Studio place.
5. Use the Roblox Studio **Script Sync** plugin to pull the repo folders into the open place.

The folder names map directly to Roblox services:

- `ReplicatedStorage/` → `ReplicatedStorage`
- `ServerScriptService/` → `ServerScriptService`
- `StarterPlayerScripts/` → `StarterPlayer > StarterPlayerScripts`

RemoteEvents are created manually in Studio. See `ReplicatedStorage/Remotes/README.md` and `SETUP.md`.

## Important setup files

- `SETUP.md` — step-by-step setup for Roblox Studio + Script Sync
- `MAP_SETUP.md` — arena and map setup notes
- `ReplicatedStorage/Remotes/README.md` — exact RemoteEvent names to create manually

## Notes

Keep the Lua code in this repo as the source of truth. Use Script Sync to mirror changes into Studio, then press Play in Studio to test.
