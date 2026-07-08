-- 디자인 설정 (플러그인 코드 기반)
local Converted = {
    ["_ScreenGui"] = Instance.new("ScreenGui"),
    ["_Frame"] = Instance.new("Frame"),
    ["_SliderTrack"] = Instance.new("Frame"),
    ["_SliderFill"] = Instance.new("Frame"),
    ["_SliderButton"] = Instance.new("TextButton"),
    ["_ValueLabel"] = Instance.new("TextLabel"),
    ["_Aimbot"] = Instance.new("TextBox")
}

-- UI 계층 구조 및 속성 적용
Converted["_ScreenGui"].Parent = game:GetService("CoreGui")
Converted["_Frame"].Parent = Converted["_ScreenGui"]
Converted["_Frame"].Size = UDim2.new(0, 616, 0, 730)
Converted["_Frame"].Position = UDim2.new(0.5, -308, 0.5, -365)
Converted["_Frame"].BackgroundColor3 = Color3.fromRGB(165, 165, 165)
Converted["_Frame"].Active = true
Converted["_Frame"].Draggable = true

-- 에임봇 기능 변수
local isActivated = false
_G.AimbotSmoothness = 0.15

-- 슬라이더 기능 (Smoothness)
Converted["_SliderTrack"].Parent = Converted["_Frame"]
Converted["_SliderTrack"].InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local scale = math.clamp((input.Position.X - Converted["_SliderTrack"].AbsolutePosition.X) / Converted["_SliderTrack"].AbsoluteSize.X, 0, 1)
        Converted["_SliderFill"].Size = UDim2.new(scale, 0, 1, 0)
        _G.AimbotSmoothness = math.floor(scale * 100) / 100
        Converted["_ValueLabel"].Text = "Smoothness: " .. _G.AimbotSmoothness
    end
end)

-- 에임봇 루프
game:GetService("RunService").RenderStepped:Connect(function()
    if isActivated then
        local closest, dist = nil, math.huge
        local mousePos = game:GetService("UserInputService"):GetMouseLocation()
        for _, p in pairs(game:GetService("Players"):GetPlayers()) do
            if p ~= game:GetService("Players").LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local d = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if d < dist then closest, dist = p.Character.Head, d end
                end
            end
        end
        if closest then
            workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(CFrame.new(workspace.CurrentCamera.CFrame.Position, closest.Position), _G.AimbotSmoothness)
        end
    end
end)

-- 우측 쉬프트 토글 기능
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        Converted["_Frame"].Visible = not Converted["_Frame"].Visible
    end
end)
