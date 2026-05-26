-- Heaven Line Final (Clean + Scrollable GUI + Revenge Dropdown + Header + Color + Auto Update Bot/Player + Close Button + Modern UI)
-- by ChatGPT

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

-- Remote Events
local Events = ReplicatedStorage:WaitForChild("Events")
local cutLineEvent = Events:WaitForChild("moveUpInQueue")
local claimRewardEvent = Events:WaitForChild("claimReward")
local enterHeavenEvent = Events:WaitForChild("enterHeaven")
local rebirthEvent = Events:WaitForChild("rebirth")
local swordHitEvent = Events:WaitForChild("swordHit")

-- Flags
local autoCutline = false
local autoEnterExit = false
local autoKill = false
local autoInfSmite = false
local antiLagLoop = true

-- GUI Config
local BASE_HEIGHT = 400
local HEADER_HEIGHT = 30
local BUTTON_HEIGHT = 40

-- === FUNCTIONS ===
-- AntiLag
local function applyAntiLag()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = false
        elseif obj:IsA("PointLight") or obj:IsA("SurfaceLight") or obj:IsA("SpotLight") then
            obj.Enabled = false
        elseif obj:IsA("MeshPart") and obj.Material == Enum.Material.Neon then
            obj.Material = Enum.Material.Plastic
        end
    end
    pcall(function()
        Lighting.FogEnd = 100000
        local atm = Lighting:FindFirstChildOfClass("Atmosphere")
        if atm then atm:Destroy() end
    end)
end

local function antiLagLoopFunc()
    task.spawn(function()
        while antiLagLoop do
            applyAntiLag()
            task.wait(60)
        end
    end)
end

-- Auto Cutline
local function startAutoCutline()
    task.spawn(function()
        while autoCutline do
            pcall(function() cutLineEvent:FireServer(2,5) end)
            task.wait(0.05)
        end
    end)
end

-- Auto Enter+Exit
local function startAutoEnterExit()
    task.spawn(function()
        while autoEnterExit do
            pcall(function() enterHeavenEvent:FireServer() end)
            task.wait(0.1)
            pcall(function() rebirthEvent:FireServer() end)
            task.wait(0.1)
        end
    end)
end

-- Auto Kill Bot
local function autoKillLoop()
    task.spawn(function()
        while autoKill do
            local myChar = player.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                if workspace:FindFirstChild("Bots") then
                    for _, bot in ipairs(workspace.Bots:GetChildren()) do
                        if not autoKill then break end
                        if bot:FindFirstChild("HumanoidRootPart") then
                            pcall(function()
                                swordHitEvent:FireServer(bot)
                            end)
                            task.wait(0.5)
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

-- Auto Inf Smite
local function startInfSmiteLoop()
    task.spawn(function()
        while autoInfSmite do
            pcall(function()
                claimRewardEvent:FireServer("giftSmite")
                task.wait(0.5)
                claimRewardEvent:FireServer("giftSmite2")
            end)
            task.wait(0.5)
        end
    end)
end

-- === GUI ===
-- Hapus GUI lama kalau ada
local oldGui = player.PlayerGui:FindFirstChild("HeavenLineGUI")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HeavenLineGUI"
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0,200,0,BASE_HEIGHT)
Frame.Position = UDim2.new(0.05,0,0.2,0)
Frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.ClipsDescendants = true
Frame.Parent = ScreenGui

-- Rounded + Stroke + Gradient
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0,12)
UICorner.Parent = Frame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(200,200,200)
UIStroke.Parent = Frame

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50,50,50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25,25,25))
}
gradient.Rotation = 90
gradient.Parent = Frame

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,HEADER_HEIGHT)
Header.BackgroundColor3 = Color3.fromRGB(30,30,30)
Header.Parent = Frame
local hCorner = Instance.new("UICorner") hCorner.CornerRadius = UDim.new(0,12) hCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-40,1,0)
Title.Position = UDim2.new(0,10,0,0)
Title.BackgroundTransparency = 1
Title.Text = "Heaven Line"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Content Scrollable
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1,0,1,-HEADER_HEIGHT)
Content.Position = UDim2.new(0,0,0,HEADER_HEIGHT)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 6
Content.CanvasSize = UDim2.new(0,0,0,0)
Content.Parent = Frame
local contentLayout = Instance.new("UIListLayout")
contentLayout.Parent = Content
contentLayout.Padding = UDim.new(0,5)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Content.CanvasSize = UDim2.new(0,0,0,contentLayout.AbsoluteContentSize.Y)
end)

-- === Minimize / Maximize ===
local minimized = false
local miniBtn = Instance.new("TextButton")
miniBtn.Size = UDim2.new(0,30,0,24)
miniBtn.Position = UDim2.new(1,-34,0,3)
miniBtn.Text = "-"
miniBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
miniBtn.TextColor3 = Color3.new(1,1,1)
miniBtn.Font = Enum.Font.GothamBold
miniBtn.TextSize = 18
miniBtn.Parent = Header
local mCorner = Instance.new("UICorner") mCorner.CornerRadius = UDim.new(0,8) mCorner.Parent = miniBtn

miniBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Content.Visible = not minimized
    miniBtn.Text = minimized and "+" or "-"
    Frame:TweenSize(
        UDim2.new(0,200,0, minimized and HEADER_HEIGHT or BASE_HEIGHT),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,
        0.2,
        true
    )
end)

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,30,0,24)
closeBtn.Position = UDim2.new(1,-68,0,3)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(150,40,40)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = Header
local cCorner = Instance.new("UICorner") cCorner.CornerRadius = UDim.new(0,8) cCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    autoCutline, autoEnterExit, autoKill, autoInfSmite, antiLagLoop = false,false,false,false,false
    ScreenGui:Destroy()
end)

-- Button Factory (modern)
local function createToggleButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-20,0,BUTTON_HEIGHT)
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.Text = text.." [OFF]"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.Parent = Content
    local bCorner = Instance.new("UICorner") bCorner.CornerRadius = UDim.new(0,10) bCorner.Parent = btn

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.Text = text.." [ON]"
            btn.BackgroundColor3 = Color3.fromRGB(0,120,0)
            callback(true)
        else
            btn.Text = text.." [OFF]"
            btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
            callback(false)
        end
    end)

    btn.MouseEnter:Connect(function()
        if not state then btn.BackgroundColor3 = Color3.fromRGB(80,80,80) end
    end)
    btn.MouseLeave:Connect(function()
        if not state then btn.BackgroundColor3 = Color3.fromRGB(60,60,60) end
    end)

    return btn
end

-- BUTTONS
createToggleButton("Auto Cutline",function(v) autoCutline = v if v then startAutoCutline() end end)
createToggleButton("Auto Enter+Exit",function(v) autoEnterExit = v if v then startAutoEnterExit() end end)
createToggleButton("Auto Kill Bot",function(v) autoKill = v if v then autoKillLoop() end end)
createToggleButton("Inf Smite Loop",function(v) autoInfSmite = v if v then startInfSmiteLoop() end end)

-- Revenge Dropdown
local revengeFrame = Instance.new("Frame")
revengeFrame.Size = UDim2.new(1,-20,0,160)
revengeFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
revengeFrame.Parent = Content
local rCorner = Instance.new("UICorner") rCorner.CornerRadius = UDim.new(0,10) rCorner.Parent = revengeFrame

local revengeTitle = Instance.new("TextLabel")
revengeTitle.Size = UDim2.new(1,0,0,20)
revengeTitle.BackgroundColor3 = Color3.fromRGB(50,50,50)
revengeTitle.Text = "Revenge Target"
revengeTitle.TextColor3 = Color3.new(1,1,1)
revengeTitle.Font = Enum.Font.GothamBold
revengeTitle.TextSize = 14
revengeTitle.Parent = revengeFrame
local rtCorner = Instance.new("UICorner") rtCorner.CornerRadius = UDim.new(0,10) rtCorner.Parent = revengeTitle

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,-8,1,-28)
scroll.Position = UDim2.new(0,4,0,24)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1
scroll.Parent = revengeFrame
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = scroll
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function createRevengeButton(name,obj,isBot)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-4,0,26)
    btn.BackgroundColor3 = isBot and Color3.fromRGB(150,40,40) or Color3.fromRGB(40,90,160)
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = scroll
    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0,8) corner.Parent = btn
    local stroke = Instance.new("UIStroke") stroke.Color = Color3.fromRGB(255,255,255) stroke.Thickness = 1 stroke.Parent = btn

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = isBot and Color3.fromRGB(180,60,60) or Color3.fromRGB(60,120,200)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = isBot and Color3.fromRGB(150,40,40) or Color3.fromRGB(40,90,160)
    end)

    btn.MouseButton1Click:Connect(function()
        pcall(function()
            swordHitEvent:FireServer(obj)
        end)
    end)
end

local function updateRevengeList()
    for _, child in ipairs(scroll:GetChildren()) do
        if not child:IsA("UIListLayout") then child:Destroy() end
    end
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and obj.Name ~= player.Name then
            createRevengeButton(obj.Name, obj, false)
        end
    end
    if workspace:FindFirstChild("Bots") then
        for _, bot in ipairs(workspace.Bots:GetChildren()) do
            if bot:FindFirstChild("HumanoidRootPart") then
                createRevengeButton("[BOT] "..bot.Name, bot, true)
            end
        end
    end
    scroll.CanvasSize = UDim2.new(0,0,0,UIListLayout.AbsoluteContentSize.Y)
end

task.spawn(function()
    while true do
        updateRevengeList()
        task.wait(5)
    end
end)

-- Auto Claim Reward
local function autoClaimRewardLoop()
    task.spawn(function()
        while true do
            pcall(function()
                claimRewardEvent:FireServer("gift250MillDuration")
                task.wait(0.5)
                claimRewardEvent:FireServer("gift1")
                task.wait(0.5)
                claimRewardEvent:FireServer("giftHalo")
                task.wait(0.5)
                claimRewardEvent:FireServer("giftWings")
                task.wait(0.5)
                claimRewardEvent:FireServer("gift2")
                task.wait(0.5)
                claimRewardEvent:FireServer("giftGodTitle")
            end)
            task.wait(30)
        end
    end)
end

-- AUTO START
antiLagLoopFunc()
autoClaimRewardLoop()

-- === Anti AFK (langsung aktif) ===
local VirtualUser = game:GetService("VirtualUser")

player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
