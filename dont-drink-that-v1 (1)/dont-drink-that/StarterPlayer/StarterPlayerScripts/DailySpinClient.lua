--[[
Purpose: Simple client ClickDetector setup for the cosmetic-only Daily Spin Wheel stand.
Where it goes in Studio: StarterPlayer/StarterPlayerScripts/DailySpinClient.lua (LocalScript)
Dependencies: ReplicatedStorage/Remotes/RequestDailySpin, DailySpinResult
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local gui = Instance.new("ScreenGui")
gui.Name = "DailySpinUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local toast = Instance.new("TextLabel")
toast.Size = UDim2.fromOffset(460, 60)
toast.Position = UDim2.new(0.5, -230, 1, -190)
toast.BackgroundTransparency = 0.2
toast.BackgroundColor3 = Color3.fromRGB(20, 60, 25)
toast.TextColor3 = Color3.fromRGB(255, 255, 255)
toast.TextScaled = true
toast.Font = Enum.Font.FredokaOne
toast.Visible = false
toast.Parent = gui

local function showToast(message)
	toast.Text = message
	toast.Visible = true
	task.delay(4, function()
		toast.Visible = false
	end)
end

local function wireSpinWheel()
	local stand = workspace:FindFirstChild("DailySpinWheel", true)
	if not stand then return end
	local part = stand:IsA("BasePart") and stand or stand:FindFirstChildWhichIsA("BasePart", true)
	if not part or part:FindFirstChild("DailySpinClick") then return end
	local click = Instance.new("ClickDetector")
	click.Name = "DailySpinClick"
	click.MaxActivationDistance = 14
	click.Parent = part
	click.MouseClick:Connect(function(clickingPlayer)
		if clickingPlayer == player then
			Remotes.RequestDailySpin:FireServer()
		end
	end)
end

wireSpinWheel()
workspace.DescendantAdded:Connect(function(descendant)
	if descendant.Name == "DailySpinWheel" then
		task.wait(0.1)
		wireSpinWheel()
	end
end)

Remotes.DailySpinResult.OnClientEvent:Connect(function(payload)
	showToast(payload.message or (payload.ok and "Cosmetic unlocked!" or "Spin unavailable."))
end)
