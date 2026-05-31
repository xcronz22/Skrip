-- =======================================================================
-- EAT THE WORLD - V53 ULTIMATE EDITION (PERFECTED PHYSICS + ANTI-STUCK)
-- 100% ANTI-FAIL UNTUK DELTA & SEMUA EXECUTOR MOBILE/PC
-- =======================================================================

local execCmd = [[task.wait(3); loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/EatTheWorld.lua"))()]]
pcall(function()
    if queue_on_teleport then queue_on_teleport(execCmd)
    elseif syn and syn.queue_on_teleport then syn.queue_on_teleport(execCmd) end
end)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local settings = {
    AutoFarm = false, AutoEat = false, AutoGrab = false, AutoSell = false,
    FarmMode = "Tween", LayDownMode = false, SafeZoneFarm = false, SafeZoneYValue = 0,
    AutoThrow = false, ThrowTarget = nil, SafeUnowned = true,
    AntiRagdoll = false, CleanTrash = false, AntiFreeze = false,
    NoAnimBrutal = false, NoAnimV2 = false,
    AutoRewards = false, AutoCube = false, RejoinAfterRewards = false
}

-- =======================================================================
-- VARIABEL SISTEM ANTI-STUCK (BLACKLIST)
-- =======================================================================
local blacklist = {}
local currentTarget = nil
local stuckTimer = tick()

local safeZoneFloorPart = nil
local activeTween = nil

task.spawn(function()
    pcall(function()
        LocalPlayer.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end)
end)

-- =======================================================================
-- CUSTOM STANDALONE UI (100% ANTI-GAGAL LOADSTRING)
-- =======================================================================
local parentGui = LocalPlayer:WaitForChild("PlayerGui")
pcall(function() if gethui then parentGui = gethui() else parentGui = CoreGui end end)

local uiName = "ETW_Ultimate_V53"
if parentGui:FindFirstChild(uiName) then parentGui[uiName]:Destroy() end

local uiScreen = Instance.new("ScreenGui", parentGui)
uiScreen.Name = uiName
uiScreen.ResetOnSpawn = false

local MinIcon = Instance.new("TextButton", uiScreen)
MinIcon.Size = UDim2.new(0, 45, 0, 45)
MinIcon.Position = UDim2.new(0, 20, 0, 20)
MinIcon.BackgroundColor3 = Color3.fromRGB(20, 15, 25)
MinIcon.Text = "ETW"
MinIcon.TextColor3 = Color3.fromRGB(0, 255, 150)
MinIcon.Font = Enum.Font.SourceSansBold
MinIcon.TextSize = 16
MinIcon.Visible = false
MinIcon.Active = true
MinIcon.Draggable = true
Instance.new("UICorner", MinIcon).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", MinIcon).Color = Color3.fromRGB(0, 255, 150)

local MainFrame = Instance.new("Frame", uiScreen)
MainFrame.Size = UDim2.new(0, 250, 0, 450)
MainFrame.Position = UDim2.new(0, 20, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 30)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(100, 50, 150)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -60, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ETW Ultimate V53"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinBtn = Instance.new("TextButton", MainFrame)
MinBtn.Size = UDim2.new(0, 30, 0, 35)
MinBtn.Position = UDim2.new(1, -60, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinBtn.TextSize = 24

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 35)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 18

MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; MinIcon.Visible = true end)
MinIcon.MouseButton1Click:Connect(function() MinIcon.Visible = false; MainFrame.Visible = true end)
CloseBtn.MouseButton1Click:Connect(function() uiScreen:Destroy() end)

local ScrollFrame = Instance.new("ScrollingFrame", MainFrame)
ScrollFrame.Size = UDim2.new(1, -10, 1, -45)
ScrollFrame.Position = UDim2.new(0, 5, 0, 40)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 50, 150)
ScrollFrame.BorderSizePixel = 0

local ListLayout = Instance.new("UIListLayout", ScrollFrame)
ListLayout.Padding = UDim.new(0, 6)
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function updateCanvas()
    task.wait(0.1)
    local h = 10
    for _, child in ipairs(ScrollFrame:GetChildren()) do
        if child:IsA("GuiObject") and child.Visible then h = h + child.AbsoluteSize.Y + 6 end
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, h)
end
ScrollFrame.ChildAdded:Connect(updateCanvas)

-- =======================================================================
-- UI BUILDER FUNCTIONS & UPDATERS
-- =======================================================================
local uiUpdaters = {}

local function CreateSectionTitle(text)
    local lbl = Instance.new("TextLabel", ScrollFrame)
    lbl.Size = UDim2.new(1, -10, 0, 25)
    lbl.BackgroundTransparency = 1
    lbl.Text = "--- " .. text .. " ---"
    lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 14
end

local function CreateToggle(text, settingKey)
    local btn = Instance.new("TextButton", ScrollFrame)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local function updateVisual()
        if settings[settingKey] then
            btn.Text = text .. ": ON"
            btn.BackgroundColor3 = Color3.fromRGB(0, 100, 50)
            btn.TextColor3 = Color3.fromRGB(150, 255, 150)
        else
            btn.Text = text .. ": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
            btn.TextColor3 = Color3.fromRGB(255, 150, 150)
        end
    end
    
    uiUpdaters[settingKey] = updateVisual
    
    btn.MouseButton1Click:Connect(function()
        settings[settingKey] = not settings[settingKey]
        updateVisual()
    end)
    updateVisual()
    return btn
end

local function CreateDropdown(text, settingKey, options)
    local btn = Instance.new("TextButton", ScrollFrame)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local function updateVisual()
        btn.Text = text .. ": " .. tostring(settings[settingKey] or "None")
    end
    uiUpdaters[settingKey] = updateVisual
    
    btn.MouseButton1Click:Connect(function()
        local currentIndex = table.find(options, settings[settingKey]) or 1
        currentIndex = currentIndex + 1
        if currentIndex > #options then currentIndex = 1 end
        settings[settingKey] = options[currentIndex]
        updateVisual()
    end)
    updateVisual()
    return btn
end

-- =======================================================================
-- MEMBANGUN MENU
-- =======================================================================
CreateSectionTitle("MAIN FARMING")
CreateToggle("Auto Farm (Multi-Mode)", "AutoFarm")
CreateToggle("Auto Grab (Ambil)", "AutoGrab")
CreateToggle("Auto Eat (Makan)", "AutoEat")
CreateToggle("Auto Sell", "AutoSell")
CreateToggle("Safe Unowned", "SafeUnowned")

CreateSectionTitle("MOVEMENT & EXPLOIT")
CreateDropdown("Move Mode", "FarmMode", {"Tween", "Walk", "TP"})
CreateToggle("Sleep Free-Walk (Tidur)", "LayDownMode")
CreateToggle("Safe Zone Floor", "SafeZoneFarm")

local yContainer = Instance.new("Frame", ScrollFrame)
yContainer.Size = UDim2.new(1, -10, 0, 35)
yContainer.BackgroundTransparency = 1
local yLbl = Instance.new("TextLabel", yContainer)
yLbl.Size = UDim2.new(0.6, 0, 1, 0); yLbl.BackgroundTransparency = 1
yLbl.Text = "Safe Zone Y Axis:"; yLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
yLbl.Font = Enum.Font.SourceSansBold; yLbl.TextSize = 14; yLbl.TextXAlignment = Enum.TextXAlignment.Left
local yInput = Instance.new("TextBox", yContainer)
yInput.Size = UDim2.new(0.4, 0, 1, 0); yInput.Position = UDim2.new(0.6, 0, 0, 0)
yInput.BackgroundColor3 = Color3.fromRGB(30, 30, 40); yInput.TextColor3 = Color3.fromRGB(255, 255, 255)
yInput.Text = tostring(settings.SafeZoneYValue); Instance.new("UICorner", yInput)

uiUpdaters["SafeZoneYValue"] = function() yInput.Text = tostring(settings.SafeZoneYValue) end

yInput.FocusLost:Connect(function()
    local val = tonumber(yInput.Text)
    if val then settings.SafeZoneYValue = val else yInput.Text = tostring(settings.SafeZoneYValue) end
end)

CreateSectionTitle("COMBAT & REWARDS")
CreateToggle("Auto All Rewards & Spin", "AutoRewards")
CreateToggle("Auto Collect Cubes", "AutoCube")
CreateToggle("Auto Rejoin (Rewards Done)", "RejoinAfterRewards")
CreateToggle("Enable Auto Throw", "AutoThrow")

local pList = {"None"}
for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(pList, p.Name) end end
local targetBtn = CreateDropdown("Target", "ThrowTarget", pList)

local refreshBtn = Instance.new("TextButton", ScrollFrame)
refreshBtn.Size = UDim2.new(1, -10, 0, 25)
refreshBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshBtn.Text = "Refresh Player List"
refreshBtn.Font = Enum.Font.SourceSansBold; refreshBtn.TextSize = 12
Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 6)
refreshBtn.MouseButton1Click:Connect(function()
    pList = {"None"}
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(pList, p.Name) end end
    settings.ThrowTarget = nil
    if uiUpdaters["ThrowTarget"] then uiUpdaters["ThrowTarget"]() end
end)

CreateSectionTitle("PROTECTIONS")
CreateToggle("Anti-Ragdoll (Ledakan)", "AntiRagdoll")
CreateToggle("Anti-Freeze (Nyangkut)", "AntiFreeze")
CreateToggle("Aggressive Clean Trash", "CleanTrash")
CreateToggle("No Animation (Brutal)", "NoAnimBrutal")
CreateToggle("No Animation V2 (Jalan)", "NoAnimV2")

-- =======================================================================
-- SAVE & LOAD MANAGER (NATIVE)
-- =======================================================================
local fileName = "ETW_Ultimate_V53_Settings.json"

local function SaveSettings()
    if writefile then
        pcall(function() writefile(fileName, HttpService:JSONEncode(settings)) end)
    end
end

local function LoadSettings()
    if readfile and isfile then
        pcall(function()
            if isfile(fileName) then
                local decoded = HttpService:JSONDecode(readfile(fileName))
                if type(decoded) == "table" then
                    for key, value in pairs(decoded) do
                        settings[key] = value
                        -- Update visual UI tombolnya langsung
                        if uiUpdaters[key] then uiUpdaters[key]() end
                    end
                end
            end
        end)
    end
end

CreateSectionTitle("CONFIGURATION")
local SaveBtn = Instance.new("TextButton", ScrollFrame)
SaveBtn.Size = UDim2.new(1, -10, 0, 35)
SaveBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 150)
SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBtn.Font = Enum.Font.SourceSansBold; SaveBtn.TextSize = 14; SaveBtn.Text = "Save Settings"
Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 6)

local LoadBtn = Instance.new("TextButton", ScrollFrame)
LoadBtn.Size = UDim2.new(1, -10, 0, 35)
LoadBtn.BackgroundColor3 = Color3.fromRGB(150, 80, 30)
LoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadBtn.Font = Enum.Font.SourceSansBold; LoadBtn.TextSize = 14; LoadBtn.Text = "Load Settings"
Instance.new("UICorner", LoadBtn).CornerRadius = UDim.new(0, 6)

SaveBtn.MouseButton1Click:Connect(function()
    SaveSettings(); SaveBtn.Text = "Saved!"; task.wait(1); SaveBtn.Text = "Save Settings"
end)
LoadBtn.MouseButton1Click:Connect(function()
    LoadSettings(); LoadBtn.Text = "Loaded!"; task.wait(1); LoadBtn.Text = "Load Settings"
end)

updateCanvas()
LoadSettings() -- Auto Load di awal eksekusi

-- =======================================================================
-- NON-BLOCKING CONTROLS SETUP
-- =======================================================================
local Controls = nil
task.spawn(function()
    pcall(function()
        local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts", 5)
        if PlayerScripts then
            local PlayerModule = require(PlayerScripts:WaitForChild("PlayerModule", 5))
            if PlayerModule then Controls = PlayerModule:GetControls() end
        end
    end)
end)

-- =======================================================================
-- CORE LOGIC: SLEEP HACK (FIXED), ANTI-RAGDOLL, ANTI-FREEZE
-- =======================================================================
local defaultC0s = {}

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if root and humanoid then
        -- 1. Trik RootJoint (Sleep Free-Walk) yang telah di-FIX
        local joint = root:FindFirstChild("RootJoint")
        if not joint then
            local lowerTorso = char:FindFirstChild("LowerTorso")
            if lowerTorso then joint = lowerTorso:FindFirstChild("Root") end
        end
        
        if joint then
            -- Simpan orientasi default tulang punggung
            if not defaultC0s[joint] then defaultC0s[joint] = joint.C0 end
            
            if settings.LayDownMode then
                -- Paksa miring -90 derajat pada sumbu X agar menunduk/tidur sempurna
                joint.C0 = defaultC0s[joint] * CFrame.Angles(math.rad(-90), 0, 0)
            else
                joint.C0 = defaultC0s[joint]
            end
        end
        
        -- 2. Anti Ragdoll (Explosive Chunk)
        if settings.AntiRagdoll then
            if humanoid:GetState() == Enum.HumanoidStateType.Ragdoll or humanoid:GetState() == Enum.HumanoidStateType.Physics then
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                pcall(function() ReplicatedStorage.Events.unRagdoll:FireServer(char) end)
            end
        end
        
        -- 3. No Animation
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then
            for _, anim in pairs(animator:GetPlayingAnimationTracks()) do
                if settings.NoAnimV2 then
                    local p = anim.Priority
                    if p == Enum.AnimationPriority.Action or p == Enum.AnimationPriority.Action2 or p == Enum.AnimationPriority.Action3 or p == Enum.AnimationPriority.Action4 then
                        anim:Stop(0)
                    end
                elseif settings.NoAnimBrutal then
                    anim:Stop(0)
                end
            end
        end
    end
    
    -- 4. Anti Freeze
    if settings.AntiFreeze then
        if root and root.Anchored then root.Anchored = false end
        if Controls then pcall(function() Controls:Enable() end) end
    end
end)

-- =======================================================================
-- SAFE ZONE FAIL-SAFE LOGIC
-- =======================================================================
task.spawn(function()
    while task.wait(1) do
        if settings.SafeZoneFarm then
            if not safeZoneFloorPart or not safeZoneFloorPart.Parent then
                safeZoneFloorPart = Instance.new("Part")
                safeZoneFloorPart.Size = Vector3.new(10000, 2, 10000)
                safeZoneFloorPart.Anchored = true; safeZoneFloorPart.CanCollide = true
                safeZoneFloorPart.Transparency = 0.5; safeZoneFloorPart.Color = Color3.fromRGB(150, 50, 255)
                safeZoneFloorPart.Parent = Workspace
            end
            safeZoneFloorPart.Position = Vector3.new(0, settings.SafeZoneYValue, 0)
            
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root and root.Position.Y < (settings.SafeZoneYValue - 5) then
                root.CFrame = CFrame.new(root.Position.X, settings.SafeZoneYValue + 4, root.Position.Z)
            end
        else
            if safeZoneFloorPart then safeZoneFloorPart:Destroy(); safeZoneFloorPart = nil end
        end
    end
end)

-- =======================================================================
-- MOVEMENT & TARGETING LOGIC (FIXED WALK & BLINK TP VERSION)
-- =======================================================================
local function moveToTarget(targetPos, targetSize)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end
    
    local targetPosFlat = Vector3.new(targetPos.X, root.Position.Y, targetPos.Z)
    local diff = root.Position - targetPosFlat
    local direction = diff.Magnitude > 0.1 and diff.Unit or Vector3.new(1, 0, 0)
    
    local objectRadius = targetSize and (math.max(targetSize.X, targetSize.Z) / 2) or 4
    local stopDistance = objectRadius + 3 
    local finalPosition = targetPosFlat + (direction * stopDistance)
    
    if settings.SafeZoneFarm and settings.FarmMode ~= "TP" then
        finalPosition = Vector3.new(finalPosition.X, settings.SafeZoneYValue + 3, finalPosition.Z)
    end
    
    local targetLookCFrame = CFrame.lookAt(root.Position, targetPosFlat)
    local distance = (root.Position - finalPosition).Magnitude
    
    -- Jika sudah sangat dekat dengan target, hentikan pergerakan
    if distance < 1.5 then 
        if settings.FarmMode == "Walk" then
            humanoid:Move(Vector3.new(0, 0, 0)) -- Stop jalan
        end
        return 
    end
    
    -- MODE 1: TWEEN (Terbang Halus)
    if settings.FarmMode == "Tween" then
        if activeTween then activeTween:Cancel() end
        local info = TweenInfo.new(distance / 65, Enum.EasingStyle.Linear)
        activeTween = TweenService:Create(root, info, {CFrame = CFrame.new(finalPosition) * targetLookCFrame.Rotation})
        activeTween:Play()
        
    -- MODE 2: WALK (ANTI-STUCK VERSION)
    elseif settings.FarmMode == "Walk" then
        if activeTween then activeTween:Cancel() end
        
        -- Paksa karakter selalu menghadap ke makanan
        root.CFrame = CFrame.new(root.Position) * targetLookCFrame.Rotation
        
        -- Hitung arah kompas menuju makanan dari posisi kamu sekarang
        local moveDir = (finalPosition - root.Position).Unit
        
        -- Tekan tombol jalan secara konstan ke arah makanan (Bebas dari bug timeout/spam)
        humanoid:Move(moveDir, false)
        
    -- MODE 3: TP (BLINK SNIPER)
    elseif settings.FarmMode == "TP" then
        if activeTween then activeTween:Cancel() end
        local originalCFrame = root.CFrame
        local blinkHeight = targetPos.Y + 3
        
        root.CFrame = CFrame.new(targetPos.X, blinkHeight, targetPos.Z) * CFrame.lookAt(Vector3.new(targetPos.X, blinkHeight, targetPos.Z), targetPos).Rotation
        task.wait(5.5) 
        
        pcall(function() 
            char.Events.Grab:FireServer(false, false, false)
            char.Events.Eat:FireServer()
        end)
        
        root.CFrame = originalCFrame
    end
end

-- =======================================================================
-- LOOPS: GRAB, EAT, SELL, TRASH CLEANER & COMBAT
-- =======================================================================
task.spawn(function()
    while task.wait(0.1) do
        local Char = LocalPlayer.Character
        if Char and Char:FindFirstChild("Events") then
            local chunk = Char:FindFirstChild("CurrentChunk")
            local isHolding = (chunk and chunk.Value ~= nil)
            if settings.AutoEat and isHolding then pcall(function() Char.Events.Eat:FireServer() end) end
            if settings.AutoGrab and not isHolding then pcall(function() Char.Events.Grab:FireServer(false, false, false) end) end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if settings.AutoSell then
            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if PlayerGui then
                pcall(function()
                    local warn = PlayerGui.ScreenGui.Sell.WarningText
                    if warn and warn.Visible and LocalPlayer.Character then LocalPlayer.Character.Events.Sell:FireServer() end
                end)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        if settings.CleanTrash and Workspace:FindFirstChild("Chunks") then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                for _, obj in ipairs(Workspace.Chunks:GetChildren()) do
                    if obj.Name == "TemplateChunk" then
                        local owner = obj:FindFirstChild("Owner")
                        if owner and owner.Value == nil then
                            local pos = obj:IsA("BasePart") and obj.Position or (obj:IsA("Model") and obj.PrimaryPart and obj.PrimaryPart.Position)
                            if pos and (root.Position - pos).Magnitude > 40 then pcall(function() obj:Destroy() end) end
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if settings.AutoThrow and settings.ThrowTarget then
            local tPlayer = Players:FindFirstChild(settings.ThrowTarget)
            local char = LocalPlayer.Character
            if tPlayer and tPlayer.Character and char then
                local myRoot = char:FindFirstChild("HumanoidRootPart")
                local tRoot = tPlayer.Character:FindFirstChild("HumanoidRootPart")
                local events = char:FindFirstChild("Events")
                if myRoot and tRoot and events and events:FindFirstChild("Throw") then
                    if not settings.LayDownMode then
                        myRoot.CFrame = CFrame.lookAt(myRoot.Position, Vector3.new(tRoot.Position.X, myRoot.Position.Y, tRoot.Position.Z))
                    end
                    pcall(function() events.Throw:FireServer(tRoot.Position) end)
                end
            end
        end
    end
end)

-- =======================================================================
-- LOOPS: REWARDS & CUBES
-- =======================================================================
task.spawn(function()
    while task.wait(1) do
        if settings.AutoCube then
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj.Name == "Cube" and obj:IsA("BasePart") then
                    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if root and firetouchinterest then 
                        pcall(function() firetouchinterest(root, obj, 0); firetouchinterest(root, obj, 1) end) 
                    end
                end
            end
        end
        
        if settings.AutoRewards then
            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if PlayerGui then
                pcall(function()
                    local grid = PlayerGui.ScreenGui.Rewards.TimedRewards.RewardGrid
                    local allClaimed = true
                    
                    for _, t in pairs(grid:GetChildren()) do
                        if t.Name == "Template" and t:FindFirstChild("Time") then
                            if t.Time.Text == "Tap to claim!" then
                                allClaimed = false
                                local rf = LocalPlayer:WaitForChild("TimedRewards", 2)
                                local re = ReplicatedStorage.Events.RewardEvent
                                if rf then for _, item in pairs(rf:GetChildren()) do re:FireServer(item) end end
                            elseif t.Time.Text ~= "Claimed!" then
                                allClaimed = false
                            end
                        end
                    end
                    
                    if settings.RejoinAfterRewards and allClaimed then
                        TeleportService:Teleport(game.PlaceId, LocalPlayer)
                    end
                end)
                
                pcall(function() 
                    if PlayerGui.ScreenGui.Rewards.Spin.NextSpin.Visible == false then 
                        ReplicatedStorage.Events.SpinEvent:FireServer(); task.wait(2) 
                    end 
                end)
            end
        end
    end
end)

-- =======================================================================
-- AUTOFARM PENCARI CHUNK (TERINTEGRASI SISTEM ANTI-STUCK)
-- =======================================================================
task.spawn(function()
    while task.wait(0.3) do
        if settings.AutoFarm then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local targetPos = nil; local shortestDist = math.huge; local targetObjSize = Vector3.new(4, 4, 4)
                local foldersToSearch = {}
                local currentFoundTarget = nil -- Menyimpan referensi objek terpilih
                
                if Workspace:FindFirstChild("Chunks") then table.insert(foldersToSearch, Workspace.Chunks) end
                if Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Fragmentable") then table.insert(foldersToSearch, Workspace.Map.Fragmentable) end
                
                for _, folder in pairs(foldersToSearch) do
                    for _, obj in pairs(folder:GetChildren()) do
                        -- Cek apakah objek sedang di-blacklist
                        if not blacklist[obj] then
                            local isAllowed = true
                            if settings.SafeUnowned and folder.Name == "Chunks" and obj.Name == "TemplateChunk" then
                                local owner = obj:FindFirstChild("Owner")
                                if owner and owner.Value ~= nil then isAllowed = false end
                            end
                            
                            if isAllowed then
                                local visualCheck = false; local currentSize = Vector3.new(4, 4, 4)
                                if obj:IsA("BasePart") and obj.Transparency < 1 and obj.Size.Magnitude > 0 then
                                    visualCheck = true; currentSize = obj.Size
                                elseif obj:IsA("Model") then
                                    local pPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                                    if pPart and pPart.Transparency < 1 and pPart.Size.Magnitude > 0 then 
                                        visualCheck = true; currentSize = pPart.Size 
                                    end
                                end
                                
                                if visualCheck then
                                    local pos = obj:IsA("BasePart") and obj.Position or (obj:IsA("Model") and obj.PrimaryPart and obj.PrimaryPart.Position)
                                    if pos then
                                        local basePos = settings.SafeZoneFarm and Vector3.new(root.Position.X, pos.Y, root.Position.Z) or root.Position
                                        local dist = (basePos - pos).Magnitude
                                        if dist < shortestDist then 
                                            shortestDist = dist; 
                                            targetPos = pos; 
                                            targetObjSize = currentSize;
                                            currentFoundTarget = obj -- Simpan target untuk logika anti-stuck
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                
                -- LOGIKA ANTI-STUCK
                if currentFoundTarget then
                    if currentFoundTarget ~= currentTarget then
                        currentTarget = currentFoundTarget
                        stuckTimer = tick() -- Reset timer jika target baru
                    elseif tick() - stuckTimer > 3 then
                        -- Jika nyangkut lebih dari 3 detik
                        blacklist[currentFoundTarget] = true
                        local foodToReset = currentFoundTarget
                        task.delay(5, function()
                            blacklist[foodToReset] = nil -- Hapus dari blacklist setelah 5 detik
                        end)
                        currentTarget = nil
                        targetPos = nil -- Batalkan pergerakan agar lanjut ke iterasi berikutnya
                    end
                end
                
                -- EKSEKUSI PERGERAKAN
                if targetPos and currentTarget then
                    local safeX = targetPos.X; local safeZ = targetPos.Z
                    local bedrock = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Bedrock")
                    if bedrock then
                        local halfX = (bedrock.Size.X / 2) - 5; local halfZ = (bedrock.Size.Z / 2) - 5
                        safeX = math.clamp(safeX, bedrock.Position.X - halfX, bedrock.Position.X + halfX)
                        safeZ = math.clamp(safeZ, bedrock.Position.Z - halfZ, bedrock.Position.Z + halfZ)
                    end
                    moveToTarget(Vector3.new(safeX, targetPos.Y, safeZ), targetObjSize)
                end
            end
        end
    end
end)
