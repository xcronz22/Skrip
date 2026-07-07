-- ================================================================
-- 1. LOAD UI LIBRARY DARI GITHUB
-- ================================================================
local RZY_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()

-- ================================================================
-- 2. INISIALISASI WINDOW & VARIABEL
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

-- UTILITY: Normalisasi Teks
local function normalizeString(str)
    if not str then return "" end
    return string.gsub(string.lower(str), "%s+", "")
end

-- UTILITY: Cari Pasien Aktif & Meja
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
Window:AddToggle("Auto Coffee Machine", false, function(state) AutoCoffeeEnabled = state end)
task.spawn(function()
    while task.wait(0.5) do
        if AutoCoffeeEnabled then
            pcall(function()
                local coffeeMachine = workspace:FindFirstChild("CoffeeMachine") or (workspace:FindFirstChild("Misc") and workspace.Misc:FindFirstChild("CoffeeMachine"))
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
                                    task.wait(0.7) 
                                    
                                    local printedBadge = activeDesk:FindFirstChild("PrintedBadge")
                                    firePromptIn(printedBadge)
                                    task.wait(0.7)
                                    
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

workspace.NPCs.ChildRemoved:Connect(function(child)
    if ProcessedNPCs[child] then ProcessedNPCs[child] = nil end
end)

-- ================================================================
-- FITUR: AUTO AMBIL OBAT (Room 8) - SMART GRAB (CEKLIST HIJAU)
-- ================================================================
local function hasTool(parentFolder, itemName)
    if not parentFolder then return false end
    local normName = normalizeString(itemName)
    for _, tool in ipairs(parentFolder:GetChildren()) do
        if tool:IsA("Tool") and normalizeString(tool.Name) == normName then
            return true
        end
    end
    return false
end

Window:AddToggle("Auto Ambil Obat (Room 8)", false, function(state) AutoMedicineEnabled = state end)
task.spawn(function()
    while task.wait(0.5) do
        if AutoMedicineEnabled then
            pcall(function()
                local rooms = workspace:FindFirstChild("Rooms")
                if not rooms then return end
                local emergency = rooms:FindFirstChild("Emergency")
                if not emergency then return end
                local room8 = emergency:FindFirstChild("Room8")
                if not room8 then return end
                local minigame = room8:FindFirstChild("Minigame")
                if not minigame then return end
                
                local tv = minigame:FindFirstChild("TV")
                local medicineFolder = minigame:FindFirstChild("Medicine")
                if not tv or not medicineFolder then return end

                local itemsNeeded = {}
                
                -- MENCARI ITEM YANG DIBUTUHKAN DI TV
                for _, desc in ipairs(tv:GetDescendants()) do
                    if desc.Name == "inv" then
                        for _, uiItem in ipairs(desc:GetChildren()) do
                            if uiItem:IsA("GuiObject") and not uiItem:IsA("UIListLayout") and not uiItem:IsA("UIPadding") and not uiItem:IsA("UICorner") then
                                
                                -- LOGIKA CERDAS: Cek apakah item sudah selesai (Ceklist Hijau)
                                local checkMark = uiItem:FindFirstChild("check")
                                if checkMark and checkMark.Visible == true then
                                    -- Jika sudah diceklist hijau, lewati item ini (jangan dimasukkan ke daftar itemsNeeded)
                                    continue
                                else
                                    -- Jika belum diceklist, masukkan ke daftar untuk diambil dari folder obat
                                    itemsNeeded[uiItem.Name] = true
                                end
                                
                            end
                        end
                    end
                end

                local grabbedSomething = false

                for itemName, _ in pairs(itemsNeeded) do
                    local normItemName = normalizeString(itemName)
                    local char = LocalPlayer.Character
                    
                    if not hasTool(LocalPlayer.Backpack, itemName) and not hasTool(char, itemName) then
                        for _, desc in ipairs(medicineFolder:GetDescendants()) do
                            if desc:IsA("ProximityPrompt") then
                                local parentName = desc.Parent and desc.Parent.Name or ""
                                if normalizeString(parentName) == normItemName or normalizeString(desc.ObjectText) == normItemName then
                                    
                                    local oldDist = desc.MaxActivationDistance
                                    local oldLOS = desc.RequiresLineOfSight
                                    
                                    desc.MaxActivationDistance = 9e9
                                    desc.RequiresLineOfSight = false
                                    
                                    fireproximityprompt(desc)
                                    
                                    task.spawn(function()
                                        task.wait(0.5)
                                        desc.MaxActivationDistance = oldDist
                                        desc.RequiresLineOfSight = oldLOS
                                    end)
                                    
                                    grabbedSomething = true
                                    -- Jeda sangat singkat agar bisa langsung mengambil obat berikutnya
                                    task.wait(0.3) 
                                    break -- Berhenti mencari obat INI, lanjut cek obat BERIKUTNYA di daftar itemsNeeded
                                end
                            end
                        end
                    end
                end

                if grabbedSomething then
                    -- Setelah mengambil obat yang dibutuhkan, tunggu sebentar sebelum looping kembali
                    task.wait(5) 
                end
            end)
        end
    end
end)

-- ================================================================
-- FITUR: AUTO CLEAN SLIME
-- ================================================================
Window:AddToggle("Auto Clean Slime", false, function(state) AutoSlimeEnabled = state end)
task.spawn(function()
    while task.wait(1) do
        if AutoSlimeEnabled then
            pcall(function()
                local slime = workspace:FindFirstChild("Slime") or (workspace:FindFirstChild("Misc") and workspace.Misc:FindFirstChild("Slime"))
                if slime then firePromptIn(slime) end
            end)
        end
    end
end)

-- ================================================================
-- FITUR: AUTO EXTINGUISH FIRE
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
-- FITUR: AUTO TASER ANOMALY
-- ================================================================
Window:AddToggle("Auto Taser Anomaly", false, function(state) AutoTaserEnabled = state end)
task.spawn(function()
    while task.wait(0.5) do
        if AutoTaserEnabled then
            pcall(function()
                local hasSkinwalker = false
                local targetNPC = nil
                
                -- 1. Cari apakah ada NPC Anomaly (Skinwalker) yang aktif
                for _, npc in ipairs(workspace.NPCs:GetChildren()) do
                    if npc:GetAttribute("Skinwalker") == true then
                        hasSkinwalker = true
                        targetNPC = npc
                        break
                    end
                end
                
                -- 2. Jika ada Anomaly, jalankan aksi
                if hasSkinwalker and targetNPC then
                    local char = LocalPlayer.Character
                    local backpack = LocalPlayer:FindFirstChild("Backpack")
                    
                    -- Cek apakah Taser sudah ada di tas atau sedang dipegang
                    local hasTaser = false
                    if backpack and backpack:FindFirstChild("Taser") then hasTaser = true end
                    if char and char:FindFirstChild("Taser") then hasTaser = true end
                    
                    -- Jika belum punya Taser, coba ambil dari TaserStation
                    if not hasTaser then
                        local taserStation = workspace:FindFirstChild("Misc") and workspace.Misc:FindFirstChild("TaserStation")
                        local mainPart = taserStation and taserStation:FindFirstChild("Main")
                        
                        if mainPart then
                            -- Cek Status Text "Ready"
                            local statusUI = mainPart:FindFirstChild("Attachment") and mainPart.Attachment:FindFirstChild("UI")
                            local statusLabel = statusUI and statusUI:FindFirstChild("status")
                            
                            -- Gunakan string.find dan string.lower untuk mendeteksi kata "ready" menembus tag font color
                            if statusLabel and statusLabel.Text and string.find(string.lower(statusLabel.Text), "ready") then
                                local taserPrompt = mainPart:FindFirstChild("PP")
                                
                                if taserPrompt and taserPrompt:IsA("ProximityPrompt") then
                                    -- BYPASS: Hapus batasan jarak dan halangan untuk memaksa PP bekerja
                                    local oldDist = taserPrompt.MaxActivationDistance
                                    local oldLOS = taserPrompt.RequiresLineOfSight
                                    
                                    taserPrompt.MaxActivationDistance = 9e9
                                    taserPrompt.RequiresLineOfSight = false
                                    
                                    fireproximityprompt(taserPrompt)
                                    
                                    -- Kembalikan settingan asli agar tidak error
                                    task.spawn(function()
                                        task.wait(0.5)
                                        taserPrompt.MaxActivationDistance = oldDist
                                        taserPrompt.RequiresLineOfSight = oldLOS
                                    end)
                                    
                                    task.wait(0.8) -- Jeda tunggu agar Taser masuk ke inventory dengan sempurna
                                end
                            end
                        end
                    end
                    
                    -- 3. Cek ulang apakah Taser SEKARANG sudah ada di tas/tangan, baru tembak
                    local hasTaserNow = false
                    if backpack and backpack:FindFirstChild("Taser") then hasTaserNow = true end
                    if char and char:FindFirstChild("Taser") then hasTaserNow = true end
                    
                    if hasTaserNow then
                        local args = { targetNPC }
                        game:GetService("ReplicatedStorage"):WaitForChild("Util"):WaitForChild("Net"):WaitForChild("RE/TaserFired"):FireServer(unpack(args))
                        task.wait(1)
                    end
                end
            end)
        end
    end
end)
