local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Define your tabs and options (moved up for height calculation)
local tabs = {
    -- Farm
    {
        name = "Farm",
        options = {
            {
                name = "Sell on Hand",
                type = "toggle",
                callback = function(state)
                    -- Use a local variable to control the selling loop
                    local isSelling = state 
                    getfenv().isSellingOnHand = isSelling -- Update the global flag

                    if isSelling then
                        -- If a selling thread already exists, cancel it to avoid duplicates
                        if getfenv().sellThread then
                            task.cancel(getfenv().sellThread)
                        end
                        -- Start a new thread for selling
                        getfenv().sellThread = task.spawn(function()
                            while getfenv().isSellingOnHand do -- Loop as long as the flag is true
                                game:GetService("ReplicatedStorage").GameEvents.Sell_Item:FireServer()
                                task.wait(0.5) -- Use task.wait for controlled delay
                            end
                        end)
                    else
                        -- Stop selling by canceling the thread
                        if getfenv().sellThread then
                            task.cancel(getfenv().sellThread)
                            getfenv().sellThread = nil
                        end
                    end
                end
            },
            {
                name = "Auto Plant",
                type = "toggle",
                callback = function(state)
                    if state then
                        -- Start planting repeatedly
                        local plantConnection
                        plantConnection = RunService.Heartbeat:Connect(function()
                            local character = player.Character
                            if character then
                                local rootPart = character:FindFirstChild("HumanoidRootPart")
                                if rootPart then
                                    -- Only plant seeds that are selected in the dropdown
                                    for seedName, shouldPlant in pairs(getfenv().selectedPlants or {}) do
                                        if shouldPlant then
                                            -- Get current position and add random offset (5-10 studs away)
                                            local currentPos = rootPart.Position
                                            local randomAngle = math.random() * 2 * math.pi
                                            local randomDistance = math.random(5, 10)
                                            local randomOffset = Vector3.new(
                                                math.cos(randomAngle) * randomDistance,
                                                0,
                                                math.sin(randomAngle) * randomDistance
                                            )
                                            local plantPos = currentPos + randomOffset
                                            
                                            local args = {
                                                [1] = plantPos,
                                                [2] = seedName
                                            }
                                            game:GetService("ReplicatedStorage").GameEvents.Plant_RE:FireServer(unpack(args))
                                            task.wait(0.2) -- Small delay between plants
                                        end
                                    end
                                end
                            end
                        end)
                        
                        -- Store the connection so we can disconnect it later
                        getfenv().plantConnection = plantConnection
                    else
                        -- Stop planting
                        if getfenv().plantConnection then
                            getfenv().plantConnection:Disconnect()
                            getfenv().plantConnection = nil
                        end
                    end
                end,
                hasDropdown = true,
                dropdownOptions = {
                    "Rose",
                    "Carrot",
                    "Strawberry",
                    "Blueberry",
                    "Orange Tulip",
                    "Tomato",
                    "Corn",
                    "Daffodil",
                    "Watermelon",
                    "Pumpkin",            
                    "Apple",
                    "Bamboo",
                    "Coconut",
                    "Cactus",
                    "Dragon Fruit",                                
                    "Mango",
                    "Grape",
                    "Mushroom",
                    "Pepper",
                    "Cacao",
                    "Beanstalk"
                }
            }
        }
    }, 
    
    {
        name = "Player",
        options = {
            {
                name = "Speed (50)", 
                type = "toggle", 
                callback = function(state)
                    local humanoid = ensureCharacter()
                    if state then
                        humanoid.WalkSpeed = 50
                    else
                        humanoid.WalkSpeed = 16 -- Default speed
                    end
                end
            },
            {
                name = "Jump (200)", 
                type = "toggle", 
                callback = function(state)
                    local humanoid = ensureCharacter()
                    if state then
                        humanoid.JumpPower = 200
                    else
                        humanoid.JumpPower = 50 -- Default jump power (note: default is usually 50 in newer Roblox)
                    end
                end
            }
        }
    },
    -- Utility Tab (now only for Anti-AFK)
    {
        name = "Utility",
        options = {
            {
                name = "Anti-AFK",
                type = "toggle",
                callback = toggleAntiAFK
            }
        }
    },
    -- New Auto Buy Tab
    {
        name = "Auto Buy",
        options = {
            {
                name = "Buy Seeds",
                type = "toggle",
                callback = function(state)
                    if state then
                        -- Start buying seeds repeatedly
                        local buySeedsConnection
                        buySeedsConnection = RunService.Heartbeat:Connect(function()
                            -- Only buy seeds that are selected in the dropdown
                            for seedName, shouldBuy in pairs(getfenv().selectedSeeds or {}) do
                                if shouldBuy then
                                    local args = {
                                        [1] = seedName
                                    }
                                    game:GetService("ReplicatedStorage").GameEvents.BuySeedStock:FireServer(unpack(args))
                                    wait(0.1) -- Small delay between purchases
                                end
                            end
                        end)
                        
                        -- Store the connection so we can disconnect it later
                        getfenv().buySeedsConnection = buySeedsConnection
                    else
                        -- Stop buying seeds
                        if getfenv().buySeedsConnection then
                            getfenv().buySeedsConnection:Disconnect()
                            getfenv().buySeedsConnection = nil
                        end
                    end
                end,
                -- Additional properties for the dropdown
                hasDropdown = true,
                dropdownOptions = {
                    "Carrot",
                    "Strawberry",
                    "Blueberry",
                    "Orange Tulip",
                    "Tomato",
                    "Corn",
                    "Daffodil",
                    "Watermelon",
                    "Pumpkin",            
                    "Apple",
                    "Bamboo",
                    "Coconut",
                    "Cactus",
                    "Dragon Fruit",                                
                    "Mango",
                    "Grape",
                    "Mushroom",
                    "Pepper",
                    "Cacao",
                    "Beanstalk"
                }
            },
            {
                name = "Buy Gear",
                type = "toggle",
                callback = function(state)
                    if state then
                        -- Start buying gear repeatedly
                        local buyGearConnection
                        buyGearConnection = RunService.Heartbeat:Connect(function()
                            -- Only buy gear that is selected in the dropdown
                            for gearName, shouldBuy in pairs(getfenv().selectedGear or {}) do
                                if shouldBuy then
                                    local args = {
                                        [1] = gearName
                                    }
                                    game:GetService("ReplicatedStorage").GameEvents.BuyGearStock:FireServer(unpack(args))
                                    wait(0.1) -- Small delay between purchases
                                end
                            end
                        end)
                        
                        -- Store the connection so we can disconnect it later
                        getfenv().buyGearConnection = buyGearConnection
                    else
                        -- Stop buying gear
                        if getfenv().buyGearConnection then
                            getfenv().buyGearConnection:Disconnect()
                            getfenv().buyGearConnection = nil
                        end
                    end
                end,
                -- Additional properties for the dropdown
                hasDropdown = true,
                dropdownOptions = {
                    "Watering Can",
                    "Trowel",
                    "Recall Wrench",
                    "Basic Sprinkler",
                    "Advanced Sprinkler",
                    "Godly Sprinkler",
                    "Lightning Rod",
                    "Master Sprinkler",
                    "Favorite Tool",
                    "Harvest Tool"
                }
            },
            -- New Buy Honey toggle
            {
                name = "Buy Honey",
                type = "toggle",
                callback = function(state)
                    if state then
                        local buyHoneyConnection
                        buyHoneyConnection = RunService.Heartbeat:Connect(function()
                            for honeyItemName, shouldBuy in pairs(getfenv().selectedHoney or {}) do
                                if shouldBuy then
                                    local args = {
                                        [1] = honeyItemName
                                    }
                                    game:GetService("ReplicatedStorage").GameEvents.BuyEventShopStock:FireServer(unpack(args))
                                    wait(0.1) -- Small delay between purchases
                                end
                            end
                        end)
                        getfenv().buyHoneyConnection = buyHoneyConnection
                    else
                        if getfenv().buyHoneyConnection then
                            getfenv().buyHoneyConnection:Disconnect()
                            getfenv().buyHoneyConnection = nil
                        end
                    end
                end,
                hasDropdown = true,
                dropdownOptions = {
                    "Flower Seed Pack",
                    "Nectarine Seed",
                    "Hive Fruit Seed",
                    "Bee Crates",
                    "Honey Torch",
                    "Bee Chair",
                    "Honey Comb",
                    "Honey Walkway",
                }
            }
        }
    }
}

-- Calculate required heights based on the number of tabs
local TAB_BUTTON_HEIGHT = 35 -- pixels
local TAB_PADDING = 5 -- pixels
local HEADER_HEIGHT = 35 -- pixels

local numTabs = table.getn(tabs)
local totalTabsAreaPixelHeight = (numTabs * TAB_BUTTON_HEIGHT) + (math.max(0, numTabs - 1) * TAB_PADDING) + 10 -- Add small buffer for top/bottom

local totalMainFramePixelHeight = HEADER_HEIGHT + totalTabsAreaPixelHeight

-- Main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0.25, 0, 0, totalMainFramePixelHeight) -- Adjusted height in pixels
mainFrame.Position = UDim2.new(0.01, 0, 0.25, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
mainFrame.Visible = true -- Ensure the main frame is visible by default

-- Corner for main frame
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Header with "PHCzack Mods" text
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT) -- Fixed pixel height
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 1, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "PHCzack Mods"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = header

-- Hide Menu Button (Mobile)
local hideButton = Instance.new("TextButton")
hideButton.Name = "HideButton"
hideButton.Size = UDim2.new(0.1, 0, 0.05, 0)
hideButton.Position = UDim2.new(0.01, 0, 0.01, 0)
hideButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
hideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
hideButton.Text = "☰"
hideButton.Font = Enum.Font.SourceSansBold
hideButton.TextSize = 20
hideButton.Parent = screenGui

local hideButtonCorner = Instance.new("UICorner")
hideButtonCorner.CornerRadius = UDim.new(0, 8)
hideButtonCorner.Parent = hideButton

-- Tabs Container
local tabsContainer = Instance.new("Frame")
tabsContainer.Name = "TabsContainer"
tabsContainer.Size = UDim2.new(0.3, 0, 0, totalTabsAreaPixelHeight) -- Adjusted height in pixels
tabsContainer.Position = UDim2.new(0, 0, 0, HEADER_HEIGHT) -- Starts after header
tabsContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
tabsContainer.BorderSizePixel = 0
tabsContainer.Parent = mainFrame

local tabsCorner = Instance.new("UICorner")
tabsCorner.CornerRadius = UDim.new(0, 8)
tabsCorner.Parent = tabsContainer

-- UIListLayout for tabsContainer
local tabListLayout = Instance.new("UIListLayout")
tabListLayout.Name = "TabListLayout"
tabListLayout.FillDirection = Enum.FillDirection.Vertical
tabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabListLayout.Padding = UDim.new(0, TAB_PADDING) -- 5 pixels of spacing between tabs
tabListLayout.Parent = tabsContainer

-- Content Container
local contentContainer = Instance.new("Frame")
contentContainer.Name = "ContentContainer"
contentContainer.Size = UDim2.new(0.7, 0, 0, totalTabsAreaPixelHeight) -- Adjusted height in pixels
contentContainer.Position = UDim2.new(0.3, 0, 0, HEADER_HEIGHT) -- Starts after header
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

-- New: Dropdown Popup Frame
local dropdownPopupFrame = Instance.new("Frame")
dropdownPopupFrame.Name = "DropdownPopup"
dropdownPopupFrame.Size = UDim2.new(0.3, 0, 0.4, 0) -- Example size, consider making this dynamic or fixed pixels
dropdownPopupFrame.Position = UDim2.new(0.35, 0, 0.3, 0) -- Example position (centered-ish)
dropdownPopupFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
dropdownPopupFrame.BackgroundTransparency = 0.1
dropdownPopupFrame.BorderSizePixel = 0
dropdownPopupFrame.Visible = false
dropdownPopupFrame.Parent = screenGui 

local dropdownPopupCorner = Instance.new("UICorner")
dropdownPopupCorner.CornerRadius = UDim.new(0, 8)
dropdownPopupCorner.Parent = dropdownPopupFrame

local popupTitle = Instance.new("TextLabel")
popupTitle.Name = "PopupTitle"
popupTitle.Size = UDim2.new(1, 0, 0.1, 0)
popupTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
popupTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
popupTitle.TextSize = 18
popupTitle.Font = Enum.Font.SourceSansBold
popupTitle.Text = "Select Items" -- Default title, will be updated
popupTitle.Parent = dropdownPopupFrame

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0.1, 0, 0.1, 0)
closeButton.Position = UDim2.new(0.9, 0, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Text = "X"
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 18
closeButton.Parent = dropdownPopupFrame

local popupScrollFrame = Instance.new("ScrollingFrame")
popupScrollFrame.Name = "PopupScrollFrame"
popupScrollFrame.Size = UDim2.new(1, 0, 0.9, 0)
popupScrollFrame.Position = UDim2.new(0, 0, 0.1, 0)
popupScrollFrame.BackgroundTransparency = 1
popupScrollFrame.ScrollBarThickness = 6
popupScrollFrame.Parent = dropdownPopupFrame

closeButton.MouseButton1Click:Connect(function()
    dropdownPopupFrame.Visible = false
end)

-- Function to populate and show the dropdown popup
local function populateAndShowDropdownPopup(selectedTableName, optionsList, titleText)
    -- Clear existing checkboxes
    for _, child in pairs(popupScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    popupTitle.Text = titleText -- Update popup title

    local currentY = 0
    for i, item in ipairs(optionsList) do
        local checkboxFrame = Instance.new("Frame")
        checkboxFrame.Size = UDim2.new(1, -10, 0, 25)
        checkboxFrame.Position = UDim2.new(0, 5, 0, currentY)
        checkboxFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        checkboxFrame.Parent = popupScrollFrame
        
        local checkboxCorner = Instance.new("UICorner")
        checkboxCorner.CornerRadius = UDim.new(0, 4)
        checkboxCorner.Parent = checkboxFrame
        
        local checkboxText = Instance.new("TextLabel")
        checkboxText.Size = UDim2.new(0.7, 0, 1, 0)
        checkboxText.Position = UDim2.new(0, 5, 0, 0)
        checkboxText.BackgroundTransparency = 1
        checkboxText.Text = item
        checkboxText.TextColor3 = Color3.fromRGB(255, 255, 255)
        checkboxText.TextXAlignment = Enum.TextXAlignment.Left
        checkboxText.Font = Enum.Font.SourceSans
        checkboxText.TextSize = 14
        checkboxText.Parent = checkboxFrame
        
        local checkboxButton = Instance.new("TextButton")
        checkboxButton.Size = UDim2.new(0.2, 0, 0.7, 0)
        checkboxButton.Position = UDim2.new(0.75, 0, 0.15, 0)
        checkboxButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        checkboxButton.Text = ""
        checkboxButton.Parent = checkboxFrame
        
        local checkboxCorner2 = Instance.new("UICorner")
        checkboxCorner2.CornerRadius = UDim.new(0, 4)
        checkboxCorner2.Parent = checkboxButton
        
        local checkboxState = Instance.new("Frame")
        checkboxState.Name = "CheckboxState"
        checkboxState.Size = UDim2.new(0.4, 0, 1, 0)
        checkboxState.Parent = checkboxButton
        
        local checkboxStateCorner = Instance.new("UICorner")
        checkboxStateCorner.CornerRadius = UDim.new(0, 4)
        checkboxStateCorner.Parent = checkboxState
        
        -- Set initial state of checkbox
        if getfenv()[selectedTableName][item] then
            checkboxState.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            checkboxState.Position = UDim2.new(0.6, 0, 0, 0)
        else
            checkboxState.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            checkboxState.Position = UDim2.new(0, 0, 0, 0)
        end

        checkboxButton.MouseButton1Click:Connect(function()
            getfenv()[selectedTableName][item] = not getfenv()[selectedTableName][item]
            if getfenv()[selectedTableName][item] then
                checkboxState.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
                checkboxState.Position = UDim2.new(0.6, 0, 0, 0)
            else
                checkboxState.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                checkboxState.Position = UDim2.new(0, 0, 0, 0)
            end
        end)
        
        currentY = currentY + 30 -- Increment for next item
    end

    popupScrollFrame.CanvasSize = UDim2.new(0, 0, 0, currentY)
    dropdownPopupFrame.Visible = true
end


-- Function to ensure character exists and is valid
local function ensureCharacter()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    return humanoid, character
end

-- Create Tab Function
local function createTab(tabName, tabOptions)
    -- Tab Button
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tabName .. "Tab"
    tabButton.Size = UDim2.new(1, 0, 0, TAB_BUTTON_HEIGHT) -- Set fixed pixel height for tabs
    -- Position is now handled by UIListLayout
    tabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabButton.Text = tabName
    tabButton.Font = Enum.Font.SourceSansBold
    tabButton.TextSize = 16
    tabButton.Parent = tabsContainer
    
    local tabButtonCorner = Instance.new("UICorner")
    tabButtonCorner.CornerRadius = UDim.new(0, 6)
    tabButtonCorner.Parent = tabButton
    
    -- Tab Content
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = tabName .. "Content"
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.Position = UDim2.new(0, 0, 0, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false
    tabContent.ScrollBarThickness = 5
    tabContent.CanvasSize = UDim2.new(0, 0, 0, #tabOptions * 40 + 20)
    tabContent.Parent = contentContainer
    
    -- Create options for this tab
    for i, option in ipairs(tabOptions) do
        if option.type == "toggle" then
            local optionFrame = Instance.new("Frame")
            optionFrame.Size = UDim2.new(0.9, 0, 0, 30)
            optionFrame.Position = UDim2.new(0.05, 0, 0, (i-1)*40 + 10)
            optionFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            optionFrame.Parent = tabContent
            
            local optionCorner = Instance.new("UICorner")
            optionCorner.CornerRadius = UDim.new(0, 6)
            optionCorner.Parent = optionFrame
            
            local optionText = Instance.new("TextLabel")
            optionText.Size = UDim2.new(0.7, 0, 1, 0)
            optionText.Position = UDim2.new(0, 5, 0, 0)
            optionText.BackgroundTransparency = 1
            optionText.Text = option.name
            optionText.TextColor3 = Color3.fromRGB(255, 255, 255)
            optionText.TextXAlignment = Enum.TextXAlignment.Left
            optionText.Font = Enum.Font.SourceSans
            optionText.TextSize = 16
            optionText.Parent = optionFrame
            
            local toggle = Instance.new("TextButton")
            toggle.Name = option.name .. "Toggle"
            toggle.Size = UDim2.new(0.2, 0, 0.7, 0)
            toggle.Position = UDim2.new(0.75, 0, 0.15, 0)
            toggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            toggle.Text = ""
            toggle.Parent = optionFrame
            
            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 6)
            toggleCorner.Parent = toggle
            
            local toggleState = Instance.new("Frame")
            toggleState.Name = "ToggleState"
            toggleState.Size = UDim2.new(0.4, 0, 1, 0)
            toggleState.Position = UDim2.new(0, 0, 0, 0)
            toggleState.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Default red for off
            toggleState.Parent = toggle

            local toggleStateCorner = Instance.new("UICorner")
            toggleStateCorner.CornerRadius = UDim.new(0, 6)
            toggleStateCorner.Parent = toggleState
            
            -- Toggle functionality
            local isToggled = false
            option.isToggled = isToggled 

            -- Add dropdown if this option has one
            if option.hasDropdown then
                -- Initialize selected items table
                local selectedTableName = ""
                local dropdownTitle = ""
                if option.name == "Buy Seeds" then
                    selectedTableName = "selectedSeeds"
                    dropdownTitle = "Select Seeds"
                elseif option.name == "Buy Gear" then
                    selectedTableName = "selectedGear"
                    dropdownTitle = "Select Gear"
                elseif option.name == "Buy Honey" then
                    selectedTableName = "selectedHoney"
                    dropdownTitle = "Select Honey Items"
                elseif option.name == "Auto Plant" then
                    selectedTableName = "selectedPlants"
                    dropdownTitle = "Select Plants"
                end

                if not getfenv()[selectedTableName] then
                    getfenv()[selectedTableName] = {}
                    for _, item in ipairs(option.dropdownOptions) do
                        getfenv()[selectedTableName][item] = true -- Default all items to selected
                    end
                end
                
                -- Create dropdown button (to open the separate popup)
                local dropdownButton = Instance.new("TextButton")
                dropdownButton.Name = "DropdownButton"
                dropdownButton.Size = UDim2.new(0.25, 0, 0.7, 0)
                dropdownButton.Position = UDim2.new(0.5, 0, 0.15, 0)
                dropdownButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                dropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                dropdownButton.Text = "Dropdown"
                dropdownButton.Font = Enum.Font.SourceSans
                dropdownButton.TextSize = 14
                dropdownButton.Parent = optionFrame
                
                local dropdownCorner = Instance.new("UICorner")
                dropdownCorner.CornerRadius = UDim.new(0, 6)
                dropdownCorner.Parent = dropdownButton
                
                -- Connect dropdown button to show the popup
                dropdownButton.MouseButton1Click:Connect(function()
                    populateAndShowDropdownPopup(selectedTableName, option.dropdownOptions, dropdownTitle)
                end)
            end
            
            toggle.MouseButton1Click:Connect(function()
                isToggled = not isToggled
                option.isToggled = isToggled -- Update stored state
                if isToggled then
                    toggleState.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- Green for on
                    toggleState.Position = UDim2.new(0.6, 0, 0, 0)
                    if option.callback then
                        option.callback(true)
                    end
                else
                    toggleState.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Red for off
                    toggleState.Position = UDim2.new(0, 0, 0, 0)
                    if option.callback then
                        option.callback(false)
                    end
                end
            end)
        elseif option.type == "slider" then
            warn("Slider type is no longer used in this script. Removing this section from UI.")
        end
    end
    
    -- Tab button functionality
    tabButton.MouseButton1Click:Connect(function()
        -- Hide all content
        for _, child in ipairs(contentContainer:GetChildren()) do
            if child:IsA("ScrollingFrame") then
                child.Visible = false
            end
        end
        
        -- Show this tab's content
        tabContent.Visible = true
        
        -- Highlight this tab
        for _, child in ipairs(tabsContainer:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            end
        end
        tabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end)
    
    -- Show first tab by default
    if #tabsContainer:GetChildren() == 2 then -- First tab (1 is the UIListLayout, 1 is the first button)
        tabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        tabContent.Visible = true
    end
end

--- ANTI-AFK FUNCTIONALITY ---

local antiAFK_enabled = false
local antiAFK_connection = nil

local function toggleAntiAFK(state)
    antiAFK_enabled = state
    if antiAFK_enabled then
        warn("Anti-AFK Enabled")
        -- Move the character slightly every few seconds to prevent AFK kick
        antiAFK_connection = RunService.Heartbeat:Connect(function()
            local humanoid, character = ensureCharacter()
            if humanoid and character and humanoid.Health > 0 then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    -- Move slightly in a random direction
                    local currentPos = rootPart.Position
                    local newPos = currentPos + Vector3.new(math.random() * 0.1 - 0.05, 0, math.random() * 0.1 - 0.05)
                    rootPart.CFrame = CFrame.new(newPos)
                end
            end
        end)
    else
        warn("Anti-AFK Disabled")
        if antiAFK_connection then
            antiAFK_connection:Disconnect()
            antiAFK_connection = nil
        end
    end
end

--- END ANTI-AFK FUNCTIONALITY ---


-- Handle character respawns
player.CharacterAdded:Connect(function(character)
    -- Reapply any active modifications when character respawns
    
    -- Reapply speed and jump power
    for _, tab in ipairs(tabs) do
        for _, option in ipairs(tab.options) do
            -- Ensure it's a toggle and it was previously on
            if option.type == "toggle" and option.isToggled then
                -- Reapply speed and jump power
                if option.name == "Speed (50)" or option.name == "Jump (200)" then
                     option.callback(true)
                end
            end
        end
    end

    -- Re-enable anti-AFK if it was active
    if antiAFK_enabled then
        toggleAntiAFK(true)
    end
end)

-- Create tabs
for _, tab in ipairs(tabs) do
    createTab(tab.name, tab.options)
end

-- Hide/show menu functionality
local isMenuVisible = true -- Assuming it starts visible
hideButton.MouseButton1Click:Connect(function()
    isMenuVisible = not isMenuVisible
    mainFrame.Visible = isMenuVisible
    -- Also hide the dropdown popup if the main menu is hidden
    if not isMenuVisible then
        dropdownPopupFrame.Visible = false
    end
end)

-- Mobile support: make UI draggable for mainFrame
local mainFrameDragging = false
local mainFrameDragInput, mainFrameDragStart, mainFrameStartPos

local function updateMainFrameInput(input)
    local delta = input.Position - mainFrameDragStart
    mainFrame.Position = UDim2.new(mainFrameStartPos.X.Scale, mainFrameStartPos.X.Offset + delta.X, 
                                  mainFrameStartPos.Y.Scale, mainFrameStartPos.Y.Offset + delta.Y)
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        mainFrameDragging = true
        mainFrameDragStart = input.Position
        mainFrameStartPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                mainFrameDragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        mainFrameDragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if mainFrameDragging and (input == mainFrameDragInput) then
        updateMainFrameInput(input)
    end
end)

-- Mobile support: make UI draggable for hideButton
local hideButtonDragging = false
local hideButtonDragInput, hideButtonDragStart, hideButtonStartPos

local function updateHideButtonInput(input)
    local delta = input.Position - hideButtonDragStart
    hideButton.Position = UDim2.new(hideButtonStartPos.X.Scale, hideButtonStartPos.X.Offset + delta.X, 
                                  hideButtonStartPos.Y.Scale, hideButtonStartPos.Y.Offset + delta.Y)
end

hideButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        hideButtonDragging = true
        hideButtonDragStart = input.Position
        hideButtonStartPos = hideButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                hideButtonDragging = false
            end
        end)
    end
end)

hideButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        hideButtonDragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if hideButtonDragging and (input == hideButtonDragInput) then
        updateHideButtonInput(input)
    end
end)

-- Mobile support: make UI draggable for dropdownPopupFrame
local dropdownPopupFrameDragging = false
local dropdownPopupFrameDragInput, dropdownPopupFrameDragStart, dropdownPopupFrameStartPos

local function updateDropdownPopupFrameInput(input)
    local delta = input.Position - dropdownPopupFrameDragStart
    dropdownPopupFrame.Position = UDim2.new(dropdownPopupFrameStartPos.X.Scale, dropdownPopupFrameStartPos.X.Offset + delta.X, 
                                  dropdownPopupFrameStartPos.Y.Scale, dropdownPopupFrameStartPos.Y.Offset + delta.Y)
end

dropdownPopupFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dropdownPopupFrameDragging = true
        dropdownPopupFrameDragStart = input.Position
        dropdownPopupFrameStartPos = dropdownPopupFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dropdownPopupFrameDragging = false
            end
        end)
    end
end)

dropdownPopupFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        dropdownPopupFrameDragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dropdownPopupFrameDragging and (input == dropdownPopupFrameDragInput) then
        updateDropdownPopupFrameInput(input)
    end
end)
