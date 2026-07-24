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
local AutoHipHeight = false

-- Menyimpan daftar senjata yang dicentang di MultiDropdown
local SenjataTerpilih = {
    CosmicPistol = false,
    Quasar = false,
    Pulsar = false,
    Interstellar = false
}

local TargetHipHeight = 30 -- Nilai default otomatis 30

-- ==========================================
-- TAMPILAN MENU (UI)
-- ==========================================

-- 1. MultiDropdown untuk memilih lebih dari 1 senjata
Window:AddMultiDropdown("Pilih Senjata", {"CosmicPistol", "Quasar", "Pulsar", "Interstellar"}, function(opsiTerpilih)
    SenjataTerpilih = opsiTerpilih
end)

-- 2. Toggle Hip Height + Input untuk mengatur tinggi (maksimal 60)
Window:AddToggle("Auto Hip Height", false, function(state)
    AutoHipHeight = state
end)

Window:AddInput("Atur Tinggi (Max 60)", "Default: 30", function(text)
    local angka = tonumber(text)
    if angka then
        -- Membatasi agar tidak lebih dari 60 dan tidak kurang dari 0
        if angka > 60 then
            TargetHipHeight = 60
        else
            TargetHipHeight = angka
        end
    end
end)

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

-- 3. Mesin Auto Hip Height (Mengatur posisi terbang/melayang karakter)
task.spawn(function()
    while task.wait(0.1) do
        if AutoHipHeight then
            pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChildOfClass("Humanoid") then
                    character.Humanoid.HipHeight = TargetHipHeight
                end
            end)
        else
            pcall(function()
                -- Mengembalikan ke normal (0) jika toggle dimatikan
                local character = LocalPlayer.Character
                if character and character:FindFirstChildOfClass("Humanoid") then
                    character.Humanoid.HipHeight = 0
                end
            end)
        end
    end
end)

-- 4. Mesin Auto Kill (Multi-Senjata Sesuai Dropdown)
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
                            
                            local ID_String = string.match(zombie.Name, "%d+")
                            
                            if ID_String then
                                local ID_Angka = tonumber(ID_String)
                                
                                -- Menembakkan HANYA senjata yang kamu centang di MultiDropdown
                                for namaSenjata, statusCeklis in pairs(SenjataTerpilih) do
                                    if statusCeklis then
                                        ReplicatedStorage.Remotes.NetRemotes.GunFire:FireServer(namaSenjata, targetPos, direction)
                                        ReplicatedStorage.Remotes.GunRemotes.GunHit:FireServer(namaSenjata, ID_Angka, targetPos)
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
