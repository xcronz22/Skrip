local RZY_Library = {}

function RZY_Library:MakeWindow(TitleText)
    local CoreGui = game:GetService("CoreGui")
    
    if CoreGui:FindFirstChild("RZY_Hub") then
        CoreGui.RZY_Hub:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RZY_Hub"
    ScreenGui.Parent = CoreGui

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

    function WindowElements:AddLabel(Text)
        local LabelFrame = Instance.new("Frame")
        LabelFrame.Size = UDim2.new(1, -10, 0, 30)
        LabelFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        LabelFrame.Parent = Container

        Instance.new("UICorner", LabelFrame).CornerRadius = UDim.new(0, 5)
        local LabelStroke = Instance.new("UIStroke", LabelFrame)
        LabelStroke.Color = Color3.fromRGB(0, 100, 150)
        LabelStroke.Thickness = 1

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

    -- [FITUR BARU] AddDropdown
    function WindowElements:AddDropdown(Text, Options, Callback)
        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Size = UDim2.new(1, -10, 0, 35)
        DropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        DropdownFrame.ClipsDescendants = true
        DropdownFrame.Parent = Container

        Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 5)
        local UIStroke = Instance.new("UIStroke", DropdownFrame)
        UIStroke.Color = Color3.fromRGB(0, 100, 150)
        UIStroke.Thickness = 1

        local TitleBtn = Instance.new("TextButton")
        TitleBtn.Size = UDim2.new(1, 0, 0, 35)
        TitleBtn.BackgroundTransparency = 1
        TitleBtn.Text = Text .. " ▼"
        TitleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleBtn.Font = Enum.Font.GothamBold
        TitleBtn.TextSize = 12
        TitleBtn.Parent = DropdownFrame

        local DropdownList = Instance.new("ScrollingFrame")
        DropdownList.Size = UDim2.new(1, -10, 1, -40)
        DropdownList.Position = UDim2.new(0, 5, 0, 35)
        DropdownList.BackgroundTransparency = 1
        DropdownList.ScrollBarThickness = 2
        DropdownList.Parent = DropdownFrame

        local ListLayout = Instance.new("UIListLayout", DropdownList)
        ListLayout.Padding = UDim.new(0, 4)
        ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local isOpen = false
        TitleBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            if isOpen then
                DropdownFrame.Size = UDim2.new(1, -10, 0, 140) -- Buka
                TitleBtn.Text = Text .. " ▲"
            else
                DropdownFrame.Size = UDim2.new(1, -10, 0, 35) -- Tutup
                TitleBtn.Text = Text .. " ▼"
            end
        end)

        for _, option in ipairs(Options) do
            local OptBtn = Instance.new("TextButton")
            OptBtn.Size = UDim2.new(1, 0, 0, 25)
            OptBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            OptBtn.Text = option
            OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            OptBtn.Font = Enum.Font.Gotham
            OptBtn.TextSize = 12
            OptBtn.Parent = DropdownList
            Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 4)

            OptBtn.MouseButton1Click:Connect(function()
                TitleBtn.Text = Text .. " : " .. option
                isOpen = false
                DropdownFrame.Size = UDim2.new(1, -10, 0, 35)
                pcall(Callback, option)
            end)
        end

        ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            DropdownList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
        end)
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

        Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 5)
        local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
        ToggleStroke.Color = Color3.fromRGB(0, 100, 150)
        ToggleStroke.Thickness = 1

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

        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 5)

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

        Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 5)
        local InputStroke = Instance.new("UIStroke", InputFrame)
        InputStroke.Color = Color3.fromRGB(0, 100, 150)
        InputStroke.Thickness = 1

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

        Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 4)

        TextBox.FocusLost:Connect(function(enterPressed)
            pcall(Callback, TextBox.Text)
        end)
        
        local InputHandler = {}
        function InputHandler:Set(NewText)
            TextBox.Text = NewText
        end
        return InputHandler
    end

        -- [FITUR BARU] AddMultiDropdown (Banyak Pilihan dengan Centang)
    function WindowElements:AddMultiDropdown(Text, Options, Callback)
        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Size = UDim2.new(1, -10, 0, 35)
        DropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        DropdownFrame.ClipsDescendants = true
        DropdownFrame.Parent = Container

        Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 5)
        local UIStroke = Instance.new("UIStroke", DropdownFrame)
        UIStroke.Color = Color3.fromRGB(0, 100, 150)
        UIStroke.Thickness = 1

        local TitleBtn = Instance.new("TextButton")
        TitleBtn.Size = UDim2.new(1, 0, 0, 35)
        TitleBtn.BackgroundTransparency = 1
        TitleBtn.Text = Text .. " ▼"
        TitleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleBtn.Font = Enum.Font.GothamBold
        TitleBtn.TextSize = 12
        TitleBtn.Parent = DropdownFrame

        local DropdownList = Instance.new("ScrollingFrame")
        DropdownList.Size = UDim2.new(1, -10, 1, -40)
        DropdownList.Position = UDim2.new(0, 5, 0, 35)
        DropdownList.BackgroundTransparency = 1
        DropdownList.ScrollBarThickness = 2
        DropdownList.Parent = DropdownFrame

        local ListLayout = Instance.new("UIListLayout", DropdownList)
        ListLayout.Padding = UDim.new(0, 4)
        ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local isOpen = false
        TitleBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            if isOpen then
                DropdownFrame.Size = UDim2.new(1, -10, 0, 140) -- Buka
                TitleBtn.Text = Text .. " ▲"
            else
                DropdownFrame.Size = UDim2.new(1, -10, 0, 35) -- Tutup
                TitleBtn.Text = Text .. " ▼"
            end
        end)

        -- Menyimpan status pilihan (centang/tidak)
        local SelectedOptions = {}

        for _, option in ipairs(Options) do
            SelectedOptions[option] = false -- Default belum tercentang

            local OptBtn = Instance.new("TextButton")
            OptBtn.Size = UDim2.new(1, 0, 0, 25)
            OptBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            OptBtn.Text = option
            OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            OptBtn.Font = Enum.Font.Gotham
            OptBtn.TextSize = 12
            OptBtn.Parent = DropdownList
            Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 4)

            -- Fungsi ketika opsi diklik
            OptBtn.MouseButton1Click:Connect(function()
                SelectedOptions[option] = not SelectedOptions[option]
                
                if SelectedOptions[option] then
                    OptBtn.Text = "✅ " .. option
                    OptBtn.TextColor3 = Color3.fromRGB(0, 255, 100)
                else
                    OptBtn.Text = option
                    OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
                
                -- Kirim table status terbaru ke skrip utama
                pcall(Callback, SelectedOptions)
            end)
        end

        ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            DropdownList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
        end)
    end
    
    return WindowElements
end

return RZY_Library
