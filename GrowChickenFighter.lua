-- ==========================================
-- GROW A CHICKEN FIGHTER - AUTOMATION SCRIPT
-- ==========================================

-- Memanggil library dari GitHub
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Window = Library:MakeWindow("Grow a Chicken Fighter")

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)

-- State Variables
local AutoBuyGenerator = false
local AutoUpgradeGenerator = false
local AutoUpgradeRecycler = false
local AutoExpandCoop = false
local AutoNoThanks = false
local AutoTower = false
local TowerDelay = 1 -- Default 1 detik
local AutoAntiLag = false
local AutoNoFog = false
local AutoAntiAFK = true

local LoopInterval = 1.2

-- ==========================================
-- ADVANCED ANTI-AFK ENGINE
-- ==========================================
task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        if AutoAntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
    while task.wait(60) do
        if AutoAntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
                task.wait(0.1)
                VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            end)
        end
    end
end)

-- ==========================================
-- LOOP OTOMASI REMOTE
-- ==========================================

-- 1. Auto Buy Generator (1 sampai 6)
task.spawn(function()
    while task.wait(LoopInterval) do
        if AutoBuyGenerator and Remotes and Remotes:FindFirstChild("BuyGenerator") then
            for gen = 1, 6 do
                if not AutoBuyGenerator then break end
                pcall(function()
                    Remotes.BuyGenerator:InvokeServer(gen)
                end)
                task.wait(0.25)
            end
        end
    end
end)

-- 2. Auto Upgrade Generator (1 sampai 6)
task.spawn(function()
    while task.wait(LoopInterval) do
        if AutoUpgradeGenerator and Remotes and Remotes:FindFirstChild("UpgradeGenerator") then
            for gen = 1, 6 do
                if not AutoUpgradeGenerator then break end
                pcall(function()
                    Remotes.UpgradeGenerator:InvokeServer(gen)
                end)
                task.wait(0.25)
            end
        end
    end
end)

-- 3. Auto Upgrade Recycler
task.spawn(function()
    while task.wait(LoopInterval) do
        if AutoUpgradeRecycler and Remotes and Remotes:FindFirstChild("UpgradeRecycler") then
            pcall(function()
                Remotes.UpgradeRecycler:InvokeServer()
            end)
        end
    end
end)

-- 4. Auto Expand Coop
task.spawn(function()
    while task.wait(LoopInterval) do
        if AutoExpandCoop and Remotes and Remotes:FindFirstChild("ExpandCoop") then
            pcall(function()
                Remotes.ExpandCoop:InvokeServer()
            end)
        end
    end
end)

-- 5. Auto No Thanks (Tower Continue Decline)
task.spawn(function()
    while task.wait(LoopInterval) do
        if AutoNoThanks then
            pcall(function()
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    local towerContinue = playerGui:FindFirstChild("TowerContinue")
                    if towerContinue and towerContinue:FindFirstChild("Frame") then
                        local declineEvent = Remotes and Remotes:FindFirstChild("TowerContinueDecline")
                        if declineEvent then
                            declineEvent:FireServer()
                        end
                    end
                end
            end)
        end
    end
end)

-- 6. Auto Tower (Filter Teks & Delay)
task.spawn(function()
    while task.wait(1) do -- Cek setiap 1 detik
        if AutoTower then
            pcall(function()
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    local hud = playerGui:FindFirstChild("HUD")
                    local caption = hud 
                        and hud:FindFirstChild("Frame") 
                        and hud.Frame:FindFirstChild("trio") 
                        and hud.Frame.trio:FindFirstChild("tower") 
                        and hud.Frame.trio.tower:FindFirstChild("caption")

                    -- Cek apakah teks berisi "TOWER" (huruf besar/kecil diabaikan agar aman)
                    if caption and string.match(string.upper(caption.Text), "TOWER") then
                        -- Tunggu sesuai input (default 1 detik)
                        task.wait(TowerDelay)
                        
                        -- Cek lagi apakah Auto Tower masih menyala setelah delay selesai
                        if AutoTower then
                            local towerStart = Remotes and Remotes:FindFirstChild("TowerStart")
                            if towerStart then
                                towerStart:InvokeServer()
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ==========================================
-- ANTI-LAG & NO FOG
-- ==========================================
local function MemoryLightAntiLag()
    pcall(function()
        Lighting.GlobalShadows = false
        Workspace.Terrain.WaterWaveSize = 0
        Workspace.Terrain.WaterWaveSpeed = 0
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            end
        end
    end)
end

task.spawn(function()
    while task.wait(3) do
        if AutoNoFog then
            pcall(function()
                Lighting.FogEnd = 9e9
                Lighting.FogStart = 9e9
                local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
                if atmosphere then
                    atmosphere.Density = 0
                end
            end)
        end
    end
end)

-- ==========================================
-- UI MENU & TOGGLES
-- ==========================================
Window:AddToggle("Auto Buy Generator (1-6)", false, function(state)
    AutoBuyGenerator = state
end)

Window:AddToggle("Auto Upgrade Generator (1-6)", false, function(state)
    AutoUpgradeGenerator = state
end)

Window:AddToggle("Auto Upgrade Recycler", false, function(state)
    AutoUpgradeRecycler = state
end)

Window:AddToggle("Auto Expand Coop", false, function(state)
    AutoExpandCoop = state
end)

Window:AddToggle("Auto No Thanks (Tower)", false, function(state)
    AutoNoThanks = state
end)

-- Input dan Toggle untuk Tower Start
Window:AddInput("Tower Delay (Detik)", "Angka (Def: 1)", function(text)
    -- Pastikan yang dimasukkan adalah angka, jika gagal kembali ke default 1 detik
    local num = tonumber(text)
    if num then
        TowerDelay = num
    else
        TowerDelay = 1
    end
end)

Window:AddToggle("Auto Tower", false, function(state)
    AutoTower = state
end)

Window:AddToggle("No Fog (Infinite View)", false, function(state)
    AutoNoFog = state
end)

Window:AddToggle("Anti-Lag (Memory Light)", false, function(state)
    AutoAntiLag = state
    if state then
        MemoryLightAntiLag()
    end
end)

Window:AddToggle("Advanced Anti-AFK", true, function(state)
    AutoAntiAFK = state
end)
