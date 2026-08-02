local RZY_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Window = RZY_Library:MakeWindow("+1 Banana Monkey")

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")

-- Variabel Global
getgenv().WallPunch = false
getgenv().AutoGrabThrow = false
getgenv().AutoCollect = false
getgenv().AutoTrain = false
getgenv().SelectedTiers = {} -- Diubah menjadi table untuk menampung multi-select
getgenv().Noclip = false
getgenv().AutoRun = false
getgenv().CombatActive = false 
getgenv().AntiShake = false
getgenv().PunchRadius = 20 

-- ==========================================
-- MENU 1: INPUT PENGATURAN & TIER SELECTION
-- ==========================================
Window:AddInput("Radius Hancur (Jarak)", "Default 20 stud...", function(value)
    local angka = tonumber(value)
    if angka then
        getgenv().PunchRadius = angka
    end
end)

-- Menggunakan AddMultiDropdown sesuai pembaruan library kamu
Window:AddMultiDropdown("Pilih Tier Training", {"Tier1A", "Tier1B", "Tier1C", "Tier2", "Tier3", "Tier4", "Tier5", "Tier6"}, function(selected)
    -- 'selected' me-return table e.g., {["Tier1A"] = true, ["Tier2"] = false}
    getgenv().SelectedTiers = selected 
end)

-- ==========================================
-- SISTEM SINKRONISASI (PUNCH + GRAB + THROW)
-- ==========================================
local function StartSynchronizedCombat()
    if getgenv().CombatActive then return end
    getgenv().CombatActive = true
    
    task.spawn(function()
        while getgenv().WallPunch or getgenv().AutoGrabThrow do
            task.wait(0.1) 
            
            pcall(function()
                local char = Players.LocalPlayer.Character
                if not char then return end
                
                local rootPart = char:FindFirstChild("HumanoidRootPart")
                if not rootPart then return end
                
                local rootPos = rootPart.Position
                local eventsFolder = RS:FindFirstChild("Shared") and RS.Shared:FindFirstChild("Events")
                if not eventsFolder then return end
                
                -- 1. PUKULAN (Fokus Argumen 1)
                if getgenv().WallPunch then
                    local punchRemote = eventsFolder:FindFirstChild("Destruction_Punch")
                    local mapFolder = workspace:FindFirstChild("Map")
                    local radius = getgenv().PunchRadius
                    
                    if punchRemote and mapFolder then
                        for _, part in ipairs(mapFolder:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide == true then
                                local distance = (part.Position - rootPos).Magnitude
                                if distance <= radius then
                                    punchRemote:FireServer(1, part.Position)
                                    break 
                                end
                            end
                        end
                    end
                end
                
                -- 2. GRAB & THROW
                if getgenv().AutoGrabThrow then
                    local grabRemote = eventsFolder:FindFirstChild("Chunk_Grab")
                    local throwRemote = eventsFolder:FindFirstChild("Chunk_Throw")
                    
                    if grabRemote and throwRemote then
                        local grabOffset = Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
                        local grabPos = rootPos + grabOffset
                        local randomDir = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
                        
                        grabRemote:FireServer(grabPos)
                        throwRemote:FireServer(rootPos, randomDir)
                    end
                end
                
            end)
        end
        getgenv().CombatActive = false
    end)
end

-- ==========================================
-- MENU 2: FITUR UTAMA GAMEPLAY
-- ==========================================
Window:AddToggle("Auto Train", false, function(state)
    getgenv().AutoTrain = state
    
    if state then
        task.spawn(function()
            while getgenv().AutoTrain do
                pcall(function()
                    local trainEvent = RS:FindFirstChild("Shared") and RS.Shared:FindFirstChild("Events") and RS.Shared.Events:FindFirstChild("Training_Punch")
                    local trainingArea = workspace:FindFirstChild("LobbyArea") and workspace.LobbyArea:FindFirstChild("TrainingArea")
                    
                    if trainEvent and trainingArea then
                        -- Looping semua opsi yang ada di dalam table SelectedTiers
                        for tierName, isSelected in pairs(getgenv().SelectedTiers) do
                            if isSelected then -- Jika tier tersebut di-ceklis (true)
                                local currentTier = trainingArea:FindFirstChild(tierName)
                                local zone = currentTier and currentTier:FindFirstChild("Zone")
                                
                                if zone then
                                    trainEvent:FireServer(zone)
                                end
                            end
                        end
                    end
                end)
                task.wait(0.04) -- Delay 0.1s
            end
        end)
    end
end)

Window:AddToggle("Punch Wall (Auto-Map)", false, function(state)
    getgenv().WallPunch = state
    if state then
        StartSynchronizedCombat()
    end
end)

Window:AddToggle("Auto Grab & Throw", false, function(state)
    getgenv().AutoGrabThrow = state
    if state then
        StartSynchronizedCombat()
    end
end)

Window:AddToggle("Auto Collect", false, function(state)
    getgenv().AutoCollect = state
    
    if state then
        task.spawn(function()
            while getgenv().AutoCollect do
                task.wait(0.5)
                pcall(function()
                    local eventsFolder = RS:FindFirstChild("Shared") and RS.Shared:FindFirstChild("Events")
                    local collectRemote = eventsFolder and eventsFolder:FindFirstChild("Collectable_Collect")
                    
                    if collectRemote then
                        for _, v in pairs(workspace:GetDescendants()) do
                            local idFromName = tonumber(v.Name)
                            if idFromName and idFromName > 100000 then
                                collectRemote:FireServer(idFromName)
                            end
                            
                            local idFromAttr = v:GetAttribute("ID") or v:GetAttribute("Id") or v:GetAttribute("id")
                            if idFromAttr and type(idFromAttr) == "number" then
                                collectRemote:FireServer(idFromAttr)
                            end

                            local intVal = v:FindFirstChildOfClass("IntValue") or v:FindFirstChildOfClass("NumberValue")
                            if intVal and intVal.Value > 100000 then
                                collectRemote:FireServer(intVal.Value)
                            end
                        end
                    end
                end)
            end
        end)
    end
end)

-- ==========================================
-- MENU 3: MOVEMENT & UTILITY
-- ==========================================
Window:AddToggle("Auto Run Random", false, function(state)
    getgenv().AutoRun = state
    
    if state then
        task.spawn(function()
            while getgenv().AutoRun do
                pcall(function()
                    local char = Players.LocalPlayer.Character
                    local hum = char and char:FindFirstChild("Humanoid")
                    local base = workspace:FindFirstChild("Base")
                    
                    if hum and base then
                        local sizeX = base.Size.X / 2.2 
                        local sizeZ = base.Size.Z / 2.2
                        local targetX = base.Position.X + math.random(-sizeX, sizeX)
                        local targetZ = base.Position.Z + math.random(-sizeZ, sizeZ)
                        
                        hum:MoveTo(Vector3.new(targetX, base.Position.Y + 3, targetZ))
                    end
                end)
                task.wait(2) 
            end
        end)
    end
end)

Window:AddToggle("Noclip + NoclipCam", false, function(state)
    getgenv().Noclip = state
    local lp = Players.LocalPlayer
    
    if state then
        pcall(function() lp.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam end)
        
        getgenv().NoclipConnection = RunService.Stepped:Connect(function()
            if getgenv().Noclip then
                pcall(function()
                    local char = lp.Character
                    if char then
                        for _, v in pairs(char:GetDescendants()) do
                            if v:IsA("BasePart") and v.CanCollide then
                                v.CanCollide = false
                            end
                        end
                    end
                end)
            end
        end)
    else
        pcall(function() lp.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom end)
        
        if getgenv().NoclipConnection then
            getgenv().NoclipConnection:Disconnect()
            getgenv().NoclipConnection = nil
        end
    end
end)

Window:AddToggle("Anti-AFK", false, function(state)
    if state then
        getgenv().AntiAFK = Players.LocalPlayer.Idled:Connect(function()
            pcall(function()
                VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end)
    else
        if getgenv().AntiAFK then
            getgenv().AntiAFK:Disconnect()
            getgenv().AntiAFK = nil
        end
    end
end)

-- ==========================================
-- MENU 4: VISUAL & PERFORMA
-- ==========================================
Window:AddToggle("Anti-Shake (Fix Loop)", false, function(state)
    getgenv().AntiShake = state
    
    if state then
        getgenv().ShakeConn = RunService.RenderStepped:Connect(function()
            pcall(function()
                local char = Players.LocalPlayer.Character
                local hum = char and char:FindFirstChild("Humanoid")
                if hum then
                    hum.CameraOffset = Vector3.new(0, 0, 0)
                end
            end)
        end)
        
        pcall(function()
            for _, script in pairs(Players.LocalPlayer.PlayerScripts:GetDescendants()) do
                if script:IsA("LocalScript") and string.find(string.lower(script.Name), "shake") then
                    script.Disabled = true
                end
            end
        end)

        getgenv().DebrisConn = workspace.DescendantAdded:Connect(function(v)
            if getgenv().AntiShake then
                task.wait() 
                pcall(function()
                    if v:IsA("BasePart") and not v.Anchored then
                        v.CanCollide = false
                        v.Massless = true
                    end
                end)
            end
        end)
    else
        if getgenv().ShakeConn then getgenv().ShakeConn:Disconnect() end
        if getgenv().DebrisConn then getgenv().DebrisConn:Disconnect() end
        
        pcall(function()
            for _, script in pairs(Players.LocalPlayer.PlayerScripts:GetDescendants()) do
                if script:IsA("LocalScript") and string.find(string.lower(script.Name), "shake") then
                    script.Disabled = false
                end
            end
        end)
    end
end)

Window:AddToggle("No Fog", false, function(state)
    pcall(function()
        if state then
            getgenv().OriFog = Lighting.FogEnd
            Lighting.FogEnd = 100000
            if Lighting:FindFirstChildOfClass("Atmosphere") then
                Lighting:FindFirstChildOfClass("Atmosphere").Density = 0
            end
        else
            Lighting.FogEnd = getgenv().OriFog or 10000
            if Lighting:FindFirstChildOfClass("Atmosphere") then
                Lighting:FindFirstChildOfClass("Atmosphere").Density = 0.3
            end
        end
    end)
end)

Window:AddButton("Anti-Lag (FPS Boost)", function()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.ShadowSoftness = 0
        
        for _, e in pairs(Lighting:GetChildren()) do
            if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
                e.Enabled = false
            end
        end
        
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Lifetime = NumberRange.new(0)
            elseif v:IsA("Explosion") then
                v.BlastPressure = 1
                v.BlastRadius = 1
            end
        end
    end)
end)
