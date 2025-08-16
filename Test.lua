local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Create main screen GUI
local MobileUI = Instance.new("ScreenGui")
MobileUI.Name = "MobileUI"
MobileUI.ResetOnSpawn = false
MobileUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MobileUI.DisplayOrder = 10
MobileUI.Parent = PlayerGui

-- Main container frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0.8, 0, 0.9, 0)
MainFrame.Position = UDim2.new(0.1, 0, 0.05, 0)
MainFrame.AnchorPoint = Vector2.new(0, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = MobileUI

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = MainFrame

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0.08, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0.15, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Game Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = TitleBar

-- Hide/show button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0.15, 0, 1, 0)
ToggleButton.Position = UDim2.new(0, 0, 0, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "≡"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = TitleBar

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 12)
toggleCorner.Parent = ToggleButton

-- Tab buttons container
local TabButtons = Instance.new("Frame")
TabButtons.Name = "TabButtons"
TabButtons.Size = UDim2.new(0.15, 0, 0.92, 0)
TabButtons.Position = UDim2.new(0, 0, 0.08, 0)
TabButtons.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TabButtons.BorderSizePixel = 0
TabButtons.Parent = MainFrame

local tabButtonsCorner = Instance.new("UICorner")
tabButtonsCorner.CornerRadius = UDim.new(0, 12)
tabButtonsCorner.Parent = TabButtons

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Padding = UDim.new(0, 5)
TabListLayout.FillDirection = Enum.FillDirection.Vertical
TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
TabListLayout.Parent = TabButtons

-- Content frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(0.85, 0, 0.92, 0)
ContentFrame.Position = UDim2.new(0.15, 0, 0.08, 0)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local ContentScrolling = Instance.new("ScrollingFrame")
ContentScrolling.Name = "ContentScrolling"
ContentScrolling.Size = UDim2.new(1, 0, 1, 0)
ContentScrolling.BackgroundTransparency = 1
ContentScrolling.BorderSizePixel = 0
ContentScrolling.ScrollBarThickness = 6
ContentScrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentScrolling.Parent = ContentFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 10)
ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ContentLayout.Parent = ContentScrolling

-- Hide/show functionality
local isMenuOpen = true

local function toggleMenu()
    isMenuOpen = not isMenuOpen
    
    if isMenuOpen then
        TabButtons.Visible = true
        ContentFrame.Size = UDim2.new(0.85, 0, 0.92, 0)
        ContentFrame.Position = UDim2.new(0.15, 0, 0.08, 0)
        ToggleButton.Text = "≡"
    else
        TabButtons.Visible = false
        ContentFrame.Size = UDim2.new(0.98, 0, 0.92, 0)
        ContentFrame.Position = UDim2.new(0.01, 0, 0.08, 0)
        ToggleButton.Text = ">"
    end
end

ToggleButton.MouseButton1Click:Connect(toggleMenu)

-- UI Template Functions
local UITemplate = {}

function UITemplate:CreateTab(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "TabButton"
    TabButton.Size = UDim2.new(0.9, 0, 0.1, 0)
    TabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    TabButton.BorderSizePixel = 0
    TabButton.Text = name
    TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.TextScaled = true
    TabButton.Font = Enum.Font.Gotham
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = TabButton
    
    TabButton.Parent = TabButtons
    
    local TabContent = Instance.new("Frame")
    TabContent.Name = name .. "Content"
    TabContent.Size = UDim2.new(1, 0, 0, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.Visible = false
    TabContent.Parent = ContentScrolling
    
    local tabContentLayout = Instance.new("UIListLayout")
    tabContentLayout.Padding = UDim.new(0, 10)
    tabContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabContentLayout.Parent = TabContent
    
    TabButton.MouseButton1Click:Connect(function()
        for _, child in ipairs(ContentScrolling:GetChildren()) do
            if child:IsA("Frame") and child.Name:find("Content") then
                child.Visible = false
            end
        end
        TabContent.Visible = true
    end)
    
    -- Select first tab by default
    if #TabButtons:GetChildren() == 2 then -- Layout + first button
        TabContent.Visible = true
    end
    
    local TabAPI = {}
    
    function TabAPI:Button(params)
        local ButtonFrame = Instance.new("Frame")
        ButtonFrame.Name = params.Name .. "ButtonFrame"
        ButtonFrame.Size = UDim2.new(0.95, 0, 0, 40)
        ButtonFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        ButtonFrame.BackgroundTransparency = 0.2
        ButtonFrame.BorderSizePixel = 0
        ButtonFrame.Parent = TabContent
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 8)
        buttonCorner.Parent = ButtonFrame
        
        local Button = Instance.new("TextButton")
        Button.Name = params.Name .. "Button"
        Button.Size = UDim2.new(1, 0, 1, 0)
        Button.BackgroundTransparency = 1
        Button.Text = params.Name
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextScaled = true
        Button.Font = Enum.Font.Gotham
        Button.Parent = ButtonFrame
        
        if params.Description then
            local Desc = Instance.new("TextLabel")
            Desc.Name = "Description"
            Desc.Size = UDim2.new(0.9, 0, 0, 15)
            Desc.Position = UDim2.new(0.05, 0, 0.8, 0)
            Desc.BackgroundTransparency = 1
            Desc.Text = params.Description
            Desc.TextColor3 = Color3.fromRGB(200, 200, 200)
            Desc.TextScaled = true
            Desc.Font = Enum.Font.Gotham
            Desc.Parent = ButtonFrame
            
            Button.TextSize = 14
        end
        
        Button.MouseButton1Click:Connect(function()
            pcall(params.Callback)
        end)
        
        return Button
    end
    
    function TabAPI:Toggle(params)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Name = params.Name .. "ToggleFrame"
        ToggleFrame.Size = UDim2.new(0.95, 0, 0, 40)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        ToggleFrame.BackgroundTransparency = 0.2
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Parent = TabContent
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 8)
        toggleCorner.Parent = ToggleFrame
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Name = params.Name .. "Toggle"
        ToggleButton.Size = UDim2.new(0.7, 0, 1, 0)
        ToggleButton.Position = UDim2.new(0, 0, 0, 0)
        ToggleButton.BackgroundTransparency = 1
        ToggleButton.Text = params.Name
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleButton.TextScaled = true
        ToggleButton.TextXAlignment = Enum.TextXAlignment.Left
        ToggleButton.Font = Enum.Font.Gotham
        ToggleButton.Parent = ToggleFrame
        
        local ToggleStatus = Instance.new("Frame")
        ToggleStatus.Name = "ToggleStatus"
        ToggleStatus.Size = UDim2.new(0.2, 0, 0.6, 0)
        ToggleStatus.Position = UDim2.new(0.75, 0, 0.2, 0)
        ToggleStatus.BackgroundColor3 = params.StartingState and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        ToggleStatus.BorderSizePixel = 0
        ToggleStatus.Parent = ToggleFrame
        
        local statusCorner = Instance.new("UICorner")
        statusCorner.CornerRadius = UDim.new(0.5, 0)
        statusCorner.Parent = ToggleStatus
        
        if params.Description then
            local Desc = Instance.new("TextLabel")
            Desc.Name = "Description"
            Desc.Size = UDim2.new(0.9, 0, 0, 15)
            Desc.Position = UDim2.new(0.05, 0, 0.8, 0)
            Desc.BackgroundTransparency = 1
            Desc.Text = params.Description
            Desc.TextColor3 = Color3.fromRGB(200, 200, 200)
            Desc.TextScaled = true
            Desc.Font = Enum.Font.Gotham
            Desc.Parent = ToggleFrame
            
            ToggleButton.TextSize = 14
        end
        
        local function updateToggle(state)
            ToggleStatus.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
            pcall(params.Callback, state)
        end
        
        ToggleButton.MouseButton1Click:Connect(function()
            local newState = not (ToggleStatus.BackgroundColor3 == Color3.fromRGB(0, 200, 0))
            updateToggle(newState)
        end)
        
        -- Initialize state
        updateToggle(params.StartingState)
        
        return {
            Update = updateToggle
        }
    end
    
    function TabAPI:Textbox(params)
        local TextboxFrame = Instance.new("Frame")
        TextboxFrame.Name = params.Name .. "TextboxFrame"
        TextboxFrame.Size = UDim2.new(0.95, 0, 0, 50)
        TextboxFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        TextboxFrame.BackgroundTransparency = 0.2
        TextboxFrame.BorderSizePixel = 0
        TextboxFrame.Parent = TabContent
        
        local textboxCorner = Instance.new("UICorner")
        textboxCorner.CornerRadius = UDim.new(0, 8)
        textboxCorner.Parent = TextboxFrame
        
        local TextboxLabel = Instance.new("TextLabel")
        TextboxLabel.Name = "Label"
        TextboxLabel.Size = UDim2.new(0.9, 0, 0.4, 0)
        TextboxLabel.Position = UDim2.new(0.05, 0, 0, 0)
        TextboxLabel.BackgroundTransparency = 1
        TextboxLabel.Text = params.Name
        TextboxLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextboxLabel.TextScaled = true
        TextboxLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextboxLabel.Font = Enum.Font.Gotham
        TextboxLabel.Parent = TextboxFrame
        
        local Textbox = Instance.new("TextBox")
        Textbox.Name = "Textbox"
        Textbox.Size = UDim2.new(0.9, 0, 0.5, 0)
        Textbox.Position = UDim2.new(0.05, 0, 0.4, 0)
        Textbox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Textbox.BorderSizePixel = 0
        Textbox.Text = ""
        Textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
        Textbox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
        Textbox.Font = Enum.Font.Gotham
        Textbox.Parent = TextboxFrame
        
        local boxCorner = Instance.new("UICorner")
        boxCorner.CornerRadius = UDim.new(0, 4)
        boxCorner.Parent = Textbox
        
        Textbox.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                pcall(params.Callback, Textbox.Text)
                Textbox.Text = ""
            end
        end)
        
        return Textbox
    end
    
    function TabAPI:Dropdown(params)
        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Name = params.Name .. "DropdownFrame"
        DropdownFrame.Size = UDim2.new(0.95, 0, 0, 40)
        DropdownFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        DropdownFrame.BackgroundTransparency = 0.2
        DropdownFrame.BorderSizePixel = 0
        DropdownFrame.ClipsDescendants = true
        DropdownFrame.Parent = TabContent
        
        local dropdownCorner = Instance.new("UICorner")
        dropdownCorner.CornerRadius = UDim.new(0, 8)
        dropdownCorner.Parent = DropdownFrame
        
        local DropdownButton = Instance.new("TextButton")
        DropdownButton.Name = "DropdownButton"
        DropdownButton.Size = UDim2.new(1, 0, 0, 40)
        DropdownButton.BackgroundTransparency = 1
        DropdownButton.Text = params.Name .. ": " .. params.StartingText
        DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        DropdownButton.TextScaled = true
        DropdownButton.Font = Enum.Font.Gotham
        DropdownButton.Parent = DropdownFrame
        
        local DropdownList = Instance.new("Frame")
        DropdownList.Name = "DropdownList"
        DropdownList.Size = UDim2.new(1, 0, 0, 0)
        DropdownList.Position = UDim2.new(0, 0, 0, 40)
        DropdownList.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        DropdownList.BorderSizePixel = 0
        DropdownList.Visible = false
        DropdownList.Parent = DropdownFrame
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 2)
        listLayout.Parent = DropdownList
        
        local items = {}
        local selectedItem = nil
        
        local function updateDropdownSize()
            DropdownList.Size = UDim2.new(1, 0, 0, listLayout.AbsoluteContentSize.Y)
            DropdownFrame.Size = UDim2.new(0.95, 0, 0, DropdownList.Visible and (40 + DropdownList.Size.Y.Offset) or 40)
        end
        
        local function toggleDropdown()
            DropdownList.Visible = not DropdownList.Visible
            updateDropdownSize()
        end
        
        local function selectItem(itemName, itemValue)
            selectedItem = {Name = itemName, Value = itemValue}
            DropdownButton.Text = params.Name .. ": " .. itemName
            toggleDropdown()
            pcall(params.Callback, selectedItem)
        end
        
        local function addItem(itemName, itemValue)
            local name = itemName
            local value = itemValue
            
            if type(itemName) == "table" then
                name = itemName[1]
                value = itemName[2]
            elseif itemValue == nil then
                value = itemName
                name = tostring(itemName)
            end
            
            local ItemButton = Instance.new("TextButton")
            ItemButton.Name = name .. "Item"
            ItemButton.Size = UDim2.new(1, 0, 0, 30)
            ItemButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            ItemButton.BorderSizePixel = 0
            ItemButton.Text = name
            ItemButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            ItemButton.TextScaled = true
            ItemButton.Font = Enum.Font.Gotham
            ItemButton.Parent = DropdownList
            
            local itemCorner = Instance.new("UICorner")
            itemCorner.CornerRadius = UDim.new(0, 4)
            itemCorner.Parent = ItemButton
            
            ItemButton.MouseButton1Click:Connect(function()
                selectItem(name, value)
            end)
            
            table.insert(items, {Name = name, Value = value})
            updateDropdownSize()
        end
        
        local function removeItem(itemName)
            for i, item in ipairs(items) do
                if string.lower(item.Name) == string.lower(itemName) then
                    table.remove(items, i)
                    local itemFrame = DropdownList:FindFirstChild(item.Name .. "Item")
                    if itemFrame then
                        itemFrame:Destroy()
                    end
                    break
                end
            end
            updateDropdownSize()
        end
        
        -- Add initial items
        for _, item in ipairs(params.Items) do
            addItem(item)
        end
        
        DropdownButton.MouseButton1Click:Connect(toggleDropdown)
        
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateDropdownSize)
        
        return {
            AddItems = function(newItems)
                for _, item in ipairs(newItems) do
                    addItem(item)
                end
            end,
            RemoveItems = function(itemNames)
                for _, name in ipairs(itemNames) do
                    removeItem(name)
                end
            end,
            Clear = function()
                for _, item in ipairs(items) do
                    local itemFrame = DropdownList:FindFirstChild(item.Name .. "Item")
                    if itemFrame then
                        itemFrame:Destroy()
                    end
                end
                items = {}
                updateDropdownSize()
            end,
            SelectItem = selectItem
        }
    end
    
    function TabAPI:Slider(params)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Name = params.Name .. "SliderFrame"
        SliderFrame.Size = UDim2.new(0.95, 0, 0, 70)
        SliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        SliderFrame.BackgroundTransparency = 0.2
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Parent = TabContent
        
        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(0, 8)
        sliderCorner.Parent = SliderFrame
        
        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Name = "SliderLabel"
        SliderLabel.Size = UDim2.new(0.9, 0, 0.3, 0)
        SliderLabel.Position = UDim2.new(0.05, 0, 0, 0)
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Text = params.Name .. ": " .. params.Default
        SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        SliderLabel.TextScaled = true
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        SliderLabel.Font = Enum.Font.Gotham
        SliderLabel.Parent = SliderFrame
        
        local SliderTrack = Instance.new("Frame")
        SliderTrack.Name = "SliderTrack"
        SliderTrack.Size = UDim2.new(0.9, 0, 0.3, 0)
        SliderTrack.Position = UDim2.new(0.05, 0, 0.4, 0)
        SliderTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        SliderTrack.BorderSizePixel = 0
        SliderTrack.Parent = SliderFrame
        
        local trackCorner = Instance.new("UICorner")
        trackCorner.CornerRadius = UDim.new(0.5, 0)
        trackCorner.Parent = SliderTrack
        
        local SliderThumb = Instance.new("Frame")
        SliderThumb.Name = "SliderThumb"
        SliderThumb.Size = UDim2.new(0, 20, 1, 0)
        SliderThumb.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        SliderThumb.BorderSizePixel = 0
        SliderThumb.Parent = SliderTrack
        
        local thumbCorner = Instance.new("UICorner")
        thumbCorner.CornerRadius = UDim.new(0.5, 0)
        thumbCorner.Parent = SliderThumb
        
        local currentValue = params.Default or params.Min
        
        local function updateSlider(value)
            currentValue = math.clamp(value, params.Min, params.Max)
            local percent = (currentValue - params.Min) / (params.Max - params.Min)
            SliderThumb.Position = UDim2.new(percent, -10, 0, 0)
            SliderLabel.Text = params.Name .. ": " .. string.format("%.2f", currentValue)
            pcall(params.Callback, currentValue)
        end
        
        local isDragging = false
        
        SliderThumb.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
            end
        end)
        
        SliderThumb.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = false
            end
        end)
        
        SliderTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                local xPos = input.Position.X - SliderTrack.AbsolutePosition.X
                local percent = math.clamp(xPos / SliderTrack.AbsoluteSize.X, 0, 1)
                local value = params.Min + (params.Max - params.Min) * percent
                updateSlider(value)
            end
        end)
        
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local xPos = input.Position.X - SliderTrack.AbsolutePosition.X
                local percent = math.clamp(xPos / SliderTrack.AbsoluteSize.X, 0, 1)
                local value = params.Min + (params.Max - params.Min) * percent
                updateSlider(value)
            end
        end)
        
        -- Initialize slider
        updateSlider(params.Default or params.Min)
        
        return {
            SetValue = updateSlider
        }
    end
    
    return TabAPI
end

function UITemplate:Notification(params)
    local Notification = Instance.new("Frame")
    Notification.Name = "Notification"
    Notification.Size = UDim2.new(0.8, 0, 0.15, 0)
    Notification.Position = UDim2.new(0.1, 0, 0.02, 0)
    Notification.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Notification.BackgroundTransparency = 0.2
    Notification.BorderSizePixel = 0
    Notification.Parent = MobileUI
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 12)
    notifCorner.Parent = Notification
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0.9, 0, 0.4, 0)
    Title.Position = UDim2.new(0.05, 0, 0.05, 0)
    Title.BackgroundTransparency = 1
    Title.Text = params.Title or "Notification"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextScaled = true
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Notification
    
    local Text = Instance.new("TextLabel")
    Text.Name = "Text"
    Text.Size = UDim2.new(0.9, 0, 0.5, 0)
    Text.Position = UDim2.new(0.05, 0, 0.4, 0)
    Text.BackgroundTransparency = 1
    Text.Text = params.Text or ""
    Text.TextColor3 = Color3.fromRGB(200, 200, 200)
    Text.TextScaled = true
    Text.Font = Enum.Font.Gotham
    Text.Parent = Notification
    
    local duration = params.Duration or 3
    
    task.spawn(function()
        wait(duration)
        Notification:Destroy()
        if params.Callback then
            pcall(params.Callback)
        end
    end)
    
    return Notification
end

return UITemplate
