--[[

	Aimbot Module [westbound.pro] by Exunys © CC0 1.0 Universal (2023)

	https://github.com/Exunys

]]

--// Cache

local pcall, getgenv, next, setmetatable, Vector2new, CFramenew, Color3fromRGB, mousemoverel = pcall, getgenv, next, setmetatable, Vector2.new, CFrame.new, Color3.fromRGB, mousemoverel or (Input and Input.MouseMove)

--// Launching checks

if not getgenv().AirTeam_westboundpro or getgenv().AirTeam_westboundpro.Aimbot then return end

--// Services

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Variables

local RequiredDistance, Typing, Running, ServiceConnections, Parts, Animation, OriginalSensitivity = 2000, false, false, {}, {"Head", "HumanoidRootPart", "LeftHand", "RightHand", "LeftLowerArm", "RightLowerArm", "LeftUpperArm", "RightUpperArm", "LeftFoot", "LeftLowerLeg", "UpperTorso", "LeftUpperLeg", "RightFoot", "RightLowerLeg", "LowerTorso", "RightUpperLeg", "Random"}

--// Environment

getgenv().AirTeam_westboundpro.Aimbot = {
	Settings = {
		Enabled = false,
		WallCheck = false,
		Sensitivity = 0, -- Animation length (in seconds) before fully locking onto target
		ThirdPerson = false, -- Uses mousemoverel instead of CFrame to support locking in third person (could be choppy)
		ThirdPersonSensitivity = 3,
		TriggerKey = "MouseButton2",
		Toggle = false,
	},

	FOVSettings = {
		Color = Color3fromRGB(255, 255, 255),
		LockedColor = Color3fromRGB(255, 70, 70),
		Transparency = 0.5,
		Sides = 60,
		Thickness = 1,
		Filled = false
	}
}

local FOVCircle = Drawing.new("Circle")
local ParentEnvironment, Environment = getgenv().AirTeam_westboundpro.Settings, getgenv().AirTeam_westboundpro.Aimbot

--// Core Functions

local function ConvertVector(Vector)
	return Vector2new(Vector.X, Vector.Y)
end

local function CancelLock()
	getgenv().AirTeam_westboundpro.Aimbot.Locked = nil
	if Animation then Animation:Cancel() end
	FOVCircle.Color = getgenv().AirTeam_westboundpro.Aimbot.FOVSettings.Color
	UserInputService.MouseDeltaSensitivity = OriginalSensitivity
end

local function GetClosestPlayer()
	local HitPart = Parentgetgenv().AirTeam_westboundpro.Aimbot.HitPart == "Random" and Parts[math.random(1, #Parts - 1)] or Parentgetgenv().AirTeam_westboundpro.Aimbot.HitPart

	if not getgenv().AirTeam_westboundpro.Aimbot.Locked then
		RequiredDistance = (Parentgetgenv().AirTeam_westboundpro.Aimbot.FOV.Enabled and Parentgetgenv().AirTeam_westboundpro.Aimbot.FOV.Amount or 2000)

		for _, v in next, Players:GetPlayers() do
			if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Parentgetgenv().AirTeam_westboundpro.Aimbot.HitPart) and v.Character:FindFirstChildOfClass("Humanoid") then
				if LocalPlayer.Team == game.Teams.Cowboys and v.TeamColor == LocalPlayer.TeamColor then continue end
				if v.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then continue end
				if getgenv().AirTeam_westboundpro.Aimbot.Settings.WallCheck and #(Camera:GetPartsObscuringTarget({v.Character[HitPart].Position}, v.Character:GetDescendants())) > 0 then continue end

				local Vector, OnScreen = Camera:WorldToViewportPoint(v.Character[HitPart].Position); Vector = ConvertVector(Vector)
				local Distance = (UserInputService:GetMouseLocation() - Vector).Magnitude

				if Distance < RequiredDistance and OnScreen then
					RequiredDistance = Distance
					getgenv().AirTeam_westboundpro.Aimbot.Locked = v
				end
			end
		end
	elseif (UserInputService:GetMouseLocation() - ConvertVector(Camera:WorldToViewportPoint(getgenv().AirTeam_westboundpro.Aimbot.Locked.Character[Parentgetgenv().AirTeam_westboundpro.Aimbot.HitPart].Position))).Magnitude > RequiredDistance then
		CancelLock()
	end
end

local function Load()
	OriginalSensitivity = UserInputService.MouseDeltaSensitivity

	ServiceConnections.RenderSteppedConnection = RunService.RenderStepped:Connect(function()
		if Parentgetgenv().AirTeam_westboundpro.Aimbot.FOV.Enabled then
			FOVCircle.Radius = Parentgetgenv().AirTeam_westboundpro.Aimbot.FOV.Amount
			FOVCircle.Thickness = getgenv().AirTeam_westboundpro.Aimbot.FOVSettings.Thickness
			FOVCircle.Filled = getgenv().AirTeam_westboundpro.Aimbot.FOVSettings.Filled
			FOVCircle.NumSides = getgenv().AirTeam_westboundpro.Aimbot.FOVSettings.Sides
			FOVCircle.Color = getgenv().AirTeam_westboundpro.Aimbot.FOVSettings.Color
			FOVCircle.Transparency = getgenv().AirTeam_westboundpro.Aimbot.FOVSettings.Transparency
			FOVCircle.Visible = Parentgetgenv().AirTeam_westboundpro.Aimbot.FOV.Enabled
			FOVCircle.Position = Vector2new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
		else
			FOVCircle.Visible = false
		end

		if Running and getgenv().AirTeam_westboundpro.Aimbot.Settings.Enabled then
			GetClosestPlayer()

			if getgenv().AirTeam_westboundpro.Aimbot.Locked then
				if getgenv().AirTeam_westboundpro.Aimbot.Settings.ThirdPerson then
					local Vector = Camera:WorldToViewportPoint(getgenv().AirTeam_westboundpro.Aimbot.Locked.Character[Parentgetgenv().AirTeam_westboundpro.Aimbot.HitPart].Position)

					mousemoverel((Vector.X - UserInputService:GetMouseLocation().X) * getgenv().AirTeam_westboundpro.Aimbot.Settings.ThirdPersonSensitivity, (Vector.Y - UserInputService:GetMouseLocation().Y) * getgenv().AirTeam_westboundpro.Aimbot.Settings.ThirdPersonSensitivity)
				else
					if getgenv().AirTeam_westboundpro.Aimbot.Settings.Sensitivity > 0 then
						Animation = TweenService:Create(Camera, TweenInfo.new(getgenv().AirTeam_westboundpro.Aimbot.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFramenew(Camera.CFrame.Position, getgenv().AirTeam_westboundpro.Aimbot.Locked.Character[getgenv().AirTeam_westboundpro.Aimbot.Settings.LockPart].Position)})
						Animation:Play()
					else
						Camera.CFrame = CFramenew(Camera.CFrame.Position, getgenv().AirTeam_westboundpro.Aimbot.Locked.Character[Parentgetgenv().AirTeam_westboundpro.Aimbot.HitPart].Position)
					end

					UserInputService.MouseDeltaSensitivity = 0
				end

				FOVCircle.Color = getgenv().AirTeam_westboundpro.Aimbot.FOVSettings.LockedColor
			end
		end
	end)

	ServiceConnections.InputBeganConnection = UserInputService.InputBegan:Connect(function(Input)
		if not Typing then
			pcall(function()
				if Input.KeyCode == Enum.KeyCode[getgenv().AirTeam_westboundpro.Aimbot.Settings.TriggerKey] then
					if getgenv().AirTeam_westboundpro.Aimbot.Settings.Toggle then
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
				if Input.UserInputType == Enum.UserInputType[getgenv().AirTeam_westboundpro.Aimbot.Settings.TriggerKey] then
					if getgenv().AirTeam_westboundpro.Aimbot.Settings.Toggle then
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

	ServiceConnections.InputEndedConnection = UserInputService.InputEnded:Connect(function(Input)
		if not Typing then
			if not getgenv().AirTeam_westboundpro.Aimbot.Settings.Toggle then
				pcall(function()
					if Input.KeyCode == Enum.KeyCode[getgenv().AirTeam_westboundpro.Aimbot.Settings.TriggerKey] then
						Running = false; CancelLock()
					end
				end)

				pcall(function()
					if Input.UserInputType == Enum.UserInputType[getgenv().AirTeam_westboundpro.Aimbot.Settings.TriggerKey] then
						Running = false; CancelLock()
					end
				end)
			end
		end
	end)
end

--// Typing Check

ServiceConnections.TypingStartedConnection = UserInputService.TextBoxFocused:Connect(function()
	Typing = true
end)

ServiceConnections.TypingEndedConnection = UserInputService.TextBoxFocusReleased:Connect(function()
	Typing = false
end)

--// Load

Load()
