# ReplicatedStorage/Remotes

Script Sync mirrors Lua scripts, but RemoteEvents should be created manually in Roblox Studio.

Create a Folder named `Remotes` inside `ReplicatedStorage`, then add these `RemoteEvent` instances exactly as named:

- `DailySpinResult`
- `ProgressionUpdated`
- `ReactionPlayed`
- `RequestDailySpin`
- `RequestEquipCup`
- `RequestEquipReaction`
- `RequestFill`
- `RequestPoison`
- `RequestSip`
- `RoundResult`
- `StateChanged`

Do not add `.model.json` files; those were for the old Rojo workflow.
