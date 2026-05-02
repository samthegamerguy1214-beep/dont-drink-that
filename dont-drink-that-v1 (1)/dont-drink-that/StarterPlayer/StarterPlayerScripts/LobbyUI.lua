--[[
Purpose: Basic Don't Drink That lobby UI for queue status and match/opponent preview text.
Where it goes in Studio: StarterPlayer/StarterPlayerScripts/LobbyUI.lua (LocalScript)
Dependencies: ReplicatedStorage/Remotes/StateChanged, RoundResult
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local gui = Instance.new("ScreenGui")
gui.Name = "DontDrinkThatLobbyUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("TextLabel")
panel.Size = UDim2.fromOffset(360, 90)
panel.Position = UDim2.new(0, 20, 1, -120)
panel.BackgroundTransparency = 0.2
panel.BackgroundColor3 = Color3.fromRGB(20, 10, 35)
panel.TextColor3 = Color3.fromRGB(255, 255, 255)
panel.TextScaled = true
panel.Font = Enum.Font.FredokaOne
panel.Text = "Step on the star pad to queue.\nWatch open fountain duels while you wait."
panel.Parent = gui

Remotes.StateChanged.OnClientEvent:Connect(function(payload)
	if payload.phase then
		panel.Text = "Matched at " .. tostring(payload.fountainName or "fountain") .. "\nPhase: " .. payload.phase
	end
end)

Remotes.RoundResult.OnClientEvent:Connect(function(payload)
	if payload.isMatchEnd then
		local won = payload.matchWinnerUserId == player.UserId
		panel.Text = won and "Match won! New reaction progress saved." or "Match over. Queue again for revenge."
	end
end)
