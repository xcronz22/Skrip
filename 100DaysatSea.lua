-- Memuat Library RZY (Pastikan link github sudah yang terbaru)
local RZY_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Win = RZY_Library:MakeWindow("100 Days at Sea - V4")

-- Default status material
local TargetMaterials = {
    ["Wood"] = false,
    ["Metal"] = false,
    ["Goo"] = false
}

-- Menambahkan Dropdown Centang Ganda
Win:AddMultiDropdown("Pilih Material (Bisa >1)", {"Wood", "Metal", "Goo"}, function(selectedTable)
    TargetMaterials = selectedTable
end)

local AutoGrinderEnabled = false
local AutoCampfireEnabled = false
local AutoEatEnabled = false
local AutoCrabTrapEnabled = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local SocialService = game:GetService("SocialService")

-- ====================================================================
-- [SISTEM INTI]: ANTI DESYNC / TOKEN INTERCEPTOR (PERBAIKAN HOOK)
-- ====================================================================
local CurrentSyncToken = nil

-- Menyadap komunikasi secaran aman (FIXED: Mencegah UI Stuck/Crash)
pcall(function()
    if hookmetamethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            -- Deteksi remote yang dituju
            if method == "FireServer" and self.Name == "RemoteEvent" and self.Parent == SocialService then
                -- Jika argumen pertama adalah angka (Token)
                if type(args[1]) == "number" then
                    if not checkcaller() then
                        -- Script asli game mengirim data, sinkronkan token kita!
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
            return oldNamecall(self, ...)
        end)
    end
end)

-- Fungsi Remote Aman (Tidak akan merusak status tangan/grabbed)
local function SafeRemoteInteract(actionName, targetData)
    local remote = SocialService:FindFirstChild("RemoteEvent")
    if not remote then return end
    
    if not CurrentSyncToken then 
        CurrentSyncToken = math.random(100000, 999999) 
    end
    
    CurrentSyncToken = CurrentSyncToken + 1
    remote:FireServer(CurrentSyncToken, actionName, targetData)
end

-- ====================================================================
-- [FITUR 1]: AUTO GRINDER (SMART FILTER, ANTI-ARMOR & FIXED GRAB BUG)
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
                    local itemsToProcess = {}
                    
                    for _, obj in ipairs(DebrisField:GetChildren()) do
                        local resType = obj:GetAttribute("Resource")
                        
                        if resType and TargetMaterials[resType] then
                            local isArmor = false
                            for attrName, attrValue in pairs(obj:GetAttributes()) do
                                if string.find(string.lower(attrName), "armor") or (type(attrValue) == "string" and string.find(string.lower(attrValue), "armor")) then
                                    isArmor = true
                                    break
                                end
                            end
                            if isArmor then continue end 

                            local primary = obj:IsA("Model") and obj.PrimaryPart or (obj:IsA("BasePart") and obj)
                            
                            if primary then
                                local distance = (primary.Position - GrinderCol.Position).Magnitude
                                if distance > 3 then
                                    local isGrabbed = obj:GetAttribute("Grabbed")
                                    local grabberAttr = obj:GetAttribute("Grabber")
                                    
                                    local myId = LocalPlayer.UserId
                                    local myName = LocalPlayer.Name
                                    
                                    local isGrabberMe = false
                                    if grabberAttr ~= nil then
                                        isGrabberMe = (grabberAttr == myId or tostring(grabberAttr) == tostring(myId) or grabberAttr == myName)
                                    end
                                    
                                    if isGrabbed == true and not isGrabberMe then continue end
                                    
                                    table.insert(itemsToProcess, { Object = obj, Distance = distance })
                                end
                            end
                        end
                    end

                    table.sort(itemsToProcess, function(a, b) return a.Distance < b.Distance end)

                    for _, data in ipairs(itemsToProcess) do
                        if not AutoGrinderEnabled then break end 
                        
                        local obj = data.Object
                        local targetCFrame = GrinderCol.CFrame
                        
                        obj:SetAttribute("Grabbed", false) 
                        obj:SetAttribute("LastHolder", LocalPlayer.Name)  

                        if obj:IsA("BasePart") then
                            obj.CFrame = targetCFrame
                            obj.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        elseif obj:IsA("Model") then
                            obj:PivotTo(targetCFrame)
                            for _, part in ipairs(obj:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                end
                            end
                        end
                        task.wait(0.1)
                    end
                end
                task.wait(0.1) 
            end
        end)
    end
end)

-- ====================================================================
-- [FITUR 2]: AUTO CAMPFIRE (KHUSUS KAYU, ANTI-ARMOR & FIXED GRAB BUG)
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
                            
                            if resType == "Wood" then
                                local isArmor = false
                                for attrName, attrValue in pairs(obj:GetAttributes()) do
                                    if string.find(string.lower(attrName), "armor") or (type(attrValue) == "string" and string.find(string.lower(attrValue), "armor")) then
                                        isArmor = true
                                        break
                                    end
                                end
                                if isArmor then continue end

                                local primary = obj:IsA("Model") and obj.PrimaryPart or (obj:IsA("BasePart") and obj)
                                
                                if primary then
                                    local distance = (primary.Position - dropperPart.Position).Magnitude
                                    if distance > 3 then
                                        local isGrabbed = obj:GetAttribute("Grabbed")
                                        local grabberAttr = obj:GetAttribute("Grabber")
                                        
                                        local myId = LocalPlayer.UserId
                                        local myName = LocalPlayer.Name
                                        
                                        local isGrabberMe = false
                                        if grabberAttr ~= nil then
                                            isGrabberMe = (grabberAttr == myId or tostring(grabberAttr) == tostring(myId) or grabberAttr == myName)
                                        end
                                        
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
                                    if part:IsA("BasePart") then
                                        part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                    end
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
-- [FITUR 3]: AUTO EAT (DENGAN UI DETEKTOR & REMOTE AMAN)
-- ====================================================================
Win:AddToggle("Mulai Auto Eat", false, function(state)
    AutoEatEnabled = state
    
    if AutoEatEnabled then
        task.spawn(function()
            while AutoEatEnabled do
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    
                    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                    local foodFill = playerGui 
                        and playerGui:FindFirstChild("HUD") 
                        and playerGui.HUD:FindFirstChild("Food") 
                        and playerGui.HUD.Food:FindFirstChild("Bar") 
                        and playerGui.HUD.Food.Bar:FindFirstChild("Fill")
                    
                    if foodFill and foodFill.Size.X.Scale <= 0.3 then
                        local workspace = game:GetService("Workspace")
                        local DebrisField = workspace:FindFirstChild("DebrisField")
                        
                        if DebrisField then
                            for _, obj in ipairs(DebrisField:GetChildren()) do
                                if not AutoEatEnabled then break end 
                                
                                if obj:GetAttribute("Food") then
                                    while foodFill.Size.X.Scale < 0.95 and AutoEatEnabled do
                                        SafeRemoteInteract("Eat", "~s" .. obj.Name)
                                        task.wait(0.5) 
                                    end
                                    
                                    if foodFill.Size.X.Scale >= 0.95 then break end
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
-- [FITUR 4]: AUTO INTERACT (CRAB TRAP)
-- ====================================================================
Win:AddToggle("Auto Harvest Crab Trap", false, function(state)
    AutoCrabTrapEnabled = state
    
    if AutoCrabTrapEnabled then
        task.spawn(function()
            while AutoCrabTrapEnabled do
                local workspace = game:GetService("Workspace")
                local CraftedFolder = workspace:FindFirstChild("SpawnIsland") and workspace.SpawnIsland:FindFirstChild("Crafted")
                
                if CraftedFolder then
                    for _, obj in ipairs(CraftedFolder:GetChildren()) do
                        if string.find(string.lower(obj.Name), "crab trap") then
                            SafeRemoteInteract("Interact", obj)
                            task.wait(0.2) 
                        end
                    end
                end
                task.wait(5) 
            end
        end)
    end
end)
