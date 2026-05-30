-- ==========================================
-- EAT THE WORLD - LIGHTWEIGHT HUB V23 (CUSTOM HITBOX INPUT & ANTI-FREEZE)
-- ==========================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 1. SISTEM AUTO SAVE
local settingsFile = "ETW_Settings_V23.json"
local settings = {
    AutoGrab = false,
    AutoEat = false,
    AutoSell = false,
    WideHitbox = false,
    HitboxSize = 150, -- Default Size
    AntiFreeze = false,
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

local uiName = "ETW_LightPanel_V23"
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
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 15, 20)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
MainFrame.Parent = uiScreen

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -60, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ETW Tool - V23"
Title.TextColor3 = Color3.fromRGB(255, 200, 100)
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
MinIcon.BackgroundColor3 = Color3.fromRGB(20, 15, 20)
MinIcon.Text = "ETW"
MinIcon.TextColor3 = Color3.fromRGB(255, 200, 100)
MinIcon.Font = Enum.Font.SourceSansBold
MinIcon.TextSize = 14
MinIcon.Visible = false
MinIcon.Active = true
MinIcon.Draggable = true
Instance.new("UICorner", MinIcon).CornerRadius = UDim.new(1, 0)
MinIcon.Parent = uiScreen

local buttonRefs = {}

local function updateVisual(sKey)
    local ref = buttonRefs[sKey]
    if not ref then return end
    local b = ref.button
    local label = ref.label

    if settings[sKey] then
        b.Text = label .. ": ON"
        b.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
        b.TextColor3 = Color3.fromRGB(150, 255, 150)
    else
        b.Text = label .. ": OFF"
        b.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
        b.TextColor3 = Color3.fromRGB(255, 150, 150)
    end
end

local function createToggle(text, yPos, settingKey)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 180, 0, 35)
    btn.Position = UDim2.new(0, 20, 0, yPos)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    buttonRefs[settingKey] = {button = btn, label = text}
    
    btn.MouseButton1Click:Connect(function()
        settings[settingKey] = not settings[settingKey]
        updateVisual(settingKey); saveSettings()
    end)
    updateVisual(settingKey)
end

-- Membuat Standar Toggle
createToggle("Auto Grab", 40, "AutoGrab")
createToggle("Auto Eat", 85, "AutoEat")
createToggle("Auto Sell", 130, "AutoSell")

-- ====================================================
-- PEMBUATAN CUSTOM TOGGLE & INPUT UNTUK HITBOX
-- ====================================================
local hitBoxBtn = Instance.new("TextButton", MainFrame)
hitBoxBtn.Size = UDim2.new(0, 120, 0, 35) -- Lebih pendek untuk ruang Input Box
hitBoxBtn.Position = UDim2.new(0, 20, 0, 175)
hitBoxBtn.Font = Enum.Font.SourceSansBold
hitBoxBtn.TextSize = 14
Instance.new("UICorner", hitBoxBtn).CornerRadius = UDim.new(0, 6)
buttonRefs["WideHitbox"] = {button = hitBoxBtn, label = "Wide Hitbox"}

hitBoxBtn.MouseButton1Click:Connect(function()
    settings["WideHitbox"] = not settings["WideHitbox"]
    updateVisual("WideHitbox"); saveSettings()
end)
updateVisual("WideHitbox")

local hitboxInput = Instance.new("TextBox", MainFrame)
hitboxInput.Size = UDim2.new(0, 55, 0, 35)
hitboxInput.Position = UDim2.new(0, 145, 0, 175)
hitboxInput.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
hitboxInput.TextColor3 = Color3.fromRGB(255, 255, 255)
hitboxInput.Font = Enum.Font.SourceSansBold
hitboxInput.TextSize = 14
hitboxInput.Text = tostring(settings.HitboxSize)
hitboxInput.PlaceholderText = "Size"
Instance.new("UICorner", hitboxInput).CornerRadius = UDim.new(0, 6)

-- Event saat menekan Enter pada TextBox
hitboxInput.FocusLost:Connect(function()
    local val = tonumber(hitboxInput.Text)
    if val then
        settings.HitboxSize = val
        saveSettings()
    else
        hitboxInput.Text = tostring(settings.HitboxSize) -- Kembalikan ke angka awal jika yang diketik huruf
    end
end)
-- ====================================================

createToggle("Anti-Freeze (Move)", 220, "AntiFreeze")
createToggle("Auto Reward", 265, "AutoReward")
createToggle("Auto Cube", 310, "AutoCube")

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
-- 5. LOGIKA PERMAINAN (V23 - CUSTOM HITBOX)
-- ==========================================

local originalWalkSpeed = 16

task.spawn(function()
    local lastGrabTick = 0
    local lastEatTick = 0
    local isSellingCooldown = false

    while task.wait(0.05) do
        if not uiScreen.Parent then break end
        
        local Character = LocalPlayer.Character
        local Events = Character and Character:FindFirstChild("Events")
        if not Character or not Events then continue end
        
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        if not Humanoid or not RootPart then continue end
        
        sweepCubes()

        -- ====================================================
        -- 1. DYNAMIC WIDE HITBOX (Menggunakan Input Pengguna)
        -- ====================================================
        local radiusPart = Character:FindFirstChild("Radius")
        if radiusPart then
            if settings.WideHitbox then
                -- Ambil angka dari TextBox (misal 50, 150, 200)
                local sizeValue = tonumber(settings.HitboxSize) or 150
                -- Kita terapkan Size X dan Z sesuai input, Y (ketinggian) biarkan standar (50) agar tidak error ke bawah map
                radiusPart.Size = Vector3.new(sizeValue, 50, sizeValue)
            else
                -- Kembalikan ke ukuran normal
                if radiusPart.Size.X > 50 then
                    radiusPart.Size = Vector3.new(10, 10, 10)
                end
            end
        end

        -- ====================================================
        -- 2. ANTI-FREEZE (Mencegah karakter nyangkut/berhenti)
        -- ====================================================
        if settings.AntiFreeze then
            if Humanoid.WalkSpeed > 5 then
                originalWalkSpeed = Humanoid.WalkSpeed
            end
            
            if Humanoid.WalkSpeed < 2 then
                Humanoid.WalkSpeed = originalWalkSpeed
            end
            
            if RootPart.Anchored then
                RootPart.Anchored = false
            end
        end
        -- ====================================================
        
        -- AUTO SELL
        if settings.AutoSell and not isSellingCooldown then
            local isFull = false
            pcall(function()
                local warningUI = PlayerGui.ScreenGui.Sell.WarningText
                if warningUI and warningUI.Visible then isFull = true end
            end)
            
            if isFull then
                isSellingCooldown = true
                Events:WaitForChild("Sell"):FireServer()
                task.wait(1.5) 
                isSellingCooldown = false
                continue 
            end
        end
        if isSellingCooldown then continue end
        
        -- CEK TANGAN
        local chunkValueObj = Character:FindFirstChild("CurrentChunk")
        local isHoldingChunk = (chunkValueObj and chunkValueObj.Value ~= nil)
        
        -- AUTO EAT
        if settings.AutoEat and isHoldingChunk then
            if tick() - lastEatTick > 0.2 then 
                pcall(function() Events:WaitForChild("Eat"):FireServer() end)
                lastEatTick = tick()
            end
        end
            
        -- AUTO GRAB
        if settings.AutoGrab and not isHoldingChunk then
            if tick() - lastGrabTick > 0.5 then
                pcall(function() Events:WaitForChild("Grab"):FireServer(false, false, false) end)
                lastGrabTick = tick()
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
