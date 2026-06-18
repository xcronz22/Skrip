-- Memuat Library RZY
local RZY_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xcronz22/Skrip/main/RZY_Library.lua"))()
local Win = RZY_Library:MakeWindow("100 Days at Sea - V5")

local TargetMaterials = {
    ["Wood"] = false,
    ["Metal"] = false,
    ["Goo"] = false
}

Win:AddMultiDropdown("Pilih Material (Bisa >1)", {"Wood", "Metal", "Goo"}, function(selectedTable)
    TargetMaterials = selectedTable
end)

local AutoGrinderEnabled = false
local AutoCampfireEnabled = false
local AutoEatEnabled = false
local AutoCrabTrapEnabled = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ====================================================================
-- [SISTEM INTI]: DYNAMIC REMOTE FINDER & TOKEN INTERCEPTOR
-- ====================================================================
local CurrentSyncToken = nil
local GameRemoteEvent = nil
local GameRemoteFunction = nil

-- 1. FUNGSI PELACAK REMOTE (Otomatis mencari di semua Service)
local function FindHiddenRemotes()
    -- Daftar Service yang sering dipakai developer untuk menyembunyikan Remote
    local hiddenServices = {
        "Chat", "LocalizationService", "SocialService", 
        "TestService", "SoundService", "Lighting", "Stats", "JointsService"
    }
    
    for _, sName in ipairs(hiddenServices) do
        pcall(function()
            local service = game:GetService(sName)
            if service then
                local re = service:FindFirstChild("RemoteEvent")
                local rf = service:FindFirstChild("RemoteFunction")
                if re then GameRemoteEvent = re end
                if rf then GameRemoteFunction = rf end
            end
        end)
    end
end

FindHiddenRemotes() -- Jalankan pelacak saat script dimulai

-- 2. PENYADAP KOMUNIKASI (Dibuat Dinamis Tanpa Mempedulikan Service Parent-nya)
pcall(function()
    if hookmetamethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if (method == "FireServer" or method == "InvokeServer") then
                if self.Name == "RemoteEvent" or self.Name == "RemoteFunction" then
                    -- Verifikasi format remote game ini (Arg 1 adalah Token Angka, Arg 2 adalah String Action)
                    if type(args[1]) == "number" and type(args[2]) == "string" then
                        if not checkcaller() then
                            -- Jika pelacak gagal di awal, kita tangkap/curi remotenya langsung dari gamenya di sini
                            if self:IsA("RemoteEvent") then GameRemoteEvent = self end
                            if self:IsA("RemoteFunction") then GameRemoteFunction = self end
                            
                            -- Sinkronisasi Token
                            if CurrentSyncToken then
                                CurrentSyncToken = CurrentSyncToken + 1
                                args[1] = CurrentSyncToken
                                return oldNamecall(self, unpack(args))
                            else
                                CurrentSyncToken = args[1]
                            end
                        end
                    end
                end
            end
            return oldNamecall(self, ...)
        end)
    end
end)

-- Fungsi Generator Token
local function GetNextToken()
    if not CurrentSyncToken then CurrentSyncToken = math.random(100000, 999999) end
    CurrentSyncToken = CurrentSyncToken + 1
    return CurrentSyncToken
end

-- Eksekusi Remote Event Aman & Dinamis
local function SafeRemoteEvent(actionName, ...)
    if GameRemoteEvent then
        GameRemoteEvent:FireServer(GetNextToken(), actionName, ...)
    else
        warn("[RZY Hub] RemoteEvent belum ditemukan! Coba bergerak atau ambil 1 item manual.")
    end
end

-- Eksekusi Remote Function Aman & Dinamis
local function SafeRemoteFunction(actionName, ...)
    if GameRemoteFunction then
        return GameRemoteFunction:InvokeServer(GetNextToken(), actionName, ...)
    end
end

-- ====================================================================
-- [FITUR 1 & 2]: AUTO GRINDER & CAMPFIRE (TETAP SAMA SEPERTI V4)
-- ====================================================================
Win:AddToggle("Mulai Auto Grinder", false, function(state)
    AutoGrinderEnabled = state
    if AutoGrinderEnabled then
        task.spawn(function()
            while AutoGrinderEnabled do
                local workspace = game:GetService("Workspace")
                local DebrisField = workspace:FindFirstChild("DebrisField")
                local GrinderCol = workspace:FindFirstChild("SpawnIsland") and workspace.SpawnIsland:FindFirstChild("Grinder") and workspace.SpawnIsland.Grinder:FindFirstChild("Collection")

                if DebrisField and GrinderCol then
                    local itemsToProcess = {}
                    for _, obj in ipairs(DebrisField:GetChildren()) do
                        local resType = obj:GetAttribute("Resource")
                        if resType and TargetMaterials[resType] then
                            local isArmor = false
                            for attrName, attrValue in pairs(obj:GetAttributes()) do
                                if string.find(string.lower(attrName), "armor") or (type(attrValue) == "string" and string.find(string.lower(attrValue), "armor")) then
                                    isArmor = true
                                    break
                                end
                            end
                            if isArmor then continue end 

                            local primary = obj:IsA("Model") and obj.PrimaryPart or (obj:IsA("BasePart") and obj)
                            if primary then
                                local distance = (primary.Position - GrinderCol.Position).Magnitude
                                if distance > 3 then
                                    local isGrabbed = obj:GetAttribute("Grabbed")
                                    local grabberAttr = obj:GetAttribute("Grabber")
                                    local myId, myName = LocalPlayer.UserId, LocalPlayer.Name
                                    local isGrabberMe = false
                                    if grabberAttr ~= nil then
                                        isGrabberMe = (grabberAttr == myId or tostring(grabberAttr) == tostring(myId) or grabberAttr == myName)
                                    end
                                    
                                    if isGrabbed == true and not isGrabberMe then continue end
                                    table.insert(itemsToProcess, { Object = obj, Distance = distance })
                                end
                            end
                        end
                    end
                    table.sort(itemsToProcess, function(a, b) return a.Distance < b.Distance end)

                    for _, data in ipairs(itemsToProcess) do
                        if not AutoGrinderEnabled then break end 
                        local obj = data.Object
                        local targetCFrame = GrinderCol.CFrame
                        obj:SetAttribute("Grabbed", false) 
                        obj:SetAttribute("LastHolder", LocalPlayer.Name)  

                        if obj:IsA("BasePart") then
                            obj.CFrame = targetCFrame
                            obj.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        elseif obj:IsA("Model") then
                            obj:PivotTo(targetCFrame)
                            for _, part in ipairs(obj:GetDescendants()) do
                                if part:IsA("BasePart") then part.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end
                            end
                        end
                        task.wait(0.1)
                    end
                end
                task.wait(0.1) 
            end
        end)
    end
end)

Win:AddToggle("Mulai Auto Campfire", false, function(state)
    AutoCampfireEnabled = state
    if AutoCampfireEnabled then
        task.spawn(function()
            while AutoCampfireEnabled do
                local workspace = game:GetService("Workspace")
                local DebrisField = workspace:FindFirstChild("DebrisField")
                local Dropper = workspace:FindFirstChild("SpawnIsland") and workspace.SpawnIsland:FindFirstChild("Dropper")

                if DebrisField and Dropper then
                    local dropperPart = Dropper:IsA("BasePart") and Dropper or Dropper:FindFirstChildWithClass("BasePart") or (Dropper:IsA("Model") and Dropper.PrimaryPart)
                    if dropperPart then
                        local itemsToProcess = {}
                        for _, obj in ipairs(DebrisField:GetChildren()) do
                            if obj:GetAttribute("Resource") == "Wood" then
                                local isArmor = false
                                for attrName, attrValue in pairs(obj:GetAttributes()) do
                                    if string.find(string.lower(attrName), "armor") or (type(attrValue) == "string" and string.find(string.lower(attrValue), "armor")) then
                                        isArmor = true; break
                                    end
                                end
                                if isArmor then continue end

                                local primary = obj:IsA("Model") and obj.PrimaryPart or (obj:IsA("BasePart") and obj)
                                if primary then
                                    local distance = (primary.Position - dropperPart.Position).Magnitude
                                    if distance > 3 then
                                        local isGrabbed = obj:GetAttribute("Grabbed")
                                        local grabberAttr = obj:GetAttribute("Grabber")
                                        local myId, myName = LocalPlayer.UserId, LocalPlayer.Name
                                        local isGrabberMe = false
                                        if grabberAttr ~= nil then isGrabberMe = (grabberAttr == myId or tostring(grabberAttr) == tostring(myId) or grabberAttr == myName) end
                                        if isGrabbed == true and not isGrabberMe then continue end
                                        
                                        table.insert(itemsToProcess, { Object = obj, Distance = distance })
                                    end
                                end
                            end
                        end
                        table.sort(itemsToProcess, function(a, b) return a.Distance < b.Distance end)

                        for _, data in ipairs(itemsToProcess) do
                            if not AutoCampfireEnabled then break end 
                            local obj = data.Object
                            local targetCFrame = dropperPart.CFrame
                            obj:SetAttribute("Grabbed", false) 
                            obj:SetAttribute("LastHolder", LocalPlayer.Name)

                            if obj:IsA("BasePart") then
                                obj.CFrame = targetCFrame
                                obj.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            elseif obj:IsA("Model") then
                                obj:PivotTo(targetCFrame)
                                for _, part in ipairs(obj:GetDescendants()) do
                                    if part:IsA("BasePart") then part.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end
                                end
                            end
                            
                            if firetouchinterest then
                                local touchPart = obj:IsA("BasePart") and obj or obj.PrimaryPart
                                if touchPart then
                                    firetouchinterest(dropperPart, touchPart, 0) 
                                    task.wait()
                                    firetouchinterest(dropperPart, touchPart, 1) 
                                end
                            end
                            task.wait(0.1)
                        end
                    end
                end
                task.wait(0.1) 
            end
        end)
    end
end)

-- ====================================================================
-- [FITUR 3]: AUTO EAT (OPTIMIZED: INSTANT EAT VIA DYNAMIC ID)
-- ====================================================================
Win:AddToggle("Mulai Auto Eat", false, function(state)
    AutoEatEnabled = state
    
    if AutoEatEnabled then
        task.spawn(function()
            while AutoEatEnabled do
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    
                    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                    local foodFill = playerGui 
                        and playerGui:FindFirstChild("HUD") 
                        and playerGui.HUD:FindFirstChild("Food") 
                        and playerGui.HUD.Food:FindFirstChild("Bar") 
                        and playerGui.HUD.Food.Bar:FindFirstChild("Fill")
                    
                    -- Skrip hanya berjalan jika indikator makanan di bawah 30%
                    if foodFill and foodFill.Size.X.Scale <= 0.3 then
                        local workspace = game:GetService("Workspace")
                        local DebrisField = workspace:FindFirstChild("DebrisField")
                        
                        if DebrisField then
                            for _, obj in ipairs(DebrisField:GetChildren()) do
                                if not AutoEatEnabled then break end 
                                
                                -- Deteksi jika objek di laut memiliki attribute Food
                                if obj:GetAttribute("Food") then
                                    
                                    -- EXTRACT ID: Mengambil angka unik di antara titik dua (Contoh: "Burger:1781769071:3834" -> "1781769071")
                                    local foodId = string.match(obj.Name, ":(%d+)")
                                    
                                    -- Backup jika format nama berbeda, ambil angka apa saja yang tersedia di nama objek
                                    if not foodId then
                                        foodId = string.match(obj.Name, "%d+")
                                    end
                                    
                                    if foodId then
                                        -- Loop makan objek tersebut sampai indikator kenyang (X Scale >= 0.95)
                                        while foodFill.Size.X.Scale < 0.95 and AutoEatEnabled and obj.Parent do
                                            
                                            -- LANGSUNG EAT: Hanya menembak remote Eat menggunakan ID yang sudah dibersihkan
                                            SafeRemoteEvent("Eat", "~s" .. foodId)
                                            
                                            -- Jeda sangat singkat agar server sempat memproses penambahan indikator lapar
                                            task.wait(0.15) 
                                        end
                                    end
                                    
                                    -- Jika sudah kenyang, stop mencari makanan lain
                                    if foodFill.Size.X.Scale >= 0.95 then break end
                                end
                            end
                        end
                    end
                end
                task.wait(1) -- Cek status kelaparan setiap 1 detik
            end
        end)
    end
end)

-- ====================================================================
-- [FITUR 4]: AUTO INTERACT (CRAB TRAP FIX REMOTE & FOLDER DETECT)
-- ====================================================================
Win:AddToggle("Auto Harvest Crab Trap", false, function(state)
    AutoCrabTrapEnabled = state
    
    if AutoCrabTrapEnabled then
        task.spawn(function()
            while AutoCrabTrapEnabled do
                local workspace = game:GetService("Workspace")
                local SpawnIsland = workspace:FindFirstChild("SpawnIsland")
                
                if SpawnIsland then
                    -- Mencari folder tanpa takut error jika foldernya belum dibuat
                    local CraftedFolder = SpawnIsland:FindFirstChild("Crafted")
                    
                    if CraftedFolder then
                        for _, obj in ipairs(CraftedFolder:GetChildren()) do
                            
                            -- Mendeteksi otomatis Crab Trap yang angkanya selalu berubah-ubah
                            if string.find(string.lower(obj.Name), "crab trap") then
                                -- Mengeksekusi interaksi menggunakan RemoteEvent yang sudah ditemukan otomatis
                                SafeRemoteEvent("Interact", obj)
                                task.wait(0.3) -- Jeda aman agar tidak dikira spam oleh server
                            end
                            
                        end
                    end
                end
                
                -- Cek setiap 4 detik untuk melihat apakah ada trap baru yang siap dipanen
                task.wait(4) 
            end
        end)
    end
end)
