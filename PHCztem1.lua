-- PHCz Farming Script GUI Library
-- Modern Roblox GUI with comprehensive farming features

local GUI = {}
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configuration
local CONFIG = {
    THEME = {
        PRIMARY = Color3.fromRGB(64, 128, 255),
        SECONDARY = Color3.fromRGB(45, 45, 45),
        BACKGROUND = Color3.fromRGB(25, 25, 25),
        TEXT = Color3.fromRGB(255, 255, 255),
        SUCCESS = Color3.fromRGB(76, 175, 80),
        WARNING = Color3.fromRGB(255, 193, 7),
        DANGER = Color3.fromRGB(244, 67, 54)
    },
    ANIMATIONS = {
        SPEED = 0.3,
        EASING = Enum.EasingStyle.Quad,
        DIRECTION = Enum.EasingDirection.Out
    }
}

-- Global Variables
local GlobalState = {
    -- Farm Variables
    Sellinv = false,
    running = false,
    FeedonHand = false,
    FeedAll = false,
    running1 = false,
    SellAllFruit = false,
    AutoHatch = false,
    running2 = false,
    AutoBuySeeds = false,
    AutoBuyGears = false,
    runningBuySeeds = false,
    runningBuyGears = false,
    
    -- ESP Variables
    PlantESP = false,
    selectedPlant = nil,
    espObjects = {},
    allFilteredPlants = {},
    
    -- Manual Plant Filter Variables
    manualPlantFilters = {},
    searchText = ""
}

-- Data Tables
local DATA = {
    availablePlantTypes = {
        "Zenflare", "SugarApple", "Carrot", "Strawberry", "Blueberry", "Orange Tulip", 
        "Tomato", "Corn", "Daffodil", "Watermelon", "Pumpkin", "Apple", "Bamboo", 
        "Coconut", "Cactus", "Dragon Fruit", "Mango", "Grape", "Mushroom", "Pepper", 
        "Cacao", "Beanstalk", "Ember Lily", "Sugar Apple", "Burning Bud", 
        "Giant Pinecone", "Romanesco"
    },
    
    seedTypes = {
        "Carrot", "Strawberry", "Blueberry", "Orange Tulip", "Tomato", "Corn", "Daffodil", 
        "Watermelon", "Pumpkin", "Apple", "Bamboo", "Coconut", "Cactus", "Dragon Fruit", 
        "Mango", "Grape", "Mushroom", "Pepper", "Cacao", "Beanstalk", "Ember Lily", 
        "Sugar Apple", "Burning Bud", "Giant Pinecone", "Romanesco"
    },
    
    gearTypes = {
        "Watering Can", "Trowel", "Recall Wrench", "Trading Ticket", "Basic Sprinkler", 
        "Advanced Sprinkler", "Godly Sprinkler", "Lightning Rod", "Medium Toy", 
        "Magnifying Glass", "Medium Treat", "Master Sprinkler", "Grandmaster Sprinkler", 
        "Favorite Tool", "Harvest Tool", "Friendship Pot", "Tanning Mirror", 
        "Cleaning Spray", "Levelup Lollipop"
    },
    
    teleportLocations = {
        {name = "Seed Shop", position = Vector3.new(86.58, 2.76, -27.00)},
        {name = "Sell Shop", position = Vector3.new(86.58, 2.76, 0.42)},
        {name = "Gear Shop", position = Vector3.new(-284.41, 5.76, -32.97)},
        {name = "Cosmetics Shop", position = Vector3.new(-284.93, 2.99, -14.60)},
        {name = "Egg Shop", position = Vector3.new(-283.50, 2.99, 6.02)},
        {name = "Honey Shop", position = Vector3.new(-99.03, 4.00, -3.47)}
    }
}

-- Utility Functions
local function createTween(instance, properties, duration, easingStyle, easingDirection)
    duration = duration or CONFIG.ANIMATIONS.SPEED
    easingStyle = easingStyle or CONFIG.ANIMATIONS.EASING
    easingDirection = easingDirection or CONFIG.ANIMATIONS.DIRECTION
    
    local tween = TweenService:Create(instance, TweenInfo.new(duration, easingStyle, easingDirection), properties)
    return tween
end

local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function createStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or CONFIG.THEME.PRIMARY
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

-- Core Functions
local function feedItems()
    while (GlobalState.FeedonHand or GlobalState.FeedAll or GlobalState.Sellinv or GlobalState.SellAllFruit) and task.wait(0.5) do
        local args = {}
        if GlobalState.FeedonHand then
            ReplicatedStorage:WaitForChild("GameEvents", 9e9)
                           :WaitForChild("BeanstalkRESubmitHeldPlant", 9e9):FireServer(unpack(args))
        end
        if GlobalState.FeedAll then
            ReplicatedStorage:WaitForChild("GameEvents", 9e9)
                           :WaitForChild("BeanstalkRESubmitAllPlant", 9e9):FireServer(unpack(args))
        end
        if GlobalState.Sellinv then 
            ReplicatedStorage:WaitForChild("GameEvents", 9e9)
                           :WaitForChild("Sell_Item", 9e9):FireServer(unpack(args))
        end
        if GlobalState.SellAllFruit then 
            ReplicatedStorage:WaitForChild("GameEvents", 9e9)
                           :WaitForChild("Sell_Inventory", 9e9):FireServer(unpack(args))
        end
    end
    GlobalState.running1 = false
end

local function findEgg()
    for _, farmSection in ipairs(workspace.Farm:GetChildren()) do
        if farmSection:FindFirstChild("Important") then
            local objectsPhysical = farmSection.Important:FindFirstChild("Objects_Physical")
            if objectsPhysical then
                for _, obj in ipairs(objectsPhysical:GetChildren()) do
                    if (obj:IsA("BasePart") or obj:IsA("Model")) and string.find(obj.Name:lower(), "egg") then
                        if not obj:FindFirstChild("PetID") and not obj:FindFirstChild("PetData") and not obj:GetAttribute("PetGUID") then
                            return obj
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function hatchEggs()
    while GlobalState.AutoHatch and task.wait(0.5) do
        local egg = findEgg()
        if egg then
            ReplicatedStorage:WaitForChild("GameEvents", 9e9)
                           :WaitForChild("PetEggService", 9e9):FireServer("HatchPet", egg)
            print("Hatching egg:", egg.Name)
        end
    end
    GlobalState.running2 = false
end

local function buyAllSeeds()
    while GlobalState.AutoBuySeeds and task.wait(0.5) do
        for _, seedType in ipairs(DATA.seedTypes) do
            if not GlobalState.AutoBuySeeds then break end
            local args = { [1] = seedType }
            ReplicatedStorage:WaitForChild("GameEvents", 9e9)
                           :WaitForChild("BuySeedStock", 9e9):FireServer(unpack(args))
            print("Purchased:", seedType)
        end
    end
    GlobalState.runningBuySeeds = false
end

local function buyAllGears()
    while GlobalState.AutoBuyGears and task.wait(0.5) do
        for _, gearType in ipairs(DATA.gearTypes) do
            if not GlobalState.AutoBuyGears then break end
            local args = { [1] = gearType }
            ReplicatedStorage:WaitForChild("GameEvents", 9e9)
                           :WaitForChild("BuyGearStock", 9e9):FireServer(unpack(args))
            print("Purchased:", gearType)
        end
    end
    GlobalState.runningBuyGears = false
end

local function teleportPlayer(position)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(position)
        print("Teleported to:", position)
    end
end

-- ESP Functions
local function clearESP()
    for _, obj in pairs(GlobalState.espObjects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    GlobalState.espObjects = {}
end

local function createESP(plant)
    if not plant or not plant.Parent then return end
    clearESP()
    
    local hasActiveFilters = false
    for filterName, isActive in pairs(GlobalState.manualPlantFilters) do
        if isActive then
            hasActiveFilters = true
            break
        end
    end
    
    if hasActiveFilters then
        local plantsToHighlight = {}
        local farm = workspace:FindFirstChild("Farm")
        if farm then
            local farmSection = farm:FindFirstChild("Farm")
            if farmSection then
                local important = farmSection:FindFirstChild("Important")
                if important then
                    local plantsPhysical = important:FindFirstChild("Plants_Physical")
                    if plantsPhysical then
                        for _, plantModel in ipairs(plantsPhysical:GetChildren()) do
                            if plantModel:IsA("Model") then
                                for filterName, isActive in pairs(GlobalState.manualPlantFilters) do
                                    if isActive and string.find(plantModel.Name:lower(), filterName:lower()) then
                                        table.insert(plantsToHighlight, plantModel)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        for _, plantModel in ipairs(plantsToHighlight) do
            local rootPart = plantModel:FindFirstChild("Main") or plantModel:FindFirstChildWhichIsA("BasePart")
            if rootPart then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "PlantESP_Billboard"
                billboard.Parent = rootPart
                billboard.Size = UDim2.new(0, 80, 0, 20)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                billboard.LightInfluence = 0
                billboard.MaxDistance = math.huge
                
                local frame = Instance.new("Frame")
                frame.Parent = billboard
                frame.Size = UDim2.new(1, 0, 1, 0)
                frame.BackgroundColor3 = CONFIG.THEME.BACKGROUND
                frame.BackgroundTransparency = 0.2
                frame.BorderSizePixel = 0
                createCorner(frame, 4)
                
                local label = Instance.new("TextLabel")
                label.Parent = frame
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = plantModel.Name
                label.TextColor3 = CONFIG.THEME.SUCCESS
                label.TextScaled = true
                label.Font = Enum.Font.GothamBold
                label.TextStrokeTransparency = 0
                label.TextStrokeColor3 = Color3.new(0, 0, 0)
                
                table.insert(GlobalState.espObjects, billboard)
            end
        end
    else
        if plant then
            local rootPart = plant:FindFirstChild("Main") or plant:FindFirstChildWhichIsA("BasePart")
            if not rootPart then return end
            
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "PlantESP_Billboard"
            billboard.Parent = rootPart
            billboard.Size = UDim2.new(0, 80, 0, 20)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true
            billboard.LightInfluence = 0
            billboard.MaxDistance = math.huge
            
            local frame = Instance.new("Frame")
            frame.Parent = billboard
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundColor3 = CONFIG.THEME.BACKGROUND
            frame.BackgroundTransparency = 0.2
            frame.BorderSizePixel = 0
            createCorner(frame, 4)
            
            local label = Instance.new("TextLabel")
            label.Parent = frame
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = plant.Name
            label.TextColor3 = CONFIG.THEME.SUCCESS
            label.TextScaled = true
            label.Font = Enum.Font.GothamBold
            label.TextStrokeTransparency = 0
            label.TextStrokeColor3 = Color3.new(0, 0, 0)
            
            table.insert(GlobalState.espObjects, billboard)
        end
    end
end

local function updateESP()
    if GlobalState.PlantESP and GlobalState.selectedPlant then
        createESP(GlobalState.selectedPlant)
    else
        clearESP()
    end
end

-- GUI Creation Functions
function GUI:CreateWindow(title)
    local Window = {}
    Window.Tabs = {}
    
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PHCzScript"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.BackgroundColor3 = CONFIG.THEME.BACKGROUND
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    createCorner(mainFrame, 12)
    createStroke(mainFrame, CONFIG.THEME.PRIMARY, 2)
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = CONFIG.THEME.PRIMARY
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    createCorner(titleBar, 12)
    
    -- Title Label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "PHCz Script"
    titleLabel.TextColor3 = CONFIG.THEME.TEXT
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.BackgroundColor3 = CONFIG.THEME.DANGER
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = CONFIG.THEME.TEXT
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar
    createCorner(closeButton, 6)
    
    closeButton.MouseButton1Click:Connect(function()
        local closeTween = createTween(mainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        closeTween:Play()
        closeTween.Completed:Connect(function()
            screenGui:Destroy()
        end)
    end)
    
    -- Minimize Button
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0, 30, 0, 30)
    minimizeButton.Position = UDim2.new(1, -75, 0, 5)
    minimizeButton.BackgroundColor3 = CONFIG.THEME.WARNING
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Text = "−"
    minimizeButton.TextColor3 = CONFIG.THEME.TEXT
    minimizeButton.TextScaled = true
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.Parent = titleBar
    createCorner(minimizeButton, 6)
    
    local isMinimized = false
    minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local targetSize = isMinimized and UDim2.new(0, 500, 0, 40) or UDim2.new(0, 500, 0, 400)
        local minimizeTween = createTween(mainFrame, {Size = targetSize}, 0.3)
        minimizeTween:Play()
    end)
    
    -- Tab Container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 120, 1, -50)
    tabContainer.Position = UDim2.new(0, 10, 0, 50)
    tabContainer.BackgroundColor3 = CONFIG.THEME.SECONDARY
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame
    createCorner(tabContainer, 8)
    
    -- Content Container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -150, 1, -50)
    contentContainer.Position = UDim2.new(0, 140, 0, 50)
    contentContainer.BackgroundTransparency = 1
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = mainFrame
    
    -- Drag functionality
    local dragToggle = nil
    local dragSpeed = 0.25
    local dragStart = nil
    local startPos = nil
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                  startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        createTween(mainFrame, {Position = position}, dragSpeed):Play()
    end
    
    titleBar.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then 
            dragToggle = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragToggle then
                updateInput(input)
            end
        end
    end)
    
    -- Window Methods
    function Window:CreateTab(name)
        local Tab = {}
        Tab.Elements = {}
        
        -- Tab Button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = name .. "Tab"
        tabButton.Size = UDim2.new(1, -10, 0, 30)
        tabButton.Position = UDim2.new(0, 5, 0, 5 + (#Window.Tabs * 35))
        tabButton.BackgroundColor3 = CONFIG.THEME.BACKGROUND
        tabButton.BorderSizePixel = 0
        tabButton.Text = name
        tabButton.TextColor3 = CONFIG.THEME.TEXT
        tabButton.TextScaled = true
        tabButton.Font = Enum.Font.Gotham
        tabButton.Parent = tabContainer
        createCorner(tabButton, 6)
        
        -- Tab Content
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = name .. "Content"
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.Position = UDim2.new(0, 0, 0, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = CONFIG.THEME.PRIMARY
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.Visible = false
        tabContent.Parent = contentContainer
        
        -- Tab switching
        tabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
                tab.Button.BackgroundColor3 = CONFIG.THEME.BACKGROUND
            end
            tabContent.Visible = true
            tabButton.BackgroundColor3 = CONFIG.THEME.PRIMARY
        end)
        
        -- Auto-select first tab
        if #Window.Tabs == 0 then
            tabContent.Visible = true
            tabButton.BackgroundColor3 = CONFIG.THEME.PRIMARY
        end
        
        local elementY = 0
        
        -- Tab Methods
        function Tab:Toggle(options)
            local toggle = Instance.new("Frame")
            toggle.Name = options.Name .. "Toggle"
            toggle.Size = UDim2.new(1, -20, 0, 40)
            toggle.Position = UDim2.new(0, 10, 0, elementY)
            toggle.BackgroundColor3 = CONFIG.THEME.SECONDARY
            toggle.BorderSizePixel = 0
            toggle.Parent = tabContent
            createCorner(toggle, 8)
            
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1, -60, 1, 0)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = options.Name
            label.TextColor3 = CONFIG.THEME.TEXT
            label.TextScaled = true
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = toggle
            
            local button = Instance.new("TextButton")
            button.Name = "Button"
            button.Size = UDim2.new(0, 40, 0, 25)
            button.Position = UDim2.new(1, -50, 0.5, -12.5)
            button.BackgroundColor3 = options.StartingState and CONFIG.THEME.SUCCESS or CONFIG.THEME.DANGER
            button.BorderSizePixel = 0
            button.Text = options.StartingState and "ON" or "OFF"
            button.TextColor3 = CONFIG.THEME.TEXT
            button.TextScaled = true
            button.Font = Enum.Font.GothamBold
            button.Parent = toggle
            createCorner(button, 6)
            
            local state = options.StartingState or false
            
            button.MouseButton1Click:Connect(function()
                state = not state
                button.Text = state and "ON" or "OFF"
                button.BackgroundColor3 = state and CONFIG.THEME.SUCCESS or CONFIG.THEME.DANGER
                
                local buttonTween = createTween(button, {Size = UDim2.new(0, 45, 0, 30)}, 0.1)
                buttonTween:Play()
                buttonTween.Completed:Connect(function()
                    createTween(button, {Size = UDim2.new(0, 40, 0, 25)}, 0.1):Play()
                end)
                
                if options.Callback then
                    options.Callback(state)
                end
            end)
            
            elementY = elementY + 50
            tabContent.CanvasSize = UDim2.new(0, 0, 0, elementY)
        end
        
        function Tab:Button(options)
            local button = Instance.new("TextButton")
            button.Name = options.Name .. "Button"
            button.Size = UDim2.new(1, -20, 0, 40)
            button.Position = UDim2.new(0, 10, 0, elementY)
            button.BackgroundColor3 = CONFIG.THEME.PRIMARY
            button.BorderSizePixel = 0
            button.Text = options.Name
            button.TextColor3 = CONFIG.THEME.TEXT
            button.TextScaled = true
            button.Font = Enum.Font.GothamBold
            button.Parent = tabContent
            createCorner(button, 8)
            
            button.MouseButton1Click:Connect(function()
                local buttonTween = createTween(button, {Size = UDim2.new(1, -15, 0, 45)}, 0.1)
                buttonTween:Play()
                buttonTween.Completed:Connect(function()
                    createTween(button, {Size = UDim2.new(1, -20, 0, 40)}, 0.1):Play()
                end)
                
                if options.Callback then
                    options.Callback()
                end
            end)
            
            elementY = elementY + 50
            tabContent.CanvasSize = UDim2.new(0, 0, 0, elementY)
        end
        
        function Tab:Dropdown(options)
            local dropdown = {}
            dropdown.Options = options.Options or {}
            
            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Name = options.Name .. "Dropdown"
            dropdownFrame.Size = UDim2.new(1, -20, 0, 40)
            dropdownFrame.Position = UDim2.new(0, 10, 0, elementY)
            dropdownFrame.BackgroundColor3 = CONFIG.THEME.SECONDARY
            dropdownFrame.BorderSizePixel = 0
            dropdownFrame.Parent = tabContent
            createCorner(dropdownFrame, 8)
            
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1, -30, 1, 0)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = options.Name
            label.TextColor3 = CONFIG.THEME.TEXT
            label.TextScaled = true
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = dropdownFrame
            
            local dropButton = Instance.new("TextButton")
            dropButton.Name = "DropButton"
            dropButton.Size = UDim2.new(0, 20, 0, 20)
            dropButton.Position = UDim2.new(1, -30, 0.5, -10)
            dropButton.BackgroundColor3 = CONFIG.THEME.PRIMARY
            dropButton.BorderSizePixel = 0
            dropButton.Text = "▼"
            dropButton.TextColor3 = CONFIG.THEME.TEXT
            dropButton.TextScaled = true
            dropButton.Font = Enum.Font.GothamBold
            dropButton.Parent = dropdownFrame
            createCorner(dropButton, 4)
            
            local optionsFrame = Instance.new("Frame")
            optionsFrame.Name = "OptionsFrame"
            optionsFrame.Size = UDim2.new(1, 0, 0, 0)
            optionsFrame.Position = UDim2.new(0, 0, 1, 2)
            optionsFrame.BackgroundColor3 = CONFIG.THEME.BACKGROUND
            optionsFrame.BorderSizePixel = 0
            optionsFrame.Visible = false
            optionsFrame.Parent = dropdownFrame
            createCorner(optionsFrame, 6)
            
            local optionsScroll = Instance.new("ScrollingFrame")
            optionsScroll.Name = "OptionsScroll"
            optionsScroll.Size = UDim2.new(1, 0, 1, 0)
            optionsScroll.Position = UDim2.new(0, 0, 0, 0)
            optionsScroll.BackgroundTransparency = 1
            optionsScroll.BorderSizePixel = 0
            optionsScroll.ScrollBarThickness = 2
            optionsScroll.ScrollBarImageColor3 = CONFIG.THEME.PRIMARY
            optionsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            optionsScroll.Parent = optionsFrame
            
            local isOpen = false
            
            dropButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                dropButton.Text = isOpen and "▲" or "▼"
                
                if isOpen then
                    optionsFrame.Visible = true
                    local targetHeight = math.min(#dropdown.Options * 30, 150)
                    optionsFrame.Size = UDim2.new(1, 0, 0, targetHeight)
                    optionsScroll.CanvasSize = UDim2.new(0, 0, 0, #dropdown.Options * 30)
                else
                    optionsFrame.Visible = false
                    optionsFrame.Size = UDim2.new(1, 0, 0, 0)
                end
            end)
            
            function dropdown:Refresh(newOptions)
                dropdown.Options = newOptions or {}
                
                -- Clear existing options
                for _, child in ipairs(optionsScroll:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                
                -- Create new options
                for i, option in ipairs(dropdown.Options) do
                    local optionButton = Instance.new("TextButton")
                    optionButton.Name = "Option" .. i
                    optionButton.Size = UDim2.new(1, -4, 0, 28)
                    optionButton.Position = UDim2.new(0, 2, 0, (i-1) * 30 + 1)
                    optionButton.BackgroundColor3 = CONFIG.THEME.SECONDARY
                    optionButton.BorderSizePixel = 0
                    optionButton.Text = option
                    optionButton.TextColor3 = CONFIG.THEME.TEXT
                    optionButton.TextScaled = true
                    optionButton.Font = Enum.Font.Gotham
                    optionButton.Parent = optionsScroll
                    createCorner(optionButton, 4)
                    
                    optionButton.MouseButton1Click:Connect(function()
                        label.Text = options.Name .. ": " .. option
                        isOpen = false
                        dropButton.Text = "▼"
                        optionsFrame.Visible = false
                        optionsFrame.Size = UDim2.new(1, 0, 0, 0)
                        
                        if options.Callback then
                            options.Callback(option)
                        end
                    end)
                end
                
                optionsScroll.CanvasSize = UDim2.new(0, 0, 0, #dropdown.Options * 30)
            end
            
            -- Initialize dropdown
            dropdown:Refresh(dropdown.Options)
            
            elementY = elementY + 50
            tabContent.CanvasSize = UDim2.new(0, 0, 0, elementY)
            
            return dropdown
        end
        
        function Tab:Textbox(options)
            local textboxFrame = Instance.new("Frame")
            textboxFrame.Name = options.Name .. "Textbox"
            textboxFrame.Size = UDim2.new(1, -20, 0, 40)
            textboxFrame.Position = UDim2.new(0, 10, 0, elementY)
            textboxFrame.BackgroundColor3 = CONFIG.THEME.SECONDARY
            textboxFrame.BorderSizePixel = 0
            textboxFrame.Parent = tabContent
            createCorner(textboxFrame, 8)
            
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(0.4, -5, 1, 0)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = options.Name
            label.TextColor3 = CONFIG.THEME.TEXT
            label.TextScaled = true
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = textboxFrame
            
            local textBox = Instance.new("TextBox")
            textBox.Name = "TextBox"
            textBox.Size = UDim2.new(0.6, -10, 0, 25)
            textBox.Position = UDim2.new(0.4, 5, 0.5, -12.5)
            textBox.BackgroundColor3 = CONFIG.THEME.BACKGROUND
            textBox.BorderSizePixel = 0
            textBox.Text = ""
            textBox.PlaceholderText = options.PlaceholderText or "Enter text..."
            textBox.TextColor3 = CONFIG.THEME.TEXT
            textBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
            textBox.TextScaled = true
            textBox.Font = Enum.Font.Gotham
            textBox.Parent = textboxFrame
            createCorner(textBox, 6)
            createStroke(textBox, CONFIG.THEME.PRIMARY, 1)
            
            textBox.FocusLost:Connect(function(enterPressed)
                if enterPressed and options.Callback then
                    options.Callback(textBox.Text)
                end
            end)
            
            elementY = elementY + 50
            tabContent.CanvasSize = UDim2.new(0, 0, 0, elementY)
        end
        
        Window.Tabs[name] = {
            Button = tabButton,
            Content = tabContent,
            Tab = Tab
        }
        
        return Tab
    end
    
    return Window
end

-- Initialize the main script
local function initializeScript()
    local Window = GUI:CreateWindow("PHCz Farming Script")
    
    -- Create Tabs
    local FarmTab = Window:CreateTab("Farm")
    local EventTab = Window:CreateTab("Event") 
    local EggTab = Window:CreateTab("Eggs")
    local TeleportTab = Window:CreateTab("Teleport")
    local ScannerTab = Window:CreateTab("Plant Scanner")
    
    -- Farm Tab Elements
    FarmTab:Toggle{
        Name = "Sell on Hand",
        StartingState = false,
        Callback = function(state)
            GlobalState.Sellinv = state
            print("Sell inv on Hand:", state)
            if (state or GlobalState.SellAllFruit or GlobalState.FeedonHand or GlobalState.FeedAll) and not GlobalState.running1 then
                GlobalState.running1 = true
                task.spawn(feedItems)
            end
        end
    }
    
    FarmTab:Toggle{
        Name = "Sell All Fruit",
        StartingState = false,
        Callback = function(state)
            GlobalState.SellAllFruit = state
            print("Sell All Fruit:", state)
            if (state or GlobalState.Sellinv or GlobalState.FeedonHand or GlobalState.FeedAll) and not GlobalState.running1 then
                GlobalState.running1 = true
                task.spawn(feedItems)
            end
        end
    }
    
    FarmTab:Toggle{
        Name = "Auto Buy All Seeds",
        StartingState = false,
        Callback = function(state)
            GlobalState.AutoBuySeeds = state
            if state and not GlobalState.runningBuySeeds then
                GlobalState.runningBuySeeds = true
                task.spawn(buyAllSeeds)
            end
        end
    }
    
    FarmTab:Toggle{
        Name = "Auto Buy All Gears",
        StartingState = false,
        Callback = function(state)
            GlobalState.AutoBuyGears = state
            if state and not GlobalState.runningBuyGears then
                GlobalState.runningBuyGears = true
                task.spawn(buyAllGears)
            end
        end
    }
    
    -- Event Tab Elements
    EventTab:Toggle{
        Name = "Feed on Hand",
        StartingState = false,
        Callback = function(state)
            GlobalState.FeedonHand = state
            print("On Hand Feeded:", state)
            if (state or GlobalState.FeedAll or GlobalState.Sellinv or GlobalState.SellAllFruit) and not GlobalState.running1 then
                GlobalState.running1 = true
                task.spawn(feedItems)
            end
        end
    }
    
    EventTab:Toggle{
        Name = "Feed All",
        StartingState = false,
        Callback = function(state)
            GlobalState.FeedAll = state
            print("All Feeded:", state)
            if (state or GlobalState.FeedonHand or GlobalState.Sellinv or GlobalState.SellAllFruit) and not GlobalState.running1 then
                GlobalState.running1 = true
                task.spawn(feedItems)
            end
        end
    }
    
    -- Egg Tab Elements
    EggTab:Toggle{
        Name = "Auto Hatch Eggs",
        StartingState = false,
        Callback = function(state)
            GlobalState.AutoHatch = state
            print("Auto Hatch:", state)
            if state and not GlobalState.running2 then
                GlobalState.running2 = true
                task.spawn(hatchEggs)
            end
        end
    }
    
    -- Teleport Tab Elements
    for _, location in ipairs(DATA.teleportLocations) do
        TeleportTab:Button{
            Name = location.name,
            Callback = function()
                teleportPlayer(location.position)
            end
        }
    end
    
    -- Plant Scanner Tab Elements
    local plantsDropdown
    local plantFilterDropdown
    local lastScanTime = 0
    local scanCooldown = 5
    
    -- Helper functions for plant scanning
    local function getFilteredPlantOptions()
        local filtered = {}
        for _, plantType in ipairs(DATA.availablePlantTypes) do
            if GlobalState.searchText == "" or string.find(plantType:lower(), GlobalState.searchText:lower()) then
                local status = GlobalState.manualPlantFilters[plantType] and " ✓" or ""
                table.insert(filtered, plantType .. status)
            end
        end
        return filtered
    end
    
    local function getSelectedFiltersText()
        local selected = {}
        for plantType, isSelected in pairs(GlobalState.manualPlantFilters) do
            if isSelected then
                table.insert(selected, plantType)
            end
        end
        if #selected == 0 then
            return "No filters selected"
        elseif #selected <= 3 then
            return table.concat(selected, ", ")
        else
            return selected[1] .. ", " .. selected[2] .. " (+" .. (#selected - 2) .. " more)"
        end
    end
    
    local function scanPlants()
        local plants = {}
        local farm = workspace:FindFirstChild("Farm")
        if not farm then return plants end
        
        local farmSection = farm:FindFirstChild("Farm")
        if not farmSection then return plants end
        
        local important = farmSection:FindFirstChild("Important")
        if not important then return plants end
        
        local plantsPhysical = important:FindFirstChild("Plants_Physical")
        if not plantsPhysical then return plants end
        
        for _, plant in ipairs(plantsPhysical:GetChildren()) do
            if plant:IsA("Model") then
                local shouldInclude = true
                local hasActiveFilters = false
                
                for filterName, isActive in pairs(GlobalState.manualPlantFilters) do
                    if isActive then
                        hasActiveFilters = true
                        break
                    end
                end
                
                if hasActiveFilters then
                    shouldInclude = false
                    for filterName, isActive in pairs(GlobalState.manualPlantFilters) do
                        if isActive and string.find(plant.Name:lower(), filterName:lower()) then
                            shouldInclude = true
                            break
                        end
                    end
                end
                
                if shouldInclude then
                    local rootPart = plant:FindFirstChild("Main") or plant:FindFirstChildWhichIsA("BasePart")
                    local position = rootPart and rootPart.Position or Vector3.new(0, 0, 0)
                    local posString = string.format("(%d, %d, %d)", 
                                                  math.floor(position.X), 
                                                  math.floor(position.Y), 
                                                  math.floor(position.Z))
                    
                    table.insert(plants, {
                        name = plant.Name.." "..posString,
                        model = plant,
                        position = position
                    })
                end
            end
        end
        
        return plants
    end
    
    -- Plant Scanner Elements
    ScannerTab:Toggle{
        Name = "Plant ESP",
        StartingState = false,
        Callback = function(state)
            GlobalState.PlantESP = state
            print("Plant ESP:", state)
            updateESP()
        end
    }
    
    ScannerTab:Textbox{
        Name = "Search Plants",
        PlaceholderText = "Type to search...",
        Callback = function(text)
            GlobalState.searchText = text
            if plantFilterDropdown then
                local filteredOptions = getFilteredPlantOptions()
                plantFilterDropdown:Refresh(filteredOptions)
            end
        end
    }
    
    plantFilterDropdown = ScannerTab:Dropdown{
        Name = "Plant Filters",
        Options = getFilteredPlantOptions(),
        Callback = function(selected)
            local plantName = selected:gsub(" ✓", "")
            
            if GlobalState.manualPlantFilters[plantName] == nil then
                GlobalState.manualPlantFilters[plantName] = true
            else
                GlobalState.manualPlantFilters[plantName] = not GlobalState.manualPlantFilters[plantName]
            end
            
            print("Filter toggled:", plantName, "=", GlobalState.manualPlantFilters[plantName])
            
            local filteredOptions = getFilteredPlantOptions()
            plantFilterDropdown:Refresh(filteredOptions)
            
            if GlobalState.PlantESP then
                updateESP()
            end
        end
    }
    
    ScannerTab:Button{
        Name = "Clear All Filters",
        Callback = function()
            GlobalState.manualPlantFilters = {}
            print("All plant filters cleared")
            
            if plantFilterDropdown then
                local filteredOptions = getFilteredPlantOptions()
                plantFilterDropdown:Refresh(filteredOptions)
            end
            
            if GlobalState.PlantESP then
                updateESP()
            end
        end
    }
    
    ScannerTab:Button{
        Name = "Scan Plants",
        Callback = function()
            if os.time() - lastScanTime < scanCooldown then
                print(string.format("Please wait %d more seconds before scanning again", 
                      scanCooldown - (os.time() - lastScanTime)))
                return
            end
            
            lastScanTime = os.time()
            local plants = scanPlants()
            
            local options = {}
            for i, plant in ipairs(plants) do
                table.insert(options, plant.name)
            end
            
            if #options == 0 then
                table.insert(options, "No plants found!")
            end
            
            if plantsDropdown then
                plantsDropdown:Refresh(options)
            else
                plantsDropdown = ScannerTab:Dropdown{
                    Name = "Select Plant",
                    Options = options,
                    Callback = function(selected)
                        for _, plant in ipairs(plants) do
                            if plant.name == selected then
                                GlobalState.selectedPlant = plant.model
                                updateESP()
                                
                                local char = player.Character
                                if char and char:FindFirstChild("HumanoidRootPart") then
                                    char.HumanoidRootPart.CFrame = CFrame.new(plant.position + Vector3.new(0, 5, 0))
                                    print("Teleported to:", plant.name)
                                end
                                break
                            end
                        end
                    end
                }
            end
            
            print(string.format("Found %d plants", #options))
        end
    }
    
    -- Auto-scan every 30 seconds
    task.spawn(function()
        while task.wait(30) do
            if plantsDropdown then
                local plants = scanPlants()
                local options = {}
                for i, plant in ipairs(plants) do
                    table.insert(options, plant.name)
                end
                if #options > 0 then
                    plantsDropdown:Refresh(options)
                end
            end
        end
    end)
    
    -- Cleanup on script end
    Players.PlayerRemoving:Connect(function(playerLeaving)
        if playerLeaving == player then
            clearESP()
        end
    end)
    
    print("PHCz Farming Script Loaded Successfully!")
end

-- Auto-initialize when the module is loaded
initializeScript()

return GUI
