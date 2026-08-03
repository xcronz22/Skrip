local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Window = Library:MakeWindow("SZA Script Pro")

-- ==========================================
-- LAYANAN UTAMA & VARIABEL
-- ==========================================
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- Nama File Konfigurasi
local ConfigFile = "SZA_Config.json"

-- Variabel Default (Auto Kill langsung AKTIF sesuai permintaan)
local AutoSilentAim = true
local AutoAuraKill = true
local AutoBloodmoon = false
local AutoArtifact = false
local AutoHealth = false
local AutoHipHeight = false
local AutoNoFog = false
local AutoAntiLag = false

local MaxJarakSilentAim = 100 
local MaxJarakAuraKill = 100
local TargetHipHeight = 30 
local KecepatanRemote = 0.04 

-- Indeks Semua Senjata (Sudah terpilih langsung untuk Silent Aim)
local SemuaSenjata = {
    "BloodPistol", "CosmicPistol", "Revolver", "DualPistols", "RicochetRevolver", "Deagle", "USP-S", "Redline",
    "BloodSMG", "Shotgun", "SMG", "Quasar", "CombatShotgun", "HoneyBadger", "P90", "ArcWelder", "Slingshot", "MP5",
    "BloodAR", "Rifle", "BurstRifle", "AK-47", "Pulsar", "TommyGun", "Sniper", "HeavyRifle", "Scar-H", "ImpalerRifle",
    "Bloodblaster", "Minigun", "Flamethrower", "GrenadeLauncher", "VoidScythe", "BloodStaff", "GumdropBlaster", 
    "ArcticStriker", "AcidSpitter", "HydraCannon", "Interstellar", "WorldEnder", "StarShooter", "SantitosGoldenAK-47"
}

-- Menyimpan Handler UI untuk fungsi Load Config
local UI = {}

-- ==========================================
-- TAMPILAN MENU (UI)
-- ==========================================

UI.KecepatanRemote = Window:AddInput("Kecepatan Remote (Detik)", "Default: 0.04", function(text)
    local angka = tonumber(text)
    if angka then KecepatanRemote = angka end
end)

UI.SilentAim = Window:AddToggle("Auto Silent Aim (All Guns)", true, function(state)
    AutoSilentAim = state
end)

UI.JarakSilentAim = Window:AddInput("Jarak Silent Aim", "Default: 100", function(text)
    local angka = tonumber(text)
    if angka then MaxJarakSilentAim = angka end
end)

UI.AuraKill = Window:AddToggle("Auto Kill Aura (Damage)", true, function(state)
    AutoAuraKill = state
end)

UI.JarakAuraKill = Window:AddInput("Jarak Kill Aura", "Default: 100", function(text)
    local angka = tonumber(text)
    if angka then MaxJarakAuraKill = angka end
end)

UI.HipHeight = Window:AddToggle("Auto Hip Height", false, function(state)
    AutoHipHeight = state
end)

UI.TinggiHipHeight = Window:AddInput("Atur Tinggi (Max 60)", "Default: 30", function(text)
    local angka = tonumber(text)
    if angka then
        TargetHipHeight = (angka > 60) and 60 or angka
    end
end)

UI.NoFog = Window:AddToggle("No Fog (Hapus Kabut)", false, function(state)
    AutoNoFog = state
end)

UI.AntiLag = Window:AddToggle("Anti Lag (Mode Kentang)", false, function(state)
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
                -- Jeda agar game tidak crash/lag saat mengubah map
                if i % 50 == 0 then task.wait() end 
            end
        end)
    end
end)

UI.Bloodmoon = Window:AddToggle("Auto Bloodmoon Spin", false, function(state)
    AutoBloodmoon = state
end)

UI.Artifact = Window:AddToggle("Auto Artifact Spin", false, function(state)
    AutoArtifact = state
end)

UI.Health = Window:AddToggle("Auto Health Upgrade", false, function(state)
    AutoHealth = state
end)

Window:AddButton("Simpan Config", function()
    local configData = {
        C_KecepatanRemote = KecepatanRemote,
        C_AutoSilentAim = AutoSilentAim,
        C_MaxJarakSilentAim = MaxJarakSilentAim,
        C_AutoAuraKill = AutoAuraKill,
        C_MaxJarakAuraKill = MaxJarakAuraKill,
        C_AutoHipHeight = AutoHipHeight,
        C_TargetHipHeight = TargetHipHeight,
        C_AutoNoFog = AutoNoFog,
        C_AutoAntiLag = AutoAntiLag,
        C_AutoBloodmoon = AutoBloodmoon,
        C_AutoArtifact = AutoArtifact,
        C_AutoHealth = AutoHealth
    }
    pcall(function()
        writefile(ConfigFile, HttpService:JSONEncode(configData))
    end)
end)

Window:AddButton("Muat Config", function()
    pcall(function()
        if isfile(ConfigFile) then
            local data = HttpService:JSONDecode(readfile(ConfigFile))
            
            if data.C_KecepatanRemote ~= nil then KecepatanRemote = data.C_KecepatanRemote end
            if data.C_AutoSilentAim ~= nil then AutoSilentAim = data.C_AutoSilentAim end
            if data.C_MaxJarakSilentAim ~= nil then MaxJarakSilentAim = data.C_MaxJarakSilentAim end
            if data.C_AutoAuraKill ~= nil then AutoAuraKill = data.C_AutoAuraKill end
            if data.C_MaxJarakAuraKill ~= nil then MaxJarakAuraKill = data.C_MaxJarakAuraKill end
            if data.C_AutoHipHeight ~= nil then AutoHipHeight = data.C_AutoHipHeight end
            if data.C_TargetHipHeight ~= nil then TargetHipHeight = data.C_TargetHipHeight end
            if data.C_AutoNoFog ~= nil then AutoNoFog = data.C_AutoNoFog end
            if data.C_AutoAntiLag ~= nil then AutoAntiLag = data.C_AutoAntiLag end
            if data.C_AutoBloodmoon ~= nil then AutoBloodmoon = data.C_AutoBloodmoon end
            if data.C_AutoArtifact ~= nil then AutoArtifact = data.C_AutoArtifact end
            if data.C_AutoHealth ~= nil then AutoHealth = data.C_AutoHealth end
        end
    end)
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

-- 3. Mesin Auto Silent Aim (GunFire + GunHit Semua Senjata)
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
                                    
                                    -- Menembakkan seluruh 40+ senjata secara bersamaan ke target
                                    for _, namaSenjata in ipairs(SemuaSenjata) do
                                        ReplicatedStorage.Remotes.NetRemotes.GunFire:FireServer(namaSenjata, myPos, arahTembakan)
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
