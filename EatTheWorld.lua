-- ==========================================
-- EAT THE WORLD - LIGHTWEIGHT HUB V4 (FIXED)
-- ==========================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 1. SISTEM AUTO SAVE
local settingsFile = "ETW_Settings_V4.json"
local settings = {
    AutoGrab = false,
    AutoEat = false,
    AutoSell = false,
    AutoMove = false,
    AutoTP = false,
    AutoReward = false
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
pcall(function()
    if gethui then parentGui = gethui() else parentGui = CoreGui end
end)

local uiName = "ETW_LightPanel_V4"
if parentGui:FindFirstChild(uiName) then parentGui[uiName]:Destroy() end

-- ==========================================
-- 3. PEMBUATAN UI
-- ==========================================
local uiScreen = Instance.new("ScreenGui")
uiScreen.Name = uiName
uiScreen.ResetOnSpawn = false
uiScreen.Parent = parentGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 320) -- Tinggi ditambah agar muat 6 tombol
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
Title.Text = "ETW Tool - V4"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
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
    
    local function updateVisual()
        if settings[settingKey] then
            btn.Text = text .. ": ON"
            btn.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
            btn.TextColor3 = Color3.fromRGB(150, 255, 150)
        else
            btn.Text = text .. ": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
            btn.TextColor3 = Color3.fromRGB(255, 150, 150)
        end
    end
    
    updateVisual()
    
    btn.MouseButton1Click:Connect(function()
        settings[settingKey] = not settings[settingKey]
        
        -- Proteksi Move vs TP
        if settingKey == "AutoMove" and settings.AutoMove then
            settings.AutoTP = false
        elseif settingKey == "AutoTP" and settings.AutoTP then
            settings.AutoMove = false
        end
        
        for key, button in pairs(buttonRefs) do
            if settings[key] then
                button.Text = string.gsub(button.Text, ": OFF", ": ON")
                button.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
                button.TextColor3 = Color3.fromRGB(150, 255, 150)
            else
                button.Text = string.gsub(button.Text, ": ON", ": OFF")
                button.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
                button.TextColor3 = Color3.fromRGB(255, 150, 150)
            end
        end
        saveSettings()
    end)
end

-- Susunan tombol yang baru (Dipisah)
createToggle("Auto Grab (Ambil)", 40, "AutoGrab")
createToggle("Auto Eat (Makan)", 85, "AutoEat")
createToggle("Auto Sell (Max)", 130, "AutoSell")
createToggle("Auto Move (Jalan)", 175, "AutoMove")
createToggle("Auto TP Farm", 220, "AutoTP")
createToggle("Auto Timed Reward", 265, "AutoReward")

MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; MinIcon.Position = MainFrame.Position; MinIcon.Visible = true end)
MinIcon.MouseButton1Click:Connect(function() MinIcon.Visible = false; MainFrame.Position = MinIcon.Position; MainFrame.Visible = true end)
CloseBtn.MouseButton1Click:Connect(function() uiScreen:Destroy() end)

-- ==========================================
-- 4. LOGIKA PERMAINAN
-- ==========================================

-- MEMBACA OBJECTVALUE DARI DEX EXPLORER
local function isHoldingFood()
    local chunksFolder = Workspace:FindFirstChild("Chunks")
    if not chunksFolder then return false end
    for _, chunk in pairs(chunksFolder:GetChildren()) do
        local ownerTag = chunk:FindFirstChild("Owner")
        if ownerTag then
            -- Fix: Cek apakah class-nya ObjectValue (karena ini yang menunjuk langsung ke karakter/player)
            if ownerTag:IsA("ObjectValue") and ownerTag.Value and ownerTag.Value.Name == LocalPlayer.Name then 
                return true 
            elseif ownerTag:IsA("StringValue") and ownerTag.Value == LocalPlayer.Name then
                return true
            end
        end
    end
    return false
end

-- FUNGSI RELOKASI TANPA MENGGANGGU KECEPATAN (WALKSPEED) ASLI
local function relocateCharacter()
    local Character = LocalPlayer.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    
    if Humanoid and RootPart and Humanoid.Health > 0 then
        local rx = math.random(-35, 35) -- Radius dilebarkan sedikit
        local rz = math.random(-35, 35)
        local targetPosition = RootPart.Position + Vector3.new(rx, 0, rz)
        
        if settings.AutoTP then
            RootPart.CFrame = CFrame.new(targetPosition)
            task.wait(0.2)
        elseif settings.AutoMove then
            -- Murni memanggil fungsi bergerak satu kali, tanpa manipulasi WalkSpeed
            Humanoid:MoveTo(targetPosition)
            local t = tick()
            -- Tunggu sampai bergerak selesai, atau maksimal 2 detik agar tidak nyangkut
            repeat 
                task.wait(0.1) 
            until (tick() - t > 2) or (RootPart.Position - targetPosition).Magnitude < 4 or not settings.AutoMove
        end
    end
end

-- LOOP GRINDING UTAMA (TERPISAH GRAB & EAT)
task.spawn(function()
    while task.wait(0.05) do
        if not uiScreen.Parent then break end
        
        local Character = LocalPlayer.Character
        local Events = Character and Character:FindFirstChild("Events")
        
        if Character and Events then
            local isFull = false
            pcall(function()
                local warningUI = PlayerGui.ScreenGui.Sell.WarningText
                if warningUI and warningUI.Visible then isFull = true end
            end)
            
            if settings.AutoSell and isFull then
                Events:WaitForChild("Sell"):FireServer()
                task.wait(0.5)
            elseif not isFull then
                
                -- Cek apakah kita sedang memegang makanan saat ini
                if isHoldingFood() then
                    -- Tangan ada isinya -> Eksekusi Auto Eat
                    if settings.AutoEat then
                        Events:WaitForChild("Eat"):FireServer()
                        task.wait(0.05)
                    end
                else
                    -- Tangan kosong -> Eksekusi Auto Grab
                    if settings.AutoGrab then
                        Events:WaitForChild("Grab"):FireServer(false, false, false)
                        task.wait(0.3) -- Jeda untuk melihat hasil grab
                        
                        -- Cek ulang setelah grab, jika tetap kosong = tanah habis!
                        if not isHoldingFood() then
                            -- Saatnya pindah tempat
                            if settings.AutoMove or settings.AutoTP then
                                relocateCharacter()
                            end
                        end
                    end
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
