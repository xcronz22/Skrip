local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
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
MainFrame.Size = UDim2.new(0, 280, 0, 300)
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
Title.Text = "🍋 Lemon Auto V2"
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
    AutoHarvestAll = false,
    AutoHarvestTP = false,
    AutoClick = false,
    AutoDrop = false,
    AutoBuy = false
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
        if name == "AutoHarvestAll" and Toggles.AutoHarvestTP then
            Toggles.AutoHarvestTP = false
        elseif name == "AutoHarvestTP" and Toggles.AutoHarvestAll then
            Toggles.AutoHarvestAll = false
        end

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

CreateToggle("AutoHarvestAll", "Steal Lemons (Silent)")
CreateToggle("AutoHarvestTP", "Steal Lemons (Teleport)")
CreateToggle("AutoClick", "Auto Click My Stand")
CreateToggle("AutoDrop", "Auto Collect Drops")
CreateToggle("AutoBuy", "Auto Buy My Tycoon")

-- ==========================================
-- 3. LOOP UNTUK SEMUA FITUR
-- ==========================================
task.spawn(function()
    while task.wait(0.5) do
        local MyTycoon = GetMyTycoon()
        
        -- Auto Harvest ALL Tycoons (Silent)
        if Toggles.AutoHarvestAll and not Toggles.AutoHarvestTP then
            for i = 1, 10 do
                local tycoon = Workspace:FindFirstChild("Tycoon" .. i)
                if tycoon then
                    local constantFolder = tycoon:FindFirstChild("Constant")
                    if constantFolder and constantFolder:FindFirstChild("Trees") then
                        for _, tree in pairs(constantFolder.Trees:GetChildren()) do
                            if tree.Name == "LemonTree" then
                                for _, part in pairs(tree:GetChildren()) do
                                    if part.Name == "Fruit" then
                                        local clickDetector = part:FindFirstChildWhichIsA("ClickDetector", true)
                                        if clickDetector then
                                            fireclickdetector(clickDetector, 0)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        -- Auto Harvest ALL Tycoons (Dengan Teleport Aman & Bisa Distop Langsung)
        if Toggles.AutoHarvestTP and not Toggles.AutoHarvestAll then
            local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local originalCFrame = rootPart.CFrame
                local hasTeleported = false

                -- Membuat karakter diam mematung agar tidak terbang/jatuh
                rootPart.Anchored = true 

                for i = 1, 10 do
                    if not Toggles.AutoHarvestTP then break end -- Deteksi stop instan

                    local tycoon = Workspace:FindFirstChild("Tycoon" .. i)
                    if tycoon then
                        local constantFolder = tycoon:FindFirstChild("Constant")
                        if constantFolder and constantFolder:FindFirstChild("Trees") then
                            for _, tree in pairs(constantFolder.Trees:GetChildren()) do
                                if not Toggles.AutoHarvestTP then break end -- Deteksi stop instan

                                if tree.Name == "LemonTree" then
                                    for _, part in pairs(tree:GetChildren()) do
                                        if not Toggles.AutoHarvestTP then break end -- Deteksi stop instan

                                        if part.Name == "Fruit" then
                                            local clickDetector = part:FindFirstChildWhichIsA("ClickDetector", true)
                                            if clickDetector then
                                                -- Teleport HANYA POSISI, abaikan rotasi buahnya
                                                rootPart.CFrame = CFrame.new(part.Position)
                                                task.wait(0.1) 
                                                fireclickdetector(clickDetector, 0)
                                                hasTeleported = true
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                if hasTeleported then
                    task.wait(0.1)
                    rootPart.CFrame = originalCFrame
                end
                
                -- Kembalikan physics karakter ke normal
                rootPart.Anchored = false 
            end
        end
        
        -- Auto Click Stand Income
        if Toggles.AutoClick and MyTycoon then
            local remotes = MyTycoon:FindFirstChild("Remotes")
            if remotes and remotes:FindFirstChild("WakeIncomeStream") then
                pcall(function()
                    remotes.WakeIncomeStream:InvokeServer("LemonStand")
                end)
            end
        end

        -- Auto Buy (Membeli tombol-tombol fisik di base)
        if Toggles.AutoBuy and MyTycoon then
            local purchases = MyTycoon:FindFirstChild("Purchases")
            if purchases then
                for _, category in pairs(purchases:GetChildren()) do
                    local buttons = category:FindFirstChild("Buttons")
                    if buttons then
                        for _, item in pairs(buttons:GetDescendants()) do
                            if item:IsA("TouchTransmitter") or item.Name == "TouchInterest" then
                                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, item.Parent, 0)
                                task.wait(0.01)
                                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, item.Parent, 1)
                            elseif item:IsA("ProximityPrompt") then
                                fireproximityprompt(item)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Loop Terpisah untuk Cash Drops
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
