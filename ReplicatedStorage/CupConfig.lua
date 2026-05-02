--[[
Purpose: Shared cup/straw customization data for Don't Drink That.
Where it goes in Studio: ReplicatedStorage/CupConfig.lua (ModuleScript)
Dependencies: None
]]

local CupConfig = {}

CupConfig.Shapes = {
	{ id = "classic", displayName = "Classic", scale = Vector3.new(1, 1, 1) },
	{ id = "tall", displayName = "Tall", scale = Vector3.new(0.85, 1.3, 0.85) },
	{ id = "wide", displayName = "Wide", scale = Vector3.new(1.25, 0.9, 1.25) },
	{ id = "wobble", displayName = "Wobble", scale = Vector3.new(1.1, 1, 1.1) },
	{ id = "crystal", displayName = "Crystal", scale = Vector3.new(0.95, 1.1, 0.95) },
}

CupConfig.Colors = {
	{ id = "cola_red", displayName = "Cola Red", color = Color3.fromRGB(255, 55, 75) },
	{ id = "blue_raspberry", displayName = "Blue Raspberry", color = Color3.fromRGB(0, 170, 255) },
	{ id = "slime_green", displayName = "Slime Green", color = Color3.fromRGB(85, 255, 95) },
	{ id = "grape", displayName = "Grape", color = Color3.fromRGB(155, 85, 255) },
	{ id = "orange", displayName = "Orange", color = Color3.fromRGB(255, 145, 35) },
	{ id = "lemon", displayName = "Lemon", color = Color3.fromRGB(255, 238, 65) },
	{ id = "bubblegum", displayName = "Bubblegum", color = Color3.fromRGB(255, 105, 210) },
	{ id = "mint", displayName = "Mint", color = Color3.fromRGB(95, 255, 210) },
	{ id = "midnight", displayName = "Midnight", color = Color3.fromRGB(25, 25, 45) },
	{ id = "vanilla", displayName = "Vanilla", color = Color3.fromRGB(255, 241, 205) },
}

CupConfig.Patterns = {
	{ id = "solid", displayName = "Solid" },
	{ id = "stripes", displayName = "Stripes" },
	{ id = "dots", displayName = "Dots" },
	{ id = "checker", displayName = "Checker" },
	{ id = "gradient", displayName = "Gradient" },
	{ id = "galaxy", displayName = "Galaxy" },
	{ id = "camo", displayName = "Camo" },
	{ id = "holo", displayName = "Holo" },
}

CupConfig.Straws = {
	{ id = "straight", displayName = "Straight", rarity = "Common", behaviorId = "none", unlockWins = 0 },
	{ id = "bendy", displayName = "Bendy", rarity = "Common", behaviorId = "wiggle", unlockWins = 0 },
	{ id = "crazy", displayName = "Crazy", rarity = "Uncommon", behaviorId = "twirl", unlockWins = 3 },
	{ id = "glitter", displayName = "Glitter", rarity = "Rare", behaviorId = "glitter_trail", unlockWins = 10 },
	{ id = "glow", displayName = "Glow", rarity = "Epic", behaviorId = "light_streak", unlockWins = 25 },
	{ id = "loop", displayName = "Loop", rarity = "Legendary", behaviorId = "spin_wild", unlockWins = 50 },
}

local strawById = {}
for _, straw in ipairs(CupConfig.Straws) do
	strawById[straw.id] = straw
end

function CupConfig.GetStraw(strawId)
	return strawById[strawId] or CupConfig.Straws[1]
end

function CupConfig.GetUnlockedStrawsForWins(wins)
	local unlocked = {}
	for _, straw in ipairs(CupConfig.Straws) do
		if wins >= straw.unlockWins then
			table.insert(unlocked, straw.id)
		end
	end
	return unlocked
end

function CupConfig.IsStrawUnlocked(strawId, wins)
	local straw = CupConfig.GetStraw(strawId)
	return straw ~= nil and wins >= straw.unlockWins
end

CupConfig.Flavors = {
	{ id = "witches_brew", displayName = "Witches Brew", color = Color3.fromRGB(90, 20, 140) },
	{ id = "starblox", displayName = "StarBlox", color = Color3.fromRGB(35, 135, 255) },
	{ id = "slushie", displayName = "Slushie", color = Color3.fromRGB(0, 220, 255) },
	{ id = "milkshake", displayName = "Milkshake", color = Color3.fromRGB(255, 210, 230) },
	{ id = "coconut", displayName = "Coconut", color = Color3.fromRGB(250, 250, 235) },
	{ id = "bloxiade", displayName = "Bloxiade", color = Color3.fromRGB(255, 95, 80) },
	{ id = "honey", displayName = "Honey", color = Color3.fromRGB(255, 205, 65) },
	{ id = "milk", displayName = "Milk", color = Color3.fromRGB(245, 245, 245) },
	{ id = "lemonade", displayName = "Lemonade", color = Color3.fromRGB(255, 240, 65) },
	{ id = "pickle_juice", displayName = "Pickle Juice", color = Color3.fromRGB(110, 220, 70) },
}

function CupConfig.GetDefaultCup()
	return {
		shape = CupConfig.Shapes[1].id,
		color = CupConfig.Colors[1].id,
		pattern = CupConfig.Patterns[1].id,
		straw = CupConfig.Straws[1].id,
	}
end

return CupConfig
