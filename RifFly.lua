local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("RifFlyGui")
if oldGui then
	oldGui:Destroy()
end

local flying = false
local flySpeed = 50
local verticalSpeed = 35
local minimized = false
local moveUp = false
local moveDown = false

local renderConn
local lv, ao, attachment

local function stopFly()
	flying = false
	moveUp = false
	moveDown = false

	if renderConn then
		renderConn:Disconnect()
		renderConn = nil
	end
	if lv then lv:Destroy() lv = nil end
	if ao then ao:Destroy() ao = nil end
	if attachment then attachment:Destroy() attachment = nil end

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.PlatformStand = false
	end
end

local function startFly()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid then return end

	stopFly()
	flying = true
	humanoid.PlatformStand = true

	attachment = Instance.new("Attachment")
	attachment.Parent = root

	lv = Instance.new("LinearVelocity")
	lv.Attachment0 = attachment
	lv.MaxForce = math.huge
	lv.VectorVelocity = Vector3.zero
	lv.Parent = root

	ao = Instance.new("AlignOrientation")
	ao.Attachment0 = attachment
	ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
	ao.MaxTorque = math.huge
	ao.Responsiveness = 20
	ao.Parent = root

	renderConn = RunService.RenderStepped:Connect(function()
		local camera = workspace.CurrentCamera
		if not flying or not root.Parent or not camera then
			stopFly()
			return
		end

		local moveDir = humanoid.MoveDirection
		local camLook = camera.CFrame.LookVector
		local rightVec = camera.CFrame.RightVector

		local horizontalVel = Vector3.zero
		if moveDir.Magnitude > 0 then
			local flatLook = Vector3.new(camLook.X, 0, camLook.Z)
			if flatLook.Magnitude > 0 then
				flatLook = flatLook.Unit
			end

			local flatRight = Vector3.new(rightVec.X, 0, rightVec.Z)
			if flatRight.Magnitude > 0 then
				flatRight = flatRight.Unit
			end

			local forwardAmount = moveDir:Dot(flatLook)
			local rightAmount = moveDir:Dot(flatRight)

			local inputVec = (flatLook * forwardAmount) + (flatRight * rightAmount)
			if inputVec.Magnitude > 0 then
				horizontalVel = inputVec.Unit * flySpeed
			end
		end

		local verticalVel = 0
		if moveUp then
			verticalVel += verticalSpeed
		end
		if moveDown then
			verticalVel -= verticalSpeed
		end

		lv.VectorVelocity = horizontalVel + Vector3.new(0, verticalVel, 0)
		ao.CFrame = CFrame.lookAt(root.Position, root.Position + camLook)
	end)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RifFlyGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainPanel"
mainFrame.Size = UDim2.new(0, 215, 0, 122)
mainFrame.Position = UDim2.new(0.5, -107, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 16, 26)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(37, 99, 235)
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 0, 28)
titleLabel.Position = UDim2.new(0, 10, 0, 4)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Rif Fly"
titleLabel.TextColor3 = Color3.fromRGB(96, 165, 250)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 15
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

local miniBtn = Instance.new("TextButton")
miniBtn.Size = UDim2.new(0, 24, 0, 24)
miniBtn.Position = UDim2.new(1, -32, 0, 6)
miniBtn.BackgroundColor3 = Color3.fromRGB(29, 78, 216)
miniBtn.Text = "-"
miniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
miniBtn.Font = Enum.Font.GothamBold
miniBtn.TextSize = 16
miniBtn.Parent = mainFrame

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(0, 6)
miniCorner.Parent = miniBtn

local controlsFrame = Instance.new("Frame")
controlsFrame.Size = UDim2.new(1, -16, 1, -38)
controlsFrame.Position = UDim2.new(0, 8, 0, 34)
controlsFrame.BackgroundTransparency = 1
controlsFrame.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.48, 0, 0, 32)
toggleBtn.Position = UDim2.new(0, 0, 0, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(23, 37, 84)
toggleBtn.Text = "Fly: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(226, 232, 240)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 12
toggleBtn.Parent = controlsFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 7)
toggleCorner.Parent = toggleBtn

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.48, 0, 0, 16)
speedLabel.Position = UDim2.new(0.52, 0, 0, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: " .. flySpeed
speedLabel.TextColor3 = Color3.fromRGB(147, 197, 253)
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 11
speedLabel.Parent = controlsFrame

local speedMinusBtn = Instance.new("TextButton")
speedMinusBtn.Size = UDim2.new(0.22, 0, 0, 16)
speedMinusBtn.Position = UDim2.new(0.52, 0, 0, 16)
speedMinusBtn.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
speedMinusBtn.Text = "-"
speedMinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedMinusBtn.Font = Enum.Font.GothamBold
speedMinusBtn.TextSize = 12
speedMinusBtn.Parent = controlsFrame

local speedMinusCorner = Instance.new("UICorner")
speedMinusCorner.CornerRadius = UDim.new(0, 5)
speedMinusCorner.Parent = speedMinusBtn

local speedPlusBtn = Instance.new("TextButton")
speedPlusBtn.Size = UDim2.new(0.22, 0, 0, 16)
speedPlusBtn.Position = UDim2.new(0.78, 0, 0, 16)
speedPlusBtn.BackgroundColor3 = Color3.fromRGB(29, 78, 216)
speedPlusBtn.Text = "+"
speedPlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedPlusBtn.Font = Enum.Font.GothamBold
speedPlusBtn.TextSize = 12
speedPlusBtn.Parent = controlsFrame

local speedPlusCorner = Instance.new("UICorner")
speedPlusCorner.CornerRadius = UDim.new(0, 5)
speedPlusCorner.Parent = speedPlusBtn

local upBtn = Instance.new("TextButton")
upBtn.Size = UDim2.new(0.48, 0, 0, 30)
upBtn.Position = UDim2.new(0, 0, 0, 38)
upBtn.BackgroundColor3 = Color3.fromRGB(30, 58, 138)
upBtn.Text = "Up ▲"
upBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
upBtn.Font = Enum.Font.GothamBold
upBtn.TextSize = 12
upBtn.Parent = controlsFrame

local upCorner = Instance.new("UICorner")
upCorner.CornerRadius = UDim.new(0, 7)
upCorner.Parent = upBtn

local downBtn = Instance.new("TextButton")
downBtn.Size = UDim2.new(0.48, 0, 0, 30)
downBtn.Position = UDim2.new(0.52, 0, 0, 38)
downBtn.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
downBtn.Text = "Down ▼"
downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
downBtn.Font = Enum.Font.GothamBold
downBtn.TextSize = 12
downBtn.Parent = controlsFrame

local downCorner = Instance.new("UICorner")
downCorner.CornerRadius = UDim.new(0, 7)
downCorner.Parent = downBtn

local circleBtn = Instance.new("TextButton")
circleBtn.Name = "RifFlyCircle"
circleBtn.Size = UDim2.new(0, 68, 0, 68)
circleBtn.Position = mainFrame.Position
circleBtn.BackgroundColor3 = Color3.fromRGB(12, 16, 26)
circleBtn.Text = "Rif Fly"
circleBtn.TextColor3 = Color3.fromRGB(96, 165, 250)
circleBtn.Font = Enum.Font.GothamBold
circleBtn.TextSize = 13
circleBtn.TextWrapped = true
circleBtn.Visible = false
circleBtn.Active = true
circleBtn.Draggable = true
circleBtn.Parent = screenGui

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = circleBtn

local circleStroke = Instance.new("UIStroke")
circleStroke.Color = Color3.fromRGB(37, 99, 235)
circleStroke.Thickness = 2.5
circleStroke.Parent = circleBtn

local function refreshFlyVisual()
	if flying then
		toggleBtn.Text = "Fly: ON"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
		circleStroke.Color = Color3.fromRGB(59, 130, 246)
	else
		toggleBtn.Text = "Fly: OFF"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(23, 37, 84)
		circleStroke.Color = Color3.fromRGB(37, 99, 235)
	end
end

miniBtn.MouseButton1Click:Connect(function()
	minimized = true
	circleBtn.Position = mainFrame.Position
	mainFrame.Visible = false
	circleBtn.Visible = true
end)

circleBtn.MouseButton1Click:Connect(function()
	if minimized then
		minimized = false
		mainFrame.Position = circleBtn.Position
		circleBtn.Visible = false
		mainFrame.Visible = true
	end
end)

toggleBtn.MouseButton1Click:Connect(function()
	if flying then
		stopFly()
	else
		startFly()
	end
	refreshFlyVisual()
end)

speedPlusBtn.MouseButton1Click:Connect(function()
	flySpeed = math.min(flySpeed + 10, 300)
	speedLabel.Text = "Speed: " .. flySpeed
end)

speedMinusBtn.MouseButton1Click:Connect(function()
	flySpeed = math.max(flySpeed - 10, 10)
	speedLabel.Text = "Speed: " .. flySpeed
end)

upBtn.MouseButton1Down:Connect(function()
	moveUp = true
end)
upBtn.MouseButton1Up:Connect(function()
	moveUp = false
end)
upBtn.MouseLeave:Connect(function()
	moveUp = false
end)

downBtn.MouseButton1Down:Connect(function()
	moveDown = true
end)
downBtn.MouseButton1Up:Connect(function()
	moveDown = false
end)
downBtn.MouseLeave:Connect(function()
	moveDown = false
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not flying then return end
	if input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.Space then
		moveUp = true
	elseif input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.LeftControl then
		moveDown = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.Space then
		moveUp = false
	elseif input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.LeftControl then
		moveDown = false
	end
end)

player.CharacterAdded:Connect(function()
	stopFly()
	refreshFlyVisual()
end)
