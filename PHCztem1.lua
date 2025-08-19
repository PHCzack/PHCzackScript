--[[
    Enhanced GUI Library

    - Author: Gemini
    - Date: August 19, 2025
    - Description: A modular and themeable GUI library for Roblox.

    Features:
    - Centralized theme configuration for easy customization.
    - Draggable and interactive window with minimize, zoom, and hide controls.
    - Tab-based navigation.
    - A suite of components: Button, Toggle, Textbox, Slider, Keybind, Dropdown.
    - Optimized and reusable utility functions to reduce redundancy.
]]

--// Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

--// Type Definitions for Luau
type optionsTable = {[string]: any}
type tabObject = {
	Button: (options: optionsTable) -> (),
	Toggle: (options: optionsTable) -> (),
	Textbox: (options: optionsTable) -> (),
	Slider: (options: optionsTable) -> (),
	Keybind: (options: optionsTable) -> (),
	Dropdown: (options: optionsTable) -> any,
}
type windowObject = {
	CreateTab: (name: string) -> tabObject,
}

--// Centralized Theme and Configuration
local Theme = {
	-- Fonts
	Font = Enum.Font.SourceSans,
	BoldFont = Enum.Font.SourceSansBold,
	TextSize = 14,
	TitleSize = 16,

	-- Colors
	Background = Color3.fromRGB(30, 30, 30),
	Primary = Color3.fromRGB(25, 25, 25),
	Secondary = Color3.fromRGB(35, 35, 35),
	Tertiary = Color3.fromRGB(50, 50, 50),
	Accent = Color3.fromRGB(80, 120, 220),

	-- Text Colors
	Text = Color3.fromRGB(220, 220, 220),
	TextDisabled = Color3.fromRGB(150, 150, 150),
	
	-- Interactive Colors
	Interactable = Color3.fromRGB(45, 45, 45),
	InteractableHover = Color3.fromRGB(60, 60, 60),
	InteractableActive = Color3.fromRGB(65, 65, 65),
	
	-- Special
	Success = Color3.fromRGB(75, 180, 75),
	Disabled = Color3.fromRGB(100, 100, 100),
	Border = Color3.fromRGB(50, 50, 50),

	-- Sizing & Styling
	CornerRadius = UDim.new(0, 4),
	WindowCornerRadius = UDim.new(0, 8),
	BorderSize = 2,
}

--// Main GUI Library Table
local GUI = {}
GUI.__index = GUI

--// Utility Functions
--- Creates a new UI instance with specified properties and an optional UICorner.
local function Create(className: string, properties: optionsTable): GuiObject
	local obj = Instance.new(className)
	local cornerRadius = properties.CornerRadius
	properties.CornerRadius = nil -- Avoids error when applying properties

	for prop, value in pairs(properties) do
		obj[prop] = value
	end
	
	if cornerRadius then
		Create("UICorner", {
			CornerRadius = cornerRadius,
			Parent = obj,
		})
	end
	
	return obj
end

--- Makes a GuiObject draggable.
local function MakeDraggable(target: GuiObject, container: GuiObject)
	local dragging = false
	local inputConnection: RBXScriptConnection
	local dragStart: Vector2
	local startPos: UDim2

	target.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = container.Position

			inputConnection = UserInputService.InputChanged:Connect(function(changedInput)
				if (changedInput.UserInputType == Enum.UserInputType.MouseMovement or changedInput.UserInputType == Enum.UserInputType.Touch) and dragging then
					local delta = changedInput.Position - dragStart
					container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
				end
			end)
		end
	end)

	target.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			if inputConnection then
				inputConnection:Disconnect()
			end
		end
	end)
end

--// Core UI Setup
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local MainGui = Create("ScreenGui", {
	Name = "MainGui",
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	ResetOnSpawn = false,
	Parent = playerGui,
})

local MainFrame = Create("Frame", {
	Name = "MainFrame",
	Size = UDim2.new(0, 550, 0, 350),
	Position = UDim2.new(0.5, -275, 0.5, -175),
	BackgroundColor3 = Theme.Background,
	BorderColor3 = Theme.Border,
	BorderSizePixel = Theme.BorderSize,
	Active = true,
	Visible = true,
	ClipsDescendants = true,
	CornerRadius = Theme.WindowCornerRadius,
	Parent = MainGui,
})

local Header = Create("Frame", {
	Name = "Header",
	Size = UDim2.new(1, 0, 0, 30),
	BackgroundColor3 = Theme.Primary,
	BorderSizePixel = 0,
	Parent = MainFrame,
})

-- Partial corner radius for the header
Create("UICorner", { CornerRadius = Theme.WindowCornerRadius, Parent = Header })
Create("Frame", {
	Size = UDim2.new(1, 0, 0.5, 0),
	Position = UDim2.new(0, 0, 0.5, 0),
	BackgroundColor3 = Header.BackgroundColor3,
	BorderSizePixel = 0,
	Parent = Header,
})

local Title = Create("TextLabel", {
	Name = "Title",
	Size = UDim2.new(1, -100, 1, 0),
	Position = UDim2.new(0, 10, 0, 0),
	BackgroundTransparency = 1,
	Font = Theme.BoldFont,
	TextColor3 = Theme.Text,
	TextSize = Theme.TitleSize,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = Header,
})

--// Window Controls
local ControlsFrame = Create("Frame", {
	Name = "ControlsFrame",
	Size = UDim2.new(0, 90, 1, 0),
	Position = UDim2.new(1, -90, 0, 0),
	BackgroundTransparency = 1,
	Parent = Header,
})

Create("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0, 5),
	Parent = ControlsFrame,
})

local function CreateControlButton(text: string): TextButton
	return Create("TextButton", {
		Size = UDim2.new(0, 20, 0, 20),
		BackgroundColor3 = Theme.Interactable,
		Text = text,
		Font = Theme.BoldFont,
		TextColor3 = Theme.Text,
		TextSize = Theme.TextSize,
		CornerRadius = Theme.CornerRadius,
		Parent = ControlsFrame,
	})
end

local HideButton = CreateControlButton("X")
local ZoomButton = CreateControlButton("+")
local MinimizeButton = CreateControlButton("-")

--// Show UI Button (when main UI is hidden)
local ShowButton = Create("TextButton", {
	Name = "ShowButton",
	Size = UDim2.new(0, 100, 0, 30),
	Position = UDim2.new(0, 10, 0, 10),
	Text = "Show UI",
	BackgroundColor3 = Theme.Primary,
	TextColor3 = Theme.Text,
	Font = Theme.Font,
	Visible = false,
	ZIndex = 10,
	CornerRadius = UDim.new(0, 6),
	Parent = MainGui,
})

--// Window State and Logic
local isMinimized = false
local isZoomed = false
local originalSize = MainFrame.Size
local originalPosition = MainFrame.Position
local zoomedSize = UDim2.new(0, 800, 0, 500)
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

HideButton.MouseButton1Click:Connect(function()
	MainFrame.Visible = false
	ShowButton.Visible = true
end)

ShowButton.MouseButton1Click:Connect(function()
	MainFrame.Visible = true
	ShowButton.Visible = false
end)

MinimizeButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		isZoomed = false
		local minimizedSize = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, Header.AbsoluteSize.Y)
		TweenService:Create(MainFrame, tweenInfo, { Size = minimizedSize }):Play()
	else
		TweenService:Create(MainFrame, tweenInfo, { Size = originalSize }):Play()
	end
end)

ZoomButton.MouseButton1Click:Connect(function()
	isZoomed = not isZoomed
	if isZoomed then
		isMinimized = false
		originalSize = MainFrame.Size
		originalPosition = MainFrame.Position
		TweenService:Create(MainFrame, tweenInfo, {
			Size = zoomedSize,
			Position = UDim2.new(0.5, -zoomedSize.X.Offset / 2, 0.5, -zoomedSize.Y.Offset / 2)
		}):Play()
	else
		TweenService:Create(MainFrame, tweenInfo, { Size = originalSize, Position = originalPosition }):Play()
	end
end)

--// Tab and Content Containers
local TabContainer = Create("Frame", {
	Name = "TabContainer",
	Size = UDim2.new(0, 120, 1, -30),
	Position = UDim2.new(0, 0, 0, 30),
	BackgroundColor3 = Theme.Primary,
	BorderSizePixel = 0,
	Parent = MainFrame,
})

Create("UIListLayout", {
	Padding = UDim.new(0, 5),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = TabContainer,
})

local ContentContainer = Create("Frame", {
	Name = "ContentContainer",
	Size = UDim2.new(1, -120, 1, -30),
	Position = UDim2.new(0, 120, 0, 30),
	BackgroundColor3 = Theme.Secondary,
	BorderSizePixel = 0,
	Parent = MainFrame,
})

--// Global State
local activeTab: ScrollingFrame | nil = nil
local tabs: {[string]: {Frame: ScrollingFrame, Button: TextButton, Layout: UIListLayout}} = {}

--// Input Handling
MakeDraggable(Header, MainFrame)
MakeDraggable(ShowButton, ShowButton)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then return end
	if input.KeyCode == Enum.KeyCode.RightControl then
		MainFrame.Visible = not MainFrame.Visible
		ShowButton.Visible = not MainFrame.Visible
	end
end)

--// API Definition
function GUI:CreateWindow(title: string): windowObject
	Title.Text = title or "UI Library"
	local Window: windowObject = { CreateTab = function() return {} end } -- Stub

	function Window:CreateTab(name: string): tabObject
		local Tab: tabObject = {}

		local contentFrame = Create("ScrollingFrame", {
			Name = name,
			Size = UDim2.new(1, -10, 1, -10),
			Position = UDim2.new(0, 5, 0, 5),
			BackgroundColor3 = Theme.Secondary,
			BorderSizePixel = 0,
			Visible = false,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollBarImageColor3 = Theme.Disabled,
			ScrollBarThickness = 6,
			Parent = ContentContainer,
		})

		local contentLayout = Create("UIListLayout", {
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = contentFrame,
		})
		
		contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
		end)

		local tabButton = Create("TextButton", {
			Name = name .. "Button",
			Size = UDim2.new(1, -10, 0, 30),
			Position = UDim2.new(0, 5, 0, 0),
			BackgroundColor3 = Theme.Interactable,
			Text = name,
			Font = Theme.Font,
			TextColor3 = Theme.Text,
			TextSize = Theme.TextSize,
			CornerRadius = Theme.CornerRadius,
			Parent = TabContainer,
		})

		tabButton.MouseButton1Click:Connect(function()
			if activeTab then
				activeTab.Visible = false
				tabs[activeTab.Name].Button.BackgroundColor3 = Theme.Interactable
			end
			contentFrame.Visible = true
			tabButton.BackgroundColor3 = Theme.InteractableActive
			activeTab = contentFrame
		end)
		
		tabs[name] = {
			Frame = contentFrame,
			Button = tabButton,
			Layout = contentLayout
		}
		
		if not activeTab then
			task.defer(function() -- Defer to ensure all initial tabs are created
				tabButton:MouseButton1Click()
			end)
		end

		--// Component Functions
		function Tab:Button(options: optionsTable)
			local btn = Create("TextButton", {
				Name = options.Name or "Button",
				Size = UDim2.new(1, 0, 0, 35),
				BackgroundColor3 = Theme.Tertiary,
				Text = options.Name or "Button",
				Font = Theme.Font,
				TextColor3 = Theme.Text,
				TextSize = Theme.TitleSize,
				CornerRadius = Theme.CornerRadius,
				Parent = contentFrame,
			})
			if options.Callback then
				btn.MouseButton1Click:Connect(options.Callback)
			end
		end
		
		function Tab:Toggle(options: optionsTable)
			local state = options.StartingState or false
			
			local container = Create("Frame", {
				Name = options.Name or "Toggle",
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundTransparency = 1,
				Parent = contentFrame,
			})

			Create("TextLabel", {
				Size = UDim2.new(1, -60, 1, 0),
				BackgroundTransparency = 1,
				Font = Theme.Font,
				Text = options.Name or "Toggle",
				TextColor3 = Theme.Text,
				TextSize = Theme.TitleSize,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = container,
			})
			
			local switchTrack = Create("Frame", {
				Size = UDim2.new(0, 50, 0, 24),
				Position = UDim2.new(1, -50, 0.5, -12),
				BackgroundColor3 = state and Theme.Success or Theme.Disabled,
				CornerRadius = UDim.new(1, 0),
				Parent = container,
			})
			
			local switchKnob = Create("Frame", {
				Size = UDim2.new(0, 20, 0, 20),
				Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10),
				BackgroundColor3 = Color3.fromRGB(240, 240, 240),
				CornerRadius = UDim.new(1, 0),
				Parent = switchTrack,
			})
			
			local clickDetector = Create("TextButton", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = "",
				Parent = switchTrack,
			})

			clickDetector.MouseButton1Click:Connect(function()
				state = not state
				local trackColor = state and Theme.Success or Theme.Disabled
				local knobPos = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
				
				TweenService:Create(switchTrack, tweenInfo, { BackgroundColor3 = trackColor }):Play()
				TweenService:Create(switchKnob, tweenInfo, { Position = knobPos }):Play()
				
				if options.Callback then
					task.spawn(options.Callback, state)
				end
			end)
		end
		
		function Tab:Textbox(options: optionsTable)
			local textbox = Create("TextBox", {
				Name = options.Name or "Textbox",
				Size = UDim2.new(1, 0, 0, 35),
				BackgroundColor3 = Theme.Tertiary,
				PlaceholderText = options.Name or "Enter text...",
				Font = Theme.Font,
				TextColor3 = Theme.Text,
				PlaceholderColor3 = Theme.TextDisabled,
				TextSize = Theme.TextSize,
				ClearTextOnFocus = false,
				CornerRadius = Theme.CornerRadius,
				Parent = contentFrame,
			})

			textbox.FocusLost:Connect(function(enterPressed)
				if enterPressed and options.Callback then
					task.spawn(options.Callback, textbox.Text)
				end
			end)
		end
		
		function Tab:Slider(options: optionsTable)
			local min, max, default = options.Min or 0, options.Max or 100, options.Default or 50
			local value = default

			local container = Create("Frame", {
				Name = options.Name or "Slider",
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundTransparency = 1,
				Parent = contentFrame,
			})
			
			local label = Create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 20),
				BackgroundTransparency = 1,
				Font = Theme.Font,
				TextColor3 = Theme.Text,
				TextSize = Theme.TitleSize,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = container,
			})
			
			local sliderFrame = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 10),
				Position = UDim2.new(0, 0, 0, 25),
				BackgroundColor3 = Theme.Tertiary,
				CornerRadius = UDim.new(1, 0),
				Parent = container,
			})
			
			local fill = Create("Frame", {
				BackgroundColor3 = Theme.Accent,
				BorderSizePixel = 0,
				CornerRadius = UDim.new(1, 0),
				Parent = sliderFrame,
			})
			
			local handle = Create("TextButton", {
				Size = UDim2.new(0, 16, 0, 16),
				BackgroundColor3 = Theme.Text,
				Text = "",
				ZIndex = 2,
				CornerRadius = UDim.new(1, 0),
				Parent = fill,
			})

			local function UpdateSlider(percent: number)
				percent = math.clamp(percent, 0, 1)
				value = min + (max - min) * percent
				fill.Size = UDim2.new(percent, 0, 1, 0)
				handle.Position = UDim2.new(1, -8, 0.5, -8) -- Center handle
				label.Text = string.format("%s: %.2f", options.Name or "Slider", value)
				if options.Callback then task.spawn(options.Callback, value) end
			end

			UpdateSlider((default - min) / (max - min))
			
			local dragConnection: RBXScriptConnection
			handle.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragConnection = UserInputService.InputChanged:Connect(function(changedInput)
						if changedInput.UserInputType == Enum.UserInputType.MouseMovement or changedInput.UserInputType == Enum.UserInputType.Touch then
							local relativePos = changedInput.Position.X - sliderFrame.AbsolutePosition.X
							local percent = relativePos / sliderFrame.AbsoluteSize.X
							UpdateSlider(percent)
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
		
		function Tab:Keybind(options: optionsTable)
			local isBinding = false
			local bindConnection: RBXScriptConnection

			local container = Create("Frame", {
				Name = options.Name or "Keybind",
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundTransparency = 1,
				Parent = contentFrame,
			})

			Create("TextLabel", {
				Size = UDim2.new(0.6, 0, 1, 0),
				BackgroundTransparency = 1,
				Font = Theme.Font,
				Text = options.Name or "Keybind",
				TextColor3 = Theme.Text,
				TextSize = Theme.TitleSize,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = container,
			})
			
			local keybindButton = Create("TextButton", {
				Size = UDim2.new(0.4, -5, 1, 0),
				Position = UDim2.new(0.6, 5, 0, 0),
				BackgroundColor3 = Theme.Tertiary,
				Text = options.Keybind or "...",
				Font = Theme.Font,
				TextColor3 = Theme.Text,
				TextSize = Theme.TextSize,
				CornerRadius = Theme.CornerRadius,
				Parent = container,
			})
			
			keybindButton.MouseButton1Click:Connect(function()
				isBinding = not isBinding
				if isBinding then
					keybindButton.Text = "..."
					bindConnection = UserInputService.InputBegan:Connect(function(input, gp)
						if gp then return end
						if input.UserInputType == Enum.UserInputType.Keyboard then
							keybindButton.Text = input.KeyCode.Name
							if options.Callback then task.spawn(options.Callback, input.KeyCode.Name) end
							bindConnection:Disconnect()
							isBinding = false
						end
					end)
				else
					keybindButton.Text = options.Keybind or "..."
					if bindConnection then bindConnection:Disconnect() end
				end
			end)
		end
		
		function Tab:Dropdown(options: optionsTable)
			local DropdownAPI = {}
			local currentOption = options.CurrentOption or (options.Options and options.Options[1]) or ""
			local isOpen = false
			local outsideClickListener: RBXScriptConnection

			local container = Create("Frame", {
				Name = options.Name or "Dropdown",
				Size = UDim2.new(1, 0, 0, 35),
				BackgroundTransparency = 1,
				ZIndex = 2,
				Parent = contentFrame,
			})

			local mainButton = Create("TextButton", {
				Name = "MainButton",
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundColor3 = Theme.Tertiary,
				Text = currentOption,
				Font = Theme.Font,
				TextColor3 = Theme.Text,
				TextSize = Theme.TextSize,
				CornerRadius = Theme.CornerRadius,
				Parent = container,
			})

			local dropdownFrame = Create("ScrollingFrame", {
				Name = "DropdownFrame",
				Size = UDim2.new(1, 0, 0, 120),
				Position = UDim2.new(0, 0, 1, 5),
				BackgroundColor3 = Theme.Interactable,
				BorderSizePixel = 1,
				BorderColor3 = Theme.InteractableHover,
				Visible = false,
				ZIndex = 3,
				ClipsDescendants = true,
				CornerRadius = Theme.CornerRadius,
				Parent = container,
			})
			
			local dropdownLayout = Create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = dropdownFrame,
			})

			local function CloseDropdown()
				isOpen = false
				dropdownFrame.Visible = false
				container.ZIndex = 2
				if outsideClickListener then outsideClickListener:Disconnect() end
			end

			local function RefreshOptions(newOptions: {string})
				for _, child in ipairs(dropdownFrame:GetChildren()) do
					if child:IsA("UIListLayout") or child:IsA("UICorner") then continue end
					child:Destroy()
				end

				for _, optionName in ipairs(newOptions) do
					local optionButton = Create("TextButton", {
						Name = optionName,
						Size = UDim2.new(1, -10, 0, 30),
						Position = UDim2.new(0, 5, 0, 0),
						BackgroundColor3 = Theme.Interactable,
						Text = optionName,
						Font = Theme.Font,
						TextColor3 = Theme.Text,
						TextSize = Theme.TextSize,
						Parent = dropdownFrame,
					})
					optionButton.MouseEnter:Connect(function() optionButton.BackgroundColor3 = Theme.InteractableHover end)
					optionButton.MouseLeave:Connect(function() optionButton.BackgroundColor3 = Theme.Interactable end)
					optionButton.MouseButton1Click:Connect(function()
						currentOption = optionName
						mainButton.Text = optionName
						CloseDropdown()
						if options.Callback then task.spawn(options.Callback, optionName) end
					end)
				end
				dropdownFrame.CanvasSize = UDim2.new(0, 0, 0, dropdownLayout.AbsoluteContentSize.Y)
			end

			mainButton.MouseButton1Click:Connect(function()
				isOpen = not isOpen
				dropdownFrame.Visible = isOpen
				container.ZIndex = isOpen and 10 or 2
				if isOpen then
					outsideClickListener = UserInputService.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							local mousePos = UserInputService:GetMouseLocation()
							local guiAtPos = playerGui:GetGuiObjectsAtPosition(mousePos.X, mousePos.Y)
							local isClickOnDropdown = false
							for _, v in ipairs(guiAtPos) do
								if v:IsDescendantOf(container) then
									isClickOnDropdown = true
									break
								end
							end
							if not isClickOnDropdown then
								CloseDropdown()
							end
						end
					end)
				else
					CloseDropdown()
				end
			end)
			
			function DropdownAPI:Refresh(newOptions: {string}, newCurrent: string?)
				options.Options = newOptions
				currentOption = newCurrent or newOptions[1] or ""
				mainButton.Text = currentOption
				RefreshOptions(newOptions)
			end
			
			function DropdownAPI:Set(optionName: string)
				 if table.find(options.Options, optionName) then
					currentOption = optionName
					mainButton.Text = optionName
				 end
			end
			
			RefreshOptions(options.Options or {})
			return DropdownAPI
		end

		return Tab
	end
	
	return Window
end

return GUI
