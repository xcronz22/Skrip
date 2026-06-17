-- Memuat Library RZY (Pastikan link github sudah yang terbaru)
local RZY_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Win = RZY_Library:MakeWindow("100 Days at Sea - V4")

-- Default status material (semua mati)
local TargetMaterials = {
    ["Wood"] = false,
    ["Metal"] = false,
    ["Goo"] = false
}

-- Menambahkan Dropdown Centang Ganda
Win:AddMultiDropdown("Pilih Material (Bisa >1)", {"Wood", "Metal", "Goo"}, function(selectedTable)
    -- Update tabel material target sesuai dengan pilihan di UI
    TargetMaterials = selectedTable
end)

local AutoGrinderEnabled = false

Win:AddToggle("Mulai Auto Grinder", false, function(state)
    AutoGrinderEnabled = state
    
    if AutoGrinderEnabled then
        task.spawn(function()
            while AutoGrinderEnabled do
                local workspace = game:GetService("Workspace")
                local DebrisField = workspace:FindFirstChild("DebrisField")
                local currentGrinder = workspace:FindFirstChild("SpawnIsland") 
                    and workspace.SpawnIsland:FindFirstChild("Grinder") 
                    and workspace.SpawnIsland.Grinder:FindFirstChild("Collection")

                if DebrisField and currentGrinder then
                    for _, obj in ipairs(DebrisField:GetChildren()) do
                        local resType = obj:GetAttribute("Resource")
                        
                        -- Cek apakah tipe resource tersebut statusnya true (dicentang di UI)
                        if resType and TargetMaterials[resType] then
                            local primary = obj:IsA("Model") and obj.PrimaryPart or (obj:IsA("BasePart") and obj)
                            
                            if primary then
                                if (primary.Position - currentGrinder.Position).Magnitude > 12 then
                                    if obj:IsA("BasePart") then
                                        obj.CFrame = currentGrinder.CFrame
                                        obj.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                        obj.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                                    elseif obj:IsA("Model") then
                                        obj:PivotTo(currentGrinder.CFrame)
                                        for _, part in ipairs(obj:GetDescendants()) do
                                            if part:IsA("BasePart") then
                                                part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                                part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                                            end
                                        end
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
