local queue_on_teleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
if queue_on_teleport then
    -- Fitur ini berjalan otomatis di latar belakang untuk mengeksekusi ulang saat ganti map/rejoin
    queue_on_teleport([[
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/SZA.lua"))()
    ]])
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Window = Library:MakeWindow("SZA Script Pro")

-- ==========================================
-- LAYANAN UTAMA & VARIABEL
-- ==========================================
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- Pengaturan Bawaan (Default)
local AutoSilentAim = false
local AutoAuraKill = true
local AutoBloodmoon = false
local AutoArtifact = false
local AutoHealth = false
local AutoHipHeight = false
local AutoNoFog = true
local AutoAntiLag = true

local MaxJarakSilentAim = 100 
local MaxJarakAuraKill = 100
local TargetHipHeight = 30 
local KecepatanRemote = 0.1 

-- Daftar Semua Senjata
local SemuaSenjata = {
    "BloodPistol", "CosmicPistol", "Revolver", "DualPistols", "RicochetRevolver", "Deagle", "USP-S", "Redline",
    "BloodSMG", "Shotgun", "SMG", "Quasar", "CombatShotgun", "HoneyBadger", "P90", "ArcWelder", "Slingshot", "MP5",
    "BloodAR", "Rifle", "BurstRifle", "AK-47", "Pulsar", "TommyGun", "Sniper", "HeavyRifle", "Scar-H", "ImpalerRifle",
    "Bloodblaster", "Minigun", "Flamethrower", "GrenadeLauncher", "VoidScythe", "BloodStaff", "GumdropBlaster", 
    "ArcticStriker", "AcidSpitter", "HydraCannon", "Interstellar", "WorldEnder", "StarShooter", "SantitosGoldenAK-47"
}

-- Menyimpan senjata yang dipilih dari dropdown
local SenjataTerpilih = {}

-- ==========================================
-- TAMPILAN MENU (UI)
-- ==========================================

Window:AddInput("Kecepatan Remote (Detik)", "Default: 0.1", function(text)
    local angka = tonumber(text)
    if angka then KecepatanRemote = angka end
end)

Window:AddMultiDropdown("Pilih Senjata (Bisa Lebih Dari 1)", SemuaSenjata, function(opsiTerpilih)
    SenjataTerpilih = opsiTerpilih
end)

Window:AddToggle("Auto Silent Aim", false, function(state)
    AutoSilentAim = state
end)

Window:AddInput("Jarak Silent Aim", "Default: 100", function(text)
    local angka = tonumber(text)
    if angka then MaxJarakSilentAim = angka end
end)

Window:AddToggle("Auto Kill Aura (Damage)", true, function(state)
    AutoAuraKill = state
end)

Window:AddInput("Jarak Kill Aura", "Default: 100", function(text)
    local angka = tonumber(text)
    if angka then MaxJarakAuraKill = angka end
end)

Window:AddToggle("Auto Hip Height", false, function(state)
    AutoHipHeight = state
end)

Window:AddInput("Atur Tinggi (Max 60)", "Default: 30", function(text)
    local angka = tonumber(text)
    if angka then TargetHipHeight = (angka > 60) and 60 or angka end
end)

Window:AddToggle("No Fog (Hapus Kabut)", true, function(state)
    AutoNoFog = state
end)

Window:AddToggle("Anti Lag (Mode Kentang)", true, function(state)
    AutoAntiLag = state
    if state then
        task.spawn(function()
            for i, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                end
                -- Jeda agar game tidak freeze
                if i % 50 == 0 then task.wait() end 
            end
        end)
    end
end)

Window:AddToggle("Auto Bloodmoon Spin", false, function(state)
    AutoBloodmoon = state
end)

Window:AddToggle("Auto Artifact Spin", false, function(state)
    AutoArtifact = state
end)

Window:AddToggle("Auto Health Upgrade", false, function(state)
    AutoHealth = state
end)

-- ==========================================
-- MESIN BELAKANG (LOOPING TUGAS)
-- ==========================================

-- 1. Mesin Auto Upgrade & Spin
task.spawn(function()
    while task.wait(0.1) do
        if AutoBloodmoon then
            pcall(function() ReplicatedStorage.Remotes.EventRemotes.BloodmoonRequestSpin:InvokeServer() end)
        end
        if AutoArtifact then
            pcall(function() ReplicatedStorage.Remotes.ArtifactCrateRemotes.Spin:InvokeServer("Standard", 5) end)
        end
        if AutoHealth then
            pcall(function() ReplicatedStorage.Remotes.UpgradeRemotes.PurchaseHealthUpgrade:FireServer() end)
        end
    end
end)

-- 2. Mesin Auto Hip Height
task.spawn(function()
    while task.wait(0.1) do
        local character = LocalPlayer.Character
        if character and character:FindFirstChildOfClass("Humanoid") then
            if AutoHipHeight then
                character.Humanoid.HipHeight = TargetHipHeight
            else
                if character.Humanoid.HipHeight ~= 0 then
                    character.Humanoid.HipHeight = 0
                end
            end
        end
    end
end)

-- 3. Mesin Auto Silent Aim (Menembakkan semua senjata yang dipilih)
task.spawn(function()
    while true do
        task.wait(KecepatanRemote)
        if AutoSilentAim then
            pcall(function()
                local zombiesFolder = Workspace:FindFirstChild("Zombies_Local") or Workspace:FindFirstChild("Zombies")
                local character = LocalPlayer.Character
                
                if zombiesFolder and character and character:FindFirstChild("HumanoidRootPart") then
                    local myPos = character.HumanoidRootPart.Position
                    
                    for _, zombie in pairs(zombiesFolder:GetChildren()) do
                        local targetPart = zombie:FindFirstChild("HumanoidRootPart")
                        if targetPart then
                            local targetPos = targetPart.Position
                            local jarakZombi = (targetPos - myPos).Magnitude
                            
                            if jarakZombi <= MaxJarakSilentAim then
                                local ID_String = string.match(zombie.Name, "%d+")
                                if ID_String then
                                    local ID_Angka = tonumber(ID_String)
                                    local arahTembakan = (targetPos - myPos).Unit
                                    
                                    -- Looping untuk menembakkan setiap senjata yang diceklis
                                    for k, v in pairs(SenjataTerpilih) do
                                        -- Mengakomodasi jika library UI me-return array (opsi) atau dictionary (status)
                                        local namaSenjata = type(k) == "number" and v or k
                                        local statusCeklis = type(k) == "number" and true or v
                                        
                                        if statusCeklis then
                                            ReplicatedStorage.Remotes.NetRemotes.GunFire:FireServer(namaSenjata, myPos, arahTembakan)
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

-- 4. Mesin Auto Kill Aura (ZombieDamage)
task.spawn(function()
    while true do
        task.wait(KecepatanRemote)
        if AutoAuraKill then
            pcall(function()
                local zombiesFolder = Workspace:FindFirstChild("Zombies_Local") or Workspace:FindFirstChild("Zombies")
                local character = LocalPlayer.Character
                
                if zombiesFolder and character and character:FindFirstChild("HumanoidRootPart") then
                    local myPos = character.HumanoidRootPart.Position
                    
                    for _, zombie in pairs(zombiesFolder:GetChildren()) do
                        local targetPart = zombie:FindFirstChild("HumanoidRootPart")
                        if targetPart then
                            local targetPos = targetPart.Position
                            local jarakZombi = (targetPos - myPos).Magnitude
                            
                            if jarakZombi <= MaxJarakAuraKill then
                                local ID_String = string.match(zombie.Name, "%d+")
                                if ID_String then
                                    local ID_Angka = tonumber(ID_String)
                                    ReplicatedStorage.Remotes.ZombieRemotes.ZombieDamage:FireServer(ID_Angka, math.huge)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 5. Mesin NoFog & AntiLag (Loop Ringan Berkala)
task.spawn(function()
    while task.wait(3) do
        if AutoNoFog then
            pcall(function()
                Lighting.FogEnd = 9e9
                Lighting.FogStart = 9e9
            end)
        end
        
        if AutoAntiLag then
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                Lighting.GlobalShadows = false
                
                if sethiddenproperty then
                    sethiddenproperty(Lighting, "Technology", 2)
                end
            end)
        end
    end
end)
