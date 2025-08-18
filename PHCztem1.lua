--// Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// Main GUI Library Table
local GUI = {}
GUI.__index = GUI

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
bottomFix.Parent = headerCorner

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -100, 1, 0) -- Make space for buttons
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

--// Show UI Button (appears when main UI is hidden, now draggable and top-left)
local ShowButton = Instance.new("TextButton")
ShowButton.Name = "ShowButton"
ShowButton.Size = UDim2.new(0, 100, 0, 30)
ShowButton.Position = UDim2.new(0, 10, 0, 10) -- Positioned top-left
ShowButton.Text = "Show UI"
ShowButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ShowButton.TextColor3 = Color3.fromRGB(220, 220, 220)
ShowButton.Font = Enum.Font.SourceSans
ShowButton.Visible = false
ShowButton.ZIndex = 10 -- Make sure it's on top
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

--// Dragging Logic for Main Window
local dragging = false
local dragStart, startPos
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
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging and not isZoomed then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

--// Dragging Logic for ShowButton
local showButtonDragging = false
local showButtonDragStart, showButtonStartPos
ShowButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        showButtonDragging = true
        showButtonDragStart = input.Position
        showButtonStartPos = ShowButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                showButtonDragging = false
            end
        end)
    end
end)
ShowButton.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and showButtonDragging then
        local delta = input.Position - showButtonDragStart
        ShowButton.Position = UDim2.new(showButtonStartPos.X.Scale, showButtonStartPos.X.Offset + delta.X, showButtonStartPos.Y.Scale, showButtonStartPos.Y.Offset + delta.Y)
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
        
        --// NOTE: This is a ScrollingFrame, it already has a scrollbar when content overflows.
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
        contentLayout.Padding = UDim.new(0, 10)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Parent = contentFrame
        
        local function updateCanvasSize()
            -- Add a little padding at the bottom
            contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
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

        --// Component Functions
        function Tab:Button(options)
            local btn = Instance.new("TextButton")
            btn.Name = options.Name
            btn.Size = UDim2.new(1, 0, 0, 35)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.Text = options.Name
            btn.Font = Enum.Font.SourceSans
            btn.TextColor3 = Color3.fromRGB(220, 220, 220)
            btn.TextSize = 16
            btn.Parent = contentFrame
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = btn
            btn.MouseButton1Click:Connect(function() if options.Callback then options.Callback() end end)
        end
        
        function Tab:Toggle(options)
            local state = options.StartingState or false
            local container = Instance.new("Frame")
            container.Name = options.Name
            container.Size = UDim2.new(1, 0, 0, 35)
            container.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            container.Parent = contentFrame
            
            local containerCorner = Instance.new("UICorner")
            containerCorner.CornerRadius = UDim.new(0, 6)
            containerCorner.Parent = container
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -70, 1, 0)
            label.Position = UDim2.new(0, 15, 0, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.SourceSansSemibold
            label.Text = options.Name
            label.TextColor3 = Color3.fromRGB(220, 220, 220)
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container
            
            -- Modern iOS-style toggle
            local toggleBg = Instance.new("Frame")
            toggleBg.Size = UDim2.new(0, 44, 0, 26)
            toggleBg.Position = UDim2.new(1, -55, 0.5, -13)
            toggleBg.BackgroundColor3 = state and Color3.fromRGB(52, 199, 89) or Color3.fromRGB(70, 70, 70)
            toggleBg.Parent = container
            
            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 13)
            toggleCorner.Parent = toggleBg
            
            local toggleKnob = Instance.new("Frame")
            toggleKnob.Size = UDim2.new(0, 22, 0, 22)
            toggleKnob.Position = state and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
            toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            toggleKnob.Parent = toggleBg
            
            local knobCorner = Instance.new("UICorner")
            knobCorner.CornerRadius = UDim.new(0, 11)
            knobCorner.Parent = toggleKnob
            
            -- Add shadow effect to knob
            local knobShadow = Instance.new("Frame")
            knobShadow.Size = UDim2.new(1, 4, 1, 4)
            knobShadow.Position = UDim2.new(0, -2, 0, -2)
            knobShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            knobShadow.BackgroundTransparency = 0.8
            knobShadow.ZIndex = toggleKnob.ZIndex - 1
            knobShadow.Parent = toggleKnob
            
            local shadowCorner = Instance.new("UICorner")
            shadowCorner.CornerRadius = UDim.new(0, 13)
            shadowCorner.Parent = knobShadow
            
            local clickDetector = Instance.new("TextButton")
            clickDetector.Size = UDim2.new(1, 10, 1, 10)
            clickDetector.Position = UDim2.new(0, -5, 0, -5)
            clickDetector.BackgroundTransparency = 1
            clickDetector.Text = ""
            clickDetector.Parent = toggleBg
            
            clickDetector.MouseButton1Click:Connect(function()
                state = not state
                local bgColor = state and Color3.fromRGB(52, 199, 89) or Color3.fromRGB(70, 70, 70)
                local knobPos = state and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
                
                TweenService:Create(toggleBg, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = bgColor}):Play()
                TweenService:Create(toggleKnob, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = knobPos}):Play()
                
                if options.Callback then options.Callback(state) end
            end)
        end
        
        function Tab:Textbox(options)
            local container = Instance.new("Frame")
            container.Name = options.Name
            container.Size = UDim2.new(1, 0, 0, 45)
            container.BackgroundTransparency = 1
            container.Parent = contentFrame
            
            -- Modern material design inspired textbox
            local textboxBg = Instance.new("Frame")
            textboxBg.Size = UDim2.new(1, 0, 0, 38)
            textboxBg.Position = UDim2.new(0, 0, 0, 7)
            textboxBg.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            textboxBg.Parent = container
            
            local bgCorner = Instance.new("UICorner")
            bgCorner.CornerRadius = UDim.new(0, 8)
            bgCorner.Parent = textboxBg
            
            -- Accent border
            local accent = Instance.new("Frame")
            accent.Size = UDim2.new(0, 3, 1, 0)
            accent.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
            accent.BorderSizePixel = 0
            accent.Parent = textboxBg
            
            local accentCorner = Instance.new("UICorner")
            accentCorner.CornerRadius = UDim.new(0, 8)
            accentCorner.Parent = accent
            
            local textbox = Instance.new("TextBox")
            textbox.Size = UDim2.new(1, -15, 1, 0)
            textbox.Position = UDim2.new(0, 15, 0, 0)
            textbox.BackgroundTransparency = 1
            textbox.PlaceholderText = options.Name
            textbox.Font = Enum.Font.SourceSans
            textbox.TextColor3 = Color3.fromRGB(240, 240, 240)
            textbox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
            textbox.TextSize = 16
            textbox.TextXAlignment = Enum.TextXAlignment.Left
            textbox.ClearTextOnFocus = false
            textbox.Parent = textboxBg
            
            -- Focus effects
            textbox.Focused:Connect(function()
                TweenService:Create(textboxBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}):Play()
                TweenService:Create(accent, TweenInfo.new(0.2), {Size = UDim2.new(0, 4, 1, 0)}):Play()
            end)
            
            textbox.FocusLost:Connect(function(enterPressed)
                TweenService:Create(textboxBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
                TweenService:Create(accent, TweenInfo.new(0.2), {Size = UDim2.new(0, 3, 1, 0)}):Play()
                if enterPressed and options.Callback then options.Callback(textbox.Text) end
            end)
        end
        
        function Tab:Slider(options)
            local container = Instance.new("Frame")
            container.Name = options.Name
            container.Size = UDim2.new(1, 0, 0, 50)
            container.BackgroundTransparency = 1
            container.Parent = contentFrame
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.7, 0, 0, 20)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.SourceSansSemibold
            label.TextColor3 = Color3.fromRGB(220, 220, 220)
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0.3, 0, 0, 20)
            valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Font = Enum.Font.SourceSansSemibold
            valueLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
            valueLabel.TextSize = 14
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Parent = container
            
            -- Modern track-based slider
            local sliderTrack = Instance.new("Frame")
            sliderTrack.Size = UDim2.new(1, 0, 0, 6)
            sliderTrack.Position = UDim2.new(0, 0, 0, 30)
            sliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            sliderTrack.Parent = container
            
            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(0, 3)
            trackCorner.Parent = sliderTrack
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Size = UDim2.new(0, 0, 1, 0)
            sliderFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderTrack
            
            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(0, 3)
            fillCorner.Parent = sliderFill
            
            local handle = Instance.new("Frame")
            handle.Size = UDim2.new(0, 18, 0, 18)
            handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            handle.ZIndex = 2
            handle.Parent = sliderTrack
            
            local handleCorner = Instance.new("UICorner")
            handleCorner.CornerRadius = UDim.new(0, 9)
            handleCorner.Parent = handle
            
            -- Handle shadow
            local handleShadow = Instance.new("Frame")
            handleShadow.Size = UDim2.new(1, 4, 1, 4)
            handleShadow.Position = UDim2.new(0, -2, 0, -2)
            handleShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            handleShadow.BackgroundTransparency = 0.7
            handleShadow.ZIndex = 1
            handleShadow.Parent = handle
            
            local shadowCorner = Instance.new("UICorner")
            shadowCorner.CornerRadius = UDim.new(0, 11)
            shadowCorner.Parent = handleShadow
            
            local min, max, default = options.Min or 0, options.Max or 100, options.Default or 50
            local value = default
            
            local function updateSlider(percent)
                percent = math.clamp(percent, 0, 1)
                value = min + (max - min) * percent
                sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                handle.Position = UDim2.new(percent, -9, 0.5, -9)
                label.Text = options.Name
                valueLabel.Text = string.format("%.1f", value)
                if options.Callback then options.Callback(value) end
            end
            
            updateSlider((default - min) / (max - min))
            
            local dragConnection
            local clickDetector = Instance.new("TextButton")
            clickDetector.Size = UDim2.new(1, 20, 1, 20)
            clickDetector.Position = UDim2.new(0, -10, 0, -10)
            clickDetector.BackgroundTransparency = 1
            clickDetector.Text = ""
            clickDetector.Parent = sliderTrack
            
            clickDetector.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    TweenService:Create(handle, TweenInfo.new(0.1), {Size = UDim2.new(0, 20, 0, 20)}):Play()
                    dragConnection = UserInputService.InputChanged:Connect(function(changedInput)
                        if changedInput.UserInputType == Enum.UserInputType.MouseMovement or changedInput.UserInputType == Enum.UserInputType.Touch then
                            local mousePos = UserInputService:GetMouseLocation()
                            local relativePos = mousePos.X - sliderTrack.AbsolutePosition.X
                            local percent = math.clamp(relativePos / sliderTrack.AbsoluteSize.X, 0, 1)
                            updateSlider(percent)
                        end
                    end)
                end
            end)
            
            clickDetector.InputEnded:Connect(function()
                TweenService:Create(handle, TweenInfo.new(0.1), {Size = UDim2.new(0, 18, 0, 18)}):Play()
                if dragConnection then dragConnection:Disconnect() end
            end)
        end
        
        function Tab:Keybind(options)
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
            label.TextColor3 = Color3.fromRGB(220, 220, 220)
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container
            local keybindButton = Instance.new("TextButton")
            keybindButton.Size = UDim2.new(0.4, -5, 1, 0)
            keybindButton.Position = UDim2.new(0.6, 5, 0, 0)
            keybindButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            keybindButton.Text = options.Keybind or "..."
            keybindButton.Font = Enum.Font.SourceSans
            keybindButton.TextColor3 = Color3.fromRGB(220, 220, 220)
            keybindButton.TextSize = 14
            keybindButton.Parent = container
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = keybindButton
            keybindButton.MouseButton1Click:Connect(function()
                keybindButton.Text = "..."
                local connection
                connection = UserInputService.InputBegan:Connect(function(input, gp)
                    if gp then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        keybindButton.Text = input.KeyCode.Name
                        connection:Disconnect()
                    end
                end)
            end)
        end
        
        function Tab:Dropdown(options)
            local Dropdown = {}
            Dropdown.CurrentOption = options.CurrentOption or options.Options[1]
            local isOpen = false

            local container = Instance.new("Frame")
            container.Name = options.Name
            container.Size = UDim2.new(1, 0, 0, 42)
            container.BackgroundTransparency = 1
            container.ZIndex = 1
            container.Parent = contentFrame

            -- Modern card-style dropdown
            local dropdownCard = Instance.new("Frame")
            dropdownCard.Size = UDim2.new(1, 0, 1, 0)
            dropdownCard.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
            dropdownCard.ZIndex = 1
            dropdownCard.Parent = container
            
            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 10)
            cardCorner.Parent = dropdownCard
            
            -- Subtle border gradient effect
            local borderFrame = Instance.new("Frame")
            borderFrame.Size = UDim2.new(1, 2, 1, 2)
            borderFrame.Position = UDim2.new(0, -1, 0, -1)
            borderFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            borderFrame.ZIndex = 1
            borderFrame.Parent = dropdownCard
            
            local borderCorner = Instance.new("UICorner")
            borderCorner.CornerRadius = UDim.new(0, 11)
            borderCorner.Parent = borderFrame

            local mainButton = Instance.new("TextButton")
            mainButton.Name = "MainButton"
            mainButton.Size = UDim2.new(1, -15, 1, 0)
            mainButton.Position = UDim2.new(0, 15, 0, 0)
            mainButton.BackgroundTransparency = 1
            mainButton.Text = Dropdown.CurrentOption
            mainButton.Font = Enum.Font.SourceSansSemibold
            mainButton.TextColor3 = Color3.fromRGB(240, 240, 240)
            mainButton.TextSize = 16
            mainButton.TextXAlignment = Enum.TextXAlignment.Left
            mainButton.ZIndex = 2
            mainButton.Parent = dropdownCard

            -- Modern chevron indicator
            local chevron = Instance.new("TextLabel")
            chevron.Size = UDim2.new(0, 20, 1, 0)
            chevron.Position = UDim2.new(1, -25, 0, 0)
            chevron.BackgroundTransparency = 1
            chevron.Text = "⌄"
            chevron.Font = Enum.Font.SourceSansBold
            chevron.TextColor3 = Color3.fromRGB(150, 150, 150)
            chevron.TextSize = 18
            chevron.TextXAlignment = Enum.TextXAlignment.Center
            chevron.ZIndex = 2
            chevron.Parent = dropdownCard

            -- Create dropdown list directly in ContentContainer to avoid clipping
            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Name = "DropdownFrame"
            dropdownFrame.Size = UDim2.new(0, container.AbsoluteSize.X, 0, 0)
            dropdownFrame.Position = UDim2.new(0, container.AbsolutePosition.X - ContentContainer.AbsolutePosition.X, 0, container.AbsolutePosition.Y - ContentContainer.AbsolutePosition.Y + 50)
            dropdownFrame.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
            dropdownFrame.BorderSizePixel = 0
            dropdownFrame.Visible = false
            dropdownFrame.ZIndex = 10
            dropdownFrame.ClipsDescendants = true
            dropdownFrame.Parent = ContentContainer
            
            local dCorner = Instance.new("UICorner")
            dCorner.CornerRadius = UDim.new(0, 8)
            dCorner.Parent = dropdownFrame
            
            -- Dropdown shadow
            local dropShadow = Instance.new("Frame")
            dropShadow.Size = UDim2.new(1, 6, 1, 6)
            dropShadow.Position = UDim2.new(0, -3, 0, -3)
            dropShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            dropShadow.BackgroundTransparency = 0.8
            dropShadow.ZIndex = 9
            dropShadow.Parent = dropdownFrame
            
            local shadowCorner = Instance.new("UICorner")
            shadowCorner.CornerRadius = UDim.new(0, 11)
            shadowCorner.Parent = dropShadow

            local scrollFrame = Instance.new("ScrollingFrame")
            scrollFrame.Size = UDim2.new(1, 0, 1, 0)
            scrollFrame.BackgroundTransparency = 1
            scrollFrame.ScrollBarThickness = 4
            scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
            scrollFrame.ZIndex = 10
            scrollFrame.Parent = dropdownFrame
            
            local dropdownLayout = Instance.new("UIListLayout")
            dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
            dropdownLayout.Padding = UDim.new(0, 2)
            dropdownLayout.Parent = scrollFrame

            local function updateDropdownPosition()
                -- Update position when container moves
                dropdownFrame.Position = UDim2.new(0, container.AbsolutePosition.X - ContentContainer.AbsolutePosition.X, 0, container.AbsolutePosition.Y - ContentContainer.AbsolutePosition.Y + 50)
                dropdownFrame.Size = UDim2.new(0, container.AbsoluteSize.X, 0, dropdownFrame.Size.Y.Offset)
            end

            local function refreshOptions(newOptions)
                for _, child in ipairs(scrollFrame:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                for i, optionName in ipairs(newOptions) do
                    local optionButton = Instance.new("TextButton")
                    optionButton.Name = optionName
                    optionButton.Size = UDim2.new(1, 0, 0, 32)
                    optionButton.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
                    optionButton.Text = optionName
                    optionButton.Font = Enum.Font.SourceSans
                    optionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                    optionButton.TextSize = 15
                    optionButton.TextXAlignment = Enum.TextXAlignment.Left
                    optionButton.ZIndex = 10
                    optionButton.Parent = scrollFrame
                    
                    -- Add padding to text
                    local textPadding = Instance.new("UIPadding")
                    textPadding.PaddingLeft = UDim.new(0, 12)
                    textPadding.Parent = optionButton
                    
                    -- Highlight current selection
                    if optionName == Dropdown.CurrentOption then
                        optionButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
                        optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    end
                    
                    optionButton.MouseEnter:Connect(function()
                        if optionName ~= Dropdown.CurrentOption then
                            optionButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
                        end
                    end)
                    
                    optionButton.MouseLeave:Connect(function()
                        if optionName ~= Dropdown.CurrentOption then
                            optionButton.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
                        end
                    end)
                    
                    optionButton.MouseButton1Click:Connect(function()
                        Dropdown.CurrentOption = optionName
                        mainButton.Text = optionName
                        isOpen = false
                        
                        -- Animate chevron and close dropdown
                        TweenService:Create(chevron, TweenInfo.new(0.2), {Rotation = 0}):Play()
                        local closeTween = TweenService:Create(dropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(0, container.AbsoluteSize.X, 0, 0)})
                        closeTween:Play()
                        closeTween.Completed:Connect(function()
                            dropdownFrame.Visible = false
                        end)
                        
                        if options.Callback then options.Callback(optionName) end
                        
                        -- Refresh to update selection highlighting
                        refreshOptions(newOptions)
                    end)
                end
                scrollFrame.CanvasSize = UDim2.new(0,0,0,dropdownLayout.AbsoluteContentSize.Y)
            end

            mainButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                updateDropdownPosition()
                
                if isOpen then
                    dropdownFrame.Visible = true
                    dropdownFrame.Size = UDim2.new(0, container.AbsoluteSize.X, 0, 0)
                    TweenService:Create(chevron, TweenInfo.new(0.2), {Rotation = 180}):Play()
                    TweenService:Create(dropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, container.AbsoluteSize.X, 0, math.min(120, #options.Options * 34))}):Play()
                else
                    TweenService:Create(chevron, TweenInfo.new(0.2), {Rotation = 0}):Play()
                    local closeTween = TweenService:Create(dropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(0, container.AbsoluteSize.X, 0, 0)})
                    closeTween:Play()
                    closeTween.Completed:Connect(function()
                        dropdownFrame.Visible = false
                    end)
                end
            end)
            
            function Dropdown:Refresh(newOptions, newCurrent)
                options.Options = newOptions
                Dropdown.CurrentOption = newCurrent or newOptions[1]
                mainButton.Text = Dropdown.CurrentOption
                refreshOptions(newOptions)
            end
            
            function Dropdown:Set(optionName)
                 if table.find(options.Options, optionName) then
                    Dropdown.CurrentOption = optionName
                    mainButton.Text = optionName
                    refreshOptions(options.Options)
                 end
            end
            
            refreshOptions(options.Options)
            return Dropdown
        end

        return Tab
    end
    
    return Window
end

return GUI
