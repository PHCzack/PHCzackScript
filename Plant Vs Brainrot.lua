--// Load Library
local PHCzack = loadstring(game:HttpGet("https://raw.githubusercontent.com/PHCzack/PHCzackScript/refs/heads/main/PHCztem1.lua"))()

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
local visualTargets = {
    ["Board"] = {
        workspace.Plots["1"].Other.Tier3.Model,
        workspace.Plots["2"].Other.Tier1.Model,
        workspace.Plots["3"].Other.Tier1.Model,
        workspace.Plots["4"].Other.Tier1.Model,
        workspace.Plots["5"].Other.Tier1.Model,
        workspace.Plots["6"].Other.Tier1.Model
    },
    ["Rows"] = {
        workspace.Plots["1"].Rows,
        workspace.Plots["2"].Rows,
        workspace.Plots["3"].Rows,
        workspace.Plots["4"].Rows,
        workspace.Plots["5"].Rows,
        workspace.Plots["6"].Rows
    },
    ["Plants"] = {
        workspace.Plots["1"].Plants,
        workspace.Plots["2"].Plants,
        workspace.Plots["3"].Plants,
        workspace.Plots["4"].Plants,
        workspace.Plots["5"].Plants,
        workspace.Plots["6"].Plants
    }
}

local selectedVisual = nil
local hiddenObjects = {}
-- Info Label (created once, updated later)
--local rowsInfoLabel = VisualTab:Label("")




local selectedPlots = {}
local selectedSeeds = {}
local selectedGears = {}

local claimInterval = 0.1
local originalPosition = nil

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

-- Plots
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
-- Brainrots Auto Attack (Fixed)
--// =========================
local WeaponAttack = ReplicatedStorage:WaitForChild("Remotes", 9e9):WaitForChild("AttacksServer", 9e9):WaitForChild("WeaponAttack", 9e9)
local weaponName = "Leather Grip Bat"

local function getNearestBrainrot()
    local folder = workspace:FindFirstChild("ScriptedMap") and workspace.ScriptedMap:FindFirstChild("Brainrots")
    if not folder then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
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

local function getBrainrotUUID(brainrot)
    if not brainrot then return nil end
    if brainrot:GetAttribute("Uuid") then
        return brainrot:GetAttribute("Uuid")
    end
    local uuidObj = brainrot:FindFirstChild("Uuid")
    if uuidObj and uuidObj:IsA("StringValue") then
        return uuidObj.Value
    end
    return brainrot.Name -- fallback
end

local function equipWeapon()
    local char = LocalPlayer.Character
    if not char then return end
    -- Already holding weapon?
    if char:FindFirstChildOfClass("Tool") and char:FindFirstChildOfClass("Tool").Name == weaponName then
        return
    end
    -- Search Backpack
    local tool = LocalPlayer.Backpack:FindFirstChild(weaponName)
    if tool then
        LocalPlayer.Character.Humanoid:EquipTool(tool)
    end
end

local function followAndAttack()
    local brainrot = getNearestBrainrot()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if brainrot and root then
        local hrp = brainrot:FindFirstChild("HumanoidRootPart") or brainrot:FindFirstChildWhichIsA("BasePart")
        if hrp then
            equipWeapon()
            -- follow closer
            root.CFrame = root.CFrame:Lerp(CFrame.new(hrp.Position + Vector3.new(0,3,0)), 0.2)
            -- attack
            local uuid = getBrainrotUUID(brainrot)
            if uuid then
                WeaponAttack:FireServer({uuid}) -- ✅ fixed args
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if followAttackEnabled then
        followAndAttack()
    end
end)

BrainrotsTab:Toggle({
    Name = "Auto Hit Brainrot",
    CurrentValue = false,
    Callback = function(state)
        followAttackEnabled = state
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

FarmTab:Toggle({
    Name = "Auto Equip Best Pet (Beta)",
    CurrentValue = false,
    Callback = function(state)
        autoEquipEnabled = state
        if state then
            task.spawn(function()
                local remote = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")
                while autoEquipEnabled do
                    fireRemoteSafely(remote,{{[2]="5"}})
                    task.wait(5)
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

ShopTab:Toggle({
    Name = "Auto Buy Seeds",
    CurrentValue = false,
    Callback = function(state)
        autoBuyEnabled = state
        if state then
            task.spawn(function()
                local remote = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")
                while autoBuyEnabled do
                    for _, seedName in ipairs(selectedSeeds) do
                        if not autoBuyEnabled then break end
                        fireRemoteSafely(remote,{{seedName,"\8"}})
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

ShopTab:Toggle({
    Name = "Auto Buy Gear",
    CurrentValue = false,
    Callback = function(state)
        autoBuyGearEnabled = state
        if state then
            task.spawn(function()
                local remote = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")
                while autoBuyGearEnabled do
                    for _, gearName in ipairs(selectedGears) do
                        if not autoBuyGearEnabled then break end
                        fireRemoteSafely(remote,{{gearName,"\26"}})
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



-- Unlimited Jump Toggle
local unlimitedJump = false
MiscTab:Toggle({
    Name = "Unlimited Jump",
    CurrentValue = false,
    Callback = function(state)
        unlimitedJump = state
    end
})

-- Listen for jumping
game:GetService("UserInputService").JumpRequest:Connect(function()
    if unlimitedJump and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

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
            -- Reset (approx defaults)
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

--// =========================
-- Visual Tab
--// =========================



VisualTab:Dropdown({
    Name = "Select Visual(s)",
    Options = {"Board","Rows","Plants"},
    MultiSelection = true,
    CurrentOption = {},
    Callback = function(list)
        selectedVisuals = list
        -- Show description only if "Rows" is selected
        if table.find(list, "Rows") then
            rowsInfoLabel:Set('<font color="rgb(255,0,0)">⚠️ If you hide Rows, Brainrots may not show.\nDon\'t worry, it\'s just a visual change to reduce lag.</font>')
        else
            rowsInfoLabel:Set("") -- clear text
        end
    end
})

VisualTab:Toggle({
    Name = "Hide/Show Selected",
    CurrentValue = false,
    Callback = function(state)
        for _, visType in ipairs(selectedVisuals) do
            if visualTargets[visType] then
                if state then
                    -- Hide
                    hiddenObjects[visType] = {}
                    for _, obj in ipairs(visualTargets[visType]) do
                        if obj and obj.Parent then
                            table.insert(hiddenObjects[visType], obj.Parent)
                            obj.Parent = nil
                        end
                    end
                else
                    -- Restore
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