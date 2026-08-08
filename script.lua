--[[
                                               _                                 
                     __      ____ _ _ __ _ __ (_)_ __   __ _                     
                     \ \ /\ / / _` | '__| '_ \| | '_ \ / _` |                    
                      \ V  V / (_| | |  | | | | | | | | (_| |                    
                       \_/\_/ \__,_|_|  |_| |_|_|_| |_|\__, |                    
                                                       |___/                     
 --]]

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
    Title = "Example menu",
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

-- ==========================================
-- AIMBOT 설정 및 초기화
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local AIM_RADIUS = 200
local SMOOTH_FACTOR = 1.0 -- 1이 가장 셈 (즉시 타겟팅)
local aiming = false

-- FOV 원 생성
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "AimbotGui"
local fov = Instance.new("Frame", gui)
fov.AnchorPoint = Vector2.new(0.5, 0.5)
fov.Position = UDim2.new(0.5, 0, 0.5, 0)
fov.Size = UDim2.new(0.18, 0, 0.18, 0)
fov.BackgroundTransparency = 1
fov.Visible = false
Instance.new("UICorner", fov).CornerRadius = UDim.new(1, 0)
local stroke = Instance.new("UIStroke", fov)
stroke.Thickness = 3
stroke.Transparency = 0.7
stroke.Color = Color3.new(1, 1, 1)

local function getTarget()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local closest, dist = nil, AIM_RADIUS
    for _, m in pairs(workspace:GetDescendants()) do
        if m:IsA("Model") and m:FindFirstChild("Humanoid") and m:FindFirstChild("Head") and m ~= player.Character then
            local d = (m.Head.Position - root.Position).Magnitude
            if d < dist then
                dist = d
                closest = m
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if not aiming then return end
    local target = getTarget()
    if target then
        local head = target:FindFirstChild("Head")
        if head then
            local cf = CFrame.new(camera.CFrame.Position, head.Position)
            -- SMOOTH_FACTOR가 1에 가까울수록 즉시 타겟팅, 0에 가까울수록 느림
            camera.CFrame = camera.CFrame:Lerp(cf, SMOOTH_FACTOR)
        end
    end
end)
-- ==========================================

-- 맨 왼쪽 그룹박스에 에임봇 UI 추가
local AimbotGroupBox = Tabs.Main:AddLeftGroupbox("Aimbot")

AimbotGroupBox:AddToggle("AimbotToggle", {
    Text = "Enable Aimbot",
    Tooltip = "Toggles the aimbot on and off",
    Default = false,
    Callback = function(Value)
        aiming = Value
        fov.Visible = Value
    end
})

AimbotGroupBox:AddSlider("AimbotSmoothness", {
    Text = "Smoothness (1 = Strong)",
    Default = 1,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Callback = function(Value)
        -- 1이 가장 셈(1.0), 10이 가장 약함(0.1)
        -- 공식: 1.1 - (Value / 10)
        -- 1 -> 1.0
        -- 10 -> 0.1
        SMOOTH_FACTOR = 1.1 - (Value / 10)
    end
})

-- 기존 그룹박스들
local LeftGroupBox = Tabs.Main:AddLeftGroupbox("Groupbox")
local UnlockGroupBox = Tabs.Main:AddRightGroupbox("Unlock All")

local unlockAllExecuted = false

local function safeWait(parent, name, timeout)
    timeout = timeout or 5
    local success, obj = pcall(function() return parent:WaitForChild(name, timeout) end)
    return success and obj or nil
end

local function safeRequire(path)
    local success, module = pcall(function() return require(path) end)
    return success and module or nil
end

UnlockGroupBox:AddButton({
    Text = "Unlock All Cosmetics",
    Tooltip = "Unlocks Skins, Charms, Dances, Wraps. No Freeze/Lag.",
    Func = function()
        if unlockAllExecuted then
            Library:Notify("Unlock All has already been executed!")
            return
        end
        unlockAllExecuted = true
        Library:Notify("Starting Unlock All... Please wait 1 second.")

        task.delay(1, function()
            local success, err = pcall(function()
                local Players = game:GetService("Players")
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local HttpService = game:GetService("HttpService")
                local player = Players.LocalPlayer
                
                local playerScripts = safeWait(player, "PlayerScripts", 10)
                if not playerScripts then return end
                local controllers = safeWait(playerScripts, "Controllers", 10)
                if not controllers then return end
                
                local modules = safeWait(ReplicatedStorage, "Modules", 10)
                if not modules then return end
                
                local EnumLibrary = safeRequire(safeWait(modules, "EnumLibrary", 10))
                if EnumLibrary and EnumLibrary.WaitForEnumBuilder then
                    pcall(function() EnumLibrary:WaitForEnumBuilder() end)
                end
                
                local CosmeticLibrary = safeRequire(safeWait(modules, "CosmeticLibrary", 10))
                local ItemLibrary = safeRequire(safeWait(modules, "ItemLibrary", 10))
                local DataController = safeRequire(safeWait(controllers, "PlayerDataController", 10))
                
                if not CosmeticLibrary or not ItemLibrary or not DataController then
                    Library:Notify("Failed to load game modules!")
                    return
                end
                
                local equipped, favorites = {}, {}
                local constructingWeapon, viewingProfile = nil, nil
                local lastUsedWeapon = nil
                
                local ValidTypes = { Skin = true, Charm = true, Dance = true, Emote = true, Wrap = true, Wrapping = true }
                local validCache = {}
                
                local function isValidCosmetic(name)
                    if not name then return false end
                    if validCache[name] ~= nil then return validCache[name] end
                    if name:find("MISSING_") then validCache[name] = false return false end
                    
                    local cosmetic = CosmeticLibrary.Cosmetics[name]
                    local result = false
                    if cosmetic then
                        if ValidTypes[cosmetic.Type] then result = true end
                        local lowerName = name:lower()
                        if cosmetic.Type == "Charm" or lowerName:find("charm") then result = true end
                        if cosmetic.Type == "Dance" or cosmetic.Type == "Emote" or lowerName:find("dance") or lowerName:find("emote") then result = true end
                        if cosmetic.Type == "Wrap" or cosmetic.Type == "Wrapping" or lowerName:find("wrap") then result = true end
                    end
                    validCache[name] = result
                    return result
                end
                
                local function cloneCosmetic(name, cosmeticType, options)
                    local base = CosmeticLibrary.Cosmetics[name]
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
                                    config.equipped[weapon][cosmeticType] = {
                                        name = cosmeticData.Name, seed = cosmeticData.Seed, inverted = cosmeticData.Inverted
                                    }
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
                
                local originalOwnsCosmetic = CosmeticLibrary.OwnsCosmetic
                CosmeticLibrary.OwnsCosmetic = function(self, inventory, name, weapon)
                    if isValidCosmetic(name) then return true end
                    return originalOwnsCosmetic(self, inventory, name, weapon)
                end
                
                local originalGet = DataController.Get
                DataController.Get = function(self, key)
                    local data = originalGet(self, key)
                    if key == "CosmeticInventory" then
                        local proxy = {}
                        if data then for k, v in pairs(data) do 
                            if isValidCosmetic(k) then proxy[k] = v end
                        end end
                        return setmetatable(proxy, {__index = function(t, k)
                            if isValidCosmetic(k) then return true end
                            return nil
                        end})
                    end
                    if key == "FavoritedCosmetics" then
                        local result = data and table.clone(data) or {}
                        for weapon, favs in pairs(favorites) do
                            result[weapon] = result[weapon] or {}
                            for name, isFav in pairs(favs) do 
                                if isValidCosmetic(name) then result[weapon][name] = isFav end
                            end
                        end
                        return result
                    end
                    return data
                end
                
                local originalGetWeaponData = DataController.GetWeaponData
                DataController.GetWeaponData = function(self, weaponName)
                    local data = originalGetWeaponData(self, weaponName)
                    if not data then return nil end
                    local merged = {}
                    for key, value in pairs(data) do merged[key] = value end
                    merged.Name = weaponName
                    if equipped[weaponName] then
                        for cosmeticType, cosmeticData in pairs(equipped[weaponName]) do 
                            merged[cosmeticType] = cosmeticData
                        end
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
                            if getnamecallmethod() ~= "FireServer" then return oldNamecall(self, ...) end
                            local args = {...}
                            
                            if useItemRemote and self == useItemRemote then
                                local objectID = args[1]
                                if FighterController then
                                    pcall(function()
                                        local fighter = FighterController:GetFighter(player)
                                        if fighter and fighter.Items then
                                            for _, item in pairs(fighter.Items) do
                                                if item:Get("ObjectID") == objectID then lastUsedWeapon = item.Name break end
                                            end
                                        end
                                    end)
                                end
                            end
                            
                            if self == equipRemote then
                                local weaponName, cosmeticType, cosmeticName, options = args[1], args[2], args[3], args[4] or {}
                                if cosmeticType == "Dance" or cosmeticType == "Emote" then
                                    equipped.Dances = equipped.Dances or {}
                                    if not cosmeticName or cosmeticName == "None" or cosmeticName == "" then
                                        equipped.Dances[cosmeticType] = nil
                                    else
                                        local cloned = cloneCosmetic(cosmeticName, cosmeticType, {inverted = options.IsInverted, favoritesOnly = options.OnlyUseFavorites})
                                        if cloned then equipped.Dances[cosmeticType] = cloned end
                                    end
                                    task.defer(function()
                                        pcall(function() DataController.CurrentData:Replicate("CosmeticInventory") end)
                                        task.wait(0.2)
                                        saveConfig()
                                    end)
                                    return
                                else
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
                                    task.defer(function()
                                        pcall(function() DataController.CurrentData:Replicate("WeaponInventory") end)
                                        task.wait(0.2)
                                        saveConfig()
                                    end)
                                    return
                                end
                            end
                            
                            if self == favoriteRemote then
                                if isValidCosmetic(args[2]) then
                                    favorites[args[1]] = favorites[args[1]] or {}
                                    favorites[args[1]][args[2]] = args[3] or nil
                                    saveConfig()
                                    task.spawn(function() pcall(function() DataController.CurrentData:Replicate("FavoritedCosmetics") end) end)
                                end
                                return
                            end
                            
                            return oldNamecall(self, ...)
                        end)
                    end
                end
                
                local ClientItem = safeRequire(safeWait(safeWait(safeWait(playerScripts, "Modules", 10), "ClientReplicatedClasses", 10), "ClientFighter", 10) and safeWait(playerScripts.Modules.ClientReplicatedClasses.ClientFighter, "ClientItem", 10))
                
                if ClientItem and ClientItem._CreateViewModel then
                    local originalCreateViewModel = ClientItem._CreateViewModel
                    ClientItem._CreateViewModel = function(self, viewmodelRef)
                        if not self or not viewmodelRef then return originalCreateViewModel(self, viewmodelRef) end
                        local weaponName = self.Name
                        local weaponPlayer = self.ClientFighter and self.ClientFighter.Player
                        constructingWeapon = (weaponPlayer == player) and weaponName or nil
                        
                        if weaponPlayer == player and equipped[weaponName] and viewmodelRef then
                            local dataKey = self:ToEnum("Data")
                            local cosmetics = equipped[weaponName]
                            
                            if viewmodelRef[dataKey] then
                                if cosmetics.Skin then
                                    viewmodelRef[dataKey][self:ToEnum("Skin")] = cosmetics.Skin
                                    viewmodelRef[dataKey][self:ToEnum("Name")] = cosmetics.Skin.Name
                                end
                                if cosmetics.Charm then
                                    viewmodelRef[dataKey][self:ToEnum("Charm")] = cosmetics.Charm
                                end
                                if cosmetics.Wrap then
                                    viewmodelRef[dataKey][self:ToEnum("Wrap")] = cosmetics.Wrap
                                end
                            elseif viewmodelRef.Data then
                                if cosmetics.Skin then
                                    viewmodelRef.Data.Skin = cosmetics.Skin
                                    viewmodelRef.Data.Name = cosmetics.Skin.Name
                                end
                                if cosmetics.Charm then viewmodelRef.Data.Charm = cosmetics.Charm end
                                if cosmetics.Wrap then viewmodelRef.Data.Wrap = cosmetics.Wrap end
                            end
                        end
                        
                        local result = originalCreateViewModel(self, viewmodelRef)
                        constructingWeapon = nil
                        return result
                    end
                end
                
                local viewModelModule = ClientItem and ClientItem:FindFirstChild("ClientViewModel")
                if viewModelModule then
                    local ClientViewModel = safeRequire(viewModelModule)
                    if ClientViewModel then
                        if ClientViewModel.GetWrap then
                            local originalGetWrapFunc = ClientViewModel.GetWrap
                            ClientViewModel.GetWrap = function(self)
                                local weaponName = self.ClientItem and self.ClientItem.Name
                                local weaponPlayer = self.ClientItem and self.ClientItem.ClientFighter and self.ClientItem.ClientFighter.Player
                                if weaponName and weaponPlayer == player and equipped[weaponName] and equipped[weaponName].Wrap then
                                    return equipped[weaponName].Wrap
                                end
                                return originalGetWrapFunc(self)
                            end
                        end
                        
                        if ClientViewModel.GetCharm then
                            local originalGetCharmFunc = ClientViewModel.GetCharm
                            ClientViewModel.GetCharm = function(self)
                                local weaponName = self.ClientItem and self.ClientItem.Name
                                local weaponPlayer = self.ClientItem and self.ClientItem.ClientFighter and self.ClientItem.ClientFighter.Player
                                if weaponName and weaponPlayer == player and equipped[weaponName] and equipped[weaponName].Charm then
                                    return equipped[weaponName].Charm
                                end
                                return originalGetCharmFunc(self)
                            end
                        end
                        
                        local originalNew = ClientViewModel.new
                        ClientViewModel.new = function(replicatedData, clientItem)
                            if not clientItem then return originalNew(replicatedData, clientItem) end
                            local weaponPlayer = clientItem.ClientFighter and clientItem.ClientFighter.Player
                            local weaponName = constructingWeapon or clientItem.Name
                            if weaponPlayer == player and equipped[weaponName] then
                                local ReplicatedClass = safeRequire(safeWait(ReplicatedStorage.Modules, "ReplicatedClass", 10))
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
                
                local originalGetViewModelImage = ItemLibrary.GetViewModelImageFromWeaponData
                ItemLibrary.GetViewModelImageFromWeaponData = function(self, weaponData, highRes)
                    if not weaponData then return originalGetViewModelImage(self, weaponData, highRes) end
                    local weaponName = weaponData.Name
                    local shouldShowSkin = (weaponData.Skin and equipped[weaponName] and weaponData.Skin == equipped[weaponName].Skin) or (viewingProfile == player and equipped[weaponName] and equipped[weaponName].Skin)
                    if shouldShowSkin and equipped[weaponName] and equipped[weaponName].Skin then
                        local skinInfo = self.ViewModels[equipped[weaponName].Skin.Name]
                        if skinInfo then return skinInfo[highRes and "ImageHighResolution" or "Image"] or skinInfo.Image end
                    end
                    return originalGetViewModelImage(self, weaponData, highRes)
                end
                
                local EmoteController = safeRequire(safeWait(controllers, "EmoteController", 10))
                if EmoteController and EmoteController.GetEmotes then
                    local originalGetEmotes = EmoteController.GetEmotes
                    EmoteController.GetEmotes = function(self)
                        local emotes = originalGetEmotes(self)
                        for name, cosmetic in pairs(CosmeticLibrary.Cosmetics) do
                            if isValidCosmetic(name) and (cosmetic.Type == "Dance" or cosmetic.Type == "Emote") then
                                if not emotes[name] then
                                    emotes[name] = {
                                        Name = name, Type = cosmetic.Type,
                                        ObjectID = cosmetic.ObjectID, Enum = cosmetic.Enum
                                    }
                                end
                            end
                        end
                        return emotes
                    end
                end
                
                local ViewProfile = safeRequire(safeWait(safeWait(playerScripts, "Modules", 10), "Pages", 10) and safeWait(playerScripts.Modules.Pages, "ViewProfile", 10))
                if ViewProfile and ViewProfile.Fetch then
                    local originalFetch = ViewProfile.Fetch
                    ViewProfile.Fetch = function(self, targetPlayer)
                        viewingProfile = targetPlayer
                        return originalFetch(self, targetPlayer)
                    end
                end
                
                loadConfig()
                Library:Notify("Unlock All successfully loaded! (No Lag)")
            end)

            if not success then
                Library:Notify("Error loading Unlock All: " .. tostring(err))
                warn("UnlockAll Error:", err)
            end
        end)
    end
})

-- 기존 UI 요소들 유지
LeftGroupBox:AddToggle("MyToggle", {
    Text = "This is a toggle",
    Tooltip = "This is a tooltip", 
    DisabledTooltip = "I am disabled!", 
    Default = true, 
    Disabled = false, 
    Visible = true, 
    Risky = false, 
    Callback = function(Value)
        print("[cb] MyToggle changed to:", Value)
    end
}):AddColorPicker("ColorPicker1", {
    Default = Color3.new(1, 0, 0),
    Title = "Some color1", 
    Transparency = 0, 
    Callback = function(Value, Transparency)
        print("[cb] Color changed!", Value, "| Transparency changed to:", Transparency)
    end
}):AddColorPicker("ColorPicker2", {
    Default = Color3.new(0, 1, 0),
    Title = "Some color2",
    Transparency = 0,
    Callback = function(Value, Transparency)
        print("[cb] Color changed!", Value, "| Transparency changed to:", Transparency)
    end
}):AddColorPicker("ColorPicker3", {
    Default = Color3.new(0, 0, 1),
    Title = "Some color3",
    Transparency = 0,
    Callback = function(Value, Transparency)
        print("[cb] Color changed!", Value, "| Transparency changed to:", Transparency)
    end
})

Toggles.MyToggle:OnChanged(function()
    print("MyToggle changed to:", Toggles.MyToggle.Value)
end)

Toggles.MyToggle:SetValue(false)

local MyButton = LeftGroupBox:AddButton({
    Text = "Button",
    Func = function()
        print("You clicked a button!")
        Library:Notify("This is a notification")
    end,
    DoubleClick = false,
    Tooltip = "This is the main button",
    DisabledTooltip = "I am disabled!",
    Disabled = false, 
    Visible = true 
})

local MyButton2 = MyButton:AddButton({
    Text = "Sub button",
    Func = function()
        print("You clicked a sub button!")
        Library:Notify("This is a notification with sound", nil, 4590657391)
    end,
    DoubleClick = true, 
    Tooltip = "This is the sub button (double click me!)"
})

local MyDisabledButton = LeftGroupBox:AddButton({
    Text = "Disabled Button",
    Func = function()
        print("You somehow clicked a disabled button!")
    end,
    DoubleClick = false,
    Tooltip = "This is a disabled button",
    DisabledTooltip = "I am disabled!", 
    Disabled = true
})

LeftGroupBox:AddLabel("This is a label")
LeftGroupBox:AddLabel("This is a label\n\nwhich wraps its text!", true)
LeftGroupBox:AddLabel("This is a label exposed to Labels", true, "TestLabel")
LeftGroupBox:AddLabel("SecondTestLabel", {
    Text = "This is a label made with table options and an index",
    DoesWrap = true 
})

LeftGroupBox:AddLabel("SecondTestLabel", {
    Text = "This is a label that doesn\"t wrap it\"s own text",
    DoesWrap = false 
})

LeftGroupBox:AddDivider()

LeftGroupBox:AddSlider("MySlider", {
    Text = "This is my slider!",
    Default = 0,
    Min = 0,
    Max = 5,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        print("[cb] MySlider was changed! New value:", Value)
    end,
    Tooltip = "I am a slider!", 
    DisabledTooltip = "I am disabled!", 
    Disabled = false, 
    Visible = true, 
})

local Number = Options.MySlider.Value
Options.MySlider:OnChanged(function()
    print("MySlider was changed! New value:", Options.MySlider.Value)
end)

Options.MySlider:SetValue(3)

LeftGroupBox:AddSlider("MySlider2", {
    Text = "This is my custom display slider!",
    Default = 0,
    Min = 0,
    Max = 5,
    Rounding = 1,
    Compact = false,
    FormatDisplayValue = function(slider, value)
        if value == slider.Max then return "Everything" end
        if value == slider.Min then return "Nothing" end
    end,
    Tooltip = "I am a slider!", 
    DisabledTooltip = "I am disabled!", 
    Disabled = false, 
    Visible = true, 
})

LeftGroupBox:AddInput("MyTextbox", {
    Default = "My textbox!",
    Numeric = false, 
    Finished = false, 
    ClearTextOnFocus = true, 
    Text = "This is a textbox",
    Tooltip = "This is a tooltip", 
    Placeholder = "Placeholder text", 
    Callback = function(Value)
        print("[cb] Text updated. New text:", Value)
    end
})

Options.MyTextbox:OnChanged(function()
    print("Text updated. New text:", Options.MyTextbox.Value)
end)

local DropdownGroupBox = Tabs.Main:AddRightGroupbox("Dropdowns")

DropdownGroupBox:AddDropdown("MyDropdown", {
    Values = { "This", "is", "a", "dropdown" },
    Default = 1, 
    Multi = false, 
    Text = "A dropdown",
    Tooltip = "This is a tooltip", 
    DisabledTooltip = "I am disabled!", 
    Searchable = false, 
    Callback = function(Value)
        print("[cb] Dropdown got changed. New value:", Value)
    end,
    Disabled = false, 
    Visible = true, 
})

Options.MyDropdown:OnChanged(function()
    print("Dropdown got changed. New value:", Options.MyDropdown.Value)
end)

Options.MyDropdown:SetValue("This")

DropdownGroupBox:AddDropdown("MySearchableDropdown", {
    Values = { "This", "is", "a", "searchable", "dropdown" },
    Default = 1, 
    Multi = false, 
    Text = "A searchable dropdown",
    Tooltip = "This is a tooltip", 
    DisabledTooltip = "I am disabled!", 
    Searchable = true, 
    Callback = function(Value)
        print("[cb] Dropdown got changed. New value:", Value)
    end,
    Disabled = false, 
    Visible = true, 
})

DropdownGroupBox:AddDropdown("MyDisplayFormattedDropdown", {
    Values = { "This", "is", "a", "formatted", "dropdown" },
    Default = 1, 
    Multi = false, 
    Text = "A display formatted dropdown",
    Tooltip = "This is a tooltip", 
    DisabledTooltip = "I am disabled!", 
    FormatDisplayValue = function(Value) 
        if Value == "formatted" then
            return "display formatted" 
        end;
        return Value
    end,
    Searchable = false, 
    Callback = function(Value)
        print("[cb] Display formatted dropdown got changed. New value:", Value)
    end,
    Disabled = false, 
    Visible = true, 
})

DropdownGroupBox:AddDropdown("MyMultiDropdown", {
    Values = { "This", "is", "a", "dropdown" },
    Default = 1,
    Multi = true, 
    Text = "A multi dropdown",
    Tooltip = "This is a tooltip", 
    Callback = function(Value)
        print("[cb] Multi dropdown got changed:")
        for key, value in next, Options.MyMultiDropdown.Value do
            print(key, value) 
        end
    end
})

Options.MyMultiDropdown:SetValue({
    This = true,
    is = true,
})

DropdownGroupBox:AddDropdown("MyDisabledDropdown", {
    Values = { "This", "is", "a", "dropdown" },
    Default = 1, 
    Multi = false, 
    Text = "A disabled dropdown",
    Tooltip = "This is a tooltip", 
    DisabledTooltip = "I am disabled!", 
    Callback = function(Value)
        print("[cb] Disabled dropdown got changed. New value:", Value)
    end,
    Disabled = true, 
    Visible = true, 
})

DropdownGroupBox:AddDropdown("MyDisabledValueDropdown", {
    Values = { "This", "is", "a", "dropdown", "with", "disabled", "value" },
    DisabledValues = { "disabled" }, 
    Default = 1, 
    Multi = false, 
    Text = "A dropdown with disabled value",
    Tooltip = "This is a tooltip", 
    DisabledTooltip = "I am disabled!", 
    Callback = function(Value)
        print("[cb] Dropdown with disabled value got changed. New value:", Value)
    end,
    Disabled = false, 
    Visible = true, 
})

DropdownGroupBox:AddDropdown("MyVeryLongDropdown", {
    Values = { "This", "is", "a", "very", "long", "dropdown", "with", "a", "lot", "of", "values", "but", "you", "can", "see", "more", "than", "8", "values" },
    Default = 1, 
    Multi = false, 
    MaxVisibleDropdownItems = 12, 
    Text = "A very long dropdown",
    Tooltip = "This is a tooltip", 
    DisabledTooltip = "I am disabled!", 
    Searchable = false, 
    Callback = function(Value)
        print("[cb] Very long dropdown got changed. New value:", Value)
    end,
    Disabled = false, 
    Visible = true, 
})

DropdownGroupBox:AddDropdown("MyPlayerDropdown", {
    SpecialType = "Player",
    ExcludeLocalPlayer = true, 
    Text = "A player dropdown",
    Tooltip = "This is a tooltip", 
    Callback = function(Value)
        print("[cb] Player dropdown got changed:", Value)
    end
})

DropdownGroupBox:AddDropdown("MyTeamDropdown", {
    SpecialType = "Team",
    Text = "A team dropdown",
    Tooltip = "This is a tooltip", 
    Callback = function(Value)
        print("[cb] Team dropdown got changed:", Value)
    end
})

LeftGroupBox:AddLabel("Color"):AddColorPicker("ColorPicker", {
    Default = Color3.new(0, 1, 0), 
    Title = "Some color", 
    Transparency = 0, 
    Callback = function(Value)
        print("[cb] Color changed!", Value)
    end
})

Options.ColorPicker:OnChanged(function()
    print("Color changed!", Options.ColorPicker.Value)
    print("Transparency changed!", Options.ColorPicker.Transparency)
end)

Options.ColorPicker:SetValueRGB(Color3.fromRGB(0, 255, 140))

LeftGroupBox:AddLabel("Keybind"):AddKeyPicker("KeyPicker", {
    Default = "MB2", 
    SyncToggleState = false,
    Mode = "Toggle", 
    Text = "Auto lockpick safes", 
    NoUI = false, 
    Callback = function(Value)
        print("[cb] Keybind clicked!", Value)
    end,
    ChangedCallback = function(NewKey, NewModifiers)
        print("[cb] Keybind changed!", NewKey, table.unpack(NewModifiers or {}))
    end,
})

Options.KeyPicker:OnClick(function()
    print("Keybind clicked!", Options.KeyPicker:GetState())
end)

Options.KeyPicker:OnChanged(function()
    print("Keybind changed!", Options.KeyPicker.Value, table.unpack(Options.KeyPicker.Modifiers or {}))
end)

task.spawn(function()
    while task.wait(1) do
        local state = Options.KeyPicker:GetState()
        if state then
            print("KeyPicker is being held down")
        end
        if Library.Unloaded then break end
    end
end)

Options.KeyPicker:SetValue({ "MB2", "Hold" }) 

local KeybindNumber = 0

LeftGroupBox:AddLabel("Press Keybind"):AddKeyPicker("KeyPicker2", {
    Default = "X", 
    Mode = "Press",
    WaitForCallback = false, 
    Text = "Increase Number", 
    Callback = function()
        KeybindNumber = KeybindNumber + 1
        print("[cb] Keybind clicked! Number increased to:", KeybindNumber)
    end
})

LeftGroupBox:AddLabel("Dropdown"):AddDropdown("MyDropdown", {
    Values = { "Addon", "Dropdown" },
    Default = 1, 
    Multi = false, 
    Tooltip = "This is a tooltip", 
    DisabledTooltip = "I am disabled!", 
    Searchable = false, 
    Callback = function(Value)
        print("[cb] Dropdown got changed. New value:", Value)
    end,
    Disabled = false, 
    Visible = true, 
})

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

Depbox:SetupDependencies({
    { Toggles.ControlToggle, true } 
});

SubDepbox:SetupDependencies({
    { Toggles.DepboxToggle, true }
});

SecretDepbox:SetupDependencies({
    { Options.DepboxDropdown, "ĉ"} 
})

Library:SetWatermarkVisibility(true)

local FrameTimer = tick()
local FrameCounter = 0;
local FPS = 60;
local GetPing = (function() return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end)
local CanDoPing = pcall(function() return GetPing(); end)

local WatermarkConnection = game:GetService("RunService").RenderStepped:Connect(function()
    FrameCounter += 1;

    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter;
        FrameTimer = tick();
        FrameCounter = 0;
    end;

    if CanDoPing then
        Library:SetWatermark(("LinoriaLib demo | %d fps | %d ms"):format(
            math.floor(FPS),
            GetPing()
        ));
    else
        Library:SetWatermark(("LinoriaLib demo | %d fps"):format(
            math.floor(FPS)
        ));
    end
end);

Library:OnUnload(function()
    WatermarkConnection:Disconnect()

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
