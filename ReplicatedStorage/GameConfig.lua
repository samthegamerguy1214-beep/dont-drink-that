--[[
Purpose: Shared tunable constants for Don't Drink That.
Where it goes in Studio: ReplicatedStorage/GameConfig.lua (ModuleScript)
Dependencies: CupConfig.lua, ReactionRegistry.lua
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CupConfig = require(ReplicatedStorage:WaitForChild("CupConfig"))
local ReactionRegistry = require(ReplicatedStorage:WaitForChild("ReactionRegistry"))

local GameConfig = {}

GameConfig.GAME_NAME = "Don't Drink That"

GameConfig.Phases = {
	LOBBY = "LOBBY",
	MATCH_START = "MATCH_START",
	CUSTOMIZE = "CUSTOMIZE",
	POISON_SELECT = "POISON_SELECT",
	FILL = "FILL",
	SIP = "SIP",
	REVEAL = "REVEAL",
	ROUND_SCORE = "ROUND_SCORE",
	MATCH_END = "MATCH_END",
}

GameConfig.PhaseDurations = {
	MATCH_START = 4,
	CUSTOMIZE = 30,
	POISON_SELECT = 12,
	FILL = 15,
	SIP = 3,
	REVEAL = 6,
	ROUND_SCORE = 3,
	MATCH_END = 5,
}

GameConfig.SpoutCount = 10
GameConfig.CupCount = 10 -- backwards-compatible alias for shared registry helpers
GameConfig.SpoutClickDistanceStuds = 14
GameConfig.LobbyPadName = "LobbyQueuePad"
GameConfig.FountainStationsFolderName = "FountainStations"
GameConfig.DefaultFountainStationCount = 20
GameConfig.MatchWinsRequired = 2
GameConfig.DailySpinCooldownSeconds = 24 * 60 * 60
GameConfig.CupWeldOffset = CFrame.new(-0.18, -0.55, -0.28) * CFrame.Angles(math.rad(-18), math.rad(90), math.rad(10))
GameConfig.StrawWeldOffset = CFrame.new(0.12, 0.38, -0.08) * CFrame.Angles(math.rad(-18), 0, math.rad(8))

GameConfig.DefaultFlavors = {
	"Witches Brew",
	"StarBlox",
	"Slushie",
	"Milkshake",
	"Coconut",
	"Bloxiade",
	"Honey",
	"Milk",
	"Lemonade",
	"Pickle Juice",
}

GameConfig.FlavorColors = {
	Color3.fromRGB(90, 20, 140),
	Color3.fromRGB(35, 135, 255),
	Color3.fromRGB(0, 220, 255),
	Color3.fromRGB(255, 210, 230),
	Color3.fromRGB(250, 250, 235),
	Color3.fromRGB(255, 95, 80),
	Color3.fromRGB(255, 205, 65),
	Color3.fromRGB(245, 245, 245),
	Color3.fromRGB(255, 240, 65),
	Color3.fromRGB(110, 220, 70),
}

GameConfig.Cups = CupConfig
GameConfig.Reactions = ReactionRegistry

GameConfig.DefaultReactionId = "spin_fling"

return GameConfig
