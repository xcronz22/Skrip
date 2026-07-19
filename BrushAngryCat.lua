local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()

-- 1. Membuat UI Window menggunakan MakeWindow dari library kamu
local Window = Library:MakeWindow("Brush Angry Cat")

local Event = game:GetService("ReplicatedStorage").Msg.RemoteFunction.RollFunction
local AutoHatch = false

-- Tabel default untuk menyimpan status Egg
local SelectedEggs = {
    Egg1 = false,
    Egg2 = false,
    Egg3 = false,
    Egg4 = false,
    Egg5 = false
}

-- 2. Menggunakan fitur AddMultiDropdown dari library kamu untuk memilih Egg
Window:AddMultiDropdown("Pilih Egg", {"Egg1", "Egg2", "Egg3", "Egg4", "Egg5"}, function(OpsiTerpilih)
    -- OpsiTerpilih akan otomatis memperbarui tabel dengan Egg mana saja yang dicentang
    SelectedEggs = OpsiTerpilih
end)

-- 3. Membuat Toggle utama untuk menyalakan/mematikan Auto Hatch
Window:AddToggle("Mulai Auto Hatch", false, function(state)
    AutoHatch = state
end)

-- 4. Mesin Utama (Berjalan di latar belakang)
task.spawn(function()
    while task.wait(1) do
        if AutoHatch then
            -- Mengecek satu per satu Egg di dalam tabel SelectedEggs
            for namaEgg, dipilih in pairs(SelectedEggs) do
                if dipilih then -- Jika Egg tersebut di-ceklis (bernilai true)
                    pcall(function()
                        Event:InvokeServer(namaEgg, 1, true)
                    end)
                end
            end
        end
    end
end)
