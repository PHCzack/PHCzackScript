--// Load Library
local PHCzack = loadstring(game:HttpGet("https://raw.githubusercontent.com/PHCzack/PHCzackScript/refs/heads/main/Library1.lua"))()

--// Create Window
local Window = PHCzack:CreateWindow({
    Name = "PHCzack Script [Plants Vs Brainrot]",
    Size = 0.7
})

local FarmTab = Window:CreateTab("Farm")
local ShopTab = Window:CreateTab("Shop")
local BrainrotsTab = Window:CreateTab("Brainrots")
local MiscTab = Window:CreateTab("Misc")
local VisualTab = Window:CreateTab("Visual")

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

--// =========================
-- Variables
--// =========================
local autoClaimEnabled = false
local autoSellEnabled = false
local autoSellPlantsEnabled = false
local autoEquipEnabled = false
local autoBuyEnabled = false
local autoBuyGearEnabled = false
local followAttackEnabled = false
local followAttackEnabled = false  
local espEnabled = false 
local legendaryAttackEnabled = false -- NEW toggle flag
local selectedVisuals = {}
local hiddenObjects = {}
local selectedPlots = {}
local selectedSeeds = {}
local selectedGears = {}
local claimInterval = 0.1
local originalPosition = nil
local selectedRarities = {}
local equipDelay = 5  

local selectedRarityAttackEnabled = false
-- Seeds & Gear List
local seedsList = {
    "Cactus Seed","Strawberry Seed","Pumpkin Seed","Sunflower Seed",
    "Dragon Fruit Seed","Eggplant Seed","Watermelon Seed","Grape Seed",
    "Cocotank Seed","Carnivorous Plant Seed","Mr Carrot Seed",
    "Tomatrio Seed","Shroombino Seed"
}

local gearList = {
    "Water Bucket","Frost Grenade","Banana Gun","Frost Blower","Carrot Launcher"
}

-- ✅ Safe Plots Loader
local plots = workspace:WaitForChild("Plots", 10)
if not plots then
    warn("⚠️ Plots not found, creating dummy folder.")
    plots = Instance.new("Folder", workspace)
    plots.Name = "Plots"
end

local function safeGetPlot(id, childName)
    local plot = plots:FindFirstChild(tostring(id))
    if plot then
        return plot:FindFirstChild(childName)
    end
end

-- ✅ Safe Visual Targets
local visualTargets = {
    ["Board"] = {
        safeGetPlot(1,"Other") and safeGetPlot(1,"Other"):FindFirstChild("Tier3") and safeGetPlot(1,"Other").Tier3:FindFirstChild("Model"),
        safeGetPlot(2,"Other") and safeGetPlot(2,"Other"):FindFirstChild("Tier1") and safeGetPlot(2,"Other").Tier1:FindFirstChild("Model"),
        safeGetPlot(3,"Other") and safeGetPlot(3,"Other"):FindFirstChild("Tier1") and safeGetPlot(3,"Other").Tier1:FindFirstChild("Model"),
        safeGetPlot(4,"Other") and safeGetPlot(4,"Other"):FindFirstChild("Tier1") and safeGetPlot(4,"Other").Tier1:FindFirstChild("Model"),
        safeGetPlot(5,"Other") and safeGetPlot(5,"Other"):FindFirstChild("Tier1") and safeGetPlot(5,"Other").Tier1:FindFirstChild("Model"),
        safeGetPlot(6,"Other") and safeGetPlot(6,"Other"):FindFirstChild("Tier1") and safeGetPlot(6,"Other").Tier1:FindFirstChild("Model")
    },
    ["Rows"] = {
        safeGetPlot(1,"Rows"),
        safeGetPlot(2,"Rows"),
        safeGetPlot(3,"Rows"),
        safeGetPlot(4,"Rows"),
        safeGetPlot(5,"Rows"),
        safeGetPlot(6,"Rows")
    },
    ["Plants"] = {
        safeGetPlot(1,"Plants"),
        safeGetPlot(2,"Plants"),
        safeGetPlot(3,"Plants"),
        safeGetPlot(4,"Plants"),
        safeGetPlot(5,"Plants"),
        safeGetPlot(6,"Plants")
    },
    ["PlatForms"] = {
        safeGetPlot(1,"Brainrots"),
        safeGetPlot(2,"Brainrots"),
        safeGetPlot(3,"Brainrots"),
        safeGetPlot(4,"Brainrots"),
        safeGetPlot(5,"Brainrots"),
        safeGetPlot(6,"Brainrots")
    }
}


-- Plots teleport points (unchanged)
local plotLocations = {
    ["Plot 1"] = {Vector3.new(94,10,685),Vector3.new(93,10,697),Vector3.new(93,10,707)},
    ["Plot 2"] = {Vector3.new(-7,10,685),Vector3.new(-7,10,697),Vector3.new(-6,10,707)},
    ["Plot 3"] = {Vector3.new(-107,10,685),Vector3.new(-108,10,696),Vector3.new(-108,10,708)},
    ["Plot 4"] = {Vector3.new(-209,10,685),Vector3.new(-209,10,697),Vector3.new(-209,10,708)},
    ["Plot 5"] = {Vector3.new(-310,10,685),Vector3.new(-311,10,696),Vector3.new(-310,10,707)},
    ["Plot 6"] = {Vector3.new(-411,10,685),Vector3.new(-412,10,697),Vector3.new(-412,10,708)},
}

--// =========================
-- Helpers
--// =========================
local function fireRemoteSafely(remote, args)
    local success, err = pcall(function()
        remote:FireServer(unpack(args))
    end)
    if not success then warn("Remote error:", err) end
    return success
end

--// =========================
-- Brainrots Auto Attack
--// =========================
local WeaponAttack = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AttacksServer"):WaitForChild("WeaponAttack")
local weaponName = "Leather Grip Bat"

--// Helper Functions
local function getRarity(brainrot)
    if brainrot then
        local rarity = brainrot:FindFirstChild("Rarity") or brainrot:GetAttribute("Rarity")
        if rarity then
            return rarity.Value or rarity
        end
    end
    return "Unknown"
end

local function getBrainrotUUID(brainrot)
    if not brainrot then return nil end
    if brainrot:GetAttribute("Uuid") then
        return brainrot:GetAttribute("Uuid")
    end
    local uuidObj = brainrot:FindFirstChild("Uuid")
    if uuidObj and uuidObj:IsA("StringValue") then
        return uuidObj.Value
    end
    return brainrot.Name
end

local function equipWeapon()
    local char = LocalPlayer.Character
    if not char then return end
    if char:FindFirstChildOfClass("Tool") and char:FindFirstChildOfClass("Tool").Name == weaponName then
        return
    end
    local tool = LocalPlayer.Backpack:FindFirstChild(weaponName)
    if tool then
        char.Humanoid:EquipTool(tool)
    end
end

--// Get nearest Brainrot (all)
local function getNearestBrainrot()
    local folder = workspace:FindFirstChild("ScriptedMap") and workspace.ScriptedMap:FindFirstChild("Brainrots")
    if not folder then return nil end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local closest, dist = nil, math.huge
    for _, brainrot in ipairs(folder:GetChildren()) do
        if brainrot:IsA("Model") then
            local hrp = brainrot:FindFirstChild("HumanoidRootPart") or brainrot:FindFirstChildWhichIsA("BasePart")
            if hrp then
                local mag = (hrp.Position - root.Position).Magnitude
                if mag < dist then
                    closest, dist = brainrot, mag
                end
            end
        end
    end
    return closest
end

--// Get nearest Legendary Brainrot (rarity filter)
local function getNearestLegendaryBrainrot()
    local folder = workspace:FindFirstChild("ScriptedMap") and workspace.ScriptedMap:FindFirstChild("Brainrots")
    if not folder then return nil end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local closest, dist = nil, math.huge
    for _, brainrot in ipairs(folder:GetChildren()) do
        if brainrot:IsA("Model") and getRarity(brainrot) == "Legendary" then
            local hrp = brainrot:FindFirstChild("HumanoidRootPart") or brainrot:FindFirstChildWhichIsA("BasePart")
            if hrp then
                local mag = (hrp.Position - root.Position).Magnitude
                if mag < dist then
                    closest, dist = brainrot, mag
                end
            end
        end
    end
    return closest
end

--// Attack logic
local function followAndAttack(targetBrainrot)
    local brainrot = targetBrainrot
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if brainrot and root then
        local hrp = brainrot:FindFirstChild("HumanoidRootPart") or brainrot:FindFirstChildWhichIsA("BasePart")
        if hrp then
            equipWeapon()
            root.CFrame = root.CFrame:Lerp(CFrame.new(hrp.Position + Vector3.new(0, 3, 0)), 0.2)
            local uuid = getBrainrotUUID(brainrot)
            if uuid then
                WeaponAttack:FireServer({uuid})
            end
        end
    end
end

--// ESP Function (unchanged)
local function createESP(brainrot)
    if not espEnabled then return end
    
    local hrp = brainrot:FindFirstChild("HumanoidRootPart") or brainrot:FindFirstChildWhichIsA("BasePart")
    if hrp and not hrp:FindFirstChild("RarityESP") then
        local rarity = getRarity(brainrot)

        local rarityColor = Color3.fromRGB(255, 255, 255)
        if rarity == "Common" then
            rarityColor = Color3.fromRGB(0, 255, 0)
        elseif rarity == "Rare" then
            rarityColor = Color3.fromRGB(0, 0, 255)
        elseif rarity == "Epic" then
            rarityColor = Color3.fromRGB(128, 0, 128)
        elseif rarity == "Legendary" then
            rarityColor = Color3.fromRGB(255, 215, 0)
        end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "RarityESP"
        billboard.Parent = hrp
        billboard.Adornee = hrp
        billboard.Size = UDim2.new(0, 50, 0, 25)
        billboard.StudsOffset = Vector3.new(0, 3, 0)

        local textLabel = Instance.new("TextLabel")
        textLabel.Parent = billboard
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = rarity
        textLabel.TextColor3 = rarityColor
        textLabel.TextStrokeTransparency = 0.8
        textLabel.TextScaled = false
        textLabel.TextSize = 14
    end
end

-- Get nearest Brainrot from selected rarities
local function getNearestSelectedRarityBrainrot()
    local folder = workspace:FindFirstChild("ScriptedMap") and workspace.ScriptedMap:FindFirstChild("Brainrots")
    if not folder or #selectedRarities == 0 then return nil end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local closest, dist = nil, math.huge
    for _, brainrot in ipairs(folder:GetChildren()) do
        if brainrot:IsA("Model") then
            local rarity = getRarity(brainrot)
            if table.find(selectedRarities, rarity) then
                local hrp = brainrot:FindFirstChild("HumanoidRootPart") or brainrot:FindFirstChildWhichIsA("BasePart")
                if hrp then
                    local mag = (hrp.Position - root.Position).Magnitude
                    if mag < dist then
                        closest, dist = brainrot, mag
                    end
                end
            end
        end
    end
    return closest
end

-- Update your main loop
RunService.Heartbeat:Connect(function()
    if followAttackEnabled then
        local target = getNearestBrainrot()
        if target then followAndAttack(target) end
    elseif legendaryAttackEnabled then
        local target = getNearestLegendaryBrainrot()
        if target then followAndAttack(target) end
    elseif selectedRarityAttackEnabled and #selectedRarities > 0 then
        local target = getNearestSelectedRarityBrainrot()
        if target then followAndAttack(target) end
    end

    if espEnabled then
        local folder = workspace:FindFirstChild("ScriptedMap") and workspace.ScriptedMap:FindFirstChild("Brainrots")
        if folder then
            for _, brainrot in ipairs(folder:GetChildren()) do
                if brainrot:IsA("Model") then
                    createESP(brainrot)
                end
            end
        end
    end
end)


BrainrotsTab:Dropdown({
    Name = "Auto Hit Selected Rarity",
    Options = {"Rare", "Epic", "Legendary", "Mythic", "Godly", "Secret"},
    CurrentOption = {},
    MultiSelection = true,
    Callback = function(list)
        selectedRarities = list or {}
        if #selectedRarities > 0 then
            followAttackEnabled = false
            legendaryAttackEnabled = false
        end
    end
})

-- Toggle for enabling/disabling the feature
BrainrotsTab:Toggle({
    Name = "Enable Selected Rarity Attack",
    CurrentValue = false,
    Callback = function(state)
        selectedRarityAttackEnabled = state
        if state then
            followAttackEnabled = false
            legendaryAttackEnabled = false
        end
    end
})

--// Toggles
BrainrotsTab:Toggle({
    Name = "Auto Hit Brainrot (All)",
    CurrentValue = false,
    Callback = function(state)
        followAttackEnabled = state
        if state then legendaryAttackEnabled = false end -- avoid conflict
    end
})

BrainrotsTab:Toggle({
    Name = "ESP Rarity Name",
    CurrentValue = false,
    Callback = function(state)
        espEnabled = state
    end
})




--// =========================
-- Farm Tab
--// =========================
FarmTab:Dropdown({
    Name = "Select Plots to Claim",
    Options = {"Plot 1","Plot 2","Plot 3","Plot 4","Plot 5","Plot 6"},
    MultiSelection = true,
    CurrentOption = {},
    Callback = function(list) selectedPlots = list end
})

FarmTab:Dropdown({
    Name = "Claim Every?",
    Options = {"Fast Claim","Claim Every 5s","Claim Every 30s","Claim Every 1m","Claim Every 10m"},
    CurrentOption = "Fast Claim",
    Callback = function(opt)
        if opt=="Fast Claim" then claimInterval=0.1
        elseif opt=="Claim Every 5s" then claimInterval=5
        elseif opt=="Claim Every 30s" then claimInterval=30
        elseif opt=="Claim Every 1m" then claimInterval=60
        elseif opt=="Claim Every 10m" then claimInterval=600 end
    end
})

FarmTab:Toggle({
    Name = "Auto Claim",
    CurrentValue = false,
    Callback = function(state)
        autoClaimEnabled = state
        if state then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                originalPosition = LocalPlayer.Character.HumanoidRootPart.Position
            end
            task.spawn(function()
                while autoClaimEnabled do
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = LocalPlayer.Character.HumanoidRootPart
                        for _, plotName in ipairs(selectedPlots) do
                            if not autoClaimEnabled then break end
                            local plot = plotLocations[plotName]
                            if plot then
                                for _, pos in ipairs(plot) do
                                    if not autoClaimEnabled then break end
                                    hrp.CFrame = CFrame.new(pos)
                                    task.wait(0.2)
                                end
                            end
                        end
                        if originalPosition and autoClaimEnabled then
                            hrp.CFrame = CFrame.new(originalPosition)
                        end
                    end
                    task.wait(claimInterval)
                end
            end)
        end
    end
})



-- Dropdown for Equip Time
FarmTab:Dropdown({
    Name = "Equip Time",
    Options = {"5 Seconds", "10 Seconds", "30 Seconds", "1 Minute", "5 Minutes", "10 Minutes", "15 Minutes"},
    CurrentOption = "Equip Time",
    Callback = function(option)
        if option == "5 Seconds" then
            equipDelay = 5
        elseif option == "10 Seconds" then
            equipDelay = 10
        elseif option == "30 Seconds" then
            equipDelay = 30
        elseif option == "1 Minute" then
            equipDelay = 60
        elseif option == "5 Minutes" then
            equipDelay = 300
        elseif option == "10 Minutes" then
            equipDelay = 600
        elseif option == "15 Minutes" then
            equipDelay = 900
        end
    end
})

-- Auto Equip Brainrots Pet Toggle
FarmTab:Toggle({
    Name = "Auto Equip Brainrots Pet",
    CurrentValue = false,
    Callback = function(state)
        autoEquipEnabled = state
        if state then
            task.spawn(function()
                local remote = ReplicatedStorage:WaitForChild("Remotes", 9e9):WaitForChild("EquipBestBrainrots", 9e9)

                while autoEquipEnabled do
                    remote:FireServer() -- ✅ Updated Remote
                    task.wait(equipDelay)
                end
            end)
        end
    end
})

-- Auto Open Lucky Egg Toggle
FarmTab:Toggle({
    Name = "Auto Open Lucky Egg",
    CurrentValue = false,
    Callback = function(state)
        autoOpenLuckyEggEnabled = state
        if state then
            task.spawn(function()
                local remote = ReplicatedStorage:WaitForChild("Remotes", 9e9):WaitForChild("OpenEgg", 9e9)

                while autoOpenLuckyEggEnabled do
                    remote:FireServer("Godly Lucky Egg") -- ✅ Open Lucky Egg
                    task.wait(1) -- ⏳ opens every 0.5s
                end
            end)
        end
    end
})

-- Auto Open Secret Lucky Egg Toggle
FarmTab:Toggle({
    Name = "Auto Open Secret Lucky Egg",
    CurrentValue = false,
    Callback = function(state)
        autoOpenSecretLuckyEggEnabled = state
        if state then
            task.spawn(function()
                local remote = ReplicatedStorage:WaitForChild("Remotes", 9e9):WaitForChild("OpenEgg", 9e9)

                while autoOpenSecretLuckyEggEnabled do
                    remote:FireServer("Secret Lucky Egg")
                    task.wait(1) -- ⏳ every 1s
                end
            end)
        end
    end
})

-- Auto Open Meme Lucky Egg Toggle
FarmTab:Toggle({
    Name = "Auto Open Meme Lucky Egg",
    CurrentValue = false,
    Callback = function(state)
        autoOpenMemeLuckyEggEnabled = state
        if state then
            task.spawn(function()
                local remote = ReplicatedStorage:WaitForChild("Remotes", 9e9):WaitForChild("OpenEgg", 9e9)

                while autoOpenMemeLuckyEggEnabled do
                    remote:FireServer("Meme Lucky Egg")
                    task.wait(1) -- ⏳ every 1s
                end
            end)
        end
    end
})


-- Auto Fuse Toggle
FarmTab:Toggle({
    Name = "Auto Fuse",
    CurrentValue = false,
    Callback = function(state)
        autoFuseEnabled = state
        if state then
            task.spawn(function()
                local remote = ReplicatedStorage:WaitForChild("Remotes", 9e9):WaitForChild("PromptFuse", 9e9)

                while autoFuseEnabled do
                    remote:FireServer() -- ✅ Fire fuse remote
                    task.wait(0.5) -- ⏳ now runs every 0.5 seconds
                end
            end)
        end
    end
})

-- Auto Rebirth Toggle
FarmTab:Toggle({
    Name = "Auto Rebirth",
    CurrentValue = false,
    Callback = function(state)
        autoRebirthEnabled = state
        if state then
            task.spawn(function()
                local remote = ReplicatedStorage:WaitForChild("Remotes", 9e9):WaitForChild("Rebirth", 9e9)

                while autoRebirthEnabled do
                    remote:FireServer({}) -- ✅ Fire Rebirth remote
                    task.wait(1) -- ⏳ every 1s (adjust if needed)
                end
            end)
        end
    end
})

-- Buy All Platforms (1-30) Button
ShopTab:Button({
    Name = "Buy Platforms (All)",
    Callback = function()
        local remote = ReplicatedStorage:WaitForChild("Remotes", 9e9):WaitForChild("BuyPlatform", 9e9)

        for i = 1, 30 do
            remote:FireServer(tostring(i)) -- ✅ buys platform i
            task.wait(0.2) -- small delay to avoid flooding
        end
    end
})

FarmTab:Toggle({
    Name = "Auto Sell Brainrot",
    CurrentValue = false,
    Callback = function(state)
        autoSellEnabled = state
        if state then
            task.spawn(function()
                local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ItemSell")
                while autoSellEnabled do
                    fireRemoteSafely(remote,{})
                    task.wait(0.05)
                end
            end)
        end
    end
})

FarmTab:Toggle({
    Name = "Auto Sell Plants",
    CurrentValue = false,
    Callback = function(state)
        autoSellPlantsEnabled = state
        if state then
            task.spawn(function()
                local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ItemSell")
                while autoSellPlantsEnabled do
                    fireRemoteSafely(remote,{[2]=true})
                    task.wait(0.05)
                end
            end)
        end
    end
})



--// =========================
-- Shop Tab
--// =========================
ShopTab:Dropdown({
    Name = "Select Seeds",
    Options = seedsList,
    MultiSelection = true,
    CurrentOption = {},
    Callback = function(list) selectedSeeds = list end
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Auto Buy Seeds Toggle
ShopTab:Toggle({
    Name = "Auto Buy Seeds",
    CurrentValue = false,
    Callback = function(state)
        autoBuyEnabled = state
        if state then
            task.spawn(function()
                -- ✅ Updated Remote Path
                local remote = ReplicatedStorage:WaitForChild("Remotes", 9e9):WaitForChild("BuyItem", 9e9)

                while autoBuyEnabled do
                    for _, seedName in ipairs(selectedSeeds) do
                        if not autoBuyEnabled then break end
                        remote:FireServer(seedName)
                        task.wait(0.5)
                    end
                end
            end)
        end
    end
})

ShopTab:Dropdown({
    Name = "Select Gear",
    Options = gearList,
    MultiSelection = true,
    CurrentOption = {},
    Callback = function(list) selectedGears = list end
})



-- Auto Buy Gear Toggle
ShopTab:Toggle({
    Name = "Auto Buy Gear",
    CurrentValue = false,
    Callback = function(state)
        autoBuyGearEnabled = state
        if state then
            task.spawn(function()
                -- ✅ Updated Remote Path
                local remote = ReplicatedStorage:WaitForChild("Remotes", 9e9):WaitForChild("BuyGear", 9e9)

                while autoBuyGearEnabled do
                    for _, gearName in ipairs(selectedGears) do
                        if not autoBuyGearEnabled then break end
                        -- Fire directly with the gearName
                        remote:FireServer(gearName)
                        task.wait(0.5)
                    end
                end
            end)
        end
    end
})

--// =========================
-- Misc Tab
--// =========================
local unlimitedJump = false
MiscTab:Toggle({
    Name = "Unlimited Jump",
    CurrentValue = false,
    Callback = function(state)
        unlimitedJump = state
    end
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if unlimitedJump and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

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

--// =========================
-- Visual Tab
--// =========================
VisualTab:Dropdown({
    Name = "Select Visual(s)",
    Options = {"Board","Rows","Plants","PlatForms"},
    MultiSelection = true,
    CurrentOption = {},
    Callback = function(list)
        selectedVisuals = list
    end
})

VisualTab:Toggle({
    Name = "Hide/Show Selected (Reduce Lag)",
    CurrentValue = false,
    Callback = function(state)
        for _, visType in ipairs(selectedVisuals) do
            if visualTargets[visType] then
                if state then
                    hiddenObjects[visType] = {}
                    for _, obj in ipairs(visualTargets[visType]) do
                        if obj and obj.Parent then
                            table.insert(hiddenObjects[visType], obj.Parent)
                            obj.Parent = nil
                        end
                    end
                else
                    if hiddenObjects[visType] then
                        for i, obj in ipairs(visualTargets[visType]) do
                            if obj and not obj.Parent then
                                obj.Parent = hiddenObjects[visType][i]
                            end
                        end
                        hiddenObjects[visType] = nil
                    end
                end
            end
        end
    end
})
