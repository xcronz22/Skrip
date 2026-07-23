local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Window = Library:MakeWindow("SZA Script")

-- ==========================================
-- LAYANAN & REMOTE
-- ==========================================
local BloodmoonEvent = game:GetService("ReplicatedStorage").Remotes.EventRemotes.BloodmoonRequestSpin
local ArtifactEvent = game:GetService("ReplicatedStorage").Remotes.ArtifactCrateRemotes.Spin

local AutoBloodmoon = false
local AutoArtifact = false

-- ==========================================
-- TAMPILAN MENU (UI)
-- ==========================================
Window:AddToggle("Auto Bloodmoon Spin", false, function(state)
    AutoBloodmoon = state
end)

Window:AddToggle("Auto Artifact Spin", false, function(state)
    AutoArtifact = state
end)

-- ==========================================
-- MESIN BELAKANG (LOOPING TUGAS 0.1 DETIK)
-- ==========================================

-- 1. Mesin Bloodmoon Spin
task.spawn(function()
    while task.wait(0.1) do
        if AutoBloodmoon then
            pcall(function()
                BloodmoonEvent:InvokeServer()
            end)
        end
    end
end)

-- 2. Mesin Artifact Spin
task.spawn(function()
    while task.wait(0.1) do
        if AutoArtifact then
            pcall(function()
                ArtifactEvent:InvokeServer("Standard", 5)
            end)
        end
    end
end)
