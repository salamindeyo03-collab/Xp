-- [1. 플러그인이 뽑아준 디자인 코드 전체]
local Converted = {
	["_ScreenGui"] = Instance.new("ScreenGui"),
	["_Frame"] = Instance.new("Frame"),
	["_Aimbot"] = Instance.new("TextBox"),
	["_SliderTrack"] = Instance.new("Frame"),
	["_SliderFill"] = Instance.new("Frame"),
	["_ValueLabel"] = Instance.new("TextLabel"),
}

-- Generated using RoadToGlory's Converter v1.1 (RoadToGlory#9879)

-- Instances:

local Converted = {
	["_ScreenGui"] = Instance.new("ScreenGui");
	["_Frame"] = Instance.new("Frame");
	["_LocalScript"] = Instance.new("LocalScript");
	["_LocalScript1"] = Instance.new("LocalScript");
	["_TextButton"] = Instance.new("TextButton");
	["_Aimbot"] = Instance.new("TextBox");
	["_UICorner"] = Instance.new("UICorner");
	["_SliderTrack"] = Instance.new("Frame");
	["_LocalScript2"] = Instance.new("LocalScript");
	["_SliderFill"] = Instance.new("Frame");
	["_UICorner1"] = Instance.new("UICorner");
	["_SliderButton"] = Instance.new("TextButton");
	["_UICorner2"] = Instance.new("UICorner");
	["_ValueLabel"] = Instance.new("TextLabel");
	["_UICorner3"] = Instance.new("UICorner");
	["_UICorner4"] = Instance.new("UICorner");
	["_LocalScript3"] = Instance.new("LocalScript");
	["_LocalScript4"] = Instance.new("LocalScript");
}

-- Properties:

Converted["_ScreenGui"].ResetOnSpawn = false
Converted["_ScreenGui"].ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Converted["_ScreenGui"].Parent = game:GetService("CoreGui")

Converted["_Frame"].BackgroundColor3 = Color3.fromRGB(165.00000536441803, 165.00000536441803, 165.00000536441803)
Converted["_Frame"].BackgroundTransparency = 0.20000000298023224
Converted["_Frame"].BorderColor3 = Color3.fromRGB(204.0000182390213, 204.0000182390213, 204.0000182390213)
Converted["_Frame"].BorderSizePixel = 0
Converted["_Frame"].Position = UDim2.new(0.498436213, 0, 0.242571771, 0)
Converted["_Frame"].Size = UDim2.new(0, 616, 0, 730)
Converted["_Frame"].Parent = Converted["_ScreenGui"]

Converted["_TextButton"].Font = Enum.Font.SourceSans
Converted["_TextButton"].Text = "X"
Converted["_TextButton"].TextColor3 = Color3.fromRGB(90.00000223517418, 90.00000223517418, 90.00000223517418)
Converted["_TextButton"].TextSize = 25
Converted["_TextButton"].TextStrokeColor3 = Color3.fromRGB(145.00000655651093, 145.00000655651093, 145.00000655651093)
Converted["_TextButton"].BackgroundColor3 = Color3.fromRGB(188.0000039935112, 188.0000039935112, 188.0000039935112)
Converted["_TextButton"].BackgroundTransparency = 1
Converted["_TextButton"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_TextButton"].BorderSizePixel = 0
Converted["_TextButton"].Position = UDim2.new(0.95616895, 0, 0.018739352, 0)
Converted["_TextButton"].Size = UDim2.new(0, 16, 0, 14)
Converted["_TextButton"].Parent = Converted["_Frame"]

Converted["_Aimbot"].Font = Enum.Font.SourceSansBold
Converted["_Aimbot"].Text = "Aimbot"
Converted["_Aimbot"].TextColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Aimbot"].TextSize = 18
Converted["_Aimbot"].BackgroundColor3 = Color3.fromRGB(156.00000590085983, 156.00000590085983, 156.00000590085983)
Converted["_Aimbot"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Aimbot"].BorderSizePixel = 0
Converted["_Aimbot"].Position = UDim2.new(0.0535714291, 0, 0.157431573, 0)
Converted["_Aimbot"].Size = UDim2.new(0, 64, 0, 20)
Converted["_Aimbot"].Name = "Aimbot"
Converted["_Aimbot"].Parent = Converted["_Frame"]

Converted["_UICorner"].Parent = Converted["_Frame"]

Converted["_SliderTrack"].BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Converted["_SliderTrack"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_SliderTrack"].BorderSizePixel = 0
Converted["_SliderTrack"].Position = UDim2.new(0, 110, 0, 118)
Converted["_SliderTrack"].Size = UDim2.new(0, 200, 0, 14)
Converted["_SliderTrack"].Name = "SliderTrack"
Converted["_SliderTrack"].Parent = Converted["_Frame"]

Converted["_SliderFill"].BackgroundColor3 = Color3.fromRGB(25.000000409781933, 150.0000062584877, 218.00000220537186)
Converted["_SliderFill"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_SliderFill"].BorderSizePixel = 0
Converted["_SliderFill"].Size = UDim2.new(0.150000006, 0, 1, 0)
Converted["_SliderFill"].Name = "SliderFill"
Converted["_SliderFill"].Parent = Converted["_SliderTrack"]

Converted["_UICorner1"].BottomLeftRadius = UDim.new(1, 0)
Converted["_UICorner1"].BottomRightRadius = UDim.new(1, 0)
Converted["_UICorner1"].CornerRadius = UDim.new(1, 0)
Converted["_UICorner1"].TopLeftRadius = UDim.new(1, 0)
Converted["_UICorner1"].TopRightRadius = UDim.new(1, 0)
Converted["_UICorner1"].Parent = Converted["_SliderFill"]

Converted["_SliderButton"].Font = Enum.Font.SourceSans
Converted["_SliderButton"].Text = ""
Converted["_SliderButton"].TextColor3 = Color3.fromRGB(0, 0, 0)
Converted["_SliderButton"].TextSize = 14
Converted["_SliderButton"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_SliderButton"].BackgroundColor3 = Color3.fromRGB(25.000000409781933, 150.0000062584877, 218.00000220537186)
Converted["_SliderButton"].BackgroundTransparency = 1
Converted["_SliderButton"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_SliderButton"].BorderSizePixel = 0
Converted["_SliderButton"].Position = UDim2.new(0.150000006, 0, 0.5, 0)
Converted["_SliderButton"].Size = UDim2.new(0, 14, 0, 14)
Converted["_SliderButton"].Name = "SliderButton"
Converted["_SliderButton"].Parent = Converted["_SliderTrack"]

Converted["_UICorner2"].BottomLeftRadius = UDim.new(1, 0)
Converted["_UICorner2"].BottomRightRadius = UDim.new(1, 0)
Converted["_UICorner2"].CornerRadius = UDim.new(1, 0)
Converted["_UICorner2"].TopLeftRadius = UDim.new(1, 0)
Converted["_UICorner2"].TopRightRadius = UDim.new(1, 0)
Converted["_UICorner2"].Parent = Converted["_SliderButton"]

Converted["_ValueLabel"].Font = Enum.Font.SourceSans
Converted["_ValueLabel"].Text = "Smoothness: 0.15"
Converted["_ValueLabel"].TextColor3 = Color3.fromRGB(0, 0, 0)
Converted["_ValueLabel"].TextSize = 14
Converted["_ValueLabel"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_ValueLabel"].BackgroundTransparency = 0.30000001192092896
Converted["_ValueLabel"].BorderColor3 = Color3.fromRGB(255, 255, 255)
Converted["_ValueLabel"].BorderSizePixel = 0
Converted["_ValueLabel"].Size = UDim2.new(0, 200, 0, 14)
Converted["_ValueLabel"].Name = "ValueLabel"
Converted["_ValueLabel"].Parent = Converted["_SliderTrack"]

Converted["_UICorner3"].Parent = Converted["_ValueLabel"]

Converted["_UICorner4"].BottomLeftRadius = UDim.new(1, 0)
Converted["_UICorner4"].BottomRightRadius = UDim.new(1, 0)
Converted["_UICorner4"].CornerRadius = UDim.new(1, 0)
Converted["_UICorner4"].TopLeftRadius = UDim.new(1, 0)
Converted["_UICorner4"].TopRightRadius = UDim.new(1, 0)
Converted["_UICorner4"].Parent = Converted["_SliderTrack"]

-- Fake Module Scripts:

local fake_module_scripts = {}


-- Fake Local Scripts:

local function NTZHABJ_fake_script() -- Fake Script: StarterGui.ScreenGui.Frame.LocalScript
    local script = Instance.new("LocalScript")
    script.Name = "LocalScript"
    script.Parent = Converted["_Frame"]
    local req = require
    local require = function(obj)
        local fake = fake_module_scripts[obj]
        if fake then
            return fake()
        end
        return req(obj)
    end

	local Players = game:GetService("Players")
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	
	local player = Players.LocalPlayer
	local mouse = player:GetMouse()
	local gui = script.Parent -- 본래 UI (Frame)
	
	local dragStartMousePos = nil   -- 클릭 시작 시 마우스 위치
	local guiStartPos = nil    -- 클릭 시작 시 UI 위치
	local previewGui = nil     -- 마우스를 따라다닐 테두리 창
	local renderConnection = nil -- 매 프레임 위치 업데이트용
	local upConnection = nil     -- 마우스 뗌 감지용
	
	-- [안전 장치] ScreenGui가 완전히 로드될 때까지 안전하게 대기합니다.
	local screenGui = gui:FindFirstAncestorOfClass("ScreenGui")
	if not screenGui then
		repeat
			task.wait()
			screenGui = gui:FindFirstAncestorOfClass("ScreenGui")
		until screenGui or not gui.Parent
	end
	
	-- [1. 탑바 설정(IgnoreGuiInset)을 자동으로 감지해서 정확한 마우스 좌표를 구하는 함수]
	local function getAbsolutePositions()
		if not screenGui then return Vector2.new(0,0), Vector2.new(0,0) end
		-- IgnoreGuiInset 설정에 따라 Y축에 36픽셀을 더할지 말지 자동으로 결정합니다.
		local inset = (not screenGui.IgnoreGuiInset) and Vector2.new(0, 36) or Vector2.new(0, 0)
	
		local guiPos = gui.AbsolutePosition + inset
		local guiSize = gui.AbsoluteSize
		return guiPos, guiSize
	end
	
	-- [2. 현재 마우스가 UI 창 영역 위에 있는지 체크하는 함수]
	local function isMouseOverGui()
		local mousePos = UserInputService:GetMouseLocation()
		local guiPos, guiSize = getAbsolutePositions()
	
		return mousePos.X >= guiPos.X and mousePos.X <= guiPos.X + guiSize.X and
			mousePos.Y >= guiPos.Y and mousePos.Y <= guiPos.Y + guiSize.Y
	end
	
	-- [3. 마우스 클릭 다운 버튼 감지]
	mouse.Button1Down:Connect(function()
		if not screenGui then return end
		if isMouseOverGui() then
			if previewGui then return end -- 중복 실행 방지
	
			dragStartMousePos = UserInputService:GetMouseLocation()
			guiStartPos = gui.Position -- 원래 창의 처음 위치 저장
	
			local _, guiAbsSize = getAbsolutePositions()
	
			-- [테두리 창 생성] 내부 투명, 원래 창 크기와 동일하게 설정
			previewGui = Instance.new("Frame")
			previewGui.Name = "MovePreviewBorder"
			previewGui.Size = UDim2.new(0, guiAbsSize.X, 0, guiAbsSize.Y)
			previewGui.Position = UDim2.new(0, gui.AbsolutePosition.X, 0, gui.AbsolutePosition.Y)
			previewGui.BackgroundTransparency = 1 -- 내부 투명
			previewGui.BorderSizePixel = 0
	
			-- 아주 얇은 하늘색 테두리(UIStroke) 추가
			local stroke = Instance.new("UIStroke")
			stroke.Thickness = 1
			stroke.Color = Color3.fromRGB(100, 200, 255)
			stroke.Parent = previewGui
	
			previewGui.Parent = screenGui
	
			-- [4. 드래그 중: 원래 창은 가만히 두고, 테두리만 마우스 따라 이동]
			renderConnection = RunService.RenderStepped:Connect(function()
				if dragStartMousePos and previewGui then
					local currentMouse = UserInputService:GetMouseLocation()
					local delta = currentMouse - dragStartMousePos
	
					previewGui.Position = UDim2.new(
						0, gui.AbsolutePosition.X + delta.X,
						0, gui.AbsolutePosition.Y + delta.Y
					)
				end
			end)
	
			-- [5. 마우스를 놓았을 때: 그제서야 원래 창을 테두리 위치로 배달]
			upConnection = mouse.Button1Up:Connect(function()
				if renderConnection then renderConnection:Disconnect() renderConnection = nil end
				if upConnection then upConnection:Disconnect() upConnection = nil end
	
				if previewGui then
					local finalMouse = UserInputService:GetMouseLocation()
					local delta = finalMouse - dragStartMousePos
	
					-- 원래 창의 원래 좌표(Scale/Offset)에 마우스가 움직인 거리(delta)만 깔끔하게 더해줍니다.
					gui.Position = UDim2.new(
						guiStartPos.X.Scale, guiStartPos.X.Offset + delta.X,
						guiStartPos.Y.Scale, guiStartPos.Y.Offset + delta.Y
					)
	
					previewGui:Destroy()
					previewGui = nil
				end
	
				dragStartMousePos = nil
				guiStartPos = nil
			end)
		end
	end)
end
local function MQSV_fake_script() -- Fake Script: StarterGui.ScreenGui.Frame.LocalScript
    local script = Instance.new("LocalScript")
    script.Name = "LocalScript"
    script.Parent = Converted["_Frame"]
    local req = require
    local require = function(obj)
        local fake = fake_module_scripts[obj]
        if fake then
            return fake()
        end
        return req(obj)
    end

	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Players = game:GetService("Players")
	-- 필요한 모듈을 맨 위에서 미리 가져옵니다.
	local DebugController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("DebugController"))
	
	local button = script.Parent -- 현재 버튼 오브젝트
	local isActivated = false -- 버튼의 켜짐/꺼짐 상태
	
	local function toggleFunction()
		isActivated = not isActivated -- 누를 때마다 상태를 반대로 바꿈
	
		if isActivated then
			-------------------------------------------------
			-- [1] 버튼을 눌러서 '켤 때' 실행할 코드
			-------------------------------------------------
			DebugController:SetHandicapsEnabled(true) -- 기능 켜기
			print("기능 활성화!")
	
			button.BackgroundColor3 = Color3.fromRGB(100, 255, 100) -- 초록색으로 변경
	
		else
			-------------------------------------------------
			-- [2] 다시 눌러서 '끌 때' 실행할 코드
			-------------------------------------------------
			DebugController:SetHandicapsEnabled(false) -- 기능 끄기 (이 부분이 추가되어야 합니다!)
			print("기능 비활성화!")
	
			button.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- 하얀색으로 변경
	
		end
	end
	
	-- 버튼 클릭 이벤트 연결
	button.MouseButton1Click:Connect(toggleFunction)
end
local function ZEGW_fake_script() -- Fake Script: StarterGui.ScreenGui.Frame.SliderTrack.LocalScript
    local script = Instance.new("LocalScript")
    script.Name = "LocalScript"
    script.Parent = Converted["_SliderTrack"]
    local req = require
    local require = function(obj)
        local fake = fake_module_scripts[obj]
        if fake then
            return fake()
        end
        return req(obj)
    end

	local UserInputService = game:GetService("UserInputService")
	
	-- 🎛️ 오브젝트 참조 (스크립트가 SliderTrack 바로 아래에 있는지 꼭 확인!)
	local Track = script.Parent
	local Fill = Track:WaitForChild("SliderFill")
	local Button = Track:WaitForChild("SliderButton")
	local ValueLabel = Track:WaitForChild("ValueLabel")
	
	local isDragging = false
	local currentValue = 0.15 -- 초기 감도값
	
	-- 📐 슬라이더 움직임 및 값 연산 함수
	local function updateSlider()
		local mouseX = UserInputService:GetMouseLocation().X
		local trackLeft = Track.AbsolutePosition.X
		local trackWidth = Track.AbsoluteSize.X
	
		-- 마우스 위치를 비율(0에서 1 사이)로 변환
		local scale = (mouseX - trackLeft) / trackWidth
		scale = math.clamp(scale, 0, 1)
	
		-- 🔵 UI 바 크기와 동그란 단추 위치 맞추기
		Fill.Size = UDim2.new(scale, 0, 1, 0)
		Button.Position = UDim2.new(scale, 0, 0.5, 0)
	
		-- 📝 글자 다 빼고 오직 숫자만 표시
		currentValue = math.floor(scale * 100) / 100
		ValueLabel.Text = tostring(currentValue)
	
		-- 💡 공유 변수 설정 (글로벌 변수로 등록해서 에임봇 스크립트가 가져갈 수 있게 함)
		_G.AimbotSmoothness = currentValue
	end
	
	-- 🖱️ 마우스 클릭 및 드래그 이벤트 등록
	Button.MouseButton1Down:Connect(function()
		isDragging = true
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateSlider()
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = false
		end
	end)
end
local function TNCTSQT_fake_script() -- Fake Script: StarterGui.ScreenGui.Frame.LocalScript
    local script = Instance.new("LocalScript")
    script.Name = "LocalScript"
    script.Parent = Converted["_Frame"]
    local req = require
    local require = function(obj)
        local fake = fake_module_scripts[obj]
        if fake then
            return fake()
        end
        return req(obj)
    end

	local Players = game:GetService("Players")
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	
	local Camera = workspace.CurrentCamera
	local LocalPlayer = Players.LocalPlayer
	
	-- UI 오브젝트 참조 (토글 버튼 이름이 맞는지 확인 필수!)
	local MainFrame = script.Parent
	local ToggleButton = MainFrame:WaitForChild("AimbotToggleButton")
	
	local isActivated = false
	
	-------------------------------------------------
	-- 🎯 에임봇 타겟 조건 검사
	-------------------------------------------------
	local function isValidTarget(player)
		if player == LocalPlayer then return false end
		local character = player.Character
		if not character then return false end
	
		local head = character:FindFirstChild("Head")
		local root = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChildOfClass("Humanoid")
	
		if not (head and root and humanoid) then return false end
		if humanoid.Health <= 0 then return false end
		return true
	end
	
	-- 🔍 마우스 커서와 가장 가까운 캐릭터 찾기
	local function getClosestPlayer()
		local closestTarget = nil
		local shortestDistance = math.huge
		local mousePos = UserInputService:GetMouseLocation()
	
		for _, player in ipairs(Players:GetPlayers()) do
			if isValidTarget(player) then
				local character = player.Character
				local screenPos, onScreen = Camera:WorldToViewportPoint(character.Head.Position)
	
				if onScreen then
					local target2D = Vector2.new(screenPos.X, screenPos.Y)
					local distance = (target2D - mousePos).Magnitude
	
					if distance < shortestDistance then
						shortestDistance = distance
						closestTarget = character.Head
					end
				end
			end
		end
		return closestTarget
	end
	
	-------------------------------------------------
	-- 🔄 실시간 에임 루프 (렌더 스텝 연동)
	-------------------------------------------------
	local aimbotConnection = nil
	
	local function startAimbotLoop()
		aimbotConnection = RunService.RenderStepped:Connect(function()
			if isActivated then
				local targetHead = getClosestPlayer()
				if targetHead then
					local targetCFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
	
					-- 🌟 [핵심 연동] 슬라이더 스크립트에서 저장한 _G.AimbotSmoothness 값을 실시간으로 가져옴
					-- 혹시라도 값이 비어있을 때를 대비해 기본값 0.15 세팅
					local sliderValue = _G.AimbotSmoothness or 0.15
	
					-- 숫자가 낮을수록(0.01에 가까울수록) 느리고 부드럽게 타겟을 쫓아가고, 
					-- 1에 가까울수록 딜레이 없이 즉시 적에게 에임이 고정되는 공식!
					local finalSmoothness = math.clamp(sliderValue, 0.01, 1)
	
					Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, finalSmoothness)
				end
			end
		end)
	end
	
	-------------------------------------------------
	-- 🔘 에임봇 ON/OFF 토글 버튼 클릭 이벤트
	-------------------------------------------------
	ToggleButton.MouseButton1Click:Connect(function()
		isActivated = not isActivated
	
		if isActivated then
			ToggleButton.Text = "Aimbot: ON"
			ToggleButton.BackgroundColor3 = Color3.fromRGB(100, 255, 100) -- 초록색 변환
			startAimbotLoop()
		else
			ToggleButton.Text = "Aimbot: OFF"
			ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- 흰색 변환
			if aimbotConnection then
				aimbotConnection:Disconnect()
				aimbotConnection = nil
			end
		end
	end)
end
local function LTACEN_fake_script() -- Fake Script: StarterGui.ScreenGui.LocalScript
    local script = Instance.new("LocalScript")
    script.Name = "LocalScript"
    script.Parent = Converted["_ScreenGui"]
    local req = require
    local require = function(obj)
        local fake = fake_module_scripts[obj]
        if fake then
            return fake()
        end
        return req(obj)
    end

	--local UserInputService = game:GetService("UserInputService")
	
	---- 🗂️ 오브젝트 참조 (ScreenGui 바로 아래에 이 스크립트가 있을 때 기준)
	--local ScreenGui = script.Parent
	--local MainFrame = ScreenGui:WaitForChild("Frame") -- 네가 만든 회색 메인 GUI 프레임 이름!
	
	---- ⌨️ 키보드 입력 감지 이벤트
	--UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	--	-- 만약 채팅창을 치고 있는 중이라면 키보드 입력을 무시함 (채팅창 대문자 치다가 UI 꺼지는 것 방지)
	--	if gameProcessedEvent then return end
	
	--	-- 누른 키가 오른쪽 쉬프트(RightShift)인지 확인
	--	if input.KeyCode == Enum.KeyCode.RightShift then
	--		-- 현재 Visible(보이기) 상태를 반대로 뒤집음 (켜져 있으면 끄고, 꺼져 있으면 켬)
	--		MainFrame.Visible = not MainFrame.Visible
	--	end
	--end)
end

coroutine.wrap(NTZHABJ_fake_script)()
coroutine.wrap(MQSV_fake_script)()
coroutine.wrap(ZEGW_fake_script)()
coroutine.wrap(TNCTSQT_fake_script)()
coroutine.wrap(LTACEN_fake_script)()


-- [2. 기능 연결 코드 (디자인 코드 바로 밑에 붙여)]
local Frame = Converted["_Frame"] 
local AimbotBtn = Converted["_Aimbot"] -- 디자인 코드의 이름과 정확히 일치해야 함!
local SliderTrack = Converted["_SliderTrack"]
local SliderFill = Converted["_SliderFill"]
local ValueLabel = Converted["_ValueLabel"]

local isActivated = false
_G.AimbotSmoothness = 0.15

-- [기능 1: 에임봇 토글]
AimbotBtn.MouseButton1Click:Connect(function()
    isActivated = not isActivated
    AimbotBtn.Text = isActivated and "Aimbot: ON" or "Aimbot: OFF"
end)

-- [기능 2: 슬라이더 조절]
SliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local scale = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
        SliderFill.Size = UDim2.new(scale, 0, 1, 0)
        _G.AimbotSmoothness = math.floor(scale * 100) / 100
        ValueLabel.Text = "Smoothness: " .. _G.AimbotSmoothness
    end
end)

-- [기능 3: 에임봇 루프]
game:GetService("RunService").RenderStepped:Connect(function()
    if isActivated then
        local cam = workspace.CurrentCamera
        local mPos = game:GetService("UserInputService"):GetMouseLocation()
        local closest, dist = nil, math.huge
        for _, p in pairs(game:GetService("Players"):GetPlayers()) do
            if p ~= game:GetService("Players").LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, onScreen = cam:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local d = (Vector2.new(pos.X, pos.Y) - mPos).Magnitude
                    if d < dist then closest, dist = p.Character.Head, d end
                end
            end
        end
        if closest then
            cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, closest.Position), _G.AimbotSmoothness)
        end
    end
end)

-- [기능 4: 우측 Shift로 끄고 켜기]
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        Frame.Visible = not Frame.Visible
    end
end)
