if getgenv().RedExecutorKeySys then return end
getgenv().RedExecutorKeySys = true

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Configuration
Config = {
    api = "1b7e01aa-e92a-4d60-af14-8a41c9562d67", 
    service = "PvBProvider",
    provider = "PvBProvider"
}

local KeySystemData = {
    Name = "PHCzack Key System",
    DiscordInvite = "PHCzackChannel",
    FileName = "redexecutor/key.txt"
}

local function main()
local PHCzack = loadstring(game:HttpGet("https://api.junkie-development.de/api/v1/luascripts/public/601aefe2a7e17848099a02ed55ec4cde1e10db616d10861dabbffe87cbd51a5c/download"))()
    print("Script loaded! User was here")
    -- Your main script here
end

-- Create Main GUI
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "NeonKeySystem"
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MainGui.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 350)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 200)
MainFrame.BorderSizePixel = 1
MainFrame.Active = true
MainFrame.Visible = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = MainGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

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
bottomFix.Size = UDim2.new(1, 0, 0.5, 0)
bottomFix.Position = UDim2.new(0, 0, 0.5, 0)
bottomFix.BackgroundColor3 = Header.BackgroundColor3
bottomFix.BorderSizePixel = 0
bottomFix.Parent = Header
local bottomFixGradient = headerGradient:Clone()
bottomFixGradient.Parent = bottomFix

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.Text = KeySystemData.Name
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
CloseButton.BackgroundTransparency = 0.2
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextColor3 = Color3.fromRGB(20, 20, 30)
CloseButton.TextSize = 16
CloseButton.Parent = Header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    MainGui:Destroy()
end)

-- Content Container
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -40, 1, -60)
ContentContainer.Position = UDim2.new(0, 20, 0, 50)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0, 10)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.Text = "Enter your key to continue"
StatusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
StatusLabel.TextSize = 16
StatusLabel.Parent = ContentContainer

-- Key Input
local KeyInputFrame = Instance.new("Frame")
KeyInputFrame.Size = UDim2.new(1, 0, 0, 45)
KeyInputFrame.Position = UDim2.new(0, 0, 0, 50)
KeyInputFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
KeyInputFrame.BorderColor3 = Color3.fromRGB(0, 255, 200)
KeyInputFrame.BorderSizePixel = 1
KeyInputFrame.Parent = ContentContainer

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 6)
inputCorner.Parent = KeyInputFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -20, 1, 0)
KeyInput.Position = UDim2.new(0, 10, 0, 0)
KeyInput.BackgroundTransparency = 1
KeyInput.Font = Enum.Font.SourceSans
KeyInput.PlaceholderText = "Enter Key..."
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(220, 220, 220)
KeyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
KeyInput.TextSize = 14
KeyInput.TextXAlignment = Enum.TextXAlignment.Left
KeyInput.ClearTextOnFocus = false
KeyInput.Parent = KeyInputFrame

-- Submit Button
local SubmitButton = Instance.new("TextButton")
SubmitButton.Name = "SubmitButton"
SubmitButton.Size = UDim2.new(1, 0, 0, 40)
SubmitButton.Position = UDim2.new(0, 0, 0, 110)
SubmitButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
SubmitButton.Text = "Verify Key"
SubmitButton.Font = Enum.Font.SourceSansBold
SubmitButton.TextColor3 = Color3.fromRGB(220, 220, 220)
SubmitButton.TextSize = 16
SubmitButton.Parent = ContentContainer

local submitGradient = Instance.new("UIGradient")
submitGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 120, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 0, 255))
})
submitGradient.Parent = SubmitButton

local submitCorner = Instance.new("UICorner")
submitCorner.CornerRadius = UDim.new(0, 6)
submitCorner.Parent = SubmitButton

-- Get Key Button
local GetKeyButton = Instance.new("TextButton")
GetKeyButton.Name = "GetKeyButton"
GetKeyButton.Size = UDim2.new(1, 0, 0, 40)
GetKeyButton.Position = UDim2.new(0, 0, 0, 160)
GetKeyButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
GetKeyButton.Text = "Get Key"
GetKeyButton.Font = Enum.Font.SourceSansBold
GetKeyButton.TextColor3 = Color3.fromRGB(220, 220, 220)
GetKeyButton.TextSize = 16
GetKeyButton.Parent = ContentContainer

local getKeyCorner = Instance.new("UICorner")
getKeyCorner.CornerRadius = UDim.new(0, 6)
getKeyCorner.Parent = GetKeyButton

-- Discord Button
local DiscordButton = Instance.new("TextButton")
DiscordButton.Name = "DiscordButton"
DiscordButton.Size = UDim2.new(1, 0, 0, 40)
DiscordButton.Position = UDim2.new(0, 0, 0, 210)
DiscordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
DiscordButton.Text = "Join Telegram"
DiscordButton.Font = Enum.Font.SourceSansBold
DiscordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DiscordButton.TextSize = 16
DiscordButton.Parent = ContentContainer

local discordCorner = Instance.new("UICorner")
discordCorner.CornerRadius = UDim.new(0, 6)
discordCorner.Parent = DiscordButton

-- Dragging Logic
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
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Functions
local function setStatus(text, color)
    StatusLabel.Text = text
    StatusLabel.TextColor3 = color or Color3.fromRGB(220, 220, 220)
end

-- Save key to file
local function saveKey(key)
    if not isfolder("redexecutor") then
        makefolder("redexecutor")
    end
    writefile(KeySystemData.FileName, key)
end

-- Load saved key
local function loadKey()
    if isfile(KeySystemData.FileName) then
        return readfile(KeySystemData.FileName)
    end
    return nil
end

-- Verify Key Function using JunkieKeySystem
local function verifyKey(key)
    local userKey = key:gsub("%s+", "")
    if not userKey or userKey == "" then
        return false
    end
    
    -- Load SDK when needed
    local success, JunkieKeySystem = pcall(function()
        return loadstring(game:HttpGet("https://junkie-development.de/sdk/JunkieKeySystem.lua"))()
    end)
    
    if not success then
        warn("Failed to load JunkieKeySystem SDK")
        return false
    end
    
    local API_KEY = Config.api
    local SERVICE = Config.service
    
    return JunkieKeySystem.verifyKey(API_KEY, userKey, SERVICE)
end

-- Get Key Function using JunkieKeySystem
local function openGetKey()
    -- Load SDK when needed
    local success, JunkieKeySystem = pcall(function()
        return loadstring(game:HttpGet("https://junkie-development.de/sdk/JunkieKeySystem.lua"))()
    end)
    
    if not success then
        setStatus("Failed to load key system!", Color3.fromRGB(255, 100, 100))
        return
    end
    
    local API_KEY = Config.api
    local PROVIDER = Config.provider
    local SERVICE = Config.service
    
    local link = JunkieKeySystem.getLink(API_KEY, PROVIDER, SERVICE)
    if link then
        if setclipboard then
            setclipboard(link)
            setStatus("Key link copied to clipboard!", Color3.fromRGB(100, 255, 100))
        else
            setStatus("Link: " .. link, Color3.fromRGB(100, 200, 255))
        end
    else
        setStatus("Failed to generate key link!", Color3.fromRGB(255, 100, 100))
    end
end

-- Button Events
SubmitButton.MouseButton1Click:Connect(function()
    local key = KeyInput.Text
    if key == "" then
        setStatus("Please enter a key!", Color3.fromRGB(255, 100, 100))
        return
    end
    
    setStatus("Verifying key...", Color3.fromRGB(255, 200, 100))
    SubmitButton.Text = "Verifying..."
    
    task.wait(0.5)
    
    if verifyKey(key) then
        setStatus("Key verified! Saving & loading script...", Color3.fromRGB(100, 255, 100))
        saveKey(key) -- Save the valid key
        task.wait(1)
        MainGui:Destroy()
        main()
    else
        setStatus("Invalid key! Please try again.", Color3.fromRGB(255, 100, 100))
        SubmitButton.Text = "Verify Key"
    end
end)

GetKeyButton.MouseButton1Click:Connect(function()
    openGetKey()
end)

DiscordButton.MouseButton1Click:Connect(function()
    setStatus("Opening Telegram invite...", Color3.fromRGB(100, 200, 255))
    setclipboard("https://t.me/" .. KeySystemData.DiscordInvite)
    setStatus("Telegram invite copied!", Color3.fromRGB(100, 255, 100))
end)

-- Enter key to submit
KeyInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        SubmitButton.MouseButton1Click:Fire()
    end
end)

-- Hover Effects
local function addHoverEffect(button, hoverColor, normalColor)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = normalColor}):Play()
    end)
end

addHoverEffect(SubmitButton, Color3.fromRGB(40, 40, 50), Color3.fromRGB(30, 30, 40))
addHoverEffect(GetKeyButton, Color3.fromRGB(35, 35, 45), Color3.fromRGB(25, 25, 35))
addHoverEffect(DiscordButton, Color3.fromRGB(98, 111, 252), Color3.fromRGB(88, 101, 242))

-- Check for saved key on startup
local savedKey = loadKey()
if savedKey and savedKey ~= "" then
    setStatus("Checking saved key...", Color3.fromRGB(255, 200, 100))
    MainFrame.Visible = true
    
    task.wait(0.5)
    
    if verifyKey(savedKey) then
        setStatus("Saved key valid! Loading script...", Color3.fromRGB(100, 255, 100))
        task.wait(1)
        MainGui:Destroy()
        main()
        return -- Exit early, don't show the UI
    else
        setStatus("Saved key expired. Please enter new key.", Color3.fromRGB(255, 200, 100))
        KeyInput.Text = ""
    end
else
    setStatus("Enter your key to continue", Color3.fromRGB(220, 220, 220))
end

-- Parent to PlayerGui
local player = game.Players.LocalPlayer
if player then
    local playerGui = player:WaitForChild("PlayerGui")
    MainGui.Parent = playerGui
else
    MainGui.Parent = game:GetService("CoreGui")
end
