local queue_on_teleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
if queue_on_teleport then
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
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Pengaturan Bawaan (Default)
local AutoSilentAim = true
local AutoAuraKill = false
local AutoKillAll = false
local AutoBloodmoon = false
local AutoArtifact = false
local AutoHealth = false
local AutoHipHeight = false
local AutoNoFog = true
local AutoAntiLag = true

local MaxJarakSilentAim = 100 
local MaxFOVSilentAim = 50
local MaxJarakAuraKill = 100
local TargetHipHeight = 30 
local KecepatanRemote = 0.1 

-- Daftar Semua Senjata
local SemuaSenjata = {
    "Pistol", "BloodPistol", "CosmicPistol", "Revolver", "DualPistols", "RicochetRevolver", "Deagle", "USP-S", "Redline",
    "BloodSMG", "Shotgun", "SMG", "Quasar", "CombatShotgun", "HoneyBadger", "P90", "ArcWelder", "Slingshot", "MP5",
    "BloodAR", "Rifle", "BurstRifle", "AK-47", "Pulsar", "TommyGun", "Sniper", "HeavyRifle", "Scar-H", "ImpalerRifle",
    "Bloodblaster", "Minigun", "Flamethrower", "GrenadeLauncher", "VoidScythe", "BloodStaff", "GumdropBlaster", 
    "ArcticStriker", "AcidSpitter", "HydraCannon", "Interstellar", "WorldEnder", "StarShooter", "SantitosGoldenAK-47"
}

local SenjataValid = {}
for _, nama in ipairs(SemuaSenjata) do
    SenjataValid[nama] = true
end

-- ==========================================
-- TAMPILAN MENU (UI)
-- ==========================================

Window:AddInput("Kecepatan Remote (Detik)", "Default: 0.1", function(text)
    local angka = tonumber(text)
    if angka then KecepatanRemote = angka end
end)

Window:AddToggle("Auto Silent Aim (Legit/Crosshair)", true, function(state)
    AutoSilentAim = state
end)

Window:AddInput("Jarak Maksimal Silent Aim", "Default: 200", function(text)
    local angka = tonumber(text)
    if angka then MaxJarakSilentAim = angka end
end)

Window:AddInput("Radius FOV Crosshair (Pixel)", "Default: 150", function(text)
    local angka = tonumber(text)
    if angka then MaxFOVSilentAim = angka end
end)

Window:AddToggle("Auto Kill Aura (Terdekat)", false, function(state)
    AutoAuraKill = state
end)

Window:AddInput("Jarak Kill Aura", "Default: 100", function(text)
    local angka = tonumber(text)
    if angka then MaxJarakAuraKill = angka end
end)

Window:AddToggle("Auto Kill All (Tembak 1 Map)", false, function(state)
    AutoKillAll = state
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

-- 3. Mesin Auto Silent Aim (LEGIT: Hanya di layar & dekat crosshair)
task.spawn(function()
    while true do
        task.wait(KecepatanRemote)
        if AutoSilentAim then
            pcall(function()
                local character = LocalPlayer.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                local senjataPegang = character:FindFirstChildOfClass("Tool")
                
                if senjataPegang and SenjataValid[senjataPegang.Name] then
                    local namaSenjata = senjataPegang.Name
                    local myPos = character.HumanoidRootPart.Position
                    local zombiesFolder = Workspace:FindFirstChild("Zombies_Local") or Workspace:FindFirstChild("Zombies")
                    
                    if zombiesFolder then
                        local viewportSize = Camera.ViewportSize
                        local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
                        
                        for _, zombie in pairs(zombiesFolder:GetChildren()) do
                            local targetPart = zombie:FindFirstChild("HumanoidRootPart")
                            if targetPart then
                                local targetPos = targetPart.Position
                                local jarakZombi = (targetPos - myPos).Magnitude
                                
                                if jarakZombi <= MaxJarakSilentAim then
                                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
                                    
                                    if onScreen then
                                        local distanceToCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                                        
                                        if distanceToCenter <= MaxFOVSilentAim then
                                            local ID_String = string.match(zombie.Name, "%d+")
                                            if ID_String then
                                                local ID_Angka = tonumber(ID_String)
                                                local arahTembakan = (targetPos - myPos).Unit
                                                
                                                ReplicatedStorage.Remotes.NetRemotes.GunFire:FireServer(namaSenjata, myPos, arahTembakan)
                                                ReplicatedStorage.Remotes.GunRemotes.GunHit:FireServer(namaSenjata, ID_Angka, targetPos)
                                            end
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

-- 4. Mesin Auto Kill Aura (Terbatas Jarak)
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

-- 5. Mesin Auto Kill All (Perpaduan Tembak & Zombie Damage 1 Map)
task.spawn(function()
    while true do
        task.wait(KecepatanRemote)
        if AutoKillAll then
            pcall(function()
                local character = LocalPlayer.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                local senjataPegang = character:FindFirstChildOfClass("Tool")
                
                if senjataPegang and SenjataValid[senjataPegang.Name] then
                    local namaSenjata = senjataPegang.Name
                    local myPos = character.HumanoidRootPart.Position
                    local zombiesFolder = Workspace:FindFirstChild("Zombies_Local") or Workspace:FindFirstChild("Zombies")
                    
                    if zombiesFolder then
                        for _, zombie in pairs(zombiesFolder:GetChildren()) do
                            local targetPart = zombie:FindFirstChild("HumanoidRootPart")
                            if targetPart then
                                local targetPos = targetPart.Position
                                local ID_String = string.match(zombie.Name, "%d+")
                                
                                if ID_String then
                                    local ID_Angka = tonumber(ID_String)
                                    local arahTembakan = (targetPos - myPos).Unit
                                    
                                    -- Eksekusi perpaduan ketiga remote
                                    ReplicatedStorage.Remotes.NetRemotes.GunFire:FireServer(namaSenjata, myPos, arahTembakan)
                                    ReplicatedStorage.Remotes.GunRemotes.GunHit:FireServer(namaSenjata, ID_Angka, targetPos)
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

-- 6. Mesin NoFog & AntiLag
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
