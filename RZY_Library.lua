local RZY_Library = {}

function RZY_Library:MakeWindow(TitleText)
    local CoreGui = game:GetService("CoreGui")
    
    if CoreGui:FindFirstChild("RZY_Hub") then
        CoreGui.RZY_Hub:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RZY_Hub"
    ScreenGui.Parent = CoreGui

    -- Ikon Logo RZY
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

    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(1, 0) 
    IconCorner.Parent = RZYIcon

    local IconStroke = Instance.new("UIStroke")
    IconStroke.Color = Color3.fromRGB(0, 170, 255)
    IconStroke.Thickness = 1.5
    IconStroke.Parent = RZYIcon

    -- Panel Utama
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -225)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) 
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true 
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(0, 170, 255) 
    MainStroke.Thickness = 1.5
    MainStroke.Parent = MainFrame

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    TopBar.Parent = MainFrame

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 8)
    TopCorner.Parent = TopBar

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

    -- [FITUR BARU] AddLabel
    function WindowElements:AddLabel(Text)
        local LabelFrame = Instance.new("Frame")
        LabelFrame.Size = UDim2.new(1, -10, 0, 30)
        LabelFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- Background sedikit lebih gelap
        LabelFrame.Parent = Container

        local LabelCorner = Instance.new("UICorner")
        LabelCorner.CornerRadius = UDim.new(0, 5)
        LabelCorner.Parent = LabelFrame

        local LabelStroke = Instance.new("UIStroke")
        LabelStroke.Color = Color3.fromRGB(0, 100, 150)
        LabelStroke.Thickness = 1
        LabelStroke.Parent = LabelFrame

        local TextLabel = Instance.new("TextLabel")
        TextLabel.Size = UDim2.new(1, -20, 1, 0)
        TextLabel.Position = UDim2.new(0, 10, 0, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.Text = Text
        TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        TextLabel.Font = Enum.Font.Gotham
        TextLabel.TextSize = 12
        TextLabel.TextWrapped = true
        TextLabel.TextXAlignment = Enum.TextXAlignment.Center
        TextLabel.Parent = LabelFrame

        local LabelHandler = {}
        function LabelHandler:Set(NewText)
            TextLabel.Text = NewText
        end
        return LabelHandler
    end

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

        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 5)
        ToggleCorner.Parent = ToggleBtn

        local ToggleStroke = Instance.new("UIStroke")
        ToggleStroke.Color = Color3.fromRGB(0, 100, 150)
        ToggleStroke.Thickness = 1
        ToggleStroke.Parent = ToggleBtn

        ToggleBtn.MouseButton1Click:Connect(function()
            state = not state
            UpdateVisuals()
            pcall(Callback, state)
        end)

        local ToggleHandler = {}
        function ToggleHandler:Set(Value)
            state = Value
            UpdateVisuals()
        end
        return ToggleHandler
    end

    function WindowElements:AddButton(Text, Callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, -10, 0, 35)
        Btn.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
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

    function WindowElements:AddInput(Text, Placeholder, Callback)
        local InputFrame = Instance.new("Frame")
        InputFrame.Size = UDim2.new(1, -10, 0, 40)
        InputFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        InputFrame.Parent = Container

        local InputCorner = Instance.new("UICorner")
        InputCorner.CornerRadius = UDim.new(0, 5)
        InputCorner.Parent = InputFrame

        local InputStroke = Instance.new("UIStroke")
        InputStroke.Color = Color3.fromRGB(0, 100, 150)
        InputStroke.Thickness = 1
        InputStroke.Parent = InputFrame

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.5, 0, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = Text
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = InputFrame

        local TextBox = Instance.new("TextBox")
        TextBox.Size = UDim2.new(0.4, 0, 0, 26)
        TextBox.Position = UDim2.new(0.6, -5, 0.5, -13)
        TextBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        TextBox.Text = ""
        TextBox.PlaceholderText = Placeholder or "Ketik..."
        TextBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
        TextBox.TextColor3 = Color3.fromRGB(0, 170, 255)
        TextBox.Font = Enum.Font.GothamBold
        TextBox.TextSize = 12
        TextBox.ClearTextOnFocus = true
        TextBox.Parent = InputFrame

        local TBCorner = Instance.new("UICorner")
        TBCorner.CornerRadius = UDim.new(0, 4)
        TBCorner.Parent = TextBox

        TextBox.FocusLost:Connect(function(enterPressed)
            pcall(Callback, TextBox.Text)
        end)
    end

    return WindowElements
end

return RZY_Library
