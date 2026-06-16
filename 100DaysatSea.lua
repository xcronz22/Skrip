-- Memuat Library RZY
local RZY_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()

-- Membuat Window Utama
local Win = RZY_Library:MakeWindow("100 Days at Sea - V4")

local AutoGrinderEnabled = false

Win:AddToggle("Auto Grinder V4 (Natural)", false, function(state)
    AutoGrinderEnabled = state
    
    if AutoGrinderEnabled then
        task.spawn(function()
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            
            while AutoGrinderEnabled do
                local workspace = game:GetService("Workspace")
                local DebrisField = workspace:FindFirstChild("DebrisField")
                local GrinderPart = workspace:FindFirstChild("SpawnIsland") 
                    and workspace.SpawnIsland:FindFirstChild("Grinder") 
                    and workspace.SpawnIsland.Grinder:FindFirstChild("Collection")

                if DebrisField and GrinderPart then
                    -- Titik Jatuh: Tepat di tengah-tengah (X, Z) koordinat Grinder, dinaikkan 2.5 stud (Y)
                    local dropTargetCFrame = CFrame.new(GrinderPart.Position + Vector3.new(0, 2.5, 0))
                    
                    for _, obj in ipairs(DebrisField:GetChildren()) do
                        local resType = obj:GetAttribute("Resource")
                        
                        -- Deteksi material Wood, Metal, dan Goo
                        if resType == "Wood" or resType == "Metal" or resType == "Goo" then
                            local primary = obj:IsA("Model") and obj.PrimaryPart or (obj:IsA("BasePart") and obj)
                            
                            if primary then
                                -- Jarak aman: jika objek berada di luar radius 6 stud dari gilingan, langsung tarik
                                if (primary.Position - GrinderPart.Position).Magnitude > 6 then
                                    
                                    -- Eksekusi Teleportasi
                                    if obj:IsA("BasePart") then
                                        -- Reset kecepatan bawaan air agar tidak mental kesamping
                                        obj.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                        obj.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                                        obj.CFrame = dropTargetCFrame
                                        
                                        -- Paksa Fisika dan Gravitasi aktif seketika di Client kita
                                        pcall(function()
                                            if obj.CanCollide == false then obj.CanCollide = true end
                                            obj:SetNetworkOwner(LocalPlayer)
                                        end)
                                        
                                    elseif obj:IsA("Model") then
                                        obj:PivotTo(dropTargetCFrame)
                                        
                                        for _, part in ipairs(obj:GetDescendants()) do
                                            if part:IsA("BasePart") then
                                                part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                                part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                                                
                                                pcall(function()
                                                    if part.CanCollide == false then part.CanCollide = true end
                                                    part:SetNetworkOwner(LocalPlayer)
                                                end)
                                            end
                                        end
                                    end
                                    
                                end
                            end
                        end
                    end
                end
                
                -- Kecepatan ultra responsif (0.05 detik) untuk mendeteksi material baru tanpa jeda
                task.wait(0.05) 
            end
        end)
    end
end)
