-- ==========================================
-- GROW A CHICKEN FIGHTER - AUTOMATION SCRIPT
-- ==========================================

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
local MaxGeneratorTier = 6
local AutoBuyGenerator = false
local AutoUpgradeGenerator = false
local AutoUpgradeRecycler = false
local AutoExpandCoop = false
local AutoRebirth = false
local AutoNoThanks = false
local AutoTower = false
local TowerDelay = 1 
local AutoAntiLag = false
local AutoNoFog = false
local AutoAntiAFK = true

-- Variabel Memori Smart Tracking
local TargetRebirthFloor = nil
local HighestFloorMemory = 0

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
-- HELPER FUNCTION: GET CURRENT FLOOR (WORKSPACE)
-- ==========================================
local function GetCurrentTowerFloor()
    local currentFloor = 0
    local myPlotNum = nil

    pcall(function()
        local plots = Workspace:FindFirstChild("World") and Workspace.World:FindFirstChild("Plots")
        if plots then
            for _, plot in pairs(plots:GetChildren()) do
                if plot:FindFirstChild("Owner") and plot.Owner:FindFirstChild("PlayerName") then
                    if plot.Owner.PlayerName.Text == LocalPlayer.Name then
                        myPlotNum = string.match(plot.Name, "Plot(%d+)")
                        break
                    end
                end
            end
        end

        if myPlotNum then
            local towerStack = Workspace:FindFirstChild("TowerStack" .. myPlotNum)
            if towerStack then
                for _, floorPart in pairs(towerStack:GetChildren()) do
                    local fNum = string.match(floorPart.Name, "Floor(%d+)")
                    if fNum then
                        local num = tonumber(fNum)
                        if num > currentFloor then
                            currentFloor = num
                        end
                    end
                end
            end
        end
    end)

    return currentFloor
end

-- ==========================================
-- MEMORY TRACKER LOOP (Menjaga Ingatan Skrip)
-- ==========================================
task.spawn(function()
    while task.wait(0.5) do
        -- 1. Update dari Workspace (saat TowerStack ada)
        local wsFloor = GetCurrentTowerFloor()
        if wsFloor > HighestFloorMemory then
            HighestFloorMemory = wsFloor
        end

        -- 2. Update dari UI Rebirth (jika menu sedang dibuka)
        pcall(function()
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                local rebirthGui = playerGui:FindFirstChild("Rebirth")
                if rebirthGui and rebirthGui:FindFirstChild("Frame") and rebirthGui.Frame:FindFirstChild("window") then
                    local reqCard = rebirthGui.Frame.window:FindFirstChild("panel")
                        and rebirthGui.Frame.window.panel:FindFirstChild("face")
                        and rebirthGui.Frame.window.panel.face:FindFirstChild("content")
                        and rebirthGui.Frame.window.panel.face.content:FindFirstChild("content")
                        and rebirthGui.Frame.window.panel.face.content.content:FindFirstChild("body")
                        and rebirthGui.Frame.window.panel.face.content.content.body:FindFirstChild("reqCard")

                    if reqCard and reqCard:FindFirstChild("face") and reqCard.face:FindFirstChild("content") and reqCard.face.content:FindFirstChild("bar") then
                        local textLabel = reqCard.face.content.bar:FindFirstChild("text")
                        if textLabel and textLabel.Text then
                            local curStr, reqStr = string.match(textLabel.Text, "(%d+)%s*/%s*(%d+)")
                            if curStr and reqStr then
                                local uiFloor = tonumber(curStr)
                                TargetRebirthFloor = tonumber(reqStr)
                                
                                -- Simpan angka tertinggi
                                if uiFloor > HighestFloorMemory then
                                    HighestFloorMemory = uiFloor
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- ==========================================
-- LOOP OTOMASI REMOTE
-- ==========================================

-- 1. Auto Buy Generator
task.spawn(function()
    while task.wait(LoopInterval) do
        if AutoBuyGenerator and Remotes and Remotes:FindFirstChild("BuyGenerator") then
            for gen = 1, MaxGeneratorTier do
                if not AutoBuyGenerator then break end
                pcall(function() Remotes.BuyGenerator:InvokeServer(gen) end)
                task.wait(0.25)
            end
        end
    end
end)

-- 2. Auto Upgrade Generator
task.spawn(function()
    while task.wait(LoopInterval) do
        if AutoUpgradeGenerator and Remotes and Remotes:FindFirstChild("UpgradeGenerator") then
            for gen = 1, MaxGeneratorTier do
                if not AutoUpgradeGenerator then break end
                pcall(function() Remotes.UpgradeGenerator:InvokeServer(gen) end)
                task.wait(0.25)
            end
        end
    end
end)

-- 3. Auto Upgrade Recycler
task.spawn(function()
    while task.wait(LoopInterval) do
        if AutoUpgradeRecycler and Remotes and Remotes:FindFirstChild("UpgradeRecycler") then
            pcall(function() Remotes.UpgradeRecycler:InvokeServer() end)
        end
    end
end)

-- 4. Auto Expand Coop
task.spawn(function()
    while task.wait(LoopInterval) do
        if AutoExpandCoop and Remotes and Remotes:FindFirstChild("ExpandCoop") then
            pcall(function() Remotes.ExpandCoop:InvokeServer() end)
        end
    end
end)

-- 5. SMART AUTO REBIRTH + FALLBACK
task.spawn(function()
    while task.wait(LoopInterval) do
        if AutoRebirth then
            if TargetRebirthFloor then
                -- Eksekusi jika memori lantai saat ini sudah mencapai target
                if HighestFloorMemory >= TargetRebirthFloor then
                    pcall(function()
                        local surrenderEvent = Remotes:FindFirstChild("TowerSurrender")
                        if surrenderEvent then
                            surrenderEvent:InvokeServer()
                            task.wait(1) 
                        end
                        
                        local rebirthEvent = Remotes:FindFirstChild("Rebirth")
                        if rebirthEvent then
                            rebirthEvent:InvokeServer()
                            
                            -- Reset memori kembali ke 0 karena sudah sukses rebirth
                            TargetRebirthFloor = nil 
                            HighestFloorMemory = 0
                        end
                    end)
                end
            else
                -- Fallback jika target floor belum terdeteksi (Menu UI belum pernah dibuka)
                pcall(function()
                    local rebirthEvent = Remotes and Remotes:FindFirstChild("Rebirth")
                    if rebirthEvent then
                        rebirthEvent:InvokeServer()
                        -- Reset memori just in case berhasil rebirth via fallback
                        HighestFloorMemory = 0 
                    end
                end)
            end
        end
    end
end)

-- 6. Auto No Thanks (Tower Continue Decline)
task.spawn(function()
    while task.wait(LoopInterval) do
        if AutoNoThanks then
            pcall(function()
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    local towerContinue = playerGui:FindFirstChild("TowerContinue")
                    if towerContinue and towerContinue:FindFirstChild("Frame") then
                        local declineEvent = Remotes and Remotes:FindFirstChild("TowerContinueDecline")
                        if declineEvent then declineEvent:FireServer() end
                    end
                end
            end)
        end
    end
end)

-- 7. SMART AUTO TOWER (Elevator + Start)
task.spawn(function()
    while task.wait(1) do 
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

                    if caption and string.match(string.upper(caption.Text), "TOWER") then
                        task.wait(TowerDelay)
                        if AutoTower then
                            
                            -- A. Tembak Elevator menggunakan memori lantai terakhir yang diingat
                            if HighestFloorMemory > 0 then
                                local elevatorEvent = Remotes and Remotes:FindFirstChild("TowerElevator")
                                if elevatorEvent then
                                    pcall(function() elevatorEvent:InvokeServer(HighestFloorMemory) end)
                                    task.wait(0.2) -- Jeda sebentar sebelum menekan start
                                end
                            end

                            -- B. Tembak Tower Start (Sebagai kelanjutan atau fallback jika elevator gagal)
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
                if atmosphere then atmosphere.Density = 0 end
            end)
        end
    end
end)

-- ==========================================
-- UI MENU & TOGGLES
-- ==========================================

Window:AddInput("Batas Maksimal Generator (1-6)", "Ketik 1 - 6 (Def: 6)", function(text)
    local num = tonumber(text)
    if num then
        num = math.floor(num)
        if num >= 1 and num <= 6 then
            MaxGeneratorTier = num
        else
            MaxGeneratorTier = 6 
        end
    else
        MaxGeneratorTier = 6 
    end
end)

Window:AddToggle("Auto Buy Generator", false, function(state) AutoBuyGenerator = state end)
Window:AddToggle("Auto Upgrade Generator", false, function(state) AutoUpgradeGenerator = state end)

Window:AddToggle("Auto Upgrade Recycler", false, function(state) AutoUpgradeRecycler = state end)
Window:AddToggle("Auto Expand Coop", false, function(state) AutoExpandCoop = state end)
Window:AddToggle("Auto Rebirth (Smart Tracking)", false, function(state) AutoRebirth = state end)
Window:AddToggle("Auto No Thanks (Tower)", false, function(state) AutoNoThanks = state end)

Window:AddInput("Tower Delay (Detik)", "Angka (Def: 1)", function(text)
    local num = tonumber(text)
    if num then TowerDelay = num else TowerDelay = 1 end
end)
Window:AddToggle("Auto Tower (Smart Elevator)", false, function(state) AutoTower = state end)

Window:AddToggle("No Fog (Infinite View)", false, function(state) AutoNoFog = state end)
Window:AddToggle("Anti-Lag (Memory Light)", false, function(state)
    AutoAntiLag = state
    if state then MemoryLightAntiLag() end
end)
Window:AddToggle("Advanced Anti-AFK", true, function(state) AutoAntiAFK = state end)
