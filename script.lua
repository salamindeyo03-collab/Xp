local success, err = pcall(function()
    local repo = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/"
    local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
    local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
    local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

    local Options = Library.Options
    local Toggles = Library.Toggles

    Library.ShowToggleFrameInKeybinds = true 
    Library.ShowCustomCursor = true 
    Library.NotifySide = "Left" 

    local Window = Library:CreateWindow({
        Title = "Necrophilia",
        Center = true, AutoShow = true, Resizable = true,
        ShowCustomCursor = true, UnlockMouseWhileOpen = true,
        NotifySide = "Left", TabPadding = 8, MenuFadeTime = 0.2
    })

    local Tabs = {
        Main = Window:AddTab("Main"),
        Void = Window:AddTab("Void Spam"),
        ESP = Window:AddTab("ESP"),
        ["UI Settings"] = Window:AddTab("UI Settings"),
    }

    local AimbotSection = Tabs.Main:AddLeftGroupbox("Aimbot")
    local SilentAimSection = Tabs.Main:AddLeftGroupbox("Silent Aim")
    local TriggerbotSection = Tabs.Main:AddLeftGroupbox("Triggerbot")
    local DHSection = Tabs.Main:AddRightGroupbox("Da Hood Features")
    local UnlockSection = Tabs.Main:AddRightGroupbox("Unlock All")

    local VoidSection = Tabs.Void:AddLeftGroupbox("Void Movement")
    local OrbitSection = Tabs.Void:AddRightGroupbox("Orbit")

    local CharmSection = Tabs.ESP:AddLeftGroupbox("Charm")
    local ESPSection = Tabs.ESP:AddRightGroupbox("ESP Settings")
    local MenuSection = Tabs["UI Settings"]:AddLeftGroupbox("Menu")

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local player = Players.LocalPlayer
    local camera = workspace.CurrentCamera
    local isUnloaded = false
    local character, hrp

    -- 변수 선언
    local AIM_RADIUS = 200
    local SMOOTH_FACTOR = 1.0
    local MAX_DISTANCE = 1000
    local aimbotEnabled = false
    local aimbotKeyState = false
    local aimbotKeybindEnum = Enum.KeyCode.E
    local wallCheck = true
    local showFOV = false
    local aimbotFOVColor = Color3.fromRGB(255, 255, 255)
    local aimbotHitbox = "Head"

    local SA_ENABLED = false
    local saKeyState = false
    local saKeybindEnum = Enum.KeyCode.Q
    local SA_FOV = 50
    local SA_SHOW_FOV = true
    local SA_WALLCHECK = true
    local saFOVColor = Color3.fromRGB(255, 0, 0)
    local saHitbox = "Head"

    local TB_ENABLED = false
    local tbKeyState = false
    local tbKeybindEnum = Enum.KeyCode.E
    local TB_FOV = 50
    local TB_WALLCHECK = true
    local TB_DELAY = 0.05

    local dhAntiStompEnabled = false
    local dhRapidFireEnabled = false

    local charmToggle = false
    local charmColor = Color3.fromRGB(0, 255, 127)

    local espEnable = false
    local espBoxType = true
    local espBoxColor = Color3.fromRGB(255, 255, 255)
    local espTracer = false
    local espTracerColor = Color3.fromRGB(255, 255, 255)
    local espName = false
    local espNameColor = Color3.fromRGB(255, 255, 255)
    local espHealthBar = false
    local espHealthColor = Color3.fromRGB(255, 255, 255)

    -- Void Spam 변수
    local running = false
    local teleportMode = "VOID_SPAM"
    local voidSpamMode = "Random Far"
    local currentDistance = 500
    local teleportInterval = 0.035
    local jitterStrength = 14
    local distPlusX, distMinusX = 200000, 200000
    local distPlusY, distMinusY = 200000, 200000
    local distPlusZ, distMinusZ = 200000, 200000
    local originalCFrame, voidHideLastCFrame, lastTeleport, lastVelocityClear
    local voidX, voidZ, voidYOffset, voidYDir, voidDirX, voidDirZ, voidElapsed, voidYBase, voidDriftSpeed, voidYDriftSpeed, voidYDriftRange, voidChaos
    local teleportConnection

    -- Orbit 변수
    local orbitEnabled = false
    local orbitSpeed = 1.8
    local orbitRange = 8
    local orbitHeight = 4
    local orbitAngle = 0.0

    local function disconnect(conn)
        if conn then conn:Disconnect() end
        return nil
    end

    local function updateChar(newCharacter)
        character = newCharacter
        hrp = nil
        if character then
            hrp = character:WaitForChild("HumanoidRootPart", 5)
        end
    end

    if player.Character then updateChar(player.Character) end
    player.CharacterAdded:Connect(updateChar)
    player.CharacterRemoving:Connect(function() updateChar(nil) end)

    -- 키바인드 처리
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == aimbotKeybindEnum then aimbotKeyState = true end
        if input.KeyCode == saKeybindEnum then saKeyState = true end
        if input.KeyCode == tbKeybindEnum then tbKeyState = true end
    end)
    UserInputService.InputEnded:Connect(function(input, gpe)
        if input.KeyCode == aimbotKeybindEnum then aimbotKeyState = false end
        if input.KeyCode == saKeybindEnum then saKeyState = false end
        if input.KeyCode == tbKeybindEnum then tbKeyState = false end
    end)

    local function getHitboxPart(char, hitboxName)
        if not char then return nil end
        if hitboxName == "Head" then return char:FindFirstChild("Head")
        elseif hitboxName == "Torso" then return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        elseif hitboxName == "Left Arm" then return char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftHand") or char:FindFirstChild("LeftLowerArm") or char:FindFirstChild("LeftUpperArm")
        elseif hitboxName == "Right Arm" then return char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand") or char:FindFirstChild("RightLowerArm") or char:FindFirstChild("RightUpperArm")
        elseif hitboxName == "Left Leg" then return char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftFoot") or char:FindFirstChild("LeftLowerLeg") or char:FindFirstChild("LeftUpperLeg")
        elseif hitboxName == "Right Leg" then return char:FindFirstChild("Right Leg") or char:FindFirstChild("RightFoot") or char:FindFirstChild("RightLowerLeg") or char:FindFirstChild("RightUpperLeg")
        end
        return char:FindFirstChild("Head")
    end

    local fovCircle = Drawing.new("Circle")
    fovCircle.Color = aimbotFOVColor
    fovCircle.Thickness = 2
    fovCircle.Transparency = 1
    fovCircle.Filled = false
    fovCircle.Visible = false
    fovCircle.Radius = AIM_RADIUS

    local saFovCircle = Drawing.new("Circle")
    saFovCircle.Color = saFOVColor
    saFovCircle.Thickness = 1
    saFovCircle.Transparency = 1
    saFovCircle.Filled = false
    saFovCircle.Visible = false
    saFovCircle.Radius = SA_FOV

    local function getTarget()
        local closest, dist = nil, AIM_RADIUS
        local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        local localRoot = hrp
        if not localRoot then return nil end
        
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        rayParams.FilterDescendantsInstances = {player.Character}
        rayParams.IgnoreWater = true
        
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local char = plr.Character
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                local targetPart = getHitboxPart(char, aimbotHitbox)
                if targetPart and humanoid and humanoid.Health > 0 and char:FindFirstChild("HumanoidRootPart") then
                    local distance3D = (char.HumanoidRootPart.Position - localRoot.Position).Magnitude
                    if distance3D <= MAX_DISTANCE then
                        local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen and screenPos.Z > 0 then
                            local d = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            if d < dist then
                                local canSee = true
                                if wallCheck then
                                    local hit = workspace:Raycast(camera.CFrame.Position, (targetPart.Position - camera.CFrame.Position), rayParams)
                                    if hit and hit.Instance and not hit.Instance:IsDescendantOf(char) then canSee = false end
                                end
                                if canSee then dist = d closest = char end
                            end
                        end
                    end
                end
            end
        end
        return closest
    end

    RunService.RenderStepped:Connect(function()
        if isUnloaded then return end
        pcall(function()
            if showFOV then
                local mousePos = UserInputService:GetMouseLocation()
                fovCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
                fovCircle.Radius = AIM_RADIUS
                fovCircle.Color = aimbotFOVColor
                fovCircle.Visible = true
            else
                fovCircle.Visible = false
            end

            if aimbotEnabled and aimbotKeyState then
                local target = getTarget()
                if target and camera then
                    local targetPart = getHitboxPart(target, aimbotHitbox)
                    if targetPart then
                        local screenPos = camera:WorldToViewportPoint(targetPart.Position)
                        if screenPos.Z > 0 then
                            local targetVec = Vector2.new(screenPos.X, screenPos.Y)
                            local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                            local move = targetVec - screenCenter
                            local smooth = math.max(1, SMOOTH_FACTOR)
                            local moveX = move.X / smooth
                            local moveY = move.Y / smooth
                            if math.abs(moveX) < 5000 and math.abs(moveY) < 5000 then
                                if mousemoverel then mousemoverel(moveX, moveY) end
                            end
                        end
                    end
                end
            end
        end)
    end)

    AimbotSection:AddToggle("AimbotToggle", { Text = "Enable Aimbot", Default = false, Callback = function(v) aimbotEnabled = v end })
    AimbotSection:AddLabel("Aimbot Keybind"):AddKeyPicker("AimbotKeybind", { Default = "E", SyncToggleState = false, Mode = "Hold", Text = "Aimbot Key", NoUI = false, Callback = function(v) aimbotKeybindEnum = v end })
    AimbotSection:AddDropdown("AimbotHitbox", { Text = "Aimbot Hitbox", Values = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}, Default = 1, Callback = function(v) aimbotHitbox = v end })
    AimbotSection:AddToggle("AimbotShowFOV", { Text = "Show FOV Circle", Default = false, Callback = function(v) showFOV = v end })
    AimbotSection:AddLabel("FOV Color"):AddColorPicker("AimbotFOVColorPicker", { Default = Color3.fromRGB(255, 255, 255), Title = "Aimbot FOV Color", Transparency = 0, Callback = function(v) aimbotFOVColor = v end })
    AimbotSection:AddToggle("AimbotWallCheck", { Text = "Wall Check", Default = true, Callback = function(v) wallCheck = v end })
    AimbotSection:AddSlider("AimbotSmoothness", { Text = "Smoothness", Default = 1, Min = 1, Max = 10, Rounding = 0, Callback = function(v) SMOOTH_FACTOR = v end })
    AimbotSection:AddSlider("AimbotFOV", { Text = "FOV Radius", Default = 200, Min = 1, Max = 1000, Rounding = 0, Callback = function(v) AIM_RADIUS = v end })
    AimbotSection:AddSlider("AimbotDistance", { Text = "Max Distance", Default = 1000, Min = 1, Max = 5000, Rounding = 0, Callback = function(v) MAX_DISTANCE = v end })

    -- Silent Aim 로직
    local function safeWait(parent, name, timeout)
        if not parent then return nil end
        local success, obj = pcall(function() return parent:WaitForChild(name, timeout or 5) end)
        return success and obj or nil
    end
    local function safeRequire(path)
        if not path then return nil end
        local success, module = pcall(function() return require(path) end)
        return success and module or nil
    end

    local modulesFolder = safeWait(ReplicatedStorage, "Modules", 10)
    local UtilityModule = modulesFolder and safeRequire(safeWait(modulesFolder, "Utility", 10))
    local originalRaycast = UtilityModule and UtilityModule.Raycast or nil

    if UtilityModule and originalRaycast then
        local function getSilentTargetPart()
            local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
            local closestPart = nil
            local shortestDist = SA_FOV
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            rayParams.FilterDescendantsInstances = {player.Character}
            rayParams.IgnoreWater = true

            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                    local targetPart = getHitboxPart(plr.Character, saHitbox)
                    if targetPart and humanoid and humanoid.Health > 0 then
                        local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen and screenPos.Z > 0 then
                            local dist = (screenCenter - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                            if dist < shortestDist then
                                local canSee = true
                                if SA_WALLCHECK then
                                    local hit = workspace:Raycast(camera.CFrame.Position, (targetPart.Position - camera.CFrame.Position), rayParams)
                                    if hit and hit.Instance and not hit.Instance:IsDescendantOf(plr.Character) then canSee = false end
                                end
                                if canSee then shortestDist = dist closestPart = targetPart end
                            end
                        end
                    end
                end
            end
            return closestPart
        end

        UtilityModule.Raycast = function(self, origin, direction, distance, params, ignoreWater, debug)
            if not SA_ENABLED or not saKeyState or type(distance) ~= "number" or distance < 100 then
                return originalRaycast(self, origin, direction, distance, params, ignoreWater, debug)
            end
            local targetPart = getSilentTargetPart()
            if not targetPart then return originalRaycast(self, origin, direction, distance, params, ignoreWater, debug) end
            local targetPos = targetPart.Position
            local newDir = (targetPos - origin).Unit
            local newDist = (targetPos - origin).Magnitude
            if newDist > distance then newDist = distance targetPos = origin + (newDir * distance) end
            return { Position = targetPos, Distance = newDist, Instance = targetPart, Material = targetPart.Material, Normal = -newDir }
        end
    end

    RunService.RenderStepped:Connect(function()
        if isUnloaded then return end
        pcall(function()
            if saFovCircle then
                if SA_ENABLED and SA_SHOW_FOV and saKeyState then
                    saFovCircle.Position = camera.ViewportSize / 2
                    saFovCircle.Radius = SA_FOV
                    saFovCircle.Color = saFOVColor
                    saFovCircle.Visible = true
                else
                    saFovCircle.Visible = false
                end
            end
        end)
    end)

    SilentAimSection:AddToggle("SilentAimToggle", { Text = "Enable Silent Aim", Default = false, Callback = function(v) SA_ENABLED = v end })
    SilentAimSection:AddLabel("Silent Keybind"):AddKeyPicker("SilentAimKeybind", { Default = "Q", SyncToggleState = false, Mode = "Hold", Text = "Silent Key", NoUI = false, Callback = function(v) saKeybindEnum = v end })
    SilentAimSection:AddDropdown("SilentAimHitbox", { Text = "Silent Aim Hitbox", Values = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}, Default = 1, Callback = function(v) saHitbox = v end })
    SilentAimSection:AddToggle("SilentAimWallCheck", { Text = "Wall Check", Default = true, Callback = function(v) SA_WALLCHECK = v end })
    SilentAimSection:AddToggle("SilentAimShowFOV", { Text = "Show Silent FOV", Default = true, Callback = function(v) SA_SHOW_FOV = v end })
    SilentAimSection:AddLabel("SA FOV Color"):AddColorPicker("SilentAimFOVColorPicker", { Default = Color3.fromRGB(255, 0, 0), Title = "Silent Aim FOV Color", Transparency = 0, Callback = function(v) saFOVColor = v end })
    SilentAimSection:AddSlider("SilentAimFOV", { Text = "Silent FOV Radius", Default = 50, Min = 10, Max = 1000, Rounding = 0, Callback = function(v) SA_FOV = v end })

    -- Triggerbot 로직
    local function isLobbyVisible()
        local ok, res = pcall(function() return player.PlayerGui.MainGui.MainFrame.Lobby.Currency.Visible == true end)
        return ok and res or false
    end

    task.spawn(function()
        while not isUnloaded do
            task.wait()
            pcall(function()
                if TB_ENABLED and not isLobbyVisible() then
                    if tbKeyState then
                        local mousePos = UserInputService:GetMouseLocation()
                        local localRoot = hrp
                        if localRoot then
                            local rayParams = RaycastParams.new()
                            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                            rayParams.FilterDescendantsInstances = {player.Character}
                            rayParams.IgnoreWater = true
                            local closest, dist = nil, TB_FOV
                            for _, plr in pairs(Players:GetPlayers()) do
                                if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                                    local pos, onScreen = camera:WorldToViewportPoint(plr.Character.Head.Position)
                                    if onScreen and pos.Z > 0 then
                                        local d = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                                        if d < dist then
                                            local canSee = true
                                            if TB_WALLCHECK then
                                                local hit = workspace:Raycast(camera.CFrame.Position, (plr.Character.Head.Position - camera.CFrame.Position), rayParams)
                                                if hit and hit.Instance and not hit.Instance:IsDescendantOf(plr.Character) then canSee = false end
                                            end
                                            if canSee then dist = d closest = plr.Character end
                                        end
                                    end
                                end
                            end
                            if closest and mouse1click then mouse1click() task.wait(TB_DELAY) end
                        end
                    end
                end
            end)
        end
    end)

    TriggerbotSection:AddToggle("TriggerbotToggle", { Text = "Enable Triggerbot", Default = false, Callback = function(v) TB_ENABLED = v end })
    TriggerbotSection:AddLabel("Trigger Keybind"):AddKeyPicker("TriggerbotKeybind", { Default = "E", SyncToggleState = false, Mode = "Hold", Text = "Trigger Key", NoUI = false, Callback = function(v) tbKeybindEnum = v end })
    TriggerbotSection:AddToggle("TriggerbotWallCheck", { Text = "Wall Check", Default = true, Callback = function(v) TB_WALLCHECK = v end })
    TriggerbotSection:AddSlider("TriggerbotFOV", { Text = "Trigger FOV Radius", Default = 50, Min = 1, Max = 1000, Rounding = 0, Callback = function(v) TB_FOV = v end })
    TriggerbotSection:AddSlider("TriggerbotDelay", { Text = "Fire Delay (ms)", Default = 50, Min = 10, Max = 1000, Rounding = 0, Callback = function(v) TB_DELAY = v / 1000 end })

    -- Da Hood Features
    task.spawn(function()
        while not isUnloaded do
            if dhRapidFireEnabled then
                pcall(function()
                    local backpack = player:FindFirstChild("Backpack")
                    if backpack then
                        for _, tool in ipairs(backpack:GetChildren()) do
                            if tool:IsA("Tool") and tool.Name == "Combat" then
                                local shooting = tool:FindFirstChild("ShootingCooldown")
                                if shooting then shooting.Value = 0.000000001 end
                            end
                        end
                    end
                end)
            end
            task.wait(0.001)
        end
    end)

    RunService.RenderStepped:Connect(function()
        if isUnloaded then return end
        if dhAntiStompEnabled then
            pcall(function()
                local char = player.Character
                if char then
                    local bodyEffects = char:FindFirstChild("BodyEffects")
                    if bodyEffects then
                        local ko = bodyEffects:FindFirstChild("K.O")
                        if ko and ko.Value == true then
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if hum then hum.Health = 0 end
                        end
                    end
                end
            end)
        end
    end)

    DHSection:AddToggle("DHRapidFire", { Text = "Enable Rapid Fire", Default = false, Callback = function(v) dhRapidFireEnabled = v end })
    DHSection:AddToggle("DHAntiStomp", { Text = "Enable Anti Stomp", Default = false, Callback = function(v) dhAntiStompEnabled = v end })

    -- 보이드 스팸 로직
    local function resetVoidPattern()
        voidX = math.random(-1e8, 1e8)
        voidZ = math.random(-1e8, 1e8)
        voidYOffset = 0
        voidYDir = 1
        voidDirX = math.random() * 2 - 1
        voidDirZ = math.random() * 2 - 1
        voidElapsed = 0
        voidYBase = 1e10 + math.random(-5e9, 5e9)
    end

    local function safeTeleport(pos)
        if not hrp then return end
        local x = pos.X
        local y = math.clamp(pos.Y, 2, hrp.Position.Y + 800)
        local z = pos.Z
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = character and { character } or {}
        local hit = workspace:Raycast(Vector3.new(x, y + 500, z), Vector3.new(0, -1000, 0), params)
        if hit then y = math.max(hit.Position.Y + 3, 2) end
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(x, y, z)
    end

    local function rawVoidTeleport(pos)
        if not hrp then return end
        if tick() - lastVelocityClear > 0.2 then
            lastVelocityClear = tick()
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
        hrp.CFrame = CFrame.new(pos)
    end

    local function getVoidHidePosition()
        if not hrp then return nil end
        return Vector3.new(hrp.Position.X + 2e15, 999999, hrp.Position.Z + 2e15)
    end

    local function getDirectionalLimitOffset()
        local raw = Vector3.new(math.random(-distMinusX, distPlusX), math.random(-distMinusY, distPlusY), math.random(-distMinusZ, distPlusZ))
        if raw.Magnitude <= 0 then return Vector3.zero end
        return raw.Unit * math.min(raw.Magnitude, currentDistance)
    end

    local function computeVoidDriftDir(t)
        local nx, nz, amplitude, frequency = 0, 0, 1, 0.0001
        for _ = 1, 4 do
            nx += math.noise(t * frequency, 0) * amplitude
            nz += math.noise(0, t * frequency) * amplitude
            frequency *= 2.37
            amplitude *= 0.5
        end
        nx += math.sin(t * 0.00213) * math.cos(t * 0.00344) * 0.2
        nz += math.cos(t * 0.00131) * math.sin(t * 0.00579) * 0.2
        local len = math.sqrt(nx * nx + nz * nz)
        if len < 0.001 then return math.cos(t * 0.1), math.sin(t * 0.1) end
        return nx / len, nz / len
    end

    local function getFarVoidPosition(dt)
        voidElapsed += dt
        if voidSpamMode == "Still Point" then return Vector3.new(voidX, voidYBase + voidYOffset, voidZ) end
        if voidSpamMode == "Slow Drift" then
            local dx, dz = computeVoidDriftDir(voidElapsed)
            voidDirX += (dx - voidDirX) * voidChaos * dt * 10
            voidDirZ += (dz - voidDirZ) * voidChaos * dt * 10
            voidX += voidDirX * voidDriftSpeed * dt
            voidZ += voidDirZ * voidDriftSpeed * dt
            voidYOffset += voidYDir * voidYDriftSpeed * dt
            if math.abs(voidYOffset) >= voidYDriftRange then voidYDir = -voidYDir end
            return Vector3.new(voidX, voidYBase + voidYOffset, voidZ)
        end
        local r = math.max(currentDistance * 10000, 1e11)
        local sign = math.random() > 0.5 and 1 or -1
        local jitter = Vector3.new(math.random(-1e9, 1e9), math.random(-1e8, 1e8), math.random(-1e9, 1e9))
        return Vector3.new(voidX + r * sign, voidYBase + jitter.Y, voidZ + r * sign) + jitter
    end

    local function performVoidStep(dt, phase)
        if not hrp then return false end
        dt = dt or teleportInterval
        phase = phase or (voidElapsed + dt * 28)
        if teleportMode == "VOID_HIDE" then
            if not voidHideLastCFrame then voidHideLastCFrame = hrp.CFrame end
            local hidePos = getVoidHidePosition()
            if hidePos then rawVoidTeleport(hidePos) end
            return true
        end
        if teleportMode == "VOID_SPAM" then
            rawVoidTeleport(getFarVoidPosition(dt))
            return true
        end
        local offset
        if teleportMode == "FORWARD" then offset = hrp.CFrame.LookVector * currentDistance
        elseif teleportMode == "CAMERA" and workspace.CurrentCamera then offset = workspace.CurrentCamera.CFrame.LookVector * currentDistance
        elseif teleportMode == "DIRECTIONAL" then offset = getDirectionalLimitOffset()
        else
            local r1 = currentDistance * (0.60 + 0.40 * math.sin(phase * 2.3))
            local r2 = currentDistance * (0.25 + 0.15 * math.sin(phase * 5.7))
            local r3 = currentDistance * (0.10 + 0.10 * math.sin(phase * 11.3))
            local oX = math.cos(phase * 7.1) * r1 + math.cos(phase * 13.4) * r2 + math.cos(phase * 21.9) * r3
            local oZ = math.sin(phase * 7.1) * r1 + math.sin(phase * 13.4) * r2 + math.sin(phase * 21.9) * r3
            local oY = math.sin(phase * 9) * r1 * 0.4 + math.sin(phase * 17) * r2 * 0.3
            local jX = math.noise(phase * 6, 0, 0) * jitterStrength * 3 + (math.random() - 0.5) * jitterStrength * 2.5
            local jY = math.noise(0, phase * 6, 0) * jitterStrength * 1.5 + (math.random() - 0.5) * jitterStrength * 1.2
            local jZ = math.noise(0, 0, phase * 6) * jitterStrength * 3 + (math.random() - 0.5) * jitterStrength * 2.5
            offset = Vector3.new(oX + jX, oY + jY, oZ + jZ)
        end
        safeTeleport(hrp.Position + offset)
        return true
    end

    local function startTeleport()
        teleportConnection = disconnect(teleportConnection)
        if hrp then originalCFrame = hrp.CFrame end
        local phase = 0
        teleportConnection = RunService.Heartbeat:Connect(function(dt)
            if not running or not hrp or isUnloaded then return end
            if tick() - lastTeleport < teleportInterval then return end
            lastTeleport = tick()
            phase += dt * 28
            performVoidStep(dt, phase)
        end)
    end

    local function stopTeleport()
        teleportConnection = disconnect(teleportConnection)
        if teleportMode == "VOID_HIDE" and hrp and voidHideLastCFrame then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.CFrame = voidHideLastCFrame
            voidHideLastCFrame = nil
        elseif hrp and originalCFrame then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.CFrame = originalCFrame
        end
        originalCFrame = nil
    end

    VoidSection:AddToggle("VoidMovement", { Text = "Enable Void Movement", Default = false, Callback = function(v) running = v if v then startTeleport() else stopTeleport() end end })
    VoidSection:AddDropdown("TeleportMode", { Text = "Movement Mode", Values = {"VOID_SPAM", "VOID_HIDE", "RANDOM", "CAMERA", "FORWARD", "DIRECTIONAL"}, Default = 1, Callback = function(v) teleportMode = v end })
    VoidSection:AddSlider("Distance", { Text = "Distance", Default = 500, Min = 50, Max = 50000000, Rounding = 0, Callback = function(v) currentDistance = v end })
    VoidSection:AddSlider("TeleportInterval", { Text = "Step Interval (s)", Default = 0.035, Min = 0.01, Max = 2, Rounding = 2, Callback = function(v) teleportInterval = v end })
    VoidSection:AddSlider("JitterStrength", { Text = "Jitter Strength", Default = 14, Min = 0, Max = 60, Rounding = 0, Callback = function(v) jitterStrength = v end })
    VoidSection:AddButton({ Text = "Reset Pattern", Func = function() resetVoidPattern() end })

    -- Orbit 로직
    RunService.Heartbeat:Connect(function()
        if isUnloaded then return end
        if orbitEnabled and hrp then
            local target = getTarget()
            if target and target.Character then
                local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    orbitAngle = orbitAngle + (0.004 * orbitSpeed)
                    if orbitAngle > math.pi * 2 then orbitAngle = orbitAngle - (math.pi * 2) end
                    
                    local orbitOffset = Vector3.new(orbitRange * math.sin(orbitAngle), orbitHeight, orbitRange * math.cos(orbitAngle))
                    local finalPos = targetRoot.Position + orbitOffset
                    hrp.CFrame = CFrame.lookAt(finalPos, targetRoot.Position)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                end
            end
        end
    end)

    OrbitSection:AddToggle("OrbitEnabled", { Text = "Enable Orbit", Default = false, Callback = function(v) orbitEnabled = v end })
    OrbitSection:AddSlider("OrbitSpeed", { Text = "Orbit Speed", Default = 1.8, Min = 0.1, Max = 12, Rounding = 1, Callback = function(v) orbitSpeed = v end })
    OrbitSection:AddSlider("OrbitRange", { Text = "Orbit Range", Default = 8, Min = 2, Max = 60, Rounding = 0, Callback = function(v) orbitRange = v end })
    OrbitSection:AddSlider("OrbitHeight", { Text = "Orbit Height", Default = 4, Min = -20, Max = 40, Rounding = 0, Callback = function(v) orbitHeight = v end })

    -- Charm 로직
    RunService.RenderStepped:Connect(function()
        if isUnloaded then return end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local char = p.Character
                if not charmToggle or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then
                    local hl = char:FindFirstChild("CharmHighlight")
                    if hl then hl:Destroy() end
                else
                    local hl = char:FindFirstChild("CharmHighlight")
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "CharmHighlight"
                        hl.Parent = char
                    end
                    hl.FillTransparency = 1
                    hl.OutlineColor = charmColor
                end
            end
        end
    end)

    CharmSection:AddToggle("CharmToggle", { Text = "Enable Charm (Highlight)", Default = false, Callback = function(v) charmToggle = v end })
    CharmSection:AddLabel("Charm Color"):AddColorPicker("CharmColor", { Default = charmColor, Title = "Charm Color", Transparency = 0, Callback = function(v) charmColor = v end })

    -- ESP 로직
    local ESPObjects = {}
    local function createESPObject()
        local obj = {}
        obj.GlowLines, obj.Lines = {}, {}
        for i = 1, 4 do
            obj.GlowLines[i] = Drawing.new("Line"); obj.GlowLines[i].Thickness = 2; obj.GlowLines[i].Transparency = 0.6
            obj.Lines[i] = Drawing.new("Line"); obj.Lines[i].Thickness = 1
        end
        obj.GlowCorners, obj.Corners = {}, {}
        for i = 1, 8 do
            obj.GlowCorners[i] = Drawing.new("Line"); obj.GlowCorners[i].Thickness = 2; obj.GlowCorners[i].Transparency = 0.6
            obj.Corners[i] = Drawing.new("Line"); obj.Corners[i].Thickness = 1
        end
        obj.Tracer = Drawing.new("Line"); obj.Tracer.Thickness = 1
        obj.NameText = Drawing.new("Text"); obj.NameText.Center = true; obj.NameText.Outline = true; obj.NameText.Size = 13; obj.NameText.Font = 2
        obj.HealthBarBg = Drawing.new("Square"); obj.HealthBarBg.Thickness = 1; obj.HealthBarBg.Filled = false
        obj.HealthBarFill = Drawing.new("Square"); obj.HealthBarFill.Filled = true
        return obj
    end

    local function hideESP(p)
        local obj = ESPObjects[p]
        if not obj then return end
        for _, c in ipairs(obj.GlowLines) do c.Visible = false end
        for _, c in ipairs(obj.Lines) do c.Visible = false end
        for _, c in ipairs(obj.GlowCorners) do c.Visible = false end
        for _, c in ipairs(obj.Corners) do c.Visible = false end
        obj.Tracer.Visible = false; obj.NameText.Visible = false; obj.HealthBarBg.Visible = false; obj.HealthBarFill.Visible = false
    end

    local function clearESP(p)
        local obj = ESPObjects[p]
        if obj then
            for _, c in ipairs(obj.GlowLines) do pcall(function() c:Remove() end) end
            for _, c in ipairs(obj.Lines) do pcall(function() c:Remove() end) end
            for _, c in ipairs(obj.GlowCorners) do pcall(function() c:Remove() end) end
            for _, c in ipairs(obj.Corners) do pcall(function() c:Remove() end) end
            pcall(function() obj.Tracer:Remove() end); pcall(function() obj.NameText:Remove() end)
            pcall(function() obj.HealthBarBg:Remove() end); pcall(function() obj.HealthBarFill:Remove() end)
            ESPObjects[p] = nil
        end
    end

    Players.PlayerRemoving:Connect(clearESP)

    RunService:BindToRenderStep("ESPRender", Enum.RenderPriority.Camera.Value + 1, function()
        if isUnloaded then return end
        pcall(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player then
                    if not espEnable or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") or not p.Character:FindFirstChild("Humanoid") or not p.Character:FindFirstChild("Head") or p.Character.Humanoid.Health <= 0 then
                        hideESP(p)
                    else
                        local char = p.Character
                        local root = char.HumanoidRootPart
                        if not ESPObjects[p] then ESPObjects[p] = createESPObject() end
                        local obj = ESPObjects[p]
                        
                        local rootPos, rootVis = camera:WorldToViewportPoint(root.Position)
                        if not rootVis or rootPos.Z < 0 then
                            hideESP(p)
                        else
                            -- 튕김 방지: Z(거리)를 기반으로 고정된 높이/너비 계산 및 픽셀 단위 정렬
                            local distance = rootPos.Z
                            local height = math.floor((2000 / distance) + 0.5)
                            local width = math.floor((height / 2) + 0.5)
                            
                            local boxTop = math.floor(rootPos.Y - height * 0.5 + 0.5)
                            local boxBottom = boxTop + height
                            local boxLeft = math.floor(rootPos.X - width * 0.5 + 0.5)
                            local boxRight = boxLeft + width
                            
                            for _, c in ipairs(obj.GlowLines) do c.Color = espBoxColor end
                            for _, c in ipairs(obj.Lines) do c.Color = espBoxColor end
                            for _, c in ipairs(obj.GlowCorners) do c.Color = espBoxColor end
                            for _, c in ipairs(obj.Corners) do c.Color = espBoxColor end
                            obj.Tracer.Color = espTracerColor; obj.NameText.Color = espNameColor; obj.HealthBarFill.Color = espHealthColor; obj.HealthBarBg.Color = Color3.fromRGB(0, 0, 0)
                            
                            if espTracer then
                                obj.Tracer.Visible = true
                                obj.Tracer.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
                                obj.Tracer.To = Vector2.new(rootPos.X, boxBottom)
                            else
                                obj.Tracer.Visible = false
                            end
                            
                            obj.NameText.Visible = espName
                            if espName then
                                obj.NameText.Text = p.Name
                                obj.NameText.Position = Vector2.new(rootPos.X, boxTop - 16)
                            end
                            
                            if espHealthBar then
                                local hp = char.Humanoid.Health; local maxHp = char.Humanoid.MaxHealth; local ratio = hp / maxHp
                                local barX, barY = boxLeft - 6, boxTop; local barW, barH = 3, height
                                obj.HealthBarBg.Visible = true; obj.HealthBarBg.Position = Vector2.new(barX, barY); obj.HealthBarBg.Size = Vector2.new(barW, barH)
                                obj.HealthBarFill.Visible = true; obj.HealthBarFill.Position = Vector2.new(barX, barY + (barH * (1 - ratio))); obj.HealthBarFill.Size = Vector2.new(barW, barH * ratio)
                            else
                                obj.HealthBarBg.Visible = false; obj.HealthBarFill.Visible = false
                            end
                            
                            for _, c in ipairs(obj.GlowLines) do c.Visible = false end
                            for _, c in ipairs(obj.Lines) do c.Visible = false end
                            for _, c in ipairs(obj.GlowCorners) do c.Visible = false end
                            for _, c in ipairs(obj.Corners) do c.Visible = false end
                            
                            if espBoxType then
                                obj.GlowLines[1].Visible = true; obj.GlowLines[1].From = Vector2.new(boxLeft, boxTop); obj.GlowLines[1].To = Vector2.new(boxRight, boxTop)
                                obj.GlowLines[2].Visible = true; obj.GlowLines[2].From = Vector2.new(boxLeft, boxBottom); obj.GlowLines[2].To = Vector2.new(boxRight, boxBottom)
                                obj.GlowLines[3].Visible = true; obj.GlowLines[3].From = Vector2.new(boxLeft, boxTop); obj.GlowLines[3].To = Vector2.new(boxLeft, boxBottom)
                                obj.GlowLines[4].Visible = true; obj.GlowLines[4].From = Vector2.new(boxRight, boxTop); obj.GlowLines[4].To = Vector2.new(boxRight, boxBottom)
                                
                                obj.Lines[1].Visible = true; obj.Lines[1].From = Vector2.new(boxLeft, boxTop); obj.Lines[1].To = Vector2.new(boxRight, boxTop)
                                obj.Lines[2].Visible = true; obj.Lines[2].From = Vector2.new(boxLeft, boxBottom); obj.Lines[2].To = Vector2.new(boxRight, boxBottom)
                                obj.Lines[3].Visible = true; obj.Lines[3].From = Vector2.new(boxLeft, boxTop); obj.Lines[3].To = Vector2.new(boxLeft, boxBottom)
                                obj.Lines[4].Visible = true; obj.Lines[4].From = Vector2.new(boxRight, boxTop); obj.Lines[4].To = Vector2.new(boxRight, boxBottom)
                            end
                        end
                    end
                end
            end
        end)
    end)

    ESPSection:AddToggle("ESPEnable", { Text = "Enable ESP", Default = false, Callback = function(v) espEnable = v end })
    ESPSection:AddToggle("ESPBoxType", { Text = "Box ESP", Default = true, Callback = function(v) espBoxType = v end }):AddColorPicker("ESPBoxColor", { Default = espBoxColor, Title = "Box Color", Callback = function(v) espBoxColor = v end })
    ESPSection:AddToggle("ESPTracer", { Text = "Tracer ESP", Default = false, Callback = function(v) espTracer = v end }):AddColorPicker("ESPTracerColor", { Default = espTracerColor, Title = "Tracer Color", Callback = function(v) espTracerColor = v end })
    ESPSection:AddToggle("ESPName", { Text = "Name ESP", Default = false, Callback = function(v) espName = v end }):AddColorPicker("ESPNameColor", { Default = espNameColor, Title = "Name Color", Callback = function(v) espNameColor = v end })
    ESPSection:AddToggle("ESPHealthBar", { Text = "Health Bar ESP", Default = false, Callback = function(v) espHealthBar = v end }):AddColorPicker("ESPHealthColor", { Default = espHealthColor, Title = "Health Color", Callback = function(v) espHealthColor = v end })

    -- UI 설정 및 언로드
    MenuSection:AddButton("Unload", function()
        isUnloaded = true
        RunService:UnbindFromRenderStep("ESPRender")
        pcall(function() if fovCircle then fovCircle.Visible = false fovCircle:Remove() end end)
        pcall(function() if saFovCircle then saFovCircle.Visible = false saFovCircle:Remove() end end)
        for p, obj in pairs(ESPObjects) do clearESP(p) end
        Library:Unload()
    end)

    Library.ToggleKeybind = Options.MenuKeybind 
    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
    ThemeManager:SetFolder("MyScriptHub")
    SaveManager:SetFolder("MyScriptHub/specific-game")
    SaveManager:SetSubFolder("specific-place") 
    SaveManager:BuildConfigSection(Tabs["UI Settings"])
    
    -- 이전 설정 로드 무시하고 무조건 보라색(cultware) 테마로 강제 고정
    ThemeManager.Theme = ThemeManager.Theme or {}
    ThemeManager.Theme.Main = Color3.fromRGB(30, 30, 30)
    ThemeManager.Theme.Background = Color3.fromRGB(25, 25, 25)
    ThemeManager.Theme.Border = Color3.fromRGB(100, 0, 110)
    ThemeManager.Theme.Text = Color3.fromRGB(255, 255, 255)
    ThemeManager.Theme.TextDark = Color3.fromRGB(150, 150, 150)
    ThemeManager.Theme.Accent = Color3.fromRGB(185, 0, 191) -- 보라색
    ThemeManager.Theme.TabText = Color3.fromRGB(200, 200, 200)
    ThemeManager.Theme.TabBackground = Color3.fromRGB(40, 40, 40)
    
    ThemeManager:ApplyToTab(Tabs["UI Settings"])
end)

if not success then warn("Script failed to load:", err) end
