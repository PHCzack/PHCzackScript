--// Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// Main GUI Library Table
local Rayfield = {}
Rayfield.__index = Rayfield

--// Main ScreenGui and configuration
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "MainGui"
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MainGui.ResetOnSpawn = false

--// Create the main frame for the UI
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 300)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 200)
MainFrame.BorderSizePixel = 1
MainFrame.Active = true
MainFrame.Visible = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = MainGui

--// Corner radius
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = MainFrame

--// Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

--// Gradient
local headerGradient = Instance.new("UIGradient")
headerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 180))
})
headerGradient.Rotation = 90
headerGradient.Parent = Header

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = Header

local bottomFix = Instance.new("Frame")
bottomFix.Size = UDim2.new(1,0,0.5,0)
bottomFix.Position = UDim2.new(0,0,0.5,0)
bottomFix.BackgroundColor3 = Header.BackgroundColor3
bottomFix.BorderSizePixel = 0
bottomFix.Parent = headerCorner
local bottomFixGradientClone = headerGradient:Clone()
bottomFixGradientClone.Parent = bottomFix

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 5, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.Text = "Neon Cyberpunk UI"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Window Controls
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
    btn.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    btn.BackgroundTransparency = 0.2
    btn.Text = text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextColor3 = Color3.fromRGB(20, 20, 30)
    btn.TextSize = 14
    btn.Parent = ControlsFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn
    return btn
end

local HideButton = createControlButton("X")
local ZoomButton = createControlButton("❐")
local MinimizeButton = createControlButton("—")

-- Show UI Button
local ShowButton = Instance.new("TextButton")
ShowButton.Name = "ShowButton"
ShowButton.Size = UDim2.new(0, 100, 0, 30)
ShowButton.Position = UDim2.new(0, 10, 0, 10)
ShowButton.Text = "Show UI"
ShowButton.TextColor3 = Color3.fromRGB(220, 220, 220)
ShowButton.Font = Enum.Font.SourceSans
ShowButton.Visible = false
ShowButton.ZIndex = 10
ShowButton.Parent = MainGui
local showButtonGradient = headerGradient:Clone()
showButtonGradient.Parent = ShowButton

local showCorner = Instance.new("UICorner")
showCorner.CornerRadius = UDim.new(0, 6)
showCorner.Parent = ShowButton

ShowButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    ShowButton.Visible = false
end)

-- Window state variables
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
        TweenService:Create(MainFrame, TweenInfo.new(0.2), { Size = zoomedSize, Position = UDim2.new(0.5, -zoomedSize.X.Offset/2, 0.5, -zoomedSize.Y.Offset/2) }):Play()
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = originalSize, Position = originalPosition}):Play()
    end
end)

-- Tab container
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(0, 120, 1, -30)
TabContainer.Position = UDim2.new(0, 0, 0, 30)
TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
TabContainer.BackgroundTransparency = 0.1
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.Padding = UDim.new(0, 5)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = TabContainer

-- Content container
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -120, 1, -30)
ContentContainer.Position = UDim2.new(0, 120, 0, 30)
ContentContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
ContentContainer.BackgroundTransparency = 0.1
ContentContainer.BorderSizePixel = 0
ContentContainer.ClipsDescendants = false
ContentContainer.Parent = MainFrame

local activeTab = nil
local tabs = {}

--// Notification System
local NotificationContainer = Instance.new("Frame")
NotificationContainer.Name = "NotificationContainer"
NotificationContainer.Size = UDim2.new(0, 350, 1, 0)
NotificationContainer.Position = UDim2.new(0.5, -175, 0, 0)
NotificationContainer.BackgroundTransparency = 1
NotificationContainer.ZIndex = 100
NotificationContainer.Parent = MainGui

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 6)
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = NotificationContainer

local activeNotifications = {}

function Rayfield:Notify(options)
    local title = options.Title or "Notification"
    local content = options.Content or ""
    local duration = options.Duration or 3
    local image = options.Image or nil

    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(1, 0, 0, 0)
    notifFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    notifFrame.BorderSizePixel = 1
    notifFrame.BorderColor3 = Color3.fromRGB(0, 120, 255)
    notifFrame.ZIndex = 101
    notifFrame.AutomaticSize = Enum.AutomaticSize.Y
    notifFrame.Parent = NotificationContainer

    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 6)
    notifCorner.Parent = notifFrame

    local glow = Instance.new("UIStroke")
    glow.Color = Color3.fromRGB(0, 120, 255)
    glow.Thickness = 1.5
    glow.Transparency = 0.5
    glow.Parent = notifFrame

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 1, -20)
    contentFrame.Position = UDim2.new(0, 10, 0, 10)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ZIndex = 102
    contentFrame.Parent = notifFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 103
    titleLabel.Parent = contentFrame

    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, 0, 0, 18)
    contentLabel.Position = UDim2.new(0, 0, 0, 22)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Font = Enum.Font.SourceSans
    contentLabel.Text = content
    contentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    contentLabel.TextSize = 14
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextWrapped = true
    contentLabel.ZIndex = 103
    contentLabel.Parent = contentFrame

    notifFrame.BackgroundTransparency = 1
    titleLabel.TextTransparency = 1
    contentLabel.TextTransparency = 1
    glow.Transparency = 1

    local slideIn = TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 0.1
    })

    local fadeInTitle = TweenService:Create(titleLabel, TweenInfo.new(0.3), {TextTransparency = 0})
    local fadeInContent = TweenService:Create(contentLabel, TweenInfo.new(0.3), {TextTransparency = 0})
    local fadeInGlow = TweenService:Create(glow, TweenInfo.new(0.3), {Transparency = 0.5})

    slideIn:Play()
    fadeInTitle:Play()
    fadeInContent:Play()
    fadeInGlow:Play()

    table.insert(activeNotifications, notifFrame)

    task.delay(duration, function()
        local slideOut = TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1
        })
        local fadeOutTitle = TweenService:Create(titleLabel, TweenInfo.new(0.3), {TextTransparency = 1})
        local fadeOutContent = TweenService:Create(contentLabel, TweenInfo.new(0.3), {TextTransparency = 1})
        local fadeOutGlow = TweenService:Create(glow, TweenInfo.new(0.3), {Transparency = 1})

        slideOut:Play()
        fadeOutTitle:Play()
        fadeOutContent:Play()
        fadeOutGlow:Play()

        slideOut.Completed:Connect(function()
            for i, notif in ipairs(activeNotifications) do
                if notif == notifFrame then
                    table.remove(activeNotifications, i)
                    break
                end
            end
            notifFrame:Destroy()
        end)
    end)
end

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

--// Create a separate ScreenGui for dropdowns
local DropdownGui = Instance.new("ScreenGui")
DropdownGui.Name = "DropdownGui"
DropdownGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
DropdownGui.ResetOnSpawn = false
DropdownGui.Parent = playerGui

--// Window Object
function Rayfield:CreateWindow(options)
    Title.Text = options.Name or "Roblox UI"
    local Window = {}
    
    function Window:Notify(options)
        return Rayfield:Notify(options)
    end

    function Window:CreateTab(name, iconId)
        local Tab = {}

        local contentFrame = Instance.new("ScrollingFrame")
        contentFrame.Name = name
        contentFrame.Size = UDim2.new(1, -10, 1, -10)
        contentFrame.Position = UDim2.new(0, 5, 0, 5)
        contentFrame.BackgroundTransparency = 1
        contentFrame.BorderSizePixel = 0
        contentFrame.Visible = false
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        contentFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 120, 255)
        contentFrame.ScrollBarThickness = 6
        contentFrame.ClipsDescendants = true
        contentFrame.ScrollingDirection = Enum.ScrollingDirection.Y
        contentFrame.Parent = ContentContainer

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, 10)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Parent = contentFrame
        
        local function updateCanvasSize()
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
            tabButton.BackgroundColor3 = Color3.fromRGB(0, 80, 170)
            activeTab = contentFrame
        end)

        tabs[name] = { Frame = contentFrame, Button = tabButton, Layout = contentLayout }

        if not activeTab then
            contentFrame.Visible = true
            tabButton.BackgroundColor3 = Color3.fromRGB(0, 80, 170)
            activeTab = contentFrame
        end
        
        --// CreateSection function for categories (DEFAULT CLOSED)
        function Tab:CreateSection(sectionName)
            local Section = {}
            local isExpanded = false
            
            -- Section Header Container
            local sectionContainer = Instance.new("Frame")
            sectionContainer.Name = sectionName .. "Section"
            sectionContainer.Size = UDim2.new(1, 0, 0, 0)
            sectionContainer.BackgroundTransparency = 1
            sectionContainer.AutomaticSize = Enum.AutomaticSize.Y
            sectionContainer.ClipsDescendants = false
            sectionContainer.Parent = contentFrame
            
            -- Section Header Button
            local sectionHeader = Instance.new("TextButton")
            sectionHeader.Name = "Header"
            sectionHeader.Size = UDim2.new(1, 0, 0, 35)
            sectionHeader.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
            sectionHeader.BorderSizePixel = 1
            sectionHeader.BorderColor3 = Color3.fromRGB(0, 120, 255)
            sectionHeader.Text = ""
            sectionHeader.Parent = sectionContainer
            
            local headerCorner = Instance.new("UICorner")
            headerCorner.CornerRadius = UDim.new(0, 6)
            headerCorner.Parent = sectionHeader
            
            -- Section Title
            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Size = UDim2.new(1, -40, 1, 0)
            sectionTitle.Position = UDim2.new(0, 10, 0, 0)
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Font = Enum.Font.SourceSansBold
            sectionTitle.Text = sectionName
            sectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            sectionTitle.TextSize = 15
            sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            sectionTitle.Parent = sectionHeader
            
            -- Arrow Indicator
            local arrow = Instance.new("TextLabel")
            arrow.Size = UDim2.new(0, 20, 1, 0)
            arrow.Position = UDim2.new(1, -30, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Font = Enum.Font.SourceSansBold
            arrow.Text = "▶"
            arrow.TextColor3 = Color3.fromRGB(0, 120, 255)
            arrow.TextSize = 14
            arrow.Rotation = -90
            arrow.Parent = sectionHeader
            
            -- Section Content Container
            local sectionContent = Instance.new("Frame")
            sectionContent.Name = "Content"
            sectionContent.Size = UDim2.new(1, 0, 0, 0)
            sectionContent.Position = UDim2.new(0, 0, 0, 40)
            sectionContent.BackgroundTransparency = 1
            sectionContent.AutomaticSize = Enum.AutomaticSize.Y
            sectionContent.Visible = false
            sectionContent.ClipsDescendants = false
            sectionContent.Parent = sectionContainer
            
            local sectionLayout = Instance.new("UIListLayout")
            sectionLayout.Padding = UDim.new(0, 8)
            sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sectionLayout.Parent = sectionContent
            
            -- Toggle expand/collapse
            sectionHeader.MouseButton1Click:Connect(function()
                isExpanded = not isExpanded
                sectionContent.Visible = isExpanded
                arrow.Text = isExpanded and "▼" or "▶"
                
                TweenService:Create(arrow, TweenInfo.new(0.2), {
                    Rotation = isExpanded and 0 or -90
                }):Play()
            end)
            
            -- Add elements to this section
            function Section:Button(options)
                local btn = Instance.new("TextButton")
                btn.Name = options.Name
                btn.Size = UDim2.new(1, 0, 0, 35)
                btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                btn.Text = options.Name
                btn.Font = Enum.Font.SourceSans
                btn.TextColor3 = Color3.fromRGB(220, 220, 220)
                btn.TextSize = 16
                btn.Parent = sectionContent

                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 4)
                corner.Parent = btn

                if options.Info then
                    local infoLabel = Instance.new("TextLabel")
                    infoLabel.Size = UDim2.new(1, -10, 0, 12)
                    infoLabel.Position = UDim2.new(0, 5, 1, 2)
                    infoLabel.BackgroundTransparency = 1
                    infoLabel.Font = Enum.Font.SourceSans
                    infoLabel.Text = options.Info
                    infoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                    infoLabel.TextSize = 12
                    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
                    infoLabel.Parent = btn
                end

                btn.MouseButton1Click:Connect(function()
                    if options.Callback then
                        options.Callback()
                    end
                end)
            end
            
            function Section:Toggle(options)
                local state = options.CurrentValue or false

                local container = Instance.new("Frame")
                container.Name = options.Name
                container.Size = UDim2.new(1, 0, 0, 30)
                container.BackgroundTransparency = 1
                container.Parent = sectionContent

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -60, 1, 0)
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.SourceSans
                label.Text = options.Name
                label.TextColor3 = Color3.fromRGB(220, 220, 220)
                label.TextSize = 16
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = container

                local switchTrack = Instance.new("Frame")
                switchTrack.Size = UDim2.new(0, 50, 0, 24)
                switchTrack.Position = UDim2.new(1, -50, 0.5, -12)
                switchTrack.BackgroundColor3 = state and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(100, 100, 100)
                switchTrack.Parent = container

                local trackCorner = Instance.new("UICorner")
                trackCorner.CornerRadius = UDim.new(1, 0)
                trackCorner.Parent = switchTrack

                local switchKnob = Instance.new("Frame")
                switchKnob.Size = UDim2.new(0, 20, 0, 20)
                switchKnob.Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
                switchKnob.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
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
                    local trackColor = state and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(100, 100, 100)
                    local knobPos = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
                    TweenService:Create(switchTrack, TweenInfo.new(0.2), {BackgroundColor3 = trackColor}):Play()
                    TweenService:Create(switchKnob, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = knobPos}):Play()
                    
                    if options.Callback then
                        options.Callback(state)
                    end
                end)
            end
            
            function Section:Textbox(options)
                local Input = {}
                Input.CurrentValue = options.CurrentValue or options.Default or ""
                
                local container = Instance.new("Frame")
                container.Name = options.Name
                container.Size = UDim2.new(1, 0, 0, 45)
                container.BackgroundTransparency = 1
                container.Parent = sectionContent

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 0, 15)
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.SourceSans
                label.Text = options.Name
                label.TextColor3 = Color3.fromRGB(220, 220, 220)
                label.TextSize = 14
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = container

                local textboxFrame = Instance.new("Frame")
                textboxFrame.Size = UDim2.new(1, 0, 0, 28)
                textboxFrame.Position = UDim2.new(0, 0, 0, 17)
                textboxFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                textboxFrame.BorderSizePixel = 0
                textboxFrame.Parent = container

                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 4)
                corner.Parent = textboxFrame

                local textbox = Instance.new("TextBox")
                textbox.Size = UDim2.new(1, -10, 1, 0)
                textbox.Position = UDim2.new(0, 5, 0, 0)
                textbox.BackgroundTransparency = 1
                textbox.PlaceholderText = options.PlaceholderText or "Enter text..."
                textbox.Font = Enum.Font.SourceSans
                textbox.Text = Input.CurrentValue
                textbox.TextColor3 = Color3.fromRGB(220, 220, 220)
                textbox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
                textbox.TextSize = 14
                textbox.TextXAlignment = Enum.TextXAlignment.Left
                textbox.ClearTextOnFocus = false
                textbox.Parent = textboxFrame

                textbox.Focused:Connect(function()
                    TweenService:Create(textboxFrame, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                        BorderSizePixel = 1,
                        BorderColor3 = Color3.fromRGB(0, 120, 255)
                    }):Play()
                end)

                textbox.FocusLost:Connect(function(enterPressed)
                    TweenService:Create(textboxFrame, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                        BorderSizePixel = 0
                    }):Play()
                    
                    if enterPressed or options.RemoveTextAfterFocusLost ~= false then
                        Input.CurrentValue = textbox.Text
                        
                        if options.Callback then
                            options.Callback(textbox.Text)
                        end
                        
                        if options.RemoveTextAfterFocusLost then
                            textbox.Text = ""
                        end
                    end
                end)

                function Input:Set(value)
                    Input.CurrentValue = value
                    textbox.Text = value
                    if options.Callback then
                        options.Callback(value)
                    end
                end

                return Input
            end

            function Section:Slider(options)
                local container = Instance.new("Frame")
                container.Name = options.Name
                container.Size = UDim2.new(1, 0, 0, 40)
                container.BackgroundTransparency = 1
                container.Parent = sectionContent

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 0, 20)
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.SourceSans
                label.TextColor3 = Color3.fromRGB(220, 220, 220)
                label.TextSize = 16
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = container

                local sliderFrame = Instance.new("Frame")
                sliderFrame.Size = UDim2.new(1, 0, 0, 10)
                sliderFrame.Position = UDim2.new(0, 0, 0, 25)
                sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                sliderFrame.Parent = container

                local sCorner = Instance.new("UICorner")
                sCorner.CornerRadius = UDim.new(0, 5)
                sCorner.Parent = sliderFrame

                local fill = Instance.new("Frame")
                fill.BorderSizePixel = 0
                fill.Parent = sliderFrame
                
                local fillGradient = Instance.new("UIGradient")
                fillGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 120, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 0, 255))
                })
                fillGradient.Parent = fill

                local fCorner = Instance.new("UICorner")
                fCorner.CornerRadius = UDim.new(0, 5)
                fCorner.Parent = fill

                local handle = Instance.new("TextButton")
                handle.Size = UDim2.new(0, 16, 0, 16)
                handle.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
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
                    handle.Position = UDim2.new(percent, -8, 0.5, -8)
                    label.Text = string.format("%s: %.2f", options.Name, value)
                    if options.Callback then
                        options.Callback(value)
                    end
                end

                updateSlider((default - min) / (max - min))

                local dragConnection
                handle.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local startPos = input.Position
                        local startSize = fill.Size.X.Scale

                        dragConnection = input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.Change then
                                local delta = (input.Position.X - startPos.X) / sliderFrame.AbsoluteSize.X
                                updateSlider(startSize + delta)
                            elseif input.UserInputState == Enum.UserInputState.End then
                                dragConnection:Disconnect()
                            end
                        end)
                    end
                end)

                handle.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch then
                        local startPos = input.Position
                        local startSize = fill.Size.X.Scale

                        dragConnection = input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.Change then
                                local delta = (input.Position.X - startPos.X) / sliderFrame.AbsoluteSize.X
                                updateSlider(startSize + delta)
                            elseif input.UserInputState == Enum.UserInputState.End then
                                dragConnection:Disconnect()
                            end
                        end)
                    end
                end)
            end

            function Section:Keybind(options)
                local container = Instance.new("Frame")
                container.Name = options.Name
                container.Size = UDim2.new(1, 0, 0, 30)
                container.BackgroundTransparency = 1
                container.Parent = sectionContent

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

            function Section:CreateDropdown(options)
                local Dropdown = {}
                local isOpen = false

                local container = Instance.new("Frame")
                container.Name = options.Name
                container.Size = UDim2.new(1, 0, 0, 35)
                container.BackgroundTransparency = 1
                container.ZIndex = 2
                container.ClipsDescendants = false
                container.Parent = sectionContent

                local mainButton = Instance.new("TextButton")
                mainButton.Name = "MainButton"
                mainButton.Size = UDim2.new(1, 0, 1, 0)
                mainButton.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
                mainButton.BorderSizePixel = 1
                mainButton.BorderColor3 = Color3.fromRGB(0, 120, 255)
                mainButton.Font = Enum.Font.SourceSans
                mainButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                mainButton.TextSize = 13
                mainButton.TextXAlignment = Enum.TextXAlignment.Left
                mainButton.Parent = container

                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 4)
                corner.Parent = mainButton

                -- Add dropdown arrow indicator
                local arrowLabel = Instance.new("TextLabel")
                arrowLabel.Name = "Arrow"
                arrowLabel.Size = UDim2.new(0, 25, 1, 0)
                arrowLabel.Position = UDim2.new(1, -25, 0, 0)
                arrowLabel.BackgroundTransparency = 1
                arrowLabel.Font = Enum.Font.SourceSansBold
                arrowLabel.Text = "▼"
                arrowLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
                arrowLabel.TextSize = 10
                arrowLabel.Parent = mainButton
                
                -- Add padding to text so it doesn't overlap arrow
                mainButton.TextXAlignment = Enum.TextXAlignment.Left
                local textPadding = Instance.new("UIPadding")
                textPadding.PaddingLeft = UDim.new(0, 10)
                textPadding.PaddingRight = UDim.new(0, 30)
                textPadding.Parent = mainButton

                -- Create dropdown window frame (40% size)
                local dropdownWindowFrame = Instance.new("Frame")
                dropdownWindowFrame.Name = "DropdownWindow"
                dropdownWindowFrame.Size = UDim2.new(0, 180, 0, 240)
                dropdownWindowFrame.Position = lastDropdownPosition
                dropdownWindowFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
                dropdownWindowFrame.BorderSizePixel = 2
                dropdownWindowFrame.BorderColor3 = Color3.fromRGB(0, 255, 200)
                dropdownWindowFrame.Visible = false
                dropdownWindowFrame.ZIndex = 100
                dropdownWindowFrame.Parent = DropdownGui

                local windowCorner = Instance.new("UICorner")
                windowCorner.CornerRadius = UDim.new(0, 6)
                windowCorner.Parent = dropdownWindowFrame

                -- Header for dropdown window
                local dropdownHeader = Instance.new("Frame")
                dropdownHeader.Name = "Header"
                dropdownHeader.Size = UDim2.new(1, 0, 0, 30)
                dropdownHeader.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
                dropdownHeader.BorderSizePixel = 0
                dropdownHeader.Parent = dropdownWindowFrame

                local headerCorner = Instance.new("UICorner")
                headerCorner.CornerRadius = UDim.new(0, 6)
                headerCorner.Parent = dropdownHeader

                local headerGradient = Instance.new("UIGradient")
                headerGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 200, 180)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 200))
                })
                headerGradient.Rotation = 90
                headerGradient.Parent = dropdownHeader

                local headerTitle = Instance.new("TextLabel")
                headerTitle.Name = "Title"
                headerTitle.Size = UDim2.new(1, -10, 1, 0)
                headerTitle.Position = UDim2.new(0, 5, 0, 0)
                headerTitle.BackgroundTransparency = 1
                headerTitle.Font = Enum.Font.SourceSansBold
                headerTitle.Text = options.Name
                headerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
                headerTitle.TextSize = 12
                headerTitle.TextXAlignment = Enum.TextXAlignment.Left
                headerTitle.Parent = dropdownHeader

                -- Dragging logic for dropdown window
                dropdownHeader.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dropdownDragging = true
                        dropdownDragStart = input.Position
                        dropdownStartPos = dropdownWindowFrame.Position
                        input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then
                                dropdownDragging = false
                                -- Save the last position
                                lastDropdownPosition = dropdownWindowFrame.Position
                            end
                        end)
                    end
                end)

                dropdownHeader.InputChanged:Connect(function(input)
                    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dropdownDragging then
                        local delta = input.Position - dropdownDragStart
                        dropdownWindowFrame.Position = UDim2.new(dropdownStartPos.X.Scale, dropdownStartPos.X.Offset + delta.X, dropdownStartPos.Y.Scale, dropdownStartPos.Y.Offset + delta.Y)
                    end
                end)

                -- Create dropdown container inside the window (no gap)
                local dropdownContainer = Instance.new("Frame")
                dropdownContainer.Name = "DropdownContainer"
                dropdownContainer.Size = UDim2.new(1, 0, 1, -30)
                dropdownContainer.Position = UDim2.new(0, 0, 0, 30)
                dropdownContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
                dropdownContainer.BorderSizePixel = 0
                dropdownContainer.Visible = true
                dropdownContainer.ZIndex = 100
                dropdownContainer.Parent = dropdownWindowFrame
                
                local dropContainerCorner = Instance.new("UICorner")
                dropContainerCorner.CornerRadius = UDim.new(0, 6)
                dropContainerCorner.Parent = dropdownContainer
                
                local dropdownGlow = Instance.new("UIStroke")
                dropdownGlow.Color = Color3.fromRGB(0, 255, 200)
                dropdownGlow.Thickness = 2
                dropdownGlow.Transparency = 0.3
                dropdownGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                dropdownGlow.Parent = dropdownContainer

                local searchFrame = Instance.new("Frame")
                searchFrame.Name = "SearchFrame"
                searchFrame.Size = UDim2.new(1, -10, 0, 30)
                searchFrame.Position = UDim2.new(0, 5, 0, 5)
                searchFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
                searchFrame.BorderSizePixel = 1
                searchFrame.BorderColor3 = Color3.fromRGB(0, 200, 180)
                searchFrame.ZIndex = 6
                searchFrame.Parent = dropdownContainer

                local searchCorner = Instance.new("UICorner")
                searchCorner.CornerRadius = UDim.new(0, 4)
                searchCorner.Parent = searchFrame

                local searchBox = Instance.new("TextBox")
                searchBox.Name = "SearchBox"
                searchBox.Size = UDim2.new(1, -10, 1, 0)
                searchBox.Position = UDim2.new(0, 5, 0, 0)
                searchBox.BackgroundTransparency = 1
                searchBox.Font = Enum.Font.SourceSans
                searchBox.PlaceholderText = "Search"
                searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
                searchBox.Text = ""
                searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                searchBox.TextSize = 14
                searchBox.TextXAlignment = Enum.TextXAlignment.Left
                searchBox.ClearTextOnFocus = false
                searchBox.ZIndex = 7
                searchBox.Parent = searchFrame

                local dropdownFrame = Instance.new("ScrollingFrame")
                dropdownFrame.Name = "DropdownFrame"
                dropdownFrame.Size = UDim2.new(1, -10, 1, -45)
                dropdownFrame.Position = UDim2.new(0, 5, 0, 40)
                dropdownFrame.BackgroundTransparency = 1
                dropdownFrame.BorderSizePixel = 0
                dropdownFrame.Visible = true
                dropdownFrame.ZIndex = 6
                dropdownFrame.ScrollBarThickness = 4
                dropdownFrame.ScrollBarImageColor3 = Color3.fromRGB(120, 40, 40)
                dropdownFrame.Parent = dropdownContainer

                local dropdownLayout = Instance.new("UIListLayout")
                dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
                dropdownLayout.Padding = UDim.new(0, 2)
                dropdownLayout.Parent = dropdownFrame

                local function updateDropdownPosition()
                    if isOpen then
                        local buttonAbsPos = mainButton.AbsolutePosition
                        local buttonAbsSize = mainButton.AbsoluteSize
                        local dropdownHeight = 200
                        
                        -- Get the screen bounds
                        local screenSize = contentFrame.Parent.AbsoluteSize.Y
                        local screenTop = contentFrame.Parent.AbsolutePosition.Y
                        
                        -- Calculate available space
                        local spaceBelow = screenSize - (buttonAbsPos.Y - screenTop + buttonAbsSize.Y)
                        local spaceAbove = buttonAbsPos.Y - screenTop
                        
                        -- Position dropdown relative to contentFrame
                        local relativeButtonX = buttonAbsPos.X - contentFrame.AbsolutePosition.X
                        local relativeButtonY = buttonAbsPos.Y - contentFrame.AbsolutePosition.Y
                        
                        -- Prefer showing above if there's enough space, otherwise below
                        if spaceAbove > dropdownHeight then
                            -- Show above the button
                            dropdownContainer.Position = UDim2.new(0, relativeButtonX, 0, relativeButtonY - dropdownHeight - 5)
                        else
                            -- Show below the button
                            dropdownContainer.Position = UDim2.new(0, relativeButtonX, 0, relativeButtonY + buttonAbsSize.Y + 5)
                        end
                    end
                end

                if options.MultiSelection then
                    local selectedOptions = {}
                    for _, v in ipairs(options.CurrentOption or {}) do table.insert(selectedOptions, v) end

                    local function updateMainButtonText()
                        local count = #selectedOptions
                        if count == 0 then mainButton.Text = options.Name
                        elseif count <= 2 then mainButton.Text = table.concat(selectedOptions, ", ")
                        else mainButton.Text = count .. " Selected" end
                    end

                    local allOptionButtons = {}

                    local function refreshOptions(newOptions)
                        for _, child in ipairs(dropdownFrame:GetChildren()) do 
                            if child:IsA("TextButton") then child:Destroy() end 
                        end
                        allOptionButtons = {}
                        
                        for _, optionName in ipairs(newOptions or options.Options) do
                            local optionButton = Instance.new("TextButton")
                            optionButton.Name = optionName
                            optionButton.Size = UDim2.new(1, 0, 0, 30)
                            optionButton.Text = optionName
                            optionButton.Font = Enum.Font.SourceSans
                            optionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                            optionButton.TextSize = 13
                            optionButton.TextXAlignment = Enum.TextXAlignment.Left
                            optionButton.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
                            optionButton.BorderSizePixel = 0
                            optionButton.ZIndex = 7
                            optionButton.Parent = dropdownFrame
                            
                            local optCorner = Instance.new("UICorner")
                            optCorner.CornerRadius = UDim.new(0, 3)
                            optCorner.Parent = optionButton

                            local isSelected = table.find(selectedOptions, optionName)
                            optionButton.BackgroundColor3 = isSelected and Color3.fromRGB(0, 150, 130) or Color3.fromRGB(25, 25, 50)

                            table.insert(allOptionButtons, {button = optionButton, name = optionName})

                            optionButton.MouseEnter:Connect(function() 
                                if not table.find(selectedOptions, optionName) then 
                                    optionButton.BackgroundColor3 = Color3.fromRGB(35, 35, 65)
                                end 
                            end)
                            
                            optionButton.MouseLeave:Connect(function() 
                                if not table.find(selectedOptions, optionName) then 
                                    optionButton.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
                                end 
                            end)

                            optionButton.MouseButton1Click:Connect(function()
                                local foundIndex = table.find(selectedOptions, optionName)
                                if foundIndex then
                                    table.remove(selectedOptions, foundIndex)
                                    optionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
                                else
                                    table.insert(selectedOptions, optionName)
                                    optionButton.BackgroundColor3 = Color3.fromRGB(0, 80, 170)
                                end
                                updateMainButtonText()
                                if options.Callback then options.Callback(selectedOptions) end
                            end)
                        end
                        dropdownFrame.CanvasSize = UDim2.new(0,0,0,dropdownLayout.AbsoluteContentSize.Y)
                    end
                    
                    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                        local searchText = searchBox.Text:lower()
                        for _, optionData in ipairs(allOptionButtons) do
                            local btn = optionData.button
                            local name = optionData.name:lower()
                            if searchText == "" or name:find(searchText, 1, true) then
                                btn.Visible = true
                            else
                                btn.Visible = false
                            end
                        end
                    end)
                    
                    updateMainButtonText()
                    refreshOptions(options.Options)
                else
                    Dropdown.CurrentOption = options.CurrentOption or options.Options[1]
                    mainButton.Text = Dropdown.CurrentOption

                    local allOptionButtons = {}

                    local function refreshOptions(newOptions)
                        for _, child in ipairs(dropdownFrame:GetChildren()) do 
                            if child:IsA("TextButton") then child:Destroy() end 
                        end
                        allOptionButtons = {}
                        
                        for _, optionName in ipairs(newOptions) do
                            local optionButton = Instance.new("TextButton")
                            optionButton.Name = optionName
                            optionButton.Size = UDim2.new(1, 0, 0, 30)
                            optionButton.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
                            optionButton.Text = optionName
                            optionButton.Font = Enum.Font.SourceSans
                            optionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                            optionButton.TextSize = 13
                            optionButton.TextXAlignment = Enum.TextXAlignment.Left
                            optionButton.BorderSizePixel = 0
                            optionButton.ZIndex = 7
                            optionButton.Parent = dropdownFrame
                            
                            local optCorner = Instance.new("UICorner")
                            optCorner.CornerRadius = UDim.new(0, 3)
                            optCorner.Parent = optionButton

                            table.insert(allOptionButtons, {button = optionButton, name = optionName})
                            
                            optionButton.MouseEnter:Connect(function() 
                                optionButton.BackgroundColor3 = Color3.fromRGB(35, 35, 65)
                            end)
                            
                            optionButton.MouseLeave:Connect(function() 
                                optionButton.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
                            end)

                            optionButton.MouseButton1Click:Connect(function()
                                Dropdown.CurrentOption = optionName
                                mainButton.Text = optionName
                                isOpen = false
                                dropdownContainer.Visible = false
                                container.ZIndex = 2
                                if options.Callback then options.Callback(optionName) end
                            end)
                        end
                        dropdownFrame.CanvasSize = UDim2.new(0,0,0,dropdownLayout.AbsoluteContentSize.Y)
                    end
                    
                    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                        local searchText = searchBox.Text:lower()
                        for _, optionData in ipairs(allOptionButtons) do
                            local btn = optionData.button
                            local name = optionData.name:lower()
                            if searchText == "" or name:find(searchText, 1, true) then
                                btn.Visible = true
                            else
                                btn.Visible = false
                            end
                        end
                    end)
                    
                    refreshOptions(options.Options)
                end

                mainButton.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    
                    -- Close any other open dropdown
                    if isOpen and currentOpenDropdown and currentOpenDropdown ~= dropdownWindowFrame then
                        currentOpenDropdown.Visible = false
                    end
                    
                    dropdownWindowFrame.Visible = isOpen
                    
                    if isOpen then
                        currentOpenDropdown = dropdownWindowFrame
                        -- Save position for next dropdown
                        dropdownWindowFrame.Position = lastDropdownPosition
                    end
                    
                    container.ZIndex = isOpen and 100 or 2
                    updateDropdownPosition()
                end)

                -- Add this dropdown to the section's tracking list
                table.insert(sectionDropdowns, dropdownWindowFrame)

                return Dropdown
            end
            Section.Dropdown = Section.CreateDropdown
            
            return Section
        end
        
        
        -- Original Tab functions (for backward compatibility)
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

            if options.Info then
                local infoLabel = Instance.new("TextLabel")
                infoLabel.Size = UDim2.new(1, -10, 0, 12)
                infoLabel.Position = UDim2.new(0, 5, 1, 2)
                infoLabel.BackgroundTransparency = 1
                infoLabel.Font = Enum.Font.SourceSans
                infoLabel.Text = options.Info
                infoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                infoLabel.TextSize = 12
                infoLabel.TextXAlignment = Enum.TextXAlignment.Left
                infoLabel.Parent = btn
            end

            btn.MouseButton1Click:Connect(function()
                if options.Callback then
                    options.Callback()
                end
            end)
        end

        function Tab:Toggle(options)
            local state = options.CurrentValue or false

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
            label.TextColor3 = Color3.fromRGB(220, 220, 220)
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container

            local switchTrack = Instance.new("Frame")
            switchTrack.Size = UDim2.new(0, 50, 0, 24)
            switchTrack.Position = UDim2.new(1, -50, 0.5, -12)
            switchTrack.BackgroundColor3 = state and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(100, 100, 100)
            switchTrack.Parent = container

            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(1, 0)
            trackCorner.Parent = switchTrack

            local switchKnob = Instance.new("Frame")
            switchKnob.Size = UDim2.new(0, 20, 0, 20)
            switchKnob.Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
            switchKnob.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
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
                local trackColor = state and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(100, 100, 100)
                local knobPos = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
                TweenService:Create(switchTrack, TweenInfo.new(0.2), {BackgroundColor3 = trackColor}):Play()
                TweenService:Create(switchKnob, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = knobPos}):Play()
                
                if options.Callback then
                    options.Callback(state)
                end
            end)
        end

        function Tab:Textbox(options)
            local Input = {}
            Input.CurrentValue = options.CurrentValue or options.Default or ""
            
            local container = Instance.new("Frame")
            container.Name = options.Name
            container.Size = UDim2.new(1, 0, 0, 45)
            container.BackgroundTransparency = 1
            container.Parent = contentFrame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 15)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.SourceSans
            label.Text = options.Name
            label.TextColor3 = Color3.fromRGB(220, 220, 220)
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container

            local textboxFrame = Instance.new("Frame")
            textboxFrame.Size = UDim2.new(1, 0, 0, 28)
            textboxFrame.Position = UDim2.new(0, 0, 0, 17)
            textboxFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            textboxFrame.BorderSizePixel = 0
            textboxFrame.Parent = container

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = textboxFrame

            local textbox = Instance.new("TextBox")
            textbox.Size = UDim2.new(1, -10, 1, 0)
            textbox.Position = UDim2.new(0, 5, 0, 0)
            textbox.BackgroundTransparency = 1
            textbox.PlaceholderText = options.PlaceholderText or "Enter text..."
            textbox.Font = Enum.Font.SourceSans
            textbox.Text = Input.CurrentValue
            textbox.TextColor3 = Color3.fromRGB(220, 220, 220)
            textbox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
            textbox.TextSize = 14
            textbox.TextXAlignment = Enum.TextXAlignment.Left
            textbox.ClearTextOnFocus = false
            textbox.Parent = textboxFrame

            textbox.Focused:Connect(function()
                TweenService:Create(textboxFrame, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                    BorderSizePixel = 1,
                    BorderColor3 = Color3.fromRGB(0, 120, 255)
                }):Play()
            end)

            textbox.FocusLost:Connect(function(enterPressed)
                TweenService:Create(textboxFrame, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                    BorderSizePixel = 0
                }):Play()
                
                if enterPressed or options.RemoveTextAfterFocusLost ~= false then
                    Input.CurrentValue = textbox.Text
                    
                    if options.Callback then
                        options.Callback(textbox.Text)
                    end
                    
                    if options.RemoveTextAfterFocusLost then
                        textbox.Text = ""
                    end
                end
            end)

            function Input:Set(value)
                Input.CurrentValue = value
                textbox.Text = value
                if options.Callback then
                    options.Callback(value)
                end
            end

            return Input
        end

        function Tab:Slider(options)
            local container = Instance.new("Frame")
            container.Name = options.Name
            container.Size = UDim2.new(1, 0, 0, 40)
            container.BackgroundTransparency = 1
            container.Parent = contentFrame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 20)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.SourceSans
            label.TextColor3 = Color3.fromRGB(220, 220, 220)
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container

            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(1, 0, 0, 10)
            sliderFrame.Position = UDim2.new(0, 0, 0, 25)
            sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            sliderFrame.Parent = container

            local sCorner = Instance.new("UICorner")
            sCorner.CornerRadius = UDim.new(0, 5)
            sCorner.Parent = sliderFrame

            local fill = Instance.new("Frame")
            fill.BorderSizePixel = 0
            fill.Parent = sliderFrame
            
            local fillGradient = Instance.new("UIGradient")
            fillGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 120, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 0, 255))
            })
            fillGradient.Parent = fill

            local fCorner = Instance.new("UICorner")
            fCorner.CornerRadius = UDim.new(0, 5)
            fCorner.Parent = fill

            local handle = Instance.new("TextButton")
            handle.Size = UDim2.new(0, 16, 0, 16)
            handle.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
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
                handle.Position = UDim2.new(percent, -8, 0.5, -8)
                label.Text = string.format("%s: %.2f", options.Name, value)
                if options.Callback then
                    options.Callback(value)
                end
            end

            updateSlider((default - min) / (max - min))

            local dragConnection
            handle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local startPos = input.Position
                    local startSize = fill.Size.X.Scale

                    dragConnection = input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.Change then
                            local delta = (input.Position.X - startPos.X) / sliderFrame.AbsoluteSize.X
                            updateSlider(startSize + delta)
                        elseif input.UserInputState == Enum.UserInputState.End then
                            dragConnection:Disconnect()
                        end
                    end)
                end
            end)

            handle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    local startPos = input.Position
                    local startSize = fill.Size.X.Scale

                    dragConnection = input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.Change then
                            local delta = (input.Position.X - startPos.X) / sliderFrame.AbsoluteSize.X
                            updateSlider(startSize + delta)
                        elseif input.UserInputState == Enum.UserInputState.End then
                            dragConnection:Disconnect()
                        end
                    end)
                end
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

        function Tab:CreateDropdown(options)
            local Dropdown = {}
            local isOpen = false

            local container = Instance.new("Frame")
            container.Name = options.Name
            container.Size = UDim2.new(1, 0, 0, 35)
            container.BackgroundTransparency = 1
            container.ZIndex = 2
            container.ClipsDescendants = false
            container.Parent = contentFrame

            local mainButton = Instance.new("TextButton")
            mainButton.Name = "MainButton"
            mainButton.Size = UDim2.new(1, 0, 1, 0)
            mainButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            mainButton.Font = Enum.Font.SourceSans
            mainButton.TextColor3 = Color3.fromRGB(220, 220, 220)
            mainButton.TextSize = 14
            mainButton.Parent = container

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = mainButton

            local dropdownContainer = Instance.new("Frame")
            dropdownContainer.Name = "DropdownContainer"
            dropdownContainer.Size = UDim2.new(1, 0, 0, 200)
            dropdownContainer.Position = UDim2.new(0, 0, 1, 5)
            dropdownContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
            dropdownContainer.BorderSizePixel = 2
            dropdownContainer.BorderColor3 = Color3.fromRGB(0, 120, 255)
            dropdownContainer.Visible = false
            dropdownContainer.ZIndex = 100
            dropdownContainer.Parent = container
            
            local dropContainerCorner = Instance.new("UICorner")
            dropContainerCorner.CornerRadius = UDim.new(0, 6)
            dropContainerCorner.Parent = dropdownContainer
            
            local dropdownGlow = Instance.new("UIStroke")
            dropdownGlow.Color = Color3.fromRGB(0, 120, 255)
            dropdownGlow.Thickness = 1.5
            dropdownGlow.Transparency = 0.5
            dropdownGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            dropdownGlow.Parent = dropdownContainer

            local searchFrame = Instance.new("Frame")
            searchFrame.Name = "SearchFrame"
            searchFrame.Size = UDim2.new(1, -10, 0, 30)
            searchFrame.Position = UDim2.new(0, 5, 0, 5)
            searchFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 60)
            searchFrame.BorderSizePixel = 0
            searchFrame.ZIndex = 6
            searchFrame.Parent = dropdownContainer

            local searchCorner = Instance.new("UICorner")
            searchCorner.CornerRadius = UDim.new(0, 4)
            searchCorner.Parent = searchFrame

            local searchBox = Instance.new("TextBox")
            searchBox.Name = "SearchBox"
            searchBox.Size = UDim2.new(1, -10, 1, 0)
            searchBox.Position = UDim2.new(0, 5, 0, 0)
            searchBox.BackgroundTransparency = 1
            searchBox.Font = Enum.Font.SourceSans
            searchBox.PlaceholderText = "Search"
            searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
            searchBox.Text = ""
            searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            searchBox.TextSize = 14
            searchBox.TextXAlignment = Enum.TextXAlignment.Left
            searchBox.ClearTextOnFocus = false
            searchBox.ZIndex = 7
            searchBox.Parent = searchFrame

            local dropdownFrame = Instance.new("ScrollingFrame")
            dropdownFrame.Name = "DropdownFrame"
            dropdownFrame.Size = UDim2.new(1, -10, 1, -45)
            dropdownFrame.Position = UDim2.new(0, 5, 0, 40)
            dropdownFrame.BackgroundTransparency = 1
            dropdownFrame.BorderSizePixel = 0
            dropdownFrame.Visible = true
            dropdownFrame.ZIndex = 6
            dropdownFrame.ScrollBarThickness = 4
            dropdownFrame.ScrollBarImageColor3 = Color3.fromRGB(120, 40, 40)
            dropdownFrame.Parent = dropdownContainer

            local dropdownLayout = Instance.new("UIListLayout")
            dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
            dropdownLayout.Padding = UDim.new(0, 2)
            dropdownLayout.Parent = dropdownFrame

            if options.MultiSelection then
                local selectedOptions = {}
                for _, v in ipairs(options.CurrentOption or {}) do table.insert(selectedOptions, v) end

                local function updateMainButtonText()
                    local count = #selectedOptions
                    if count == 0 then mainButton.Text = options.Name
                    elseif count <= 2 then mainButton.Text = table.concat(selectedOptions, ", ")
                    else mainButton.Text = count .. " Selected" end
                end

                local allOptionButtons = {}

                local function refreshOptions(newOptions)
                    for _, child in ipairs(dropdownFrame:GetChildren()) do 
                        if child:IsA("TextButton") then child:Destroy() end 
                    end
                    allOptionButtons = {}
                    
                    for _, optionName in ipairs(newOptions or options.Options) do
                        local optionButton = Instance.new("TextButton")
                        optionButton.Name = optionName
                        optionButton.Size = UDim2.new(1, 0, 0, 30)
                        optionButton.Text = optionName
                        optionButton.Font = Enum.Font.SourceSans
                        optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                        optionButton.TextSize = 14
                        optionButton.TextXAlignment = Enum.TextXAlignment.Left
                        optionButton.ZIndex = 7
                        optionButton.Parent = dropdownFrame
                        
                        local optCorner = Instance.new("UICorner")
                        optCorner.CornerRadius = UDim.new(0, 4)
                        optCorner.Parent = optionButton

                        local isSelected = table.find(selectedOptions, optionName)
                        optionButton.BackgroundColor3 = isSelected and Color3.fromRGB(0, 80, 170) or Color3.fromRGB(40, 40, 65)

                        table.insert(allOptionButtons, {button = optionButton, name = optionName})

                        optionButton.MouseEnter:Connect(function() 
                            if not table.find(selectedOptions, optionName) then 
                                optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
                            end 
                        end)
                        
                        optionButton.MouseLeave:Connect(function() 
                            if not table.find(selectedOptions, optionName) then 
                                optionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
                            end 
                        end)

                        optionButton.MouseButton1Click:Connect(function()
                            local foundIndex = table.find(selectedOptions, optionName)
                            if foundIndex then
                                table.remove(selectedOptions, foundIndex)
                                optionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
                            else
                                table.insert(selectedOptions, optionName)
                                optionButton.BackgroundColor3 = Color3.fromRGB(0, 80, 170)
                            end
                            updateMainButtonText()
                            if options.Callback then options.Callback(selectedOptions) end
                        end)
                    end
                    dropdownFrame.CanvasSize = UDim2.new(0,0,0,dropdownLayout.AbsoluteContentSize.Y)
                end
                
                searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local searchText = searchBox.Text:lower()
                    for _, optionData in ipairs(allOptionButtons) do
                        local btn = optionData.button
                        local name = optionData.name:lower()
                        if searchText == "" or name:find(searchText, 1, true) then
                            btn.Visible = true
                        else
                            btn.Visible = false
                        end
                    end
                end)
                
                updateMainButtonText()
                refreshOptions(options.Options)
            else
                Dropdown.CurrentOption = options.CurrentOption or options.Options[1]
                mainButton.Text = Dropdown.CurrentOption

                local allOptionButtons = {}

                local function refreshOptions(newOptions)
                    for _, child in ipairs(dropdownFrame:GetChildren()) do 
                        if child:IsA("TextButton") then child:Destroy() end 
                    end
                    allOptionButtons = {}
                    
                    for _, optionName in ipairs(newOptions) do
                        local optionButton = Instance.new("TextButton")
                        optionButton.Name = optionName
                        optionButton.Size = UDim2.new(1, 0, 0, 30)
                        optionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
                        optionButton.Text = optionName
                        optionButton.Font = Enum.Font.SourceSans
                        optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                        optionButton.TextSize = 14
                        optionButton.TextXAlignment = Enum.TextXAlignment.Left
                        optionButton.ZIndex = 7
                        optionButton.Parent = dropdownFrame
                        
                        local optCorner = Instance.new("UICorner")
                        optCorner.CornerRadius = UDim.new(0, 4)
                        optCorner.Parent = optionButton

                        table.insert(allOptionButtons, {button = optionButton, name = optionName})
                        
                        optionButton.MouseEnter:Connect(function() 
                            optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
                        end)
                        
                        optionButton.MouseLeave:Connect(function() 
                            optionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
                        end)

                        optionButton.MouseButton1Click:Connect(function()
                            Dropdown.CurrentOption = optionName
                            mainButton.Text = optionName
                            isOpen = false
                            dropdownContainer.Visible = false
                            container.ZIndex = 2
                            if options.Callback then options.Callback(optionName) end
                        end)
                    end
                    dropdownFrame.CanvasSize = UDim2.new(0,0,0,dropdownLayout.AbsoluteContentSize.Y)
                end
                
                searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local searchText = searchBox.Text:lower()
                    for _, optionData in ipairs(allOptionButtons) do
                        local btn = optionData.button
                        local name = optionData.name:lower()
                        if searchText == "" or name:find(searchText, 1, true) then
                            btn.Visible = true
                        else
                            btn.Visible = false
                        end
                    end
                end)
                
                refreshOptions(options.Options)
            end

            mainButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                dropdownContainer.Visible = isOpen
                container.ZIndex = isOpen and 100 or 2
            end)
            
            return Dropdown
        end
        Tab.Dropdown = Tab.CreateDropdown
        
        return Tab
    end
    return Window
end

return Rayfield