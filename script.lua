-- 1. [UI 디자인] 배경 불투명도 0.3 설정
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BackgroundTransparency = 0.3 -- 배경 불투명도 0.3 설정!

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0.3, 0, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Sidebar.BackgroundTransparency = 0.3

-- 버튼들...
local AimbotBtn = Instance.new("TextButton", Sidebar)
AimbotBtn.Text = "Aimbot: OFF"
AimbotBtn.Size = UDim2.new(1, 0, 0, 50)
AimbotBtn.Position = UDim2.new(0, 0, 0.1, 0)

local SilentBtn = Instance.new("TextButton", Sidebar)
SilentBtn.Text = "Silent: OFF"
SilentBtn.Size = UDim2.new(1, 0, 0, 50)
SilentBtn.Position = UDim2.new(0, 0, 0.3, 0)

-- 2. [기능 엔진]
local aimEnabled = false
local silentEnabled = false

AimbotBtn.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    AimbotBtn.Text = aimEnabled and "Aimbot: ON" or "Aimbot: OFF"
end)

SilentBtn.MouseButton1Click:Connect(function()
    silentEnabled = not silentEnabled
    SilentBtn.Text = silentEnabled and "Silent: ON" or "Silent: OFF"
end)

-- [기능: 우측 쉬프트로 끄고 켜기]
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- 에임봇 루프
game:GetService("RunService").RenderStepped:Connect(function()
    if aimEnabled then
        local cam = workspace.CurrentCamera
        local target = nil
        local dist = math.huge
        for _, p in pairs(game:GetService("Players"):GetPlayers()) do
            if p ~= game:GetService("Players").LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, on = cam:WorldToViewportPoint(p.Character.Head.Position)
                if on then
                    local d = (Vector2.new(pos.X, pos.Y) - game:GetService("UserInputService"):GetMouseLocation()).Magnitude
                    if d < dist then target = p.Character.Head; dist = d end
                end
            end
        end
        if target then
            cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, target.Position), 0.1)
        end
    end
end)
