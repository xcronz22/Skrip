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
            
            -- Ambil Drain yang ada di luar (workspace.Scripted.Drain)
            for _, obj in ipairs(scriptedFolder:GetChildren()) do
                if obj.Name == "Drain" then
                    table.insert(targetDrains, obj)
                end
            end
            
            -- Ambil Drain yang ada di dalam CheckpointParts["1"]
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
                    
                    -- Prompt utama untuk argumen remote (Diambil dari ProximityPosition)
                    local mainPrompt = scripted:FindFirstChild("ProximityPosition")
                        and scripted.ProximityPosition:FindFirstChild("ProximityPrompt")
                        
                    -- Prompt visual untuk pencairan manual (Diambil dari TakeTokens)
                    local visualTokenPrompt = scripted:FindFirstChild("TakeTokens")
                        and scripted.TakeTokens:FindFirstChild("ProximityPrompt")

                    -- AUTO STOR
                    if getgenv().AutoStor and isFull and mainPrompt then
                        pourBucket:FireServer(mainPrompt)
                    end
                    
                    -- AUTO TOKEN
                    if getgenv().AutoToken then
                        -- Tembak Remote menggunakan mainPrompt (Sesuai script asli Anda)
                        if mainPrompt then
                            takeToken:FireServer(mainPrompt)
                        end
                        
                        -- Backup: Tembak prompt visual TakeTokens secara paksa
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

-- AUTO UPGRADE LOOP (Terpisah dari loop utama)
task.spawn(function()
    -- Kategori berdasarkan remote yang kamu berikan
    local upgradeCategories = {"buckets", "root", "diamonds"} 
    
    while task.wait(2) do -- Berjalan setiap 2 detik agar tidak membuat ping tinggi
        if getgenv().AutoUpgrade then
            for _, category in ipairs(upgradeCategories) do
                if not getgenv().AutoUpgrade then break end
                
                -- Brute-force angka (Diubah: mencoba ID dari -10 sampai 20)
                for nodeId = -10, 10 do
                    if not getgenv().AutoUpgrade then break end
                    
                    task.spawn(function()
                        pcall(function()
                            -- Coba dengan angka argumen -1 dan 1
                            skillTreePurchase:InvokeServer(category, nodeId, -1)
                            skillTreePurchase:InvokeServer(category, nodeId, 1)
                        end)
                    end)
                    
                    -- Jeda per-request agar tidak terkena limit atau kick dari server karena spam
                    task.wait(0.05) 
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
    -- Inisialisasi Window
    local Window = Library:MakeWindow("Drain The Lake")
    
    -- Toggles
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
