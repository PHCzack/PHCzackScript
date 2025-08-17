-- UIMaker v1.0
-- A modular, mobile-friendly UI library.

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Main library table
local UIMaker = {}
UIMaker.__index = UIMaker

-- Global settings (can be configured)
local ZINDEX_BASE = 100
local FONT = Enum.Font.GothamSemibold
local THEME = {
	Background = Color3.fromRGB(35, 35, 45),
	Primary = Color3.fromRGB(50, 50, 60),
	Secondary = Color3.fromRGB(70, 70, 80),
	Accent = Color3.fromRGB(120, 100, 255),
	Text = Color3.fromRGB(255, 255, 255),
	TextSecondary = Color3.fromRGB(180, 180, 180),
}

--// UTILITY FUNCTIONS //--
local function CreateInstance(className, properties)
	local inst = Instance.new(className)
	for prop, value in pairs(properties) do
		inst[prop] = value
	end
	return inst
end

--// MAIN GUI CONSTRUCTOR //--
function UIMaker.new(config)
	local self = setmetatable({}, UIMaker)

	-- Main ScreenGui
	self.ScreenGui = CreateInstance("ScreenGui", {
		Name = config.Name or "MyGUI",
		Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"),
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		ResetOnSpawn = false,
	})

	-- Main Window Frame (Draggable)
	self.Window = CreateInstance("Frame", {
		Name = "Window",
		Parent = self.ScreenGui,
		Size = UDim2.fromScale(0.4, 0.5), -- Mobile-friendly scaling
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = THEME.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Visible = true,
		ZIndex = ZINDEX_BASE,
	})
	CreateInstance("UICorner", { CornerRadius = UDim.new(0, 8), Parent = self.Window })

	-- Header (for title and dragging)
	local Header = CreateInstance("Frame", {
		Name = "Header",
		Parent = self.Window,
		Size = UDim2.new(1, 0, 0, 35),
		BackgroundColor3 = THEME.Primary,
		BorderSizePixel = 0,
		ZIndex = ZINDEX_BASE + 1,
	})

	local Title = CreateInstance("TextLabel", {
		Name = "Title",
		Parent = Header,
		Size = UDim2.new(1, -40, 1, 0),
		Position = UDim2.fromScale(0.02, 0),
		Text = config.Title or "My UI",
		TextColor3 = THEME.Text,
		Font = FONT,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		ZIndex = ZINDEX_BASE + 2,
	})

	-- Hide/Show button
	local HideButton = CreateInstance("TextButton", {
		Name = "HideButton",
		Parent = Header,
		Size = UDim2.new(0, 30, 0, 20),
		Position = UDim2.new(1, -35, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Text = "-",
		TextColor3 = THEME.Text,
		Font = FONT,
		TextSize = 20,
		BackgroundColor3 = THEME.Secondary,
		ZIndex = ZINDEX_BASE + 2,
	})
	CreateInstance("UICorner", { Parent = HideButton, CornerRadius = UDim.new(0, 4) })

	-- Tab Container
	local TabContainer = CreateInstance("Frame", {
		Name = "TabContainer",
		Parent = self.Window,
		Size = UDim2.new(0.25, 0, 1, -35),
		Position = UDim2.new(0, 0, 0, 35),
		BackgroundColor3 = THEME.Primary,
		BorderSizePixel = 0,
		ZIndex = ZINDEX_BASE + 1,
	})
	CreateInstance("UIListLayout", {
		Parent = TabContainer,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 5),
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	})
	CreateInstance("UIPadding", {
		Parent = TabContainer,
		PaddingTop = UDim.new(0, 5),
	})


	-- Content Container (where tab content goes)
	self.ContentContainer = CreateInstance("Frame", {
		Name = "ContentContainer",
		Parent = self.Window,
		Size = UDim2.new(0.75, 0, 1, -35),
		Position = UDim2.new(0.25, 0, 0, 35),
		BackgroundTransparency = 1,
		ZIndex = ZINDEX_BASE + 1,
	})
	
	self.Tabs = {}
	self.CurrentTab = nil

	--// DRAGGING LOGIC //--
	local dragging = false
	local dragInput, dragStart, startPos
	Header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = self.Window.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			if dragging then
				local delta = input.Position - dragStart
				self.Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end
	end)

	--// HIDE/SHOW LOGIC //--
	local isVisible = true
	local function setVisibility(visible)
		isVisible = visible
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local goal = {Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.4, 0.5)}
		if not visible then
			goal = {Position = UDim2.fromScale(0.5, -1), Size = UDim2.fromScale(0.3, 0.4)}
		end
		TweenService:Create(self.Window, tweenInfo, goal):Play()
		HideButton.Text = visible and "-" or "+"
	end

	HideButton.MouseButton1Click:Connect(function()
		setVisibility(not isVisible)
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == (config.ToggleKey or Enum.KeyCode.RightControl) then
			setVisibility(not isVisible)
		end
	end)

	return self
end

function UIMaker:CreateTab(config)
	local Tab = {}
	Tab.__index = Tab

	local layoutOrder = #self.Tabs + 1

	-- Tab Button
	local TabButton = CreateInstance("TextButton", {
		Name = config.Name,
		Parent = self.Window.TabContainer,
		Size = UDim2.new(0.9, 0, 0, 30),
		Text = config.Name,
		Font = FONT,
		TextColor3 = THEME.TextSecondary,
		TextSize = 14,
		BackgroundColor3 = THEME.Primary,
		LayoutOrder = layoutOrder,
	})
	CreateInstance("UICorner", {Parent = TabButton, CornerRadius = UDim.new(0, 6)})

	-- Tab Content (ScrollingFrame)
	local ContentFrame = CreateInstance("ScrollingFrame", {
		Name = config.Name .. "Content",
		Parent = self.ContentContainer,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		CanvasSize = UDim2.fromScale(0, 0), -- Auto-size
		ScrollBarImageColor3 = THEME.Accent,
		ScrollBarThickness = 5,
	})
	local ContentLayout = CreateInstance("UIListLayout", {
		Parent = ContentFrame,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	})
	CreateInstance("UIPadding", {
		Parent = ContentFrame,
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 10),
	})

	local tabObject = setmetatable({
		Button = TabButton,
		Content = ContentFrame,
		Layout = ContentLayout,
		Elements = {},
		Order = 1,
	}, Tab)

	local function selectTab()
		if self.CurrentTab then
			self.CurrentTab.Content.Visible = false
			self.CurrentTab.Button.TextColor3 = THEME.TextSecondary
			self.CurrentTab.Button.BackgroundColor3 = THEME.Primary
		end
		tabObject.Content.Visible = true
		tabObject.Button.TextColor3 = THEME.Text
		tabObject.Button.BackgroundColor3 = THEME.Secondary
		self.CurrentTab = tabObject
	end

	TabButton.MouseButton1Click:Connect(selectTab)
	self.Tabs[config.Name] = tabObject

	if not self.CurrentTab then
		selectTab()
	end

	return tabObject
end

local function createBaseElement(tab, name, height)
	local Container = CreateInstance("Frame", {
		Name = name,
		Parent = tab.Content,
		Size = UDim2.new(1, 0, 0, height),
		BackgroundTransparency = 1,
		LayoutOrder = tab.Order,
	})
	tab.Order = tab.Order + 1
	return Container
end

--// ELEMENT FUNCTIONS //--

function UIMaker:Button(config)
	local Container = createBaseElement(self, config.Name, 40)
	
	local Button = CreateInstance("TextButton", {
		Name = config.Name,
		Parent = Container,
		Size = UDim2.new(1, 0, 0, 30),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = THEME.Secondary,
		Text = config.Name,
		Font = FONT,
		TextColor3 = THEME.Text,
		TextSize = 14,
	})
	CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Button })

	Button.MouseButton1Click:Connect(function()
		config.Callback()
	end)

	if config.Description then
		local Desc = CreateInstance("TextLabel", {
			Name = "Description",
			Parent = Container,
			Size = UDim2.new(1, 0, 0, 10),
			Position = UDim2.new(0, 0, 1, -10),
			Text = config.Description,
			Font = FONT,
			TextSize = 10,
			TextColor3 = THEME.TextSecondary,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
	end
	
	return Button
end

function UIMaker:Toggle(config)
	local state = config.StartingState or false
	local Container = createBaseElement(self, config.Name, 30)
	
	local Label = CreateInstance("TextLabel", {
		Name = "Label",
		Parent = Container,
		Size = UDim2.new(0.7, 0, 1, 0),
		Font = FONT,
		TextColor3 = THEME.Text,
		TextSize = 14,
		Text = config.Name,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
	})

	local ToggleButton = CreateInstance("TextButton", {
		Name = "ToggleButton",
		Parent = Container,
		Size = UDim2.new(0.25, 0, 0.8, 0),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = state and THEME.Accent or THEME.Secondary,
		Text = "",
	})
	CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ToggleButton })
	
	local Knob = CreateInstance("Frame", {
		Name = "Knob",
		Parent = ToggleButton,
		Size = UDim2.new(0.4, 0, 0.8, 0),
		Position = UDim2.fromScale(state and 0.75 or 0.25, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = THEME.Background,
	})
	CreateInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Knob })
	
	local function updateVisuals()
		local knobPos = state and UDim2.fromScale(0.75, 0.5) or UDim2.fromScale(0.25, 0.5)
		local bgColor = state and THEME.Accent or THEME.Secondary
		local tweenInfo = TweenInfo.new(0.15)
		TweenService:Create(Knob, tweenInfo, {Position = knobPos}):Play()
		TweenService:Create(ToggleButton, tweenInfo, {BackgroundColor3 = bgColor}):Play()
	end

	ToggleButton.MouseButton1Click:Connect(function()
		state = not state
		updateVisuals()
		if config.Callback then
			config.Callback(state)
		end
	end)
	
	return ToggleButton
end

-- Bind the element functions to the Tab's metatable
getmetatable(UIMaker.new({Name="temp"}).Tabs).Button = UIMaker.Button
getmetatable(UIMaker.new({Name="temp"}).Tabs).Toggle = UIMaker.Toggle
game.Players.LocalPlayer.PlayerGui:FindFirstChild("temp"):Destroy()


return UIMaker
