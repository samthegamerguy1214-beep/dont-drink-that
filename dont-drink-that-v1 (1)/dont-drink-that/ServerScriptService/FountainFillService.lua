--[[
Purpose: Server validation for secret spout poisoning and cup filling at shared Fountain stations.
Where it goes in Studio: ServerScriptService/FountainFillService.lua (ModuleScript)
Dependencies: ReplicatedStorage/GameConfig.lua
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local FountainFillService = {}
FountainFillService.__index = FountainFillService

function FountainFillService.new()
	local self = setmetatable({}, FountainFillService)
	self.fillsByRound = {}
	return self
end

function FountainFillService:StartRound(roundId, players)
	self.fillsByRound[roundId] = {}
	for _, player in ipairs(players) do
		self.fillsByRound[roundId][player.UserId] = nil
	end
end

function FountainFillService:EndRound(roundId)
	self.fillsByRound[roundId] = nil
end

local function getSpout(fountain, spoutIndex)
	return fountain and fountain:FindFirstChild("Spout_" .. tostring(spoutIndex), true) or nil
end

local function getPosition(instance)
	if not instance then return nil end
	if instance:IsA("BasePart") then return instance.Position end
	if instance:IsA("Model") then return instance:GetPivot().Position end
	return nil
end

local function isPlayerNearSpout(player, spout)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local spoutPosition = getPosition(spout)
	if not root or not spoutPosition then return false end
	return (root.Position - spoutPosition).Magnitude <= GameConfig.SpoutClickDistanceStuds
end

function FountainFillService:ValidateSpoutTap(fountain, player, spoutIndex)
	if typeof(spoutIndex) ~= "number" or spoutIndex < 1 or spoutIndex > GameConfig.SpoutCount then
		return false, "Invalid spout."
	end
	local spout = getSpout(fountain, spoutIndex)
	if not isPlayerNearSpout(player, spout) then
		return false, "Move closer to that spout."
	end
	return true, spout
end

function FountainFillService:RegisterPoison(fountain, player, phase, poisonLogic, spoutIndex)
	if phase ~= GameConfig.Phases.POISON_SELECT then
		return false, "You can only poison during POISON_SELECT."
	end
	local ok, err = self:ValidateSpoutTap(fountain, player, spoutIndex)
	if not ok then return false, err end
	return poisonLogic:SetPoison(player, spoutIndex)
end

function FountainFillService:RegisterFill(roundId, fountain, player, phase, spoutIndex)
	if phase ~= GameConfig.Phases.FILL then
		return false, "You can only fill during FILL."
	end
	local ok, err = self:ValidateSpoutTap(fountain, player, spoutIndex)
	if not ok then return false, err end
	local roundFills = self.fillsByRound[roundId]
	if not roundFills or roundFills[player.UserId] then
		return false, "Fill already locked or round closed."
	end
	roundFills[player.UserId] = {
		spoutIndex = spoutIndex,
		flavor = GameConfig.DefaultFlavors[spoutIndex],
		color = GameConfig.FlavorColors[spoutIndex],
		time = os.time(),
	}
	return true, roundFills[player.UserId]
end

function FountainFillService:GetFill(roundId, player)
	local roundFills = self.fillsByRound[roundId]
	return roundFills and roundFills[player.UserId] or nil
end

function FountainFillService:EveryoneFilled(roundId, players)
	local roundFills = self.fillsByRound[roundId]
	if not roundFills then return false end
	for _, player in ipairs(players) do
		if not roundFills[player.UserId] then return false end
	end
	return true
end

return FountainFillService
