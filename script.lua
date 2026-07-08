-- 1. [플러그인 디자인 코드 시작] - 이 영역은 건드리지 마세요
local Converted = {
	["_ScreenGui"] = Instance.new("ScreenGui");
	["_Frame"] = Instance.new("Frame");
	["_Aimbot"] = Instance.new("TextBox");
	["_SliderTrack"] = Instance.new("Frame");
	["_SliderFill"] = Instance.new("Frame");
	["_ValueLabel"] = Instance.new("TextLabel");
}
-- (여기에 플러그인이 뽑아준 나머지 속성 코드들을 쭉 붙여넣으세요)
-- 예: Converted["_Frame"].Size = UDim2.new(...) 등등


-- 2. [기능 코드 시작] - 디자인 코드 바로 아래에 붙이세요
local Frame = Converted["_Frame"]
local AimbotBtn = Frame:FindFirstChild("_Aimbot") -- 플러그인 코드상의 이름으로 확인하세요
local SliderTrack = Frame:FindFirstChild("_SliderTrack")
local ValueLabel = SliderTrack:FindFirstChild("_ValueLabel")
local SliderFill = SliderTrack:FindFirstChild("_SliderFill")

local isActivated = false
_G.AimbotSmoothness = 0.15

-- [에임봇 토글]
AimbotBtn.MouseButton1Click:Connect(function()
    isActivated = not isActivated
    AimbotBtn.Text = isActivated and "Aimbot: ON" or "Aimbot: OFF"
end)

-- [슬라이더 조절]
SliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local scale = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
        SliderFill.Size = UDim2.new(scale, 0, 1, 0)
        _G.AimbotSmoothness = math.floor(scale * 100) / 100
        ValueLabel.Text = "Smoothness: " .. _G.AimbotSmoothness
    end
end)

-- [에임봇 실행 로직]
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

-- [우측 쉬프트로 창 끄고 켜기]
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        Frame.Visible = not Frame.Visible
    end
end)
