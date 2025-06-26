local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local speed = 50
local fly1Enabled = false
local fly2Enabled = false
local bodyVel = nil

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyModesGUI"
screenGui.ResetOnSpawn = false

-- Use PlayerGui instead of CoreGui for better compatibility
pcall(function()
	screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
end)

-- Fly Mode 1 Button
local fly1Button = Instance.new("TextButton")
fly1Button.Size = UDim2.new(0, 150, 0, 40)
fly1Button.Position = UDim2.new(0, 10, 0, 10)
fly1Button.Text = "Fly Mode 1 [F]"
fly1Button.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
fly1Button.TextColor3 = Color3.fromRGB(255, 255, 255)
fly1Button.Font = Enum.Font.SourceSansBold
fly1Button.TextSize = 20
fly1Button.BorderSizePixel = 0
fly1Button.Parent = screenGui

-- Fly Mode 2 Button
local fly2Button = Instance.new("TextButton")
fly2Button.Size = UDim2.new(0, 150, 0, 40)
fly2Button.Position = UDim2.new(0, 10, 0, 60)
fly2Button.Text = "Fly Mode 2 [R]"
fly2Button.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
fly2Button.TextColor3 = Color3.fromRGB(255, 255, 255)
fly2Button.Font = Enum.Font.SourceSansBold
fly2Button.TextSize = 20
fly2Button.BorderSizePixel = 0
fly2Button.Parent = screenGui

-- Toggle Fly Mode 1
local function toggleFly1()
	if fly2Enabled then return end
	fly1Enabled = not fly1Enabled
	fly1Button.Text = fly1Enabled and "Stop Fly 1 [F]" or "Fly Mode 1 [F]"
	fly1Button.BackgroundColor3 = fly1Enabled and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(60, 180, 75)
end

-- Toggle Fly Mode 2
local function toggleFly2()
	if fly1Enabled then return end
	fly2Enabled = not fly2Enabled
	if fly2Enabled then
		bodyVel = Instance.new("BodyVelocity")
		bodyVel.MaxForce = Vector3.new(1, 1, 1) * 1e6
		bodyVel.Velocity = Vector3.zero
		bodyVel.Parent = root
	else
		if bodyVel then bodyVel:Destroy() bodyVel = nil end
	end
	fly2Button.Text = fly2Enabled and "Stop Fly 2 [R]" or "Fly Mode 2 [R]"
	fly2Button.BackgroundColor3 = fly2Enabled and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(60, 180, 75)
end

-- Reconnect on character respawn
local function setupCharacter(newCharacter)
	character = newCharacter
	root = character:WaitForChild("HumanoidRootPart")
end
localPlayer.CharacterAdded:Connect(setupCharacter)

-- Button connections
fly1Button.MouseButton1Click:Connect(toggleFly1)
fly2Button.MouseButton1Click:Connect(toggleFly2)

-- Keybinds
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.F then toggleFly1() end
	if input.KeyCode == Enum.KeyCode.R then toggleFly2() end
end)

-- Mode 1: Move forward
RunService.RenderStepped:Connect(function(dt)
	if fly1Enabled and root then
		local direction = root.CFrame.LookVector * speed * dt
		root.CFrame = root.CFrame + direction
	end
end)

-- Mode 2: Camera directional
RunService.RenderStepped:Connect(function()
	if fly2Enabled and root and bodyVel then
		local cam = workspace.CurrentCamera
		local direction = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += cam.CFrame.UpVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction -= cam.CFrame.UpVector end

		if direction.Magnitude > 0 then
			bodyVel.Velocity = direction.Unit * speed
		else
			bodyVel.Velocity = Vector3.zero
		end
	end
end)
