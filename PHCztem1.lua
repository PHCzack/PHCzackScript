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
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
MainFrame.BorderSizePixel = 1
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
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = Header

local bottomFix = Instance.new("Frame")
bottomFix.Size = UDim2.new(1, 0, 0.5, 0)
bottomFix.Position = UDim2.new(0, 0, 0.5, 0)
bottomFix.BackgroundColor3 = Header.BackgroundColor3
bottomFix.BorderSizePixel = 0
bottomFix.Parent = Header

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
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
ControlsFrame.Position = UDim2.new(1, -95, 0, 0)
ControlsFrame.BackgroundTransparency = 1
ControlsFrame.Parent = Header

local controlsLayout = Instance.new("UIListLayout")
controlsLayout.FillDirection = Enum.FillDirection.Horizontal
controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
controlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
controlsLayout.Padding = UDim.new(0, 5)
controlsLayout.Parent = ControlsFrame

local function createControlButton(text, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 22, 0, 22)
    btn.BackgroundColor3 = color or Color3.fromRGB(55, 55, 55)
    btn.Text = text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.TextSize = 12
    btn.Parent = ControlsFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 3)
    corner.Parent = btn
    
    -- Hover effects
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(75, 75, 75)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = color or Color3.fromRGB(55, 55, 55)}):Play()
    end)
    
    return btn
end

local HideButton = createControlButton("X", Color3.fromRGB(220, 60, 60))
local ZoomButton = createControlButton("+", Color3.fromRGB(60, 160, 60))
local MinimizeButton = createControlButton("-", Color3.fromRGB(255, 180, 60))

--// Show UI Button
local ShowButton = Instance.new("TextButton")
ShowButton.Name = "ShowButton"
ShowButton.Size = UDim2.new(0, 100, 0, 30)
ShowButton.Position = UDim2.new(0, 10, 0, 10)
ShowButton.Text = "Show UI"
ShowButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ShowButton.TextColor3 = Color3.fromRGB(220, 220, 220)
ShowButton.Font = Enum.Font.SourceSans
ShowButton.TextSize = 14
ShowButton.Visible = false
ShowButton.ZIndex = 10
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

--// Tab container with proper styling
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(0, 130, 1, -35)
TabContainer.Position = UDim2.new(0, 0, 0, 35)
TabContainer.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

-- Add padding for tabs
local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingTop = UDim.new(0, 8)
tabPadding.PaddingLeft = UDim.new(0, 8)
tabPadding.PaddingRight = UDim.new(0, 8)
tabPadding.PaddingBottom = UDim.new(0, 8)
tabPadding.Parent = TabContainer

local tabLayout = Instance.new("UIListLayout")
tabLayout.Padding = UDim.new(0, 4)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = TabContainer

--// Content container with better styling
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -130, 1, -35)
ContentContainer.Position = UDim2.new(0, 130, 0, 35)
ContentContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
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
        contentFrame.Size = UDim2.new(1, -15, 1, -15)
        contentFrame.Position = UDim2.new(0, 8, 0, 8)
        contentFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        contentFrame.BorderSizePixel = 0
        contentFrame.Visible = false
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        contentFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
        contentFrame.ScrollBarThickness = 8
        contentFrame.Parent = ContentContainer

        -- Add padding to content
        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingAll = UDim.new(0, 8)
        contentPadding.Parent = contentFrame

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, 8)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Parent = contentFrame
        
        local function updateCanvasSize()
            contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 16)
        end
        
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)

        -- Improved tab button styling
        local tabButton = Instance.new("TextButton")
        tabButton.Name = name .. "Button"
        tabButton.Size = UDim2.new(1, -16, 0, 32)
        tabButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        tabButton.Text = name
        tabButton.Font = Enum.Font.SourceSans
        tabButton.TextColor3 = Color3.fromRGB(220, 220, 220)
        tabButton.TextSize = 14
        tabButton.Parent = TabContainer
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = tabButton

        -- Tab button hover effects
        tabButton.MouseEnter:Connect(function()
            if activeTab ~= contentFrame then
                TweenService:Create(tabButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
            end
        end)

        tabButton.MouseLeave:Connect(function()
            if activeTab ~= contentFrame then
                TweenService:Create(tabButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}):Play()
            end
        end)

        tabButton.MouseButton1Click:Connect(function()
            if activeTab then
                activeTab.Visible = false
                tabs[activeTab.Name].Button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            end
            contentFrame.Visible = true
            tabButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
            activeTab = contentFrame
        end)
        
        tabs[name] = {
            Frame = contentFrame,
            Button = tabButton,
            Layout = contentLayout
        }
        
        if not activeTab then
            contentFrame.Visible = true
            tabButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
            activeTab = contentFrame
        end

        --// Component Functions with improved styling
        function Tab:Button(options)
            local btn = Instance.new("TextButton")
            btn.Name = options.Name
            btn.Size = UDim2.new(1, 0, 0, 40)
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.Text = options.Name
            btn.Font = Enum.Font.SourceSans
            btn.TextColor3 = Color3.fromRGB(240, 240, 240)
            btn.TextSize = 16
            btn.Parent = contentFrame
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = btn
            
            -- Button hover effects
            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
            end)
            
            btn.MouseButton1Click:Connect(function() 
                if options.Callback then 
                    options.Callback() 
                end 
            end)
        end
        
        function Tab:Toggle(options)
            local state = options.StartingState or false
            
            local container = Instance.new("Frame")
            container.Name = options.Name
            container.Size = UDim2.new(1, 0, 0, 40)
            container.BackgroundTransparency = 1
            container.Parent = contentFrame
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -70, 1, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.SourceSans
            label.Text = options.Name
            label.TextColor3 = Color3.fromRGB(240, 240, 240)
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextYAlignment = Enum.TextYAlignment.Center
            label.Parent = container
            
            -- Improved toggle switch styling
            local switchTrack = Instance.new("Frame")
            switchTrack.Size = UDim2.new(0, 60, 0, 28)
            switchTrack.Position = UDim2.new(1, -60, 0.5, -14)
            switchTrack.BackgroundColor3 = state and Color3.fromRGB(80, 160, 80) or Color3.fromRGB(80, 80, 80)
            switchTrack.BorderSizePixel = 0
            switchTrack.Parent = container
            
            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(1, 0)
            trackCorner.Parent = switchTrack
            
            local switchKnob = Instance.new("Frame")
            switchKnob.Size = UDim2.new(0, 24, 0, 24)
            switchKnob.Position = state and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)
            switchKnob.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
            switchKnob.BorderSizePixel = 0
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
                local trackColor = state and Color3.fromRGB(80, 160, 80) or Color3.fromRGB(80, 80, 80)
                local knobPos = state and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)
                
                TweenService:Create(switchTrack, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {BackgroundColor3 = trackColor}):Play()
                TweenService:Create(switchKnob, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = knobPos}):Play()
                
                if options.Callback then 
                    options.Callback(state) 
                end
            end)
        end
        
        function Tab:Textbox(options)
            local container = Instance.new("Frame")
            container.Name = options.Name
            container.Size = UDim2.new(1, 0, 0, 45)
            container.BackgroundTransparency = 1
            container.Parent = contentFrame
            
            local textbox = Instance.new("TextBox")
            textbox.Size = UDim2.new(1, 0, 0, 35)
            textbox.Position = UDim2.new(0, 0, 0, 10)
            textbox.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            textbox.PlaceholderText = options.Name
            textbox.Font = Enum.Font.SourceSans
            textbox.TextColor3 = Color3.fromRGB(240, 240, 240)
            textbox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
            textbox.TextSize = 15
            textbox.ClearTextOnFocus = false
            textbox.Text = ""
            textbox.Parent = container
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = textbox
            
            -- Add padding inside textbox
            local padding = Instance.new("UIPadding")
            padding.PaddingLeft = UDim.new(0, 10)
            padding.PaddingRight = UDim.new(0, 10)
            padding.Parent = textbox
            
            textbox.FocusLost:Connect(function(enterPressed) 
                if enterPressed and options.Callback then 
                    options.Callback(textbox.Text) 
                end 
            end)
        end
        
        function Tab:Slider(options)
            local container = Instance.new("Frame")
            container.Name = options.Name
            container.Size = UDim2.new(1, 0, 0, 55)
            container.BackgroundTransparency = 1
            container.Parent = contentFrame
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 25)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.SourceSans
            label.TextColor3 = Color3.fromRGB(240, 240, 240)
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container
            
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(1, 0, 0, 12)
            sliderFrame.Position = UDim2.new(0, 0, 0, 30)
            sliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            sliderFrame.BorderSizePixel = 0
            sliderFrame.Parent = container
            
            local sCorner = Instance.new("UICorner")
            sCorner.CornerRadius = UDim.new(0, 6)
            sCorner.Parent = sliderFrame
            
            local fill = Instance.new("Frame")
            fill.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
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
            handle.Parent = sliderFrame
            
            local hCorner = Instance.new("UICorner")
            hCorner.CornerRadius = UDim.new(1, 0)
            hCorner.Parent = handle
            
            local min, max, default = options.Min or 0, options.Max or 100, options.Default or 50
            local value = default
            
            local function updateSlider(percent)
                percent = math.clamp(percent, 0, 1)
                value = min + (max - min) * percent
                fill.Size = UDim2.new(percent, 0, 1, 0)
                handle.Position = UDim2.new(percent, -10, 0.5, -10)
                label.Text = string.format("%s: %.1f", options.Name, value)
                if options.Callback then 
                    options.Callback(value) 
                end
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
            
            handle.InputEnded:Connect(function() 
                if dragConnection then 
                    dragConnection:Disconnect() 
                end 
            end)
        end
        
        function Tab:Keybind(options)
            local container = Instance.new("Frame")
            container.Name = options.Name
            container.Size = UDim2.new(1, 0, 0, 40)
            container.BackgroundTransparency = 1
            container.Parent = contentFrame
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.6, -5, 1, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.SourceSans
            label.Text = options.Name
            label.TextColor3 = Color3.fromRGB(240, 240, 240)
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextYAlignment = Enum.TextYAlignment.Center
            label.Parent = container
            
            local keybindButton = Instance.new("TextButton")
            keybindButton.Size = UDim2.new(0.4, 0, 0, 30)
            keybindButton.Position = UDim2.new(0.6, 0, 0.5, -15)
            keybindButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            keybindButton.Text = options.Keybind or "None"
            keybindButton.Font = Enum.Font.SourceSans
            keybindButton.TextColor3 = Color3.fromRGB(220, 220, 220)
            keybindButton.TextSize = 14
            keybindButton.Parent = container
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = keybindButton
            
            keybindButton.MouseButton1Click:Connect(function()
                keybindButton.Text = "Press key..."
                local connection
                connection = UserInputService.InputBegan:Connect(function(input, gp)
                    if gp then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        keybindButton.Text = input.KeyCode.Name
                        connection:Disconnect()
                        if options.Callback then
                            options.Callback(input.KeyCode)
                        end
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
            container.Size = UDim2.new(1, 0, 0, 40)
            container.BackgroundTransparency = 1
            container.ZIndex = 2
            container.Parent = contentFrame

            local mainButton = Instance.new("TextButton")
            mainButton.Name = "MainButton"
            mainButton.Size = UDim2.new(1, 0, 1, 0)
            mainButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            mainButton.Text = Dropdown.CurrentOption
            mainButton.Font = Enum.Font.SourceSans
            mainButton.TextColor3 = Color3.fromRGB(240, 240, 240)
            mainButton.TextSize = 15
            mainButton.Parent = container
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = mainButton
            
            -- Add dropdown arrow
            local arrow = Instance.new("TextLabel")
            arrow.Size = UDim2.new(0, 20, 1, 0)
            arrow.Position = UDim2.new(1, -25, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text = "▼"
            arrow.TextColor3 = Color3.fromRGB(180, 180, 180)
            arrow.TextSize = 12
            arrow.Font = Enum.Font.SourceSans
            arrow.Parent = mainButton

            local dropdownFrame = Instance.new("ScrollingFrame")
            dropdownFrame.Name = "DropdownFrame"
            dropdownFrame.Size = UDim2.new(1, 0, 0, math.min(120, #options.Options * 35))
            dropdownFrame.Position = UDim2.new(0, 0, 1, 5)
            dropdownFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            dropdownFrame.BorderSizePixel = 1
            dropdownFrame.BorderColor3 = Color3.fromRGB(70, 70, 70)
            dropdownFrame.Visible = false
            dropdownFrame.ZIndex = 10
            dropdownFrame.ClipsDescendants = true
            dropdownFrame.ScrollBarThickness = 6
            dropdownFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
            dropdownFrame.Parent = container
            
            local dCorner = Instance.new("UICorner")
            dCorner.CornerRadius = UDim.new(0, 6)
            dCorner.Parent = dropdownFrame
            
            local dropdownLayout = Instance.new("UIListLayout")
            dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
            dropdownLayout.Padding = UDim.new(0, 2)
            dropdownLayout.Parent = dropdownFrame

            local function refreshOptions(newOptions)
                for _, child in ipairs(dropdownFrame:GetChildren()) do
                    if child:IsA("TextButton") then 
                        child:Destroy() 
                    end
                end
                
                for _, optionName in ipairs(newOptions) do
                    local optionButton = Instance.new("TextButton")
                    optionButton.Name = optionName
                    optionButton.Size = UDim2.new(1, -4, 0, 32)
                    optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    optionButton.Text = optionName
                    optionButton.Font = Enum.Font.SourceSans
                    optionButton.TextColor3 = Color3.fromRGB(220, 220, 220)
                    optionButton.TextSize = 14
                    optionButton.Parent = dropdownFrame
                    
                    local optionCorner = Instance.new("UICorner")
                    optionCorner.CornerRadius = UDim.new(0, 4)
                    optionCorner.Parent = optionButton
                    
                    optionButton.MouseEnter:Connect(function() 
                        optionButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70) 
                    end)
                    optionButton.MouseLeave:Connect(function() 
                        optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50) 
                    end)
                    
                    optionButton.MouseButton1Click:Connect(function()
                        Dropdown.CurrentOption = optionName
                        mainButton.Text = optionName
                        isOpen = false
                        dropdownFrame.Visible = false
                        container.ZIndex = 2
                        arrow.Text = "▼"
                        if options.Callback then 
                            options.Callback(optionName) 
                        end
                    end)
                end
                
                dropdownFrame.CanvasSize = UDim2.new(0, 0, 0, dropdownLayout.AbsoluteContentSize.Y)
            end

            mainButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                dropdownFrame.Visible = isOpen
                container.ZIndex = isOpen and 15 or 2
                arrow.Text = isOpen and "▲" or "▼"
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

        function Tab:Label(options)
            local label = Instance.new("TextLabel")
            label.Name = options.Name
            label.Size = UDim2.new(1, 0, 0, 30)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.SourceSans
            label.Text = options.Text or options.Name
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextSize = 15
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextYAlignment = Enum.TextYAlignment.Center
            label.Parent = contentFrame
        end

        function Tab:Divider()
            local divider = Instance.new("Frame")
            divider.Name = "Divider"
            divider.Size = UDim2.new(1, 0, 0, 1)
            divider.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            divider.BorderSizePixel = 0
            divider.Parent = contentFrame
        end

        return Tab
    end
    
    return Window
end

return GUI
