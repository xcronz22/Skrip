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
    ["Riptide"] = false
}

Win:AddMultiDropdown("Material", {"Wood", "Metal", "Goo", "Small Gas Can", "Big Gas Can", "Gas Drum"}, function(selectedTable)
    TargetMaterials = selectedTable
end)

Win:AddMultiDropdown("Weapon", {"Harpoon", "Magma Staff", "Squid Laser", "DualPistols", "Rifle", "Flintlock", "Blunderbuss", "Hand Cannon", "Revolver", "Boomstick", "Grenade", "Riptide"}, function(selectedTable)
    TargetWeapons = selectedTable
end)

local AutoGrinderEnabled = false
local AutoCampfireEnabled = false
local AutoEatEnabled = false
local AutoDoubloonEnabled = false 
local AutoAttackEnabled = false 
local AutoPickEnabled = false
local AutoChestEnabled = false

-- ====================================================================
-- [FUNGSI BANTUAN]: DETEKSI COOKING POT & CHOWDER/PIZZA (UPDATED)
-- ====================================================================
local function GetCookingPot()
    local spawnIsland = workspace:FindFirstChild("SpawnIsland")
    if spawnIsland then
        local crafted = spawnIsland:FindFirstChild("Crafted")
        if crafted then
            for _, obj in ipairs(crafted:GetChildren()) do
                -- Pencarian string.lower memastikan 'Cooking Pot', 'cooking pot', dll akan terdeteksi
                if string.find(string.lower(obj.Name), "cooking pot") then
                    return obj
                end
            end
        end
    end
    return nil
end

local function PotNeedsFood(pot)
    local activate = pot:FindFirstChild("ACTIVATE")
    if not activate then return false end
    
    -- Cek dari Bar Enabled
    local bar = activate:FindFirstChild("Bar")
    if bar and bar.Enabled == false then return true end
    
    -- Cek dari TextLabel
    local bg = activate:FindFirstChild("BillboardGui")
    if bg and bg:FindFirstChild("TextLabel") then
        local txt = bg.TextLabel.Text
        -- Cek murni angkanya saja
        if string.find(txt, "0/3") or string.find(txt, "1/3") or string.find(txt, "2/3") then
            return true
        end
    end
    
    return false
end

local AutoCookChowderEnabled = false

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
-- [FITUR 3]: AUTO EAT
-- ====================================================================
Win:AddToggle("Auto Eat", false, function(state)
    AutoEatEnabled = state
    if AutoEatEnabled then
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
end)

-- ====================================================================
-- [FITUR 4]: AUTO COLLECT (ONLY DIAMOND CHEST, AMMO, BANDAGE & WEAPONS)
-- ====================================================================
local CollectedItems = {} 
local HasDiamondChest = false

-- Reset data saat respawn / ngulang game
LocalPlayer.CharacterAdded:Connect(function()
    CollectedItems = {}
    HasDiamondChest = false
end)

-- Daftar senjata (Huruf kecil untuk pencocokan mutlak)
local TargetWeaponsCollect = {
    ["machete"] = true, ["poku poku"] = true, ["ghost cutlass"] = true,
    ["flintlock"] = true, ["blunderbuss"] = true, ["rifle"] = true, ["boomstick"] = true,
    ["magma staff"] = true, ["ice staff"] = true, ["squid laser"] = true, ["revolver"] = true, ["hand cannon"] = true
}

Win:AddToggle("Auto Collect", false, function(state)
    AutoDoubloonEnabled = state
    if AutoDoubloonEnabled then
        task.spawn(function()
            while AutoDoubloonEnabled do
                local workspace = game:GetService("Workspace")
                local DebrisField = workspace:FindFirstChild("DebrisField")
                
                local character = LocalPlayer.Character
                local humanoid = character and character:FindFirstChild("Humanoid")
                local rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChildWhichIsA("BasePart"))
                
                -- Detektor Kematian Ekstra
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
                        
                        -- Cek DoubloonChest (Peti Koin)
                        if folderObj:GetAttribute("DoubloonChest") or (part and part:GetAttribute("DoubloonChest")) then 
                            isChest = true 
                        end
                        if not isChest then
                            for attrName, attrValue in pairs(folderObj:GetAttributes()) do
                                local lowerName = string.lower(attrName)
                                local lowerValue = type(attrValue) == "string" and string.lower(attrValue) or ""
                                if string.find(lowerName, "doubloonchest") or string.find(lowerValue, "doubloonchest") then
                                    isChest = true
                                    break
                                end
                            end
                        end
                        
                        if isChest then
                            SafeRemoteEvent("Collect", "~s" .. uniqueId)
                            task.wait(0.3) 
                            continue 
                        end
                        
                        -- Cek Item dengan batas 15 Studs
                        if part then
                            local resType = folderObj:GetAttribute("Resource") or folderObj:GetAttribute("Item")
                            if not resType then resType = part:GetAttribute("Resource") or part:GetAttribute("Item") end
                            if not resType then resType = part.Name end 
                            
                            if resType then
                                local distance = (part.Position - rootPart.Position).Magnitude
                                if distance <= 15 then
                                    local shouldCollect = false
                                    local lowerRes = string.lower(resType)
                                    
                                    -- 1. Repeatable (Ammo & Bandage)
                                    if string.find(lowerRes, "ammo") or string.find(lowerRes, "bandage") then
                                        shouldCollect = true
                                        
                                    -- 2. HANYA Diamond Chest / Armor
                                    elseif string.find(lowerRes, "diamond") and (string.find(lowerRes, "chest") or string.find(lowerRes, "armor")) then
                                        if not HasDiamondChest then
                                            shouldCollect = true
                                            HasDiamondChest = true
                                        end
                                        
                                    -- 3. Weapons (Collect Once)
                                    else
                                        for wName, _ in pairs(TargetWeaponsCollect) do
                                            if string.find(lowerRes, wName) then
                                                if not CollectedItems[wName] then
                                                    shouldCollect = true
                                                    CollectedItems[wName] = true
                                                end
                                                break 
                                            end
                                        end
                                    end
                                    
                                    -- Eksekusi Collect Utama
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
end)

-- ====================================================================
-- [FITUR 5]: AUTO ATTACK (BUG FIXED & FULLY OPTIMIZED)
-- ====================================================================
local AttackMode = "Brutal All Target" 
local BrutalAttackRange = 100 

Win:AddDropdown("Mode Auto Attack", {"Nearest (Global)", "Brutal All Target"}, function(selectedMode)
    AttackMode = selectedMode
end)

Win:AddInput("Brutal Attack Range", "100", function(value)
    local num = tonumber(value)
    if num then
        BrutalAttackRange = num
    end
end)

Win:AddToggle("Auto Attack", false, function(state)
    AutoAttackEnabled = state
    
    if AutoAttackEnabled then
        task.spawn(function()
            while AutoAttackEnabled do
                -- Menggunakan pcall di loop utama agar jika terjadi error, fitur tidak mati
                pcall(function()
                    local workspace = game:GetService("Workspace")
                    local CreatureContainer = workspace:FindFirstChild("CreatureContainer")
                    
                    local character = LocalPlayer.Character
                    local humanoid = character and character:FindFirstChild("Humanoid")
                    local rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChildWhichIsA("BasePart"))
                    local backpack = LocalPlayer:FindFirstChild("Backpack")
                    
                    if CreatureContainer and rootPart and humanoid then
                        
                        -- Logika Cerdas: Cek apakah dicentang di UI atau sedang dipegang di tangan
                        local function CheckAndAttackAsync(toolName, attackLogic)
                            local isSelected = TargetWeapons[toolName] == true
                            local tool = character:FindFirstChild(toolName)
                            
                            -- 1. Jika TIDAK dicentang di UI, DAN TIDAK sedang dipegang di tangan, lewati.
                            if not isSelected and not tool then return end
                            
                            -- 2. Jika dicentang di UI tapi barang ada di tas, ambil dan paksa pakai (Equip)
                            if not tool and isSelected and backpack then
                                tool = backpack:FindFirstChild(toolName)
                                if tool then 
                                    humanoid:EquipTool(tool) 
                                end
                            end
                            
                            -- 3. Eksekusi serangan! (Berlaku untuk yang dicentang maupun yang manual dipegang)
                            if tool then 
                                task.spawn(function() pcall(attackLogic, tool) end)
                            end
                        end

                        if AttackMode == "Nearest (Global)" then
                            local nearestEnemy = nil
                            local nearestEnemyPart = nil
                            local shortestDistance = math.huge 

                            for _, enemy in ipairs(CreatureContainer:GetChildren()) do
                                if enemy.Name == "Wraith" or enemy.Name == "Wraith_CLIENT" then continue end
                                
                                local enemyPart = enemy:IsA("BasePart") and enemy or enemy:FindFirstChildWhichIsA("BasePart") or (enemy:IsA("Model") and enemy.PrimaryPart)
                                
                                if enemyPart then
                                    local distance = (enemyPart.Position - rootPart.Position).Magnitude
                                    if distance <= shortestDistance then
                                        shortestDistance = distance
                                        nearestEnemy = enemy
                                        nearestEnemyPart = enemyPart
                                    end
                                end
                            end
                            
                            if nearestEnemy and nearestEnemyPart then
                                local enemyPos = nearestEnemy:IsA("Model") and nearestEnemy:GetPivot().Position or nearestEnemyPart.Position
                                local vecStr = string.format("~v%.4f,%.4f,%.4f", enemyPos.X, enemyPos.Y, enemyPos.Z)
                                
                                pcall(function()
                                    for _, wName in ipairs({"Harpoon", "Riptide"}) do
                                        CheckAndAttackAsync(wName, function(t) SafeRemoteFunction("ToolReplicator", "~s" .. wName, "~sHitEnemy", nearestEnemy) end)
                                    end
                                    CheckAndAttackAsync("Magma Staff", function(t) SafeRemoteFunction("ToolReplicator", "~sMagma Staff", "~sFire", vecStr) end)
                                    CheckAndAttackAsync("Squid Laser", function(t) SafeRemoteFunction("ToolReplicator", "~sLaser", "~sShoot", vecStr) end)
                                    CheckAndAttackAsync("Grenade", function(t) SafeRemoteFunction("ToolReplicator", "~sGrenade", "~sThrow", vecStr, vecStr) end)
                                    
                                    local gunTypes = {"Rifle", "Flintlock", "Blunderbuss", "Revolver", "Hand Cannon", "Boomstick", "DualPistols"}
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
                                end)
                            end
                            
                        elseif AttackMode == "Brutal All Target" then
                            for _, enemy in ipairs(CreatureContainer:GetChildren()) do
                                if enemy.Name == "Wraith" or enemy.Name == "Wraith_CLIENT" then continue end
                                
                                local enemyPart = enemy:IsA("BasePart") and enemy or enemy:FindFirstChildWhichIsA("BasePart") or (enemy:IsA("Model") and enemy.PrimaryPart)
                                
                                if enemyPart then
                                    -- Typo telah diperbaiki menjadi IsA("Model")
                                    local enemyPos = enemy:IsA("Model") and enemy:GetPivot().Position or enemyPart.Position
                                    local distance = (enemyPos - rootPart.Position).Magnitude
                                    
                                    if distance <= BrutalAttackRange then
                                        local vecStr = string.format("~v%.4f,%.4f,%.4f", enemyPos.X, enemyPos.Y, enemyPos.Z)
                                        
                                        pcall(function()
                                            for _, wName in ipairs({"Harpoon", "Riptide"}) do
                                                CheckAndAttackAsync(wName, function(t) SafeRemoteFunction("ToolReplicator", "~s" .. wName, "~sHitEnemy", enemy) end)
                                            end
                                            CheckAndAttackAsync("Magma Staff", function(t) SafeRemoteFunction("ToolReplicator", "~sMagma Staff", "~sFire", vecStr) end)
                                            CheckAndAttackAsync("Squid Laser", function(t) SafeRemoteFunction("ToolReplicator", "~sLaser", "~sShoot", vecStr) end)
                                            CheckAndAttackAsync("Grenade", function(t) SafeRemoteFunction("ToolReplicator", "~sGrenade", "~sThrow", vecStr, vecStr) end)

                                            local gunTypes = {"Rifle", "Flintlock", "Blunderbuss", "Revolver", "Hand Cannon", "Boomstick", "DualPistols"}
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
end)

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
-- [FITUR 7]: AUTO OPEN CHEST (OPTIMIZED & EXPANDED SEARCH, 15 STUDS)
-- ====================================================================
Win:AddToggle("Auto Open Chest", false, function(state)
    AutoChestEnabled = state
    if AutoChestEnabled then
        task.spawn(function()
            while AutoChestEnabled do
                local workspace = game:GetService("Workspace")
                local ChestsFolder = workspace:FindFirstChild("Chests")
                local IslandContainer = workspace:FindFirstChild("IslandContainer")
                
                local character = LocalPlayer.Character
                local rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart"))
                
                if rootPart then
                    local nearestChest = nil
                    local shortestDistance = 15 -- Dikembalikan ke 15 stud sesuai permintaan
                    
                    local potentialChests = {}
                    
                    -- 1. Mengumpulkan Chest dari workspace.Chests
                    if ChestsFolder then
                        for _, chest in ipairs(ChestsFolder:GetChildren()) do
                            table.insert(potentialChests, chest)
                        end
                    end
                    
                    -- 2. Mengumpulkan Chest dari workspace.IslandContainer (Cek semua pulau)
                    if IslandContainer then
                        for _, island in ipairs(IslandContainer:GetChildren()) do
                            for _, item in ipairs(island:GetChildren()) do
                                if string.find(string.lower(item.Name), "chest") then
                                    table.insert(potentialChests, item)
                                end
                            end
                        end
                    end
                    
                    -- 3. Mencari 1 Chest terdekat (dalam radius 15 stud)
                    for _, chest in ipairs(potentialChests) do
                        local part = chest:IsA("BasePart") and chest or chest:FindFirstChildWhichIsA("BasePart")
                        if part then
                            local distance = (part.Position - rootPart.Position).Magnitude
                            if distance < shortestDistance then
                                shortestDistance = distance
                                nearestChest = chest
                            end
                        end
                    end
                    
                    -- 4. Mengeksekusi Remote untuk membuka Chest
                    if nearestChest then
                        pcall(function()
                            SafeRemoteFunction("OpenChest", nearestChest)
                        end)
                    end
                end
                
                task.wait(0.1) 
            end
        end)
    end
end)

-- ====================================================================
-- [FITUR 8]: AUTO FISHING (FIXED - BUANG FOOD, CRATES, & CHESTS)
-- ====================================================================
local AutoFishingEnabled = false
Win:AddToggle("Auto Fishing", false, function(state)
    AutoFishingEnabled = state
    if AutoFishingEnabled then
        
        -- Thread 1: Lempar pancingan (Cast & Poof)
        task.spawn(function()
            while AutoFishingEnabled do
                local rootPart = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChildWhichIsA("BasePart"))
                
                if rootPart then
                    local pos = rootPart.Position
                    local dir = rootPart.CFrame.LookVector
                    
                    local vecStr = string.format("~f%.4f,%.4f,%.4f:%.4f,%.4f,%.4fZ0", 
                        pos.X, pos.Y + 1, pos.Z, dir.X, dir.Y, dir.Z)
                    
                    SafeRemoteFunction("ToolReplicator", "~sFishing Rod", "~sCast")
                    SafeRemoteFunction("ToolReplicator", "~sFishing Rod", "~sFishPoof", vecStr)
                end
                
                task.wait(0.2) 
            end
        end)
        
        -- Thread 2: Pelepasan Item (Langsung Buang)
        task.spawn(function()
            while AutoFishingEnabled do
                local workspace = game:GetService("Workspace")
                local DebrisField = workspace:FindFirstChild("DebrisField")
                local character = LocalPlayer.Character
                local rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart"))
                
                if DebrisField and rootPart then
                    for _, folderObj in ipairs(DebrisField:GetChildren()) do
                        if not AutoFishingEnabled then break end
                        
                        -- Abaikan jika sudah masuk grinder/campfire
                        if folderObj:GetAttribute("RZY_Processed") then continue end
                        
                        local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                        if part then
                            -- Deteksi luas: Makanan, Peti, dan Crate (huruf kecil semua agar pasti cocok)
                            local isFood = folderObj:GetAttribute("Food") or part:GetAttribute("Food")
                            local folderName = string.lower(folderObj.Name)
                            local partName = string.lower(part.Name)
                            local resAttr = string.lower(tostring(folderObj:GetAttribute("Resource") or part:GetAttribute("Resource") or ""))
                            
                            local isChestOrCrate = string.find(folderName, "chest") or string.find(partName, "chest") or string.find(resAttr, "chest") or
                                                   string.find(folderName, "crate") or string.find(partName, "crate") or string.find(resAttr, "crate")
                            
                            -- Eksekusi hanya jika itu hasil pancingan yang sah
                            if isFood ~= nil or isChestOrCrate then
                                local isGrabbed = folderObj:GetAttribute("Grabbed") or part:GetAttribute("Grabbed")
                                local grabber = folderObj:GetAttribute("Grabber") or part:GetAttribute("Grabber")
                                
                                local myId = tostring(LocalPlayer.UserId)
                                local myName = LocalPlayer.Name
                                
                                local isCurrentlyMyGrab = (isGrabbed == true and (tostring(grabber) == myId or grabber == myName))
                                
                                if isCurrentlyMyGrab then
                                    local distance = (part.Position - rootPart.Position).Magnitude
                                    
                                    -- Jika barang sudah ditarik dan sampai ke kita (jarak <= 10 stud), langsung lepaskan!
                                    if distance <= 10 then
                                        pcall(function() 
                                            -- Argumen ~v0.0000 agar server menerima perintahnya
                                            SafeRemoteEvent("GiveUpOwnership", part, "~v0.0000,0.0000,0.0000") 
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
        
    end
end)

-- ====================================================================
-- [FITUR 9]: AUTO COOK CHOWDER / PIZZA (VERSI SINKRON GRINDER)
-- ====================================================================
Win:AddToggle("Auto Cook Chowder", false, function(state)
    AutoCookChowderEnabled = state
    if AutoCookChowderEnabled then
        task.spawn(function()
            while AutoCookChowderEnabled do
                local pot = GetCookingPot()
                
                -- Hanya eksekusi jika panci terdeteksi dan butuh bahan
                if pot and PotNeedsFood(pot) then
                    local storeBlock = pot:FindFirstChild("StoreBlock")
                    local DebrisField = workspace:FindFirstChild("DebrisField")
                    
                    if storeBlock and DebrisField then
                        for _, folderObj in ipairs(DebrisField:GetChildren()) do
                            local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                            
                            -- Deteksi Atribut Food (Case-Insensitive)
                            local isFood = (folderObj:GetAttribute("Food") ~= nil or folderObj:GetAttribute("food") ~= nil)
                            
                            if isFood and part then
                                -- Filter: Hanya ambil jika item sudah jadi "milik" kita
                                local isGrabbed = folderObj:GetAttribute("Grabbed") or part:GetAttribute("Grabbed")
                                local grabber = tostring(folderObj:GetAttribute("Grabber") or part:GetAttribute("Grabber"))
                                local lastHolder = tostring(folderObj:GetAttribute("LastHolder") or part:GetAttribute("LastHolder"))
                                local myId = tostring(LocalPlayer.UserId)
                                
                                -- Jika item sedang dipegang oleh kita (sama persis dengan logic Auto Grinder)
                                if isGrabbed and (grabber == myId or lastHolder == myId) then
                                    pcall(function()
                                        -- Tweak: Ditambahkan '* CFrame.new(0, 3, 0)' agar TP berada di luar atas StoreBlock
                                        part.CFrame = storeBlock.CFrame * CFrame.new(0, 5, 0)
                                    end)
                                end
                            end
                        end
                    end
                end
                task.wait(0.5) -- Kecepatan tinggi agar tidak ada delay saat TP
            end
        end)
    end
end)
