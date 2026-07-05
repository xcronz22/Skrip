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

-- UTILITY: Cari Pasien Aktif (Check-In)
local function getActivePatient()
    local checkIn = workspace.Misc:FindFirstChild("CheckIn")
    local bell = checkIn and checkIn:FindFirstChild("Bell")
    if not bell then return nil end

    local bellPos = bell:IsA("BasePart") and bell.Position or (bell:FindFirstChildOfClass("BasePart") and bell:FindFirstChildOfClass("BasePart").Position)
    if not bellPos then return nil end

    for _, npc in ipairs(workspace.NPCs:GetChildren()) do
        if npc:GetAttribute("IsPatient") == true then
            local root = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
            if root and (root.Position - bellPos).Magnitude <= 15 then
                return npc
            end
        end
    end
    return nil
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
                    local statusLabel = coffeeMachine:FindFirstChild("Attachment") and coffeeMachine.Attachment:FindFirstChild("UI") and coffeeMachine.Attachment.UI:FindFirstChild("status")
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
    highlight.Name = "AnomalyHighlight"
    highlight.FillColor, highlight.FillTransparency, highlight.OutlineColor, highlight.OutlineTransparency, highlight.Enabled = color, 0.5, color, 0, true

    local root = npc:FindFirstChild("HumanoidRootPart")
    if root then
        local tag = npc:FindFirstChild("AnomalyTag")
        if not tag then
            tag = Instance.new("BillboardGui", npc)
            tag.Name, tag.Size, tag.AlwaysOnTop, tag.StudsOffset = "AnomalyTag", UDim2.new(0, 200, 0, 50), true, Vector3.new(0, 3, 0)
            local label = Instance.new("TextLabel", tag)
            label.Size, label.BackgroundTransparency, label.Font, label.TextSize = UDim2.new(1, 0, 1, 0), 1, Enum.Font.GothamBold, 14
        end
        tag.Enabled = true
        tag.TextLabel.Text = npc.Name .. "\n" .. (isSkinwalker == true and "[ANOMALY]" or "[NORMAL]")
        tag.TextLabel.TextColor3 = color
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
-- FITUR: AUTO CHECK-IN
-- ================================================================
Window:AddToggle("Auto Check-In (Normal Only)", false, function(state)
    AutoCheckInEnabled = state
    if not state then table.clear(ProcessedNPCs) end
end)
task.spawn(function()
    while task.wait(1) do
        if AutoCheckInEnabled then
            local activeNPC = getActivePatient()
            if activeNPC and not ProcessedNPCs[activeNPC] then
                ProcessedNPCs[activeNPC] = true 
                if activeNPC:GetAttribute("Skinwalker") ~= true then
                    task.spawn(function()
                        local checkIn = workspace.Misc:FindFirstChild("CheckIn")
                        while activeNPC and activeNPC.Parent and AutoCheckInEnabled and checkIn do
                            pcall(function()
                                firePromptIn(checkIn:FindFirstChild("Form")); task.wait(0.7)
                                firePromptIn(checkIn:FindFirstChild("Camera")); task.wait(0.7)
                                firePromptIn(checkIn:FindFirstChild("Computer")); task.wait(0.7)
                                firePromptIn(checkIn:FindFirstChild("Printer")); task.wait(3.0) 
                                firePromptIn(checkIn:FindFirstChild("PrintedBadge")); task.wait(0.7)
                                firePromptIn(activeNPC)
                            end)
                            task.wait(1.5)
                        end
                    end)
                end
            end
        end
    end
end)
workspace.NPCs.ChildRemoved:Connect(function(child) if ProcessedNPCs[child] then ProcessedNPCs[child] = nil end end)

-- ================================================================
-- FITUR: AUTO AMBIL OBAT (Room 8 - Fixed with recursive search)
-- ================================================================
Window:AddToggle("Auto Ambil Obat (Room 8)", false, function(state)
    AutoMedicineEnabled = state
end)
task.spawn(function()
    while task.wait(0.5) do
        if AutoMedicineEnabled then
            pcall(function()
                local room8 = workspace.Rooms.Emergency:FindFirstChild("Room8")
                if not room8 then return end

                local inv = room8.Minigame.TV.Screen.UI.Report:FindFirstChild("inv")
                local medicineFolder = room8.Minigame:FindFirstChild("Medicine")
                
                if not inv or not medicineFolder then return end

                for _, uiItem in ipairs(inv:GetChildren()) do
                    if not uiItem:IsA("UIListLayout") and not uiItem:IsA("UIPadding") and not uiItem:IsA("UICorner") and uiItem.Visible then
                        local itemName = uiItem.Name
                        local char = LocalPlayer.Character
                        local hasInBackpack = LocalPlayer.Backpack:FindFirstChild(itemName)
                        local hasInHand = char and char:FindFirstChild(itemName)
                        
                        if not hasInBackpack and not hasInHand then
                            -- Recursive search: menembus ke dalam 'Model' berdasarkan nama item
                            local itemPart = medicineFolder:FindFirstChild(itemName, true)
                            if itemPart then
                                local prompt = itemPart:FindFirstChild("PP") or itemPart:FindFirstChildOfClass("ProximityPrompt")
                                if prompt then
                                    fireproximityprompt(prompt)
                                    task.wait(1) 
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
-- FITUR: AUTO EXTINGUISH FIRE
-- ================================================================
Window:AddToggle("Auto Extinguish Fire", false, function(state)
    AutoFireEnabled = state
end)
task.spawn(function()
    while task.wait(1) do
        if AutoFireEnabled then
            pcall(function()
                -- Memeriksa di dalam Medical dan Emergency
                local foldersToCheck = {
                    workspace.Rooms:FindFirstChild("Medical"),
                    workspace.Rooms:FindFirstChild("Emergency")
                }
                
                for _, folder in ipairs(foldersToCheck) do
                    if folder then
                        for _, room in ipairs(folder:GetChildren()) do
                            local fire = room:FindFirstChild("Fire")
                            if fire then
                                -- Mencari semua ProximityPrompt di dalam model Fire
                                for _, desc in ipairs(fire:GetDescendants()) do
                                    if desc:IsA("ProximityPrompt") then
                                        fireproximityprompt(desc)
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
                        -- Gunakan remote event untuk menembak taser ke NPC tersebut
                        local args = { npc }
                        game:GetService("ReplicatedStorage"):WaitForChild("Util"):WaitForChild("Net"):WaitForChild("RE/TaserFired"):FireServer(unpack(args))
                        
                        -- Jeda sebentar setelah menembak satu anomaly agar tidak spam server
                        task.wait(1)
                    end
                end
            end)
        end
    end
end)
