--[[
Purpose: DataStore-backed wins, reactions, cup ownership, and rare straw unlocks for Don't Drink That.
Where it goes in Studio: ServerScriptService/ProgressionService.lua (ModuleScript)
Dependencies: ReplicatedStorage/ReactionRegistry.lua, ReplicatedStorage/CupConfig.lua
]]

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReactionRegistry = require(ReplicatedStorage:WaitForChild("ReactionRegistry"))
local CupConfig = require(ReplicatedStorage:WaitForChild("CupConfig"))

local STORE_NAME = "DontDrinkThatProgression_v1"
local store = DataStoreService:GetDataStore(STORE_NAME)

local ProgressionService = {}
ProgressionService.__index = ProgressionService

function ProgressionService.new()
	local self = setmetatable({}, ProgressionService)
	self.cache = {}
	return self
end

local function defaultData()
	return {
		wins = 0,
		winStreak = 0,
		equippedReaction = "spin_fling",
		equippedCup = CupConfig.GetDefaultCup(),
		ownedCupParts = {
			shapes = { "classic" },
			colors = { "cola_red", "blue_raspberry", "slime_green" },
			patterns = { "solid" },
			straws = { "straight", "bendy" },
		},
		purchasedNamedStraws = {}, -- exact named Robux straw unlocks only; no random bundles.
	}
end

local function refreshUnlocks(data)
	data.unlockedReactions = ReactionRegistry.GetUnlockedForWins(data.wins or 0)
	data.unlockedStraws = CupConfig.GetUnlockedStrawsForWins(data.wins or 0)
	for _, strawId in ipairs(data.purchasedNamedStraws or {}) do
		if not table.find(data.unlockedStraws, strawId) then
			table.insert(data.unlockedStraws, strawId)
		end
	end
	data.ownedCupParts = data.ownedCupParts or defaultData().ownedCupParts
	data.ownedCupParts.straws = data.unlockedStraws
end

function ProgressionService:Load(player)
	local key = "player_" .. player.UserId
	local ok, data = pcall(function()
		return store:GetAsync(key)
	end)
	if not ok or type(data) ~= "table" then
		data = defaultData()
	end
	refreshUnlocks(data)
	self.cache[player.UserId] = data
	return data
end

function ProgressionService:Get(player)
	return self.cache[player.UserId] or self:Load(player)
end

function ProgressionService:Save(player)
	local data = self.cache[player.UserId]
	if not data then
		return
	end
	local key = "player_" .. player.UserId
	pcall(function()
		store:SetAsync(key, data)
	end)
end

function ProgressionService:AwardWin(player)
	local data = self:Get(player)
	data.wins = (data.wins or 0) + 1
	data.winStreak = (data.winStreak or 0) + 1
	refreshUnlocks(data)
	self:Save(player)
	return data
end

function ProgressionService:RecordLoss(player)
	local data = self:Get(player)
	data.winStreak = 0
	self:Save(player)
	return data
end

function ProgressionService:EquipReaction(player, reactionId)
	local data = self:Get(player)
	if not ReactionRegistry.IsUnlocked(reactionId, data.wins or 0) then
		return false, "Reaction locked"
	end
	data.equippedReaction = reactionId
	self:Save(player)
	return true
end

function ProgressionService:EquipCup(player, cupSelection)
	local data = self:Get(player)
	if cupSelection and cupSelection.straw and not table.find(data.unlockedStraws or {}, cupSelection.straw) then
		return false, "Straw locked"
	end
	data.equippedCup = cupSelection or CupConfig.GetDefaultCup()
	self:Save(player)
	return true
end

function ProgressionService:UnlockNamedStraw(player, strawId)
	-- TODO: Call this after MarketplaceService.ProcessReceipt confirms the exact named straw product id.
	-- Example mapping to add in your purchase handler:
	-- local STRAW_PRODUCT_IDS = { crazy = 000000, glitter = 000000, glow = 000000, loop = 000000 }
	local data = self:Get(player)
	data.purchasedNamedStraws = data.purchasedNamedStraws or {}
	if not table.find(data.purchasedNamedStraws, strawId) then
		table.insert(data.purchasedNamedStraws, strawId)
	end
	refreshUnlocks(data)
	self:Save(player)
	return true
end

function ProgressionService:Remove(player)
	self:Save(player)
	self.cache[player.UserId] = nil
end

return ProgressionService
