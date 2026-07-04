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
local skillTreePurchase = verdantRemotes:WaitForChild("VDT_SkillTree.Purchase") -- Remote Upgrade

-- Global Toggle Status
getgenv().AutoDrain = false
getgenv().AutoStor  = false
getgenv().AutoToken = false
getgenv().AutoChest = false
getgenv().AutoUpgrade = false -- Toggle untuk Auto Upgrade

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
        if getgenv().AutoDrain and not isFull then
            useBucket:FireServer()
        end

        local scriptedFolder = Workspace:FindFirstChild("Scripted")
        if scriptedFolder then
            
            -- 3. AUTO CHEST
            if getgenv().AutoChest then
                local chestsFolder = scriptedFolder:FindFirstChild("Chests")
                if chestsFolder then
                    for _, prompt in ipairs(chestsFolder:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                            pcall(function()
                                fireproximityprompt(prompt)
                            end)
                        end
                    end
                end
            end

            -- Mengumpulkan target spesifik folder "Drain" sesuai screenshot
            local targetDrains = {}
            for _, obj in ipairs(scriptedFolder:GetChildren()) do
                if obj.Name == "Drain" then
                    table.insert(targetDrains, obj)
                end
            end
            
            local checkpointParts = scriptedFolder:FindFirstChild("CheckpointParts")
            if checkpointParts then
                local cp1 = checkpointParts:FindFirstChild("1")
                if cp1 then
                    for _, obj in ipairs(cp1:GetChildren()) do
                        if obj.Name == "Drain" then
                            table.insert(targetDrains, obj)
                        end
                    end
                end
            end

            -- 4 & 5. AUTO STOR & AUTO TOKEN
            for _, drainObj in ipairs(targetDrains) do
                local scripted = drainObj:FindFirstChild("Scripted")
                if scripted then
                    local mainPrompt = scripted:FindFirstChild("ProximityPosition")
                        and scripted.ProximityPosition:FindFirstChild("ProximityPrompt")
                        
                    local visualTokenPrompt = scripted:FindFirstChild("TakeTokens")
                        and scripted.TakeTokens:FindFirstChild("ProximityPrompt")

                    if getgenv().AutoStor and isFull and mainPrompt then
                        pourBucket:FireServer(mainPrompt)
                    end
                    
                    if getgenv().AutoToken then
                        if mainPrompt then
                            takeToken:FireServer(mainPrompt)
                        end
                        if visualTokenPrompt and visualTokenPrompt.Enabled then
                            pcall(function()
                                fireproximityprompt(visualTokenPrompt)
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- AUTO UPGRADE LOOP (Penyebaran dari Tengah 0,0 ke Luar)
task.spawn(function()
    local upgradeCategories = {"buckets", "root", "diamonds"} 
    
    -- 1. Membuat daftar semua kemungkinan koordinat dari -10 sampai 10
    local coords = {}
    for x = -10, 10 do
        for y = -10, 10 do
            table.insert(coords, {x, y})
        end
    end
    
    -- 2. MENGURUTKAN DAFTAR: Memastikan dimulai dari (0,0) menyebar ke luar
    table.sort(coords, function(a, b)
        -- Menghitung jarak dari (0,0)
        local distA = math.abs(a[1]) + math.abs(a[2])
        local distB = math.abs(b[1]) + math.abs(b[2])
        return distA < distB -- Yang paling dekat dengan 0,0 akan dieksekusi pertama
    end)

    while task.wait(2) do
        if getgenv().AutoUpgrade then
            for _, category in ipairs(upgradeCategories) do
                if not getgenv().AutoUpgrade then break end
                
                -- Mengeksekusi dari (0,0) menyebar berurutan berkat fungsi sort di atas
                for _, coord in ipairs(coords) do
                    if not getgenv().AutoUpgrade then break end
                    
                    local x, y = coord[1], coord[2]
                    
                    task.spawn(function()
                        pcall(function()
                            skillTreePurchase:InvokeServer(category, x, y)
                        end)
                    end)
                    
                    -- Jeda super singkat 0.01 detik agar tidak menyebabkan game lag
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
