--[[
Purpose: Client reaction animation player for Don't Drink That poison-sip losses.
Where it goes in Studio: StarterPlayer/StarterPlayerScripts/ReactionPlayer.lua (ModuleScript)
Dependencies: ReplicatedStorage/ReactionRegistry.lua, StarterPlayerScripts/StrawBehaviors.lua
]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReactionRegistry = require(ReplicatedStorage:WaitForChild("ReactionRegistry"))
local StrawBehaviors = require(script.Parent:WaitForChild("StrawBehaviors"))

local ReactionPlayer = {}

local function getCharacter(player)
	return player and player.Character
end

local function getParts(character)
	local parts = {}
	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") and not descendant:FindFirstAncestor("EquippedDontDrinkThatCup") then
			table.insert(parts, descendant)
		end
	end
	return parts
end

local function playSpinFling(player)
	local character = getCharacter(player)
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local head = character and character:FindFirstChild("Head")
	if not root or not head then return end

	local face = head:FindFirstChildWhichIsA("Decal")
	local oldTexture = face and face.Texture
	if face then
		-- TODO: Replace with your disgust face decal asset id after uploading it.
		face.Texture = "rbxassetid://0"
	end

	for i = 1, 3 do
		local tween = TweenService:Create(head, TweenInfo.new(0.18, Enum.EasingStyle.Linear), { CFrame = head.CFrame * CFrame.Angles(0, math.rad(360), 0) })
		tween:Play()
		tween.Completed:Wait()
	end

	local velocity = Instance.new("BodyVelocity")
	velocity.MaxForce = Vector3.new(0, math.huge, 0)
	velocity.Velocity = Vector3.new(0, 85, 0)
	velocity.Parent = root
	Debris:AddItem(velocity, 1.5)

	task.delay(2, function()
		if face and oldTexture then
			face.Texture = oldTexture
		end
	end)
end

local function playPuddle(player)
	local character = getCharacter(player)
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local puddle = Instance.new("Part")
	puddle.Name = "DontDrinkThatPuddle"
	puddle.Shape = Enum.PartType.Cylinder
	puddle.Anchored = true
	puddle.CanCollide = false
	puddle.Material = Enum.Material.Neon
	puddle.Color = Color3.fromRGB(85, 255, 180)
	puddle.Size = Vector3.new(0.2, 0.1, 0.2)
	puddle.CFrame = CFrame.new(root.Position - Vector3.new(0, 2.5, 0)) * CFrame.Angles(0, 0, math.rad(90))
	puddle.Parent = workspace
	TweenService:Create(puddle, TweenInfo.new(0.8, Enum.EasingStyle.Back), { Size = Vector3.new(0.2, 5, 5) }):Play()
	Debris:AddItem(puddle, 3)

	for _, part in ipairs(getParts(character)) do
		TweenService:Create(part, TweenInfo.new(0.8), { Transparency = 1 }):Play()
	end
	task.delay(2.5, function()
		for _, part in ipairs(getParts(character)) do
			part.Transparency = 0
		end
	end)
end

local function playBalloon(player)
	local character = getCharacter(player)
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	for _, part in ipairs(getParts(character)) do
		local goal = { Size = part.Size * 3 }
		TweenService:Create(part, TweenInfo.new(1, Enum.EasingStyle.Back), goal):Play()
	end

	local pop = Instance.new("ParticleEmitter")
	pop.Name = "BalloonPop"
	pop.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	pop.Rate = 0
	pop.Lifetime = NumberRange.new(0.35, 0.7)
	pop.Speed = NumberRange.new(20, 35)
	pop.Parent = root

	task.delay(1.05, function()
		pop:Emit(80)
		for _, part in ipairs(getParts(character)) do
			part.Transparency = 1
		end
	end)
	Debris:AddItem(pop, 3)
	task.delay(2.5, function()
		for _, part in ipairs(getParts(character)) do
			part.Transparency = 0
		end
	end)
end

local function playRagdollFlop(player)
	local character = getCharacter(player)
	local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then return end

	humanoid.PlatformStand = true
	root:ApplyImpulse((-root.CFrame.LookVector * 90 + Vector3.new(0, 45, 0)) * root.AssemblyMass)
	task.delay(2.25, function()
		if humanoid then
			humanoid.PlatformStand = false
		end
	end)
end

local handlers = {
	spin_fling = playSpinFling,
	puddle = playPuddle,
	balloon = playBalloon,
	ragdoll_flop = playRagdollFlop,
}

function ReactionPlayer.PlayReaction(player, reactionId)
	local reaction = ReactionRegistry.Get(reactionId)
	if not reaction then
		warn("Unknown reaction: " .. tostring(reactionId))
		return
	end

	local character = getCharacter(player)
	StrawBehaviors.PlayForCharacter(character, 2.8)
	local handler = handlers[reactionId]
	if handler then
		handler(player)
	else
		warn("TODO: Add full animation for reaction " .. reactionId .. " (" .. reaction.displayName .. ")")
		playSpinFling(player)
	end
end

return ReactionPlayer
