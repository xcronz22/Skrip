-- ==========================================
-- GAME GUARD: PASTIKAN HANYA JALAN DI PICKAXE TYCOON
-- ==========================================
if not game:IsLoaded() then game.Loaded:Wait() end
if not workspace:FindFirstChild("Plots") then
    print("[SYSTEM] Folder 'Plots' tidak ditemukan. Skrip Pickaxe Tycoon dibatalkan!")
    return
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- Bersihkan UI Lama jika ada
if CoreGui:FindFirstChild("PickaxeTycoonPanel") then
    CoreGui.PickaxeTycoonPanel:Destroy()
end

-- ==========================================
-- UNIVERSAL AUTO REJOIN (ANTI KICK/DISCONNECT)
-- ==========================================
local function HandleErrorPrompt(child)
	if child.Name == 'ErrorPrompt' then
		print("[AUTO REJOIN] Terdeteksi Disconnect/Kick! Mencoba rejoin dalam 5 detik...")
		task.wait(5)
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end
end

local promptOverlay = CoreGui:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")
promptOverlay.ChildAdded:Connect(HandleErrorPrompt)
for _, child in ipairs(promptOverlay:GetChildren()) do
	HandleErrorPrompt(child)
end

-- ==========================================
-- DETEKSI PLOT SELEKSI DINAMIS
-- ==========================================
local function GetMyPlot()
    local character = LocalPlayer.Character
    local attr = character and character:GetAttribute("assignedPlot") or LocalPlayer:GetAttribute("assignedPlot")
    if attr then
        local p = workspace.Plots:FindFirstChild(tostring(attr))
        if p then return p end
    end
    return workspace.Plots:FindFirstChild("Plot_3") -- Fallback
end

-- ==========================================
-- LOGIKA EMULASI SENTUHAN TOMBOL FISIK
-- ==========================================
local function TouchButton(buttonInstance)
    if buttonInstance and buttonInstance:IsA("BasePart") and firetouchinterest then
        local character = LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if root then
            firetouchinterest(buttonInstance, root, 0)
            task.wait(0.02)
            firetouchinterest(buttonInstance, root, 1)
        end
    end
end

-- ==========================================
-- SMART EXTRACTOR ANGKA (K, M, B, T)
-- ==========================================
local function ExtractNumber(textObject)
    if not textObject then return 0 end
    local text = string.upper(tostring(textObject.Text))
    local numberStr = string.match(text, "[%d%.]+")
    local num = tonumber(numberStr) or 0
    
    if string.find(text, "K") then num = num * 1000
    elseif string.find(text, "M") then num = num * 1000000
    elseif string.find(text, "B") then num = num * 1000000000
    elseif string.find(text, "T") then num = num * 1000000000000 end
    return num
end

-- ==========================================
-- STATE VARIABEL & CONFIG
-- ==========================================
local isLoadedCompletely = false
local SaveFileName = "PickaxeTycoon_Config.json"
local isMinimized = false

local toggles = {
    AutoLoot = false,
    AutoDeposit = false,
    AutoCollect = false,
    AutoMerge = false,
    AutoBuy = false,
    AutoUnlock = false,
    AutoPerSecond = false,
    AutoGroup = false,
    OreMultiplierEnabled = false, -- Fitur Baru
    TargetMultiplier = 1.0        -- Fitur Baru
}

local function SaveConfig()
    if not isLoadedCompletely then return end
    if writefile then pcall(function() writefile(SaveFileName, HttpService:JSONEncode(toggles)) end) end
end

local function LoadConfig()
    if isfile and isfile(SaveFileName) and readfile then
        local success, result = pcall(function() return HttpService:JSONDecode(readfile(SaveFileName)) end)
        if success and result then
            for k, v in pairs(result) do if toggles[k] ~= nil then toggles[k] = v end end
        end
    end
end

-- ==========================================
-- INITIALIZE INTERFACE (GUI PANEL)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "PickaxeTycoonPanel"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.15, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 420) -- Diperpanjang untuk menu baru
MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.ClipsDescendants = true

local TitleBar = Instance.new("TextLabel", MainFrame)
TitleBar.Text = "  Pickaxe Tycoon v2.12"
TitleBar.Size = UDim2.new(1, 0, 0, 35); TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TitleBar.TextColor3 = Color3.new(1, 1, 1); TitleBar.Font = Enum.Font.SourceSansBold; TitleBar.TextSize = 15
TitleBar.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Text = "X"; CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -35, 0, 2.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50); CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Text = "-"; MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(1, -70, 0, 2.5)
MinBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70); MinBtn.TextColor3 = Color3.new(1, 1, 1)

local Container = Instance.new("ScrollingFrame", MainFrame)
Container.Position = UDim2.new(0, 0, 0, 35); Container.Size = UDim2.new(1, 0, 1, -35)
Container.BackgroundTransparency = 1; Container.CanvasSize = UDim2.new(0, 0, 0, 500); Container.ScrollBarThickness = 4

local UIList = Instance.new("UIListLayout", Container)
UIList.Padding = UDim.new(0, 5); UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local buttonsRefs = {}
local function CreateToggle(name, configName)
    local Btn = Instance.new("TextButton", Container)
    Btn.Size = UDim2.new(0, 200, 0, 35); Btn.Font = Enum.Font.SourceSansSemibold; Btn.TextSize = 14
    
    local function RefreshVisual()
        if toggles[configName] then
            Btn.Text = name .. " : ON"; Btn.BackgroundColor3 = Color3.fromRGB(0, 150, 70); Btn.TextColor3 = Color3.new(1, 1, 1)
        else
            Btn.Text = name .. " : OFF"; Btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55); Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
    Btn.MouseButton1Click:Connect(function() toggles[configName] = not toggles[configName]; RefreshVisual(); SaveConfig() end)
    buttonsRefs[configName] = RefreshVisual
end

-- Registrasi Tombol Utama
CreateToggle("Auto Loot (Ore & Chest)", "AutoLoot")
CreateToggle("Auto Deposit Ore", "AutoDeposit")

-- UI KHUSUS ORE MULTIPLIER (Baru)
CreateToggle("Deposit Ore Multiplier", "OreMultiplierEnabled")

local StepperFrame = Instance.new("Frame", Container)
StepperFrame.Size = UDim2.new(0, 200, 0, 30)
StepperFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

local MinValueBtn = Instance.new("TextButton", StepperFrame)
MinValueBtn.Size = UDim2.new(0, 40, 1, 0); MinValueBtn.Text = "-"; MinValueBtn.Font = Enum.Font.SourceSansBold
MinValueBtn.BackgroundColor3 = Color3.fromRGB(65, 65, 65); MinValueBtn.TextColor3 = Color3.new(1, 1, 1); MinValueBtn.TextSize = 18

local ValueLabel = Instance.new("TextLabel", StepperFrame)
ValueLabel.Size = UDim2.new(1, -80, 1, 0); ValueLabel.Position = UDim2.new(0, 40, 0, 0)
ValueLabel.BackgroundTransparency = 1; ValueLabel.TextColor3 = Color3.new(1, 1, 1)
ValueLabel.Font = Enum.Font.SourceSansBold; ValueLabel.TextSize = 14

local PlusValueBtn = Instance.new("TextButton", StepperFrame)
PlusValueBtn.Size = UDim2.new(0, 40, 1, 0); PlusValueBtn.Position = UDim2.new(1, -40, 0, 0); PlusValueBtn.Text = "+"
PlusValueBtn.BackgroundColor3 = Color3.fromRGB(65, 65, 65); PlusValueBtn.TextColor3 = Color3.new(1, 1, 1); PlusValueBtn.Font = Enum.Font.SourceSansBold; PlusValueBtn.TextSize = 18

local function UpdateTargetMultiLabel()
    ValueLabel.Text = "Target Multi: " .. string.format("%.1f", toggles.TargetMultiplier) .. "x"
end

MinValueBtn.MouseButton1Click:Connect(function()
    toggles.TargetMultiplier = math.max(0.5, toggles.TargetMultiplier - 0.1)
    UpdateTargetMultiLabel(); SaveConfig()
end)
PlusValueBtn.MouseButton1Click:Connect(function()
    toggles.TargetMultiplier = math.min(1.5, toggles.TargetMultiplier + 0.1)
    UpdateTargetMultiLabel(); SaveConfig()
end)

CreateToggle("Auto Collect Money", "AutoCollect")
CreateToggle("Auto Merge Pickaxe", "AutoMerge")
CreateToggle("Auto Buy Pickaxe", "AutoBuy")
CreateToggle("Auto Unlock/Discard Chest", "AutoUnlock")
CreateToggle("Auto Upgrade Per Second", "AutoPerSecond")
CreateToggle("Auto Group Reward", "AutoGroup")

LoadConfig(); isLoadedCompletely = true
for _, refreshFunc in pairs(buttonsRefs) do refreshFunc() end
UpdateTargetMultiLabel() -- Panggil awal untuk Multiplier

MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then Container.Visible = false; MainFrame:TweenSize(UDim2.new(0, 220, 0, 35), "Out", "Quad", 0.12, true)
    else MainFrame:TweenSize(UDim2.new(0, 220, 0, 420), "Out", "Quad", 0.12, true); task.wait(0.12); Container.Visible = true end
end)

-- ==========================================
-- CORE SYSTEM ENGINES (LOOPS)
-- ==========================================

-- Loop 1: MAGNET BRUTAL
task.spawn(function()
    while task.wait(0.3) do
        if toggles.AutoLoot then
            pcall(function()
                local character = LocalPlayer.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                if root then
                    for _, obj in ipairs(workspace:GetChildren()) do
                        local objName = string.lower(obj.Name)
                        
                        if string.find(objName, "loot") or string.find(objName, "chest") then
                            if obj:IsA("Model") or obj:IsA("Tool") then
                                local targetPart = obj:FindFirstChild("Hitbox") or obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("BasePart")
                                if targetPart then
                                    targetPart.CFrame = root.CFrame
                                    if firetouchinterest then
                                        firetouchinterest(targetPart, root, 0)
                                        task.wait(0.01)
                                        firetouchinterest(targetPart, root, 1)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Loop 2A: KHUSUS DEPOSIT & BUTTONS (CEPAT)
task.spawn(function()
    while task.wait(0.1) do
        local myPlot = GetMyPlot()
        if not myPlot then continue end
        
        -- LOGIKA BARU: AUTO DEPOSIT DENGAN MULTIPLIER
        if toggles.AutoDeposit and myPlot:FindFirstChild("Sell") and myPlot.Sell:FindFirstChild("DepositButton") then
            local shouldDeposit = true
            
            -- Jika fitur Multiplier menyala, kita cek server dulu
            if toggles.OreMultiplierEnabled then
                shouldDeposit = false -- Setel ke false dulu
                local currentMulti = 0
                
                -- Baca data langsung dari part yang kamu temukan!
                local multPart = workspace:FindFirstChild("OreMultPart")
                if multPart and multPart:FindFirstChild("BillboardGui") and multPart.BillboardGui:FindFirstChild("Frame") and multPart.BillboardGui.Frame:FindFirstChild("MultText") then
                    local textData = multPart.BillboardGui.Frame.MultText.Text
                    local numData = tonumber(string.match(textData, "[%d%.]+"))
                    if numData then currentMulti = numData end
                end
                
                -- Cek apakah angka server memenuhi syarat targetmu
                if currentMulti >= toggles.TargetMultiplier then
                    shouldDeposit = true
                end
            end
            
            if shouldDeposit then
                TouchButton(myPlot.Sell.DepositButton:FindFirstChild("Button"))
            end
        end

        if toggles.AutoCollect and myPlot:FindFirstChild("Sell") and myPlot.Sell:FindFirstChild("CollectButton") then
            TouchButton(myPlot.Sell.CollectButton:FindFirstChild("Button"))
        end
        if toggles.AutoMerge and myPlot:FindFirstChild("Buttons") and myPlot.Buttons:FindFirstChild("ButtonMerge") then
            TouchButton(myPlot.Buttons.ButtonMerge:FindFirstChild("Button"))
        end
        if toggles.AutoBuy and myPlot:FindFirstChild("Buttons") then
            local b = myPlot.Buttons
            if b:FindFirstChild("ButtonBuy100") then TouchButton(b.ButtonBuy100:FindFirstChild("Button")) end
            if b:FindFirstChild("ButtonBuy25") then TouchButton(b.ButtonBuy25:FindFirstChild("Button")) end
            if b:FindFirstChild("ButtonBuy5") then TouchButton(b.ButtonBuy5:FindFirstChild("Button")) end
            if b:FindFirstChild("ButtonBuy1") then TouchButton(b.ButtonBuy1:FindFirstChild("Button")) end
        end
        if toggles.AutoPerSecond and myPlot:FindFirstChild("Sell") and myPlot.Sell:FindFirstChild("UpgradeButton") then
            TouchButton(myPlot.Sell.UpgradeButton:FindFirstChild("Button"))
        end
    end
end)

-- Loop 2B: KHUSUS GROUP REWARD (SANTAI)
task.spawn(function()
    while task.wait(2.0) do
        local myPlot = GetMyPlot()
        if not myPlot then continue end
        if toggles.AutoGroup and myPlot:FindFirstChild("GroupReward") and myPlot.GroupReward:FindFirstChild("CollectButton") then
            TouchButton(myPlot.GroupReward.CollectButton:FindFirstChild("Button"))
        end
    end
end)

-- Loop 3: AUTO UNLOCK DENGAN COOLDOWN & ANTI-SPAM
local isProcessingChest = false
task.spawn(function()
    while task.wait(0.2) do
        if toggles.AutoUnlock and not isProcessingChest then
            pcall(function()
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                local chestGui = playerGui and playerGui:FindFirstChild("ChestGui")
                local currencyGui = playerGui and playerGui:FindFirstChild("CurrencyGui")
                
                if chestGui and chestGui:FindFirstChild("ChestInfo") and chestGui.ChestInfo.Visible then
                    isProcessingChest = true 
                    task.wait(0.5) 
                    
                    if chestGui.ChestInfo.Visible then
                        local myCash = ExtractNumber(currencyGui.Frame.CashText)
                        local chestPrice = ExtractNumber(chestGui.ChestInfo.UnlockMenu.PriceFrame.ItemPrice)
                        
                        if myCash >= chestPrice and chestPrice > 0 then
                            ReplicatedStorage.RemoteEvents.UnlockChest:FireServer()
                        else
                            ReplicatedStorage.RemoteEvents.DiscardChest:FireServer()
                        end
                        task.wait(1.5) 
                    end
                    isProcessingChest = false 
                end
            end)
        end
    end
end)

-- ==========================================
-- BYPASS DETEKSI IDLE (ANTI AFK)
-- ==========================================
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

print("[SUCCESS] Pickaxe Tycoon Panel v2.12 (Ore Multiplier Fix) Berhasil Dimuat!")
