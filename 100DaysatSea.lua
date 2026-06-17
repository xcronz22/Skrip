-- Memuat Library RZY
local RZY_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()

-- Membuat Window Utama
local Win = RZY_Library:MakeWindow("100 Days at Sea - V3")

local AutoGrinderEnabled = false

Win:AddToggle("Auto Grinder (Smart Drop)", false, function(state)
    AutoGrinderEnabled = state
    local workspace = game:GetService("Workspace")
    
    -- [FITUR BARU] Bersihkan invisible wall jika sebelumnya sudah ada (saat toggle dimatikan/dinyalakan ulang)
    local existingWalls = workspace:FindFirstChild("RZY_InvisWalls")
    if existingWalls then
        existingWalls:Destroy()
    end

    if AutoGrinderEnabled then
        -- Cari part Collection untuk membuat dinding di sekitarnya
        local SpawnIsland = workspace:WaitForChild("SpawnIsland", 5)
        local GrinderPart = SpawnIsland and SpawnIsland:FindFirstChild("Grinder") and SpawnIsland.Grinder:FindFirstChild("Collection")

        if GrinderPart then
            -- Membuat Folder khusus untuk menyimpan dinding invisible
            local wallFolder = Instance.new("Folder")
            wallFolder.Name = "RZY_InvisWalls"
            wallFolder.Parent = workspace

            -- Fungsi pembantu untuk membuat part dinding
            local function createWall(size, offset)
                local wall = Instance.new("Part")
                wall.Size = size
                wall.CFrame = GrinderPart.CFrame * offset
                wall.Anchored = true
                wall.Transparency = 0.5 -- Set ke 0 atau 0.5 jika kamu ingin melihat wujud dindingnya saat testing
                wall.CanCollide = true
                wall.Parent = wallFolder
            end

            -- Membuat kotak/corong setinggi 12 stud, luas area dalam 6x6 stud
            createWall(Vector3.new(1, 12, 6), CFrame.new(-3, 6, 0)) -- Dinding Kiri
            createWall(Vector3.new(1, 12, 6), CFrame.new(3, 6, 0))  -- Dinding Kanan
            createWall(Vector3.new(6, 12, 1), CFrame.new(0, 6, -3)) -- Dinding Depan
            createWall(Vector3.new(6, 12, 1), CFrame.new(0, 6, 3))  -- Dinding Belakang
            createWall(Vector3.new(7, 1, 7), CFrame.new(0, 12, 0))  -- Atap (Mencegah material mental ke atas)
        end

        task.spawn(function()
            while AutoGrinderEnabled do
                local DebrisField = workspace:FindFirstChild("DebrisField")
                local currentGrinder = workspace:FindFirstChild("SpawnIsland") 
                    and workspace.SpawnIsland:FindFirstChild("Grinder") 
                    and workspace.SpawnIsland.Grinder:FindFirstChild("Collection")

                if DebrisField and currentGrinder then
                    -- Titik drop: di dalam ruang dinding invisible, agak ke atas agar ada ruang jatuh
                    local dropCenter = currentGrinder.CFrame * CFrame.new(0, 8, 0)
                    
                    for _, obj in ipairs(DebrisField:GetChildren()) do
                        local resType = obj:GetAttribute("Resource")
                        
                        if resType == "Wood" or resType == "Metal" or resType == "Goo" then
                            local primary = obj:IsA("Model") and obj.PrimaryPart or (obj:IsA("BasePart") and obj)
                            
                            if primary then
                                if (primary.Position - currentGrinder.Position).Magnitude > 12 then
                                    
                                    local heightOffset = math.random() * 2 
                                    local finalCFrame = dropCenter * CFrame.new(0, heightOffset, 0)
                                    
                                    if obj:IsA("BasePart") then
                                        obj.CFrame = finalCFrame
                                        -- Menghapus dorongan ke bawah. Cukup nol-kan fisika sebelumnya agar jatuh natural oleh gravitasi
                                        obj.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                        obj.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                                    elseif obj:IsA("Model") then
                                        obj:PivotTo(finalCFrame)
                                        for _, part in ipairs(obj:GetDescendants()) do
                                            if part:IsA("BasePart") then
                                                -- Menghapus dorongan ke bawah
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
