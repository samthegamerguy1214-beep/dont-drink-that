--[[
Purpose: Builds and welds the player's equipped cup + straw to their left hand for lobby, duels, and reactions.
Where it goes in Studio: ServerScriptService/CupAvatarService.lua (ModuleScript)
Dependencies: ReplicatedStorage/GameConfig.lua, CupConfig.lua
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local CupConfig = require(ReplicatedStorage:WaitForChild("CupConfig"))

local CupAvatarService = {}

local function findById(list, id)
	for _, item in ipairs(list) do
		if item.id == id then return item end
	end
	return list[1]
end

local function scaleVector(a, b)
	return Vector3.new(a.X * b.X, a.Y * b.Y, a.Z * b.Z)
end

function CupAvatarService.BuildCupModel(cupSelection)
	cupSelection = cupSelection or CupConfig.GetDefaultCup()
	local shape = findById(CupConfig.Shapes, cupSelection.shape)
	local color = findById(CupConfig.Colors, cupSelection.color)
	local straw = findById(CupConfig.Straws, cupSelection.straw)

	local model = Instance.new("Model")
	model.Name = "EquippedDontDrinkThatCup"

	local cup = Instance.new("Part")
	cup.Name = "CupBody"
	cup.Shape = Enum.PartType.Cylinder
	cup.Size = scaleVector(Vector3.new(0.75, 1.05, 0.75), shape.scale or Vector3.new(1, 1, 1))
	cup.Material = Enum.Material.SmoothPlastic
	cup.Color = color.color
	cup.CanCollide = false
	cup.Massless = true
	cup.Parent = model
	model.PrimaryPart = cup

	local strawPart = Instance.new("Part")
	strawPart.Name = "Straw_" .. straw.id
	strawPart.Size = Vector3.new(0.09, 1.25, 0.09)
	strawPart.Material = straw.id == "glow" and Enum.Material.Neon or Enum.Material.SmoothPlastic
	strawPart.Color = straw.id == "glitter" and Color3.fromRGB(255, 230, 255) or Color3.fromRGB(255, 255, 255)
	strawPart.CanCollide = false
	strawPart.Massless = true
	strawPart.CFrame = cup.CFrame * GameConfig.StrawWeldOffset
	strawPart.Parent = model

	local strawWeld = Instance.new("WeldConstraint")
	strawWeld.Name = "StrawToCupWeld"
	strawWeld.Part0 = cup
	strawWeld.Part1 = strawPart
	strawWeld.Parent = cup

	return model
end

function CupAvatarService.ApplyCupToCharacter(player, cupSelection)
	local character = player.Character
	if not character then return nil end
	local hand = character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm")
	if not hand or not hand:IsA("BasePart") then return nil end

	local existing = character:FindFirstChild("EquippedDontDrinkThatCup")
	if existing then existing:Destroy() end

	local model = CupAvatarService.BuildCupModel(cupSelection)
	model.Parent = character
	local cup = model.PrimaryPart
	cup.CFrame = hand.CFrame * GameConfig.CupWeldOffset
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") and part ~= cup then
			part.CFrame = cup.CFrame * GameConfig.StrawWeldOffset
		end
	end

	local weld = Instance.new("WeldConstraint")
	weld.Name = "CupToLeftHandWeld"
	weld.Part0 = hand
	weld.Part1 = cup
	weld.Parent = cup
	return model
end

return CupAvatarService
