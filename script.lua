-- 1. 디자인 (플러그인 코드)
local Converted = {
	["_ScreenGui"] = Instance.new("ScreenGui");
	["_Frame"] = Instance.new("Frame");
	["_Aimbot"] = Instance.new("TextBox");
	["_SliderTrack"] = Instance.new("Frame");
	["_SliderFill"] = Instance.new("Frame");
	["_SliderButton"] = Instance.new("TextButton");
	["_ValueLabel"] = Instance.new("TextLabel");
}

-- [디자인 속성 적용] 
Converted["_ScreenGui"].Parent = game:GetService("CoreGui")
Converted["_Frame"].Parent = Converted["_ScreenGui"]
Converted["_Frame"].Size = UDim2.new(0, 616, 0, 730)
Converted["_Frame"].Position = UDim2.new(0.5, -308, 0.5, -365)
Converted["_Frame"].BackgroundColor3 = Color3.fromRGB(165, 165, 165)
Converted["_Frame"].Active = true
Converted["_Frame"].Draggable = true

Converted["_Aimbot"].Parent = Converted["_Frame"]
Converted["_Aimbot"].Name = "Aimbot"
Converted["_Aimbot"].Size = UDim2.new(0, 64, 0, 20)
Converted["_Aimbot"].Position = UDim2.new(0.05, 0, 0.15, 0)
Converted["_Aimbot"].Text = "Aimbot: OFF"

Converted["_SliderTrack"].Parent = Converted["_Frame"]
Converted["_SliderTrack"].Name = "SliderTrack"
Converted["_SliderTrack"].Size = UDim2.new(0, 200, 0, 14)
Converted["_SliderTrack"].Position = UDim2.new(0, 110, 0, 118)
Converted["_SliderTrack"].BackgroundColor3 = Color3.fromRGB(0, 0, 0)

Converted["_SliderFill"].Parent = Converted["_SliderTrack"]
Converted["_SliderFill"].Name = "SliderFill"
Converted["_SliderFill"].Size = UDim2.new(0.15, 0, 1, 0)
Converted["_SliderFill"].BackgroundColor3 = Color3.fromRGB(25, 150, 218)

Converted["_ValueLabel"].Parent = Converted["_SliderTrack"]
Converted["_ValueLabel"].Name = "ValueLabel"
Converted["_ValueLabel"].Size = UDim2.new(0, 200, 0, 14)
Converted["_ValueLabel"].Text = "Smoothness: 0.15"

-- 2. 기능 코드 (합치기)
local Frame = Converted["_Frame"]
local AimbotBtn = Converted["_Aimbot"]
local SliderTrack = Converted["_SliderTrack"]
local ValueLabel = Converted["_ValueLabel"]
local SliderFill = Converted["_SliderFill"]

local isActivated = false
_G.AimbotSmoothness = 0.15

-- [토글 버튼]
AimbotBtn.MouseButton1Click:Connect(function()
    isActivated = not isActivated
    AimbotBtn.Text = isActivated and "Aimbot: ON" or "Aimbot: OFF"
end)

-- [슬라이더]
SliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local scale = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
        SliderFill.Size = UDim2.new(scale, 0, 1, 0)
        _G.AimbotSmoothness = math.floor(scale * 100) / 100
        ValueLabel.Text = "Smoothness: " .. _G.AimbotSmoothness
    end
end)

-- [에임봇 루프]
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

-- [우측 쉬프트 토글]
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        Converted["_Frame"].Visible = not Converted["_Frame"].Visible
    end
end)
