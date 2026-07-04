-- Tunggu sampai game sepenuhnya termuat
repeat task.wait() until game:IsLoaded()

-- Variables Setup
local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

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

-- MAIN LOOP: SEMUA 0.1 DETIK
task.spawn(function()
    while task.wait(0.1) do
        if getgenv().AutoFarm then
            -- 1. Drain (Tembak Use Bucket)
            useBucket:FireServer()
            
            -- 2. Setor Bucket (Ditembak bersamaan)
            pourBucket:FireServer(unpack(args))
            
            -- 3. Ambil Token (Ditembak bersamaan)
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
    -- Inisialisasi Window UI sesuai dengan struktur library RZY
    local Window = Library:MakeWindow("Drain The Lake")
    
    -- Tambahkan Toggle Auto Farm
    Window:AddToggle("Auto Farm", false, function(Value)
        getgenv().AutoFarm = Value
    end)
else
    -- Jika UI gagal muncul, peringatan ini akan keluar di Console (F9)
    warn("UI Gagal Dimuat! Pastikan link raw github RZY_Library masih aktif dan bisa diakses.")
end
