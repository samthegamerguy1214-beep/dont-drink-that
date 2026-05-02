--[[
Purpose: Cosmetic-only daily spin service with 24-hour cooldown and no paid spins/reaction drops.
Where it goes in Studio: ServerScriptService/DailySpinService.server.lua (Script)
Dependencies: ReplicatedStorage/GameConfig.lua, CupConfig.lua, Remotes/RequestDailySpin and DailySpinResult
]]

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local CupConfig = require(ReplicatedStorage:WaitForChild("CupConfig"))

local store = DataStoreService:GetDataStore("DontDrinkThatDailySpin_v1")
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not Remotes then
	Remotes = Instance.new("Folder")
	Remotes.Name = "Remotes"
	Remotes.Parent = ReplicatedStorage
end
for _, name in ipairs({ "RequestDailySpin", "DailySpinResult" }) do
	if not Remotes:FindFirstChild(name) then
		local event = Instance.new("RemoteEvent")
		event.Name = name
		event.Parent = Remotes
	end
end

local function getPrizePool()
	local pool = {}
	for _, color in ipairs(CupConfig.Colors) do
		table.insert(pool, { type = "color", id = color.id, displayName = color.displayName })
	end
	for _, pattern in ipairs(CupConfig.Patterns) do
		table.insert(pool, { type = "pattern", id = pattern.id, displayName = pattern.displayName })
	end
	return pool
end

Remotes.RequestDailySpin.OnServerEvent:Connect(function(player)
	local key = "daily_spin_" .. player.UserId
	local now = os.time()
	local ok, lastSpin = pcall(function() return store:GetAsync(key) end)
	lastSpin = (ok and tonumber(lastSpin)) or 0
	local remaining = GameConfig.DailySpinCooldownSeconds - (now - lastSpin)
	if remaining > 0 then
		Remotes.DailySpinResult:FireClient(player, { ok = false, remainingSeconds = remaining, message = "Daily cosmetic spin is still cooling down." })
		return
	end
	local pool = getPrizePool()
	local prize = pool[math.random(1, #pool)]
	pcall(function() store:SetAsync(key, now) end)
	-- TODO: Merge this prize into ProgressionService ownedCupParts if you want permanent ownership tracked in one profile store.
	Remotes.DailySpinResult:FireClient(player, { ok = true, prize = prize, message = "Cosmetic cup part unlocked: " .. prize.displayName })
end)
