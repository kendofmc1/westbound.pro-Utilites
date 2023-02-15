--[[

	Aimbot Module [westbound.pro] by Exunys © CC0 1.0 Universal (2023)
	https://github.com/Exunys

]]

--// Cache

local pcall, getgenv, next, Vector2new, CFramenew, mousemoverel = pcall, getgenv, next, Vector2.new, CFrame.new, mousemoverel or (Input and Input.MouseMove)

--// Launching checks

if not getgenv().AirTeam_westboundpro or not GetEnv() then return end

--// Services

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Variables

local RequiredDistance, Typing, Running, Parts, Animation, OriginalSensitivity = 2000, false, false

--// Environment

local FOVCircle = Drawing.new("Circle")

--// Core Functions

local function GetEnv()
    return getgenv().AirTeam_westboundpro.Aimbot
end

local function GetParentEnv()
    return getgenv().AirTeam_westboundpro.Settings
end

local function ConvertVector(Vector)
	return Vector2new(Vector.X, Vector.Y)
end

local function CancelLock()
	GetEnv().Locked = nil
	if Animation then Animation:Cancel() end
	FOVCircle.Color = GetEnv().FOVSettings.Color
	UserInputService.MouseDeltaSensitivity = OriginalSensitivity
end

local function GetClosestPlayer()
	local HitPart = GetParentEnv().HitPart == "Random" and Parts[math.random(1, #Parts - 1)] or GetParentEnv().HitPart

	if not GetEnv().Locked then
		RequiredDistance = (GetParentEnv().FOV.Enabled and GetParentEnv().FOV.Amount or 2000)

		for _, v in next, Players:GetPlayers() do
			if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(GetParentEnv().HitPart) and v.Character:FindFirstChildOfClass("Humanoid") then
				if LocalPlayer.Team == game.Teams.Cowboys and v.TeamColor == LocalPlayer.TeamColor then continue end
				if v.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then continue end
				if GetEnv().Settings.WallCheck and #(Camera:GetPartsObscuringTarget({v.Character[HitPart].Position}, v.Character:GetDescendants())) > 0 then continue end

				local Vector, OnScreen = Camera:WorldToViewportPoint(v.Character[HitPart].Position); Vector = ConvertVector(Vector)
				local Distance = (UserInputService:GetMouseLocation() - Vector).Magnitude

				if Distance < RequiredDistance and OnScreen then
					RequiredDistance = Distance
					GetEnv().Locked = v
				end
			end
		end
	elseif (UserInputService:GetMouseLocation() - ConvertVector(Camera:WorldToViewportPoint(GetEnv().Locked.Character[GetParentEnv().HitPart].Position))).Magnitude > RequiredDistance then
		CancelLock()
	end
end

local function Load()
	OriginalSensitivity = UserInputService.MouseDeltaSensitivity

	RunService.RenderStepped:Connect(function()
		if GetParentEnv().FOV.Enabled then
			FOVCircle.Radius = GetParentEnv().FOV.Amount
			FOVCircle.Thickness = GetEnv().FOVSettings.Thickness
			FOVCircle.Filled = GetEnv().FOVSettings.Filled
			FOVCircle.NumSides = GetEnv().FOVSettings.Sides
			FOVCircle.Color = GetEnv().FOVSettings.Color
			FOVCircle.Transparency = GetEnv().FOVSettings.Transparency
			FOVCircle.Visible = GetParentEnv().FOV.Enabled
			FOVCircle.Position = Vector2new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
		else
			FOVCircle.Visible = false
		end

		if Running and GetEnv().Settings.Enabled then
			GetClosestPlayer()

			if GetEnv().Locked then
				if GetEnv().Settings.ThirdPerson then
					local Vector = Camera:WorldToViewportPoint(GetEnv().Locked.Character[GetParentEnv().HitPart].Position)

					mousemoverel((Vector.X - UserInputService:GetMouseLocation().X) * GetEnv().Settings.ThirdPersonSensitivity, (Vector.Y - UserInputService:GetMouseLocation().Y) * GetEnv().Settings.ThirdPersonSensitivity)
				else
					if GetEnv().Settings.Sensitivity > 0 then
						Animation = TweenService:Create(Camera, TweenInfo.new(GetEnv().Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFramenew(Camera.CFrame.Position, GetEnv().Locked.Character[GetEnv().Settings.LockPart].Position)})
						Animation:Play()
					else
						Camera.CFrame = CFramenew(Camera.CFrame.Position, GetEnv().Locked.Character[GetParentEnv().HitPart].Position)
					end

					UserInputService.MouseDeltaSensitivity = 0
				end

				FOVCircle.Color = GetEnv().FOVSettings.LockedColor
			end
		end
	end)

	UserInputService.InputBegan:Connect(function(Input)
		if not Typing then
			pcall(function()
				if Input.KeyCode == Enum.KeyCode[GetEnv().Settings.TriggerKey] then
					if GetEnv().Settings.Toggle then
						Running = not Running

						if not Running then
							CancelLock()
						end
					else
						Running = true
					end
				end
			end)

			pcall(function()
				if Input.UserInputType == Enum.UserInputType[GetEnv().Settings.TriggerKey] then
					if GetEnv().Settings.Toggle then
						Running = not Running

						if not Running then
							CancelLock()
						end
					else
						Running = true
					end
				end
			end)
		end
	end)

	UserInputService.InputEnded:Connect(function(Input)
		if not Typing then
			if not GetEnv().Settings.Toggle then
				pcall(function()
					if Input.KeyCode == Enum.KeyCode[GetEnv().Settings.TriggerKey] then
						Running = false; CancelLock()
					end
				end)

				pcall(function()
					if Input.UserInputType == Enum.UserInputType[GetEnv().Settings.TriggerKey] then
						Running = false; CancelLock()
					end
				end)
			end
		end
	end)
end

--// Typing Check

UserInputService.TextBoxFocused:Connect(function()
	Typing = true
end)

UserInputService.TextBoxFocusReleased:Connect(function()
	Typing = false
end)

--// Load

Load()
