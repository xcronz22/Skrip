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
                    
                    -- 1. Kumpulkan semua material yang valid
                    for _, obj in ipairs(DebrisField:GetChildren()) do
                        local resType = obj:GetAttribute("Resource")
                        
                        -- Cek apakah tipe material dicentang di UI
                        if resType and TargetMaterials[resType] then
                            local primary = obj:IsA("Model") and obj.PrimaryPart or (obj:IsA("BasePart") and obj)
                            
                            if primary then
                                local distance = (primary.Position - currentGrinder.Position).Magnitude
                                if distance > 12 then
                                    table.insert(itemsToProcess, {
                                        Object = obj,
                                        Distance = distance,
                                        Grabbed = obj:GetAttribute("Grabbed"),
                                        Grabber = obj:GetAttribute("Grabber"),
                                        LastHolder = obj:GetAttribute("LastHolder")
                                    })
                                end
                            end
                        end
                    end

                    -- 2. Urutkan berdasarkan Prioritas dan Jarak Terdekat
                    table.sort(itemsToProcess, function(a, b)
                        -- KONDISI PRIORITAS UTAMA: Grabbed kosong/false, TAPI Grabber & LastHolder ada isinya
                        local aIsPriority = (a.Grabbed == nil or a.Grabbed == false) and (a.Grabber ~= nil) and (a.LastHolder ~= nil)
                        local bIsPriority = (b.Grabbed == nil or b.Grabbed == false) and (b.Grabber ~= nil) and (b.LastHolder ~= nil)

                        if aIsPriority ~= bIsPriority then
                            return aIsPriority -- Utamakan yang Prioritas Utama (true)
                        else
                            return a.Distance < b.Distance -- Jika prioritasnya sama, tarik yang paling dekat dulu
                        end
                    end)

                    -- 3. Eksekusi Teleportasi
                    for _, data in ipairs(itemsToProcess) do
                        local obj = data.Object
                        local isPriority = (data.Grabbed == nil or data.Grabbed == false) and (data.Grabber ~= nil) and (data.LastHolder ~= nil)
                        
                        -- Penentuan Titik Drop berdasarkan Prioritas
                        local targetCFrame
                        if isPriority then
                            -- Prioritas Utama: TP pas di tengah penggiling
                            targetCFrame = currentGrinder.CFrame 
                        else
                            -- Prioritas Kedua (selain di atas): TP sedikit lebih tinggi agar tidak aneh (1.2 stud di atasnya)
                            targetCFrame = currentGrinder.CFrame * CFrame.new(0, 1.2, 0)
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
                
                -- Jeda pemrosesan
                task.wait(0.05) 
            end
        end)
    end
end)
