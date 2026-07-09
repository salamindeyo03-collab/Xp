local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- [1. UI 디자인: 회색 톤 테마]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- 회색 테마
MainFrame.BackgroundTransparency = 0.3
MainFrame.BorderSizePixel = 0

-- ESP 기능용 박스 생성 (플레이어 위에 띄울 박스)
local function createESP(player)
    local highlight = Instance.new("Highlight", player.Character)
    highlight.FillColor = Color3.new(1, 0, 0)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    
    local billboard = Instance.new("BillboardGui", player.Character:FindFirstChild("Head"))
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    
    local healthBar = Instance.new("Frame", billboard)
    healthBar.Size = UDim2.new(0.8, 0, 0.2, 0)
    healthBar.BackgroundColor3 = Color3.new(0, 1, 0)
    
    return highlight
end

-- [2. 버튼 생성]
local AimbotBtn = Instance.new("TextButton", MainFrame)
AimbotBtn.Text = "Aimbot: OFF"; AimbotBtn.Size = UDim2.new(0, 200, 0, 50)
AimbotBtn.Position = UDim2.new(0.1, 0, 0.2, 0)

local ESPBtn = Instance.new("TextButton", MainFrame)
ESPBtn.Text = "ESP: OFF"; ESPBtn.Size = UDim2.new(0, 200, 0, 50)
ESPBtn.Position = UDim2.new(0.1, 0, 0.4, 0)

-- [3. 기능 로직]
local aimEnabled = false
local espEnabled = false

AimbotBtn.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    AimbotBtn.Text = "Aimbot: " .. (aimEnabled and "ON" or "OFF")
end)

ESPBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    ESPBtn.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
    if espEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then createESP(p) end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then 
                local h = p.Character:FindFirstChild("Highlight")
                if h then h:Destroy() end
                if p.Character:FindFirstChild("Head"):FindFirstChild("BillboardGui") then
                    p.Character.Head.BillboardGui:Destroy()
                end
            end
        end
    end
end)

-- [오른쪽 쉬프트 숨기기]
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then MainFrame.Visible = not MainFrame.Visible end
end)

-- 에임봇 루프
RunService.RenderStepped:Connect(function()
    if aimEnabled then
        local cam = workspace.CurrentCamera
        local target = nil
        local dist = math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, on = cam:WorldToViewportPoint(p.Character.Head.Position)
                if on then
                    local d = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                    if d < dist then target = p.Character.Head; dist = d end
                end
            end
        end
        if target then cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, target.Position), 0.1) end
    end
end)
