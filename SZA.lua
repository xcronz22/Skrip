local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Window = Library:MakeWindow("SZA Script Pro")

-- ==========================================
-- INDEKS SENJATA (Smart Dictionary)
-- ==========================================
-- Format: ["Nama Senjata di Tangan"] = "Nama Senjata untuk Server"
local IndeksSenjata = {
    ["CosmicPistol"] = "CosmicPistol",
    ["Quasar"]       = "Quasar",
    ["Pulsar"]       = "Pulsar",
    ["Interstellar"] = "Interstellar"
}

-- ==========================================
-- LAYANAN UTAMA
-- ==========================================
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local AutoBloodmoon = false
local AutoArtifact = false
local AutoKill = false

-- ==========================================
-- TAMPILAN MENU (UI)
-- ==========================================
Window:AddToggle("Auto Bloodmoon Spin", false, function(state)
    AutoBloodmoon = state
end)

Window:AddToggle("Auto Artifact Spin", false, function(state)
    AutoArtifact = state
end)

Window:AddToggle("Auto Kill (Aura + Damage)", false, function(state)
    AutoKill = state
end)

-- ==========================================
-- MESIN BELAKANG (LOOPING TUGAS)
-- ==========================================

-- 1. Mesin Bloodmoon Spin
task.spawn(function()
    while task.wait(0.1) do
        if AutoBloodmoon then
            pcall(function()
                ReplicatedStorage.Remotes.EventRemotes.BloodmoonRequestSpin:InvokeServer()
            end)
        end
    end
end)

-- 2. Mesin Artifact Spin
task.spawn(function()
    while task.wait(0.1) do
        if AutoArtifact then
            pcall(function()
                ReplicatedStorage.Remotes.ArtifactCrateRemotes.Spin:InvokeServer("Standard", 5)
            end)
        end
    end
end)

-- 3. Mesin Auto Kill (Wajib Pegang Senjata Terdaftar)
task.spawn(function()
    while task.wait(0.04) do
        if AutoKill then
            pcall(function()
                local zombiesFolder = Workspace:FindFirstChild("Zombies_Local")
                local character = LocalPlayer.Character
                
                if zombiesFolder and character and character:FindFirstChild("HumanoidRootPart") then
                    
                    -- [WAJIB]: Mengecek senjata apa yang sedang dipegang di tangan
                    local senjataAktif = character:FindFirstChildOfClass("Tool")
                    
                    -- Mengecek apakah senjata di tangan ada di dalam IndeksSenjata
                    if senjataAktif and IndeksSenjata[senjataAktif.Name] then
                        
                        -- Menerjemahkan nama senjata untuk server
                        local namaSenjataServer = IndeksSenjata[senjataAktif.Name]
                        local myPos = character.HumanoidRootPart.Position
                        
                        for _, zombie in pairs(zombiesFolder:GetChildren()) do
                            local targetPart = zombie:FindFirstChild("HumanoidRootPart")
                            
                            if targetPart then
                                local targetPos = targetPart.Position
                                local direction = (targetPos - myPos).Unit
                                
                                local ID_String = string.match(zombie.Name, "%d+")
                                
                                if ID_String then
                                    local ID_Angka = tonumber(ID_String)
                                    
                                    -- Eksekusi GunFire dan GunHit menggunakan nama senjata yang sah
                                    ReplicatedStorage.Remotes.NetRemotes.GunFire:FireServer(namaSenjataServer, targetPos, direction)
                                    ReplicatedStorage.Remotes.GunRemotes.GunHit:FireServer(namaSenjataServer, ID_Angka, targetPos)
                                end
                            end
                        end
                        
                    end
                    
                end
            end)
        end
    end
end)
