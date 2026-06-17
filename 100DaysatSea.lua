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
-- [FITUR 3]: ADVANCED GOD MODE (BYPASS SERVER-SIDE)
-- ====================================================================

local RunService = game:GetService("RunService")
local DesyncEnabled = false
local FakeRoot = nil

-- [NEW OPSI 1]: Matikan Script Damage/Survival Bawaan Game
Win:AddButton("Matikan Script Damage/Survival Game", function()
    local char = LocalPlayer.Character
    local playerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
    
    -- Daftar nama script yang biasanya mengatur damage/survival di game
    -- Kamu bisa cek nama script aslinya via Dex Explorer jika namanya berbeda
    local targetScripts = {"Health", "Survival", "Damage", "Hunger", "Thirst", "Oxygen", "EnvironmentDamage"}
    
    -- Cari di dalam Karakter
    if char then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("LocalScript") then
                for _, name in ipairs(targetScripts) do
                    if string.find(string.lower(v.Name), string.lower(name)) then
                        v.Disabled = true
                        print("Berhasil mematikan script karakter: " .. v.Name)
                    end
                end
            end
        end
    end
    
    -- Cari di dalam PlayerScripts
    if playerScripts then
        for _, v in ipairs(playerScripts:GetDescendants()) do
            if v:IsA("LocalScript") then
                for _, name in ipairs(targetScripts) do
                    if string.find(string.lower(v.Name), string.lower(name)) then
                        v.Disabled = true
                        print("Berhasil mematikan script player: " .. v.Name)
                    end
                end
            end
        end
    end
end)

-- [NEW OPSI 2]: Desync Hitbox God Mode (Memisahkan Tubuh dari Hitbox)
Win:AddToggle("Desync Hitbox (God Mode)", false, function(state)
    DesyncEnabled = state
    local char = LocalPlayer.Character
    local root = char UltraFindFirstChild("HumanoidRootPart")
    
    if DesyncEnabled and char and root then
        task.spawn(function()
            -- Membuat tiruan posisi aman di langit agar tidak terkena hit server
            root.Anchored = true
            local originalCFrame = root.CFrame
            root.CFrame = originalCFrame * CFrame.new(0, 500, 0) -- Lempar hitbox asli ke langit 500 stud
            
            while DesyncEnabled do
                -- Memaksa bagian tubuh visual tetap bisa digerakkan di bawah olehmu
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    end
                end
                RunService.RenderStepped:Wait()
            end
            
            -- Jika dimatikan, kembalikan hitbox ke tubuh
            root.Anchored = false
            root.CFrame = originalCFrame
        end)
    else
        if root then root.Anchored = false end
    end
end)

-- [NEW OPSI 3]: Mencegah Kematian via Reset State (State Bypass)
Win:AddButton("Bypass Humanoid State", function()
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    
    if humanoid then
        -- Mematikan paksa beberapa kondisi status yang memicu kematian/damage bawaan engine
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        print("Humanoid State Berhasil di-Bypass!")
    end
end)
