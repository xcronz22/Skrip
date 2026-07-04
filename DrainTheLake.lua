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

-- LOOP 1: BRUTAL DRAIN (Spam secepat mungkin / setiap frame)
task.spawn(function()
    while task.wait() do
        if getgenv().AutoFarm then
            useBucket:FireServer()
        end
    end
end)

-- LOOP 2: SETOR & AMBIL TOKEN (Ditembak otomatis tanpa tunggu full, delay 0.5 detik)
task.spawn(function()
    while task.wait(0.5) do
        if getgenv().AutoFarm then
            pourBucket:FireServer(unpack(args))
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
