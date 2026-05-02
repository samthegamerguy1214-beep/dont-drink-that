--[[
Purpose: Saves Don't Drink That cup/straw and reaction equips per-player and reapplies hand cup visuals.
Where it goes in Studio: ServerScriptService/CustomizationService.server.lua (Script)
Dependencies: ProgressionService.lua, CupAvatarService.lua, ReplicatedStorage/Remotes
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ProgressionService = require(ServerScriptService:WaitForChild("ProgressionService"))
local CupAvatarService = require(ServerScriptService:WaitForChild("CupAvatarService"))
local progression = ProgressionService.new()

local remotes = ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage
for _, name in ipairs({ "RequestEquipCup", "RequestEquipReaction", "ProgressionUpdated" }) do
	if not remotes:FindFirstChild(name) then
		local event = Instance.new("RemoteEvent")
		event.Name = name
		event.Parent = remotes
	end
end

remotes.RequestEquipCup.OnServerEvent:Connect(function(player, cupSelection)
	local ok, message = progression:EquipCup(player, cupSelection)
	if ok then
		local data = progression:Get(player)
		CupAvatarService.ApplyCupToCharacter(player, data.equippedCup)
		remotes.ProgressionUpdated:FireClient(player, data)
	else
		remotes.ProgressionUpdated:FireClient(player, { error = message })
	end
end)

remotes.RequestEquipReaction.OnServerEvent:Connect(function(player, reactionId)
	local ok, message = progression:EquipReaction(player, reactionId)
	remotes.ProgressionUpdated:FireClient(player, ok and progression:Get(player) or { error = message })
end)
