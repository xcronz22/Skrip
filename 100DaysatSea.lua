-- Memuat Library RZY
local RZY_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Win = RZY_Library:MakeWindow("100 Days at Sea")

-- Tabel Penyimpanan Status Dropdown
local TargetMaterials = {
    ["Wood"] = false,
    ["Metal"] = false,
    ["Goo"] = false,
    ["Small Gas Can"] = false,
    ["Big Gas Can"] = false,
    ["Gas Drum"] = false
}

local TargetWeapons = {
    ["Harpoon"] = false,
    ["Magma Staff"] = false,
    ["Squid Laser"] = false,
    ["DualPistols"] = false,
    ["Rifle"] = false,
    ["Flintlock"] = false,
    ["Blunderbuss"] = false,
    ["Hand Cannon"] = false,
    ["Revolver"] = false,
    ["Boomstick"] = false,
    ["Grenade"] = false,
    ["Assault Rifle"] = false,
    ["Riptide"] = false
}

Win:AddMultiDropdown("Material", {"Wood", "Metal", "Goo", "Small Gas Can", "Big Gas Can", "Gas Drum"}, function(selectedTable)
    TargetMaterials = selectedTable
end)

--Win:AddMultiDropdown("Weapon", {"Harpoon", "Magma Staff", "Squid Laser", "DualPistols", "Rifle", "Flintlock", "Blunderbuss", "Hand Cannon", "Revolver", "Boomstick", "Grenade", "Riptide"}, function(selectedTable)
    --TargetWeapons = selectedTable
--end)

local AutoGrinderEnabled = false
local AutoCampfireEnabled = false
local AutoPickEnabled = false

local GrinderToggle = nil
local CampfireToggle = nil

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ====================================================================
-- [SISTEM INTI]: DYNAMIC REMOTE FINDER & TOKEN INTERCEPTOR
-- ====================================================================
local CurrentSyncToken = nil
local GameRemoteEvent = nil
local GameRemoteFunction = nil

local function FindHiddenRemotes()
    local hiddenServices = {
        "Chat", "LocalizationService", "SocialService", "LogService"
    }
    for _, sName in ipairs(hiddenServices) do
        pcall(function()
            local service = game:GetService(sName)
            if service then
                local re = service:FindFirstChild("RemoteEvent")
                local rf = service:FindFirstChild("RemoteFunction")
                if re then GameRemoteEvent = re end
                if rf then GameRemoteFunction = rf end
            end
        end)
    end
end

FindHiddenRemotes()

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
                            
                            if CurrentSyncToken then
                                CurrentSyncToken = CurrentSyncToken + 1
                                args[1] = CurrentSyncToken
                                return oldNamecall(self, unpack(args))
                            else
                                CurrentSyncToken = args[1]
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
    if not CurrentSyncToken then CurrentSyncToken = math.random(100000, 999999) end
    CurrentSyncToken = CurrentSyncToken + 1
    return CurrentSyncToken
end

local function SafeRemoteEvent(actionName, ...)
    if GameRemoteEvent then
        GameRemoteEvent:FireServer(GetNextToken(), actionName, ...)
    else
        FindHiddenRemotes()
        if GameRemoteEvent then GameRemoteEvent:FireServer(GetNextToken(), actionName, ...) end
    end
end

local function SafeRemoteFunction(actionName, ...)
    if GameRemoteFunction then
        return GameRemoteFunction:InvokeServer(GetNextToken(), actionName, ...)
    else
        FindHiddenRemotes()
        if GameRemoteFunction then return GameRemoteFunction:InvokeServer(GetNextToken(), actionName, ...) end
    end
end

-- ====================================================================
-- [FITUR 1]: AUTO GRINDER (PRESERVED POSITION + DISCONNECT)
-- ====================================================================
GrinderToggle = Win:AddToggle("Auto Grinder", false, function(state)
    AutoGrinderEnabled = state
    
    if AutoGrinderEnabled then
        task.spawn(function()
            while AutoGrinderEnabled do
                local workspace = game:GetService("Workspace")
                local DebrisField = workspace:FindFirstChild("DebrisField")
                local GrinderCol = workspace:FindFirstChild("SpawnIsland") and workspace.SpawnIsland:FindFirstChild("Grinder") and workspace.SpawnIsland.Grinder:FindFirstChild("Collection")
                
                if DebrisField and GrinderCol then
                    for _, folderObj in ipairs(DebrisField:GetChildren()) do
                        if not AutoGrinderEnabled then break end
                        
                        if folderObj:GetAttribute("RZY_Processed") then continue end
                        
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
                                local grabber = folderObj:GetAttribute("Grabber") or part:GetAttribute("Grabber")
                                local lastHolder = folderObj:GetAttribute("LastHolder") or part:GetAttribute("LastHolder")
                                
                                local myId = tostring(LocalPlayer.UserId)
                                local myName = LocalPlayer.Name
                                
                                local isCurrentlyMyGrab = (isGrabbed == true and (tostring(grabber) == myId or grabber == myName))
                                local isMyPastItem = (lastHolder == myName)
                                
                                if isCurrentlyMyGrab or isMyPastItem then
                                    -- Posisi pas seperti semula tanpa rx, rz
                                    part.CFrame = GrinderCol.CFrame + Vector3.new(0, 0, 0)
                                    part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                    
                                    -- Langsung putus hubungan & tandai agar dilepas skrip
                                    pcall(function() SafeRemoteEvent("GiveUpOwnership", part) end)
                                    folderObj:SetAttribute("RZY_Processed", true)
                                end
                            end
                        end
                    end
                end
                task.wait(0.05) 
            end
        end)
    end
end)

-- ====================================================================
-- [FITUR 2]: AUTO CAMPFIRE (PRESERVED POSITION + DISCONNECT)
-- ====================================================================
CampfireToggle = Win:AddToggle("Auto Campfire", false, function(state)
    AutoCampfireEnabled = state
    
    if state and GrinderToggle then
        AutoGrinderEnabled = false
        GrinderToggle:Set(false)
    end
    
    if AutoCampfireEnabled then
        task.spawn(function()
            while AutoCampfireEnabled do
                local workspace = game:GetService("Workspace")
                local DebrisField = workspace:FindFirstChild("DebrisField")
                local Dropper = workspace:FindFirstChild("SpawnIsland") and workspace.SpawnIsland:FindFirstChild("Dropper")

                if DebrisField and Dropper then
                    local dropperPart = Dropper:IsA("BasePart") and Dropper or Dropper:FindFirstChildWithClass("BasePart") or (Dropper:IsA("Model") and Dropper.PrimaryPart)
                    
                    if dropperPart then
                        for _, folderObj in ipairs(DebrisField:GetChildren()) do
                            if not AutoCampfireEnabled then break end
                            
                            if folderObj:GetAttribute("RZY_Processed") then continue end
                            
                            local resType = folderObj:GetAttribute("Resource") or folderObj:GetAttribute("Item")
                            local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                            if not resType and part then
                                resType = part:GetAttribute("Resource") or part:GetAttribute("Item")
                            end
                            
                            local validFuels = {
                                ["Wood"] = true, ["Small Gas Can"] = true, ["Big Gas Can"] = true, ["Gas Drum"] = true
                            }
                            
                            if resType and TargetMaterials[resType] and validFuels[resType] and part then
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
                                    local grabber = folderObj:GetAttribute("Grabber") or part:GetAttribute("Grabber")
                                    local lastHolder = folderObj:GetAttribute("LastHolder") or part:GetAttribute("LastHolder")
                                    
                                    local myId = tostring(LocalPlayer.UserId)
                                    local myName = LocalPlayer.Name
                                    
                                    local isCurrentlyMyGrab = (isGrabbed == true and (tostring(grabber) == myId or grabber == myName))
                                    local isMyPastItem = (lastHolder == myName)
                                    
                                    if isCurrentlyMyGrab or isMyPastItem then
                                        -- Posisi pas seperti semula tanpa rx, rz
                                        part.CFrame = dropperPart.CFrame + Vector3.new(0, 0, 0)
                                        part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                        
                                        -- Langsung putus hubungan & tandai agar dilepas skrip
                                        pcall(function() SafeRemoteEvent("GiveUpOwnership", part) end)
                                        folderObj:SetAttribute("RZY_Processed", true)
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(0.05) 
            end
        end)
    end
end)

-- ====================================================================
-- [FITUR 3]: AUTO EAT (DEFAULT AKTIF)
-- ====================================================================
local AutoEatEnabled = true

local function RunAutoEat()
    task.spawn(function()
        local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
        local FillBar = PlayerGui:WaitForChild("HUD"):WaitForChild("Food"):WaitForChild("Bar"):WaitForChild("Fill")
        
        while AutoEatEnabled do
            if FillBar.Size.X.Scale <= 0.7 then
                local workspace = game:GetService("Workspace")
                local DebrisField = workspace:FindFirstChild("DebrisField")
                
                if DebrisField then
                    for _, folderObj in ipairs(DebrisField:GetChildren()) do
                        if not AutoEatEnabled or FillBar.Size.X.Scale >= 0.99 then break end
                        
                        local isFood = folderObj:GetAttribute("Food")
                        local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                        if not isFood and part then isFood = part:GetAttribute("Food") end
                        
                        if isFood and part then
                            local isGrabbed = folderObj:GetAttribute("Grabbed") or part:GetAttribute("Grabbed")
                            local grabber = folderObj:GetAttribute("Grabber") or part:GetAttribute("Grabber")
                            
                            if isGrabbed and tostring(grabber) ~= tostring(LocalPlayer.UserId) and grabber ~= LocalPlayer.Name then continue end
                            
                            SafeRemoteEvent("Eat", "~s" .. folderObj.Name)
                            task.wait(0.05) 
                        end
                    end
                end
            end
            task.wait(1) 
        end
    end)
end

Win:AddToggle("Auto Eat", true, function(state)
    AutoEatEnabled = state
    if AutoEatEnabled then RunAutoEat() end
end)
RunAutoEat() -- EKSEKUSI OTOMATIS

-- ====================================================================
-- [FITUR 4]: AUTO COLLECT (DEFAULT AKTIF)
-- ====================================================================
local CollectedItems = {} 
local HasDiamondChest = false
local AutoDoubloonEnabled = true -- Default Aktif

LocalPlayer.CharacterAdded:Connect(function()
    CollectedItems = {}
    HasDiamondChest = false
end)

local TargetWeaponsCollect = {
    ["machete"] = true, ["poku poku"] = true, ["swordfish spear"] = true, ["ghost cutlass"] = true,
    ["flintlock"] = true, ["blunderbuss"] = true, ["rifle"] = true, ["boomstick"] = true,
    ["magma staff"] = true, ["ice staff"] = true, ["squid laser"] = true, ["revolver"] = true, ["hand cannon"] = true, 
    ["angler flare"] = true
}

local function RunAutoCollect()
    task.spawn(function()
        while AutoDoubloonEnabled do
            local workspace = game:GetService("Workspace")
            local DebrisField = workspace:FindFirstChild("DebrisField")
            
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChild("Humanoid")
            local rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChildWhichIsA("BasePart"))
            
            if humanoid and humanoid.Health <= 0 then
                HasDiamondChest = false
                CollectedItems = {}
            end
            
            if DebrisField and rootPart then
                for _, folderObj in ipairs(DebrisField:GetChildren()) do
                    if not AutoDoubloonEnabled then break end
                    
                    local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                    local uniqueId = folderObj.Name 
                    local isChest = false
                    
                    if folderObj:GetAttribute("DoubloonChest") or (part and part:GetAttribute("DoubloonChest")) then isChest = true end
                    if not isChest then
                        for attrName, attrValue in pairs(folderObj:GetAttributes()) do
                            local lowerName, lowerValue = string.lower(attrName), type(attrValue) == "string" and string.lower(attrValue) or ""
                            if string.find(lowerName, "doubloonchest") or string.find(lowerValue, "doubloonchest") then
                                isChest = true; break
                            end
                        end
                    end
                    
                    if isChest then
                        SafeRemoteEvent("Collect", "~s" .. uniqueId)
                        task.wait(0.3) 
                        continue 
                    end
                    
                    if part then
                        local resType = folderObj:GetAttribute("Resource") or folderObj:GetAttribute("Item")
                        if not resType then resType = part:GetAttribute("Resource") or part:GetAttribute("Item") end
                        if not resType then resType = part.Name end 
                        
                        if resType then
                            local distance = (part.Position - rootPart.Position).Magnitude
                            if distance <= 15 then
                                local shouldCollect = false
                                local lowerRes = string.lower(resType)
                                
                                if string.find(lowerRes, "ammo") or string.find(lowerRes, "bandage") then
                                    shouldCollect = true
                                elseif string.find(lowerRes, "diamond") and (string.find(lowerRes, "chest") or string.find(lowerRes, "armor")) then
                                    if not HasDiamondChest then shouldCollect = true; HasDiamondChest = true end
                                else
                                    for wName, _ in pairs(TargetWeaponsCollect) do
                                        if string.find(lowerRes, wName) then
                                            if not CollectedItems[wName] then shouldCollect = true; CollectedItems[wName] = true end
                                            break 
                                        end
                                    end
                                end
                                
                                if shouldCollect then
                                    SafeRemoteEvent("Collect", "~s" .. uniqueId)
                                    task.wait(0.1)
                                end
                            end
                        end
                    end
                end
            end
            task.wait(1) 
        end
    end)
end

Win:AddToggle("Auto Collect", true, function(state)
    AutoDoubloonEnabled = state
    if AutoDoubloonEnabled then RunAutoCollect() end
end)
RunAutoCollect() -- EKSEKUSI OTOMATIS

-- ====================================================================
-- [FITUR 5]: AUTO ATTACK (MELEE & GUNS) - CLEANED & FIXED WRAITH
-- ====================================================================
local AttackMode = "Brutal All Target" 
local BrutalAttackRange = 200 
local AutoAttackEnabled = true 

Win:AddDropdown("Mode Auto Attack", {"Nearest (Global)", "Brutal All Target"}, function(selectedMode)
    AttackMode = selectedMode
end)

Win:AddInput("Brutal Attack Range", "200", function(value)
    local num = tonumber(value)
    if num then BrutalAttackRange = num end
end)

-- [FUNGSI]: Pengecekan Nyawa Anti-Bug (Strict Custom Health Check)
local function IsEnemyAlive(enemy)
    -- Cek Custom Health buatan developer (Prioritas)
    local healthVal = enemy:FindFirstChild("Health")
    if healthVal and (healthVal:IsA("IntValue") or healthVal:IsA("NumberValue")) then
        return healthVal.Value > 0 
    end
    
    -- Cek nyawa Humanoid bawaan Roblox
    local humanoid = enemy:FindFirstChild("Humanoid") or enemy:FindFirstChildOfClass("Humanoid")
    if humanoid then
        return humanoid.Health > 0
    end
    
    return true
end

local function RunAutoAttack()
    task.spawn(function()
        while AutoAttackEnabled do
            pcall(function()
                local workspace = game:GetService("Workspace")
                local CreatureContainer = workspace:FindFirstChild("CreatureContainer")
                
                local player = game:GetService("Players").LocalPlayer
                local character = player.Character
                local humanoid = character and character:FindFirstChild("Humanoid")
                local rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChildWhichIsA("BasePart"))
                local backpack = player:FindFirstChild("Backpack")
                
                if CreatureContainer and rootPart and humanoid then
                    local function CheckAndAttackAsync(toolName, attackLogic)
                        local isSelected = TargetWeapons and TargetWeapons[toolName] == true
                        local tool = character:FindFirstChild(toolName)
                        
                        if not isSelected and not tool then return false end
                        
                        if not tool and isSelected and backpack then
                            tool = backpack:FindFirstChild(toolName)
                            if tool then humanoid:EquipTool(tool) end
                        end
                        
                        if tool then 
                            task.spawn(function() pcall(attackLogic, tool) end) 
                            return true
                        end
                        return false
                    end

                    -- [LOGIKA 1]: SERANG SATU MUSUH TERDEKAT (NEAREST)
                    if AttackMode == "Nearest (Global)" then
                        local nearestEnemy, nearestEnemyPart, shortestDistance = nil, nil, math.huge 
                        for _, enemy in ipairs(CreatureContainer:GetChildren()) do
                            
                            -- [PERBAIKAN]: ABAIKAN WRAITH
                            if enemy.Name == "Wraith" or enemy.Name == "Wraith_CLIENT" then continue end
                            
                            -- CEK NYAWA: Lewati target mati (bug)
                            if not IsEnemyAlive(enemy) then continue end
                            
                            local enemyPart = enemy:IsA("BasePart") and enemy or enemy:FindFirstChildWhichIsA("BasePart") or (enemy:IsA("Model") and enemy.PrimaryPart)
                            if enemyPart then
                                local distance = (enemyPart.Position - rootPart.Position).Magnitude
                                if distance <= shortestDistance then
                                    shortestDistance = distance; nearestEnemy = enemy; nearestEnemyPart = enemyPart
                                end
                            end
                        end
                        
                        if nearestEnemy and nearestEnemyPart then
                            local enemyPos = nearestEnemy:IsA("Model") and nearestEnemy:GetPivot().Position or nearestEnemyPart.Position
                            local vecStr = string.format("~v%.4f,%.4f,%.4f", enemyPos.X, enemyPos.Y, enemyPos.Z)
                            
                            pcall(function()
                                -- Senjata Remote Jarak Jauh
                                for _, wName in ipairs({"Harpoon", "Riptide"}) do
                                    CheckAndAttackAsync(wName, function(t) SafeRemoteFunction("ToolReplicator", "~s" .. wName, "~sHitEnemy", nearestEnemy) end)
                                end
                                CheckAndAttackAsync("Magma Staff", function(t) SafeRemoteFunction("ToolReplicator", "~sMagma Staff", "~sFire", vecStr) end)
                                CheckAndAttackAsync("Squid Laser", function(t) SafeRemoteFunction("ToolReplicator", "~sLaser", "~sShoot", vecStr) end)
                                CheckAndAttackAsync("Grenade", function(t) SafeRemoteFunction("ToolReplicator", "~sGrenade", "~sThrow", vecStr, vecStr) end)
                                
                                local gunTypes = {"Rifle", "Flintlock", "Blunderbuss", "Revolver", "Hand Cannon", "Boomstick", "DualPistols", "Assault Rifle"}
                                for _, gunName in ipairs(gunTypes) do
                                    CheckAndAttackAsync(gunName, function(t)
                                        local firePart = t:FindFirstChild("Handle") or t:FindFirstChildWhichIsA("BasePart") or rootPart
                                        if firePart then
                                            local direction = (enemyPos - rootPart.Position).Unit
                                            local gunFormatStr = string.format("~t{1=~f%.4f,%.4f,%.4f:%.4f,%.4f,%.4fZ0}", enemyPos.X, enemyPos.Y, enemyPos.Z, direction.X, direction.Y, direction.Z)
                                            SafeRemoteFunction("ToolReplicator", "~sGun", "~sShoot", firePart, gunFormatStr)
                                        end
                                    end)
                                end

                                -- Senjata Melee
                                local meleeTypes = {"Machete", "Ghost Cutlass", "Poku Poku", "Swordfish Spear"} 
                                for _, meleeName in ipairs(meleeTypes) do
                                    CheckAndAttackAsync(meleeName, function(t)
                                        local handle = t:FindFirstChild("Handle") or t:FindFirstChildWhichIsA("BasePart")
                                        if handle and nearestEnemyPart then
                                            t:Activate()
                                            if firetouchinterest then
                                                firetouchinterest(handle, nearestEnemyPart, 0)
                                                task.wait(0.01)
                                                firetouchinterest(handle, nearestEnemyPart, 1)
                                            end
                                        end
                                    end)
                                end
                            end)
                        end
                        
                    -- [LOGIKA 2]: SERANG SEMUA MUSUH DALAM RADIUS (BRUTAL)
                    elseif AttackMode == "Brutal All Target" then
                        for _, enemy in ipairs(CreatureContainer:GetChildren()) do
                            
                            -- [PERBAIKAN]: ABAIKAN WRAITH
                            if enemy.Name == "Wraith" or enemy.Name == "Wraith_CLIENT" then continue end
                            
                            -- CEK NYAWA: Lewati target mati (bug)
                            if not IsEnemyAlive(enemy) then continue end
                            
                            local enemyPart = enemy:IsA("BasePart") and enemy or enemy:FindFirstChildWhichIsA("BasePart") or (enemy:IsA("Model") and enemy.PrimaryPart)
                            
                            if enemyPart then
                                local enemyPos = enemy:IsA("Model") and enemy:GetPivot().Position or enemyPart.Position
                                local distance = (enemyPos - rootPart.Position).Magnitude
                                
                                if distance <= BrutalAttackRange then
                                    local vecStr = string.format("~v%.4f,%.4f,%.4f", enemyPos.X, enemyPos.Y, enemyPos.Z)
                                    pcall(function()
                                        -- Senjata Remote Jarak Jauh
                                        for _, wName in ipairs({"Harpoon", "Riptide"}) do
                                            CheckAndAttackAsync(wName, function(t) SafeRemoteFunction("ToolReplicator", "~s" .. wName, "~sHitEnemy", enemy) end)
                                        end
                                        CheckAndAttackAsync("Magma Staff", function(t) SafeRemoteFunction("ToolReplicator", "~sMagma Staff", "~sFire", vecStr) end)
                                        CheckAndAttackAsync("Squid Laser", function(t) SafeRemoteFunction("ToolReplicator", "~sLaser", "~sShoot", vecStr) end)
                                        CheckAndAttackAsync("Grenade", function(t) SafeRemoteFunction("ToolReplicator", "~sGrenade", "~sThrow", vecStr, vecStr) end)

                                        local gunTypes = {"Rifle", "Flintlock", "Blunderbuss", "Revolver", "Hand Cannon", "Boomstick", "DualPistols", "Assault Rifle"}
                                        for _, gunName in ipairs(gunTypes) do
                                            CheckAndAttackAsync(gunName, function(t)
                                                local firePart = t:FindFirstChild("Handle") or t:FindFirstChildWhichIsA("BasePart") or rootPart
                                                if firePart then
                                                    local direction = (enemyPos - rootPart.Position).Unit
                                                    local gunFormatStr = string.format("~t{1=~f%.4f,%.4f,%.4f:%.4f,%.4f,%.4fZ0}", enemyPos.X, enemyPos.Y, enemyPos.Z, direction.X, direction.Y, direction.Z)
                                                    SafeRemoteFunction("ToolReplicator", "~sGun", "~sShoot", firePart, gunFormatStr)
                                                end
                                            end)
                                        end

                                        -- Senjata Melee
                                        local meleeTypes = {"Machete", "Ghost Cutlass", "Poku Poku", "Swordfish Spear"} 
                                        for _, meleeName in ipairs(meleeTypes) do
                                            CheckAndAttackAsync(meleeName, function(t)
                                                local handle = t:FindFirstChild("Handle") or t:FindFirstChildWhichIsA("BasePart")
                                                if handle and enemyPart then
                                                    t:Activate()
                                                    if firetouchinterest then
                                                        firetouchinterest(handle, enemyPart, 0)
                                                        task.wait(0.01)
                                                        firetouchinterest(handle, enemyPart, 1)
                                                    end
                                                end
                                            end)
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(0.1) 
        end
    end)
end

Win:AddToggle("Auto Attack", true, function(state)
    AutoAttackEnabled = state
    if AutoAttackEnabled then RunAutoAttack() end
end)
RunAutoAttack()

-- ====================================================================
-- [FITUR 6]: AUTO PICK MATERIAL (NEAREST) + INJEKSI AUTO COOK
-- ====================================================================
Win:AddToggle("Auto Pick Material", false, function(state)
    AutoPickEnabled = state
    
    if AutoPickEnabled then
        task.spawn(function()
            while AutoPickEnabled do
                local workspace = game:GetService("Workspace")
                local DebrisField = workspace:FindFirstChild("DebrisField")
                
                local character = LocalPlayer.Character
                local rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChildWhichIsA("BasePart"))
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                
                if DebrisField and rootPart then
                    local nearestItem = nil
                    local nearestPart = nil
                    local shortestDistance = math.huge
                    
                    local pullTool = "Harpoon"
                    if (character and character:FindFirstChild("Riptide")) or (backpack and backpack:FindFirstChild("Riptide")) then
                        pullTool = "Riptide"
                    end
                    
                    for _, folderObj in ipairs(DebrisField:GetChildren()) do
                        -- Jika barang sudah masuk Grinder/Campfire, langsung LEWATKAN!
                        if folderObj:GetAttribute("RZY_Processed") then continue end
                                
                        local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                        if not part then continue end
                        
                        local isGrabbed = folderObj:GetAttribute("Grabbed") or part:GetAttribute("Grabbed")
                        if isGrabbed then continue end 
                        
                        -- 1. Evaluasi Material
                        local resType = folderObj:GetAttribute("Resource") or folderObj:GetAttribute("Item")
                        if not resType then resType = part:GetAttribute("Resource") or part:GetAttribute("Item") end
                        
                        local isTargetMaterial = false
                        if resType and TargetMaterials[resType] then
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
                            if not isExcluded then isTargetMaterial = true end
                        end
                        
                        -- 2. Evaluasi Makanan (Hanya jika Auto Cook Chowder aktif)
                        local isTargetFood = false
                        if AutoCookChowderEnabled then
                            if folderObj:GetAttribute("Food") ~= nil or folderObj:GetAttribute("food") ~= nil then
                                isTargetFood = true
                            elseif part and (part:GetAttribute("Food") ~= nil or part:GetAttribute("food") ~= nil) then
                                isTargetFood = true
                            end
                        end
                        
                        -- Eksekusi Jarak
                        if isTargetMaterial or isTargetFood then
                            local distance = (part.Position - rootPart.Position).Magnitude
                            if distance < shortestDistance then
                                shortestDistance = distance
                                nearestItem = folderObj
                                nearestPart = part
                            end
                        end
                    end
                    
                    if nearestItem and nearestPart then
                        pcall(function()
                            local pos = nearestPart.Position
                            local vecStr = string.format("~v%.4f,%.4f,%.4f", pos.X, pos.Y, pos.Z)
                            SafeRemoteFunction("ToolReplicator", "~s" .. pullTool, "~sGrab", nearestItem, vecStr)
                        end)
                    end
                end
                task.wait(0.1) 
            end
        end)
    end
end)

-- ====================================================================
-- [FITUR 7]: AUTO OPEN CHEST (DEFAULT AKTIF)
-- ====================================================================
local AutoChestEnabled = true

local function RunAutoChest()
    task.spawn(function()
        while AutoChestEnabled do
            local workspace = game:GetService("Workspace")
            local ChestsFolder = workspace:FindFirstChild("Chests")
            local IslandContainer = workspace:FindFirstChild("IslandContainer")
            
            local character = LocalPlayer.Character
            local rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart"))
            
            if rootPart then
                local nearestChest = nil
                local shortestDistance = 15 
                local potentialChests = {}
                
                if ChestsFolder then
                    for _, chest in ipairs(ChestsFolder:GetChildren()) do table.insert(potentialChests, chest) end
                end
                
                if IslandContainer then
                    for _, island in ipairs(IslandContainer:GetChildren()) do
                        for _, item in ipairs(island:GetChildren()) do
                            if string.find(string.lower(item.Name), "chest") then table.insert(potentialChests, item) end
                        end
                    end
                end
                
                for _, chest in ipairs(potentialChests) do
                    local part = chest:IsA("BasePart") and chest or chest:FindFirstChildWhichIsA("BasePart")
                    if part then
                        local distance = (part.Position - rootPart.Position).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance; nearestChest = chest
                        end
                    end
                end
                
                if nearestChest then pcall(function() SafeRemoteFunction("OpenChest", nearestChest) end) end
            end
            task.wait(0.1) 
        end
    end)
end

Win:AddToggle("Auto Open Chest", true, function(state)
    AutoChestEnabled = state
    if AutoChestEnabled then RunAutoChest() end
end)
RunAutoChest() -- EKSEKUSI OTOMATIS

-- ====================================================================
-- [FITUR 8]: AUTO FISHING (DEFAULT AKTIF)
-- ====================================================================
local AutoFishingEnabled = true

local function RunAutoFishing()
    task.spawn(function()
        while AutoFishingEnabled do
            local character = LocalPlayer.Character
            if character then
                local equippedTool = character:FindFirstChild("Fishing Rod")
                if equippedTool then
                    local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart")
                    if rootPart then
                        local pos = rootPart.Position
                        local dir = rootPart.CFrame.LookVector
                        local vecStr = string.format("~f%.4f,%.4f,%.4f:%.4f,%.4f,%.4fZ0", pos.X, pos.Y + 1, pos.Z, dir.X, dir.Y, dir.Z)
                        
                        pcall(function()
                            SafeRemoteFunction("ToolReplicator", "~sFishing Rod", "~sCast")
                            SafeRemoteFunction("ToolReplicator", "~sFishing Rod", "~sFishPoof", vecStr)
                        end)
                    end
                end
            end
            task.wait(0.5) 
        end
    end)
end

Win:AddToggle("Auto Fishing", true, function(state)
    AutoFishingEnabled = state
    if AutoFishingEnabled then RunAutoFishing() end
end)
RunAutoFishing() -- EKSEKUSI OTOMATIS

-- ====================================================================
-- [FITUR 9]: AUTO STORE (DEFAULT AKTIF)
-- ====================================================================
local AutoStoreEnabled = true

local function RunAutoStore()
    task.spawn(function()
        local myId = tostring(LocalPlayer.UserId)
        local myName = LocalPlayer.Name
        
        while AutoStoreEnabled do
            local workspace = game:GetService("Workspace")
            local DebrisField = workspace:FindFirstChild("DebrisField")
            
            if DebrisField then
                for _, folderObj in ipairs(DebrisField:GetChildren()) do
                    if not AutoStoreEnabled then break end
                    if folderObj:GetAttribute("RZY_Processed") then continue end
                    
                    local isGrabbed = folderObj:GetAttribute("Grabbed")
                    if not isGrabbed then
                        local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                        if part then isGrabbed = part:GetAttribute("Grabbed") end
                    end
                    
                    if isGrabbed then
                        local grabber = tostring(folderObj:GetAttribute("Grabber"))
                        if grabber == "nil" then
                            local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                            if part then grabber = tostring(part:GetAttribute("Grabber")) end
                        end
                        
                        if grabber == myId or grabber == myName then
                            local resType = folderObj:GetAttribute("Resource") or folderObj:GetAttribute("Item")
                            local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                            
                            if not resType and part then resType = part:GetAttribute("Resource") or part:GetAttribute("Item") end
                            
                            if resType == "Wood" or resType == "Metal" then
                                if part then
                                    pcall(function()
                                        SafeRemoteEvent("StoreItem", part)
                                        folderObj:SetAttribute("RZY_Processed", true)
                                    end)
                                end
                            end
                        end
                    end
                end
            end
            task.wait(0.5) 
        end
    end)
end

Win:AddToggle("Auto Store (Wood & Metal)", true, function(state)
    AutoStoreEnabled = state
    if AutoStoreEnabled then RunAutoStore() end
end)
RunAutoStore() -- EKSEKUSI OTOMATIS

-- ====================================================================
-- [FITUR 10]: AUTO DISCOVER ISLANDS (SKY DROP & STAY + EXCLUSION)
-- ====================================================================
local AutoDiscoverEnabled = false
local DiscoveredIslands = {} -- Tabel memori agar pulau yang sudah dikunjungi tidak di-TP lagi

-- Daftar kata kunci pulau yang TIDAK BOLEH dikunjungi
local ExcludedIslandKeywords = {
    "RivalRig1", 
    "RivalRig2", 
    "RivalRig3", 
    "GhostGalleon", 
    "SquidIsland", 
    "MushroomIsland", 
    "CanonIsland"
}

Win:AddToggle("Auto Discover Island", false, function(state)
    AutoDiscoverEnabled = state
    
    if AutoDiscoverEnabled then
        task.spawn(function()
            while AutoDiscoverEnabled do
                pcall(function()
                    local char = LocalPlayer.Character
                    local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart"))
                    local container = workspace:FindFirstChild("IslandContainer")
                    
                    if root and container then
                        -- 1. Cari semua pulau yang belum pernah kita kunjungi
                        local pendingIslands = {}
                        for _, island in ipairs(container:GetChildren()) do
                            local isExcluded = false
                            
                            -- Pengecekan nama pulau terhadap daftar blacklist
                            for _, keyword in ipairs(ExcludedIslandKeywords) do
                                if string.find(island.Name, keyword) then
                                    isExcluded = true
                                    break
                                end
                            end
                            
                            -- Jika pulau belum dikunjungi dan BUKAN pulau yang dilarang
                            if not DiscoveredIslands[island] and not isExcluded then
                                table.insert(pendingIslands, island)
                            end
                        end
                        
                        -- 2. Jika ada pulau baru yang belum dikunjungi, eksekusi!
                        if #pendingIslands > 0 then
                            for _, island in ipairs(pendingIslands) do
                                -- Pengaman: Berhenti jika toggle dimatikan di tengah jalan
                                if not AutoDiscoverEnabled or not root.Parent then return end
                                
                                -- AMAN DARI NYANGKUT: Mengambil titik tengah pulau, lalu ditambah ketinggian 50 stud ke atas
                                local targetCFrame = island:GetPivot()
                                root.CFrame = targetCFrame * CFrame.new(0, 50, 0)
                                
                                -- JEDA: Diam 1 detik (Ada waktu jatuh dari langit dan server membaca "Discovered")
                                task.wait(2) 
                                
                                -- TANDAI: Masukkan pulau ini ke tabel agar tidak di-TP lagi
                                DiscoveredIslands[island] = true
                            end
                        end
                    end
                end)
                
                -- Jeda santai mengecek folder IslandContainer setiap 1 detik
                task.wait(1) 
            end
        end)
    end
end)

-- ====================================================================
-- [FITUR 11]: UNIVERSAL FLY (UPGRADED: FIX JITTER, STUCK, NOCLIP & FIXCAM)
-- ====================================================================
local UniversalFlyEnabled = true 
local UniversalFlySpeed = 150

Win:AddInput("Fly Speed (Universal)", "150", function(val)
    local num = tonumber(val)
    if num then
        UniversalFlySpeed = num
    end
end)

local UFlyConnection
local currentMoverTarget = nil
local currentBG = nil
local currentBV = nil

-- Fungsi untuk membersihkan efek terbang secara bersih
local function ClearFlyMovers()
    if currentBG then currentBG:Destroy(); currentBG = nil end
    if currentBV then currentBV:Destroy(); currentBV = nil end
    currentMoverTarget = nil
    
    pcall(function()
        local char = game:GetService("Players").LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then 
            hum.PlatformStand = false 
        end
    end)
end

local function StopUniversalFly()
    UniversalFlyEnabled = false
    if UFlyConnection then
        UFlyConnection:Disconnect()
        UFlyConnection = nil
    end
    ClearFlyMovers()
end

-- Fungsi FixCam
local function ApplyFixCam(humanoid)
    task.spawn(function()
        task.wait(0.15) -- Sedikit lebih lama agar transisi fisika kendaraan selesai
        local camera = workspace.CurrentCamera
        if camera and humanoid then
            camera.CameraType = Enum.CameraType.Custom
            camera.CameraSubject = humanoid
        end
    end)
end

-- Fungsi Utama Terbang
local function StartUniversalFly()
    if UFlyConnection then return end 
    
    local runService = game:GetService("RunService")
    local uis = game:GetService("UserInputService")
    
    -- MENGGUNAKAN STEPPED: Berjalan sebelum kalkulasi fisika, ampuh mengatasi GETARAN!
    UFlyConnection = runService.Stepped:Connect(function()
        if not UniversalFlyEnabled then
            StopUniversalFly()
            return
        end

        local player = game:GetService("Players").LocalPlayer
        local char = player.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local rootPart = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart"))
        local camera = workspace.CurrentCamera
        
        if not humanoid or not rootPart then return end
        
        -- [INTEGRASI NOCLIP]: Mengubah semua part tubuh menjadi tembus pandang/tembok
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
        
        -- [SMART DETECT]
        local expectedTarget = humanoid.SeatPart or rootPart
        local isVehicle = (expectedTarget ~= rootPart)
        
        -- Transisi Penggerak
        if currentMoverTarget ~= expectedTarget then
            local wasVehicle = (currentMoverTarget and (currentMoverTarget:IsA("VehicleSeat") or currentMoverTarget:IsA("Seat")))
            
            ClearFlyMovers()
            currentMoverTarget = expectedTarget
            
            -- [ANTI STUCK/NEMPEL BUG]: Jika baru turun dari kendaraan, paksa lepas dan lompatkan sedikit
            if wasVehicle and not isVehicle then
                humanoid.Sit = false
                -- Beri jeda sangat kecil sebelum PlatformStand aktif agar karakter terlepas dari las kendaraan
                rootPart.CFrame = rootPart.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.05) 
            end
            
            if isVehicle then
                ApplyFixCam(humanoid)
            end
            
            -- Pengaturan BodyGyro yang lebih soft untuk Anti-Getar pada kendaraan
            currentBG = Instance.new("BodyGyro")
            currentBG.P = 9e4
            -- Membatasi Torque agar tidak berantem dengan fisika bawaan kendaraan
            currentBG.maxTorque = isVehicle and Vector3.new(1e5, 1e5, 1e5) or Vector3.new(9e9, 9e9, 9e9) 
            currentBG.cframe = expectedTarget.CFrame
            currentBG.Parent = expectedTarget

            currentBV = Instance.new("BodyVelocity")
            currentBV.velocity = Vector3.new(0, 0, 0)
            currentBV.maxForce = Vector3.new(9e9, 9e9, 9e9)
            currentBV.Parent = expectedTarget
        end
        
        humanoid.PlatformStand = not isVehicle

        local moveDir = Vector3.new(0, 0, 0)

        -- [LOGIKA UNIVERSAL + DEADZONE ANTI TERBANG SENDIRI]
        local moveMagnitude = humanoid.MoveDirection.Magnitude
        -- Deadzone: Abaikan pergerakan joystick yang kurang dari 0.1 (mencegah jalan sendiri)
        if moveMagnitude > 0.1 then
            local localMove = camera.CFrame:VectorToObjectSpace(humanoid.MoveDirection)
            
            if localMove.Z < -0.1 or localMove.Z > 0.1 then
                moveDir = moveDir + (camera.CFrame.LookVector * -localMove.Z)
            end
            if localMove.X > 0.1 or localMove.X < -0.1 then
                moveDir = moveDir + (camera.CFrame.RightVector * localMove.X)
            end
        end

        -- KONTROL PC
        if uis:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if uis:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end

        -- Eksekusi
        if currentBG and currentBV then
            currentBG.cframe = camera.CFrame
            
            -- Memastikan velocity benar-benar di-Nol-kan jika tidak ada input
            if moveDir.Magnitude > 0 then
                currentBV.velocity = moveDir.Unit * UniversalFlySpeed
            else
                currentBV.velocity = Vector3.new(0, 0, 0)
            end
        end
    end)
end

Win:AddToggle("Universal Fly", true, function(state)
    UniversalFlyEnabled = state
    if UniversalFlyEnabled then
        StartUniversalFly()
    else
        StopUniversalFly()
    end
end)

StartUniversalFly()

-- ====================================================================
-- [FITUR 12]: AUTO DISMANTLE ALL (SPAWN ISLAND) - FIXED
-- ====================================================================
local AutoDismantleEnabled = false

local function RunAutoDismantle()
    task.spawn(function()
        while AutoDismantleEnabled do
            pcall(function()
                local spawnIsland = workspace:FindFirstChild("SpawnIsland")
                local craftedFolder = spawnIsland and spawnIsland:FindFirstChild("Crafted")
                
                if craftedFolder then
                    for _, item in ipairs(craftedFolder:GetChildren()) do
                        if not AutoDismantleEnabled then break end 
                        
                        -- [FILTER PENGECUALIAN]: 
                        -- Kita hanya akan menghancurkan jika nama item mengandung karakter ":" 
                        -- yang artinya lantai tersebut memiliki ID (lantai buatan pemain).
                        -- Jika namanya HANYA "WoodenFloor", kita akan melewatinya (continue).
                        if string.find(item.Name, ":") then
                            
                            local targetString = "~s" .. item.Name
                            
                            -- Memanggil fungsi penghancur
                            SafeRemoteFunction("ToolReplicator", "~sWrench", "~sTeardown", targetString)
                            
                            -- Delay agar tidak terdeteksi spam oleh server
                            task.wait(0.1) 
                            
                        else
                            -- Ini adalah lantai "WoodenFloor" bawaan (base awal)
                            -- Kita tidak melakukan apa-apa di sini (skip)
                            continue
                        end
                    end
                end
            end)
            task.wait(1) 
        end
    end)
end

Win:AddToggle("Auto Dismantle All", false, function(state)
    AutoDismantleEnabled = state
    if AutoDismantleEnabled then
        RunAutoDismantle()
    end
end)

-- ====================================================================
-- [FITUR 13]: SOFT ANTI-LAG (WATER & DEBRIS OPTIMIZER)
-- ====================================================================
local SoftAntiLagEnabled = true

Win:AddToggle("Soft Anti-Lag (Sea & Debris)", true, function(state)
    SoftAntiLagEnabled = state
    
    if SoftAntiLagEnabled then
        task.spawn(function()
            local workspace = game:GetService("Workspace")
            local terrain = workspace.Terrain
            local Lighting = game:GetService("Lighting")
            
            while SoftAntiLagEnabled do
                pcall(function()
                    -- [OPTIMASI LAUT]: Mematikan gelombang dan pantulan cahaya laut
                    -- Ini adalah sumber lag terbesar di game bertema lautan
                    if terrain then
                        terrain.WaterWaveSize = 0
                        terrain.WaterWaveSpeed = 0
                        terrain.WaterReflectance = 0
                    end
                    
                    -- [OPTIMASI PENCAHAYAAN GLOBAL]: Kurangi pantulan silau
                    Lighting.GlobalShadows = false -- Mematikan bayangan global (Sangat ampuh menaikkan FPS)
                    Lighting.EnvironmentDiffuseScale = 0
                    Lighting.EnvironmentSpecularScale = 0
                    
                    -- [OPTIMASI DEBRIS]: Matikan bayangan pada ratusan barang yang mengapung
                    local DebrisField = workspace:FindFirstChild("DebrisField")
                    if DebrisField then
                        for _, folderObj in ipairs(DebrisField:GetChildren()) do
                            -- Pengecekan agar tidak membebani CPU, hanya memproses beberapa part
                            local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                            if part and part.CastShadow then
                                part.CastShadow = false
                            end
                        end
                    end
                end)
                
                -- Jeda 5 detik: Sangat ramah CPU karena tidak perlu di-scan setiap saat
                task.wait(5)
            end
        end)
    else
        -- Jika dimatikan, kembalikan ke settingan normal/standar Roblox
        pcall(function()
            local terrain = game:GetService("Workspace").Terrain
            if terrain then
                terrain.WaterWaveSize = 0.15
                terrain.WaterWaveSpeed = 10
                terrain.WaterReflectance = 1
            end
            game:GetService("Lighting").GlobalShadows = true
        end)
    end
end)

-- ====================================================================
-- [FITUR: AUTO VISIBLE HUD COMPONENTS (LANGSUNG AKTIF SEKALI JALAN)]
-- ====================================================================
task.spawn(function()
    local Player = game:GetService("Players").LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")
    
    pcall(function()
        -- Menunggu HUD utama dan Features UI terbentuk (maksimal 10 detik)
        local HUD = PlayerGui:WaitForChild("HUD", 10)
        local FeaturesUI = HUD and HUD:WaitForChild("Features", 10)
        
        if FeaturesUI then
            -- Ubah status visible menjadi true hanya sekali jalan
            FeaturesUI.Visible = true
            
            local mapUI = FeaturesUI:WaitForChild("Map", 5)
            if mapUI then mapUI.Visible = true end
            
            local timerUI = FeaturesUI:WaitForChild("Timer", 5)
            if timerUI then timerUI.Visible = true end
        end
    end)
end)

-- ====================================================================
-- [BACKGROUND TASK]: AUTO NO-FOG (SANTAI / LIGHTWEIGHT)
-- ====================================================================
task.spawn(function()
    local Lighting = game:GetService("Lighting")
    
    while true do
        pcall(function()
            -- 1. Hapus kabut klasik (FogEnd dijauhkan ke ujung dunia)
            Lighting.FogEnd = 9e9
            Lighting.FogStart = 9e9
            
            -- 2. Hapus kabut modern (Atmosphere) yang biasa dipakai saat event/hujan
            local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
            if atmosphere then
                atmosphere.Density = 0
                atmosphere.Glare = 0
                atmosphere.Haze = 0
            end
        end)
        
        -- Jeda 3 detik: Sangat santai, CPU tidak akan panas sama sekali
        task.wait(3)
    end
end)

