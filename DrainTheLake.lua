-- Tunggu sampai game sepenuhnya termuat
repeat task.wait() until game:IsLoaded()

-- Variables Setup
local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Define Remotes (Hanya untuk Bucket/Drain)
local verdantRemotes = RS:WaitForChild("VerdantRemotes")
local useBucket = verdantRemotes:WaitForChild("VDT_Bucket.Used")
local pourBucket = verdantRemotes:WaitForChild("VDT_Bucket.Poured")
local takeToken = verdantRemotes:WaitForChild("VDT_Tokens.Take")

-- Global Toggle Status
getgenv().AutoDrain = false
getgenv().AutoStor  = false
getgenv().AutoToken = false
getgenv().AutoChest = false

-- MAIN LOOP: 0.1 Detik
task.spawn(function()
    while task.wait(0.1) do
        
        -- 1. Cek Status Bucket (Mencegah error jika UI reset)
        local isFull = false
        pcall(function()
            if LocalPlayer.PlayerGui.Interface.Holder.BucketFill.Bar.Progress.Text == "100% Full" then
                isFull = true
            end
        end)

        -- 2. AUTO DRAIN (Hanya berjalan jika BUKAN 100%)
        if getgenv().AutoDrain and not isFull then
            useBucket:FireServer()
        end

        local scriptedFolder = Workspace:FindFirstChild("Scripted")
        if scriptedFolder then
            
            -- 3. AUTO CHEST (Loop semua chest & cek Enabled == true)
            if getgenv().AutoChest then
                local chestsFolder = scriptedFolder:FindFirstChild("Chests")
                if chestsFolder then
                    for _, prompt in ipairs(chestsFolder:GetDescendants()) do
                        -- Pastikan objeknya adalah ProximityPrompt dan sedang aktif
                        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                            pcall(function()
                                fireproximityprompt(prompt)
                            end)
                        end
                    end
                end
            end

            -- 4 & 5. AUTO STOR & AUTO TOKEN (Loop semua folder Drain)
            for _, obj in ipairs(scriptedFolder:GetChildren()) do
                if obj.Name == "Drain" then
                    
                    -- AUTO STOR (Berjalan jika status bucket isFull)
                    if getgenv().AutoStor and isFull then
                        -- Sesuai screenshot: Drain -> Scripted -> ProximityPosition -> ProximityPrompt
                        local storPrompt = obj:FindFirstChild("Scripted") 
                            and obj.Scripted:FindFirstChild("ProximityPosition") 
                            and obj.Scripted.ProximityPosition:FindFirstChild("ProximityPrompt")
                            
                        if storPrompt then
                            pourBucket:FireServer(storPrompt)
                        end
                    end
                    
                    -- AUTO TOKEN (Berjalan terus untuk klaim)
                    if getgenv().AutoToken then
                        -- Sesuai screenshot: Drain -> Scripted -> TakeTokens -> ProximityPrompt
                        local tokenPrompt = obj:FindFirstChild("Scripted") 
                            and obj.Scripted:FindFirstChild("TakeTokens") 
                            and obj.Scripted.TakeTokens:FindFirstChild("ProximityPrompt")
                            
                        if tokenPrompt then
                            takeToken:FireServer(tokenPrompt)
                        end
                    end
                    
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
else
    warn("UI Gagal Dimuat! Pastikan link github RZY_Library valid.")
end
