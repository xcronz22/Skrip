-- Memuat Library RZY
local RZY_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Win = RZY_Library:MakeWindow("100 Days at Sea - V6.6 FLEKSIBEL")

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
    ["Rifle"] = false,
    ["Flintlock"] = false,
    ["Blunderbuss"] = false,
    ["Hand Cannon"] = false,
    ["Revolver"] = false,
    ["Boomstick"] = false,
    ["Riptide"] = false
}

Win:AddMultiDropdown("Pilih Material Grinder & Bakar", {"Wood", "Metal", "Goo", "Small Gas Can", "Big Gas Can", "Gas Drum"}, function(selectedTable)
    TargetMaterials = selectedTable
end)

Win:AddMultiDropdown("Pilih Senjata Attack", {"Harpoon", "Magma Staff", "Squid Laser", "Rifle", "Flintlock", "Blunderbuss", "Hand Cannon", "Revolver", "Boomstick", "Riptide"}, function(selectedTable)
    TargetWeapons = selectedTable
end)

local AutoGrinderEnabled = false
local AutoCampfireEnabled = false
local AutoEatEnabled = false
local AutoDoubloonEnabled = false 
local AutoAttackEnabled = false 
local AutoPickEnabled = false

local GrinderToggle = nil
local CampfireToggle = nil

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ====================================================================
-- [SISTEM INTI]: DYNAMIC REMOTE FINDER & TOKEN INTERCEPTOR (FIXED)
-- ====================================================================
local CurrentSyncToken = nil
local GameRemoteEvent = nil
local GameRemoteFunction = nil
local SystemReady = false

-- Menggunakan StarterGui bawaan Roblox untuk memberikan notifikasi instruksi
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "RZY HUB INFO",
        Text = "Silakan lakukan 1x aksi manual di game (pukul/gunakan tool) untuk mengaktifkan skrip!",
        Duration = 7
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
                            
                            -- Interseptor Token Asli Game
                            if not SystemReady then
                                CurrentSyncToken = args[1]
                                SystemReady = true
                                pcall(function()
                                    game:GetService("StarterGui"):SetCore("SendNotification", {
                                        Title = "RZY HUB READY",
                                        Text = "Token & Remote berhasil diverifikasi! Fitur siap digunakan.",
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
    if not SystemReady or not CurrentSyncToken then 
        return nil -- Mencegah pengiriman data jika token belum sinkron dengan game asli
    end
    CurrentSyncToken = CurrentSyncToken + 1
    return CurrentSyncToken
end

local function SafeRemoteEvent(actionName, ...)
    local token = GetNextToken()
    if token and GameRemoteEvent then
        GameRemoteEvent:FireServer(token, actionName, ...)
    end
end

local function SafeRemoteFunction(actionName, ...)
    local token = GetNextToken()
    if token and GameRemoteFunction then
        return GameRemoteFunction:InvokeServer(token, actionName, ...)
    end
    return nil
end

-- ====================================================================
-- [FITUR 1]: AUTO GRINDER
-- ====================================================================
GrinderToggle = Win:AddToggle("Mulai Auto Grinder", false, function(state)
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
-- [FITUR 2]: SMART AUTO CAMPFIRE (SORTING FUEL -> CAMPFIRE, LAINNYA -> GRINDER)
-- ====================================================================
CampfireToggle = Win:AddToggle("Auto Campfire (Smart Sorter)", false, function(state)
    AutoCampfireEnabled = state
    
    -- [SISTEM PINTAR]: Matikan Auto Grinder agar tidak bentrok
    if state and GrinderToggle then
        AutoGrinderEnabled = false
        GrinderToggle:Set(false)
    end
    
    if AutoCampfireEnabled then
        task.spawn(function()
            while AutoCampfireEnabled do
                local workspace = game:GetService("Workspace")
                local DebrisField = workspace:FindFirstChild("DebrisField")
                
                -- Deteksi kedua mesin sekaligus
                local Dropper = workspace:FindFirstChild("SpawnIsland") and workspace.SpawnIsland:FindFirstChild("Dropper")
                local GrinderCol = workspace:FindFirstChild("SpawnIsland") and workspace.SpawnIsland:FindFirstChild("Grinder") and workspace.SpawnIsland.Grinder:FindFirstChild("Collection")

                if DebrisField then
                    local dropperPart = Dropper and (Dropper:IsA("BasePart") and Dropper or Dropper:FindFirstChildWithClass("BasePart") or (Dropper:IsA("Model") and Dropper.PrimaryPart))
                    local grinderPart = GrinderCol
                    
                    local itemsToProcess = {}
                    
                    for _, folderObj in ipairs(DebrisField:GetChildren()) do
                        if not AutoCampfireEnabled then break end
                        
                        local resType = folderObj:GetAttribute("Resource") or folderObj:GetAttribute("Item")
                        local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                        if not resType and part then
                            resType = part:GetAttribute("Resource") or part:GetAttribute("Item")
                        end
                        
                        -- Daftar material khusus pembakaran (Campfire)
                        local validFuels = {
                            ["Wood"] = true, 
                            ["Small Gas Can"] = true, 
                            ["Big Gas Can"] = true, 
                            ["Gas Drum"] = true
                        }
                        
                        -- Memastikan item tersebut adalah salah satu yang kamu CENTANG di Dropdown
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
                                
                                -- Filter Kepemilikan Barang (Hanya proses bekas / barang pegangan sendiri)
                                local isCurrentlyMyGrab = (isGrabbed == true and (tostring(grabber) == myId or grabber == myName))
                                local isMyPastItem = (lastHolder == myName)
                                
                                if isCurrentlyMyGrab or isMyPastItem then
                                    
                                    -- [LOGIKA SORTIR]: Jika ini bahan bakar -> ke Dropper. Jika bukan -> ke Grinder.
                                    local isFuel = validFuels[resType]
                                    local targetDestination = isFuel and dropperPart or grinderPart
                                    
                                    if targetDestination then
                                        local distance = (part.Position - targetDestination.Position).Magnitude
                                        
                                        -- Tambahkan ke antrean jika berada di luar radius
                                        if distance > 3 then
                                            table.insert(itemsToProcess, { 
                                                Object = folderObj, 
                                                Part = part, 
                                                Distance = distance,
                                                IsFuel = isFuel,
                                                TargetDest = targetDestination
                                            })
                                        end
                                    end
                                    
                                end
                            end
                        end
                    end
                    
                    -- Urutkan jarak agar pemindahan mulus dari yang terdekat
                    table.sort(itemsToProcess, function(a, b) return a.Distance < b.Distance end)

                    for _, data in ipairs(itemsToProcess) do
                        if not AutoCampfireEnabled then break end 
                        local obj = data.Object
                        local part = data.Part
                        local targetDest = data.TargetDest
                        local isFuel = data.IsFuel
                        
                        obj:SetAttribute("Grabbed", false) 
                        obj:SetAttribute("LastHolder", LocalPlayer.Name)

                        -- Eksekusi Teleportasi sesuai tujuan mesin
                        if part:IsA("BasePart") then
                            part.CFrame = isFuel and (targetDest.CFrame + Vector3.new(0, 3, 0)) or targetDest.CFrame
                            part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        elseif obj:IsA("Model") then
                            obj:PivotTo(isFuel and (targetDest.CFrame + Vector3.new(0, 3, 0)) or targetDest.CFrame)
                            for _, p in ipairs(obj:GetDescendants()) do
                                if p:IsA("BasePart") then p.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end
                            end
                        end
                        
                        -- Memicu trigger pembakaran HANYA jika barang masuk ke Campfire
                        if isFuel and firetouchinterest then
                            local touchPart = part or obj.PrimaryPart
                            if touchPart then
                                firetouchinterest(targetDest, touchPart, 0) 
                                task.wait()
                                firetouchinterest(targetDest, touchPart, 1) 
                            end
                        end
                        
                        task.wait(0.1)
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
-- [FITUR 4]: AUTO COLLECT (CHEST & AMMO)
-- ====================================================================
Win:AddToggle("Auto Collect", false, function(state)
    AutoDoubloonEnabled = state
    if AutoDoubloonEnabled then
        task.spawn(function()
            while AutoDoubloonEnabled do
                local workspace = game:GetService("Workspace")
                local DebrisField = workspace:FindFirstChild("DebrisField")
                
                local character = LocalPlayer.Character
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                local hasRifle = (character and character:FindFirstChild("Rifle")) or (backpack and backpack:FindFirstChild("Rifle"))
                
                if DebrisField then
                    for _, folderObj in ipairs(DebrisField:GetChildren()) do
                        if not AutoDoubloonEnabled then break end
                        
                        local isChest = false
                        local isAmmo = false
                        local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                        
                        if folderObj:GetAttribute("DoubloonChest") or (part and part:GetAttribute("DoubloonChest")) then isChest = true end
                        if folderObj:GetAttribute("Ammo") or (part and part:GetAttribute("Ammo")) then isAmmo = true end
                        
                        if not isChest and not isAmmo then
                            for attrName, attrValue in pairs(folderObj:GetAttributes()) do
                                local lowerName = string.lower(attrName)
                                local lowerValue = type(attrValue) == "string" and string.lower(attrValue) or ""
                                if string.find(lowerName, "doubloonchest") or string.find(lowerValue, "doubloonchest") then
                                    isChest = true
                                end
                                if string.find(lowerName, "ammo") or string.find(lowerValue, "ammo") then
                                    isAmmo = false
                                end
                            end
                        end
                        
                        if isChest or (isAmmo and hasRifle) then
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
-- [FITUR 5]: AUTO ATTACK FLEKSIBEL (NEAREST / ALL TARGET)
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
                local humanoid = character and character:FindFirstChild("Humanoid")
                local rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChildWhichIsA("BasePart"))
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                
                if CreatureContainer and rootPart and humanoid then
                    
                    -- Menghitung berapa banyak senjata yang sedang dicentang di UI
                    local activeWeaponsCount = 0
                    for _, isSelected in pairs(TargetWeapons) do
                        if isSelected then activeWeaponsCount = activeWeaponsCount + 1 end
                    end

                    local function CheckAndAttackAsync(toolName, attackLogic)
                        if not TargetWeapons[toolName] then return end 
                        
                        local tool = character:FindFirstChild(toolName)
                        
                        -- Logika Fleksibel: Paksa equip HANYA JIKA pilih lebih dari 1 senjata
                        if activeWeaponsCount > 1 then
                            if not tool and backpack then
                                tool = backpack:FindFirstChild(toolName)
                                if tool then humanoid:EquipTool(tool) end
                            end
                        end
                        
                        -- Hanya eksekusi serangan jika senjata BENAR-BENAR ada di tangan (Character)
                        if tool and tool.Parent == character then 
                            task.spawn(function() pcall(attackLogic, tool) end)
                        end
                    end

                    if AttackMode == "Nearest (Global)" then
                        -- MODE: NEAREST
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
                                
                                local gunTypes = {"Rifle", "Flintlock", "Blunderbuss", "Revolver", "Hand Cannon", "Boomstick"}
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
                        -- MODE: BRUTAL ALL TARGET
                        for _, enemy in ipairs(CreatureContainer:GetChildren()) do
                            if enemy.Name == "Wraith" or enemy.Name == "Wraith_CLIENT" then continue end
                            
                            local enemyPart = enemy:IsA("BasePart") and enemy or enemy:FindFirstChildWhichIsA("BasePart") or (enemy:IsA("Model") and enemy.PrimaryPart)
                            
                            if enemyPart then
                                local enemyPos = enemy:IsA("Model") and enemy:GetPivot().Position or enemyPart.Position
                                local vecStr = string.format("~v%.4f,%.4f,%.4f", enemyPos.X, enemyPos.Y, enemyPos.Z)
                                
                                pcall(function()
                                    for _, wName in ipairs({"Harpoon", "Riptide"}) do
                                        CheckAndAttackAsync(wName, function(t) SafeRemoteFunction("ToolReplicator", "~s" .. wName, "~sHitEnemy", enemy) end)
                                    end
                                    CheckAndAttackAsync("Magma Staff", function(t) SafeRemoteFunction("ToolReplicator", "~sMagma Staff", "~sFire", vecStr) end)
                                    CheckAndAttackAsync("Squid Laser", function(t) SafeRemoteFunction("ToolReplicator", "~sLaser", "~sShoot", vecStr) end)

                                    local gunTypes = {"Rifle", "Flintlock", "Blunderbuss", "Revolver", "Hand Cannon", "Boomstick"}
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
                task.wait(0.04) 
            end
        end)
    end
end)

-- ====================================================================
-- [FITUR 6]: BRUTAL AUTO PICK MATERIAL (HARPOON MASS GRAB)
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
                                
                                if isGrabbed then
                                    continue 
                                end
                                
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
                
                task.wait(0.2) 
            end
        end)
    end
end)

-- ====================================================================
-- [FITUR 7]: AUTO OPEN CHEST (NEAREST)
-- ====================================================================
Win:AddToggle("Auto Open Chest", false, function(state)
    AutoChestEnabled = state
    if AutoChestEnabled then
        task.spawn(function()
            while AutoChestEnabled do
                local workspace = game:GetService("Workspace")
                local ChestsFolder = workspace:FindFirstChild("Chests")
                local rootPart = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChildWhichIsA("BasePart"))
                
                if ChestsFolder and rootPart then
                    local nearestChest = nil
                    local shortestDistance = math.huge
                    
                    for _, chest in ipairs(ChestsFolder:GetChildren()) do
                        local part = chest:IsA("BasePart") and chest or chest:FindFirstChildWhichIsA("BasePart")
                        if part then
                            local distance = (part.Position - rootPart.Position).Magnitude
                            if distance < shortestDistance then
                                shortestDistance = distance
                                nearestChest = chest
                            end
                        end
                    end
                    
                    if nearestChest then
                        pcall(function()
                            SafeRemoteFunction("OpenChest", nearestChest)
                        end)
                    end
                end
                task.wait(1) -- Jeda 1 detik agar tidak spamming ke server
            end
        end)
    end
end)
