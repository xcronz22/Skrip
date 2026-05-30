-- =======================================================================
-- EAT THE WORLD - V53 ULTIMATE EDITION (ANTI-YIELD / BUG FIX)
-- =======================================================================

-- 1. AUTO EXECUTE (REJOIN / HOP)
local execCmd = [[task.wait(3); loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/EatTheWorld.lua"))()]]
if queue_on_teleport then pcall(function() queue_on_teleport(execCmd) end)
elseif syn and syn.queue_on_teleport then pcall(function() syn.queue_on_teleport(execCmd) end) end

-- 2. SERVICES & VARIABLES
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- GLOBAL SETTINGS
local settings = {
    AutoFarm = false, AutoEat = false, AutoGrab = false, AutoSell = false,
    FarmMode = "Tween", LayDownMode = false, SafeZoneFarm = false, SafeZoneYValue = 0,
    AutoThrow = false, ThrowTarget = nil, SafeUnowned = true,
    AntiRagdoll = false, CleanTrash = false, AntiFreeze = false,
    NoAnimBrutal = false, NoAnimV2 = false,
    AutoRewards = false, AutoCube = false, RejoinAfterRewards = false
}

local safeZoneFloorPart = nil
local activeTween = nil
local originalC0 = nil

-- ANTI-AFK (Dibungkus agar aman)
task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end)
end)

-- =======================================================================
-- FLUENT UI (LOAD PALING AWAL AGAR TIDAK MACET)
-- =======================================================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Eat The World - Ultimate V53", SubTitle = "by AI",
    TabWidth = 160, Size = UDim2.new(0, 520, 0, 420),
    Acrylic = true, Theme = "Darker", MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main Farm", Icon = "home" }),
    Move = Window:AddTab({ Title = "Movement & Z", Icon = "move" }),
    Combat = Window:AddTab({ Title = "Combat & Rewards", Icon = "swords" }),
    Misc = Window:AddTab({ Title = "Protections", Icon = "shield" }),
    Settings = Window:AddTab({ Title = "Settings & Save", Icon = "settings" })
}

-- TAB: MAIN FARM
Tabs.Main:AddToggle("T_AutoFarm", {Title = "Auto Farm (Multi-Mode)", Default = false}):OnChanged(function(v) settings.AutoFarm = v end)
Tabs.Main:AddToggle("T_AutoGrab", {Title = "Auto Grab (Ambil)", Default = false}):OnChanged(function(v) settings.AutoGrab = v end)
Tabs.Main:AddToggle("T_AutoEat", {Title = "Auto Eat (Makan)", Default = false}):OnChanged(function(v) settings.AutoEat = v end)
Tabs.Main:AddToggle("T_AutoSell", {Title = "Auto Sell", Default = false}):OnChanged(function(v) settings.AutoSell = v end)

-- TAB: MOVEMENT & Z
Tabs.Move:AddDropdown("D_Mode", {Title = "Mode", Values = {"Tween", "Walk", "TP"}, CurrentValue = "Tween"}):OnChanged(function(v) settings.FarmMode = v end)
Tabs.Move:AddToggle("T_LayDown", {Title = "Sleep Free-Walk Mode (Tidur)", Default = false}):OnChanged(function(v) settings.LayDownMode = v end)
Tabs.Move:AddToggle("T_SafeZone", {Title = "Safe Zone Floor", Default = false}):OnChanged(function(v) settings.SafeZoneFarm = v end)
Tabs.Move:AddInput("I_SafeY", {Title = "Safe Zone Height (Y)", Default = "0", Numeric = true, Finished = true, Callback = function(v)
    if tonumber(v) then settings.SafeZoneYValue = tonumber(v) end
end})

-- TAB: COMBAT & REWARDS
Tabs.Combat:AddToggle("T_AutoRewards", {Title = "Auto All Rewards & Spin", Default = false}):OnChanged(function(v) settings.AutoRewards = v end)
Tabs.Combat:AddToggle("T_AutoCube", {Title = "Auto Collect Cubes", Default = false}):OnChanged(function(v) settings.AutoCube = v end)
Tabs.Combat:AddToggle("T_RejoinReward", {Title = "Auto Rejoin If All Rewards Claimed", Default = false}):OnChanged(function(v) settings.RejoinAfterRewards = v end)

Tabs.Combat:AddToggle("T_AutoThrow", {Title = "Enable Auto Throw", Default = false}):OnChanged(function(v) settings.AutoThrow = v end)
local pList = {"None"}; for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(pList, p.Name) end end
local DropdownTarget = Tabs.Combat:AddDropdown("D_Target", {Title = "Select Player Target", Values = pList, Multi = false, Default = "None"})
DropdownTarget:OnChanged(function(v) settings.ThrowTarget = (v == "None" and nil or v) end)
Tabs.Combat:AddButton({Title = "Refresh Players", Callback = function()
    local nl = {"None"}; for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(nl, p.Name) end end
    DropdownTarget:SetValues(nl)
end})

-- TAB: PROTECTIONS (MISC)
Tabs.Misc:AddToggle("T_AntiRag", {Title = "Anti-Ragdoll (Anti Ledakan Chunk)", Default = false}):OnChanged(function(v) settings.AntiRagdoll = v end)
Tabs.Misc:AddToggle("T_AntiFreeze", {Title = "Anti-Freeze (Anti Nyangkut)", Default = false}):OnChanged(function(v) settings.AntiFreeze = v end)
Tabs.Misc:AddToggle("T_CleanTrash", {Title = "Aggressive Clean Trash (FPS Boost)", Default = false}):OnChanged(function(v) settings.CleanTrash = v end)
Tabs.Misc:AddToggle("T_NoAnimBrutal", {Title = "No Animation (Brutal)", Default = false}):OnChanged(function(v) settings.NoAnimBrutal = v end)
Tabs.Misc:AddToggle("T_NoAnimV2", {Title = "No Animation V2 (Bisa Jalan/Idle)", Default = false}):OnChanged(function(v) settings.NoAnimV2 = v end)


-- =======================================================================
-- NON-BLOCKING CONTROLS SETUP (MENCEGAH SKRIP NYANGKUT)
-- =======================================================================
local Controls = nil
task.spawn(function()
    pcall(function()
        local PlayerModule = require(LocalPlayer:WaitForChild("PlayerScripts", 10):WaitForChild("PlayerModule", 10))
        Controls = PlayerModule:GetControls()
    end)
end)

-- =======================================================================
-- CORE LOGIC: SLEEP HACK, ANTI-RAGDOLL, ANTI-FREEZE & ANIMATION
-- =======================================================================
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    -- 1. Trik RootJoint (Sleep Free-Walk)
    local lowerTorso = char:FindFirstChild("LowerTorso")
    local joint = (root and root:FindFirstChild("RootJoint")) or (lowerTorso and lowerTorso:FindFirstChild("Root"))
    if joint then
        if not originalC0 then originalC0 = joint.C0 end
        if settings.LayDownMode then
            joint.C0 = originalC0 * CFrame.Angles(math.rad(90), 0, 0)
        else
            joint.C0 = originalC0
        end
    end
    
    -- 2. Anti Ragdoll (Explosive Chunk)
    if settings.AntiRagdoll and humanoid then
        if humanoid:GetState() == Enum.HumanoidStateType.Ragdoll or humanoid:GetState() == Enum.HumanoidStateType.Physics then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            pcall(function() ReplicatedStorage.Events.unRagdoll:FireServer(char) end)
        end
    end
    
    -- 3. Anti Freeze
    if settings.AntiFreeze then
        if root and root.Anchored then root.Anchored = false end
        if Controls then pcall(function() Controls:Enable() end) end
    end
    
    -- 4. No Animation
    if humanoid then
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
-- MOVEMENT & TARGETING LOGIC
-- =======================================================================
local function moveToTarget(targetPos, targetSize)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end
    
    local flatTarget = Vector3.new(targetPos.X, root.Position.Y, targetPos.Z)
    local diff = root.Position - flatTarget
    local direction = diff.Magnitude > 0.1 and diff.Unit or Vector3.new(1, 0, 0)
    
    local objectRadius = targetSize and (math.max(targetSize.X, targetSize.Z) / 2) or 4
    local stopDistance = objectRadius + 3 
    local finalPosition = flatTarget + (direction * stopDistance)
    
    if settings.SafeZoneFarm then
        finalPosition = Vector3.new(finalPosition.X, settings.SafeZoneYValue + 3, finalPosition.Z)
    end
    
    if not settings.LayDownMode then
        root.CFrame = CFrame.lookAt(root.Position, Vector3.new(finalPosition.X, root.Position.Y, finalPosition.Z))
    end
    
    local distance = (root.Position - finalPosition).Magnitude
    if distance < 1 then return end
    
    if settings.FarmMode == "Tween" then
        if activeTween then activeTween:Cancel() end
        local info = TweenInfo.new(distance / 65, Enum.EasingStyle.Linear)
        activeTween = TweenService:Create(root, info, {CFrame = CFrame.new(finalPosition) * root.CFrame.Rotation})
        activeTween:Play()
    elseif settings.FarmMode == "Walk" then
        humanoid:MoveTo(finalPosition)
    elseif settings.FarmMode == "TP" then
        root.CFrame = CFrame.new(finalPosition) * root.CFrame.Rotation
        task.wait(0.1)
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
                local myRoot, tRoot = char:FindFirstChild("HumanoidRootPart"), tPlayer.Character:FindFirstChild("HumanoidRootPart")
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
                                local rf = LocalPlayer:WaitForChild("TimedRewards")
                                local re = ReplicatedStorage.Events.RewardEvent
                                for _, item in pairs(rf:GetChildren()) do re:FireServer(item) end
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
-- AUTOFARM PENCARI CHUNK (BUILDING & FRAGMENTABLE)
-- =======================================================================
task.spawn(function()
    while task.wait(0.3) do
        if settings.AutoFarm then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local targetPos = nil; local shortestDist = math.huge; local targetObjSize = Vector3.new(4, 4, 4)
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
                                    if dist < shortestDist then shortestDist = dist; targetPos = pos; targetObjSize = currentSize end
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
                        safeX = math.clamp(safeX, bedrock.Position.X - halfX, bedrock.Position.X + halfX)
                        safeZ = math.clamp(safeZ, bedrock.Position.Z - halfZ, bedrock.Position.Z + halfZ)
                    end
                    moveToTarget(Vector3.new(safeX, targetPos.Y, safeZ), targetObjSize)
                end
            end
        end
    end
end)

-- =======================================================================
-- SAVE & LOAD MANAGER (FLUENT)
-- =======================================================================
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("ETW_Ultimate")
SaveManager:SetFolder("ETW_Ultimate/configs")

Tabs.Settings:AddButton({Title = "Save Configuration", Callback = function() SaveManager:Save("AutoSave") end})
Tabs.Settings:AddButton({Title = "Load Configuration", Callback = function() SaveManager:Load("AutoSave") end})

pcall(function() SaveManager:Load("AutoSave") end)
Fluent:Notify({Title = "V53 Ultimate Active", Content = "Semua fitur komplit & bebas bug macet!", Duration = 5})
Window:SelectTab(Tabs.Main)
