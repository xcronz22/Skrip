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
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ====================================================================
-- [FITUR 1]: AUTO GRINDER (AGRESIF & SMART FILTER)
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
                            local primary = obj:IsA("Model") and obj.PrimaryPart or (obj:IsA("BasePart") and obj)
                            
                            if primary then
                                local distance = (primary.Position - GrinderCol.Position).Magnitude
                                
                                -- Ambil jika jaraknya di luar radius 3 stud dari penggiling
                                if distance > 3 then
                                    local isGrabbed = obj:GetAttribute("Grabbed")
                                    local grabberAttr = obj:GetAttribute("Grabber")
                                    
                                    -- Data Identitas Player Kamu
                                    local myId = LocalPlayer.UserId
                                    local myName = LocalPlayer.Name
                                    
                                    local isGrabberMe = false
                                    if grabberAttr ~= nil then
                                        isGrabberMe = (grabberAttr == myId or tostring(grabberAttr) == tostring(myId) or grabberAttr == myName)
                                    end
                                    
                                    -- [FILTER MUTLAK]: Lewati HANYA JIKA sedang dipegang (Grabbed=true) OLEH PLAYER LAIN
                                    if isGrabbed == true and not isGrabberMe then
                                        continue
                                    end
                                    
                                    -- Selain itu (Alam murni, bekas sendiri, bekas player lain), sedot semua!
                                    table.insert(itemsToProcess, {
                                        Object = obj,
                                        Distance = distance
                                    })
                                end
                            end
                        end
                    end

                    -- Urutkan berdasarkan jarak paling dekat dengan mesin giling terlebih dahulu
                    table.sort(itemsToProcess, function(a, b)
                        return a.Distance < b.Distance 
                    end)

                    -- Eksekusi TP langsung ke dalam Grinder
                    for _, data in ipairs(itemsToProcess) do
                        local obj = data.Object
                        local targetCFrame = GrinderCol.CFrame

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
                    end
                end
                task.wait(0.1) 
            end
        end)
    end
end)

-- ====================================================================
-- [FITUR 2]: AUTO CAMPFIRE (KHUSUS KAYU, AGRESIF & SMART FILTER)
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
                                local primary = obj:IsA("Model") and obj.PrimaryPart or (obj:IsA("BasePart") and obj)
                                
                                if primary then
                                    local distance = (primary.Position - dropperPart.Position).Magnitude
                                    
                                    if distance > 3 then
                                        local isGrabbed = obj:GetAttribute("Grabbed")
                                        local grabberAttr = obj:GetAttribute("Grabber")
                                        
                                        -- Data Identitas Player Kamu
                                        local myId = LocalPlayer.UserId
                                        local myName = LocalPlayer.Name
                                        
                                        local isGrabberMe = false
                                        if grabberAttr ~= nil then
                                            isGrabberMe = (grabberAttr == myId or tostring(grabberAttr) == tostring(myId) or grabberAttr == myName)
                                        end
                                        
                                        -- [FILTER MUTLAK]: Lewati HANYA JIKA sedang dipegang (Grabbed=true) OLEH PLAYER LAIN
                                        if isGrabbed == true and not isGrabberMe then
                                            continue
                                        end
                                        
                                        table.insert(itemsToProcess, {
                                            Object = obj,
                                            Distance = distance
                                        })
                                    end
                                end
                            end
                        end
                        
                        -- Urutkan jarak untuk Campfire agar eksekusi rapi dari yang terdekat
                        table.sort(itemsToProcess, function(a, b)
                            return a.Distance < b.Distance 
                        end)

                        for _, data in ipairs(itemsToProcess) do
                            local obj = data.Object
                            local targetCFrame = dropperPart.CFrame

                            -- Teleportasi langsung ke Campfire
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
                            
                            -- Memicu sensor pembakaran secara instan
                            if firetouchinterest then
                                local touchPart = obj:IsA("BasePart") and obj or obj.PrimaryPart
                                if touchPart then
                                    firetouchinterest(dropperPart, touchPart, 0) 
                                    task.wait()
                                    firetouchinterest(dropperPart, touchPart, 1) 
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
