--[[
Purpose: Client click handling for secret poison selection and cup filling at Don't Drink That fountain spouts.
Where it goes in Studio: StarterPlayer/StarterPlayerScripts/FountainSpoutController.lua (LocalScript)
Dependencies: ReplicatedStorage/GameConfig.lua, ReplicatedStorage/Remotes/RequestPoison, RequestFill
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local activePhase = GameConfig.Phases.LOBBY
local activeFountainName = nil

local function getSpoutIndex(name)
	return tonumber(string.match(name, "Spout_(%d+)"))
end

local function pulseSpout(spout)
	if not spout or not spout:IsA("BasePart") then return end
	local original = spout.Size
	local grow = TweenService:Create(spout, TweenInfo.new(0.12, Enum.EasingStyle.Back), { Size = original * 1.18 })
	local shrink = TweenService:Create(spout, TweenInfo.new(0.12), { Size = original })
	grow:Play()
	grow.Completed:Connect(function() shrink:Play() end)
end

local function animateOwnCupFill(color)
	local character = player.Character
	local cup = character and character:FindFirstChild("EquippedDontDrinkThatCup")
	local body = cup and cup:FindFirstChild("CupBody", true)
	if not body then return end
	local liquid = body:FindFirstChild("ReactionLiquid") or Instance.new("Part")
	liquid.Name = "ReactionLiquid"
	liquid.Shape = Enum.PartType.Cylinder
	liquid.Size = Vector3.new(0.58, 0.04, 0.58)
	liquid.Material = Enum.Material.Neon
	liquid.Color = color or Color3.fromRGB(0, 220, 255)
	liquid.CanCollide = false
	liquid.Massless = true
	liquid.Parent = body
	liquid.CFrame = body.CFrame * CFrame.new(0, -0.35, 0)
	local weld = liquid:FindFirstChild("LiquidWeld") or Instance.new("WeldConstraint")
	weld.Name = "LiquidWeld"
	weld.Part0 = body
	weld.Part1 = liquid
	weld.Parent = liquid
	TweenService:Create(liquid, TweenInfo.new(0.6, Enum.EasingStyle.Quad), { Size = Vector3.new(0.58, 0.62, 0.58) }):Play()
end

local function wireSpout(spout)
	local spoutIndex = getSpoutIndex(spout.Name)
	if not spoutIndex or spout:FindFirstChild("SpoutClickDetector") then return end
	local click = Instance.new("ClickDetector")
	click.Name = "SpoutClickDetector"
	click.MaxActivationDistance = GameConfig.SpoutClickDistanceStuds
	click.Parent = spout
	click.MouseClick:Connect(function(clickingPlayer)
		if clickingPlayer ~= player then return end
		local fountain = spout:FindFirstAncestorWhichIsA("Model")
		if activeFountainName and fountain and fountain.Name ~= activeFountainName then return end
		pulseSpout(spout)
		if activePhase == GameConfig.Phases.POISON_SELECT then
			Remotes.RequestPoison:FireServer(spoutIndex)
		elseif activePhase == GameConfig.Phases.FILL then
			Remotes.RequestFill:FireServer(spoutIndex)
		end
	end)
end

local function wireFountain(fountain)
	for i = 1, GameConfig.SpoutCount do
		local spout = fountain:FindFirstChild("Spout_" .. tostring(i), true)
		if spout and spout:IsA("BasePart") then wireSpout(spout) end
	end
	fountain.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") and string.match(descendant.Name, "^Spout_%d+$") then
			wireSpout(descendant)
		end
	end)
end

local folder = workspace:WaitForChild(GameConfig.FountainStationsFolderName, 15)
if folder then
	for _, fountain in ipairs(folder:GetChildren()) do wireFountain(fountain) end
	folder.ChildAdded:Connect(wireFountain)
end

Remotes.StateChanged.OnClientEvent:Connect(function(payload)
	activePhase = payload.phase or activePhase
	activeFountainName = payload.fountainName or activeFountainName
end)

Remotes.RequestFill.OnClientEvent:Connect(function(payload)
	animateOwnCupFill(payload.color)
	print("Filled from", payload.flavor or payload.spoutIndex)
end)
