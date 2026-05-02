# RemoteEvents folder marker

Create a `Folder` named `Remotes` in `ReplicatedStorage`, then add these `RemoteEvent` children:

- `RequestPoison`
- `RequestFill`
- `ReactionPlayed`
- `StateChanged`
- `RoundResult`
- `RequestDailySpin`
- `DailySpinResult`
- `RequestEquipCup`
- `RequestEquipReaction`
- `ProgressionUpdated`

The server scripts include setup helpers that create missing RemoteEvents automatically, but creating them manually first makes debugging easier in Studio.
