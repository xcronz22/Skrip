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
                    local itemsToProcess = {}
                    
                    for _, obj in ipairs(DebrisField:GetChildren()) do
                        local resType = obj:GetAttribute("Resource")
                        
                        if resType and TargetMaterials[resType] then
                            -- Filter ketat: Jangan ambil jika sedang di-grab player
                            if obj:GetAttribute("Grabbed") == true or obj:FindFirstChild("Drag") then
                                continue 
                            end

                            local primary = obj:IsA("Model") and obj.PrimaryPart or (obj:IsA("BasePart") and obj)
                            
                            if primary then
                                local distance = (primary.Position - GrinderCol.Position).Magnitude
                                
                                -- Ambil jika jaraknya di luar radius 3 stud dari penggiling
                                if distance > 3 then
                                    local grabberAttr = obj:GetAttribute("Grabber")
                                    local lastHolderAttr = obj:GetAttribute("LastHolder")
                                    
                                    -- Cek Kategori berdasarkan Atribut History
                                    local category = 2 
                                    if grabberAttr ~= nil and lastHolderAttr ~= nil then
                                        category = 1 
                                    end

                                    table.insert(itemsToProcess, {
                                        Object = obj,
                                        Distance = distance,
                                        Category = category
                                    })
                                end
                            end
                        end
                    end

                    -- Urutkan berdasarkan jarak paling dekat dengan mesin giling terlebih dahulu
                    table.sort(itemsToProcess, function(a, b)
                        return a.Distance < b.Distance 
                    end)

                    for _, data in ipairs(itemsToProcess) do
                        local obj = data.Object
                        local targetCFrame
                        
                        if data.Category == 1 then
                            targetCFrame = GrinderCol.CFrame -- Kategori 1 masuk ke Grinder
                        else
                            targetCFrame = GrinderCol.CFrame * CFrame.new(0, 4, 0) -- Kategori 2 melayang 4 stud di atas Grinder
                        end

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
-- [FITUR 2]: AUTO CAMPFIRE (KHUSUS KAYU)
-- ====================================================================
Win:AddToggle("Mulai Auto Campfire", false, function(state)
    AutoCampfireEnabled = state
    
    if AutoCampfireEnabled then
        task.spawn(function()
            while AutoCampfireEnabled do
                local workspace = game:GetService("Workspace")
                local DebrisField = workspace:FindFirstChild("DebrisField")
                local Dropper = workspace:FindFirstChild("SpawnIsland") and workspace.SpawnIsland:FindFirstChild("Dropper")
                local GrinderCol = workspace:FindFirstChild("SpawnIsland") and workspace.SpawnIsland:FindFirstChild("Grinder") and workspace.SpawnIsland.Grinder:FindFirstChild("Collection")

                if DebrisField and Dropper and GrinderCol then
                    local dropperPart = Dropper:IsA("BasePart") and Dropper or Dropper:FindFirstChildWithClass("BasePart") or (Dropper:IsA("Model") and Dropper.PrimaryPart)
                    
                    if dropperPart then
                        for _, obj in ipairs(DebrisField:GetChildren()) do
                            local resType = obj:GetAttribute("Resource")
                            
                            if resType == "Wood" then
                                -- FILTER KETAT: Abaikan jika sedang di-grab player
                                if obj:GetAttribute("Grabbed") == true or obj:FindFirstChild("Drag") then
                                    continue
                                end
                                
                                local primary = obj:IsA("Model") and obj.PrimaryPart or (obj:IsA("BasePart") and obj)
                                
                                if primary then
                                    local distance = (primary.Position - dropperPart.Position).Magnitude
                                    
                                    if distance > 3 then
                                        local grabberAttr = obj:GetAttribute("Grabber")
                                        local lastHolderAttr = obj:GetAttribute("LastHolder")
                                        
                                        local category = 2 
                                        if grabberAttr ~= nil and lastHolderAttr ~= nil then
                                            category = 1 
                                        end

                                        local targetCFrame
                                        if category == 1 then
                                            targetCFrame = dropperPart.CFrame -- Kategori 1 masuk ke Campfire Dropper
                                        else
                                            targetCFrame = GrinderCol.CFrame * CFrame.new(0, 4, 0) -- Kategori 2 melayang 4 stud di atas Grinder
                                        end

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
                                        
                                        -- FIRETOUCH SIMULATION: Hanya dilakukan jika kayu dikirim ke api unggun (Kategori 1)
                                        if category == 1 and firetouchinterest then
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
                        end
                    end
                end
                task.wait(0.1) 
            end
        end)
    end
end)
