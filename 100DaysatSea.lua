-- Memuat Library RZY
local RZY_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()

-- Membuat Window Utama
local Win = RZY_Library:MakeWindow("100 Days at Sea - Pro")

-- State Manajemen untuk masing-masing material
local Toggles = {
    Wood = false,
    Metal = false,
    Goo = false
}

local Connection -- Variabel tunggal untuk event listener

-- Cache elemen map di awal agar eksekusi lebih cepat
local workspace = game:GetService("Workspace")
local DebrisField = workspace:WaitForChild("DebrisField", 10)
local SpawnIsland = workspace:WaitForChild("SpawnIsland", 10)
local Grinder = SpawnIsland and SpawnIsland:WaitForChild("Grinder", 10)
local Collection = Grinder and Grinder:WaitForChild("Collection", 10)

-- Fungsi untuk memproses dan memindahkan resource
local function TeleportResource(obj, GrinderPart)
    if not obj or not GrinderPart then return end
    
    local resType = obj:GetAttribute("Resource")
    
    -- Hanya teleport jika tipe resource tersebut aktif di toggle
    if resType and Toggles[resType] then
        if obj:IsA("BasePart") then
            obj.CFrame = GrinderPart.CFrame
            obj.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            obj.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        elseif obj:IsA("Model") and obj.PrimaryPart then
            obj:PivotTo(GrinderPart.CFrame)
            for _, part in ipairs(obj:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end
end

-- Fungsi untuk menyapu item yang sudah ada di laut saat toggle baru dinyalakan
local function SweepResources(targetType)
    if not DebrisField or not Collection then return end
    for _, obj in ipairs(DebrisField:GetChildren()) do
        if obj:GetAttribute("Resource") == targetType then
            TeleportResource(obj, Collection)
        end
    end
end

-- Fungsi otomatisasi Event Listener (Menyala jika minimal ada 1 toggle aktif)
local function UpdateEventListener()
    local anyEnabled = Toggles.Wood or Toggles.Metal or Toggles.Goo
    
    if anyEnabled then
        if not Connection then
            Connection = DebrisField.ChildAdded:Connect(function(newObj)
                -- Menggunakan task.spawn agar respons instan dan tidak nge-lag saat banyak item spawn bersamaan
                task.spawn(function()
                    -- OPTIMASI KECEPATAN: Cek langsung, jika belum replikasi baru tunggu 1 frame (~0.016s)
                    if not newObj:GetAttribute("Resource") then
                        task.wait(0.05) 
                    end
                    TeleportResource(newObj, Collection)
                end)
            end)
        end
    else
        -- Matikan listener jika semua toggle OFF (Hemat RAM / Anti-lag)
        if Connection then
            Connection:Disconnect()
            Connection = nil
        end
    end
end

-- ==================== TOMBOL TOGGLE TERPISAH ====================

Win:AddToggle("Auto Wood", false, function(state)
    Toggles.Wood = state
    if state then SweepResources("Wood") end
    UpdateEventListener()
end)

Win:AddToggle("Auto Metal", false, function(state)
    Toggles.Metal = state
    if state then SweepResources("Metal") end
    UpdateEventListener()
end)

Win:AddToggle("Auto Goo", false, function(state)
    Toggles.Goo = state
    if state then SweepResources("Goo") end
    UpdateEventListener()
end)
