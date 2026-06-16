-- Memuat Library RZY
local RZY_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()

-- Membuat Window Utama
local Win = RZY_Library:MakeWindow("100 Days at Sea - Pro")

local AutoGrinderEnabled = false
local Connection -- Variabel untuk menyimpan event listener

-- [FUNGSI PRO] Fungsi terpisah untuk memproses dan memindahkan resource
local function TeleportResource(obj, GrinderPart)
    if not obj then return end
    
    local resType = obj:GetAttribute("Resource")
    
    if resType == "Wood" or resType == "Metal" or resType == "Goo" then
        if obj:IsA("BasePart") then
            obj.CFrame = GrinderPart.CFrame
            -- Reset fisika agar tidak terpental (Bouncing fix)
            obj.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            obj.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        elseif obj:IsA("Model") and obj.PrimaryPart then
            obj:PivotTo(GrinderPart.CFrame)
            -- Reset fisika untuk seluruh part di dalam model
            for _, part in ipairs(obj:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end
end

-- Membuat Toggle Auto Grinder
Win:AddToggle("Auto Grinder", false, function(state)
    AutoGrinderEnabled = state
    
    local workspace = game:GetService("Workspace")
    -- Menggunakan WaitForChild agar aman saat map belum sepenuhnya load
    local DebrisField = workspace:WaitForChild("DebrisField", 5)
    local SpawnIsland = workspace:WaitForChild("SpawnIsland", 5)
    local Grinder = SpawnIsland and SpawnIsland:WaitForChild("Grinder", 5)
    local Collection = Grinder and Grinder:WaitForChild("Collection", 5)

    if not DebrisField or not Collection then
        warn("[RZY Hub] Elemen map gagal dimuat. Pastikan Anda sudah di dalam game.")
        return
    end

    if AutoGrinderEnabled then
        -- 1. Initial Sweep: Sapu bersih semua item yang *sudah ada* di laut saat ini
        for _, obj in ipairs(DebrisField:GetChildren()) do
            TeleportResource(obj, Collection)
        end

        -- 2. Event Listener: Langsung TP item detik itu juga saat baru spawn
        Connection = DebrisField.ChildAdded:Connect(function(newObj)
            -- Jeda sangat singkat (0.1s) agar game punya waktu memuat atribut 'Resource' pada objek baru
            task.wait(0.1) 
            TeleportResource(newObj, Collection)
        end)
    else
        -- [FUNGSI PRO] Bersihkan event listener saat dimatikan agar tidak lag/memory leak
        if Connection then
            Connection:Disconnect()
            Connection = nil
        end
    end
end)
