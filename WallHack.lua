--[[

	Wall Hack Module [westbound.pro] by Exunys © CC0 1.0 Universal (2023)
	https://github.com/Exunys

]]

--// Cache

local select, next, tostring, pcall, getgenv, setmetatable, mathfloor, mathabs, stringgsub, stringmatch, wait = select, next, tostring, pcall, getgenv, setmetatable, math.floor, math.abs, string.gsub, string.match, task.wait
local Vector2new, Vector3new, CFramenew, Drawingnew, Color3fromRGB, WorldToViewportPoint = Vector2.new, Vector3.new, CFrame.new, Drawing.new, Color3.fromRGB

--// Launching checks

if not getgenv().AirTeam_westboundpro or getgenv().AirTeam_westboundpro.WallHack then return end

--// Services

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Variables

local ServiceConnections = {}

--// Environment

getgenv().AirTeam_westboundpro.WallHack = {
	Settings = {
		Enabled = false,
		TeamCheck = false,
		AliveCheck = true,
		Animals = false
	},

	Visuals = {
		ESPSettings = {
			Enabled = true,
			TextColor = Color3fromRGB(255, 255, 255),
			TextSize = 14,
			Outline = true,
			OutlineColor = Color3fromRGB(0, 0, 0),
			TextTransparency = 0.7,
			TextFont = Drawing.Fonts.UI, -- UI, System, Plex, Monospace
			DisplayDistance = true,
			DisplayHealth = true,
			DisplayName = true
		},

		TracersSettings = {
			Enabled = true,
			Type = 1, -- 1 - Bottom; 2 - Center; 3 - Mouse
			Transparency = 0.7,
			Thickness = 1,
			Color = Color3fromRGB(255, 255, 255)
		},

		BoxSettings = {
			Enabled = true,
			Type = 1; -- 1 - 3D; 2 - 2D;
			Color = Color3fromRGB(255, 255, 255),
			Transparency = 0.7,
			Thickness = 1,
			Filled = false, -- For 2D
			Increase = 1
		},

		HeadDotSettings = {
			Enabled = true,
			Color = Color3fromRGB(255, 255, 255),
			Transparency = 0.5,
			Thickness = 1,
			Filled = true,
			Sides = 30
		}
	},

	Crosshair = {
		Settings = {
			Enabled = false,
			Type = 1, -- 1 - Mouse; 2 - Center
			Size = 12,
			Thickness = 1,
			Color = Color3fromRGB(0, 255, 0),
			Transparency = 1,
			GapSize = 5,
			CenterDot = false,
			CenterDotColor = Color3fromRGB(0, 255, 0),
			CenterDotSize = 1,
			CenterDotTransparency = 1,
			CenterDotFilled = true,
			CenterDotThickness = 1
		},
	}
}

local CrosshairParts, WrappedPlayers = {
	LeftLine = Drawingnew("Line"),
	RightLine = Drawingnew("Line"),
	TopLine = Drawingnew("Line"),
	BottomLine = Drawingnew("Line"),
	CenterDot = Drawingnew("Circle")
}, {}

local Environment = getgenv().AirTeam_westboundpro.WallHack

--// Core Functions

WorldToViewportPoint = function(...)
	return Camera.WorldToViewportPoint(Camera, ...)
end

local function GetPlayerTable(Player)
	for _, v in next, WrappedPlayers do
		if v.Name == Player.Name then
			return v
		end
	end
end

local function AssignRigType(Player)
	local PlayerTable = GetPlayerTable(Player)

	repeat wait(0) until Player.Character

	if Player.Character:FindFirstChild("Torso") and not Player.Character:FindFirstChild("LowerTorso") then
		PlayerTable.RigType = "R6"
	elseif Player.Character:FindFirstChild("LowerTorso") and not Player.Character:FindFirstChild("Torso") then
		PlayerTable.RigType = "R15"
	else
		repeat AssignRigType(Player) until PlayerTable.RigType
	end
end

local function InitChecks(Player)
	local PlayerTable = GetPlayerTable(Player)

	PlayerTable.Connections.UpdateChecks = RunService.RenderStepped:Connect(function()
		if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
			if getgenv().AirTeam_westboundpro.WallHack.Settings.AliveCheck then
				PlayerTable.Checks.Alive = Player.Character:FindFirstChildOfClass("Humanoid").Health > 0
			else
				PlayerTable.Checks.Alive = true
			end

			if getgenv().AirTeam_westboundpro.WallHack.Settings.TeamCheck then
				PlayerTable.Checks.Team = Player.TeamColor ~= LocalPlayer.TeamColor
			else
				PlayerTable.Checks.Team = true
			end
		else
			PlayerTable.Checks.Alive = false
			PlayerTable.Checks.Team = false
		end
	end)
end

--// Visuals

local Visuals = {
	AddESP_Animal = function(Animal)
		local AnimalTable = {
			Name = Animal.Name,
			ESP = Drawingnew("Text"),
			Connections = {}
		}

		AnimalTable.Connections.ESP = RunService.RenderStepped:Connect(function()
			if workspace.Animals:FindFirstChild(AnimalTable.Name) and Animal:FindFirstChildOfClass("Humanoid") and Animal:FindFirstChild("HumanoidRootPart") and Animal:FindFirstChild("Head") and getgenv().AirTeam_westboundpro.WallHack.Settings.Enabled and getgenv().AirTeam_westboundpro.WallHack.Settings.Animals then
				local Vector, OnScreen = WorldToViewportPoint(Animal.Head.Position)

				if OnScreen then
					AnimalTable.ESP.Visible = getgenv().AirTeam_westboundpro.WallHack.Settings.Animals

					if AnimalTable.ESP.Visible then
						AnimalTable.ESP.Center = true
						AnimalTable.ESP.Size = getgenv().AirTeam_westboundpro.WallHack.Visuals.ESPSettings.TextSize
						AnimalTable.ESP.Outline = getgenv().AirTeam_westboundpro.WallHack.Visuals.ESPSettings.Outline
						AnimalTable.ESP.OutlineColor = getgenv().AirTeam_westboundpro.WallHack.Visuals.ESPSettings.OutlineColor
						AnimalTable.ESP.Color = getgenv().AirTeam_westboundpro.WallHack.Visuals.ESPSettings.TextColor
						AnimalTable.ESP.Transparency = getgenv().AirTeam_westboundpro.WallHack.Visuals.ESPSettings.TextTransparency
						AnimalTable.ESP.Font = getgenv().AirTeam_westboundpro.WallHack.Visuals.ESPSettings.TextFont

						AnimalTable.ESP.Position = Vector2new(Vector.X, Vector.Y - 25)

						local Parts, Content = {
							Health = "("..tostring(mathfloor(Animal.Humanoid.Health))..")",
							Distance = "["..tostring(mathfloor(((Animal.HumanoidRootPart.Position or Vector3new(0, 0, 0)) - (LocalPlayer.Character.HumanoidRootPart.Position or Vector3new(0, 0, 0))).Magnitude)).."]",
							Name = stringgsub(stringmatch(Animal.Name, "(.+){"), "(%l)(%u)", function(...)
								return select(1, ...).." "..select(2, ...)
							end)
						}, ""

						if getgenv().AirTeam_westboundpro.WallHack.Visuals.ESPSettings.DisplayName then
							Content = Parts.Name..Content
						end

						if getgenv().AirTeam_westboundpro.WallHack.Visuals.ESPSettings.DisplayHealth then
							Content = Parts.Health..(getgenv().AirTeam_westboundpro.WallHack.Visuals.ESPSettings.DisplayName and " " or "")..Content
						end

						if getgenv().AirTeam_westboundpro.WallHack.Visuals.ESPSettings.DisplayDistance then
							Content = Content.." "..Parts.Distance
						end

						AnimalTable.ESP.Text = Content
					end
				else
					AnimalTable.ESP.Visible = false
				end
			else
				AnimalTable.ESP.Visible = false
			end

			if not workspace.Animals:FindFirstChild(AnimalTable.Name) then
				AnimalTable.Connections.ESP:Disconnect()
				AnimalTable.ESP:Remove()
			end
		end)
	end,

	AddESP = function(Player)
		local PlayerTable = GetPlayerTable(Player)

		PlayerTable.ESP = Drawingnew("Text")

		PlayerTable.Connections.ESP = RunService.RenderStepped:Connect(function()
			if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChild("Head") and getgenv().AirTeam_westboundpro.WallHack.Settings.Enabled then
				local Vector, OnScreen = WorldToViewportPoint(Player.Character.Head.Position)

				PlayerTable.ESP.Visible = getgenv().AirTeam_westboundpro.WallHack.Visuals.ESPSettings.Enabled

				if OnScreen and getgenv().AirTeam_westboundpro.WallHack.Visuals.ESPSettings.Enabled then
					PlayerTable.ESP.Visible = PlayerTable.Checks.Alive and PlayerTable.Checks.Team and true or false

					if PlayerTable.ESP.Visible then
						PlayerTable.ESP.Center = true
						PlayerTable.ESP.Size = getgenv().AirTeam_westboundpro.WallHack.Visuals.ESPSettings.TextSize
						PlayerTable.ESP.Outline = getgenv().AirTeam_westboundpro.WallHack.Visuals.ESPSettings.Outline
						PlayerTable.ESP.OutlineColor = getgenv().AirTeam_westboundpro.WallHack.Visuals.ESPSettings.OutlineColor
						PlayerTable.ESP.Color = getgenv().AirTeam_westboundpro.WallHack.Visuals.ESPSettings.TextColor
						PlayerTable.ESP.Transparency = getgenv().AirTeam_westboundpro.WallHack.Visuals.ESPSettings.TextTransparency
						PlayerTable.ESP.Font = getgenv().AirTeam_westboundpro.WallHack.Visuals.ESPSettings.TextFont

						PlayerTable.ESP.Position = Vector2new(Vector.X, Vector.Y - 25)

						local Parts, Content = {
							Health = "("..tostring(mathfloor(Player.Character.Humanoid.Health))..")",
							Distance = "["..tostring(mathfloor(((Player.Character.HumanoidRootPart.Position or Vector3new(0, 0, 0)) - (LocalPlayer.Character.HumanoidRootPart.Position or Vector3new(0, 0, 0))).Magnitude)).."]",
							Name = Player.DisplayName == Player.Name and Player.Name or Player.DisplayName.." {"..Player.Name.."}"
						}, ""

						if getgenv().AirTeam_westboundpro.WallHack.Visuals.ESPSettings.DisplayName then
							Content = Parts.Name..Content
						end

						if getgenv().AirTeam_westboundpro.WallHack.Visuals.ESPSettings.DisplayHealth then
							Content = Parts.Health..(getgenv().AirTeam_westboundpro.WallHack.Visuals.ESPSettings.DisplayName and " " or "")..Content
						end

						if getgenv().AirTeam_westboundpro.WallHack.Visuals.ESPSettings.DisplayDistance then
							Content = Content.." "..Parts.Distance
						end

						PlayerTable.ESP.Text = Content
					end
				else
					PlayerTable.ESP.Visible = false
				end
			else
				PlayerTable.ESP.Visible = false
			end
		end)
	end,

	AddTracer = function(Player)
		local PlayerTable = GetPlayerTable(Player)

		PlayerTable.Tracer = Drawingnew("Line")

		PlayerTable.Connections.Tracer = RunService.RenderStepped:Connect(function()
			if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") and Player.Character:FindFirstChild("HumanoidRootPart") and getgenv().AirTeam_westboundpro.WallHack.Settings.Enabled then
				local HRPCFrame, HRPSize = Player.Character.HumanoidRootPart.CFrame, Player.Character.HumanoidRootPart.Size
				local Vector, OnScreen = WorldToViewportPoint(HRPCFrame * CFramenew(0, -HRPSize.Y, 0).Position)

				if OnScreen and getgenv().AirTeam_westboundpro.WallHack.Visuals.TracersSettings.Enabled then
					if getgenv().AirTeam_westboundpro.WallHack.Visuals.TracersSettings.Enabled then
						PlayerTable.Tracer.Visible = PlayerTable.Checks.Alive and PlayerTable.Checks.Team and true or false

						if PlayerTable.Tracer.Visible then
							PlayerTable.Tracer.Thickness = getgenv().AirTeam_westboundpro.WallHack.Visuals.TracersSettings.Thickness
							PlayerTable.Tracer.Color = getgenv().AirTeam_westboundpro.WallHack.Visuals.TracersSettings.Color
							PlayerTable.Tracer.Transparency = getgenv().AirTeam_westboundpro.WallHack.Visuals.TracersSettings.Transparency

							PlayerTable.Tracer.To = Vector2new(Vector.X, Vector.Y)

							if getgenv().AirTeam_westboundpro.WallHack.Visuals.TracersSettings.Type == 1 then
								PlayerTable.Tracer.From = Vector2new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
							elseif getgenv().AirTeam_westboundpro.WallHack.Visuals.TracersSettings.Type == 2 then
								PlayerTable.Tracer.From = Vector2new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
							elseif getgenv().AirTeam_westboundpro.WallHack.Visuals.TracersSettings.Type == 3 then
								PlayerTable.Tracer.From = Vector2new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
							else
								PlayerTable.Tracer.From = Vector2new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
							end
						end
					end
				else
					PlayerTable.Tracer.Visible = false
				end
			else
				PlayerTable.Tracer.Visible = false
			end
		end)
	end,

	AddBox = function(Player)
		local PlayerTable = GetPlayerTable(Player)

		PlayerTable.Box.Square = Drawingnew("Square")

		PlayerTable.Box.TopLeftLine = Drawingnew("Line")
		PlayerTable.Box.TopLeftLine = Drawingnew("Line")
		PlayerTable.Box.TopRightLine = Drawingnew("Line")
		PlayerTable.Box.BottomLeftLine = Drawingnew("Line")
		PlayerTable.Box.BottomRightLine = Drawingnew("Line")

		local function Visibility(Bool)
			if getgenv().AirTeam_westboundpro.WallHack.Visuals.BoxSettings.Type == 1 then
				PlayerTable.Box.Square.Visible = not Bool

				PlayerTable.Box.TopLeftLine.Visible = Bool
				PlayerTable.Box.TopRightLine.Visible = Bool
				PlayerTable.Box.BottomLeftLine.Visible = Bool
				PlayerTable.Box.BottomRightLine.Visible = Bool
			elseif getgenv().AirTeam_westboundpro.WallHack.Visuals.BoxSettings.Type == 2 then
				PlayerTable.Box.Square.Visible = Bool

				PlayerTable.Box.TopLeftLine.Visible = not Bool
				PlayerTable.Box.TopRightLine.Visible = not Bool
				PlayerTable.Box.BottomLeftLine.Visible = not Bool
				PlayerTable.Box.BottomRightLine.Visible = not Bool
			end
		end

		local function Visibility2(Bool)
			PlayerTable.Box.Square.Visible = Bool

			PlayerTable.Box.TopLeftLine.Visible = Bool
			PlayerTable.Box.TopRightLine.Visible = Bool
			PlayerTable.Box.BottomLeftLine.Visible = Bool
			PlayerTable.Box.BottomRightLine.Visible = Bool
		end

		PlayerTable.Connections.Box = RunService.RenderStepped:Connect(function()
			if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChild("Head") and getgenv().AirTeam_westboundpro.WallHack.Settings.Enabled then
				local Vector, OnScreen = WorldToViewportPoint(Player.Character.HumanoidRootPart.Position)

				local HRPCFrame, HRPSize = Player.Character.HumanoidRootPart.CFrame, Player.Character.HumanoidRootPart.Size * getgenv().AirTeam_westboundpro.WallHack.Visuals.BoxSettings.Increase

				local TopLeftPosition = WorldToViewportPoint(HRPCFrame * CFramenew(HRPSize.X,  HRPSize.Y, 0).Position)
				local TopRightPosition = WorldToViewportPoint(HRPCFrame * CFramenew(-HRPSize.X,  HRPSize.Y, 0).Position)
				local BottomLeftPosition = WorldToViewportPoint(HRPCFrame * CFramenew(HRPSize.X, -HRPSize.Y, 0).Position)
				local BottomRightPosition = WorldToViewportPoint(HRPCFrame * CFramenew(-HRPSize.X, -HRPSize.Y, 0).Position)

				local HeadOffset = WorldToViewportPoint(Player.Character.Head.Position + Vector3new(0, 0.5, 0))
				local LegsOffset = WorldToViewportPoint(Player.Character.HumanoidRootPart.Position - Vector3new(0, 3, 0))

				Visibility(getgenv().AirTeam_westboundpro.WallHack.Visuals.BoxSettings.Enabled)

				if OnScreen and getgenv().AirTeam_westboundpro.WallHack.Visuals.BoxSettings.Enabled then
					if PlayerTable.Checks.Alive and PlayerTable.Checks.Team then
						Visibility(true)
					else
						Visibility2(false)
					end

					if PlayerTable.Box.Square.Visible and not PlayerTable.Box.TopLeftLine.Visible and not PlayerTable.Box.TopRightLine.Visible and not PlayerTable.Box.BottomLeftLine.Visible and not PlayerTable.Box.BottomRightLine.Visible then
						PlayerTable.Box.Square.Thickness = getgenv().AirTeam_westboundpro.WallHack.Visuals.BoxSettings.Thickness
						PlayerTable.Box.Square.Color = getgenv().AirTeam_westboundpro.WallHack.Visuals.BoxSettings.Color
						PlayerTable.Box.Square.Transparency = getgenv().AirTeam_westboundpro.WallHack.Visuals.BoxSettings.Transparency
						PlayerTable.Box.Square.Filled = getgenv().AirTeam_westboundpro.WallHack.Visuals.BoxSettings.Filled

						PlayerTable.Box.Square.Size = Vector2new(2000 / Vector.Z, HeadOffset.Y - LegsOffset.Y)
						PlayerTable.Box.Square.Position = Vector2new(Vector.X - PlayerTable.Box.Square.Size.X / 2, Vector.Y - PlayerTable.Box.Square.Size.Y / 2)
					elseif not PlayerTable.Box.Square.Visible and PlayerTable.Box.TopLeftLine.Visible and PlayerTable.Box.TopRightLine.Visible and PlayerTable.Box.BottomLeftLine.Visible and PlayerTable.Box.BottomRightLine.Visible then
						PlayerTable.Box.TopLeftLine.Thickness = getgenv().AirTeam_westboundpro.WallHack.Visuals.BoxSettings.Thickness
						PlayerTable.Box.TopLeftLine.Transparency = getgenv().AirTeam_westboundpro.WallHack.Visuals.BoxSettings.Transparency
						PlayerTable.Box.TopLeftLine.Color = getgenv().AirTeam_westboundpro.WallHack.Visuals.BoxSettings.Color

						PlayerTable.Box.TopRightLine.Thickness = getgenv().AirTeam_westboundpro.WallHack.Visuals.BoxSettings.Thickness
						PlayerTable.Box.TopRightLine.Transparency = getgenv().AirTeam_westboundpro.WallHack.Visuals.BoxSettings.Transparency
						PlayerTable.Box.TopRightLine.Color = getgenv().AirTeam_westboundpro.WallHack.Visuals.BoxSettings.Color

						PlayerTable.Box.BottomLeftLine.Thickness = getgenv().AirTeam_westboundpro.WallHack.Visuals.BoxSettings.Thickness
						PlayerTable.Box.BottomLeftLine.Transparency = getgenv().AirTeam_westboundpro.WallHack.Visuals.BoxSettings.Transparency
						PlayerTable.Box.BottomLeftLine.Color = getgenv().AirTeam_westboundpro.WallHack.Visuals.BoxSettings.Color

						PlayerTable.Box.BottomRightLine.Thickness = getgenv().AirTeam_westboundpro.WallHack.Visuals.BoxSettings.Thickness
						PlayerTable.Box.BottomRightLine.Transparency = getgenv().AirTeam_westboundpro.WallHack.Visuals.BoxSettings.Transparency
						PlayerTable.Box.BottomRightLine.Color = getgenv().AirTeam_westboundpro.WallHack.Visuals.BoxSettings.Color

						PlayerTable.Box.TopLeftLine.From = Vector2new(TopLeftPosition.X, TopLeftPosition.Y)
						PlayerTable.Box.TopLeftLine.To = Vector2new(TopRightPosition.X, TopRightPosition.Y)

						PlayerTable.Box.TopRightLine.From = Vector2new(TopRightPosition.X, TopRightPosition.Y)
						PlayerTable.Box.TopRightLine.To = Vector2new(BottomRightPosition.X, BottomRightPosition.Y)

						PlayerTable.Box.BottomLeftLine.From = Vector2new(BottomLeftPosition.X, BottomLeftPosition.Y)
						PlayerTable.Box.BottomLeftLine.To = Vector2new(TopLeftPosition.X, TopLeftPosition.Y)

						PlayerTable.Box.BottomRightLine.From = Vector2new(BottomRightPosition.X, BottomRightPosition.Y)
						PlayerTable.Box.BottomRightLine.To = Vector2new(BottomLeftPosition.X, BottomLeftPosition.Y)
					end
				else
					Visibility2(false)
				end
			else
				Visibility2(false)
			end
		end)
	end,

	AddHeadDot = function(Player)
		local PlayerTable = GetPlayerTable(Player)

		PlayerTable.HeadDot = Drawingnew("Circle")

		PlayerTable.Connections.HeadDot = RunService.RenderStepped:Connect(function()
			if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") and Player.Character:FindFirstChild("Head") and getgenv().AirTeam_westboundpro.WallHack.Settings.Enabled then
				local Vector, OnScreen = WorldToViewportPoint(Player.Character.Head.Position)

				PlayerTable.HeadDot.Visible = getgenv().AirTeam_westboundpro.WallHack.Visuals.HeadDotSettings.Enabled

				if OnScreen and getgenv().AirTeam_westboundpro.WallHack.Visuals.HeadDotSettings.Enabled then
					if getgenv().AirTeam_westboundpro.WallHack.Visuals.HeadDotSettings.Enabled then
						PlayerTable.HeadDot.Visible = PlayerTable.Checks.Alive and PlayerTable.Checks.Team and true or false

						if PlayerTable.HeadDot.Visible then
							PlayerTable.HeadDot.Thickness = getgenv().AirTeam_westboundpro.WallHack.Visuals.HeadDotSettings.Thickness
							PlayerTable.HeadDot.Color = getgenv().AirTeam_westboundpro.WallHack.Visuals.HeadDotSettings.Color
							PlayerTable.HeadDot.Transparency = getgenv().AirTeam_westboundpro.WallHack.Visuals.HeadDotSettings.Transparency
							PlayerTable.HeadDot.NumSides = getgenv().AirTeam_westboundpro.WallHack.Visuals.HeadDotSettings.Sides
							PlayerTable.HeadDot.Filled = getgenv().AirTeam_westboundpro.WallHack.Visuals.HeadDotSettings.Filled
							PlayerTable.HeadDot.Position = Vector2new(Vector.X, Vector.Y)

							local Top, Bottom = WorldToViewportPoint((Player.Character.Head.CFrame * CFramenew(0, Player.Character.Head.Size.Y / 2, 0)).Position), WorldToViewportPoint((Player.Character.Head.CFrame * CFramenew(0, -Player.Character.Head.Size.Y / 2, 0)).Position)
							PlayerTable.HeadDot.Radius = mathabs((Top - Bottom).Y) - 3
						end
					end
				else
					PlayerTable.HeadDot.Visible = false
				end
			else
				PlayerTable.HeadDot.Visible = false
			end
		end)
	end,

	AddCrosshair = function()
		local AxisX, AxisY = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2

		ServiceConnections.AxisConnection = RunService.RenderStepped:Connect(function()
			if getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.Enabled then
				if getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.Type == 1 then
					AxisX, AxisY = UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y
				elseif getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.Type == 2 then
					AxisX, AxisY = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
				else
					getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.Type = 1
				end
			end
		end)

		ServiceConnections.CrosshairConnection = RunService.RenderStepped:Connect(function()
			if getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.Enabled then

				--// Left Line

				CrosshairParts.LeftLine.Visible = getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.Enabled and getgenv().AirTeam_westboundpro.WallHack.Settings.Enabled
				CrosshairParts.LeftLine.Color = getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.Color
				CrosshairParts.LeftLine.Thickness = getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.Thickness
				CrosshairParts.LeftLine.Transparency = getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.Transparency

				CrosshairParts.LeftLine.From = Vector2new(AxisX + getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.GapSize, AxisY)
				CrosshairParts.LeftLine.To = Vector2new(AxisX + getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.Size + getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.GapSize, AxisY)

				--// Right Line

				CrosshairParts.RightLine.Visible = getgenv().AirTeam_westboundpro.WallHack.Settings.Enabled
				CrosshairParts.RightLine.Color = getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.Color
				CrosshairParts.RightLine.Thickness = getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.Thickness
				CrosshairParts.RightLine.Transparency = getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.Transparency

				CrosshairParts.RightLine.From = Vector2new(AxisX - getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.GapSize, AxisY)
				CrosshairParts.RightLine.To = Vector2new(AxisX - getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.Size - getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.GapSize, AxisY)

				--// Top Line

				CrosshairParts.TopLine.Visible = getgenv().AirTeam_westboundpro.WallHack.Settings.Enabled
				CrosshairParts.TopLine.Color = getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.Color
				CrosshairParts.TopLine.Thickness = getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.Thickness
				CrosshairParts.TopLine.Transparency = getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.Transparency

				CrosshairParts.TopLine.From = Vector2new(AxisX, AxisY + getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.GapSize)
				CrosshairParts.TopLine.To = Vector2new(AxisX, AxisY + getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.Size + getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.GapSize)

				--// Bottom Line

				CrosshairParts.BottomLine.Visible = getgenv().AirTeam_westboundpro.WallHack.Settings.Enabled
				CrosshairParts.BottomLine.Color = getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.Color
				CrosshairParts.BottomLine.Thickness = getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.Thickness
				CrosshairParts.BottomLine.Transparency = getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.Transparency

				CrosshairParts.BottomLine.From = Vector2new(AxisX, AxisY - getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.GapSize)
				CrosshairParts.BottomLine.To = Vector2new(AxisX, AxisY - getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.Size - getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.GapSize)

				--// Center Dot

				CrosshairParts.CenterDot.Visible = getgenv().AirTeam_westboundpro.WallHack.Settings.Enabled and getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.CenterDot
				CrosshairParts.CenterDot.Color = getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.CenterDotColor
				CrosshairParts.CenterDot.Radius = getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.CenterDotSize
				CrosshairParts.CenterDot.Transparency = getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.CenterDotTransparency
				CrosshairParts.CenterDot.Filled = getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.CenterDotFilled
				CrosshairParts.CenterDot.Thickness = getgenv().AirTeam_westboundpro.WallHack.Crosshair.Settings.CenterDotThickness

				CrosshairParts.CenterDot.Position = Vector2new(AxisX, AxisY)
			else
				CrosshairParts.LeftLine.Visible = false
				CrosshairParts.RightLine.Visible = false
				CrosshairParts.TopLine.Visible = false
				CrosshairParts.BottomLine.Visible = false
				CrosshairParts.CenterDot.Visible = false
			end
		end)
	end
}

--// Functions

local function Wrap(Player)
	if not GetPlayerTable(Player) then
		local Table, Value = nil, {Name = Player.Name, RigType = nil, Checks = {Alive = true, Team = true}, Connections = {}, ESP = nil, Tracer = nil, HeadDot = nil, Box = {Square = nil, TopLeftLine = nil, TopRightLine = nil, BottomLeftLine = nil, BottomRightLine = nil}, Chams = {}}

		for _, v in next, WrappedPlayers do
			if v[1] == Player.Name then
				Table = v
			end
		end

		if not Table then
			WrappedPlayers[#WrappedPlayers + 1] = Value
			AssignRigType(Player)
			InitChecks(Player)

			Visuals.AddESP(Player)
			Visuals.AddTracer(Player)
			Visuals.AddBox(Player)
			Visuals.AddHeadDot(Player)
		end
	end
end

local function UnWrap(Player)
	local Table, Index = nil, nil

	for i, v in next, WrappedPlayers do
		if v.Name == Player.Name then
			Table, Index = v, i
		end
	end

	if Table then
		for _, v in next, Table.Connections do
			v:Disconnect()
		end

		pcall(function()
			Table.ESP:Remove()
			Table.Tracer:Remove()
			Table.HeadDot:Remove()
		end)

		for _, v in next, Table.Box do
			if type(v.Remove) == "function" then
				v:Remove()
			end
		end

		for _, v in next, Table.Chams do
			for _, v2 in next, v do
				if type(v2.Remove) == "function" then
					v2:Remove()
				end
			end
		end

		WrappedPlayers[Index] = nil
	end
end

local function Load()
	Visuals.AddCrosshair()

	ServiceConnections.AnimalAddedConnection = workspace.Animals.ChildAdded:Connect(Visuals.AddESP_Animal)
	ServiceConnections.PlayerAddedConnection = Players.PlayerAdded:Connect(Wrap)
	ServiceConnections.PlayerRemovingConnection = Players.PlayerRemoving:Connect(UnWrap)

	for _, v in next, workspace.Animals:GetChildren() do
		if v:IsA("Model") and v:WaitForChild("Humanoid", 1 / 0) then
			Visuals.AddESP_Animal(v)
		end
	end

	ServiceConnections.ReWrapPlayers = RunService.RenderStepped:Connect(function()
		for _, v in next, Players:GetPlayers() do
			if v ~= LocalPlayer then
				Wrap(v)
			end
		end

		wait(10)
	end)
end

--// Main

Load()
