local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Window = Library:MakeWindow("Brush Angry Cat")

local HatchEvent = game:GetService("ReplicatedStorage").Msg.RemoteFunction.RollFunction
local TrainEvent = game:GetService("ReplicatedStorage").Msg.RemoteFunction.Setting

local AutoHatch = false
local AutoTrain = false

local SelectedEggs = {
    Egg1 = false,
    Egg2 = false,
    Egg3 = false,
    Egg4 = false
}

-- ==========================================
-- TAMPILAN MENU (UI)
-- ==========================================
Window:AddMultiDropdown("Pilih Egg", {"Egg1", "Egg2", "Egg3", "Egg4", "Egg5"}, function(OpsiTerpilih)
    SelectedEggs = OpsiTerpilih
end)

Window:AddToggle("Mulai Auto Hatch", false, function(state)
    AutoHatch = state
end)

Window:AddToggle("Mulai Auto Train", false, function(state)
    AutoTrain = state
end)

-- ==========================================
-- MESIN BELAKANG (LOOPING)
-- ==========================================
task.spawn(function()
    while task.wait(1) do
        if AutoHatch then
            for namaEgg, dipilih in pairs(SelectedEggs) do
                if dipilih then
                    pcall(function()
                        HatchEvent:InvokeServer(namaEgg, 1, true)
                    end)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if AutoTrain then
            pcall(function()
                TrainEvent:InvokeServer("AutoTrain", 1)
            end)
        end
    end
end)
