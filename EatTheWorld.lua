-- ==========================================
-- EAT THE WORLD - V51 (UNIVERSAL SAFE ZONE)
-- ==========================================

-- 1. LOGIKA AUTO EXECUTE SETELAH REJOIN
local scriptURL = "https://raw.githubusercontent.com/xcronz22/Skrip/main/EatTheWorld.lua"
if queue_on_teleport then
    queue_on_teleport('task.wait(1); loadstring(game:HttpGet("' .. scriptURL .. '"))()')
elseif syn and syn.queue_on_teleport then
    syn.queue_on_teleport('task.wait(1); loadstring(game:HttpGet("' .. scriptURL .. '"))()')
end

-- 2. SERVICES
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ==========================================
-- ANTI-AFK SYSTEM
-- ==========================================
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- ==========================================
-- PENGATURAN & PENYIMPANAN DATA
-- ==========================================
local settingsFile = "ETW_Settings_V51.json"
local settings = {
    AutoGrab = false, AutoEat = false, AutoSell = false,
    WalkSpeedToggle = false, WalkSpeedValue = 16,
    AntiFreeze = false, NoAnimation = false, NoAnimV2 = false,
    AutoTween = false, Noclip = false, 
    SmartAutoRejoin = false, AutoAllRewards = false, AutoCube = false,
    AntiRagdoll = false, AntiChunk = false,
    AutoTargetThrow = false, SafeUnowned = false, FPSBooster = false,
    SafeZoneFarm = false,   -- Fitur Utama Dynamic Safe Zone V51
    SafeZoneYValue = -30    -- Default koordinat Y (bawah tanah)
}
local CurrentTarget = nil
local safeZoneFloorPart = nil
local activeTween = nil

local function saveSettings()
    if writefile then pcall(function() writefile(settingsFile, HttpService:JSONEncode(settings)) end) end
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

-- ==========================================
-- PEMBUATAN ANTARMUKA UI LENGKAP
-- ==========================================
local parentGui = PlayerGui
pcall(function() if gethui then parentGui = gethui() else parentGui = CoreGui end end)
local uiName = "ETW_LightPanel_V51"
if parentGui:FindFirstChild(uiName) then parentGui[uiName]:Destroy() end

local uiScreen = Instance.new("ScreenGui", parentGui)
uiScreen.Name = uiName
uiScreen.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", uiScreen)
MainFrame.Size = UDim2.new(0, 240, 0, 420) 
MainFrame.Position = UDim2.new(0, 20, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 15, 25)
MainFrame.Active = true; MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -60, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ETW Tool - V51"
Title.TextColor3 = Color3.fromRGB(200, 150, 255)
Title.Font = Enum.Font.SourceSansBold; Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinBtn = Instance.new("TextButton", MainFrame)
MinBtn.Size = UDim2.new(0, 30, 0, 35)
MinBtn.Position = UDim2.new(1, -60, 0, 0)
MinBtn.BackgroundTransparency = 1; MinBtn.Text = "_"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200); MinBtn.TextSize = 20

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 35)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1; CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80); CloseBtn.TextSize = 18

local ScrollFrame = Instance.new("ScrollingFrame", MainFrame)
ScrollFrame.Size = UDim2.new(1, 0, 1, -40)
ScrollFrame.Position = UDim2.new(0, 0, 0, 35)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 150, 255)
ScrollFrame.BorderSizePixel = 0

local ListLayout = Instance.new("UIListLayout", ScrollFrame)
ListLayout.Padding = UDim.new(0, 8)
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function updateCanvas()
    task.wait(0.1)
    local totalHeight = 10
    for _, child in ipairs(ScrollFrame:GetChildren()) do
        if child:IsA("GuiObject") and child.Visible then
            totalHeight = totalHeight + child.AbsoluteSize.Y + 8
        end
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
end
ScrollFrame.ChildAdded:Connect(updateCanvas)
ScrollFrame.ChildRemoved:Connect(updateCanvas)

local MinIcon = Instance.new("TextButton", uiScreen)
MinIcon.Size = UDim2.new(0, 45, 0, 45)
MinIcon.Position = UDim2.new(0, 20, 0, 20)
MinIcon.BackgroundColor3 = Color3.fromRGB(20, 15, 25)
MinIcon.Text = "ETW"; MinIcon.TextColor3 = Color3.fromRGB(200, 150, 255)
MinIcon.Font = Enum.Font.SourceSansBold; MinIcon.TextSize = 16
MinIcon.Visible = false; MinIcon.Active = true; MinIcon.Draggable = true
Instance.new("UICorner", MinIcon).CornerRadius = UDim.new(1, 0)

local buttonRefs = {}
local layoutOrderCounter = 1

local function updateVisual(sKey)
    local ref = buttonRefs[sKey]; if not ref then return end
    if settings[sKey] then
        ref.button.Text = ref.label .. ": ON"
        ref.button.BackgroundColor3 = Color3.fromRGB(60, 40, 80)
        ref.button.TextColor3 = Color3.fromRGB(220, 180, 255)
    else
        ref.button.Text = ref.label .. ": OFF"
        ref.button.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
        ref.button.TextColor3 = Color3.fromRGB(255, 150, 150)
    end
end

local function createToggle(text, settingKey, onToggleCallback)
    local btn = Instance.new("TextButton", ScrollFrame)
    btn.Size = UDim2.new(0, 210, 0, 35)
    btn.Font = Enum.Font.SourceSansBold; btn.TextSize = 15
    btn.LayoutOrder = layoutOrderCounter; layoutOrderCounter = layoutOrderCounter + 1
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    buttonRefs[settingKey] = {button = btn, label = text}
    
    btn.MouseButton1Click:Connect(function()
        settings[settingKey] = not settings[settingKey]
        updateVisual(settingKey); saveSettings()
        if onToggleCallback then onToggleCallback(settings[settingKey]) end
    end)
    updateVisual(settingKey)
    return btn
end

-- FUNGSIONALITAS PEMBARUAN PLATFORM SAFE ZONE SECARA REAL-TIME
local function updateSafeZonePlatform()
    if settings.SafeZoneFarm then
        if not safeZoneFloorPart then
            safeZoneFloorPart = Instance.new("Part")
            safeZoneFloorPart.Name = "ETW_UniversalSafeZone"
            safeZoneFloorPart.Size = Vector3.new(2000, 2, 2000)
            safeZoneFloorPart.Anchored = true
            safeZoneFloorPart.Transparency = 0.8
            safeZoneFloorPart.Color = Color3.fromRGB(180, 100, 255)
            safeZoneFloorPart.Material = Enum.Material.Neon
            safeZoneFloorPart.Parent = Workspace
        end
        safeZoneFloorPart.Position = Vector3.new(0, settings.SafeZoneYValue, 0)
        
        -- Paksa noclip hidup otomatis demi keamanan perpindahan axis Y
        settings.Noclip = true
        updateVisual("Noclip")
        
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = CFrame.new(root.Position.X, settings.SafeZoneYValue + 4, root.Position.Z) end
    else
        if safeZoneFloorPart then safeZoneFloorPart:Destroy(); safeZoneFloorPart = nil end
    end
end

-- ==========================================
-- INISIALISASI TOMBOL FITUR UI
-- ==========================================
createToggle("Auto Grab (Original)", "AutoGrab")
createToggle("Auto Eat (Instan)", "AutoEat")
createToggle("Auto Sell", "AutoSell")

-- CONTAINERS WALK SPEED
local wsContainer = Instance.new("Frame", ScrollFrame)
wsContainer.Size = UDim2.new(0, 210, 0, 35)
wsContainer.BackgroundTransparency = 1
wsContainer.LayoutOrder = layoutOrderCounter; layoutOrderCounter = layoutOrderCounter + 1

local wsBtn = Instance.new("TextButton", wsContainer)
wsBtn.Size = UDim2.new(0, 140, 1, 0)
wsBtn.Font = Enum.Font.SourceSansBold; wsBtn.TextSize = 15
Instance.new("UICorner", wsBtn).CornerRadius = UDim.new(0, 6)
buttonRefs["WalkSpeedToggle"] = {button = wsBtn, label = "Walk Speed"}
wsBtn.MouseButton1Click:Connect(function() settings["WalkSpeedToggle"] = not settings["WalkSpeedToggle"]; updateVisual("WalkSpeedToggle"); saveSettings() end)
updateVisual("WalkSpeedToggle")

local wsInput = Instance.new("TextBox", wsContainer)
wsInput.Size = UDim2.new(0, 65, 1, 0)
wsInput.Position = UDim2.new(1, -65, 0, 0)
wsInput.BackgroundColor3 = Color3.fromRGB(35, 30, 40)
wsInput.TextColor3 = Color3.fromRGB(255, 255, 255)
wsInput.Font = Enum.Font.SourceSansBold; wsInput.TextSize = 16
wsInput.Text = tostring(settings.WalkSpeedValue)
Instance.new("UICorner", wsInput).CornerRadius = UDim.new(0, 6)
wsInput.FocusLost:Connect(function() local val = tonumber(wsInput.Text); if val then settings.WalkSpeedValue = val; saveSettings() else wsInput.Text = tostring(settings.WalkSpeedValue) end end)

createToggle("Anti-Freeze", "AntiFreeze")
createToggle("Anti-Ragdoll (God)", "AntiRagdoll")
createToggle("Anti-Chunk Aura", "AntiChunk")

-- SETUP DROPDOWN UNTUK AUTO TARGET THROW
local DropdownBtn = Instance.new("TextButton", ScrollFrame)
local DropdownList = Instance.new("ScrollingFrame", ScrollFrame)

createToggle("Auto Target Throw", "AutoTargetThrow", function(state)
    DropdownBtn.Visible = state
    if not state then DropdownList.Visible = false end
    updateCanvas()
end)

DropdownBtn.Size = UDim2.new(0, 210, 0, 30)
DropdownBtn.BackgroundColor3 = Color3.fromRGB(50, 40, 60)
DropdownBtn.TextColor3 = Color3.fromRGB(230, 200, 255)
DropdownBtn.Font = Enum.Font.SourceSansBold; DropdownBtn.TextSize = 14
DropdownBtn.Text = "Pilih Target: None ▼"
DropdownBtn.Visible = settings.AutoTargetThrow
DropdownBtn.LayoutOrder = layoutOrderCounter; layoutOrderCounter = layoutOrderCounter + 1
Instance.new("UICorner", DropdownBtn).CornerRadius = UDim.new(0, 6)

if CurrentTarget and CurrentTarget.Parent then DropdownBtn.Text = "Target: " .. CurrentTarget.Name .. " ▼" end

DropdownList.Size = UDim2.new(0, 210, 0, 110)
DropdownList.BackgroundColor3 = Color3.fromRGB(30, 25, 35)
DropdownList.Visible = false
DropdownList.ScrollBarThickness = 4
DropdownList.LayoutOrder = layoutOrderCounter; layoutOrderCounter = layoutOrderCounter + 1
Instance.new("UICorner", DropdownList).CornerRadius = UDim.new(0, 6)
local DropdownLayout = Instance.new("UIListLayout", DropdownList)
DropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function refreshDropdown()
    for _, child in pairs(DropdownList:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    local ySize = 0
    local players = Players:GetPlayers()
    for i, p in ipairs(players) do
        if p ~= LocalPlayer then
            local btn = Instance.new("TextButton", DropdownList)
            btn.Size = UDim2.new(1, 0, 0, 25)
            btn.BackgroundTransparency = (i % 2 == 0) and 0.8 or 1
            btn.BackgroundColor3 = Color3.fromRGB(60, 50, 70)
            btn.TextColor3 = Color3.fromRGB(240, 220, 255)
            btn.Font = Enum.Font.SourceSans; btn.TextSize = 14
            btn.Text = "  " .. p.Name
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.LayoutOrder = i
            
            btn.MouseButton1Click:Connect(function()
                CurrentTarget = p; DropdownBtn.Text = "Target: " .. p.Name .. " ▼"; DropdownList.Visible = false; updateCanvas()
            end)
            ySize = ySize + 25
        end
    end
    DropdownList.CanvasSize = UDim2.new(0, 0, 0, ySize)
end

DropdownBtn.MouseButton1Click:Connect(function() DropdownList.Visible = not DropdownList.Visible; if DropdownList.Visible then refreshDropdown() end; updateCanvas() end)
Players.PlayerAdded:Connect(function() if DropdownList.Visible then refreshDropdown() end end)
Players.PlayerRemoving:Connect(function(player) if CurrentTarget == player then CurrentTarget = nil; DropdownBtn.Text = "Pilih Target: None ▼" end; if DropdownList.Visible then refreshDropdown() end end)

createToggle("No Anim (Brutal)", "NoAnimation")
createToggle("No Anim V2", "NoAnimV2")

-- ==========================================
-- NEW REVOLUTIONARY FITUR V51: SAFE ZONE DYNAMIC Y AXIS
-- ==========================================
local sfContainer = Instance.new("Frame", ScrollFrame)
sfContainer.Size = UDim2.new(0, 210, 0, 35)
sfContainer.BackgroundTransparency = 1
sfContainer.LayoutOrder = layoutOrderCounter; layoutOrderCounter = layoutOrderCounter + 1

local sfBtn = Instance.new("TextButton", sfContainer)
sfBtn.Size = UDim2.new(0, 140, 1, 0)
sfBtn.Font = Enum.Font.SourceSansBold; sfBtn.TextSize = 15
Instance.new("UICorner", sfBtn).CornerRadius = UDim.new(0, 6)
buttonRefs["SafeZoneFarm"] = {button = sfBtn, label = "Safe Zone Farm"}

sfBtn.MouseButton1Click:Connect(function() 
    settings["SafeZoneFarm"] = not settings["SafeZoneFarm"]
    updateVisual("SafeZoneFarm"); saveSettings()
    updateSafeZonePlatform()
end)
updateVisual("SafeZoneFarm")

local sfInput = Instance.new("TextBox", sfContainer)
sfInput.Size = UDim2.new(0, 65, 1, 0)
sfInput.Position = UDim2.new(1, -65, 0, 0)
sfInput.BackgroundColor3 = Color3.fromRGB(35, 30, 40)
sfInput.TextColor3 = Color3.fromRGB(255, 255, 255)
sfInput.Font = Enum.Font.SourceSansBold; sfInput.TextSize = 15
sfInput.Text = tostring(settings.SafeZoneYValue)
Instance.new("UICorner", sfInput).CornerRadius = UDim.new(0, 6)

sfInput.FocusLost:Connect(function() 
    local val = tonumber(sfInput.Text)
    if val then 
        settings.SafeZoneYValue = val; saveSettings()
        updateSafeZonePlatform() -- Perbarui letak platform saat angka Y diubah
    else 
        sfInput.Text = tostring(settings.SafeZoneYValue) 
    end 
end)

createToggle("Auto Tween (2Axis Smooth)", "AutoTween") 
createToggle("Safe Unowned Farm", "SafeUnowned")
createToggle("FPS Booster (Clean Trash)", "FPSBooster")
createToggle("Noclip (Wajib Aktif!)", "Noclip") 
createToggle("Smart Rejoin (All)", "SmartAutoRejoin") 
createToggle("Auto All Rewards", "AutoAllRewards")
createToggle("Auto Cube", "AutoCube")

MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; MinIcon.Visible = true end)
MinIcon.MouseButton1Click:Connect(function() MinIcon.Visible = false; MainFrame.Visible = true end)
CloseBtn.MouseButton1Click:Connect(function() uiScreen:Destroy() end)
updateCanvas()

if settings.SafeZoneFarm then task.spawn(updateSafeZonePlatform) end

-- ==========================================
-- SMART REJOIN SYSTEM
-- ==========================================
local retryCount = 0
local function handleDisconnect()
    if settings.SmartAutoRejoin then
        if retryCount < 3 then
            retryCount = retryCount + 1
            task.wait(3); TeleportService:Teleport(game.PlaceId, LocalPlayer)
        else
            local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100"))
            if servers and servers.data and #servers.data > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, servers.data[math.random(1, #servers.data)].id)
            end
        end
    end
end
game:GetService("CoreGui").ChildAdded:Connect(function(child) if child:IsA("ScreenGui") and child.Name == "ErrorPrompt" then handleDisconnect() end end)

-- ==========================================
-- MESIN FARMING UTAMA LOOPS
-- ==========================================
task.spawn(function()
    while task.wait(0.3) do
        if settings.AutoTargetThrow and CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("HumanoidRootPart") then
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local targetRoot = CurrentTarget.Character.HumanoidRootPart
            if myRoot then
                myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(targetRoot.Position.X, myRoot.Position.Y, targetRoot.Position.Z))
                local events = LocalPlayer.Character:FindFirstChild("Events")
                if events and events:FindFirstChild("Throw") then pcall(function() events.Throw:FireServer(targetRoot.Position + Vector3.new(0, 3, 0)) end) end
            end
        end
        
        if settings.AutoGrab then
            local Char = LocalPlayer.Character
            if Char and Char:FindFirstChild("Events") and Char:FindFirstChild("HumanoidRootPart") then
                local currentChunk = Char:FindFirstChild("CurrentChunk")
                if not currentChunk or currentChunk.Value == nil then pcall(function() Char.Events.Grab:FireServer(false, false, false) end) end
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

-- LOGIKA SMOOTH TWEENING BERDASARKAN INPUT AXIS Y DYNAMIC
local function tweenTo(targetPos)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local finalPosition = targetPos
    if settings.SafeZoneFarm then
        -- Kunci posisi vertical (Y) mengikuti nilai input box UI secara real-time
        finalPosition = Vector3.new(targetPos.X, settings.SafeZoneYValue + 3, targetPos.Z)
    end
    
    local distance = (root.Position - finalPosition).Magnitude
    if distance < 1 then return end
    
    if activeTween then activeTween:Cancel() end
    
    local info = TweenInfo.new(distance / 65, Enum.EasingStyle.Linear)
    local targetCFrame = CFrame.new(finalPosition) * root.CFrame.Rotation
    
    activeTween = TweenService:Create(root, info, {CFrame = targetCFrame})
    activeTween:Play()
end

task.spawn(function()
    while task.wait(0.3) do
        if settings.AutoTween then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local targetPos = nil; local shortestDist = math.huge
                local foldersToSearch = {}
                if Workspace:FindFirstChild("Chunks") then table.insert(foldersToSearch, Workspace.Chunks) end
                if Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Fragmentable") then table.insert(foldersToSearch, Workspace.Map.Fragmentable) end
                
                for _, folder in pairs(foldersToSearch) do
                    for _, obj in pairs(folder:GetChildren()) do
                        local isAllowed = true
                        
                        if settings.SafeUnowned and folder.Name == "Chunks" and obj.Name == "TemplateChunk" then
                            local owner = obj:FindFirstChild("Owner")
                            if owner and owner.Value ~= nil then isAllowed = false end
                        end
                        
                        if isAllowed then
                            local visualCheck = false
                            if obj:IsA("BasePart") and obj.Transparency < 1 and obj.Size.Magnitude > 0 then
                                visualCheck = true
                            elseif obj:IsA("Model") then
                                local pPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                                if pPart and pPart.Transparency < 1 and pPart.Size.Magnitude > 0 then visualCheck = true end
                            end
                            
                            if visualCheck then
                                local pos = obj:IsA("BasePart") and obj.Position or (obj:IsA("Model") and obj.PrimaryPart and obj.PrimaryPart.Position)
                                if pos then
                                    local basePos = settings.SafeZoneFarm and Vector3.new(root.Position.X, pos.Y, root.Position.Z) or root.Position
                                    local dist = (basePos - pos).Magnitude
                                    if dist < shortestDist then shortestDist = dist; targetPos = pos end
                                end
                            end
                        end
                    end
                end
                
                if targetPos then
                    local safeX = targetPos.X; local safeZ = targetPos.Z
                    local bedrock = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Bedrock")
                    if bedrock then
                        local halfX = (bedrock.Size.X / 2) - 5; local halfZ = (bedrock.Size.Z / 2) - 5
                        local cx = bedrock.Position.X; local cz = bedrock.Position.Z
                        safeX = math.clamp(safeX, cx - halfX, cx + halfX)
                        safeZ = math.clamp(safeZ, cz - halfZ, cz + halfZ)
                    else
                        safeX = math.clamp(safeX, -144, 144); safeZ = math.clamp(safeZ, -144, 144)
                    end
                    tweenTo(Vector3.new(safeX, targetPos.Y, safeZ))
                end
            end
        end
    end
end)

-- AGGRESSIVE CLEAN TRASH (BERDASARKAN POSISI HORIZONTAL DYNAMIC AXIS Y)
task.spawn(function()
    while task.wait(1.5) do
        if settings.FPSBooster and Workspace:FindFirstChild("Chunks") then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                for _, obj in ipairs(Workspace.Chunks:GetChildren()) do
                    if obj.Name == "TemplateChunk" then
                        local owner = obj:FindFirstChild("Owner")
                        if owner and owner.Value == nil then
                            local pos = obj:IsA("BasePart") and obj.Position or (obj:IsA("Model") and obj.PrimaryPart and obj.PrimaryPart.Position)
                            if pos then
                                local basePos = settings.SafeZoneFarm and Vector3.new(root.Position.X, pos.Y, root.Position.Z) or root.Position
                                if (basePos - pos).Magnitude > 40 then pcall(function() obj:Destroy() end) end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- STEPPED SERVICES LOOP
local PlayerModule, Controls
pcall(function() PlayerModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")); Controls = PlayerModule:GetControls() end)

RunService.Stepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char then return end
    local Humanoid = Char:FindFirstChildOfClass("Humanoid")
    local RootPart = Char:FindFirstChild("HumanoidRootPart")
    
    if RootPart then
        local _, yRotation, _ = RootPart.CFrame:ToOrientation()
        RootPart.CFrame = CFrame.new(RootPart.Position) * CFrame.fromOrientation(0, yRotation, 0)
    end
    
    if settings.AntiRagdoll and Humanoid then
        if Humanoid:GetState() == Enum.HumanoidStateType.Physics or Humanoid:GetState() == Enum.HumanoidStateType.Ragdoll then
            Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            pcall(function() ReplicatedStorage.Events.unRagdoll:FireServer(Char) end)
        end
    end
    
    if settings.AntiChunk and RootPart then
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("BasePart") and (obj.Name == "Chunk" or obj.Name == "ExplodeChunk") then
                local basePos = settings.SafeZoneFarm and Vector3.new(RootPart.Position.X, obj.Position.Y, RootPart.Position.Z) or RootPart.Position
                if (obj.Position - basePos).Magnitude <= 15 then obj.CanCollide = false; obj.Velocity = Vector3.new(0,0,0) end
            end
        end
    end

    if Humanoid then
        if settings.WalkSpeedToggle then Humanoid.WalkSpeed = settings.WalkSpeedValue
        elseif settings.AntiFreeze and Humanoid.WalkSpeed < 5 then Humanoid.WalkSpeed = 16 end
        
        if settings.NoAnimation or settings.NoAnimV2 then
            local Animator = Humanoid:FindFirstChildOfClass("Animator")
            if Animator then
                for _, anim in pairs(Animator:GetPlayingAnimationTracks()) do
                    if settings.NoAnimV2 then
                        if anim.Priority == Enum.AnimationPriority.Action or anim.Priority == Enum.AnimationPriority.Action2 or anim.Priority == Enum.AnimationPriority.Action3 or anim.Priority == Enum.AnimationPriority.Action4 then anim:Stop(0) end
                    else anim:Stop(0) end
                end
            end
        end
    end
    
    if settings.AntiFreeze then
        if RootPart and RootPart.Anchored then RootPart.Anchored = false end
        if Controls then pcall(function() Controls:Enable() end) end
    end
    
    if settings.Noclip then
        for _, part in pairs(Char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then part.CanCollide = false end
        end
    end
end)

-- AUTO CUBE & TIME REWARDS
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
                local hasPendingRewards = false
                for _, t in pairs(grid:GetChildren()) do
                    if t.Name == "Template" and t:FindFirstChild("Time") then
                        if t.Time.Text == "Tap to claim!" then
                            local rf = LocalPlayer:WaitForChild("TimedRewards")
                            local re = ReplicatedStorage.Events.RewardEvent
                            for _, item in pairs(rf:GetChildren()) do re:FireServer(item) end
                        elseif t.Time.Text ~= "Claimed!" then hasPendingRewards = true end
                    end
                end
                if settings.SmartAutoRejoin and not hasPendingRewards then TeleportService:Teleport(game.PlaceId, LocalPlayer) end
            end)
            pcall(function() if PlayerGui.ScreenGui.Rewards.Spin.NextSpin.Visible == false then ReplicatedStorage.Events.SpinEvent:FireServer(); task.wait(2) end end)
        end
    end
end)
