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
local AutoKill = true -- Diubah menjadi true agar langsung aktif

-- Menyimpan daftar senjata yang dicentang di MultiDropdown
-- Diubah menjadi true semua agar langsung terpilih
local SenjataTerpilih = {
    CosmicPistol = true,
    Quasar = true,
    Pulsar = true,
    Interstellar = true
}

-- ==========================================
-- TAMPILAN MENU (UI)
-- ==========================================

-- 1. MultiDropdown untuk memilih lebih dari 1 senjata
Window:AddMultiDropdown("Pilih Senjata", {"CosmicPistol", "Quasar", "Pulsar", "Interstellar"}, function(opsiTerpilih)
    SenjataTerpilih = opsiTerpilih
end)

Window:AddToggle("Auto Bloodmoon Spin", false, function(state)
    AutoBloodmoon = state
end)

Window:AddToggle("Auto Artifact Spin", false, function(state)
    AutoArtifact = state
end)

-- Default toggle diubah menjadi true
Window:AddToggle("Auto Kill (Aura + Damage)", true, function(state)
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

-- 3. Mesin Auto Kill (Multi-Senjata Sesuai Dropdown)
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
                            
                            local ID_String = string.match(zombie.Name, "%d+")
                            
                            if ID_String then
                                local ID_Angka = tonumber(ID_String)
                                
                                -- Menembakkan HANYA senjata yang kamu centang di MultiDropdown
                                for namaSenjata, statusCeklis in pairs(SenjataTerpilih) do
                                    if statusCeklis then
                                        -- Hanya menyisakan GunHit
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
