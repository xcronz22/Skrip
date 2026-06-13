-- Memuat Library RZY
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()

-- Membuat Window/Panel UI menggunakan fungsi asli dari library kamu (MakeWindow)
local Window = Library:MakeWindow("Merge a Nuke! Hub")

-- Services & Variables
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local NukeRemotes = ReplicatedStorage:WaitForChild("NukeRemotes")

-- Global Toggles
_G.AutoMerge = false
_G.AutoMaxSpawn = false
_G.AutoSpawnTier = false
_G.AutoLockBase = false
_G.AutoRebirth = false

-- ==========================================
-- FUNGSI PENCARI BASE (Akurat & Multi-Deteksi)
-- ==========================================
local function GetMyBase()
    local basesFolder = workspace:FindFirstChild("Bases")
    if basesFolder then
        -- Cara 1: Cek atribut OwnerUserId di Base atau di dalam Nukes (Sesuai Screenshot)
        for _, base in pairs(basesFolder:GetChildren()) do
            if base:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
                return base
            end
            
            local nukesFolder = base:FindFirstChild("Nukes")
            if nukesFolder then
                for _, nuke in pairs(nukesFolder:GetChildren()) do
                    if nuke:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
                        return base
                    end
                end
            end
        end

        -- Cara 2: Jika cara di atas gagal, deteksi via teks papan nama Floor (rzkym22)
        for _, base in pairs(basesFolder:GetChildren()) do
            local success, match = pcall(function()
                return base.Floor.BillboardGui.TextLabel.Text == "rzkym22" or string.find(base.Floor.BillboardGui.TextLabel.Text, LocalPlayer.Name)
            end)
            if success and match then
                return base
            end
        end
    end
    return nil
end

-- ==========================================
-- AUTO MERGE LOGIC (Berjalan di background)
-- ==========================================
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoMerge then
            local myBase = GetMyBase()
            if myBase and myBase:FindFirstChild("Nukes") then
                local nukes = myBase.Nukes:GetChildren()
                local tierGroups = {}

                -- Kelompokkan Nuke berdasarkan nilai "Tier"
                for _, nuke in pairs(nukes) do
                    local tier = nuke:GetAttribute("Tier")
                    if tier then
                        if not tierGroups[tier] then
                            tierGroups[tier] = {}
                        end
                        table.insert(tierGroups[tier], nuke)
                    end
                end

                -- Jika ada 2 atau lebih Nuke di Tier yang sama, tembakkan Remote Merge
                for tier, nukeList in pairs(tierGroups) do
                    if #nukeList >= 2 then
                        pcall(function()
                            NukeRemotes.MergeRequest:FireServer(nukeList[1])
                        end)
                        task.wait(0.1) -- Jeda ringan anti-lag
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- AUTO UPGRADE & REBIRTH LOGIC
-- ==========================================
task.spawn(function()
    while task.wait(1) do
        -- UPGRADES
        if _G.AutoMaxSpawn then
            pcall(function() NukeRemotes.PurchaseUpgrade:FireServer("MAX") end)
            pcall(function() NukeRemotes.PurchaseUpgrade:FireServer("MAX SPAWN") end)
        end
        if _G.AutoSpawnTier then
            pcall(function() 
                NukeRemotes.PurchaseUpgrade:FireServer("TIER")
                NukeRemotes.PurchaseUpgrade:FireServer("SPAWN")
                NukeRemotes.PurchaseUpgrade:FireServer("SPAWN TIER")
            end)
        end
        if _G.AutoLockBase then
            pcall(function() 
                NukeRemotes.PurchaseUpgrade:FireServer("LOCK")
                NukeRemotes.PurchaseUpgrade:FireServer("BASE")
                NukeRemotes.PurchaseUpgrade:FireServer("LOCK BASE")
            end)
        end

        -- REBIRTH
        if _G.AutoRebirth then
            -- Mencoba brute force beberapa kemungkinan remote rebirth game ini
            pcall(function() NukeRemotes.Rebirth:FireServer() end)
            pcall(function() NukeRemotes.RebirthRequest:FireServer() end)
            pcall(function() NukeRemotes.RequestRebirth:FireServer() end)
            pcall(function() NukeRemotes.PurchaseUpgrade:FireServer("REBIRTH") end)
        end
    end
end)

-- ==========================================
-- MENU / UI TOGGLES (Sesuai Format AddToggle Library Kamu)
-- ==========================================
-- Parameter: AddToggle("Nama Teks", StatusDefaultAwal, FungsiCallback)

Window:AddToggle("Auto Merge Nukes", false, function(state)
    _G.AutoMerge = state
end)

Window:AddToggle("Auto Rebirth", false, function(state)
    _G.AutoRebirth = state
end)

Window:AddToggle("Auto Max Spawn", false, function(state)
    _G.AutoMaxSpawn = state
end)

Window:AddToggle("Auto Spawn Tier", false, function(state)
    _G.AutoSpawnTier = state
end)

Window:AddToggle("Auto Lock Base", false, function(state)
    _G.AutoLockBase = state
end)
