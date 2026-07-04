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
getgenv().AutoFarm = false

-- Fungsi untuk mengecek apakah bucket sudah 100% Full
local function isBucketFull()
    local success, result = pcall(function()
        return LocalPlayer.PlayerGui.Interface.Holder.BucketFill.Bar.Progress.Text == "100% Full"
    end)
    return success and result
end

-- Main Auto Farm Loop (Brutal)
task.spawn(function()
    while task.wait() do
        if getgenv().AutoFarm then
            if isBucketFull() then
                -- Setor Bucket
                pourBucket:FireServer(unpack(args))
                -- Ambil Token
                takeToken:FireServer(unpack(args))
            else
                -- Spam Use Bucket
                useBucket:FireServer()
            end
        end
    end
end)

------------------------------------------
-- UI SETUP MENGGUNAKAN RZY LIBRARY
------------------------------------------
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()

-- Inisialisasi Window UI sesuai dengan library Anda
local Window = Library:MakeWindow("Drain The Lake")

-- Tambahkan Toggle Auto Farm
Window:AddToggle("Auto Farm", false, function(Value)
    getgenv().AutoFarm = Value
end)
