-- =======================================================================
-- EAT THE WORLD - V53 ULTIMATE (DELTA EXECUTOR / ORION UI VERSION)
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
local LocalPlayer = Players.LocalPlayer

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
-- ORION UI (RINGAN & STABIL UNTUK DELTA EXECUTOR)
-- =======================================================================
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
    Name = "Eat The World - Ultimate V53",
    HidePremium = true,
    SaveConfig = true,
    ConfigFolder = "ETW_Ultimate_Config"
})

local TabMain = Window:MakeTab({Name = "Main Farm", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local TabMove = Window:MakeTab({Name = "Move & Z", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local TabCombat = Window:MakeTab({Name = "Combat & Rewards", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local TabMisc = Window:MakeTab({Name = "Protections", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- TAB: MAIN
TabMain:AddToggle({Name = "Auto Farm (Multi-Mode)", Default = false, Callback = function(v) settings.AutoFarm = v end})
TabMain:AddToggle({Name = "Auto Grab (Ambil)", Default = false, Callback = function(v) settings.AutoGrab = v end})
TabMain:AddToggle({Name = "Auto Eat (Makan)", Default = false, Callback = function(v) settings.AutoEat = v end})
TabMain:AddToggle({Name = "Auto Sell", Default = false, Callback = function(v) settings.AutoSell = v end})

-- TAB: MOVE & Z
TabMove:AddDropdown({Name = "Movement Mode", Default = "Tween", Options = {"Tween", "Walk", "TP"}, Callback = function(v) settings.FarmMode = v end})
TabMove:AddToggle({Name = "Sleep Free-Walk Mode (Tidur)", Default = false, Callback = function(v) settings.LayDownMode = v end})
TabMove:AddToggle({Name = "Safe Zone Floor", Default = false, Callback = function(v) settings.SafeZoneFarm = v end})
TabMove:AddTextbox({Name = "Safe Zone Height (Y)", Default = "0", TextDisappear = false, Callback = function(v)
    if tonumber(v) then settings.SafeZoneYValue = tonumber(v) end
end})

-- TAB: COMBAT
TabCombat:AddToggle({Name = "Auto All Rewards & Spin", Default = false, Callback = function(v) settings.AutoRewards = v end})
TabCombat:AddToggle({Name = "Auto Collect Cubes", Default = false, Callback = function(v) settings.AutoCube = v end})
TabCombat:AddToggle({Name = "Auto Rejoin (All Rewards Claimed)", Default = false, Callback = function(v) settings.RejoinAfterRewards = v end})

TabCombat:AddToggle({Name = "Enable Auto Throw", Default = false, Callback = function(v) settings.AutoThrow = v end})

local pList = {"None"}
for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(pList, p.Name) end end
local targetDropdown = TabCombat:AddDropdown({
    Name = "Select Player Target",
    Default = "None",
    Options = pList,
    Callback = function(v) settings.ThrowTarget = (v == "None" and nil or v) end
})

TabCombat:AddButton({
    Name = "Refresh Players",
    Callback = function()
        local nl = {"None"}
        for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(nl, p.Name) end end
        targetDropdown:Refresh(nl, true)
    end
})

-- TAB: MISC
TabMisc:AddToggle({Name = "Anti-Ragdoll (Anti Ledakan)", Default = false, Callback = function(v) settings.AntiRagdoll = v end})
TabMisc:AddToggle({Name = "Anti-Freeze (Anti Nyangkut)", Default = false, Callback = function(v) settings.AntiFreeze = v end})
TabMisc:AddToggle({Name = "Aggressive Clean Trash (FPS)", Default = false, Callback = function(v) settings.CleanTrash = v end})
TabMisc:AddToggle({Name = "No Animation (Brutal)", Default = false, Callback = function(v) settings.NoAnimBrutal = v end})
TabMisc:AddToggle({Name = "No Animation V2", Default = false, Callback = function(v) settings.NoAnimV2 = v end})

OrionLib:Init()

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
-- CORE LOGIC: SLEEP HACK, ANTI-RAGDOLL, ANTI-FREEZE & ANIMATION
-- =======================================================================
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    -- Trik RootJoint (Sleep Free-Walk)
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
    
    if settings.AntiRagdoll and humanoid then
        if humanoid:GetState() == Enum.HumanoidStateType.Ragdoll or humanoid:GetState() == Enum.HumanoidStateType.Physics then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            pcall(function() ReplicatedStorage.Events.unRagdoll:FireServer(char) end)
        end
    end
    
    if settings.AntiFreeze then
        if root and root.Anchored then root.Anchored = false end
        if Controls then pcall(function() Controls:Enable() end) end
    end
    
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
