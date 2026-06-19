-- Memuat Library RZY
local RZY_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Win = RZY_Library:MakeWindow("100 Days at Sea - V6.8 Brutal")

-- ====================================================================
-- 1. TABEL PENYIMPANAN STATUS (DATA STATES)
-- ====================================================================
local TargetMaterials = {
    ["Wood"] = false, ["Metal"] = false, ["Goo"] = false,
    ["Small Gas Can"] = false, ["Big Gas Can"] = false, ["Gas Drum"] = false
}

local TargetWeapons = {
    ["Harpoon"] = false, ["Magma Staff"] = false, ["Squid Laser"] = false,
    ["Rifle"] = false, ["Flintlock"] = false, ["Blunderbuss"] = false,
    ["Hand Cannon"] = false, ["Revolver"] = false, ["Boomstick"] = false, ["Riptide"] = false
}

local AttackMode = "Nearest (Global)" 

local AutoGrinderEnabled = false
local AutoCampfireEnabled = false
local AutoEatEnabled = false
local AutoDoubloonEnabled = false 
local AutoAttackEnabled = false 
local AutoPickEnabled = false
local AutoChestEnabled = false

local GrinderToggle = nil
local CampfireToggle = nil

-- ====================================================================
-- 2. PENGELOMPOKAN KOMPONEN UI (SEMUA DI BAGIAN ATAS)
-- ====================================================================
Win:AddMultiDropdown("Pilih Material Grinder & Bakar", {"Wood", "Metal", "Goo", "Small Gas Can", "Big Gas Can", "Gas Drum"}, function(selectedTable)
    TargetMaterials = selectedTable
end)

Win:AddMultiDropdown("Pilih Senjata Attack", {"Harpoon", "Magma Staff", "Squid Laser", "Rifle", "Flintlock", "Blunderbuss", "Hand Cannon", "Revolver", "Boomstick", "Riptide"}, function(selectedTable)
    TargetWeapons = selectedTable
end)

Win:AddDropdown("Mode Auto Attack", {"Nearest (Global)", "Brutal All Target"}, function(selectedMode)
    AttackMode = selectedMode
end)

GrinderToggle = Win:AddToggle("Mulai Auto Grinder", false, function(state)
    AutoGrinderEnabled = state
end)

CampfireToggle = Win:AddToggle("Auto Campfire (Smart Sorter)", false, function(state)
    AutoCampfireEnabled = state
    if state and GrinderToggle then
        AutoGrinderEnabled = false
        GrinderToggle:Set(false)
    end
end)

Win:AddToggle("Auto Eat", false, function(state)
    AutoEatEnabled = state
end)

Win:AddToggle("Auto Collect", false, function(state)
    AutoDoubloonEnabled = state
end)

Win:AddToggle("Mulai Auto Attack", false, function(state)
    AutoAttackEnabled = state
end)

Win:AddToggle("Auto Pick Material (Harpoon)", false, function(state)
    AutoPickEnabled = state
end)

Win:AddToggle("Auto Open Chest", false, function(state)
    AutoChestEnabled = state
end)


-- ====================================================================
-- 3. SISTEM INTI: DYNAMIC REMOTE FINDER & TOKEN INTERCEPTOR
-- ====================================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CurrentSyncToken = nil
local GameRemoteEvent = nil
local GameRemoteFunction = nil
local SystemReady = false

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "RZY HUB INFO",
        Text = "Silakan lakukan 1x aksi manual di game (pukul/gunakan tool) untuk sinkronisasi token!",
        Duration = 6
    })
end)

pcall(function()
    if hookmetamethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if (method == "FireServer" or method == "InvokeServer") then
                if self.Name == "RemoteEvent" or self.Name == "RemoteFunction" then
                    if type(args[1]) == "number" and type(args[2]) == "string" then
                        if not checkcaller() then
                            if self:IsA("RemoteEvent") then GameRemoteEvent = self end
                            if self:IsA("RemoteFunction") then GameRemoteFunction = self end
                            
                            if not SystemReady then
                                CurrentSyncToken = args[1]
                                SystemReady = true
                                pcall(function()
                                    game:GetService("StarterGui"):SetCore("SendNotification", {
                                        Title = "RZY HUB READY",
                                        Text = "Token diverifikasi! Fitur siap digunakan.",
                                        Duration = 4
                                    })
                                end)
                            end

                            if CurrentSyncToken then
                                CurrentSyncToken = CurrentSyncToken + 1
                                args[1] = CurrentSyncToken
                                return oldNamecall(self, unpack(args))
                            end
                        end
                    end
                end
            end
            return oldNamecall(self, ...)
        end)
    end
end)

local function GetNextToken()
    if not SystemReady or not CurrentSyncToken then return nil end
    CurrentSyncToken = CurrentSyncToken + 1
    return CurrentSyncToken
end

local function SafeRemoteEvent(actionName, ...)
    local token = GetNextToken()
    if token and GameRemoteEvent then GameRemoteEvent:FireServer(token, actionName, ...) end
end

local function SafeRemoteFunction(actionName, ...)
    local token = GetNextToken()
    if token and GameRemoteFunction then return GameRemoteFunction:InvokeServer(token, actionName, ...) end
    return nil
end


-- ====================================================================
-- 4. LOGIKA LOOPING FITUR (BACKGROUND THREADS)
-- ====================================================================

-- LOOP FITUR 1: AUTO GRINDER
task.spawn(function()
    while true do
        if AutoGrinderEnabled then
            local workspace = game:GetService("Workspace")
            local DebrisField = workspace:FindFirstChild("DebrisField")
            local GrinderCol = workspace:FindFirstChild("SpawnIsland") and workspace.SpawnIsland:FindFirstChild("Grinder") and workspace.SpawnIsland.Grinder:FindFirstChild("Collection")
            
            if DebrisField and GrinderCol then
                for _, folderObj in ipairs(DebrisField:GetChildren()) do
                    if not AutoGrinderEnabled then break end
                    local resType = folderObj:GetAttribute("Resource") or folderObj:GetAttribute("Item")
                    local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                    if not resType and part then resType = part:GetAttribute("Resource") or part:GetAttribute("Item") end
                    
                    if resType and TargetMaterials[resType] and part then
                        local isExcluded = false
                        for attrName, attrValue in pairs(folderObj:GetAttributes()) do
                            if string.find(string.lower(attrName), "armor") or string.find(string.lower(tostring(attrValue)), "armor") then
                                isExcluded = true break
                            end
                        end
                        if not isExcluded then
                            local lastHolder = folderObj:GetAttribute("LastHolder") or part:GetAttribute("LastHolder")
                            if lastHolder == LocalPlayer.Name then
                                part.CFrame = GrinderCol.CFrame
                                part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.05)
    end
end)

-- LOOP FITUR 2: SMART CAMPFIRE SORTING
task.spawn(function()
    while true do
        if AutoCampfireEnabled then
            local workspace = game:GetService("Workspace")
            local DebrisField = workspace:FindFirstChild("DebrisField")
            local Dropper = workspace:FindFirstChild("SpawnIsland") and workspace.SpawnIsland:FindFirstChild("Dropper")
            local GrinderCol = workspace:FindFirstChild("SpawnIsland") and workspace.SpawnIsland:FindFirstChild("Grinder") and workspace.SpawnIsland.Grinder:FindFirstChild("Collection")

            if DebrisField then
                local dropperPart = Dropper and (Dropper:IsA("BasePart") and Dropper or Dropper:FindFirstChildWithClass("BasePart") or (Dropper:IsA("Model") and Dropper.PrimaryPart))
                local itemsToProcess = {}
                
                for _, folderObj in ipairs(DebrisField:GetChildren()) do
                    if not AutoCampfireEnabled then break end
                    local resType = folderObj:GetAttribute("Resource") or folderObj:GetAttribute("Item")
                    local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                    if not resType and part then resType = part:GetAttribute("Resource") or part:GetAttribute("Item") end
                    
                    local validFuels = { ["Wood"] = true, ["Small Gas Can"] = true, ["Big Gas Can"] = true, ["Gas Drum"] = true }
                    
                    if resType and TargetMaterials[resType] and part then
                        local lastHolder = folderObj:GetAttribute("LastHolder") or part:GetAttribute("LastHolder")
                        if lastHolder == LocalPlayer.Name then
                            local isFuel = validFuels[resType]
                            local targetDestination = isFuel and dropperPart or GrinderCol
                            
                            if targetDestination then
                                local distance = (part.Position - targetDestination.Position).Magnitude
                                if distance > 3 then
                                    table.insert(itemsToProcess, { Object = folderObj, Part = part, Distance = distance, IsFuel = isFuel, TargetDest = targetDestination })
                                end
                            end
                        end
                    end
                end
                
                table.sort(itemsToProcess, function(a, b) return a.Distance < b.Distance end)
                for _, data in ipairs(itemsToProcess) do
                    if not AutoCampfireEnabled then break end
                    data.Object:SetAttribute("Grabbed", false)
                    data.Object:SetAttribute("LastHolder", LocalPlayer.Name)

                    if data.Part:IsA("BasePart") then
                        data.Part.CFrame = data.IsFuel and (data.TargetDest.CFrame + Vector3.new(0, 3, 0)) or data.TargetDest.CFrame
                        data.Part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    end
                    if data.IsFuel and firetouchinterest then
                        firetouchinterest(data.TargetDest, data.Part, 0) task.wait() firetouchinterest(data.TargetDest, data.Part, 1)
                    end
                    task.wait(0.1)
                end
            end
        end
        task.wait(0.05)
    end
end)

-- LOOP FITUR 3: AUTO EAT
task.spawn(function()
    while true do
        if AutoEatEnabled then
            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
            local FillBar = PlayerGui and PlayerGui:FindFirstChild("HUD") and PlayerGui.HUD:FindFirstChild("Food") and PlayerGui.HUD.Food.Bar.Fill
            if FillBar and FillBar.Size.X.Scale <= 0.7 then
                local DebrisField = game:GetService("Workspace"):FindFirstChild("DebrisField")
                if DebrisField then
                    for _, folderObj in ipairs(DebrisField:GetChildren()) do
                        if not AutoEatEnabled or FillBar.Size.X.Scale >= 0.99 then break end
                        if folderObj:GetAttribute("Food") then
                            SafeRemoteEvent("Eat", "~s" .. folderObj.Name)
                            task.wait(0.05)
                        end
                    end
                end
            end
        end
        task.wait(1)
    end
end)

-- LOOP FITUR 4: AUTO COLLECT (AMMO & CHEST)
task.spawn(function()
    while true do
        if AutoDoubloonEnabled then
            local DebrisField = game:GetService("Workspace"):FindFirstChild("DebrisField")
            local character = LocalPlayer.Character
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            local hasRifle = (character and character:FindFirstChild("Rifle")) or (backpack and backpack:FindFirstChild("Rifle"))
            
            if DebrisField then
                for _, folderObj in ipairs(DebrisField:GetChildren()) do
                    if not AutoDoubloonEnabled then break end
                    local isChest = folderObj:GetAttribute("DoubloonChest")
                    local isAmmo = folderObj:GetAttribute("Ammo")
                    
                    if isChest or (isAmmo and hasRifle) then
                        SafeRemoteEvent("Collect", "~s" .. folderObj.Name)
                        task.wait(0.3)
                    end
                end
            end
        end
        task.wait(1)
    end
end)

-- LOOP FITUR 5: AUTO ATTACK FLEKSIBEL
task.spawn(function()
    while true do
        if AutoAttackEnabled then
            local workspace = game:GetService("Workspace")
            local CreatureContainer = workspace:FindFirstChild("CreatureContainer")
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChild("Humanoid")
            local rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart"))
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            
            if CreatureContainer and rootPart and humanoid then
                local activeWeaponsCount = 0
                for _, isSelected in pairs(TargetWeapons) do if isSelected then activeWeaponsCount = activeWeaponsCount + 1 end end

                local function CheckAndAttackAsync(toolName, attackLogic)
                    if not TargetWeapons[toolName] then return end
                    local tool = character:FindFirstChild(toolName)
                    if activeWeaponsCount > 1 and not tool and backpack then
                        tool = backpack:FindFirstChild(toolName)
                        if tool then humanoid:EquipTool(tool) end
                    end
                    if tool and tool.Parent == character then task.spawn(function() pcall(attackLogic, tool) end) end
                end

                if AttackMode == "Nearest (Global)" then
                    local nearestEnemy, shortestDistance = nil, math.huge
                    for _, enemy in ipairs(CreatureContainer:GetChildren()) do
                        if enemy.Name == "Wraith" or enemy.Name == "Wraith_CLIENT" then continue end
                        local enemyPart = enemy:IsA("BasePart") and enemy or enemy:FindFirstChildWhichIsA("BasePart") or (enemy:IsA("Model") and enemy.PrimaryPart)
                        if enemyPart then
                            local distance = (enemyPart.Position - rootPart.Position).Magnitude
                            if distance <= shortestDistance then shortestDistance = distance nearestEnemy = enemy end
                        end
                    end
                    if nearestEnemy then
                        local enemyPos = nearestEnemy:IsA("Model") and nearestEnemy:GetPivot().Position or nearestEnemy.Position
                        local vecStr = string.format("~v%.4f,%.4f,%.4f", enemyPos.X, enemyPos.Y, enemyPos.Z)
                        
                        for _, wName in ipairs({"Harpoon", "Riptide"}) do CheckAndAttackAsync(wName, function() SafeRemoteFunction("ToolReplicator", "~s" .. wName, "~sHitEnemy", nearestEnemy) end) end
                        CheckAndAttackAsync("Magma Staff", function() SafeRemoteFunction("ToolReplicator", "~sMagma Staff", "~sFire", vecStr) end)
                        CheckAndAttackAsync("Squid Laser", function() SafeRemoteFunction("ToolReplicator", "~sLaser", "~sShoot", vecStr) end)
                    end
                end
            end
        end
        task.wait(0.04)
    end
end)

-- LOOP FITUR 6: BRUTAL AUTO PICK MATERIAL (HARPOON MASS GRAB) - UPDATED VERSION
task.spawn(function()
    while true do
        if AutoPickEnabled then
            local workspace = game:GetService("Workspace")
            local DebrisField = workspace:FindFirstChild("DebrisField")
            local character = LocalPlayer.Character
            local rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChildWhichIsA("BasePart"))
            
            if DebrisField and rootPart then
                -- MELOOPING SEMUA ITEM SEKALIGUS (BRUTAL MODE)
                for _, folderObj in ipairs(DebrisField:GetChildren()) do
                    if not AutoPickEnabled then break end -- Berhenti instan jika toggle dimatikan di tengah loop
                    
                    local resType = folderObj:GetAttribute("Resource") or folderObj:GetAttribute("Item")
                    local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                    
                    if not resType and part then
                        resType = part:GetAttribute("Resource") or part:GetAttribute("Item")
                    end
                    
                    if resType and TargetMaterials[resType] and part then
                        local isExcluded = false
                        for attrName, attrValue in pairs(folderObj:GetAttributes()) do
                            local lowerName = string.lower(attrName)
                            local lowerValue = type(attrValue) == "string" and string.lower(attrValue) or ""
                            if string.find(lowerName, "armor") or string.find(lowerValue, "armor") or
                               string.find(lowerName, "chest") or string.find(lowerValue, "chest") or
                               string.find(lowerName, "leg") or string.find(lowerValue, "leg") then
                                isExcluded = true
                                break
                            end
                        end
                        
                        if not isExcluded then
                            local isGrabbed = folderObj:GetAttribute("Grabbed") or part:GetAttribute("Grabbed")
                            
                            if not isGrabbed then
                                -- Eksekusi asinkron: Menembakkan harpoon ke semua target di saat yang sama
                                task.spawn(function()
                                    pcall(function()
                                        local pos = part.Position
                                        local vecStr = string.format("~v%.4f,%.4f,%.4f", pos.X, pos.Y, pos.Z)
                                        SafeRemoteFunction("ToolReplicator", "~sHarpoon", "~sGrab", folderObj, vecStr)
                                    end)
                                end)
                            end
                        end
                    end
                end
            end
            task.wait(0.2) -- Jeda loop utama (200ms) agar server punya waktu memproses tarikan harpoon massal
        else
            task.wait(0.5) -- Hemat CPU saat toggle off
        end
    end
end)

-- LOOP FITUR 7: AUTO OPEN CHEST
task.spawn(function()
    while true do
        if AutoChestEnabled then
            local ChestsFolder = game:GetService("Workspace"):FindFirstChild("Chests")
            local rootPart = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChildWhichIsA("BasePart"))
            if ChestsFolder and rootPart then
                local nearestChest, shortestDistance = nil, math.huge
                for _, chest in ipairs(ChestsFolder:GetChildren()) do
                    local part = chest:IsA("BasePart") and chest or chest:FindFirstChildWhichIsA("BasePart")
                    if part then
                        local distance = (part.Position - rootPart.Position).Magnitude
                        if distance < shortestDistance then shortestDistance = distance nearestChest = chest end
                    end
                end
                if nearestChest then SafeRemoteFunction("OpenChest", nearestChest) end
            end
        end
        task.wait(1)
    end
end)
