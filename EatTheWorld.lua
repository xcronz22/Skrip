-- ==========================================
-- EAT THE WORLD - LIGHTWEIGHT HUB V25 (CUSTOM WALK SPEED & STABILITY)
-- ==========================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 1. SISTEM AUTO SAVE (DENGAN WALK SPEED)
local settingsFile = "ETW_Settings_V25.json"
local settings = {
    AutoGrab = false,
    AutoEat = false,
    AutoSell = false,
    WideHitbox = false,
    HitboxSize = 100,
    WalkSpeedToggle = false,
    WalkSpeedValue = 16, -- Kecepatan normal Roblox
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

local uiName = "ETW_LightPanel_V25"
if parentGui:FindFirstChild(uiName) then parentGui[uiName]:Destroy() end

-- ==========================================
-- 3. PEMBUATAN UI
-- ==========================================
local uiScreen = Instance.new("ScreenGui")
uiScreen.Name = uiName
uiScreen.ResetOnSpawn = false
uiScreen.Parent = parentGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 410) -- Diperpanjang untuk menu Walk Speed
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
Title.Text = "ETW Tool - V25"
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

createToggle("Auto Grab", 40, "AutoGrab")
createToggle("Auto Eat", 85, "AutoEat")
createToggle("Auto Sell", 130, "AutoSell")

-- ====================================================
-- CUSTOM INPUT HITBOX UI
-- ====================================================
local hitBoxBtn = Instance.new("TextButton", MainFrame)
hitBoxBtn.Size = UDim2.new(0, 120, 0, 35)
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

hitboxInput.FocusLost:Connect(function()
    local val = tonumber(hitboxInput.Text)
    if val then settings.HitboxSize = val; saveSettings() else hitboxInput.Text = tostring(settings.HitboxSize) end
end)

-- ====================================================
-- CUSTOM INPUT WALK SPEED UI
-- ====================================================
local wsBtn = Instance.new("TextButton", MainFrame)
wsBtn.Size = UDim2.new(0, 120, 0, 35)
wsBtn.Position = UDim2.new(0, 20, 0, 220)
wsBtn.Font = Enum.Font.SourceSansBold
wsBtn.TextSize = 14
Instance.new("UICorner", wsBtn).CornerRadius = UDim.new(0, 6)
buttonRefs["WalkSpeedToggle"] = {button = wsBtn, label = "Walk Speed"}

wsBtn.MouseButton1Click:Connect(function()
    settings["WalkSpeedToggle"] = not settings["WalkSpeedToggle"]
    updateVisual("WalkSpeedToggle"); saveSettings()
end)
updateVisual("WalkSpeedToggle")

local wsInput = Instance.new("TextBox", MainFrame)
wsInput.Size = UDim2.new(0, 55, 0, 35)
wsInput.Position = UDim2.new(0, 145, 0, 220)
wsInput.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
wsInput.TextColor3 = Color3.fromRGB(255, 255, 255)
wsInput.Font = Enum.Font.SourceSansBold
wsInput.TextSize = 14
wsInput.Text = tostring(settings.WalkSpeedValue)
wsInput.PlaceholderText = "Speed"
Instance.new("UICorner", wsInput).CornerRadius = UDim.new(0, 6)

wsInput.FocusLost:Connect(function()
    local val = tonumber(wsInput.Text)
    if val then settings.WalkSpeedValue = val; saveSettings() else wsInput.Text = tostring(settings.WalkSpeedValue) end
end)

-- ====================================================

createToggle("Anti-Freeze (Move)", 265, "AntiFreeze")
createToggle("Auto Reward", 310, "AutoReward")
createToggle("Auto Cube", 355, "AutoCube")

MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; MinIcon.Position = MainFrame.Position; MinIcon.Visible = true end)
MinIcon.MouseButton1Click:Connect(function() MinIcon.Visible = false; MainFrame.Position = MinIcon.Position; MainFrame.Visible = true end)
CloseBtn.MouseButton1Click:Connect(function() uiScreen:Destroy() end)

-- ==========================================
-- 4. MESIN MULTI-THREAD (KEBAL ERROR & STUCK)
-- ==========================================

-- LOOP 1: AUTO GRAB 
task.spawn(function()
    while task.wait(0.5) do
        if not settings.AutoGrab then continue end
        local Char = LocalPlayer.Character
        if not Char then continue end
        local chunkValueObj = Char:FindFirstChild("CurrentChunk")
        local isHoldingChunk = (chunkValueObj and chunkValueObj.Value ~= nil)
        if not isHoldingChunk then
            pcall(function() Char.Events.Grab:FireServer(false, false, false) end)
        end
    end
end)

-- LOOP 2: AUTO EAT 
task.spawn(function()
    while task.wait(0.2) do
        if not settings.AutoEat then continue end
        local Char = LocalPlayer.Character
        if not Char then continue end
        local chunkValueObj = Char:FindFirstChild("CurrentChunk")
        local isHoldingChunk = (chunkValueObj and chunkValueObj.Value ~= nil)
        if isHoldingChunk then
            pcall(function() Char.Events.Eat:FireServer() end)
        end
    end
end)

-- LOOP 3: DYNAMIC WIDE HITBOX
task.spawn(function()
    while task.wait(1) do
        local Char = LocalPlayer.Character
        local radiusPart = Char and Char:FindFirstChild("Radius")
        if not radiusPart then continue end
        
        if settings.WideHitbox then
            local sizeValue = tonumber(settings.HitboxSize) or 100
            pcall(function() radiusPart.Size = Vector3.new(sizeValue, 50, sizeValue) end)
        else
            if radiusPart.Size.X > 20 then
                pcall(function() radiusPart.Size = Vector3.new(10, 10, 10) end)
            end
        end
    end
end)

-- ====================================================
-- LOOP 4: AGGRESSIVE WALK SPEED & ANTI-FREEZE (60 FPS Override)
-- ====================================================
local PlayerModule, Controls
pcall(function()
    PlayerModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))
    Controls = PlayerModule:GetControls()
end)

RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char then return end
    local Humanoid = Char:FindFirstChildOfClass("Humanoid")
    local RootPart = Char:FindFirstChild("HumanoidRootPart")
    
    if Humanoid then
        -- Jika Toggle WalkSpeed NYALA, paksakan terus menerus ke angka yang diketik
        if settings.WalkSpeedToggle then
            Humanoid.WalkSpeed = tonumber(settings.WalkSpeedValue) or 16
            
        -- Jika Toggle Mati, TAPI Anti-Freeze Nyala, cegah kecepatan jadi 0 (Standar Roblox 16)
        elseif settings.AntiFreeze and Humanoid.WalkSpeed < 5 then
            Humanoid.WalkSpeed = 16
        end
    end
    
    if settings.AntiFreeze then
        -- Cabut paksa gembok akar tubuh
        if RootPart and RootPart.Anchored then
            RootPart.Anchored = false
        end
        -- Paksa kontrol tetap aktif
        if Controls then
            pcall(function() Controls:Enable() end)
        end
    end
end)

-- LOOP 5: AUTO SELL
task.spawn(function()
    while task.wait(1) do
        if not settings.AutoSell then continue end
        local isFull = false
        pcall(function()
            local warningUI = PlayerGui.ScreenGui.Sell.WarningText
            if warningUI and warningUI.Visible then isFull = true end
        end)
        
        if isFull then
            local Char = LocalPlayer.Character
            if Char then
                pcall(function() Char.Events.Sell:FireServer() end)
                task.wait(1.5)
            end
        end
    end
end)

-- LOOP 6: AUTO CUBE & AUTO REWARD
task.spawn(function()
    while task.wait(1) do
        if settings.AutoCube then
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj.Name == "Cube" and obj:IsA("BasePart") then
                    local Char = LocalPlayer.Character
                    local Root = Char and Char:FindFirstChild("HumanoidRootPart")
                    if Root and firetouchinterest then
                        pcall(function()
                            firetouchinterest(Root, obj, 0)
                            firetouchinterest(Root, obj, 1)
                        end)
                    end
                end
            end
        end
        
        if settings.AutoReward then
            pcall(function()
                local rewardGrid = PlayerGui.ScreenGui.Rewards.TimedRewards.RewardGrid
                for _, template in pairs(rewardGrid:GetChildren()) do
                    if template.Name == "Template" and template:FindFirstChild("Time") then
                        if template.Time.Text == "Tap to claim!" then
                            local rewardFolder = LocalPlayer:WaitForChild("TimedRewards")
                            local rewardEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RewardEvent")
                            for _, rewardItem in pairs(rewardFolder:GetChildren()) do
                                rewardEvent:FireServer(rewardItem)
                            end
                            break
                        end
                    end
                end
            end)
        end
    end
end)
