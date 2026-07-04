-- Tunggu sampai game sepenuhnya termuat
repeat task.wait() until game:IsLoaded()

-- Variables Setup
local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Define Remote Hanya Untuk yang Wajib
local useBucket = RS:WaitForChild("VerdantRemotes"):WaitForChild("VDT_Bucket.Used")
local skillTreePurchase = RS:WaitForChild("VerdantRemotes"):WaitForChild("VDT_SkillTree.Purchase")

-- Global Toggle Status
getgenv().AutoFarm  = false 
getgenv().AutoDrain = false
getgenv().AutoStor  = false
getgenv().AutoToken = false
getgenv().AutoChest = false
getgenv().AutoPhone = false
getgenv().AutoUpgrade = false

-- Fungsi Helper untuk menembak prompt
local function clickPrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled then
        fireproximityprompt(prompt)
    end
end

-- MAIN LOOP
task.spawn(function()
    while task.wait(0.1) do
        
        -- Cek Status Bucket
        local isFull = false
        pcall(function()
            if LocalPlayer.PlayerGui.Interface.Holder.BucketFill.Bar.Progress.Text == "100% Full" then
                isFull = true
            end
        end)

        -- 1. Auto Drain
        if (getgenv().AutoDrain or getgenv().AutoFarm) and not isFull then
            useBucket:FireServer()
        end

        -- 2. Auto Phone
        if (getgenv().AutoPhone or getgenv().AutoFarm) then
            local phonePrompt = Workspace:FindFirstChild("Phone") and Workspace.Phone:FindFirstChild("PhoneHandle") and Workspace.Phone.PhoneHandle:FindFirstChild("ProximityPrompt")
            clickPrompt(phonePrompt)
        end

        local scriptedFolder = Workspace:FindFirstChild("Scripted")
        if scriptedFolder then
            
            -- 3. Auto Chest (Scanning semua descendant di Chests)
            if (getgenv().AutoChest or getgenv().AutoFarm) then
                local chestsFolder = scriptedFolder:FindFirstChild("Chests")
                if chestsFolder then
                    for _, d in ipairs(chestsFolder:GetDescendants()) do
                        if d:IsA("ProximityPrompt") then clickPrompt(d) end
                    end
                end
            end

            -- 4. Auto Stor & Token (Scanning Drain di luar dan di Checkpoint)
            -- Kita cari semua ProximityPrompt yang ada di bawah objek bernama "Drain"
            for _, d in ipairs(scriptedFolder:GetDescendants()) do
                if d.Name == "Drain" and d:IsA("Model") then
                    -- Cari prompt di dalam ProximityPosition atau langsung di dalam model
                    local prompt = d:FindFirstChild("Scripted") and d.Scripted:FindFirstChild("ProximityPosition") and d.Scripted.ProximityPosition:FindFirstChild("ProximityPrompt")
                    local tokenPrompt = d:FindFirstChild("Scripted") and d.Scripted:FindFirstChild("TakeTokens") and d.Scripted.TakeTokens:FindFirstChild("ProximityPrompt")
                    
                    if (getgenv().AutoStor or getgenv().AutoFarm) and isFull then
                        clickPrompt(prompt)
                    end
                    if (getgenv().AutoToken or getgenv().AutoFarm) then
                        clickPrompt(tokenPrompt)
                    end
                end
            end
        end
    end
end)

-- AUTO UPGRADE LOOP (Tetap menggunakan remote karena ini sistem data)
task.spawn(function()
    local upgradeCategories = {"buckets", "root", "diamonds", "character"} 
    local coords = {}
    for x = -10, 10 do for y = -10, 10 do table.insert(coords, {x, y}) end end
    
    table.sort(coords, function(a, b) return (math.abs(a[1]) + math.abs(a[2])) < (math.abs(b[1]) + math.abs(b[2])) end)

    while task.wait(2) do
        if (getgenv().AutoUpgrade or getgenv().AutoFarm) then
            for _, category in ipairs(upgradeCategories) do
                if not (getgenv().AutoUpgrade or getgenv().AutoFarm) then break end
                for _, coord in ipairs(coords) do
                    if not (getgenv().AutoUpgrade or getgenv().AutoFarm) then break end
                    task.spawn(function() pcall(function() skillTreePurchase:InvokeServer(category, coord[1], coord[2]) end) end)
                    task.wait(0.01) 
                end
            end
        end
    end
end)

------------------------------------------
-- UI SETUP
------------------------------------------
local success, Library = pcall(function() return loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))() end)

if success and Library then
    local Window = Library:MakeWindow("Drain The Lake")
    Window:AddToggle("Auto Farm (All-In-One)", false, function(v) getgenv().AutoFarm = v end)
    Window:AddToggle("Auto Drain", false, function(v) getgenv().AutoDrain = v end)
    Window:AddToggle("Auto Stor", false, function(v) getgenv().AutoStor = v end)
    Window:AddToggle("Auto Token", false, function(v) getgenv().AutoToken = v end)
    Window:AddToggle("Auto Chest", false, function(v) getgenv().AutoChest = v end)
    Window:AddToggle("Auto Phone", false, function(v) getgenv().AutoPhone = v end)
    Window:AddToggle("Auto Upgrade", false, function(v) getgenv().AutoUpgrade = v end)
end
