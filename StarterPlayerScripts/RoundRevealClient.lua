--[[
Purpose: Plays visible Don't Drink That reaction animations when RoundResult reveals poisoned players.
Where it goes in Studio: StarterPlayer/StarterPlayerScripts/RoundRevealClient.client.lua (LocalScript)
Dependencies: ReactionPlayer.lua ModuleScript in StarterPlayerScripts, ReplicatedStorage/Remotes/RoundResult
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReactionPlayer = require(script.Parent:WaitForChild("ReactionPlayer"))
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local function getPlayerByUserId(userId)
	for _, player in ipairs(Players:GetPlayers()) do
		if player.UserId == userId then
			return player
		end
	end
	return nil
end

Remotes.RoundResult.OnClientEvent:Connect(function(payload)
	if payload.isMatchEnd or not payload.results then return end
	for userId, result in pairs(payload.results) do
		if result.poisoned then
			local target = getPlayerByUserId(userId)
			local reactionId = payload.reactionByUserId and payload.reactionByUserId[userId] or "spin_fling"
			ReactionPlayer.PlayReaction(target, reactionId)
		end
	end
end)
