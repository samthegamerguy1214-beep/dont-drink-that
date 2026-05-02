--[[
Purpose: Client phase HUD, timer, instructions, and client-only poisoned spout highlight for Don't Drink That.
Where it goes in Studio: StarterPlayer/StarterPlayerScripts/DuelHUD.client.lua (LocalScript)
Dependencies: ReplicatedStorage/GameConfig.lua, ReplicatedStorage/Remotes/StateChanged
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local gui = Instance.new("ScreenGui")
gui.Name = "DontDrinkThatDuelHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.fromOffset(480, 90)
label.Position = UDim2.new(0.5, -240, 0, 20)
label.BackgroundTransparency = 0.25
label.BackgroundColor3 = Color3.fromRGB(25, 10, 40)
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextScaled = true
label.Font = Enum.Font.FredokaOne
label.Parent = gui

local currentHighlight

local instructions = {
	[GameConfig.Phases.CUSTOMIZE] = "Customize your cup + reaction.",
	[GameConfig.Phases.MATCH_START] = "Match found. Take your side.",
	[GameConfig.Phases.POISON_SELECT] = "Secretly poison one cup.",
	[GameConfig.Phases.FILL] = "Fill your own cup from one spout.",
	[GameConfig.Phases.SIP] = "Sip on three...",
	[GameConfig.Phases.REVEAL] = "Reaction time!",
	[GameConfig.Phases.ROUND_SCORE] = "Round score.",
	[GameConfig.Phases.MATCH_END] = "Match over.",
}

local function highlightOwnPoison(fountainName, spoutIndex)
	if currentHighlight then
		currentHighlight:Destroy()
		currentHighlight = nil
	end
	local fountains = workspace:FindFirstChild(GameConfig.FountainStationsFolderName)
	local fountain = fountains and fountains:FindFirstChild(fountainName)
	local adornee = fountain and fountain:FindFirstChild("Spout_" .. tostring(spoutIndex), true)
	if adornee then
		local highlight = Instance.new("Highlight")
		highlight.Name = "OwnPoisonHighlight"
		highlight.FillColor = Color3.fromRGB(255, 0, 0)
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Adornee = adornee
		highlight.Parent = adornee
		currentHighlight = highlight
	end
end

Remotes.StateChanged.OnClientEvent:Connect(function(payload)
	local phase = payload.phase or "WAITING"
	local score = payload.matchScore and (tostring(payload.matchScore[player.UserId] or 0) .. " pts") or ""
	label.Text = string.format("%s\n%s %ss  Round %s  %s", instructions[phase] or phase, phase, tostring(payload.secondsRemaining or 0), tostring(payload.roundNumber or "-"), score)
	if payload.ownPoison then
		highlightOwnPoison(payload.fountainName, payload.ownPoison)
	end
	if phase == GameConfig.Phases.REVEAL or phase == GameConfig.Phases.ROUND_SCORE or phase == GameConfig.Phases.MATCH_END then
		if currentHighlight then
			currentHighlight:Destroy()
			currentHighlight = nil
		end
	end
end)
