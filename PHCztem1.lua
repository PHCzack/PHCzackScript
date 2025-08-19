--[[
=========================================================================================================================
-- || Modular UI Library ||
--
-- Features:
--  - Draggable Window
--  - Hide/Show UI (Default Key: RightControl)
--  - Mobile Friendly (Uses Scale sizing)
--  - Scrollable Tabs
--  - All components you requested
--  - Fully modular and easy to integrate
--
-- Instructions:
-- 1. Place this script inside a LocalScript in StarterPlayer > StarterPlayerScripts.
-- 2. The UI will be created automatically.
-- 3. Modify the "Example Usage" section at the bottom to build your own UI.
=========================================================================================================================
]]

--// Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

--// Main GUI Library Table
local GUI = {}
GUI.__index = GUI

--// Configuration
local HIDE_KEY = Enum.KeyCode.RightControl
local UI_FONT = Enum.Font.SourceSans
local UI_PRIMARY_COLOR = Color3.fromRGB(30, 30, 30)
local UI_SECONDARY_COLOR = Color3.fromRGB(45, 45, 45)
local UI_ACCENT_COLOR = Color3.fromRGB(100, 65, 165)
local UI_TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local UI_TEXT_STROKE_COLOR = Color3.fromRGB(0, 0, 0)

--// Create the main GUI object
function GUI.new()
	local self = setmetatable({}, GUI)

	-- Main ScreenGui
	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.ResetOnSpawn = false
	self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	-- Main Frame (The draggable window)
	self.MainFrame = Instance.new("Frame")
	self.MainFrame.Size = UDim2.fromScale(0.4, 0.5)
	self.MainFrame.Position = UDim2.fromScale(0.5, 0.5)
	self.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	self.MainFrame.BackgroundColor3 = UI_PRIMARY_COLOR
	self.MainFrame.BorderSizePixel = 0
	self.MainFrame.ClipsDescendants = true
	self.MainFrame.Parent = self.ScreenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = self.MainFrame

	-- Header for Title and Dragging
	self.Header = Instance.new("Frame")
	self.Header.Size = UDim2.new(1, 0, 0, 35)
	self.Header.BackgroundColor3 = UI_SECONDARY_COLOR
	self.Header.BorderSizePixel = 0
	self.Header.Parent = self.MainFrame

	self.TitleLabel = Instance.new("TextLabel")
	self.TitleLabel.Size = UDim2.new(1, -10, 1, 0)
	self.TitleLabel.Position = UDim2.fromOffset(10, 0)
	self.TitleLabel.BackgroundColor3 = self.Header.BackgroundColor3
	self.TitleLabel.BackgroundTransparency = 1
	self.TitleLabel.Font = UI_FONT
	self.TitleLabel.Text = "My Roblox Game UI"
	self.TitleLabel.TextColor3 = UI_TEXT_COLOR
	self.TitleLabel.TextSize = 18
	self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	self.TitleLabel.Parent = self.Header

	-- Tab Container
	self.TabContainer = Instance.new("Frame")
	self.TabContainer.Size = UDim2.new(0.25, 0, 1, -35)
	self.TabContainer.Position = UDim2.fromOffset(0, 35)
	self.TabContainer.BackgroundColor3 = UI_SECONDARY_COLOR
	self.TabContainer.BorderSizePixel = 0
	self.TabContainer.Parent = self.MainFrame

	self.TabListLayout = Instance.new("UIListLayout")
	self.TabListLayout.Padding = UDim.new(0, 5)
	self.TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	self.TabListLayout.Parent = self.TabContainer

	-- Content Container
	self.ContentContainer = Instance.new("Frame")
	self.ContentContainer.Size = UDim2.new(0.75, 0, 1, -35)
	self.ContentContainer.Position = UDim2.new(0.25, 0, 0, 35)
	self.ContentContainer.BackgroundColor3 = UI_PRIMARY_COLOR
	self.ContentContainer.BorderSizePixel = 0
	self.ContentContainer.Parent = self.MainFrame

	self.Tabs = {}
	self.Visible = true
	self.CurrentTab = nil

	self:_makeDraggable()
	self:_handleVisibility()

	return self
end

--// Make the main frame draggable
function GUI:_makeDraggable()
	local dragging
	local dragInput
	local dragStart
	local startPos

	self.Header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = self.MainFrame.Position
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
				self.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end
	end)
end

--// Handle showing/hiding the UI
function GUI:_handleVisibility()
	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then return end
		if input.KeyCode == HIDE_KEY then
			self.Visible = not self.Visible
			self.MainFrame.Visible = self.Visible
		end
	end)
end

--// Create a new Tab
function GUI:Tab(name)
	local tab = {}
	tab.Name = name
	tab.GUI = self

	-- Tab Button
	tab.Button = Instance.new("TextButton")
	tab.Button.Size = UDim2.new(1, -10, 0, 30)
	tab.Button.Position = UDim2.fromOffset(5, 0)
	tab.Button.BackgroundColor3 = UI_PRIMARY_COLOR
	tab.Button.Text = name
	tab.Button.Font = UI_FONT
	tab.Button.TextColor3 = UI_TEXT_COLOR
	tab.Button.TextSize = 16
	tab.Button.Parent = self.TabContainer

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = tab.Button

	-- Content Frame (Scrollable)
	tab.ContentFrame = Instance.new("ScrollingFrame")
	tab.ContentFrame.Size = UDim2.new(1, 0, 1, 0)
	tab.ContentFrame.BackgroundColor3 = self.ContentContainer.BackgroundColor3
	tab.ContentFrame.BorderSizePixel = 0
	tab.ContentFrame.BackgroundTransparency = 1
	tab.ContentFrame.Visible = false
	tab.ContentFrame.ScrollBarImageColor3 = UI_ACCENT_COLOR
	tab.ContentFrame.ScrollBarThickness = 6
	tab.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	tab.ContentFrame.Parent = self.ContentContainer

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 10)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = tab.ContentFrame
	tab.Layout = listLayout

	-- Tab selection logic
	tab.Button.MouseButton1Click:Connect(function()
		if self.CurrentTab then
			self.CurrentTab.ContentFrame.Visible = false
			self.CurrentTab.Button.BackgroundColor3 = UI_PRIMARY_COLOR
		end
		self.CurrentTab = tab
		tab.ContentFrame.Visible = true
		tab.Button.BackgroundColor3 = UI_ACCENT_COLOR
	end)

	-- Auto-select the first tab
	if not self.CurrentTab then
		tab.Button:Invoke()
	end

	-- Attach component functions to this tab instance
	setmetatable(tab, { __index = self.TabMethods })
	table.insert(self.Tabs, tab)
	return tab
end

--// Methods for Tab objects will be stored here
GUI.TabMethods = {}

-- Helper function to create a base frame for components
local function createComponentFrame(tab, height)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -20, 0, height)
	frame.BackgroundColor3 = UI_SECONDARY_COLOR
	frame.BorderSizePixel = 0
	frame.Parent = tab.ContentFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = frame

	-- Auto-update canvas size
	tab.Layout:ApplyTo(tab.ContentFrame)
	local absoluteContentSize = tab.Layout.AbsoluteContentSize
	tab.ContentFrame.CanvasSize = UDim2.fromOffset(0, absoluteContentSize.Y)

	return frame
end

-- Helper function to create a label for components
local function createComponentLabel(parent, text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.5, -10, 1, 0)
	label.Position = UDim2.fromOffset(10, 0)
	label.BackgroundTransparency = 1
	label.Font = UI_FONT
	label.Text = text
	label.TextColor3 = UI_TEXT_COLOR
	label.TextSize = 16
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

--// Button Component
function GUI.TabMethods:Button(options)
	local frame = createComponentFrame(self, 35)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -10, 1, -10)
	button.Position = UDim2.fromScale(0.5, 0.5)
	button.AnchorPoint = Vector2.new(0.5, 0.5)
	button.BackgroundColor3 = UI_ACCENT_COLOR
	button.Font = UI_FONT
	button.Text = options.Name or "Button"
	button.TextColor3 = UI_TEXT_COLOR
	button.TextSize = 16
	button.Parent = frame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = button

	if options.Callback and type(options.Callback) == "function" then
		button.MouseButton1Click:Connect(options.Callback)
	end
end

--// Toggle Component
function GUI.TabMethods:Toggle(options)
	local frame = createComponentFrame(self, 30)
	createComponentLabel(frame, options.Name or "Toggle")

	local state = options.StartingState or false

	local toggleButton = Instance.new("TextButton")
	toggleButton.Size = UDim2.new(0.4, 0, 0.8, 0)
	toggleButton.Position = UDim2.new(0.95, 0, 0.5, 0)
	toggleButton.AnchorPoint = Vector2.new(1, 0.5)
	toggleButton.BackgroundColor3 = state and UI_ACCENT_COLOR or UI_PRIMARY_COLOR
	toggleButton.Text = ""
	toggleButton.Parent = frame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = toggleButton

	local stroke = Instance.new("UIStroke")
	stroke.Color = UI_ACCENT_COLOR
	stroke.Thickness = 1
	stroke.Parent = toggleButton

	toggleButton.MouseButton1Click:Connect(function()
		state = not state
		TweenService:Create(toggleButton, TweenInfo.new(0.2), { BackgroundColor3 = state and UI_ACCENT_COLOR or UI_PRIMARY_COLOR }):Play()
		if options.Callback and type(options.Callback) == "function" then
			options.Callback(state)
		end
	end)
end

--// Textbox Component
function GUI.TabMethods:Textbox(options)
	local frame = createComponentFrame(self, 35)
	createComponentLabel(frame, options.Name or "Textbox")

	local textbox = Instance.new("TextBox")
	textbox.Size = UDim2.new(0.5, -10, 0.8, 0)
	textbox.Position = UDim2.new(0.95, 0, 0.5, 0)
	textbox.AnchorPoint = Vector2.new(1, 0.5)
	textbox.BackgroundColor3 = UI_PRIMARY_COLOR
	textbox.Font = UI_FONT
	textbox.Text = options.Default or ""
	textbox.PlaceholderText = options.Placeholder or "Enter text..."
	textbox.TextColor3 = UI_TEXT_COLOR
	textbox.TextSize = 14
	textbox.ClearTextOnFocus = false
	textbox.Parent = frame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = textbox

	textbox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			if options.Callback and type(options.Callback) == "function" then
				options.Callback(textbox.Text)
			end
		end
	end)
end

--// Dropdown Component
function GUI.TabMethods:Dropdown(options)
	local frame = createComponentFrame(self, 35)
	createComponentLabel(frame, options.Name or "Dropdown")

	local isOpen = false
	local multiSelect = options.MultiSelect or false
	local selected = {}

	local dropdownButton = Instance.new("TextButton")
	dropdownButton.Size = UDim2.new(0.5, -10, 0.8, 0)
	dropdownButton.Position = UDim2.new(0.95, 0, 0.5, 0)
	dropdownButton.AnchorPoint = Vector2.new(1, 0.5)
	dropdownButton.BackgroundColor3 = UI_PRIMARY_COLOR
	dropdownButton.Font = UI_FONT
	dropdownButton.Text = "Select..."
	dropdownButton.TextColor3 = UI_TEXT_COLOR
	dropdownButton.TextSize = 14
	dropdownButton.Parent = frame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = dropdownButton

	local dropdownList = Instance.new("Frame")
	dropdownList.Size = UDim2.new(dropdownButton.Size.X.Scale, dropdownButton.Size.X.Offset, 0, 0)
	dropdownList.Position = UDim2.new(dropdownButton.Position.X.Scale, dropdownButton.Position.X.Offset, dropdownButton.Position.Y.Scale + 0.4, dropdownButton.Position.Y.Offset)
	dropdownList.AnchorPoint = Vector2.new(1, 0)
	dropdownList.BackgroundColor3 = UI_PRIMARY_COLOR
	dropdownList.BorderSizePixel = 0
	dropdownList.ClipsDescendants = true
	dropdownList.Visible = false
	dropdownList.ZIndex = 2
	dropdownList.Parent = frame

	local listCorner = Instance.new("UICorner")
	listCorner.CornerRadius = UDim.new(0, 4)
	listCorner.Parent = dropdownList

	local listLayout = Instance.new("UIListLayout")
	listLayout.Parent = dropdownList

	local function updateButtonText()
		if table.getn(selected) == 0 then
			dropdownButton.Text = "Select..."
		elseif table.getn(selected) > 1 then
			dropdownButton.Text = table.getn(selected) .. " selected"
		else
			dropdownButton.Text = selected[1]
		end
	end

	for _, itemText in ipairs(options.Items or {}) do
		local itemButton = Instance.new("TextButton")
		itemButton.Size = UDim2.new(1, 0, 0, 25)
		itemButton.BackgroundColor3 = UI_PRIMARY_COLOR
		itemButton.BackgroundTransparency = 1
		itemButton.Font = UI_FONT
		itemButton.Text = itemText
		itemButton.TextColor3 = UI_TEXT_COLOR
		itemButton.TextSize = 14
		itemButton.Parent = dropdownList

		itemButton.MouseEnter:Connect(function() itemButton.BackgroundTransparency = 0.5 end)
		itemButton.MouseLeave:Connect(function() itemButton.BackgroundTransparency = 1 end)

		itemButton.MouseButton1Click:Connect(function()
			if multiSelect then
				local existingIndex = table.find(selected, itemText)
				if existingIndex then
					table.remove(selected, existingIndex)
					itemButton.TextColor3 = UI_TEXT_COLOR
				else
					table.insert(selected, itemText)
					itemButton.TextColor3 = UI_ACCENT_COLOR
				end
			else
				selected = { itemText }
				isOpen = false -- Close on single select
				dropdownList.Visible = false
				itemButton.TextColor3 = UI_ACCENT_COLOR
			end
			updateButtonText()
			if options.Callback and type(options.Callback) == "function" then
				options.Callback(multiSelect and selected or selected[1])
			end
		end)
	end

	dropdownButton.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		dropdownList.Visible = isOpen
		local listHeight = #dropdownList:GetChildren() * 25
		TweenService:Create(dropdownList, TweenInfo.new(0.2), { Size = UDim2.new(dropdownButton.Size.X.Scale, 0, 0, isOpen and listHeight or 0) }):Play()
	end)
end

--// Slider Component
function GUI.TabMethods:Slider(options)
	local frame = createComponentFrame(self, 40)
	local min, max, default = options.Min or 0, options.Max or 100, options.Default or 50
	createComponentLabel(frame, options.Name or "Slider")

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0, 50, 1, 0)
	valueLabel.Position = UDim2.new(1, -10, 0, 0)
	valueLabel.AnchorPoint = Vector2.new(1, 0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Font = UI_FONT
	valueLabel.TextColor3 = UI_TEXT_COLOR
	valueLabel.TextSize = 14
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = frame

	local sliderBack = Instance.new("Frame")
	sliderBack.Size = UDim2.new(0.5, -70, 0, 6)
	sliderBack.Position = UDim2.new(0.7, 0, 0.7, 0)
	sliderBack.AnchorPoint = Vector2.new(0.5, 0.5)
	sliderBack.BackgroundColor3 = UI_PRIMARY_COLOR
	sliderBack.Parent = frame
	local backCorner = Instance.new("UICorner")
	backCorner.CornerRadius = UDim.new(1, 0)
	backCorner.Parent = sliderBack

	local sliderFill = Instance.new("Frame")
	sliderFill.BackgroundColor3 = UI_ACCENT_COLOR
	sliderFill.Parent = sliderBack
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = sliderFill

	local handle = Instance.new("Frame")
	handle.Size = UDim2.fromOffset(12, 12)
	handle.AnchorPoint = Vector2.new(0.5, 0.5)
	handle.BackgroundColor3 = UI_TEXT_COLOR
	handle.Parent = sliderFill
	local handleCorner = Instance.new("UICorner")
	handleCorner.CornerRadius = UDim.new(1, 0)
	handleCorner.Parent = handle

	local currentValue = default
	local function updateSlider(value)
		currentValue = math.clamp(value, min, max)
		local percentage = (currentValue - min) / (max - min)
		sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
		handle.Position = UDim2.new(1, 0, 0.5, 0)
		valueLabel.Text = tostring(math.floor(currentValue))
		if options.Callback and type(options.Callback) == "function" then
			options.Callback(currentValue)
		end
	end

	updateSlider(default)

	local dragging = false
	sliderBack.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)
	sliderBack.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local mouseX = input.Position.X
			local startX = sliderBack.AbsolutePosition.X
			local width = sliderBack.AbsoluteSize.X
			local percentage = math.clamp((mouseX - startX) / width, 0, 1)
			local newValue = min + (max - min) * percentage
			updateSlider(newValue)
		end
	end)
end

--// Keybind Component
function GUI.TabMethods:Keybind(options)
	local frame = createComponentFrame(self, 35)
	createComponentLabel(frame, options.Name or "Keybind")

	local currentKey = options.Keybind or "..."
	local isBinding = false

	local keybindButton = Instance.new("TextButton")
	keybindButton.Size = UDim2.new(0.3, 0, 0.8, 0)
	keybindButton.Position = UDim2.new(0.95, 0, 0.5, 0)
	keybindButton.AnchorPoint = Vector2.new(1, 0.5)
	keybindButton.BackgroundColor3 = UI_PRIMARY_COLOR
	keybindButton.Font = UI_FONT
	keybindButton.Text = tostring(currentKey)
	keybindButton.TextColor3 = UI_TEXT_COLOR
	keybindButton.TextSize = 14
	keybindButton.Parent = frame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = keybindButton

	keybindButton.MouseButton1Click:Connect(function()
		isBinding = true
		keybindButton.Text = "..."
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if isBinding and not gameProcessedEvent then
			isBinding = false
			if input.KeyCode == Enum.KeyCode.Escape then
				currentKey = "..."
			else
				currentKey = input.KeyCode.Name
			end
			keybindButton.Text = tostring(currentKey)
			if options.Callback and type(options.Callback) == "function" then
				options.Callback(currentKey)
			end
		end
	end)
end

--// ColorPicker Component
function GUI.TabMethods:ColorPicker(options)
	-- This is a simplified color picker. A full-featured one is very complex.
	local frame = createComponentFrame(self, 120)
	createComponentLabel(frame, options.Name or "Color Picker")

	local colorPreview = Instance.new("Frame")
	colorPreview.Size = UDim2.new(0.2, 0, 0.2, 0)
	colorPreview.Position = UDim2.new(0.9, 0, 0.2, 0)
	colorPreview.AnchorPoint = Vector2.new(1, 0.5)
	colorPreview.BackgroundColor3 = Color3.new(1, 1, 1)
	colorPreview.Parent = frame
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = colorPreview

	local hueGradient = Instance.new("UIGradient")
	hueGradient.Rotation = 90
	hueGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
	})
	
	local function createSlider(name, parent, yPos, callback)
		local sliderFrame = Instance.new("Frame")
		sliderFrame.Size = UDim2.new(1, -20, 0, 20)
		sliderFrame.Position = UDim2.fromOffset(10, yPos)
		sliderFrame.BackgroundTransparency = 1
		sliderFrame.Parent = parent
		
		local back = Instance.new("Frame")
		back.Size = UDim2.new(1, 0, 0, 6)
		back.Position = UDim2.fromScale(0.5, 0.5)
		back.AnchorPoint = Vector2.new(0.5, 0.5)
		back.BackgroundColor3 = UI_PRIMARY_COLOR
		back.Parent = sliderFrame
		local backCorner = Instance.new("UICorner")
		backCorner.CornerRadius = UDim.new(1, 0)
		backCorner.Parent = back
		
		local fill = Instance.new("Frame")
		fill.Size = UDim2.fromScale(1, 1)
		fill.BackgroundColor3 = UI_ACCENT_COLOR
		fill.Parent = back
		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(1, 0)
		fillCorner.Parent = fill
		
		local handle = Instance.new("Frame")
		handle.Size = UDim2.fromOffset(12, 12)
		handle.AnchorPoint = Vector2.new(0.5, 0.5)
		handle.Position = UDim2.fromScale(1, 0.5)
		handle.BackgroundColor3 = UI_TEXT_COLOR
		handle.Parent = fill
		local handleCorner = Instance.new("UICorner")
		handleCorner.CornerRadius = UDim.new(1, 0)
		handleCorner.Parent = handleCorner
		
		local value = 1
		
		local function update(input)
			local pos = input.Position.X
			local start = back.AbsolutePosition.X
			local width = back.AbsoluteSize.X
			value = math.clamp((pos - start) / width, 0, 1)
			fill.Size = UDim2.new(value, 0, 1, 0)
			callback()
		end
		
		back.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local conn
				conn = UserInputService.InputChanged:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseMovement then
						update(i)
					end
				end)
				local conn2 = UserInputService.InputEnded:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						conn:Disconnect()
						conn2:Disconnect()
					end
				end)
				update(input)
			end
		end)
		
		return function() return value end, back, fill
	end
	
	local r, g, b = 1, 1, 1
	
	local function updateColor()
		local finalColor = Color3.fromHSV(r(), g(), b())
		colorPreview.BackgroundColor3 = finalColor
		if options.Callback then options.Callback(finalColor) end
	end
	
	r, _, _ = createSlider("H", frame, 40, updateColor)
	g, _, _ = createSlider("S", frame, 65, updateColor)
	b, _, _ = createSlider("V", frame, 90, updateColor)
end

--// Prompt
function GUI:Prompt(options)
	local promptBg = Instance.new("Frame")
	promptBg.Size = UDim2.fromScale(1, 1)
	promptBg.BackgroundColor3 = Color3.new(0, 0, 0)
	promptBg.BackgroundTransparency = 0.5
	promptBg.ZIndex = 10
	promptBg.Parent = self.ScreenGui

	local promptFrame = Instance.new("Frame")
	promptFrame.Size = UDim2.fromScale(0.3, 0.2)
	promptFrame.Position = UDim2.fromScale(0.5, 0.5)
	promptFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	promptFrame.BackgroundColor3 = UI_PRIMARY_COLOR
	promptFrame.Parent = promptBg
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = promptFrame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 30)
	title.BackgroundColor3 = UI_SECONDARY_COLOR
	title.Text = options.Title or "Prompt"
	title.Font = UI_FONT
	title.TextColor3 = UI_TEXT_COLOR
	title.TextSize = 18
	title.Parent = promptFrame

	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1, -20, 0.6, -30)
	text.Position = UDim2.fromOffset(10, 30)
	text.BackgroundTransparency = 1
	text.Text = options.Text or ""
	text.Font = UI_FONT
	text.TextColor3 = UI_TEXT_COLOR
	text.TextSize = 16
	text.TextWrapped = true
	text.Parent = promptFrame

	local buttonContainer = Instance.new("Frame")
	buttonContainer.Size = UDim2.new(1, 0, 0.4, 0)
	buttonContainer.Position = UDim2.new(0, 0, 0.6, 0)
	buttonContainer.BackgroundTransparency = 1
	buttonContainer.Parent = promptFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Horizontal
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	listLayout.Padding = UDim.new(0, 10)
	listLayout.Parent = buttonContainer

	for btnText, callback in pairs(options.Buttons) do
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(0, 100, 0, 30)
		button.BackgroundColor3 = UI_ACCENT_COLOR
		button.Text = btnText
		button.Font = UI_FONT
		button.TextColor3 = UI_TEXT_COLOR
		button.TextSize = 16
		button.Parent = buttonContainer
		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 4)
		btnCorner.Parent = button

		button.MouseButton1Click:Connect(function()
			if callback() and not options.Followup then
				promptBg:Destroy()
			end
		end)
	end
end

--// Notification
function GUI:Notification(options)
	local notifFrame = Instance.new("Frame")
	notifFrame.Size = UDim2.new(0.2, 0, 0, 60)
	notifFrame.Position = UDim2.new(0.5, 0, 0, -60)
	notifFrame.AnchorPoint = Vector2.new(0.5, 0)
	notifFrame.BackgroundColor3 = UI_PRIMARY_COLOR
	notifFrame.ZIndex = 10
	notifFrame.Parent = self.ScreenGui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = notifFrame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -10, 0.5, 0)
	title.Position = UDim2.fromOffset(10, 0)
	title.BackgroundTransparency = 1
	title.Text = options.Title or "Notification"
	title.Font = UI_FONT
	title.TextColor3 = UI_TEXT_COLOR
	title.TextSize = 16
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = notifFrame

	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1, -10, 0.5, 0)
	text.Position = UDim2.new(0, 10, 0.5, 0)
	text.BackgroundTransparency = 1
	text.Text = options.Text or ""
	text.Font = UI_FONT
	text.TextColor3 = Color3.fromRGB(200, 200, 200)
	text.TextSize = 14
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.Parent = notifFrame

	TweenService:Create(notifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, 0, 0.02, 0) }):Play()

	task.delay(options.Duration or 3, function()
		local tween = TweenService:Create(notifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Position = UDim2.new(0.5, 0, 0, -60) })
		tween:Play()
		tween.Completed:Connect(function()
			notifFrame:Destroy()
			if options.Callback then options.Callback() end
		end)
	end)
end

--// Credit
function GUI:Credit(options)
    -- Find or create a dedicated credits tab
    local creditsTab
    for _, tab in ipairs(self.Tabs) do
        if tab.Name == "Credits" then
            creditsTab = tab
            break
        end
    end
    if not creditsTab then
        creditsTab = self:Tab("Credits")
    end

    local frame = createComponentFrame(creditsTab, 80)
    frame.BackgroundColor3 = UI_PRIMARY_COLOR
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -20, 0, 20)
    nameLabel.Position = UDim2.fromOffset(10, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = UI_FONT
    nameLabel.Text = options.Name or "Unknown"
    nameLabel.TextColor3 = UI_ACCENT_COLOR
    nameLabel.TextSize = 18
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = frame
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -20, 0, 20)
    descLabel.Position = UDim2.fromOffset(10, 25)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = UI_FONT
    descLabel.Text = options.Description or ""
    descLabel.TextColor3 = UI_TEXT_COLOR
    descLabel.TextSize = 14
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = frame
    
    local socialText = ""
    if options.V3rm then socialText = socialText .. "V3rm: " .. options.V3rm .. " " end
    if options.Discord then socialText = socialText .. "Discord: " .. options.Discord end
    
    local socialLabel = Instance.new("TextLabel")
    socialLabel.Size = UDim2.new(1, -20, 0, 20)
    socialLabel.Position = UDim2.fromOffset(10, 45)
    socialLabel.BackgroundTransparency = 1
    socialLabel.Font = UI_FONT
    socialLabel.Text = socialText
    socialLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    socialLabel.TextSize = 12
    socialLabel.TextXAlignment = Enum.TextXAlignment.Left
    socialLabel.Parent = frame
end


--// Parent the ScreenGui to the player's PlayerGui
local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local MyGUI = GUI.new()
MyGUI.ScreenGui.Parent = PlayerGui
