local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Window = Library:MakeWindow("Train NPC Script")

-- ==========================================
-- LAYANAN & REMOTE
-- ==========================================
local AbilityEvent = game:GetService("ReplicatedStorage").AIArena.Remotes.UseAbility
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local AutoAbility = false
local AntiAFK = false
local AntiLag = false

-- ==========================================
-- TAMPILAN MENU (UI)
-- ==========================================
Window:AddToggle("Auto Use Ability", false, function(state)
    AutoAbility = state
end)

Window:AddToggle("Aktifkan Anti AFK", false, function(state)
    AntiAFK = state
end)

Window:AddToggle("Anti Lag Ekstrem & No Fog", false, function(state)
    AntiLag = state
end)

-- ==========================================
-- MESIN BELAKANG (LOOPING TUGAS)
-- ==========================================

-- 1. Auto Use Ability (Per 1 detik)
task.spawn(function()
    while task.wait(1) do
        if AutoAbility then
            pcall(function()
                AbilityEvent:FireServer()
            end)
        end
    end
end)

-- 2. Anti AFK (Berjalan otomatis saat terdeteksi diam)
Players.LocalPlayer.Idled:Connect(function()
    if AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- 3. Anti Lag Ekstrem (Gaya Infinite Yield tapi "Santuy")
task.spawn(function()
    -- Menggunakan 10 detik agar tidak terlalu sering mengecek memori
    while task.wait(10) do 
        if AntiLag then
            pcall(function()
                -- A. Bagian Lighting (Instan karena sangat ringan)
                Lighting.FogEnd = 9e9
                Lighting.FogStart = 0
                Lighting.GlobalShadows = false
                Lighting.Brightness = 2
                
                -- B. Sapu Bersih Workspace (Mode Santuy)
                local semuaObjek = Workspace:GetDescendants()
                
                for i, objek in ipairs(semuaObjek) do
                    if not AntiLag then break end -- Langsung berhenti jika toggle dimatikan di tengah jalan
                    
                    -- Mengubah balok menjadi plastik polos tanpa bayangan
                    if objek:IsA("BasePart") then
                        objek.Material = Enum.Material.SmoothPlastic
                        objek.CastShadow = false
                        objek.Reflectance = 0
                        
                    -- Menyembunyikan gambar dan tekstur map
                    elseif objek:IsA("Decal") or objek:IsA("Texture") then
                        objek.Transparency = 1
                        
                    -- Mematikan efek atmosfer dan partikel (debu, asap, dll)
                    elseif objek:IsA("PostEffect") or objek:IsA("Atmosphere") or objek:IsA("ParticleEmitter") or objek:IsA("Trail") then
                        objek.Enabled = false
                    end
                    
                    -- [SISTEM BERNAPAS] 
                    -- Setiap mengecek 200 objek, skrip akan jeda sesaat (task.wait)
                    -- Ini yang membuat game tidak akan freeze/patah-patah saat ganti map!
                    if i % 200 == 0 then
                        task.wait()
                    end
                end
            end)
        end
    end
end)
