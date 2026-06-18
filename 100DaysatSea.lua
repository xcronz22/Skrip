-- Memuat Library RZY
local RZY_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Win = RZY_Library:MakeWindow("100 Days at Sea - V6")

local TargetMaterials = {
    ["Wood"] = false,
    ["Metal"] = false,
    ["Goo"] = false
}

Win:AddMultiDropdown("Pilih Material (Bisa >1)", {"Wood", "Metal", "Goo"}, function(selectedTable)
    TargetMaterials = selectedTable
end)

local AutoGrinderEnabled = false
local AutoCampfireEnabled = false
local AutoEatEnabled = false
local AutoCrabTrapEnabled = false
local AutoDoubloonEnabled = false 
local AutoHarpoonEnabled = false 
local AutoPickEnabled = false -- [BARU] Variabel untuk Auto Pick Harpoon

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

FindHiddenRemotes() -- Jalankan pelacak saat script dimulai

-- 2. PENYADAP KOMUNIKASI (Dibuat Dinamis Tanpa Mempedulikan Service Parent-nya)
pcall(function()
    if hookmetamethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if (method == "FireServer" or method == "InvokeServer") then
                if self.Name == "RemoteEvent" or self.Name == "RemoteFunction" then
                    -- Verifikasi format remote game ini (Arg 1 adalah Token Angka, Arg 2 adalah String Action)
                    if type(args[1]) == "number" and type(args[2]) == "string" then
                        if not checkcaller() then
                            -- Jika pelacak gagal di awal, kita tangkap/curi remotenya langsung dari gamenya di sini
                            if self:IsA("RemoteEvent") then GameRemoteEvent = self end
                            if self:IsA("RemoteFunction") then GameRemoteFunction = self end
                            
                            -- Sinkronisasi Token
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

-- Fungsi Generator Token
local function GetNextToken()
    if not CurrentSyncToken then CurrentSyncToken = math.random(100000, 999999) end
    CurrentSyncToken = CurrentSyncToken + 1
    return CurrentSyncToken
end

-- Eksekusi Remote Event Aman & Dinamis
local function SafeRemoteEvent(actionName, ...)
    if GameRemoteEvent then
        GameRemoteEvent:FireServer(GetNextToken(), actionName, ...)
    else
        FindHiddenRemotes()
        if GameRemoteEvent then
            GameRemoteEvent:FireServer(GetNextToken(), actionName, ...)
        else
            warn("[RZY Hub] RemoteEvent belum ditemukan! Coba bergerak atau ambil 1 item manual.")
        end
    end
end

-- Eksekusi Remote Function Aman & Dinamis
local function SafeRemoteFunction(actionName, ...)
    if GameRemoteFunction then
        return GameRemoteFunction:InvokeServer(GetNextToken(), actionName, ...)
    else
        FindHiddenRemotes()
        if GameRemoteFunction then
            return GameRemoteFunction:InvokeServer(GetNextToken(), actionName, ...)
        end
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
-- [FITUR 2]: AUTO CAMPFIRE
-- ====================================================================
Win:AddToggle("Mulai Auto Campfire", false, function(state)
    AutoCampfireEnabled = state
    if AutoCampfireEnabled then
        task.spawn(function()
            while AutoCampfireEnabled do
                local workspace = game:GetService("Workspace")
                local DebrisField = workspace:FindFirstChild("DebrisField")
                local Dropper = workspace:FindFirstChild("SpawnIsland") and workspace.SpawnIsland:FindFirstChild("Dropper")

                if DebrisField and Dropper then
                    local dropperPart = Dropper:IsA("BasePart") and Dropper or Dropper:FindFirstChildWithClass("BasePart") or (Dropper:IsA("Model") and Dropper.PrimaryPart)
                    if dropperPart then
                        local itemsToProcess = {}
                        for _, obj in ipairs(DebrisField:GetChildren()) do
                            if obj:GetAttribute("Resource") == "Wood" then
                                local isArmor = false
                                for attrName, attrValue in pairs(obj:GetAttributes()) do
                                    if string.find(string.lower(attrName), "armor") or (type(attrValue) == "string" and string.find(string.lower(attrValue), "armor")) then
                                        isArmor = true; break
                                    end
                                end
                                if isArmor then continue end

                                local primary = obj:IsA("Model") and obj.PrimaryPart or (obj:IsA("BasePart") and obj)
                                if primary then
                                    local distance = (primary.Position - dropperPart.Position).Magnitude
                                    if distance > 3 then
                                        local isGrabbed = obj:GetAttribute("Grabbed")
                                        local grabberAttr = obj:GetAttribute("Grabber")
                                        local myId, myName = LocalPlayer.UserId, LocalPlayer.Name
                                        local isGrabberMe = false
                                        if grabberAttr ~= nil then isGrabberMe = (grabberAttr == myId or tostring(grabberAttr) == tostring(myId) or grabberAttr == myName) end
                                        if isGrabbed == true and not isGrabberMe then continue end
                                        
                                        table.insert(itemsToProcess, { Object = obj, Distance = distance })
                                    end
                                end
                            end
                        end
                        table.sort(itemsToProcess, function(a, b) return a.Distance < b.Distance end)

                        for _, data in ipairs(itemsToProcess) do
                            if not AutoCampfireEnabled then break end 
                            local obj = data.Object
                            local targetCFrame = dropperPart.CFrame
                            obj:SetAttribute("Grabbed", false) 
                            obj:SetAttribute("LastHolder", LocalPlayer.Name)

                            if obj:IsA("BasePart") then
                                obj.CFrame = targetCFrame
                                obj.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            elseif obj:IsA("Model") then
                                obj:PivotTo(targetCFrame)
                                for _, part in ipairs(obj:GetDescendants()) do
                                    if part:IsA("BasePart") then part.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end
                                end
                            end
                            
                            if firetouchinterest then
                                local touchPart = obj:IsA("BasePart") and obj or obj.PrimaryPart
                                if touchPart then
                                    firetouchinterest(dropperPart, touchPart, 0) 
                                    task.wait()
                                    firetouchinterest(dropperPart, touchPart, 1) 
                                end
                            end
                            task.wait(0.1)
                        end
                    end
                end
                task.wait(0.1) 
            end
        end)
    end
end)

-- ====================================================================
-- [FITUR 3]: AUTO EAT (DENGAN SENSOR UI - MAKAN JIKA BAR <= 0.7)
-- ====================================================================
Win:AddToggle("Mulai Auto Eat (Sensor UI)", false, function(state)
    AutoEatEnabled = state
    
    if AutoEatEnabled then
        task.spawn(function()
            -- Path ke UI Bar Food
            local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
            local FillBar = PlayerGui:WaitForChild("HUD"):WaitForChild("Food"):WaitForChild("Bar"):WaitForChild("Fill")
            
            while AutoEatEnabled do
                -- Cek ukuran (Scale) bar makanan saat ini
                local currentScale = FillBar.Size.X.Scale
                
                -- Jika lapar (Scale <= 0.7), mulai makan sampai kenyang (Scale >= 0.99)
                if currentScale <= 0.7 then
                    local workspace = game:GetService("Workspace")
                    local DebrisField = workspace:FindFirstChild("DebrisField")
                    
                    if DebrisField then
                        for _, folderObj in ipairs(DebrisField:GetChildren()) do
                            if not AutoEatEnabled or FillBar.Size.X.Scale >= 0.99 then break end
                            
                            -- Deteksi objek makanan
                            local isFood = folderObj:GetAttribute("Food")
                            local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                            if not isFood and part then isFood = part:GetAttribute("Food") end
                            
                            if isFood and part then
                                local isGrabbed = folderObj:GetAttribute("Grabbed") or part:GetAttribute("Grabbed")
                                local grabber = folderObj:GetAttribute("Grabber") or part:GetAttribute("Grabber")
                                
                                -- Skip jika dipegang orang lain
                                if isGrabbed and tostring(grabber) ~= tostring(LocalPlayer.UserId) and grabber ~= LocalPlayer.Name then
                                    continue
                                end
                                
                                local foodId = folderObj.Name 
                                
                                -- Makan 1x lalu cek lagi apakah sudah kenyang
                                SafeRemoteEvent("Eat", "~s" .. foodId)
                                task.wait(0.05) -- Jeda antar suapan
                            end
                        end
                    end
                end
                
                -- Cek sensor setiap 1 detik
                task.wait(1) 
            end
        end)
    end
end)

-- ====================================================================
-- [FITUR 4]: AUTO INTERACT CRAB TRAP
-- ====================================================================
Win:AddToggle("Auto Harvest Crab Trap", false, function(state)
    AutoCrabTrapEnabled = state
    
    if AutoCrabTrapEnabled then
        task.spawn(function()
            while AutoCrabTrapEnabled do
                local workspace = game:GetService("Workspace")
                local SpawnIsland = workspace:FindFirstChild("SpawnIsland")
                
                if SpawnIsland then
                    local CraftedFolder = SpawnIsland:FindFirstChild("Crafted")
                    if CraftedFolder then
                        for _, obj in ipairs(CraftedFolder:GetChildren()) do
                            if string.find(string.lower(obj.Name), "crab trap") then
                                SafeRemoteEvent("Interact", obj)
                                task.wait(0.3) 
                            end
                        end
                    end
                end
                task.wait(4) 
            end
        end)
    end
end)

-- ====================================================================
-- [FITUR 5]: AUTO DOUBLOON CHEST (100% DINAMIS)
-- ====================================================================
Win:AddToggle("Auto Doubloon Chest", false, function(state)
    AutoDoubloonEnabled = state
    
    if AutoDoubloonEnabled then
        task.spawn(function()
            while AutoDoubloonEnabled do
                local workspace = game:GetService("Workspace")
                local DebrisField = workspace:FindFirstChild("DebrisField")
                
                if DebrisField then
                    for _, folderObj in ipairs(DebrisField:GetChildren()) do
                        if not AutoDoubloonEnabled then break end
                        
                        local isChest = folderObj:GetAttribute("DoubloonChest")
                        local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                        
                        if not isChest and part then
                            isChest = part:GetAttribute("DoubloonChest")
                        end
                        
                        if not isChest then
                            for attrName, attrValue in pairs(folderObj:GetAttributes()) do
                                if string.find(string.lower(attrName), "doubloonchest") or (type(attrValue) == "string" and string.find(string.lower(attrValue), "doubloonchest")) then
                                    isChest = true
                                    break
                                end
                            end
                        end
                        
                        if isChest then
                            local chestId = folderObj.Name 
                            SafeRemoteEvent("Collect", "~s" .. chestId)
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
-- [FITUR 6]: BRUTAL AUTO ATTACK HARPOON SYSTEM (TARGET TERDEKAT)
-- ====================================================================
Win:AddToggle("Brutal Auto Harpoon", false, function(state)
    AutoHarpoonEnabled = state
    
    if AutoHarpoonEnabled then
        task.spawn(function()
            while AutoHarpoonEnabled do
                local workspace = game:GetService("Workspace")
                local CreatureContainer = workspace:FindFirstChild("CreatureContainer")
                
                -- Pastikan Karakter Anda dan RootPart-nya ada untuk menghitung jarak
                local character = LocalPlayer.Character
                local rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChildWhichIsA("BasePart"))
                
                if CreatureContainer and rootPart then
                    local nearestEnemy = nil
                    local shortestDistance = math.huge -- Set awal ke nilai tak terhingga
                    
                    -- LOOP 1: Mencari target musuh yang paling dekat
                    for _, enemy in ipairs(CreatureContainer:GetChildren()) do
                        -- Sesuai kondisi: Abaikan jika musuh bernama Seagull
                        if enemy.Name ~= "Seagull" then
                            -- Cari part fisik musuh untuk mendeteksi koordinat posisi
                            local enemyPart = enemy:IsA("BasePart") and enemy or enemy:FindFirstChildWhichIsA("BasePart") or (enemy:IsA("Model") and enemy.PrimaryPart)
                            
                            if enemyPart then
                                -- Hitung jarak antara posisi Anda dengan posisi musuh tersebut
                                local distance = (enemyPart.Position - rootPart.Position).Magnitude
                                
                                -- Jika jaraknya lebih dekat dari rekor jarak sebelumnya, simpan sebagai target utama
                                if distance < shortestDistance then
                                    shortestDistance = distance
                                    nearestEnemy = enemy
                                end
                            end
                        end
                    end
                    
                    -- LOOP 2: Jika target terdekat ditemukan, bantai secara brutal
                    if nearestEnemy then
                        -- Menggunakan fungsi remote bawaan aman agar otomatis bypass dimanapun remote berada
                        pcall(function()
                            SafeRemoteFunction("ToolReplicator", "~sHarpoon", "~sHitEnemy", nearestEnemy)
                        end)
                    end
                end
                
                -- Kecepatan serangan brutal (task.wait tanpa angka = secepat frame rate game Anda)
                task.wait() 
            end
        end)
    end
end)

-- ====================================================================
-- [FITUR 7]: AUTO PICK MATERIAL (HARPOON SYSTEM - TARGET TERDEKAT)
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
