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
    AutoHarvest = false,
    AutoDrop = false,
    AutoBuy = false,
    AutoUpgrade = false,
    AutoPhone = false,
    AutoRebirth = false,
    AutoEvolve = false
}

local RebirthMode = "Multiplier" 
local RebirthValue = 2
local UpgradeAmount = 1
local UpgradeRemotes = {}
local UI_Buttons = {}

local ToggleDefinitions = {
    {Name = "AutoHarvest", Text = "Auto Steal Lemons"},
    {Name = "AutoDrop", Text = "Auto Collect Drops"},
    {Name = "AutoBuy", Text = "Auto Buy Buttons"},
    {Name = "AutoUpgrade", Text = "Auto Upgrade Max"},
    {Name = "AutoPhone", Text = "Auto Answer Phone"},
    {Name = "AutoRebirth", Text = "Auto Rebirth"},
    {Name = "AutoEvolve", Text = "Auto Evolve"}
}

local function SaveConfig()
    local configData = {
        Toggles = Toggles,
        RebirthMode = RebirthMode,
        RebirthValue = RebirthValue,
        UpgradeAmount = UpgradeAmount
    }
    pcall(function()
        if writefile then
            writefile(FILE_NAME, HttpService:JSONEncode(configData))
        end
    end)
end

local function LoadConfig()
    pcall(function()
        if isfile and readfile and isfile(FILE_NAME) then
            local decoded = HttpService:JSONDecode(readfile(FILE_NAME))
            if decoded then
                if decoded.Toggles then
                    for k, v in pairs(decoded.Toggles) do Toggles[k] = v end
                end
                if decoded.RebirthMode then RebirthMode = decoded.RebirthMode end
                if decoded.RebirthValue then RebirthValue = decoded.RebirthValue end
                if decoded.UpgradeAmount then UpgradeAmount = decoded.UpgradeAmount end
            end
        end
    end)
end

-- ==========================================
-- 1. PEMBUATAN UI MOBILE-FRIENDLY
-- ==========================================
if CoreGui:FindFirstChild("LemonTycoonGUI") then
    CoreGui.LemonTycoonGUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LemonTycoonGUI"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 520) -- Diperpanjang untuk mengakomodasi tombol baru
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -230)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🍋 Lemon Auto V5.6"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 35)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 35)
MinimizeBtn.Position = UDim2.new(1, -60, 0, 0)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 24
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = MainFrame

local LemonIcon = Instance.new("TextButton")
LemonIcon.Size = UDim2.new(0, 45, 0, 45)
LemonIcon.Position = UDim2.new(0.5, -22, 0, 20)
LemonIcon.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
LemonIcon.Text = "🍋"
LemonIcon.TextSize = 20
LemonIcon.Visible = false
LemonIcon.Active = true
LemonIcon.Draggable = true
LemonIcon.Parent = ScreenGui

local UICornerIcon = Instance.new("UICorner")
UICornerIcon.CornerRadius = UDim.new(1, 0)
UICornerIcon.Parent = LemonIcon

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 8)
UICornerMain.Parent = MainFrame

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false LemonIcon.Visible = true end)
LemonIcon.MouseButton1Click:Connect(function() MainFrame.Visible = true LemonIcon.Visible = false end)

local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -45)
Container.Position = UDim2.new(0, 10, 0, 40)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 3
Container.CanvasSize = UDim2.new(0, 0, 0, 0)
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = Container

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 80)
end)

-- ==========================================
-- 2. ENGINE VALUE CONVERTER & UTILITIES
-- ==========================================
local Multipliers = {
    ["k"] = 1e3, ["thousand"] = 1e3,
    ["m"] = 1e6, ["million"] = 1e6,
    ["b"] = 1e9, ["billion"] = 1e9,
    ["t"] = 1e12, ["trillion"] = 1e12,
    ["qd"] = 1e15, ["quadrillion"] = 1e15,
    ["qn"] = 1e18, ["quintillion"] = 1e18,
    ["sx"] = 1e21, ["sextillion"] = 1e21,
    ["sp"] = 1e24, ["septillion"] = 1e24,
    ["o"] = 1e27, ["octillion"] = 1e27,
    ["n"] = 1e30, ["nonillion"] = 1e30,
    ["d"] = 1e33, ["decillion"] = 1e33,
    ["ud"] = 1e36, ["undecillion"] = 1e36,
    ["dd"] = 1e39, ["duodecillion"] = 1e39,
    ["td"] = 1e42, ["tredecillion"] = 1e42,
    ["qad"]= 1e45, ["quattuordecillion"] = 1e45,
    ["qid"]= 1e48, ["quindecillion"] = 1e48,
    ["sxd"]= 1e51, ["sexdecillion"] = 1e51,
    ["spd"]= 1e54, ["septendecillion"] = 1e54,
    ["odc"]= 1e57, ["octodecillion"] = 1e57,
    ["ndc"]= 1e60, ["novemdecillion"] = 1e60,
    ["v"]  = 1e63, ["vigintillion"] = 1e63,
    ["uv"] = 1e66, ["unvigintillion"] = 1e66,
    ["dv"] = 1e69, ["duovigintillion"] = 1e69,
    ["tv"] = 1e72, ["trevigintillion"] = 1e72,
    ["qav"]= 1e75, ["quattuorvigintillion"] = 1e75,
    ["qiv"]= 1e78, ["quinvigintillion"] = 1e78,
    ["sxv"]= 1e81, ["sexvigintillion"] = 1e81,
    ["spv"]= 1e84, ["septenvigintillion"] = 1e84,
    ["ocv"]= 1e87, ["octovigintillion"] = 1e87,
    ["nov"]= 1e90, ["novemvigintillion"] = 1e90,
    ["tg"] = 1e93, ["trigintillion"] = 1e93,
    ["utg"]= 1e96, ["untrigintillion"] = 1e96,
    ["dtg"]= 1e99, ["duotrigintillion"] = 1e99,
    ["ttg"]= 1e102, ["tretrigintillion"] = 1e102,
    ["qatg"]=1e105, ["quattuortrigintillion"] = 1e105,
    ["qitg"]=1e108, ["quintrigintillion"] = 1e108,
    ["sxtg"]=1e111, ["sextrigintillion"] = 1e111,
    ["sptg"]=1e114, ["septentrigintillion"] = 1e114,
    ["otg"]= 1e117, ["octotrigintillion"] = 1e117,
    ["notg"]=1e120, ["novemtrigintillion"] = 1e120,
    ["qag"]= 1e123, ["quadragintillion"] = 1e123,
    ["qig"]= 1e153, ["quinquagintillion"] = 1e153,
    ["sxg"]= 1e183, ["sexagintillion"] = 1e183,
    ["spg"]= 1e213, ["septuagintillion"] = 1e213,
    ["ocg"]= 1e243, ["octogintillion"] = 1e243,
    ["nog"]= 1e273, ["nonagintillion"] = 1e273,
    ["c"]  = 1e303, ["centillion"] = 1e303
}

local function parseStringToNumber(text)
    if not text then return 0 end
    text = string.lower(string.gsub(text, ",", "")) 
    local numStr = string.match(text, "[%d%.]+") 
    if not numStr then return 0 end
    local num = tonumber(numStr) or 0
    local suffixStr = string.match(text, "[a-z]+") 
    if suffixStr and Multipliers[suffixStr] then return num * Multipliers[suffixStr] end
    return num
end

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
-- 3. UI ELEMENTS: SAVE/LOAD BUTTONS
-- ==========================================
local ConfigFrame = Instance.new("Frame")
ConfigFrame.Size = UDim2.new(1, 0, 0, 35)
ConfigFrame.BackgroundTransparency = 1
ConfigFrame.Parent = Container

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0.48, 0, 1, 0)
SaveBtn.Position = UDim2.new(0, 0, 0, 0)
SaveBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
SaveBtn.Text = "💾 Save"
SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBtn.Font = Enum.Font.GothamBold
SaveBtn.TextSize = 13
SaveBtn.Parent = ConfigFrame

local UICornerSave = Instance.new("UICorner")
UICornerSave.CornerRadius = UDim.new(0, 5)
UICornerSave.Parent = SaveBtn

local LoadBtn = Instance.new("TextButton")
LoadBtn.Size = UDim2.new(0.48, 0, 1, 0)
LoadBtn.Position = UDim2.new(0.52, 0, 0, 0)
LoadBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 100)
LoadBtn.Text = "📂 Load"
LoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadBtn.Font = Enum.Font.GothamBold
LoadBtn.TextSize = 13
LoadBtn.Parent = ConfigFrame

local UICornerLoad = Instance.new("UICorner")
UICornerLoad.CornerRadius = UDim.new(0, 5)
UICornerLoad.Parent = LoadBtn

-- ==========================================
-- 4. UI ELEMENTS: TOGGLES & INPUTS
-- ==========================================
local function CreateToggle(name, text)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Btn.Text = text .. " [OFF]"
    Btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Btn.Parent = Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Btn

    UI_Buttons[name] = Btn

    Btn.MouseButton1Click:Connect(function()
        Toggles[name] = not Toggles[name]
        
        -- FAILSAFE: Pembebas Kunci PlatformStand
        if name == "AutoHarvest" and not Toggles[name] then
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.PlatformStand = false
                end
            end)
        end

        if Toggles[name] then
            Btn.Text = text .. " [ON]"
            Btn.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            Btn.Text = text .. " [OFF]"
            Btn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)
end

for _, def in pairs(ToggleDefinitions) do
    CreateToggle(def.Name, def.Text)
end

-- INPUT 1: TARGET REBIRTH
local InputFrame = Instance.new("Frame")
InputFrame.Size = UDim2.new(1, 0, 0, 40)
InputFrame.BackgroundTransparency = 1
InputFrame.Parent = Container

local InputLabel = Instance.new("TextLabel")
InputLabel.Size = UDim2.new(0.4, 0, 1, 0)
InputLabel.Text = "Target Rebirth:"
InputLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
InputLabel.Font = Enum.Font.GothamBold
InputLabel.TextSize = 12
InputLabel.BackgroundTransparency = 1
InputLabel.Parent = InputFrame

local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(0.55, 0, 0.8, 0)
TextBox.Position = UDim2.new(0.45, 0, 0.1, 0)
TextBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TextBox.Text = "Smart (2x)"
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.Font = Enum.Font.Gotham
TextBox.TextSize = 12
TextBox.ClearTextOnFocus = false
TextBox.Parent = InputFrame

local UICornerBox = Instance.new("UICorner")
UICornerBox.CornerRadius = UDim.new(0, 4)
UICornerBox.Parent = TextBox

TextBox.FocusLost:Connect(function()
    local input = string.lower(TextBox.Text)
    if input == "smart" then
        RebirthMode = "Multiplier"
        RebirthValue = 2
        TextBox.Text = "Smart (2x)"
    elseif string.match(input, "^[%d%.]+x$") then
        local mult = tonumber(string.match(input, "[%d%.]+"))
        if mult then
            RebirthMode = "Multiplier"
            RebirthValue = mult
            TextBox.Text = mult .. "x"
        end
    else
        local val = parseStringToNumber(input)
        if val and val > 0 then 
            RebirthMode = "Target"
            RebirthValue = val 
            TextBox.Text = tostring(val)
        else 
            if RebirthMode == "Multiplier" then TextBox.Text = RebirthValue .. "x" else TextBox.Text = tostring(RebirthValue) end
        end
    end
end)

-- INPUT 2: JUMLAH UPGRADE 
local UpgradeInputFrame = Instance.new("Frame")
UpgradeInputFrame.Size = UDim2.new(1, 0, 0, 40)
UpgradeInputFrame.BackgroundTransparency = 1
UpgradeInputFrame.Parent = Container

local UpgradeInputLabel = Instance.new("TextLabel")
UpgradeInputLabel.Size = UDim2.new(0.4, 0, 1, 0)
UpgradeInputLabel.Text = "Jumlah Upgrade:"
UpgradeInputLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
UpgradeInputLabel.Font = Enum.Font.GothamBold
UpgradeInputLabel.TextSize = 12
UpgradeInputLabel.BackgroundTransparency = 1
UpgradeInputLabel.Parent = UpgradeInputFrame

local UpgradeTextBox = Instance.new("TextBox")
UpgradeTextBox.Size = UDim2.new(0.55, 0, 0.8, 0)
UpgradeTextBox.Position = UDim2.new(0.45, 0, 0.1, 0)
UpgradeTextBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
UpgradeTextBox.Text = "1"
UpgradeTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
UpgradeTextBox.Font = Enum.Font.Gotham
UpgradeTextBox.TextSize = 12
UpgradeTextBox.ClearTextOnFocus = false
UpgradeTextBox.Parent = UpgradeInputFrame

local UICornerUpgradeBox = Instance.new("UICorner")
UICornerUpgradeBox.CornerRadius = UDim.new(0, 4)
UICornerUpgradeBox.Parent = UpgradeTextBox

UpgradeTextBox.FocusLost:Connect(function()
    local val = tonumber(UpgradeTextBox.Text)
    if val and val > 0 then
        UpgradeAmount = math.floor(val)
        UpgradeTextBox.Text = tostring(UpgradeAmount)
    else
        UpgradeTextBox.Text = tostring(UpgradeAmount)
    end
end)

-- ==========================================
-- 5. BUTTON SEWER & DOORS (TAP FUNCTIONS)
-- ==========================================
local function CreateTapButton(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(60, 100, 160)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Btn.Parent = Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Btn

    Btn.MouseButton1Click:Connect(function()
        Btn.Text = "⏳ Processing..."
        task.spawn(function()
            pcall(callback)
            task.wait(1)
            Btn.Text = text
        end)
    end)
    return Btn
end

local isCashVineLooping = false

 CreateTapButton("Auto Sewer [TAP]", function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local sewer = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Sewer")
    if not sewer then return end

    -- 1. Trigger SewerAlien & Talk (Tanpa TP ke Alien)
    pcall(function()
        local alienFolder = sewer:FindFirstChild("SewerAlien")
        if alienFolder then
            -- Memicu trigger awal
            local trig = alienFolder:FindFirstChild("Trigger")
            if trig and trig:IsA("RemoteFunction") then trig:InvokeServer() end
            
            -- Eksekusi langsung Prompt "Talk" dari jauh tanpa TP
            local alien = alienFolder:FindFirstChild("Alien")
            if alien then
                local alienRoot = alien:FindFirstChild("HumanoidRootPart")
                if alienRoot then
                    local talkPrompt = alienRoot:FindFirstChild("Prompt")
                    if talkPrompt and talkPrompt:IsA("ProximityPrompt") then
                        fireproximityprompt(talkPrompt)
                    end
                end
            end
            
            -- Ambil UFOKey
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
    end)

    -- 2. Temukan dan Interaksi dengan Alien Tersembunyi di DoorsGreen
    pcall(function()
        local doorsGreen = sewer:FindFirstChild("DoorsGreen")
        if doorsGreen then
            for _, desc in pairs(doorsGreen:GetDescendants()) do
                if desc:IsA("Humanoid") then
                    local alienModel = desc.Parent
                    local alienRoot = alienModel:FindFirstChild("HumanoidRootPart")
                    
                    -- Kita tetap sisakan TP di sini just in case alien di labirin belum ke-render sempurna oleh server
                    if alienRoot then
                        root.CFrame = alienRoot.CFrame
                        task.wait(0.5)
                    end
                    local prompt = alienModel:FindFirstChild("ListenPrompt", true) or alienModel:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt then fireproximityprompt(prompt) end
                    break 
                end
            end
        end
    end)

    -- 3. Buka Kunci Penjara CashVine Sekali
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
            if unlock and unlock:IsA("RemoteFunction") then
                unlock:InvokeServer()
            end
        end
    end)

    -- 4. Inisiasi Loop Auto CashVine Berkelanjutan (Berjalan di Background)
    if not isCashVineLooping then
        isCashVineLooping = true
        task.spawn(function()
            while task.wait(5) do
                pcall(function()
                    local currSewer = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Sewer")
                    if not currSewer then return end
                    
                    local cvFolder = currSewer:FindFirstChild("CashVine")
                    if cvFolder then
                        local cvModel = cvFolder:FindFirstChild("CashVine")
                        if cvModel then
                            local cvMesh = cvModel:FindFirstChild("CashVine")
                            if cvMesh then
                                local attach = cvMesh:FindFirstChild("Attachment")
                                local label = attach and attach:FindFirstChild("Gui") and attach.Gui:FindFirstChild("Label")
                                
                                if label and label.Text == "READY" then
                                    local useFunc = cvModel:FindFirstChild("Use")
                                    if useFunc and useFunc:IsA("RemoteFunction") then
                                        useFunc:InvokeServer()
                                    end
                                    
                                    local prompt = attach:FindFirstChild("Prompt")
                                    if prompt and prompt:IsA("ProximityPrompt") then
                                        fireproximityprompt(prompt)
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end
end)

-- ==========================================
-- 6. FULLY SHIELDED MULTI-THREAD ENGINE (V5.6)
-- ==========================================

local function SyncLoadedDataToUI()
    for _, def in pairs(ToggleDefinitions) do
        local btn = UI_Buttons[def.Name]
        if btn then
            if Toggles[def.Name] then
                btn.Text = def.Text .. " [ON]"
                btn.TextColor3 = Color3.fromRGB(100, 255, 100)
            else
                btn.Text = def.Text .. " [OFF]"
                btn.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end
    end
    if RebirthMode == "Multiplier" then
        if RebirthValue == 2 then
            TextBox.Text = "Smart (2x)"
        else
            TextBox.Text = RebirthValue .. "x"
        end
    else
        TextBox.Text = tostring(RebirthValue)
    end
    UpgradeTextBox.Text = tostring(UpgradeAmount)
end

SaveBtn.MouseButton1Click:Connect(function() SaveConfig() SaveBtn.Text = "✅ Saved!" task.wait(1) SaveBtn.Text = "💾 Save" end)
LoadBtn.MouseButton1Click:Connect(function() LoadConfig() SyncLoadedDataToUI() LoadBtn.Text = "✅ Loaded!" task.wait(1) LoadBtn.Text = "📂 Load" end)

LocalPlayer.Idled:Connect(function()
    pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end)
end)

-- LOOP 1: AUTO HARVEST (PERBAIKAN ANTI-NYANGKUT)
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
                                    if not Toggles.AutoHarvest then 
                                        stopFarming = true 
                                        break 
                                    end
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

-- LOOP 2: AUTO BUY (Anti-Crash)
task.spawn(function()
    while task.wait(0.1) do
        if Toggles.AutoBuy then
            pcall(function() 
                local MyTycoon = GetMyTycoon()
                local char = LocalPlayer.Character
                local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                
                if MyTycoon and rootPart then
                    local purchases = MyTycoon:FindFirstChild("Purchases")
                    if purchases then
                        local purchaseItems = purchases:GetChildren()
                        for _, purchaseItem in pairs(purchaseItems) do
                            if not Toggles.AutoBuy then return end
                            local buttonsFolder = purchaseItem:FindFirstChild("Buttons")
                            if buttonsFolder then
                                local buttons = buttonsFolder:GetDescendants()
                                for _, item in pairs(buttons) do
                                    if not Toggles.AutoBuy then return end
                                    pcall(function() 
                                        if item:IsA("TouchTransmitter") or item.Name == "TouchInterest" then
                                            local target = item.Parent
                                            if target then
                                                firetouchinterest(rootPart, target, 0)
                                                task.wait(0.01)
                                                if target and target.Parent then 
                                                    firetouchinterest(rootPart, target, 1)
                                                end
                                            end
                                        elseif item:IsA("ProximityPrompt") then
                                            fireproximityprompt(item)
                                        end
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

-- LOOP 3: AUTO UPGRADE
local lastScanTime = 0
local clickTargets = {"LemonDepot", "LemonLabs", "LemonRepublic", "LemonRobotics", "LemonStand", "LemonTrading", "LemonDash", "LemonX"}
local clickIndex = 1 

task.spawn(function()
    while task.wait(0.04) do 
        if Toggles.AutoUpgrade then
            pcall(function() 
                local MyTycoon = GetMyTycoon()
                if MyTycoon then
                    
                    local remotes = MyTycoon:FindFirstChild("Remotes")
                    local wakeRemote = remotes and remotes:FindFirstChild("WakeIncomeStream")
                    
                    if wakeRemote and wakeRemote:IsA("RemoteFunction") then
                        local targetName = clickTargets[clickIndex]
                        
                        task.spawn(function()
                            pcall(function() 
                                wakeRemote:InvokeServer(targetName) 
                            end)
                        end)
                        
                        clickIndex = clickIndex + 1
                        if clickIndex > #clickTargets then
                            clickIndex = 1 
                        end
                    end

                    if #UpgradeRemotes == 0 or (tick() - lastScanTime) > 5 then
                        RefreshUpgradeRemotes()
                        lastScanTime = tick()
                    end

                    for i = #UpgradeRemotes, 1, -1 do
                        if not Toggles.AutoUpgrade then return end
                        local remote = UpgradeRemotes[i]
                        
                        local isValid = false
                        pcall(function() if remote and remote.Parent then isValid = true end end)

                        if isValid then
                            task.spawn(function()
                                pcall(function() 
                                    remote:InvokeServer(UpgradeAmount) 
                                end)
                            end)
                        else
                            table.remove(UpgradeRemotes, i)
                        end
                    end
                end
            end)
        end
    end
end)

-- LOOP 4: AUTO PHONE
task.spawn(function()
    while task.wait(0.5) do
        if Toggles.AutoPhone then
            pcall(function() 
                local MyTycoon = GetMyTycoon()
                if MyTycoon then
                    local phoneGui = LocalPlayer.PlayerGui:FindFirstChild("Phone")
                    local phoneFrame = phoneGui and phoneGui:FindFirstChild("Phone")
                    if phoneFrame and phoneFrame.Visible then
                        local remotes = MyTycoon:FindFirstChild("Remotes")
                        if remotes and remotes:FindFirstChild("PhoneOffer") then
                            task.wait(3)
                            pcall(function() remotes.PhoneOffer:FireServer("Raise") end)
                            task.wait(3)
                            pcall(function() remotes.PhoneOffer:FireServer("Accept") end)
                            task.wait(2)
                        end
                    end
                end
            end)
        end
    end
end)

-- LOOP 5: AUTO REBIRTH
task.spawn(function()
    while task.wait(0.5) do
        if Toggles.AutoRebirth then
            pcall(function() 
                local MyTycoon = GetMyTycoon()
                if MyTycoon then
                    local rebirthGui = LocalPlayer.PlayerGui:FindFirstChild("Rebirth")
                    local investorsMenu = rebirthGui and rebirthGui:FindFirstChild("InvestorsMenu", true) 
                    local body = investorsMenu and investorsMenu:FindFirstChild("Body")

                    if body then
                        local potentialLabel = body:FindFirstChild("Potential", true) and body.Potential:FindFirstChild("Quantity")
                        local currentLabel = body:FindFirstChild("Amount", true) and body.Amount:FindFirstChild("Quantity")

                        if potentialLabel and currentLabel then
                            local currentPotential = parseStringToNumber(potentialLabel.Text)
                            local currentInvestors = parseStringToNumber(currentLabel.Text)

                            local shouldRebirth = false
                            
                            if RebirthMode == "Multiplier" then
                                if currentPotential >= (currentInvestors * RebirthValue) then
                                    shouldRebirth = true
                                end
                            elseif RebirthMode == "Target" then
                                if currentPotential >= RebirthValue then
                                    shouldRebirth = true
                                end
                            end

                            if shouldRebirth then
                                local remotes = MyTycoon:FindFirstChild("Remotes")
                                local rebirthRemote = remotes and remotes:FindFirstChild("Rebirth")
                                if rebirthRemote then
                                    pcall(function() rebirthRemote:InvokeServer() end)
                                    UpgradeRemotes = {} 
                                    task.wait(2) 
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- LOOP 6: AUTO EVOLVE
task.spawn(function()
    while task.wait(0.5) do
        if Toggles.AutoEvolve then
            pcall(function() 
                local MyTycoon = GetMyTycoon()
                if MyTycoon then
                    local rebirthGui = LocalPlayer.PlayerGui:FindFirstChild("Rebirth")
                    local evoMenu = rebirthGui and rebirthGui:FindFirstChild("EvolutionMenu")
                    local body = evoMenu and evoMenu:FindFirstChild("Body")
                    local progress = body and body:FindFirstChild("Progress")

                    if progress then
                        local percent = tonumber(string.match(progress.Text, "[%d%.]+"))
                        if percent and percent >= 100 then
                            local remotes = MyTycoon:FindFirstChild("Remotes")
                            local evolveRemote = remotes and remotes:FindFirstChild("Evolve")
                            
                            if evolveRemote and evolveRemote:IsA("RemoteFunction") then
                                pcall(function() evolveRemote:InvokeServer() end)
                                UpgradeRemotes = {} 
                                task.wait(2) 
                            end
                        end
                    end
                end
            end)
        end
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
