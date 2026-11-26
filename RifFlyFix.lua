local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local function getFixedDirection()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return Vector3.zero
	end

	local cam = workspace.CurrentCamera
	if not cam then
		return Vector3.zero
	end

	local camLook = cam.CFrame.LookVector
	local camRight = cam.CFrame.RightVector

	local flatLook = Vector3.new(camLook.X, 0, camLook.Z)
	if flatLook.Magnitude > 0 then
		flatLook = flatLook.Unit
	end

	local flatRight = Vector3.new(camRight.X, 0, camRight.Z)
	if flatRight.Magnitude > 0 then
		flatRight = flatRight.Unit
	end

	-- أولوية للكيبورد إذا كان مضغوطاً
	local keyVec = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then
		keyVec += flatLook
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then
		keyVec -= flatLook
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then
		keyVec += flatRight
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then
		keyVec -= flatRight
	end

	if keyVec.Magnitude > 0 then
		return keyVec.Unit
	end

	-- تحويل MoveDirection (الجويستيك / الحركة) بالنسبة لاتجاه الكاميرا
	local moveDir = humanoid.MoveDirection
	if moveDir.Magnitude > 0 then
		local forwardAmount = moveDir:Dot(flatLook)
		local rightAmount = moveDir:Dot(flatRight)
		local fixedVec = (flatLook * forwardAmount) + (flatRight * rightAmount)
		if fixedVec.Magnitude > 0 then
			return fixedVec.Unit
		end
	end

	return Vector3.zero
end

RunService.RenderStepped:Connect(function()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid then
		return
	end

	local fixedDir = getFixedDirection()

	for _, obj in ipairs(root:GetDescendants()) do
		if obj:IsA("LinearVelocity") and obj.Enabled then
			local currentVel = obj.VectorVelocity
			local horizSpeed = Vector3.new(currentVel.X, 0, currentVel.Z).Magnitude
			local vertSpeed = currentVel.Y

			if horizSpeed > 0.1 and fixedDir.Magnitude > 0 then
				obj.VectorVelocity = Vector3.new(
					fixedDir.X * horizSpeed,
					vertSpeed,
					fixedDir.Z * horizSpeed
				)
			end
		elseif obj:IsA("BodyVelocity") then
			local currentVel = obj.Velocity
			local horizSpeed = Vector3.new(currentVel.X, 0, currentVel.Z).Magnitude
			local vertSpeed = currentVel.Y

			if horizSpeed > 0.1 and fixedDir.Magnitude > 0 then
				obj.Velocity = Vector3.new(
					fixedDir.X * horizSpeed,
					vertSpeed,
					fixedDir.Z * horizSpeed
				)
			end
		end
	end
end)
