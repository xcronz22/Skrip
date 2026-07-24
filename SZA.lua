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

-- Variabel Jarak Maksimal (Default: math.huge / tak terhingga)
local MaxJarak = math.huge 

-- Menyimpan daftar senjata yang dicentang di MultiDropdown
local SenjataTerpilih = {
    CosmicPistol = false,
    Quasar = false,
    Pulsar = false,
    Interstellar = false,
    Star Shooter = false
}

-- ==========================================
-- TAMPILAN MENU (UI)
-- ==========================================

-- 1. MultiDropdown untuk memilih lebih dari 1 senjata
Window:AddMultiDropdown("Pilih Senjata", {"CosmicPistol", "Quasar", "Pulsar", "Interstellar", "Star Shooter"}, function(opsiTerpilih)
    SenjataTerpilih = opsiTerpilih
end)

-- 2. Input untuk Jarak Auto Kill
Window:AddInput("Jarak Auto Kill (Angka)", "Default: Semua", function(text)
    local angka = tonumber(text)
    if angka then
        MaxJarak = angka -- Mengubah jarak sesuai input (misal: 20)
    else
        MaxJarak = math.huge -- Jika dikosongkan/huruf, kembali ke jarak tak terbatas
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

-- 3. Mesin Auto Kill (Dengan Batas Jarak)
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
                            
                            -- [FITUR BARU] Menghitung jarak antara kita dan zombie
                            local jarakZombi = (targetPos - myPos).Magnitude
                            
                            -- Mengecek apakah jarak zombie masuk ke dalam radius yang diatur
                            if jarakZombi <= MaxJarak then
                                local ID_String = string.match(zombie.Name, "%d+")
                                
                                if ID_String then
                                    local ID_Angka = tonumber(ID_String)
                                    
                                    -- Menembakkan HANYA senjata yang kamu centang di MultiDropdown
                                    for namaSenjata, statusCeklis in pairs(SenjataTerpilih) do
                                        if statusCeklis then
                                            ReplicatedStorage.Remotes.GunRemotes.GunHit:FireServer(namaSenjata, ID_Angka, targetPos)
                                        end
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
