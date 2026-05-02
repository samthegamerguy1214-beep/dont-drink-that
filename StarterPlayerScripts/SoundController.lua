--[[
Purpose: Local sound effects for cup fills, BLEH reactions, and victory chimes in Don't Drink That.
Where it goes in Studio: StarterPlayer/StarterPlayerScripts/SoundController.client.lua (LocalScript)
Dependencies: ReplicatedStorage/Remotes/RequestFill, RoundResult
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local function playSound(name, soundId, volume)
	local sound = Instance.new("Sound")
	sound.Name = name
	-- TODO: Replace rbxassetid://0 placeholders with uploaded fizz/BLEH/chime sounds.
	sound.SoundId = soundId or "rbxassetid://0"
	sound.Volume = volume or 0.7
	sound.Parent = player:WaitForChild("PlayerGui")
	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

Remotes.RequestFill.OnClientEvent:Connect(function()
	playSound("CupFill", "rbxassetid://0", 0.45)
end)

Remotes.RoundResult.OnClientEvent:Connect(function(payload)
	if payload.isMatchEnd then
		if payload.matchWinnerUserId == player.UserId then
			playSound("VictoryChime", "rbxassetid://0", 0.75)
		else
			playSound("Bleh", "rbxassetid://0", 0.75)
		end
	end
end)
