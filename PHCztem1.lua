--[[
    Modular UI Library by Gemini (Upgraded Version 3 - Improved Visual Design)
    Place this script in: StarterPlayer > StarterPlayerScripts
    This is the main library module with enhanced visual components.
]]

--// Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// Main GUI Library Table
local GUI = {}
GUI.__index = GUI

--// Color Theme
local Theme = {
    Background = Color3.fromRGB(22, 22, 22),
    Surface = Color3.fromRGB(30, 30, 30),
    SurfaceVariant = Color3.fromRGB(40, 40, 40),
    Primary = Color3.fromRGB(88, 166, 255),
    PrimaryDark = Color3.fromRGB(66, 133, 244),
    Secondary = Color3.fromRGB(255, 193, 7),
    Success = Color3.fromRGB(76, 175, 80),
    Error = Color3.fromRGB(244, 67, 54),
    OnSurface = Color3.fromRGB(255, 255, 255),
    OnSurfaceMuted = Color3.fromRGB(180, 180, 180),
    OnSurfaceDisabled = Color3.fromRGB(120, 120, 120),
    Accent = Color3.fromRGB(129, 199, 132)
}

--// Main ScreenGui and configuration
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "MainGui"
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MainGui.ResetOnSpawn = false

--// Create the main frame for the UI
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Visible = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = MainGui

--// Main frame shadow effect
local mainShadow = Instance.new("Frame")
mainShadow.Name = "Shadow"
mainShadow.Size = UDim2.new(1, 6, 1, 6)
mainShadow.Position = UDim2.new(0, -3, 0, -3)
mainShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainShadow.BackgroundTransparency = 0.8
mainShadow.ZIndex = -1
mainShadow.Parent = MainFrame

local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0, 12)
shadowCorner.Parent = mainShadow

--// Corner radius for modern look
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = MainFrame

--// Header for title and dragging
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Theme.Surface
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = Header

-- Fix for rounded corners on header bottom
local bottomFix = Instance.new("Frame")
bottomFix.Size = UDim2.new(1, 0, 0.5, 0)
bottomFix.Position = UDim2.new(0, 0, 0.5, 0)
bottomFix.BackgroundColor3 = Header.BackgroundColor3
bottomFix.BorderSizePixel = 0
bottomFix.Parent = Header

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -120, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "My Awesome Game UI"
Title.TextColor3 = Theme.OnSurface
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

--// Window Controls (Minimize, Zoom, Hide)
local ControlsFrame = Instance.new("Frame")
ControlsFrame.Name = "ControlsFrame"
ControlsFrame.Size = UDim2.new(0, 100, 1, 0)
ControlsFrame.Position = UDim2.new(1, -100, 0, 0)
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
    btn.BackgroundColor3 = color or Theme.SurfaceVariant
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Theme.OnSurface
    btn.TextSize = 12
    btn.Parent = ControlsFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    -- Hover effects
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(math.min(255, color.R * 255 + 20), math.min(255, color.G * 255 + 20), math.min(255, color.B * 255 + 20))}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
    end)
    
    return btn
end

local HideButton = createControlButton("✕", Theme.Error)
local ZoomButton = createControlButton("⛶", Theme.Primary)
local MinimizeButton = createControlButton("—", Theme.Secondary)

--// Show UI Button (improved design)
local ShowButton = Instance.new("TextButton")
ShowButton.Name = "ShowButton"
ShowButton.Size = UDim2.new(0, 120, 0, 35)
ShowButton.Position = UDim2.new(0, 15, 0, 15)
ShowButton.Text = "Show UI ⚙️"
ShowButton.BackgroundColor3 = Theme.Primary
ShowButton.TextColor3 = Theme.OnSurface
ShowButton.Font = Enum.Font.GothamSemibold
ShowButton.TextSize = 14
ShowButton.Visible = false
ShowButton.ZIndex = 10
ShowButton.Parent = MainGui

local showCorner = Instance.new("UICorner")
showCorner.CornerRadius = UDim.new(0, 8)
showCorner.Parent = ShowButton

-- Show button shadow
local showShadow = Instance.new("Frame")
showShadow.Name = "Shadow"
showShadow.Size = UDim2.new(1, 4, 1, 4)
showShadow.Position = UDim2.new(0, -2, 0, -2)
showShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
showShadow.BackgroundTransparency = 0.7
showShadow.ZIndex = 9
showShadow.Parent = ShowButton

local showShadowCorner = Instance.new("UICorner")
showShadowCorner.CornerRadius = UDim.new(0, 8)
showShadowCorner.Parent = showShadow

ShowButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    ShowButton.Visible = false
end)

--// Window state variables
local isMinimized = false
local isZoomed = false
local originalSize = MainFrame.Size
local originalPosition = MainFrame.Position
local zoomedSize = UDim2.new(0, 900, 0, 600)

HideButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ShowButton.Visible = true
end)

MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        isZoomed = false
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, Header.AbsoluteSize.Y)}):Play()
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = originalSize}):Play()
    end
end)

ZoomButton.MouseButton1Click:Connect(function()
    isZoomed = not isZoomed
    if isZoomed then
        isMinimized = false
        originalSize = MainFrame.Size
        originalPosition = MainFrame.Position
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = zoomedSize,
            Position = UDim2.new(0.5, -zoomedSize.X.Offset/2, 0.5, -zoomedSize.Y.Offset/2)
        }):Play()
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = originalSize, Position = originalPosition}):Play()
    end
end)

--// Tab container
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(0, 140, 1, -40)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundColor3 = Theme.Surface
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingTop = UDim.new(0, 10)
tabPadding.PaddingBottom = UDim.new(0, 10)
tabPadding.PaddingLeft = UDim.new(0, 10)
tabPadding.PaddingRight = UDim.new(0, 10)
tabPadding.Parent = TabContainer

local tabLayout = Instance.new("UIListLayout")
tabLayout.Padding = UDim.new(0, 8)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = TabContainer

--// Content container
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -140, 1, -40)
ContentContainer.Position = UDim2.new(0, 140, 0, 40)
ContentContainer.BackgroundColor3 = Theme.Background
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
        contentFrame.BackgroundColor3 = Theme.Background
        contentFrame.BorderSizePixel = 0
        contentFrame.Visible = false
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        contentFrame.ScrollBarImageColor3 = Theme.Primary
        contentFrame.ScrollBarThickness = 4
        contentFrame.ScrollingDirection = Enum.ScrollingDirection.Y
        contentFrame.Parent = ContentContainer

        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingAll = UDim.new(0, 15)
        contentPadding.Parent = contentFrame

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, 15)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Parent = contentFrame
        
        local function updateCanvasSize()
            contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 30)
        end
        
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)

        local tabButton = Instance.new("TextButton")
        tabButton.Name = name .. "Button"
        tabButton.Size = UDim2.new(1, 0, 0, 40)
        tabButton.Position = UDim2.new(0, 0, 0, 0)
        tabButton.BackgroundColor3 = Theme.SurfaceVariant
        tabButton.Text = name
        tabButton.Font = Enum.Font.GothamSemibold
        tabButton.TextColor3 = Theme.OnSurfaceMuted
        tabButton.TextSize = 14
        tabButton.Parent = TabContainer
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = tabButton

        -- Tab selection indicator
        local indicator = Instance.new("Frame")
        indicator.Name = "Indicator"
        indicator.Size = UDim2.new(0, 3, 0.7, 0)
        indicator.Position = UDim2.new(0, -1, 0.15, 0)
        indicator.BackgroundColor3 = Theme.Primary
        indicator.BorderSizePixel = 0
        indicator.Visible = false
        indicator.Parent = tabButton
        
        local indicatorCorner = Instance.new("UICorner")
        indicatorCorner.CornerRadius = UDim.new(0, 2)
        indicatorCorner.Parent = indicator

        tabButton.MouseButton1Click:Connect(function()
            if activeTab then
                activeTab.Visible = false
                tabs[activeTab.Name].Button.BackgroundColor3 = Theme.SurfaceVariant
                tabs[activeTab.Name].Button.TextColor3 = Theme.OnSurfaceMuted
                tabs[activeTab.Name].Button.Indicator.Visible = false
            end
            contentFrame.Visible = true
            tabButton.BackgroundColor3 = Theme.Primary
            tabButton.TextColor3 = Theme.OnSurface
            indicator.Visible = true
            activeTab = contentFrame
        end)
        
        -- Hover effects for tabs
        tabButton.MouseEnter:Connect(function()
            if activeTab ~= contentFrame then
                TweenService:Create(tabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(Theme.SurfaceVariant.R * 255 + 10, Theme.SurfaceVariant.G * 255 + 10, Theme.SurfaceVariant.B * 255 + 10)}):Play()
            end
        end)
        tabButton.MouseLeave:Connect(function()
            if activeTab ~= contentFrame then
                TweenService:Create(tabButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.SurfaceVariant}):Play()
            end
        end)
        
        tabs[name] = {
            Frame = contentFrame,
            Button = tabButton,
            Layout = contentLayout,
            Indicator = indicator
        }
        
        if not activeTab then
            contentFrame.Visible = true
            tabButton.BackgroundColor3 = Theme.Primary
            tabButton.TextColor3 = Theme.OnSurface
            indicator.Visible = true
            activeTab = contentFrame
        end

        --// Enhanced Component Functions
        function Tab:Button(options)
            local btn = Instance.new("TextButton")
            btn.Name = options.Name
            btn.Size = UDim2.new(1, 0, 0, 45)
            btn.BackgroundColor3 = Theme.Primary
            btn.Text = options.Name
            btn.Font = Enum.Font.GothamSemibold
            btn.TextColor3 = Theme.OnSurface
            btn.TextSize = 16
            btn.Parent = contentFrame
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = btn
            
            -- Hover and click effects
            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.PrimaryDark}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Primary}):Play()
            end)
            btn.MouseButton1Down:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(1, -4, 0, 41)}):Play()
            end)
            btn.MouseButton1Up:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 45)}):Play()
            end)
            
            btn.MouseButton1Click:Connect(function() 
                if options.Callback then options.Callback() end 
            end)
        end
        
        function Tab:Toggle(options)
            local state = options.StartingState or false
            
            local container = Instance.new("Frame")
            container.Name = options.Name
            container.Size = UDim2.new(1, 0, 0, 50)
            container.BackgroundColor3 = Theme.Surface
            container.Parent = contentFrame
            
            local containerCorner = Instance.new("UICorner")
            containerCorner.CornerRadius = UDim.new(0, 8)
            containerCorner.Parent = container
            
            local containerPadding = Instance.new("UIPadding")
            containerPadding.PaddingAll = UDim.new(0, 15)
            containerPadding.Parent = container
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -80, 1, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamMedium
            label.Text = options.Name
            label.TextColor3 = Theme.OnSurface
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container
            
            -- Modern toggle switch
            local switchTrack = Instance.new("Frame")
            switchTrack.Size = UDim2.new(0, 60, 0, 30)
            switchTrack.Position = UDim2.new(1, -60, 0.5, -15)
            switchTrack.BackgroundColor3 = state and Theme.Success or Theme.SurfaceVariant
            switchTrack.Parent = container
            
            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(1, 0)
            trackCorner.Parent = switchTrack
            
            local switchKnob = Instance.new("Frame")
            switchKnob.Size = UDim2.new(0, 26, 0, 26)
            switchKnob.Position = state and UDim2.new(1, -28, 0.5, -13) or UDim2.new(0, 2, 0.5, -13)
            switchKnob.BackgroundColor3 = Theme.OnSurface
            switchKnob.Parent = switchTrack
            
            local knobCorner = Instance.new("UICorner")
            knobCorner.CornerRadius = UDim.new(1, 0)
            knobCorner.Parent = switchKnob
            
            -- Shadow for knob
            local knobShadow = Instance.new("Frame")
            knobShadow.Size = UDim2.new(1, 2, 1, 2)
            knobShadow.Position = UDim2.new(0, -1, 0, -1)
            knobShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            knobShadow.BackgroundTransparency = 0.8
            knobShadow.ZIndex = -1
            knobShadow.Parent = switchKnob
            
            local knobShadowCorner = Instance.new("UICorner")
            knobShadowCorner.CornerRadius = UDim.new(1, 0)
            knobShadowCorner.Parent = knobShadow
            
            local clickDetector = Instance.new("TextButton")
            clickDetector.Size = UDim2.new(1, 0, 1, 0)
            clickDetector.BackgroundTransparency = 1
            clickDetector.Text = ""
            clickDetector.Parent = switchTrack
            
            clickDetector.MouseButton1Click:Connect(function()
                state = not state
                local trackColor = state and Theme.Success or Theme.SurfaceVariant
                local knobPos = state and UDim2.new(1, -28, 0.5, -13) or UDim2.new(0, 2, 0.5, -13)
                
                TweenService:Create(switchTrack, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = trackColor}):Play()
                TweenService:Create(switchKnob, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = knobPos}):Play()
                
                if options.Callback then options.Callback(state) end
            end)
        end
        
        function Tab:Textbox(options)
            local container = Instance.new("Frame")
            container.Name = options.Name
            container.Size = UDim2.new(1, 0, 0, 70)
            container.BackgroundColor3 = Theme.Surface
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
            label.Font = Enum.Font.GothamMedium
            label.Text = options.Name
            label.TextColor3 = Theme.OnSurface
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container
            
            local textboxFrame = Instance.new("Frame")
            textboxFrame.Size = UDim2.new(1, 0, 0, 35)
            textboxFrame.Position = UDim2.new(0, 0, 1, -35)
            textboxFrame.BackgroundColor3 = Theme.Background
            textboxFrame.BorderSizePixel = 1
            textboxFrame.BorderColor3 = Theme.SurfaceVariant
            textboxFrame.Parent = container
            
            local textboxCorner = Instance.new("UICorner")
            textboxCorner.CornerRadius = UDim.new(0, 6)
            textboxCorner.Parent = textboxFrame
            
            local textbox = Instance.new("TextBox")
            textbox.Size = UDim2.new(1, -20, 1, 0)
            textbox.Position = UDim2.new(0, 10, 0, 0)
            textbox.BackgroundTransparency = 1
            textbox.PlaceholderText = options.PlaceholderText or "Enter text..."
            textbox.Font = Enum.Font.Gotham
            textbox.TextColor3 = Theme.OnSurface
            textbox.PlaceholderColor3 = Theme.OnSurfaceDisabled
            textbox.TextSize = 14
            textbox.ClearTextOnFocus = false
            textbox.Parent = textboxFrame
            
            -- Focus effects
            textbox.Focused:Connect(function()
                TweenService:Create(textboxFrame, TweenInfo.new(0.2), {BorderColor3 = Theme.Primary}):Play()
            end)
            textbox.FocusLost:Connect(function(enterPressed) 
                TweenService:Create(textboxFrame, TweenInfo.new(0.2), {BorderColor3 = Theme.SurfaceVariant}):Play()
                if enterPressed and options.Callback then 
                    options.Callback(textbox.Text) 
                end 
            end)
        end
        
        function Tab:Slider(options)
            local container = Instance.new("Frame")
            container.Name = options.Name
            container.Size = UDim2.new(1, 0, 0, 80)
            container.BackgroundColor3 = Theme.Surface
            container.Parent = contentFrame
            
            local containerCorner = Instance.new("UICorner")
            containerCorner.CornerRadius = UDim.new(0, 8)
            containerCorner.Parent = container
            
            local containerPadding = Instance.new("UIPadding")
            containerPadding.PaddingAll = UDim.new(0, 15)
            containerPadding.Parent = container
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 25)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamMedium
            label.TextColor3 = Theme.OnSurface
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0, 80, 0, 25)
            valueLabel.Position = UDim2.new(1, -80, 0, 0)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.TextColor3 = Theme.Primary
            valueLabel.TextSize = 14
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Parent = container
            
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(1, 0, 0, 15)
            sliderFrame.Position = UDim2.new(0, 0, 1, -25)
            sliderFrame.BackgroundColor3 = Theme.SurfaceVariant
            sliderFrame.Parent = container
            
            local sCorner = Instance.new("UICorner")
            sCorner.CornerRadius = UDim.new(0, 8)
            sCorner.Parent = sliderFrame
            
            local fill = Instance.new("Frame")
            fill.BackgroundColor3 = Theme.Primary
            fill.BorderSizePixel = 0
            fill.Parent = sliderFrame
            
            local fCorner = Instance.new("UICorner")
            fCorner.CornerRadius = UDim.new(0, 8)
            fCorner.Parent = fill
            
            local handle = Instance.new("TextButton")
            handle.Size = UDim2.new(0, 20, 0, 20)
            handle.BackgroundColor3 = Theme.OnSurface
            handle.Text = ""
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
            
            local hShadowCorner = Instance.new("UICorner")
            hShadowCorner.CornerRadius = UDim.new(1, 0)
            hShadowCorner.Parent = handleShadow
            
            local min, max, default = options.Min or 0, options.Max or 100, options.Default or 50
            local value = default
            
            local function updateSlider(percent)
                percent = math.clamp(percent, 0, 1)
                value = min + (max - min) * percent
                fill.Size = UDim2.new(percent, 0, 1, 0)
                handle.Position = UDim2.new(1, -10, 0.5, -10)
                label.Text = options.Name
                valueLabel.Text = string.format("%.1f", value)
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
            
            handle.InputEnded:Connect(function() 
                if dragConnection then dragConnection:Disconnect() end 
            end)
            
            -- Click to set slider position
            sliderFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local mousePos = UserInputService:GetMouseLocation()
                    local relativePos = mousePos.X - sliderFrame.AbsolutePosition.X
                    local percent = math.clamp(relativePos / sliderFrame.AbsoluteSize.X, 0, 1)
                    updateSlider(percent)
                end
            end)
        end
        
        function Tab:Keybind(options)
            local container = Instance.new("Frame")
            container.Name = options.Name
            container.Size = UDim2.new(1, 0, 0, 50)
            container.BackgroundColor3 = Theme.Surface
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
            label.Font = Enum.Font.GothamMedium
            label.Text = options.Name
            label.TextColor3 = Theme.OnSurface
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container
            
            local keybindButton = Instance.new("TextButton")
            keybindButton.Size = UDim2.new(0.4, -10, 0, 35)
            keybindButton.Position = UDim2.new(0.6, 10, 0.5, -17.5)
            keybindButton.BackgroundColor3 = Theme.SurfaceVariant
            keybindButton.Text = options.Keybind or "Click to bind"
            keybindButton.Font = Enum.Font.GothamMedium
            keybindButton.TextColor3 = Theme.OnSurface
            keybindButton.TextSize = 12
            keybindButton.Parent = container
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = keybindButton
            
            keybindButton.MouseButton1Click:Connect(function()
                keybindButton.Text = "Press a key..."
                keybindButton.BackgroundColor3 = Theme.Primary
                local connection
                connection = UserInputService.InputBegan:Connect(function(input, gp)
                    if gp then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        keybindButton.Text = input.KeyCode.Name
                        keybindButton.BackgroundColor3 = Theme.SurfaceVariant
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
            container.Size = UDim2.new(1, 0, 0, 70)
            container.BackgroundColor3 = Theme.Surface
            container.ZIndex = 2
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
            label.Font = Enum.Font.GothamMedium
            label.Text = options.Name
            label.TextColor3 = Theme.OnSurface
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container

            local mainButton = Instance.new("TextButton")
            mainButton.Name = "MainButton"
            mainButton.Size = UDim2.new(1, 0, 0, 35)
            mainButton.Position = UDim2.new(0, 0, 1, -35)
            mainButton.BackgroundColor3 = Theme.Background
            mainButton.Text = Dropdown.CurrentOption
            mainButton.Font = Enum.Font.Gotham
            mainButton.TextColor3 = Theme.OnSurface
            mainButton.TextSize = 14
            mainButton.BorderSizePixel = 1
            mainButton.BorderColor3 = Theme.SurfaceVariant
            mainButton.Parent = container
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = mainButton
            
            -- Dropdown arrow
            local arrow = Instance.new("TextLabel")
            arrow.Size = UDim2.new(0, 20, 1, 0)
            arrow.Position = UDim2.new(1, -25, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Font = Enum.Font.GothamBold
            arrow.Text = "▼"
            arrow.TextColor3 = Theme.OnSurfaceMuted
            arrow.TextSize = 12
            arrow.Parent = mainButton

            local dropdownFrame = Instance.new("ScrollingFrame")
            dropdownFrame.Name = "DropdownFrame"
            dropdownFrame.Size = UDim2.new(1, 0, 0, math.min(150, #options.Options * 35))
            dropdownFrame.Position = UDim2.new(0, 0, 1, 5)
            dropdownFrame.BackgroundColor3 = Theme.Surface
            dropdownFrame.BorderSizePixel = 1
            dropdownFrame.BorderColor3 = Theme.Primary
            dropdownFrame.Visible = false
            dropdownFrame.ZIndex = 5
            dropdownFrame.ClipsDescendants = true
            dropdownFrame.ScrollBarImageColor3 = Theme.Primary
            dropdownFrame.ScrollBarThickness = 4
            dropdownFrame.Parent = container
            
            local dCorner = Instance.new("UICorner")
            dCorner.CornerRadius = UDim.new(0, 6)
            dCorner.Parent = dropdownFrame
            
            -- Dropdown shadow
            local dropdownShadow = Instance.new("Frame")
            dropdownShadow.Size = UDim2.new(1, 4, 1, 4)
            dropdownShadow.Position = UDim2.new(0, -2, 0, -2)
            dropdownShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            dropdownShadow.BackgroundTransparency = 0.8
            dropdownShadow.ZIndex = 4
            dropdownShadow.Parent = dropdownFrame
            
            local dShadowCorner = Instance.new("UICorner")
            dShadowCorner.CornerRadius = UDim.new(0, 6)
            dShadowCorner.Parent = dropdownShadow
            
            local dropdownLayout = Instance.new("UIListLayout")
            dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
            dropdownLayout.Parent = dropdownFrame

            local function refreshOptions(newOptions)
                for _, child in ipairs(dropdownFrame:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                
                for i, optionName in ipairs(newOptions) do
                    local optionButton = Instance.new("TextButton")
                    optionButton.Name = optionName
                    optionButton.Size = UDim2.new(1, 0, 0, 35)
                    optionButton.BackgroundColor3 = Theme.Surface
                    optionButton.Text = optionName
                    optionButton.Font = Enum.Font.Gotham
                    optionButton.TextColor3 = Theme.OnSurface
                    optionButton.TextSize = 14
                    optionButton.ZIndex = 6
                    optionButton.Parent = dropdownFrame
                    
                    -- Highlight current selection
                    if optionName == Dropdown.CurrentOption then
                        optionButton.BackgroundColor3 = Theme.Primary
                        optionButton.TextColor3 = Theme.OnSurface
                    end
                    
                    optionButton.MouseEnter:Connect(function() 
                        if optionName ~= Dropdown.CurrentOption then
                            TweenService:Create(optionButton, TweenInfo.new(0.1), {BackgroundColor3 = Theme.SurfaceVariant}):Play()
                        end
                    end)
                    optionButton.MouseLeave:Connect(function() 
                        if optionName ~= Dropdown.CurrentOption then
                            TweenService:Create(optionButton, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Surface}):Play()
                        end
                    end)
                    
                    optionButton.MouseButton1Click:Connect(function()
                        -- Update previous selection
                        for _, child in ipairs(dropdownFrame:GetChildren()) do
                            if child:IsA("TextButton") and child.Name == Dropdown.CurrentOption then
                                child.BackgroundColor3 = Theme.Surface
                                child.TextColor3 = Theme.OnSurface
                            end
                        end
                        
                        Dropdown.CurrentOption = optionName
                        mainButton.Text = optionName
                        optionButton.BackgroundColor3 = Theme.Primary
                        
                        isOpen = false
                        dropdownFrame.Visible = false
                        container.ZIndex = 2
                        TweenService:Create(arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
                        
                        if options.Callback then options.Callback(optionName) end
                    end)
                end
                dropdownFrame.CanvasSize = UDim2.new(0, 0, 0, dropdownLayout.AbsoluteContentSize.Y)
            end

            mainButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                dropdownFrame.Visible = isOpen
                container.ZIndex = isOpen and 10 or 2
                
                local arrowRotation = isOpen and 180 or 0
                TweenService:Create(arrow, TweenInfo.new(0.2), {Rotation = arrowRotation}):Play()
                
                if isOpen then
                    -- Animate dropdown opening
                    dropdownFrame.Size = UDim2.new(1, 0, 0, 0)
                    TweenService:Create(dropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Size = UDim2.new(1, 0, 0, math.min(150, #options.Options * 35))
                    }):Play()
                end
            end)
            
            -- Focus effects
            mainButton.MouseEnter:Connect(function()
                TweenService:Create(mainButton, TweenInfo.new(0.2), {BorderColor3 = Theme.Primary}):Play()
            end)
            mainButton.MouseLeave:Connect(function()
                if not isOpen then
                    TweenService:Create(mainButton, TweenInfo.new(0.2), {BorderColor3 = Theme.SurfaceVariant}):Play()
                end
            end)
            
            function Dropdown:Refresh(newOptions, newCurrent)
                options.Options = newOptions
                Dropdown.CurrentOption = newCurrent or newOptions[1]
                mainButton.Text = Dropdown.CurrentOption
                refreshOptions(newOptions)
                
                -- Update container size if needed
                container.Size = UDim2.new(1, 0, 0, 70)
                dropdownFrame.Size = UDim2.new(1, 0, 0, math.min(150, #newOptions * 35))
            end
            
            function Dropdown:Set(optionName)
                if table.find(options.Options, optionName) then
                    Dropdown.CurrentOption = optionName
                    mainButton.Text = optionName
                    refreshOptions(options.Options) -- Refresh to update highlighting
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
