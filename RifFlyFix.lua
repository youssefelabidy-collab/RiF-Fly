-- RifFlyFix.lua | إصلاح عكس اتجاه الحركة أثناء الطيران
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local function getCorrectDirection()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return Vector3.zero
	end

	-- دعم الكيبورد (PC)
	local dir = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += camera.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= camera.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= camera.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += camera.CFrame.RightVector end

	-- دعم الجوال (عصا التحكم / MoveDirection)
	if dir.Magnitude == 0 and humanoid.MoveDirection.Magnitude > 0 then
		-- تحويل MoveDirection بالنسبة لاتجاه الكاميرا الحالي بدقة
		local move = humanoid.MoveDirection
		local camLook = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
		local camRight = Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z)

		if camLook.Magnitude > 0 then camLook = camLook.Unit end
		if camRight.Magnitude > 0 then camRight = camRight.Unit end

		local forwardAmount = move:Dot(camLook)
		local rightAmount = move:Dot(camRight)

		dir = (camera.CFrame.LookVector * forwardAmount) + (camera.CFrame.RightVector * rightAmount)
	end

	return dir.Magnitude > 0 and dir.Unit or Vector3.zero
end

RunService.Heartbeat:Connect(function()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	-- البحث عن محرك الطيران النشط في الشخصية
	for _, obj in ipairs(root:GetDescendants()) do
		if obj:IsA("LinearVelocity") and obj.Enabled then
			local currentVel = obj.VectorVelocity
			local horizontalSpeed = Vector3.new(currentVel.X, 0, currentVel.Z).Magnitude
			local verticalSpeed = currentVel.Y

			if horizontalSpeed > 0.1 then
				local correctDir = getCorrectDirection()
				if correctDir.Magnitude > 0 then
					obj.VectorVelocity = Vector3.new(
						correctDir.X * horizontalSpeed,
						(correctDir.Y * horizontalSpeed) + verticalSpeed,
						correctDir.Z * horizontalSpeed
					)
				end
			end
		elseif obj:IsA("BodyVelocity") then
			local currentVel = obj.Velocity
			local horizontalSpeed = Vector3.new(currentVel.X, 0, currentVel.Z).Magnitude
			local verticalSpeed = currentVel.Y

			if horizontalSpeed > 0.1 then
				local correctDir = getCorrectDirection()
				if correctDir.Magnitude > 0 then
					obj.Velocity = Vector3.new(
						correctDir.X * horizontalSpeed,
						(correctDir.Y * horizontalSpeed) + verticalSpeed,
						correctDir.Z * horizontalSpeed
					)
				end
			end
		end
	end
end)
