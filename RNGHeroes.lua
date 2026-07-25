-- Memuat Library RZY dari GitHub
local RZY_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()

-- Membuat Window UI
local Window = RZY_Library:MakeWindow("RNG Heroes Auto")

-- Variabel Servis Roblox
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Global Variables
getgenv().SelectedZone = "Beach" 
getgenv().AutoClick = false
getgenv().AutoRoll = false

-- Mengambil daftar Zones secara otomatis
local ZonesFolder = workspace:FindFirstChild("Zones")
local ZoneList = {}

if ZonesFolder then
    for _, zone in pairs(ZonesFolder:GetChildren()) do
        table.insert(ZoneList, zone.Name)
    end
else
    ZoneList = {"Forest", "Beach", "Jungle", "Meadows", "Sea", "Badlands", "SerpentSands", "Shadowgrove"}
end

-- ==========================================
-- MENU 1: PENGATURAN ZONA
-- ==========================================
Window:AddDropdown("Pilih Zone", ZoneList, function(option)
    getgenv().SelectedZone = option
end)

-- ==========================================
-- MENU 2: AUTO CLICK (BRUTAL SPEED)
-- ==========================================
local ClickEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ReportClickAttack")

Window:AddToggle("Auto Click Player", false, function(state)
    getgenv().AutoClick = state
    if state then
        task.spawn(function()
            local EnemyFolder = workspace:WaitForChild("EnemyRender")
            while getgenv().AutoClick do
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                
                if root then
                    -- Menghajar semua musuh sekaligus di layar
                    for _, enemy in ipairs(EnemyFolder:GetChildren()) do
                        local enemyIdStr = string.match(enemy.Name, "%d+")
                        if enemyIdStr then
                            ClickEvent:FireServer(getgenv().SelectedZone, tonumber(enemyIdStr), root.Position)
                        end
                    end
                end
                task.wait() -- Tanpa delay tambahan, murni kecepatan Frame/FPS
            end
        end)
    end
end)

-- ==========================================
-- MENU 3: AUTO ROLL
-- ==========================================
local RollFunction = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Roll")

Window:AddToggle("Auto Roll", false, function(state)
    getgenv().AutoRoll = state
    if state then
        task.spawn(function()
            while getgenv().AutoRoll do
                pcall(function()
                    -- Mengeksekusi gacha/roll terus menerus
                    RollFunction:InvokeServer(1)
                end)
                task.wait() 
            end
        end)
    end
end)
