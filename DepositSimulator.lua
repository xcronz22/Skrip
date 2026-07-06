-- Memuat RZY_Library menggunakan loadstring yang kamu berikan
local RZY_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()

-- Membuat Window/Hub Utama
local Window = RZY_Library:MakeWindow("Deposit Simulator")

-- Label Informasi
Window:AddLabel("Made with RZY_Library")
Window:AddLabel("Interval: 0.1 Detik")

-- Setup Variabel Global untuk Toggle
getgenv().autoSell = false
getgenv().autoBuy = false

-- Daftar Upgrades
local upgrades = {
    "LootTable_Zone1",
    "DisposalSpeed",
    "BinSpeed_Zone1",
    "BottleValue"
}

-- Fitur Auto Sell
Window:AddToggle("Auto Sell Bottle", false, function(state)
    getgenv().autoSell = state
end)

-- Fitur Auto Buy Upgrade
Window:AddToggle("Auto Buy Upgrades", false, function(state)
    getgenv().autoBuy = state
end)

-- Loop Utama (Berjalan di background menggunakan task.spawn)
task.spawn(function()
    local RS = game:GetService("ReplicatedStorage")
    
    while task.wait(0.1) do
        -- Eksekusi Auto Sell
        if getgenv().autoSell then
            pcall(function()
                RS:WaitForChild("RemoveLastBottle"):FireServer()
            end)
        end
        
        -- Eksekusi Auto Buy
        if getgenv().autoBuy then
            for _, upgradeName in ipairs(upgrades) do
                pcall(function()
                    -- InvokeServer langsung menerima string argumen tersebut, 
                    -- sama efeknya dengan unpack({"Nama_Upgrade"})
                    RS:WaitForChild("PurchaseUpgrade"):InvokeServer(upgradeName)
                end)
            end
        end
    end
end)
