-- Memuat Library RZY
local RZY_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Win = RZY_Library:MakeWindow("100 Days at Sea - V6")

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
    ["Laser"] = false,
    ["Rifle"] = false
}

Win:AddMultiDropdown("Pilih Material Grinder & Bakar", {"Wood", "Metal", "Goo", "Small Gas Can", "Big Gas Can", "Gas Drum"}, function(selectedTable)
    TargetMaterials = selectedTable
end)

Win:AddMultiDropdown("Pilih Senjata Attack", {"Harpoon", "Magma Staff", "Laser", "Rifle"}, function(selectedTable)
    TargetWeapons = selectedTable
end)

local AutoGrinderEnabled = false
local AutoCampfireEnabled = false
local AutoEatEnabled = false
local AutoDoubloonEnabled = false 
local AutoAttackEnabled = false 
local AutoPickEnabled = false

-- Variabel pengikat Toggle agar bisa dimatikan dari luar
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

-- 1. FUNGSI PELACAK REMOTE (Otomatis mencari di semua Service secara dinamis)
local function FindHiddenRemotes()
    local hiddenServices = {
        "Chat", "LocalizationService", "SocialService", 
        "TestService", "SoundService", "Lighting", "Stats", "JointsService"
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

-- 2. PENYADAP KOMUNIKASI (Dibuat Dinamis)
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
-- [FITUR 1]: AUTO GRINDER (PERFECT COMBINATION: GRABBED & LAST HOLDER)
-- ====================================================================
Win:AddToggle("Mulai Auto Grinder", false, function(state)
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
                        
                        local resType = folderObj:GetAttribute("Resource")
                        local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                        
                        if not resType and part then
                            resType = part:GetAttribute("Resource")
                        end
                        
                        if resType and TargetMaterials[resType] and part then
                            -- Abaikan jika itu Armor, Chest, atau Leg
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
-- [FITUR 2]: AUTO CAMPFIRE (IDENTIK DENGAN GRINDER)
-- ====================================================================
CampfireToggle = Win:AddToggle("Auto Campfire", false, function(state)
    AutoCampfireEnabled = state
    
    -- [SISTEM PINTAR]: Matikan Auto Grinder jika Auto Campfire menyala
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
                            
                            local resType = folderObj:GetAttribute("Resource")
                            local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                            
                            if not resType and part then
                                resType = part:GetAttribute("Resource")
                            end
                            
                            -- Filter Material Khusus Campfire
                            local validFuels = {
                                ["Wood"] = true, 
                                ["Small Gas Can"] = true, 
                                ["Big Gas Can"] = true, 
                                ["Gas Drum"] = true
                            }
                            
                            if resType and TargetMaterials[resType] and validFuels[resType] and part then
                                -- Abaikan jika itu Armor, Chest, atau Leg
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
                                        -- Eksekusi langsung ke tungku, dinaikkan 3 stud ke atas sumbu Y
                                        part.CFrame = dropperPart.CFrame + Vector3.new(0, 3, 0)
                                        part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(0.05) -- Kecepatan disamakan dengan Grinder
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
-- [FITUR 4]: AUTO COLLECT (CHEST & AMMO) + PENGECEKAN RIFLE
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
                
                -- Pengecekan ketersediaan Rifle di Tas / Tangan
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
                                    isAmmo = true
                                end
                            end
                        end
                        
                        -- Logika Pintar: Ambil Chest selalu. Ambil Ammo HANYA JIKA punya Rifle.
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
-- [FITUR 5]: BRUTAL AUTO ATTACK (MULTI-TOOL & AUTO EQUIP)
-- ====================================================================
Win:AddToggle("Auto Attack Multi-Tool", false, function(state)
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
                    local nearestEnemy = nil
                    local shortestDistance = math.huge
                    
                    -- Mencari musuh terdekat
                    for _, enemy in ipairs(CreatureContainer:GetChildren()) do
                        if enemy.Name ~= "Seagull" then
                            local enemyPart = enemy:IsA("BasePart") and enemy or enemy:FindFirstChildWhichIsA("BasePart") or (enemy:IsA("Model") and enemy.PrimaryPart)
                            
                            if enemyPart then
                                local distance = (enemyPart.Position - rootPart.Position).Magnitude
                                if distance < shortestDistance then
                                    shortestDistance = distance
                                    nearestEnemy = enemy
                                end
                            end
                        end
                    end
                    
                    if nearestEnemy then
                        local enemyPos = nearestEnemy:IsA("Model") and nearestEnemy:GetPivot().Position or nearestEnemy.Position
                        local vecStr = string.format("~v%.4f,%.4f,%.4f", enemyPos.X, enemyPos.Y, enemyPos.Z)
                        
                        -- Fungsi Cerdas Equip berdasarkan status centang UI
                        local function CheckAndAttack(toolName, attackLogic)
                            if not TargetWeapons[toolName] then return end -- Abaikan jika tidak dicentang di UI
                            
                            local tool = character:FindFirstChild(toolName)
                            if not tool and backpack then
                                tool = backpack:FindFirstChild(toolName)
                                if tool then
                                    humanoid:EquipTool(tool)
                                    task.wait() 
                                end
                            end
                            
                            if tool then
                                attackLogic(tool)
                            end
                        end

                        pcall(function()
                            -- 1. Harpoon
                            CheckAndAttack("Harpoon", function(t)
                                SafeRemoteFunction("ToolReplicator", "~sHarpoon", "~sHitEnemy", nearestEnemy)
                            end)
                            
                            -- 2. Magma Staff
                            CheckAndAttack("Magma Staff", function(t)
                                SafeRemoteFunction("ToolReplicator", "~sMagma Staff", "~sFire", vecStr)
                            end)

                            -- 3. Laser
                            CheckAndAttack("Laser", function(t)
                                SafeRemoteFunction("ToolReplicator", "~sLaser", "~sShoot", vecStr)
                            end)

                            -- 4. Rifle (Gun)
                            CheckAndAttack("Rifle", function(t)
                                local handle = t:FindFirstChild("Handle")
                                if handle then
                                    -- Menghitung arah rotasi peluru (LookVector) secara matematis
                                    local direction = (enemyPos - rootPart.Position).Unit
                                    local rifleFormatStr = string.format("~t{1=~f%.4f,%.4f,%.4f:%.4f,%.4f,%.4fZ0}", enemyPos.X, enemyPos.Y, enemyPos.Z, direction.X, direction.Y, direction.Z)
                                    
                                    SafeRemoteFunction("ToolReplicator", "~sGun", "~sShoot", handle, rifleFormatStr)
                                end
                            end)
                        end)
                    end
                end
                task.wait() 
            end
        end)
    end
end)

-- ====================================================================
-- [FITUR 6]: AUTO PICK MATERIAL (HARPOON SYSTEM - TARGET TERDEKAT)
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
                    local targetPart = nil
                    local shortestDistance = math.huge
                    
                    for _, folderObj in ipairs(DebrisField:GetChildren()) do
                        local resType = folderObj:GetAttribute("Resource")
                        local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                        
                        if not resType and part then
                            resType = part:GetAttribute("Resource")
                        end
                        
                        -- Cek material yang dipilih di MultiDropdown
                        if resType and TargetMaterials[resType] and part then
                            
                            -- Pengecualian Armor, Chest, dan Leg
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
                                -- Mengecek apakah item sedang dipegang oleh player lain
                                local isGrabbed = folderObj:GetAttribute("Grabbed") or part:GetAttribute("Grabbed")
                                local grabber = folderObj:GetAttribute("Grabber") or part:GetAttribute("Grabber")
                                
                                local myId = tostring(LocalPlayer.UserId)
                                local myName = LocalPlayer.Name
                                
                                if isGrabbed and (tostring(grabber) ~= myId and grabber ~= myName) then
                                    continue
                                end
                                
                                -- Mencari yang terdekat
                                local distance = (part.Position - rootPart.Position).Magnitude
                                if distance < shortestDistance then
                                    shortestDistance = distance
                                    nearestItem = folderObj
                                    targetPart = part
                                end
                            end
                        end
                    end
                    
                    -- Jika menemukan item target terdekat, tembak dengan harpoon
                    if nearestItem and targetPart then
                        pcall(function()
                            -- Konversi titik posisi ke string format Game (contoh: ~v22.6462,-26.8099,15.0381)
                            local pos = targetPart.Position
                            local vecStr = string.format("~v%.4f,%.4f,%.4f", pos.X, pos.Y, pos.Z)
                            
                            SafeRemoteFunction("ToolReplicator", "~sHarpoon", "~sGrab", nearestItem, vecStr)
                        end)
                        task.wait(0.2) -- Jeda biar harpoon tidak error karena spam berlebih
                    end
                end
                
                task.wait(0.1) 
            end
        end)
    end
end)
