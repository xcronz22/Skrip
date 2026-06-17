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
                    local itemsToProcess = {}
                    
                    -- 1. Kumpulkan material dan filter jarak
                    for _, obj in ipairs(DebrisField:GetChildren()) do
                        local resType = obj:GetAttribute("Resource")
                        
                        if resType and TargetMaterials[resType] then
                            
                            -- [BLOKIR MUTLAK]: Jika sedang dipegang (Grabbed = true), lewati!
                            if obj:GetAttribute("Grabbed") == true then
                                continue 
                            end

                            local primary = obj:IsA("Model") and obj.PrimaryPart or (obj:IsA("BasePart") and obj)
                            
                            if primary then
                                local distance = (primary.Position - currentGrinder.Position).Magnitude
                                
                                -- Jarak sangat dekat, ditarik jika jaraknya lebih dari 3 stud dari tengah mesin
                                if distance > 3 then
                                    local grabberAttr = obj:GetAttribute("Grabber")
                                    local lastHolderAttr = obj:GetAttribute("LastHolder")
                                    
                                    -- Tentukan Kategori saat ini
                                    local category = 2 
                                    if grabberAttr ~= nil and lastHolderAttr ~= nil then
                                        category = 1 -- Kategori 1 (Prioritas Utama)
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

                    -- 2. Alur Baru: Urutkan murni berdasarkan Jarak Terdekat dulu
                    table.sort(itemsToProcess, function(a, b)
                        return a.Distance < b.Distance 
                    end)

                    -- 3. Eksekusi Teleportasi berdasarkan Kategori
                    for _, data in ipairs(itemsToProcess) do
                        local obj = data.Object
                        
                        -- Penentuan Posisi berdasarkan Kategori
                        local targetCFrame
                        if data.Category == 1 then
                            -- Kategori 1: Langsung masuk di titik tengah mesin
                            targetCFrame = currentGrinder.CFrame 
                        else
                            -- Kategori 2: Posisi di atas mesin (jarak 2.5 stud)
                            targetCFrame = currentGrinder.CFrame * CFrame.new(0, 2.5, 0)
                        end

                        if obj:IsA("BasePart") then
                            obj.CFrame = targetCFrame
                            obj.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            obj.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                        elseif obj:IsA("Model") then
                            obj:PivotTo(targetCFrame)
                            for _, part in ipairs(obj:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                    part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                                end
                            end
                        end
                    end
                end
                
                -- Jeda lebih santai (10 kali cek per detik) sangat aman untuk performa dan tidak akan ngadat
                task.wait(0.1) 
            end
        end)
    end
end)
