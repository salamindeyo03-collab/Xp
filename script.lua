-- [1. 기본 UI 프레임 생성]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 700, 0, 500)
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- 어두운 테마

-- [2. 사이드바 (Combat, ESP 등 버튼)]
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0.2, 0, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local AimbotTabBtn = Instance.new("TextButton", Sidebar)
AimbotTabBtn.Text = "Combat"
AimbotTabBtn.Size = UDim2.new(1, 0, 0, 50)

-- [3. 기능 설정 탭 (Aimbot & Silent Aim)]
local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Position = UDim2.new(0.2, 0, 0, 0)
ContentFrame.Size = UDim2.new(0.8, 0, 1, 0)
ContentFrame.BackgroundTransparency = 1

local AimbotToggle = Instance.new("TextButton", ContentFrame)
AimbotToggle.Text = "Aimbot: OFF"
AimbotToggle.Size = UDim2.new(0, 200, 0, 50)
AimbotToggle.Position = UDim2.new(0.1, 0, 0.1, 0)

local SilentToggle = Instance.new("TextButton", ContentFrame)
SilentToggle.Text = "Silent Aim: OFF"
SilentToggle.Size = UDim2.new(0, 200, 0, 50)
SilentToggle.Position = UDim2.new(0.1, 0, 0.3, 0)

-- [4. 기능 엔진]
local aimEnabled = false
local silentEnabled = false

AimbotToggle.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    AimbotToggle.Text = aimEnabled and "Aimbot: ON" or "Aimbot: OFF"
end)

SilentToggle.MouseButton1Click:Connect(function()
    silentEnabled = not silentEnabled
    SilentToggle.Text = silentEnabled and "Silent Aim: ON" or "Silent Aim: OFF"
end)

-- 에임봇 루프 (카메라 제어)
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
