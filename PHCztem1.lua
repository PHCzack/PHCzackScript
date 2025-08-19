--[[
    UI Library ModuleScript
    Author: YourName
    Version: 1.0.0

    Instructions:
    1. Place this script inside a ModuleScript in ReplicatedStorage.
    2. Name the ModuleScript something like "UILibrary".
    3. Require this module from a LocalScript to create your UI.
]]

local library = {}
local GUI = {}

--// SERVICES
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// CONFIGURATION
local UI_CONFIG = {
    ToggleKey = Enum.KeyCode.RightControl, -- Key to hide/show the UI
    AccentColor = Color3.fromRGB(70, 130, 180),
    BackgroundColor = Color3.fromRGB(30, 30, 30),
    ContainerColor = Color3.fromRGB(45, 45, 45),
    TextColor = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.SourceSans,
    FrameRate = 90 -- Target FPS for animations
}

local screenGui, mainFrame, tabsContainer, contentContainer

local isDragging = false
local dragStart
local startPos

--// UTILITY FUNCTIONS
local function create(instanceType, properties)
    local inst = Instance.new(instanceType)
    for prop, value in pairs(properties or {}) do
        inst[prop] = value
    end
    return inst
end

--// MAIN GUI CREATION
function library.new(title)
    -- Destroy any existing UI to prevent duplicates
    if game.Players.LocalPlayer:FindFirstChild("MyGameUI") then
        game.Players.LocalPlayer.MyGameUI:Destroy()
    end

    screenGui = create("ScreenGui", {
        Name = "MyGameUI",
        Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    mainFrame = create("Frame", {
        Name = "MainFrame",
        Parent = screenGui,
        Size = UDim2.new(0, 500, 0, 350),
        Position = UDim2.new(0.5, -250, 0.5, -175),
        BackgroundColor3 = UI_CONFIG.BackgroundColor,
        BorderSizePixel = 0,
        Active = true,
        Draggable = true,
        Visible = true
    })
    create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = mainFrame })

    local header = create("Frame", {
        Name = "Header",
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = UI_CONFIG.AccentColor,
    })
    create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = header })

    local titleLabel = create("TextLabel", {
        Name = "Title",
        Parent = header,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        Text = title or "My Roblox Game",
        TextColor3 = UI_CONFIG.TextColor,
        Font = UI_CONFIG.Font,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1
    })

    tabsContainer = create("Frame", {
        Name = "TabsContainer",
        Parent = mainFrame,
        Size = UDim2.new(0, 120, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = UI_CONFIG.BackgroundColor,
        BorderSizePixel = 0
    })

    contentContainer = create("Frame", {
        Name = "ContentContainer",
        Parent = mainFrame,
        Size = UDim2.new(1, -120, 1, -40),
        Position = UDim2.new(0, 120, 0, 40),
        BackgroundColor3 = UI_CONFIG.ContainerColor,
        BorderSizePixel = 0
    })

    --// DRAG FUNCTIONALITY
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                end
            end)
        end
    end)

    header.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    --// HIDE/SHOW FUNCTIONALITY
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == UI_CONFIG.ToggleKey then
            mainFrame.Visible = not mainFrame.Visible
        end
    end)

    local self = {}
    
    function self:Tab(name)
        -- Hide all other content frames
        for _, child in ipairs(contentContainer:GetChildren()) do
            if child:IsA("ScrollingFrame") then
                child.Visible = false
            end
        end

        local contentFrame = create("ScrollingFrame", {
            Name = name .. "Content",
            Parent = contentContainer,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = UI_CONFIG.ContainerColor,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarImageColor3 = UI_CONFIG.AccentColor,
            Visible = true
        })

        create("UIListLayout", {
            Parent = contentFrame,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })

        local tabButton = create("TextButton", {
            Name = name,
            Parent = tabsContainer,
            Size = UDim2.new(1, 0, 0, 30),
            Text = name,
            TextColor3 = UI_CONFIG.TextColor,
            BackgroundColor3 = UI_CONFIG.AccentColor,
            Font = UI_CONFIG.Font,
            TextSize = 16
        })
        create("UICorner", { Parent = tabButton })

        tabButton.MouseButton1Click:Connect(function()
            for _, child in ipairs(contentContainer:GetChildren()) do
                if child:IsA("ScrollingFrame") then
                    child.Visible = false
                end
            end
            contentFrame.Visible = true
        end)

        local tabApi = {}
        local layoutOrder = 0

        local function updateCanvasSize()
            local layout = contentFrame.UIListLayout
            local absoluteContentSize = layout.AbsoluteContentSize
            contentFrame.CanvasSize = UDim2.new(0, 0, 0, absoluteContentSize.Y)
        end
        
        contentFrame.ChildAdded:Connect(updateCanvasSize)
        contentFrame.ChildRemoved:Connect(updateCanvasSize)
        
        --// COMPONENTS
        function tabApi:Button(options)
            layoutOrder = layoutOrder + 1
            local button = create("TextButton", {
                Name = options.Name,
                Parent = contentFrame,
                Size = UDim2.new(1, -20, 0, 30),
                Position = UDim2.new(0, 10, 0, 0),
                Text = options.Name,
                TextColor3 = UI_CONFIG.TextColor,
                BackgroundColor3 = UI_CONFIG.AccentColor,
                Font = UI_CONFIG.Font,
                TextSize = 14,
                LayoutOrder = layoutOrder
            })
            create("UICorner", { Parent = button })
            button.MouseButton1Click:Connect(options.Callback)
        end

        function tabApi:Toggle(options)
            layoutOrder = layoutOrder + 1
            local state = options.StartingState or false
            
            local container = create("Frame", {
                Name = options.Name,
                Parent = contentFrame,
                Size = UDim2.new(1, -20, 0, 30),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                LayoutOrder = layoutOrder
            })

            local label = create("TextLabel", {
                Parent = container,
                Size = UDim2.new(0.7, 0, 1, 0),
                Text = options.Name,
                TextColor3 = UI_CONFIG.TextColor,
                Font = UI_CONFIG.Font,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1
            })

            local toggleButton = create("TextButton", {
                Parent = container,
                Size = UDim2.new(0.3, 0, 1, 0),
                Position = UDim2.new(0.7, 0, 0, 0),
                BackgroundColor3 = state and UI_CONFIG.AccentColor or Color3.fromRGB(80, 80, 80),
                Text = ""
            })
            create("UICorner", { Parent = toggleButton })

            toggleButton.MouseButton1Click:Connect(function()
                state = not state
                toggleButton.BackgroundColor3 = state and UI_CONFIG.AccentColor or Color3.fromRGB(80, 80, 80)
                if options.Callback then options.Callback(state) end
            end)
        end
        
        function tabApi:Textbox(options)
            layoutOrder = layoutOrder + 1
            local textbox = create("TextBox", {
                Name = options.Name,
                Parent = contentFrame,
                Size = UDim2.new(1, -20, 0, 30),
                Position = UDim2.new(0, 10, 0, 0),
                PlaceholderText = options.Name,
                Text = "",
                TextColor3 = UI_CONFIG.TextColor,
                BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                Font = UI_CONFIG.Font,
                TextSize = 14,
                LayoutOrder = layoutOrder,
                ClearTextOnFocus = false
            })
            create("UICorner", { Parent = textbox })
            
            textbox.FocusLost:Connect(function(enterPressed)
                if enterPressed and options.Callback then
                    options.Callback(textbox.Text)
                end
            end)
        end

        function tabApi:Slider(options)
            layoutOrder = layoutOrder + 1
            local container = create("Frame", {
                Name = options.Name,
                Parent = contentFrame,
                Size = UDim2.new(1, -20, 0, 40),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                LayoutOrder = layoutOrder
            })

            local label = create("TextLabel", {
                Parent = container,
                Size = UDim2.new(1, 0, 0, 20),
                Text = options.Name .. ": " .. (options.Default or 50),
                TextColor3 = UI_CONFIG.TextColor,
                Font = UI_CONFIG.Font,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1
            })

            local sliderBack = create("Frame", {
                Parent = container,
                Size = UDim2.new(1, 0, 0, 10),
                Position = UDim2.new(0, 0, 0, 20),
                BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            })
            create("UICorner", { Parent = sliderBack })

            local fill = create("Frame", {
                Parent = sliderBack,
                Size = UDim2.new((options.Default or 50) / (options.Max or 100), 0, 1, 0),
                BackgroundColor3 = UI_CONFIG.AccentColor
            })
            create("UICorner", { Parent = fill })

            local handle = create("TextButton", {
                Parent = sliderBack,
                Size = UDim2.new(0, 15, 0, 15),
                Position = UDim2.new(fill.Size.X.Scale, -7.5, 0.5, -7.5),
                BackgroundColor3 = UI_CONFIG.TextColor,
                Text = "",
                Draggable = true
            })
            create("UICorner", { Parent = handle })

            local isSliding = false
            handle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isSliding = true
                end
            end)
            handle.InputEnded:Connect(function() isSliding = false end)
            
            UserInputService.InputChanged:Connect(function(input)
                if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local mouseX = UserInputService:GetMouseLocation().X
                    local backPos = sliderBack.AbsolutePosition.X
                    local backSize = sliderBack.AbsoluteSize.X
                    
                    local percent = math.clamp((mouseX - backPos) / backSize, 0, 1)
                    local value = math.floor((options.Min or 0) + percent * ((options.Max or 100) - (options.Min or 0)))
                    
                    fill.Size = UDim2.new(percent, 0, 1, 0)
                    handle.Position = UDim2.new(percent, -7.5, 0.5, -7.5)
                    label.Text = options.Name .. ": " .. value
                    
                    if options.Callback then options.Callback(value) end
                end
            end)
        end

        -- Add other components like Dropdown, Keybind, ColorPicker here...

        return tabApi
    end

    return self
end

--// SYSTEM COMPONENTS (Notifications, Prompts, etc.)
function GUI:Notification(options)
    -- Implementation for notifications
end

function GUI:Prompt(options)
    -- Implementation for prompts
end

function GUI:Credit(options)
    -- Implementation for credits
end

library.GUI = GUI

return library
