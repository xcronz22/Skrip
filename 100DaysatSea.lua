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
local GodModeHeal = false
local GodModeCanTouch = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ====================================================================
-- [FITUR 1]: AUTO GRINDER (HANYA PRIORITAS UTAMA)
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
                            if obj:GetAttribute("Grabbed") == true or obj:FindFirstChild("Drag") then
                                continue 
                            end

                            local primary = obj:IsA("Model") and obj.PrimaryPart or (obj:IsA("BasePart") and obj)
                            
                            if primary then
                                local distance = (primary.Position - GrinderCol.Position).Magnitude
                                
                                if distance > 3 then
                                    local grabberAttr = obj:GetAttribute("Grabber")
                                    local lastHolderAttr = obj:GetAttribute("LastHolder")
                                    
                                    if grabberAttr ~= nil and lastHolderAttr ~= nil then
                                        table.insert(itemsToProcess, {
                                            Object = obj,
                                            Distance = distance
                                        })
                                    end
                                end
                            end
                        end
                    end

                    table.sort(itemsToProcess, function(a, b)
                        return a.Distance < b.Distance 
                    end)

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
-- [FITUR 2]: AUTO CAMPFIRE (KHUSUS KAYU & HANYA PRIORITAS UTAMA)
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
                        for _, obj in ipairs(DebrisField:GetChildren()) do
                            local resType = obj:GetAttribute("Resource")
                            
                            if resType == "Wood" then
                                if obj:GetAttribute("Grabbed") == true or obj:FindFirstChild("Drag") then
                                    continue
                                end
                                
                                local primary = obj:IsA("Model") and obj.PrimaryPart or (obj:IsA("BasePart") and obj)
                                
                                if primary then
                                    local distance = (primary.Position - dropperPart.Position).Magnitude
                                    
                                    if distance > 3 then
                                        local grabberAttr = obj:GetAttribute("Grabber")
                                        local lastHolderAttr = obj:GetAttribute("LastHolder")
                                        
                                        if grabberAttr ~= nil and lastHolderAttr ~= nil then
                                            local targetCFrame = dropperPart.CFrame

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

-- ====================================================================
-- [FITUR 3]: GOD MODE OPTIONS (ANTI-RESPAWN & SEMUA VARIASI)
-- ====================================================================

-- [OPSI 1]: God Mode via Auto Heal (Membaca karakter secara dinamis di dalam loop)
Win:AddToggle("God Mode (Auto Heal)", false, function(state)
    GodModeHeal = state
    
    if GodModeHeal then
        task.spawn(function()
            while GodModeHeal do
                local char = LocalPlayer.Character
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                
                if humanoid and humanoid.Health > 0 then
                    humanoid.Health = humanoid.MaxHealth
                end
                task.wait() -- Loop super cepat per frame
            end
        end)
    end
end)

-- [OPSI 2]: God Mode via CanTouch (Otomatis mengunci CanTouch = false saat respawn)
Win:AddToggle("God Mode (Disable CanTouch)", false, function(state)
    GodModeCanTouch = state
    
    local function applyCanTouch(character)
        if not character then return end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanTouch = not GodModeCanTouch
            end
        end
    end

    -- Eksekusi ke karakter saat ini
    applyCanTouch(LocalPlayer.Character)
end)

-- Loop konstan khusus CanTouch agar bagian tubuh yang baru/respawn langsung terkunci CanTouch = false
task.spawn(function()
    while task.wait(0.5) do
        if GodModeCanTouch and LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanTouch == true then
                    part.CanTouch = false
                end
            end
        end
    end
end)

-- [OPSI 3]: God Mode via ForceField Bawaan Roblox
Win:AddButton("Beri ForceField Kebal", function()
    local char = LocalPlayer.Character
    if char and not char:FindFirstChildOfClass("ForceField") then
        local ff = Instance.new("ForceField")
        ff.Visible = true -- Ubah ke false jika ingin efek birunya hilang tapi tetap kebal
        ff.Parent = char
    end
end)

-- Otomatis memberikan ForceField kembali secara otomatis setelah mati/respawn
LocalPlayer.CharacterAdded:Connect(function(newChar)
    -- Jika tombol CanTouch sedang aktif saat respawn, langsung matikan CanTouch karakter baru
    if GodModeCanTouch then
        task.wait(0.2)
        for _, part in ipairs(newChar:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanTouch = false
            end
        end
    end
end)
