-- ==========================================
-- EAT THE WORLD - LIGHTWEIGHT HUB V18 (RADAR-LESS & SMART MOVEMENT)
-- ==========================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 1. SISTEM AUTO SAVE
local settingsFile = "ETW_Settings_V18.json"
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

local uiName = "ETW_LightPanel_V18"
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
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
MainFrame.Parent = uiScreen

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -60, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ETW Tool - V18"
Title.TextColor3 = Color3.fromRGB(200, 150, 255)
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
MinIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MinIcon.Text = "ETW"
MinIcon.TextColor3 = Color3.fromRGB(200, 150, 255)
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
        if settingKey == "AutoMove" and settings.AutoMove then
            settings.AutoTP = false; updateVisual("AutoTP")
        elseif settingKey == "AutoTP" and settings.AutoTP then
            settings.AutoMove = false; updateVisual("AutoMove")
        end
        updateVisual(settingKey); saveSettings()
    end)
    updateVisual(settingKey)
end

createToggle("Auto Grab", 40, "AutoGrab")
createToggle("Auto Eat", 85, "AutoEat")
createToggle("Auto Sell", 130, "AutoSell")
createToggle("Auto Move (All)", 175, "AutoMove")
createToggle("Auto TP (Fragment Only)", 220, "AutoTP")
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
-- 5. LOGIKA PERMAINAN (V18 - TARGETING TANPA RADAR)
-- ==========================================

local mapDescendantsCache = {}
local lastCacheTick = 0

-- Mencari target dengan menghitung jarak matematis saja (Sangat ringan, 0% physics lag)
local function getLightweightTarget(RootPart, onlyFragmentable)
    local mapFolder = Workspace:FindFirstChild("Map")
    if not mapFolder then return nil end

    -- Update cache setiap 10 detik agar tidak usah membaca Workspace terus-menerus
    if tick() - lastCacheTick > 10 or #mapDescendantsCache == 0 then
        mapDescendantsCache = mapFolder:GetDescendants()
        lastCacheTick = tick()
    end

    local nearestPart = nil
    local shortestDist = math.huge

    for _, obj in ipairs(mapDescendantsCache) do
        if obj:IsA("BasePart") and obj.CanCollide and obj.Name ~= "Baseplate" then
            local parent = obj.Parent
            -- Pastikan ini objek valid (punya Size, bukan Player/Humanoid)
            if parent and parent:FindFirstChild("Size") and not parent:FindFirstChild("Humanoid") then
                
                local isValidTarget = false
                if onlyFragmentable then
                    -- KHUSUS AUTO TP: Hanya incar yang berada di dalam folder "fragmentable"
                    if string.find(string.lower(parent.Name), "fragment") then
                        isValidTarget = true
                    end
                else
                    -- UNTUK AUTO MOVE: Bebas (Building / Fragmentable)
                    isValidTarget = true
                end

                if isValidTarget then
                    local dist = (RootPart.Position - obj.Position).Magnitude
                    if dist > 2 and dist < shortestDist then
                        shortestDist = dist
                        nearestPart = obj
                    end
                end
            end
        end
    end

    return nearestPart
end

-- LOOP UTAMA
task.spawn(function()
    local lastStuckPos = Vector3.zero
    local lastStuckTick = tick()
    local lastGrabTick = 0
    local lastEatTick = 0
    
    local moveTarget = nil
    local tpTarget = nil
    local isSellingCooldown = false

    while task.wait(0.05) do
        if not uiScreen.Parent then break end
        
        -- SISTEM IDLE SLEEP: Jika tidak ada yang nyala, skrip tidur total.
        if not (settings.AutoGrab or settings.AutoEat or settings.AutoSell or settings.AutoMove or settings.AutoTP or settings.AutoCube) then
            continue
        end
        
        local Character = LocalPlayer.Character
        local Events = Character and Character:FindFirstChild("Events")
        if not Character or not Events then continue end
        
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if not RootPart or not Humanoid then continue end
        
        sweepCubes()
        
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
        
        -- CEK APAKAH SEDANG MEMEGANG CHUNK
        local chunkValueObj = Character:FindFirstChild("CurrentChunk")
        local isHoldingChunk = (chunkValueObj and chunkValueObj.Value ~= nil)
        
        -- 1. AUTO EAT (Hanya jika memegang)
        if settings.AutoEat and isHoldingChunk then
            if tick() - lastEatTick > 0.1 then 
                pcall(function() Events:WaitForChild("Eat"):FireServer() end)
                lastEatTick = tick()
            end
        end
            
        -- 2. AUTO GRAB (Hanya jika tidak memegang)
        if settings.AutoGrab and not isHoldingChunk then
            if tick() - lastGrabTick > 0.2 then
                -- Coba Grab dulu sebelum bergerak
                pcall(function() Events:WaitForChild("Grab"):FireServer(false, false, false) end)
                lastGrabTick = tick()
                
                -- Tunggu sebentar untuk membiarkan server memproses Grab
                task.wait(0.15)
                
                -- Cek ulang apakah Grab berhasil mendapatkan sesuatu
                local recheckChunk = Character:FindFirstChild("CurrentChunk")
                isHoldingChunk = (recheckChunk and recheckChunk.Value ~= nil)
            end
        end
        
        -- 3. PERGERAKAN PINTAR (HANYA BERGERAK JIKA GRAB GAGAL / TANGAN MASIH KOSONG)
        if not isHoldingChunk then
            if settings.AutoTP then
                -- Cari target KHUSUS Fragmentable
                if not tpTarget or not tpTarget.Parent then
                    tpTarget = getLightweightTarget(RootPart, true)
                end
                
                if tpTarget then
                    -- TP tepat ke objek tersebut (sedikit di atasnya)
                    RootPart.CFrame = tpTarget.CFrame + Vector3.new(0, (tpTarget.Size.Y / 2) + Humanoid.HipHeight + 2, 0)
                    task.wait(0.2) -- Jeda TP agar tidak brutal
                end

            elseif settings.AutoMove then
                -- Cari target BEBAS (Building / Fragmentable)
                if not moveTarget or not moveTarget.Parent then
                    moveTarget = getLightweightTarget(RootPart, false)
                end
                
                if moveTarget then
                    Humanoid:MoveTo(moveTarget.Position)
                    
                    -- Anti nyangkut (Stuck Detector)
                    if tick() - lastStuckTick > 1 then
                        local moveDist = (RootPart.Position - lastStuckPos).Magnitude
                        if moveDist < 1.5 then 
                            Humanoid.Jump = true
                            moveTarget = nil -- Reset target jika terlanjur nyangkut
                        end
                        lastStuckPos = RootPart.Position
                        lastStuckTick = tick()
                    end
                end
            end
        else
            -- Jika sudah memegang barang, lupakan target lama. 
            -- Berdiri santai sambil makan (Auto Eat mengambil alih).
            moveTarget = nil
            tpTarget = nil
        end
    end
end)

-- LOOP AUTO REWARD (Terpisah agar aman)
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
