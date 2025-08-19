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
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 27)
MainFrame.BorderColor3 = Color3.fromRGB(45, 47, 55)
MainFrame.BorderSizePixel = 1
MainFrame.Active = true
MainFrame.Visible = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = MainGui

--// Corner radius for modern look
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = MainFrame

--// Add subtle shadow effect
local shadowFrame = Instance.new("Frame")
shadowFrame.Name = "Shadow"
shadowFrame.Size = UDim2.new(1, 4, 1, 4)
shadowFrame.Position = UDim2.new(0, -2, 0, -2)
shadowFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadowFrame.BackgroundTransparency = 0.7
shadowFrame.ZIndex = -1
shadowFrame.Parent = MainFrame
local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0, 14)
shadowCorner.Parent = shadowFrame

--// Header for title and dragging
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(15, 17, 22)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = Header

local bottomFix = Instance.new("Frame")
bottomFix.Size = UDim2.new(1,0,0.5,0)
bottomFix.Position = UDim2.new(0,0,0.5,0)
bottomFix.BackgroundColor3 = Header.BackgroundColor3
bottomFix.BorderSizePixel = 0
bottomFix.Parent = Header

--// Header gradient
local headerGradient = Instance.new("UIGradient")
headerGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 27, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 17, 22))
}
headerGradient.Rotation = 90
headerGradient.Parent = Header

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "My Awesome Game UI"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
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

local function createControlButton(text, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 24, 0, 24)
    btn.BackgroundColor3 = color or Color3.fromRGB(55, 57, 65)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Parent = ControlsFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    -- Hover effects
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(75, 77, 85)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color or Color3.fromRGB(55, 57, 65)}):Play()
    end)
    
    return btn
end

local HideButton = createControlButton("✕", Color3.fromRGB(255, 95, 86))
local ZoomButton = createControlButton("⬜", Color3.fromRGB(255, 189, 46))
local MinimizeButton = createControlButton("—", Color3.fromRGB(40, 201, 64))

--// Show UI Button with modern design
local ShowButton = Instance.new("TextButton")
ShowButton.Name = "ShowButton"
ShowButton.Size = UDim2.new(0, 120, 0, 40)
ShowButton.Position = UDim2.new(0, 15, 0, 15)
ShowButton.Text = "Show UI"
ShowButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
ShowButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ShowButton.Font = Enum.Font.GothamSemibold
ShowButton.TextSize = 14
ShowButton.Visible = false
ShowButton.ZIndex = 10
ShowButton.Parent = MainGui

local showCorner = Instance.new("UICorner")
showCorner.CornerRadius = UDim.new(0, 10)
showCorner.Parent = ShowButton

-- Show button gradient
local showGradient = Instance.new("UIGradient")
showGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(67, 78, 210))
}
showGradient.Rotation = 45
showGradient.Parent = ShowButton

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
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, Header.AbsoluteSize.Y)}):Play()
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = originalSize}):Play()
    end
end)

ZoomButton.MouseButton1Click:Connect(function()
    isZoomed = not isZoomed
    if isZoomed then
        isMinimized = false
        originalSize = MainFrame.Size
        originalPosition = MainFrame.Position
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Size = zoomedSize,
            Position = UDim2.new(0.5, -zoomedSize.X.Offset/2, 0.5, -zoomedSize.Y.Offset/2)
        }):Play()
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = originalSize, Position = originalPosition}):Play()
    end
end)

--// Tab container with modern styling
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(0, 140, 1, -40)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundColor3 = Color3.fromRGB(15, 17, 22)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingTop = UDim.new(0, 10)
tabPadding.PaddingLeft = UDim.new(0, 10)
tabPadding.PaddingRight = UDim.new(0, 10)
tabPadding.Parent = TabContainer

local tabLayout = Instance.new("UIListLayout")
tabLayout.Padding = UDim.new(0, 8)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = TabContainer

--// Content container with improved styling
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -140, 1, -40)
ContentContainer.Position = UDim2.new(0, 140, 0, 40)
ContentContainer.BackgroundColor3 = Color3.fromRGB(25, 27, 35)
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
        contentFrame.Size = UDim2.new(1, -20, 1, -20)
        contentFrame.Position = UDim2.new(0, 10, 0, 10)
        contentFrame.BackgroundColor3 = Color3.fromRGB(25, 27, 35)
        contentFrame.BorderSizePixel = 0
        contentFrame.Visible = false
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        contentFrame.ScrollBarImageColor3 = Color3.fromRGB(88, 101, 242)
        contentFrame.ScrollBarThickness = 4
        contentFrame.Parent = ContentContainer

        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingAll = UDim.new(0, 10)
        contentPadding.Parent = contentFrame

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, 15)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Parent = contentFrame
        
        local function updateCanvasSize()
            contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
        end
        
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)

        local tabButton = Instance.new("TextButton")
        tabButton.Name = name .. "Button"
        tabButton.Size = UDim2.new(1, -10, 0, 40)
        tabButton.Position = UDim2.new(0, 5, 0, 0)
        tabButton.BackgroundColor3 = Color3.fromRGB(35, 37, 45)
        tabButton.Text = name
        tabButton.Font = Enum.Font.GothamSemibold
        tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabButton.TextSize = 14
        tabButton.Parent = TabContainer
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = tabButton

        -- Tab button hover effects
        tabButton.MouseEnter:Connect(function()
            if activeTab ~= contentFrame then
                TweenService:Create(tabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 47, 55)}):Play()
            end
        end)
        tabButton.MouseLeave:Connect(function()
            if activeTab ~= contentFrame then
                TweenService:Create(tabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 37, 45)}):Play()
            end
        end)

        tabButton.MouseButton1Click:Connect(function()
            if activeTab then
                activeTab.Visible = false
                tabs[activeTab.Name].Button.BackgroundColor3 = Color3.fromRGB(35, 37, 45)
            end
            contentFrame.Visible = true
            tabButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
            activeTab = contentFrame
        end)
        
        tabs[name] = {
            Frame = contentFrame,
            Button = tabButton,
            Layout = contentLayout
        }
        
        if not activeTab then
            contentFrame.Visible = true
            tabButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
            activeTab = contentFrame
        end

        --// Enhanced Button Component
        function Tab:Button(options)
            local btn = Instance.new("TextButton")
            btn.Name = options.Name
            btn.Size = UDim2.new(1, 0, 0, 45)
            btn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
            btn.Text = options.Name
            btn.Font = Enum.Font.GothamSemibold
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 16
            btn.Parent = contentFrame
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = btn
            
            -- Button gradient
            local gradient = Instance.new("UIGradient")
            gradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(67, 78, 210))
            }
            gradient.Rotation = 45
            gradient.Parent = btn
            
            -- Enhanced hover and click effects
            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 47)}):Play()
                TweenService:Create(gradient, TweenInfo.new(0.2), {
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(108, 121, 262)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(87, 98, 230))
                    }
                }):Play()
            end)
            
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 45)}):Play()
                TweenService:Create(gradient, TweenInfo.new(0.2), {
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(67, 78, 210))
                    }
                }):Play()
            end)
            
            btn.MouseButton1Down:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 43)}):Play()
            end)
            
            btn.MouseButton1Up:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 47)}):Play()
            end)
            
            btn.MouseButton1Click:Connect(function() 
                if options.Callback then options.Callback() end 
            end)
        end
        
        --// Enhanced Toggle Component
        function Tab:Toggle(options)
            local state = options.StartingState or false
            local container = Instance.new("Frame")
            container.Name = options.Name
            container.Size = UDim2.new(1, 0, 0, 40)
            container.BackgroundColor3 = Color3.fromRGB(35, 37, 45)
            container.Parent = contentFrame
            
            local containerCorner = Instance.new("UICorner")
            containerCorner.CornerRadius = UDim.new(0, 8)
            containerCorner.Parent = container
            
            local containerPadding = Instance.new("UIPadding")
            containerPadding.PaddingAll = UDim.new(0, 15)
            containerPadding.Parent = container
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -70, 1, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamSemibold
            label.Text = options.Name
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container
            
            local switchTrack = Instance.new("Frame")
            switchTrack.Size = UDim2.new(0, 60, 0, 30)
            switchTrack.Position = UDim2.new(1, -60, 0.5, -15)
            switchTrack.BackgroundColor3 = state and Color3.fromRGB(88, 101, 242) or Color3.fromRGB(65, 67, 75)
            switchTrack.Parent = container
            
            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(1, 0)
            trackCorner.Parent = switchTrack
            
            -- Track gradient
            local trackGradient = Instance.new("UIGradient")
            if state then
                trackGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(67, 78, 210))
                }
            else
                trackGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(65, 67, 75)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(55, 57, 65))
                }
            end
            trackGradient.Rotation = 45
            trackGradient.Parent = switchTrack
            
            local switchKnob = Instance.new("Frame")
            switchKnob.Size = UDim2.new(0, 26, 0, 26)
            switchKnob.Position = state and UDim2.new(1, -28, 0.5, -13) or UDim2.new(0, 2, 0.5, -13)
            switchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            switchKnob.Parent = switchTrack
            
            local knobCorner = Instance.new("UICorner")
            knobCorner.CornerRadius = UDim.new(1, 0)
            knobCorner.Parent = switchKnob
            
            -- Knob shadow
            local knobShadow = Instance.new("Frame")
            knobShadow.Size = UDim2.new(1, 2, 1, 2)
            knobShadow.Position = UDim2.new(0, -1, 0, -1)
            knobShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            knobShadow.BackgroundTransparency = 0.8
            knobShadow.ZIndex = -1
            knobShadow.Parent = switchKnob
            local shadowCorner2 = Instance.new("UICorner")
            shadowCorner2.CornerRadius = UDim.new(1, 0)
            shadowCorner2.Parent = knobShadow
            
            local clickDetector = Instance.new("TextButton")
            clickDetector.Size = UDim2.new(1, 0, 1, 0)
            clickDetector.BackgroundTransparency = 1
            clickDetector.Text = ""
            clickDetector.Parent = switchTrack
            
            clickDetector.MouseButton1Click:Connect(function()
                state = not state
                local trackColor, gradientColor, knobPos
                
                if state then
                    trackColor = Color3.fromRGB(88, 101, 242)
                    gradientColor = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(67, 78, 210))
                    }
                    knobPos = UDim2.new(1, -28, 0.5, -13)
                else
                    trackColor = Color3.fromRGB(65, 67, 75)
                    gradientColor = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(65, 67, 75)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(55, 57, 65))
                    }
                    knobPos = UDim2.new(0, 2, 0.5, -13)
                end
                
                TweenService:Create(switchTrack, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundColor3 = trackColor}):Play()
                TweenService:Create(trackGradient, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Color = gradientColor}):Play()
                TweenService:Create(switchKnob, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = knobPos}):Play()
                
                if options.Callback then options.Callback(state) end
            end)
        end
        
        --// Enhanced Textbox Component
        function Tab:Textbox(options)
            local container = Instance.new("Frame")
            container.Name = options.Name
            container.Size = UDim2.new(1, 0, 0, 50)
            container.BackgroundColor3 = Color3.fromRGB(35, 37, 45)
            container.Parent = contentFrame
            
            local containerCorner = Instance.new("UICorner")
            containerCorner.CornerRadius = UDim.new(0, 8)
            containerCorner.Parent = container
            
            local containerPadding = Instance.new("UIPadding")
            containerPadding.PaddingAll = UDim.new(0, 15)
            containerPadding.Parent = container
            
            local textbox = Instance.new("TextBox")
            textbox.Size = UDim2.new(1, 0, 1, 0)
            textbox.BackgroundTransparency = 1
            textbox.PlaceholderText = options.Name
            textbox.Font = Enum.Font.Gotham
            textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
            textbox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
            textbox.TextSize = 16
            textbox.TextXAlignment = Enum.TextXAlignment.Left
            textbox.ClearTextOnFocus = false
            textbox.Parent = container
            
            -- Focus border effect
            local border = Instance.new("UIStroke")
            border.Thickness = 2
            border.Color = Color3.fromRGB(55, 57, 65)
            border.Transparency = 1
            border.Parent = container
            
            textbox.Focused:Connect(function()
                TweenService:Create(border, TweenInfo.new(0.2), {
                    Color = Color3.fromRGB(88, 101, 242),
                    Transparency = 0
                }):Play()
            end)
            
            textbox.FocusLost:Connect(function(enterPressed)
                TweenService:Create(border, TweenInfo.new(0.2), {Transparency = 1}):Play()
                if enterPressed and options.Callback then 
                    options.Callback(textbox.Text) 
                end
            end)
        end
        
        --// Enhanced Slider Component
        function Tab:Slider(options)
            local container = Instance.new("Frame")
            container.Name = options.Name
            container.Size = UDim2.new(1, 0, 0, 60)
            container.BackgroundColor3 = Color3.fromRGB(35, 37, 45)
            container.Parent = contentFrame
            
            local containerCorner = Instance.new("UICorner")
            containerCorner.CornerRadius = UDim.new(0, 8)
            containerCorner.Parent = container
            
            local containerPadding = Instance.new("UIPadding")
            containerPadding.PaddingAll = UDim.new(0, 15)
            containerPadding.Parent = container
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 20)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamSemibold
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container
            
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(1, 0, 0, 6)
            sliderFrame.Position = UDim2.new(0, 0, 0, 30)
            sliderFrame.BackgroundColor3 = Color3.fromRGB(55, 57, 65)
            sliderFrame.Parent = container
            
            local sCorner = Instance.new("UICorner")
            sCorner.CornerRadius = UDim.new(0, 3)
            sCorner.Parent = sliderFrame
            
            local fill = Instance.new("Frame")
            fill.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
            fill.BorderSizePixel = 0
            fill.Parent = sliderFrame
            
            local fCorner = Instance.new("UICorner")
            fCorner.CornerRadius = UDim.new(0, 3)
            fCorner.Parent = fill
            
            -- Fill gradient
            local fillGradient = Instance.new("UIGradient")
            fillGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(67, 78, 210))
            }
            fillGradient.Parent = fill
            
            local handle = Instance.new("Frame")
            handle.Size = UDim2.new(0, 20, 0, 20)
            handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            handle.ZIndex = 2
            handle.Parent = fill
            
            local hCorner = Instance.new("UICorner")
            hCorner.CornerRadius = UDim.new(1, 0)
            hCorner.Parent = handle
            
            -- Handle shadow
            local handleShadow = Instance.new("Frame")
            handleShadow.Size = UDim2.new(1, 4, 1, 4)
            handleShadow.Position = UDim2.new(0, -2, 0, -2)
            handleShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            handleShadow.BackgroundTransparency = 0.7
            handleShadow.ZIndex = 1
            handleShadow.Parent = handle
            local hsCorner = Instance.new("UICorner")
            hsCorner.CornerRadius = UDim.new(1, 0)
            hsCorner.Parent = handleShadow
            
            -- Invisible button for dragging
            local handleButton = Instance.new("TextButton")
            handleButton.Size = UDim2.new(0, 30, 0, 30)
            handleButton.Position = UDim2.new(0.5, -15, 0.5, -15)
            handleButton.BackgroundTransparency = 1
            handleButton.Text = ""
            handleButton.ZIndex = 3
            handleButton.Parent = handle
            
            local min, max, default = options.Min or 0, options.Max or 100, options.Default or 50
            local value = default
            
            local function updateSlider(percent)
                percent = math.clamp(percent, 0, 1)
                value = min + (max - min) * percent
                fill.Size = UDim2.new(percent, 0, 1, 0)
                handle.Position = UDim2.new(percent, -10, 0.5, -10)
                label.Text = string.format("%s: %.1f", options.Name, value)
                if options.Callback then options.Callback(value) end
            end
            
            updateSlider((default - min) / (max - min))
            
            local dragConnection
            local isDragging = false
            
            handleButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = true
                    TweenService:Create(handle, TweenInfo.new(0.1), {Size = UDim2.new(0, 24, 0, 24)}):Play()
                    
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
            
            handleButton.InputEnded:Connect(function()
                if isDragging then
                    isDragging = false
                    TweenService:Create(handle, TweenInfo.new(0.1), {Size = UDim2.new(0, 20, 0, 20)}):Play()
                    if dragConnection then 
                        dragConnection:Disconnect() 
                        dragConnection = nil
                    end
                end
            end)
            
            -- Hover effects
            handleButton.MouseEnter:Connect(function()
                if not isDragging then
                    TweenService:Create(handle, TweenInfo.new(0.2), {Size = UDim2.new(0, 22, 0, 22)}):Play()
                end
            end)
            
            handleButton.MouseLeave:Connect(function()
                if not isDragging then
                    TweenService:Create(handle, TweenInfo.new(0.2), {Size = UDim2.new(0, 20, 0, 20)}):Play()
                end
            end)
        end
        
        --// Enhanced Keybind Component
        function Tab:Keybind(options)
            local container = Instance.new("Frame")
            container.Name = options.Name
            container.Size = UDim2.new(1, 0, 0, 40)
            container.BackgroundColor3 = Color3.fromRGB(35, 37, 45)
            container.Parent = contentFrame
            
            local containerCorner = Instance.new("UICorner")
            containerCorner.CornerRadius = UDim.new(0, 8)
            containerCorner.Parent = container
            
            local containerPadding = Instance.new("UIPadding")
            containerPadding.PaddingAll = UDim.new(0, 15)
            containerPadding.Parent = container
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.6, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamSemibold
            label.Text = options.Name
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container
            
            local keybindButton = Instance.new("TextButton")
            keybindButton.Size = UDim2.new(0.4, -10, 1, 0)
            keybindButton.Position = UDim2.new(0.6, 10, 0, 0)
            keybindButton.BackgroundColor3 = Color3.fromRGB(55, 57, 65)
            keybindButton.Text = options.Keybind or "None"
            keybindButton.Font = Enum.Font.Gotham
            keybindButton.TextColor3 = Color3.fromRGB(220, 220, 220)
            keybindButton.TextSize = 14
            keybindButton.Parent = container
            
            local kCorner = Instance.new("UICorner")
            kCorner.CornerRadius = UDim.new(0, 6)
            kCorner.Parent = keybindButton
            
            local kBorder = Instance.new("UIStroke")
            kBorder.Thickness = 1
            kBorder.Color = Color3.fromRGB(75, 77, 85)
            kBorder.Parent = keybindButton
            
            keybindButton.MouseEnter:Connect(function()
                TweenService:Create(keybindButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(65, 67, 75)}):Play()
                TweenService:Create(kBorder, TweenInfo.new(0.2), {Color = Color3.fromRGB(88, 101, 242)}):Play()
            end)
            
            keybindButton.MouseLeave:Connect(function()
                TweenService:Create(keybindButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 57, 65)}):Play()
                TweenService:Create(kBorder, TweenInfo.new(0.2), {Color = Color3.fromRGB(75, 77, 85)}):Play()
            end)
            
            keybindButton.MouseButton1Click:Connect(function()
                keybindButton.Text = "Press a key..."
                keybindButton.TextColor3 = Color3.fromRGB(88, 101, 242)
                
                local connection
                connection = UserInputService.InputBegan:Connect(function(input, gp)
                    if gp then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        keybindButton.Text = input.KeyCode.Name
                        keybindButton.TextColor3 = Color3.fromRGB(220, 220, 220)
                        connection:Disconnect()
                        if options.Callback then options.Callback(input.KeyCode) end
                    end
                end)
            end)
        end
        
        --// Enhanced Dropdown Component
        function Tab:Dropdown(options)
            local Dropdown = {}
            Dropdown.CurrentOption = options.CurrentOption or options.Options[1]
            local isOpen = false

            local container = Instance.new("Frame")
            container.Name = options.Name
            container.Size = UDim2.new(1, 0, 0, 45)
            container.BackgroundColor3 = Color3.fromRGB(35, 37, 45)
            container.ZIndex = 2
            container.Parent = contentFrame
            
            local containerCorner = Instance.new("UICorner")
            containerCorner.CornerRadius = UDim.new(0, 8)
            containerCorner.Parent = container
            
            local containerPadding = Instance.new("UIPadding")
            containerPadding.PaddingAll = UDim.new(0, 15)
            containerPadding.Parent = container

            local mainButton = Instance.new("TextButton")
            mainButton.Name = "MainButton"
            mainButton.Size = UDim2.new(1, 0, 1, 0)
            mainButton.BackgroundTransparency = 1
            mainButton.Text = Dropdown.CurrentOption
            mainButton.Font = Enum.Font.GothamSemibold
            mainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            mainButton.TextSize = 16
            mainButton.TextXAlignment = Enum.TextXAlignment.Left
            mainButton.Parent = container
            
            -- Dropdown arrow
            local arrow = Instance.new("TextLabel")
            arrow.Size = UDim2.new(0, 20, 1, 0)
            arrow.Position = UDim2.new(1, -20, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text = "▼"
            arrow.Font = Enum.Font.GothamBold
            arrow.TextColor3 = Color3.fromRGB(150, 150, 150)
            arrow.TextSize = 12
            arrow.TextXAlignment = Enum.TextXAlignment.Center
            arrow.Parent = container
            
            local dropdownFrame = Instance.new("ScrollingFrame")
            dropdownFrame.Name = "DropdownFrame"
            dropdownFrame.Size = UDim2.new(1, 0, 0, 150)
            dropdownFrame.Position = UDim2.new(0, 0, 1, 5)
            dropdownFrame.BackgroundColor3 = Color3.fromRGB(25, 27, 35)
            dropdownFrame.BorderSizePixel = 0
            dropdownFrame.Visible = false
            dropdownFrame.ZIndex = 5
            dropdownFrame.ClipsDescendants = true
            dropdownFrame.ScrollBarImageColor3 = Color3.fromRGB(88, 101, 242)
            dropdownFrame.ScrollBarThickness = 4
            dropdownFrame.Parent = container
            
            local dCorner = Instance.new("UICorner")
            dCorner.CornerRadius = UDim.new(0, 8)
            dCorner.Parent = dropdownFrame
            
            local dBorder = Instance.new("UIStroke")
            dBorder.Thickness = 1
            dBorder.Color = Color3.fromRGB(55, 57, 65)
            dBorder.Parent = dropdownFrame
            
            local dropdownLayout = Instance.new("UIListLayout")
            dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
            dropdownLayout.Padding = UDim.new(0, 2)
            dropdownLayout.Parent = dropdownFrame

            local function refreshOptions(newOptions)
                for _, child in ipairs(dropdownFrame:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                
                for _, optionName in ipairs(newOptions) do
                    local optionButton = Instance.new("TextButton")
                    optionButton.Name = optionName
                    optionButton.Size = UDim2.new(1, 0, 0, 35)
                    optionButton.BackgroundColor3 = Color3.fromRGB(35, 37, 45)
                    optionButton.Text = optionName
                    optionButton.Font = Enum.Font.Gotham
                    optionButton.TextColor3 = Color3.fromRGB(220, 220, 220)
                    optionButton.TextSize = 14
                    optionButton.TextXAlignment = Enum.TextXAlignment.Left
                    optionButton.ZIndex = 6
                    optionButton.Parent = dropdownFrame
                    
                    local oPadding = Instance.new("UIPadding")
                    oPadding.PaddingLeft = UDim.new(0, 10)
                    oPadding.Parent = optionButton
                    
                    local oCorner = Instance.new("UICorner")
                    oCorner.CornerRadius = UDim.new(0, 4)
                    oCorner.Parent = optionButton
                    
                    optionButton.MouseEnter:Connect(function() 
                        TweenService:Create(optionButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}):Play()
                    end)
                    
                    optionButton.MouseLeave:Connect(function() 
                        TweenService:Create(optionButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 37, 45)}):Play()
                    end)
                    
                    optionButton.MouseButton1Click:Connect(function()
                        Dropdown.CurrentOption = optionName
                        mainButton.Text = optionName
                        isOpen = false
                        dropdownFrame.Visible = false
                        container.ZIndex = 2
                        
                        -- Animate arrow
                        TweenService:Create(arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
                        
                        if options.Callback then options.Callback(optionName) end
                    end)
                end
                dropdownFrame.CanvasSize = UDim2.new(0, 0, 0, dropdownLayout.AbsoluteContentSize.Y)
            end

            mainButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                dropdownFrame.Visible = isOpen
                container.ZIndex = isOpen and 6 or 2
                
                -- Animate arrow
                local rotation = isOpen and 180 or 0
                TweenService:Create(arrow, TweenInfo.new(0.2), {Rotation = rotation}):Play()
                
                -- Animate dropdown appearance
                if isOpen then
                    dropdownFrame.Size = UDim2.new(1, 0, 0, 0)
                    TweenService:Create(dropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 150)}):Play()
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
