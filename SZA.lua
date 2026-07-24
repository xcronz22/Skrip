-- ==========================================
-- 1. BAGIAN LIBRARY UI (DITULIS LANGSUNG AGAR TIDAK ERROR/KOSONG)
-- ==========================================
local RZY_Library = {}

function RZY_Library:MakeWindow(TitleText)
    local TargetGui
    pcall(function()
        TargetGui = (gethui and gethui()) or game:GetService("CoreGui")
    end)
    if not TargetGui then
        TargetGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    
    if TargetGui:FindFirstChild("RZY_Hub") then
        TargetGui.RZY_Hub:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RZY_Hub"
    ScreenGui.Parent = TargetGui

    local RZYIcon = Instance.new("TextButton")
    RZYIcon.Size = UDim2.new(0, 50, 0, 50)
    RZYIcon.Position = UDim2.new(0.5, -25, 0, 20)
    RZYIcon.BackgroundColor3 = Color3.fromRGB(15, 15, 15) 
    RZYIcon.Text = "R Z Y" 
    RZYIcon.TextColor3 = Color3.fromRGB(0, 170, 255) 
    RZYIcon.TextSize = 13 
    RZYIcon.Font = Enum.Font.Gotham 
    RZYIcon.Visible = false 
    RZYIcon.Active = true
    RZYIcon.Draggable = true 
    RZYIcon.Parent = ScreenGui

    Instance.new("UICorner", RZYIcon).CornerRadius = UDim.new(1, 0) 
    local IconStroke = Instance.new("UIStroke", RZYIcon)
    IconStroke.Color = Color3.fromRGB(0, 170, 255)
    IconStroke.Thickness = 1.5

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -225)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) 
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true 
    MainFrame.Parent = ScreenGui

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = Color3.fromRGB(0, 170, 255) 
    MainStroke.Thickness = 1.5

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    TopBar.Parent = MainFrame
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

    local TopCover = Instance.new("Frame")
    TopCover.Size = UDim2.new(1, 0, 0, 10)
    TopCover.Position = UDim2.new(0, 0, 1, -10)
    TopCover.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    TopCover.BorderSizePixel = 0
    TopCover.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -90, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = TitleText 
    Title.TextColor3 = Color3.fromRGB(0, 170, 255) 
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.Parent = TopBar

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -70, 0, 5)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 24
    MinBtn.Parent = TopBar

    local Container = Instance.new("ScrollingFrame")
    Container.Size = UDim2.new(1, -20, 1, -55)
    Container.Position = UDim2.new(0, 10, 0, 45)
    Container.BackgroundTransparency = 1
    Container.ScrollBarThickness = 2
    Container.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
    Container.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.Parent = Container

    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 1000)
    end)

    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false RZYIcon.Visible = true end)
    RZYIcon.MouseButton1Click:Connect(function() MainFrame.Visible = true RZYIcon.Visible = false end)

    local WindowElements = {}

    function WindowElements:AddToggle(Text, DefaultState, Callback)
        local state = DefaultState or false
        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Size = UDim2.new(1, -10, 0, 35)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        ToggleBtn.Font = Enum.Font.GothamBold
        ToggleBtn.TextSize = 13
        ToggleBtn.Parent = Container

        local function UpdateVisuals()
            ToggleBtn.Text = Text .. (state and " [ON]" or " [OFF]")
            ToggleBtn.TextColor3 = state and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 100, 100)
        end
        UpdateVisuals()

        Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 5)
        local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
        ToggleStroke.Color = Color3.fromRGB(0, 100, 150)
        ToggleStroke.Thickness = 1

        ToggleBtn.MouseButton1Click:Connect(function()
            state = not state
            UpdateVisuals()
            pcall(Callback, state)
        end)

        return {
            Set = function(Value)
                state = Value
                UpdateVisuals()
            end
        }
    end
    
    return WindowElements
end


-- ==========================================
-- 2. BAGIAN SKRIP UTAMA (SZA SCRIPT)
-- ==========================================
local Window = RZY_Library:MakeWindow("SZA Script")

-- ==========================================
-- LAYANAN & REMOTE
-- ==========================================
local BloodmoonEvent = game:GetService("ReplicatedStorage").Remotes.EventRemotes.BloodmoonRequestSpin
local ArtifactEvent = game:GetService("ReplicatedStorage").Remotes.ArtifactCrateRemotes.Spin
local GunEvent = game:GetService("ReplicatedStorage").Remotes.NetRemotes.GunFire

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local AutoBloodmoon = false
local AutoArtifact = false
local AutoKill = false

-- Senjata mutlak yang akan selalu dikirim ke server meskipun tangan kosong
local SenjataUtama = "CosmicPistol"

-- ==========================================
-- TAMPILAN MENU (UI)
-- ==========================================
Window:AddToggle("Auto Bloodmoon Spin", false, function(state)
    AutoBloodmoon = state
end)

Window:AddToggle("Auto Artifact Spin", false, function(state)
    AutoArtifact = state
end)

Window:AddToggle("Auto Kill (Aura)", false, function(state)
    AutoKill = state
end)

-- ==========================================
-- MESIN BELAKANG (LOOPING TUGAS)
-- ==========================================

-- 1. Mesin Bloodmoon Spin (0.1 Detik)
task.spawn(function()
    while task.wait(0.1) do
        if AutoBloodmoon then
            pcall(function()
                BloodmoonEvent:InvokeServer()
            end)
        end
    end
end)

-- 2. Mesin Artifact Spin (0.1 Detik)
task.spawn(function()
    while task.wait(0.1) do
        if AutoArtifact then
            pcall(function()
                ArtifactEvent:InvokeServer("Standard", 5)
            end)
        end
    end
end)

-- 3. Mesin Auto Kill (Tanpa Pegang Senjata)
task.spawn(function()
    while task.wait(0.04) do
        if AutoKill then
            pcall(function()
                local zombiesFolder = Workspace:FindFirstChild("Zombies_Local")
                local character = LocalPlayer.Character
                
                -- Hanya mengecek folder zombie dan keberadaan tubuh kita (tidak mengecek Tool)
                if zombiesFolder and character and character:FindFirstChild("HumanoidRootPart") then
                    
                    local myPos = character.HumanoidRootPart.Position
                    
                    for _, zombie in pairs(zombiesFolder:GetChildren()) do
                        local targetPart = zombie:FindFirstChild("HumanoidRootPart")
                        
                        if targetPart then
                            local targetPos = targetPart.Position
                            local direction = (targetPos - myPos).Unit
                            
                            -- Mengirimkan tembakan langsung ke semua zombie secara otomatis
                            GunEvent:FireServer(SenjataUtama, targetPos, direction)
                        end
                    end
                    
                end
            end)
        end
    end
end)
