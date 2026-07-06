-- ================================================================
-- 1. RZY UI LIBRARY (Bypass Executor Mobile)
-- ================================================================
local RZY_Library = {}

function RZY_Library:MakeWindow(TitleText)
    local TargetGui
    pcall(function()
        TargetGui = (gethui and gethui()) or game:GetService("CoreGui")
    end)
    if not TargetGui then
        TargetGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    
    if TargetGui:FindFirstChild("RZY_Hub") then
        TargetGui.RZY_Hub:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RZY_Hub"
    ScreenGui.Parent = TargetGui

    local RZYIcon = Instance.new("TextButton")
    RZYIcon.Size = UDim2.new(0, 50, 0, 50)
    RZYIcon.Position = UDim2.new(0.5, -25, 0, 20)
    RZYIcon.BackgroundColor3 = Color3.fromRGB(15, 15, 15) 
    RZYIcon.Text = "R Z Y" 
    RZYIcon.TextColor3 = Color3.fromRGB(0, 170, 255) 
    RZYIcon.TextSize = 13 
    RZYIcon.Font = Enum.Font.Gotham 
    RZYIcon.Visible = false 
    RZYIcon.Active = true
    RZYIcon.Draggable = true 
    RZYIcon.Parent = ScreenGui

    Instance.new("UICorner", RZYIcon).CornerRadius = UDim.new(1, 0) 
    local IconStroke = Instance.new("UIStroke", RZYIcon)
    IconStroke.Color = Color3.fromRGB(0, 170, 255)
    IconStroke.Thickness = 1.5

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -225)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) 
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true 
    MainFrame.Parent = ScreenGui

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = Color3.fromRGB(0, 170, 255) 
    MainStroke.Thickness = 1.5

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    TopBar.Parent = MainFrame
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

    local TopCover = Instance.new("Frame")
    TopCover.Size = UDim2.new(1, 0, 0, 10)
    TopCover.Position = UDim2.new(0, 0, 1, -10)
    TopCover.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    TopCover.BorderSizePixel = 0
    TopCover.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -90, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = TitleText 
    Title.TextColor3 = Color3.fromRGB(0, 170, 255) 
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.Parent = TopBar

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -70, 0, 5)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 24
    MinBtn.Parent = TopBar

    local Container = Instance.new("ScrollingFrame")
    Container.Size = UDim2.new(1, -20, 1, -55)
    Container.Position = UDim2.new(0, 10, 0, 45)
    Container.BackgroundTransparency = 1
    Container.ScrollBarThickness = 2
    Container.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
    Container.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.Parent = Container

    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
    end)

    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false RZYIcon.Visible = true end)
    RZYIcon.MouseButton1Click:Connect(function() MainFrame.Visible = true RZYIcon.Visible = false end)

    local WindowElements = {}

    function WindowElements:AddToggle(Text, DefaultState, Callback)
        local state = DefaultState or false
        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Size = UDim2.new(1, -10, 0, 35)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        ToggleBtn.Font = Enum.Font.GothamBold
        ToggleBtn.TextSize = 13
        ToggleBtn.Parent = Container

        local function UpdateVisuals()
            ToggleBtn.Text = Text .. (state and " [ON]" or " [OFF]")
            ToggleBtn.TextColor3 = state and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 100, 100)
        end
        UpdateVisuals()

        Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 5)
        local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
        ToggleStroke.Color = Color3.fromRGB(0, 100, 150)
        ToggleStroke.Thickness = 1

        ToggleBtn.MouseButton1Click:Connect(function()
            state = not state
            UpdateVisuals()
            pcall(Callback, state)
        end)
    end

    return WindowElements
end


-- ================================================================
-- 2. ANIMAL HOSPITAL ANOMALY LOGIC
-- ================================================================

local Window = RZY_Library:MakeWindow("Animal Hospital (Anomaly)")
local LocalPlayer = game:GetService("Players").LocalPlayer

-- State Variables
local AutoCoffeeEnabled = false
local AutoCheckInEnabled = false
local EspEnabled = false
local AutoMedicineEnabled = false
local AutoSlimeEnabled = false
local AutoFireEnabled = false
local AutoTaserEnabled = false
local ProcessedNPCs = {}

-- UTILITY: Sistem Aman Tekan Prompt
local function firePromptIn(instance)
    if not instance then return end
    local prompt = instance:FindFirstChild("PP") or instance:FindFirstChildOfClass("ProximityPrompt")
    if prompt then fireproximityprompt(prompt) end
end

-- UTILITY: Normalisasi Teks (Hapus spasi dan jadikan huruf kecil untuk pencocokan)
local function normalizeString(str)
    if not str then return "" end
    return string.gsub(string.lower(str), "%s+", "")
end

-- UTILITY: Cari Pasien Aktif & Meja (CheckIn 1 dan 2)
local function getActivePatientInfo()
    local misc = workspace:FindFirstChild("Misc")
    if not misc then return nil, nil, nil end

    local deskNames = {"CheckIn", "CheckIn2"}
    for _, deskName in ipairs(deskNames) do
        local desk = misc:FindFirstChild(deskName)
        if desk then
            local bell = desk:FindFirstChild("Bell")
            if bell then
                local bellPos = bell:IsA("BasePart") and bell.Position or (bell:FindFirstChildOfClass("BasePart") and bell:FindFirstChildOfClass("BasePart").Position)
                if bellPos then
                    for _, npc in ipairs(workspace.NPCs:GetChildren()) do
                        if npc:GetAttribute("IsPatient") == true then
                            local root = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
                            if root and (root.Position - bellPos).Magnitude <= 5 then
                                return npc, desk, bellPos
                            end
                        end
                    end
                end
            end
        end
    end
    return nil, nil, nil
end

-- ================================================================
-- FITUR: AUTO COFFEE
-- ================================================================
Window:AddToggle("Auto Coffee Machine", false, function(state) AutoCoffeeEnabled = state end)
task.spawn(function()
    while task.wait(0.5) do
        if AutoCoffeeEnabled then
            pcall(function()
                local coffeeMachine = workspace.Misc:FindFirstChild("CoffeeMachine")
                if coffeeMachine then
                    local statusUI = coffeeMachine:FindFirstChild("Attachment") and coffeeMachine.Attachment:FindFirstChild("UI")
                    local statusLabel = statusUI and statusUI:FindFirstChild("status")
                    if statusLabel and string.find(statusLabel.Text:lower(), "ready") then
                        firePromptIn(coffeeMachine:FindFirstChild("Coffee"))
                    end
                end
            end)
        end
    end
end)

-- ================================================================
-- FITUR: NPC ESP
-- ================================================================
Window:AddToggle("NPC Anomaly ESP", false, function(state)
    EspEnabled = state
    if not state then
        for _, npc in ipairs(workspace.NPCs:GetChildren()) do
            if npc:FindFirstChild("AnomalyHighlight") then npc.AnomalyHighlight:Destroy() end
            if npc:FindFirstChild("AnomalyTag") then npc.AnomalyTag:Destroy() end
        end
    end
end)
local function applyESP(npc)
    if not EspEnabled then return end
    local isSkinwalker = npc:GetAttribute("Skinwalker")
    local color = isSkinwalker == true and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
    
    local highlight = npc:FindFirstChild("AnomalyHighlight") or Instance.new("Highlight", npc)
    highlight.Name, highlight.FillColor, highlight.FillTransparency, highlight.OutlineColor, highlight.OutlineTransparency, highlight.Enabled = "AnomalyHighlight", color, 0.5, color, 0, true

    local root = npc:FindFirstChild("HumanoidRootPart")
    if root then
        local tag = npc:FindFirstChild("AnomalyTag") or Instance.new("BillboardGui", npc)
        tag.Name, tag.Size, tag.AlwaysOnTop, tag.StudsOffset = "AnomalyTag", UDim2.new(0, 200, 0, 50), true, Vector3.new(0, 3, 0)
        local label = tag:FindFirstChildOfClass("TextLabel") or Instance.new("TextLabel", tag)
        label.Size, label.BackgroundTransparency, label.Font, label.TextSize = UDim2.new(1, 0, 1, 0), 1, Enum.Font.GothamBold, 14
        
        tag.Enabled = true
        label.Text = npc.Name .. "\n" .. (isSkinwalker == true and "[ANOMALY]" or "[NORMAL]")
        label.TextColor3 = color
    end
end
task.spawn(function()
    while task.wait(1) do
        if EspEnabled then
            for _, npc in ipairs(workspace.NPCs:GetChildren()) do pcall(applyESP, npc) end
        end
    end
end)

-- ================================================================
-- FITUR: AUTO CHECK-IN (Tetap sama karena sudah aman)
-- ================================================================
Window:AddToggle("Auto Check-In (Normal Only)", false, function(state)
    AutoCheckInEnabled = state
    if not state then table.clear(ProcessedNPCs) end
end)
task.spawn(function()
    while task.wait(1) do
        if AutoCheckInEnabled then
            local activeNPC, activeDesk, bellPos = getActivePatientInfo()
            if activeNPC and activeDesk and bellPos and not ProcessedNPCs[activeNPC] then
                if activeNPC:GetAttribute("Skinwalker") == true then
                    ProcessedNPCs[activeNPC] = true
                else
                    ProcessedNPCs[activeNPC] = true 
                    task.spawn(function()
                        local mainCheckIn = workspace.Misc:FindFirstChild("CheckIn")
                        if mainCheckIn then
                            while activeNPC and activeNPC.Parent and AutoCheckInEnabled do
                                local root = activeNPC:FindFirstChild("HumanoidRootPart") or activeNPC.PrimaryPart
                                if not root or (root.Position - bellPos).Magnitude > 5 then break end

                                pcall(function()
                                    firePromptIn(activeDesk:FindFirstChild("Form")); task.wait(0.1)
                                    firePromptIn(activeDesk:FindFirstChild("Camera")); task.wait(0.1)
                                    firePromptIn(mainCheckIn:FindFirstChild("Computer")); task.wait(0.1)
                                    firePromptIn(mainCheckIn:FindFirstChild("Printer")); task.wait(0.1) 
                                    firePromptIn(activeDesk:FindFirstChild("PrintedBadge")); task.wait(0.1)
                                    firePromptIn(activeNPC)
                                end)
                                task.wait(0.1)
                            end
                        end
                    end)
                end
            end
        end
    end
end)
workspace.NPCs.ChildRemoved:Connect(function(child) if ProcessedNPCs[child] then ProcessedNPCs[child] = nil end end)

-- ================================================================
-- FITUR: AUTO AMBIL OBAT (Room 8) - DIPERBARUI BERDASARKAN VIDEO!
-- ================================================================
Window:AddToggle("Auto Ambil Obat (Room 8)", false, function(state) AutoMedicineEnabled = state end)
task.spawn(function()
    while task.wait(0.5) do
        if AutoMedicineEnabled then
            pcall(function()
                local room8Folder = workspace.Rooms.Emergency:FindFirstChild("Room8")
                if not room8Folder then return end
                
                local room8 = room8Folder:FindFirstChild("Room8") or room8Folder
                local minigame = room8:FindFirstChild("Minigame")
                if not minigame then return end
                
                local tv = minigame:FindFirstChild("TV")
                local medicineFolder = minigame:FindFirstChild("Medicine")
                if not tv or not medicineFolder then return end

                -- Langkah 1: Kumpulkan semua obat yang sedang diminta oleh layar TV
                local itemsNeeded = {}
                -- Mencari menembus semua struktur folder TV karena kadang letaknya di treatment.inv atau Report.inv
                for _, desc in ipairs(tv:GetDescendants()) do
                    if desc.Name == "inv" then
                        for _, uiItem in ipairs(desc:GetChildren()) do
                            -- Hindari elemen UI bawaan, pastikan ini adalah frame item
                            if not uiItem:IsA("UIListLayout") and not uiItem:IsA("UIPadding") and not uiItem:IsA("UICorner") then
                                if uiItem.Visible then
                                    itemsNeeded[uiItem.Name] = true
                                end
                            end
                        end
                    end
                end

                -- Langkah 2: Proses setiap obat yang dibutuhkan
                for itemName, _ in pairs(itemsNeeded) do
                    -- Gunakan normalize (hapus spasi, huruf kecil semua) untuk menghindari error nama "IV Drops" vs "IVDrops"
                    local normItemName = normalizeString(itemName)
                    local hasInBackpack = false
                    
                    -- Cek isi tas (Backpack)
                    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
                        if normalizeString(item.Name) == normItemName then
                            hasInBackpack = true
                            break
                        end
                    end
                    
                    -- Cek tangan karakter (jika sedang dipegang)
                    local char = LocalPlayer.Character
                    if char and not hasInBackpack then
                        for _, item in ipairs(char:GetChildren()) do
                            if item:IsA("Tool") and normalizeString(item.Name) == normItemName then
                                hasInBackpack = true
                                break
                            end
                        end
                    end
                    
                    -- Langkah 3: Jika belum punya, cari promptnya di meja Medicine dan ambil
                    if not hasInBackpack then
                        for _, desc in ipairs(medicineFolder:GetDescendants()) do
                            if desc:IsA("ProximityPrompt") then
                                local parentName = desc.Parent and desc.Parent.Name or ""
                                -- Cek apakah part induk atau objek promptnya memiliki nama obat yang kita cari
                                if normalizeString(parentName) == normItemName or normalizeString(desc.ObjectText) == normItemName then
                                    fireproximityprompt(desc)
                                    task.wait(1.5) -- Beri jeda 1.5 detik setelah ambil satu obat, agar tidak tersendat servernya
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ================================================================
-- FITUR: AUTO CLEAN SLIME (Tetap sama)
-- ================================================================
Window:AddToggle("Auto Clean Slime", false, function(state) AutoSlimeEnabled = state end)
task.spawn(function()
    while task.wait(1) do
        if AutoSlimeEnabled then
            pcall(function()
                local slime = workspace.Misc:FindFirstChild("Slime")
                if slime then firePromptIn(slime) end
            end)
        end
    end
end)

-- ================================================================
-- FITUR: AUTO EXTINGUISH FIRE (Tetap sama karena sudah aman)
-- ================================================================
Window:AddToggle("Auto Extinguish Fire", false, function(state) AutoFireEnabled = state end)
task.spawn(function()
    while task.wait(1) do
        if AutoFireEnabled then
            pcall(function()
                local rooms = workspace:FindFirstChild("Rooms")
                if rooms then
                    for _, desc in ipairs(rooms:GetDescendants()) do
                        if desc.Name == "Fire" then
                            for _, pp in ipairs(desc:GetDescendants()) do
                                if pp.Name == "PP" or pp:IsA("ProximityPrompt") then
                                    fireproximityprompt(pp)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ================================================================
-- FITUR: AUTO TASER ANOMALY (Tetap sama)
-- ================================================================
Window:AddToggle("Auto Taser Anomaly", false, function(state) AutoTaserEnabled = state end)
task.spawn(function()
    while task.wait(1) do
        if AutoTaserEnabled then
            pcall(function()
                for _, npc in ipairs(workspace.NPCs:GetChildren()) do
                    if npc:GetAttribute("Skinwalker") == true then
                        local args = { npc }
                        game:GetService("ReplicatedStorage"):WaitForChild("Util"):WaitForChild("Net"):WaitForChild("RE/TaserFired"):FireServer(unpack(args))
                        task.wait(1)
                    end
                end
            end)
        end
    end
end)
