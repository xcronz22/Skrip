local RZY_Library = {}

function RZY_Library:MakeWindow(TitleText)
    local CoreGui = game:GetService("CoreGui")
    
    -- Bersihkan GUI lama kalau di-execute ulang (biar nggak numpuk)
    if CoreGui:FindFirstChild("RZY_Hub") then
        CoreGui.RZY_Hub:Destroy()
    end

    -- ==========================================
    -- 1. PEMBUATAN SCREEN GUI & LOGO MINIMIZE
    -- ==========================================
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RZY_Hub"
    ScreenGui.Parent = CoreGui

    -- Ikon Logo RZY (Saat di-minimize)
    local RZYIcon = Instance.new("TextButton")
    RZYIcon.Size = UDim2.new(0, 50, 0, 50)
    RZYIcon.Position = UDim2.new(0.5, -25, 0, 20)
    RZYIcon.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Hitam gelap
    RZYIcon.Text = "RZY"
    RZYIcon.TextColor3 = Color3.fromRGB(0, 170, 255) -- Biru Neon
    RZYIcon.TextSize = 18
    RZYIcon.Font = Enum.Font.GothamBlack
    RZYIcon.Visible = false -- Disembunyikan saat panel utama terbuka
    RZYIcon.Active = true
    RZYIcon.Draggable = true -- Bisa digeser
    RZYIcon.Parent = ScreenGui

    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(1, 0) -- Bikin bulat sempurna
    IconCorner.Parent = RZYIcon

    local IconStroke = Instance.new("UIStroke")
    IconStroke.Color = Color3.fromRGB(0, 170, 255)
    IconStroke.Thickness = 2
    IconStroke.Parent = RZYIcon

    -- ==========================================
    -- 2. PEMBUATAN PANEL UTAMA
    -- ==========================================
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -225)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Hitam
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true -- Bisa digeser
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(0, 170, 255) -- Garis pinggir biru
    MainStroke.Thickness = 1.5
    MainStroke.Parent = MainFrame

    -- ==========================================
    -- 3. BAGIAN ATAS (TOP BAR & TOMBOL)
    -- ==========================================
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    TopBar.Parent = MainFrame

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 8)
    TopCorner.Parent = TopBar

    -- Menutupi sudut bawah TopBar agar rata dengan MainFrame
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
    Title.Text = TitleText -- NAMA JUDUL DINAMIS DARI LUAR
    Title.TextColor3 = Color3.fromRGB(0, 170, 255) -- Biru
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    -- Tombol Close
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.Parent = TopBar

    -- Tombol Minimize
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -70, 0, 5)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 24
    MinBtn.Parent = TopBar

    -- ==========================================
    -- 4. CONTAINER UNTUK DAFTAR TOMBOL
    -- ==========================================
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
        Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 200)
    end)

    -- ==========================================
    -- 5. LOGIK FUNGSI MINIMIZE & CLOSE
    -- ==========================================
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    MinBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        RZYIcon.Visible = true
    end)

    RZYIcon.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        RZYIcon.Visible = false
    end)

    -- ==========================================
    -- 6. FUNGSI UNTUK MENAMBAH FITUR KE DALAM PANEL
    -- ==========================================
    local WindowElements = {}

    -- Cetakan untuk Toggle (On/Off)
    function WindowElements:AddToggle(Text, DefaultState, Callback)
        local state = DefaultState or false

        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Size = UDim2.new(1, -10, 0, 35)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        ToggleBtn.Text = Text .. (state and " [ON]" or " [OFF]")
        ToggleBtn.TextColor3 = state and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 100, 100)
        ToggleBtn.Font = Enum.Font.GothamBold
        ToggleBtn.TextSize = 13
        ToggleBtn.Parent = Container

        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 5)
        ToggleCorner.Parent = ToggleBtn

        local ToggleStroke = Instance.new("UIStroke")
        ToggleStroke.Color = Color3.fromRGB(0, 100, 150)
        ToggleStroke.Thickness = 1
        ToggleStroke.Parent = ToggleBtn

        ToggleBtn.MouseButton1Click:Connect(function()
            state = not state
            ToggleBtn.Text = Text .. (state and " [ON]" or " [OFF]")
            ToggleBtn.TextColor3 = state and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 100, 100)
            
            -- Panggil fungsi yang ada di script luar
            pcall(Callback, state)
        end)
    end

    -- Cetakan untuk Tombol Biasa (Sekali Tekan)
    function WindowElements:AddButton(Text, Callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, -10, 0, 35)
        Btn.BackgroundColor3 = Color3.fromRGB(0, 100, 180) -- Biru RZY
        Btn.Text = Text
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 13
        Btn.Parent = Container

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 5)
        BtnCorner.Parent = Btn

        Btn.MouseButton1Click:Connect(function()
            Btn.Text = "Loading..."
            task.spawn(function()
                pcall(Callback)
                task.wait(0.5)
                Btn.Text = Text
            end)
        end)
    end

    return WindowElements
end

return RZY_Library
