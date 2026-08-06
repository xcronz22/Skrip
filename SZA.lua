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
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- INDIKATOR FOV (GUI ROBLOX NATIVE)
-- ==========================================
local FOVGui = Instance.new("ScreenGui")
FOVGui.Name = "FOVCircleGUI"
FOVGui.IgnoreGuiInset = true -- Memastikan presisi di tengah layar
-- Menyembunyikan GUI ke CoreGui agar tidak terdeteksi game (jika ada), atau ke PlayerGui sebagai cadangan
local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
FOVGui.Parent = success and coreGui or LocalPlayer:WaitForChild("PlayerGui")

local FOVFrame = Instance.new("Frame")
FOVFrame.Parent = FOVGui
FOVFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FOVFrame.BackgroundTransparency = 1 -- Tengahnya bolong (transparan)
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5) -- Titik tumpu di tengah

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0) -- Membuatnya bulat sempurna
FOVCorner.Parent = FOVFrame

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.fromRGB(255, 255, 255) -- Warna Putih
FOVStroke.Thickness = 1.5
FOVStroke.Transparency = 0.3 -- Sedikit transparan agar tidak mengganggu mata
FOVStroke.Parent = FOVFrame

-- Pengaturan Bawaan (Default)
local AutoSilentAim = true
local AutoAuraKill = false
local AutoKillAll = false
local AutoAntiAFK = true
local AutoBloodmoon = false
local AutoArtifact = false
local AutoHealth = false
local AutoHipHeight = false
local AutoNoFog = true
local AutoAntiLag = false
local AntiLagConnection = nil
local AutoCollectBloodmoon = false
local DaftarIDShard = {} -- Menyimpan ID Shard yang belum diambil

local MaxJarakSilentAim = 1500 
local MaxFOVSilentAim = 150
local MaxJarakAuraKill = 50
local TargetHipHeight = 30 
local KecepatanRemote = 0.2 

-- Daftar Semua Senjata (Telah Diperbarui Sesuai Video)
local SemuaSenjata = {
    "AcidSpitter", "AK47", "ArcWelder", "ArcticStriker", "BloodAR", "Bloodblaster", 
    "BloodPistol", "BloodSMG", "BloodStaff", "BurstRifle", "CombatShotgun", 
    "CoreBreaker", "CosmicPistol", "Deagle", "DualPistols", "EmberSMG", 
    "Flamethrower", "GalacticWeaver", "GoldenAK47", "GrenadeLauncher", 
    "GumdropBlaster", "HeavyRifle", "HoneyBadger", "HydraCannon", "ImpalerRifle", 
    "InfernoMinigun", "Interstellar", "LavaBow", "LavaGatling", "LavaRifle", 
    "Minigun", "MP5", "P90", "Pistol", "Plasma", "Pulsar", "Quasar", "Redline", 
    "Revolver", "RicochetRevolver", "Rifle", "RPG", "Scar-H", "ShotGun", 
    "Slingshot", "SMG", "Sniper", "StarShooter", "TommyGun", "USPS", 
    "ViridianAR", "ViridianPistol", "ViridianShotgun", "ViridianSniper", 
    "VoidScythe", "WorldEnder", "WorldrootCrossbow"
}

local SenjataValid = {}
for _, nama in ipairs(SemuaSenjata) do
    SenjataValid[nama] = true
end

-- ==========================================
-- FUNGSI OPTIMASI PART (NO LAG)
-- ==========================================
local function OptimasiObjek(obj)
    if not AutoAntiLag then return end
    
    -- Filter: Jangan sentuh Zombie atau Karakter Pemain
    if obj:FindFirstAncestor("Zombies") or obj:FindFirstAncestor("Zombies_Local") then return end
    if obj:FindFirstAncestorOfClass("Model") and Players:GetPlayerFromCharacter(obj:FindFirstAncestorOfClass("Model")) then return end

    pcall(function()
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            obj.Enabled = false -- Matikan efek partikel berlebih pada map/senjata luar
        end
    end)
end

-- ==========================================
-- TAMPILAN MENU (UI)
-- ==========================================

Window:AddInput("Kecepatan Remote (Detik)", "Default: 0.2", function(text)
    local angka = tonumber(text)
    if angka then KecepatanRemote = angka end
end)

Window:AddToggle("Auto Silent Aim (Legit/Crosshair)", true, function(state)
    AutoSilentAim = state
end)

--Window:AddInput("Jarak Maksimal Silent Aim", "Default: 1500", function(text)
    --local angka = tonumber(text)
    --if angka then MaxJarakSilentAim = angka end
--end)

Window:AddInput("Radius FOV Crosshair (Pixel)", "Default: 150", function(text)
    local angka = tonumber(text)
    if angka then MaxFOVSilentAim = angka end
end)

Window:AddToggle("Auto Kill Aura (Terdekat)", false, function(state)
    AutoAuraKill = state
end)

Window:AddInput("Jarak Kill Aura", "Default: 50", function(text)
    local angka = tonumber(text)
    if angka then MaxJarakAuraKill = angka end
end)

Window:AddToggle("Auto Kill All (Tembak 1 Map)", false, function(state)
    AutoKillAll = state
end)

Window:AddToggle("Anti AFK (Advanced & No Lag)", true, function(state)
    AutoAntiAFK = state
    if state and getconnections then
        pcall(function()
            for _, connection in pairs(getconnections(LocalPlayer.Idled)) do
                connection:Disable()
            end
        end)
    end
end)

Window:AddToggle("Auto Hip Height", false, function(state)
    AutoHipHeight = state
end)

--Window:AddInput("Atur Tinggi (Max 60)", "Default: 30", function(text)
    --local angka = tonumber(text)
    --if angka then TargetHipHeight = (angka > 60) and 60 or angka end
--end)

Window:AddToggle("No Fog (Hapus Kabut)", true, function(state)
    AutoNoFog = state
end)

-- Tombol Anti Lag yang Diperbarui (Pengecualian Zombie)
Window:AddToggle("Anti Lag (Advanced & 0% Spike)", false, function(state)
    AutoAntiLag = state
    if state then
        -- 1. Penurunan Kualitas Rendering Dasar
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            Lighting.GlobalShadows = false
            if sethiddenproperty then
                sethiddenproperty(Lighting, "Technology", 2)
            end
        end)

        -- 2. Proses objek yang SUDAH ADA di dalam map
        task.spawn(function()
            local isiMap = Workspace:GetDescendants()
            for i = 1, #isiMap do
                OptimasiObjek(isiMap[i])
                if i % 1000 == 0 then task.wait() end 
            end
        end)

        -- 3. Tangkap objek yang BARU MUNCUL
        if not AntiLagConnection then
            AntiLagConnection = Workspace.DescendantAdded:Connect(OptimasiObjek)
        end
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

Window:AddToggle("Auto Collect Bloodmoon Shard", false, function(state)
    AutoCollectBloodmoon = state
end)

-- ==========================================
-- MESIN BELAKANG (LOOPING TUGAS)
-- ==========================================

-- 0. Mesin Pasif Anti-AFK
LocalPlayer.Idled:Connect(function()
    if AutoAntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- 1. Mesin Auto Upgrade & Spin
task.spawn(function()
    while task.wait(0.3) do
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
    while task.wait(0.5) do
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

-- 3. Mesin Auto Silent Aim
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

-- 4. Mesin Auto Kill Aura
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

-- 5. Mesin Auto Kill All
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

-- 6. Mesin NoFog
task.spawn(function()
    while task.wait(3) do
        if AutoNoFog then
            pcall(function()
                Lighting.FogEnd = 9e9
                Lighting.FogStart = 9e9
            end)
        end
    end
end)

-- 7. Mesin Update Indikator FOV (Diperbarui untuk GUI Native)
RunService.RenderStepped:Connect(function()
    if AutoSilentAim then
        local viewportSize = Camera.ViewportSize
        -- Update posisi agar selalu persis di tengah layar
        FOVFrame.Position = UDim2.new(0, viewportSize.X / 2, 0, viewportSize.Y / 2)
        -- Update ukuran berdasarkan angka FOV (Radius dikali 2 untuk dapat Diameter / ukuran Frame)
        FOVFrame.Size = UDim2.new(0, MaxFOVSilentAim * 2, 0, MaxFOVSilentAim * 2)
        FOVFrame.Visible = true
    else
        FOVFrame.Visible = false
    end
end)

-- ==========================================
-- MESIN AUTO COLLECT BLOODMOON SHARD
-- ==========================================

-- A. Mesin Penangkap ID & Jumlah Shard (Real-time)
task.spawn(function()
    local eventRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("EventRemotes")
    local dropEvent = eventRemotes:WaitForChild("BloodmoonShardDrop")
    
    dropEvent.OnClientEvent:Connect(function(shardID, amount, position)
        if shardID and type(amount) == "number" then
            -- Alih-alih pakai 'true', kita simpan JUMLAH shard yang jatuh ke dalam ID tersebut.
            -- Jika ID yang sama jatuh lagi, jumlahnya akan ditambahkan.
            DaftarIDShard[shardID] = (DaftarIDShard[shardID] or 0) + amount
        end
    end)
end)

-- B. Mesin Eksekutor Pengambil Shard (Per 1 Detik)
task.spawn(function()
    while task.wait(1) do
        if AutoCollectBloodmoon then
            for id_shard, jumlah in pairs(DaftarIDShard) do
                if jumlah > 0 then
                    pcall(function()
                        -- Lakukan spam remote sebanyak jumlah shard yang jatuh untuk ID tersebut
                        for i = 1, jumlah do
                            ReplicatedStorage.Remotes.EventRemotes.BloodmoonShardCollect:FireServer(id_shard)
                        end
                        
                        -- Setelah semua ditembak ke server, hapus ID dari memori agar tidak lag
                        DaftarIDShard[id_shard] = nil
                    end)
                end
            end
        end
    end
end)
