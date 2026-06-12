local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

local FILE_NAME = "LemonConfigV56.json"

-- ==========================================
-- 0. DEFAULT CONFIGURATION & STORAGE
-- ==========================================
local Toggles = {
    SilentHarvest = false,
    AutoHarvest = false,
    AutoDrop = false,
    AutoBuy = false,
    AutoUpgrade = false,
    AutoRebirth = false,
    RebirthTP = true,
    AutoEvolve = false,
    AutoAscend = false
}

local TargetBuyMode = "V1"
local BuyMethod = "Sequential"
local RebirthMode = "Multiplier"
local RemoteInvokeDelay = 0.5
local RebirthValue = 2
local SmartMultiplier = 2
local LastRebirthTime = 0
local UpgradeRemotes = {}
local ToggleObjects = {}

-- Reference elemen Input UI untuk kebutuhan sinkronisasi Load Config
local RebirthInput

-- ==========================================
-- 1. IDENTIFIKASI PENGALI (KATA PENUH & SINGKATAN IN-GAME)
-- ==========================================
local Multipliers = {
    -- [KATA PENUH ASLI BAWAAN SKRIP]
    ["thousand"] = 1e3, ["million"] = 1e6, ["billion"] = 1e9, ["trillion"] = 1e12,
    ["quadrillion"] = 1e15, ["quintillion"] = 1e18, ["sextillion"] = 1e21, ["septillion"] = 1e24,
    ["octillion"] = 1e27, ["nonillion"] = 1e30, ["decillion"] = 1e33, ["undecillion"] = 1e36,
    ["duodecillion"] = 1e39, ["tredecillion"] = 1e42, ["tresdecillion"] = 1e42, ["quattuordecillion"] = 1e45,
    ["quindecillion"] = 1e48, ["sexdecillion"] = 1e51, ["septendecillion"] = 1e54, ["octodecillion"] = 1e57,
    ["novemdecillion"] = 1e60, ["vigintillion"] = 1e63, ["unvigintillion"] = 1e66, ["duovigintillion"] = 1e69,
    ["trevigintillion"] = 1e72, ["tresvigintillion"] = 1e72, ["quattuorvigintillion"] = 1e75, ["quinvigintillion"] = 1e78,
    ["sexvigintillion"] = 1e81, ["septenvigintillion"] = 1e84, ["octovigintillion"] = 1e87, ["novemvigintillion"] = 1e90,
    ["trigintillion"] = 1e93, ["untrigintillion"] = 1e96, ["duotrigintillion"] = 1e99, ["tretrigintillion"] = 1e102,
    ["trestrigintillion"] = 1e102, ["quattuortrigintillion"] = 1e105, ["quintrigintillion"] = 1e108, ["sextrigintillion"] = 1e111,
    ["septentrigintillion"] = 1e114, ["octotrigintillion"] = 1e117, ["novemtrigintillion"] = 1e120, ["quadragintillion"] = 1e123,
    ["unquadragintillion"] = 1e126, ["duoquadragintillion"] = 1e129, ["trequadragintillion"] = 1e132, ["tresquadragintillion"] = 1e132,
    ["quattuorquadragintillion"] = 1e135, ["quinquadragintillion"] = 1e138, ["sexquadragintillion"] = 1e141, ["septenquadragintillion"] = 1e144,
    ["octoquadragintillion"] = 1e147, ["novemquadragintillion"] = 1e150, ["quinquagintillion"] = 1e153, ["unquinquagintillion"] = 1e156,
    ["duoquinquagintillion"] = 1e159, ["trequinquagintillion"] = 1e162, ["tresquinquagintillion"] = 1e162, ["quattuorquinquagintillion"] = 1e165,
    ["quinquinquagintillion"] = 1e168, ["sexquinquagintillion"] = 1e171, ["septenquinquagintillion"] = 1e174, ["octoquinquagintillion"] = 1e177,
    ["novemquinquagintillion"] = 1e180, ["sexagintillion"] = 1e183, ["unsexagintillion"] = 1e186, ["duosexagintillion"] = 1e189,
    ["tresexagintillion"] = 1e192, ["tressexagintillion"] = 1e192, ["quattuorsexagintillion"] = 1e195, ["quinsexagintillion"] = 1e198,
    ["sexsexagintillion"] = 1e201, ["septensexagintillion"] = 1e204, ["octosexagintillion"] = 1e207, ["novemsexagintillion"] = 1e210,
    ["septuagintillion"] = 1e213, ["unseptuagintillion"] = 1e216, ["duoseptuagintillion"] = 1e219, ["treseptuagintillion"] = 1e222,
    ["tresseptuagintillion"] = 1e222, ["quattuorseptuagintillion"] = 1e225, ["quinseptuagintillion"] = 1e228, ["sexseptuagintillion"] = 1e231,
    ["septenseptuagintillion"] = 1e234, ["octoseptuagintillion"] = 1e237, ["novemseptuagintillion"] = 1e240, ["octogintillion"] = 1e243,
    ["unoctogintillion"] = 1e246, ["duooctogintillion"] = 1e249, ["treoctogintillion"] = 1e252, ["tresoctogintillion"] = 1e252,
    ["quattuoroctogintillion"] = 1e255, ["quinoctogintillion"] = 1e258, ["sexoctogintillion"] = 1e261, ["septenoctogintillion"] = 1e264,
    ["octooctogintillion"] = 1e267, ["novemoctogintillion"] = 1e270, ["nonagintillion"] = 1e273, ["unnonagintillion"] = 1e276,
    ["duononagintillion"] = 1e279, ["trenonagintillion"] = 1e282, ["tresnonagintillion"] = 1e282, ["quattuornonagintillion"] = 1e285,
    ["quinnonagintillion"] = 1e288, ["sexnonagintillion"] = 1e291, ["septennonagintillion"] = 1e294, ["octononagintillion"] = 1e297,
    ["novemnonagintillion"] = 1e300, ["centillion"] = 1e303,

    -- =======================================================
    -- [SINGKATAN KHUSUS LEADERSTATS (PREFIX+SUFFIX PATTERN)]
    -- =======================================================
    ["k"] = 1e3, ["m"] = 1e6, ["b"] = 1e9, ["t"] = 1e12,
    ["qd"] = 1e15, ["qn"] = 1e18, ["sx"] = 1e21, ["sp"] = 1e24, ["o"] = 1e27, ["n"] = 1e30,
    
    -- Decillions (Sufiks: de)
    ["de"] = 1e33, ["ude"] = 1e36, ["dde"] = 1e39, ["tde"] = 1e42, ["qtde"] = 1e45,
    ["qnde"] = 1e48, ["sxde"] = 1e51, ["spde"] = 1e54, ["ode"] = 1e57, ["nde"] = 1e60,
    
    -- Vigintillions (Sufiks: vg)
    ["vg"] = 1e63, ["uvg"] = 1e66, ["dvg"] = 1e69, ["tvg"] = 1e72, ["qtvg"] = 1e75,
    ["qnvg"] = 1e78, ["sxvg"] = 1e81, ["spvg"] = 1e84, ["ovg"] = 1e87, ["nvg"] = 1e90,
    
    -- Trigintillions (Sufiks: tg)
    ["tg"] = 1e93, ["utg"] = 1e96, ["dtg"] = 1e99, ["ttg"] = 1e102, ["qttg"] = 1e105,
    ["qntg"] = 1e108, ["sxtg"] = 1e111, ["sptg"] = 1e114, ["otg"] = 1e117, ["ntg"] = 1e120,
    
    -- Quadragintillions (Sufiks: qdg)
    ["qdg"] = 1e123, ["uqdg"] = 1e126, ["dqdg"] = 1e129, ["tqdg"] = 1e132, ["qtqdg"] = 1e135,
    ["qnqdg"] = 1e138, ["sxqdg"] = 1e141, ["spqdg"] = 1e144, ["oqdg"] = 1e147, ["nqdg"] = 1e150,
    
    -- Quinquagintillions (Sufiks: qng)
    ["qng"] = 1e153, ["uqng"] = 1e156, ["dqng"] = 1e159, ["tqng"] = 1e162, ["qtqng"] = 1e165,
    ["qnqng"] = 1e168, ["sxqng"] = 1e171, ["spqng"] = 1e174, ["oqng"] = 1e177, ["nqng"] = 1e180,
    
    -- Sexagintillions (Sufiks: sxg)
    ["sxg"] = 1e183, ["usxg"] = 1e186, ["dsxg"] = 1e189, ["tsxg"] = 1e192, ["qtsxg"] = 1e195,
    ["qnsxg"] = 1e198, ["sxsxg"] = 1e201, ["spsxg"] = 1e204, ["osxg"] = 1e207, ["nsxg"] = 1e210,
    
    -- Septuagintillions (Sufiks: spg)
    ["spg"] = 1e213, ["uspg"] = 1e216, ["dspg"] = 1e219, ["tspg"] = 1e222, ["qtspg"] = 1e225,
    ["qnspg"] = 1e228, ["sxspg"] = 1e231, ["spspg"] = 1e234, ["ospg"] = 1e237, ["nspg"] = 1e240,
    
    -- Octogintillions (Sufiks: og)
    ["og"] = 1e243, ["uog"] = 1e246, ["dog"] = 1e249, ["tog"] = 1e252, ["qtog"] = 1e255,
    ["qnog"] = 1e258, ["sxog"] = 1e261, ["spog"] = 1e264, ["oog"] = 1e267, ["nvog"] = 1e270,
    
    -- Nonagintillions (Sufiks: nog) -> Seperti contohmu: Tnog, Qtnog
    ["nog"] = 1e273, ["unog"] = 1e276, ["dnog"] = 1e279, ["tnog"] = 1e282, ["qtnog"] = 1e285,
    ["qnnog"] = 1e288, ["sxnog"] = 1e291, ["spnog"] = 1e294, ["onog"] = 1e297, ["nnog"] = 1e300,
    
    ["c"] = 1e303, ["ce"] = 1e303
}

local function parseStringToNumber(textStr)
    if not textStr or textStr == "" then return 0 end
    local clean = string.lower(textStr):gsub("[$,%s]", "")
    
    local num, suffix = string.match(clean, "([%d%.]+)(%a+)")
    if num and suffix and Multipliers[suffix] then
        return tonumber(num) * Multipliers[suffix]
    end
    
    return tonumber(clean) or 0
end

-- SAVE CONFIG
local function SaveConfig()
    local configData = {
        Toggles = Toggles,
        RebirthMode = RebirthMode,
        RebirthValue = RebirthValue,
    }
    pcall(function()
        if writefile then
            writefile(FILE_NAME, HttpService:JSONEncode(configData))
        end
    end)
end

-- LOAD CONFIG
local function LoadConfig()
    pcall(function()
        if isfile and readfile and isfile(FILE_NAME) then
            local decoded = HttpService:JSONDecode(readfile(FILE_NAME))
            if decoded then
                if decoded.Toggles then
                    for k, v in pairs(decoded.Toggles) do 
                        Toggles[k] = v 
                        if ToggleObjects[k] then
                            ToggleObjects[k]:Set(v)
                        end
                    end
                end
                
                if decoded.RebirthMode then RebirthMode = decoded.RebirthMode end
                if decoded.RebirthValue then RebirthValue = decoded.RebirthValue end
                
                if RebirthInput and RebirthInput.Set then
                    if RebirthMode == "Smart" then
                        RebirthInput:Set("Smart")
                    elseif RebirthMode == "Multiplier" then
                        RebirthInput:Set(RebirthValue .. "x")
                    else
                        RebirthInput:Set(tostring(RebirthValue))
                    end
                end
            end
        end
    end)
end

-- CLEAN AND PARSE
local function CleanAndParse(textStr)
    if not textStr or textStr == "" then return 0, 0 end
    local clean = string.lower(textStr):gsub("[$,%s]", "")
    
    local base, exp = string.match(clean, "([%d%.]+)x10%^(%d+)")
    if not base then base, exp = string.match(clean, "([%d%.]+)%^(%d+)") end
    if base and exp then return tonumber(base), tonumber(exp) end
    
    local num, suffix = string.match(clean, "([%d%.]+)(%a+)")
    if num and suffix and Multipliers[suffix] then
        local realValue = tonumber(num) * Multipliers[suffix]
        local log10 = math.log10(realValue)
        local e = math.floor(log10)
        local b = realValue / (10^e)
        return b, e
    end
    
    local plainNum = tonumber(clean:match("[%d%.]+")) or 0
    if plainNum > 0 then
        local e = math.floor(math.log10(plainNum))
        local b = plainNum / (10^e)
        return b, e
    end
    return 0, 0
end

local function IsPotentialEnough(basePot, expPot, baseCur, expCur, targetMultiplier)
    local targetBase = baseCur * targetMultiplier
    local targetExp = expCur
    
    while targetBase >= 10 do
        targetBase = targetBase / 10
        targetExp = targetExp + 1
    end
    
    if expPot > targetExp then return true end
    if expPot == targetExp and basePot >= targetBase then return true end
    return false
end

-- MENCARI TYCOON OTOMATIS
local function GetMyTycoon()
    local foundTycoon = nil
    pcall(function()
        for i = 1, 12 do
            local tycoon = Workspace:FindFirstChild("Tycoon" .. i)
            if tycoon then
                local owner = tycoon:FindFirstChild("Owner")
                if owner and (tostring(owner.Value) == LocalPlayer.Name or owner.Value == LocalPlayer) then
                    foundTycoon = tycoon
                end
            end
        end
    end)
    return foundTycoon
end

local function RefreshUpgradeRemotes()
    pcall(function()
        local MyTycoon = GetMyTycoon()
        if MyTycoon and MyTycoon:FindFirstChild("Purchases") then
            local tempTable = {}
            for _, desc in pairs(MyTycoon.Purchases:GetDescendants()) do
                if desc:IsA("RemoteFunction") and desc.Name == "Upgrade" then
                    table.insert(tempTable, desc)
                end
            end
            UpgradeRemotes = tempTable
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function() UpgradeRemotes = {} end)

-- ==========================================
-- 2. TAP FUNCTIONS (CASHVINE & DOORS)
-- ==========================================
local function TapCollectCashvine()
    pcall(function()
        local char = LocalPlayer.Character
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChild("Humanoid")
        if not rootPart or not humanoid then return end
        
        local sewer = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Sewer")
        local cashVineFolder = sewer and sewer:FindFirstChild("CashVine")
        local targetPrompt = cashVineFolder and cashVineFolder:FindFirstChild("Prompt", true)
        local targetPart = targetPrompt and targetPrompt.Parent and targetPrompt.Parent.Parent
        
        if targetPrompt and targetPart and targetPart:IsA("BasePart") then
            local originalCFrame = rootPart.CFrame
            humanoid.PlatformStand = true
            rootPart.CFrame = targetPart.CFrame * CFrame.new(0, 3, 0)
            task.wait(0.15)
            fireproximityprompt(targetPrompt)
            task.wait(0.15)
            rootPart.CFrame = originalCFrame
            task.wait(0.1)
            humanoid.PlatformStand = false
        end
    end)
end

local function TapOpenAllDoors()
    pcall(function()
        local sewer = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Sewer")
        if sewer then
            local colors = {"Blue", "Green", "Purple", "Red"}
            for _, color in ipairs(colors) do
                local doorFolder = sewer:FindFirstChild("Doors" .. color)
                if doorFolder then
                    local lever = doorFolder:FindFirstChild("Lever (" .. color .. ")")
                    if lever then
                        local rootPart = lever:FindFirstChild("Root")
                        if rootPart then
                            local attach = rootPart:FindFirstChild("Attachment")
                            if attach then
                                local prompt = attach:FindFirstChild("PullPrompt")
                                if prompt and prompt:IsA("ProximityPrompt") then
                                    fireproximityprompt(prompt)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function TapAutoSewer()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local sewer = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Sewer")
    if not sewer then return end

    pcall(function()
        local args = {"InvestorsRevealed", true}
        game:GetService("ReplicatedStorage"):WaitForChild("Core"):WaitForChild("PlayerSettings"):WaitForChild("Set"):FireServer(unpack(args))
    end)

    pcall(function()
        local alienFolder = sewer:FindFirstChild("SewerAlien")
        if alienFolder then
            local trig = alienFolder:FindFirstChild("Trigger")
            if trig and trig:IsA("RemoteFunction") then trig:InvokeServer() end
            local alien = alienFolder:FindFirstChild("Alien")
            if alien then
                local alienRoot = alien:FindFirstChild("HumanoidRootPart")
                if alienRoot then
                    local talkPrompt = alienRoot:FindFirstChild("Prompt")
                    if talkPrompt and talkPrompt:IsA("ProximityPrompt") then fireproximityprompt(talkPrompt) end
                end
            end
            local ufoKey = alienFolder:FindFirstChild("UFOKey")
            if ufoKey then
                local ti = ufoKey:FindFirstChild("TouchInterest")
                if ti then
                    firetouchinterest(root, ufoKey, 0)
                    firetouchinterest(root, ufoKey, 1)
                end
                local coll = ufoKey:FindFirstChild("Collected")
                if coll and coll:IsA("RemoteEvent") then coll:FireServer() end
            end
        end
        local vineUnlock = sewer:FindFirstChild("CashVine") and sewer.CashVine:FindFirstChild("VineDoor") and sewer.CashVine.VineDoor:FindFirstChild("Door") and sewer.CashVine.VineDoor.Door:FindFirstChild("Unlock")
        if vineUnlock and vineUnlock:IsA("RemoteFunction") then vineUnlock:InvokeServer() end
    end)

    pcall(function()
        local doorsGreen = sewer:FindFirstChild("DoorsGreen")
        if doorsGreen then
            for _, desc in pairs(doorsGreen:GetDescendants()) do
                if desc:IsA("Humanoid") then
                    local alienModel = desc.Parent
                    local alienRoot = alienModel:FindFirstChild("HumanoidRootPart")
                    if alienRoot then
                        root.CFrame = alienRoot.CFrame
                        task.wait(0.5)
                    end
                    local prompt = alienModel:FindFirstChild("ListenPrompt", true) or alienModel:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt then 
                        fireproximityprompt(prompt)
                        task.wait(10) 
                    end
                    break 
                end
            end
        end
    end)

    pcall(function()
        local cvFolder = sewer:FindFirstChild("CashVine")
        if cvFolder then
            local vineKey = cvFolder:FindFirstChild("VineKey")
            if vineKey then
                local ti = vineKey:FindFirstChild("TouchInterest")
                if ti then
                    firetouchinterest(root, vineKey, 0)
                    firetouchinterest(root, vineKey, 1)
                end
                local coll = vineKey:FindFirstChild("Collected")
                if coll and coll:IsA("RemoteEvent") then coll:FireServer() end
            end
            local unlock = cvFolder:FindFirstChild("VineDoor") and cvFolder.VineDoor:FindFirstChild("Door") and cvFolder.VineDoor.Door:FindFirstChild("Unlock")
            if unlock and unlock:IsA("RemoteFunction") then unlock:InvokeServer() end
        end
        task.wait(10)
    end)

    pcall(function()
        local bo = sewer:FindFirstChild("Bo")
        local promptFolder = bo and bo:FindFirstChild("Prompt")
        local thePrompt = promptFolder and promptFolder:FindFirstChild("Prompt")
        if thePrompt and thePrompt:IsA("ProximityPrompt") then fireproximityprompt(thePrompt) end
    end)
end

-- UNLOCK POWERS SECARA INSTAN
local function TapUnlockPowers()
    pcall(function()
        local MyTycoon = GetMyTycoon()
        if MyTycoon then
            local permFolder = MyTycoon:FindFirstChild("Values") and MyTycoon.Values:FindFirstChild("Powers") and MyTycoon.Values.Powers:FindFirstChild("Permanent")
            if permFolder then
                permFolder:SetAttribute("BuyNext", 1)
                permFolder:SetAttribute("ClickFruitValue", 3)
                permFolder:SetAttribute("Manage", 1)
                permFolder:SetAttribute("UpgradeStack", 4)
                permFolder:SetAttribute("WalkSpeed", 4)
            end
        end
    end)
end

-- ==========================================
-- 3. UI GENERATION
-- ==========================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()

-- Menggunakan nama string bersih untuk menghindari encoding error
local Window = Library:MakeWindow("Sell Lemons")

ToggleObjects.SilentHarvest = Window:AddToggle("Silent Harvest", false, function(Value) Toggles.SilentHarvest = Value end)
ToggleObjects.AutoHarvest = Window:AddToggle("Auto Harvest Lemons (TP)", false, function(Value)
    Toggles.AutoHarvest = Value
    if not Value then
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.PlatformStand = false
            end
        end)
    end
end)

ToggleObjects.AutoDrop = Window:AddToggle("Auto Collect Drops", false, function(Value) Toggles.AutoDrop = Value end)

-- =======================================================
-- SISTEM INVISIBLE BARU (ANTI LAG & LEBIH RESPONSIF)
-- =======================================================
local InvisibleConnection = nil
local pendingInvisible = {}
local processingInvisible = false

local function MakeInvisible(desc)
    if desc:IsA("BasePart") then
        local isButton = desc:FindFirstChild("TouchInterest") or desc:FindFirstChildWhichIsA("TouchTransmitter")
        if not isButton and desc.Transparency < 1 then
            desc:SetAttribute("OriTrans", desc.Transparency)
            desc:SetAttribute("OriMat", desc.Material.Name)
            
            desc.Transparency = 1
            desc.CastShadow = false
            desc.Material = Enum.Material.SmoothPlastic
            
            for _, effect in ipairs(desc:GetChildren()) do
                if effect:IsA("Texture") or effect:IsA("Decal") then effect:Destroy() end
            end
        end
    end
end

ToggleObjects.AutoBuy = Window:AddToggle("Auto Buy Buttons", false, function(Value) 
    Toggles.AutoBuy = Value 
    local MyTycoon = GetMyTycoon()
    
    if Value then
        if MyTycoon then
            -- 1. Sembunyikan bangunan yang SUDAH ADA
            for _, desc in ipairs(MyTycoon:GetDescendants()) do
                MakeInvisible(desc)
            end
            
            -- 2. Sistem Batching (Mencegah Lag FPS Drop!)
            InvisibleConnection = MyTycoon.DescendantAdded:Connect(function(desc)
                if not Toggles.AutoBuy then return end
                table.insert(pendingInvisible, desc)
                
                -- Proses antrean secara massal tiap 0.1 detik (Cuma pakai 1 thread)
                if not processingInvisible then
                    processingInvisible = true
                    task.delay(0.1, function()
                        for _, part in ipairs(pendingInvisible) do
                            pcall(function() MakeInvisible(part) end)
                        end
                        table.clear(pendingInvisible)
                        processingInvisible = false
                    end)
                end
            end)
        end
    else
        if InvisibleConnection then
            InvisibleConnection:Disconnect()
            InvisibleConnection = nil
        end
        table.clear(pendingInvisible)
        processingInvisible = false
        
        task.spawn(function()
            pcall(function()
                if not MyTycoon then return end
                for _, desc in ipairs(MyTycoon:GetDescendants()) do
                    if desc:IsA("BasePart") then
                        local oriTrans = desc:GetAttribute("OriTrans")
                        local oriMat = desc:GetAttribute("OriMat")
                        
                        if oriTrans then
                            desc.Transparency = oriTrans
                            desc.CastShadow = true
                            if oriMat then pcall(function() desc.Material = Enum.Material[oriMat] end) end
                            desc:SetAttribute("OriTrans", nil)
                            desc:SetAttribute("OriMat", nil)
                        end
                    end
                end
            end)
        end)
    end
end)

Window:AddDropdown("Auto Buy Mode", {"V1", "V2"}, function(SelectedMode)
    TargetBuyMode = SelectedMode
end)

Window:AddDropdown("Auto Buy Method", {"Sequential", "Direct Gas", "Remote Invoke"}, function(SelectedMethod)
    BuyMethod = SelectedMethod
end)

Window:AddInput("Invoke Delay", "0.5", function(Text)
    local num = tonumber(Text)
    -- Memastikan yang dimasukkan adalah angka dan bukan 0
    if num and num > 0 then
        RemoteInvokeDelay = num
    end
end)

-- =======================================================
-- SISTEM CUSTOM TP & SAFEZONE DINAMIS
-- =======================================================
local CustomTPCFrame = nil
local CustomTPSize = Vector3.new(10, 1, 10) -- Pijakan dibuat lebih luas (10x10)

local function EnsureSafeZone(targetCFrame, targetSize)
    local safeZoneName = "BrutalSafeZone_Custom"
    local safeZone = workspace:FindFirstChild(safeZoneName)

    if not safeZone then
        safeZone = Instance.new("Part")
        safeZone.Name = safeZoneName
        safeZone.Size = Vector3.new(10, 1, 10) 
        safeZone.Anchored = true
        safeZone.CanCollide = true
        safeZone.Transparency = 0.7
        safeZone.BrickColor = BrickColor.new("Black") 
        safeZone.Material = Enum.Material.Neon
        safeZone.Parent = workspace
    end
    
    local targetTopY = targetCFrame.Position.Y + (targetSize.Y / 2)
    safeZone.CFrame = CFrame.new(targetCFrame.Position.X, targetTopY - 0.5, targetCFrame.Position.Z)
end

ToggleObjects.AutoUpgrade = Window:AddToggle("Auto Upgrade", false, function(Value) Toggles.AutoUpgrade = Value end)
ToggleObjects.AutoRebirth = Window:AddToggle("Auto Rebirth", false, function(Value) Toggles.AutoRebirth = Value end)

-- TOMBOL TP YANG SUDAH DI-MODIFIKASI
ToggleObjects.RebirthTP = Window:AddToggle("TP After Rebirth", true, function(Value) 
    Toggles.RebirthTP = Value 
    if Value then
        pcall(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                CustomTPCFrame = root.CFrame
                EnsureSafeZone(CustomTPCFrame, CustomTPSize)
                
                -- Memunculkan notifikasi pop-up di layar saat posisi berhasil disimpan!
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "📍 Posisi TP Disimpan!",
                    Text = "SafeZone & TP mengikuti lokasi kamu berdiri saat ini.",
                    Duration = 3
                })
            end
        end)
    end
end)

ToggleObjects.AutoEvolve = Window:AddToggle("Auto Evolve", false, function(Value) Toggles.AutoEvolve = Value end)
ToggleObjects.AutoAscend = Window:AddToggle("Auto Ascend", false, function(Value) Toggles.AutoAscend = Value end)

-- REBIRTH INPUT
RebirthInput = Window:AddInput("Target Rebirth", "Smart / 100 / 2x", function(Text)
    local input = string.lower(Text)
    if input == "smart" then
        RebirthMode = "Smart"
        SmartMultiplier = 2        -- Reset ke gigi 1
        LastRebirthTime = os.clock() -- Reset timer
    elseif string.match(input, "^[%d%.]+x$") then
        local mult = tonumber(string.match(input, "[%d%.]+"))
        if mult then
            RebirthMode = "Multiplier"
            RebirthValue = mult
        end
    else
        local val = parseStringToNumber(input) 
        if val and val > 0 then 
            RebirthMode = "Target"
            RebirthValue = val 
        end
    end
end)

-- TELEPORT DROPDOWN
local tpLocations = {"Spawn", "Lemon Stand", "Lemon Dash", "Lemon Depot", "Lemon Trading", "Lemon Labs", "Lemon Robotics", "Lemon Republic", "LemonX", "Staircase"}
Window:AddDropdown("Teleport To", tpLocations, function(SelectedLocation)
    pcall(function()
        local MyTycoon = GetMyTycoon()
        local char = LocalPlayer.Character
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
        
        if MyTycoon and rootPart then
            local locFolder = MyTycoon:FindFirstChild("Locations")
            if locFolder then
                local targetPart = locFolder:FindFirstChild(SelectedLocation)
                if targetPart and targetPart:IsA("BasePart") then
                    rootPart.CFrame = targetPart.CFrame * CFrame.new(0, 3, 0)
                end
            end
        end
    end)
end)

Window:AddButton("Sewer: Collect Cashvine [TAP]", function() task.spawn(TapCollectCashvine) end)
Window:AddButton("Sewer: Open All Doors [TAP]", function() task.spawn(TapOpenAllDoors) end)
Window:AddButton("Sewer: Auto Full Sewer [TAP]", function() task.spawn(TapAutoSewer) end)
Window:AddButton("Unlock Power Attributes [TAP]", function() task.spawn(TapUnlockPowers) end)

Window:AddButton("Save Configuration", function() SaveConfig() end)
Window:AddButton("Load Configuration", function() LoadConfig() end)

-- PROTEKSI UTAMA: Menggunakan pcall agar skrip tidak mati total jika library tidak mendukung AddLabel
local labelSuccess = pcall(function()
    Window:AddLabel("Background Features Active: Auto Buy Power, Auto Answer Phone, Unlock Remote Buy.")
    Window:AddLabel("For UI Rebirth Evolve Ascension Manage Power will close Automatically after 5s.")
    Window:AddLabel("Warning: Auto Permanent Buy inside Direct Gas Feature.")
end)

-- FALLBACK: Jika AddLabel error (tidak ada di library), otomatis buat catatan berbentuk Button pasif
if not labelSuccess then
    pcall(function()
        Window:AddButton("--------------------------------------------------", function() end)
        Window:AddButton("Active: Auto Buy Power & Auto Answer Phone", function() end)
        Window:AddButton("Note: Keep Rebirth Menu open for Auto Rebirth", function() end)
    end)
end

LocalPlayer.Idled:Connect(function()
    pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end)
end)

-- =======================================================
-- HIGH-PRIORITY HUD PROTECTOR (INSTANT RESPONSE)
-- =======================================================
task.spawn(function()
    -- Memastikan skrip berjalan di thread terpisah yang tidak terganggu oleh Farming Engine
    task.priority = 1 -- Memberikan prioritas tinggi pada thread ini
    
    local playerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
    local cashLabel = playerGui and playerGui:FindFirstChild("HUD") 
                      and playerGui.HUD:FindFirstChild("Balance") 
                      and playerGui.HUD.Balance:FindFirstChild("Main") 
                      and playerGui.HUD.Balance.Main:FindFirstChild("Cash")

    if cashLabel then
        local lastValid = cashLabel.Text
        
        -- Menggunakan event paling rendah (tanpa jeda, langsung eksekusi saat sinyal masuk)
        cashLabel:GetPropertyChangedSignal("Text"):Connect(function()
            local txt = cashLabel.Text
            
            -- Filter Glitch brutal
            if txt == "$0.00" or txt == "0.00" or txt == "" then
                cashLabel.Text = lastValid -- Respon instant
            else
                lastValid = txt -- Update memori secepat kilat
            end
        end)
    end
end)

-- ==========================================
-- 4. MULTI-THREAD FARMING ENGINE
-- ==========================================

-- LOOP 0: SILENT HARVEST
task.spawn(function()
    while task.wait(0.1) do
        if Toggles.SilentHarvest then
            pcall(function()
                local char = LocalPlayer.Character
                local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    for i = 1, 12 do
                        local tycoon = Workspace:FindFirstChild("Tycoon" .. i)
                        if tycoon then
                            local constantFolder = tycoon:FindFirstChild("Constant")
                            if constantFolder and constantFolder:FindFirstChild("Trees") then
                                for _, tree in pairs(constantFolder.Trees:GetChildren()) do
                                    if tree.Name == "LemonTree" then
                                        for _, part in pairs(tree:GetChildren()) do
                                            if part.Name == "Fruit" then
                                                local cd = part:FindFirstChildWhichIsA("ClickDetector", true)
                                                if cd then
                                                    local distance = (part.Position - rootPart.Position).Magnitude
                                                    local maxDist = cd.MaxActivationDistance or 32 
                                                    if distance <= (maxDist + 5) then
                                                        fireclickdetector(cd)
                                                    end
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

-- =======================================================
-- LOOP 1: AUTO BUY MULTI-VERSION (3 ENGINES SYSTEM + ANTI-SPAM)
-- =======================================================
local PurchaseV1 = { "Staircase", "Hills", "Minigames", "Lemon Stand", "LemonDash", "Lemon Depot", "Lemon Trading", "Lemon Labs", "Lemon Robotics", "Lemon Republic", "LemonX Ground", "LemonX" }
local PurchaseV2 = { "Staircase", "Hills", "LemonX", "Lemon Republic", "Lemon Robotics", "Lemon Labs", "Lemon Trading", "Lemon Depot", "LemonDash", "Lemon Stand", "Minigames", "LemonX Ground" }
local isBuyingSequence = false
local remoteCooldowns = {} -- FITUR PENGAMAN: Memori pintar pencatat remote yang sudah ditembak (Anti-Spam/Anti-DC)
local lastRemoteInvokeTime = 0 -- FIX: Ditambahkan kembali agar penahan waktu tidak error

-- VARIABEL PENGUNCI DAN SINKRONISASI INSTAN (HYPER-SPEED COMPATIBLE)
local currentSeqIndex = 1
local lastTrackedTycoon = nil
local lastTrackedMode = nil

task.spawn(function()
    while task.wait(0.05) do -- Radar deteksi kilat (0.05 detik)
        if Toggles.AutoBuy then
            
            local MyTycoon = GetMyTycoon()
            
            -- PUSAT REM DARURAT MILIDETIK: Jika Tycoon berganti (Rebirth) atau Mode V1/V2 Berubah, Paksa Detik Itu Juga Reset Ke Awal!
            if MyTycoon ~= lastTrackedTycoon or TargetBuyMode ~= lastTrackedMode then
                lastTrackedTycoon = MyTycoon
                lastTrackedMode = TargetBuyMode
                currentSeqIndex = 1 -- Kembalikan paksa ke "Staircase" instan tanpa nunggu loop selesai
                remoteCooldowns = {} -- Bersihkan sisa cooldown babak sebelumnya agar gas pol langsung aman
                isBuyingSequence = false
            end

            -- ==========================================
            -- VERSI 1: ENGINES SEQUENTIAL (BAWAAN ASLI)
            -- ==========================================
            if BuyMethod == "Sequential" then
                if not isBuyingSequence then
                    pcall(function()
                        local char = LocalPlayer.Character
                        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                        if not rootPart then return end
                        
                        if MyTycoon and MyTycoon:FindFirstChild("Purchases") then
                            isBuyingSequence = true
                            task.spawn(function()
                                pcall(function()
                                    local activeOrder = (TargetBuyMode == "V1") and PurchaseV1 or PurchaseV2
                                    
                                    -- PELINDUNG UTAMA (ANTI-STUCK): Jika indeks overflow akibat overlap thread, paksa balik ke 1!
                                    if currentSeqIndex == nil or currentSeqIndex > #activeOrder or currentSeqIndex < 1 then 
                                        currentSeqIndex = 1 
                                    end
                                    
                                    local folderName = activeOrder[currentSeqIndex]
                                    local purchaseFolder = MyTycoon.Purchases:FindFirstChild(folderName)
                                    
                                    if purchaseFolder then
                                        local buttonsFolder = purchaseFolder:FindFirstChild("Buttons")
                                        if buttonsFolder then
                                            local targets = {}
                                            local currentTargets = {}
                                            
                                            for _, item in ipairs(buttonsFolder:GetDescendants()) do
                                                -- Deteksi interupsi darurat di tengah jalan
                                                if MyTycoon ~= lastTrackedTycoon or TargetBuyMode ~= lastTrackedMode or not Toggles.AutoBuy or BuyMethod ~= "Sequential" then break end
                                                
                                                local targetPart = item.Parent
                                                
                                                -- SMART FILTER LOGIC (Mengatasi Bug Shown & Atribut Tidak Konsisten)
                                                local isEnabled, isShown = false, false
                                                local isPurchased = true
                                                local hasPurchasedAttr = false
                                                
                                                if targetPart then
                                                    if targetPart:GetAttribute("Enabled") == true or (targetPart.Parent and targetPart.Parent:GetAttribute("Enabled") == true) then isEnabled = true end
                                                    if targetPart:GetAttribute("Shown") == true or (targetPart.Parent and targetPart.Parent:GetAttribute("Shown") == true) then isShown = true end
                                                    
                                                    local pAttr = targetPart:GetAttribute("Purchased")
                                                    if pAttr == nil and targetPart.Parent then pAttr = targetPart.Parent:GetAttribute("Purchased") end
                                                    if pAttr ~= nil then
                                                        hasPurchasedAttr = true
                                                        isPurchased = pAttr
                                                    end
                                                end
                                                
                                                local isValidToBuy = false
                                                if isEnabled then
                                                    if isShown then
                                                        isValidToBuy = true -- Lolos jalur normal (Shown = true)
                                                    elseif hasPurchasedAttr and isPurchased == false then
                                                        isValidToBuy = true -- Lolos jalur bug (Shown false, tapi Purchased false)
                                                    end
                                                end
                                                
                                                if isValidToBuy then
                                                    if item:IsA("TouchTransmitter") or item.Name == "TouchInterest" then
                                                        if targetPart and targetPart:IsA("BasePart") then
                                                            table.insert(targets, {Type = "Touch", Target = targetPart})
                                                            table.insert(currentTargets, item)
                                                        end
                                                    elseif item:IsA("ProximityPrompt") and item.Enabled then
                                                        table.insert(targets, {Type = "Prompt", Target = item})
                                                        table.insert(currentTargets, item)
                                                    end
                                                end
                                            end
                                            
                                            -- Jika folder item ini sudah bersih/habis dibeli, lanjut ke indeks folder berikutnya di putaran depan
                                            if #currentTargets == 0 then
                                                currentSeqIndex = currentSeqIndex + 1
                                            else
                                                -- Eksekusi Pembelian
                                                for _, btn in ipairs(targets) do
                                                    if MyTycoon ~= lastTrackedTycoon or TargetBuyMode ~= lastTrackedMode or not Toggles.AutoBuy or BuyMethod ~= "Sequential" then break end
                                                    pcall(function()
                                                        if btn.Type == "Touch" then
                                                            firetouchinterest(rootPart, btn.Target, 0)
                                                            firetouchinterest(rootPart, btn.Target, 1)
                                                        elseif btn.Type == "Prompt" then
                                                            fireproximityprompt(btn.Target)
                                                        end
                                                    end)
                                                end
                                            end
                                        else
                                            currentSeqIndex = currentSeqIndex + 1
                                        end
                                    else
                                        currentSeqIndex = currentSeqIndex + 1
                                    end
                                end)
                                task.wait(0.01) -- Jeda penyeimbang super kilat demi kestabilan thread
                                isBuyingSequence = false
                            end)
                        end
                    end)
                end

            -- ==========================================
            -- VERSI 2: ENGINES DIRECT GAS (TOUCH / PROMPTS INTERACTION)
            -- ==========================================
            elseif BuyMethod == "Direct Gas" then
                pcall(function()
                    local char = LocalPlayer.Character
                    local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                    if not rootPart then return end

                    -- =======================================
                    -- DETEKSI PERMABUY (UI CHECK KHUSUS)
                    -- =======================================
                    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                    local permaBuyBtn = playerGui and playerGui:FindFirstChild("HUD") 
                        and playerGui.HUD:FindFirstChild("Balance") 
                        and playerGui.HUD.Balance:FindFirstChild("PermaBuyButton")
                    
                    local canPermaBuy = false
                    if permaBuyBtn and permaBuyBtn.Visible == true then
                        local countLabel = permaBuyBtn:FindFirstChild("Count")
                        if countLabel then
                            local textStr = countLabel.Text
                            -- Membersihkan huruf 'x', koma, titik, dan spasi agar sisa angkanya saja
                            local cleanedStr = string.gsub(textStr, "[x%,%.%s]", "")
                            if cleanedStr ~= "" and tonumber(cleanedStr) ~= nil then
                                canPermaBuy = true
                            end
                        end
                    end
                    -- =======================================

                    if MyTycoon and MyTycoon:FindFirstChild("Purchases") then
                        local activeOrder = (TargetBuyMode == "V1") and PurchaseV1 or PurchaseV2
                        
                        for _, folderName in ipairs(activeOrder) do
                            if MyTycoon ~= lastTrackedTycoon or TargetBuyMode ~= lastTrackedMode or not Toggles.AutoBuy or BuyMethod ~= "Direct Gas" then break end
                            local purchaseFolder = MyTycoon.Purchases:FindFirstChild(folderName)
                            if purchaseFolder and purchaseFolder:FindFirstChild("Buttons") then
                                for _, item in ipairs(purchaseFolder.Buttons:GetDescendants()) do
                                    local targetPart = item.Parent
                                    
                                    -- SMART FILTER LOGIC
                                    local isEnabled, isShown = false, false
                                    local isPurchased = true
                                    local hasPurchasedAttr = false
                                    
                                    if targetPart then
                                        if targetPart:GetAttribute("Enabled") == true or (targetPart.Parent and targetPart.Parent:GetAttribute("Enabled") == true) then isEnabled = true end
                                        if targetPart:GetAttribute("Shown") == true or (targetPart.Parent and targetPart.Parent:GetAttribute("Shown") == true) then isShown = true end
                                        
                                        local pAttr = targetPart:GetAttribute("Purchased")
                                        if pAttr == nil and targetPart.Parent then pAttr = targetPart.Parent:GetAttribute("Purchased") end
                                        if pAttr ~= nil then
                                                            hasPurchasedAttr = true
                                                            isPurchased = pAttr
                                                        end
                                    end
                                    
                                    local isValidToBuy = false
                                    if isEnabled then
                                        if isShown then
                                            isValidToBuy = true
                                        elseif hasPurchasedAttr and isPurchased == false then
                                            isValidToBuy = true
                                        end
                                    end
                                    
                                    if isValidToBuy then
                                        if item:IsA("TouchTransmitter") or item.Name == "TouchInterest" then
                                            firetouchinterest(rootPart, targetPart, 0)
                                            firetouchinterest(rootPart, targetPart, 1)
                                        elseif item:IsA("ProximityPrompt") and item.Enabled then
                                            fireproximityprompt(item)
                                        elseif item:IsA("RemoteFunction") and item.Name == "Purchase" then
                                            -- FITUR PERMABUY: Eksekusi True hanya jalan jika validasi UI lolos!
                                            if canPermaBuy then
                                                task.spawn(function()
                                                    pcall(function() item:InvokeServer(true) end)
                                                end)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)

            -- ==========================================
            -- VERSI 3: ENGINES REMOTE INVOKE (SUPER GHOST BUYER) - SAFE ANTI-SPAM!
            -- ==========================================
            elseif BuyMethod == "Remote Invoke" then
                local tickNow = os.clock()
                -- MENGGUNAKAN VARIABEL MANUAL DARI UI: RemoteInvokeDelay
                if tickNow - lastRemoteInvokeTime >= RemoteInvokeDelay then
                    lastRemoteInvokeTime = tickNow
                    pcall(function()
                        if MyTycoon and MyTycoon:FindFirstChild("Purchases") then
                            local activeOrder = (TargetBuyMode == "V1") and PurchaseV1 or PurchaseV2
                            local currentTime = os.clock()
                            
                            for _, folderName in ipairs(activeOrder) do
                                if MyTycoon ~= lastTrackedTycoon or TargetBuyMode ~= lastTrackedMode or not Toggles.AutoBuy or BuyMethod ~= "Remote Invoke" then break end
                                local purchaseFolder = MyTycoon.Purchases:FindFirstChild(folderName)
                                if purchaseFolder and purchaseFolder:FindFirstChild("Buttons") then
                                    -- Membongkar secara mendalam folder Buttons melewati Structure, Decor, dll.
                                    for _, item in ipairs(purchaseFolder.Buttons:GetDescendants()) do
                                        if item:IsA("RemoteFunction") and item.Name == "Purchase" then
                                            
                                            -- PROTEKSI DATA: Jika tombol ini baru saja ditembak kurang dari 0.8 detik lalu, lewati!
                                            if remoteCooldowns[item] and (currentTime - remoteCooldowns[item] < 0.8) then
                                                continue
                                            end
                                            
                                            local targetPart = item.Parent -- Mendapatkan model barang utama
                                            
                                            -- SMART FILTER LOGIC
                                            local isEnabled, isShown = false, false
                                            local isPurchased = true
                                            local hasPurchasedAttr = false
                                            
                                            if targetPart then
                                                if targetPart:GetAttribute("Enabled") == true or (targetPart.Parent and targetPart.Parent:GetAttribute("Enabled") == true) then isEnabled = true end
                                                if targetPart:GetAttribute("Shown") == true or (targetPart.Parent and targetPart.Parent:GetAttribute("Shown") == true) then isShown = true end
                                                
                                                local pAttr = targetPart:GetAttribute("Purchased")
                                                if pAttr == nil and targetPart.Parent then pAttr = targetPart.Parent:GetAttribute("Purchased") end
                                                if pAttr ~= nil then
                                                                hasPurchasedAttr = true
                                                                isPurchased = pAttr
                                                            end
                                            end
                                            
                                            local isValidToBuy = false
                                            if isEnabled then
                                                if isShown then
                                                    isValidToBuy = true
                                                elseif hasPurchasedAttr and isPurchased == false then
                                                    isValidToBuy = true
                                                end
                                            end
                                            
                                            if isValidToBuy then
                                                -- Kunci tombol ini saat ini juga agar tidak ditembak berulang-ulang oleh putaran radar berikutnya
                                                remoteCooldowns[item] = currentTime
                                                
                                                -- Menggunakan task.spawn agar InvokeServer berjalan async (Anti-Lag, Anti-Stuck, Anti-DC)
                                                task.spawn(function()
                                                    local success = pcall(function()
                                                        item:InvokeServer(false) -- Eksekusi argumen 'false' hasil rspy
                                                    end)
                                                    -- Jika penembakan gagal/error, hapus kuncian agar bisa dicoba lagi nanti
                                                    if not success then
                                                        remoteCooldowns[item] = nil
                                                    end
                                                end)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                end
            end

        end
    end
end)

-- LOOP 2: [CORE 2] MESIN KHUSUS AUTO HARVEST (BUAH & TP BRUTAL)
-- =======================================================
-- MESIN DUAL-CORE: PEKERJA TERPISAH (ANTI-MACET/ANTI-LIMIT)
-- REVISI: Penyesuaian Jeda Server Tombol (0.3 Detik)
-- =======================================================
local kedalaman = 15

task.spawn(function()
    while task.wait(0.1) do
        if Toggles.AutoHarvest then
            pcall(function()
                local char = LocalPlayer.Character
                local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                local humanoid = char and char:FindFirstChild("Humanoid")
                if not rootPart or not humanoid or humanoid.Health <= 0 then return end

                local currentTime = os.clock()
                local originalCFrame = rootPart.CFrame
                local hasTeleported = false

                for i = 1, 12 do
                    if not Toggles.AutoHarvest then break end -- Rem darurat
                    local tycoon = Workspace:FindFirstChild("Tycoon" .. i)
                    if tycoon then
                        local trees = tycoon:FindFirstChild("Constant", true) and tycoon.Constant:FindFirstChild("Trees")
                        if trees then
                            for _, tree in pairs(trees:GetChildren()) do
                                if tree.Name == "LemonTree" then
                                    for _, part in pairs(tree:GetChildren()) do
                                        if part.Name == "Fruit" then
                                            local cd = part:FindFirstChildWhichIsA("ClickDetector", true)
                                            local lastHarvest = part:GetAttribute("WaktuAmbil") or 0
                                            
                                            -- Cek buah yang sudah siap
                                            if cd and (currentTime - lastHarvest > 0.05) then
                                                hasTeleported = true
                                                humanoid.PlatformStand = true
                                                rootPart.Velocity = Vector3.new(0, 0, 0)
                                                
                                                local tPos = part.Position
                                                rootPart.CFrame = CFrame.new(tPos.X, tPos.Y - kedalaman, tPos.Z) * CFrame.Angles(math.rad(90), 0, 0)
                                                
                                                part:SetAttribute("WaktuAmbil", os.clock())
                                                pcall(function() fireclickdetector(cd) end)
                                                
                                                -- Jeda tipis agar TP berjalan mulus tanpa tertahan
                                                task.wait(0.05) 
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                -- KEMBALI KE POSISI ASAL JIKA TADI SEMPAT TP
                if hasTeleported then
                    task.wait()
                    if LocalPlayer.Character == char and rootPart.Parent ~= nil and humanoid.Health > 0 then
                        humanoid.PlatformStand = false
                        rootPart.Velocity = Vector3.new(0, 0, 0)
                        rootPart.CFrame = originalCFrame
                    end
                end
            end)
        end
    end
end)

-- =======================================================
-- LOOP 3: AUTO UPGRADE & CLICK (FIX BUG KOMA RIBUAN + ANTI POPUP)
-- =======================================================
local clickTargets = {"LemonDepot", "LemonLabs", "LemonRepublic", "LemonRobotics", "LemonStand", "LemonTrading", "LemonDash", "LemonX"}
local visibleTimerManage = 0
local wasManageOn = false
local isUpgradingSequence = false 

task.spawn(function()
    -- [BAGIAN A]: AUTO CLICKER
    task.spawn(function()
        while task.wait(0.1) do
            if Toggles.AutoUpgrade then
                pcall(function()
                    local MyTycoon = GetMyTycoon()
                    local wakeRemote = MyTycoon and MyTycoon:FindFirstChild("Remotes") and MyTycoon.Remotes:FindFirstChild("WakeIncomeStream")
                    
                    if wakeRemote and wakeRemote:IsA("RemoteFunction") then
                        for _, targetName in ipairs(clickTargets) do
                            task.spawn(function() 
                                pcall(function() wakeRemote:InvokeServer(targetName) end) 
                            end)
                        end
                    end
                end)
            end
        end
    end)

    -- [BAGIAN B & C]: SMART AUTO UPGRADE (BAIT & VERIFY LOGIC)
    local promptPaths = {
        {"LemonX", "LemonX", "LemonX"},
        {"Lemon Republic", "Lemon Republic", "Lemon Republic"},
        {"Lemon Robotics", "Lemon Robotics", "Lemon Robotics"},
        {"Lemon Labs", "Lemon Labs", "Lemon Labs"},
        {"Lemon Trading", "Lemon Trading", "Lemon Trading"},
        {"Lemon Depot", "Lemon Depot", "Lemon Depot"},
        {"LemonDash", "LemonDash", "LemonDash"},
        {"Lemon Stand", "Lemon Stand", "Lemon Stand"}
    }
    
    while true do 
        local dt = task.wait(0.05)
        
        pcall(function()
            local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
            
            -- ==========================================
            -- PENGHANCUR POPUP ARROW HINT YANG MENGGANGGU
            -- ==========================================
            local popupGui = playerGui and playerGui:FindFirstChild("Popup")
            local arrowHint = popupGui and popupGui:FindFirstChild("GuiArrowHint")
            if arrowHint and arrowHint.Visible == true then
                arrowHint.Visible = false
            end
            -- ==========================================

            local manageMenu = playerGui and playerGui:FindFirstChild("Manage") and playerGui.Manage:FindFirstChild("ManageMenu")
            
            -- 1. TRIGGER & TIMER MANAGE MENU
            if Toggles.AutoUpgrade then
                wasManageOn = true
                if manageMenu then
                    if manageMenu:GetAttribute("Exclusive") ~= false then manageMenu:SetAttribute("Exclusive", false) end
                    if manageMenu:GetAttribute("Visible") ~= true then manageMenu:SetAttribute("Visible", true) end
                    
                    if manageMenu.Visible == true then
                        visibleTimerManage = visibleTimerManage + dt
                        if visibleTimerManage >= 5 then
                            manageMenu.Visible = false
                            visibleTimerManage = 0
                        end
                    else
                        visibleTimerManage = 0
                    end
                end
            elseif wasManageOn then
                if manageMenu then
                    pcall(function()
                        manageMenu:SetAttribute("Exclusive", true)
                        manageMenu:SetAttribute("Visible", false)
                    end)
                end
                wasManageOn = false
                visibleTimerManage = 0
            end

            -- 2. SMART FILTER & SEQUENTIAL UPGRADE
            if Toggles.AutoUpgrade and not isUpgradingSequence then
                local MyTycoon = GetMyTycoon()
                local manageFrame = manageMenu and manageMenu:FindFirstChild("Body")
                                  and manageMenu.Body:FindFirstChild("Frame")
                                  and manageMenu.Body.Frame:FindFirstChild("Manage")

                if MyTycoon and MyTycoon:FindFirstChild("Purchases") and manageFrame then
                    
                    isUpgradingSequence = true 
                    
                    task.spawn(function()
                        pcall(function()
                            for _, path in ipairs(promptPaths) do
                                if not Toggles.AutoUpgrade then break end
                                
                                local uiName = string.gsub(path[1], " ", "")
                                local folderUI = manageFrame:FindFirstChild(uiName)
                                
                                local canUpgrade = true 
                                
                                if folderUI then
                                    if not folderUI.Visible then folderUI.Visible = true end
                                    if folderUI:GetAttribute("Visible") ~= true then folderUI:SetAttribute("Visible", true) end

                                    local upgBtn = folderUI:FindFirstChild("Upgrade")
                                    if upgBtn then
                                        local bgColor = upgBtn.BackgroundColor3
                                        local r = math.floor((bgColor.R * 255) + 0.5)
                                        local g = math.floor((bgColor.G * 255) + 0.5)
                                        local b = math.floor((bgColor.B * 255) + 0.5)

                                        if upgBtn.Active == false or (r == 125 and g == 125 and b == 125) then
                                            canUpgrade = false
                                        end

                                        if canUpgrade then
                                            local current = MyTycoon.Purchases
                                            for _, folderName in ipairs(path) do
                                                current = current and current:FindFirstChild(folderName)
                                            end
                                            
                                            if current then
                                                local upgradeRemote = current:FindFirstChild("Upgrade") or current:FindFirstChildWhichIsA("RemoteFunction")
                                                
                                                if upgradeRemote and upgradeRemote:IsA("RemoteFunction") then
                                                    
                                                    -- ==========================================
                                                    -- FIX: FUNGSI PEMBERSIH KOMA DI ANGKA RIBUAN
                                                    -- ==========================================
                                                    local function getCurrentCount()
                                                        local cObj = upgBtn:FindFirstChild("Count")
                                                        if cObj and cObj.Text and cObj.Text ~= "" then
                                                            -- Bersihkan teks dari koma dan spasi sebelum dibaca angkanya
                                                            local cleanStr = string.gsub(cObj.Text, "[,%s]", "")
                                                            local ext = tonumber(string.match(cleanStr, "%d+"))
                                                            return ext or 0
                                                        end
                                                        return 0 
                                                    end

                                                    local countSebelum = getCurrentCount()

                                                    -- TAHAP 1: Pancing beli 1
                                                    pcall(function() 
                                                        upgradeRemote:InvokeServer(1) 
                                                    end)

                                                    -- TAHAP 2: SMART WAIT 
                                                    local waitTime = 0
                                                    while getCurrentCount() <= countSebelum and waitTime < 0.6 do
                                                        waitTime = waitTime + task.wait(0.05)
                                                    end

                                                    -- TAHAP 3: Verifikasi & Gas Max
                                                    local countSesudah = getCurrentCount()
                                                    
                                                    if countSesudah > countSebelum then
                                                        local burstAmmo = 0
                                                        local stackObj = upgBtn:FindFirstChild("Stack")
                                                        
                                                        if stackObj and stackObj.Text then
                                                            local cleanText = string.gsub(stackObj.Text, "[+%,%s]", "")
                                                            local extractedNum = tonumber(cleanText)
                                                            if extractedNum and extractedNum > 0 then
                                                                burstAmmo = extractedNum
                                                            end
                                                        end
                                                        
                                                        if burstAmmo > 0 then
                                                            pcall(function() 
                                                                upgradeRemote:InvokeServer(burstAmmo) 
                                                            end)
                                                            task.wait(0.1) 
                                                        end
                                                    end
                                                    
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                        
                        -- Buka gembok antrean
                        isUpgradingSequence = false
                    end)
                end
            end
        end)
    end
end)

-- LOOP 4: AUTO PHONE (RUNS IN BACKGROUND SEKARANG)
task.spawn(function()
    while task.wait(0.1) do
        pcall(function() 
            local MyTycoon = GetMyTycoon()
            if MyTycoon then
                local phoneGui = LocalPlayer.PlayerGui:FindFirstChild("Phone")
                local phoneFrame = phoneGui and phoneGui:FindFirstChild("Phone")
                if phoneFrame and phoneFrame.Visible then
                    local remotes = MyTycoon:FindFirstChild("Remotes")
                    if remotes and remotes:FindFirstChild("PhoneOffer") then
                        task.wait(0.1)
                        pcall(function() remotes.PhoneOffer:FireServer("Raise") end)
                        task.wait(0.1)
                        pcall(function() remotes.PhoneOffer:FireServer("Accept") end)
                        task.wait(0.1)
                        phoneFrame.Visible = false
                        task.wait(0.1)
                    end
                end
            end
        end)
    end
end)

-- =======================================================
-- LOOP 5: DYNAMIC SMART AUTO REBIRTH (INSTANT GHOST TP - NO ANCHOR)
-- =======================================================
local wasAutoRebirthOn = false
local visibleTimerRebirth = 0
local isRebirthing = false 

task.spawn(function()
    while true do
        local dt = task.wait(0.05) 
        pcall(function()
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                local rebirthGui = playerGui:FindFirstChild("Rebirth")
                local investorsMenu = rebirthGui and rebirthGui:FindFirstChild("InvestorsMenu")
                local sidebarContainer = rebirthGui and rebirthGui:FindFirstChild("Sidebar") and rebirthGui.Sidebar:FindFirstChild("Container")
                local sidebarInvestors = sidebarContainer and sidebarContainer:FindFirstChild("Investors")
                
                if Toggles.AutoRebirth then
                    if not wasAutoRebirthOn then LastRebirthTime = os.clock() end
                    wasAutoRebirthOn = true
                    
                    if investorsMenu then
                        if investorsMenu.Visible == true then
                            visibleTimerRebirth = visibleTimerRebirth + dt
                            if visibleTimerRebirth >= 5 then
                                investorsMenu.Visible = false
                                visibleTimerRebirth = 0
                            end
                        else
                            visibleTimerRebirth = 0
                        end
                        
                        pcall(function()
                            if investorsMenu:GetAttribute("Exclusive") ~= false then investorsMenu:SetAttribute("Exclusive", false) end
                            if investorsMenu:GetAttribute("Visible") ~= true then investorsMenu:SetAttribute("Visible", true) end
                        end)
                        
                        if sidebarInvestors and sidebarInvestors.Active ~= true then sidebarInvestors.Active = true end
                        
                        local body = investorsMenu:FindFirstChild("Body")
                        local potentialObj = body and body:FindFirstChild("Potential") and body.Potential:FindFirstChild("Quantity")
                        local amountObj = body and body:FindFirstChild("Amount") and body.Amount:FindFirstChild("Quantity")
                        
                        if potentialObj and amountObj then
                            local basePot, expPot = CleanAndParse(potentialObj.Text)
                            local baseCur, expCur = CleanAndParse(amountObj.Text)
                            local shouldRebirth = false

                            -- ==========================================
                            -- LOGIKA TURUN GIGI (DOWNSHIFT) SUPER AGRESIF
                            -- ==========================================
                            if RebirthMode == "Smart" and LastRebirthTime > 0 then
                                local timeElapsed = os.clock() - LastRebirthTime
                                
                                -- Toleransi turun gigi dipercepat agar tidak kelamaan menunggu!
                                if SmartMultiplier == 50 and timeElapsed > 15 then
                                    SmartMultiplier = 30
                                    LastRebirthTime = os.clock() -- Reset timer agar gigi 30x punya waktu penuh
                                elseif SmartMultiplier == 30 and timeElapsed > 20 then
                                    SmartMultiplier = 20
                                    LastRebirthTime = os.clock()
                                elseif SmartMultiplier == 20 and timeElapsed > 25 then
                                    SmartMultiplier = 10
                                    LastRebirthTime = os.clock() 
                                elseif SmartMultiplier == 10 and timeElapsed > 30 then
                                    SmartMultiplier = 2
                                    LastRebirthTime = os.clock() 
                                end
                            end

                            if RebirthMode == "Multiplier" then
                                shouldRebirth = IsPotentialEnough(basePot, expPot, baseCur, expCur, tonumber(RebirthValue) or 2)
                            elseif RebirthMode == "Smart" then
                                shouldRebirth = IsPotentialEnough(basePot, expPot, baseCur, expCur, SmartMultiplier)
                            elseif RebirthMode == "Target" then
                                local rVal = tonumber(RebirthValue) or 0
                                local targetBase, targetExp = 0, 0
                                if rVal > 0 then
                                    targetExp = math.floor(math.log10(rVal))
                                    targetBase = rVal / (10^targetExp)
                                end
                                if expPot > targetExp or (expPot == targetExp and basePot >= targetBase) then shouldRebirth = true end
                            end

                            if shouldRebirth and not isRebirthing then
                                local MyTycoon = GetMyTycoon()
                                local rebirthRemote = MyTycoon and MyTycoon:FindFirstChild("Remotes") and MyTycoon.Remotes:FindFirstChild("Rebirth")
                                
                                if rebirthRemote and rebirthRemote:IsA("RemoteFunction") then
                                    isRebirthing = true
                                    
                                    -- ==========================================
                                    -- LOGIKA NAIK GIGI (UPSHIFT) YANG LEBIH CERDAS
                                    -- ==========================================
                                    if RebirthMode == "Smart" then
                                        local currentTime = os.clock()
                                        if LastRebirthTime > 0 then
                                            local speed = currentTime - LastRebirthTime
                                            
                                            -- Syarat naik gigi disesuaikan dengan beban multipliernya
                                            if SmartMultiplier == 2 and speed < 3 then 
                                                SmartMultiplier = 10
                                            elseif SmartMultiplier == 10 and speed < 6 then 
                                                SmartMultiplier = 20
                                            elseif SmartMultiplier == 20 and speed < 10 then 
                                                SmartMultiplier = 30
                                            elseif SmartMultiplier == 30 and speed < 15 then 
                                                SmartMultiplier = 50
                                            end
                                        end
                                        LastRebirthTime = currentTime 
                                    end

                                    task.spawn(function()
                                        pcall(function() 
                                            local char = LocalPlayer.Character
                                            local root = char and char:FindFirstChild("HumanoidRootPart")

                                            -- 1. SETUP TARGET LOKASI
                                            local targetCFrame = nil
                                            if root and (Toggles.RebirthTP or Toggles.AutoHarvest) then
                                                if not CustomTPCFrame then
                                                    CustomTPCFrame = root.CFrame
                                                end
                                                EnsureSafeZone(CustomTPCFrame, CustomTPSize)
                                                local targetTopY = CustomTPCFrame.Position.Y + (CustomTPSize.Y / 2)
                                                targetCFrame = CFrame.new(CustomTPCFrame.Position.X, targetTopY + 3, CustomTPCFrame.Position.Z)
                                            end

                                            -- 2. TEMBAK REMOTE
                                            task.spawn(function()
                                                pcall(function() rebirthRemote:InvokeServer() end)
                                            end)
                                            UpgradeRemotes = {} 

                                            -- 3. GHOST LOCK (MURNI CFRAME, TANPA ANCHOR)
                                            if targetCFrame and root then
                                                for i = 1, 20 do
                                                    if root and root.Parent then
                                                        root.Velocity = Vector3.new(0, 0, 0)
                                                        root.CFrame = targetCFrame
                                                    end
                                                    task.wait()
                                                end
                                            end
                                        end)
                                        isRebirthing = false 
                                    end)
                                end
                            end
                        end
                    end
                    
                elseif wasAutoRebirthOn then
                    if investorsMenu then
                        pcall(function()
                            investorsMenu:SetAttribute("Exclusive", true)
                            investorsMenu:SetAttribute("Visible", false)
                            if investorsMenu.Visible == true then investorsMenu.Visible = false end
                        end)
                    end
                    if sidebarInvestors then sidebarInvestors.Active = false end
                    
                    wasAutoRebirthOn = false
                    visibleTimerRebirth = 0
                end
            end
        end)
    end
end)

-- LOOP 6: SMART AUTO EVOLVE
local wasAutoEvolveOn = false
local visibleTimerEvolve = 0
local isEvolving = false -- Debounce

task.spawn(function()
    while true do
        local dt = task.wait(0.1) -- dt tangkap durasi nyata
        pcall(function() 
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                local rebirthGui = playerGui:FindFirstChild("Rebirth")
                local evolutionMenu = rebirthGui and rebirthGui:FindFirstChild("EvolutionMenu")
                
                local sidebarContainer = rebirthGui and rebirthGui:FindFirstChild("Sidebar") and rebirthGui.Sidebar:FindFirstChild("Container")
                local sidebarEvolution = sidebarContainer and sidebarContainer:FindFirstChild("Evolution")
                
                if Toggles.AutoEvolve then
                    wasAutoEvolveOn = true
                    
                    if evolutionMenu then
                        -- TIMER 5 DETIK BERBASIS DELTA TIME
                        if evolutionMenu.Visible == true then
                            visibleTimerEvolve = visibleTimerEvolve + dt
                            if visibleTimerEvolve >= 5 then
                                evolutionMenu.Visible = false
                                visibleTimerEvolve = 0
                            end
                        else
                            visibleTimerEvolve = 0
                        end
                        
                        pcall(function()
                            if evolutionMenu:GetAttribute("Exclusive") ~= false then evolutionMenu:SetAttribute("Exclusive", false) end
                            if evolutionMenu:GetAttribute("Visible") ~= true then evolutionMenu:SetAttribute("Visible", true) end
                        end)

                        if sidebarEvolution and sidebarEvolution.Active ~= true then sidebarEvolution.Active = true end

                        local body = evolutionMenu:FindFirstChild("Body")
                        local progressObj = body and body:FindFirstChild("Progress")
                        
                        if progressObj then
                            local evolveText = progressObj.Text
                            if (string.find(evolveText, "100%%") or evolveText == "100%") and not isEvolving then
                                local MyTycoon = GetMyTycoon()
                                local evolveRemote = MyTycoon and MyTycoon:FindFirstChild("Remotes") and MyTycoon.Remotes:FindFirstChild("Evolve")
                                
                                if evolveRemote and evolveRemote:IsA("RemoteFunction") then
                                    isEvolving = true
                                    task.spawn(function()
                                        pcall(function() 
                                            evolveRemote:InvokeServer() 
                                            UpgradeRemotes = {} 
                                        end)
                                        task.wait(2) -- Delay cooldown aman di dalam thread terpisah, loop utama tidak terganggu
                                        isEvolving = false
                                    end)
                                end
                            end
                        end
                    end
                    
                elseif wasAutoEvolveOn then
                    if evolutionMenu then
                        pcall(function()
                            evolutionMenu:SetAttribute("Exclusive", true)
                            evolutionMenu:SetAttribute("Visible", false)
                            if evolutionMenu.Visible == true then evolutionMenu.Visible = false end
                        end)
                    end
                    if sidebarEvolution then sidebarEvolution.Active = false end
                    wasAutoEvolveOn = false
                    visibleTimerEvolve = 0
                end
            end
        end)
    end
end)

-- LOOP 7: AUTO DROP
task.spawn(function()
    while task.wait(0.1) do
        if Toggles.AutoDrop then
            pcall(function() 
                local char = LocalPlayer.Character
                local humanoid = char and char:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local cashDropsFolder = Workspace:FindFirstChild("CashDrops")
                    if cashDropsFolder then
                        for _, drop in pairs(cashDropsFolder:GetChildren()) do
                            if drop.Name == "CashDrop" then
                                local root = char:FindFirstChild("HumanoidRootPart")
                                local touchInterest = drop:FindFirstChild("TouchInterest") or drop:FindFirstChildWhichIsA("TouchTransmitter", true)
                                if root and touchInterest then
                                    pcall(function() 
                                        firetouchinterest(root, touchInterest.Parent, 0)
                                        firetouchinterest(root, touchInterest.Parent, 1)
                                    end)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- LOOP 8: AUTO BUY POWER (RUNS IN BACKGROUND)
task.spawn(function()
    local powerNames = {"Manage", "ClickFruitValue", "UpgradeStack", "WalkSpeed"}
    while task.wait(5) do
        pcall(function()
            local MyTycoon = GetMyTycoon()
            local upgradeRemote = MyTycoon and MyTycoon:FindFirstChild("Remotes") and MyTycoon.Remotes:FindFirstChild("UpgradePowerLevel")

            if upgradeRemote and upgradeRemote:IsA("RemoteFunction") then
                for _, powerName in ipairs(powerNames) do
                    task.spawn(function()
                        pcall(function() upgradeRemote:InvokeServer(powerName) end)
                    end)
                end
            end
        end)
    end
end)

-- LOOP 9: SMART AUTO ASCEND
local wasAutoAscendOn = false
local visibleTimerAscend = 0
local isAscending = false -- Debounce

task.spawn(function()
    while true do
        local dt = task.wait(0.5) -- dt tangkap durasi nyata
        pcall(function()
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                local rebirthGui = playerGui:FindFirstChild("Rebirth")
                local ascensionMenu = rebirthGui and rebirthGui:FindFirstChild("AscensionMenu")
                
                local sidebarContainer = rebirthGui and rebirthGui:FindFirstChild("Sidebar") and rebirthGui.Sidebar:FindFirstChild("Container")
                local sidebarAscension = sidebarContainer and sidebarContainer:FindFirstChild("Ascension")
                
                if Toggles.AutoAscend then
                    wasAutoAscendOn = true
                    
                    if ascensionMenu then
                        -- TIMER 5 DETIK BERBASIS DELTA TIME (FIXED!)
                        if ascensionMenu.Visible == true then
                            visibleTimerAscend = visibleTimerAscend + dt
                            if visibleTimerAscend >= 5 then
                                ascensionMenu.Visible = false
                                visibleTimerAscend = 0
                            end
                        else
                            visibleTimerAscend = 0
                        end
                        
                        pcall(function()
                            if ascensionMenu:GetAttribute("Exclusive") ~= false then ascensionMenu:SetAttribute("Exclusive", false) end
                            if ascensionMenu:GetAttribute("Visible") ~= true then ascensionMenu:SetAttribute("Visible", true) end
                        end)
                        
                        if sidebarAscension and sidebarAscension.Active ~= true then sidebarAscension.Active = true end
                        
                        local body = ascensionMenu:FindFirstChild("Body")
                        local ascendButton = body and body:FindFirstChild("Ascend")
                        
                        if ascendButton then
                            local currentColor = ascendButton.BackgroundColor3
                            if currentColor ~= Color3.fromRGB(80, 80, 80) and not isAscending then
                                local MyTycoon = GetMyTycoon()
                                local ascendRemote = MyTycoon and MyTycoon:FindFirstChild("Remotes") and MyTycoon.Remotes:FindFirstChild("Ascend")
                                
                                if ascendRemote and ascendRemote:IsA("RemoteFunction") then
                                    isAscending = true
                                    task.spawn(function()
                                        pcall(function() 
                                            ascendRemote:InvokeServer() 
                                            UpgradeRemotes = {} 
                                        end)
                                        task.wait(3) -- Pindah ke dalam thread terpisah! Timer UI sekarang berjalan lancar jaya!
                                        isAscending = false
                                    end)
                                end
                            end
                        end
                    end
                    
                elseif wasAutoAscendOn then
                    if ascensionMenu then
                        pcall(function()
                            ascensionMenu:SetAttribute("Exclusive", true)
                            ascensionMenu:SetAttribute("Visible", false)
                            if ascensionMenu.Visible == true then ascensionMenu.Visible = false end
                        end)
                    end
                    if sidebarAscension then sidebarAscension.Active = false end
                    wasAutoAscendOn = false
                    visibleTimerAscend = 0
                end
            end
        end)
    end
end)

-- LOOP 10: AUTO SPOOF FRIEND BONUS (RUNS IN BACKGROUND)
task.spawn(function()
    while task.wait(1) do -- Berjalan setiap 1 detik agar hemat CPU tapi tetap responsif
        pcall(function()
            local MyTycoon = GetMyTycoon()
            if MyTycoon then
                local valuesFolder = MyTycoon:FindFirstChild("Values")
                if valuesFolder then
                    if valuesFolder:GetAttribute("FriendCount") <= 1 then
                        valuesFolder:SetAttribute("FriendCount", 1)
                    end
                end
            end
        end)
    end
end)

-- =======================================================
-- LOOP 11: AUTO BUY V2 (ALWAYS ACTIVE BACKGROUND PROCESS)
-- =======================================================
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            
            -- ==========================================
            -- TAHAP 1: UNLOCK POWER 'BUYNEXT' (NILAI 1)
            -- ==========================================
            local MyTycoon = GetMyTycoon()
            if MyTycoon then
                local permFolder = MyTycoon:FindFirstChild("Values") and MyTycoon.Values:FindFirstChild("Powers") and MyTycoon.Values.Powers:FindFirstChild("Permanent")
                if permFolder then
                    if permFolder:GetAttribute("BuyNext") ~= 1 then
                        permFolder:SetAttribute("BuyNext", 1)
                    end
                end
            end

            -- ==========================================
            -- TAHAP 2: MODIFIKASI PROPERTIES & ATTRIBUTES UI
            -- ==========================================
            local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
            local buyNextUI = playerGui and playerGui:FindFirstChild("HUD") 
                              and playerGui.HUD:FindFirstChild("Powers") 
                              and playerGui.HUD.Powers:FindFirstChild("BuyNext")
            
            if buyNextUI then
                -- Menggunakan angka murni hasil spy Dex Explorer kamu!
                buyNextUI.Position = UDim2.new(1.69002998, 0, 0.0868578553, 0)
                buyNextUI.Size = UDim2.new(0.800000012, 0, 0.800000012, 0)
                
                -- Paksa nyalakan Property bawaan Roblox
                if not buyNextUI.Visible then
                    buyNextUI.Visible = true
                end

                -- Paksa nyalakan Attribute buatan developer gamenya
                if buyNextUI:GetAttribute("Visible") ~= true then
                    buyNextUI:SetAttribute("Visible", true)
                end
            end
            
        end)
    end
end)

-- =======================================================
-- LOOP 12: AUTO CLICK UI "NICE!" BUTTON (BACKGROUND SERVICE)
-- =======================================================
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
            -- Mengunci langsung struktur folder utama dari Dex Spy milikmu
            local alertButtons = playerGui 
                                 and playerGui:FindFirstChild("Important") 
                                 and playerGui.Important:FindFirstChild("Alert") 
                                 and playerGui.Important.Alert:FindFirstChild("Main") 
                                 and playerGui.Important.Alert.Main:FindFirstChild("Buttons")
            
            if alertButtons then
                -- Melakukan scan otomatis terhadap semua tombol di dalam folder Buttons
                for _, child in ipairs(alertButtons:GetChildren()) do
                    if child:IsA("TextButton") or child:IsA("ImageButton") then
                        
                        -- Cek nama objek atau teks tombol (Ubah ke huruf kecil semua agar anti-salah)
                        local targetName = string.lower(child.Name)
                        local targetText = child:IsA("TextButton") and string.lower(child.Text) or ""
                        
                        -- Jika nama ATAU teks tombol mengandung kata "nice"
                        if string.find(targetName, "nice") or string.find(targetText, "nice") then
                            
                            -- Validasi Kehadiran: Tombol hanya ditekan jika sedang aktif tampil di layar
                            if child.Visible and child.AbsoluteSize.X > 0 and child.AbsoluteSize.Y > 0 then
                                
                                -- Taktik Utama: firesignal (Metode injeksi sinyal klik Roblox)
                                if firesignal then
                                    firesignal(child.MouseButton1Click)
                                    firesignal(child.Activated)
                                else
                                    -- Taktik Cadangan: Menguras getconnections jika executor memiliki limitasi fungsi
                                    local connections = getconnections and getconnections(child.MouseButton1Click)
                                    if connections then
                                        for _, connection in ipairs(connections) do
                                            connection:Fire()
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
end)
