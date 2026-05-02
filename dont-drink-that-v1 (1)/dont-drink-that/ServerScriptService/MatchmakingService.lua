--[[
Purpose: Simple 1v1 queue that assigns matched players to open public Fountain station models in Don't Drink That.
Where it goes in Studio: ServerScriptService/MatchmakingService.lua (Script)
Dependencies: ReplicatedStorage/GameConfig.lua, ServerScriptService/DuelController.lua, FountainBuilder.lua
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local DuelController = require(ServerScriptService:WaitForChild("DuelController"))
local FountainBuilder = require(ServerScriptService:WaitForChild("FountainBuilder"))

local controller = DuelController.new()
local queue = {}
local queuedByUserId = {}
local fountainsFolder = FountainBuilder.EnsureFountains()

local function findOpenFountain()
	for _, fountain in ipairs(fountainsFolder:GetChildren()) do
		if fountain:IsA("Model") and fountain:GetAttribute("Occupied") ~= true then
			return fountain
		end
	end
	return nil
end

local function removeFromQueue(player)
	queuedByUserId[player.UserId] = nil
	for index = #queue, 1, -1 do
		if queue[index] == player then table.remove(queue, index) end
	end
end

local function tryStartMatch()
	while #queue >= 2 do
		local fountain = findOpenFountain()
		if not fountain then return end
		local playerA = table.remove(queue, 1)
		local playerB = table.remove(queue, 1)
		queuedByUserId[playerA.UserId] = nil
		queuedByUserId[playerB.UserId] = nil
		if playerA.Parent == Players and playerB.Parent == Players then
			controller:StartDuel(playerA, playerB, fountain)
		end
	end
end

local function enqueue(player)
	if controller:GetDuelForPlayer(player) or queuedByUserId[player.UserId] then return end
	queuedByUserId[player.UserId] = true
	table.insert(queue, player)
	tryStartMatch()
end

local function setupLobbyPad()
	local pad = Workspace:FindFirstChild(GameConfig.LobbyPadName) or FountainBuilder.EnsureLobbyPad()
	pad.Touched:Connect(function(hit)
		local player = hit.Parent and Players:GetPlayerFromCharacter(hit.Parent)
		if player then enqueue(player) end
	end)
end

Players.PlayerRemoving:Connect(removeFromQueue)
setupLobbyPad()

task.spawn(function()
	while true do
		tryStartMatch()
		task.wait(2)
	end
end)

-- Studio testing convenience: uncomment to auto-queue players a few seconds after spawn.
-- Players.PlayerAdded:Connect(function(player)
-- 	task.wait(3)
-- 	enqueue(player)
-- end)
