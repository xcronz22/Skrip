-- Tunggu sampai game sepenuhnya termuat
repeat task.wait() until game:IsLoaded()

-- Variables Setup
local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Define Remotes
local verdantRemotes = RS:WaitForChild("VerdantRemotes")
local useBucket = verdantRemotes:WaitForChild("VDT_Bucket.Used")
local pourBucket = verdantRemotes:WaitForChild("VDT_Bucket.Poured")
local takeToken = verdantRemotes:WaitForChild("VDT_Tokens.Take")
local openChest = verdantRemotes:WaitForChild("VDT_Chest.Open") -- Menambahkan remote Chest
local skillTreePurchase = verdantRemotes:WaitForChild("VDT_SkillTree.Purchase")

-- Global Toggle Status
getgenv().AutoFarm  = false -- MASTER TOGGLE
getgenv().AutoDrain = false
getgenv().AutoStor  = false
getgenv().AutoToken = false
getgenv().AutoChest = false
getgenv().AutoUpgrade = false

-- MAIN LOOP: 0.1 Detik (Untuk Farming)
task.spawn(function()
    while task.wait(0.1) do
        
        -- 1. Cek Status Bucket
        local isFull = false
        pcall(function()
            if LocalPlayer.PlayerGui.Interface.Holder.BucketFill.Bar.Progress.Text == "100% Full" then
                isFull = true
            end
        end)

        -- 2. AUTO DRAIN
        if (getgenv().AutoDrain or getgenv().AutoFarm) and not isFull then
            useBucket:FireServer()
        end

        local scriptedFolder = Workspace:FindFirstChild("Scripted")
        if scriptedFolder then
            
            -- 3. AUTO CHEST (Diperbarui menggunakan Remote Server & Pencarian Dinamis)
            if (getgenv().AutoChest or getgenv().AutoFarm) then
                local chestsFolder = scriptedFolder:FindFirstChild("Chests")
                if chestsFolder then
                    -- Looping ke semua Chest yang ada di dalam folder Chests
                    for _, chestObj in ipairs(chestsFolder:GetChildren()) do
                        local chestPart = chestObj:FindFirstChild("Part")
                        if chestPart then
                            pcall(function()
                                openChest:FireServer(chestPart)
                            end)
                        end
                    end
                end
            end

            -- 4. PENCARIAN DRAIN DINAMIS (Fleksibel untuk semua Checkpoint)
            local targetPrompts = {}
            
            -- A. Mengambil Prompt dari Drain yang ada di area awal (workspace.Scripted.Drain)
            local mainDrain = scriptedFolder:FindFirstChild("Drain")
            if mainDrain and mainDrain:FindFirstChild("Scripted") and mainDrain.Scripted:FindFirstChild("ProximityPosition") then
                local prompt = mainDrain.Scripted.ProximityPosition:FindFirstChild("ProximityPrompt")
                if prompt then table.insert(targetPrompts, prompt) end
            end
            
            -- B. Mengambil Prompt dari SEMUA Checkpoint yang terbuka (1, 2, 3, dst.)
            local checkpointParts = scriptedFolder:FindFirstChild("CheckpointParts")
            if checkpointParts then
                for _, cp in ipairs(checkpointParts:GetChildren()) do
                    local cpDrain = cp:FindFirstChild("Drain")
                    if cpDrain and cpDrain:FindFirstChild("Scripted") and cpDrain.Scripted:FindFirstChild("ProximityPosition") then
                        local prompt = cpDrain.Scripted.ProximityPosition:FindFirstChild("ProximityPrompt")
                        if prompt then table.insert(targetPrompts, prompt) end
                    end
                end
            end

            -- 5. AUTO STOR & AUTO TOKEN (Mengeksekusi semua target yang ditemukan)
            for _, prompt in ipairs(targetPrompts) do
                -- AUTO STOR
                if (getgenv().AutoStor or getgenv().AutoFarm) and isFull then
                    pcall(function()
                        pourBucket:FireServer(prompt)
                    end)
                end
                
                -- AUTO TOKEN
                if (getgenv().AutoToken or getgenv().AutoFarm) then
                    pcall(function()
                        takeToken:FireServer(prompt)
                    end)
                end
            end
        end
    end
end)

-- AUTO UPGRADE LOOP (Penyebaran dari Tengah 0,0 ke Luar)
task.spawn(function()
    local upgradeCategories = {"buckets", "root", "diamonds", "character"} 
    
    local coords = {}
    for x = -10, 10 do
        for y = -10, 10 do
            table.insert(coords, {x, y})
        end
    end
    
    table.sort(coords, function(a, b)
        local distA = math.abs(a[1]) + math.abs(a[2])
        local distB = math.abs(b[1]) + math.abs(b[2])
        return distA < distB
    end)

    while task.wait(2) do
        if (getgenv().AutoUpgrade or getgenv().AutoFarm) then
            for _, category in ipairs(upgradeCategories) do
                if not (getgenv().AutoUpgrade or getgenv().AutoFarm) then break end
                
                for _, coord in ipairs(coords) do
                    if not (getgenv().AutoUpgrade or getgenv().AutoFarm) then break end
                    
                    local x, y = coord[1], coord[2]
                    
                    task.spawn(function()
                        pcall(function()
                            skillTreePurchase:InvokeServer(category, x, y)
                        end)
                    end)
                    
                    task.wait(0.01) 
                end
            end
        end
    end
end)

------------------------------------------
-- UI SETUP MENGGUNAKAN RZY LIBRARY
------------------------------------------
local success, Library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
end)

if success and Library then
    local Window = Library:MakeWindow("Drain The Lake")
    
    -- TOMBOL MASTER
    Window:AddToggle("Auto Farm (All-In-One)", false, function(Value)
        getgenv().AutoFarm = Value
    end)

    -- TOMBOL INDIVIDUAL
    Window:AddToggle("Auto Drain", false, function(Value)
        getgenv().AutoDrain = Value
    end)

    Window:AddToggle("Auto Stor", false, function(Value)
        getgenv().AutoStor = Value
    end)

    Window:AddToggle("Auto Token", false, function(Value)
        getgenv().AutoToken = Value
    end)
    
    Window:AddToggle("Auto Chest", false, function(Value)
        getgenv().AutoChest = Value
    end)

    Window:AddToggle("Auto Upgrade", false, function(Value)
        getgenv().AutoUpgrade = Value
    end)
else
    warn("UI Gagal Dimuat! Pastikan link github RZY_Library valid.")
end
