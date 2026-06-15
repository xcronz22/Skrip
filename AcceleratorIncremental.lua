-- [[ 1. UI INITIALIZATION (Dijalankan paling awal agar panel PASTI muncul) ]] --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local RZY_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Window = RZY_Library:MakeWindow("Accelerator Incremental")

-- [[ 2. DYNAMIC REMOTE FETCHING (Anti-Macet / Decoupled Execution) ]] --
local function GetRemote(name)
    local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("remotes")
    if remotes then
        return remotes:FindFirstChild(name)
    end
    return nil
end

-- [[ 2. UTILITY FUNCTIONS ]] --
local function GetRemote(name)
    return Remotes:FindFirstChild(name)
end

local function StringToNumber(str)
    if not str then return 0 end
    str = tostring(str):gsub("Cost:%s*", ""):gsub(" g", ""):gsub(" G", ""):gsub("°", ""):gsub(",", ""):gsub(" ", "")
    
    local numberPart = string.match(str, "[%d%.]+")
    local suffixPart = string.match(str, "%a+")
    local num = tonumber(numberPart) or 0
    
    if suffixPart then
        suffixPart = string.upper(suffixPart)
        local multipliers = {
            K = 1e3, M = 1e6, B = 1e9, T = 1e12, QD = 1e15, QN = 1e18, SX = 1e21, SP = 1e24, OC = 1e27, NO = 1e30,
            DE = 1e33, UDE = 1e36, DDE = 1e39, TDE = 1e42, QDDE = 1e45, QNDE = 1e48, SXDE = 1e51, SPDE = 1e54, OCDE = 1e57, NODE = 1e60,
            VG = 1e63, UVG = 1e66, DVG = 1e69, TVG = 1e72, QDVG = 1e75, QNVG = 1e78, SXVG = 1e81, SPVG = 1e84, OCVG = 1e87, NOVG = 1e90,
            TG = 1e93, UTG = 1e96, DTG = 1e99, TTG = 1e102, QDTG = 1e105, QNTG = 1e108, SXTG = 1e111, SPTG = 1e114, OCTG = 1e117, NOTG = 1e120,
            QDG = 1e123, UQDG = 1e126, DQDG = 1e129, TQDG = 1e132, QQDG = 1e135, QIDG = 1e138, SXDG = 1e141, SPDG = 1e144, OCDG = 1e147, NODG = 1e150,
            PC = 1e153, UPC = 1e156, DPC = 1e159, TPC = 1e162, QAPC = 1e165, QIPC = 1e168, SXPC = 1e171, SPPC = 1e174, OCPC = 1e177, NOPC = 1e180,
            HX = 1e183, UHX = 1e186, DHX = 1e189, THX = 1e192, QAHX = 1e195, QIHX = 1e198, SXHX = 1e201, SPHX = 1e204, OCHX = 1e207, NOHX = 1e210,
            HP = 1e213, UHP = 1e216, DHP = 1e219, THP = 1e222, QAHP = 1e225, QIHP = 1e228, SXHP = 1e231, SPHP = 1e234, OCHP = 1e237, NOHP = 1e240,
            OG = 1e243, UOG = 1e246, DOG = 1e249, TOG = 1e252, QAOG = 1e255, QIOG = 1e258, SXOG = 1e261, SPOG = 1e264, OCOG = 1e267, NOOG = 1e270,
            N = 1e273, UN = 1e276, DN = 1e279, TN = 1e282, QAN = 1e285, QIN = 1e288, SXN = 1e291, SPN = 1e294, OCN = 1e297, NON = 1e300, CEN = 1e303
        }
        multipliers["QA"] = multipliers.QD
        multipliers["QI"] = multipliers.QN
        
        if multipliers[suffixPart] then
            num = num * multipliers[suffixPart]
        end
    end
    return num
end

-- [[ 4. TOGGLES ]] --

-- [1] Auto Click Brutal (Click + Pressure + Quark)
local autoClick = false
Window:AddToggle("Auto Click Brutal", false, function(state)
    autoClick = state
    if state then
        task.spawn(function()
            while autoClick do
                pcall(function() 
                    local clickRemote = GetRemote("IncreaseSpeedBoost")
                    local pressureRemote = GetRemote("IncreasePressure")
                    local quarkRemote = GetRemote("RollParticle") -- Remote untuk Quark
                    
                    -- Klik
                    if clickRemote then 
                        clickRemote:FireServer(Vector2.new(math.random(100, 800), math.random(100, 600))) 
                    end
                    
                    -- Pressure
                    if pressureRemote then 
                        pressureRemote:FireServer() 
                    end
                    
                    -- Quark
                    if quarkRemote then 
                        quarkRemote:FireServer("Quark") 
                    end
                end)
                
                -- Jika game terasa lag atau remote tidak merespon, 
                -- ganti task.wait() menjadi task.wait(0.05) agar tidak kena limit server
                task.wait() 
            end
        end)
    end
end)

-- [2] Auto Up Speed
local autoUpSpeed = false
Window:AddToggle("Auto Up Speed", false, function(state)
    autoUpSpeed = state
    if state then
        task.spawn(function()
            local upgrades = {"AutoIncrement", "BoostMax", "CompoundingMultiplier", "FlatAddition", "ParticleBulk"}
            while autoUpSpeed do
                local buyRemote = GetRemote("BuyUpgrade")
                if buyRemote then
                    for _, upgradeName in ipairs(upgrades) do
                        pcall(function() buyRemote:FireServer("Speed", upgradeName, true) end)
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

-- [3] Auto Up Heat
local autoUpHeat = false
Window:AddToggle("Auto Up Heat", false, function(state)
    autoUpHeat = state
    if state then
        task.spawn(function()
            local upgrades = {"AccelerationMultiplier", "AutoIncrement", "HeatAmountToSpeedMultiplier", "PressureAdd", "SpeedAmountToHeatMultiplier"}
            while autoUpHeat do
                local buyRemote = GetRemote("BuyUpgrade")
                if buyRemote then
                    for _, upgradeName in ipairs(upgrades) do
                        pcall(function() buyRemote:FireServer("Heat", upgradeName, true) end)
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

-- [4] Auto Up RacePoint
local autoUpRacePoint = false
Window:AddToggle("Auto Up RacePoint", false, function(state)
    autoUpRacePoint = state
    if state then
        task.spawn(function()
            local upgrades = {"Health", "MassMultiplier", "PointMultiplier", "PressureMultiplier", "SpeedMultiplier"}
            while autoUpRacePoint do
                local buyRemote = GetRemote("BuyUpgrade")
                if buyRemote then
                    for _, upgradeName in ipairs(upgrades) do
                        pcall(function() buyRemote:FireServer("RacePoint", upgradeName, true) end)
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

-- [5] Auto Up Flux
local autoUpFlux = false
Window:AddToggle("Auto Up Flux", false, function(state)
    autoUpFlux = state
    if state then
        task.spawn(function()
            local upgrades = {"BarrierThinning", "Resonance", "SuccessRate"}
            while autoUpFlux do
                local buyRemote = GetRemote("BuyUpgrade")
                if buyRemote then
                    for _, upgradeName in ipairs(upgrades) do
                        pcall(function() buyRemote:FireServer("Flux", upgradeName, true) end)
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

-- [6] Auto Up MassUpgradeTree (Sistem Akurat Proteksi Kandungan Teks)
local autoUpMassTree = false
Window:AddToggle("Auto Up MassUpgradeTree", false, function(state)
    autoUpMassTree = state
    if state then
        task.spawn(function()
            while autoUpMassTree do
                pcall(function()
                    local treeFolder = workspace:FindFirstChild("MassUpgradeTree")
                    local massConvert = workspace:FindFirstChild("MassConvert")
                    
                    if treeFolder and massConvert then
                        local currentMass = StringToNumber(massConvert.SurfaceGui.Frame.Mass.Text)
                        
                        for i = 1, 19 do
                            local folder = treeFolder:FindFirstChild(tostring(i))
                            if folder then
                                local main = folder:FindFirstChild("Main")
                                local surfaceGui = main and main:FindFirstChild("SurfaceGui")
                                local frame = surfaceGui and surfaceGui:FindFirstChild("Frame")
                                local costLabel = frame and frame:FindFirstChild("Cost")
                                
                                if costLabel then
                                    local isBlocked = false
                                    for _, child in ipairs(frame:GetChildren()) do
                                        if child:IsA("TextLabel") then
                                            local labelText = string.lower(child.Text)
                                            if string.find(labelText, "max") or string.find(labelText, "unbuy") then
                                                isBlocked = true
                                                break
                                            end
                                        end
                                    end
                                    
                                    if not isBlocked then
                                        local costValue = StringToNumber(costLabel.Text)
                                        if currentMass >= costValue then
                                            local clickDetector = folder:FindFirstChildWhichIsA("ClickDetector", true)
                                            if clickDetector then
                                                fireclickdetector(clickDetector)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
                task.wait(0.1)
            end
        end)
    end
end)

-- [7] Auto Prestige (Tier, Smart Heat, & Smart Mass Syarat 1e23)
local autoPrestige = false
Window:AddToggle("Auto Prestige", false, function(state)
    autoPrestige = state
    if state then
        -- Jalur 1: Prestige TIER
        task.spawn(function()
            while autoPrestige do
                pcall(function()
                    local prestigeRemote = GetRemote("Prestige")
                    local playerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
                    local tierUpBar = playerGui:WaitForChild("TierUpBar", 5)
                    local progressBar = tierUpBar:WaitForChild("ProgressBar", 5)
                    
                    local progressLabel = progressBar.ProgressLabel
                    local tierUpReady = progressBar.TierUpReady
                    
                    local isReadyToTierUp = false
                    if tierUpReady.Visible == true then
                        isReadyToTierUp = true
                    elseif string.find(progressLabel.Text, "100.00%%") or string.find(progressLabel.Text, "100%%") then
                        isReadyToTierUp = true
                    end
                    
                    if isReadyToTierUp and prestigeRemote then prestigeRemote:FireServer("Tier") end
                end)
                task.wait(0.1)
            end
        end)
            
        -- Jalur 2: Prestige HEAT (Hyper Responsive)
        task.spawn(function()
            local lastHeat = 0
            local tickCounter = 0
            while autoPrestige do
                pcall(function()
                    local prestigeRemote = GetRemote("Prestige")
                    local freeze = workspace:FindFirstChild("Freeze")
                    if freeze and prestigeRemote then
                        local heatLabel = freeze.SurfaceGui.Frame.Heat
                        local currentHeat = StringToNumber(heatLabel.Text)
                        
                        if currentHeat >= 0 then
                            tickCounter = tickCounter + 1
                            if tickCounter >= 4 then
                                local gain = currentHeat - lastHeat
                                if lastHeat > 0 and gain < (currentHeat * 0.30) then
                                    prestigeRemote:FireServer("Heat")
                                    lastHeat = 0
                                else
                                    lastHeat = currentHeat
                                end
                                tickCounter = 0
                            end
                        else
                            lastHeat = currentHeat
                            tickCounter = 0
                        end
                    end
                end)
                task.wait(0.05)
            end
        end)

        -- Jalur 3: Prestige MASS (Minimal Syarat 1e23)
        task.spawn(function()
            local lastMass = 0
            local massTickCounter = 0
            while autoPrestige do
                pcall(function()
                    local prestigeRemote = GetRemote("Prestige")
                    local massConvert = workspace:FindFirstChild("MassConvert")
                    if massConvert and prestigeRemote then
                        local massLabel = massConvert.SurfaceGui.Frame.Mass
                        local currentMass = StringToNumber(massLabel.Text)
                        
                        if currentMass >= 0 then
                            massTickCounter = massTickCounter + 1
                            if massTickCounter >= 4 then
                                local gain = currentMass - lastMass
                                if lastMass > 0 and gain < (currentMass * 0.30) then
                                    prestigeRemote:FireServer("Mass")
                                    lastMass = 0
                                else
                                    lastMass = currentMass
                                end
                                massTickCounter = 0
                            end
                        else
                            lastMass = currentMass
                            massTickCounter = 0
                        end
                    end
                end)
                task.wait(0.05)
            end
        end)
    end
end)

-- [8] God Mode Race
local godModeRace = false
Window:AddToggle("God Mode Race", false, function(state)
    godModeRace = state
    if state then
        task.spawn(function()
            while godModeRace do
                pcall(function()
                    local raceMap = workspace:FindFirstChild("RaceMap")
                    if raceMap then
                        for _, obj in pairs(raceMap:GetChildren()) do
                            if obj:IsA("BasePart") then
                                if obj:GetAttribute("Player") == LocalPlayer.Name or obj.Name == LocalPlayer.Name .. " Ball" then
                                    if obj.CanTouch ~= false then 
                                        obj.CanTouch = false 
                                    end
                                end
                            end
                        end
                    end
                end)
                task.wait(0.05)
            end
        end)
    else
        pcall(function()
            local raceMap = workspace:FindFirstChild("RaceMap")
            if raceMap then
                for _, obj in pairs(raceMap:GetChildren()) do
                    if obj:IsA("BasePart") then
                        if obj:GetAttribute("Player") == LocalPlayer.Name or obj.Name == LocalPlayer.Name .. " Ball" then
                            obj.CanTouch = true
                        end
                    end
                end
            end
        end)
    end
end)
