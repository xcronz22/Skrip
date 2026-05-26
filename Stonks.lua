-- ==========================================
-- TUNGGU GAME LOADING (UNTUK AUTOEXEC DELTA)
-- ==========================================
if not game:IsLoaded() then game.Loaded:Wait() end

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- ==========================================
-- 1. UNIVERSAL AUTO REJOIN (ANTI KICK 291/279)
-- ==========================================
local function HandleErrorPrompt(child)
	if child.Name == 'ErrorPrompt' then
		print("[AUTO REJOIN] Terdeteksi Error/Kick! Mencoba rejoin dalam 5 detik...")
		task.wait(5)
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end
end

local promptOverlay = CoreGui:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")
promptOverlay.ChildAdded:Connect(HandleErrorPrompt)
for _, child in ipairs(promptOverlay:GetChildren()) do
	HandleErrorPrompt(child)
end

-- ==========================================
-- VARIABEL UTAMA & DATA SAHAM
-- ==========================================
local isLoadedComplety = false -- PERBAIKAN: Penjaga agar config tidak tertimpa saat awal mulai
local isAutoTrading = false
local isAutoSelling = false
local isMinimized = false
local isDropdownOpen = false
local tradePhase = "PREPARE"
local guardEndTime = 0
local SaveFileName = "StonksBot_Config.json"

local shares = {
	{Name = "RZY", ID = 86724784390911},
	{Name = "rzkym22's Place", ID = 10709518235},
}
local selectedShareID = shares[1].ID
local selectedShareName = shares[1].Name

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ==========================================
-- Pembuatan UI Utama (MainFrame)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StonksPanel"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -180)
MainFrame.Size = UDim2.new(0, 200, 0, 360) 
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true 

local Title = Instance.new("TextLabel", MainFrame)
Title.Text = "Pump & Smart Dump"
Title.Size = UDim2.new(1, -60, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.TextColor3 = Color3.new(1, 1, 1)

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Text = "X"; CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local MinBtn = Instance.new("TextButton", MainFrame)
MinBtn.Text = "-"; MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(1, -60, 0, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80); MinBtn.TextColor3 = Color3.new(1, 1, 1)

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Name = "Content"
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 0, 0, 30)
ContentFrame.Size = UDim2.new(1, 0, 1, -30)

-- ==========================================
-- ELEMENT KONTEN
-- ==========================================
local DropdownBtn = Instance.new("TextButton", ContentFrame)
DropdownBtn.Text = "Saham: " .. selectedShareName
DropdownBtn.Size = UDim2.new(0, 180, 0, 30); DropdownBtn.Position = UDim2.new(0, 10, 0, 10)
DropdownBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); DropdownBtn.TextColor3 = Color3.new(1, 1, 1)

local DropdownList = Instance.new("ScrollingFrame", ContentFrame)
DropdownList.Size = UDim2.new(0, 180, 0, 120); DropdownList.Position = UDim2.new(0, 10, 0, 40)
DropdownList.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
DropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y; DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
DropdownList.ScrollBarThickness = 6; DropdownList.ZIndex = 10; DropdownList.Visible = false
local UIListLayout = Instance.new("UIListLayout", DropdownList)

local TargetPriceInput = Instance.new("TextBox", ContentFrame)
TargetPriceInput.PlaceholderText = "Target Harga Puncak"; TargetPriceInput.Size = UDim2.new(0, 180, 0, 30)
TargetPriceInput.Position = UDim2.new(0, 10, 0, 50); TargetPriceInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TargetPriceInput.TextColor3 = Color3.new(0, 0, 0)

local MinSharesInput = Instance.new("TextBox", ContentFrame)
MinSharesInput.PlaceholderText = "Sisa Saham (Jaga-jaga)"; MinSharesInput.Size = UDim2.new(0, 180, 0, 30)
MinSharesInput.Position = UDim2.new(0, 10, 0, 90); MinSharesInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MinSharesInput.TextColor3 = Color3.new(0, 0, 0)

local MinPointsInput = Instance.new("TextBox", ContentFrame)
MinPointsInput.PlaceholderText = "Sisa Point (Jaga-jaga)"; MinPointsInput.Size = UDim2.new(0, 180, 0, 30)
MinPointsInput.Position = UDim2.new(0, 10, 0, 130); MinPointsInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MinPointsInput.TextColor3 = Color3.new(0, 0, 0)

local PhaseLabel = Instance.new("TextLabel", ContentFrame)
PhaseLabel.Text = "Status: " .. tradePhase
PhaseLabel.Size = UDim2.new(0, 180, 0, 20); PhaseLabel.Position = UDim2.new(0, 10, 0, 170)
PhaseLabel.BackgroundTransparency = 1; PhaseLabel.TextColor3 = Color3.new(1, 1, 0)

local BtnPrep = Instance.new("TextButton", ContentFrame)
BtnPrep.Text = "PREP"; BtnPrep.Size = UDim2.new(0, 55, 0, 25); BtnPrep.Position = UDim2.new(0, 10, 0, 195)
BtnPrep.BackgroundColor3 = Color3.fromRGB(100, 100, 100); BtnPrep.TextColor3 = Color3.new(1,1,1)

local BtnPump = Instance.new("TextButton", ContentFrame)
BtnPump.Text = "PUMP"; BtnPump.Size = UDim2.new(0, 55, 0, 25); BtnPump.Position = UDim2.new(0, 72, 0, 195)
BtnPump.BackgroundColor3 = Color3.fromRGB(0, 150, 0); BtnPump.TextColor3 = Color3.new(1,1,1)

local BtnDump = Instance.new("TextButton", ContentFrame)
BtnDump.Text = "DUMP"; BtnDump.Size = UDim2.new(0, 55, 0, 25); BtnDump.Position = UDim2.new(0, 135, 0, 195)
BtnDump.BackgroundColor3 = Color3.fromRGB(150, 0, 0); BtnDump.TextColor3 = Color3.new(1,1,1)

local AutoTradeBtn = Instance.new("TextButton", ContentFrame)
AutoTradeBtn.Text = "START PUMP & DUMP"
AutoTradeBtn.Size = UDim2.new(0, 180, 0, 40); AutoTradeBtn.Position = UDim2.new(0, 10, 0, 230)
AutoTradeBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0); AutoTradeBtn.TextColor3 = Color3.new(1, 1, 1)
AutoTradeBtn.Font = Enum.Font.SourceSansBold

local AutoSellBtn = Instance.new("TextButton", ContentFrame)
AutoSellBtn.Text = "HOLD PRICE (SELL 1)"
AutoSellBtn.Size = UDim2.new(0, 180, 0, 40); AutoSellBtn.Position = UDim2.new(0, 10, 0, 280)
AutoSellBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 150); AutoSellBtn.TextColor3 = Color3.new(1, 1, 1)
AutoSellBtn.Font = Enum.Font.SourceSansBold

-- ==========================================
-- 2. AUTO SAVE & LOAD CONFIG 
-- ==========================================
local function SaveConfig()
	if not isLoadedComplety then return end -- PERBAIKAN: Stop over-write file config sebelum init selesai
	local data = {
		TargetPrice = TargetPriceInput.Text or "1000",
		MinShares = MinSharesInput.Text or "1000000",
		MinPoints = MinPointsInput.Text or "100000000",
		AutoTrade = isAutoTrading,
		SelectedShareID = selectedShareID,
		SelectedShareName = selectedShareName,
		TradePhase = tradePhase,
		SavedShares = shares
	}
	if writefile then
		pcall(function() writefile(SaveFileName, HttpService:JSONEncode(data)) end)
	end
end

local function LoadConfig()
	if isfile and isfile(SaveFileName) and readfile then
		local success, result = pcall(function()
			return HttpService:JSONDecode(readfile(SaveFileName))
		end)
		if success and result then
			if result.SavedShares then shares = result.SavedShares end
			selectedShareID = tonumber(result.SelectedShareID) or shares[1].ID
			selectedShareName = result.SelectedShareName or shares[1].Name
			tradePhase = result.TradePhase or "PREPARE"
			return result
		end
	end
	return nil
end

local configData = LoadConfig()

if configData then
	TargetPriceInput.Text = tostring(configData.TargetPrice or "1000")
	MinSharesInput.Text = tostring(configData.MinShares or "1000000")
	MinPointsInput.Text = tostring(configData.MinPoints or "100000000")
	DropdownBtn.Text = "Saham: " .. tostring(selectedShareName) -- PERBAIKAN: Paksa visual UI sinkron dengan saham yg di-load
end

isLoadedComplety = true -- Buka kunci penyimpanan config

-- ==========================================
-- LOGIKA UPDATE FASA & HIGHLIGHT VISUAL
-- ==========================================
local function UpdatePhase(newPhase)
	tradePhase = newPhase
	PhaseLabel.Text = "Status: " .. tradePhase
	
	BtnPrep.BorderSizePixel = (tradePhase == "PREPARE") and 2 or 0
	BtnPrep.BorderColor3 = Color3.fromRGB(255, 255, 255)
	
	BtnPump.BorderSizePixel = (tradePhase == "PUMPING") and 2 or 0
	BtnPump.BorderColor3 = Color3.fromRGB(255, 255, 255)
	
	BtnDump.BorderSizePixel = (tradePhase == "DUMPING") and 2 or 0
	BtnDump.BorderColor3 = Color3.fromRGB(255, 255, 255)
	
	SaveConfig()
end
UpdatePhase(tradePhase)

BtnPrep.MouseButton1Click:Connect(function() UpdatePhase("PREPARE") end)
BtnPump.MouseButton1Click:Connect(function() UpdatePhase("PUMPING") end)
BtnDump.MouseButton1Click:Connect(function() UpdatePhase("DUMPING") end)

TargetPriceInput.FocusLost:Connect(SaveConfig)
MinSharesInput.FocusLost:Connect(SaveConfig)
MinPointsInput.FocusLost:Connect(SaveConfig)

MinBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		ContentFrame.Visible = false
		MainFrame:TweenSize(UDim2.new(0, 200, 0, 30), "Out", "Quad", 0.15, true)
	else
		MainFrame:TweenSize(UDim2.new(0, 200, 0, 360), "Out", "Quad", 0.15, true)
		task.wait(0.15)
		if not isMinimized then ContentFrame.Visible = true end
	end
end)

local function RenderDropdown()
	for _, child in ipairs(DropdownList:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	for i, shareData in ipairs(shares) do
		local itemBtn = Instance.new("TextButton", DropdownList)
		itemBtn.Size = UDim2.new(1, 0, 0, 30); itemBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		itemBtn.TextColor3 = Color3.new(1, 1, 1); itemBtn.Text = shareData.Name; itemBtn.ZIndex = 10
		itemBtn.MouseButton1Click:Connect(function()
			selectedShareID = shareData.ID
			selectedShareName = shareData.Name
			DropdownBtn.Text = "Saham: " .. shareData.Name
			DropdownList.Visible = false
			isDropdownOpen = false
			UpdatePhase("PREPARE")
			SaveConfig()
			task.spawn(function()
				pcall(function() game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.Stocks.RF.OpenSocket:InvokeServer(unpack({ selectedShareID })) end)
			end)
		end)
	end
end
RenderDropdown()

DropdownBtn.MouseButton1Click:Connect(function()
	isDropdownOpen = not isDropdownOpen
	DropdownList.Visible = isDropdownOpen
end)

-- ==========================================
-- 3. AUTO-DETECT SAHAM (REMOTE SPY)
-- ==========================================
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
	local method = getnamecallmethod()
	local args = {...}
	if not checkcaller() and method == "InvokeServer" and self.Name == "OpenSocket" then
		local detectedID = args[1]
		if type(detectedID) == "number" then
			task.spawn(function()
				task.wait(1.5)
				pcall(function()
					local symbolText = PlayerGui.Main.Invest.Stock.Trading.Interface.Details.Symbol.Text
					if symbolText and symbolText ~= "" then
						local exists = false
						for _, v in ipairs(shares) do
							if v.ID == detectedID then exists = true; break end
						end
						if not exists then
							table.insert(shares, {Name = symbolText, ID = detectedID})
							RenderDropdown()
							SaveConfig()
						end
					end
				end)
			end)
		end
	end
	return oldNamecall(self, ...)
end)

-- ==========================================
-- PATH UI GAME & EXTRACTOR
-- ==========================================
local PricePath = PlayerGui:WaitForChild("Main").Invest.Stock.Trading.Interface.Details.Price.TextLabel
local SharesPath = PlayerGui:WaitForChild("Main").Invest.Stock.Trading.Interface.Statement.Shares
local PointsPath = PlayerGui:WaitForChild("Main").Invest.Stock.Points.TextLabel

local function ExtractNumber(text)
	local cleaned = string.gsub(tostring(text), "[^%d%.]", "") 
	return math.floor(tonumber(cleaned) or 0)
end

-- ==========================================
-- LOGIKA TRADING ENGINE (STATE MACHINE)
-- ==========================================
local function ToggleTrading()
	isAutoTrading = not isAutoTrading
	SaveConfig()
	
	if isAutoTrading then
		AutoTradeBtn.Text = "STOP TRADING"
		AutoTradeBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
		
		task.spawn(function()
			local buyCount = 0
			local sellCount = 0
			
			while isAutoTrading do
				pcall(function() PlayerGui.Main.Invest.Stock.Trading.Visible = true end)
				
				local currentPrice = ExtractNumber(PricePath.Text)
				local currentShares = ExtractNumber(SharesPath.Text)
				local currentPoints = ExtractNumber(PointsPath.Text)
				
				local targetPrice = tonumber(TargetPriceInput.Text) or 1
				local minSharesToKeep = tonumber(MinSharesInput.Text) or 1
				local minPointsToKeep = tonumber(MinPointsInput.Text) or 1
				
				if TargetPriceInput:IsFocused() then targetPrice = 99999999 end
				
				if tradePhase == "PREPARE" then
					if currentPrice > 1 then
						if currentShares > 0 then
							pcall(function() game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.Stocks.RF.MarketSellPoints:InvokeServer(unpack({ selectedShareID, 1 })) end)
							task.wait(7)
						elseif currentShares == 0 and currentPrice <= 1000 then
							local sharesNeeded = currentPrice - 1
							if sharesNeeded < 1 then sharesNeeded = 1 end
							
							local spendablePoints = currentPoints - minPointsToKeep
							local futurePrice = currentPrice + sharesNeeded
							local totalCost = math.ceil((sharesNeeded / 2) * ((currentPrice + 1) + futurePrice))
							
							if spendablePoints >= totalCost then
								pcall(function() game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.Stocks.RF.MarketBuyPoints:InvokeServer(unpack({ selectedShareID, sharesNeeded })) end)
								task.wait(3)
								UpdatePhase("DUMPING")
							else
								task.wait(5)
							end
						else
							task.wait(5)
						end
					else
						local spendablePoints = currentPoints - minPointsToKeep
						local realPricePerShare = currentPrice + 1
						local sharesToBuy = math.floor(spendablePoints / realPricePerShare)
						
						if sharesToBuy > 0 then
							pcall(function() game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.Stocks.RF.MarketBuyPoints:InvokeServer(unpack({ selectedShareID, sharesToBuy })) end)
							UpdatePhase("GUARD")
							guardEndTime = os.time() + 20
							task.wait(2) 
						else
							task.wait(2)
						end
					end
				
				elseif tradePhase == "GUARD" then
					if os.time() < guardEndTime then
						if currentPrice > 1 then
							pcall(function() game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.Stocks.RF.MarketSellPoints:InvokeServer(unpack({ selectedShareID, 1 })) end)
							task.wait(5.5)
						else
							task.wait(1)
						end
					else
						UpdatePhase("PUMPING")
					end
				
				elseif tradePhase == "PUMPING" then
					if currentPrice >= targetPrice then
						UpdatePhase("DUMPING")
						task.wait(5.5)
						continue
					end
					
					local realPricePerShare = currentPrice + 1
					if currentPoints < realPricePerShare then
						local stepsRemaining = targetPrice - currentPrice
						if stepsRemaining > 0 then
							local bufferSteps = 10
							if bufferSteps > stepsRemaining then bufferSteps = stepsRemaining end
							local pointsNeeded = ((currentPrice + 1 + (currentPrice + bufferSteps)) * bufferSteps) / 2
							local sharesToSell = math.ceil(pointsNeeded / currentPrice)
							if sharesToSell < 1 then sharesToSell = 1 end
							
							local sellableShares = currentShares - minSharesToKeep
							if sharesToSell > sellableShares then sharesToSell = sellableShares end
							
							if sharesToSell > 0 then
								pcall(function() game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.Stocks.RF.MarketSellPoints:InvokeServer(unpack({ selectedShareID, sharesToSell })) end)
								task.wait(7)
								continue 
							else
								task.wait(5)
								continue
							end
						end
					end

					pcall(function() game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.Stocks.RF.MarketBuyPoints:InvokeServer(unpack({ selectedShareID, 1 })) end)
					
					buyCount = buyCount + 1
					if buyCount >= 50 then
						task.wait(math.random(30, 45))
						buyCount = 0
					else
						task.wait(5 + (math.random(1, 20) / 10))
					end
					
				elseif tradePhase == "DUMPING" then 
					if currentShares <= 0 and currentPrice > 1 then
						UpdatePhase("PREPARE")
						continue
					end
					
					if currentPrice <= 1 then 
						UpdatePhase("PREPARE")
						continue
					end
					
					local stepsNeeded = currentPrice - 1
					if stepsNeeded < 1 then stepsNeeded = 1 end
					
					local sellableShares = currentShares - minSharesToKeep
					local sellAmountPerTick = 1
					if sellableShares > 0 then sellAmountPerTick = math.floor(sellableShares / stepsNeeded) end
					if sellAmountPerTick < 1 then sellAmountPerTick = 1 end
					
					pcall(function() game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.Stocks.RF.MarketSellPoints:InvokeServer(unpack({ selectedShareID, sellAmountPerTick })) end)
					
					sellCount = sellCount + 1
					if sellCount >= 50 then
						task.wait(math.random(30, 45))
						sellCount = 0
					else
						task.wait(5 + (math.random(1, 20) / 10))
					end
				end
			end
		end)
	else
		AutoTradeBtn.Text = "START PUMP & DUMP"
		AutoTradeBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
	end
end

AutoTradeBtn.MouseButton1Click:Connect(ToggleTrading)

AutoSellBtn.MouseButton1Click:Connect(function()
	isAutoSelling = not isAutoSelling
	if isAutoSelling then
		AutoSellBtn.Text = "STOP HOLDING"
		AutoSellBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
		task.spawn(function()
			while isAutoSelling do
				pcall(function() PlayerGui.Main.Invest.Stock.Trading.Visible = true end)
				pcall(function() game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.Stocks.RF.MarketSellPoints:InvokeServer(unpack({ selectedShareID, 1 })) end)
				task.wait(5 + (math.random(1, 5) / 10))
			end
		end)
	else
		AutoSellBtn.Text = "HOLD PRICE (SELL 1)"
		AutoSellBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
	end
end)

-- ==========================================
-- ANTI AFK
-- ==========================================
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

-- ==========================================
-- AUTO INISIALISASI AWAL
-- ==========================================
task.spawn(function()
	-- PERBAIKAN: Indikator visual saat bot sedang resume kerja (waktu rejoin)
	if configData and configData.AutoTrade then
		AutoTradeBtn.Text = "MEMULAI ULANG (LOADING)..."
		AutoTradeBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 0)
	end
	
	task.wait(6)
	pcall(function() game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.Stocks.RF.OpenSocket:InvokeServer(unpack({ selectedShareID })) end)
	task.wait(2)
	pcall(function()
		local pointsToggle = LocalPlayer.PlayerGui:WaitForChild("Main", 10).Invest.Stock.Trading.Interf
