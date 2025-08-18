--[=[
    Modular UI Library by Gemini (Upgraded Version 2)
    Place this script in: StarterPlayer > StarterPlayerScripts
    This is the main library module with updated UI components.
]=]

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
MainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 32) -- Darker, sleek background
MainFrame.BorderColor3 = Color3.fromRGB(60, 60, 70)
MainFrame.BorderSizePixel = 1
MainFrame.Active = true
MainFrame.Visible = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = MainGui

--// Corner radius for modern look
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = MainFrame

--// Header for title and dragging
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 36) -- Slightly taller for better spacing
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = Header

local bottomFix = Instance.new("Frame")
bottomFix.Size = UDim2.new(1, 0, 0.5, 0)
bottomFix.Position = UDim2.new(0, 0, 0.5, 0)
bottomFix.BackgroundColor3 = Header.BackgroundColor3
bottomFix.BorderSizePixel = 0
bottomFix.Parent = headerCorner

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0) -- Adjusted padding
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "My Awesome Game UI"
Title.TextColor3 = Color3.fromRGB(230, 230, 230)
Title.TextSize = 18
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
controlsLayout.Padding = UDim.new(0, 8)
controlsLayout.Parent = ControlsFrame

local function createControlButton(text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 28, 0, 28) -- Larger buttons for better interaction
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 16
    btn.Parent = ControlsFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    -- Hover effect
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 90)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}):Play()
    end)
    return btn
end

local HideButton = createControlButton("X")
local ZoomButton = createControlButton("+")
local MinimizeButton = createControlButton("-")

--// Show UI Button (draggable, top-left)
local ShowButton = Instance.new("TextButton")
ShowButton.Name = "ShowButton"
ShowButton.Size = UDim2.new(0, 120, 0, 36)
ShowButton.Position = UDim2.new(0, 10, 0, 10)
ShowButton.Text = "Show UI"
ShowButton.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
ShowButton.TextColor3 = Color3.fromRGB(230, 230, 230)
ShowButton.Font = Enum.Font.Gotham
ShowButton.TextSize = 16
ShowButton.Visible = false
ShowButton.ZIndex = 10
ShowButton.Parent = MainGui
local showCorner = Instance.new("UICorner")
showCorner.CornerRadius = UDim.new(0, 8)
showCorner.Parent = ShowButton
-- Hover effect
ShowButton.MouseEnter:Connect(function()
    TweenService:Create(ShowButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
end)
ShowButton.MouseLeave:Connect(function()
    TweenService:Create(ShowButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 20, 24)}):Play()
end)

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
TabContainer.Size = UDim2.new(0, 140, 1, -36) -- Wider for better tab visibility
TabContainer.Position = UDim2.new(0, 0, 0, 36)
TabContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.Padding = UDim.new(0, 8)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = TabContainer

--// Content container
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -140, 1, -36)
ContentContainer.Position = UDim2.new(0, 140, 0, 36)
ContentContainer.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
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
        
        local contentFrame = Instance.new("ScrollingFrame")
        contentFrame.Name = name
        contentFrame.Size = UDim2.new(1, -10, 1, -10)
        contentFrame.Position = UDim2.new(0, 5, 0, 5)
        contentFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
        contentFrame.BorderSizePixel = 0
        contentFrame.Visible = false
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        contentFrame.ScrollBarImageColor3 = Color3.fromRGB(90, 90, 100)
        contentFrame.ScrollBarThickness = 4
        contentFrame.Parent = ContentContainer

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, 12)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Parent = contentFrame
        
        local function updateCanvasSize()
            contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 12)
        end
        
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)

        local tabButton = Instance.new("TextButton")
        tabButton.Name = name .. "Button"
        tabButton.Size = UDim2.new(1, -10, 0, 36)
        tabButton.Position = UDim2.new(0, 5, 0, 0)
        tabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        tabButton.Text = name
        tabButton.Font = Enum.Font.Gotham
        tabButton.TextColor3 = Color3.fromRGB(230, 230, 230)
        tabButton.TextSize = 16
        tabButton.Parent = TabContainer
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = tabButton
        -- Hover effect
        tabButton.MouseEnter:Connect(function()
            TweenService:Create(tabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 90)}):Play()
        end)
        tabButton.MouseLeave:Connect(function()
            TweenService:Create(tabButton, TweenInfo.new(0.2), {BackgroundColor3 = activeTab == contentFrame and Color3.fromRGB(80, 80, 100) or Color3.fromRGB(50, 50, 60)}):Play()
        end)

        tabButton.MouseButton1Click:Connect(function()
            if activeTab then
                activeTab.Visible = false
                tabs[activeTab.Name].Button.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            end
            contentFrame.Visible = true
            tabButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
            activeTab = contentFrame
        end)
        
        tabs[name] = {
            Frame = contentFrame,
            Button = tabButton,
            Layout = contentLayout
        }
        
        if not activeTab then
            contentFrame.Visible = true
            tabButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
            activeTab = contentFrame
        end

        --// Component Functions
        function Tab:Button(options)
            local btn = Instance.new("TextButton")
            btn.Name = options.Name
            btn.Size = UDim2.new(1, -10, 0, 40)
            btn.Position = UDim2.new(0, 5, 0, 0)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            btn.Text = options.Name
            btn.Font = Enum.Font.Gotham
            btn.TextColor3 = Color3.fromRGB(230, 230, 230)
            btn.TextSize = 16
            btn.Parent = contentFrame
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = btn
            -- Hover effect
            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 90)}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}):Play()
            end)
            btn.MouseButton1Click:Connect(function() if options.Callback then options.Callback() end end)
        end
        
        function Tab:Toggle(options)
            local state = options.StartingState or false
            local container = Instance.new("Frame")
            container.Name = options.Name
            container.Size = UDim2.new(1, -10, 0, 40)
            container.Position = UDim2.new(0, 5, 0, 0)
            container.BackgroundTransparency = 1
            container.Parent = contentFrame
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -70, 1, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.Gotham
            label.Text = options.Name
            label.TextColor3 = Color3.fromRGB(230, 230, 230)
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container
            local switchTrack = Instance.new("Frame")
            switchTrack.Size = UDim2.new(0, 60, 0, 28)
            switchTrack.Position = UDim2.new(1, -60, 0.5, -14)
            switchTrack.BackgroundColor3 = state and Color3.fromRGB(255, 165, 0) or Color3.fromRGB(80, 80, 90) -- Orange for on to distinguish
            switchTrack.Parent = container
            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(0, 4) -- Less rounded for distinction
            trackCorner.Parent = switchTrack
            local switchKnob = Instance.new("Frame")
            switchKnob.Size = UDim2.new(0, 24, 0, 24)
            switchKnob.Position = state and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)
            switchKnob.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
            switchKnob.Parent = switchTrack
            local knobCorner = Instance.new("UICorner")
            knobCorner.CornerRadius = UDim.new(0, 4) -- Less rounded
            knobCorner.Parent = switchKnob
            local clickDetector = Instance.new("TextButton")
            clickDetector.Size = UDim2.new(1, 0, 1, 0)
            clickDetector.BackgroundTransparency = 1
            clickDetector.Text = ""
            clickDetector.Parent = switchTrack
            clickDetector.MouseButton1Click:Connect(function()
                state = not state
                local trackColor = state and Color3.fromRGB(255, 165, 0) or Color3.fromRGB(80, 80, 90)
                local knobPos = state and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)
                TweenService:Create(switchTrack, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = trackColor}):Play()
                TweenService:Create(switchKnob, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = knobPos}):Play()
                if options.Callback then options.Callback(state) end
            end)
            -- Add border for distinction
            local trackStroke = Instance.new("UIStroke")
            trackStroke.Color = Color3.fromRGB(100, 100, 100)
            trackStroke.Thickness = 1
            trackStroke.Parent = switchTrack
        end
        
        function Tab:Textbox(options)
            local container = Instance.new("Frame")
            container.Name = options.Name
            container.Size = UDim2.new(1, -10, 0, 40)
            container.Position = UDim2.new(0, 5, 0, 0)
            container.BackgroundTransparency = 1
            container.Parent = contentFrame
            local textbox = Instance.new("TextBox")
            textbox.Size = UDim2.new(1, 0, 1, 0)
            textbox.BackgroundColor3 = Color3.fromRGB(60, 60, 70) -- Lighter gray for distinction
            textbox.PlaceholderText = options.Name
            textbox.Font = Enum.Font.GothamSemibold -- Bolder font
            textbox.TextColor3 = Color3.fromRGB(230, 230, 230)
            textbox.PlaceholderColor3 = Color3.fromRGB(140, 140, 150)
            textbox.TextSize = 16
            textbox.ClearTextOnFocus = false
            textbox.Parent = container
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 2) -- Almost square corners
            corner.Parent = textbox
            -- Focus effect
            textbox.Focused:Connect(function()
                TweenService:Create(textbox, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 90)}):Play()
            end)
            textbox.FocusLost:Connect(function()
                TweenService:Create(textbox, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
                if options.Callback then options.Callback(textbox.Text) end
            end)
            -- Add border
            local textStroke = Instance.new("UIStroke")
            textStroke.Color = Color3.fromRGB(120, 120, 120)
            textStroke.Thickness = 1.5
            textStroke.Parent = textbox
        end
        
        function Tab:Slider(options)
            local container = Instance.new("Frame")
            container.Name = options.Name
            container.Size = UDim2.new(1, -10, 0, 50)
            container.Position = UDim2.new(0, 5, 0, 0)
            container.BackgroundTransparency = 1
            container.Parent = contentFrame
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 20)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.Gotham
            label.TextColor3 = Color3.fromRGB(230, 230, 230)
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(1, 0, 0, 12)
            sliderFrame.Position = UDim2.new(0, 0, 0, 30)
            sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            sliderFrame.Parent = container
            local sCorner = Instance.new("UICorner")
            sCorner.CornerRadius = UDim.new(0, 6)
            sCorner.Parent = sliderFrame
            local fill = Instance.new("Frame")
            fill.BackgroundColor3 = Color3.fromRGB(186, 85, 211) -- Purple fill for distinction
            fill.BorderSizePixel = 0
            fill.Parent = sliderFrame
            local fCorner = Instance.new("UICorner")
            fCorner.CornerRadius = UDim.new(0, 6)
            fCorner.Parent = fill
            local handle = Instance.new("TextButton")
            handle.Size = UDim2.new(0, 20, 0, 20)
            handle.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
            handle.Text = ""
            handle.ZIndex = 2
            handle.Parent = fill
            local hCorner = Instance.new("UICorner")
            hCorner.CornerRadius = UDim.new(0, 10)
            hCorner.Parent = handle
            local min, max, default = options.Min or 0, options.Max or 100, options.Default or 50
            local value = default
            local function updateSlider(percent)
                percent = math.clamp(percent, 0, 1)
                value = min + (max - min) * percent
                fill.Size = UDim2.new(percent, 0, 1, 0)
                handle.Position = UDim2.new(percent, -10, 0.5, -10)
                label.Text = string.format("%s: %.2f", options.Name, value)
                if options.Callback then options.Callback(value) end
            end
            updateSlider((default - min) / (max - min))
            local dragConnection
            handle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragConnection = UserInputService.InputChanged:Connect(function(changedInput)
                        if changedInput.UserInputType == Enum.UserInputType.MouseMovement or changedInput.UserInputType == Enum.UserInputType.Touch then
                            local mousePos = UserInputService:GetMouseLocation()
                            local relativePos = mousePos.X - sliderFrame.AbsolutePosition.X
                            local percent = math.clamp(relativePos / sliderFrame.AbsoluteSize.X, 0, 1)
                            updateSlider(percent)
                        end
                    end)
                end
            end)
            handle.InputEnded:Connect(function() if dragConnection then dragConnection:Disconnect() end end)
            -- Hover effect for handle
            handle.MouseEnter:Connect(function()
                TweenService:Create(handle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            end)
            handle.MouseLeave:Connect(function()
                TweenService:Create(handle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(220, 220, 220)}):Play()
            end)
            -- Add gradient to fill for distinction
            local fillGradient = Instance.new("UIGradient")
            fillGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(186, 85, 211)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(147, 112, 219))
            }
            fillGradient.Parent = fill
        end
        
        function Tab:Keybind(options)
            local container = Instance.new("Frame")
            container.Name = options.Name
            container.Size = UDim2.new(1, -10, 0, 40)
            container.Position = UDim2.new(0, 5, 0, 0)
            container.BackgroundTransparency = 1
            container.Parent = contentFrame
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.6, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.Gotham
            label.Text = options.Name
            label.TextColor3 = Color3.fromRGB(230, 230, 230)
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container
            local keybindButton = Instance.new("TextButton")
            keybindButton.Size = UDim2.new(0.4, -5, 1, 0)
            keybindButton.Position = UDim2.new(0.6, 5, 0, 0)
            keybindButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            keybindButton.Text = options.Keybind or "..."
            keybindButton.Font = Enum.Font.Gotham
            keybindButton.TextColor3 = Color3.fromRGB(230, 230, 230)
            keybindButton.TextSize = 16
            keybindButton.Parent = container
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = keybindButton
            -- Hover effect
            keybindButton.MouseEnter:Connect(function()
                TweenService:Create(keybindButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 90)}):Play()
            end)
            keybindButton.MouseLeave:Connect(function()
                TweenService:Create(keybindButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}):Play()
            end)
            keybindButton.MouseButton1Click:Connect(function()
                keybindButton.Text = "..."
                local connection
                connection = UserInputService.InputBegan:Connect(function(input, gp)
                    if gp then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        keybindButton.Text = input.KeyCode.Name
                        connection:Disconnect()
                        if options.Callback then options.Callback(input.KeyCode) end
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
            container.Size = UDim2.new(1, -10, 0, 40)
            container.Position = UDim2.new(0, 5, 0, 0)
            container.BackgroundTransparency = 1
            container.ZIndex = 2
            container.Parent = contentFrame

            local mainButton = Instance.new("TextButton")
            mainButton.Name = "MainButton"
            mainButton.Size = UDim2.new(1, 0, 1, 0)
            mainButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180) -- Blue tint for distinction
            mainButton.Text = Dropdown.CurrentOption
            mainButton.Font = Enum.Font.Gotham
            mainButton.TextColor3 = Color3.fromRGB(230, 230, 230)
            mainButton.TextSize = 16
            mainButton.Parent = container
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8) -- More rounded
            corner.Parent = mainButton
            -- Hover effect
            mainButton.MouseEnter:Connect(function()
                TweenService:Create(mainButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 149, 237)}):Play()
            end)
            mainButton.MouseLeave:Connect(function()
                TweenService:Create(mainButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 130, 180)}):Play()
            end)

            local dropdownFrame = Instance.new("ScrollingFrame")
            dropdownFrame.Name = "DropdownFrame"
            dropdownFrame.Size = UDim2.new(1, 0, 0, 140)
            dropdownFrame.Position = UDim2.new(0, 0, 1, 8)
            dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
            dropdownFrame.BorderSizePixel = 0
            dropdownFrame.Visible = false
            dropdownFrame.ZIndex = 3
            dropdownFrame.ClipsDescendants = true
            dropdownFrame.ScrollBarImageColor3 = Color3.fromRGB(90, 90, 100)
            dropdownFrame.ScrollBarThickness = 4
            dropdownFrame.Parent = container
            local dCorner = Instance.new("UICorner")
            dCorner.CornerRadius = UDim.new(0, 8) -- More rounded
            dCorner.Parent = dropdownFrame
            local dropdownLayout = Instance.new("UIListLayout")
            dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
            dropdownLayout.Padding = UDim.new(0, 4)
            dropdownLayout.Parent = dropdownFrame

            local function refreshOptions(newOptions)
                for _, child in ipairs(dropdownFrame:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                for _, optionName in ipairs(newOptions) do
                    local optionButton = Instance.new("TextButton")
                    optionButton.Name = optionName
                    optionButton.Size = UDim2.new(1, 0, 0, 36)
                    optionButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
                    optionButton.Text = optionName
                    optionButton.Font = Enum.Font.Gotham
                    optionButton.TextColor3 = Color3.fromRGB(230, 230, 230)
                    optionButton.TextSize = 16
                    optionButton.Parent = dropdownFrame
                    local oCorner = Instance.new("UICorner")
                    oCorner.CornerRadius = UDim.new(0, 8)
                    oCorner.Parent = optionButton
                    optionButton.MouseEnter:Connect(function()
                        TweenService:Create(optionButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 149, 237)}):Play()
                    end)
                    optionButton.MouseLeave:Connect(function()
                        TweenService:Create(optionButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 130, 180)}):Play()
                    end)
                    optionButton.MouseButton1Click:Connect(function()
                        Dropdown.CurrentOption = optionName
                        mainButton.Text = optionName
                        isOpen = false
                        dropdownFrame.Visible = false
                        container.ZIndex = 2
                        if options.Callback then options.Callback(optionName) end
                    end)
                end
                dropdownFrame.CanvasSize = UDim2.new(0, 0, 0, dropdownLayout.AbsoluteContentSize.Y)
            end

            mainButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                dropdownFrame.Visible = isOpen
                container.ZIndex = isOpen and 4 or 2
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
