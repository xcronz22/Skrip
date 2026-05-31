local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")

-- ==========================================
-- 0. ANTI-AFK SYSTEM
-- ==========================================
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

if CoreGui:FindFirstChild("LemonTycoonGUI") then
    CoreGui.LemonTycoonGUI:Destroy()
end

-- ==========================================
-- 1. PEMBUATAN UI MOBILE-FRIENDLY
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LemonTycoonGUI"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 305) -- Diperpanjang sedikit untuk tombol baru
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🍋 Lemon Auto V3.9"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 35)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 35)
MinimizeBtn.Position = UDim2.new(1, -60, 0, 0)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 24
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = MainFrame

local LemonIcon = Instance.new("TextButton")
LemonIcon.Size = UDim2.new(0, 45, 0, 45)
LemonIcon.Position = UDim2.new(0.5, -22, 0, 20)
LemonIcon.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
LemonIcon.Text = "🍋"
LemonIcon.TextSize = 20
LemonIcon.Visible = false
LemonIcon.Active = true
LemonIcon.Draggable = true
LemonIcon.Parent = ScreenGui

local UICornerIcon = Instance.new("UICorner")
UICornerIcon.CornerRadius = UDim.new(1, 0)
UICornerIcon.Parent = LemonIcon

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 8)
UICornerMain.Parent = MainFrame

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    LemonIcon.Visible = true
end)

LemonIcon.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    LemonIcon.Visible = false
end)

local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -45)
Container.Position = UDim2.new(0, 10, 0, 40)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 3
Container.CanvasSize = UDim2.new(0, 0, 0, 0)
Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = Container

-- ==========================================
-- 2. SISTEM LOGIKA & AUTO FEATURES
-- ==========================================
local Toggles = {
    AutoHarvest = false,
    AutoDrop = false,
    AutoBuy = false,
    AutoUpgrade = false,
    AutoPhone = false
}

local function GetMyTycoon()
    for i = 1, 10 do
        local tycoon = Workspace:FindFirstChild("Tycoon" .. i)
        if tycoon then
            local owner = tycoon:FindFirstChild("Owner")
            if owner and (tostring(owner.Value) == LocalPlayer.Name or owner.Value == LocalPlayer) then
                return tycoon
            end
        end
    end
    return nil
end

local function CreateToggle(name, text)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Btn.Text = text .. " [OFF]"
    Btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Btn.Parent = Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Btn

    Btn.MouseButton1Click:Connect(function()
        Toggles[name] = not Toggles[name]
        
        if Toggles[name] then
            Btn.Text = text .. " [ON]"
            Btn.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            Btn.Text = text .. " [OFF]"
            Btn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)
end

CreateToggle("AutoHarvest", "Auto Steal Lemons")
CreateToggle("AutoDrop", "Auto Collect Drops")
CreateToggle("AutoBuy", "Auto Buy My Tycoon")
CreateToggle("AutoUpgrade", "Auto Upgrade Max")
CreateToggle("AutoPhone", "Auto Answer Phone") -- Tombol Baru

-- ==========================================
-- 3. LOOP 1: AUTO HARVEST (VACUUM & TERTIDUR)
-- ==========================================
task.spawn(function()
    while task.wait(0.1) do
        if Toggles.AutoHarvest then
            local char = LocalPlayer.Character
            local rootPart = char and char:FindFirstChild("HumanoidRootPart")
            local humanoid = char and char:FindFirstChild("Humanoid")

            if rootPart and humanoid then
                local originalCFrame = rootPart.CFrame
                local hasTeleported = false

                for i = 1, 10 do
                    if not Toggles.AutoHarvest then break end

                    local tycoon = Workspace:FindFirstChild("Tycoon" .. i)
                    if tycoon then
                        local constantFolder = tycoon:FindFirstChild("Constant")
                        if constantFolder and constantFolder:FindFirstChild("Trees") then
                            for _, tree in pairs(constantFolder.Trees:GetChildren()) do
                                if not Toggles.AutoHarvest then break end

                                if tree.Name == "LemonTree" then
                                    local function getRemainingFruits()
                                        local fruits = {}
                                        for _, part in pairs(tree:GetChildren()) do
                                            if part.Name == "Fruit" then
                                                local clickDetector = part:FindFirstChildWhichIsA("ClickDetector", true)
                                                if clickDetector then
                                                    table.insert(fruits, {Part = part, CD = clickDetector})
                                                end
                                            end
                                        end
                                        return fruits
                                    end

                                    local readyFruits = getRemainingFruits()

                                    if #readyFruits > 0 then
                                        hasTeleported = true
                                        local targetPos = readyFruits[1].Part.Position
                                        
                                        humanoid.PlatformStand = true 
                                        rootPart.CFrame = CFrame.new(targetPos - Vector3.new(0, 15, 0)) * CFrame.Angles(math.rad(90), 0, 0)
                                        task.wait(0.2) 

                                        while #readyFruits > 0 and Toggles.AutoHarvest do
                                            for _, fruitData in pairs(readyFruits) do
                                                if fruitData.Part and fruitData.Part.Parent then
                                                    fireclickdetector(fruitData.CD)
                                                end
                                            end
                                            
                                            task.wait(0.1) 
                                            readyFruits = getRemainingFruits() 
                                        end
                                        
                                        task.wait(0.1)
                                    end
                                end
                            end
                        end
                    end
                end

                if hasTeleported then
                    task.wait(0.2)
                    humanoid.PlatformStand = false
                    rootPart.CFrame = originalCFrame
                end
            end
        end
    end
end)

-- ==========================================
-- 4. LOOP 2: TYCOON MANAGEMENT & AUTO PHONE
-- ==========================================
task.spawn(function()
    while task.wait(0.1) do 
        local MyTycoon = GetMyTycoon()
        
        if MyTycoon then
            -- Auto Buy Tombol Fisik (Blacklist Minigames & Elevator Lemon Trading)
            if Toggles.AutoBuy then
                local purchases = MyTycoon:FindFirstChild("Purchases")
                if purchases then
                    for _, item in pairs(purchases:GetDescendants()) do
                        
                        -- Cek Blacklist
                        local isMinigame = item:FindFirstAncestor("Minigames")
                        local isLemonTrading = item:FindFirstAncestor("Lemon Trading")
                        local isStructure = item:FindFirstAncestor("Structure")
                        
                        -- Lewati jika objek ada di Minigames ATAU di dalam Lemon Trading -> Structure
                        local isBlacklisted = isMinigame or (isLemonTrading and isStructure)

                        if not isBlacklisted then
                            if item:IsA("TouchTransmitter") or item.Name == "TouchInterest" then
                                if item.Parent then
                                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, item.Parent, 0)
                                    task.wait(0.01)
                                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, item.Parent, 1)
                                end
                            elseif item:IsA("ProximityPrompt") then
                                fireproximityprompt(item)
                            end
                        end
                    end
                end
            end

            -- Auto Upgrade
            if Toggles.AutoUpgrade then
                local purchases = MyTycoon:FindFirstChild("Purchases")
                if purchases then
                    for _, desc in pairs(purchases:GetDescendants()) do
                        if desc:IsA("RemoteFunction") and desc.Name == "Upgrade" then
                            task.spawn(function()
                                pcall(function()
                                    desc:InvokeServer(1)
                                end)
                            end)
                        end
                    end
                end
            end

            -- Auto Phone (Raise & Accept)
            if Toggles.AutoPhone then
                local phoneGui = LocalPlayer.PlayerGui:FindFirstChild("Phone")
                local phoneFrame = phoneGui and phoneGui:FindFirstChild("Phone")
                
                -- Jika UI HP muncul di layar
                if phoneFrame and phoneFrame.Visible then
                    local remotes = MyTycoon:FindFirstChild("Remotes")
                    if remotes and remotes:FindFirstChild("PhoneOffer") then
                        pcall(function()
                            -- Tekan tombol Raise (Angkat)
                            remotes.PhoneOffer:FireServer("Raise")
                            
                            -- Tunggu 3 detik sesuai permintaan
                            task.wait(3)
                            
                            -- Tekan tombol Accept (Terima)
                            remotes.PhoneOffer:FireServer("Accept")
                        end)
                        
                        -- Tambahkan jeda ekstra setelah menerima agar tidak spam beruntun
                        task.wait(2)
                    end
                end
            end

        end
    end
end)

-- ==========================================
-- 5. LOOP 3: AUTO DROP
-- ==========================================
task.spawn(function()
    while task.wait(0.1) do
        if Toggles.AutoDrop then
            local cashDropsFolder = Workspace:FindFirstChild("CashDrops")
            if cashDropsFolder then
                for _, drop in pairs(cashDropsFolder:GetChildren()) do
                    if drop.Name == "CashDrop" then
                        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local touchInterest = drop:FindFirstChild("TouchInterest") or drop:FindFirstChildWhichIsA("TouchTransmitter", true)
                        
                        if root and touchInterest then
                            firetouchinterest(root, touchInterest.Parent, 0)
                            firetouchinterest(root, touchInterest.Parent, 1)
                        end
                    end
                end
            end
        end
    end
end)
