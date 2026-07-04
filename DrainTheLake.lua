-- Tunggu sampai game sepenuhnya termuat
repeat task.wait() until game:IsLoaded()

-- Variables Setup
local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Define Remotes & Target Path (Di-load di awal agar performa lebih ringan dan brutal saat dilooping)
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
    -- Menggunakan pcall agar script tidak memunculkan error di konsol jika path UI belum siap
    local success, result = pcall(function()
        return LocalPlayer.PlayerGui.Interface.Holder.BucketFill.Bar.Progress.Text == "100% Full"
    end)
    return success and result
end

-- Main Auto Farm Loop
task.spawn(function()
    while task.wait() do
        if getgenv().AutoFarm then
            if isBucketFull() then
                -- 1. Jika sudah penuh -> Setor Bucket
                pourBucket:FireServer(unpack(args))
                
                -- 2. Langsung Cairkan / Ambil Token (Tanpa menunggu)
                takeToken:FireServer(unpack(args))
            else
                -- 3. Jika belum penuh -> Brutal Drain (Spam Use Bucket)
                useBucket:FireServer()
            end
        end
    end
end)

------------------------------------------
-- UI SETUP MENGGUNAKAN RZY LIBRARY
------------------------------------------
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()

-- Inisialisasi Window UI
local Window = Library:CreateWindow({
    Title = "Drain The Lake",
    Center = true,
    AutoShow = true,
})

-- Tambahkan Toggle untuk Auto Farm
Window:AddToggle({
    Text = "Auto Farm",
    Default = false,
    Callback = function(Value)
        getgenv().AutoFarm = Value
    end
})
