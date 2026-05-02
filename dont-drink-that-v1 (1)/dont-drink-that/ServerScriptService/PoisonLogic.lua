--[[
Purpose: Server-authoritative poison selection and sip resolution for Don't Drink That.
Where it goes in Studio: ServerScriptService/PoisonLogic.lua (ModuleScript)
Dependencies: ReplicatedStorage/GameConfig.lua
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local PoisonLogic = {}
PoisonLogic.__index = PoisonLogic

function PoisonLogic.new()
	local self = setmetatable({}, PoisonLogic)
	self.playerPoison = {}
	return self
end

function PoisonLogic:Reset(players)
	self.playerPoison = {}
	for _, player in ipairs(players) do
		self.playerPoison[player.UserId] = nil
	end
end

function PoisonLogic:SetPoison(player, fountainIndex)
	if typeof(fountainIndex) ~= "number" then
		return false, "Fountain index must be a number"
	end
	if fountainIndex < 1 or fountainIndex > GameConfig.SpoutCount then
		return false, "Fountain index outside valid range"
	end
	self.playerPoison[player.UserId] = fountainIndex
	return true
end

function PoisonLogic:GetOwnPoison(player)
	return self.playerPoison[player.UserId]
end

function PoisonLogic:EveryoneSelected(players)
	for _, player in ipairs(players) do
		if not self.playerPoison[player.UserId] then
			return false
		end
	end
	return true
end

-- selectedDrinks is a map: [drinker.UserId] = cupIndexDrunk
function PoisonLogic:Resolve(players, selectedDrinks)
	local results = {}

	for _, drinker in ipairs(players) do
		local selectedFountain = selectedDrinks[drinker.UserId]
		local poisonedByOpponent = false

		for _, opponent in ipairs(players) do
			if opponent ~= drinker and self.playerPoison[opponent.UserId] == selectedFountain then
				poisonedByOpponent = true
				break
			end
		end

		results[drinker.UserId] = {
			player = drinker,
			selectedFountain = selectedFountain,
			poisoned = poisonedByOpponent,
		}
	end

	return results
end

return PoisonLogic
