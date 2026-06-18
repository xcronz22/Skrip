-- Memuat Library RZY
local RZY_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Win = RZY_Library:MakeWindow("100 Days at Sea - V7")

-- [DIPERBARUI]: Gas dihapus dari daftar manual
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
local AutoPickEnabled = false 
local AutoOpenChestEnabled = false

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
        if GameRemoteEvent then
            GameRemoteEvent:FireServer(GetNextToken(), actionName, ...)
        else
            warn("[RZY Hub] RemoteEvent belum ditemukan! Coba bergerak atau ambil 1 item manual.")
        end
    end
end

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
-- [FITUR 1]: AUTO GRINDER 
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
-- [FITUR 2]: AUTO CAMPFIRE (GAS & WOOD)
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
                            local resType = obj:GetAttribute("Resource")
                            local isGas = resType == "Gas" or string.find(string.lower(obj.Name), "gas")
                            
                            if resType == "Wood" or isGas then
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
                            local targetCFrame = dropperPart.CFrame + Vector3.new(0, 3, 0)
                            
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
-- [FITUR 3]: AUTO EAT 
-- ====================================================================
Win:AddToggle("Mulai Auto Eat (Sensor UI)", false, function(state)
    AutoEatEnabled = state
    
    if AutoEatEnabled then
        task.spawn(function()
            local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
            local FillBar = PlayerGui:WaitForChild("HUD"):WaitForChild("Food"):WaitForChild("Bar"):WaitForChild("Fill")
            
            while AutoEatEnabled do
                local currentScale = FillBar.Size.X.Scale
                if currentScale <= 0.7 then
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
                                
                                if isGrabbed and tostring(grabber) ~= tostring(LocalPlayer.UserId) and grabber ~= LocalPlayer.Name then
                                    continue
                                end
                                
                                local foodId = folderObj.Name 
                                SafeRemoteEvent("Eat", "~s" .. foodId)
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
-- [FITUR 5]: AUTO DOUBLOON CHEST
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
-- [FITUR 6]: BRUTAL AUTO ATTACK HARPOON & RIPTIDE (TARGET TERDEKAT)
-- ====================================================================
Win:AddToggle("Brutal Auto Harpoon", false, function(state)
    AutoHarpoonEnabled = state
    
    if AutoHarpoonEnabled then
        task.spawn(function()
            while AutoHarpoonEnabled do
                local workspace = game:GetService("Workspace")
                local CreatureContainer = workspace:FindFirstChild("CreatureContainer")
                
                local character = LocalPlayer.Character
                local rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChildWhichIsA("BasePart"))
                
                if CreatureContainer and rootPart then
                    local nearestEnemy = nil
                    local shortestDistance = math.huge
                    
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
                        pcall(function()
                            SafeRemoteFunction("ToolReplicator", "~sHarpoon", "~sHitEnemy", nearestEnemy)
                            SafeRemoteFunction("ToolReplicator", "~sRiptide", "~sHitEnemy", nearestEnemy)
                        end)
                    end
                end
                task.wait() 
            end
        end)
    end
end)

-- ====================================================================
-- [FITUR 7]: AUTO PICK MATERIAL (HARPOON & RIPTIDE + GAS SENSOR)
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
                        
                        -- Evaluasi Material Target
                        local isMaterial = false
                        if resType and TargetMaterials[resType] then
                            isMaterial = true
                        end
                        
                        -- [DIPERBARUI]: Deteksi GAS HANYA akan aktif jika Auto Campfire menyala
                        if AutoCampfireEnabled then
                            if resType == "Gas" or string.find(string.lower(folderObj.Name), "gas") then
                                isMaterial = true
                            end
                        end
                        
                        if isMaterial and part then
                            local isExcluded = false
                            for attrName, attrValue in pairs(folderObj:GetAttributes()) do
                                local lName = string.lower(attrName)
                                local lValue = type(attrValue) == "string" and string.lower(attrValue) or ""
                                
                                if string.find(lName, "armor") or string.find(lValue, "armor") or
                                   string.find(lName, "chest") or string.find(lValue, "chest") or
                                   string.find(lName, "leg") or string.find(lValue, "leg") then
                                    isExcluded = true
                                    break
                                end
                            end
                            
                            if not isExcluded then
                                local isGrabbed = folderObj:GetAttribute("Grabbed") or part:GetAttribute("Grabbed")
                                local grabber = folderObj:GetAttribute("Grabber") or part:GetAttribute("Grabber")
                                local myId = tostring(LocalPlayer.UserId)
                                local myName = LocalPlayer.Name
                                
                                if isGrabbed and (tostring(grabber) ~= myId and grabber ~= myName) then
                                    continue
                                end
                                
                                local distance = (part.Position - rootPart.Position).Magnitude
                                if distance < shortestDistance then
                                    shortestDistance = distance
                                    nearestItem = folderObj
                                    targetPart = part
                                end
                            end
                        end
                    end
                    
                    if nearestItem and targetPart then
                        pcall(function()
                            local pos = targetPart.Position
                            local vecStr = string.format("~v%.4f,%.4f,%.4f", pos.X, pos.Y, pos.Z)
                            
                            SafeRemoteFunction("ToolReplicator", "~sHarpoon", "~sGrab", nearestItem, vecStr)
                            SafeRemoteFunction("ToolReplicator", "~sRiptide", "~sGrab", nearestItem, vecStr)
                        end)
                        task.wait(0.2) 
                    end
                end
                
                task.wait(0.1) 
            end
        end)
    end
end)

-- ====================================================================
-- [FITUR 8]: AUTO OPEN CHEST (RADIUS 5 STUD)
-- ====================================================================
Win:AddToggle("Auto Open Chest (Radius 5)", false, function(state)
    AutoOpenChestEnabled = state
    
    if AutoOpenChestEnabled then
        task.spawn(function()
            while AutoOpenChestEnabled do
                local workspace = game:GetService("Workspace")
                local ChestsFolder = workspace:FindFirstChild("Chests")
                
                local character = LocalPlayer.Character
                local rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChildWhichIsA("BasePart"))
                
                if ChestsFolder and rootPart then
                    for _, chest in ipairs(ChestsFolder:GetChildren()) do
                        if not AutoOpenChestEnabled then break end
                        
                        local chestPart = chest:IsA("BasePart") and chest or chest:FindFirstChildWhichIsA("BasePart") or (chest:IsA("Model") and chest.PrimaryPart)
                        
                        if chestPart then
                            local distance = (chestPart.Position - rootPart.Position).Magnitude
                            
                            if distance <= 5 then
                                pcall(function()
                                    SafeRemoteFunction("OpenChest", chest)
                                end)
                                task.wait(0.1) 
                            end
                        end
                    end
                end
                
                task.wait(0.5) 
            end
        end)
    end
end)
