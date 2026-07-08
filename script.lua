-- 1. 디자인 코드 (아까 네가 추출한 거 전체 붙여넣기)
local Converted = {
	["_ScreenGui"] = Instance.new("ScreenGui");
	["_Frame"] = Instance.new("Frame");
	-- ... (아까 복사한 긴 코드 내용들 전부 여기 붙여넣어!) ...
}
-- (아까 플러그인이 준 코드의 나머지 부분들도 다 여기에 그대로 붙여넣어 줘)


-- 2. 기능 코드 (이걸 맨 아래에 추가하면 돼)
local Frame = Converted["_Frame"]
local AimbotBtn = Frame:FindFirstChild("Aimbot")
local SliderTrack = Frame:FindFirstChild("SliderTrack")
local ValueLabel = SliderTrack:FindFirstChild("ValueLabel")
local SliderFill = SliderTrack:FindFirstChild("SliderFill")

local isActivated = false
_G.AimbotSmoothness = 0.15

-- [기능 1: 에임봇 토글]
AimbotBtn.MouseButton1Click:Connect(function()
    isActivated = not isActivated
    AimbotBtn.Text = isActivated and "Aimbot: ON" or "Aimbot: OFF"
    AimbotBtn.BackgroundColor3 = isActivated and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(156, 156, 156)
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
        local camera = workspace.CurrentCamera
        local mousePos = game:GetService("UserInputService"):GetMouseLocation()
        local closest, dist = nil, math.huge
        
        for _, p in pairs(game:GetService("Players"):GetPlayers()) do
            if p ~= game:GetService("Players").LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, onScreen = camera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local d = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if d < dist then closest, dist = p.Character.Head, d end
                end
            end
        end
        if closest then
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, closest.Position), _G.AimbotSmoothness)
        end
    end
end)

-- [기능 4: 우측 쉬프트로 끄고 켜기]
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        Converted["_Frame"].Visible = not Converted["_Frame"].Visible
    end
end)
