-- 기능 코드 부분 (기존에 넣은 기능 코드들을 지우고 이걸로 덮어쓰세요)
local Frame = Converted["_Frame"]
local AimbotBtn = Frame:FindFirstChild("_Aimbot") -- 실제 이름이 _Aimbot인지 다시 확인!
local SliderTrack = Frame:FindFirstChild("_SliderTrack")
local SliderFill = Frame:FindFirstChild("_SliderFill")
local ValueLabel = Frame:FindFirstChild("_ValueLabel") -- 혹은 SliderTrack 안이라면 SliderTrack:FindFirstChild(...)

local isActivated = false
_G.AimbotSmoothness = 0.15

-- 1. 버튼 기능 (클릭 가능하게 설정)
AimbotBtn.Active = true
AimbotBtn.Selectable = true
AimbotBtn.MouseButton1Click:Connect(function()
    isActivated = not isActivated
    AimbotBtn.Text = isActivated and "Aimbot: ON" or "Aimbot: OFF"
end)

-- 2. 슬라이더 조절 (마우스 이동 감지 방식)
local isDragging = false
SliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if isDragging then
        local mouse = game:GetService("Players").LocalPlayer:GetMouse()
        local relativeX = mouse.X - SliderTrack.AbsolutePosition.X
        local scale = math.clamp(relativeX / SliderTrack.AbsoluteSize.X, 0, 1)
        
        SliderFill.Size = UDim2.new(scale, 0, 1, 0)
        _G.AimbotSmoothness = math.floor(scale * 100) / 100
        ValueLabel.Text = "Smoothness: " .. _G.AimbotSmoothness
    end
end)
