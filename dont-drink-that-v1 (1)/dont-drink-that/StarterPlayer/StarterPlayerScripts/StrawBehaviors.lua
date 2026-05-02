--[[
Purpose: Rare straw reaction-time behaviors for Don't Drink That social flex.
Where it goes in Studio: StarterPlayer/StarterPlayerScripts/StrawBehaviors.lua (ModuleScript)
Dependencies: ReplicatedStorage/CupConfig.lua
]]

local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CupConfig = require(ReplicatedStorage:WaitForChild("CupConfig"))

local StrawBehaviors = {}

local function getCupAndStraw(character)
	local cupModel = character and character:FindFirstChild("EquippedDontDrinkThatCup")
	local cupBody = cupModel and cupModel:FindFirstChild("CupBody", true)
	local straw
	if cupModel then
		for _, descendant in ipairs(cupModel:GetDescendants()) do
			if descendant:IsA("BasePart") and string.match(descendant.Name, "^Straw_") then
				straw = descendant
				break
			end
		end
	end
	return cupModel, cupBody, straw
end

local function getBehaviorId(straw)
	if not straw then return "none" end
	local strawId = string.gsub(straw.Name, "^Straw_", "")
	return CupConfig.GetStraw(strawId).behaviorId or "none"
end

local function addTipAttachment(straw, name, yOffset)
	local attachment = Instance.new("Attachment")
	attachment.Name = name
	attachment.Position = Vector3.new(0, yOffset or (straw.Size.Y / 2), 0)
	attachment.Parent = straw
	return attachment
end

local function addGlitterTrail(straw, duration)
	local attachment = addTipAttachment(straw, "GlitterTip", straw.Size.Y / 2)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "GlitterTrail"
	emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Size = NumberSequence.new(0.3)
	emitter.Lifetime = NumberRange.new(1.5)
	emitter.Speed = NumberRange.new(1, 4)
	emitter.Rate = 45
	emitter.Color = ColorSequence.new(Color3.fromRGB(255, 240, 255), Color3.fromRGB(255, 210, 70))
	emitter.Parent = attachment
	Debris:AddItem(attachment, duration + 1.7)
end

local function addLightStreak(straw, duration, rainbow)
	local a0 = addTipAttachment(straw, "LightStreakTip0", straw.Size.Y / 2)
	local a1 = addTipAttachment(straw, "LightStreakTip1", -straw.Size.Y / 2)
	local light = Instance.new("PointLight")
	light.Name = "StrawPointLight"
	light.Range = 9
	light.Brightness = 2.5
	light.Color = rainbow and Color3.fromRGB(255, 90, 210) or straw.Color
	light.Parent = straw
	local trail = Instance.new("Trail")
	trail.Name = "StrawLightTrail"
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Lifetime = 0.55
	trail.WidthScale = NumberSequence.new(0.18, 0)
	trail.Color = rainbow and ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 80)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60, 255, 240)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 245, 65)),
	}) or ColorSequence.new(Color3.fromRGB(255, 255, 255), straw.Color)
	trail.Parent = straw
	Debris:AddItem(light, duration + 0.5)
	Debris:AddItem(a0, duration + 0.7)
	Debris:AddItem(a1, duration + 0.7)
	Debris:AddItem(trail, duration + 0.7)
end

local function spinStraw(straw, duration, speed, wiggle)
	local start = os.clock()
	local base = straw.CFrame
	local connection
	connection = RunService.RenderStepped:Connect(function()
		local t = os.clock() - start
		if t >= duration or not straw.Parent then
			connection:Disconnect()
			return
		end
		if wiggle then
			straw.CFrame = base * CFrame.Angles(math.sin(t * 18) * 0.18, 0, math.cos(t * 14) * 0.08)
		else
			straw.CFrame = straw.CFrame * CFrame.Angles(0, math.rad(speed), 0)
		end
	end)
end

function StrawBehaviors.PlayForCharacter(character, duration)
	duration = duration or 2.5
	local _, cupBody, straw = getCupAndStraw(character)
	if not straw then return end
	local behaviorId = getBehaviorId(straw)
	if behaviorId == "none" then return end
	if behaviorId == "wiggle" then
		spinStraw(straw, duration, 0, true)
	elseif behaviorId == "twirl" then
		spinStraw(straw, duration, 42, false)
	elseif behaviorId == "glitter_trail" then
		addGlitterTrail(straw, duration)
	elseif behaviorId == "light_streak" then
		addLightStreak(straw, duration, false)
	elseif behaviorId == "spin_wild" then
		addLightStreak(straw, duration, true)
		addGlitterTrail(straw, duration)
		if cupBody then
			local weld = straw:FindFirstChildWhichIsA("WeldConstraint")
			if weld then weld.Enabled = false end
			local socket = Instance.new("BallSocketConstraint")
			socket.Name = "LegendaryStrawPlay"
			local cupAttachment = Instance.new("Attachment")
			cupAttachment.Parent = cupBody
			local strawAttachment = Instance.new("Attachment")
			strawAttachment.Parent = straw
			socket.Attachment0 = cupAttachment
			socket.Attachment1 = strawAttachment
			socket.Parent = straw
			Debris:AddItem(socket, duration + 0.4)
			Debris:AddItem(cupAttachment, duration + 0.4)
			Debris:AddItem(strawAttachment, duration + 0.4)
			task.delay(duration, function()
				if weld then weld.Enabled = true end
			end)
		end
		spinStraw(straw, duration, 72, false)
	end
end

return StrawBehaviors
