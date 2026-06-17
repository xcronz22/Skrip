-- Memuat Library RZY
local RZY_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Win = RZY_Library:MakeWindow("100 Days at Sea - V5")

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

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ====================================================================
-- [UPDATE PENTING]: SERVICE REMOTE BERADA DI LOCALIZATION SERVICE
-- ====================================================================
local LocalizationService = game:GetService("LocalizationService")
local CurrentSyncToken = nil

-- Menyadap komunikasi secaran aman untuk Event & Function
pcall(function()
    if hookmetamethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            -- Deteksi RemoteEvent (FireServer) & RemoteFunction (InvokeServer) di LocalizationService
            if (method == "FireServer" or method == "InvokeServer") and (self.Name == "RemoteEvent" or self.Name == "RemoteFunction") and self.Parent == LocalizationService then
                if type(args[1]) == "number" then
                    if not checkcaller() then
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

-- Fungsi Generator Token
local function GetNextToken()
    if not CurrentSyncToken then CurrentSyncToken = math.random(100000, 999999) end
    CurrentSyncToken = CurrentSyncToken + 1
    return CurrentSyncToken
end

-- Eksekusi Remote Event
local function SafeRemoteEvent(actionName, ...)
    local remote = LocalizationService:FindFirstChild("RemoteEvent")
    if remote then
        remote:FireServer(GetNextToken(), actionName, ...)
    end
end

-- Eksekusi Remote Function
local function SafeRemoteFunction(actionName, ...)
    local remote = LocalizationService:FindFirstChild("RemoteFunction")
    if remote then
        return remote:InvokeServer(GetNextToken(), actionName, ...)
    end
end

-- ====================================================================
-- [FITUR 1 & 2]: AUTO GRINDER & CAMPFIRE (TETAP SAMA SEPERTI V4)
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
                                    local myId, myName = LocalPlayer.UserId, LocalPlayer.Name
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
                                if part:IsA("BasePart") then part.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end
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
-- [FITUR 3]: AUTO EAT (SEKUENS: DRAG -> EAT -> GIVE UP)
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
                                    local targetPart = obj:IsA("BasePart") and obj or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                                    
                                    while foodFill.Size.X.Scale < 0.95 and AutoEatEnabled and targetPart do
                                        -- 1. Berusaha memegang objek
                                        pcall(function()
                                            SafeRemoteFunction("AttemptDrag", targetPart)
                                        end)
                                        task.wait(0.1)
                                        
                                        -- 2. Memakan objek
                                        SafeRemoteEvent("Eat", "~s" .. obj.Name)
                                        task.wait(0.2)
                                        
                                        -- 3. Melepaskan objek (agar tidak nyangkut)
                                        SafeRemoteEvent("GiveUpOwnership", targetPart, "~v0,0,0")
                                        
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
-- [FITUR 4]: AUTO INTERACT (CRAB TRAP FIX DETEKSI FOLDER)
-- ====================================================================
Win:AddToggle("Auto Harvest Crab Trap", false, function(state)
    AutoCrabTrapEnabled = state
    
    if AutoCrabTrapEnabled then
        task.spawn(function()
            while AutoCrabTrapEnabled do
                local workspace = game:GetService("Workspace")
                local CraftedFolder = workspace:FindFirstChild("SpawnIsland") and workspace.SpawnIsland:FindFirstChild("Crafted")
                
                -- Memastikan folder Crafted ada, lalu mencari isi di dalamnya
                if CraftedFolder then
                    for _, obj in ipairs(CraftedFolder:GetChildren()) do
                        -- Mengecek apakah objek yang ada di dalam folder tersebut mengandung kata "Crab Trap"
                        if string.find(string.lower(obj.Name), "crab trap") then
                            SafeRemoteEvent("Interact", obj)
                            task.wait(0.5) -- Jeda sebentar agar tidak spam remote
                        end
                    end
                end
                task.wait(3) 
            end
        end)
    end
end)
