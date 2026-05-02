--[[
Purpose: Applies each player's saved equipped cup + straw on spawn for lobby Social Flex.
Where it goes in Studio: ServerScriptService/CupAvatarBootstrap.lua (Script)
Dependencies: CupAvatarService.lua, ProgressionService.lua
]]

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local CupAvatarService = require(ServerScriptService:WaitForChild("CupAvatarService"))
local ProgressionService = require(ServerScriptService:WaitForChild("ProgressionService"))
local progression = ProgressionService.new()

local function apply(player)
	local data = progression:Get(player)
	CupAvatarService.ApplyCupToCharacter(player, data.equippedCup)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.5)
		apply(player)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	progression:Remove(player)
end)
