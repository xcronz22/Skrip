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
_G.AutoMaxSpawn = false
_G.AutoSpawnTier = false
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
                    if nuke:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
                        return base
                    end
                end
            end
        end

        for _, base in pairs(basesFolder:GetChildren()) do
            if base:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
                return base
            end
        end

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
-- AUTO MERGE LOGIC (Sistem TP, Ambil, Gabung, Drop, Balik)
-- ==========================================
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoMerge then
            local myBase = GetMyBase()
            local character = LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")

            if myBase and myBase:FindFirstChild("Nukes") and rootPart then
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

                -- Eksekusi urutan untuk nuke dengan tier yang sama
                for tier, nukeList in pairs(tierGroups) do
                    if #nukeList >= 2 then
                        local nuke1 = nukeList[1]
                        local nuke2 = nukeList[2]

                        if nuke1 and nuke2 and nuke1.Parent and nuke2.Parent then
                            -- 1. Simpan posisi aslimu sekarang
                            local originalCFrame = rootPart.CFrame

                            -- 2. Teleport ke Nuke ke-1 dan Ambil (PickUp)
                            pcall(function()
                                rootPart.CFrame = nuke1.CFrame
                                task.wait(0.15) -- Jeda agar server mendaftarkan posisimu
                                NukeRemotes.PickUp:FireServer(nuke1)
                            end)
                            
                            task.wait(0.1)

                            -- 3. Teleport ke Nuke ke-2, Gabung (Merge), dan Jatuhkan (Drop)
                            pcall(function()
                                rootPart.CFrame = nuke2.CFrame
                                task.wait(0.15)
                                NukeRemotes.MergeRequest:FireServer(nuke2)
                                NukeRemotes.Drop:FireServer(nuke2.CFrame)
                            end)

                            task.wait(0.1)

                            -- 4. Kembalikan karakter ke posisi semula
                            pcall(function()
                                rootPart.CFrame = originalCFrame
                            end)

                            -- Jeda tambahan agar proses satu per satu tidak bertabrakan
                            task.wait(0.5) 
                        end
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
        
        -- AUTO LOCK BASE
        if _G.AutoLockBase then
            pcall(function() 
                NukeRemotes.RequestLockBase:FireServer()
            end)
        end

        -- REBIRTH
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
