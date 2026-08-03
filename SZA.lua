local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Window = Library:MakeWindow("SZA Script Pro")

-- ==========================================
-- LAYANAN UTAMA & VARIABEL
-- ==========================================
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Nama File Konfigurasi
local ConfigFile = "SZA_Config.json"

local AutoBloodmoon = false
local AutoArtifact = false
local AutoHealth = false
local AutoHipHeight = false
local AutoSilentAim = false
local AutoAuraKill = false
local AutoNoFog = false
local AutoAntiLag = false

-- Variabel dengan nilai default baru
local MaxJarakSilentAim = 100 
local MaxJarakAuraKill = 100
local TargetHipHeight = 30 
local KecepatanRemote = 0.04 -- Kecepatan looping remote baru

-- Indeks Semua Senjata dari Video (Slot 1 sampai Slot 4)
local SemuaSenjata = {
    -- Pistols (Slot 1)
    "BloodPistol", "CosmicPistol", "Revolver", "DualPistols", "RicochetRevolver", "Deagle", "USP-S", "Redline",
    -- SMGs & Shotguns (Slot 2)
    "BloodSMG", "Shotgun", "SMG", "Quasar", "CombatShotgun", "HoneyBadger", "P90", "ArcWelder", "Slingshot", "MP5",
    -- Assault Rifles & Snipers (Slot 3)
    "BloodAR", "Rifle", "BurstRifle", "AK-47", "Pulsar", "TommyGun", "Sniper", "HeavyRifle", "Scar-H", "ImpalerRifle",
    -- Heavies & Specials/Mythics (Slot 4)
    "Bloodblaster", "Minigun", "Flamethrower", "GrenadeLauncher", "VoidScythe", "BloodStaff", "GumdropBlaster", 
    "ArcticStriker", "AcidSpitter", "HydraCannon", "Interstellar", "WorldEnder", "StarShooter", "SantitosGoldenAK-47"
}

-- Menyimpan Handler UI untuk fungsi Load Config
local UI = {}

-- ==========================================
-- TAMPILAN MENU (UI)
-- ==========================================

Window:AddLabel("--- Fitur Serangan ---")

-- 1. Pengaturan Kecepatan Remote
UI.KecepatanRemote = Window:AddInput("Kecepatan Remote (Detik)", "Default: 0.04", function(text)
    local angka = tonumber(text)
    KecepatanRemote = angka or 0.04
end)

-- 2. Auto Silent Aim
UI.SilentAim = Window:AddToggle("Auto Silent Aim", false, function(state)
    AutoSilentAim = state
end)
UI.JarakSilentAim = Window:AddInput("Jarak Silent Aim", "Default: 100", function(text)
    local angka = tonumber(text)
    MaxJarakSilentAim = angka or 100 
end)

-- 3. Auto Kill Aura
UI.AuraKill = Window:AddToggle("Auto Kill Aura", false, function(state)
    AutoAuraKill = state
end)
UI.JarakAuraKill = Window:AddInput("Jarak Kill Aura", "Default: 100", function(text)
    local angka = tonumber(text)
    MaxJarakAuraKill = angka or 100 
end)

Window:AddLabel("--- Pengaturan Karakter ---")

-- 4. Hip Height
UI.HipHeight = Window:AddToggle("Auto Hip Height", false, function(state)
    AutoHipHeight = state
end)
UI.TinggiHipHeight = Window:AddInput("Atur Tinggi (Max 60)", "Default: 30", function(text)
    local angka = tonumber(text)
    if angka then
        TargetHipHeight = (angka > 60) and 60 or angka
    end
end)

Window:AddLabel("--- Visual & Performa ---")

-- 5. No Fog & Anti Lag
UI.NoFog = Window:AddToggle("No Fog (Hapus Kabut)", false, function(state)
    AutoNoFog = state
end)
UI.AntiLag = Window:AddToggle("Anti Lag (Mode Kentang)", false, function(state)
    AutoAntiLag = state
    if state then
        -- Menghapus material berat di seluruh map secara bertahap agar TIDAK LAG (Frame drop)
        task.spawn(function()
            for i, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                end
                -- Beri jeda sepersekian milidetik setiap 50 objek agar tidak nge-freeze
                if i % 50 == 0 then task.wait() end 
            end
        end)
    end
end)

Window:AddLabel("--- Fitur Auto Lainnya ---")

-- 6. Upgrade & Spin
UI.Bloodmoon = Window:AddToggle("Auto Bloodmoon Spin", false, function(state)
    AutoBloodmoon = state
end)
UI.Artifact = Window:AddToggle("Auto Artifact Spin", false, function(state)
    AutoArtifact = state
end)
UI.Health = Window:AddToggle("Auto Health Upgrade", false, function(state)
    AutoHealth = state
end)

Window:AddLabel("--- Save / Load Config ---")

-- 7. Config System
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
            
            -- Memperbarui Variabel Internal & Memperbarui Tampilan UI
            if data.C_KecepatanRemote ~= nil then KecepatanRemote = data.C_KecepatanRemote UI.KecepatanRemote:Set(tostring(KecepatanRemote)) end
            
            if data.C_AutoSilentAim ~= nil then AutoSilentAim = data.C_AutoSilentAim UI.SilentAim:Set(AutoSilentAim) end
            if data.C_MaxJarakSilentAim ~= nil then MaxJarakSilentAim = data.C_MaxJarakSilentAim UI.JarakSilentAim:Set(tostring(MaxJarakSilentAim)) end
            
            if data.C_AutoAuraKill ~= nil then AutoAuraKill = data.C_AutoAuraKill UI.AuraKill:Set(AutoAuraKill) end
            if data.C_MaxJarakAuraKill ~= nil then MaxJarakAuraKill = data.C_MaxJarakAuraKill UI.JarakAuraKill:Set(tostring(MaxJarakAuraKill)) end
            
            if data.C_AutoHipHeight ~= nil then AutoHipHeight = data.C_AutoHipHeight UI.HipHeight:Set(AutoHipHeight) end
            if data.C_TargetHipHeight ~= nil then TargetHipHeight = data.C_TargetHipHeight UI.TinggiHipHeight:Set(tostring(TargetHipHeight)) end
            
            if data.C_AutoNoFog ~= nil then AutoNoFog = data.C_AutoNoFog UI.NoFog:Set(AutoNoFog) end
            if data.C_AutoAntiLag ~= nil then AutoAntiLag = data.C_AutoAntiLag UI.AntiLag:Set(AutoAntiLag) end
            
            if data.C_AutoBloodmoon ~= nil then AutoBloodmoon = data.C_AutoBloodmoon UI.Bloodmoon:Set(AutoBloodmoon) end
            if data.C_AutoArtifact ~= nil then AutoArtifact = data.C_AutoArtifact UI.Artifact:Set(AutoArtifact) end
            if data.C_AutoHealth ~= nil then AutoHealth = data.C_AutoHealth UI.Health:Set(AutoHealth) end
        end
    end)
end)

-- ==========================================
-- MESIN BELAKANG (LOOPING TUGAS)
-- ==========================================

-- 1. Mesin Bloodmoon, Spin & Health
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

-- 3. Mesin Auto Silent Aim (Menggunakan KecepatanRemote)
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

-- 4. Mesin Auto Kill Aura (Menggunakan KecepatanRemote)
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

-- 5. Mesin NoFog & AntiLag (Loop Ringan)
task.spawn(function()
    while task.wait(3) do
        local lighting = game:GetService("Lighting")
        
        if AutoNoFog then
            pcall(function()
                lighting.FogEnd = 9e9
                lighting.FogStart = 9e9
            end)
        end
        
        if AutoAntiLag then
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                lighting.GlobalShadows = false
                
                if sethiddenproperty then
                    sethiddenproperty(lighting, "Technology", 2)
                end
            end)
        end
    end
end)
