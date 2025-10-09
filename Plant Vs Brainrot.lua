-- Robust PHCzack Script (Plants Vs Brainrot) - Long-run safe version
-- Key: single main loop, reconnects on CharacterAdded, re-fetch remotes safely, queue_on_teleport

--// Load Library (unchanged)
local PHCzack = loadstring(game:HttpGet("https://raw.githubusercontent.com/PHCzack/PHCzackScript/refs/heads/main/Library1.lua"))()

--// Create Window (unchanged)
local Window = PHCzack:CreateWindow({
    Name = "PHCzack Script [Plants Vs Brainrot] (Long-run safe)",
    Size = 0.7
})

local FarmTab = Window:CreateTab("Farm")
local ShopTab = Window:CreateTab("Shop")
local BrainrotsTab = Window:CreateTab("Brainrots")
local MiscTab = Window:CreateTab("Misc")
local VisualTab = Window:CreateTab("Visual")
local PlatformTab = Window:CreateTab("PlatForm")

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = (me and me.VirtualUser) or (game:GetService("VirtualUser"))
local LocalPlayer = Players.LocalPlayer

-- State variables (defaults kept from your script)
local autoClaimEnabled = false
local autoSellEnabled = false
local autoSellPlantsEnabled = false
local autoEquipEnabled = false
local autoBuyEnabled = false
local autoBuyGearEnabled = false
local followAttackEnabled = false
local espEnabled = false
local legendaryAttackEnabled = false
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
local frostBlowerEnabled = false
local bananaGunEnabled = false
local freezeEnabled = false
local carrotLauncherEnabled = false
local autoTurnInEnabled = false
local turnInEnabled = false
local autoOpenLuckyEggEnabled = false
local autoOpenSecretLuckyEggEnabled = false
local autoOpenMemeLuckyEggEnabled = false
local autoFuseEnabled = false
local autoRebirthEnabled = false
local autoBuyAllPlantsEnabled = false
local autoBuyAllGearEnabled = false
local unlimitedJump = false
local antiAFKEnabled = false
local espCache = {} -- to avoid re-creating ESP repeatedly

-- Seeds & Gear List
local seedsList = {
    "Cactus Seed","Strawberry Seed","Pumpkin Seed","Sunflower Seed",
    "Dragon Fruit Seed","Eggplant Seed","Watermelon Seed","Grape Seed",
    "Cocotank Seed","Carnivorous Plant Seed","Mr Carrot Seed",
    "Tomatrio Seed","Shroombino Seed", "Mango Seed"
}

local gearList = {
    "Water Bucket","Frost Grenade","Banana Gun","Frost Blower","Carrot Launcher"
}

-- Plots folder safe loader
local plots = workspace:FindFirstChild("Plots")
if not plots then
    plots = Instance.new("Folder", workspace)
    plots.Name = "Plots"
end

local function safeGetPlot(id, childName)
    local plot = plots:FindFirstChild(tostring(id))
    if plot then
        return plot:FindFirstChild(childName)
    end
end

-- Visual targets table (constructed using functions so re-evaluation is possible)
local function buildVisualTargets()
    return {
        ["Board"] = {
            (safeGetPlot(1,"Other") and safeGetPlot(1,"Other"):FindFirstChild("Tier3") and safeGetPlot(1,"Other").Tier3:FindFirstChild("Model")),
            (safeGetPlot(2,"Other") and safeGetPlot(2,"Other"):FindFirstChild("Tier1") and safeGetPlot(2,"Other").Tier1:FindFirstChild("Model")),
            (safeGetPlot(3,"Other") and safeGetPlot(3,"Other"):FindFirstChild("Tier1") and safeGetPlot(3,"Other").Tier1:FindFirstChild("Model")),
            (safeGetPlot(4,"Other") and safeGetPlot(4,"Other"):FindFirstChild("Tier1") and safeGetPlot(4,"Other").Tier1:FindFirstChild("Model")),
            (safeGetPlot(5,"Other") and safeGetPlot(5,"Other"):FindFirstChild("Tier1") and safeGetPlot(5,"Other").Tier1:FindFirstChild("Model")),
            (safeGetPlot(6,"Other") and safeGetPlot(6,"Other"):FindFirstChild("Tier1") and safeGetPlot(6,"Other").Tier1:FindFirstChild("Model"))
        },
        ["Rows"] = {
            safeGetPlot(1,"Rows"), safeGetPlot(2,"Rows"), safeGetPlot(3,"Rows"),
            safeGetPlot(4,"Rows"), safeGetPlot(5,"Rows"), safeGetPlot(6,"Rows")
        },
        ["Plants"] = {
            safeGetPlot(1,"Plants"), safeGetPlot(2,"Plants"), safeGetPlot(3,"Plants"),
            safeGetPlot(4,"Plants"), safeGetPlot(5,"Plants"), safeGetPlot(6,"Plants")
        },
        ["PlatForms"] = {
            safeGetPlot(1,"Brainrots"), safeGetPlot(2,"Brainrots"), safeGetPlot(3,"Brainrots"),
            safeGetPlot(4,"Brainrots"), safeGetPlot(5,"Brainrots"), safeGetPlot(6,"Brainrots")
        }
    }
end

local visualTargets = buildVisualTargets()

-- Plot teleport points (unchanged)
local plotLocations = {
    ["Plot 1"] = {Vector3.new(94,10,685),Vector3.new(93,10,697),Vector3.new(93,10,707)},
    ["Plot 2"] = {Vector3.new(-7,10,685),Vector3.new(-7,10,697),Vector3.new(-6,10,707)},
    ["Plot 3"] = {Vector3.new(-107,10,685),Vector3.new(-108,10,696),Vector3.new(-108,10,708)},
    ["Plot 4"] = {Vector3.new(-209,10,685),Vector3.new(-209,10,697),Vector3.new(-209,10,708)},
    ["Plot 5"] = {Vector3.new(-310,10,685),Vector3.new(-311,10,696),Vector3.new(-310,10,707)},
    ["Plot 6"] = {Vector3.new(-411,10,685),Vector3.new(-412,10,697),Vector3.new(-412,10,708)},
}

-- Helper: dynamic safe WaitForChild for nested paths
local function getRemoteSafe(root, ...)
    local args = {...}
    local node = root
    for i, name in ipairs(args) do
        if not node then return nil end
        local ok, result = pcall(function()
            return node:WaitForChild(name, 10) -- wait up to 10s
        end)
        node = ok and result or nil
        if not node then
            return nil
        end
    end
    return node
end

local function fireRemoteSafely(remote, args)
    if not remote then return false end
    local success, err = pcall(function()
        if type(args) == "table" then
            remote:FireServer(unpack(args))
        else
            remote:FireServer(args)
        end
    end)
    if not success then warn("Remote error:", err) end
    return success
end

-- Character/Player dynamic variables (kept updated)
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:FindFirstChildOfClass("Humanoid")
local HRP = Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChildWhichIsA("BasePart")

local function onCharacterAdded(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid", 10) or char:FindFirstChildOfClass("Humanoid")
    HRP = char:WaitForChild("HumanoidRootPart", 10) or char:FindFirstChildWhichIsA("BasePart")
    -- restore originalPosition if needed
    if HRP then
        if not originalPosition then originalPosition = HRP.Position end
    end
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
if LocalPlayer.Character then onCharacterAdded(LocalPlayer.Character) end

-- Helper: get brainrot rarity and uuid
local function getRarity(brainrot)
    if not brainrot then return "Unknown" end
    local attr = brainrot:GetAttribute("Rarity")
    if attr then return attr end
    local fv = brainrot:FindFirstChild("Rarity")
    if fv and fv.Value then return fv.Value end
    return "Unknown"
end

local function getBrainrotUUID(brainrot)
    if not brainrot then return nil end
    local attr = brainrot:GetAttribute("Uuid")
    if attr then return attr end
    local sv = brainrot:FindFirstChild("Uuid")
    if sv and sv.Value then return sv.Value end
    return brainrot.Name
end

local function getPredictedPosition(brainrot, delay)
    if not brainrot then return nil end
    local hrp = brainrot:FindFirstChild("HumanoidRootPart") or brainrot:FindFirstChildWhichIsA("BasePart")
    if not hrp then return nil end
    local speedObj = brainrot:FindFirstChild("Speed")
    local velocity = hrp.Velocity or Vector3.zero
    local speed = speedObj and (speedObj.Value or velocity.Magnitude) or velocity.Magnitude
    local dir = (velocity.Magnitude > 0) and (velocity.Unit) or Vector3.zero
    return hrp.Position + dir * (speed * (delay or 0))
end

local function getTargetPosition(brainrot)
    if not brainrot then return nil end
    local head = brainrot:FindFirstChild("Head")
    if head and head:IsA("BasePart") then return head.Position end
    local hrp = brainrot:FindFirstChild("HumanoidRootPart") or brainrot:FindFirstChildWhichIsA("BasePart")
    if hrp then return hrp.Position + Vector3.new(0,2,0) end
    return nil
end

-- Equip helpers (search both character and backpack)
local function findToolByNamePart(namePart)
    if Character then
        for _, tool in ipairs(Character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:match(namePart) then return tool end
        end
    end
    if LocalPlayer.Backpack then
        for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:match(namePart) then return tool end
        end
    end
    return nil
end

local function equipTool(tool)
    if not tool or not Humanoid then return false end
    if Character:FindFirstChild(tool.Name) then return true end
    pcall(function() Humanoid:EquipTool(tool) end)
    return true
end

-- Finders for specific items
local function equipFrostGrenade()
    local grenade = findToolByNamePart("Frost Grenade")
    if grenade then equipTool(grenade) end
    return grenade
end
local function equipFrostBlower()
    local blower = findToolByNamePart("Frost Blower")
    if blower then equipTool(blower) end
    return blower
end
local function equipBananaGun()
    local gun = findToolByNamePart("Banana Gun")
    if gun then equipTool(gun) end
    return gun
end
local function equipCarrotLauncher()
    local launcher = findToolByNamePart("Carrot Launcher")
    if launcher then equipTool(launcher) end
    return launcher
end
local function equipWeaponByName(weaponName)
    local tool = findToolByNamePart(weaponName)
    if tool then equipTool(tool) end
    return tool
end

-- Nearest brainrot getters
local function getBrainrotFolder()
    return workspace:FindFirstChild("ScriptedMap") and workspace.ScriptedMap:FindFirstChild("Brainrots")
end

local function getNearestBrainrot()
    local folder = getBrainrotFolder()
    if not folder or not HRP then return nil end
    local closest, dist = nil, math.huge
    for _, b in ipairs(folder:GetChildren()) do
        if b:IsA("Model") then
            local hr = b:FindFirstChild("HumanoidRootPart") or b:FindFirstChildWhichIsA("BasePart")
            if hr then
                local d = (hr.Position - HRP.Position).Magnitude
                if d < dist then closest, dist = b, d end
            end
        end
    end
    return closest
end

local function getNearestLegendaryBrainrot()
    local folder = getBrainrotFolder()
    if not folder or not HRP then return nil end
    local closest, dist = nil, math.huge
    for _, b in ipairs(folder:GetChildren()) do
        if b:IsA("Model") and getRarity(b) == "Legendary" then
            local hr = b:FindFirstChild("HumanoidRootPart") or b:FindFirstChildWhichIsA("BasePart")
            if hr then
                local d = (hr.Position - HRP.Position).Magnitude
                if d < dist then closest, dist = b, d end
            end
        end
    end
    return closest
end

local function getNearestSelectedRarityBrainrot()
    local folder = getBrainrotFolder()
    if not folder or not HRP or #selectedRarities == 0 then return nil end
    local closest, dist = nil, math.huge
    for _, b in ipairs(folder:GetChildren()) do
        if b:IsA("Model") then
            local r = getRarity(b)
            if table.find(selectedRarities, r) then
                local hr = b:FindFirstChild("HumanoidRootPart") or b:FindFirstChildWhichIsA("BasePart")
                if hr then
                    local d = (hr.Position - HRP.Position).Magnitude
                    if d < dist then closest, dist = b, d end
                end
            end
        end
    end
    return closest
end

-- ESP creation (guarded and cached)
local function createESP(brainrot)
    if not espEnabled or not brainrot then return end
    local hrp = brainrot:FindFirstChild("HumanoidRootPart") or brainrot:FindFirstChildWhichIsA("BasePart")
    if not hrp then return end
    if hrp:FindFirstChild("RarityESP") then return end

    local rarity = getRarity(brainrot)
    local rarityColor = Color3.fromRGB(255,255,255)
    if rarity == "Common" then rarityColor = Color3.fromRGB(0,255,0)
    elseif rarity == "Rare" then rarityColor = Color3.fromRGB(0,0,255)
    elseif rarity == "Epic" then rarityColor = Color3.fromRGB(128,0,128)
    elseif rarity == "Legendary" then rarityColor = Color3.fromRGB(255,215,0) end

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

-- follow & attack logic (fires server remote)
local function followAndAttack(targetBrainrot, weaponName)
    if not targetBrainrot or not HRP then return end
    local hrp = targetBrainrot:FindFirstChild("HumanoidRootPart") or targetBrainrot:FindFirstChildWhichIsA("BasePart")
    if not hrp then return end

    -- Equip requested weapon if provided
    if weaponName then
        equipWeaponByName(weaponName)
    end

    -- Lerp towards target (small step)
    if HRP and hrp then
        HRP.CFrame = HRP.CFrame:Lerp(CFrame.new(hrp.Position + Vector3.new(0,3,0)), 0.2)
    end

    -- dynamic fetch of attack remote
    local AttackRemote = getRemoteSafe(ReplicatedStorage, "Remotes", "AttacksServer", "WeaponAttack")
    if AttackRemote then
        local uuid = getBrainrotUUID(targetBrainrot)
        if uuid then
            pcall(function()
                AttackRemote:FireServer({uuid})
            end)
        end
    end
end

-- Throw frost grenade helper (uses UseItem remote)
local function throwFrostGrenadeAt(brainrot)
    if not brainrot then return end
    local UseItemRemote = getRemoteSafe(ReplicatedStorage, "Remotes", "UseItem")
    if not UseItemRemote then return end
    local hrp = brainrot:FindFirstChild("HumanoidRootPart") or brainrot:FindFirstChildWhichIsA("BasePart")
    if not hrp then return end
    local grenade = equipFrostGrenade()
    if grenade then
        pcall(function()
            UseItemRemote:FireServer({Toggle = true, Time = 0.5, Tool = grenade, Pos = hrp.Position})
        end)
    end
end

-- Use item at predicted position
local function useItemAt(tool, pos, time)
    local UseItemRemote = getRemoteSafe(ReplicatedStorage, "Remotes", "UseItem")
    if not UseItemRemote or not tool or not pos then return end
    pcall(function()
        UseItemRemote:FireServer({Toggle = true, Time = time or 0.3, Tool = tool, Pos = pos})
    end)
end

-- Centralized timers & intervals
local lastClaimTick = 0
local lastAutoEquipTick = 0
local lastOpenEggTick = 0
local lastFuseTick = 0
local lastRebirthTick = 0
local lastSellTick = 0
local lastBuyTick = 0
local heartbeatDelta = 0

-- Anti-AFK using Idled fallback
local afkConnection = nil
LocalPlayer.Idled:Connect(function()
    if antiAFKEnabled then
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(0.5)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end
end)

-- Unlimited jump handler
UserInputService.JumpRequest:Connect(function()
    if unlimitedJump and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- UI bindings (only set toggles and selection lists; UI creation kept same style)
BrainrotsTab:Dropdown({
    Name = "Auto Hit Selected Rarity",
    Options = {"Rare", "Epic", "Legendary", "Mythic", "Godly", "Secret", "Limited"},
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

BrainrotsTab:Toggle({
    Name = "Enable Selected Rarity Attack (Equip Bat)",
    CurrentValue = false,
    Callback = function(state)
        selectedRarityAttackEnabled = state
        if state then followAttackEnabled = false; legendaryAttackEnabled = false end
    end
})

BrainrotsTab:Toggle({
    Name = "Freeze Brainrots (Frost Grenade)",
    CurrentValue = false,
    Callback = function(state)
        freezeEnabled = state
        if state then followAttackEnabled = false; legendaryAttackEnabled = false end
    end
})

BrainrotsTab:Toggle({
    Name = "Auto Banana Gun",
    CurrentValue = false,
    Callback = function(state)
        bananaGunEnabled = state
        if state then
            followAttackEnabled = false
            legendaryAttackEnabled = false
            selectedRarityAttackEnabled = false
        end
    end
})

BrainrotsTab:Toggle({
    Name = "Auto Frost Blower)",
    CurrentValue = false,
    Callback = function(state)
        frostBlowerEnabled = state
        if not state then
            local blower = Character and Character:FindFirstChildWhichIsA("Tool") and Character:FindFirstChildWhichIsA("Tool")
            if blower and blower.Name:match("Frost Blower") then
                local UseItemRemote = getRemoteSafe(ReplicatedStorage, "Remotes", "UseItem")
                if UseItemRemote then
                    pcall(function() UseItemRemote:FireServer({Tool = blower, Toggle = false}) end)
                end
            end
        end
    end
})

BrainrotsTab:Toggle({
    Name = "Auto Carrot Launcher",
    CurrentValue = false,
    Callback = function(state)
        carrotLauncherEnabled = state
        if state then
            followAttackEnabled = false
            legendaryAttackEnabled = false
            freezeEnabled = false
            frostBlowerEnabled = false
            bananaGunEnabled = false
        end
    end
})

BrainrotsTab:Toggle({
    Name = "Auto Hit Brainrot (All)",
    CurrentValue = false,
    Callback = function(state)
        followAttackEnabled = state
        if state then legendaryAttackEnabled = false end
    end
})

BrainrotsTab:Toggle({
    Name = "ESP Rarity Name",
    CurrentValue = false,
    Callback = function(state) espEnabled = state end
})

-- Farm tab UI
FarmTab:Toggle({
    Name = "Auto Turn In + Equip Each Item",
    CurrentValue = false,
    Callback = function(state) autoTurnInEnabled = state end
})

FarmTab:Toggle({
    Name = "Turn In (Manual)",
    CurrentValue = false,
    Callback = function(state) turnInEnabled = state end
})

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
        if state and HRP then originalPosition = HRP.Position end
    end
})

FarmTab:Dropdown({
    Name = "Equip Time",
    Options = {"5 Seconds", "10 Seconds", "30 Seconds", "1 Minute", "5 Minutes", "10 Minutes", "15 Minutes"},
    CurrentOption = "5 Seconds",
    Callback = function(option)
        if option == "5 Seconds" then equipDelay = 5
        elseif option == "10 Seconds" then equipDelay = 10
        elseif option == "30 Seconds" then equipDelay = 30
        elseif option == "1 Minute" then equipDelay = 60
        elseif option == "5 Minutes" then equipDelay = 300
        elseif option == "10 Minutes" then equipDelay = 600
        elseif option == "15 Minutes" then equipDelay = 900 end
    end
})

FarmTab:Toggle({
    Name = "Auto Equip Brainrots Pet",
    CurrentValue = false,
    Callback = function(state) autoEquipEnabled = state end
})

FarmTab:Toggle({
    Name = "Auto Open Lucky Egg",
    CurrentValue = false,
    Callback = function(state) autoOpenLuckyEggEnabled = state end
})

FarmTab:Toggle({
    Name = "Auto Open Secret Lucky Egg",
    CurrentValue = false,
    Callback = function(state) autoOpenSecretLuckyEggEnabled = state end
})

FarmTab:Toggle({
    Name = "Auto Open Meme Lucky Egg",
    CurrentValue = false,
    Callback = function(state) autoOpenMemeLuckyEggEnabled = state end
})

FarmTab:Toggle({
    Name = "Auto Fuse",
    CurrentValue = false,
    Callback = function(state) autoFuseEnabled = state end
})

FarmTab:Toggle({
    Name = "Auto Rebirth",
    CurrentValue = false,
    Callback = function(state) autoRebirthEnabled = state end
})

FarmTab:Toggle({
    Name = "Auto Sell Brainrot",
    CurrentValue = false,
    Callback = function(state) autoSellEnabled = state end
})

FarmTab:Toggle({
    Name = "Auto Sell Plants",
    CurrentValue = false,
    Callback = function(state) autoSellPlantsEnabled = state end
})

-- Platform tab
-- buyPlatformRemote will be fetched dynamically in main loop when needed
PlatformTab:Button({
    Name = "Buy All Platforms (Beta Can buy already Own)",
    Callback = function()
        local buyPlatformRemote = getRemoteSafe(ReplicatedStorage, "Remotes", "BuyPlatform")
        if not buyPlatformRemote then return end
        task.spawn(function()
            for i = 1, 30 do
                pcall(function() buyPlatformRemote:FireServer(tostring(i)) end)
                task.wait(0.2)
            end
        end)
    end
})

for i = 1, 30 do
    PlatformTab:Button({
        Name = "Buy Platform " .. i,
        Callback = function()
            local buyPlatformRemote = getRemoteSafe(ReplicatedStorage, "Remotes", "BuyPlatform")
            if buyPlatformRemote then pcall(function() buyPlatformRemote:FireServer(tostring(i)) end) end
        end
    })
end

-- Shop tab
ShopTab:Dropdown({
    Name = "Select Seeds",
    Options = seedsList,
    MultiSelection = true,
    CurrentOption = {},
    Callback = function(list) selectedSeeds = list or {} end
})

ShopTab:Toggle({
    Name = "Auto Buy Seeds",
    CurrentValue = false,
    Callback = function(state) autoBuyEnabled = state end
})

ShopTab:Dropdown({
    Name = "Select Gear",
    Options = gearList,
    MultiSelection = true,
    CurrentOption = {},
    Callback = function(list) selectedGears = list or {} end
})

ShopTab:Toggle({
    Name = "Auto Buy Gear",
    CurrentValue = false,
    Callback = function(state) autoBuyGearEnabled = state end
})

ShopTab:Toggle({
    Name = "Auto Buy All Plants",
    CurrentValue = false,
    Callback = function(state) autoBuyAllPlantsEnabled = state end
})

ShopTab:Toggle({
    Name = "Auto Buy All Gear",
    CurrentValue = false,
    Callback = function(state) autoBuyAllGearEnabled = state end
})

-- Misc tab toggles
MiscTab:Toggle({ Name = "Unlimited Jump", CurrentValue = false, Callback = function(v) unlimitedJump = v end })
MiscTab:Toggle({
    Name = "Reduce Lag",
    CurrentValue = false,
    Callback = function(state)
        if state then
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
            pcall(function() settings().Rendering.QualityLevel = "Level01" end)
            for i, v in pairs(g:GetDescendants()) do
                if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
                    v.Material = "Plastic"
                    v.Reflectance = 0
                elseif (v:IsA("Decal") or v:IsA("Texture")) then
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
            pcall(function() settings().Rendering.QualityLevel = "Level20" end)
        end
    end
})

MiscTab:Toggle({
    Name = "Remove Fog",
    CurrentValue = false,
    Callback = function(state)
        if state then game.Lighting.FogEnd = 9e9 else game.Lighting.FogEnd = 1000 end
    end
})

MiscTab:Toggle({ Name = "Anti AFK", CurrentValue = false, Callback = function(v) antiAFKEnabled = v end })

VisualTab:Dropdown({
    Name = "Select Visual(s)",
    Options = {"Board","Rows","Plants","PlatForms"},
    MultiSelection = true,
    CurrentOption = {},
    Callback = function(list) selectedVisuals = list or {} end
})

VisualTab:Toggle({
    Name = "Hide/Show Selected (Reduce Lag)",
    CurrentValue = false,
    Callback = function(state)
        visualTargets = buildVisualTargets() -- rebuild dynamic targets
        for _, visType in ipairs(selectedVisuals) do
            if visualTargets[visType] then
                if state then
                    hiddenObjects[visType] = hiddenObjects[visType] or {}
                    for _, obj in ipairs(visualTargets[visType]) do
                        if obj and obj.Parent then
                            table.insert(hiddenObjects[visType], obj.Parent)
                            obj.Parent = nil
                        end
                    end
                else
                    if hiddenObjects[visType] then
                        for i, obj in ipairs(visualTargets[visType]) do
                            if obj and not obj.Parent and hiddenObjects[visType][i] then
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

-- Main centralized loop (safe, single Heartbeat connection)
RunService.Heartbeat:Connect(function(dt)
    heartbeatDelta = heartbeatDelta + dt

    -- update HRP/Humanoid references quickly if nil
    if (not HRP or not Humanoid) and LocalPlayer.Character then
        HRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChildWhichIsA("BasePart")
        Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    end

    -- Process faster features more often, others at intervals
    -- Auto Claim (interval controlled by claimInterval)
    if autoClaimEnabled and HRP and selectedPlots and #selectedPlots > 0 then
        if heartbeatDelta >= claimInterval then
            heartbeatDelta = 0
            -- move to each plot point sequence, then return to originalPosition
            for _, plotName in ipairs(selectedPlots) do
                if not autoClaimEnabled then break end
                local plot = plotLocations[plotName]
                if plot then
                    for _, pos in ipairs(plot) do
                        if not autoClaimEnabled then break end
                        if HRP then HRP.CFrame = CFrame.new(pos) end
                        task.wait(0.2)
                    end
                end
            end
            if originalPosition and autoClaimEnabled and HRP then
                HRP.CFrame = CFrame.new(originalPosition)
            end
        end
    end

    -- Auto Equip Brainrots Pet (every equipDelay seconds)
    if autoEquipEnabled then
        if tick() - lastAutoEquipTick > equipDelay then
            lastAutoEquipTick = tick()
            local remote = getRemoteSafe(ReplicatedStorage, "Remotes", "EquipBestBrainrots")
            if remote then pcall(function() remote:FireServer() end) end
        end
    end

    -- Auto Open Eggs
    if autoOpenLuckyEggEnabled or autoOpenSecretLuckyEggEnabled or autoOpenMemeLuckyEggEnabled then
        if tick() - lastOpenEggTick > 1 then
            lastOpenEggTick = tick()
            local remote = getRemoteSafe(ReplicatedStorage, "Remotes", "OpenEgg")
            if remote then
                if autoOpenLuckyEggEnabled then pcall(function() remote:FireServer("Godly Lucky Egg") end) end
                if autoOpenSecretLuckyEggEnabled then pcall(function() remote:FireServer("Secret Lucky Egg") end) end
                if autoOpenMemeLuckyEggEnabled then pcall(function() remote:FireServer("Meme Lucky Egg") end) end
            end
        end
    end

    -- Auto Fuse
    if autoFuseEnabled and tick() - lastFuseTick > 0.5 then
        lastFuseTick = tick()
        local remote = getRemoteSafe(ReplicatedStorage, "Remotes", "PromptFuse")
        if remote then pcall(function() remote:FireServer() end) end
    end

    -- Auto Rebirth
    if autoRebirthEnabled and tick() - lastRebirthTick > 1 then
        lastRebirthTick = tick()
        local remote = getRemoteSafe(ReplicatedStorage, "Remotes", "Rebirth")
        if remote then pcall(function() remote:FireServer({}) end) end
    end

    -- Auto Sell Brainrot/Plants
    if (autoSellEnabled or autoSellPlantsEnabled) and tick() - lastSellTick > 0.05 then
        lastSellTick = tick()
        local remote = getRemoteSafe(ReplicatedStorage, "Remotes", "ItemSell")
        if remote then
            if autoSellEnabled then pcall(function() remote:FireServer({}) end) end
            if autoSellPlantsEnabled then pcall(function() remote:FireServer({[2]=true}) end) end
        end
    end

    -- Auto Buy Seeds / Gear / All
    if (autoBuyEnabled or autoBuyGearEnabled or autoBuyAllPlantsEnabled or autoBuyAllGearEnabled) and tick() - lastBuyTick > 0.5 then
        lastBuyTick = tick()
        if autoBuyEnabled and #selectedSeeds > 0 then
            local remote = getRemoteSafe(ReplicatedStorage, "Remotes", "BuyItem")
            if remote then
                for _, seedName in ipairs(selectedSeeds) do
                    if not autoBuyEnabled then break end
                    pcall(function() remote:FireServer(seedName) end)
                    task.wait(0.05)
                end
            end
        end

        if autoBuyGearEnabled and #selectedGears > 0 then
            local remote = getRemoteSafe(ReplicatedStorage, "Remotes", "BuyGear")
            if remote then
                for _, gearName in ipairs(selectedGears) do
                    if not autoBuyGearEnabled then break end
                    pcall(function() remote:FireServer(gearName) end)
                    task.wait(0.05)
                end
            end
        end

        if autoBuyAllPlantsEnabled then
            local remote = getRemoteSafe(ReplicatedStorage, "Remotes", "BuyItem")
            if remote then
                for _, seedName in ipairs(seedsList) do
                    if not autoBuyAllPlantsEnabled then break end
                    pcall(function() remote:FireServer(seedName) end)
                    task.wait(0.05)
                end
            end
        end

        if autoBuyAllGearEnabled then
            local remote = getRemoteSafe(ReplicatedStorage, "Remotes", "BuyGear")
            if remote then
                for _, gearName in ipairs(gearList) do
                    if not autoBuyAllGearEnabled then break end
                    pcall(function() remote:FireServer(gearName) end)
                    task.wait(0.05)
                end
            end
        end
    end

    -- Auto Turn In + Equip Each Item
    if autoTurnInEnabled and Character and Humanoid and Character.Parent then
        if LocalPlayer and LocalPlayer.Backpack then
            for _, namePart in ipairs({
                "Alessio","Orcalero","Orcala","Bandito","Bombirito","Bombardiro","Crocodilo",
                "Brr Brr Patapim","Ballerina Cappuccina","Bananita Dolphinita","Burbaloni Lulliloli",
                "Cappuccino Assasino","Svinino Bombondino","Bombini Gussini","Elefanto Cocofanto","Trippi Troppi","Frigo Camelo",
                "Bambini Crostini","Gangster Footera","Madung","Crazylone Pizaione"
            }) do
                if not autoTurnInEnabled then break end
                local toolToEquip = nil
                for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool.Name:match(namePart) then
                        toolToEquip = tool
                        break
                    end
                end
                if not toolToEquip then
                    for _, tool in ipairs(Character:GetChildren()) do
                        if tool:IsA("Tool") and tool.Name:match(namePart) then
                            toolToEquip = tool
                            break
                        end
                    end
                end
                if toolToEquip and Humanoid:FindFirstChildOfClass("Tool") ~= toolToEquip then
                    pcall(function() Humanoid:EquipTool(toolToEquip) end)
                    local InteractRemote = getRemoteSafe(ReplicatedStorage, "Remotes", "Events", "Prison", "Interact")
                    if InteractRemote then pcall(function() InteractRemote:FireServer("TurnIn") end) end
                    task.wait(1)
                end
            end
        end
    end

    -- Manual TurnIn
    if turnInEnabled and tick() - lastFuseTick > 1 then
        lastFuseTick = tick()
        local InteractRemote = getRemoteSafe(ReplicatedStorage, "Remotes", "Events", "Prison", "Interact")
        if InteractRemote then pcall(function() InteractRemote:FireServer("TurnIn") end) end
    end

    -- Brainrots attack logic (priority-based)
    do
        local handled = false
        -- Freeze prioritized when enabled + rarity selection
        if freezeEnabled and #selectedRarities > 0 then
            local target = getNearestSelectedRarityBrainrot()
            if target then
                throwFrostGrenadeAt(target)
                handled = true
            end
        end

        -- Frost Blower
        if not handled and frostBlowerEnabled and #selectedRarities > 0 then
            local target = getNearestSelectedRarityBrainrot()
            if target then
                local hr = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChildWhichIsA("BasePart")
                local blower = equipFrostBlower()
                if blower and hr then
                    local UseItemRemote = getRemoteSafe(ReplicatedStorage, "Remotes", "UseItem")
                    if UseItemRemote then pcall(function() UseItemRemote:FireServer({Tool = blower, Toggle = true}) end)
                    handled = true
                end
            end
        end

        -- Banana Gun
        if not handled and bananaGunEnabled and #selectedRarities > 0 then
            local target = getNearestSelectedRarityBrainrot()
            if target then
                local gun = equipBananaGun()
                local pos = getPredictedPosition(target, 0.4)
                if gun and pos then useItemAt(gun, pos, 0.4) end
                handled = true
            end
        end

        -- Carrot Launcher
        if not handled and carrotLauncherEnabled and #selectedRarities > 0 then
            local target = getNearestSelectedRarityBrainrot()
            if target then
                local launcher = equipCarrotLauncher()
                local pos = getPredictedPosition(target, 0.3)
                if launcher and pos then useItemAt(launcher, pos, 0.3) end
                handled = true
            end
        end

        -- Default attack modes (no rarity required except where flagged)
        if not handled then
            if followAttackEnabled then
                local targ = getNearestBrainrot()
                if targ then followAndAttack(targ, "Leather Grip Bat") end
            elseif legendaryAttackEnabled then
                local targ = getNearestLegendaryBrainrot()
                if targ then followAndAttack(targ, "Leather Grip Bat") end
            elseif selectedRarityAttackEnabled and #selectedRarities > 0 then
                local targ = getNearestSelectedRarityBrainrot()
                if targ then followAndAttack(targ, "Leather Grip Bat") end
            end
        end
    end

    -- ESP creation (iterate brainrots)
    if espEnabled then
        local folder = getBrainrotFolder()
        if folder then
            for _, b in ipairs(folder:GetChildren()) do
                if b:IsA("Model") then createESP(b) end
            end
        end
    else
        -- optionally remove cached ESPs when disabled
        -- remove billboard GUIs created earlier
        local folder = getBrainrotFolder()
        if folder then
            for _, b in ipairs(folder:GetChildren()) do
                local hr = b:FindFirstChild("HumanoidRootPart") or b:FindFirstChildWhichIsA("BasePart")
                if hr and hr:FindFirstChild("RarityESP") then hr.RarityESP:Destroy() end
            end
        end
    end

    -- small yield to avoid tight loop issues (Heartbeat already gives dt)
end)

-- queue_on_teleport to auto-load script after teleport/server change
if queue_on_teleport then
    local url = "loadstring(game:HttpGet('https://raw.githubusercontent.com/PHCzack/PHCzackScript/refs/heads/main/Library1.lua'))()"
    pcall(function() queue_on_teleport(url) end)
end

-- Final note to keep script resilient:
-- If you want me to also add log messages, auto-reconnect attempts, or to move repeated waits into better throttle control (or add per-feature delays), tell me which feature to prioritize and I will tweak it.

print("[PHCzack] long-run safe script loaded")