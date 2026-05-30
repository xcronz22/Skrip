-- ==========================================
-- EAT THE WORLD - V52 (FULL COMPLETE VERSION)
-- Fix Rotation, Multi-Movement, Solid Safe Zone
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
local settingsFile = "ETW_Settings_V52.json"
local settings = {
    AutoGrab = false, AutoEat = false, AutoSell = false,
    WalkSpeedToggle = false, WalkSpeedValue = 16,
    AntiFreeze = false, NoAnimation = false, NoAnimV2 = false,
    AutoFarm = false, FarmMode = "Tween", -- Pilihan: "Tween", "Walk", "TP"
    SmartAutoRejoin = false, AutoAllRewards = false, AutoCube = false,
    AntiRagdoll = false, AntiChunk = false,
    AutoTargetThrow = false, SafeUnowned = false, FPSBooster = false,
    SafeZoneFarm = false, 
    SafeZoneYValue = 500  -- Default ke 500
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
-- PEMBUATAN ANTARMUKA UI
-- ==========================================
local parentGui = PlayerGui
pcall(function() if gethui then parentGui = gethui() else parentGui = CoreGui end end)
local uiName = "ETW_LightPanel_V52"
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
Title.Text = "ETW Tool - V52"
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

-- ==========================================
-- SOLID SAFE ZONE V52 LOGIC (UPDATED FIX MAP CHANGE)
-- ==========================================
local function updateSafeZonePlatform(teleportPlayer)
    if teleportPlayer == nil then teleportPlayer = true end -- Default true jika ditekan dari UI
    
    if settings.SafeZoneFarm then
        -- 1. Buat ulang jika dihapus oleh server saat pindah map
        if not safeZoneFloorPart or not safeZoneFloorPart.Parent then
            safeZoneFloorPart = Instance.new("Part")
            safeZoneFloorPart.Name = "ETW_UniversalSafeZone"
            safeZoneFloorPart.Size = Vector3.new(10000, 2, 10000) -- Diperbesar jadi 10000 agar mencakup map baru
            safeZoneFloorPart.Anchored = true
            safeZoneFloorPart.CanCollide = true
            safeZoneFloorPart.Transparency = 0.5
            safeZoneFloorPart.Color = Color3.fromRGB(100, 255, 100)
            safeZoneFloorPart.Material = Enum.Material.SmoothPlastic
            safeZoneFloorPart.Parent = Workspace
        end
        safeZoneFloorPart.Position = Vector3.new(0, settings.SafeZoneYValue, 0)
        
        -- 2. Tarik karakter ke atas platform (Hanya jalan saat di-toggle atau respawn)
        if teleportPlayer then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then 
                root.CFrame = CFrame.new(root.Position.X, settings.SafeZoneYValue + 4, root.Position.Z) 
            end
        end
    else
        if safeZoneFloorPart then 
            safeZoneFloorPart:Destroy()
            safeZoneFloorPart = nil 
        end
    end
end

-- ==========================================
-- SISTEM AUTO-REPAIR MAP CHANGE
-- ==========================================
-- Event: Saat karakter respawn (biasanya terjadi saat pindah map)
LocalPlayer.CharacterAdded:Connect(function(char)
    if settings.SafeZoneFarm then
        char:WaitForChild("HumanoidRootPart", 5)
        task.wait(1.5) -- Tunggu loading map baru selesai 100%
        updateSafeZonePlatform(true) -- Otomatis buat platform & tarik karakter
    end
end)

-- Loop: Memastikan server tidak diam-diam menghapus platform
task.spawn(function()
    while task.wait(2) do
        if settings.SafeZoneFarm then
            -- Panggil fungsi tanpa menarik karakter ke atas agar tidak nyendat saat jalan
            updateSafeZonePlatform(false) 
        end
    end
end)

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

-- SAFE ZONE Y-AXIS INPUT
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
        updateSafeZonePlatform()
    else 
        sfInput.Text = tostring(settings.SafeZoneYValue) 
    end 
end)

-- MULTI-MOVEMENT FARM MODE (TWEEN / WALK / TP)
createToggle("Auto Farm (Multi-Mode)", "AutoFarm") 

local ModeBtn = Instance.new("TextButton", ScrollFrame)
ModeBtn.Size = UDim2.new(0, 210, 0, 35)
ModeBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 100)
ModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeBtn.Font = Enum.Font.SourceSansBold; ModeBtn.TextSize = 15
ModeBtn.LayoutOrder = layoutOrderCounter; layoutOrderCounter = layoutOrderCounter + 1
Instance.new("UICorner", ModeBtn).CornerRadius = UDim.new(0, 6)

local modes = {"Tween", "Walk", "TP"}
local currentModeIndex = table.find(modes, settings.FarmMode) or 1
ModeBtn.Text = "Mode Gerak: " .. settings.FarmMode

ModeBtn.MouseButton1Click:Connect(function()
    currentModeIndex = currentModeIndex + 1
    if currentModeIndex > #modes then currentModeIndex = 1 end
    settings.FarmMode = modes[currentModeIndex]
    ModeBtn.Text = "Mode Gerak: " .. settings.FarmMode
    saveSettings()
end)

createToggle("Anti-Freeze", "AntiFreeze")
createToggle("Anti-Ragdoll (God)", "AntiRagdoll")
createToggle("Anti-Chunk Aura", "AntiChunk")
createToggle("No Anim (Brutal)", "NoAnimation")
createToggle("No Anim V2", "NoAnimV2")
createToggle("Safe Unowned Farm", "SafeUnowned")
createToggle("FPS Booster (Clean Trash)", "FPSBooster")
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
-- MESIN FARMING UTAMA LOOPS (UPDATED)
-- ==========================================
task.spawn(function()
    while task.wait(0.1) do -- Jeda kecil agar game tidak lag, tapi responsif
        local Char = LocalPlayer.Character
        if Char and Char:FindFirstChild("Events") then
            local currentChunk = Char:FindFirstChild("CurrentChunk")
            local isHoldingChunk = (currentChunk and currentChunk.Value ~= nil)

            -- 1. AUTO EAT (HANYA menembak jika SEDANG memegang makanan)
            if settings.AutoEat and isHoldingChunk then
                pcall(function() 
                    Char.Events.Eat:FireServer() 
                end)
            end

            -- 2. AUTO GRAB (HANYA menembak jika TIDAK sedang memegang makanan)
            if settings.AutoGrab and not isHoldingChunk then
                pcall(function() 
                    Char.Events.Grab:FireServer(false, false, false) 
                end)
            end
        end
    end
end)

-- Loop Auto Sell (Dipisah agar tidak mengganggu kecepatan Grab/Eat)
task.spawn(function()
    while task.wait(0.5) do
        if settings.AutoSell then
            pcall(function()
                local warn = PlayerGui.ScreenGui.Sell.WarningText
                if warn and warn.Visible and LocalPlayer.Character then 
                    LocalPlayer.Character.Events.Sell:FireServer()
                end
            end)
        end
    end
end)

-- ==========================================
-- MULTI-MODE MOVEMENT & FIX ROTATION SYSTEM (UPDATED)
-- ==========================================
local function moveToTarget(targetPos)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end
    
    -- 1. Kunci Sumbu Y (Ketinggian) agar sejajar dengan kaki karakter saat ini.
    -- Ini mencegah karakter mencoba memanjat ke atas gedung/chunk yang tinggi.
    local flatTarget = Vector3.new(targetPos.X, root.Position.Y, targetPos.Z)
    
    -- 2. Kalkulasi Arah & Jarak Berhenti (Offset)
    local diff = root.Position - flatTarget
    local direction = Vector3.new(0, 0, 1) -- Default arah jika sudah tepat di tengah
    if diff.Magnitude > 0.1 then
        direction = diff.Unit
    end
    
    local stopDistance = 4 -- Karakter akan berhenti 4 stud sebelum titik tengah chunk
    local finalPosition = flatTarget + (direction * stopDistance)
    
    -- Jika Safe Zone aktif, timpa Y-nya ke ketinggian Safe Zone
    if settings.SafeZoneFarm then
        finalPosition = Vector3.new(finalPosition.X, settings.SafeZoneYValue + 3, finalPosition.Z)
    end
    
    -- 3. Putar badan menghadap target final
    root.CFrame = CFrame.lookAt(root.Position, Vector3.new(finalPosition.X, root.Position.Y, finalPosition.Z))
    
    local distance = (root.Position - finalPosition).Magnitude
    if distance < 1 then return end -- Jika sudah sangat dekat, tidak perlu jalan lagi
    
    -- EKSEKUSI BERDASARKAN MODE
    if settings.FarmMode == "Tween" then
        if activeTween then activeTween:Cancel() end
        local info = TweenInfo.new(distance / 65, Enum.EasingStyle.Linear)
        activeTween = TweenService:Create(root, info, {CFrame = CFrame.new(finalPosition) * root.CFrame.Rotation})
        activeTween:Play()
    elseif settings.FarmMode == "Walk" then
        if activeTween then activeTween:Cancel() end
        humanoid:MoveTo(finalPosition)
    elseif settings.FarmMode == "TP" then
        if activeTween then activeTween:Cancel() end
        root.CFrame = CFrame.new(finalPosition) * root.CFrame.Rotation
        task.wait(0.1)
    end
end

-- ==========================================
-- AUTO FARM (MULTI MODE)
-- ==========================================
task.spawn(function()
    while task.wait(0.3) do
        if settings.AutoFarm then
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
                    moveToTarget(Vector3.new(safeX, targetPos.Y, safeZ))
                end
            end
        end
    end
end)

-- AGGRESSIVE CLEAN TRASH
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
