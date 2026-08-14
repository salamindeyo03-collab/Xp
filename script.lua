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
        ESP = Window:AddTab("ESP"),
        ["UI Settings"] = Window:AddTab("UI Settings"),
    }

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local player = Players.LocalPlayer
    local camera = workspace.CurrentCamera

    local function isTeammate(plr)
        if not plr then return false end
        if player.Team and plr.Team and player.Team == plr.Team then 
            return true 
        end
        if player.TeamColor and plr.TeamColor and player.TeamColor == plr.TeamColor then 
            return true 
        end
        return false
    end

    local function getHitboxPart(character, hitboxName)
        if not character then return nil end
        if hitboxName == "Head" then
            return character:FindFirstChild("Head")
        elseif hitboxName == "Torso" then
            return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        elseif hitboxName == "Left Arm" then
            return character:FindFirstChild("Left Arm") or character:FindFirstChild("LeftHand") or character:FindFirstChild("LeftLowerArm") or character:FindFirstChild("LeftUpperArm")
        elseif hitboxName == "Right Arm" then
            return character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand") or character:FindFirstChild("RightLowerArm") or character:FindFirstChild("RightUpperArm")
        elseif hitboxName == "Left Leg" then
            return character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftFoot") or character:FindFirstChild("LeftLowerLeg") or character:FindFirstChild("LeftUpperLeg")
        elseif hitboxName == "Right Leg" then
            return character:FindFirstChild("Right Leg") or character:FindFirstChild("RightFoot") or character:FindFirstChild("RightLowerLeg") or character:FindFirstChild("RightUpperLeg")
        end
        return character:FindFirstChild("Head")
    end

    -- ==========================================
    -- AIMBOT 설정
    -- ==========================================
    local AIM_RADIUS = 200
    local SMOOTH_FACTOR = 1.0
    local MAX_DISTANCE = 1000
    local aimbotEnabled = false
    local teamCheck = true
    local wallCheck = true
    local showFOV = false
    local aimbotFOVColor = Color3.fromRGB(255, 255, 255)
    local aimbotFOVRainbow = false
    local aimbotHitbox = "Head"

    local fovCircle = nil
    if Drawing then
        pcall(function()
            fovCircle = Drawing.new("Circle")
            fovCircle.Color = aimbotFOVColor
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
            if plr ~= player and plr.Character then
                local char = plr.Character
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                local targetPart = getHitboxPart(char, aimbotHitbox)
                
                if targetPart and humanoid and humanoid.Health > 0 and char:FindFirstChild("HumanoidRootPart") then
                    local isTeammateVar = teamCheck and isTeammate(plr)
                    if not isTeammateVar then
                        local distance3D = (char.HumanoidRootPart.Position - localRoot.Position).Magnitude
                        if distance3D <= MAX_DISTANCE then
                            local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                            if onScreen and screenPos.Z > 0 then
                                local d = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                                if d < dist then
                                    local canSee = true
                                    if wallCheck then
                                        local origin = camera.CFrame.Position
                                        local hit = workspace:Raycast(origin, (targetPart.Position - origin), rayParams)
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
        return closest
    end

    local AimbotRenderConnection
    AimbotRenderConnection = RunService.RenderStepped:Connect(function()
        pcall(function()
            if showFOV and fovCircle then
                local mousePos = UserInputService:GetMouseLocation()
                fovCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
                fovCircle.Radius = AIM_RADIUS
                if aimbotFOVRainbow then
                    fovCircle.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                else
                    fovCircle.Color = aimbotFOVColor
                end
                fovCircle.Visible = true
            elseif fovCircle then
                fovCircle.Visible = false
            end

            local isKeybindActive = Options.AimbotKeybind and Options.AimbotKeybind:GetState() or false
            if aimbotEnabled and isKeybindActive then
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
                            if math.abs(moveX) < 5000 and math.abs(move.Y) < 5000 then
                                if mousemoverel then mousemoverel(moveX, moveY) end
                            end
                        end
                    end
                end
            end
        end)
    end)

    local AimbotGroupBox = Tabs.Main:AddLeftGroupbox("Aimbot")
    AimbotGroupBox:AddToggle("AimbotToggle", { Text = "Enable Aimbot", Default = false, Callback = function(Value) aimbotEnabled = Value end })
    AimbotGroupBox:AddLabel("Aimbot Keybind"):AddKeyPicker("AimbotKeybind", { Default = "MB2", SyncToggleState = false, Mode = "Hold", Text = "Aimbot Key", NoUI = false })
    AimbotGroupBox:AddDropdown("AimbotHitbox", {
        Text = "Aimbot Hitbox",
        Values = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" },
        Default = 1,
        Callback = function(Value) aimbotHitbox = Value end
    })
    AimbotGroupBox:AddToggle("AimbotShowFOV", { Text = "Show FOV Circle", Default = false, Callback = function(Value) showFOV = Value end })
    AimbotGroupBox:AddLabel("FOV Color"):AddColorPicker("AimbotFOVColorPicker", { Default = Color3.fromRGB(255, 255, 255), Title = "Aimbot FOV Color", Transparency = 0, Callback = function(Value) aimbotFOVColor = Value end })
    AimbotGroupBox:AddToggle("AimbotFOVRainbow", { Text = "Rainbow FOV", Default = false, Callback = function(Value) aimbotFOVRainbow = Value end })
    AimbotGroupBox:AddToggle("AimbotTeamCheck", { Text = "Team Check", Default = true, Callback = function(Value) teamCheck = Value end })
    AimbotGroupBox:AddToggle("AimbotWallCheck", { Text = "Wall Check", Default = true, Callback = function(Value) wallCheck = Value end })
    AimbotGroupBox:AddSlider("AimbotSmoothness", { Text = "Smoothness", Default = 1, Min = 1, Max = 10, Rounding = 0, Callback = function(Value) SMOOTH_FACTOR = Value end })
    AimbotGroupBox:AddSlider("AimbotFOV", { Text = "FOV Radius", Default = 200, Min = 1, Max = 1000, Rounding = 0, Callback = function(Value) AIM_RADIUS = Value end })
    AimbotGroupBox:AddSlider("AimbotDistance", { Text = "Max Distance", Default = 1000, Min = 1, Max = 5000, Rounding = 0, Callback = function(Value) MAX_DISTANCE = Value end })

    -- ==========================================
    -- SILENT AIM 설정 (완벽하게 수정됨)
    -- ==========================================
    local SA_ENABLED = false
    local SA_FOV = 100 -- 기본 FOV 100으로 상향
    local SA_SHOW_FOV = true
    local SA_TEAMCHECK = true
    local SA_WALLCHECK = true
    local saFOVColor = Color3.fromRGB(255, 0, 0)
    local saFOVRainbow = false
    local saHitbox = "Head"

    local saFovCircle = nil
    if Drawing then
        pcall(function()
            saFovCircle = Drawing.new("Circle")
            saFovCircle.Color = saFOVColor
            saFovCircle.Thickness = 1
            saFovCircle.Transparency = 1
            saFovCircle.Filled = false
            saFovCircle.Visible = false
            saFovCircle.Radius = SA_FOV
        end)
    end

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
    local function safeClone(t)
        if type(t) ~= "table" then return {} end
        if table.clone then return table.clone(t) end
        local copy = {}
        for k, v in pairs(t) do copy[k] = v end
        return copy
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
                    local isTeammateVar = SA_TEAMCHECK and isTeammate(plr)
                    if not isTeammateVar then
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
            end
            return closestPart
        end

        local function hookedRaycast(...)
            local args = {...}
            local isMethodCall = (type(args[1]) == "table" and args[1] == UtilityModule)
            
            local origin, direction, distance, params, ignoreWater, debug
            if isMethodCall then
                origin, direction, distance, params, ignoreWater, debug = args[2], args[3], args[4], args[5], args[6], args[7]
            else
                origin, direction, distance, params, ignoreWater, debug = args[1], args[2], args[3], args[4], args[5], args[6]
            end
            
            local isKeybindActive = Options.SilentAimKeybind and Options.SilentAimKeybind:GetState() or false
            
            -- 거리 제한(distance < 100)을 없애고 키바인드 및 토글만 체크
            if not SA_ENABLED or not isKeybindActive then
                return originalRaycast(...)
            end
            
            local targetPart = getSilentTargetPart()
            if not targetPart then 
                return originalRaycast(...) 
            end
            
            local targetPos = targetPart.Position
            local newDir = (targetPos - origin).Unit
            local newDist = (targetPos - origin).Magnitude
            
            if type(distance) == "number" and newDist > distance then 
                newDist = distance 
                targetPos = origin + (newDir * distance) 
            end
            
            return { Position = targetPos, Distance = newDist, Instance = targetPart, Material = targetPart.Material, Normal = -newDir }
        end

        -- hookfunction를 사용하여 안전하게 후킹
        if hookfunction then
            hookfunction(originalRaycast, hookedRaycast)
        else
            UtilityModule.Raycast = hookedRaycast
        end
    end

    RunService.RenderStepped:Connect(function()
        pcall(function()
            local isKeybindActive = Options.SilentAimKeybind and Options.SilentAimKeybind:GetState() or false
            if saFovCircle then
                if SA_ENABLED and SA_SHOW_FOV and isKeybindActive then
                    saFovCircle.Position = camera.ViewportSize / 2
                    saFovCircle.Radius = SA_FOV
                    if saFOVRainbow then
                        saFovCircle.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                    else
                        saFovCircle.Color = saFOVColor
                    end
                    saFovCircle.Visible = true
                else
                    saFovCircle.Visible = false
                end
            end
        end)
    end)

    local SilentAimGroupBox = Tabs.Main:AddLeftGroupbox("Silent Aim")
    SilentAimGroupBox:AddToggle("SilentAimToggle", { Text = "Enable Silent Aim", Default = false, Callback = function(Value) SA_ENABLED = Value end })
    SilentAimGroupBox:AddLabel("Silent Keybind"):AddKeyPicker("SilentAimKeybind", { Default = "MB2", SyncToggleState = false, Mode = "Hold", Text = "Silent Key", NoUI = false })
    SilentAimGroupBox:AddDropdown("SilentAimHitbox", {
        Text = "Silent Aim Hitbox",
        Values = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" },
        Default = 1,
        Callback = function(Value) saHitbox = Value end
    })
    SilentAimGroupBox:AddToggle("SilentAimTeamCheck", { Text = "Team Check", Default = true, Callback = function(Value) SA_TEAMCHECK = Value end })
    SilentAimGroupBox:AddToggle("SilentAimWallCheck", { Text = "Wall Check", Default = true, Callback = function(Value) SA_WALLCHECK = Value end })
    SilentAimGroupBox:AddToggle("SilentAimShowFOV", { Text = "Show Silent FOV", Default = true, Callback = function(Value) SA_SHOW_FOV = Value end })
    SilentAimGroupBox:AddLabel("SA FOV Color"):AddColorPicker("SilentAimFOVColorPicker", { Default = Color3.fromRGB(255, 0, 0), Title = "Silent Aim FOV Color", Transparency = 0, Callback = function(Value) saFOVColor = Value end })
    SilentAimGroupBox:AddToggle("SilentAimFOVRainbow", { Text = "Rainbow FOV", Default = false, Callback = function(Value) saFOVRainbow = Value end })
    SilentAimGroupBox:AddSlider("SilentAimFOV", { Text = "Silent FOV Radius", Default = 100, Min = 10, Max = 1000, Rounding = 0, Callback = function(Value) SA_FOV = Value end })

    -- ==========================================
    -- TRIGGERBOT 설정
    -- ==========================================
    local TB_ENABLED = false
    local TB_FOV = 50
    local TB_WALLCHECK = true
    local TB_TEAMCHECK = true 
    local TB_DELAY = 0.05

    local function isLobbyVisible()
        local ok, res = pcall(function() return player.PlayerGui.MainGui.MainFrame.Lobby.Currency.Visible == true end)
        return ok and res or false
    end

    task.spawn(function()
        while task.wait() do
            pcall(function()
                if TB_ENABLED and not isLobbyVisible() then
                    local isKeybindActive = Options.TriggerbotKeybind and Options.TriggerbotKeybind:GetState() or false
                    if isKeybindActive then
                        local mousePos = UserInputService:GetMouseLocation()
                        local localRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if localRoot then
                            local rayParams = RaycastParams.new()
                            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                            rayParams.FilterDescendantsInstances = {player.Character}
                            rayParams.IgnoreWater = true
                            local closest, dist = nil, TB_FOV
                            for _, plr in pairs(Players:GetPlayers()) do
                                if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                                    local isTeammateVar = TB_TEAMCHECK and isTeammate(plr)
                                    if not isTeammateVar then
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
                            end
                            if closest and mouse1click then mouse1click() task.wait(TB_DELAY) end
                        end
                    end
                end
            end)
        end
    end)

    local TriggerbotGroupBox = Tabs.Main:AddLeftGroupbox("Triggerbot")
    TriggerbotGroupBox:AddToggle("TriggerbotToggle", { Text = "Enable Triggerbot", Default = false, Callback = function(Value) TB_ENABLED = Value end })
    TriggerbotGroupBox:AddLabel("Trigger Keybind"):AddKeyPicker("TriggerbotKeybind", { Default = "MB2", SyncToggleState = false, Mode = "Hold", Text = "Trigger Key", NoUI = false })
    TriggerbotGroupBox:AddToggle("TriggerbotTeamCheck", { Text = "Team Check", Default = true, Callback = function(Value) TB_TEAMCHECK = Value end })
    TriggerbotGroupBox:AddToggle("TriggerbotWallCheck", { Text = "Wall Check", Default = true, Callback = function(Value) TB_WALLCHECK = Value end })
    TriggerbotGroupBox:AddSlider("TriggerbotFOV", { Text = "Trigger FOV Radius", Default = 50, Min = 1, Max = 1000, Rounding = 0, Callback = function(Value) TB_FOV = Value end })
    TriggerbotGroupBox:AddSlider("TriggerbotDelay", { Text = "Fire Delay (sec)", Default = 0.05, Min = 0.01, Max = 1, Rounding = 2, Callback = function(Value) TB_DELAY = Value end })

    -- ==========================================
    -- RAGEBOT 설정 
    -- ==========================================
    local RB_ENABLED = false
    local RB_FOV = 300
    local RB_HITBOX = "Head"
    local RB_WALLCHECK = true
    local RB_TEAMCHECK = true

    local RagebotGroupBox = Tabs.Main:AddRightGroupbox("Ragebot")
    RagebotGroupBox:AddToggle("RagebotToggle", { Text = "Enable Ragebot", Default = false, Callback = function(Value) RB_ENABLED = Value end })
    RagebotGroupBox:AddLabel("Ragebot Keybind"):AddKeyPicker("RagebotKeybind", { Default = "MB2", SyncToggleState = false, Mode = "Hold", Text = "Rage Key", NoUI = false })
    RagebotGroupBox:AddDropdown("RagebotHitbox", {
        Text = "Ragebot Hitbox",
        Values = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" },
        Default = 1,
        Callback = function(Value) RB_HITBOX = Value end
    })
    RagebotGroupBox:AddToggle("RagebotTeamCheck", { Text = "Team Check", Default = true, Callback = function(Value) RB_TEAMCHECK = Value end })
    RagebotGroupBox:AddToggle("RagebotWallCheck", { Text = "Wall Check", Default = true, Callback = function(Value) RB_WALLCHECK = Value end })
    RagebotGroupBox:AddSlider("RagebotFOV", { Text = "Ragebot FOV Radius", Default = 300, Min = 1, Max = 2000, Rounding = 0, Callback = function(Value) RB_FOV = Value end })

    task.spawn(function()
        while task.wait() do
            pcall(function()
                if RB_ENABLED and not isLobbyVisible() then
                    local isKeybindActive = Options.RagebotKeybind and Options.RagebotKeybind:GetState() or false
                    if isKeybindActive and camera then
                        local mousePos = UserInputService:GetMouseLocation()
                        local localRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if localRoot then
                            local rayParams = RaycastParams.new()
                            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                            rayParams.FilterDescendantsInstances = {player.Character}
                            rayParams.IgnoreWater = true
                            local closest, dist = nil, RB_FOV
                            
                            for _, plr in pairs(Players:GetPlayers()) do
                                if plr ~= player and plr.Character then
                                    local isTeammateVar = RB_TEAMCHECK and isTeammate(plr)
                                    if not isTeammateVar then
                                        local char = plr.Character
                                        local humanoid = char:FindFirstChildOfClass("Humanoid")
                                        local targetPart = getHitboxPart(char, RB_HITBOX)
                                        if targetPart and humanoid and humanoid.Health > 0 then
                                            local pos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                                            if onScreen and pos.Z > 0 then
                                                local d = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                                                if d < dist then
                                                    local canSee = true
                                                    if RB_WALLCHECK then
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
                            
                            if closest then
                                local targetPart = getHitboxPart(closest, RB_HITBOX)
                                if targetPart and camera then
                                    local screenPos = camera:WorldToViewportPoint(targetPart.Position)
                                    if screenPos.Z > 0 then
                                        local targetVec = Vector2.new(screenPos.X, screenPos.Y)
                                        local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                                        local move = targetVec - screenCenter
                                        if math.abs(move.X) < 5000 and math.abs(move.Y) < 5000 then
                                            if mousemoverel then mousemoverel(move.X, move.Y) end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)

    -- ==========================================
    -- RAPID FIRE & FULL AUTO
    -- ==========================================
    local RapidFireEnabled = false
    local FullAutoEnabled = false

    pcall(function()
        local Gun = require(player.PlayerScripts.Modules.ItemTypes.Gun)
        if Gun and Gun.Update then
            local oldUpdate = Gun.Update
            Gun.Update = function(self, dt, ...)
                if RapidFireEnabled then
                    if self._shoot_cooldown then
                        self._shoot_cooldown = 0 
                    end
                end
                return oldUpdate(self, dt, ...)
            end
        end
        
        if Gun and Gun.StartShooting then
            local originalStartShooting = Gun.StartShooting 
            Gun.StartShooting = function(self, ...)
                if FullAutoEnabled then
                    pcall(function()
                        self.Automatic = true
                        self.FullAuto = true
                        if self.WeaponData then self.WeaponData.Automatic = true self.WeaponData.FullAuto = true end
                        if self.WeaponStats then self.WeaponStats.Automatic = true self.WeaponStats.FullAuto = true end
                        if self._weaponData then self._weaponData.Automatic = true self._weaponData.FullAuto = true end
                    end)
                end
                return originalStartShooting(self, ...)
            end
        end
    end)

    local RapidFireGroupBox = Tabs.Main:AddRightGroupbox("Rapid Fire & Auto")
    RapidFireGroupBox:AddToggle("RapidFireToggle", { 
        Text = "Enable Rapid Fire (Postshot)", 
        Default = false, 
        Callback = function(Value) 
            RapidFireEnabled = Value 
        end 
    })
    RapidFireGroupBox:AddToggle("FullAutoToggle", { 
        Text = "Enable Full Auto", 
        Default = false, 
        Callback = function(Value) 
            FullAutoEnabled = Value 
        end 
    })

    -- ==========================================
    -- RECOIL & SPREAD 
    -- ==========================================
    local NoRecoilEnabled = false
    local NoSpreadEnabled = false

    pcall(function()
        local ClientItem = require(player.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)
        if ClientItem and ClientItem._Recoil then
            local originalRecoil = ClientItem._Recoil
            ClientItem._Recoil = function(...)
                if NoRecoilEnabled then
                    return 
                end
                return originalRecoil(...)
            end
        end
    end)

    pcall(function()
        local GunItem = require(player.PlayerScripts.Modules.ItemTypes.Gun)
        if GunItem and GunItem.StartShooting then
            local originalStartShooting = GunItem.StartShooting 
            GunItem.StartShooting = function(self, ...)
                local res = {originalStartShooting(self, ...)}
                if NoSpreadEnabled and self.ClientFighter and self.ClientFighter.IsLocalPlayer then 
                    res[4] = true 
                end 
                return unpack(res)
            end
        end
    end)

    local RecoilSpreadGroupBox = Tabs.Main:AddRightGroupbox("Recoil & Spread")
    RecoilSpreadGroupBox:AddToggle("NoRecoilToggle", { 
        Text = "Enable No Recoil", 
        Default = false, 
        Callback = function(Value) NoRecoilEnabled = Value end 
    })
    RecoilSpreadGroupBox:AddToggle("NoSpreadToggle", { 
        Text = "Enable No Spread", 
        Default = false, 
        Callback = function(Value) NoSpreadEnabled = Value end 
    })

    -- ==========================================
    -- CHARM (Highlight) 설정
    -- ==========================================
    local CharmGroupBox = Tabs.ESP:AddLeftGroupbox("Charm")
    local charmColor = Color3.fromRGB(0, 255, 127)
    
    CharmGroupBox:AddToggle("Charm_Toggle", { Text = "Enable Charm (Highlight)", Default = false })
    CharmGroupBox:AddLabel("Charm Color"):AddColorPicker("Charm_Color", { 
        Default = charmColor, 
        Title = "Charm Color", 
        Transparency = 0, 
        Callback = function(v) charmColor = v end 
    })

    local dummyModel = Instance.new("Model")
    dummyModel.Name = "WhiteDummy"
    
    local function createDummyPart(name, size, offset)
        local part = Instance.new("Part")
        part.Name = name
        part.Size = size
        part.Color = Color3.new(1, 1, 1) 
        part.Material = Enum.Material.SmoothPlastic
        part.Anchored = true
        part.CanCollide = false
        part.CFrame = CFrame.new(offset)
        part.Parent = dummyModel
        return part
    end
    
    dummyModel.PrimaryPart = createDummyPart("Torso", Vector3.new(2, 2, 1), Vector3.new(0, 0, 0))
    createDummyPart("Head", Vector3.new(2, 1, 1), Vector3.new(0, 1.5, 0))
    createDummyPart("Left Arm", Vector3.new(1, 2, 1), Vector3.new(-1.5, 0, 0))
    createDummyPart("Right Arm", Vector3.new(1, 2, 1), Vector3.new(1.5, 0, 0))
    createDummyPart("Left Leg", Vector3.new(1, 2, 1), Vector3.new(-0.5, -2, 0))
    createDummyPart("Right Leg", Vector3.new(1, 2, 1), Vector3.new(0.5, -2, 0))

    local CharmPreviewGroupbox = Tabs.ESP:AddLeftGroupbox("Charm Preview")
    local charmPreviewFrame = Instance.new("ViewportFrame")
    charmPreviewFrame.Size = UDim2.new(1, 0, 0, 250)
    charmPreviewFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    charmPreviewFrame.BorderSizePixel = 0
    charmPreviewFrame.Parent = CharmPreviewGroupbox.Container

    local charmPreviewCam = Instance.new("Camera")
    charmPreviewCam.FieldOfView = 25 
    charmPreviewCam.CFrame = CFrame.new(Vector3.new(0, 0, 10), Vector3.new(0, 0, 0))
    charmPreviewFrame.CurrentCamera = charmPreviewCam
    charmPreviewCam.Parent = charmPreviewFrame

    local previewDummy = dummyModel:Clone()
    previewDummy.Parent = charmPreviewFrame
    
    local charmPreviewHighlight = Instance.new("Highlight")
    charmPreviewHighlight.Parent = previewDummy

    -- ==========================================
    -- ESP 설정
    -- ==========================================
    local ESPGroupBox = Tabs.ESP:AddRightGroupbox("ESP Settings")
    local espBoxColor = Color3.fromRGB(0, 255, 127)
    local espTracerColor = Color3.fromRGB(0, 255, 127)
    local espNameColor = Color3.fromRGB(255, 255, 255)
    local espHealthColor = Color3.fromRGB(0, 255, 0)
    
    local ESPObjects = {}

    local function createESPObject()
        local obj = {}
        obj.GlowLines = {}
        obj.Lines = {}
        for i = 1, 4 do
            obj.GlowLines[i] = Drawing.new("Line")
            obj.GlowLines[i].Thickness = 3
            obj.GlowLines[i].Transparency = 0.6
            
            obj.Lines[i] = Drawing.new("Line")
            obj.Lines[i].Thickness = 1
        end
        
        obj.GlowCorners = {}
        obj.Corners = {}
        for i = 1, 8 do
            obj.GlowCorners[i] = Drawing.new("Line")
            obj.GlowCorners[i].Thickness = 3
            obj.GlowCorners[i].Transparency = 0.6
            
            obj.Corners[i] = Drawing.new("Line")
            obj.Corners[i].Thickness = 1
        end
        
        obj.Highlight = nil 
        
        obj.Tracer = Drawing.new("Line")
        obj.Tracer.Thickness = 1
        
        obj.NameText = Drawing.new("Text")
        obj.NameText.Center = true
        obj.NameText.Outline = true
        obj.NameText.OutlineColor = Color3.fromRGB(0, 0, 0)
        obj.NameText.Size = 13
        obj.NameText.Font = 2
        
        obj.HealthBarBg = Drawing.new("Square")
        obj.HealthBarBg.Thickness = 1
        obj.HealthBarBg.Filled = false
        
        obj.HealthBarFill = Drawing.new("Square")
        obj.HealthBarFill.Filled = true
        
        return obj
    end

    local function hideESP(p)
        local obj = ESPObjects[p]
        if not obj then return end
        for _, c in ipairs(obj.GlowLines) do c.Visible = false end
        for _, c in ipairs(obj.Lines) do c.Visible = false end
        for _, c in ipairs(obj.GlowCorners) do c.Visible = false end
        for _, c in ipairs(obj.Corners) do c.Visible = false end
        if obj.Highlight then obj.Highlight.Enabled = false end
        obj.Tracer.Visible = false
        obj.NameText.Visible = false
        obj.HealthBarBg.Visible = false
        obj.HealthBarFill.Visible = false
    end

    local function clearESP(p)
        local obj = ESPObjects[p]
        if obj then
            for _, c in ipairs(obj.GlowLines) do pcall(function() c:Remove() end) end
            for _, c in ipairs(obj.Lines) do pcall(function() c:Remove() end) end
            for _, c in ipairs(obj.GlowCorners) do pcall(function() c:Remove() end) end
            for _, c in ipairs(obj.Corners) do pcall(function() c:Remove() end) end
            if obj.Highlight then pcall(function() obj.Highlight:Destroy() end) end
            pcall(function() obj.Tracer:Remove() end)
            pcall(function() obj.NameText:Remove() end)
            pcall(function() obj.HealthBarBg:Remove() end)
            pcall(function() obj.HealthBarFill:Remove() end)
            ESPObjects[p] = nil
        end
    end

    ESPGroupBox:AddToggle("ESP_Enable", { Text = "Enable ESP", Default = false })
    ESPGroupBox:AddDropdown("ESP_BoxType", {
        Text = "Box ESP Type",
        Values = { "Full Box", "Corner Box" },
        Default = 1,
    })
    ESPGroupBox:AddToggle("ESP_Tracer", { Text = "Tracer ESP", Default = false })
    ESPGroupBox:AddToggle("ESP_Name", { Text = "Name ESP", Default = false })
    ESPGroupBox:AddToggle("ESP_HealthBar", { Text = "Health Bar ESP", Default = false })
    
    ESPGroupBox:AddLabel("Box Color"):AddColorPicker("ESP_BoxColor", { Default = espBoxColor, Title = "Box Color", Callback = function(v) espBoxColor = v end })
    ESPGroupBox:AddLabel("Tracer Color"):AddColorPicker("ESP_TracerColor", { Default = espTracerColor, Title = "Tracer Color", Callback = function(v) espTracerColor = v end })
    ESPGroupBox:AddLabel("Name Color"):AddColorPicker("ESP_NameColor", { Default = espNameColor, Title = "Name Color", Callback = function(v) espNameColor = v end })
    ESPGroupBox:AddLabel("Health Color"):AddColorPicker("ESP_HealthColor", { Default = espHealthColor, Title = "Health Color", Callback = function(v) espHealthColor = v end })

    Players.PlayerRemoving:Connect(clearESP)

    RunService.RenderStepped:Connect(function()
        pcall(function()
            if previewDummy and previewDummy.PrimaryPart then
                previewDummy:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, tick() * 0.5, 0))
            end
            
            if Toggles.Charm_Toggle and Toggles.Charm_Toggle.Value then
                if charmPreviewHighlight then 
                    charmPreviewHighlight.Enabled = true
                    charmPreviewHighlight.OutlineColor = charmColor
                end
            else
                if charmPreviewHighlight then charmPreviewHighlight.Enabled = false end
            end

            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player then
                    if not Toggles.ESP_Enable.Value or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") or not p.Character:FindFirstChild("Humanoid") or not p.Character:FindFirstChild("Head") or p.Character.Humanoid.Health <= 0 then
                        hideESP(p)
                    else
                        local char = p.Character
                        local root = char.HumanoidRootPart
                        local head = char.Head
                        
                        if not ESPObjects[p] then ESPObjects[p] = createESPObject() end
                        local obj = ESPObjects[p]
                        
                        local rootPos, rootVis = camera:WorldToViewportPoint(root.Position)
                        local headPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        local legPos = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                        
                        if not rootVis then
                            hideESP(p)
                        else
                            local height = math.abs(headPos.Y - legPos.Y) * 1.6
                            local width = height / 1.8
                            
                            local boxTop = headPos.Y - (height * 0.15)
                            local boxBottom = boxTop + height
                            local boxLeft = rootPos.X - width / 2
                            local boxRight = rootPos.X + width / 2
                            
                            for _, c in ipairs(obj.GlowLines) do c.Color = espBoxColor end
                            for _, c in ipairs(obj.Lines) do c.Color = espBoxColor end
                            for _, c in ipairs(obj.GlowCorners) do c.Color = espBoxColor end
                            for _, c in ipairs(obj.Corners) do c.Color = espBoxColor end
                            obj.Tracer.Color = espTracerColor
                            obj.NameText.Color = espNameColor
                            obj.HealthBarFill.Color = espHealthColor
                            obj.HealthBarBg.Color = Color3.fromRGB(0, 0, 0)
                            
                            if Toggles.ESP_Tracer.Value then
                                obj.Tracer.Visible = true
                                obj.Tracer.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
                                obj.Tracer.To = Vector2.new(rootPos.X, boxBottom)
                            else
                                obj.Tracer.Visible = false
                            end
                            
                            obj.NameText.Visible = Toggles.ESP_Name.Value
                            if Toggles.ESP_Name.Value then
                                obj.NameText.Text = p.Name
                                obj.NameText.Position = Vector2.new(rootPos.X, boxTop - 16)
                            end
                            
                            if Toggles.ESP_HealthBar.Value then
                                local hp = char.Humanoid.Health
                                local maxHp = char.Humanoid.MaxHealth
                                local ratio = hp / maxHp
                                
                                local barX = boxLeft - 6
                                local barY = boxTop
                                local barW = 3
                                local barH = height
                                
                                obj.HealthBarBg.Visible = true
                                obj.HealthBarBg.Position = Vector2.new(barX, barY)
                                obj.HealthBarBg.Size = Vector2.new(barW, barH)
                                
                                obj.HealthBarFill.Visible = true
                                obj.HealthBarFill.Position = Vector2.new(barX, barY + (barH * (1 - ratio)))
                                obj.HealthBarFill.Size = Vector2.new(barW, barH * ratio)
                            else
                                obj.HealthBarBg.Visible = false
                                obj.HealthBarFill.Visible = false
                            end
                            
                            for _, c in ipairs(obj.GlowLines) do c.Visible = false end
                            for _, c in ipairs(obj.Lines) do c.Visible = false end
                            for _, c in ipairs(obj.GlowCorners) do c.Visible = false end
                            for _, c in ipairs(obj.Corners) do c.Visible = false end
                            if obj.Highlight then obj.Highlight.Enabled = false end
                            
                            local boxType = Options.ESP_BoxType.Value
                            if boxType == "Full Box" then
                                obj.GlowLines[1].Visible = true; obj.GlowLines[1].From = Vector2.new(boxLeft, boxTop); obj.GlowLines[1].To = Vector2.new(boxRight, boxTop)
                                obj.GlowLines[2].Visible = true; obj.GlowLines[2].From = Vector2.new(boxLeft, boxBottom); obj.GlowLines[2].To = Vector2.new(boxRight, boxBottom)
                                obj.GlowLines[3].Visible = true; obj.GlowLines[3].From = Vector2.new(boxLeft, boxTop); obj.GlowLines[3].To = Vector2.new(boxLeft, boxBottom)
                                obj.GlowLines[4].Visible = true; obj.GlowLines[4].From = Vector2.new(boxRight, boxTop); obj.GlowLines[4].To = Vector2.new(boxRight, boxBottom)
                                
                                obj.Lines[1].Visible = true; obj.Lines[1].From = Vector2.new(boxLeft, boxTop); obj.Lines[1].To = Vector2.new(boxRight, boxTop)
                                obj.Lines[2].Visible = true; obj.Lines[2].From = Vector2.new(boxLeft, boxBottom); obj.Lines[2].To = Vector2.new(boxRight, boxBottom)
                                obj.Lines[3].Visible = true; obj.Lines[3].From = Vector2.new(boxLeft, boxTop); obj.Lines[3].To = Vector2.new(boxLeft, boxBottom)
                                obj.Lines[4].Visible = true; obj.Lines[4].From = Vector2.new(boxRight, boxTop); obj.Lines[4].To = Vector2.new(boxRight, boxBottom)
                                
                            elseif boxType == "Corner Box" then
                                local cornerLen = height * 0.3
                                
                                obj.GlowCorners[1].Visible = true; obj.GlowCorners[1].From = Vector2.new(boxLeft, boxTop); obj.GlowCorners[1].To = Vector2.new(boxLeft + cornerLen, boxTop)
                                obj.GlowCorners[2].Visible = true; obj.GlowCorners[2].From = Vector2.new(boxLeft, boxTop); obj.GlowCorners[2].To = Vector2.new(boxLeft, boxTop + cornerLen)
                                obj.GlowCorners[3].Visible = true; obj.GlowCorners[3].From = Vector2.new(boxRight, boxTop); obj.GlowCorners[3].To = Vector2.new(boxRight - cornerLen, boxTop)
                                obj.GlowCorners[4].Visible = true; obj.GlowCorners[4].From = Vector2.new(boxRight, boxTop); obj.GlowCorners[4].To = Vector2.new(boxRight, boxTop + cornerLen)
                                obj.GlowCorners[5].Visible = true; obj.GlowCorners[5].From = Vector2.new(boxLeft, boxBottom); obj.GlowCorners[5].To = Vector2.new(boxLeft + cornerLen, boxBottom)
                                obj.GlowCorners[6].Visible = true; obj.GlowCorners[6].From = Vector2.new(boxLeft, boxBottom); obj.GlowCorners[6].To = Vector2.new(boxLeft, boxBottom - cornerLen)
                                obj.GlowCorners[7].Visible = true; obj.GlowCorners[7].From = Vector2.new(boxRight, boxBottom); obj.GlowCorners[7].To = Vector2.new(boxRight - cornerLen, boxBottom)
                                obj.GlowCorners[8].Visible = true; obj.GlowCorners[8].From = Vector2.new(boxRight, boxBottom); obj.GlowCorners[8].To = Vector2.new(boxRight, boxBottom - cornerLen)
                                
                                obj.Corners[1].Visible = true; obj.Corners[1].From = Vector2.new(boxLeft, boxTop); obj.Corners[1].To = Vector2.new(boxLeft + cornerLen, boxTop)
                                obj.Corners[2].Visible = true; obj.Corners[2].From = Vector2.new(boxLeft, boxTop); obj.Corners[2].To = Vector2.new(boxLeft, boxTop + cornerLen)
                                obj.Corners[3].Visible = true; obj.Corners[3].From = Vector2.new(boxRight, boxTop); obj.Corners[3].To = Vector2.new(boxRight - cornerLen, boxTop)
                                obj.Corners[4].Visible = true; obj.Corners[4].From = Vector2.new(boxRight, boxTop); obj.Corners[4].To = Vector2.new(boxRight, boxTop + cornerLen)
                                obj.Corners[5].Visible = true; obj.Corners[5].From = Vector2.new(boxLeft, boxBottom); obj.Corners[5].To = Vector2.new(boxLeft + cornerLen, boxBottom)
                                obj.Corners[6].Visible = true; obj.Corners[6].From = Vector2.new(boxLeft, boxBottom); obj.Corners[6].To = Vector2.new(boxLeft, boxBottom - cornerLen)
                                obj.Corners[7].Visible = true; obj.Corners[7].From = Vector2.new(boxRight, boxBottom); obj.Corners[7].To = Vector2.new(boxRight - cornerLen, boxBottom)
                                obj.Corners[8].Visible = true; obj.Corners[8].From = Vector2.new(boxRight, boxBottom); obj.Corners[8].To = Vector2.new(boxRight, boxBottom - cornerLen)
                            end
                        end
                    end
                end
            end
            
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    local char = p.Character
                    if not Toggles.Charm_Toggle or not Toggles.Charm_Toggle.Value or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then
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
    end)

    -- ==========================================
    -- UNLOCK ALL 설정
    -- ==========================================
    local UnlockGroupBox = Tabs.Main:AddRightGroupbox("Unlock All")
    local unlockAllExecuted = false

    UnlockGroupBox:AddButton({
        Text = "Unlock All Cosmetics",
        Tooltip = "Unlocks Skins, Charms, Dances, Wraps, Finishers. Saves Loadout.",
        Func = function()
            if unlockAllExecuted then Library:Notify("Unlock All has already been executed!") return end
            unlockAllExecuted = true
            Library:Notify("Starting Unlock All... Please wait 1 second.")

            task.delay(1, function()
                local success, err = pcall(function()
                    local HttpService = game:GetService("HttpService")
                    local playerScripts = safeWait(player, "PlayerScripts", 10)
                    if not playerScripts then return end
                    local controllers = safeWait(playerScripts, "Controllers", 10)
                    if not controllers then return end
                    local modules = safeWait(ReplicatedStorage, "Modules", 10)
                    if not modules then return end
                    
                    local EnumLibrary = safeRequire(safeWait(modules, "EnumLibrary", 10))
                    if EnumLibrary and EnumLibrary.WaitForEnumBuilder then pcall(function() EnumLibrary:WaitForEnumBuilder() end) end
                    
                    local CosmeticLibrary = safeRequire(safeWait(modules, "CosmeticLibrary", 10))
                    local ItemLibrary = safeRequire(safeWait(modules, "ItemLibrary", 10))
                    local DataController = safeRequire(safeWait(controllers, "PlayerDataController", 10))
                    if not CosmeticLibrary or not ItemLibrary or not DataController then Library:Notify("Failed to load game modules!") return end
                    
                    local equipped, favorites = {}, {}
                    local constructingWeapon, viewingProfile = nil, nil
                    local lastUsedWeapon = nil
                    local ValidTypes = { Skin = true, Charm = true, Dance = true, Emote = true, Wrap = true, Wrapping = true, Finisher = true }
                    local validCache = {}
                    
                    local function isValidCosmetic(name)
                        if not name then return false end
                        if validCache[name] ~= nil then return validCache[name] end
                        if name:find("MISSING_") then validCache[name] = false return false end
                        local cosmetic = CosmeticLibrary.Cosmetics and CosmeticLibrary.Cosmetics[name]
                        local result = false
                        if cosmetic then
                            if ValidTypes[cosmetic.Type] then result = true end
                            local lowerName = name:lower()
                            if cosmetic.Type == "Charm" or lowerName:find("charm") then result = true end
                            if cosmetic.Type == "Dance" or cosmetic.Type == "Emote" or lowerName:find("dance") or lowerName:find("emote") then result = true end
                            if cosmetic.Type == "Wrap" or cosmetic.Type == "Wrapping" or lowerName:find("wrap") then result = true end
                            if cosmetic.Type == "Finisher" or lowerName:find("finisher") then result = true end
                        end
                        validCache[name] = result
                        return result
                    end
                    
                    local function cloneCosmetic(name, cosmeticType, options)
                        local base = CosmeticLibrary.Cosmetics and CosmeticLibrary.Cosmetics[name]
                        if not base then return nil end
                        local data = {}
                        for key, value in pairs(base) do data[key] = value end
                        data.Name = name
                        data.Type = data.Type or cosmeticType
                        data.Seed = data.Seed or math.random(1, 1000000)
                        if EnumLibrary then
                            local s, enumId = pcall(EnumLibrary.ToEnum, EnumLibrary, name)
                            if s and enumId then data.Enum, data.ObjectID = enumId, data.ObjectID or enumId end
                        end
                        if options then
                            if options.inverted ~= nil then data.Inverted = options.inverted end
                            if options.favoritesOnly ~= nil then data.OnlyUseFavorites = options.favoritesOnly end
                        end
                        return data
                    end
                    
                    local saveFile = "unlockall/config.json"
                    local function saveConfig()
                        if not writefile then return end
                        pcall(function()
                            local config = {equipped = {}, favorites = favorites}
                            for weapon, cosmetics in pairs(equipped) do
                                config.equipped[weapon] = {}
                                for cosmeticType, cosmeticData in pairs(cosmetics) do
                                    if cosmeticData and cosmeticData.Name then
                                        config.equipped[weapon][cosmeticType] = { name = cosmeticData.Name, seed = cosmeticData.Seed, inverted = cosmeticData.Inverted }
                                    end
                                end
                            end
                            makefolder("unlockall")
                            writefile(saveFile, HttpService:JSONEncode(config))
                        end)
                    end
                    
                    local function loadConfig()
                        if not readfile or not isfile or not isfile(saveFile) then return end
                        pcall(function()
                            local config = HttpService:JSONDecode(readfile(saveFile))
                            if config.equipped then
                                for weapon, cosmetics in pairs(config.equipped) do
                                    equipped[weapon] = {}
                                    for cosmeticType, cosmeticData in pairs(cosmetics) do
                                        local cloned = cloneCosmetic(cosmeticData.name, cosmeticType, {inverted = cosmeticData.inverted})
                                        if cloned then cloned.Seed = cosmeticData.seed equipped[weapon][cosmeticType] = cloned end
                                    end
                                end
                            end
                            favorites = config.favorites or {}
                        end)
                    end
                    
                    local originalOwnsCosmetic = CosmeticLibrary.OwnsCosmetic or function() return false end
                    CosmeticLibrary.OwnsCosmetic = function(self, inventory, name, weapon)
                        if isValidCosmetic(name) then return true end
                        return originalOwnsCosmetic(self, inventory, name, weapon)
                    end
                    
                    local originalGet = DataController.Get or function() return nil end
                    DataController.Get = function(self, key)
                        local data = originalGet(self, key)
                        if key == "CosmeticInventory" then
                            local proxy = {}
                            if data then for k, v in pairs(data) do if isValidCosmetic(k) then proxy[k] = v end end end
                            return setmetatable(proxy, {__index = function(t, k) if isValidCosmetic(k) then return true end return nil end})
                        end
                        if key == "FavoritedCosmetics" then
                            local result = data and safeClone(data) or {}
                            for weapon, favs in pairs(favorites) do
                                result[weapon] = result[weapon] or {}
                                for name, isFav in pairs(favs) do if isValidCosmetic(name) then result[weapon][name] = isFav end end
                            end
                            return result
                        end
                        return data
                    end
                    
                    local originalGetWeaponData = DataController.GetWeaponData or function() return nil end
                    DataController.GetWeaponData = function(self, weaponName)
                        local data = originalGetWeaponData(self, weaponName)
                        if not data then return nil end
                        local merged = {}
                        for key, value in pairs(data) do merged[key] = value end
                        merged.Name = weaponName
                        if equipped[weaponName] then
                            for cosmeticType, cosmeticData in pairs(equipped[weaponName]) do merged[cosmeticType] = cosmeticData end
                        end
                        return merged
                    end
                    
                    local FighterController = safeRequire(safeWait(controllers, "FighterController", 10))
                    if hookmetamethod then
                        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                        local dataRemotes = remotes and remotes:FindFirstChild("Data")
                        local equipRemote = dataRemotes and dataRemotes:FindFirstChild("EquipCosmetic")
                        local favoriteRemote = dataRemotes and dataRemotes:FindFirstChild("FavoriteCosmetic")
                        local replicationRemotes = remotes and remotes:FindFirstChild("Replication")
                        local fighterRemotes = replicationRemotes and replicationRemotes:FindFirstChild("Fighter")
                        local useItemRemote = fighterRemotes and fighterRemotes:FindFirstChild("UseItem")
                        
                        if equipRemote then
                            local oldNamecall
                            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                                if not getnamecallmethod then return oldNamecall(self, ...) end
                                if getnamecallmethod() ~= "FireServer" then return oldNamecall(self, ...) end
                                local args = {...}
                                
                                if useItemRemote and self == useItemRemote then
                                    local objectID = args[1]
                                    if FighterController then
                                        pcall(function()
                                            local ok, fighter = pcall(FighterController.GetFighter, FighterController, player)
                                            if ok and fighter and fighter.Items then
                                                for _, item in pairs(fighter.Items) do
                                                    if item:Get("ObjectID") == objectID then lastUsedWeapon = item.Name break end
                                                end
                                            end
                                        end)
                                    end
                                end
                                
                                if self == equipRemote then
                                    local weaponName, cosmeticType, cosmeticName, options = args[1], args[2], args[3], args[4] or {}
                                    if weaponName then lastUsedWeapon = weaponName end

                                    if cosmeticType == "Dance" or cosmeticType == "Emote" then
                                        equipped.Dances = equipped.Dances or {}
                                        if not cosmeticName or cosmeticName == "None" or cosmeticName == "" then
                                            equipped.Dances[cosmeticType] = nil
                                        else
                                            local cloned = cloneCosmetic(cosmeticName, cosmeticType, {inverted = options.IsInverted, favoritesOnly = options.OnlyUseFavorites})
                                            if cloned then equipped.Dances[cosmeticType] = cloned end
                                        end
                                        task.defer(function() pcall(function() if DataController.CurrentData and DataController.CurrentData.Replicate then DataController.CurrentData:Replicate("CosmeticInventory") end end) task.wait(0.2) saveConfig() end)
                                        return
                                    else
                                        if (not cosmeticName or cosmeticName == "None" or cosmeticName == "") then
                                            if equipped[weaponName] then
                                                equipped[weaponName][cosmeticType] = nil
                                                if not next(equipped[weaponName]) then equipped[weaponName] = nil end
                                            end
                                            task.defer(function() pcall(function() if DataController.CurrentData and DataController.CurrentData.Replicate then DataController.CurrentData:Replicate("WeaponInventory") end end) task.wait(0.2) saveConfig() end)
                                            return oldNamecall(self, ...)
                                        end
                                        
                                        if cosmeticName and cosmeticName ~= "None" and cosmeticName ~= "" then
                                            local inventory = DataController:Get("CosmeticInventory")
                                            if inventory and rawget(inventory, cosmeticName) then return oldNamecall(self, ...) end
                                        end
                                        equipped[weaponName] = equipped[weaponName] or {}
                                        if not cosmeticName or cosmeticName == "None" or cosmeticName == "" then
                                            equipped[weaponName][cosmeticType] = nil
                                            if not next(equipped[weaponName]) then equipped[weaponName] = nil end
                                        else
                                            local cloned = cloneCosmetic(cosmeticName, cosmeticType, {inverted = options.IsInverted, favoritesOnly = options.OnlyUseFavorites})
                                            if cloned then equipped[weaponName][cosmeticType] = cloned end
                                        end
                                        task.defer(function() pcall(function() if DataController.CurrentData and DataController.CurrentData.Replicate then DataController.CurrentData:Replicate("WeaponInventory") end end) task.wait(0.2) saveConfig() end)
                                        return
                                    end
                                end
                                
                                if self == favoriteRemote then
                                    if isValidCosmetic(args[2]) then
                                        favorites[args[1]] = favorites[args[1]] or {}
                                        favorites[args[1]][args[2]] = args[3] or nil
                                        saveConfig()
                                        task.spawn(function() pcall(function() if DataController.CurrentData and DataController.CurrentData.Replicate then DataController.CurrentData:Replicate("FavoritedCosmetics") end end) end)
                                    end
                                    return
                                end
                                return oldNamecall(self, ...)
                            end)
                        end
                    end
                    
                    local modulesFolder = safeWait(playerScripts, "Modules", 10)
                    local clientClasses = modulesFolder and safeWait(modulesFolder, "ClientReplicatedClasses", 10)
                    local clientFighter = clientClasses and safeWait(clientClasses, "ClientFighter", 10)
                    local clientItemModule = clientFighter and clientFighter:FindFirstChild("ClientItem")
                    local ClientItem = clientItemModule and safeRequire(clientItemModule)
                    
                    if ClientItem and ClientItem._CreateViewModel then
                        local originalCreateViewModel = ClientItem._CreateViewModel
                        ClientItem._CreateViewModel = function(self, viewmodelRef)
                            if not self or not viewmodelRef then return originalCreateViewModel(self, viewmodelRef) end
                            local weaponName = self.Name
                            local weaponPlayer = self.ClientFighter and self.ClientFighter.Player
                            constructingWeapon = (weaponPlayer == player) and weaponName or nil
                            
                            if weaponPlayer == player then lastUsedWeapon = weaponName end
                            
                            if weaponPlayer == player and equipped[weaponName] and viewmodelRef then
                                local dataKey = self:ToEnum("Data")
                                local cosmetics = equipped[weaponName]
                                if viewmodelRef[dataKey] then
                                    if cosmetics.Skin then viewmodelRef[dataKey][self:ToEnum("Skin")] = cosmetics.Skin viewmodelRef[dataKey][self:ToEnum("Name")] = cosmetics.Skin.Name end
                                    if cosmetics.Charm then viewmodelRef[dataKey][self:ToEnum("Charm")] = cosmetics.Charm end
                                    if cosmetics.Wrap then viewmodelRef[dataKey][self:ToEnum("Wrap")] = cosmetics.Wrap end
                                elseif viewmodelRef.Data then
                                    if cosmetics.Skin then viewmodelRef.Data.Skin = cosmetics.Skin viewmodelRef.Data.Name = cosmetics.Skin.Name end
                                    if cosmetics.Charm then viewmodelRef.Data.Charm = cosmetics.Charm end
                                    if cosmetics.Wrap then viewmodelRef.Data.Wrap = cosmetics.Wrap end
                                end
                            end
                            local result = originalCreateViewModel(self, viewmodelRef)
                            constructingWeapon = nil
                            return result
                        end
                    end
                    
                    local viewModelModule = clientItemModule and clientItemModule:FindFirstChild("ClientViewModel")
                    if viewModelModule then
                        local ClientViewModel = safeRequire(viewModelModule)
                        if ClientViewModel then
                            if ClientViewModel.GetWrap then
                                local originalGetWrapFunc = ClientViewModel.GetWrap
                                ClientViewModel.GetWrap = function(self)
                                    local weaponName = self.ClientItem and self.ClientItem.Name
                                    local weaponPlayer = self.ClientItem and self.ClientItem.ClientFighter and self.ClientItem.ClientFighter.Player
                                    if weaponName and weaponPlayer == player and equipped[weaponName] and equipped[weaponName].Wrap then return equipped[weaponName].Wrap end
                                    return originalGetWrapFunc(self)
                                end
                            end
                            if ClientViewModel.GetCharm then
                                local originalGetCharmFunc = ClientViewModel.GetCharm
                                ClientViewModel.GetCharm = function(self)
                                    local weaponName = self.ClientItem and self.ClientItem.Name
                                    local weaponPlayer = self.ClientItem and self.ClientItem.ClientFighter and self.ClientItem.ClientFighter.Player
                                    if weaponName and weaponPlayer == player and equipped[weaponName] and equipped[weaponName].Charm then return equipped[weaponName].Charm end
                                    return originalGetCharmFunc(self)
                                end
                            end
                            local originalNew = ClientViewModel.new
                            ClientViewModel.new = function(replicatedData, clientItem)
                                if not clientItem then return originalNew(replicatedData, clientItem) end
                                local weaponPlayer = clientItem.ClientFighter and clientItem.ClientFighter.Player
                                local weaponName = constructingWeapon or clientItem.Name
                                if weaponPlayer == player and equipped[weaponName] then
                                    local ReplicatedClass = modules and safeRequire(safeWait(modules, "ReplicatedClass", 10))
                                    if ReplicatedClass then
                                        local dataKey = ReplicatedClass:ToEnum("Data")
                                        replicatedData[dataKey] = replicatedData[dataKey] or {}
                                        local cosmetics = equipped[weaponName]
                                        if cosmetics.Skin then replicatedData[dataKey][ReplicatedClass:ToEnum("Skin")] = cosmetics.Skin end
                                        if cosmetics.Charm then replicatedData[dataKey][ReplicatedClass:ToEnum("Charm")] = cosmetics.Charm end
                                        if cosmetics.Wrap then replicatedData[dataKey][ReplicatedClass:ToEnum("Wrap")] = cosmetics.Wrap end
                                    end
                                end
                                local result = originalNew(replicatedData, clientItem)
                                if weaponPlayer == player and equipped[weaponName] and equipped[weaponName].Wrap and result and result._UpdateWrap then
                                    result:_UpdateWrap()
                                    task.delay(0.1, function() if not result._destroyed then result:_UpdateWrap() end end)
                                end
                                return result
                            end
                        end
                    end
                    
                    if ItemLibrary and ItemLibrary.GetViewModelImageFromWeaponData then
                        local originalGetViewModelImage = ItemLibrary.GetViewModelImageFromWeaponData
                        ItemLibrary.GetViewModelImageFromWeaponData = function(weaponData, highRes)
                            if not weaponData then return originalGetViewModelImage(weaponData, highRes) end
                            local weaponName = weaponData.Name
                            local shouldShowSkin = (weaponData.Skin and equipped[weaponName] and weaponData.Skin == equipped[weaponName].Skin) or (viewingProfile == player and equipped[weaponName] and equipped[weaponName].Skin)
                            if shouldShowSkin and equipped[weaponName] and equipped[weaponName].Skin then
                                local skinInfo = ItemLibrary.ViewModels[equipped[weaponName].Skin.Name]
                                if skinInfo then return skinInfo[highRes and "ImageHighResolution" or "Image"] or skinInfo.Image end
                            end
                            return originalGetViewModelImage(weaponData, highRes)
                        end
                    end
                    
                    local EmoteController = safeRequire(safeWait(controllers, "EmoteController", 10))
                    if EmoteController and EmoteController.GetEmotes then
                        local originalGetEmotes = EmoteController.GetEmotes
                        EmoteController.GetEmotes = function(self)
                            local emotes = originalGetEmotes(self)
                            for name, cosmetic in pairs(CosmeticLibrary.Cosmetics) do
                                if isValidCosmetic(name) and (cosmetic.Type == "Dance" or cosmetic.Type == "Emote") then
                                    if not emotes[name] then emotes[name] = { Name = name, Type = cosmetic.Type, ObjectID = cosmetic.ObjectID, Enum = cosmetic.Enum } end
                                end
                            end
                            return emotes
                        end
                    end
                    
                    local pagesFolder = modulesFolder and safeWait(modulesFolder, "Pages", 10)
                    local viewProfileModule = pagesFolder and safeWait(pagesFolder, "ViewProfile", 10)
                    local ViewProfile = viewProfileModule and safeRequire(viewProfileModule)
                    if ViewProfile and ViewProfile.Fetch then
                        local originalFetch = ViewProfile.Fetch
                        ViewProfile.Fetch = function(self, targetPlayer)
                            viewingProfile = targetPlayer
                            return originalFetch(self, targetPlayer)
                        end
                    end
                    
                    local ClientEntityModule = clientClasses and clientClasses:FindFirstChild("ClientEntity")
                    local ClientEntity = ClientEntityModule and safeRequire(ClientEntityModule)
                    
                    if ClientEntity and ClientEntity.ReplicateFromServer then
                        local originalReplicateFromServer = ClientEntity.ReplicateFromServer
                        ClientEntity.ReplicateFromServer = function(self, action, ...)
                            if action == "FinisherEffect" then
                                local argCount = select("#", ...)
                                local args = {...}
                                local killerName = args[3]            
                                local decodedKiller = killerName
                                if type(killerName) == "userdata" and EnumLibrary and EnumLibrary.FromEnum then
                                    local ok, decoded = pcall(EnumLibrary.FromEnum, EnumLibrary, killerName)
                                    if ok and decoded then decodedKiller = decoded end
                                end            
                                local isOurKill = tostring(decodedKiller) == player.Name or tostring(decodedKiller):lower() == player.Name:lower()            
                                
                                if isOurKill then
                                    local finisherEnum = nil
                                    
                                    if lastUsedWeapon and equipped[lastUsedWeapon] and equipped[lastUsedWeapon].Finisher then
                                        finisherEnum = equipped[lastUsedWeapon].Finisher.Enum
                                        if not finisherEnum and EnumLibrary then
                                            local ok, result = pcall(EnumLibrary.ToEnum, EnumLibrary, equipped[lastUsedWeapon].Finisher.Name)
                                            if ok and result then finisherEnum = result end
                                        end
                                    end
                                    
                                    if not finisherEnum then
                                        for weaponName, cosmetics in pairs(equipped) do
                                            if cosmetics.Finisher then
                                                finisherEnum = cosmetics.Finisher.Enum
                                                if not finisherEnum and EnumLibrary then
                                                    local ok, result = pcall(EnumLibrary.ToEnum, EnumLibrary, cosmetics.Finisher.Name)
                                                    if ok and result then finisherEnum = result end
                                                end
                                                if finisherEnum then break end
                                            end
                                        end
                                    end
                                    
                                    if finisherEnum then
                                        args[1] = finisherEnum
                                        return originalReplicateFromServer(self, action, unpack(args, 1, argCount))
                                    end
                                end
                            end        
                            return originalReplicateFromServer(self, action, ...)
                        end
                    end
                    
                    loadConfig()
                    task.spawn(function()
                        while task.wait(2) do
                            pcall(function()
                                if DataController.CurrentData and DataController.CurrentData.Replicate then DataController.CurrentData:Replicate("WeaponInventory") end
                            end)
                        end
                    end)
                    Library:Notify("Unlock All successfully loaded! (Loadout Saved)")
                end)
                if not success then Library:Notify("Error loading Unlock All: " .. tostring(err)) warn("UnlockAll Error:", err) end
            end)
        end
    })

    -- WATERMARK
    Library:SetWatermarkVisibility(true)
    local FrameTimer = tick()
    local FrameCounter = 0;
    local FPS = 60;
    local function GetSafePing()
        local ok, result = pcall(function()
            local stats = game:GetService("Stats")
            local network = stats:FindFirstChild("Network")
            if not network then return 0 end
            local serverStats = network:FindFirstChild("ServerStatsItem")
            if not serverStats then return 0 end
            local dataPing = serverStats:FindFirstChild("Data Ping")
            if not dataPing then return 0 end
            return math.floor(dataPing:GetValue())
        end)
        return ok and result or 0
    end
    local WatermarkConnection = game:GetService("RunService").RenderStepped:Connect(function()
        pcall(function()
            FrameCounter += 1;
            if (tick() - FrameTimer) >= 1 then FPS = FrameCounter; FrameTimer = tick(); FrameCounter = 0; end;
            local ping = GetSafePing()
            if ping > 0 then Library:SetWatermark(("Necrophilia | %d fps | %d ms"):format(math.floor(FPS), ping)) else Library:SetWatermark(("Necrophilia | %d fps"):format(math.floor(FPS))) end
        end)
    end)

    Library:OnUnload(function()
        WatermarkConnection:Disconnect()
        if AimbotRenderConnection then AimbotRenderConnection:Disconnect() end
        pcall(function() if fovCircle then fovCircle.Visible = false fovCircle:Remove() end end)
        pcall(function() if saFovCircle then saFovCircle.Visible = false saFovCircle:Remove() end end)
        print("Unloaded!")
        Library.Unloaded = true
    end)

    local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
    MenuGroup:AddToggle("KeybindMenuOpen", { Default = Library.KeybindFrame.Visible, Text = "Open Keybind Menu", Callback = function(value) Library.KeybindFrame.Visible = value end})
    MenuGroup:AddToggle("ShowCustomCursor", {Text = "Custom Cursor", Default = true, Callback = function(Value) Library.ShowCustomCursor = Value end})
    MenuGroup:AddDivider()
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    MenuGroup:AddButton("Unload", function() Library:Unload() end)

    Library.ToggleKeybind = Options.MenuKeybind 
    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
    ThemeManager:SetFolder("MyScriptHub")
    SaveManager:SetFolder("MyScriptHub/specific-game")
    SaveManager:SetSubFolder("specific-place") 
    SaveManager:BuildConfigSection(Tabs["UI Settings"])
    ThemeManager:ApplyToTab(Tabs["UI Settings"])
    
    ThemeManager.Theme = ThemeManager.Theme or {}
    ThemeManager.Theme.Main = Color3.fromRGB(25, 25, 25)
    ThemeManager.Theme.Background = Color3.fromRGB(20, 20, 20)
    ThemeManager.Theme.Border = Color3.fromRGB(80, 20, 20)
    ThemeManager.Theme.Text = Color3.fromRGB(255, 255, 255)
    ThemeManager.Theme.TextDark = Color3.fromRGB(150, 150, 150)
    ThemeManager.Theme.Accent = Color3.fromRGB(150, 30, 30)
    ThemeManager.Theme.TabText = Color3.fromRGB(200, 200, 200)
    ThemeManager.Theme.TabBackground = Color3.fromRGB(30, 30, 30)
    SaveManager:LoadAutoloadConfig()

    task.spawn(function()
        task.wait(1)
        local logoUrl = "https://raw.githubusercontent.com/salamindeyo03-collab/SLogo/main/RealLast.png"
        local assetId = nil
        pcall(function()
            if writefile and (getcustomasset or getsynasset) then
                if not isfile("slogo.png") or #readfile("slogo.png") < 1000 then
                    local ok, imgData = pcall(function() return game:HttpGet(logoUrl) end)
                    if ok and imgData and #imgData > 1000 then writefile("slogo.png", imgData) end
                end
                if isfile("slogo.png") and #readfile("slogo.png") > 1000 then
                    assetId = (getcustomasset or getsynasset)("slogo.png")
                end
            end
        end)

        local windowFrame = Window.WindowFrame or Window.Window or Window.Main
        if windowFrame then
            for _, v in pairs(windowFrame:GetDescendants()) do
                if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
                    v.Font = Enum.Font.Gotham
                end
                
                if v.Name == "Background" and v.Parent == windowFrame then
                    v.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    v.BackgroundTransparency = 0
                    if assetId and not v:FindFirstChild("CenterLogo") then
                        local logoImg = Instance.new("ImageLabel")
                        logoImg.Name = "CenterLogo"
                        logoImg.Image = assetId
                        logoImg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                        logoImg.BackgroundTransparency = 0
                        logoImg.Size = UDim2.new(1, 0, 1, 0)
                        logoImg.Position = UDim2.new(0.5, 0, 0.5, 0)
                        logoImg.AnchorPoint = Vector2.new(0.5, 0.5)
                        logoImg.ZIndex = 1
                        logoImg.ImageTransparency = 0.4
                        logoImg.ScaleType = Enum.ScaleType.Fit
                        logoImg.Parent = v
                    end
                elseif v:IsA("Frame") and (v.Name == "Background" or v.Name == "Container" or v.Name == "List" or v.Name == "TabContainer" or v.Name == "Tab" or v.Name == "GroupBox") then
                    v.BackgroundTransparency = 1
                    v.BorderSizePixel = 0
                end
                
                if v:IsA("ImageLabel") and v.Name == "Shadow" then v.Visible = false end
                
                if v:IsA("UIStroke") and v.Parent then
                    if v.Parent.Name == "GroupBox" then
                        v.Transparency = 0.6
                        v.Thickness = 1
                        v.Color = Color3.fromRGB(255, 255, 255)
                    elseif v.Parent.Name == "Window" or v.Parent.Name == "WindowFrame" or v.Parent.Name == "Background" then
                        v.Transparency = 1
                        v.Thickness = 0
                    end
                end
            end
        end
    end)
end)

if not success then
    warn("Script failed to load:", err)
end
