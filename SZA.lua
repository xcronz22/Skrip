local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Window = Library:MakeWindow("SZA Script Pro")

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

-- Senjata mutlak yang dideteksi server
local SenjataUtama = "CosmicPistol"

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

-- 1. Mesin Bloodmoon Spin (0.1 Detik)
task.spawn(function()
    while task.wait(0.1) do
        if AutoBloodmoon then
            pcall(function()
                ReplicatedStorage.Remotes.EventRemotes.BloodmoonRequestSpin:InvokeServer()
            end)
        end
    end
end)

-- 2. Mesin Artifact Spin (0.1 Detik)
task.spawn(function()
    while task.wait(0.1) do
        if AutoArtifact then
            pcall(function()
                ReplicatedStorage.Remotes.ArtifactCrateRemotes.Spin:InvokeServer("Standard", 5)
            end)
        end
    end
end)

-- 3. Mesin Auto Kill (Fix Damage GunHit)
task.spawn(function()
    while task.wait(0.04) do
        if AutoKill then
            pcall(function()
                local zombiesFolder = Workspace:FindFirstChild("Zombies_Local")
                local character = LocalPlayer.Character
                
                if zombiesFolder and character and character:FindFirstChild("HumanoidRootPart") then
                    
                    local myPos = character.HumanoidRootPart.Position
                    
                    for _, zombie in pairs(zombiesFolder:GetChildren()) do
                        local targetPart = zombie:FindFirstChild("HumanoidRootPart")
                        
                        if targetPart then
                            local targetPos = targetPart.Position
                            local direction = (targetPos - myPos).Unit
                            
                            -- [BARU] Mengekstrak angka ID dari nama Zombie (misal: "Zombie_22" menjadi angka 22)
                            local ID_String = string.match(zombie.Name, "%d+")
                            
                            if ID_String then
                                local ID_Angka = tonumber(ID_String)
                                
                                -- 1. Mengirim efek tembakan (GunFire)
                                ReplicatedStorage.Remotes.NetRemotes.GunFire:FireServer(SenjataUtama, targetPos, direction)
                                
                                -- 2. Mengirim DAMAGE mematikan ke server (GunHit)
                                -- Path ini sesuai dengan video Cobalt kamu di detik 0:29
                                ReplicatedStorage.Remotes.GunRemotes.GunHit:FireServer(SenjataUtama, ID_Angka, targetPos)
                            end
                        end
                    end
                    
                end
            end)
        end
    end
end)
