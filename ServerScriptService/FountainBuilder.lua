--[[
Purpose: Programmatically builds Don't Drink That plaza objects and 20 shared soda-fountain duel stations.
Where it goes in Studio: ServerScriptService/FountainBuilder.lua (ModuleScript)
Dependencies: ReplicatedStorage/GameConfig.lua
]]

-- CONFIG: Creator Store model loading
local USE_FREE_MODEL = true
local FOUNTAIN_MODEL_ASSET_ID = "rbxassetid://18492446406" -- Fountain Drink Soda Machine (Sort of Working) by @MinecraftPro97k
local FOUNTAIN_MODEL_FALLBACK_ID = "rbxassetid://10613880684" -- Soda Fountain by @Candy131000

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InsertService = game:GetService("InsertService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local FountainBuilder = {}
local cachedFreeModelTemplate = nil
local warnedFreeModelFailure = false

local function assetNumber(assetUri)
	return tonumber(string.match(assetUri, "(%d+)$"))
end

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

local function removeScripts(instance)
	for _, descendant in ipairs(instance:GetDescendants()) do
		if descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
			descendant:Destroy()
		end
	end
end

local function getModelBounds(model)
	local cframe, size = model:GetBoundingBox()
	return cframe, size
end

local function tryLoadCreatorStoreModel(assetUri)
	local id = assetNumber(assetUri)
	if not id then return nil, "Bad asset id" end
	local ok, containerOrErr = pcall(function()
		return InsertService:LoadAsset(id)
	end)
	if not ok or not containerOrErr then
		return nil, tostring(containerOrErr)
	end

	local container = containerOrErr
	removeScripts(container)
	local model = container:FindFirstChildWhichIsA("Model")
	if not model then
		model = Instance.new("Model")
		model.Name = "LoadedFountainModel"
		for _, child in ipairs(container:GetChildren()) do
			child.Parent = model
		end
	end
	model.Parent = nil
	container:Destroy()
	return model
end

local function getFreeModelTemplate()
	if not USE_FREE_MODEL then return nil end
	if cachedFreeModelTemplate then return cachedFreeModelTemplate end

	local primary, primaryErr = tryLoadCreatorStoreModel(FOUNTAIN_MODEL_ASSET_ID)
	if primary then
		cachedFreeModelTemplate = primary
		return cachedFreeModelTemplate
	end

	local backup, backupErr = tryLoadCreatorStoreModel(FOUNTAIN_MODEL_FALLBACK_ID)
	if backup then
		cachedFreeModelTemplate = backup
		return cachedFreeModelTemplate
	end

	if not warnedFreeModelFailure then
		warn("Don't Drink That: Creator Store fountain model failed to load. Falling back to in-code fountain. Primary error: " .. tostring(primaryErr) .. " Backup error: " .. tostring(backupErr))
		warnedFreeModelFailure = true
	end
	return nil
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

local function getCenterForIndex(index)
	local row = math.floor((index - 1) / 5)
	local col = (index - 1) % 5
	return Vector3.new(-48 + col * 24, 0, -36 + row * 24)
end

local function addInteractionScaffold(model, center, boundsSize)
	local width = math.max(boundsSize.X, 6)
	local depth = math.max(boundsSize.Z, 4)
	local height = math.max(boundsSize.Y, 4)
	local frontZ = center.Z - (depth / 2) - 0.45

	for i = 1, GameConfig.SpoutCount do
		local x = center.X - (width * 0.42) + ((i - 1) / (GameConfig.SpoutCount - 1)) * (width * 0.84)
		local spout = makePart("Spout_" .. tostring(i), model, Vector3.new(0.45, 0.45, 0.75), Vector3.new(x, center.Y + height * 0.55, frontZ), GameConfig.FlavorColors[i] or Color3.new(1, 1, 1), Enum.Material.Neon)
		addFlavorLabel(spout, GameConfig.DefaultFlavors[i] or ("Spout " .. i), spout.Color)
	end

	makePart("PlayerA_Pad", model, Vector3.new(5, 0.5, 5), center + Vector3.new(0, 0.25, -(depth / 2 + 5)), Color3.fromRGB(90, 220, 255), Enum.Material.Neon)
	makePart("PlayerB_Pad", model, Vector3.new(5, 0.5, 5), center + Vector3.new(0, 0.25, depth / 2 + 5), Color3.fromRGB(255, 95, 210), Enum.Material.Neon)

	local anchor = makePart("SafeBillboardAnchor", model, Vector3.new(1, 1, 1), center + Vector3.new(0, height + 3, 0), Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic)
	anchor.Transparency = 1
	anchor.CanCollide = false
end

local function buildLoadedFountain(index, parent, center)
	local template = getFreeModelTemplate()
	if not template then return nil end
	local model = template:Clone()
	model.Name = "FountainStation_" .. tostring(index)
	model:SetAttribute("Occupied", false)
	model.Parent = parent
	model:PivotTo(CFrame.new(center + Vector3.new(0, 2.5, 0)))
	local _, size = getModelBounds(model)
	addInteractionScaffold(model, center, size)
	return model
end

local function buildStylizedFallbackFountain(index, parent, center)
	local model = Instance.new("Model")
	model.Name = "FountainStation_" .. tostring(index)
	model:SetAttribute("Occupied", false)
	model.Parent = parent

	local body = makePart("FountainBody", model, Vector3.new(7.5, 5.2, 2.5), center + Vector3.new(0, 3.1, 0), Color3.fromRGB(58, 61, 67), Enum.Material.Metal)
	model.PrimaryPart = body
	makePart("ChromeTop", model, Vector3.new(8.1, 0.6, 2.9), center + Vector3.new(0, 5.95, 0), Color3.fromRGB(205, 205, 215), Enum.Material.Metal)
	makePart("DripTray", model, Vector3.new(7.2, 0.35, 1.15), center + Vector3.new(0, 1.0, -1.7), Color3.fromRGB(20, 22, 25), Enum.Material.Metal)

	local panel = makePart("SodaFrontPanel", model, Vector3.new(7.0, 2.0, 0.18), center + Vector3.new(0, 3.7, -1.34), Color3.fromRGB(210, 36, 42), Enum.Material.SmoothPlastic)
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Name = "SODALogoPlaceholder"
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.Parent = panel
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Text = "SODA"
	text.TextColor3 = Color3.fromRGB(255, 255, 255)
	text.TextStrokeTransparency = 0
	text.TextScaled = true
	text.Font = Enum.Font.FredokaOne
	text.Parent = surfaceGui

	for i = 1, GameConfig.SpoutCount do
		local x = -3.15 + (i - 1) * 0.7
		local spout = makePart("Spout_" .. tostring(i), model, Vector3.new(0.42, 0.42, 0.82), center + Vector3.new(x, 2.45, -1.75), GameConfig.FlavorColors[i] or Color3.new(1, 1, 1), Enum.Material.Neon)
		spout.Shape = Enum.PartType.Cylinder
		spout.CFrame = CFrame.new(spout.Position) * CFrame.Angles(math.rad(90), 0, 0)
		addFlavorLabel(spout, GameConfig.DefaultFlavors[i] or ("Spout " .. i), spout.Color)
	end

	makePart("PlayerA_Pad", model, Vector3.new(5, 0.5, 5), center + Vector3.new(0, 0.25, -6), Color3.fromRGB(90, 220, 255), Enum.Material.Neon)
	makePart("PlayerB_Pad", model, Vector3.new(5, 0.5, 5), center + Vector3.new(0, 0.25, 6), Color3.fromRGB(255, 95, 210), Enum.Material.Neon)
	local anchor = makePart("SafeBillboardAnchor", model, Vector3.new(1, 1, 1), center + Vector3.new(0, 8.5, 0), Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic)
	anchor.Transparency = 1
	anchor.CanCollide = false
	return model
end

function FountainBuilder.BuildFountain(index, parent)
	local center = getCenterForIndex(index)
	if USE_FREE_MODEL then
		local loaded = buildLoadedFountain(index, parent, center)
		if loaded then return loaded end
	end
	return buildStylizedFallbackFountain(index, parent, center)
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
