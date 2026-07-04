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
        
        -- 1. Cek Status Bucket untuk logika Auto Drain
        local isFull = false
        pcall(function()
            if LocalPlayer.PlayerGui.Interface.Holder.BucketFill.Bar.Progress.Text == "100% Full" then
                isFull = true
            end
        end)

        -- 2. AUTO DRAIN (Tetap FireServer)
        if getgenv().AutoDrain and not isFull then
            useBucket:FireServer()
        end

        local scriptedFolder = Workspace:FindFirstChild("Scripted")
        if scriptedFolder then
            
            -- 3. AUTO CHEST (Menggunakan fireproximityprompt)
            if getgenv().AutoChest then
                local chestsFolder = scriptedFolder:FindFirstChild("Chests")
                if chestsFolder then
                    for _, obj in ipairs(chestsFolder:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") and obj.Enabled then
                            pcall(function() fireproximityprompt(obj) end)
                        end
                    end
                end
            end

            -- Mengumpulkan target spesifik folder "Drain"
            local targetDrains = {}
            
            -- Drain di luar
            for _, obj in ipairs(scriptedFolder:GetChildren()) do
                if obj.Name == "Drain" then table.insert(targetDrains, obj) end
            end
            
            -- 4 & 5. AUTO STOR & AUTO TOKEN (Menggunakan fireproximityprompt)
            for _, drainObj in ipairs(targetDrains) do
                local scripted = drainObj:FindFirstChild("Scripted")
                if scripted then
                    
                    local storPrompt = scripted:FindFirstChild("ProximityPosition") 
                        and scripted.ProximityPosition:FindFirstChild("ProximityPrompt")
                    local tokenPrompt = scripted:FindFirstChild("TakeTokens") 
                        and scripted.TakeTokens:FindFirstChild("ProximityPrompt")
                    
                    -- AUTO STOR (Trigger prompt)
                    if getgenv().AutoStor and isFull and storPrompt and storPrompt.Enabled then
                        pcall(function() fireproximityprompt(storPrompt) end)
                    end
                    
                    -- AUTO TOKEN (Trigger prompt)
                    if getgenv().AutoToken and tokenPrompt and tokenPrompt.Enabled then
                        pcall(function() fireproximityprompt(tokenPrompt) end)
                    end
                end
            end
        end
    end
end)

------------------------------------------
-- UI SETUP
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
end
