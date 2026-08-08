--[[
                                               _                                 
                     __      ____ _ _ __ _ __ (_)_ __   __ _                     
                     \ \ /\ / / _` | '__| '_ \| | '_ \ / _` |                    
                      \ V  V / (_| | |  | | | | | | | | (_| |                    
                       \_/\_/ \__,_|_|  |_| |_|_|_| |_|\__, |                    
                                                       |___/                     
 --]]

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
        Center = true,
        AutoShow = true,
        Resizable = true,
        ShowCustomCursor = true,
        UnlockMouseWhileOpen = true,
        NotifySide = "Left",
        TabPadding = 8,
        MenuFadeTime = 0.2
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

    local AimbotRenderConnection
    AimbotRenderConnection = RunService.RenderStepped:Connect(function()
        pcall(function()
            if showFOV and fovCircle then
                local mousePos = UserInputService:GetMouseLocation()
                fovCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
                fovCircle.Radius = AIM_RADIUS
                fovCircle.Visible = true
            elseif fovCircle then
                fovCircle.Visible = false
            end

            local isKeybindActive = false
            if Options.AimbotKeybind then isKeybindActive = Options.AimbotKeybind:GetState() end
            
            if aimbotEnabled and isKeybindActive then
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

    local AimbotGroupBox = Tabs.Main:AddLeftGroupbox("Aimbot")
    AimbotGroupBox:AddToggle("AimbotToggle", { Text = "Enable Aimbot", Default = false, Callback = function(Value) aimbotEnabled = Value end })
    AimbotGroupBox:AddLabel("Aimbot Keybind"):AddKeyPicker("AimbotKeybind", { Default = "MB2", SyncToggleState = false, Mode = "Hold", Text = "Aimbot Key", NoUI = false })
    AimbotGroupBox:AddToggle("AimbotShowFOV", { Text = "Show FOV Circle", Default = false, Callback = function(Value) showFOV = Value end })
    AimbotGroupBox:AddToggle("AimbotTeamCheck", { Text = "Team Check", Default = true, Callback = function(Value) teamCheck = Value end })
    AimbotGroupBox:AddToggle("AimbotWallCheck", { Text = "Wall Check", Default = true, Callback = function(Value) wallCheck = Value end })
    AimbotGroupBox:AddSlider("AimbotSmoothness", { Text = "Smoothness (1 = Strong)", Default = 1, Min = 1, Max = 10, Rounding = 0, Callback = function(Value) SMOOTH_FACTOR = Value end })
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

    local saFovCircle = nil
    if Drawing then
        pcall(function()
            saFovCircle = Drawing.new("Circle")
            saFovCircle.Color = Color3.fromRGB(255, 0, 0)
            saFovCircle.Thickness = 1
            saFovCircle.Transparency = 1
            saFovCircle.Filled = false
            saFovCircle.Visible = false
            saFovCircle.Radius = SA_FOV
        end)
    end

    local UtilityModule = nil
    local originalRaycast = nil

    pcall(function()
        UtilityModule = require(ReplicatedStorage.Modules.Utility)
        if UtilityModule and UtilityModule.Raycast then originalRaycast = UtilityModule.Raycast end
    end)

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
                    local char = plr.Character
                    local head = char:FindFirstChild("Head")
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if head and humanoid and humanoid.Health > 0 then
                        local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
                        if onScreen and screenPos.Z > 0 then
                            local dist = (screenCenter - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                            if dist < shortestDist then
                                local canSee = true
                                if SA_WALLCHECK then
                                    local origin = camera.CFrame.Position
                                    local direction = (head.Position - origin)
                                    local hit = workspace:Raycast(origin, direction, rayParams)
                                    if hit and hit.Instance and not hit.Instance:IsDescendantOf(char) then canSee = false end
                                end
                                if canSee then shortestDist = dist closestPart = head end
                            end
                        end
                    end
                end
            end
        end
        return closestPart
    end

    if originalRaycast then
        UtilityModule.Raycast = function(self, origin, direction, distance, params, ignoreWater, debug)
            local isKeybindActive = false
            if Options.SilentAimKeybind then isKeybindActive = Options.SilentAimKeybind:GetState() end

            if not SA_ENABLED or not isKeybindActive or type(distance) ~= "number" or distance < 100 then
                return originalRaycast(self, origin, direction, distance, params, ignoreWater, debug)
            end

            local targetPart = getSilentTargetPart()
            if not targetPart then
                return originalRaycast(self, origin, direction, distance, params, ignoreWater, debug)
            end

            local targetPos = targetPart.Position
            local newDir = (targetPos - origin).Unit
            local newDist = (targetPos - origin).Magnitude

            if newDist > distance then
                newDist = distance
                targetPos = origin + (newDir * distance)
            end

            return {
                Position = targetPos,
                Distance = newDist,
                Instance = targetPart,
                Material = targetPart.Material,
                Normal = -newDir
            }
        end
    end

    RunService.RenderStepped:Connect(function()
        pcall(function()
            local isKeybindActive = false
            if Options.SilentAimKeybind then isKeybindActive = Options.SilentAimKeybind:GetState() end
            if saFovCircle then
                if SA_ENABLED and SA_SHOW_FOV and isKeybindActive then
                    saFovCircle.Position = camera.ViewportSize / 2
                    saFovCircle.Radius = SA_FOV
                    saFovCircle.Visible = true
                else
                    saFovCircle.Visible = false
                end
            end
        end)
    end)

    local SilentAimGroupBox = Tabs.Main:AddLeftGroupbox("Silent Aim")
    SilentAimGroupBox:AddToggle("SilentAimToggle", { Text = "Enable Silent Aim", Default = false, Callback = function(Value) SA_ENABLED = Value end })
    SilentAimGroupBox:AddLabel("Silent Aim Keybind"):AddKeyPicker("SilentAimKeybind", { Default = "MB2", SyncToggleState = false, Mode = "Hold", Text = "Silent Key", NoUI = false })
    SilentAimGroupBox:AddToggle("SilentAimTeamCheck", { Text = "Team Check", Default = true, Callback = function(Value) SA_TEAMCHECK = Value end })
    SilentAimGroupBox:AddToggle("SilentAimWallCheck", { Text = "Wall Check", Default = true, Callback = function(Value) SA_WALLCHECK = Value end })
    SilentAimGroupBox:AddToggle("SilentAimShowFOV", { Text = "Show Silent FOV", Default = true, Callback = function(Value) SA_SHOW_FOV = Value end })
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

    local function getTriggerTarget()
        local closest, dist = nil, TB_FOV
        local mousePos = UserInputService:GetMouseLocation()
        local localRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not localRoot then return nil end
        
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        rayParams.FilterDescendantsInstances = {player.Character}
        rayParams.IgnoreWater = true
        
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") then
                if plr.Character.Humanoid.Health > 0 then
                    local pos, onScreen = camera:WorldToViewportPoint(plr.Character.Head.Position)
                    if onScreen then
                        local d = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if d < dist then
                            local canSee = true
                            if TB_WALLCHECK then
                                local origin = camera.CFrame.Position
                                local direction = (plr.Character.Head.Position - origin)
                                local hit = workspace:Raycast(origin, direction, rayParams)
                                if hit and hit.Instance and not hit.Instance:IsDescendantOf(plr.Character) then canSee = false end
                            end
                            if canSee then dist = d closest = plr.Character end
                        end
                    end
                end
            end
        end
        return closest
    end

    task.spawn(function()
        while task.wait() do
            pcall(function()
                if TB_ENABLED and not isLobbyVisible() then
                    local isKeybindActive = false
                    if Options.TriggerbotKeybind then isKeybindActive = Options.TriggerbotKeybind:GetState() end
                    if isKeybindActive then
                        local target = getTriggerTarget()
                        if target then
                            if mouse1click then mouse1click() end
                            task.wait(TB_DELAY)
                        end
                    end
                end
            end)
        end
    end)

    local TriggerbotGroupBox = Tabs.Main:AddLeftGroupbox("Triggerbot")
    TriggerbotGroupBox:AddToggle("TriggerbotToggle", { Text = "Enable Triggerbot", Default = false, Callback = function(Value) TB_ENABLED = Value end })
    TriggerbotGroupBox:AddLabel("Triggerbot Keybind"):AddKeyPicker("TriggerbotKeybind", { Default = "MB2", SyncToggleState = false, Mode = "Hold", Text = "Trigger Key", NoUI = false })
    TriggerbotGroupBox:AddToggle("TriggerbotWallCheck", { Text = "Wall Check", Default = true, Callback = function(Value) TB_WALLCHECK = Value end })
    TriggerbotGroupBox:AddSlider("TriggerbotFOV", { Text = "Trigger FOV Radius", Default = 50, Min = 1, Max = 1000, Rounding = 0, Callback = function(Value) TB_FOV = Value end })
    TriggerbotGroupBox:AddSlider("TriggerbotDelay", { Text = "Fire Delay (sec)", Default = 0.05, Min = 0.01, Max = 1, Rounding = 2, Callback = function(Value) TB_DELAY = Value end })

    -- ==========================================
    -- UNLOCK ALL 설정
    -- ==========================================
    local LeftGroupBox = Tabs.Main:AddLeftGroupbox("Groupbox")
    local UnlockGroupBox = Tabs.Main:AddRightGroupbox("Unlock All")

    local unlockAllExecuted = false
    local function safeWait(parent, name, timeout)
        if not parent then return nil end
        timeout = timeout or 5
        local success, obj = pcall(function() return parent:WaitForChild(name, timeout) end)
        return success and obj or nil
    end
    local function safeRequire(path)
        if not path then return nil end
        local success, module = pcall(function() return require(path) end)
        return success and module or nil
    end
    local function safeClone(t)
        if not t then return {} end
        if type(table) == "table" and type(table.clone) == "function" then return table.clone(t) end
        local copy = {}
        for k, v in pairs(t) do copy[k] = v end
        return copy
    end

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

    LeftGroupBox:AddToggle("MyToggle", { Text = "This is a toggle", Tooltip = "This is a tooltip", DisabledTooltip = "I am disabled!", Default = true, Disabled = false, Visible = true, Risky = false, Callback = function(Value) print("[cb] MyToggle changed to:", Value) end }):AddColorPicker("ColorPicker1", { Default = Color3.new(1, 0, 0), Title = "Some color1", Transparency = 0, Callback = function(Value, Transparency) print("[cb] Color changed!", Value, "| Transparency changed to:", Transparency) end }):AddColorPicker("ColorPicker2", { Default = Color3.new(0, 1, 0), Title = "Some color2", Transparency = 0, Callback = function(Value, Transparency) print("[cb] Color changed!", Value, "| Transparency changed to:", Transparency) end }):AddColorPicker("ColorPicker3", { Default = Color3.new(0, 0, 1), Title = "Some color3", Transparency = 0, Callback = function(Value, Transparency) print("[cb] Color changed!", Value, "| Transparency changed to:", Transparency) end })

    Toggles.MyToggle:OnChanged(function() print("MyToggle changed to:", Toggles.MyToggle.Value) end)
    Toggles.MyToggle:SetValue(false)

    local MyButton = LeftGroupBox:AddButton({ Text = "Button", Func = function() print("You clicked a button!") Library:Notify("This is a notification") end, DoubleClick = false, Tooltip = "This is the main button", DisabledTooltip = "I am disabled!", Disabled = false, Visible = true })
    local MyButton2 = MyButton:AddButton({ Text = "Sub button", Func = function() print("You clicked a sub button!") Library:Notify("This is a notification with sound", nil, 4590657391) end, DoubleClick = true, Tooltip = "This is the sub button (double click me!)" })
    local MyDisabledButton = LeftGroupBox:AddButton({ Text = "Disabled Button", Func = function() print("You somehow clicked a disabled button!") end, DoubleClick = false, Tooltip = "This is a disabled button", DisabledTooltip = "I am disabled!", Disabled = true })

    LeftGroupBox:AddLabel("This is a label")
    LeftGroupBox:AddLabel("This is a label\n\nwhich wraps its text!", true)
    LeftGroupBox:AddLabel("This is a label exposed to Labels", true, "TestLabel")
    LeftGroupBox:AddLabel("SecondTestLabel", { Text = "This is a label made with table options and an index", DoesWrap = true })
    LeftGroupBox:AddLabel("SecondTestLabel", { Text = "This is a label that doesn\"t wrap it\"s own text", DoesWrap = false })
    LeftGroupBox:AddDivider()

    LeftGroupBox:AddSlider("MySlider", { Text = "This is my slider!", Default = 0, Min = 0, Max = 5, Rounding = 1, Compact = false, Callback = function(Value) print("[cb] MySlider was changed! New value:", Value) end, Tooltip = "I am a slider!", DisabledTooltip = "I am disabled!", Disabled = false, Visible = true })
    local Number = Options.MySlider.Value
    Options.MySlider:OnChanged(function() print("MySlider was changed! New value:", Options.MySlider.Value) end)
    Options.MySlider:SetValue(3)

    LeftGroupBox:AddSlider("MySlider2", { Text = "This is my custom display slider!", Default = 0, Min = 0, Max = 5, Rounding = 1, Compact = false, FormatDisplayValue = function(slider, value) if value == slider.Max then return "Everything" end if value == slider.Min then return "Nothing" end end, Tooltip = "I am a slider!", DisabledTooltip = "I am disabled!", Disabled = false, Visible = true })
    LeftGroupBox:AddInput("MyTextbox", { Default = "My textbox!", Numeric = false, Finished = false, ClearTextOnFocus = true, Text = "This is a textbox", Tooltip = "This is a tooltip", Placeholder = "Placeholder text", Callback = function(Value) print("[cb] Text updated. New text:", Value) end })
    Options.MyTextbox:OnChanged(function() print("Text updated. New text:", Options.MyTextbox.Value) end)

    local DropdownGroupBox = Tabs.Main:AddRightGroupbox("Dropdowns")
    DropdownGroupBox:AddDropdown("MyDropdown", { Values = { "This", "is", "a", "dropdown" }, Default = 1, Multi = false, Text = "A dropdown", Tooltip = "This is a tooltip", DisabledTooltip = "I am disabled!", Searchable = false, Callback = function(Value) print("[cb] Dropdown got changed. New value:", Value) end, Disabled = false, Visible = true })
    Options.MyDropdown:OnChanged(function() print("Dropdown got changed. New value:", Options.MyDropdown.Value) end)
    Options.MyDropdown:SetValue("This")
    DropdownGroupBox:AddDropdown("MySearchableDropdown", { Values = { "This", "is", "a", "searchable", "dropdown" }, Default = 1, Multi = false, Text = "A searchable dropdown", Tooltip = "This is a tooltip", DisabledTooltip = "I am disabled!", Searchable = true, Callback = function(Value) print("[cb] Dropdown got changed. New value:", Value) end, Disabled = false, Visible = true })
    DropdownGroupBox:AddDropdown("MyDisplayFormattedDropdown", { Values = { "This", "is", "a", "formatted", "dropdown" }, Default = 1, Multi = false, Text = "A display formatted dropdown", Tooltip = "This is a tooltip", DisabledTooltip = "I am disabled!", FormatDisplayValue = function(Value) if Value == "formatted" then return "display formatted" end; return Value end, Searchable = false, Callback = function(Value) print("[cb] Display formatted dropdown got changed. New value:", Value) end, Disabled = false, Visible = true })
    DropdownGroupBox:AddDropdown("MyMultiDropdown", { Values = { "This", "is", "a", "dropdown" }, Default = 1, Multi = true, Text = "A multi dropdown", Tooltip = "This is a tooltip", Callback = function(Value) print("[cb] Multi dropdown got changed:") for key, value in next, Options.MyMultiDropdown.Value do print(key, value) end end })
    Options.MyMultiDropdown:SetValue({ This = true, is = true })
    DropdownGroupBox:AddDropdown("MyDisabledDropdown", { Values = { "This", "is", "a", "dropdown" }, Default = 1, Multi = false, Text = "A disabled dropdown", Tooltip = "This is a tooltip", DisabledTooltip = "I am disabled!", Callback = function(Value) print("[cb] Disabled dropdown got changed. New value:", Value) end, Disabled = true, Visible = true })
    DropdownGroupBox:AddDropdown("MyDisabledValueDropdown", { Values = { "This", "is", "a", "dropdown", "with", "disabled", "value" }, DisabledValues = { "disabled" }, Default = 1, Multi = false, Text = "A dropdown with disabled value", Tooltip = "This is a tooltip", DisabledTooltip = "I am disabled!", Callback = function(Value) print("[cb] Dropdown with disabled value got changed. New value:", Value) end, Disabled = false, Visible = true })
    DropdownGroupBox:AddDropdown("MyVeryLongDropdown", { Values = { "This", "is", "a", "very", "long", "dropdown", "with", "a", "lot", "of", "values", "but", "you", "can", "see", "more", "than", "8", "values" }, Default = 1, Multi = false, MaxVisibleDropdownItems = 12, Text = "A very long dropdown", Tooltip = "This is a tooltip", DisabledTooltip = "I am disabled!", Searchable = false, Callback = function(Value) print("[cb] Very long dropdown got changed. New value:", Value) end, Disabled = false, Visible = true })
    DropdownGroupBox:AddDropdown("MyPlayerDropdown", { SpecialType = "Player", ExcludeLocalPlayer = true, Text = "A player dropdown", Tooltip = "This is a tooltip", Callback = function(Value) print("[cb] Player dropdown got changed:", Value) end })
    DropdownGroupBox:AddDropdown("MyTeamDropdown", { SpecialType = "Team", Text = "A team dropdown", Tooltip = "This is a tooltip", Callback = function(Value) print("[cb] Team dropdown got changed:", Value) end })

    LeftGroupBox:AddLabel("Color"):AddColorPicker("ColorPicker", { Default = Color3.new(0, 1, 0), Title = "Some color", Transparency = 0, Callback = function(Value) print("[cb] Color changed!", Value) end })
    Options.ColorPicker:OnChanged(function() print("Color changed!", Options.ColorPicker.Value) print("Transparency changed!", Options.ColorPicker.Transparency) end)
    Options.ColorPicker:SetValueRGB(Color3.fromRGB(0, 255, 140))

    LeftGroupBox:AddLabel("Keybind"):AddKeyPicker("KeyPicker", { Default = "MB2", SyncToggleState = false, Mode = "Toggle", Text = "Auto lockpick safes", NoUI = false, Callback = function(Value) print("[cb] Keybind clicked!", Value) end, ChangedCallback = function(NewKey, NewModifiers) print("[cb] Keybind changed!", NewKey, table.unpack(NewModifiers or {})) end })
    Options.KeyPicker:OnClick(function() print("Keybind clicked!", Options.KeyPicker:GetState()) end)
    Options.KeyPicker:OnChanged(function() print("Keybind changed!", Options.KeyPicker.Value, table.unpack(Options.KeyPicker.Modifiers or {})) end)
    task.spawn(function() while task.wait(1) do local state = Options.KeyPicker:GetState() if state then print("KeyPicker is being held down") end if Library.Unloaded then break end end end)
    Options.KeyPicker:SetValue({ "MB2", "Hold" }) 

    local KeybindNumber = 0
    LeftGroupBox:AddLabel("Press Keybind"):AddKeyPicker("KeyPicker2", { Default = "X", Mode = "Press", WaitForCallback = false, Text = "Increase Number", Callback = function() KeybindNumber = KeybindNumber + 1 print("[cb] Keybind clicked! Number increased to:", KeybindNumber) end })
    LeftGroupBox:AddLabel("Dropdown"):AddDropdown("MyDropdown", { Values = { "Addon", "Dropdown" }, Default = 1, Multi = false, Tooltip = "This is a tooltip", DisabledTooltip = "I am disabled!", Searchable = false, Callback = function(Value) print("[cb] Dropdown got changed. New value:", Value) end, Disabled = false, Visible = true })

    local LeftGroupBox2 = Tabs.Main:AddLeftGroupbox("Groupbox #2");
    LeftGroupBox2:AddLabel("Oh no...\nThis label spans multiple lines!\n\nWe\'re gonna run out of UI space...\nJust kidding! Scroll down!\n\n\nHello from below!", true)

    local TabBox = Tabs.Main:AddRightTabbox() 
    local Tab1 = TabBox:AddTab("Tab 1")
    Tab1:AddToggle("Tab1Toggle", { Text = "Tab1 Toggle" });
    local Tab2 = TabBox:AddTab("Tab 2")
    Tab2:AddToggle("Tab2Toggle", { Text = "Tab2 Toggle" });

    local RightGroupbox = Tabs.Main:AddRightGroupbox("Groupbox #3");
    RightGroupbox:AddToggle("ControlToggle", { Text = "Dependency box toggle" });
    local Depbox = RightGroupbox:AddDependencyBox();
    Depbox:AddToggle("DepboxToggle", { Text = "Sub-dependency box toggle" });
    local SubDepbox = Depbox:AddDependencyBox();
    SubDepbox:AddSlider("DepboxSlider", { Text = "Slider", Default = 50, Min = 0, Max = 100, Rounding = 0 });
    SubDepbox:AddDropdown("DepboxDropdown", { Text = "Dropdown", Default = 1, Values = {"a", "b", "c"} });
    local SecretDepbox = SubDepbox:AddDependencyBox();
    SecretDepbox:AddLabel("You found a seĉret!")
    Depbox:SetupDependencies({ { Toggles.ControlToggle, true } });
    SubDepbox:SetupDependencies({ { Toggles.DepboxToggle, true } });
    SecretDepbox:SetupDependencies({ { Options.DepboxDropdown, "ĉ"} })

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
    SaveManager:LoadAutoloadConfig()
end)

if not success then
    warn("Script failed to load:", err)
end
