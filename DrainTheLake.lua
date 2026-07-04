-- Tunggu sampai game sepenuhnya termuat
repeat task.wait() until game:IsLoaded()

-- Variables Setup
local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Define Remotes (Hanya untuk Auto Drain)
local verdantRemotes = RS:WaitForChild("VerdantRemotes")
local useBucket = verdantRemotes:WaitForChild("VDT_Bucket.Used")

-- Global Toggle Status
getgenv().AutoDrain = false
getgenv().AutoStor  = false
getgenv().AutoToken = false
getgenv().AutoChest = false

-- MAIN LOOP: 0.1 Detik
task.spawn(function()
    while task.wait(0.1) do
        
        -- 1. Cek Status Bucket (untuk Auto Drain)
        local isFull = false
        pcall(function()
            if LocalPlayer.PlayerGui.Interface.Holder.BucketFill.Bar.Progress.Text == "100% Full" then
                isFull = true
            end
        end)

        -- 2. AUTO DRAIN (Tetap menggunakan FireServer)
        if getgenv().AutoDrain and not isFull then
            useBucket:FireServer()
        end

        -- 3. AUTO CHEST (Universal Search)
        if getgenv().AutoChest then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name == "Chests" and obj:IsA("Folder") then
                    for _, prompt in ipairs(obj:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                            pcall(function() fireproximityprompt(prompt) end)
                        end
                    end
                end
            end
        end

        -- 4. AUTO STOR & AUTO TOKEN (Universal Search semua folder bernama "Drain")
        -- Tidak lagi membedakan lokasi folder, semua "Drain" di Workspace akan diurus
        for _, drainFolder in ipairs(Workspace:GetDescendants()) do
            if drainFolder.Name == "Drain" and drainFolder:IsA("Folder") then
                local scripted = drainFolder:FindFirstChild("Scripted")
                if scripted then
                    
                    -- Auto Stor (ProximityPosition)
                    if getgenv().AutoStor and isFull then
                        local storPrompt = scripted:FindFirstChild("ProximityPosition") and scripted.ProximityPosition:FindFirstChild("ProximityPrompt")
                        if storPrompt and storPrompt.Enabled then
                            pcall(function() fireproximityprompt(storPrompt) end)
                        end
                    end
                    
                    -- Auto Token (TakeTokens)
                    if getgenv().AutoToken then
                        local tokenPrompt = scripted:FindFirstChild("TakeTokens") and scripted.TakeTokens:FindFirstChild("ProximityPrompt")
                        if tokenPrompt and tokenPrompt.Enabled then
                            pcall(function() fireproximityprompt(tokenPrompt) end)
                        end
                    end
                    
                end
            end
        end
    end
end)

------------------------------------------
-- UI SETUP (RZY LIBRARY)
------------------------------------------
local success, Library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
end)

if success and Library then
    local Window = Library:MakeWindow("Drain The Lake")
    Window:AddToggle("Auto Drain", false, function(v) getgenv().AutoDrain = v end)
    Window:AddToggle("Auto Stor", false, function(v) getgenv().AutoStor = v end)
    Window:AddToggle("Auto Token", false, function(v) getgenv().AutoToken = v end)
    Window:AddToggle("Auto Chest", false, function(v) getgenv().AutoChest = v end)
else
    warn("UI Gagal Dimuat!")
end
