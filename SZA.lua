local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Window = Library:MakeWindow("SZA All-in-One")

-- ==========================================
-- PENGATURAN SENJATA (ISI MANUAL DI SINI)
-- ==========================================
-- Ubah teks di dalam tanda kutip di bawah ini sesuai dengan nama senjatamu
local NamaSenjata = "CosmicPistol" 

-- ==========================================
-- LAYANAN & REMOTE
-- ==========================================
local BloodmoonEvent = game:GetService("ReplicatedStorage").Remotes.EventRemotes.BloodmoonRequestSpin
local ArtifactEvent = game:GetService("ReplicatedStorage").Remotes.ArtifactCrateRemotes.Spin
local GunEvent = game:GetService("ReplicatedStorage").Remotes.NetRemotes.GunFire

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
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

Window:AddToggle("Auto Kill (Aura)", false, function(state)
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
                BloodmoonEvent:InvokeServer()
            end)
        end
    end
end)

-- 2. Mesin Artifact Spin (0.1 Detik)
task.spawn(function()
    while task.wait(0.1) do
        if AutoArtifact then
            pcall(function()
                ArtifactEvent:InvokeServer("Standard", 5)
            end)
        end
    end
end)

-- 3. Mesin Auto Kill Zombies (0.04 Detik)
task.spawn(function()
    while task.wait(0.04) do
        if AutoKill then
            pcall(function()
                local zombiesFolder = Workspace:FindFirstChild("Zombies_Local")
                local character = LocalPlayer.Character
                
                -- Mengecek keberadaan folder zombie dan karakter pemain
                if zombiesFolder and character and character:FindFirstChild("HumanoidRootPart") then
                    local myPos = character.HumanoidRootPart.Position
                    
                    -- Menyerang semua zombie di dalam folder
                    for _, zombie in pairs(zombiesFolder:GetChildren()) do
                        local targetPart = zombie:FindFirstChild("HumanoidRootPart")
                        
                        if targetPart then
                            local targetPos = targetPart.Position
                            local direction = (targetPos - myPos).Unit
                            
                            -- Mengeksekusi tembakan menggunakan variabel NamaSenjata
                            GunEvent:FireServer(NamaSenjata, targetPos, direction)
                        end
                    end
                end
            end)
        end
    end
end)
