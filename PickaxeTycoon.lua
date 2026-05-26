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

if CoreGui:FindFirstChild("PickaxeTycoonPanel") then
    CoreGui.PickaxeTycoonPanel:Destroy()
end

-- ==========================================
-- UNIVERSAL AUTO REJOIN
-- ==========================================
local function HandleErrorPrompt(child)
	if child.Name == 'ErrorPrompt' then
		print("[AUTO REJOIN] Terdeteksi Disconnect! Mencoba rejoin dalam 5 detik...")
		task.wait(5)
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end
end

local promptOverlay = CoreGui:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")
promptOverlay.ChildAdded:Connect(HandleErrorPrompt)
for _, child in ipairs(promptOverlay:GetChildren()) do HandleErrorPrompt(child) end

-- ==========================================
-- DETEKSI PLOT DINAMIS & TOOLS
-- ==========================================
local function GetMyPlot()
    local character = LocalPlayer.Character
    local attr = character and character:GetAttribute("assignedPlot") or LocalPlayer:GetAttribute("assignedPlot")
    if attr then
        local p = workspace.Plots:FindFirstChild(tostring(attr))
        if p then return p end
    end
    return workspace.Plots:FindFirstChild("Plot_3")
end

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

-- SMART BUY: Tetap pakai matematika karena butuh mengecek Harga vs Uang
local function SmartBuy(buttonModel, currentCash)
    if not buttonModel then return end
    local bGui = buttonModel:FindFirstChild("BillboardGui")
    local frame = bGui and bGui:FindFirstChild("Frame")
    
    if frame and frame.Visible then
        local priceTextLabel = frame:FindFirstChild("PriceText")
        if priceTextLabel then
            if currentCash >= ExtractNumber(priceTextLabel) then 
                TouchButton(buttonModel:FindFirstChild("Button")) 
            end
        else
            TouchButton(buttonModel:FindFirstChild("Button"))
        end
    end
end

-- ==========================================
-- STATE VARIABEL & CONFIG
-- ==========================================
local isLoadedCompletely = false
local SaveFileName = "PickaxeTycoon_Config.json"

local toggles = {
    AutoLoot = false, AutoDeposit = false, AutoCollect = false, AutoMerge = false,
    AutoBuy = false, AutoUnlock = false, AutoPerSecond = false, AutoGroup = false,
    OreMultiplierEnabled = false, TargetMultiplier = 1.0,
    TargetMergeEnabled = false, TargetMergeValue = 0
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
            if toggles.TargetMultiplier < 1.0 then toggles.TargetMultiplier = 1.0 end
        end
    end
end

-- ==========================================
-- LOGIKA SMART MERGE
-- ==========================================
local function ShouldMerge(myPlot)
    local holders = myPlot:FindFirstChild("Holders")
    if not holders then return false end
    
    if toggles.TargetMergeEnabled and toggles.TargetMergeValue > 0 then
        local targetIndex = toggles.TargetMergeValue - 1
        local targetHolder = holders:FindFirstChild("Holder_" .. tostring(targetIndex))
        
        local hasUnitInTargetSlot = false
        if targetHolder then
            for _, child in ipairs(targetHolder:GetChildren()) do
                if string.match(child.Name, "^Unit%d+") then
                    hasUnitInTargetSlot = true
                    break
                end
            end
        end
        if not hasUnitInTargetSlot then return false end
    end
    
    local unitCounts = {}
    for _, holder in ipairs(holders:GetChildren()) do
        if string.find(holder.Name, "Holder_") then
            for _, child in ipairs(holder:GetChildren()) do
                if string.match(child.Name, "^Unit%d+") then
                    local uName = child.Name
                    unitCounts[uName] = (unitCounts[uName] or 0) + 1
                    if unitCounts[uName] >= 3 then return true end
                end
            end
        end
    end
    return false
end

-- ==========================================
-- INITIALIZE INTERFACE (GUI PANEL)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "PickaxeTycoonPanel"; ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30); MainFrame.Position = UDim2.new(0.15, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 420); MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local TitleBar = Instance.new("TextLabel", MainFrame)
TitleBar.Text = "  Pickaxe Tycoon v2.21"; TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TitleBar.TextColor3 = Color3.new(1, 1, 1)
TitleBar.Font = Enum.Font.SourceSansBold; TitleBar.TextSize = 15; TitleBar.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Text = "X"; CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -35, 0, 2.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50); CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.SourceSansBold; CloseBtn.TextSize = 14; Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Text = "-"; MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(1, -70, 0, 2.5)
MinBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55); MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.Font = Enum.Font.SourceSansBold; MinBtn.TextSize = 16; Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local ToggleIcon = Instance.new("TextButton", ScreenGui)
ToggleIcon.Size = UDim2.new(0, 50, 0, 50); ToggleIcon.Position = UDim2.new(0.05, 0, 0.35, 0)
ToggleIcon.BackgroundColor3 = Color3.fromRGB(25, 25, 25); ToggleIcon.TextColor3 = Color3.new(1, 1, 1)
ToggleIcon.Text = "⛏️"; ToggleIcon.TextSize = 24; ToggleIcon.Font = Enum.Font.SourceSansBold
ToggleIcon.Visible = false; ToggleIcon.Active = true; ToggleIcon.Draggable = true
Instance.new("UICorner", ToggleIcon).CornerRadius = UDim.new(0, 25)
local IconStroke = Instance.new("UIStroke", ToggleIcon); IconStroke.Color = Color3.fromRGB(0, 150, 70); IconStroke.Thickness = 2

MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; ToggleIcon.Visible = true end)
ToggleIcon.MouseButton1Click:Connect(function() ToggleIcon.Visible = false; MainFrame.Visible = true end)

local Container = Instance.new("ScrollingFrame", MainFrame)
Container.Position = UDim2.new(0, 0, 0, 35); Container.Size = UDim2.new(1, 0, 1, -35)
Container.BackgroundTransparency = 1; Container.CanvasSize = UDim2.new(0, 0, 0, 600); Container.ScrollBarThickness = 4
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
    Btn.MouseButton1Click:Connect(function() toggles[configName] = not toggles[configName]; RefreshVisual(); SaveConfig() end)
    buttonsRefs[configName] = RefreshVisual
end

local function CreateStepper(labelPrefix, configKey, minVal, maxVal, step, isFloat)
    local SFrame = Instance.new("Frame", Container)
    SFrame.Size = UDim2.new(0, 200, 0, 30); SFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Instance.new("UICorner", SFrame).CornerRadius = UDim.new(0, 6)
    
    local MinBtn = Instance.new("TextButton", SFrame)
    MinBtn.Size = UDim2.new(0, 40, 1, 0); MinBtn.Text = "-"; MinBtn.Font = Enum.Font.SourceSansBold
    MinBtn.BackgroundColor3 = Color3.fromRGB(65, 65, 65); MinBtn.TextColor3 = Color3.new(1, 1, 1); MinBtn.TextSize = 18
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)
    
    local ValLabel = Instance.new("TextLabel", SFrame)
    ValLabel.Size = UDim2.new(1, -80, 1, 0); ValLabel.Position = UDim2.new(0, 40, 0, 0)
    ValLabel.BackgroundTransparency = 1; ValLabel.TextColor3 = Color3.new(1, 1, 1); ValLabel.Font = Enum.Font.SourceSansBold; ValLabel.TextSize = 14
    
    local PlusBtn = Instance.new("TextButton", SFrame)
    PlusBtn.Size = UDim2.new(0, 40, 1, 0); PlusBtn.Position = UDim2.new(1, -40, 0, 0); PlusBtn.Text = "+"
    PlusBtn.BackgroundColor3 = Color3.fromRGB(65, 65, 65); PlusBtn.TextColor3 = Color3.new(1, 1, 1); PlusBtn.Font = Enum.Font.SourceSansBold; PlusBtn.TextSize = 18
    Instance.new("UICorner", PlusBtn).CornerRadius = UDim.new(0, 6)
    
    local function UpdateLabel()
        if isFloat then ValLabel.Text = labelPrefix .. string.format("%.1f", toggles[configKey]) .. "x"
        else
            if configKey == "TargetMergeValue" and toggles[configKey] == 0 then ValLabel.Text = labelPrefix .. "0 (Auto)"
            else ValLabel.Text = labelPrefix .. tostring(toggles[configKey]) end
        end
    end
    
    MinBtn.MouseButton1Click:Connect(function() toggles[configKey] = math.max(minVal, toggles[configKey] - step); UpdateLabel(); SaveConfig() end)
    PlusBtn.MouseButton1Click:Connect(function() toggles[configKey] = math.min(maxVal, toggles[configKey] + step); UpdateLabel(); SaveConfig() end)
    
    UpdateLabel(); return UpdateLabel
end

CreateToggle("Auto Loot (Ore & Chest)", "AutoLoot")
CreateToggle("Auto Deposit Ore", "AutoDeposit")
CreateToggle("Deposit Ore Multiplier", "OreMultiplierEnabled")
local UpdateMultiLabel = CreateStepper("Target Multi: ", "TargetMultiplier", 1.0, 1.5, 0.1, true)
local UpdateMergeLabel = CreateStepper("Target Slot: ", "TargetMergeValue", 0, 100, 1, false)
CreateToggle("Auto Collect Money", "AutoCollect")
CreateToggle("Auto Merge Pickaxe", "AutoMerge")
CreateToggle("Target Merge Active", "TargetMergeEnabled")
CreateToggle("Auto Buy Pickaxe", "AutoBuy")
CreateToggle("Auto Unlock/Discard Chest", "AutoUnlock")
CreateToggle("Auto Upgrade Per Second", "AutoPerSecond")
CreateToggle("Auto Group Reward", "AutoGroup")

LoadConfig(); isLoadedCompletely = true
for _, refreshFunc in pairs(buttonsRefs) do refreshFunc() end
UpdateMultiLabel(); UpdateMergeLabel()

-- ==========================================
-- CORE SYSTEM ENGINES (LOOPS)
-- ==========================================

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
                                    if firetouchinterest then firetouchinterest(targetPart, root, 0); task.wait(0.01); firetouchinterest(targetPart, root, 1) end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        local myPlot = GetMyPlot()
        if not myPlot then continue end
        
        local myCash = 0
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        local currencyGui = playerGui and playerGui:FindFirstChild("CurrencyGui")
        if currencyGui and currencyGui:FindFirstChild("Frame") and currencyGui.Frame:FindFirstChild("CashText") then
            myCash = ExtractNumber(currencyGui.Frame.CashText)
        end
        
        -- 1. DEPOSIT ORE (PURE FRAME VISIBLE)
        if toggles.AutoDeposit and myPlot:FindFirstChild("Sell") and myPlot.Sell:FindFirstChild("DepositButton") then
            local depositBtn = myPlot.Sell.DepositButton
            local bGui = depositBtn:FindFirstChild("BillboardGui")
            local frame = bGui and bGui:FindFirstChild("Frame")
            
            if frame and frame.Visible then
                local shouldDeposit = true
                if toggles.OreMultiplierEnabled then
                    shouldDeposit = false 
                    local currentMulti = 0
                    local multPart = workspace:FindFirstChild("OreMultPart")
                    if multPart and multPart:FindFirstChild("BillboardGui") and multPart.BillboardGui:FindFirstChild("Frame") then
                        local multFrame = multPart.BillboardGui.Frame
                        if multFrame and multFrame.Visible then
                            local textLabel = multFrame:FindFirstChild("MultText")
                            if textLabel then
                                local numData = tonumber(string.match(textLabel.Text, "[%d%.]+"))
                                if numData then currentMulti = numData end
                            end
                        end
                    end
                    if currentMulti >= toggles.TargetMultiplier then shouldDeposit = true end
                end
                if shouldDeposit then TouchButton(depositBtn:FindFirstChild("Button")) end
            end
        end

        -- 2. COLLECT MONEY (PURE FRAME VISIBLE)
        if toggles.AutoCollect and myPlot:FindFirstChild("Sell") and myPlot.Sell:FindFirstChild("CollectButton") then
            local collectBtn = myPlot.Sell.CollectButton
            local bGui = collectBtn:FindFirstChild("BillboardGui")
            local frame = bGui and bGui:FindFirstChild("Frame")
            
            if frame and frame.Visible then
                TouchButton(collectBtn:FindFirstChild("Button"))
            end
        end
        
        -- 3. MERGE BUTTON (PURE FRAME VISIBLE)
        if toggles.AutoMerge and myPlot:FindFirstChild("Buttons") and myPlot.Buttons:FindFirstChild("ButtonMerge") then
            local mergeBtn = myPlot.Buttons.ButtonMerge
            local bGui = mergeBtn:FindFirstChild("BillboardGui")
            local frame = bGui and bGui:FindFirstChild("Frame")
            
            local isMergeButtonActive = true
            if frame then isMergeButtonActive = frame.Visible end
            
            if isMergeButtonActive and ShouldMerge(myPlot) then 
                TouchButton(mergeBtn:FindFirstChild("Button")) 
            end
        end
        
        -- 4 & 5. BUY & UPGRADE PER SECOND (MATH LOGIC INSIDE SMARTBUY)
        if toggles.AutoBuy and myPlot:FindFirstChild("Buttons") then
            local b = myPlot.Buttons
            if b:FindFirstChild("ButtonBuy100") then SmartBuy(b.ButtonBuy100, myCash) end
            if b:FindFirstChild("ButtonBuy25") then SmartBuy(b.ButtonBuy25, myCash) end
            if b:FindFirstChild("ButtonBuy5") then SmartBuy(b.ButtonBuy5, myCash) end
            if b:FindFirstChild("ButtonBuy1") then SmartBuy(b.ButtonBuy1, myCash) end
        end
        
        if toggles.AutoPerSecond and myPlot:FindFirstChild("Sell") and myPlot.Sell:FindFirstChild("UpgradeButton") then
            SmartBuy(myPlot.Sell.UpgradeButton, myCash)
        end
    end
end)

-- 6. GROUP REWARD (PURE FRAME VISIBLE)
task.spawn(function()
    while task.wait(1.0) do
        local myPlot = GetMyPlot()
        if toggles.AutoGroup and myPlot and myPlot:FindFirstChild("GroupReward") and myPlot.GroupReward:FindFirstChild("CollectButton") then
            local groupReward = myPlot.GroupReward
            local boardPart = groupReward:FindFirstChild("BoardPart")
            local sGui = boardPart and boardPart:FindFirstChild("SurfaceGui")
            local frame = sGui and sGui:FindFirstChild("Frame")
            
            if frame and frame.Visible then
                TouchButton(groupReward.CollectButton:FindFirstChild("Button"))
            end
        end
    end
end)

local isProcessingChest = false
task.spawn(function()
    while task.wait(0.2) do
        if toggles.AutoUnlock and not isProcessingChest then
            pcall(function()
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                local chestGui = playerGui and playerGui:FindFirstChild("ChestGui")
                local currencyGui = playerGui and playerGui:FindFirstChild("CurrencyGui")
                
                if chestGui and chestGui:FindFirstChild("ChestInfo") and chestGui.ChestInfo.Visible then
                    isProcessingChest = true; task.wait(0.5) 
                    if chestGui.ChestInfo.Visible then
                        local myCash = ExtractNumber(currencyGui.Frame.CashText)
                        local chestPrice = ExtractNumber(chestGui.ChestInfo.UnlockMenu.PriceFrame.ItemPrice)
                        if myCash >= chestPrice and chestPrice > 0 then ReplicatedStorage.RemoteEvents.UnlockChest:FireServer()
                        else ReplicatedStorage.RemoteEvents.DiscardChest:FireServer() end
                        task.wait(1.5) 
                    end
                    isProcessingChest = false 
                end
            end)
        end
    end
end)

local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)

print("[SUCCESS] Pickaxe Tycoon Panel v2.21 (Pure Frame Gate) Berhasil Dimuat!")
