-- SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- STATE VARIABLES
local autoMoveActive = false
local uiScreen = nil

-- HAPUS PANEL LAMA JIKA ADA (Biar gak tumpang tindih saat di-execute ulang)
if PlayerGui:FindFirstChild("ETW_TestPanel") then
    PlayerGui["ETW_TestPanel"]:Destroy()
end

-- ==========================================
-- 1. SEKTOR PEMBUATAN UI (LIGHTWEIGHT)
-- ==========================================
uiScreen = Instance.new("ScreenGui")
uiScreen.Name = "ETW_TestPanel"
uiScreen.ResetOnSpawn = false
uiScreen.Parent = PlayerGui

-- MAIN PANEL
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 140)
MainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Fitur drag bawaan biar bisa digeser
MainFrame.Parent = uiScreen

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = MainFrame

-- TITLE BAR
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 140, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ETW Tool - Test"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- MINIMIZE BUTTON (_)
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -60, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "_"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 18
MinBtn.Parent = MainFrame

-- CLOSE BUTTON (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 16
CloseBtn.Parent = MainFrame

-- TOGGLE AUTO MOVE BUTTON
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 180, 0, 40)
ToggleBtn.Position = UDim2.new(0, 20, 0, 60)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleBtn.Text = "Auto Move: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 16
ToggleBtn.Parent = MainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = ToggleBtn

-- SMALL MINIMIZE ICON (Muncul saat di-minimize)
local MinIcon = Instance.new("TextButton")
MinIcon.Name = "MinIcon"
MinIcon.Size = UDim2.new(0, 40, 0, 40)
MinIcon.Position = UDim2.new(0.1, 0, 0.3, 0) -- Posisi awal sama dengan panel
MinIcon.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MinIcon.Text = "ETW"
MinIcon.TextColor3 = Color3.fromRGB(0, 255, 150)
MinIcon.Font = Enum.Font.SourceSansBold
MinIcon.TextSize = 14
MinIcon.Visible = false
MinIcon.Active = true
MinIcon.Draggable = true
MinIcon.Parent = uiScreen

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(0, 20) -- Bikin bentuk bulat lingkaran
iconCorner.Parent = MinIcon


-- ==========================================
-- 2. LOGIKA FITUR UI (MINIMIZE & CLOSE)
-- ==========================================
MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MinIcon.Position = MainFrame.Position -- Mengikuti posisi terakhir panel
    MinIcon.Visible = true
end)

MinIcon.MouseButton1Click:Connect(function()
    MinIcon.Visible = false
    MainFrame.Position = MinIcon.Position -- Mengikuti posisi terakhir ikon
    MainFrame.Visible = true
end)

CloseBtn.MouseButton1Click:Connect(function()
    autoMoveActive = false -- Matikan loop pergerakan
    uiScreen:Destroy() -- Hapus UI total dari game
end)


-- ==========================================
-- 3. LOGIKA TOGGLE & AUTO MOVE TEST
-- ==========================================
ToggleBtn.MouseButton1Click:Connect(function()
    autoMoveActive = not autoMoveActive
    
    if autoMoveActive then
        ToggleBtn.Text = "Auto Move: ON"
        ToggleBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 70, 40)
    else
        ToggleBtn.Text = "Auto Move: OFF"
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

-- LOOP UTAMA UNTUK TES PERGERAKAN ALAMI
task.spawn(function()
    while uiScreen and uiScreen.Parent do
        task.wait(0.5)
        
        if autoMoveActive then
            local Character = LocalPlayer.Character
            if Character then
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                local RootPart = Character:FindFirstChild("HumanoidRootPart")
                
                if Humanoid and RootPart and Humanoid.Health > 0 then
                    -- Membuat koordinat acak berjarak sekitar 15-20 stud dari posisi karakter saat ini
                    local randomX = math.random(-20, 20)
                    local randomZ = math.random(-20, 20)
                    local targetPosition = RootPart.Position + Vector3.new(randomX, 0, randomZ)
                    
                    -- Perintahkan karakter berjalan ke titik tersebut
                    Humanoid:MoveTo(targetPosition)
                    
                    -- Tunggu sampai karakter sampai atau macet selama maksimal 5 detik sebelum mencari titik baru
                    local arrived = false
                    local connection
                    
                    connection = Humanoid.MoveToFinished:Connect(function()
                        arrived = true
                    end)
                    
                    -- Timeout guard (biar gak nyangkut selamanya kalau nabrak tembok)
                    local startTime = tick()
                    while not arrived and autoMoveActive do
                        task.wait(0.1)
                        if tick() - startTime > 5 then break end
                    end
                    
                    if connection then connection:Disconnect() end
                end
            end
        end
    end
end)
