--[[
    Enhanced Modular UI Library with Distinct Component Styles
    Place this script in: StarterPlayer > StarterPlayerScripts
    This is the main library module with improved visual differentiation.
]]

--// Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// Main GUI Library Table
local GUI = {}
GUI.__index = GUI

--// Color Schemes for Different Components
local Colors = {
    Button = {
        Background = Color3.fromRGB(70, 130, 200),  -- Blue theme
        Hover = Color3.fromRGB(90, 150, 220),
        Click = Color3.fromRGB(50, 110, 180),
        Text = Color3.fromRGB(255, 255, 255)
    },
    Toggle = {
        TrackOff = Color3.fromRGB(100, 100, 100),   -- Gray when off
        TrackOn = Color3.fromRGB(76, 175, 80),      -- Green when on
        Knob = Color3.fromRGB(245, 245, 245),
        Background = Color3.fromRGB(40, 40, 40)
    },
    Textbox = {
        Background = Color3.fromRGB(45, 45, 45),    -- Dark gray
        Border = Color3.fromRGB(85, 85, 85),
        Focus = Color3.fromRGB(100, 149, 237),      -- Cornflower blue
        Text = Color3.fromRGB(240, 240, 240),
        Placeholder = Color3.fromRGB(160, 160, 160)
    },
    Slider = {
        Track = Color3.fromRGB(60, 60, 60),         -- Dark track
        Fill = Color3.fromRGB(255, 152, 0),         -- Orange fill
        Handle = Color3.fromRGB(255, 255, 255),     -- White handle
        Background = Color3.fromRGB(35, 35, 35)
    },
    Dropdown = {
        Background = Color3.fromRGB(55, 55, 55),    -- Medium gray
        Arrow = Color3.fromRGB(200, 200, 200),
        Hover = Color3.fromRGB(75, 75, 75),
        Selected = Color3.fromRGB(138, 43, 226),    -- Purple
        Border = Color3.fromRGB(90, 90, 90)
    },
    Keybind = {
        Background = Color3.fromRGB(139, 69, 19),   -- Saddle brown
        Hover = Color3.fromRGB(160, 82, 45),
        Active = Color3.fromRGB(210, 180, 140),     -- Tan when binding
        Text = Color3.fromRGB(255, 255, 255)
    }
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
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
MainFrame.BorderSizePixel = 2
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
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
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
bottomFix.Parent = Header

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 5, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.Text = "My Awesome Game UI"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
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
ShowButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ShowButton.TextColor3 = Color3.fromRGB(220, 220, 220)
ShowButton.Font = Enum.Font.SourceSans
ShowButton.Visible = false
ShowButton.Parent = MainGui
local showCorner = Instance.new("UICorner")
showCorner.CornerRadius = UDim.new(0, 6)
showCorner.Parent = ShowButton

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
        isZoomed = false
        TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, Header.AbsoluteSize.Y)}):Play()
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = originalSize}):Play()
    end
end)

ZoomButton.MouseButton1Click:Connect(function()
    isZoomed = not isZoomed
    if isZoomed then
        isMinimized = false
        originalSize = MainFrame.Size
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
TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
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
ContentContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
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
        if dragging and not isZoomed then
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
        contentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        contentFrame.BorderSizePixel = 0
        contentFrame.Visible = false
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        contentFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
        contentFrame.ScrollBarThickness = 6
        contentFrame.Parent = ContentContainer

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, 15)  -- Increased padding for better separation
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Parent = contentFrame
        
        local function updateCanvasSize()
            contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
        end
        
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)

        local tabButton = Instance.new("TextButton")
        tabButton.Name = name .. "Button"
        tabButton.Size = UDim2.new(1, -10, 0, 30)
        tabButton.Position = UDim2.new(0, 5, 0, 0)
        tabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        tabButton.Text = name
        tabButton.Font = Enum.Font.SourceSans
        tabButton.TextColor3 = Color3.fromRGB(220, 220, 220)
        tabButton.TextSize = 14
        tabButton.Parent = TabContainer
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = tabButton

        tabButton.MouseButton1Click:Connect(function()
            if activeTab then
                activeTab.Visible = false
                tabs[activeTab.Name].Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            end
            contentFrame.Visible = true
            tabButton.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
            activeTab = contentFrame
        end)
        
        tabs[name] = {
            Frame = contentFrame,
            Button = tabButton,
            Layout = contentLayout
        }
        
        if not activeTab then
            contentFrame.Visible = true
            tabButton.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
            activeTab = contentFrame
        end

        --// ENHANCED BUTTON COMPONENT
        function Tab:Button(options)
            local container = Instance.new("Frame")
            container.Name = "ButtonContainer_" .. options.Name
            container.Size = UDim2.new(1, 0, 0, 45)  -- Taller for better distinction
            container.BackgroundTransparency = 1
            container.Parent = contentFrame

            local btn = Instance.new("TextButton")
            btn.Name = options.Name
            btn.Size = UDim2.new(1, -10, 1, -5)
            btn.Position = UDim2.new(0, 5, 0, 0)
            btn.BackgroundColor3 = Colors.Button.Background
            btn.Text = "🔘 " .. options.Name  -- Button icon
            btn.Font = Enum.Font.SourceSansBold
            btn.TextColor3 = Colors.Button.Text
            btn.TextSize = 16
            btn.Parent = container

            -- Gradient effect for buttons
            local gradient = Instance.new("UIGradient")
            gradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))
            }
            gradient.Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 0.7),
                NumberSequenceKeypoint.new(1, 0.9)
            }
            gradient.Rotation = 90
            gradient.Parent = btn
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = btn

            -- Hover effects
            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Button.Hover}):Play()
            end)

            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Button.Background}):Play()
            end)

            btn.MouseButton1Down:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Colors.Button.Click}):Play()
            end)

            btn.MouseButton1Up:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Colors.Button.Hover}):Play()
            end)
            
            btn.MouseButton1Click:Connect(function() 
                if options.Callback then 
                    options.Callback() 
                end 
            end)
        end
        
        --// ENHANCED TOGGLE COMPONENT
        function Tab:Toggle(options)
            local state = options.StartingState or false
            
            local container = Instance.new("Frame")
            container.Name = "ToggleContainer_" .. options.Name
            container.Size = UDim2.new(1, 0, 0, 40)
            container.BackgroundColor3 = Colors.Toggle.Background
            container.Parent = contentFrame
            
            local containerCorner = Instance.new("UICorner")
            containerCorner.CornerRadius = UDim.new(0, 8)
            containerCorner.Parent = container
            
            local toggleIcon = Instance.new("TextLabel")
            toggleIcon.Size = UDim2.new(0, 30, 0, 30)
            toggleIcon.Position = UDim2.new(0, 8, 0.5, -15)
            toggleIcon.BackgroundTransparency = 1
            toggleIcon.Text = "⚡"  -- Toggle icon
            toggleIcon.Font = Enum.Font.SourceSansBold
            toggleIcon.TextColor3 = Color3.fromRGB(255, 215, 0)
            toggleIcon.TextSize = 20
            toggleIcon.Parent = container
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -120, 1, 0)
            label.Position = UDim2.new(0, 45, 0, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.SourceSans
            label.Text = options.Name
            label.TextColor3 = Color3.fromRGB(220, 220, 220)
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container
            
            local switchTrack = Instance.new("Frame")
            switchTrack.Size = UDim2.new(0, 55, 0, 26)
            switchTrack.Position = UDim2.new(1, -65, 0.5, -13)
            switchTrack.BackgroundColor3 = state and Colors.Toggle.TrackOn or Colors.Toggle.TrackOff
            switchTrack.Parent = container
            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(1, 0)
            trackCorner.Parent = switchTrack
            
            -- Track glow effect when on
            local trackStroke = Instance.new("UIStroke")
            trackStroke.Color = Colors.Toggle.TrackOn
            trackStroke.Thickness = state and 2 or 0
            trackStroke.Transparency = 0.3
            trackStroke.Parent = switchTrack
            
            local switchKnob = Instance.new("Frame")
            switchKnob.Size = UDim2.new(0, 22, 0, 22)
            switchKnob.Position = state and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
            switchKnob.BackgroundColor3 = Colors.Toggle.Knob
            switchKnob.Parent = switchTrack
            local knobCorner = Instance.new("UICorner")
            knobCorner.CornerRadius = UDim.new(1, 0)
            knobCorner.Parent = switchKnob
            
            -- Knob shadow effect
            local knobShadow = Instance.new("UIStroke")
            knobShadow.Color = Color3.fromRGB(0, 0, 0)
            knobShadow.Thickness = 1
            knobShadow.Transparency = 0.5
            knobShadow.Parent = switchKnob

            local clickDetector = Instance.new("TextButton")
            clickDetector.Size = UDim2.new(1, 0, 1, 0)
            clickDetector.BackgroundTransparency = 1
            clickDetector.Text = ""
            clickDetector.Parent = switchTrack
            
            clickDetector.MouseButton1Click:Connect(function()
                state = not state
                local trackColor = state and Colors.Toggle.TrackOn or Colors.Toggle.TrackOff
                local knobPos = state and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
                local strokeThickness = state and 2 or 0
                
                TweenService:Create(switchTrack, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundColor3 = trackColor}):Play()
                TweenService:Create(switchKnob, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = knobPos}):Play()
                TweenService:Create(trackStroke, TweenInfo.new(0.3), {Thickness = strokeThickness}):Play()

                if options.Callback then
                    options.Callback(state)
                end
            end)
        end
        
        --// ENHANCED TEXTBOX COMPONENT
        function Tab:Textbox(options)
            local container = Instance.new("Frame")
            container.Name = "TextboxContainer_" .. options.Name
            container.Size = UDim2.new(1, 0, 0, 50)
            container.BackgroundTransparency = 1
            container.Parent = contentFrame
            
            local textboxIcon = Instance.new("TextLabel")
            textboxIcon.Size = UDim2.new(0, 30, 0, 30)
            textboxIcon.Position = UDim2.new(0, 8, 0, 10)
            textboxIcon.BackgroundTransparency = 1
            textboxIcon.Text = "📝"  -- Textbox icon
            textboxIcon.Font = Enum.Font.SourceSansBold
            textboxIcon.TextColor3 = Color3.fromRGB(135, 206, 235)
            textboxIcon.TextSize = 18
            textboxIcon.Parent = container
            
            local textbox = Instance.new("TextBox")
            textbox.Size = UDim2.new(1, -50, 0, 35)
            textbox.Position = UDim2.new(0, 45, 0, 8)
            textbox.BackgroundColor3 = Colors.Textbox.Background
            textbox.PlaceholderText = options.Name
            textbox.Font = Enum.Font.SourceSans
            textbox.TextColor3 = Colors.Textbox.Text
            textbox.PlaceholderColor3 = Colors.Textbox.Placeholder
            textbox.TextSize = 14
            textbox.ClearTextOnFocus = false
            textbox.Parent = container
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = textbox
            
            local border = Instance.new("UIStroke")
            border.Color = Colors.Textbox.Border
            border.Thickness = 1
            border.Parent = textbox
            
            textbox.Focused:Connect(function()
                TweenService:Create(border, TweenInfo.new(0.2), {Color = Colors.Textbox.Focus, Thickness = 2}):Play()
            end)
            
            textbox.FocusLost:Connect(function(enterPressed) 
                TweenService:Create(border, TweenInfo.new(0.2), {Color = Colors.Textbox.Border, Thickness = 1}):Play()
                if enterPressed and options.Callback then 
                    options.Callback(textbox.Text) 
                end 
            end)
        end
        
        --// ENHANCED SLIDER COMPONENT
        function Tab:Slider(options)
            local container = Instance.new("Frame")
            container.Name = "SliderContainer_" .. options.Name
            container.Size = UDim2.new(1, 0, 0, 55)
            container.BackgroundColor3 = Colors.Slider.Background
            container.Parent = contentFrame
            
            local containerCorner = Instance.new("UICorner")
            containerCorner.CornerRadius = UDim.new(0, 8)
            containerCorner.Parent = container
            
            local sliderIcon = Instance.new("TextLabel")
            sliderIcon.Size = UDim2.new(0, 25, 0, 25)
            sliderIcon.Position = UDim2.new(0, 8, 0, 5)
            sliderIcon.BackgroundTransparency = 1
            sliderIcon.Text = "🎚️"  -- Slider icon
            sliderIcon.Font = Enum.Font.SourceSansBold
            sliderIcon.TextColor3 = Colors.Slider.Fill
            sliderIcon.TextSize = 16
            sliderIcon.Parent = container
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -40, 0, 25)
            label.Position = UDim2.new(0, 35, 0, 5)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.SourceSansBold
            label.TextColor3 = Color3.fromRGB(220, 220, 220)
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container

            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(1, -20, 0, 12)
            sliderFrame.Position = UDim2.new(0, 10, 0, 32)
            sliderFrame.BackgroundColor3 = Colors.Slider.Track
            sliderFrame.Parent = container
            local sCorner = Instance.new("UICorner")
            sCorner.CornerRadius = UDim.new(0, 6)
            sCorner.Parent = sliderFrame
            
            local fill = Instance.new("Frame")
            fill.BackgroundColor3 = Colors.Slider.Fill
            fill.BorderSizePixel = 0
            fill.Parent = sliderFrame
            local fCorner = Instance.new("UICorner")
            fCorner.CornerRadius = UDim.new(0, 6)
            fCorner.Parent = fill
            
            -- Glow effect for fill
            local fillGlow = Instance.new("UIStroke")
            fillGlow.Color = Colors.Slider.Fill
            fillGlow.Thickness = 1
            fillGlow.Transparency = 0.6
            fillGlow.Parent = fill
            
            local handle = Instance.new("TextButton")
            handle.Size = UDim2.new(0, 20, 0, 20)
            handle.Position = UDim2.new(0, -10, 0.5, -10)
            handle.BackgroundColor3 = Colors.Slider.Handle
            handle.Text = ""
            handle.ZIndex = 2
            handle.Parent = fill
            local hCorner = Instance.new("UICorner")
            hCorner.CornerRadius = UDim.new(1, 0)
            hCorner.Parent = handle
            
            -- Handle shadow
            local handleShadow = Instance.new("UIStroke")
            handleShadow.Color = Color3.fromRGB(0, 0, 0)
            handleShadow.Thickness = 2
            handleShadow.Transparency = 0.4
            handleShadow.Parent = handle
            
            local min, max, default = options.Min or 0, options.Max or 100, options.Default or 50
            local value = default
            
            local function updateSlider(percent)
                percent = math.clamp(percent, 0, 1)
                value = min + (max - min) * percent
                fill.Size = UDim2.new(percent, 0, 1, 0)
                label.Text = string.format("%s: %.1f", options.Name, value)
                if options.Callback then
                    options.Callback(value)
                end
            end
            
            updateSlider((default - min) / (max - min))
