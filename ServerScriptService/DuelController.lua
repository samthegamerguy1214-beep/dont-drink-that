--[[
Purpose: Best-of-3 server state machine for open-view Don't Drink That duels at public Fountain stations.
Where it goes in Studio: ServerScriptService/DuelController.lua (ModuleScript)
Dependencies: GameConfig.lua, PoisonLogic.lua, FountainFillService.lua, ProgressionService.lua, CupAvatarService.lua
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local PoisonLogic = require(ServerScriptService:WaitForChild("PoisonLogic"))
local FountainFillService = require(ServerScriptService:WaitForChild("FountainFillService"))
local ProgressionService = require(ServerScriptService:WaitForChild("ProgressionService"))
local CupAvatarService = require(ServerScriptService:WaitForChild("CupAvatarService"))

local DuelController = {}
DuelController.__index = DuelController

local function ensureRemotes()
	local remotes = ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder")
	remotes.Name = "Remotes"
	remotes.Parent = ReplicatedStorage
	for _, name in ipairs({ "RequestPoison", "RequestFill", "ReactionPlayed", "StateChanged", "RoundResult", "RequestDailySpin", "DailySpinResult", "RequestEquipCup", "RequestEquipReaction", "ProgressionUpdated" }) do
		if not remotes:FindFirstChild(name) then
			local event = Instance.new("RemoteEvent")
			event.Name = name
			event.Parent = remotes
		end
	end
	return remotes
end

local Remotes = ensureRemotes()

function DuelController.new()
	local self = setmetatable({}, DuelController)
	self.activeDuels = {}
	self.fountainFillService = FountainFillService.new()
	self.progression = ProgressionService.new()
	self:_connectRemotes()
	Players.PlayerRemoving:Connect(function(player) self.progression:Remove(player) end)
	return self
end

function DuelController:_connectRemotes()
	Remotes.RequestPoison.OnServerEvent:Connect(function(player, spoutIndex)
		local duel = self:GetDuelForPlayer(player)
		if not duel then return end
		local ok, message = duel.fountainFillService:RegisterPoison(duel.fountain, player, duel.phase, duel.poisonLogic, spoutIndex)
		if ok then
			Remotes.StateChanged:FireClient(player, {
				phase = duel.phase,
				ownPoison = spoutIndex,
				fountainName = duel.fountain.Name,
				roundNumber = duel.roundNumber,
				matchScore = duel.matchScore,
				message = "Poison locked.",
			})
		else
			Remotes.StateChanged:FireClient(player, { phase = duel.phase, error = message })
		end
	end)

	Remotes.RequestFill.OnServerEvent:Connect(function(player, spoutIndex)
		local duel = self:GetDuelForPlayer(player)
		if not duel then return end
		local ok, payload = duel.fountainFillService:RegisterFill(duel.roundId, duel.fountain, player, duel.phase, spoutIndex)
		if ok then
			payload.fountainName = duel.fountain.Name
			Remotes.RequestFill:FireClient(player, payload)
		else
			Remotes.StateChanged:FireClient(player, { phase = duel.phase, error = payload })
		end
	end)
end

function DuelController:GetDuelForPlayer(player)
	for _, duel in pairs(self.activeDuels) do
		for _, participant in ipairs(duel.players) do
			if participant == player then return duel end
		end
	end
	return nil
end

function DuelController:_fireState(duel, phase, secondsRemaining, extra)
	duel.phase = phase
	local payload = extra or {}
	payload.phase = phase
	payload.secondsRemaining = secondsRemaining or 0
	payload.matchId = duel.matchId
	payload.roundId = duel.roundId
	payload.roundNumber = duel.roundNumber
	payload.matchScore = duel.matchScore
	payload.fountainName = duel.fountain.Name
	for _, player in ipairs(duel.players) do
		Remotes.StateChanged:FireClient(player, payload)
	end
end

function DuelController:_countdown(duel, phase, duration, canEndEarly)
	for remaining = duration, 0, -1 do
		if not self.activeDuels[duel.matchId] then return false end
		self:_fireState(duel, phase, remaining)
		if canEndEarly and canEndEarly() then break end
		task.wait(1)
	end
	return true
end

local function getPad(fountain, padName)
	local pad = fountain:FindFirstChild(padName, true)
	return pad and pad:IsA("BasePart") and pad or nil
end

function DuelController:_teleportPlayers(duel)
	for index, player in ipairs(duel.players) do
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		local pad = getPad(duel.fountain, index == 1 and "PlayerA_Pad" or "PlayerB_Pad")
		if root and pad then root.CFrame = pad.CFrame + Vector3.new(0, 4, 0) end
		local data = self.progression:Get(player)
		CupAvatarService.ApplyCupToCharacter(player, data.equippedCup)
	end
end

function DuelController:_teleportToLobby(duel)
	local lobbyPad = workspace:FindFirstChild(GameConfig.LobbyPadName)
	for _, player in ipairs(duel.players) do
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if root and lobbyPad and lobbyPad:IsA("BasePart") then
			root.CFrame = lobbyPad.CFrame + Vector3.new(math.random(-8, 8), 4, math.random(-8, 8))
		end
	end
end

function DuelController:_updateScoreboard(duel, text)
	local anchor = duel.fountain:FindFirstChild("SafeBillboardAnchor", true) or duel.fountain:FindFirstChild("ScoreboardAnchor", true)
	if not anchor or not anchor:IsA("BasePart") then anchor = duel.fountain.PrimaryPart or duel.fountain:FindFirstChildWhichIsA("BasePart", true) end
	if not anchor then return end
	local gui = anchor:FindFirstChild("MatchScoreGui")
	if not gui then
		gui = Instance.new("BillboardGui")
		gui.Name = "MatchScoreGui"
		gui.Size = UDim2.fromOffset(260, 95)
		gui.StudsOffset = Vector3.new(0, 6, 0)
		gui.AlwaysOnTop = true
		gui.Parent = anchor
		local label = Instance.new("TextLabel")
		label.Name = "ScoreLabel"
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 0.1
		label.BackgroundColor3 = Color3.fromRGB(20, 75, 35)
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextStrokeTransparency = 0
		label.Font = Enum.Font.FredokaOne
		label.TextScaled = true
		label.Parent = gui
	end
	gui.ScoreLabel.Text = text
end

function DuelController:StartDuel(playerA, playerB, fountain)
	local matchId = HttpService:GenerateGUID(false)
	local duel = {
		matchId = matchId,
		roundId = "",
		roundNumber = 0,
		players = { playerA, playerB },
		fountain = fountain,
		phase = GameConfig.Phases.LOBBY,
		poisonLogic = PoisonLogic.new(),
		fountainFillService = self.fountainFillService,
		matchScore = { [playerA.UserId] = 0, [playerB.UserId] = 0 },
	}
	self.activeDuels[matchId] = duel
	fountain:SetAttribute("Occupied", true)
	fountain:SetAttribute("MatchId", matchId)
	self:_teleportPlayers(duel)
	self:_updateScoreboard(duel, "SAFE\n0 - 0")
	task.spawn(function() self:_runMatch(duel) end)
end

function DuelController:_runRound(duel)
	duel.roundNumber += 1
	duel.roundId = duel.matchId .. "_R" .. tostring(duel.roundNumber)
	duel.poisonLogic = PoisonLogic.new()
	duel.poisonLogic:Reset(duel.players)
	duel.fountainFillService:StartRound(duel.roundId, duel.players)

	self:_countdown(duel, GameConfig.Phases.POISON_SELECT, GameConfig.PhaseDurations.POISON_SELECT, function()
		return duel.poisonLogic:EveryoneSelected(duel.players)
	end)
	for _, player in ipairs(duel.players) do
		if not duel.poisonLogic:GetOwnPoison(player) then
			duel.poisonLogic:SetPoison(player, math.random(1, GameConfig.SpoutCount))
		end
	end

	self:_countdown(duel, GameConfig.Phases.FILL, GameConfig.PhaseDurations.FILL, function()
		return duel.fountainFillService:EveryoneFilled(duel.roundId, duel.players)
	end)

	self:_countdown(duel, GameConfig.Phases.SIP, GameConfig.PhaseDurations.SIP)

	local selectedDrinks = {}
	for _, player in ipairs(duel.players) do
		local fill = duel.fountainFillService:GetFill(duel.roundId, player)
		selectedDrinks[player.UserId] = (fill and fill.spoutIndex) or math.random(1, GameConfig.SpoutCount)
	end

	local results = duel.poisonLogic:Resolve(duel.players, selectedDrinks)
	local reactionByUserId = {}
	for _, player in ipairs(duel.players) do
		reactionByUserId[player.UserId] = self.progression:Get(player).equippedReaction or GameConfig.DefaultReactionId
	end
	local poisonedA = results[duel.players[1].UserId].poisoned
	local poisonedB = results[duel.players[2].UserId].poisoned
	local roundWinner = nil
	if poisonedA and not poisonedB then roundWinner = duel.players[2]
	elseif poisonedB and not poisonedA then roundWinner = duel.players[1] end
	if roundWinner then duel.matchScore[roundWinner.UserId] += 1 end

	self:_fireState(duel, GameConfig.Phases.REVEAL, GameConfig.PhaseDurations.REVEAL, {
		results = results,
		reactionByUserId = reactionByUserId,
		roundWinnerUserId = roundWinner and roundWinner.UserId or nil,
		matchScore = duel.matchScore,
	})
	for _, player in ipairs(duel.players) do
		Remotes.RoundResult:FireClient(player, {
			isMatchEnd = false,
			results = results,
			reactionByUserId = reactionByUserId,
			roundWinnerUserId = roundWinner and roundWinner.UserId or nil,
			matchScore = duel.matchScore,
			roundNumber = duel.roundNumber,
		})
	end
	task.wait(GameConfig.PhaseDurations.REVEAL)

	local scoreText = "SAFE\n" .. tostring(duel.matchScore[duel.players[1].UserId]) .. " - " .. tostring(duel.matchScore[duel.players[2].UserId])
	self:_updateScoreboard(duel, scoreText)
	self:_countdown(duel, GameConfig.Phases.ROUND_SCORE, GameConfig.PhaseDurations.ROUND_SCORE)
	duel.fountainFillService:EndRound(duel.roundId)
end

function DuelController:_runMatch(duel)
	self:_countdown(duel, GameConfig.Phases.MATCH_START, GameConfig.PhaseDurations.MATCH_START)
	self:_countdown(duel, GameConfig.Phases.CUSTOMIZE, GameConfig.PhaseDurations.CUSTOMIZE)
	while self.activeDuels[duel.matchId] do
		self:_runRound(duel)
		if duel.matchScore[duel.players[1].UserId] >= GameConfig.MatchWinsRequired or duel.matchScore[duel.players[2].UserId] >= GameConfig.MatchWinsRequired then break end
	end

	local scoreA = duel.matchScore[duel.players[1].UserId]
	local scoreB = duel.matchScore[duel.players[2].UserId]
	local matchWinner = scoreA > scoreB and duel.players[1] or duel.players[2]
	local matchLoser = matchWinner == duel.players[1] and duel.players[2] or duel.players[1]
	local winnerData = self.progression:AwardWin(matchWinner)
	self.progression:RecordLoss(matchLoser)
	self:_updateScoreboard(duel, "WINNER\n" .. matchWinner.DisplayName)
	for _, player in ipairs(duel.players) do
		Remotes.RoundResult:FireClient(player, {
			isMatchEnd = true,
			matchWinnerUserId = matchWinner.UserId,
			matchScore = duel.matchScore,
			progression = player == matchWinner and winnerData or self.progression:Get(player),
		})
	end
	self:_fireState(duel, GameConfig.Phases.MATCH_END, GameConfig.PhaseDurations.MATCH_END, { matchWinnerUserId = matchWinner.UserId, matchScore = duel.matchScore })
	task.wait(GameConfig.PhaseDurations.MATCH_END)
	self:_teleportToLobby(duel)
	self:CleanupDuel(duel.matchId)
end

function DuelController:CleanupDuel(matchId)
	local duel = self.activeDuels[matchId]
	if not duel then return end
	duel.fountain:SetAttribute("Occupied", false)
	duel.fountain:SetAttribute("MatchId", nil)
	self:_updateScoreboard(duel, "SAFE\nOPEN")
	self.activeDuels[matchId] = nil
end

return DuelController
