local RZY_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Window = RZY_Library:MakeWindow("Accelerator Incremental")

local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local LocalPlayer = game:GetService("Players").LocalPlayer

-- Fungsi Pengubah String ke Number (Untuk Smart Check Heat)
local function StringToNumber(str)
    if not str then return 0 end
    -- Hapus spasi, koma, dan simbol derajat
    str = tostring(str):gsub("°", ""):gsub(",", ""):gsub(" ", "")
    
    local numberPart = string.match(str, "[%d%.]+")
    local suffixPart = string.match(str, "%a+")
    local num = tonumber(numberPart) or 0
    
    if suffixPart then
        suffixPart = string.upper(suffixPart)
        -- Daftar pengali suffix standar incremental
        local multipliers = {
            K = 1e3, M = 1e6, B = 1e9, T = 1e12,
            QA = 1e15, QI = 1e18, SX = 1e21, SP = 1e24,
            OC = 1e27, NO = 1e30, DC = 1e33
        }
        if multipliers[suffixPart] then
            num = num * multipliers[suffixPart]
        end
    end
    return num
end

-- [1] Auto Click Brutal (Speed Boost & Pressure)
local autoClick = false
Window:AddToggle("Auto Click Brutal", false, function(state)
    autoClick = state
    if state then
        task.spawn(function()
            local clickRemote = Remotes:WaitForChild("IncreaseSpeedBoost")
            local pressureRemote = Remotes:WaitForChild("IncreasePressure")
            
            while autoClick do
                pcall(function()
                    -- Simulasi sentuhan acak untuk Speed Boost
                    clickRemote:FireServer(Vector2.new(math.random(100, 800), math.random(100, 600)))
                end)
                
                pcall(function()
                    -- Eksekusi Increase Pressure
                    pressureRemote:FireServer()
                end)
                
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
            local buyRemote = Remotes:WaitForChild("BuyUpgrade")
            local upgrades = {"AutoIncrement", "BoostMax", "CompoundingMultiplier", "FlatAddition", "ParticleBulk"}
            while autoUpSpeed do
                for _, upgradeName in ipairs(upgrades) do
                    pcall(function() buyRemote:FireServer("Speed", upgradeName, true) end)
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
            local buyRemote = Remotes:WaitForChild("BuyUpgrade")
            local upgrades = {"AccelerationMultiplier", "AutoIncrement", "HeatAmountToSpeedMultiplier", "PressureAdd", "SpeedAmountToHeatMultiplier"}
            while autoUpHeat do
                for _, upgradeName in ipairs(upgrades) do
                    pcall(function() buyRemote:FireServer("Heat", upgradeName, true) end)
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
            local buyRemote = Remotes:WaitForChild("BuyUpgrade")
            local upgrades = {"Health", "MassMultiplier", "PointMultiplier", "PressureMultiplier", "SpeedMultiplier"}
            while autoUpRacePoint do
                for _, upgradeName in ipairs(upgrades) do
                    pcall(function() buyRemote:FireServer("RacePoint", upgradeName, true) end)
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
            local buyRemote = Remotes:WaitForChild("BuyUpgrade")
            local upgrades = {"BarrierThinning", "Resonance", "SuccessRate"}
            while autoUpFlux do
                for _, upgradeName in ipairs(upgrades) do
                    pcall(function() buyRemote:FireServer("Flux", upgradeName, true) end)
                end
                task.wait(0.1)
            end
        end)
    end
end)

-- [6] Auto Up MassUpgradeTree
local autoUpMassTree = false
Window:AddToggle("Auto Up MassUpgradeTree", false, function(state)
    autoUpMassTree = state
    if state then
        task.spawn(function()
            while autoUpMassTree do
                pcall(function()
                    local treeFolder = workspace:FindFirstChild("MassUpgradeTree")
                    if treeFolder then
                        for _, v in pairs(treeFolder:GetDescendants()) do
                            if v:IsA("ClickDetector") then
                                fireclickdetector(v)
                            end
                        end
                    end
                end)
                task.wait(0.1)
            end
        end)
    end
end)

-- [7] Auto Prestige (Tier, Smart Heat, & Mass)
local autoPrestige = false
Window:AddToggle("Auto Prestige", false, function(state)
    autoPrestige = state
    if state then
        local prestigeRemote = Remotes:WaitForChild("Prestige")
        
        -- Jalur 1: Prestige TIER (Smart Check 100%)
        task.spawn(function()
            while autoPrestige do
                pcall(function()
                    local progressBar = LocalPlayer.PlayerGui.TierUpBar.ProgressBar
                    local progressLabel = progressBar.ProgressLabel
                    local tierUpReady = progressBar.TierUpReady
                    
                    local isReadyToTierUp = false
                    
                    if tierUpReady.Visible == true then
                        isReadyToTierUp = true
                    elseif string.find(progressLabel.Text, "100.00%%") or string.find(progressLabel.Text, "100%%") then
                        isReadyToTierUp = true
                    end
                    
                    if isReadyToTierUp then
                        prestigeRemote:FireServer("Tier")
                    end
                end)
                task.wait(0.1)
            end
        end)
        
        -- Jalur 2: Prestige HEAT (Smart Check Melambat)
        task.spawn(function()
            local lastHeat = 0
            local maxGain = 0
            
            while autoPrestige do
                pcall(function()
                    local heatLabel = workspace.Freeze.SurfaceGui.Frame.Heat
                    local currentHeat = StringToNumber(heatLabel.Text)
                    
                    if currentHeat >= 10000 then -- Syarat minimal 10k
                        local gain = currentHeat - lastHeat
                        
                        -- Simpan rekor penambahan (Peak)
                        if gain > maxGain then
                            maxGain = gain
                        end
                        
                        -- Kalkulasi kondisi "Melambat"
                        -- Kondisi 1: Laju per detiknya anjlok di bawah 40% dari rekor tertinggi
                        -- Kondisi 2: Kenaikan per detiknya sangat kecil (di bawah 2% dari Heat keseluruhan)
                        local isSlowingDown = false
                        if maxGain > 0 and gain < (maxGain * 0.4) then
                            isSlowingDown = true
                        elseif gain < (currentHeat * 0.02) then
                            isSlowingDown = true
                        end
                        
                        if isSlowingDown then
                            prestigeRemote:FireServer("Heat")
                            -- Reset riwayat kalkulasi setelah sukses prestige
                            lastHeat = 0
                            maxGain = 0
                            task.wait(1.5) -- Jeda lebih lama agar tidak tembak beruntun saat loading game
                        else
                            lastHeat = currentHeat -- Simpan untuk perbandingan berikutnya
                        end
                    else
                        -- Reset memori penambahan jika berada di bawah 10k (baru selesai prestige)
                        lastHeat = currentHeat
                        maxGain = 0
                    end
                end)
                task.wait(0.5) -- Pengecekan interval 0.5 detik untuk menangkap selisih penambahan
            end
        end)
        
        -- Jalur 3: Prestige MASS
        task.spawn(function()
            while autoPrestige do
                pcall(function()
                    prestigeRemote:FireServer("Mass")
                end)
                task.wait(0.1)
            end
        end)
    end
end)
