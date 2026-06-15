local RZY_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Window = RZY_Library:MakeWindow("Accelerator Incremental")

local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local LocalPlayer = game:GetService("Players").LocalPlayer

-- Fungsi Pengubah String ke Number dengan Kamus Lengkap sampai Centillion
local function StringToNumber(str)
    if not str then return 0 end
    -- Hapus spasi, koma, dan simbol derajat
    str = tostring(str):gsub("°", ""):gsub(",", ""):gsub(" ", "")
    
    local numberPart = string.match(str, "[%d%.]+")
    local suffixPart = string.match(str, "%a+")
    local num = tonumber(numberPart) or 0
    
    if suffixPart then
        suffixPart = string.upper(suffixPart)
        -- Kamus Pengali Lengkap (Standar Incremental Game)
        local multipliers = {
            K   = 1e3,   M   = 1e6,   B   = 1e9,   T   = 1e12,  -- Thousand, Million, Billion, Trillion
            QA  = 1e15,  QI  = 1e18,  SX  = 1e21,  SP  = 1e24,  -- Quadrillion, Quintillion, Sextillion, Septillion
            OC  = 1e27,  NO  = 1e30,  DC  = 1e33,  UDC = 1e36,  -- Octillion, Nonillion, Decillion, Undecillion
            DDC = 1e39,  TDC = 1e42,  QADC= 1e45,  QIDC= 1e48,  -- Duodecillion, Tredecillion, Quattuordecillion, Quindecillion
            SXDC= 1e51,  SPDC= 1e54,  OCDC= 1e57,  NODC= 1e60,  -- Sexdecillion, Septendecillion, Octodecillion, Novemdecillion
            VG  = 1e63,  UVG = 1e66,  DVG = 1e69,  TVG = 1e72,  -- Vigintillion, Unvigintillion, Duovigintillion, Tresvigintillion
            QAVG= 1e75,  QIVG= 1e78,  SXVG= 1e81,  SPVG= 1e84,  -- Quattuorvigintillion, Quinvigintillion, Sexvigintillion, Septenvigintillion
            OCVG= 1e87,  NOVG= 1e90,  TG  = 1e93,  UTG = 1e96,  -- Octovigintillion, Novemvigintillion, Trigintillion, Untrigintillion
            DTG = 1e99,  TTG = 1e102, QATG= 1e105, QITG= 1e108, -- Duotrigintillion, Trestrigintillion, Quattuortrigintillion, Quintrigintillion
            SXTG= 1e111, SPTG= 1e114, OCTG= 1e117, NOTG= 1e120, -- Sextrigintillion, Septentrigintillion, Octotrigintillion, Novemtrigintillion
            QDG = 1e123, UQDG= 1e126, DQDG= 1e129, TQDG= 1e132, -- Quadragintillion, Unquadragintillion, Duoquadragintillion, Tresquadragintillion
            QQDG= 1e135, QIDG= 1e138, SXDG= 1e141, SPDG= 1e144, -- Quattuorquadragintillion, Quinquadragintillion, Sexquadragintillion, Septenquadragintillion
            OCDG= 1e147, NODG= 1e150, PC  = 1e153, UPC = 1e156, -- Octoquadragintillion, Novemquadragintillion, Quinquagintillion, Unquinquagintillion
            DPC = 1e159, TPC = 1e162, QAPC= 1e165, QIPC= 1e168, -- Duoquinquagintillion, Tresquinquagintillion, Quattuorquinquagintillion, Quinquinquagintillion
            SXPC= 1e171, SPPC= 1e174, OCPC= 1e177, NOPC= 1e180, -- Sexquinquagintillion, Septenquinquagintillion, Octoquinquagintillion, Novemquinquagintillion
            HX  = 1e183, UHX = 1e186, DHX = 1e189, THX = 1e192, -- Sexagintillion, Unsexagintillion, Duosexagintillion, Tresexagintillion
            QAHX= 1e195, QIHX= 1e198, SXHX= 1e201, SPHX= 1e204, -- Quattuorsexagintillion, Quinsexagintillion, Sexsexagintillion, Septensexagintillion
            OCHX= 1e207, NOHX= 1e210, HP  = 1e213, UHP = 1e216, -- Octosexagintillion, Novemsexagintillion, Septuagintillion, Unseptuagintillion
            DHP = 1e219, THP = 1e222, QAHP= 1e225, QIHP= 1e228, -- Duoseptuagintillion, Treseptuagintillion, Quattuorseptuagintillion, Quinseptuagintillion
            SXHP= 1e231, SPHP= 1e234, OCHP= 1e237, NOHP= 1e240, -- Sexseptuagintillion, Septenseptuagintillion, Octoseptuagintillion, Novemseptuagintillion
            OG  = 1e243, UOG = 1e246, DOG = 1e249, TOG = 1e252, -- Octogintillion, Unoctogintillion, Duooctogintillion, Tresoctogintillion
            QAOG= 1e255, QIOG= 1e258, SXOG= 1e261, SPOG= 1e264, -- Quattuoroctogintillion, Quinoctogintillion, Sexoctogintillion, Septenoctogintillion
            OCOG= 1e267, NOOG= 1e270, N   = 1e273, UN  = 1e276, -- Octooctogintillion, Novemoctogintillion, Nonagintillion, Unnonagintillion
            DN  = 1e279, TN  = 1e282, QAN = 1e285, QIN = 1e288, -- Duononagintillion, Trenonagintillion, Quattuornonagintillion, Quinnonagintillion
            SXN = 1e291, SPN = 1e294, OCN = 1e297, NON = 1e300, -- Sexnonagintillion, Septennonagintillion, Octononagintillion, Novemnonagintillion
            CEN = 1e303                                         -- Centillion
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

-- [8] God Mode Race (Tembus Rintangan)
local godModeRace = false
Window:AddToggle("God Mode Race", false, function(state)
    godModeRace = state
    if state then
        task.spawn(function()
            while godModeRace do
                pcall(function()
                    -- Mencari folder Obstacles di dalam RaceMap
                    local raceMap = workspace:FindFirstChild("RaceMap")
                    if raceMap then
                        local obstacles = raceMap:FindFirstChild("Obstacles")
                        if obstacles then
                            -- Looping semua rintangan di dalamnya
                            for _, obj in pairs(obstacles:GetDescendants()) do
                                if obj:IsA("BasePart") and obj.CanCollide then
                                    obj.CanCollide = false
                                    
                                    -- Opsional: Kita buat rintangannya agak transparan (kaca)
                                    -- agar kamu tahu kalau rintangan itu sudah "jinak" dan bisa ditembus
                                    obj.Transparency = 0.6 
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
