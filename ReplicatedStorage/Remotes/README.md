# RemoteEvents folder marker

Rojo creates the `RemoteEvent` children in this folder from the adjacent `.model.json` files. If importing manually, create these RemoteEvents:

- `RequestPoison`
- `RequestFill`
- `RequestSip`
- `ReactionPlayed`
- `StateChanged`
- `RoundResult`
- `RequestDailySpin`
- `DailySpinResult`
- `RequestEquipCup`
- `RequestEquipReaction`
- `ProgressionUpdated`

The server scripts include setup helpers that create missing RemoteEvents automatically, but creating them manually first makes debugging easier in Studio.
