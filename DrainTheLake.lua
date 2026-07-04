-- Tunggu sampai game sepenuhnya termuat
repeat task.wait() until game:IsLoaded()

-- Variables Setup
local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Define Remotes & Target Path
local verdantRemotes = RS:WaitForChild("VerdantRemotes")
local useBucket = verdantRemotes:WaitForChild("VDT_Bucket.Used")
local pourBucket = verdantRemotes:WaitForChild("VDT_Bucket.Poured")
local takeToken = verdantRemotes:WaitForChild("VDT_Tokens.Take")

local targetPrompt = Workspace:WaitForChild("Scripted")
    :WaitForChild("CheckpointParts")
    :WaitForChild("1")
    :WaitForChild("Drain")
    :WaitForChild("Scripted")
    :WaitForChild("ProximityPosition")
    :WaitForChild("ProximityPrompt")

local args = { targetPrompt }

-- Global Toggle Status
getgenv().AutoDrain = false
getgenv().AutoStor = false
getgenv().AutoToken = false

-- MAIN LOOP: 0.1 Detik
task.spawn(function()
    while task.wait(0.1) do
        -- 1. Cek Status Bucket dengan pcall (Mencegah error jika UI reset/belum loading)
        local isFull = false
        pcall(function()
            if LocalPlayer.PlayerGui.Interface.Holder.BucketFill.Bar.Progress.Text == "100% Full" then
                isFull = true
            end
        end)

        -- 2. Eksekusi Auto Drain (Hanya berjalan jika BUKAN 100%)
        if getgenv().AutoDrain and not isFull then
            useBucket:FireServer()
        end
        
        -- 3. Eksekusi Auto Stor (Hanya berjalan jika SUDAH 100%)
        if getgenv().AutoStor and isFull then
            pourBucket:FireServer(unpack(args))
        end
        
        -- 4. Eksekusi Auto Token (Bisa dicairkan terus-menerus)
        if getgenv().AutoToken then
            takeToken:FireServer(unpack(args))
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
    
    -- Toggle 1: Auto Drain
    Window:AddToggle("Auto Drain", false, function(Value)
        getgenv().AutoDrain = Value
    end)

    -- Toggle 2: Auto Stor
    Window:AddToggle("Auto Stor", false, function(Value)
        getgenv().AutoStor = Value
    end)

    -- Toggle 3: Auto Token
    Window:AddToggle("Auto Token", false, function(Value)
        getgenv().AutoToken = Value
    end)
else
    warn("UI Gagal Dimuat! Pastikan link github RZY_Library valid.")
end
