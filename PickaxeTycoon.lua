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
local TweenService = game:GetService("TweenService")

if CoreGui:FindFirstChild("PickaxeTycoonPanel") then
    CoreGui.PickaxeTycoonPanel:Destroy()
end
if CoreGui:FindFirstChild("PickaxeTycoonToasts") then
    CoreGui.PickaxeTycoonToasts:Destroy()
end

-- ==========================================
-- TOAST NOTIFICATION SYSTEM
-- ==========================================
local ToastScreen = Instance.new("ScreenGui", CoreGui)
ToastScreen.Name = "PickaxeTycoonToasts"
ToastScreen.ResetOnSpawn = false

local ToastFrame = Instance.new("Frame", ToastScreen)
ToastFrame.Size = UDim2.new(0, 320, 1, -20)
ToastFrame.Position = UDim2.new(1, -340, 0, 10) -- Posisi di kanan bawah/tengah layar
ToastFrame.BackgroundTransparency = 1

local ToastLayout = Instance.new("UIListLayout", ToastFrame)
ToastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
ToastLayout.Padding = UDim.new(0, 8)

local function ShowToast(text, duration)
    duration = duration or 3
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 0, 0)
    t.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    t.TextColor3 = Color3.new(1, 1, 1)
    t.Text = text
    t.TextWrapped = true
    t.Font = Enum.Font.SourceSansSemibold
    t.TextSize = 14
    t.AutomaticSize = Enum.AutomaticSize.Y
    t.Parent = ToastFrame
    
    local padding = Instance.new("UIPadding", t)
    padding.PaddingTop = UDim.new(0, 10); padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 10); padding.PaddingRight = UDim.new(0, 10)
    
    local corner = Instance.new("UICorner", t)
    corner.CornerRadius = UDim.new(0, 6)
    
    local stroke = Instance.new("UIStroke", t)
    stroke.Color = Color3.fromRGB(80, 80, 80)
    stroke.Thickness = 1
    
    -- Animasi masuk
    t.BackgroundTransparency = 1; t.TextTransparency = 1; stroke.Transparency = 1
    TweenService:Create(t, TweenInfo.new(0.3), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
    TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
    
    task.spawn(function()
        task.wait(duration)
        -- Animasi keluar & Hapus
        local fadeOut = TweenService:Create(t, TweenInfo.new(0.5), {TextTransparency = 1, BackgroundTransparency = 1})
        TweenService:Create(stroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
        fadeOut:Play()
        fadeOut.Completed:Wait()
        t:Destroy()
    end)
end

local errorDebounce = {}
local function HandleError(featureName)
    if not errorDebounce[featureName] then
        errorDebounce[featureName] = true
        ShowToast("Error pada " .. featureName, 3)
        task.delay(5, function() errorDebounce[featureName] = false end)
    end
end

-- ==========================================
-- UNIVERSAL AUTO REJOIN
-- ==========================================
local function HandleErrorPrompt(child)
	if child.Name == 'ErrorPrompt' then
		ShowToast("Disconnected! Rejoining in 5s...", 5)
		task.wait(5)
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end
end

local promptOverlay = CoreGui:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")
promptOverlay.ChildAdded:Connect(HandleErrorPrompt)
for _, child in ipairs(promptOverlay:GetChildren()) do HandleErrorPrompt(child) end

-- ==========================================
-- UTILITIES & CONFIG
-- ==========================================
local function GetMyPlot()
    local attr = LocalPlayer.Character and LocalPlayer.Character:GetAttribute("assignedPlot") or LocalPlayer:GetAttribute("assignedPlot")
    if attr then
        local p = workspace.Plots:FindFirstChild(tostring(attr))
        if p then return p end
    end
    return workspace.Plots:FindFirstChild("Plot_3")
end

local function TouchButton(buttonInstance)
    if buttonInstance and buttonInstance:IsA("BasePart") and firetouchinterest then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            firetouchinterest(buttonInstance, root, 0)
            task.wait(0.02)
            firetouchinterest(buttonInstance, root, 1)
        end
    end
end

local function ExtractNumber(textObject)
    if not textObject then return 0 end
    local text = string.upper(tostring(textObject.Text))
    local num = tonumber(string.match(text, "[%d%.]+")) or 0
    if string.find(text, "K") then num = num * 1000
    elseif string.find(text, "M") then num = num * 1000000
    elseif string.find(text, "B") then num = num * 1000000000
    elseif string.find(text, "T") then num = num * 1000000000000 
	elseif string.find(text, "Qa") then num = num * 1000000000000000 end
    return num
end

local function SmartBuy(buttonModel, currentCash)
    if not buttonModel then return end
    local frame = buttonModel:FindFirstChild("BillboardGui") and buttonModel.BillboardGui:FindFirstChild("Frame")
    if frame and frame.Visible then
        local priceLabel = frame:FindFirstChild("PriceText")
        if not priceLabel or currentCash >= ExtractNumber(priceLabel) then 
            TouchButton(buttonModel:FindFirstChild("Button")) 
        end
    end
end

-- Deteksi apakah Player sedang membawa Chest (Berdasarkan Attributes)
local function IsHoldingChest()
    local attrs = LocalPlayer:GetAttributes()
    for key, value in pairs(attrs) do
        local lowerKey = string.lower(key)
        if string.find(lowerKey, "chest") then
            -- Pastikan attribute-nya aktif (bukan string kosong atau false/0)
            if value ~= false and value ~= 0 and value ~= "" then
                return true
            end
        end
    end
    return false
end

-- Config Setup
local isLoadedCompletely = false
local SaveFileName = "PickaxeTycoon_Config.json"
local toggles = {
    AutoLoot = false, AutoDeposit = false, AutoCollect = false, AutoMerge = false,
    AutoBuy = false, AutoUnlock = false, AutoPerSecond = false, AutoGroup = false,
    OreMultiplierEnabled = false, TargetMultiplier = 1.0,
    TargetMergeEnabled = false, TargetMergeValue = 0, ShopGUIActive = false
}

local function SaveConfig()
    if isLoadedCompletely and writefile then pcall(function() writefile(SaveFileName, HttpService:JSONEncode(toggles)) end) end
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
-- GUI PANEL CREATION
-- ==========================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "PickaxeTycoonPanel"; ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30); MainFrame.Position = UDim2.new(0.15, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 420); MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local TitleBar = Instance.new("TextLabel", MainFrame)
TitleBar.Text = "  Pickaxe Tycoon v2.25"; TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TitleBar.TextColor3 = Color3.new(1, 1, 1); TitleBar.Font = Enum.Font.SourceSansBold; TitleBar.TextSize = 15; TitleBar.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TitleBar); CloseBtn.Text = "X"; CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -35, 0, 2.5); CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50); CloseBtn.TextColor3 = Color3.new(1, 1, 1); CloseBtn.Font = Enum.Font.SourceSansBold; CloseBtn.TextSize = 14; Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
local MinBtn = Instance.new("TextButton", TitleBar); MinBtn.Text = "-"; MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(1, -70, 0, 2.5); MinBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55); MinBtn.TextColor3 = Color3.new(1, 1, 1); MinBtn.Font = Enum.Font.SourceSansBold; MinBtn.TextSize = 16; Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local ToggleIcon = Instance.new("TextButton", ScreenGui); ToggleIcon.Size = UDim2.new(0, 50, 0, 50); ToggleIcon.Position = UDim2.new(0.05, 0, 0.35, 0); ToggleIcon.BackgroundColor3 = Color3.fromRGB(25, 25, 25); ToggleIcon.TextColor3 = Color3.new(1, 1, 1); ToggleIcon.Text = "⛏️"; ToggleIcon.TextSize = 24; ToggleIcon.Font = Enum.Font.SourceSansBold; ToggleIcon.Visible = false; ToggleIcon.Active = true; ToggleIcon.Draggable = true; Instance.new("UICorner", ToggleIcon).CornerRadius = UDim.new(0, 25)
local IconStroke = Instance.new("UIStroke", ToggleIcon); IconStroke.Color = Color3.fromRGB(0, 150, 70); IconStroke.Thickness = 2
MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; ToggleIcon.Visible = true end)
ToggleIcon.MouseButton1Click:Connect(function() ToggleIcon.Visible = false; MainFrame.Visible = true end)

local Container = Instance.new("ScrollingFrame", MainFrame)
Container.Position = UDim2.new(0, 0, 0, 35); Container.Size = UDim2.new(1, 0, 1, -35); Container.BackgroundTransparency = 1; Container.CanvasSize = UDim2.new(0, 0, 0, 650); Container.ScrollBarThickness = 4
local UIList = Instance.new("UIListLayout", Container); UIList.Padding = UDim.new(0, 5); UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local buttonsRefs = {}
local function CreateToggle(name, configName)
    local Btn = Instance.new("TextButton", Container)
    Btn.Size = UDim2.new(0, 200, 0, 35); Btn.Font = Enum.Font.SourceSansSemibold; Btn.TextSize = 14
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    local function RefreshVisual()
        if toggles[configName] then Btn.Text = name .. " : ON"; Btn.BackgroundColor3 = Color3.fromRGB(0, 150, 70); Btn.TextColor3 = Color3.new(1, 1, 1)
        else Btn.Text = name .. " : OFF"; Btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55); Btn.TextColor3 = Color3.fromRGB(200, 200, 200) end
    end
    Btn.MouseButton1Click:Connect(function() 
        toggles[configName] = not toggles[configName]; 
        RefreshVisual(); SaveConfig()
        if toggles[configName] then ShowToast(name .. " active smoothly", 3) end
    end)
    buttonsRefs[configName] = RefreshVisual
end

CreateToggle("Auto Loot (Ore & Chest)", "AutoLoot")
CreateToggle("Auto Deposit Ore", "AutoDeposit")
CreateToggle("Auto Collect Money", "AutoCollect")
CreateToggle("Auto Unlock/Discard Chest", "AutoUnlock")
CreateToggle("Auto Buy Pickaxe", "AutoBuy")
CreateToggle("Auto Upgrade Per Second", "AutoPerSecond")
CreateToggle("Auto Group Reward", "AutoGroup")
CreateToggle("Shop GUI Active", "ShopGUIActive")
LoadConfig(); isLoadedCompletely = true; for _, f in pairs(buttonsRefs) do f() end

-- ==========================================
-- CORE ENGINES
-- ==========================================

-- UI Cleaner Engine
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local frame = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("CurrencyGui") and LocalPlayer.PlayerGui.CurrencyGui:FindFirstChild("Frame")
            if frame then
                local buyXP = frame:FindFirstChild("BuyXPButtons")
                if buyXP then buyXP.Visible = false; buyXP.Active = false end
                local incomeBtn = frame:FindFirstChild("IncomeMultButton")
                if incomeBtn then
                    incomeBtn.Visible = toggles.ShopGUIActive; incomeBtn.Active = toggles.ShopGUIActive
                end
            end
        end)
    end
end)

-- Auto Loot Engine (SMART CHEST)
task.spawn(function()
    while task.wait(0.3) do
        if toggles.AutoLoot then
            local success, err = pcall(function()
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                local isHoldingChest = IsHoldingChest() -- Cek status Atribut Player
                
                for _, obj in ipairs(workspace:GetChildren()) do
                    local objName = string.lower(obj.Name)
                    local isChest = string.find(objName, "chest")
                    local isLoot = string.find(objName, "loot") -- Biasanya ini Ore
                    
                    -- Loot Ore selalu diambil. Chest HANYA diambil jika TIDAK sedang memegang chest lain.
                    if isLoot or (isChest and not isHoldingChest) then
                        if obj:IsA("Model") or obj:IsA("Tool") then
                            local tPart = obj:FindFirstChild("Hitbox") or obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("BasePart")
                            if tPart then
                                tPart.CFrame = root.CFrame
                                if firetouchinterest then firetouchinterest(tPart, root, 0); task.wait(0.01); firetouchinterest(tPart, root, 1) end
                            end
                        end
                    end
                end
            end)
            if not success then HandleError("Auto Loot") end
        end
    end
end)

-- SMART AUTO DISCARD / UNLOCK ENGINE
local chestMisses = 0
local isAfkMode = false
local isProcessingChest = false

task.spawn(function()
    while task.wait(0.2) do
        if toggles.AutoUnlock and not isProcessingChest then
            local success, err = pcall(function()
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                local chestGui = playerGui and playerGui:FindFirstChild("ChestGui")
                local currencyGui = playerGui and playerGui:FindFirstChild("CurrencyGui")
                
                if chestGui and chestGui:FindFirstChild("ChestInfo") and chestGui.ChestInfo.Visible then
                    isProcessingChest = true
                    task.wait(0.5) 
                    
                    if chestGui.ChestInfo.Visible then
                        local myCash = ExtractNumber(currencyGui.Frame.CashText)
                        local chestPrice = ExtractNumber(chestGui.ChestInfo.UnlockMenu.PriceFrame.ItemPrice)
                        
                        -- JIKA UANG CUKUP: LANGSUNG UNLOCK SEPERTI BIASA
                        if myCash >= chestPrice and chestPrice > 0 then
                            ReplicatedStorage.RemoteEvents.UnlockChest:FireServer()
                            task.wait(1.5)
                        
                        -- JIKA UANG TIDAK CUKUP: MASUK FASE DISCARD
                        else
                            if isAfkMode then
                                ReplicatedStorage.RemoteEvents.DiscardChest:FireServer()
                                task.wait(0.5)
                            else
                                ShowToast("Waiting for manual discard for 30 seconds, if not discarded manually 3 times it will enter AFK mode and discard instantly.", 6)
                                
                                local waitTime = 0
                                -- Tunggu sampai 30 detik, tapi berhenti jika UI hilang (ditekan manual) atau toggle dimatikan
                                while waitTime < 30 and toggles.AutoUnlock and chestGui.ChestInfo.Visible do
                                    task.wait(0.5)
                                    waitTime = waitTime + 0.5
                                end
                                
                                if not chestGui.ChestInfo.Visible then
                                    -- Artinya kamu mengklik manual Unlock / Discard
                                    chestMisses = 0 
                                elseif toggles.AutoUnlock then
                                    -- Waktu habis, sistem mengeksekusi discard
                                    ReplicatedStorage.RemoteEvents.DiscardChest:FireServer()
                                    chestMisses = chestMisses + 1
                                    
                                    if chestMisses >= 3 then
                                        isAfkMode = true
                                        ShowToast("AFK Mode Activated: Discarding chests instantly.", 4)
                                    end
                                    task.wait(1.5)
                                end
                            end
                        end
                    end
                    isProcessingChest = false 
                end
            end)
            if not success then HandleError("Auto Unlock/Discard Chest") end
        end
    end
end)

-- Auto Buy & Upgrade & Collect & Deposit
task.spawn(function()
    while task.wait(0.3) do
        local success, err = pcall(function()
            local myPlot = GetMyPlot()
            if not myPlot then return end
            
            local myCash = ExtractNumber(LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("CurrencyGui") and LocalPlayer.PlayerGui.CurrencyGui:FindFirstChild("Frame") and LocalPlayer.PlayerGui.CurrencyGui.Frame:FindFirstChild("CashText"))
            
            if toggles.AutoDeposit and myPlot:FindFirstChild("Sell") and myPlot.Sell:FindFirstChild("DepositButton") then
                local frame = myPlot.Sell.DepositButton:FindFirstChild("BillboardGui") and myPlot.Sell.DepositButton.BillboardGui:FindFirstChild("Frame")
                if frame and frame.Visible then TouchButton(myPlot.Sell.DepositButton:FindFirstChild("Button")) end
            end
            if toggles.AutoCollect and myPlot:FindFirstChild("Sell") and myPlot.Sell:FindFirstChild("CollectButton") then
                local frame = myPlot.Sell.CollectButton:FindFirstChild("BillboardGui") and myPlot.Sell.CollectButton.BillboardGui:FindFirstChild("Frame")
                if frame and frame.Visible then TouchButton(myPlot.Sell.CollectButton:FindFirstChild("Button")) end
            end
            if toggles.AutoBuy and myPlot:FindFirstChild("Buttons") then
                local b = myPlot.Buttons
                SmartBuy(b:FindFirstChild("ButtonBuy100"), myCash); SmartBuy(b:FindFirstChild("ButtonBuy25"), myCash)
                SmartBuy(b:FindFirstChild("ButtonBuy5"), myCash); SmartBuy(b:FindFirstChild("ButtonBuy1"), myCash)
            end
            if toggles.AutoPerSecond and myPlot:FindFirstChild("Sell") and myPlot.Sell:FindFirstChild("UpgradeButton") then
                SmartBuy(myPlot.Sell.UpgradeButton, myCash)
            end
        end)
        if not success then HandleError("Auto Plot Actions") end
    end
end)

-- Auto Group (Color Gate)
local isClaimingGroup = false
task.spawn(function()
    while task.wait(1.0) do
        if toggles.AutoGroup then
            local success, err = pcall(function()
                local myPlot = GetMyPlot()
                if myPlot and myPlot:FindFirstChild("GroupReward") and myPlot.GroupReward:FindFirstChild("CollectButton") and not isClaimingGroup then
                    local btnPart = myPlot.GroupReward.CollectButton:FindFirstChild("Button")
                    if btnPart and btnPart:IsA("BasePart") then
                        local r, g, b = math.round(btnPart.Color.R * 255), math.round(btnPart.Color.G * 255), math.round(btnPart.Color.B * 255)
                        if r ~= 79 or g ~= 79 or b ~= 79 then
                            isClaimingGroup = true; task.wait(2.5) 
                            TouchButton(btnPart); task.wait(1.5); isClaimingGroup = false
                        end
                    end
                end
            end)
            if not success then HandleError("Auto Group Reward") end
        end
    end
end)

local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)

ShowToast("Pickaxe Tycoon Panel v2.25 Successfully Loaded!", 4)
