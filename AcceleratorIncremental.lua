local RZY_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Window = RZY_Library:MakeWindow("Accelerator Incremental")

local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

-- [1] Auto Click Brutal
local autoClick = false
Window:AddToggle("Auto Click Brutal", false, function(state)
    autoClick = state
    if state then
        task.spawn(function()
            local clickRemote = Remotes:WaitForChild("IncreaseSpeedBoost")
            while autoClick do
                pcall(function()
                    -- Menggunakan Vektor 2 random untuk mensimulasikan sentuhan di area layar mana saja
                    clickRemote:FireServer(Vector2.new(math.random(100, 800), math.random(100, 600)))
                end)
                task.wait()
            end
        end)
    end
end)

-- [2] Auto Upgrade & Mass Tree (Disatukan)
local autoUpgrade = false
Window:AddToggle("Auto Upgrade & Mass Tree", false, function(state)
    autoUpgrade = state
    if state then
        task.spawn(function()
            local buyRemote = Remotes:WaitForChild("BuyUpgrade")
            
            -- Daftar upgrade berdasarkan path GUI
            local upgradeData = {
                Speed = {"AutoIncrement", "BoostMax", "CompoundingMultiplier", "FlatAddition", "ParticleBulk"},
                Heat = {"AccelerationMultiplier", "AutoIncrement", "HeatAmountToSpeedMultiplier", "PressureAdd", "SpeedAmountToHeatMultiplier"},
                RacePoint = {"Health", "MassMultiplier", "PointMultiplier", "PressureMultiplier", "SpeedMultiplier"},
                Flux = {"BarrierThinning", "Resonance", "SuccessRate"}
            }
            
            while autoUpgrade do
                -- A. Eksekusi Auto Upgrade
                for category, upgrades in pairs(upgradeData) do
                    for _, upgradeName in ipairs(upgrades) do
                        pcall(function()
                            -- Argument 'true' untuk fitur Buy Max
                            buyRemote:FireServer(category, upgradeName, true) 
                        end)
                    end
                end
                
                -- B. Eksekusi Auto MassUpgradeTree
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

-- [3] Auto Prestige Tier
local autoPrestige = false
Window:AddToggle("Auto Prestige Tier", false, function(state)
    autoPrestige = state
    if state then
        task.spawn(function()
            local prestigeRemote = Remotes:WaitForChild("Prestige")
            while autoPrestige do
                pcall(function()
                    prestigeRemote:FireServer("Tier")
                end)
                task.wait(0.1)
            end
        end)
    end
end)
