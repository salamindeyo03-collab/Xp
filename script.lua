-- [[ 최종 통합본: UI 생성 및 기능 통합 ]] --
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- 1. UI 생성 (한 번에 다 만듦)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotMenu_Final"
ScreenGui.Parent = CoreGui 

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 320)
MainFrame.Position = UDim2.new(0.5, -160, 0.4, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(145, 145, 145)
MainFrame.Active = true
MainFrame.Draggable = true -- 드래그 가능
MainFrame.Parent = ScreenGui

-- UI 내 버튼/기능 등은 이 아래에 계속 추가하면 됨 --

-- 2. 키보드 토글 기능 (우측 쉬프트)
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("통합 스크립트 로드 완료!")
