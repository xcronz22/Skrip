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
FOVGui.IgnoreGuiInset = true
local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
FOVGui.Parent = success and coreGui or LocalPlayer:WaitForChild("PlayerGui")

local FOVFrame = Instance.new("Frame")
FOVFrame.Parent = FOVGui
FOVFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FOVFrame.BackgroundTransparency = 1 
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5) 

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0) 
FOVCorner.Parent = FOVFrame

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.fromRGB(255, 255, 255) 
FOVStroke.Thickness = 1.5
FOVStroke.Transparency = 0.3 
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

local MaxJarakSilentAim = 1500 
local MaxFOVSilentAim = 150
local MaxJarakAuraKill = 50
local TargetHipHeight = 30 
local KecepatanRemote = 0.2 

-- Daftar Senjata Tembak
local SemuaSenjata = {
    "AcidSpitter", "AK47", "ArcWelder", "ArticStriker", "BloodAR", "Bloodblaster", 
    "BloodPistol", "BloodSMG", "BurstRifle", "CombatShotgun", 
    "CoreBreaker", "CosmicPistol", "Deagle", "DualPistols", "EmberSMG", 
    "Flamethrower", "GalacticWeaver", "GoldenAK47", "GrenadeLauncher", 
    "GumdropBlaster", "HeavyRifle", "HoneyBadger", "HydraCannon", "ImpalerRifle", 
    "InfernoMinigun", "Interstellar", "LavaBow", "LavaGatling", "LavaRifle", 
    "Minigun", "MP5", "P90", "Pistol", "Plasma", "Pulsar", "Quasar", "Redline", 
    "Revolver", "RicochetRevolver", "Rifle", "RPG", "Scar-H", "ShotGun", 
    "Slingshot", "SMG", "Sniper", "StarShooter", "TommyGun", "USPS", 
    "ViridianAR", "ViridianPistol", "ViridianShotgun", "ViridianSniper", 
    "WorldEnder", "WorldrootCrossbow"
}

-- Daftar Senjata Melee
local SenjataMelee = {
    "BloodStaff",
    "Scythe",
    "VoidScythe"
}

local SenjataValid = {}
for _, nama in ipairs(SemuaSenjata) do
    SenjataValid[nama] = true
end

local SenjataMeleeValid = {}
for _, nama in ipairs(SenjataMelee) do
    SenjataMeleeValid[nama] = true
end

-- ==========================================
-- FUNGSI OPTIMASI PART (NO LAG)
-- ==========================================
local function OptimasiObjek(obj)
    if not AutoAntiLag then return end
    if obj:FindFirstAncestor("Zombies") or obj:FindFirstAncestor("Zombies_Local") then return end
    if obj:FindFirstAncestorOfClass("Model") and Players:GetPlayerFromCharacter(obj:FindFirstAncestorOfClass("Model")) then return end

    pcall(function()
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            obj.Enabled = false
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

Window:AddToggle("Auto Hip Height", false, function(state) AutoHipHeight = state end)
Window:AddToggle("No Fog (Hapus Kabut)", true, function(state) AutoNoFog = state end)
Window:AddToggle("Anti Lag (Advanced & 0% Spike)", false, function(state)
    AutoAntiLag = state
    if state then
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            Lighting.GlobalShadows = false
            if sethiddenproperty then sethiddenproperty(Lighting, "Technology", 2) end
        end)
        task.spawn(function()
            local isiMap = Workspace:GetDescendants()
            for i = 1, #isiMap do
                OptimasiObjek(isiMap[i])
                if i % 1000 == 0 then task.wait() end 
            end
        end)
        if not AntiLagConnection then AntiLagConnection = Workspace.DescendantAdded:Connect(OptimasiObjek) end
    end
end)

Window:AddToggle("Auto Bloodmoon Spin", false, function(state) AutoBloodmoon = state end)
Window:AddToggle("Auto Artifact Spin", false, function(state) AutoArtifact = state end)
Window:AddToggle("Auto Health Upgrade", false, function(state) AutoHealth = state end)

-- ==========================================
-- MESIN BELAKANG (LOOPING TUGAS)
-- ==========================================

LocalPlayer.Idled:Connect(function()
    if AutoAntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if AutoBloodmoon then pcall(function() ReplicatedStorage.Remotes.EventRemotes.BloodmoonRequestSpin:InvokeServer() end) end
        if AutoArtifact then pcall(function() ReplicatedStorage.Remotes.ArtifactCrateRemotes.Spin:InvokeServer("Standard", 5) end) end
        if AutoHealth then pcall(function() ReplicatedStorage.Remotes.UpgradeRemotes.PurchaseHealthUpgrade:FireServer() end) end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        local character = LocalPlayer.Character
        if character and character:FindFirstChildOfClass("Humanoid") then
            if AutoHipHeight then
                character.Humanoid.HipHeight = TargetHipHeight
            else
                if character.Humanoid.HipHeight ~= 0 then character.Humanoid.HipHeight = 0 end
            end
        end
    end
end)

-- 3. Mesin Auto Silent Aim (DIPERBARUI)
task.spawn(function()
    while true do
        task.wait(KecepatanRemote) -- Kecepatan utama ayunan/tembakan
        if AutoSilentAim then
            pcall(function()
                local character = LocalPlayer.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                local senjataPegang = character:FindFirstChildOfClass("Tool")
                
                if senjataPegang then
                    local namaSenjata = senjataPegang.Name
                    local isGun = SenjataValid[namaSenjata]
                    local isMelee = SenjataMeleeValid[namaSenjata]
                    
                    if isGun or isMelee then
                        local myPos = character.HumanoidRootPart.Position
                        local zombiesFolder = Workspace:FindFirstChild("Zombies_Local") or Workspace:FindFirstChild("Zombies")
                        
                        if zombiesFolder then
                            local viewportSize = Camera.ViewportSize
                            local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
                            
                            -- LOGIKA KHUSUS MELEE (AYUNAN KONSTAN SELAMA ADA MUSUH HIDUP)
                            if isMelee then
                                local musuhDiFOV = false
                                
                                for _, zombie in pairs(zombiesFolder:GetChildren()) do
                                    local targetPart = zombie:FindFirstChild("HumanoidRootPart")
                                    local targetHum = zombie:FindFirstChildOfClass("Humanoid") or zombie:FindFirstChild("Humanoid")
                                    
                                    -- Cek validitas & pastikan zombie MASIH HIDUP (>0)
                                    if targetPart and targetHum and targetHum.Health > 0 then
                                        local targetPos = targetPart.Position
                                        if (targetPos - myPos).Magnitude <= MaxJarakSilentAim then
                                            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
                                            if onScreen and (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude <= MaxFOVSilentAim then
                                                musuhDiFOV = true
                                                break -- Cukup temukan 1 musuh hidup, stop pencarian
                                            end
                                        end
                                    end
                                end
                                
                                -- Jika ada minimal 1 musuh hidup di FOV, tembak remote ayunan pedang!
                                if musuhDiFOV then
                                    ReplicatedStorage.Remotes.GunRemotes.MeleeSwing:FireServer(namaSenjata)
                                end
                                
                            -- LOGIKA KHUSUS SENJATA API (TEMBAK SEMUA MUSUH DI FOV)
                            elseif isGun then
                                for _, zombie in pairs(zombiesFolder:GetChildren()) do
                                    local targetPart = zombie:FindFirstChild("HumanoidRootPart")
                                    local targetHum = zombie:FindFirstChildOfClass("Humanoid") or zombie:FindFirstChild("Humanoid")
                                    
                                    if targetPart and targetHum and targetHum.Health > 0 then
                                        local targetPos = targetPart.Position
                                        if (targetPos - myPos).Magnitude <= MaxJarakSilentAim then
                                            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
                                            if onScreen and (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude <= MaxFOVSilentAim then
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
                end
            end)
        end
    end
end)

-- 4. Mesin Auto Kill Aura (DIPERBARUI)
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
                        local targetHum = zombie:FindFirstChildOfClass("Humanoid") or zombie:FindFirstChild("Humanoid")
                        
                        -- Pastikan hanya menyerang yang masih hidup
                        if targetPart and targetHum and targetHum.Health > 0 then
                            local targetPos = targetPart.Position
                            
                            if (targetPos - myPos).Magnitude <= MaxJarakAuraKill then
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

-- 5. Mesin Auto Kill All (DIPERBARUI)
task.spawn(function()
    while true do
        task.wait(KecepatanRemote)
        if AutoKillAll then
            pcall(function()
                local character = LocalPlayer.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                local senjataPegang = character:FindFirstChildOfClass("Tool")
                
                if senjataPegang then
                    local namaSenjata = senjataPegang.Name
                    local isGun = SenjataValid[namaSenjata]
                    local isMelee = SenjataMeleeValid[namaSenjata]
                    
                    if isGun or isMelee then
                        local myPos = character.HumanoidRootPart.Position
                        local zombiesFolder = Workspace:FindFirstChild("Zombies_Local") or Workspace:FindFirstChild("Zombies")
                        
                        if zombiesFolder then
                            -- Jika pegang pedang, spam remote pedang secara instan tanpa cek jarak/FOV
                            if isMelee then
                                ReplicatedStorage.Remotes.GunRemotes.MeleeSwing:FireServer(namaSenjata)
                            end
                            
                            for _, zombie in pairs(zombiesFolder:GetChildren()) do
                                local targetPart = zombie:FindFirstChild("HumanoidRootPart")
                                local targetHum = zombie:FindFirstChildOfClass("Humanoid") or zombie:FindFirstChild("Humanoid")
                                
                                -- Hajar semua yang masih hidup di dalam map
                                if targetPart and targetHum and targetHum.Health > 0 then
                                    local ID_String = string.match(zombie.Name, "%d+")
                                    
                                    if ID_String then
                                        local ID_Angka = tonumber(ID_String)
                                        local targetPos = targetPart.Position
                                        
                                        if isGun then
                                            local arahTembakan = (targetPos - myPos).Unit
                                            ReplicatedStorage.Remotes.NetRemotes.GunFire:FireServer(namaSenjata, myPos, arahTembakan)
                                            ReplicatedStorage.Remotes.GunRemotes.GunHit:FireServer(namaSenjata, ID_Angka, targetPos)
                                        end
                                        
                                        ReplicatedStorage.Remotes.ZombieRemotes.ZombieDamage:FireServer(ID_Angka, math.huge)
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

-- 7. Mesin Update Indikator FOV
RunService.RenderStepped:Connect(function()
    if AutoSilentAim then
        local viewportSize = Camera.ViewportSize
        FOVFrame.Position = UDim2.new(0, viewportSize.X / 2, 0, viewportSize.Y / 2)
        FOVFrame.Size = UDim2.new(0, MaxFOVSilentAim * 2, 0, MaxFOVSilentAim * 2)
        FOVFrame.Visible = true
    else
        FOVFrame.Visible = false
    end
end)
