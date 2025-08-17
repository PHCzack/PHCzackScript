--[[
    Modular UI Library by Gemini (Upgraded Version)
    Place this script in: StarterPlayer > StarterPlayerScripts
    This is the main library module.

    --// REVISION NOTES //--
    - Added a consistent color palette for easier styling.
    - Differentiated UI elements (Button, Textbox, Dropdown, etc.) with unique styles.
    - Added hover and focus effects for better user feedback and interactivity.
    - Textbox now has an inset border that highlights when focused.
    - Dropdown now has an arrow icon to make its function clear.
]]

--// Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// Main GUI Library Table
local GUI = {}
GUI.__index = GUI

--// NEW: Consistent Color Palette
local Colors = {
    -- Backgrounds
    Main = Color3.fromRGB(30, 30, 30),        -- Main window background
    Header = Color3.fromRGB(25, 25, 25),      -- Header, tab container
    Content = Color3.fromRGB(35, 35, 35),     -- The area where elements are placed
    Element = Color3.fromRGB(50, 50, 50),     -- Default background for most elements
    ElementHover = Color3.fromRGB(65, 65, 65),-- For hover effects
    ElementDarker = Color3.fromRGB(40, 40, 40),-- Used for textbox background

    -- Text
    Text = Color3.fromRGB(220, 220, 220),      -- Primary text color
    TextSecondary = Color3.fromRGB(160, 160, 160),-- For placeholders, etc.

    -- Accents & Borders
    Accent = Color3.fromRGB(80, 120, 220),   -- For sliders, highlights, focus borders
    Border = Color3.fromRGB(60, 60, 60),      -- Default border color
    BorderLight = Color3.fromRGB(80, 80, 80), -- Lighter border
	
	-- Toggle/Switch
	ToggleOn = Color3.fromRGB(75, 180, 75),
	ToggleOff = Color3.fromRGB(100, 100, 100),
	ToggleKnob = Color3.fromRGB(240, 240, 240)
}


--// Main ScreenGui and configuration
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "MainGui"
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MainGui.ResetOnSpawn = false

--// Create the main frame for the UI
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.BackgroundColor3 = Colors.Main
MainFrame.BorderColor3 = Colors.BorderLight
MainFrame.BorderSizePixel = 1 -- Changed for a more subtle look
MainFrame.Active = true
MainFrame.Visible = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = MainGui

--// Corner radius for modern look
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = MainFrame

--// Header for title and dragging
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Colors.Header
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = Header

local bottomFix = Instance.new("Frame")
bottomFix.Size = UDim2.new(1,0,0.5,0)
bottomFix.Position = UDim2.new(0,0,0.5,0)
bottomFix.BackgroundColor3 = Header.BackgroundColor3
bottomFix.BorderSizePixel = 0
bottomFix.Parent = headerCorner

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -100, 1, 0) -- Make space for buttons
Title.Position = UDim2.new(0, 10, 0, 0) -- Added padding
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.Text = "My Awesome Game UI"
Title.TextColor3 = Colors.Text
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

--// Window Controls (Minimize, Zoom, Hide)
local ControlsFrame = Instance.new("Frame")
ControlsFrame.Name = "ControlsFrame"
ControlsFrame.Size = UDim2.new(0, 90, 1, 0)
ControlsFrame.Position = UDim2.new(1, -90, 0, 0)
ControlsFrame.BackgroundTransparency = 1
ControlsFrame.Parent = Header

local controlsLayout = Instance.new("UIListLayout")
controlsLayout.FillDirection = Enum.FillDirection.Horizontal
controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
controlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
controlsLayout.Padding = UDim.new(0, 5)
controlsLayout.Parent = ControlsFrame

local function createControlButton(text)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 20, 0, 20)
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	btn.Text = text
	btn.Font = Enum.Font.SourceSansBold
	btn.TextColor3 = Color3.fromRGB(200, 200, 200)
	btn.TextSize = 14
	btn.Parent = ControlsFrame
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = btn
	return btn
end

local HideButton = createControlButton("X")
local ZoomButton = createControlButton("+")
local MinimizeButton = createControlButton("-")

--// Show UI Button (appears when main UI is hidden)
local ShowButton = Instance.new("TextButton")
ShowButton.Name = "ShowButton"
ShowButton.Size = UDim2.new(0, 100, 0, 30)
ShowButton.Position = UDim2.new(0, 10, 1, -40)
ShowButton.Text = "Show UI (RCtrl)"
ShowButton.BackgroundColor3 = Colors.Header
ShowButton.TextColor3 = Colors.Text
ShowButton.Font = Enum.Font.SourceSans
ShowButton.Visible = false
ShowButton.Parent = MainGui
local showCorner = Instance.new("UICorner")
showCorner.CornerRadius = UDim.new(0, 6)
showCorner.Parent = ShowButton
local showBorder = Instance.new("UIStroke")
showBorder.Color = Colors.BorderLight
showBorder.Thickness = 1
showBorder.Parent = ShowButton

ShowButton.MouseButton1Click:Connect(function()
	MainFrame.Visible = true
	ShowButton.Visible = false
end)

--// Window state variables
local isMinimized = false
local isZoomed = false
local originalSize = MainFrame.Size
local originalPosition = MainFrame.Position
local zoomedSize = UDim2.new(0, 800, 0, 500)

HideButton.MouseButton1Click:Connect(function()
	MainFrame.Visible = false
	ShowButton.Visible = true
end)

MinimizeButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		isZoomed = false -- Can't be zoomed and minimized
		TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, Header.AbsoluteSize.Y)}):Play()
	else
		TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = originalSize}):Play()
	end
end)

ZoomButton.MouseButton1Click:Connect(function()
	isZoomed = not isZoomed
	if isZoomed then
		isMinimized = false -- Can't be minimized and zoomed
		originalSize = MainFrame.Size -- Save current size before zooming
		originalPosition = MainFrame.Position
		TweenService:Create(MainFrame, TweenInfo.new(0.2), {
			Size = zoomedSize,
			Position = UDim2.new(0.5, -zoomedSize.X.Offset/2, 0.5, -zoomedSize.Y.Offset/2)
		}):Play()
	else
		TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = originalSize, Position = originalPosition}):Play()
	end
end)

--// Tab container
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(0, 120, 1, -30)
TabContainer.Position = UDim2.new(0, 0, 0, 30)
TabContainer.BackgroundColor3 = Colors.Header
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.Padding = UDim.new(0, 5)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = TabContainer

--// Content container
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -120, 1, -30)
ContentContainer.Position = UDim2.new(0, 120, 0, 30)
ContentContainer.BackgroundColor3 = Colors.Content
ContentContainer.BorderSizePixel = 0
ContentContainer.Parent = MainFrame

local activeTab = nil
local tabs = {}

--// Dragging Logic
local dragging = false
local dragInput, dragStart, startPos
local function update(input)
	local delta = input.Position - dragStart
	MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

Header.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		if dragging and not isZoomed then -- Don't drag if zoomed
			update(input)
		end
	end
end)

--// Show/Hide Logic
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.RightControl then
		MainFrame.Visible = not MainFrame.Visible
		ShowButton.Visible = not MainFrame.Visible
	end
end)

--// Set PlayerGui
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
MainGui.Parent = playerGui

--// Window Object
function GUI:CreateWindow(title)
	Title.Text = title or "Roblox UI"
	local Window = {}

	function Window:CreateTab(name)
		local Tab = {}

		local contentFrame = Instance.new("ScrollingFrame")
		contentFrame.Name = name
		contentFrame.Size = UDim2.new(1, -10, 1, -10)
		contentFrame.Position = UDim2.new(0, 5, 0, 5)
		contentFrame.BackgroundColor3 = Colors.Content
		contentFrame.BorderSizePixel = 0
		contentFrame.Visible = false
		contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
		contentFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
		contentFrame.ScrollBarThickness = 6
		contentFrame.Parent = ContentContainer

		local contentLayout = Instance.new("UIListLayout")
		contentLayout.Padding = UDim.new(0, 10)
		contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
		contentLayout.Parent = contentFrame

		local function updateCanvasSize()
			contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y)
		end

		contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)

		local tabButton = Instance.new("TextButton")
		tabButton.Name = name .. "Button"
		tabButton.Size = UDim2.new(1, -10, 0, 30)
		tabButton.Position = UDim2.new(0, 5, 0, 0)
		tabButton.BackgroundColor3 = Colors.Element
		tabButton.Text = name
		tabButton.Font = Enum.Font.SourceSans
		tabButton.TextColor3 = Colors.Text
		tabButton.TextSize = 14
		tabButton.Parent = TabContainer

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 4)
		btnCorner.Parent = tabButton

		tabButton.MouseButton1Click:Connect(function()
			if activeTab then
				activeTab.Visible = false
				tabs[activeTab.Name].Button.BackgroundColor3 = Colors.Element -- Use palette
			end
			contentFrame.Visible = true
			tabButton.BackgroundColor3 = Colors.ElementHover -- Use palette
			activeTab = contentFrame
		end)

		tabs[name] = {
			Frame = contentFrame,
			Button = tabButton,
			Layout = contentLayout
		}

		if not activeTab then
			contentFrame.Visible = true
			tabButton.BackgroundColor3 = Colors.ElementHover -- Use palette
			activeTab = contentFrame
		end

		--// Component Functions
		function Tab:Button(options)
			--// CHANGED: Added hover effects and a border for better visibility.
			local btn = Instance.new("TextButton")
			btn.Name = options.Name
			btn.Size = UDim2.new(1, 0, 0, 35)
			btn.BackgroundColor3 = Colors.Element
			btn.Text = options.Name
			btn.Font = Enum.Font.SourceSans
			btn.TextColor3 = Colors.Text
			btn.TextSize = 16
			btn.Parent = contentFrame
			
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 4)
			corner.Parent = btn
			
			local border = Instance.new("UIStroke")
			border.Color = Colors.Border
			border.Thickness = 1
			border.Parent = btn

			btn.MouseEnter:Connect(function()
				TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.ElementHover}):Play()
			end)
			btn.MouseLeave:Connect(function()
				TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Element}):Play()
			end)
			
			btn.MouseButton1Click:Connect(function() if options.Callback then options.Callback() end end)
		end

		function Tab:Toggle(options)
			-- This component already had a great, distinct design. Just updated colors.
			local state = options.StartingState or false

			local container = Instance.new("Frame")
			container.Name = options.Name
			container.Size = UDim2.new(1, 0, 0, 30)
			container.BackgroundTransparency = 1
			container.Parent = contentFrame

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -60, 1, 0)
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.SourceSans
			label.Text = options.Name
			label.TextColor3 = Colors.Text
			label.TextSize = 16
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = container

			local switchTrack = Instance.new("Frame")
			switchTrack.Size = UDim2.new(0, 50, 0, 24)
			switchTrack.Position = UDim2.new(1, -50, 0.5, -12)
			switchTrack.BackgroundColor3 = state and Colors.ToggleOn or Colors.ToggleOff
			switchTrack.Parent = container
			local trackCorner = Instance.new("UICorner")
			trackCorner.CornerRadius = UDim.new(1, 0)
			trackCorner.Parent = switchTrack

			local switchKnob = Instance.new("Frame")
			switchKnob.Size = UDim2.new(0, 20, 0, 20)
			switchKnob.Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
			switchKnob.BackgroundColor3 = Colors.ToggleKnob
			switchKnob.Parent = switchTrack
			local knobCorner = Instance.new("UICorner")
			knobCorner.CornerRadius = UDim.new(1, 0)
			knobCorner.Parent = switchKnob

			local clickDetector = Instance.new("TextButton")
			clickDetector.Size = UDim2.new(1, 0, 1, 0)
			clickDetector.BackgroundTransparency = 1
			clickDetector.Text = ""
			clickDetector.Parent = switchTrack

			clickDetector.MouseButton1Click:Connect(function()
				state = not state
				local trackColor = state and Colors.ToggleOn or Colors.ToggleOff
				local knobPos = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)

				TweenService:Create(switchTrack, TweenInfo.new(0.2), {BackgroundColor3 = trackColor}):Play()
				TweenService:Create(switchKnob, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = knobPos}):Play()

				if options.Callback then
					options.Callback(state)
				end
			end)
		end

		function Tab:Textbox(options)
			--// CHANGED: Added an inner border and focus effect to look like a proper text field.
			local container = Instance.new("Frame")
			container.Name = options.Name
			container.Size = UDim2.new(1, 0, 0, 35)
			container.BackgroundTransparency = 1
			container.Parent = contentFrame
			
			local textbox = Instance.new("TextBox")
			textbox.Size = UDim2.new(1, 0, 1, 0)
			textbox.BackgroundColor3 = Colors.ElementDarker -- Darker background
			textbox.PlaceholderText = options.Name
			textbox.Font = Enum.Font.SourceSans
			textbox.TextColor3 = Colors.Text
			textbox.PlaceholderColor3 = Colors.TextSecondary
			textbox.TextSize = 14
			textbox.ClearTextOnFocus = false
			textbox.Parent = container
			
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 4)
			corner.Parent = textbox
			
			local border = Instance.new("UIStroke")
			border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border -- Makes it an inner border
			border.Color = Colors.Border
			border.Thickness = 1
			border.Parent = textbox
			
			-- Focus effect
			textbox.FocusGained:Connect(function()
				TweenService:Create(border, TweenInfo.new(0.2), {Color = Colors.Accent}):Play()
			end)
			textbox.FocusLost:Connect(function(enterPressed)
				TweenService:Create(border, TweenInfo.new(0.2), {Color = Colors.Border}):Play()
				if enterPressed and options.Callback then options.Callback(textbox.Text) end
			end)
		end

		function Tab:Slider(options)
			-- This component was also well-designed. Just updated colors for consistency.
			local container = Instance.new("Frame")
			container.Name = options.Name
			container.Size = UDim2.new(1, 0, 0, 40)
			container.BackgroundTransparency = 1
			container.Parent = contentFrame

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, 0, 0, 20)
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.SourceSans
			label.TextColor3 = Colors.Text
			label.TextSize = 16
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = container

			local sliderFrame = Instance.new("Frame")
			sliderFrame.Size = UDim2.new(1, 0, 0, 10)
			sliderFrame.Position = UDim2.new(0, 0, 0, 25)
			sliderFrame.BackgroundColor3 = Colors.Element -- Use palette
			sliderFrame.Parent = container
			local sCorner = Instance.new("UICorner")
			sCorner.CornerRadius = UDim.new(0, 5)
			sCorner.Parent = sliderFrame

			local fill = Instance.new("Frame")
			fill.BackgroundColor3 = Colors.Accent -- Use palette
			fill.BorderSizePixel = 0
			fill.Parent = sliderFrame
			local fCorner = Instance.new("UICorner")
			fCorner.CornerRadius = UDim.new(0, 5)
			fCorner.Parent = fill

			local handle = Instance.new("TextButton")
			handle.Size = UDim2.new(0, 16, 0, 16)
			handle.Position = UDim2.new(0, -8, 0.5, -8)
			handle.BackgroundColor3 = Colors.ToggleKnob -- Use palette
			handle.Text = ""
			handle.ZIndex = 2
			handle.Parent = fill
			local hCorner = Instance.new("UICorner")
			hCorner.CornerRadius = UDim.new(1, 0)
			hCorner.Parent = handle

			local min, max, default = options.Min or 0, options.Max or 100, options.Default or 50
			local value = default

			local function updateSlider(percent)
				percent = math.clamp(percent, 0, 1)
				value = min + (max - min) * percent
				fill.Size = UDim2.new(percent, 0, 1, 0)
				label.Text = string.format("%s: %.2f", options.Name, value)
				if options.Callback then
					options.Callback(value)
				end
			end

			updateSlider((default - min) / (max - min))

			local dragConnection
			handle.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragConnection = UserInputService.InputChanged:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
							local mousePos = UserInputService:GetMouseLocation()
							local relativePos = mousePos.X - sliderFrame.AbsolutePosition.X
							local percent = math.clamp(relativePos / sliderFrame.AbsoluteSize.X, 0, 1)
							updateSlider(percent)
						end
					end)
				end
			end)

			handle.InputEnded:Connect(function()
				if dragConnection then
					dragConnection:Disconnect()
				end
			end)
		end

		function Tab:Keybind(options)
			--// CHANGED: Minor style update to differentiate from a standard button.
			local container = Instance.new("Frame")
			container.Name = options.Name
			container.Size = UDim2.new(1, 0, 0, 30)
			container.BackgroundTransparency = 1
			container.Parent = contentFrame
			
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(0.6, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.SourceSans
			label.Text = options.Name
			label.TextColor3 = Colors.Text
			label.TextSize = 16
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = container
			
			local keybindButton = Instance.new("TextButton")
			keybindButton.Size = UDim2.new(0.4, -5, 1, 0)
			keybindButton.Position = UDim2.new(0.6, 5, 0, 0)
			keybindButton.BackgroundColor3 = Colors.Element
			keybindButton.Text = options.Keybind or "[ ... ]"
			keybindButton.Font = Enum.Font.SourceSans
			keybindButton.TextColor3 = Colors.TextSecondary
			keybindButton.TextSize = 14
			keybindButton.Parent = container
			
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 4)
			corner.Parent = keybindButton
			
			local border = Instance.new("UIStroke")
			border.Color = Colors.Border
			border.Parent = keybindButton
			
			keybindButton.MouseButton1Click:Connect(function()
				keybindButton.Text = "[ ... ]"
				keybindButton.TextColor3 = Colors.Accent
				local connection
				connection = UserInputService.InputBegan:Connect(function(input, gp)
					if gp then return end
					if input.UserInputType == Enum.UserInputType.Keyboard then
						keybindButton.Text = input.KeyCode.Name
						keybindButton.TextColor3 = Colors.TextSecondary
						connection:Disconnect()
					end
				end)
			end)
		end

		function Tab:Dropdown(options)
			--// CHANGED: Added a dropdown arrow icon for clear identification.
			local Dropdown = {}
			Dropdown.SelectedOptions = {}
			-- Populate initial selections
			for _, opt in ipairs(options.CurrentOptions or {}) do
				Dropdown.SelectedOptions[opt] = true
			end

			local isOpen = false

			local container = Instance.new("Frame")
			container.Name = options.Name
			container.Size = UDim2.new(1, 0, 0, 35)
			container.BackgroundTransparency = 1
			container.ZIndex = 2
			container.Parent = contentFrame

			local mainButton = Instance.new("TextButton")
			mainButton.Name = "MainButton"
			mainButton.Size = UDim2.new(1, 0, 1, 0)
			mainButton.BackgroundColor3 = Colors.Element
			mainButton.Font = Enum.Font.SourceSans
			mainButton.TextColor3 = Colors.Text
			mainButton.TextSize = 14
			mainButton.TextXAlignment = Enum.TextXAlignment.Left -- Align left for icon
			mainButton.Parent = container
			
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 4)
			corner.Parent = mainButton
			
			local border = Instance.new("UIStroke")
			border.Color = Colors.Border
			border.Thickness = 1
			border.Parent = mainButton
			
			--// NEW: Padding for text and dropdown arrow icon
			local padding = Instance.new("UIPadding")
			padding.PaddingLeft = UDim.new(0, 10)
			padding.Parent = mainButton
			
			local arrow = Instance.new("TextLabel")
			arrow.Name = "Arrow"
			arrow.Size = UDim2.new(0, 20, 1, 0)
			arrow.Position = UDim2.new(1, -25, 0, 0)
			arrow.BackgroundTransparency = 1
			arrow.Font = Enum.Font.SourceSansBold
			arrow.Text = "▼"
			arrow.TextColor3 = Colors.TextSecondary
			arrow.TextSize = 16
			arrow.Parent = mainButton
			
			mainButton.MouseEnter:Connect(function() if not isOpen then TweenService:Create(mainButton, TweenInfo.new(0.2), {BackgroundColor3 = Colors.ElementHover}):Play() end end)
			mainButton.MouseLeave:Connect(function() if not isOpen then TweenService:Create(mainButton, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Element}):Play() end end)
			
			local dropdownFrame = Instance.new("ScrollingFrame")
			dropdownFrame.Name = "DropdownFrame"
			dropdownFrame.Size = UDim2.new(1, 0, 0, 120)
			dropdownFrame.Position = UDim2.new(0, 0, 1, 5)
			dropdownFrame.BackgroundColor3 = Colors.ElementDarker
			dropdownFrame.BorderSizePixel = 0
			dropdownFrame.Visible = false
			dropdownFrame.ZIndex = 3
			dropdownFrame.ClipsDescendants = true
			dropdownFrame.Parent = container
			
			local dCorner = Instance.new("UICorner")
			dCorner.CornerRadius = UDim.new(0, 4)
			dCorner.Parent = dropdownFrame
			
			local dBorder = Instance.new("UIStroke")
			dBorder.Color = Colors.BorderLight
			dBorder.Thickness = 1
			dBorder.Parent = dropdownFrame
			
			local dropdownLayout = Instance.new("UIListLayout")
			dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
			dropdownLayout.Padding = UDim.new(0, 2)
			dropdownLayout.Parent = dropdownFrame

			local function updateMainButtonText()
				local count = 0
				local selectedName = ""
				for name, _ in pairs(Dropdown.SelectedOptions) do 
					count += 1
					selectedName = name
				end
				
				if count == 0 then
					mainButton.Text = options.Name
				elseif count == 1 then
					mainButton.Text = selectedName
				else
					mainButton.Text = count .. " items selected"
				end
			end

			local function refreshOptions(newOptions)
				for _, child in ipairs(dropdownFrame:GetChildren()) do
					if child:IsA("Frame") then child:Destroy() end
				end
				for _, optionName in ipairs(newOptions) do
					local optionFrame = Instance.new("Frame")
					optionFrame.Size = UDim2.new(1, -4, 0, 30)
					optionFrame.Position = UDim2.new(0, 2, 0, 0)
					optionFrame.BackgroundTransparency = 1
					optionFrame.Parent = dropdownFrame

					local checkbox = Instance.new("TextLabel")
					checkbox.Size = UDim2.new(0, 20, 0, 20)
					checkbox.Position = UDim2.new(0, 5, 0.5, -10)
					checkbox.BackgroundColor3 = Colors.Border
					checkbox.Text = Dropdown.SelectedOptions[optionName] and "✔" or "" -- Checkmark icon
					checkbox.Font = Enum.Font.SourceSansBold
					checkbox.TextColor3 = Colors.Text
					checkbox.TextSize = 18
					checkbox.Parent = optionFrame
					local checkCorner = Instance.new("UICorner")
					checkCorner.CornerRadius = UDim.new(0, 4)
					checkCorner.Parent = checkbox

					local optionLabel = Instance.new("TextLabel")
					optionLabel.Size = UDim2.new(1, -35, 1, 0)
					optionLabel.Position = UDim2.new(0, 30, 0, 0)
					optionLabel.BackgroundTransparency = 1
					optionLabel.Text = optionName
					optionLabel.Font = Enum.Font.SourceSans
					optionLabel.TextColor3 = Colors.Text
					optionLabel.TextSize = 14
					optionLabel.TextXAlignment = Enum.TextXAlignment.Left
					optionLabel.Parent = optionFrame

					local clickBtn = Instance.new("TextButton")
					clickBtn.Size = UDim2.new(1,0,1,0)
					clickBtn.BackgroundTransparency = 1
					clickBtn.Text = ""
					clickBtn.Parent = optionFrame

					clickBtn.MouseButton1Click:Connect(function()
						if Dropdown.SelectedOptions[optionName] then
							Dropdown.SelectedOptions[optionName] = nil
						else
							Dropdown.SelectedOptions[optionName] = true
						end
						checkbox.Text = Dropdown.SelectedOptions[optionName] and "✔" or ""
						updateMainButtonText()
						if options.Callback then
							options.Callback(Dropdown.SelectedOptions)
						end
					end)
				end
				dropdownFrame.CanvasSize = UDim2.new(0,0,0,dropdownLayout.AbsoluteContentSize.Y)
			end

			mainButton.MouseButton1Click:Connect(function()
				isOpen = not isOpen
				dropdownFrame.Visible = isOpen
				container.ZIndex = isOpen and 4 or 2
				TweenService:Create(arrow, TweenInfo.new(0.2), {Rotation = isOpen and 180 or 0}):Play()
			end)

			function Dropdown:Refresh(newOptions, newCurrent)
				options.Options = newOptions
				Dropdown.SelectedOptions = {}
				for _, opt in ipairs(newCurrent or {}) do Dropdown.SelectedOptions[opt] = true end
				refreshOptions(newOptions)
				updateMainButtonText()
			end

			function Dropdown:Set(selections)
				Dropdown.SelectedOptions = {}
				for _, opt in ipairs(selections) do
					if table.find(options.Options, opt) then
						Dropdown.SelectedOptions[opt] = true
					end
				end
				refreshOptions(options.Options)
				updateMainButtonText()
			end

			refreshOptions(options.Options)
			updateMainButtonText()
			return Dropdown
		end

		return Tab
	end

	return Window
end

return GUI
