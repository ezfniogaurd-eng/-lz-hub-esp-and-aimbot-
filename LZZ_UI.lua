-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Detect mobile
local isMobile = UserInputService.TouchEnabled

-- UI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "LZZ_UI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local main = Instance.new("Frame")
main.AnchorPoint = Vector2.new(0.5,0.5)
main.Position = UDim2.fromScale(0.5,0.5)
main.Size = isMobile and UDim2.fromScale(0.35,0.25) or UDim2.fromScale(0.2,0.32)
main.BackgroundColor3 = Color3.fromRGB(0,0,0)
main.BackgroundTransparency = 0.55
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui

-- Smooth corners
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0,12)
mainCorner.Parent = main

-- Title
local title = Instance.new("TextLabel")
title.Size = isMobile and UDim2.new(1,0,0,30) or UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "LZZ UI"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = isMobile and 16 or 20
title.Parent = main

-- Button Creator with Smooth Hover Tween
local function createButton(name, yOffset)
	local btn = Instance.new("TextButton")
	btn.Size = isMobile and UDim2.new(0.9,0,0,28) or UDim2.new(0.9,0,0,35)
	btn.Position = UDim2.new(0.05,0,0,yOffset)
	btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
	btn.BorderSizePixel = 0
	btn.TextColor3 = Color3.fromRGB(255,255,255) -- default white
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = isMobile and 14 or 16
	btn.Text = name
	btn.Parent = main

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,6)
	corner.Parent = btn

	-- Hover effect with Tween
	local hoverInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, hoverInfo, {TextColor3 = Color3.fromRGB(173,216,230)}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, hoverInfo, {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
	end)

	return btn
end

local btn1 = createButton("ESP Players", isMobile and 40 or 50)
local btn2 = createButton("Lock-On Nearest", isMobile and 75 or 95)
local btn3 = createButton("Button 3", isMobile and 110 or 140)

-- Drag System
local dragging, dragStart, startPos
local function startDrag(pos)
	dragging = true
	dragStart = pos
	startPos = main.Position
end
local function updateDrag(pos)
	if dragging then
		local delta = pos - dragStart
		main.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset + delta.X,
			startPos.Y.Scale,startPos.Y.Offset + delta.Y)
	end
end
local function endDrag()
	dragging = false
end

main.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		startDrag(input.Position)
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				endDrag()
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		updateDrag(input.Position)
	end
end)

--// Button 1: ESP Highlights + Torso Red Boxes
local TORSO_BOX_COLOR = Color3.fromRGB(255,0,0) -- bright red
local HIGHLIGHT_COLOR = Color3.fromRGB(173,216,230)
local espBoxes = {}
local espHighlights = {}
local espEnabled = false

local function addESPBox(player)
	if player == LocalPlayer or espBoxes[player] then return end
	local char = player.Character
	if not char then return end
	local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
	if not torso then return end

	local box = Instance.new("BillboardGui")
	box.Name = "ESPBox"
	box.Adornee = torso
	box.Size = UDim2.new(0,30,0,30)
	box.AlwaysOnTop = true
	box.Parent = gui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,0,1,0)
	frame.BackgroundColor3 = TORSO_BOX_COLOR
	frame.BorderSizePixel = 0
	frame.BackgroundTransparency = 0.3
	frame.Parent = box

	espBoxes[player] = box
end

local function removeESPBox(player)
	if espBoxes[player] then
		espBoxes[player]:Destroy()
		espBoxes[player] = nil
	end
end

local function addHighlight(player)
	if player == LocalPlayer or espHighlights[player] then return end
	local char = player.Character
	if not char then return end
	local highlight = Instance.new("Highlight")
	highlight.Name = "ESPHighlight"
	highlight.Adornee = char
	highlight.FillColor = HIGHLIGHT_COLOR
	highlight.OutlineColor = HIGHLIGHT_COLOR
	highlight.FillTransparency = 0.6
	highlight.OutlineTransparency = 0.3
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = Workspace
	espHighlights[player] = highlight
end

local function removeHighlight(player)
	if espHighlights[player] then
		espHighlights[player]:Destroy()
		espHighlights[player] = nil
	end
end

local function updateESP()
	if espEnabled then
		for _,player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				addESPBox(player)
				addHighlight(player)
			end
		end
	else
		for player,_ in pairs(espBoxes) do
			removeESPBox(player)
		end
		for player,_ in pairs(espHighlights) do
			removeHighlight(player)
		end
	end
end

RunService.RenderStepped:Connect(updateESP)
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		if espEnabled then
			addESPBox(player)
			addHighlight(player)
		end
	end)
end)
Players.PlayerRemoving:Connect(function(player)
	removeESPBox(player)
	removeHighl
