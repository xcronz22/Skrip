local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

local FILE_NAME = "LemonConfigV50.json"

-- ==========================================
-- 0. DEFAULT CONFIGURATION & STORAGE
-- ==========================================
local Toggles = {
    AutoHarvest = false,
    AutoDrop = false,
    AutoBuy = false,
    AutoUpgrade = false,
    AutoPhone = false,
    AutoRebirth = false
}

local RebirthMode = "Target" 
local RebirthValue = 1000
local UpgradeAmount = 1
local UpgradeRemotes = {}
local UI_Buttons = {}

local ToggleDefinitions = {
    {Name = "AutoHarvest", Text = "Auto Steal Lemons"},
    {Name = "AutoDrop", Text = "Auto Collect Drops"},
    {Name = "AutoBuy", Text = "Auto Buy Buttons"},
    {Name = "AutoUpgrade", Text = "Auto Upgrade Max"},
    {Name = "AutoPhone", Text = "Auto Answer Phone"},
    {Name = "AutoRebirth", Text = "Auto Rebirth"}
}

-- FUNCTIONS: MANUAL SAVE & LOAD SYSTEM
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
MainFrame.Size = UDim2.new(0, 280, 0, 460)
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
Title.Text = "🍋 Lemon Auto V5.0"
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
Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = Container

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
    ["o"] = 1e27, ["oc"] = 1e27, ["octillion"] = 1e27,
    ["n"] = 1e30, ["no"] = 1e30, ["nonillion"] = 1e30,
    ["d"] = 1e33, ["dc"] = 1e33, ["decillion"] = 1e33,
    ["ud"] = 1e36, ["undecillion"] = 1e36,
    ["dd"] = 1e39, ["duodecillion"] = 1e39,
    ["td"] = 1e42, ["tredecillion"] = 1e42,
    ["qad"]= 1e45, ["quattuordecillion"] = 1e45,
    ["qid"]= 1e48, ["quindecillion"] = 1e48,
    ["sxd"]= 1e51, ["sexdecillion"] = 1e51,
    ["spd"]= 1e54, ["septendecillion"] = 1e54,
    ["odc"]= 1e57, ["octodecillion"] = 1e57,     -- <--- Targetmu di sini
    ["ndc"]= 1e60, ["novemdecillion"] = 1e60,
    ["v"]  = 1e63, ["vg"] = 1e63, ["vigintillion"] = 1e63,
    ["uv"] = 1e66, ["unvigintillion"] = 1e66,
    ["dv"] = 1e69, ["duovigintillion"] = 1e69,
    ["tv"] = 1e72, ["trevigintillion"] = 1e72    -- <--- Kita siapkan sampai sini
}

local function parseStringToNumber(text)
    if not text then return 0 end
    text = string.lower(string.gsub(text, ",", "")) 
    
    local numStr = string.match(text, "[%d%.]+") 
    if not numStr then return 0 end
    local num = tonumber(numStr) or 0
    
    -- Tangkap teks kata/sufiksnya saja (misal: "billion", "odc", "octodecillion")
    local suffixStr = string.match(text, "[a-z]+") 
    if suffixStr and Multipliers[suffixStr] then
        return num * Multipliers[suffixStr]
    end
    
    return num
end

local function GetMyTycoon()
    for i = 1, 12 do
        local tycoon = Workspace:FindFirstChild("Tycoon" .. i)
        if tycoon then
            local owner = tycoon:FindFirstChild("Owner")
            if owner and (tostring(owner.Value) == LocalPlayer.Name or owner.Value == LocalPlayer) then
                return tycoon
            end
        end
    end
    return nil
end

local function RefreshUpgradeRemotes()
    UpgradeRemotes = {}
    local MyTycoon = GetMyTycoon()
    if MyTycoon and MyTycoon:FindFirstChild("Purchases") then
        for _, desc in pairs(MyTycoon.Purchases:GetDescendants()) do
            if desc:IsA("RemoteFunction") and desc.Name == "Upgrade" then
                table.insert(UpgradeRemotes, desc)
            end
        end
    end
end

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
    if input == "smart" or "2x" then
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
-- 5. BUTTON FUNCTIONALITIES (SAVE/LOAD SYNC)
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
        if RebirthValue == 2 and not string.find(TextBox.Text, "Smart") then
            TextBox.Text = "Smart (2x)"
        else
            TextBox.Text = RebirthValue .. "x"
        end
    else
        TextBox.Text = tostring(RebirthValue)
    end
    UpgradeTextBox.Text = tostring(UpgradeAmount)
end

SaveBtn.MouseButton1Click:Connect(function()
    SaveConfig()
    SaveBtn.Text = "✅ Saved!"
    task.wait(1)
    SaveBtn.Text = "💾 Save"
end)

LoadBtn.MouseButton1Click:Connect(function()
    LoadConfig()
    SyncLoadedDataToUI()
    LoadBtn.Text = "✅ Loaded!"
    task.wait(1)
    LoadBtn.Text = "📂 Load"
end)

-- ==========================================
-- 6. INTERFACES LOOP (PERMA ANTI-AFK & ENGINE)
-- ==========================================

-- ENGINE: PERMANENT ANTI-AFK (Tidak bisa dimatikan)
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

local ActiveTycoon = nil 
task.spawn(function()
    while task.wait(0.1) do
        local MyTycoon = GetMyTycoon()
        local char = LocalPlayer.Character
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChild("Humanoid")
        local isAlive = humanoid and humanoid.Health > 0

        if not isAlive or MyTycoon ~= ActiveTycoon then
            ActiveTycoon = MyTycoon
            UpgradeRemotes = {} 
            task.wait(1) 
            continue 
        end

        if not MyTycoon or not rootPart then continue end

        -- AUTO HARVEST
        if Toggles.AutoHarvest then
            local originalCFrame = rootPart.CFrame
            local hasTeleported = false

            for i = 1, 12 do
                if not Toggles.AutoHarvest then break end
                local tycoon = Workspace:FindFirstChild("Tycoon" .. i)
                if tycoon then
                    local constantFolder = tycoon:FindFirstChild("Constant")
                    if constantFolder and constantFolder:FindFirstChild("Trees") then
                        for _, tree in pairs(constantFolder.Trees:GetChildren()) do
                            if not Toggles.AutoHarvest then break end
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
                                    while #readyFruits > 0 and Toggles.AutoHarvest and rootPart do
                                        for _, fruitData in pairs(readyFruits) do
                                            if fruitData.Part and fruitData.Part.Parent then fireclickdetector(fruitData.CD) end
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
            if hasTeleported and rootPart and humanoid then
                task.wait(0.2)
                humanoid.PlatformStand = false
                rootPart.CFrame = originalCFrame
            end
        end
            
        -- AUTO BUY
        if Toggles.AutoBuy then
            local purchases = MyTycoon:FindFirstChild("Purchases")
            if purchases then
                for _, purchaseItem in pairs(purchases:GetChildren()) do
                    local buttonsFolder = purchaseItem:FindFirstChild("Buttons")
                    if buttonsFolder then
                        for _, item in pairs(buttonsFolder:GetDescendants()) do
                            if not rootPart or not Toggles.AutoBuy then break end
                            if item:IsA("TouchTransmitter") or item.Name == "TouchInterest" then
                                if item.Parent then
                                    firetouchinterest(rootPart, item.Parent, 0)
                                    task.wait(0.01)
                                    firetouchinterest(rootPart, item.Parent, 1)
                                end
                            elseif item:IsA("ProximityPrompt") then
                                fireproximityprompt(item)
                            end
                        end
                    end
                end
            end
        end
            
        -- AUTO UPGRADE
        if Toggles.AutoUpgrade then
            if #UpgradeRemotes == 0 then
                RefreshUpgradeRemotes()
            end

            for i = #UpgradeRemotes, 1, -1 do
                local remote = UpgradeRemotes[i]
                if remote and remote.Parent then
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

        -- AUTO PHONE
        if Toggles.AutoPhone then
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

        -- AUTO REBIRTH
        if Toggles.AutoRebirth then
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
                            pcall(function()
                                rebirthRemote:InvokeServer()
                            end)
                            UpgradeRemotes = {} 
                            task.wait(2) 
                        end
                    end
                end
            end
        end
    end
end)

-- LOOP TERPISAH: AUTO DROP
task.spawn(function()
    while task.wait(0.1) do
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChild("Humanoid")
        if Toggles.AutoDrop and humanoid and humanoid.Health > 0 then
            local cashDropsFolder = Workspace:FindFirstChild("CashDrops")
            if cashDropsFolder then
                for _, drop in pairs(cashDropsFolder:GetChildren()) do
                    if drop.Name == "CashDrop" then
                        local root = char:FindFirstChild("HumanoidRootPart")
                        local touchInterest = drop:FindFirstChild("TouchInterest") or drop:FindFirstChildWhichIsA("TouchTransmitter", true)
                        if root and touchInterest then
                            firetouchinterest(root, touchInterest.Parent, 0)
                            firetouchinterest(root, touchInterest.Parent, 1)
                        end
                    end
                end
            end
        end
    end
end)
