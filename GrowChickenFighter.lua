-- ==========================================
-- GROW A CHICKEN FIGHTER - OPTIMIZED STEALTH V9 (SAFE WANDERING)
-- ==========================================

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Window = Library:MakeWindow("Grow a Chicken Fighter")

-- Services (TANPA VIRTUAL USER)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)

-- State Variables (Diatur dari UI)
local MaxGeneratorTier = 1
local AutoBuyGenerator = false
local AutoUpgradeGenerator = false
local AutoUpgradeRecycler = false
local AutoExpandCoop = false
local AutoRebirth = false
local AutoNoThanks = false
local AutoTower = false
local TowerDelay = 10 
local AutoAntiLag = false
local AutoNoFog = false
local MaxStuckTime = 5 

-- Variabel Internal & Memori Tower
local LoopInterval = 1.2
local TargetRebirthFloor = nil
local HighestFloorMemory = 0
local LastFloorChangeTime = tick()

-- Variabel Zona Feeder & Memori Posisi
local IsInFeederZone = false
local SavedFeederPosition = nil 
local NextRandomMoveTime = tick()

-- ==========================================
-- ANTI-AFK STEALTH (BYPASS EXECUTOR)
-- ==========================================
pcall(function()
    for _, conn in pairs(getconnections(LocalPlayer.Idled)) do
        conn:Disable()
    end
end)

-- ==========================================
-- LOGIKA ZONA AMAN & PERGERAKAN NATURAL
-- ==========================================
task.spawn(function()
    while task.wait(0.2) do
        if MaxGeneratorTier == 1 and (AutoBuyGenerator or AutoUpgradeGenerator) then
            pcall(function()
                local character = LocalPlayer.Character
                local humanoid = character and character:FindFirstChild("Humanoid")
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                
                if humanoid and hrp then
                    -- 1. Selalu update ingatan posisi Feeder
                    local coopUI = Workspace:FindFirstChild("CoopUI") or (Workspace:FindFirstChild("Coops") and Workspace.Coops:FindFirstChild("CoopUI"))
                    if coopUI then
                        local feeder = coopUI:FindFirstChild("Feeder")
                        if feeder then
                            SavedFeederPosition = feeder:GetPivot().Position
                        end
                    end
                    
                    -- 2. Gunakan memori posisi Feeder untuk navigasi
                    if SavedFeederPosition then
                        local distance = (hrp.Position - SavedFeederPosition).Magnitude
                        
                        if distance > 4 then
                            IsInFeederZone = false -- Kunci remote, tarik karakter masuk ke tengah
                            humanoid:MoveTo(SavedFeederPosition) 
                        else
                            IsInFeederZone = true -- AMAN, Boleh Auto Buy & Upgrade!
                            
                            -- Gerak acak (2-10 stud, tiap 10-20 detik)
                            if tick() >= NextRandomMoveTime then
                                local randDistIn = math.random(20, 100) / 10 -- 2.0 sampai 10.0 stud
                                local randAngleIn = math.random() * math.pi * 2
                                local targetPos = hrp.Position + Vector3.new(math.cos(randAngleIn) * randDistIn, 0, math.sin(randAngleIn) * randDistIn)
                                
                                humanoid:MoveTo(targetPos)
                                NextRandomMoveTime = tick() + math.random(10, 20)
                            end
                        end
                    else
                        IsInFeederZone = false 
                    end
                end
            end)
        else
            IsInFeederZone = true 
        end
    end
end)

-- ==========================================
-- HELPER FUNCTION & SMART TRACKING (3 SUMBER)
-- ==========================================
local CachedPlotNum = nil
local MyTowerStack = nil
local TowerConnection = nil

local function UpdateMaxFloorFromPart(part)
    if part and part.Name then
        local fNum = string.match(part.Name, "Floor(%d+)")
        if fNum then
            local num = tonumber(fNum)
            if num and num > HighestFloorMemory then
                HighestFloorMemory = num
                LastFloorChangeTime = tick()
            end
        end
    end
end

local function FindMyTowerStack()
    if not CachedPlotNum then
        local plots = Workspace:FindFirstChild("World") and Workspace.World:FindFirstChild("Plots")
        if plots then
            for _, plot in pairs(plots:GetChildren()) do
                if plot:FindFirstChild("Owner") and plot.Owner:FindFirstChild("PlayerName") then
                    if plot.Owner.PlayerName.Text == LocalPlayer.Name then
                        CachedPlotNum = string.match(plot.Name, "%d+")
                        break
                    end
                end
            end
        end
    end
    if CachedPlotNum then
        return Workspace:FindFirstChild("TowerStack" .. CachedPlotNum)
    end
    return nil
end

task.spawn(function()
    while task.wait(0.2) do
        -- SUMBER 1: INSTANT WORKSPACE TRACKING
        pcall(function()
            local currentTower = FindMyTowerStack()
            if currentTower ~= MyTowerStack then
                MyTowerStack = currentTower
                if TowerConnection then TowerConnection:Disconnect() end
                if MyTowerStack then
                    for _, part in pairs(MyTowerStack:GetChildren()) do
                        UpdateMaxFloorFromPart(part)
                    end
                    TowerConnection = MyTowerStack.ChildAdded:Connect(function(child)
                        UpdateMaxFloorFromPart(child)
                    end)
                end
            elseif MyTowerStack then
                for _, part in pairs(MyTowerStack:GetChildren()) do
                    UpdateMaxFloorFromPart(part)
                end
            end
        end)

        -- SUMBER 2: UI REBIRTH TRACKING
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
                                if uiFloor and uiFloor > HighestFloorMemory then
                                    HighestFloorMemory = uiFloor
                                    LastFloorChangeTime = tick()
                                end
                            end
                        end
                    end
                end
            end
        end)

        -- SUMBER 3: LEADERBOARD TRACKING
        pcall(function()
            local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
            if leaderstats then
                local towerStat = leaderstats:FindFirstChild("Tower") or leaderstats:FindFirstChild("Floor")
                if towerStat then
                    local floorVal = tonumber(towerStat.Value)
                    if floorVal and floorVal > HighestFloorMemory then
                        HighestFloorMemory = floorVal
                        LastFloorChangeTime = tick()
                    end
                end
            end
        end)
    end
end)

-- ==========================================
-- LOOP OTOMASI REMOTE 
-- ==========================================

-- 1. Auto Buy Generator (SYARAT ZONA)
task.spawn(function()
    while task.wait(LoopInterval) do
        if AutoBuyGenerator and Remotes and Remotes:FindFirstChild("BuyGenerator") then
            if MaxGeneratorTier > 1 or IsInFeederZone then
                for gen = 1, MaxGeneratorTier do
                    if not AutoBuyGenerator then break end
                    pcall(function() Remotes.BuyGenerator:InvokeServer(gen) end)
                end
            end
        end
    end
end)

-- 2. Auto Upgrade Generator (JEDA ACAK & SYARAT ZONA)
task.spawn(function()
    while true do
        local randomHumanDelay = math.random(40, 100) / 100
        task.wait(randomHumanDelay)
        
        if AutoUpgradeGenerator and Remotes and Remotes:FindFirstChild("UpgradeGenerator") then
            if MaxGeneratorTier > 1 or IsInFeederZone then
                for gen = 1, MaxGeneratorTier do
                    if not AutoUpgradeGenerator then break end
                    pcall(function() Remotes.UpgradeGenerator:InvokeServer(gen) end)
                end
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

-- 5. SMART AUTO REBIRTH
task.spawn(function()
    while task.wait(LoopInterval) do
        if AutoRebirth then
            if TargetRebirthFloor then
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
                            TargetRebirthFloor = nil 
                            HighestFloorMemory = 0
                            LastFloorChangeTime = tick()
                        end
                    end)
                end
            else
                pcall(function()
                    local rebirthEvent = Remotes and Remotes:FindFirstChild("Rebirth")
                    if rebirthEvent then
                        rebirthEvent:InvokeServer()
                        HighestFloorMemory = 0 
                    end
                end)
            end
        end
    end
end)

-- 6. Auto No Thanks
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

-- 7. SMART AUTO TOWER (Elevator + Anti-Stuck)
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

                    if caption and caption.Text then
                        local capText = string.upper(caption.Text)

                        if string.match(capText, "TOWER") then
                            task.wait(TowerDelay) 
                            if AutoTower then
                                if HighestFloorMemory > 0 then
                                    local elevatorEvent = Remotes and Remotes:FindFirstChild("TowerElevator")
                                    if elevatorEvent then
                                        pcall(function() elevatorEvent:InvokeServer(HighestFloorMemory) end)
                                        task.wait(0.2) 
                                    end
                                end

                                local towerStart = Remotes and Remotes:FindFirstChild("TowerStart")
                                if towerStart then 
                                    towerStart:InvokeServer() 
                                    LastFloorChangeTime = tick()
                                end
                            end

                        elseif string.match(capText, "RETREAT") then
                            if (tick() - LastFloorChangeTime) > MaxStuckTime then
                                local surrenderEvent = Remotes and Remotes:FindFirstChild("TowerSurrender")
                                if surrenderEvent then
                                    surrenderEvent:InvokeServer()
                                    LastFloorChangeTime = tick()
                                end
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

Window:AddInput("Batas Maksimal Generator (1-6)", "Ketik 1 - 6 (Def: 1)", function(text)
    local num = tonumber(text)
    if num then
        num = math.floor(num)
        if num >= 1 and num <= 6 then
            MaxGeneratorTier = num
        else
            MaxGeneratorTier = 1
        end
    else
        MaxGeneratorTier = 1
    end
end)

Window:AddToggle("Auto Buy Generator", false, function(state) AutoBuyGenerator = state end)
Window:AddToggle("Auto Upgrade Generator", false, function(state) AutoUpgradeGenerator = state end)
Window:AddToggle("Auto Upgrade Recycler", false, function(state) AutoUpgradeRecycler = state end)
Window:AddToggle("Auto Expand Coop", false, function(state) AutoExpandCoop = state end)
Window:AddToggle("Auto Rebirth (Smart Tracking)", false, function(state) AutoRebirth = state end)
Window:AddToggle("Auto No Thanks (Tower)", false, function(state) AutoNoThanks = state end)

Window:AddInput("Waktu Jeda Makan / Tower Delay", "Angka (Def: 10)", function(text)
    local num = tonumber(text)
    if num then TowerDelay = num else TowerDelay = 10 end
end)

Window:AddInput("Batas Toleransi Macet (Detik)", "Angka (Def: 5)", function(text)
    local num = tonumber(text)
    if num then MaxStuckTime = num else MaxStuckTime = 5 end
end)

Window:AddToggle("Auto Tower (Smart Elevator)", false, function(state) AutoTower = state end)
Window:AddToggle("No Fog (Infinite View)", false, function(state) AutoNoFog = state end)
Window:AddToggle("Anti-Lag (Memory Light)", false, function(state)
    AutoAntiLag = state
    if state then MemoryLightAntiLag() end
end)
