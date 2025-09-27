local PHCzack = loadstring(game:HttpGet("https://raw.githubusercontent.com/PHCzack/PHCzackScript/refs/heads/main/PHCztem1.lua"))()

local Window = PHCzack:CreateWindow({
    Name = "PHCzack Script [Plants Vs Brainrot]",
    Size = 0.7
})

local FarmTab = Window:CreateTab("Farm")
local ShopTab = Window:CreateTab("Shop")
local BrainrotsTab = Window:CreateTab("Brainrots")
local MiscTab = Window:CreateTab("Misc")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local autoHitEnabled = false
local hitToggle

local autoSellEnabled = false
local autoEquipEnabled = false
local autoBuyEnabled = false
local autoBuyGearEnabled = false
local autoSellPlantsEnabled = false
local teleportToBrainrotsEnabled = false

local sellToggle
local equipToggle
local buyToggle
local buyGearToggle
local sellPlantsToggle

local seedsList = {
    "Cactus Seed",
    "Strawberry Seed",
    "Pumpkin Seed",
    "Sunflower Seed",
    "Dragon Fruit Seed",
    "Eggplant Seed",
    "Watermelon Seed",
    "Cocotank Seed",
    "Carnivorous Plant Seed",
    "Mr Carrot Seed",
    "Tomatrio Seed"
}

local gearList = {
    "Water Bucket",
    "Frost Grenade",
    "Banana Gun",
    "Frost Blower",
    "Carrot Launcher"
}

local selectedSeeds = {}
local selectedGears = {}

-- ESP Variables
local espEnabled = false
local espLineEnabled = false
local espNameEnabled = false
local espGlowEnabled = false
local espBoxEnabled = false
local espObjects = {}
local currentTarget = nil


local autoClaimEnabled = false
local originalPosition = nil
local claimInterval = 0.1

-- Plot locations
local plotLocations = {
    ["Plot 1"] = {
        Vector3.new(94.0, 10.0, 685.7),
        Vector3.new(93.7, 10.0, 697.8),
        Vector3.new(93.3, 10.0, 707.9),
        Vector3.new(83.0, 10.0, 707.4),
        Vector3.new(73.1, 10.0, 708.5),
        Vector3.new(64.2, 10.0, 708.0),
        Vector3.new(53.0, 10.0, 707.8),
        Vector3.new(53.2, 10.0, 697.4),
        Vector3.new(53.3, 10.0, 685.9)
    },
    ["Plot 2"] = {
        Vector3.new(-7.0, 10.1, 685.8),
        Vector3.new(-7.2, 10.1, 697.6),
        Vector3.new(-6.7, 10.1, 707.6),
        Vector3.new(-16.9, 10.1, 708.9),
        Vector3.new(-27.3, 10.1, 708.5),
        Vector3.new(-37.5, 10.1, 709.0),
        Vector3.new(-47.0, 10.1, 708.4),
        Vector3.new(-47.0, 10.1, 696.5),
        Vector3.new(-47.5, 10.1, 685.9)
    },
    ["Plot 3"] = {
        Vector3.new(-107.6, 10.1, 685.2),
        Vector3.new(-108.5, 10.1, 696.7),
        Vector3.new(-108.2, 10.1, 708.7),
        Vector3.new(-117.8, 10.1, 708.1),
        Vector3.new(-127.5, 10.1, 708.9),
        Vector3.new(-138.4, 10.1, 707.8),
        Vector3.new(-148.0, 10.1, 708.9),
        Vector3.new(-148.5, 10.1, 697.1),
        Vector3.new(-148.7, 10.1, 686.4)
    },
    ["Plot 4"] = {
        Vector3.new(-209.7, 10.1, 685.2),
        Vector3.new(-209.0, 10.1, 697.1),
        Vector3.new(-209.0, 10.1, 708.1),
        Vector3.new(-218.6, 10.1, 708.7),
        Vector3.new(-229.2, 10.1, 709.0),
        Vector3.new(-238.6, 10.1, 708.6),
        Vector3.new(-248.3, 10.1, 708.0),
        Vector3.new(-248.9, 10.1, 697.8),
        Vector3.new(-249.3, 10.1, 686.2)
    },
    ["Plot 5"] = {
        Vector3.new(-310.5, 10.1, 685.5),
        Vector3.new(-311.2, 10.1, 696.4),
        Vector3.new(-310.8, 10.1, 707.4),
        Vector3.new(-320.4, 10.1, 708.1),
        Vector3.new(-329.7, 10.1, 708.6),
        Vector3.new(-340.6, 10.1, 707.9),
        Vector3.new(-350.8, 10.1, 708.6),
        Vector3.new(-350.2, 10.1, 696.7),
        Vector3.new(-350.2, 10.1, 685.2)
    },
    ["Plot 6"] = {
        Vector3.new(-411.4, 10.1, 685.7),
        Vector3.new(-412.2, 10.1, 697.0),
        Vector3.new(-412.3, 10.1, 707.5),
        Vector3.new(-421.7, 10.1, 708.5),
        Vector3.new(-431.5, 10.1, 708.4),
        Vector3.new(-442.7, 10.1, 708.1),
        Vector3.new(-451.1, 10.1, 708.8),
        Vector3.new(-451.0, 10.1, 696.7),
        Vector3.new(-451.8, 10.1, 686.6)
    }
}

local selectedPlots = {}

-- Lag-free functions using coroutines
local function fireRemoteSafely(remote, args)
    local success, error = pcall(function()
        remote:FireServer(unpack(args))
    end)
    if not success then
        warn("Remote error:", error)
    end
    return success
end

local sellCoroutine
local equipCoroutine
local buyCoroutine
local buyGearCoroutine
local sellPlantsCoroutine

-- ESP Functions
local function createESP(brainrot)
    if not brainrot or not brainrot:IsA("Model") then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "PHCzackESP"
    highlight.Adornee = brainrot
    highlight.Parent = brainrot
    
    if espNameEnabled then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "PHCzackName"
        billboard.Adornee = brainrot.PrimaryPart or brainrot:FindFirstChild("HumanoidRootPart")
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = brainrot
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = brainrot.Name
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextSize = 14
        label.Font = Enum.Font.GothamBold
        label.Parent = billboard
    end
    
    espObjects[brainrot] = {highlight = highlight}
    return highlight
end

local function removeESP(brainrot)
    if espObjects[brainrot] then
        if espObjects[brainrot].highlight then
            espObjects[brainrot].highlight:Destroy()
        end
        espObjects[brainrot] = nil
    end
end

local function updateESP()
    for brainrot, espData in pairs(espObjects) do
        if not brainrot or not brainrot.Parent then
            removeESP(brainrot)
        end
    end
    
    if espEnabled then
        local brainrotsFolder = workspace:FindFirstChild("ScriptedMap")
        if brainrotsFolder then
            brainrotsFolder = brainrotsFolder:FindFirstChild("Brainrots")
        end
        
        if brainrotsFolder then
            for _, brainrot in pairs(brainrotsFolder:GetChildren()) do
                if brainrot:IsA("Model") and not espObjects[brainrot] then
                    createESP(brainrot)
                end
            end
        end
    end
end

-- Teleport Functions
local function findClosestBrainrot()
    local brainrotsFolder = workspace:FindFirstChild("ScriptedMap")
    if brainrotsFolder then
        brainrotsFolder = brainrotsFolder:FindFirstChild("Brainrots")
    end
    
    if not brainrotsFolder then return nil end
    
    local player = game.Players.LocalPlayer
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local closestDistance = math.huge
    local closestBrainrot = nil
    local playerPos = player.Character.HumanoidRootPart.Position
    
    for _, brainrot in pairs(brainrotsFolder:GetChildren()) do
        if brainrot:IsA("Model") and brainrot:FindFirstChild("HumanoidRootPart") then
            local humanoid = brainrot:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local distance = (playerPos - brainrot.HumanoidRootPart.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestBrainrot = brainrot
                end
            end
        end
    end
    
    return closestBrainrot
end

-- Farm Tab


-- Auto Claim System


-- Plot Selection Dropdown
FarmTab:Dropdown({
    Name = "Select Plots to Claim",
    Options = {"Plot 1", "Plot 2", "Plot 3", "Plot 4", "Plot 5", "Plot 6"},
    MultiSelection = true,
    CurrentOption = {},
    Callback = function(selectedList)
        selectedPlots = selectedList
        print("Selected plots:", table.concat(selectedList, ", "))
    end
})

-- Claim Interval Dropdown
FarmTab:Dropdown({
    Name = "Claim Every?",
    Options = {"Fast Claim", "Claim Every 5 seconds", "Claim Every 30 seconds", "Claim Every 1 Minutes", "Claim Every 10 Minutes"},
    CurrentOption = "Fast Claim",
    Callback = function(option)
        if option == "Fast Claim" then
            claimInterval = 0.1
        elseif option == "5 seconds" then
            claimInterval = 5
        elseif option == "Claim Every 30 seconds" then
            claimInterval = 30
        elseif option == "Claim Every 1 Minutes" then
            claimInterval = 60
        elseif option == "Claim Every 10 Minutes" then
            claimInterval = 600
        end
        print("Claim interval set to:", option)
    end
})

-- Auto Claim Toggle
FarmTab:Toggle({
    Name = "Auto Claim",
    CurrentValue = false,
    Callback = function(state)
        autoClaimEnabled = state
        if state then
            -- Save original position
            local player = game.Players.LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                originalPosition = player.Character.HumanoidRootPart.Position
            end
            
            spawn(function()
                while autoClaimEnabled and wait(claimInterval) do
                    local player = game.Players.LocalPlayer
                    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local humanoidRootPart = player.Character.HumanoidRootPart
                        
                        -- Teleport to each selected plot's locations
                        for _, plotName in ipairs(selectedPlots) do
                            if not autoClaimEnabled then break end
                            
                            local plot = plotLocations[plotName]
                            if plot then
                                for _, position in ipairs(plot) do
                                    if not autoClaimEnabled then break end
                                    humanoidRootPart.CFrame = CFrame.new(position)
                                    wait(0.2) -- Small delay between teleports
                                end
                            end
                        end
                        
                        -- Return to original position
                        if originalPosition and autoClaimEnabled then
                            humanoidRootPart.CFrame = CFrame.new(originalPosition)
                        end
                    end
                end
            end)
        else
            -- Return to original position when disabled
            if originalPosition then
                local player = game.Players.LocalPlayer
                if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(originalPosition)
                end
            end
        end
    end
})






sellToggle = FarmTab:Toggle({
    Name = "Auto SellBrainrot",
    CurrentValue = false,
    Callback = function(state)
        autoSellEnabled = state
        if state then
            if autoEquipEnabled then
                autoEquipEnabled = false
                equipToggle:SetValue(false)
            end
            
            sellCoroutine = coroutine.create(function()
                local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 9e9):WaitForChild("ItemSell", 9e9)
                while autoSellEnabled do
                    local args = {}
                    fireRemoteSafely(remote, args)
                    wait(0.05)
                end
            end)
            coroutine.resume(sellCoroutine)
        end
    end
})

sellPlantsToggle = FarmTab:Toggle({
    Name = "Auto Sell Plants",
    CurrentValue = false,
    Callback = function(state)
        autoSellPlantsEnabled = state
        if state then
            if autoEquipEnabled then
                autoEquipEnabled = false
                equipToggle:SetValue(false)
            end
            
            sellPlantsCoroutine = coroutine.create(function()
                local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 9e9):WaitForChild("ItemSell", 9e9)
                while autoSellPlantsEnabled do
                    local args = {
                        [2] = true;
                    }
                    fireRemoteSafely(remote, args)
                    wait(0.05)
                end
            end)
            coroutine.resume(sellPlantsCoroutine)
        end
    end
})

equipToggle = FarmTab:Toggle({
    Name = "Auto Equip Best Pet (Beta)",
    CurrentValue = false,
    Callback = function(state)
        autoEquipEnabled = state
        if state then
            if autoSellEnabled then
                autoSellEnabled = false
                sellToggle:SetValue(false)
            end
            if autoSellPlantsEnabled then
                autoSellPlantsEnabled = false
                sellPlantsToggle:SetValue(false)
            end
            
            equipCoroutine = coroutine.create(function()
                local remote = game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2", 9e9):WaitForChild("dataRemoteEvent", 9e9)
                while autoEquipEnabled do
                    local args = {
                        [1] = {
                            [2] = "5";
                        };
                    }
                    fireRemoteSafely(remote, args)
                    wait(5)
                end
            end)
            coroutine.resume(equipCoroutine)
        end
    end
})






-- Shop Tab
ShopTab:Dropdown({
    Name = "Select Seeds",
    Options = seedsList,
    MultiSelection = true,
    CurrentOption = {},
    Callback = function(selectedList)
        selectedSeeds = selectedList
        print("Selected seeds:", table.concat(selectedList, ", "))
    end
})

buyToggle = ShopTab:Toggle({
    Name = "Auto Buy Seeds",
    CurrentValue = false,
    Callback = function(state)
        autoBuyEnabled = state
        if state then
            buyCoroutine = coroutine.create(function()
                local remote = game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2", 9e9):WaitForChild("dataRemoteEvent", 9e9)
                local purchaseCooldown = 1
                
                while autoBuyEnabled do
                    local successfulPurchases = 0
                    
                    for _, seedName in ipairs(selectedSeeds) do
                        if not autoBuyEnabled then break end
                        
                        local args = {
                            [1] = {
                                [1] = seedName;
                                [2] = "";
                            };
                        }
                        
                        if fireRemoteSafely(remote, args) then
                            successfulPurchases = successfulPurchases + 1
                        end
                        
                        wait(0.5)
                    end
                    
                    if successfulPurchases > 0 then
                        purchaseCooldown = math.max(2, purchaseCooldown * 0.9)
                    else
                        purchaseCooldown = math.min(10, purchaseCooldown * 1.5)
                    end
                    
                    wait(purchaseCooldown)
                end
            end)
            coroutine.resume(buyCoroutine)
        end
    end
})

ShopTab:Dropdown({
    Name = "Select Gear",
    Options = gearList,
    MultiSelection = true,
    CurrentOption = {},
    Callback = function(selectedList)
        selectedGears = selectedList
        print("Selected gear:", table.concat(selectedList, ", "))
    end
})

buyGearToggle = ShopTab:Toggle({
    Name = "Auto Buy Gear",
    CurrentValue = false,
    Callback = function(state)
        autoBuyGearEnabled = state
        if state then
            buyGearCoroutine = coroutine.create(function()
                local remote = game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2", 9e9):WaitForChild("dataRemoteEvent", 9e9)
                local purchaseCooldown = 1
                
                while autoBuyGearEnabled do
                    local successfulPurchases = 0
                    
                    for _, gearName in ipairs(selectedGears) do
                        if not autoBuyGearEnabled then break end
                        
                        local args = {
                            [1] = {
                                [1] = gearName;
                                [2] = " ";
                            };
                        }
                        
                        if fireRemoteSafely(remote, args) then
                            successfulPurchases = successfulPurchases + 1
                        end
                        
                        wait(0.5)
                    end
                    
                    if successfulPurchases > 0 then
                        purchaseCooldown = math.max(2, purchaseCooldown * 0.9)
                    else
                        purchaseCooldown = math.min(10, purchaseCooldown * 1.5)
                    end
                    
                    wait(purchaseCooldown)
                end
            end)
            coroutine.resume(buyGearCoroutine)
        end
    end
})



-- Player Speed
MiscTab:Toggle({
    Name = "Player Speed",
    CurrentValue = false,
    Callback = function(state)
        if state then
            humanoid.WalkSpeed = 50
        else
            humanoid.WalkSpeed = 16
        end
    end
})

-- Player Jump
MiscTab:Toggle({
    Name = "Player Jump",
    CurrentValue = false,
    Callback = function(state)
        if state then
            humanoid.JumpPower = 100
        else
            humanoid.JumpPower = 50
        end
    end
})

-- High Jump
MiscTab:Toggle({
    Name = "High Jump",
    CurrentValue = false,
    Callback = function(state)
        if state then
            humanoid.JumpPower = 200
        else
            humanoid.JumpPower = 50
        end
    end
})

-- Reduce Lag
MiscTab:Toggle({
    Name = "Reduce Lag",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local decalsyeeted = true
            local g = game
            local w = g.Workspace
            local l = g.Lighting
            local t = w.Terrain
            t.WaterWaveSize = 0
            t.WaterWaveSpeed = 0
            t.WaterReflectance = 0
            t.WaterTransparency = 0
            l.GlobalShadows = false
            l.FogEnd = 9e9
            l.Brightness = 0
            settings().Rendering.QualityLevel = "Level01"
            for i, v in pairs(g:GetDescendants()) do
                if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
                    v.Material = "Plastic"
                    v.Reflectance = 0
                elseif v:IsA("Decal") or v:IsA("Texture") and decalsyeeted then
                    v.Transparency = 1
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Lifetime = NumberRange.new(0)
                elseif v:IsA("Explosion") then
                    v.BlastPressure = 1
                    v.BlastRadius = 1
                end
            end
        else
            -- Reset to default (you may need to adjust these values)
            local t = game.Workspace.Terrain
            t.WaterWaveSize = 0.5
            t.WaterWaveSpeed = 1
            t.WaterReflectance = 0.5
            t.WaterTransparency = 0.5
            game.Lighting.GlobalShadows = true
            game.Lighting.FogEnd = 1000
            game.Lighting.Brightness = 1
            settings().Rendering.QualityLevel = "Level20"
        end
    end
})

-- Remove Fog
MiscTab:Toggle({
    Name = "Remove Fog",
    CurrentValue = false,
    Callback = function(state)
        if state then
            game.Lighting.FogEnd = 9e9
        else
            game.Lighting.FogEnd = 1000
        end
    end
})

-- Brainrots Tab

BrainrotsTab:Toggle({
    Name = "ESP",
    CurrentValue = false,
    Callback = function(state)
        espEnabled = state
        if not state then
            for brainrot, espData in pairs(espObjects) do
                removeESP(brainrot)
            end
        else
            updateESP()
        end
    end
})

BrainrotsTab:Toggle({
    Name = "ESP Line",
    CurrentValue = false,
    Callback = function(state)
        espLineEnabled = state
    end
})

BrainrotsTab:Toggle({
    Name = "ESP Name",
    CurrentValue = false,
    Callback = function(state)
        espNameEnabled = state
        updateESP()
    end
})

BrainrotsTab:Toggle({
    Name = "ESP Glow",
    CurrentValue = false,
    Callback = function(state)
        espGlowEnabled = state
        updateESP()
    end
})

BrainrotsTab:Toggle({
    Name = "ESP Box",
    CurrentValue = false,
    Callback = function(state)
        espBoxEnabled = state
        updateESP()
    end
})

-- ESP Update Loop
game:GetService("RunService").Heartbeat:Connect(function()
    if espEnabled then
        updateESP()
    end
end)

