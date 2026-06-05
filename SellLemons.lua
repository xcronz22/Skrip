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

local RebirthMode = "Multiplier" 
local RebirthValue = 2
local SmartMultiplier = 2 -- FITUR BARU: Gigi otomatis untuk Smart Mode (2x atau 10x)
local LastRebirthTime = 0 -- FITUR BARU: Stopwatch pintar penghitung jeda
local UpgradeRemotes = {}
local ToggleObjects = {}

-- Reference elemen Input UI untuk kebutuhan sinkronisasi Load Config
local RebirthInput

-- =======================================================
-- TRIK ANTI-LAG TYCOON BRUTAL 2.0: NATIVE C++ ENGINE BYPASS
-- =======================================================
local TweenService = game:GetService("TweenService")
local oldCreate

oldCreate = hookfunction(TweenService.Create, function(self, instance, tweenInfo, propertyTable)
    -- Jika AutoBuy menyala, kita bajak semua animasi yang mencoba berjalan!
    if Toggles.AutoBuy and instance then
        -- Paksa durasi animasi menjadi 0 detik (Instan) tanpa mengubah fungsi asli properties-nya
        local instantInfo = TweenInfo.new(0, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
        
        -- Lempar kembali ke engine Roblox (C++ Native) agar diproses tanpa lag Lua
        return oldCreate(self, instance, instantInfo, propertyTable)
    end
    
    return oldCreate(self, instance, tweenInfo, propertyTable)
end)

-- ==========================================
-- 1. IDENTIFIKASI PENGALI (HANYA KATA PENUH SAMPAI CENTILLION)
-- ==========================================
local Multipliers = {
    ["thousand"] = 1e3,
    ["million"] = 1e6,
    ["billion"] = 1e9,
    ["trillion"] = 1e12,
    ["quadrillion"] = 1e15,
    ["quintillion"] = 1e18,
    ["sextillion"] = 1e21,
    ["septillion"] = 1e24,
    ["octillion"] = 1e27,
    ["nonillion"] = 1e30,
    ["decillion"] = 1e33,
    ["undecillion"] = 1e36,
    ["duodecillion"] = 1e39,
    ["tredecillion"] = 1e42,
    ["quattuordecillion"] = 1e45,
    ["quindecillion"] = 1e48,
    ["sexdecillion"] = 1e51,
    ["septendecillion"] = 1e54,
    ["octodecillion"] = 1e57,
    ["novemdecillion"] = 1e60,
    ["vigintillion"] = 1e63,
    ["unvigintillion"] = 1e66,
    ["duovigintillion"] = 1e69,
    ["trevingtillion"] = 1e72,
    ["quattuorvigintillion"] = 1e75,
    ["quinvigintillion"] = 1e78,
    ["sexvigintillion"] = 1e81,
    ["septenvigintillion"] = 1e84,
    ["octovigintillion"] = 1e87,
    ["novemvigintillion"] = 1e90,
    ["trigintillion"] = 1e93,
    ["untrigintillion"] = 1e96,
    ["duotrigintillion"] = 1e99,
    ["tretrigintillion"] = 1e102,
    ["trestrigintillion"] = 1e102, -- in-game typo dev tre(s)
    ["quattuortrigintillion"] = 1e105,
    ["quintrigintillion"] = 1e108,
    ["sextrigintillion"] = 1e111,
    ["septentrigintillion"] = 1e114,
    ["octotrigintillion"] = 1e117,
    ["novemtrigintillion"] = 1e120,
    ["quadragintillion"] = 1e123,
    ["unquadragintillion"] = 1e126,
    ["duoquadragintillion"] = 1e129,
    ["trequadragintillion"] = 1e132,
    ["quattuorquadragintillion"] = 1e135,
    ["quinquadragintillion"] = 1e138,
    ["sexquadragintillion"] = 1e141,
    ["septenquadragintillion"] = 1e144,
    ["octoquadragintillion"] = 1e147,
    ["novemquadragintillion"] = 1e150,
    ["quinquagintillion"] = 1e153,
    ["unquinquagintillion"] = 1e156,
    ["duoquinquagintillion"] = 1e159,
    ["trequinquagintillion"] = 1e162,
    ["tresquinquagintillion"] = 1e162, -- in-game typoe dev tre(s)
    ["quattuorquinquagintillion"] = 1e165,
    ["quinquinquagintillion"] = 1e168,
    ["sexquinquagintillion"] = 1e171,
    ["septenquinquagintillion"] = 1e174,
    ["octoquinquagintillion"] = 1e177,
    ["novemquinquagintillion"] = 1e180,
    ["sexagintillion"] = 1e183,
    ["unsexagintillion"] = 1e186,
    ["duosexagintillion"] = 1e189,
    ["tresexagintillion"] = 1e192,
    ["quattuorsexagintillion"] = 1e195,
    ["quinsexagintillion"] = 1e198,
    ["sexsexagintillion"] = 1e201,
    ["septensexagintillion"] = 1e204,
    ["octosexagintillion"] = 1e207,
    ["novemsexagintillion"] = 1e210,
    ["septuagintillion"] = 1e213,
    ["unseptuagintillion"] = 1e216,
    ["duoseptuagintillion"] = 1e219,
    ["treseptuagintillion"] = 1e222,
    ["quattuorseptuagintillion"] = 1e225,
    ["quinseptuagintillion"] = 1e228,
    ["sexseptuagintillion"] = 1e231,
    ["septenseptuagintillion"] = 1e234,
    ["octoseptuagintillion"] = 1e237,
    ["novemseptuagintillion"] = 1e240,
    ["octogintillion"] = 1e243,
    ["unoctogintillion"] = 1e246,
    ["duooctogintillion"] = 1e249,
    ["treoctogintillion"] = 1e252,
    ["quattuoroctogintillion"] = 1e255,
    ["quinoctogintillion"] = 1e258,
    ["sexoctogintillion"] = 1e261,
    ["septenoctogintillion"] = 1e264,
    ["octooctogintillion"] = 1e267,
    ["novemoctogintillion"] = 1e270,
    ["nonagintillion"] = 1e273,
    ["unnonagintillion"] = 1e276,
    ["duononagintillion"] = 1e279,
    ["trenonagintillion"] = 1e282,
    ["quattuornonagintillion"] = 1e285,
    ["quinnonagintillion"] = 1e288,
    ["sexnonagintillion"] = 1e291,
    ["septennonagintillion"] = 1e294,
    ["octononagintillion"] = 1e297,
    ["novemnonagintillion"] = 1e300,
    ["centillion"] = 1e303
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

ToggleObjects.AutoUpgrade = Window:AddToggle("Auto Upgrade", false, function(Value) Toggles.AutoUpgrade = Value end)
ToggleObjects.AutoRebirth = Window:AddToggle("Auto Rebirth", false, function(Value) Toggles.AutoRebirth = Value end)
ToggleObjects.RebirthTP = Window:AddToggle("TP After Rebirth", true, function(Value) Toggles.RebirthTP = Value end)
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
    Window:AddLabel("Background Features Active: Auto Buy Power & Auto Answer Phone.")
    Window:AddLabel("Silent Harvest: Approach fruit-bearing trees to collect the results.")
    Window:AddLabel("For UI Rebirth Evolve Ascension will close after certain time")
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

-- LOOP 1: AUTO HARVEST
task.spawn(function()
    while task.wait(0.1) do
        if Toggles.AutoHarvest then
            pcall(function() 
                local MyTycoon = GetMyTycoon()
                local char = LocalPlayer.Character
                local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                local humanoid = char and char:FindFirstChild("Humanoid")
                
                if MyTycoon and rootPart and humanoid and humanoid.Health > 0 then
                    local originalCFrame = rootPart.CFrame
                    local hasTeleported = false
                    local stopFarming = false 

                    for i = 1, 12 do
                        if not Toggles.AutoHarvest or stopFarming then break end 
                        local tycoon = Workspace:FindFirstChild("Tycoon" .. i)
                        if tycoon then
                            local constantFolder = tycoon:FindFirstChild("Constant")
                            if constantFolder and constantFolder:FindFirstChild("Trees") then
                                for _, tree in pairs(constantFolder.Trees:GetChildren()) do
                                    if not Toggles.AutoHarvest then stopFarming = true break end
                                    if tree.Name == "LemonTree" then
                                        local readyFruits = {}
                                        for _, part in pairs(tree:GetChildren()) do
                                            if part.Name == "Fruit" then
                                                local clickDetector = part:FindFirstChildWhichIsA("ClickDetector", true)
                                                if clickDetector then table.insert(readyFruits, {Part = part, CD = clickDetector}) end
                                            end
                                        end

                                        if #readyFruits > 0 then
                                            hasTeleported = true
                                            humanoid.PlatformStand = true 
                                            rootPart.CFrame = CFrame.new(readyFruits[1].Part.Position - Vector3.new(0, 15, 0)) * CFrame.Angles(math.rad(90), 0, 0)
                                            task.wait(0.2) 
                                            while #readyFruits > 0 and Toggles.AutoHarvest and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") do
                                                for _, fruitData in pairs(readyFruits) do
                                                    pcall(function() 
                                                        if fruitData.Part and fruitData.Part.Parent then fireclickdetector(fruitData.CD) end
                                                    end)
                                                end
                                                task.wait(0.1) 
                                                readyFruits = {}
                                                for _, part in pairs(tree:GetChildren()) do
                                                    if part.Name == "Fruit" and part:FindFirstChildWhichIsA("ClickDetector", true) then
                                                        table.insert(readyFruits, {Part = part, CD = part:FindFirstChildWhichIsA("ClickDetector", true)})
                                                    end
                                                end
                                            end
                                            task.wait(0.1)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    
                    if hasTeleported and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        task.wait(0.2)
                        LocalPlayer.Character.Humanoid.PlatformStand = false
                        LocalPlayer.Character.HumanoidRootPart.CFrame = originalCFrame
                    end
                end
            end)
        end
    end
end)

-- =======================================================
-- LOOP 2: AUTO BUY (SUPER OPTIMIZED - ZERO FPS DROP)
-- =======================================================
task.spawn(function()
    while task.wait(0.5) do -- Jeda dinaikkan jadi 0.5s agar tidak spam CPU
        if Toggles.AutoBuy then
            pcall(function() 
                local MyTycoon = GetMyTycoon()
                local char = LocalPlayer.Character
                local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                
                if MyTycoon and rootPart then
                    local purchases = MyTycoon:FindFirstChild("Purchases")
                    if purchases then
                        for _, purchaseItem in ipairs(purchases:GetChildren()) do
                            if not Toggles.AutoBuy then return end
                            
                            local buttonsFolder = purchaseItem:FindFirstChild("Buttons")
                            if buttonsFolder then
                                for _, item in ipairs(buttonsFolder:GetDescendants()) do
                                    if not Toggles.AutoBuy then return end
                                    
                                    if item:IsA("TouchTransmitter") or item.Name == "TouchInterest" then
                                        local target = item.Parent
                                        
                                        -- INSTAN: Hapus inner task.wait() agar skrip jalan mulus
                                        if target and target:IsA("BasePart") and target.CanTouch then
                                            pcall(function()
                                                firetouchinterest(rootPart, target, 0)
                                                firetouchinterest(rootPart, target, 1)
                                            end)
                                        end
                                        
                                    elseif item:IsA("ProximityPrompt") then
                                        if item.Enabled and item.Parent and item.Parent:IsA("BasePart") and item.Parent.Transparency < 0.8 then
                                            pcall(function() fireproximityprompt(item) end)
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
-- LOOP 3: AUTO UPGRADE & CLICK (AGRESIF & HIT-AND-RUN)
-- =======================================================
local clickTargets = {"LemonDepot", "LemonLabs", "LemonRepublic", "LemonRobotics", "LemonStand", "LemonTrading", "LemonDash", "LemonX"}
local activeUpgradeThreads = {} 

task.spawn(function()
    -- [BAGIAN A]: WAKE INCOME STREAM (AUTO CLICK SUPER CEPAT)
    for _, targetName in ipairs(clickTargets) do
        task.spawn(function()
            -- Jeda diperkecil jadi 0.05 detik (20 klik per detik per target)
            while task.wait(0.05) do 
                if Toggles.AutoUpgrade then
                    pcall(function()
                        local MyTycoon = GetMyTycoon()
                        local wakeRemote = MyTycoon and MyTycoon:FindFirstChild("Remotes") and MyTycoon.Remotes:FindFirstChild("WakeIncomeStream")
                        
                        if wakeRemote and wakeRemote:IsA("RemoteFunction") then
                            -- BUNGKUS TASK.SPAWN: Tembak dan lupakan, jangan tunggu balasan server!
                            task.spawn(function()
                                pcall(function() wakeRemote:InvokeServer(targetName) end)
                            end)
                        end
                    end)
                end
            end
        end)
    end

    -- [BAGIAN B]: AUTO UPGRADE (SPAMMER ENGINE)
    while task.wait(1) do 
        if Toggles.AutoUpgrade then
            pcall(function()
                local MyTycoon = GetMyTycoon()
                if MyTycoon and MyTycoon:FindFirstChild("Purchases") then
                    for _, desc in ipairs(MyTycoon.Purchases:GetDescendants()) do
                        if desc:IsA("RemoteFunction") and desc.Name == "Upgrade" then
                            
                            if not activeUpgradeThreads[desc] then
                                activeUpgradeThreads[desc] = true
                                
                                task.spawn(function()
                                    -- JEDA EKSTREM: 0.03 detik (Sangat cepat tapi di ambang batas aman Roblox)
                                    while task.wait(0.03) do
                                        if not Toggles.AutoUpgrade then 
                                            task.wait(0.5) 
                                            continue 
                                        end
                                        
                                        local isValid = false
                                        pcall(function() if desc and desc.Parent then isValid = true end end)
                                        
                                        if isValid then
                                            -- BUNGKUS TASK.SPAWN: Bypass delay ping!
                                            task.spawn(function()
                                                pcall(function() desc:InvokeServer(1) end)
                                            end)
                                        else
                                            activeUpgradeThreads[desc] = nil
                                            break 
                                        end
                                    end
                                end)
                            end
                            
                        end
                    end
                end
            end)
        end
    end
end)

-- LOOP 4: AUTO PHONE (RUNS IN BACKGROUND SEKARANG)
task.spawn(function()
    while task.wait(0.5) do
        pcall(function() 
            local MyTycoon = GetMyTycoon()
            if MyTycoon then
                local phoneGui = LocalPlayer.PlayerGui:FindFirstChild("Phone")
                local phoneFrame = phoneGui and phoneGui:FindFirstChild("Phone")
                if phoneFrame and phoneFrame.Visible then
                    local remotes = MyTycoon:FindFirstChild("Remotes")
                    if remotes and remotes:FindFirstChild("PhoneOffer") then
                        task.wait(0.5)
                        pcall(function() remotes.PhoneOffer:FireServer("Raise") end)
                        task.wait(0.5)
                        pcall(function() remotes.PhoneOffer:FireServer("Accept") end)
                        task.wait(0.5)
                        phoneFrame.Visible = false
                        task.wait(0.5)
                    end
                end
            end
        end)
    end
end)

-- =======================================================
-- LOOP 5: DYNAMIC SMART AUTO REBIRTH (AUTO-SHIFT GEAR)
-- =======================================================
local wasAutoRebirthOn = false
local visibleTimerRebirth = 0
local isRebirthing = false 
local cachedTargetCFrame = nil 
local cachedTargetSize = nil 

local function EnsureSafeZone(targetCFrame, targetSize)
    local safeZoneName = "BrutalSafeZone_Void"
    local safeZone = workspace:FindFirstChild(safeZoneName)

    if not safeZone then
        safeZone = Instance.new("Part")
        safeZone.Name = safeZoneName
        safeZone.Size = Vector3.new(5, 1, 5) 
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
                    -- RESET TIMER SAAT BARU DINYALAKAN (Mencegah instant downgrade)
                    if not wasAutoRebirthOn then
                        LastRebirthTime = os.clock() 
                    end
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

                            -- ==================================================
                            -- FITUR DOWNGRADE (AUTO-SHIFT KE 2X)
                            -- ==================================================
                            if RebirthMode == "Smart" and SmartMultiplier == 10 then
                                if LastRebirthTime > 0 and (os.clock() - LastRebirthTime > 30) then
                                    SmartMultiplier = 2 -- Ngeden kelamaan, balik ke 2x!
                                end
                            end

                            if RebirthMode == "Multiplier" then
                                shouldRebirth = IsPotentialEnough(basePot, expPot, baseCur, expCur, tonumber(RebirthValue) or 2)
                            elseif RebirthMode == "Smart" then
                                -- Gunakan SmartMultiplier yang dinamis (2 atau 10)
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
                                    
                                    -- ==================================================
                                    -- FITUR UPGRADE (AUTO-SHIFT KE 10X)
                                    -- ==================================================
                                    if RebirthMode == "Smart" then
                                        local currentTime = os.clock()
                                        -- Jika waktu tembus < 5 detik saat di gigi 2x, persiapkan gigi 10x untuk putaran depan
                                        if LastRebirthTime > 0 and (currentTime - LastRebirthTime <= 5) and SmartMultiplier == 2 then
                                            SmartMultiplier = 10
                                        end
                                        LastRebirthTime = currentTime -- Catat waktu eksekusi
                                    end

                                    pcall(function()
                                        local voidFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Void")
                                        if voidFolder then
                                            local parts = voidFolder:GetChildren()
                                            if parts[6] and parts[6]:IsA("BasePart") then
                                                cachedTargetCFrame = parts[6].CFrame 
                                                cachedTargetSize = parts[6].Size 
                                            end
                                        end
                                    end)

                                    task.spawn(function()
                                        pcall(function() 
                                            rebirthRemote:InvokeServer()
                                            UpgradeRemotes = {} 
                                            
                                            -- HANYA TELEPORT JIKA TOGGLE MENYALA
                                            if Toggles.RebirthTP then
                                                local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                                                local root = char:WaitForChild("HumanoidRootPart", 10)
                                                
                                                task.wait(1.5) 
                                                
                                                if root and cachedTargetCFrame and cachedTargetSize then
                                                    EnsureSafeZone(cachedTargetCFrame, cachedTargetSize)
                                                    local targetTopY = cachedTargetCFrame.Position.Y + (cachedTargetSize.Y / 2)
                                                    root.CFrame = CFrame.new(cachedTargetCFrame.Position.X, targetTopY + 3, cachedTargetCFrame.Position.Z) 
                                                    root.Anchored = false
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
                    
                    pcall(function()
                        local char = LocalPlayer.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        if root and root.Anchored then root.Anchored = false end
                    end)
                    
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
    local powerNames = {"Manage", "BuyNext", "ClickFruitValue", "UpgradeStack", "WalkSpeed"}
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
