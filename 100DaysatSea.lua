-- Memuat Library RZY
local RZY_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()

-- Membuat Window Utama
local Win = RZY_Library:MakeWindow("100 Days at Sea - V3")

local AutoGrinderEnabled = false

Win:AddToggle("Auto Grinder (Smart Drop)", false, function(state)
    AutoGrinderEnabled = state
    
    if AutoGrinderEnabled then
        task.spawn(function()
            while AutoGrinderEnabled do
                local workspace = game:GetService("Workspace")
                local DebrisField = workspace:FindFirstChild("DebrisField")
                local GrinderPart = workspace:FindFirstChild("SpawnIsland") 
                    and workspace.SpawnIsland:FindFirstChild("Grinder") 
                    and workspace.SpawnIsland.Grinder:FindFirstChild("Collection")

                if DebrisField and GrinderPart then
                    -- Titik pusat jatuh: 4 stud tepat di atas Collection box
                    local dropCenter = GrinderPart.CFrame * CFrame.new(0, 4, 0)
                    
                    for _, obj in ipairs(DebrisField:GetChildren()) do
                        local resType = obj:GetAttribute("Resource")
                        
                        -- Cek apakah item adalah material yang kita inginkan
                        if resType == "Wood" or resType == "Metal" or resType == "Goo" then
                            local primary = obj:IsA("Model") and obj.PrimaryPart or (obj:IsA("BasePart") and obj)
                            
                            if primary then
                                -- Cek Jarak: Hanya tarik item yang jaraknya lebih dari 12 stud dari Grinder
                                -- Jika sudah di dalam/dekat grinder, biarkan game memprosesnya
                                if (primary.Position - GrinderPart.Position).Magnitude > 12 then
                                    
                                    -- Efek Pasir: Beri variasi ketinggian acak (0 sampai 3 stud ke atas)
                                    -- Agar item tidak bertabrakan dan meledak di satu titik
                                    local heightOffset = math.random() * 3 
                                    local finalCFrame = dropCenter * CFrame.new(0, heightOffset, 0)
                                    
                                    if obj:IsA("BasePart") then
                                        obj.CFrame = finalCFrame
                                        -- Beri dorongan ringan ke bawah agar langsung jatuh rapi
                                        obj.AssemblyLinearVelocity = Vector3.new(0, -15, 0)
                                        obj.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                                    elseif obj:IsA("Model") then
                                        obj:PivotTo(finalCFrame)
                                        for _, part in ipairs(obj:GetDescendants()) do
                                            if part:IsA("BasePart") then
                                                part.AssemblyLinearVelocity = Vector3.new(0, -15, 0)
                                                part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                                            end
                                        end
                                    end
                                    
                                end
                            end
                        end
                    end
                end
                
                -- Jeda sangat singkat agar ultra-responsif tapi tidak bikin CPU lag
                task.wait(0.05) 
            end
        end)
    end
end)
