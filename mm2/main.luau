-- ══════════════════════════════════════════════
--  Frosty Hub — MM2 Module (v1.0)
-- ══════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════════════
--  ПРОСТАЯ UI-БИБЛИОТЕКА (Адаптация Atlas)
-- ══════════════════════════════════════════════
local C = {
	bg = Color3.fromRGB(30, 30, 34), side = Color3.fromRGB(24, 24, 27),
	title = Color3.fromRGB(38, 70, 130), head = Color3.fromRGB(46, 46, 52),
	item = Color3.fromRGB(58, 58, 66), accent = Color3.fromRGB(92, 160, 255),
	text = Color3.fromRGB(235, 235, 240), dim = Color3.fromRGB(165, 165, 175),
	ok = Color3.fromRGB(80, 210, 140), err = Color3.fromRGB(248, 113, 113),
}
local FONT = Enum.Font.Ubuntu

local function make(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	o.Parent = parent
	return o
end
local function corner(o, r) return make("UICorner", {CornerRadius = UDim.new(0, r or 4)}, o) end
local function stroke(o, color, th, tr) return make("UIStroke", {Color = color, Thickness = th or 1, Transparency = tr or 0}, o) end

-- Создаем простое окно
local gui = make("ScreenGui", {Name = "FrostyMM2", ResetOnSpawn = false, IgnoreGuiInset = true}, LocalPlayer:WaitForChild("PlayerGui"))
local main = make("Frame", {
	Size = UDim2.fromOffset(300, 250),
	Position = UDim2.fromOffset(50, 50),
	BackgroundColor3 = C.bg,
	BorderSizePixel = 0,
	Active = true,
}, gui)
corner(main, 6)
stroke(main, C.accent, 1, 0.5)

local titleBar = make("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = C.title, BorderSizePixel = 0}, main)
corner(titleBar, 6)
local titleLbl = make("TextLabel", {
	Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
	Text = "Frosty Hub | MM2", Font = FONT, TextSize = 14, TextColor3 = C.text,
}, titleBar)

-- Перетаскивание окна
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true; dragStart = input.Position; startPos = main.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Контентная часть
local content = make("Frame", {Size = UDim2.new(1, -20, 1, -40), Position = UDim2.fromOffset(10, 35), BackgroundTransparency = 1}, main)
local layout = make("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, content)

-- Функция создания кнопок (Toggle)
local function createToggle(text, default, callback)
	local btn = make("TextButton", {
		Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = C.head, Text = "",
		AutoButtonColor = false, BorderSizePixel = 0, LayoutOrder = 1,
	}, content)
	corner(btn, 4)
	local label = make("TextLabel", {Size = UDim2.new(1, -10, 1, 0), Position = UDim2.fromOffset(5, 0), BackgroundTransparency = 1, Text = text, Font = FONT, TextSize = 14, TextColor3 = C.dim, TextXAlignment = Enum.TextXAlignment.Left}, btn)
	
	local isOn = default
	local function update()
		label.TextColor3 = isOn and C.ok or C.dim
		btn.BackgroundColor3 = isOn and C.item or C.head
		callback(isOn)
	end
	update()
	
	btn.MouseButton1Click:Connect(function()
		isOn = not isOn
		update()
	end)
	return btn
end

-- ══════════════════════════════════════════════
--  ФУНКЦИОНАЛ MM2
-- ══════════════════════════════════════════════

-- 1. ESP Ролей
local ESP_Enabled = false
local esp_objects = {}

local function getRole(player)
	local char = player.Character
	if not char then return "Unknown" end
	if char:FindFirstChild("Knife") or char:FindFirstChild("Revolver") then
		if char:FindFirstChild("Knife") then return "Murderer" end
		if char:FindFirstChild("Revolver") then return "Sheriff" end
	end
	return "Innocent"
end

local function updateESP()
	if not ESP_Enabled then
		for _, obj in pairs(esp_objects) do if obj and obj.Parent then obj:Destroy() end end
		esp_objects = {}
		return
	end

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
			local role = getRole(p)
			local color = Color3.new(1, 1, 1) -- Innocent
			if role == "Murderer" then color = Color3.fromRGB(255, 50, 50)
			elseif role == "Sheriff" then color = Color3.fromRGB(50, 150, 255) end
			
			if not esp_objects[p] then
				local billboard = make("BillboardGui", {
					Size = UDim2.fromOffset(100, 30), AlwaysOnTop = true, StudsOffset = Vector3.new(0, 2.5, 0)
				}, p.Character.Head)
				local text = make("TextLabel", {
					Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
					Text = role, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = color,
					TextStrokeTransparency = 0.5
				}, billboard)
				esp_objects[p] = billboard
			else
				local billboard = esp_objects[p]
				if billboard and billboard.Parent then
					billboard.Parent = p.Character.Head
					local text = billboard:FindFirstChildOfClass("TextLabel")
					if text then
						text.Text = role
						text.TextColor3 = color
					end
				end
			end
		end
	end
end

-- 2. Speed Hack
local SpeedEnabled = false
local speedValue = 50
local defaultSpeed = 16

local function applySpeed()
	local char = LocalPlayer.Character
	if char and char:FindFirstChildOfClass("Humanoid") then
		char.Humanoid.WalkSpeed = SpeedEnabled and speedValue or defaultSpeed
	end
end

-- 3. UI
createToggle("ESP (Роли)", false, function(on) ESP_Enabled = on; updateESP() end)
createToggle("Speed Hack", false, function(on) SpeedEnabled = on; applySpeed() end)

-- Обновление ESP каждый кадр (или раз в 0.1 сек для оптимизации)
local acc = 0
RunService.Heartbeat:Connect(function(dt)
	acc = acc + dt
	if acc > 0.1 then
		acc = 0
		if ESP_Enabled then updateESP() end
	end
	if SpeedEnabled then applySpeed() end
end)

-- Уведомление о запуске
game:GetService("StarterGui"):SetCore("SendNotification", {
	Title = "Frosty Hub | MM2",
	Text = "Модуль MM2 загружен!",
	Duration = 5
})
print("[FrostyHub] MM2 Module Loaded Successfully!")
