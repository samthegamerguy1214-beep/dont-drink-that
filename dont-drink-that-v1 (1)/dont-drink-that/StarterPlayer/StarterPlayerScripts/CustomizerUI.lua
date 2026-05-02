--[[
Purpose: Lightweight Don't Drink That cup/straw customizer and reaction equip panel mockup for MVP.
Where it goes in Studio: StarterPlayer/StarterPlayerScripts/CustomizerUI.lua (LocalScript)
Dependencies: ReplicatedStorage/CupConfig.lua, ReactionRegistry.lua, Remotes/StateChanged
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local CupConfig = require(ReplicatedStorage:WaitForChild("CupConfig"))
local ReactionRegistry = require(ReplicatedStorage:WaitForChild("ReactionRegistry"))
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local selected = CupConfig.GetDefaultCup()
local selectedReaction = "spin_fling"

local gui = Instance.new("ScreenGui")
gui.Name = "DontDrinkThatCustomizerUI"
gui.ResetOnSpawn = false
gui.Enabled = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(520, 360)
panel.Position = UDim2.new(0.5, -260, 0.5, -180)
panel.BackgroundColor3 = Color3.fromRGB(22, 12, 42)
panel.BackgroundTransparency = 0.08
panel.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.FredokaOne
title.Text = "Don't Drink That Customizer"
title.Parent = panel

local body = Instance.new("TextLabel")
body.Size = UDim2.new(1, -30, 1, -65)
body.Position = UDim2.fromOffset(15, 55)
body.BackgroundTransparency = 1
body.TextColor3 = Color3.fromRGB(235, 245, 255)
body.TextWrapped = true
body.TextXAlignment = Enum.TextXAlignment.Left
body.TextYAlignment = Enum.TextYAlignment.Top
body.TextSize = 18
body.Font = Enum.Font.GothamBold
body.Parent = panel

local function redraw()
	local wins = 0 -- MVP client display fallback; server enforces real unlocks on save.
	local strawRows = {}
	for _, straw in ipairs(CupConfig.Straws) do
		local locked = wins < straw.unlockWins
		table.insert(strawRows, (locked and "[LOCKED] " or "[READY] ") .. straw.displayName .. " — " .. straw.rarity .. " — " .. straw.unlockWins .. " wins — " .. straw.behaviorId)
	end
	body.Text = "MVP defaults equipped:\n" ..
		"Cup: " .. selected.shape .. " / " .. selected.color .. " / " .. selected.pattern .. " / " .. selected.straw .. "\n" ..
		"Reaction: " .. selectedReaction .. "\n\n" ..
		"Available data already supports:\n" ..
		#CupConfig.Shapes .. " shapes × " .. #CupConfig.Colors .. " colors × " .. #CupConfig.Patterns .. " patterns × " .. #CupConfig.Straws .. " straws.\n\n" ..
		"Straws (server saves equipped straw and enforces locks):\n" .. table.concat(strawRows, "\n") .. "\n\n" ..
		"Reactions:\n" .. table.concat((function()
			local rows = {}
			for _, reaction in ipairs(ReactionRegistry.Reactions) do
				table.insert(rows, reaction.displayName .. " — " .. reaction.unlockTier .. " wins")
			end
			return rows
		end)(), "\n")
end

redraw()

Remotes.StateChanged.OnClientEvent:Connect(function(payload)
	gui.Enabled = payload.phase == "CUSTOMIZE"
end)
