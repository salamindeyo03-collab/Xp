local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- 1. UI 생성 (기존 로드된 것 삭제)
if CoreGui:FindFirstChild("AimbotUI") then CoreGui.AimbotUI:Destroy() end
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotUI"
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 616, 0, 730)
Frame.Position = UDim2.new(0.5, -308, 0.5, -365)
Frame.BackgroundColor3 = Color3.fromRGB(165, 165, 165)
Frame.Active = true
Frame.Draggable = true

-- 2. 토글 버튼 (Aimbot)
local AimbotBtn = Instance.new("TextButton", Frame)
AimbotBtn.Name = "AimbotToggleButton" -- 스크립트가 찾을 이름
AimbotBtn.Size = UDim2.new(0, 64, 0, 20)
AimbotBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
AimbotBtn.Text = "Aimbot: OFF"

-- 3. 슬라이더 (Smoothness)
local SliderTrack = Instance.new("Frame", Frame)
SliderTrack.Size = UDim2.new(0, 200, 0, 14)
SliderTrack.Position = UDim2.new(0, 110, 0, 118)
SliderTrack.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
local SliderFill = Instance.new("Frame", SliderTrack)
SliderFill.Size = UDim2.new(0.15, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(25, 150, 218)
local ValueLabel = Instance.new("TextLabel", SliderTrack)
ValueLabel.Text = "Smoothness: 0.15"

-- 4. 기능 로직
local isActivated = false
_G.AimbotSmoothness = 0.15

AimbotBtn.MouseButton1Click:Connect(function()
    isActivated = not isActivated
    AimbotBtn.Text = isActivated and "Aimbot: ON" or "Aimbot: OFF"
    AimbotBtn.BackgroundColor3 = isActivated and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 255, 255)
end)

-- 슬라이더 로직
SliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local scale = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
        SliderFill.Size = UDim2.new(scale, 0, 1, 0)
        _G.AimbotSmoothness = math.floor(scale * 100) / 100
        ValueLabel.Text = "Smoothness: " .. _G.AimbotSmoothness
    end
end)

-- 에임봇 루프
RunService.RenderStepped:Connect(function()
    if isActivated then
        local closest, dist = nil, math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local d = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if d < dist then closest, dist = p.Character.Head, d end
                end
            end
        end
        if closest then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closest.Position), _G.AimbotSmoothness)
        end
    end
end)

-- 우측 쉬프트 토글
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        Frame.Visible = not Frame.Visible
    end
end)
