--[[
    UITemplate ModuleScript
    Description: A comprehensive, modular, and mobile-friendly UI library.
    Author: YourNameHere
    Instructions: 
    1. Place this script as a ModuleScript in your game (e.g., in ReplicatedStorage).
    2. Require it from a LocalScript to build and control the UI.
]]

--//=========================================================================\\
--|| SERVICES
--\\=========================================================================//

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--//=========================================================================\\
--|| MAIN GUI LIBRARY MODULE
--\\=========================================================================//

local UITemplate = {}
UITemplate.__index = UITemplate

-- A debounce table to prevent spamming
local debounce = {}

-- Main configuration for the UI
local Config = {
    WindowTitle = "UI Template", -- Default name, can be changed
    ToggleKey = Enum.KeyCode.RightShift,
    AccentColor = Color3.fromRGB(100, 120, 255),
    BackgroundColor = Color3.fromRGB(35, 35, 45),
    ForegroundColor = Color3.fromRGB(45, 45, 55),
    TextColor = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.SourceSans,
}

-- Create the main ScreenGui and container ONCE
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainScreenGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
pcall(function() screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui") end)


local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 500, 0, 400)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
mainFrame.BackgroundColor3 = Config.BackgroundColor
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
mainFrame.Visible = false -- Start hidden

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Header for title and dragging
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Config.AccentColor
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -30, 1, 0)
titleLabel.BackgroundColor3 = Config.AccentColor
titleLabel.Text = Config.WindowTitle
titleLabel.Font = Config.Font
titleLabel.TextColor3 = Config.TextColor
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header
local titlePadding = Instance.new("UIPadding")
titlePadding.PaddingLeft = UDim.new(0, 10)
titlePadding.Parent = titleLabel

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 1, 0)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundColor3 = Config.AccentColor
closeButton.Text = "X"
closeButton.Font = Config.Font
closeButton.TextColor3 = Config.TextColor
closeButton.TextSize = 16
closeButton.Parent = header

-- Container for tabs and content
local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(0, 120, 1, -30)
tabContainer.Position = UDim2.new(0, 0, 0, 30)
tabContainer.BackgroundColor3 = Config.ForegroundColor
tabContainer.BorderSizePixel = 0
tabContainer.Parent = mainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.Padding = UDim.new(0, 5)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabContainer

local contentContainer = Instance.new("Frame")
contentContainer.Name = "ContentContainer"
contentContainer.Size = UDim2.new(1, -120, 1, -30)
contentContainer.Position = UDim2.new(0, 120, 0, 30)
contentContainer.BackgroundColor3 = Config.BackgroundColor
contentContainer.BorderSizePixel = 0
contentContainer.Parent = mainFrame

-- Store tabs and content pages
local tabs = {}
local contentPages = {}
local activeTab = nil

--//=========================================================================\\
--|| CORE FUNCTIONALITY (DRAGGING, TOGGLING)
--\\=========================================================================//

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleUI"
toggleButton.Size = UDim2.new(0, 80, 0, 30)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Config.AccentColor
toggleButton.Text = "Show UI"
toggleButton.Font = Config.Font
toggleButton.TextColor3 = Config.TextColor
toggleButton.TextSize = 14
toggleButton.Parent = screenGui
local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 4)
toggleCorner.Parent = toggleButton

local function ToggleUI(visible)
    mainFrame.Visible = visible
    toggleButton.Text = visible and "Hide UI" or "Show UI"
end

local toggleDragging = false
local toggleDragStart
local toggleStartPos

toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        toggleDragging = false
        toggleDragStart = input.Position
        toggleStartPos = toggleButton.Position
        local moveConn
        moveConn = UserInputService.InputChanged:Connect(function(moveInput)
            if (moveInput.Position - input.Position).Magnitude > 5 then
                toggleDragging = true
                moveConn:Disconnect()
            end
        end)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                moveConn:Disconnect()
                if not toggleDragging then
                    ToggleUI(not mainFrame.Visible)
                end
                toggleDragging = false
            end
        end)
    end
end)

toggleButton.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and toggleDragging then
        local delta = input.Position - toggleDragStart
        toggleButton.Position = UDim2.new(toggleStartPos.X.Scale, toggleStartPos.X.Offset + delta.X, toggleStartPos.Y.Scale, toggleStartPos.Y.Offset + delta.Y)
    end
end)

closeButton.MouseButton1Click:Connect(function() ToggleUI(false) end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Config.ToggleKey then ToggleUI(not mainFrame.Visible) end
end)

local dragging = false
local dragStart
local startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

--//=========================================================================\\
--|| PUBLIC API
--\\=========================================================================//

function UITemplate:SetName(name)
    Config.WindowTitle = name
    titleLabel.Text = name
end

function UITemplate:CreateTab(name)
    local tabObject = {}
    
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name
    tabButton.Size = UDim2.new(1, -10, 0, 30)
    tabButton.Position = UDim2.new(0.5, 0, 0, 0)
    tabButton.AnchorPoint = Vector2.new(0.5, 0)
    tabButton.BackgroundColor3 = Config.ForegroundColor
    tabButton.Text = name
    tabButton.Font = Config.Font
    tabButton.TextColor3 = Config.TextColor
    tabButton.TextSize = 14
    tabButton.Parent = tabContainer
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 4)
    tabCorner.Parent = tabButton

    local contentPage = Instance.new("ScrollingFrame")
    contentPage.Name = name .. "Content"
    contentPage.Size = UDim2.new(1, 0, 1, 0)
    contentPage.BackgroundColor3 = Config.BackgroundColor
    contentPage.BorderSizePixel = 0
    contentPage.Visible = false
    contentPage.Parent = contentContainer
    contentPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentPage.ScrollBarImageColor3 = Config.AccentColor
    contentPage.ScrollBarThickness = 5

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = contentPage

    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 10)
    contentPadding.PaddingLeft = UDim.new(0, 10)
    contentPadding.PaddingRight = UDim.new(0, 10)
    contentPadding.Parent = contentPage

    local function updateCanvasSize()
        RunService.Heartbeat:Wait()
        contentPage.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    end
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
    
    table.insert(tabs, tabButton)
    table.insert(contentPages, contentPage)

    tabButton.MouseButton1Click:Connect(function()
        if activeTab == tabButton then return end
        for _, page in ipairs(contentPages) do page.Visible = false end
        for _, t in ipairs(tabs) do t.BackgroundColor3 = Config.ForegroundColor end
        contentPage.Visible = true
        tabButton.BackgroundColor3 = Config.AccentColor
        activeTab = tabButton
    end)

    if #tabs == 1 then
        task.defer(function() tabButton.MouseButton1Click:Fire() end)
    end
    
    --//=========================================================================\\
    --|| COMPONENT FUNCTIONS
    --\\=========================================================================//
    
    function tabObject:Button(options)
        local button = Instance.new("TextButton")
        button.Name = options.Name or "Button"
        button.Size = UDim2.new(1, -20, 0, 35)
        button.BackgroundColor3 = Config.ForegroundColor
        button.Text = options.Name or "Button"
        button.Font = Config.Font
        button.TextColor3 = Config.TextColor
        button.TextSize = 14
        button.Parent = contentPage
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = button
        button.MouseButton1Click:Connect(function()
            if options.Callback then options.Callback() end
        end)
        updateCanvasSize()
    end

    function tabObject:Toggle(options)
        local state = options.StartingState or false
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = options.Name or "Toggle"
        toggleFrame.Size = UDim2.new(1, -20, 0, 35)
        toggleFrame.BackgroundColor3 = Config.ForegroundColor
        toggleFrame.BorderSizePixel = 0
        toggleFrame.Parent = contentPage
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = toggleFrame
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -50, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = options.Name or "Toggle"
        label.Font = Config.Font
        label.TextColor3 = Config.TextColor
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = toggleFrame
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 10)
        padding.Parent = label
        local switch = Instance.new("TextButton")
        switch.Size = UDim2.new(0, 40, 0, 20)
        switch.Position = UDim2.new(1, -45, 0.5, 0)
        switch.AnchorPoint = Vector2.new(1, 0.5)
        switch.BackgroundColor3 = state and Config.AccentColor or Color3.fromRGB(80, 80, 80)
        switch.Text = ""
        switch.Parent = toggleFrame
        local switchCorner = Instance.new("UICorner")
        switchCorner.CornerRadius = UDim.new(1, 0)
        switchCorner.Parent = switch
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = UDim2.new(state and 1 or 0, state and -3 or 3, 0.5, 0)
        knob.AnchorPoint = Vector2.new(state and 1 or 0, 0.5)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        knob.Parent = switch
        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(1, 0)
        knobCorner.Parent = knob
        switch.MouseButton1Click:Connect(function()
            state = not state
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(knob, tweenInfo, {Position = UDim2.new(state and 1 or 0, state and -3 or 3, 0.5, 0), AnchorPoint = Vector2.new(state and 1 or 0, 0.5)}):Play()
            TweenService:Create(switch, tweenInfo, {BackgroundColor3 = state and Config.AccentColor or Color3.fromRGB(80, 80, 80)}):Play()
            if options.Callback then options.Callback(state) end
        end)
        updateCanvasSize()
    end

    function tabObject:Textbox(options)
        local textbox = Instance.new("TextBox")
        textbox.Name = options.Name or "Textbox"
        textbox.Size = UDim2.new(1, -20, 0, 35)
        textbox.BackgroundColor3 = Config.ForegroundColor
        textbox.PlaceholderText = options.Name or "Enter text..."
        textbox.Font = Config.Font
        textbox.TextColor3 = Config.TextColor
        textbox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
        textbox.TextSize = 14
        textbox.ClearTextOnFocus = false
        textbox.Parent = contentPage
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = textbox
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 10)
        padding.Parent = textbox
        textbox.FocusLost:Connect(function(enterPressed)
            if enterPressed and options.Callback then
                options.Callback(textbox.Text)
            end
        end)
        updateCanvasSize()
    end

    function tabObject:Dropdown(options)
        local dropdownObject = {}
        local items = {} -- Internal storage for {Name, Value} pairs
        local isOpen = false

        local dropdownFrame = Instance.new("Frame")
        dropdownFrame.Name = options.Name or "Dropdown"
        dropdownFrame.Size = UDim2.new(1, -20, 0, 35)
        dropdownFrame.BackgroundColor3 = Config.ForegroundColor
        dropdownFrame.ClipsDescendants = true
        dropdownFrame.Parent = contentPage
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = dropdownFrame

        local mainButton = Instance.new("TextButton")
        mainButton.Name = "MainButton"
        mainButton.Size = UDim2.new(1, 0, 1, 0)
        mainButton.BackgroundColor3 = Config.ForegroundColor
        mainButton.Text = options.StartingText or "Select..."
        mainButton.Font = Config.Font
        mainButton.TextColor3 = Config.TextColor
        mainButton.TextSize = 14
        mainButton.Parent = dropdownFrame

        local arrow = Instance.new("TextLabel")
        arrow.Size = UDim2.new(0, 20, 1, 0)
        arrow.Position = UDim2.new(1, -20, 0, 0)
        arrow.BackgroundTransparency = 1
        arrow.Font = Enum.Font.SourceSansBold
        arrow.Text = "▼"
        arrow.TextColor3 = Config.TextColor
        arrow.TextSize = 14
        arrow.Parent = mainButton

        local itemContainer = Instance.new("ScrollingFrame")
        itemContainer.Size = UDim2.new(1, 0, 0, 120)
        itemContainer.Position = UDim2.new(0, 0, 1, 0)
        itemContainer.BackgroundColor3 = Config.ForegroundColor
        itemContainer.BorderSizePixel = 0
        itemContainer.Visible = false
        itemContainer.Parent = dropdownFrame
        itemContainer.CanvasSize = UDim2.new(0,0,0,0)
        itemContainer.ScrollBarImageColor3 = Config.AccentColor
        itemContainer.ScrollBarThickness = 4

        local itemLayout = Instance.new("UIListLayout")
        itemLayout.SortOrder = Enum.SortOrder.LayoutOrder
        itemLayout.Parent = itemContainer
        
        local function updateDropdownCanvas()
            itemContainer.CanvasSize = UDim2.new(0, 0, 0, itemLayout.AbsoluteContentSize.Y)
        end

        local function createItemButton(itemData)
            local itemButton = Instance.new("TextButton")
            itemButton.Name = itemData.Name
            itemButton.Size = UDim2.new(1, 0, 0, 30)
            itemButton.BackgroundColor3 = Config.ForegroundColor
            itemButton.Text = itemData.Name
            itemButton.Font = Config.Font
            itemButton.TextColor3 = Config.TextColor
            itemButton.TextSize = 14
            itemButton.Parent = itemContainer
            
            itemButton.MouseEnter:Connect(function() itemButton.BackgroundColor3 = Config.AccentColor end)
            itemButton.MouseLeave:Connect(function() itemButton.BackgroundColor3 = Config.ForegroundColor end)

            itemButton.MouseButton1Click:Connect(function()
                mainButton.Text = itemData.Name
                isOpen = false
                itemContainer.Visible = false
                arrow.Text = "▼"
                dropdownFrame.Size = UDim2.new(1, -20, 0, 35)
                updateCanvasSize()
                if options.Callback then options.Callback(itemData) end
            end)
            updateDropdownCanvas()
        end
        
        local function parseAndAddItem(itemData)
            local parsedItem = {}
            if type(itemData) == "table" then
                parsedItem.Name, parsedItem.Value = itemData[1], itemData[2]
            else
                parsedItem.Name, parsedItem.Value = tostring(itemData), itemData
            end
            table.insert(items, parsedItem)
            createItemButton(parsedItem)
        end

        function dropdownObject:AddItems(newItems)
            for _, itemData in ipairs(newItems) do
                parseAndAddItem(itemData)
            end
        end

        function dropdownObject:RemoveItems(namesToRemove)
            local children = itemContainer:GetChildren()
            for i = #children, 1, -1 do
                local child = children[i]
                if child:IsA("TextButton") then
                    for _, name in ipairs(namesToRemove) do
                        if string.lower(child.Name) == string.lower(name) then
                            child:Destroy()
                        end
                    end
                end
            end
            updateDropdownCanvas()
        end
        
        -- Initial population
        if options.Items then
            for _, itemData in ipairs(options.Items) do
                parseAndAddItem(itemData)
            end
        end

        mainButton.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            itemContainer.Visible = isOpen
            arrow.Text = isOpen and "▲" or "▼"
            dropdownFrame.Size = UDim2.new(1, -20, 0, isOpen and 155 or 35)
            updateCanvasSize()
        end)
        
        updateCanvasSize()
        return dropdownObject
    end
    
    function tabObject:Slider(options)
        local min, max, default = options.Min or 0, options.Max or 100, options.Default or 50
        local value = default
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Name = options.Name or "Slider"
        sliderFrame.Size = UDim2.new(1, -20, 0, 45)
        sliderFrame.BackgroundColor3 = Config.ForegroundColor
        sliderFrame.BorderSizePixel = 0
        sliderFrame.Parent = contentPage
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = sliderFrame
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 20)
        label.Position = UDim2.new(0.5, 0, 0, 0)
        label.AnchorPoint = Vector2.new(0.5, 0)
        label.BackgroundTransparency = 1
        label.Font = Config.Font
        label.TextColor3 = Config.TextColor
        label.TextSize = 14
        label.Parent = sliderFrame
        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -20, 0, 4)
        track.Position = UDim2.new(0.5, 0, 0, 30)
        track.AnchorPoint = Vector2.new(0.5, 0)
        track.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        track.Parent = sliderFrame
        local trackCorner = Instance.new("UICorner")
        trackCorner.CornerRadius = UDim.new(1,0)
        trackCorner.Parent = track
        local progress = Instance.new("Frame")
        progress.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        progress.BackgroundColor3 = Config.AccentColor
        progress.Parent = track
        local progressCorner = Instance.new("UICorner")
        progressCorner.CornerRadius = UDim.new(1,0)
        progressCorner.Parent = progress
        local thumb = Instance.new("TextButton")
        thumb.Size = UDim2.new(0, 16, 0, 16)
        thumb.AnchorPoint = Vector2.new(0.5, 0.5)
        thumb.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
        thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        thumb.Text = ""
        thumb.Parent = track
        local thumbCorner = Instance.new("UICorner")
        thumbCorner.CornerRadius = UDim.new(1,0)
        thumbCorner.Parent = thumb
        local function updateValue(inputPos)
            local relativePos = math.clamp((inputPos.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            value = min + (max - min) * relativePos
            thumb.Position = UDim2.fromScale(relativePos, 0.5)
            progress.Size = UDim2.fromScale(relativePos, 1)
            label.Text = (options.Name or "Slider") .. ": " .. math.floor(value)
            if options.Callback then options.Callback(value) end
        end
        label.Text = (options.Name or "Slider") .. ": " .. math.floor(value)
        local isDragging = false
        thumb.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                updateValue(input.Position)
            end
        end)
        thumb.InputEnded:Connect(function() isDragging = false end)
        UserInputService.InputChanged:Connect(function(input)
            if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateValue(input.Position)
            end
        end)
        updateCanvasSize()
    end
    
    return tabObject
end

function UITemplate:Notification(options)
    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 250, 0, 60)
    notifFrame.Position = UDim2.new(1, 260, 1, -70)
    notifFrame.BackgroundColor3 = Config.ForegroundColor
    notifFrame.Parent = screenGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = notifFrame
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -10, 0, 20)
    title.Position = UDim2.new(0, 5, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = options.Title or "Notification"
    title.Font = Config.Font
    title.TextColor3 = Config.AccentColor
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = notifFrame
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -10, 0, 30)
    text.Position = UDim2.new(0, 5, 0, 25)
    text.BackgroundTransparency = 1
    text.Text = options.Text or ""
    text.Font = Config.Font
    text.TextColor3 = Config.TextColor
    text.TextSize = 12
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.TextWrapped = true
    text.Parent = notifFrame
    local tweenInfoIn = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local tweenInfoOut = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    TweenService:Create(notifFrame, tweenInfoIn, {Position = UDim2.new(1, -260, 1, -70) }):Play()
    task.delay(options.Duration or 3, function()
        if notifFrame.Parent then
            if options.Callback then options.Callback() end
            TweenService:Create(notifFrame, tweenInfoOut, {Position = UDim2.new(1, 260, notifFrame.Position.Y.Scale, notifFrame.Position.Y.Offset)}):Play()
            task.wait(0.5)
            notifFrame:Destroy()
        end
    end)
end

return UITemplate
