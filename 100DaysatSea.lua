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
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Pastikan variabel TargetMaterials sudah didefinisikan sebelumnya di script utamamu
-- local TargetMaterials = { ["Metal Scrap"] = true, ["Wood"] = true } 

Win:AddToggle("Mulai Auto Grinder", false, function(state)
    AutoGrinderEnabled = state
    
    if AutoGrinderEnabled then
        task.spawn(function()
            while AutoGrinderEnabled do
                local workspace = game:GetService("Workspace")
                local DebrisField = workspace:FindFirstChild("DebrisField")
                
                -- Target tujuan
                local GrinderCol = workspace:FindFirstChild("SpawnIsland") and workspace.SpawnIsland:FindFirstChild("Grinder") and workspace.SpawnIsland.Grinder:FindFirstChild("Collection")
                local CraftingTable = workspace:FindFirstChild("SpawnIsland") and workspace.SpawnIsland:FindFirstChild("CraftingTable") and workspace.SpawnIsland.CraftingTable:FindFirstChild("CraftingBrick")

                if DebrisField and GrinderCol and CraftingTable then
                    for _, obj in ipairs(DebrisField:GetChildren()) do
                        local resType = obj:GetAttribute("Resource")
                        
                        -- Filter tipe material
                        if resType and TargetMaterials[resType] then
                            
                            -- [DETEKSI KETAT]: Jika sedang dipegang (Grabbed attr atau ada object "Drag")
                            if obj:GetAttribute("Grabbed") == true or obj:FindFirstChild("Drag") then
                                continue 
                            end

                            local primary = obj:IsA("Model") and obj.PrimaryPart or (obj:IsA("BasePart") and obj)
                            
                            if primary then
                                local distance = (primary.Position - GrinderCol.Position).Magnitude
                                
                                -- Jarak 3 stud
                                if distance > 3 then
                                    local isPriority = (obj:GetAttribute("Grabber") ~= nil and obj:GetAttribute("LastHolder") ~= nil)
                                    
                                    -- Tentukan target posisi
                                    local targetCFrame = isPriority and GrinderCol.CFrame or CraftingTable.CFrame

                                    -- Eksekusi TP
                                    if obj:IsA("BasePart") then
                                        obj.CFrame = targetCFrame
                                    elseif obj:IsA("Model") then
                                        obj:PivotTo(targetCFrame)
                                    end
                                    
                                    -- Reset velocity agar tidak mantul
                                    if obj:IsA("BasePart") then
                                        obj.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(0.1) -- Jeda santai
            end
        end)
    end
end)
