-- ==========================================
-- EAT THE WORLD - LIGHTWEIGHT HUB V32 (LARGE UI & SPLIT BUTTONS)
-- ==========================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local settingsFile = "ETW_Settings_V32.json"
local settings = {
    AutoGrab = false,
    AutoEat = false,
    AutoSell = false,
    WalkSpeedToggle = false,
    WalkSpeedValue = 16,
    AntiFreeze = false,
    Noclip = false,
    NoAnimation = false,
    AutoAllRewards = false,
    AutoCube = false
}

local function saveSettings()
    if writefile then
        pcall(function() writefile(settingsFile, HttpService:JSONEncode(settings)) end)
    end
end

local function loadSettings()
    if isfile and readfile then
        local s, res = pcall(function() return isfile(settingsFile) end)
        if s and res then
            local s2, dec = pcall(function() return HttpService:JSONDecode(readfile(settingsFile)) end)
            if s2 and type(dec) == "table" then for k, v in pairs(dec) do settings[k] = v end end
        end
    end
end
loadSettings()

local parentGui = PlayerGui
pcall(function() if gethui then parentGui = gethui() else parentGui = CoreGui end end)
local uiName = "ETW_LightPanel_V32"
if parentGui:FindFirstChild(uiName) then parentGui[uiName]:Destroy() end

local uiScreen = Instance.new("ScreenGui", parentGui)
uiScreen.Name = uiName
uiScreen.ResetOnSpawn = false

-- PANEL LEBIH BESAR UNTUK MOBILE
local MainFrame = Instance.new("Frame", uiScreen)
MainFrame.Size = UDim2.new(0, 240, 0, 455) 
MainFrame.Position = UDim2.new(0, 20, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 15, 20)
MainFrame.Active = true; MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -60, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ETW Tool - V32"
Title.TextColor3 = Color3.fromRGB(255, 200, 100)
Title.Font = Enum.Font.SourceSansBold; Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinBtn = Instance.new("TextButton", MainFrame)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -60, 0, 0)
MinBtn.BackgroundTransparency = 1; MinBtn.Text = "_"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200); MinBtn.TextSize = 20

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1; CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80); CloseBtn.TextSize = 18

local MinIcon = Instance.new("TextButton", uiScreen)
MinIcon.Size = UDim2.new(0, 45, 0, 45)
MinIcon.BackgroundColor3 = Color3.fromRGB(20, 15, 20)
MinIcon.Text = "ETW"; MinIcon.TextColor3 = Color3.fromRGB(255, 200, 100)
MinIcon.Font = Enum.Font.SourceSansBold; MinIcon.TextSize = 16
MinIcon.Visible = false; MinIcon.Active = true; MinIcon.Draggable = true
Instance.new("UICorner", MinIcon).CornerRadius = UDim.new(1, 0)

local buttonRefs = {}
local function updateVisual(sKey)
    local ref = buttonRefs[sKey]; if not ref then return end
    local b = ref.button; local label = ref.label
    if settings[sKey] then
        b.Text = label .. ": ON"; b.BackgroundColor3 = Color3.fromRGB(40, 80, 40); b.TextColor3 = Color3.fromRGB(150, 255, 150)
    else
        b.Text = label .. ": OFF"; b.BackgroundColor3 = Color3.fromRGB(60, 40, 40); b.TextColor3 = Color3.fromRGB(255, 150, 150)
    end
end

-- SEMUA TOMBOL FULL SIZE
local function createToggle(text, yPos, settingKey)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 200, 0, 35)
    btn.Position = UDim2.new(0, 20, 0, yPos)
    btn.Font = Enum.Font.SourceSansBold; btn.TextSize = 15
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    buttonRefs[settingKey] = {button = btn, label = text}
    
    btn.MouseButton1Click:Connect(function()
        settings[settingKey] = not settings[settingKey]
        updateVisual(settingKey); saveSettings()
    end)
    updateVisual(settingKey)
end

-- Layout UI
createToggle("Auto Grab", 40, "AutoGrab")
createToggle("Auto Eat (Instan)", 85, "AutoEat")
createToggle("Auto Sell", 130, "AutoSell")

-- Walkspeed (Disesuaikan agar rapi di panel yang lebih lebar)
local wsBtn = Instance.new("TextButton", MainFrame)
wsBtn.Size = UDim2.new(0, 130, 0, 35)
wsBtn.Position = UDim2.new(0, 20, 0, 175)
wsBtn.Font = Enum.Font.SourceSansBold; wsBtn.TextSize = 15
Instance.new("UICorner", wsBtn).CornerRadius = UDim.new(0, 6)
buttonRefs["WalkSpeedToggle"] = {button = wsBtn, label = "Walk Speed"}
wsBtn.MouseButton1Click:Connect(function() settings["WalkSpeedToggle"] = not settings["WalkSpeedToggle"]; updateVisual("WalkSpeedToggle"); saveSettings() end)
updateVisual("WalkSpeedToggle")

local wsInput = Instance.new("TextBox", MainFrame)
wsInput.Size = UDim2.new(0, 60, 0, 35)
wsInput.Position = UDim2.new(0, 160, 0, 175)
wsInput.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
wsInput.TextColor3 = Color3.fromRGB(255, 255, 255)
wsInput.Font = Enum.Font.SourceSansBold; wsInput.TextSize = 16
wsInput.Text = tostring(settings.WalkSpeedValue); wsInput.PlaceholderText = "Spd"
Instance.new("UICorner", wsInput).CornerRadius = UDim.new(0, 6)
wsInput.FocusLost:Connect(function() local val = tonumber(wsInput.Text); if val then settings.WalkSpeedValue = val; saveSettings() else wsInput.Text = tostring(settings.WalkSpeedValue) end end)

createToggle("Anti-Freeze", 220, "AntiFreeze")
createToggle("Noclip (Risky)", 265, "Noclip")
createToggle("Bypass Anim", 310, "NoAnimation")
createToggle("Auto All Rewards", 355, "AutoAllRewards")
createToggle("Auto Cube", 400, "AutoCube")

MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; MinIcon.Position = MainFrame.Position; MinIcon.Visible = true end)
MinIcon.MouseButton1Click:Connect(function() MinIcon.Visible = false; MainFrame.Position = MinIcon.Position; MainFrame.Visible = true end)
CloseBtn.MouseButton1Click:Connect(function() uiScreen:Destroy() end)

-- ==========================================
-- MESIN UTAMA
-- ==========================================
task.spawn(function()
    while task.wait(0.5) do
        if settings.AutoGrab then
            local Char = LocalPlayer.Character
            if Char and Char:FindFirstChild("Events") then
                local currentChunk = Char:FindFirstChild("CurrentChunk")
                if not currentChunk or currentChunk.Value == nil then
                    pcall(function() Char.Events.Grab:FireServer(false, false, false) end)
                end
            end
        end
        if settings.AutoSell then
            pcall(function()
                local warn = PlayerGui.ScreenGui.Sell.WarningText
                if warn and warn.Visible and LocalPlayer.Character then LocalPlayer.Character.Events.Sell:FireServer(); task.wait(1.5) end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait() do 
        if settings.AutoEat then
            local Char = LocalPlayer.Character
            if Char and Char:FindFirstChild("Events") then
                local currentChunk = Char:FindFirstChild("CurrentChunk")
                if currentChunk and currentChunk.Value ~= nil then pcall(function() Char.Events.Eat:FireServer() end) end
            end
        end
    end
end)

local PlayerModule, Controls
pcall(function() PlayerModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")); Controls = PlayerModule:GetControls() end)

RunService.Stepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char then return end
    
    local Humanoid = Char:FindFirstChildOfClass("Humanoid")
    local RootPart = Char:FindFirstChild("HumanoidRootPart")
    
    if Humanoid then
        if settings.WalkSpeedToggle then Humanoid.WalkSpeed = settings.WalkSpeedValue
        elseif settings.AntiFreeze and Humanoid.WalkSpeed < 5 then Humanoid.WalkSpeed = 16 end
        
        -- Bypass Animasi (Bekerja secara independen)
        if settings.NoAnimation then
            for _, anim in pairs(Humanoid:GetPlayingAnimationTracks()) do
                if anim.Animation.AnimationId ~= "" then 
                   anim:Stop()
                end
            end
        end
    end
    
    if settings.AntiFreeze then
        if RootPart and RootPart.Anchored then RootPart.Anchored = false end
        if Controls then pcall(function() Controls:Enable() end) end
    end
    
    -- Noclip (Bisa dibiarkan OFF)
    if settings.Noclip then
        for _, part in pairs(Char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                part.CanCollide = false
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if settings.AutoCube then
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj.Name == "Cube" and obj:IsA("BasePart") then
                    local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if Root and firetouchinterest then pcall(function() firetouchinterest(Root, obj, 0); firetouchinterest(Root, obj, 1) end) end
                end
            end
        end
        if settings.AutoAllRewards then
            pcall(function()
                local grid = PlayerGui.ScreenGui.Rewards.TimedRewards.RewardGrid
                for _, t in pairs(grid:GetChildren()) do
                    if t.Name == "Template" and t:FindFirstChild("Time") and t.Time.Text == "Tap to claim!" then
                        local rf = LocalPlayer:WaitForChild("TimedRewards")
                        local re = ReplicatedStorage.Events.RewardEvent
                        for _, item in pairs(rf:GetChildren()) do re:FireServer(item) end; break
                    end
                end
            end)
            pcall(function()
                if PlayerGui.ScreenGui.Rewards.Spin.NextSpin.Visible == false then
                    ReplicatedStorage.Events.SpinEvent:FireServer(); task.wait(2)
                end
            end)
        end
    end
end)
