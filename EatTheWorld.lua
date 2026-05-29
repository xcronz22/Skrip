-- ==========================================
-- EAT THE WORLD - LIGHTWEIGHT HUB V13 (ABSOLUTE CHUNK OWNER)
-- ==========================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 1. SISTEM AUTO SAVE
local settingsFile = "ETW_Settings_V13.json"
local settings = {
    AutoGrab = false,
    AutoEat = false,
    AutoSell = false,
    AutoMove = false,
    AutoTP = false,
    AutoReward = false,
    AutoCube = false
}

local function saveSettings()
    if writefile then
        pcall(function() writefile(settingsFile, HttpService:JSONEncode(settings)) end)
    end
end

local function loadSettings()
    if isfile and readfile then
        local success, hasFile = pcall(function() return isfile(settingsFile) end)
        if success and hasFile then
            local s2, decoded = pcall(function() return HttpService:JSONDecode(readfile(settingsFile)) end)
            if s2 and type(decoded) == "table" then
                for k, v in pairs(decoded) do settings[k] = v end
            end
        end
    end
end
loadSettings()

-- 2. PENEMPATAN GUI
local parentGui = PlayerGui
pcall(function() if gethui then parentGui = gethui() else parentGui = CoreGui end end)

local uiName = "ETW_LightPanel_V13"
if parentGui:FindFirstChild(uiName) then parentGui[uiName]:Destroy() end

-- ==========================================
-- 3. PEMBUATAN UI
-- ==========================================
local uiScreen = Instance.new("ScreenGui")
uiScreen.Name = uiName
uiScreen.ResetOnSpawn = false
uiScreen.Parent = parentGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 365)
MainFrame.Position = UDim2.new(0, 20, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
MainFrame.Parent = uiScreen

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -60, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ETW Tool - V13"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinBtn = Instance.new("TextButton", MainFrame)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -60, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "_"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinBtn.TextSize = 18

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 16

local MinIcon = Instance.new("TextButton")
MinIcon.Size = UDim2.new(0, 40, 0, 40)
MinIcon.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MinIcon.Text = "ETW"
MinIcon.TextColor3 = Color3.fromRGB(0, 200, 255)
MinIcon.Font = Enum.Font.SourceSansBold
MinIcon.TextSize = 14
MinIcon.Visible = false
MinIcon.Active = true
MinIcon.Draggable = true
Instance.new("UICorner", MinIcon).CornerRadius = UDim.new(1, 0)
MinIcon.Parent = uiScreen

local buttonRefs = {}

local function createToggle(text, yPos, settingKey)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 180, 0, 35)
    btn.Position = UDim2.new(0, 20, 0, yPos)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    buttonRefs[settingKey] = btn
    
    local function updateVisual(buttonToUpdate)
        local b = buttonToUpdate or btn
        local sKey = nil
        for k, v in pairs(buttonRefs) do if v == b then sKey = k; break end end
        if not sKey then return end

        if settings[sKey] then
            b.Text = string.gsub(b.Text, ": OFF", ": ON")
            b.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
            b.TextColor3 = Color3.fromRGB(150, 255, 150)
        else
            b.Text = string.gsub(b.Text, ": ON", ": OFF")
            b.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
            b.TextColor3 = Color3.fromRGB(255, 150, 150)
        end
    end
    
    btn.MouseButton1Click:Connect(function()
        settings[settingKey] = not settings[settingKey]
        
        if settingKey == "AutoMove" and settings.AutoMove then
            settings.AutoTP = false
            updateVisual(buttonRefs["AutoTP"])
        elseif settingKey == "AutoTP" and settings.AutoTP then
            settings.AutoMove = false
            updateVisual(buttonRefs["AutoMove"])
        end
        
        updateVisual(btn)
        saveSettings()
    end)
    updateVisual(btn)
end

createToggle("Auto Grab (Cerdas)", 40, "AutoGrab")
createToggle("Auto Eat (Makan)", 85, "AutoEat")
createToggle("Auto Sell (Max)", 130, "AutoSell")
createToggle("Auto Move (Jalan)", 175, "AutoMove")
createToggle("Auto TP (Di Atas)", 220, "AutoTP")
createToggle("Auto Timed Reward", 265, "AutoReward")
createToggle("Auto Cube (Instan)", 310, "AutoCube")

MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; MinIcon.Position = MainFrame.Position; MinIcon.Visible = true end)
MinIcon.MouseButton1Click:Connect(function() MinIcon.Visible = false; MainFrame.Position = MinIcon.Position; MainFrame.Visible = true end)
CloseBtn.MouseButton1Click:Connect(function() uiScreen:Destroy() end)

-- ==========================================
-- 4. EVENT-BASED AUTO CUBE
-- ==========================================
local function grabCubeInstantly(obj)
    if settings.AutoCube and obj.Name == "Cube" and obj:IsA("BasePart") and obj:FindFirstChildOfClass("TouchTransmitter") then
        local Char = LocalPlayer.Character
        if Char then
            local Root = Char:FindFirstChild("HumanoidRootPart")
            if Root and firetouchinterest then
                pcall(function()
                    firetouchinterest(Root, obj, 0)
                    task.wait(0.01)
                    firetouchinterest(Root, obj, 1)
                end)
            end
        end
    end
end

Workspace.ChildAdded:Connect(grabCubeInstantly)
local function sweepCubes()
    if not settings.AutoCube then return end
    for _, obj in ipairs(Workspace:GetChildren()) do grabCubeInstantly(obj) end
end

-- ==========================================
-- 5. LOGIKA PERMAINAN (V13 - WORKSPACE.CHUNKS OWNER TAG)
-- ==========================================

-- LOGIKA BARU: Scan Workspace.Chunks untuk tag Owner
local function isHoldingFood()
    local chunksFolder = Workspace:FindFirstChild("Chunks")
    if not chunksFolder then return false end
    
    for _, chunk in ipairs(chunksFolder:GetChildren()) do
        local ownerTag = chunk:FindFirstChild("Owner")
        if ownerTag then
            -- Mendukung ObjectValue (Player) atau StringValue (Nama)
            if (ownerTag:IsA("ObjectValue") and ownerTag.Value == LocalPlayer) or 
               (ownerTag:IsA("StringValue") and ownerTag.Value == LocalPlayer.Name) then
                return true
            end
        end
    end
    return false
end

local blacklistedTargets = {} 

local function getSmartTarget(RootPart, Humanoid)
    local mapFolder = Workspace:FindFirstChild("Map")
    if not mapFolder then return nil, nil end

    local params = OverlapParams.new()
    params.FilterDescendantsInstances = {mapFolder}
    params.FilterType = Enum.RaycastFilterType.Include

    local searchRadius = 150 + (RootPart.Size.Y * 2) 
    local parts = Workspace:GetPartBoundsInRadius(RootPart.Position, searchRadius, params)

    local nearestPart = nil
    local shortestDist = math.huge

    for _, part in ipairs(parts) do
        if part.Name == "Smooth Block Model" and part:IsA("BasePart") and part.CanCollide then
            
            if blacklistedTargets[part] and (tick() - blacklistedTargets[part] < 10) then
                continue 
            end

            local dist = (RootPart.Position - part.Position).Magnitude
            if dist > 1 and dist < shortestDist then
                shortestDist = dist
                nearestPart = part
            end
        end
    end

    if nearestPart then
        local characterHeightOffset = Humanoid.HipHeight + (RootPart.Size.Y / 2)
        local targetPosition = Vector3.new(
            nearestPart.Position.X,
            nearestPart.Position.Y + (nearestPart.Size.Y / 2) + characterHeightOffset + 2,
            nearestPart.Position.Z
        )
        return targetPosition, nearestPart
    end
    
    return nil, nil
end

local function getFallbackSmoothBlock()
    local mapFolder = Workspace:FindFirstChild("Map")
    if mapFolder then
        for _, desc in ipairs(mapFolder:GetDescendants()) do
            if desc.Name == "Smooth Block Model" and desc:IsA("BasePart") then
                return desc
            end
        end
    end
    return nil
end

-- LOOP UTAMA
task.spawn(function()
    local lastStuckPos = Vector3.zero
    local lastStuckTick = tick()
    local lastGrabTick = tick()
    
    local currentTargetPart = nil
    local grabFails = 0 
    local isSellingCooldown = false

    while task.wait(0.05) do
        if not uiScreen.Parent then break end
        
        local Character = LocalPlayer.Character
        local Events = Character and Character:FindFirstChild("Events")
        if not Character or not Events then continue end
        
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if not RootPart or not Humanoid then continue end
        
        sweepCubes()
        
        -- CEK JUAL DULU
        local isFull = false
        pcall(function()
            local warningUI = PlayerGui.ScreenGui.Sell.WarningText
            if warningUI and warningUI.Visible then isFull = true end
        end)
        
        if settings.AutoSell and isFull and not isSellingCooldown then
            isSellingCooldown = true
            Events:WaitForChild("Sell"):FireServer()
            task.wait(1.5) 
            isSellingCooldown = false
            continue 
        end
        
        if isSellingCooldown then continue end
        
        -- CEK MAKAN (Menggunakan deteksi Owner di Workspace.Chunks)
        local holding = isHoldingFood()
        if settings.AutoEat and holding then
            pcall(function() Events:WaitForChild("Eat"):FireServer() end)
            grabFails = 0 -- Reset blacklist strike
        end
            
        local targetPos, targetPart = getSmartTarget(RootPart, Humanoid)
        
        if targetPart then
            if targetPart ~= currentTargetPart then
                currentTargetPart = targetPart
                grabFails = 0
            end

            -- LOGIKA GRAB & STRIKE SYSTEM
            if settings.AutoGrab and (tick() - lastGrabTick > 0.3) then
                local distToPart = (RootPart.Position - targetPart.Position).Magnitude
                local dynamicGrabRange = 15 + (RootPart.Size.Y * 1.8) 
                
                if distToPart <= dynamicGrabRange then
                    pcall(function() Events:WaitForChild("Grab"):FireServer(false, false, false) end)
                    lastGrabTick = tick()
                    
                    task.wait(0.15)
                    -- Jika setelah Grab, namamu tidak ada di Workspace.Chunks, berarti gagal
                    if not isHoldingFood() then
                        grabFails = grabFails + 1
                        
                        if grabFails >= 4 then
                            blacklistedTargets[targetPart] = tick()
                            currentTargetPart = nil
                            grabFails = 0
                            
                            Humanoid.Jump = true
                            continue
                        end
                    end
                end
            end
            
            -- LOGIKA PERGERAKAN (Hanya jalan/TP jika tidak punya Chunk)
            if not holding then
                if settings.AutoTP then
                    RootPart.CFrame = CFrame.new(targetPos)
                    task.wait(0.1)
                elseif settings.AutoMove then
                    if (Humanoid.WalkToPoint - targetPos).Magnitude > 3 then
                        Humanoid:MoveTo(targetPos)
                    end
                    
                    if tick() - lastStuckTick > 0.8 then
                        local moveDist = (RootPart.Position - lastStuckPos).Magnitude
                        if moveDist < 1.5 then 
                            Humanoid.Jump = true 
                        end
                        lastStuckPos = RootPart.Position
                        lastStuckTick = tick()
                    end
                end
            end
        else
            if settings.AutoMove or settings.AutoTP then
                local fallbackPart = getFallbackSmoothBlock()
                if fallbackPart then
                    RootPart.CFrame = CFrame.new(fallbackPart.Position) + Vector3.new(0, fallbackPart.Size.Y + 10, 0)
                    task.wait(0.5)
                end
            end
        end
    end
end)

-- LOOP AUTO REWARD
task.spawn(function()
    while task.wait(3) do
        if not uiScreen.Parent then break end
        if settings.AutoReward then
            pcall(function()
                local rewardGrid = PlayerGui.ScreenGui.Rewards.TimedRewards.RewardGrid
                local canClaim = false
                for _, template in pairs(rewardGrid:GetChildren()) do
                    if template.Name == "Template" and template:FindFirstChild("Time") then
                        if template.Time.Text == "Tap to claim!" then
                            canClaim = true
                            break
                        end
                    end
                end
                if canClaim then
                    local rewardFolder = LocalPlayer:WaitForChild("TimedRewards")
                    local rewardEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RewardEvent")
                    for _, rewardItem in pairs(rewardFolder:GetChildren()) do
                        rewardEvent:FireServer(rewardItem)
                        task.wait(0.1)
                    end
                end
            end)
        end
    end
end)
