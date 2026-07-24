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
local AutoHealth = false
local AutoKill = false
local AutoHipHeight = false

local MaxJarak = math.huge 
local TargetHipHeight = 30 

-- Menyimpan daftar senjata
local SenjataTerpilih = {
    ["CosmicPistol"] = false,
    ["Quasar"] = false,
    ["Pulsar"] = false,
    ["Interstellar"] = false,
    ["StarShooter"] = false -- [DIPERBARUI] Tanpa spasi
}

-- ==========================================
-- TAMPILAN MENU (UI)
-- ==========================================

-- 1. MultiDropdown Senjata
Window:AddMultiDropdown("Pilih Senjata", {"CosmicPistol", "Quasar", "Pulsar", "Interstellar", "StarShooter"}, function(opsiTerpilih)
    SenjataTerpilih = opsiTerpilih
end)

-- 2. Input Jarak
Window:AddInput("Jarak Auto Kill (Angka)", "Default: Semua", function(text)
    local angka = tonumber(text)
    if angka then
        MaxJarak = angka 
    else
        MaxJarak = math.huge 
    end
end)

-- 3. Hip Height (Tinggi Melayang)
Window:AddToggle("Auto Hip Height", false, function(state)
    AutoHipHeight = state
end)

Window:AddInput("Atur Tinggi (Max 60)", "Default: 30", function(text)
    local angka = tonumber(text)
    if angka then
        if angka > 60 then
            TargetHipHeight = 60
        else
            TargetHipHeight = angka
        end
    end
end)

-- 4. Fitur Upgrade & Spin
Window:AddToggle("Auto Bloodmoon Spin", false, function(state)
    AutoBloodmoon = state
end)

Window:AddToggle("Auto Artifact Spin", false, function(state)
    AutoArtifact = state
end)

Window:AddToggle("Auto Health Upgrade", false, function(state)
    AutoHealth = state
end)

-- 5. Fitur Serangan
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

-- 3. Mesin Auto Health Upgrade (0.5 Detik)
task.spawn(function()
    while task.wait(0.5) do
        if AutoHealth then
            pcall(function()
                ReplicatedStorage.Remotes.UpgradeRemotes.PurchaseHealthUpgrade:FireServer()
            end)
        end
    end
end)

-- 4. Mesin Auto Hip Height
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
                local character = LocalPlayer.Character
                if character and character:FindFirstChildOfClass("Humanoid") then
                    if character.Humanoid.HipHeight ~= 0 then
                        character.Humanoid.HipHeight = 0
                    end
                end
            end)
        end
    end
end)

-- 5. Mesin Auto Kill (Dengan Batas Jarak)
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
                            
                            local jarakZombi = (targetPos - myPos).Magnitude
                            
                            if jarakZombi <= MaxJarak then
                                local ID_String = string.match(zombie.Name, "%d+")
                                
                                if ID_String then
                                    local ID_Angka = tonumber(ID_String)
                                    
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
