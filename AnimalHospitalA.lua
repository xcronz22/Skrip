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
                local bellPos
                if bell:IsA("BasePart") then
                    bellPos = bell.Position
                else
                    local actualPart = bell:FindFirstChildOfClass("BasePart") or (bell:IsA("Model") and bell.PrimaryPart)
                    if actualPart then bellPos = actualPart.Position end
                end

                if bellPos then
                    for _, npc in ipairs(workspace.NPCs:GetChildren()) do
                        if npc:GetAttribute("IsPatient") == true then
                            local root = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
                            if root then
                                local distance = (root.Position - bellPos).Magnitude
                                if distance <= 5 then
                                    return npc, desk, bellPos
                                end
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
Window:AddToggle("Auto Coffee Machine", false, function(state)
    AutoCoffeeEnabled = state
end)
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
    local tagText = isSkinwalker == true and "[ANOMALY]" or "[NORMAL]"

    local highlight = npc:FindFirstChild("AnomalyHighlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "AnomalyHighlight"
        highlight.Parent = npc
    end
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = color
    highlight.OutlineTransparency = 0
    highlight.Enabled = true

    local root = npc:FindFirstChild("HumanoidRootPart")
    if root then
        local tag = npc:FindFirstChild("AnomalyTag")
        if not tag then
            tag = Instance.new("BillboardGui")
            tag.Name = "AnomalyTag"
            tag.Size = UDim2.new(0, 200, 0, 50)
            tag.AlwaysOnTop = true
            tag.StudsOffset = Vector3.new(0, 3, 0)
            tag.Parent = npc

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            label.Parent = tag
        end
        tag.Enabled = true
        tag.TextLabel.Text = npc.Name .. "\n" .. tagText
        tag.TextLabel.TextColor3 = color
    end
end

task.spawn(function()
    while task.wait(1) do
        if EspEnabled then
            for _, npc in ipairs(workspace.NPCs:GetChildren()) do
                pcall(applyESP, npc)
            end
        end
    end
end)

-- ================================================================
-- FITUR: AUTO CHECK-IN 
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
                local isSkinwalker = activeNPC:GetAttribute("Skinwalker")
                
                if isSkinwalker == true then
                    ProcessedNPCs[activeNPC] = true
                else
                    ProcessedNPCs[activeNPC] = true 
                    
                    task.spawn(function()
                        local mainCheckIn = workspace.Misc:FindFirstChild("CheckIn")
                        
                        if mainCheckIn then
                            while activeNPC and activeNPC.Parent and AutoCheckInEnabled do
                                local root = activeNPC:FindFirstChild("HumanoidRootPart") or activeNPC.PrimaryPart
                                if not root or (root.Position - bellPos).Magnitude > 5 then
                                    break 
                                end

                                pcall(function()
                                    local form = activeDesk:FindFirstChild("Form")
                                    firePromptIn(form)
                                    task.wait(0.7)
                                    
                                    local camera = activeDesk:FindFirstChild("Camera")
                                    firePromptIn(camera)
                                    task.wait(0.7)
                                    
                                    local computer = mainCheckIn:FindFirstChild("Computer")
                                    firePromptIn(computer)
                                    task.wait(0.7)
                                    
                                    local printer = mainCheckIn:FindFirstChild("Printer")
                                    firePromptIn(printer)
                                    task.wait(3.0) 
                                    
                                    local printedBadge = activeDesk:FindFirstChild("PrintedBadge")
                                    firePromptIn(printedBadge)
                                    task.wait(0.7)
                                    
                                    firePromptIn(activeNPC)
                                end)
                                
                                task.wait(1.5)
                            end
                        end
                    end)
                end
            end
        end
    end
end)

workspace.NPCs.ChildRemoved:Connect(function(child)
    if ProcessedNPCs[child] then ProcessedNPCs[child] = nil end
end)

-- ================================================================
-- FITUR: AUTO AMBIL OBAT (Room 8 - Fixed Deep Search)
-- ================================================================
Window:AddToggle("Auto Ambil Obat (Room 8)", false, function(state)
    AutoMedicineEnabled = state
end)
task.spawn(function()
    while task.wait(0.5) do
        if AutoMedicineEnabled then
            pcall(function()
                -- Mengatasi bug Folder Ganda (Room8.Room8)
                local room8Folder = workspace.Rooms.Emergency:FindFirstChild("Room8")
                if not room8Folder then return end
                
                local room8 = room8Folder:FindFirstChild("Room8") or room8Folder
                local minigame = room8:FindFirstChild("Minigame")
                if not minigame then return end
                
                local tv = minigame:FindFirstChild("TV")
                local medicineFolder = minigame:FindFirstChild("Medicine")
                if not tv or not medicineFolder then return end

                -- Menggunakan FindFirstChild(..., true) agar bisa menembus path monitor TV yg panjang & berantakan
                local inv = tv:FindFirstChild("inv", true)
                if not inv then return end

                for _, uiItem in ipairs(inv:GetChildren()) do
                    if not uiItem:IsA("UIListLayout") and not uiItem:IsA("UIPadding") and uiItem.Visible then
                        local itemName = uiItem.Name
                        local char = LocalPlayer.Character
                        local hasInBackpack = LocalPlayer.Backpack:FindFirstChild(itemName)
                        local hasInHand = char and char:FindFirstChild(itemName)
                        
                        if not hasInBackpack and not hasInHand then
                            -- Cari ProximityPrompt di seluruh folder Medicine
                            for _, desc in ipairs(medicineFolder:GetDescendants()) do
                                if desc:IsA("ProximityPrompt") then
                                    -- Memastikan Part/Model-nya punya nama yg sama dengan item (misal "IV Drops")
                                    if desc.Parent and (desc.Parent.Name == itemName or desc.ObjectText == itemName) then
                                        fireproximityprompt(desc)
                                        task.wait(1) 
                                        break
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

-- ================================================================
-- FITUR: AUTO CLEAN SLIME
-- ================================================================
Window:AddToggle("Auto Clean Slime", false, function(state)
    AutoSlimeEnabled = state
end)
task.spawn(function()
    while task.wait(1) do
        if AutoSlimeEnabled then
            pcall(function()
                local slime = workspace.Misc:FindFirstChild("Slime")
                if slime then
                    local pp = slime:FindFirstChild("PP")
                    if pp then fireproximityprompt(pp) end
                end
            end)
        end
    end
end)

-- ================================================================
-- FITUR: AUTO EXTINGUISH FIRE (Fixed Deep Search)
-- ================================================================
Window:AddToggle("Auto Extinguish Fire", false, function(state)
    AutoFireEnabled = state
end)
task.spawn(function()
    while task.wait(1) do
        if AutoFireEnabled then
            pcall(function()
                local foldersToCheck = {
                    workspace.Rooms:FindFirstChild("Medical"),
                    workspace.Rooms:FindFirstChild("Emergency")
                }
                
                for _, folder in ipairs(foldersToCheck) do
                    if folder then
                        -- Menggunakan GetDescendants untuk langsung mencari semua ProximityPrompt
                        -- tanpa peduli seberapa dalam foldernya (mengatasi isu Room5.Room5.Fire.Fire.PP)
                        for _, desc in ipairs(folder:GetDescendants()) do
                            if desc:IsA("ProximityPrompt") then
                                -- Mengecek apakah tombol ini milik api
                                if desc.ActionText == "Put out fire" or (desc.Parent and desc.Parent.Name == "Fire") then
                                    fireproximityprompt(desc)
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
-- FITUR: AUTO TASER ANOMALY
-- ================================================================
Window:AddToggle("Auto Taser Anomaly", false, function(state)
    AutoTaserEnabled = state
end)
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
