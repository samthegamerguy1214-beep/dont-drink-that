--[[
Purpose: Programmatically builds Don't Drink That plaza objects and 20 shared soda-fountain duel stations.
Where it goes in Studio: ServerScriptService/FountainBuilder.lua (ModuleScript)
Dependencies: ReplicatedStorage/GameConfig.lua
]]

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local FountainBuilder = {}

local function makePart(name, parent, size, position, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Parent = parent
	return part
end

function FountainBuilder.EnsurePlaza()
	if Workspace:FindFirstChild("DontDrinkThat_PlazaFloor") then return end
	local floor = makePart("DontDrinkThat_PlazaFloor", Workspace, Vector3.new(200, 1, 200), Vector3.new(0, -0.5, 0), Color3.fromRGB(80, 220, 90), Enum.Material.Grass)
	-- TODO: Add tiled checker texture/SurfaceAppearance for the final green checkered look.
	local decal = Instance.new("Texture")
	decal.Name = "CheckerTexture_TODO"
	decal.Face = Enum.NormalId.Top
	decal.StudsPerTileU = 12
	decal.StudsPerTileV = 12
	decal.Texture = "rbxassetid://0"
	decal.Parent = floor
end

function FountainBuilder.EnsureLobbyPad()
	local pad = Workspace:FindFirstChild(GameConfig.LobbyPadName)
	if pad then return pad end
	pad = makePart(GameConfig.LobbyPadName, Workspace, Vector3.new(8, 1, 8), Vector3.new(0, 0.6, 0), Color3.fromRGB(255, 230, 70), Enum.Material.Neon)
	local decal = Instance.new("Decal")
	decal.Name = "StarDecal_TODO"
	decal.Face = Enum.NormalId.Top
	decal.Texture = "rbxassetid://0" -- TODO: Upload a star decal and replace.
	decal.Parent = pad
	return pad
end

local function addFlavorLabel(parentPart, text, color)
	local gui = Instance.new("BillboardGui")
	gui.Name = "FlavorLabel"
	gui.Size = UDim2.fromOffset(92, 28)
	gui.StudsOffset = Vector3.new(0, 0.55, 0)
	gui.AlwaysOnTop = true
	gui.Parent = parentPart
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 0.18
	label.BackgroundColor3 = color
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne
	label.Text = text
	label.Parent = gui
end

function FountainBuilder.BuildFountain(index, parent)
	local model = Instance.new("Model")
	model.Name = "FountainStation_" .. tostring(index)
	model:SetAttribute("Occupied", false)
	model.Parent = parent

	local row = math.floor((index - 1) / 5)
	local col = (index - 1) % 5
	local center = Vector3.new(-48 + col * 24, 0, -36 + row * 24)

	local body = makePart("FountainBody", model, Vector3.new(14, 9, 5), center + Vector3.new(0, 4.5, 0), Color3.fromRGB(92, 49, 28), Enum.Material.SmoothPlastic)
	model.PrimaryPart = body
	makePart("ChromeTop", model, Vector3.new(14.5, 1, 5.5), center + Vector3.new(0, 9.25, 0), Color3.fromRGB(190, 190, 200), Enum.Material.Metal)

	for i = 1, GameConfig.SpoutCount do
		local x = -6.1 + (i - 1) * 1.35
		local spout = makePart("Spout_" .. tostring(i), model, Vector3.new(0.7, 0.55, 1.2), center + Vector3.new(x, 5.6, -3), GameConfig.FlavorColors[i] or Color3.new(1, 1, 1), Enum.Material.Neon)
		addFlavorLabel(spout, GameConfig.DefaultFlavors[i] or ("Spout " .. i), spout.Color)
	end

	makePart("PlayerA_Pad", model, Vector3.new(5, 0.5, 5), center + Vector3.new(0, 0.25, -8), Color3.fromRGB(90, 220, 255), Enum.Material.Neon)
	makePart("PlayerB_Pad", model, Vector3.new(5, 0.5, 5), center + Vector3.new(0, 0.25, 8), Color3.fromRGB(255, 95, 210), Enum.Material.Neon)

	local anchor = makePart("SafeBillboardAnchor", model, Vector3.new(1, 1, 1), center + Vector3.new(0, 11, 0), Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic)
	anchor.Transparency = 1
	anchor.CanCollide = false
	return model
end

function FountainBuilder.EnsureFountains()
	FountainBuilder.EnsurePlaza()
	FountainBuilder.EnsureLobbyPad()
	local folder = Workspace:FindFirstChild(GameConfig.FountainStationsFolderName)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = GameConfig.FountainStationsFolderName
		folder.Parent = Workspace
	end
	for i = 1, GameConfig.DefaultFountainStationCount do
		if not folder:FindFirstChild("FountainStation_" .. tostring(i)) then
			FountainBuilder.BuildFountain(i, folder)
		end
	end
	return folder
end

return FountainBuilder
