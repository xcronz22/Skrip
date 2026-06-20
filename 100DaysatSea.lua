-- Memuat Library RZY
local RZY_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Win = RZY_Library:MakeWindow("100 Days at Sea - V6.3 FIX")

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
    ["Harpoon"] = true,
    ["Magma Staff"] = true,
    ["Squid Laser"] = true,
    ["Rifle"] = true,
    ["Flintlock"] = true,
    ["Blunderbuss"] = true,
    ["Hand Cannon"] = true,
    ["Revolver"] = true,
    ["Boomstick"] = true,
    ["Riptide"] = true
}

Win:AddMultiDropdown("Pilih Material Grinder & Bakar", {"Wood", "Metal", "Goo", "Small Gas Can", "Big Gas Can", "Gas Drum"}, function(selectedTable)
    TargetMaterials = selectedTable
end)

local AutoGrinderEnabled = false
local AutoCampfireEnabled = false
local AutoEatEnabled = false
local AutoDoubloonEnabled = false 
local AutoAttackEnabled = false 
local AutoPickEnabled = false
local AutoChestEnabled = false

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
-- [FITUR 1]: AUTO GRINDER
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
                        
                        -- Cek atribut Resource ATAU Item (Fix untuk Gas Can)
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
                                    part.CFrame = GrinderCol.CFrame
                                    part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
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
-- [FITUR 2]: AUTO CAMPFIRE
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
                            
                            -- Cek atribut Resource ATAU Item (Fix untuk Gas Can)
                            local resType = folderObj:GetAttribute("Resource") or folderObj:GetAttribute("Item")
                            local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                            if not resType and part then
                                resType = part:GetAttribute("Resource") or part:GetAttribute("Item")
                            end
                            
                            local validFuels = {
                                ["Wood"] = true, 
                                ["Small Gas Can"] = true, 
                                ["Big Gas Can"] = true, 
                                ["Gas Drum"] = true
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
                                        part.CFrame = dropperPart.CFrame + Vector3.new(0, 3, 0)
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
-- [FITUR 4]: AUTO COLLECT (CHEST ONLY)
-- ====================================================================
Win:AddToggle("Auto Collect", false, function(state)
    AutoDoubloonEnabled = state
    if AutoDoubloonEnabled then
        task.spawn(function()
            while AutoDoubloonEnabled do
                local workspace = game:GetService("Workspace")
                local DebrisField = workspace:FindFirstChild("DebrisField")
                
                if DebrisField then
                    for _, folderObj in ipairs(DebrisField:GetChildren()) do
                        if not AutoDoubloonEnabled then break end
                        
                        local isChest = false
                        local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                        
                        -- Cek atribut langsung
                        if folderObj:GetAttribute("DoubloonChest") or (part and part:GetAttribute("DoubloonChest")) then 
                            isChest = true 
                        end
                        
                        -- Cek melalui atribut iterasi (fallback)
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
                        
                        -- Eksekusi hanya jika terdeteksi chest
                        if isChest then
                            local itemId = folderObj.Name 
                            SafeRemoteEvent("Collect", "~s" .. itemId)
                            task.wait(0.3) 
                        end
                    end
                end
                task.wait(1) 
            end
        end)
    end
end)

-- ====================================================================
-- [FITUR 5]: AUTO ATTACK (AUTO DETECT WEAPON & ANTI-BUGGED ENEMY)
-- ====================================================================
local AttackMode = "Nearest (Global)" 

Win:AddDropdown("Mode Auto Attack", {"Nearest (Global)", "Brutal All Target"}, function(selectedMode)
    AttackMode = selectedMode
end)

Win:AddToggle("Mulai Auto Attack", false, function(state)
    AutoAttackEnabled = state
    
    if AutoAttackEnabled then
        task.spawn(function()
            while AutoAttackEnabled do
                local workspace = game:GetService("Workspace")
                local CreatureContainer = workspace:FindFirstChild("CreatureContainer")
                
                local character = LocalPlayer.Character
                local rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChildWhichIsA("BasePart"))
                
                if CreatureContainer and rootPart then
                    
                    -- DETEKSI SENJATA YANG SEDANG DIPEGANG
                    local equippedTool = character:FindFirstChildOfClass("Tool")
                    
                    -- Hanya jalankan attack jika sedang memegang senjata yang valid
                    if equippedTool and TargetWeapons[equippedTool.Name] then
                        local wName = equippedTool.Name

                        if AttackMode == "Nearest (Global)" then
                            -- MODE: NEAREST
                            local nearestEnemy = nil
                            local nearestEnemyPart = nil
                            local shortestDistance = math.huge 

                            for _, enemy in ipairs(CreatureContainer:GetChildren()) do
                                if enemy.Name == "Wraith" or enemy.Name == "Wraith_CLIENT" then continue end
                                
                                local enemyPart = enemy:IsA("BasePart") and enemy or enemy:FindFirstChildWhichIsA("BasePart") or (enemy:IsA("Model") and enemy.PrimaryPart)
                                
                                -- FILTER ANTI BUG (Mengabaikan musuh yang mati dengan Transparency 1)
                                if enemyPart and enemyPart.Transparency ~= 1 then
                                    local distance = (enemyPart.Position - rootPart.Position).Magnitude
                                    if distance <= shortestDistance then
                                        shortestDistance = distance
                                        nearestEnemy = enemy
                                        nearestEnemyPart = enemyPart
                                    end
                                end
                            end
                            
                            -- EKSEKUSI ATTACK
                            if nearestEnemy and nearestEnemyPart then
                                local enemyPos = nearestEnemy:IsA("Model") and nearestEnemy:GetPivot().Position or nearestEnemyPart.Position
                                local vecStr = string.format("~v%.4f,%.4f,%.4f", enemyPos.X, enemyPos.Y, enemyPos.Z)
                                
                                pcall(function()
                                    if wName == "Harpoon" or wName == "Riptide" then
                                        SafeRemoteFunction("ToolReplicator", "~s" .. wName, "~sHitEnemy", nearestEnemy)
                                    elseif wName == "Magma Staff" then
                                        SafeRemoteFunction("ToolReplicator", "~sMagma Staff", "~sFire", vecStr)
                                    elseif wName == "Squid Laser" then
                                        SafeRemoteFunction("ToolReplicator", "~sLaser", "~sShoot", vecStr)
                                    else
                                        -- Tipe Senjata Api (Pistol, Rifle, dsb)
                                        local firePart = equippedTool:FindFirstChild("Handle") or equippedTool:FindFirstChildWhichIsA("BasePart") or rootPart
                                        if firePart then
                                            local direction = (enemyPos - rootPart.Position).Unit
                                            local gunFormatStr = string.format("~t{1=~f%.4f,%.4f,%.4f:%.4f,%.4f,%.4fZ0}", enemyPos.X, enemyPos.Y, enemyPos.Z, direction.X, direction.Y, direction.Z)
                                            SafeRemoteFunction("ToolReplicator", "~sGun", "~sShoot", firePart, gunFormatStr)
                                        end
                                    end
                                end)
                            end
                            
                        elseif AttackMode == "Brutal All Target" then
                            -- MODE: BRUTAL ALL TARGET
                            for _, enemy in ipairs(CreatureContainer:GetChildren()) do
                                if enemy.Name == "Wraith" or enemy.Name == "Wraith_CLIENT" then continue end
                                
                                local enemyPart = enemy:IsA("BasePart") and enemy or enemy:FindFirstChildWhichIsA("BasePart") or (enemy:IsA("Model") and enemy.PrimaryPart)
                                
                                -- FILTER ANTI BUG (Mengabaikan musuh yang mati dengan Transparency 1)
                                if enemyPart and enemyPart.Transparency ~= 1 then
                                    local enemyPos = enemy:IsA("Model") and enemy:GetPivot().Position or enemyPart.Position
                                    local vecStr = string.format("~v%.4f,%.4f,%.4f", enemyPos.X, enemyPos.Y, enemyPos.Z)
                                    
                                    pcall(function()
                                        if wName == "Harpoon" or wName == "Riptide" then
                                            SafeRemoteFunction("ToolReplicator", "~s" .. wName, "~sHitEnemy", enemy)
                                        elseif wName == "Magma Staff" then
                                            SafeRemoteFunction("ToolReplicator", "~sMagma Staff", "~sFire", vecStr)
                                        elseif wName == "Squid Laser" then
                                            SafeRemoteFunction("ToolReplicator", "~sLaser", "~sShoot", vecStr)
                                        else
                                            -- Tipe Senjata Api
                                            local firePart = equippedTool:FindFirstChild("Handle") or equippedTool:FindFirstChildWhichIsA("BasePart") or rootPart
                                            if firePart then
                                                local direction = (enemyPos - rootPart.Position).Unit
                                                local gunFormatStr = string.format("~t{1=~f%.4f,%.4f,%.4f:%.4f,%.4f,%.4fZ0}", enemyPos.X, enemyPos.Y, enemyPos.Z, direction.X, direction.Y, direction.Z)
                                                SafeRemoteFunction("ToolReplicator", "~sGun", "~sShoot", firePart, gunFormatStr)
                                            end
                                        end
                                    end)
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
-- [FITUR 6]: AUTO PICK MATERIAL (HARPOON SATUAN, SUPER CEPAT)
-- ====================================================================
Win:AddToggle("Auto Pick Material (Harpoon)", false, function(state)
    AutoPickEnabled = state
    
    if AutoPickEnabled then
        task.spawn(function()
            while AutoPickEnabled do
                local workspace = game:GetService("Workspace")
                local DebrisField = workspace:FindFirstChild("DebrisField")
                
                local character = LocalPlayer.Character
                local rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChildWhichIsA("BasePart"))
                
                if DebrisField and rootPart then
                    local nearestItem = nil
                    local nearestPart = nil
                    local shortestDistance = math.huge
                    
                    -- MENCARI 1 ITEM TERDEKAT SAJA
                    for _, folderObj in ipairs(DebrisField:GetChildren()) do
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
                                    local distance = (part.Position - rootPart.Position).Magnitude
                                    if distance < shortestDistance then
                                        shortestDistance = distance
                                        nearestItem = folderObj
                                        nearestPart = part
                                    end
                                end
                            end
                        end
                    end
                    
                    -- TEMBAKKAN HARPOON KE 1 TARGET TERDEKAT TERSEBUT
                    if nearestItem and nearestPart then
                        pcall(function()
                            local pos = nearestPart.Position
                            local vecStr = string.format("~v%.4f,%.4f,%.4f", pos.X, pos.Y, pos.Z)
                            SafeRemoteFunction("ToolReplicator", "~sHarpoon", "~sGrab", nearestItem, vecStr)
                        end)
                    end
                end
                
                -- Jeda sangat cepat (50ms) agar satu per satu ditarik secara kilat
                task.wait(0.05) 
            end
        end)
    end
end)

-- ====================================================================
-- [FITUR 7]: AUTO OPEN CHEST (DEEP SCAN KESELURUH FOLDER & PULAU)
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
                    local shortestDistance = 15 
                    local potentialChests = {}
                    
                    -- FUNGSI: Menggali ke dalam setiap folder/model tanpa batas kedalaman
                    local function CollectChests(parentFolder)
                        if not parentFolder then return end
                        
                        -- Mengambil anak langsung (Khusus untuk folder 'Chests' yang mungkin namanya cuma "Warrior" dsb)
                        if parentFolder.Name == "Chests" then
                            for _, item in ipairs(parentFolder:GetChildren()) do
                                table.insert(potentialChests, item)
                            end
                        end
                        
                        -- GetDescendants() mengecek isi folder, isi model, di dalam folder lagi, dst.
                        for _, item in ipairs(parentFolder:GetDescendants()) do
                            if (item:IsA("Model") or item:IsA("Folder") or item:IsA("BasePart")) then
                                -- string.lower mematikan case-sensitive sehingga frostchest, GhostChest, chest terbaca semua
                                if string.find(string.lower(item.Name), "chest") then
                                    table.insert(potentialChests, item)
                                end
                            end
                        end
                    end
                    
                    -- Jalankan Pengumpulan
                    CollectChests(ChestsFolder)
                    CollectChests(IslandContainer)
                    
                    -- Mencari 1 Chest terdekat dari daftar komprehensif
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
                    
                    -- Buka Peti
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

-- [FITUR 8]: AUTO FISHING (OPTIMIZED)
local AutoFishingEnabled = false
Win:AddToggle("Auto Fishing", false, function(state)
    AutoFishingEnabled = state
    if AutoFishingEnabled then
        task.spawn(function()
            while AutoFishingEnabled do
                local rootPart = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChildWhichIsA("BasePart"))
                
                if rootPart then
                    -- Mengambil arah hadap karakter saat ini secara real-time
                    local pos = rootPart.Position
                    local dir = rootPart.CFrame.LookVector
                    
                    local vecStr = string.format("~f%.4f,%.4f,%.4f:%.4f,%.4f,%.4fZ0", 
                        pos.X, pos.Y + 1, pos.Z, dir.X, dir.Y, dir.Z)
                    
                    -- Eksekusi Cast menggunakan SafeRemoteFunction agar seragam dan aman
                    SafeRemoteFunction("ToolReplicator", "~sFishing Rod", "~sCast")
                    
                    -- Eksekusi instan Poof
                    SafeRemoteFunction("ToolReplicator", "~sFishing Rod", "~sFishPoof", vecStr)
                end
                
                -- Jeda 0.2 detik (sangat cepat namun cukup aman untuk server)
                task.wait(0.2) 
            end
        end)
    end
end)
