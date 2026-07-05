-- Memuat UI Library milik Anda
local RZY_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
[span_1](start_span)local Window = RZY_Library:MakeWindow("Animal Hospital (Anomaly)")[span_1](end_span)

-- State Variables
local AutoCoffeeEnabled = false
local AutoCheckInEnabled = false
local EspEnabled = false

----------------------------------------------------------------
-- UTILITY FUNCTIONS
----------------------------------------------------------------

-- Fungsi untuk mencari NPC yang sedang berada di meja kasir/dekat Bell
local function getActivePatient()
    local bell = workspace.Misc:FindFirstChild("CheckIn") and workspace.Misc.CheckIn:FindFirstChild("Bell")
    if not bell then return nil end

    for _, npc in ipairs(workspace.NPCs:GetChildren()) do
        local root = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
        if root then
            -- Mengecek jarak antara NPC dan Bell (estimasi ~12 studs sesuai screenshot)
            local distance = (root.Position - bell.Position).Magnitude
            if distance <= 12 then
                return npc
            end
        end
    end
    return nil
end

----------------------------------------------------------------
-- FEATURE: AUTO COFFEE (Menggunakan Filter Status)
----------------------------------------------------------------
[span_2](start_span)Window:AddToggle("Auto Coffee Machine", false, function(state)[span_2](end_span)
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
                    
                    -- Membaca text filter agar tidak terjadi spam saat cooldown
                    if statusLabel and string.find(statusLabel.Text:lower(), "ready") then
                        local prompt = coffeeMachine:FindFirstChild("Coffee") and coffeeMachine.Coffee:FindFirstChild("PP")
                        if prompt then
                            fireproximityprompt(prompt)
                        end
                    end
                end
            end)
        end
    end
end)

----------------------------------------------------------------
-- FEATURE: NPC ESP & ANOMALY DETECTOR
----------------------------------------------------------------
[span_3](start_span)Window:AddToggle("NPC Anomaly ESP", false, function(state)[span_3](end_span)
    EspEnabled = state
    if not state then
        -- Menghapus ESP visual jika dinonaktifkan
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

    -- 1. Buat Bounding/Chams Highlight
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

    -- 2. Buat Teks Informasi di atas Kepala NPC
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

-- Loop update ESP secara berkala
task.spawn(function()
    while task.wait(1) do
        if EspEnabled then
            for _, npc in ipairs(workspace.NPCs:GetChildren()) do
                pcall(applyESP, npc)
            end
        end
    end
end)

----------------------------------------------------------------
-- FEATURE: AUTO CHECK-IN PATIENTS (Anti-Spam & Normal Only)
----------------------------------------------------------------
-- Tabel untuk mencatat NPC yang sudah diproses
local ProcessedNPCs = {}

Window:AddToggle("Auto Check-In (Normal Only)", false, function(state)
    AutoCheckInEnabled = state
    -- Bersihkan riwayat jika fitur dimatikan agar bisa mulai dari awal saat dinyalakan lagi
    if not state then
        table.clear(ProcessedNPCs)
    end
end)

task.spawn(function()
    while task.wait(1) do
        if AutoCheckInEnabled then
            local activeNPC = getActivePatient()
            
            -- Pastikan ada pasien di dekat bel DAN belum pernah diproses
            if activeNPC and not ProcessedNPCs[activeNPC] then
                local isSkinwalker = activeNPC:GetAttribute("Skinwalker")
                
                -- Langsung tandai NPC ini sudah dipegang oleh skrip
                -- Ini mencegah loop berikutnya melakukan spam prompt
                ProcessedNPCs[activeNPC] = true
                
                if isSkinwalker ~= true then
                    local checkIn = workspace.Misc:FindFirstChild("CheckIn")
                    if checkIn then
                        pcall(function()
                            -- Langkah 1: Form
                            if checkIn:FindFirstChild("Form") and checkIn.Form:FindFirstChild("PP") then
                                fireproximityprompt(checkIn.Form.PP)
                                task.wait(0.7)
                            end
                            -- Langkah 2: Camera
                            if checkIn:FindFirstChild("Camera") and checkIn.Camera:FindFirstChild("PP") then
                                fireproximityprompt(checkIn.Camera.PP)
                                task.wait(0.7)
                            end
                            -- Langkah 3: Computer
                            if checkIn:FindFirstChild("Computer") and checkIn.Computer:FindFirstChild("PP") then
                                fireproximityprompt(checkIn.Computer.PP)
                                task.wait(0.7)
                            end
                            -- Langkah 4: Printer
                            if checkIn:FindFirstChild("Printer") and checkIn.Printer:FindFirstChild("PP") then
                                fireproximityprompt(checkIn.Printer.PP)
                                task.wait(0.7)
                            end
                            -- Langkah 5: PrintedBadge
                            if checkIn:FindFirstChild("PrintedBadge") and checkIn.PrintedBadge:FindFirstChild("PP") then
                                fireproximityprompt(checkIn.PrintedBadge.PP)
                                task.wait(0.7)
                            end
                            -- Langkah 6: Klik NPC
                            if activeNPC:FindFirstChild("PP") then
                                fireproximityprompt(activeNPC.PP)
                            end
                        end)
                    end
                else
                    -- Jika dia Anomaly, kita biarkan saja (jangan di-check-in), 
                    -- tapi tetap ditandai 'Processed' supaya loop tidak mengecek atributnya berkali-kali (hemat CPU).
                end
            end
        end
    end
end)

-- Membersihkan data NPC yang sudah hancur/hilang dari map agar tidak memenuhi RAM (Memory Leak)
workspace.NPCs.ChildRemoved:Connect(function(child)
    if ProcessedNPCs[child] then
        ProcessedNPCs[child] = nil
    end
end)
