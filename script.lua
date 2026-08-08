--[[
                                               _                                 
                     __      ____ _ _ __ _ __ (_)_ __   __ _                     
                     \ \ /\ / / _` | '__| '_ \| | '_ \ / _` |                    
                      \ V  V / (_| | |  | | | | | | | | (_| |                    
                       \_/\_/ \__,_|_|  |_| |_|_|_| |_|\__, |                    
                                                       |___/                     
 --]]

local success, err = pcall(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local CoreGui = game:GetService("CoreGui")

    local player = Players.LocalPlayer
    local camera = workspace.CurrentCamera

    -- 기본 통지(Notify) GUI 생성
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SimpleNotificationGui"
    ScreenGui.ResetOnSpawn = false
    
    local ok_cg = pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not ok_cg then
        ScreenGui.Parent = player:WaitForChild("PlayerGui")
    end

    local NotificationFrame = Instance.new("Frame")
    NotificationFrame.Size = UDim2.new(0, 250, 0, 50)
    NotificationFrame.Position = UDim2.new(0, 20, 0.8, 0)
    NotificationFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    NotificationFrame.BorderSizePixel = 0
    NotificationFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = NotificationFrame

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, -10, 1, -10)
    TextLabel.Position = UDim2.new(0, 5, 0, 5)
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextSize = 14
    TextLabel.Font = Enum.Font.SourceSansBold
    TextLabel.Text = "스크립트가 정상적으로 로드되었습니다!"
    TextLabel.Parent = NotificationFrame

    task.delay(4, function()
        pcall(function() ScreenGui:Destroy() end)
    end)

    -- ==========================================
    -- AIMBOT 설정 및 초기화
    -- ==========================================
    local AIM_RADIUS = 200
    local SMOOTH_FACTOR = 1.0
    local MAX_DISTANCE = 1000
    local aimbotEnabled = false
    local teamCheck = true
    local wallCheck = true
    local showFOV = false

    local fovCircle = nil
    if Drawing then
        pcall(function()
            fovCircle = Drawing.new("Circle")
            fovCircle.Color = Color3.fromRGB(255, 255, 255)
            fovCircle.Thickness = 2
            fovCircle.Transparency = 1
            fovCircle.Filled = false
            fovCircle.Visible = false
            fovCircle.Radius = AIM_RADIUS
        end)
    end

    local function getTarget()
        if not camera then return nil end
        local closest, dist = nil, AIM_RADIUS
        local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        local localRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not localRoot then return nil end
        
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        rayParams.FilterDescendantsInstances = {player.Character}
        rayParams.IgnoreWater = true
        
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player then
                local char = plr.Character
                if char and char:FindFirstChild("Head") and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                    if char.Humanoid.Health > 0 then
                        local isTeammate = teamCheck and player.Team and plr.Team == player.Team
                        if not isTeammate then
                            local distance3D = (char.HumanoidRootPart.Position - localRoot.Position).Magnitude
                            if distance3D <= MAX_DISTANCE then
                                local screenPos, onScreen = camera:WorldToViewportPoint(char.Head.Position)
                                if onScreen then
                                    local d = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                                    if d < dist then
                                        local canSee = true
                                        if wallCheck then
                                            local origin = camera.CFrame.Position
                                            local direction = (char.Head.Position - origin)
                                            local hit = workspace:Raycast(origin, direction, rayParams)
                                            if hit and hit.Instance and not hit.Instance:IsDescendantOf(char) then canSee = false end
                                        end
                                        if canSee then dist = d closest = char end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return closest
    end

    RunService.RenderStepped:Connect(function()
        pcall(function()
            if showFOV and fovCircle then
                local mousePos = UserInputService:GetMouseLocation()
                fovCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
                fovCircle.Radius = AIM_RADIUS
                fovCircle.Visible = true
            elseif fovCircle then
                fovCircle.Visible = false
            end
            
            if aimbotEnabled then
                local target = getTarget()
                if target then
                    local head = target:FindFirstChild("Head")
                    if head and camera then
                        local screenPos = camera:WorldToViewportPoint(head.Position)
                        local targetVec = Vector2.new(screenPos.X, screenPos.Y)
                        local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                        local move = targetVec - screenCenter
                        local smooth = math.max(1, SMOOTH_FACTOR)
                        local moveStep = move / smooth
                        if mousemoverel then mousemoverel(moveStep.X, moveStep.Y) end
                    end
                end
            end
        end)
    end)

    print("Necrophilia 코어 로직이 성공적으로 실행되었습니다.")
end)

if not success then
    warn("실행 중 오류 발생:", err)
end
