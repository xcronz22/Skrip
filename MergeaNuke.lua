-- Memuat Library RZY
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()

-- Membuat Window/Panel UI menggunakan fungsi asli dari library
local Window = Library:MakeWindow("Merge a Nuke! Hub")

-- Services & Variables
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local NukeRemotes = ReplicatedStorage:WaitForChild("NukeRemotes")

-- Global Toggles
_G.AutoMerge = false
_G.AutoUpgrade = false
_G.AutoLockBase = false
_G.AutoRebirth = false

-- ==========================================
-- FUNGSI PENCARI BASE
-- ==========================================
local function GetMyBase()
    local basesFolder = workspace:FindFirstChild("Bases")
    if basesFolder then
        for _, base in pairs(basesFolder:GetChildren()) do
            local nukesFolder = base:FindFirstChild("Nukes")
            if nukesFolder then
                for _, nuke in pairs(nukesFolder:GetChildren()) do
                    if nuke:GetAttribute("OwnerUserId") == LocalPlayer.UserId then return base end
                end
            end
        end
        for _, base in pairs(basesFolder:GetChildren()) do
            if base:GetAttribute("OwnerUserId") == LocalPlayer.UserId then return base end
        end
        for _, base in pairs(basesFolder:GetChildren()) do
            local success, match = pcall(function()
                return base.Floor.BillboardGui.TextLabel.Text == "rzkym22" or string.find(base.Floor.BillboardGui.TextLabel.Text, LocalPlayer.Name)
            end)
            if success and match then return base end
        end
    end
    return nil
end

-- ==========================================
-- SMART ORGANIZE & MERGE LOGIC
-- ==========================================
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoMerge then
            local myBase = GetMyBase()
            local character = LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")

            if myBase and myBase:FindFirstChild("Nukes") and myBase:FindFirstChild("Floor") and rootPart then
                local floor = myBase.Floor
                local nukes = myBase.Nukes:GetChildren()
                
                if #nukes == 0 then continue end

                -- Kelompokkan Tier & Cari yang Tertinggi
                local tierGroups = {}
                local highestTier = -1
                
                for _, nuke in pairs(nukes) do
                    local tier = tonumber(nuke:GetAttribute("Tier"))
                    if tier then
                        if tier > highestTier then highestTier = tier end
                        if not tierGroups[tier] then tierGroups[tier] = {} end
                        table.insert(tierGroups[tier], nuke)
                    end
                end

                -- Tentukan Nuke Display (Pajangan Utama)
                local displayNuke = nil
                if tierGroups[highestTier] and #tierGroups[highestTier] > 0 then
                    displayNuke = tierGroups[highestTier][1]
                end

                -- FUNGSI PENGAMAN TELEPORTASI
                local function SafeAction(actionFunc)
                    local originalCF = rootPart.CFrame
                    -- 1. Buang Nuke nyasar yang mungkin tak sengaja terpegang sebelum mulai
                    pcall(function() NukeRemotes.Drop:FireServer(rootPart.CFrame * CFrame.new(0, 0, -5)) end)
                    
                    -- 2. Kunci fisik karakter agar tidak terpental objek
                    rootPart.Anchored = true
                    
                    -- 3. Eksekusi tugas (Merge/Pindah)
                    pcall(function() actionFunc() end)
                    
                    -- 4. SELALU kembalikan ke tempat asal dan buka kunci
                    rootPart.CFrame = originalCF
                    rootPart.Anchored = false
                end

                local actionTaken = false

                -- [ PRIORITAS 1 ]: LAKUKAN MERGE JIKA ADA TIER SAMA
                for tier, list in pairs(tierGroups) do
                    if #list >= 2 then
                        local nuke1 = list[1]
                        local nuke2 = list[2]
                        
                        SafeAction(function()
                            -- Posisi ambil agak ke atas sedikit (+2) supaya kaki tidak nyangkut ke nuke lain
                            rootPart.CFrame = nuke1.CFrame + Vector3.new(0, 2, 0)
                            task.wait(0.15)
                            NukeRemotes.PickUp:FireServer(nuke1)
                            task.wait(0.1)
                            
                            rootPart.CFrame = nuke2.CFrame + Vector3.new(0, 2, 0)
                            task.wait(0.15)
                            NukeRemotes.MergeRequest:FireServer(nuke2)
                            NukeRemotes.Drop:FireServer(nuke2.CFrame)
                            task.wait(0.1)
                        end)
                        
                        actionTaken = true
                        break -- Hentikan loop agar daftar nukes diperbarui dulu dari server
                    end
                end

                if actionTaken then continue end

                -- [ PRIORITAS 2 ]: RAPIKAN BASE JIKA TIDAK ADA YANG DI-MERGE
                local fSize = floor.Size
                local fCF = floor.CFrame
                local yOffset = (fSize.Y / 2) + 1.5 -- Menyesuaikan letak nuke tepat di atas lantai
                
                local centerTarget = fCF * CFrame.new(0, yOffset, 0)
                local cornerStart = fCF * CFrame.new(-fSize.X/2 + 6, yOffset, -fSize.Z/2 + 6)
                
                local row, col = 0, 0
                local spacing = 8 -- Jarak antar Nuke (Cukup jauh agar tak terambil tidak sengaja)
                local maxCols = math.floor(fSize.X / spacing) - 1
                if maxCols < 1 then maxCols = 4 end

                for _, nuke in pairs(nukes) do
                    local targetCF
                    
                    if nuke == displayNuke then
                        -- Nuke tertinggi taruh di tengah base
                        targetCF = centerTarget
                    else
                        -- Nuke lainnya baris rapi di pojok
                        targetCF = cornerStart * CFrame.new(col * spacing, 0, row * spacing)
                        col = col + 1
                        if col > maxCols then
                            col = 0
                            row = row + 1
                        end
                    end
                    
                    -- Jika Nuke bergeser atau lokasinya tidak sesuai target (> 4 stud jaraknya)
                    if (nuke.Position - targetCF.Position).Magnitude > 4 then
                        SafeAction(function()
                            rootPart.CFrame = nuke.CFrame + Vector3.new(0, 2, 0)
                            task.wait(0.15)
                            NukeRemotes.PickUp:FireServer(nuke)
                            task.wait(0.1)
                            
                            rootPart.CFrame = targetCF + Vector3.new(0, 2, 0)
                            task.wait(0.15)
                            NukeRemotes.Drop:FireServer(targetCF)
                            task.wait(0.1)
                        end)
                        
                        actionTaken = true
                        break -- Rapikan perlahan 1 per 1 agar server tidak lag
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- AUTO UPGRADE, LOCK BASE, & REBIRTH LOGIC
-- ==========================================
task.spawn(function()
    while task.wait(1) do
        -- AUTO UPGRADE
        if _G.AutoUpgrade then
            pcall(function() NukeRemotes.PurchaseUpgrade:FireServer("MAX") end)
            pcall(function() NukeRemotes.PurchaseUpgrade:FireServer("MAX SPAWN") end)
            pcall(function() NukeRemotes.PurchaseUpgrade:FireServer("TIER") end)
            pcall(function() NukeRemotes.PurchaseUpgrade:FireServer("SPAWN") end)
            pcall(function() NukeRemotes.PurchaseUpgrade:FireServer("SPAWN TIER") end)
            pcall(function() NukeRemotes.PurchaseUpgrade:FireServer("LOCKBASE") end)
        end
        
        -- AUTO LOCK BASE
        if _G.AutoLockBase then
            pcall(function() NukeRemotes.RequestLockBase:FireServer() end)
        end

        -- AUTO REBIRTH
        if _G.AutoRebirth then
            pcall(function() NukeRemotes.Rebirth:FireServer() end)
            pcall(function() NukeRemotes.RebirthRequest:FireServer() end)
            pcall(function() NukeRemotes.RequestRebirth:FireServer() end)
            pcall(function() NukeRemotes.PurchaseUpgrade:FireServer("REBIRTH") end)
        end
    end
end)

-- ==========================================
-- MENU / UI TOGGLES
-- ==========================================
Window:AddToggle("Auto Smart Merge", false, function(state)
    _G.AutoMerge = state
end)

Window:AddToggle("Auto Upgrade (All)", false, function(state)
    _G.AutoUpgrade = state
end)

Window:AddToggle("Auto Lock Base", false, function(state)
    _G.AutoLockBase = state
end)

Window:AddToggle("Auto Rebirth", false, function(state)
    _G.AutoRebirth = state
end)
