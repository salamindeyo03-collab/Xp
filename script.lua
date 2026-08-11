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
        ["UI Settings"] = Window:AddTab("UI Settings"),
    }

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local player = Players.LocalPlayer
    local camera = workspace.CurrentCamera

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
                    local isTeammate = teamCheck and player.Team and plr.Team == player.Team
                    if not isTeammate then
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
                            if math.abs(moveX) < 5000 and math.abs(moveY) < 5000 then
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
    -- SILENT AIM 설정
    -- ==========================================
    local SA_ENABLED = false
    local SA_FOV = 50
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
                    local isTeammate = SA_TEAMCHECK and player.Team and plr.Team == player.Team
                    if not isTeammate then
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

        UtilityModule.Raycast = function(self, origin, direction, distance, params, ignoreWater, debug)
            local isKeybindActive = Options.SilentAimKeybind and Options.SilentAimKeybind:GetState() or false
            if not SA_ENABLED or not isKeybindActive or type(distance) ~= "number" or distance < 100 then
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
    SilentAimGroupBox:AddSlider("SilentAimFOV", { Text = "Silent FOV Radius", Default = 50, Min = 10, Max = 1000, Rounding = 0, Callback = function(Value) SA_FOV = Value end })

    -- ==========================================
    -- TRIGGERBOT 설정
    -- ==========================================
    local TB_ENABLED = false
    local TB_FOV = 50
    local TB_WALLCHECK = true
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

    local TriggerbotGroupBox = Tabs.Main:AddLeftGroupbox("Triggerbot")
    TriggerbotGroupBox:AddToggle("TriggerbotToggle", { Text = "Enable Triggerbot", Default = false, Callback = function(Value) TB_ENABLED = Value end })
    TriggerbotGroupBox:AddLabel("Trigger Keybind"):AddKeyPicker("TriggerbotKeybind", { Default = "MB2", SyncToggleState = false, Mode = "Hold", Text = "Trigger Key", NoUI = false })
    TriggerbotGroupBox:AddToggle("TriggerbotWallCheck", { Text = "Wall Check", Default = true, Callback = function(Value) TB_WALLCHECK = Value end })
    TriggerbotGroupBox:AddSlider("TriggerbotFOV", { Text = "Trigger FOV Radius", Default = 50, Min = 1, Max = 1000, Rounding = 0, Callback = function(Value) TB_FOV = Value end })
    TriggerbotGroupBox:AddSlider("TriggerbotDelay", { Text = "Fire Delay (sec)", Default = 0.05, Min = 0.01, Max = 1, Rounding = 2, Callback = function(Value) TB_DELAY = Value end })

    -- ==========================================
    -- UNLOCK ALL 설정 (원본 코드로 복구, 프리징 루프만 제거)
    -- ==========================================
    local UnlockGroupBox = Tabs.Main:AddRightGroupbox("Unlock All")
    local unlockAllExecuted = false

    UnlockGroupBox:AddButton({
        Text = "Unlock All Cosmetics",
        Tooltip = "Unlocks Skins, Charms, Dances, Wraps, Finishers. Saves Loadout.",
        Func = function()
            if unlockAllExecuted then Library:Notify("Already executed!") return end
            unlockAllExecuted = true
            Library:Notify("Starting Unlock All...")
            task.spawn(function()
                task.wait(0.5)
                local ok, err = pcall(function()
                    local HttpService = game:GetService("HttpService")
                    local playerScripts = safeWait(player, "PlayerScripts", 10)
                    local controllers = safeWait(playerScripts, "Controllers", 10)
                    local modules = safeWait(ReplicatedStorage, "Modules", 10)
                    if not modules then return end
                    
                    local EnumLibrary = safeRequire(safeWait(modules, "EnumLibrary", 10))
                    if EnumLibrary and EnumLibrary.WaitForEnumBuilder then pcall(function() EnumLibrary:WaitForEnumBuilder() end) end
                    local CosmeticLibrary = safeRequire(safeWait(modules, "CosmeticLibrary", 10))
                    local ItemLibrary = safeRequire(safeWait(modules, "ItemLibrary", 10))
                    local DataController = safeRequire(safeWait(controllers, "PlayerDataController", 10))
                    if not CosmeticLibrary or not ItemLibrary or not DataController then return end
                    
                    local equipped, favorites = {}, {}
                    local lastUsedWeapon = nil
                    local ValidTypes = { Skin = true, Charm = true, Dance = true, Emote = true, Wrap = true, Wrapping = true, Finisher = true }
                    local validCache = {}
                    
                    local function isValidCosmetic(name)
                        if type(name) ~= "string" then return false end
                        if validCache[name] ~= nil then return validCache[name] end
                        if name:find("MISSING_") then validCache[name] = false return false end
                        local cosmetic = CosmeticLibrary.Cosmetics and CosmeticLibrary.Cosmetics[name]
                        local result = false
                        if cosmetic then
                            if ValidTypes[cosmetic.Type] then result = true end
                            local ln = name:lower()
                            if cosmetic.Type == "Charm" or ln:find("charm") then result = true end
                            if cosmetic.Type == "Dance" or cosmetic.Type == "Emote" or ln:find("dance") or ln:find("emote") then result = true end
                            if cosmetic.Type == "Wrap" or cosmetic.Type == "Wrapping" or ln:find("wrap") then result = true end
                            if cosmetic.Type == "Finisher" or ln:find("finisher") then result = true end
                        end
                        validCache[name] = result
                        return result
                    end
                    
                    local function cloneCosmetic(name, cosmeticType, options)
                        local base = CosmeticLibrary.Cosmetics and CosmeticLibrary.Cosmetics[name]
                        if not base then return nil end
                        local data = {}
                        for k, v in pairs(base) do data[k] = v end
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
                            for w, c in pairs(equipped) do
                                config.equipped[w] = {}
                                for t, d in pairs(c) do
                                    if d and d.Name then config.equipped[w][t] = { name = d.Name, seed = d.Seed, inverted = d.Inverted } end
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
                                for w, c in pairs(config.equipped) do
                                    equipped[w] = {}
                                    for t, d in pairs(c) do
                                        local cloned = cloneCosmetic(d.name, t, {inverted = d.inverted})
                                        if cloned then cloned.Seed = d.seed equipped[w][t] = cloned end
                                    end
                                end
                            end
                            favorites = config.favorites or {}
                        end)
                    end
                    
                    local originalOwnsCosmetic = CosmeticLibrary.OwnsCosmetic or function() return false end
                    CosmeticLibrary.OwnsCosmetic = function(self, inv, name, weapon)
                        if isValidCosmetic(name) then return true end
                        return originalOwnsCosmetic(self, inv, name, weapon)
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
                            for w, favs in pairs(favorites) do
                                result[w] = result[w] or {}
                                for n, isFav in pairs(favs) do if isValidCosmetic(n) then result[w][n] = isFav end end
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
                        for k, v in pairs(data) do merged[k] = v end
                        merged.Name = weaponName
                        if equipped[weaponName] then
                            for t, d in pairs(equipped[weaponName]) do merged[t] = d end
                        end
                        return merged
                    end
                    
                    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                    local dataRemotes = remotes and remotes:FindFirstChild("Data")
                    local equipRemote = dataRemotes and dataRemotes:FindFirstChild("EquipCosmetic")
                    
                    if equipRemote and hookmetamethod then
                        local oldNamecall
                        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                            if getnamecallmethod() ~= "FireServer" then return oldNamecall(self, ...) end
                            local args = {...}
                            
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
                            
                            return oldNamecall(self, ...)
                        end)
                    end
                    
                    loadConfig()
                    Library:Notify("Unlock All loaded!")
                end)
                
                if not ok then
                    warn("Unlock All Error:", err)
                    unlockAllExecuted = false
                end
            end)
        end
    })

    -- WATERMARK
    Library:SetWatermarkVisibility(true)
    local FrameTimer, FrameCounter, FPS = tick(), 0, 60
    local WatermarkConnection = RunService.RenderStepped:Connect(function()
        pcall(function()
            FrameCounter += 1
            if (tick() - FrameTimer) >= 1 then FPS = FrameCounter FrameTimer = tick() FrameCounter = 0 end
            Library:SetWatermark(("Necrophilia | %d fps"):format(math.floor(FPS)))
        end)
    end)

    Library:OnUnload(function()
        WatermarkConnection:Disconnect()
        if AimbotRenderConnection then AimbotRenderConnection:Disconnect() end
        if fovCircle then fovCircle.Visible = false fovCircle:Remove() end
        if saFovCircle then saFovCircle.Visible = false saFovCircle:Remove() end
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
    
    -- 다크 레드 테마 강제 적용
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

    -- UI 1회 세팅
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

if not success then warn("Script failed to load:", err) end
