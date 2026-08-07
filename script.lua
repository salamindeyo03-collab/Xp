--[[
                                               _                                 
                     __      ____ _ _ __ _ __ (_)_ __   __ _                     
                     \ \ /\ / / _` | '__| '_ \| | '_ \ / _` |                    
                      \ V  V / (_| | |  | | | | | | | | (_| |                    
                       \_/\_/ \__,_|_|  |_| |_|_|_| |_|\__, |                    
                                                       |___/                     
       this example file is missing a lot of stuff and its pretty outdated       
                i recommend using the documentation for Obsidian:                
                         https://docs.mspaint.cc/obsidian                        
                                                                                 
               a lot of stuff is very similar but it's not the same              
                 you can look through the source code of Linoria                 
                                                                                 
                 if anyone wants to expand on this example script                
                        make an pull request or something                        
                                                                                 
                        Original example (mady by wally):                        
       https://github.com/violin-suzutsuki/LinoriaLib/blob/main/Example.lua                
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

local LeftGroupBox = Tabs.Main:AddLeftGroupbox("Groupbox")

-- ==========================================
-- UNLOCK ALL 기능 추가 부분
-- ==========================================
local UnlockGroupBox = Tabs.Main:AddRightGroupbox("Unlock All")

local unlockAllExecuted = false

UnlockGroupBox:AddButton({
    Text = "Unlock All Cosmetics",
    Tooltip = "Bypasses anti-cheat and unlocks all cosmetics/skins.",
    Func = function()
        if unlockAllExecuted then
            Library:Notify("Unlock All has already been executed!")
            return
        end
        unlockAllExecuted = true
        Library:Notify("Running Unlock All script... Please wait.")

        -- UnlockAll.lua 스크립트 비동기 실행
        task.spawn(function()
            local plrs = game:GetService("Players")
            local rf = game:GetService("ReplicatedFirst")
            local lp = plrs.LocalPlayer

            print("bypass started")

            -- Fake ClientAlert RemoteEvent the game tries to use upon loading
            local fake = Instance.new("RemoteEvent")
            fake.Name = "ClientAlert"
            fake.Parent = lp

            -- Spoof WaitForChild("ClientAlert") which the result from the LoadingScreen wanted to get
            local pmt = getrawmetatable(lp)
            local oldnc = pmt.__namecall
            setreadonly(pmt, false)
            pmt.__namecall = newcclosure(function(self, ...)
                if getnamecallmethod() == "WaitForChild" and select(1, ...) == "ClientAlert" then
                    return fake
                end
                return oldnc(self, ...)
            end)
            setreadonly(pmt, true)

            -- Block :Kick and ClientAlert:FireServer in case it gets used
            local mt = getrawmetatable(game)
            local old = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                local m = getnamecallmethod()

                if self == lp and (m == "Kick" or m == "kick") then return end
                if m:lower():find("kick") or m == "Shutdown" then return end
                if m == "FireServer" and self == fake then
                    return
                end
                return old(self, ...)
            end)
            setreadonly(mt, true)

            -- Neutered anti-cheat functions in LoadingScreen and LocalScript3
            local ls3 = rf:WaitForChild("LocalScript3", 10)
            local c = 0
            for _, f in getgc(false) do
                if typeof(f) == "function" then
                    local ok, e = pcall(getfenv, f)
                    if ok and e then
                        local scr = rawget(e, "script")
                        if scr and (scr == ls3 or tostring(scr):find("LoadingScreen")) then
                            local ok2, cs = pcall(debug.getconstants, f)
                            if ok2 then
                                for _, k in cs do
                                    if typeof(k) == "string" and (k:find("TakeTheL") or k:find("ban") or k:find("kick")) then 
                                        hookfunction(f, function() end)
                                        c = c + 1
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end

            -- stupid unlock all below --
            local Players = game:GetService("Players")
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local HttpService = game:GetService("HttpService")
            local player = Players.LocalPlayer
            local playerScripts = player.PlayerScripts
            local controllers = playerScripts.Controllers
            local EnumLibrary = require(ReplicatedStorage.Modules:WaitForChild("EnumLibrary", 10))
            if EnumLibrary then EnumLibrary:WaitForEnumBuilder() end
            local CosmeticLibrary = require(ReplicatedStorage.Modules:WaitForChild("CosmeticLibrary", 10))
            local ItemLibrary = require(ReplicatedStorage.Modules:WaitForChild("ItemLibrary", 10))
            local DataController = require(controllers:WaitForChild("PlayerDataController", 10))
            local equipped, favorites = {}, {}
            local constructingWeapon, viewingProfile = nil, nil
            local lastUsedWeapon = nil
            
            local function cloneCosmetic(name, cosmeticType, options)
                local base = CosmeticLibrary.Cosmetics[name]
                if not base then return nil end
                local data = {}
                for key, value in pairs(base) do data[key] = value end
                data.Name = name
                data.Type = data.Type or cosmeticType
                data.Seed = data.Seed or math.random(1, 1000000)
                if EnumLibrary then
                    local success, enumId = pcall(EnumLibrary.ToEnum, EnumLibrary, name)
                    if success and enumId then data.Enum, data.ObjectID = enumId, data.ObjectID or enumId end
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
            
            CosmeticLibrary.OwnsCosmeticNormally = function() return true end
            CosmeticLibrary.OwnsCosmeticUniversally = function() return true end
            CosmeticLibrary.OwnsCosmeticForWeapon = function() return true end
            local originalOwnsCosmetic = CosmeticLibrary.OwnsCosmetic
            CosmeticLibrary.OwnsCosmetic = function(self, inventory, name, weapon)
                if name:find("MISSING_") then return originalOwnsCosmetic(self, inventory, name, weapon) end
                return true
            end
            
            local originalGet = DataController.Get
            DataController.Get = function(self, key)
                local data = originalGet(self, key)
                if key == "CosmeticInventory" then
                    local proxy = {}
                    if data then for k, v in pairs(data) do proxy[k] = v end end
                    return setmetatable(proxy, {__index = function() return true end})
                end
                if key == "FavoritedCosmetics" then
                    local result = data and table.clone(data) or {}
                    for weapon, favs in pairs(favorites) do
                        result[weapon] = result[weapon] or {}
                        for name, isFav in pairs(favs) do result[weapon][name] = isFav end
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
                    for cosmeticType, cosmeticData in pairs(equipped[weaponName]) do merged[cosmeticType] = cosmeticData end
                end
                return merged
            end
            
            local FighterController
            pcall(function() FighterController = require(controllers:WaitForChild("FighterController", 10)) end)
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
                                            if item:Get("ObjectID") == objectID then
                                                lastUsedWeapon = item.Name
                                                break
                                            end
                                        end
                                    end
                                end)
                            end
                        end            
                        if self == equipRemote then
                            local weaponName, cosmeticType, cosmeticName, options = args[1], args[2], args[3], args[4] or {}                
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
                        if self == favoriteRemote then
                            favorites[args[1]] = favorites[args[1]] or {}
                            favorites[args[1]][args[2]] = args[3] or nil
                            saveConfig()
                            task.spawn(function() pcall(function() DataController.CurrentData:Replicate("FavoritedCosmetics") end) end)
                            return
                        end            
                        return oldNamecall(self, ...)
                    end)
                end
            end
            
            local ClientItem
            pcall(function() ClientItem = require(player.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem) end)
            if ClientItem and ClientItem._CreateViewModel then
                local originalCreateViewModel = ClientItem._CreateViewModel
                ClientItem._CreateViewModel = function(self, viewmodelRef)
                    local weaponName = self.Name
                    local weaponPlayer = self.ClientFighter and self.ClientFighter.Player
                    constructingWeapon = (weaponPlayer == player) and weaponName or nil    
                    if weaponPlayer == player and equipped[weaponName] and equipped[weaponName].Skin and viewmodelRef then
                        local dataKey, skinKey, nameKey = self:ToEnum("Data"), self:ToEnum("Skin"), self:ToEnum("Name")
                        if viewmodelRef[dataKey] then
                            viewmodelRef[dataKey][skinKey] = equipped[weaponName].Skin
                            viewmodelRef[dataKey][nameKey] = equipped[weaponName].Skin.Name
                        elseif viewmodelRef.Data then
                            viewmodelRef.Data.Skin = equipped[weaponName].Skin
                            viewmodelRef.Data.Name = equipped[weaponName].Skin.Name
                        end
                    end
                    local result = originalCreateViewModel(self, viewmodelRef)
                    constructingWeapon = nil
                    return result
                end
            end
            
            local viewModelModule = player.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem:FindFirstChild("ClientViewModel")
            if viewModelModule then
                local ClientViewModel = require(viewModelModule)
                if ClientViewModel.GetWrap then
                    local originalGetWrap = ClientViewModel.GetWrap
                    ClientViewModel.GetWrap = function(self)
                        local weaponName = self.ClientItem and self.ClientItem.Name
                        local weaponPlayer = self.ClientItem and self.ClientItem.ClientFighter and self.ClientItem.ClientFighter.Player
                        if weaponName and weaponPlayer == player and equipped[weaponName] and equipped[weaponName].Wrap then
                            return equipped[weaponName].Wrap
                        end
                        return originalGetWrap(self)
                    end
                end
                local originalNew = ClientViewModel.new
                ClientViewModel.new = function(replicatedData, clientItem)
                    local weaponPlayer = clientItem.ClientFighter and clientItem.ClientFighter.Player
                    local weaponName = constructingWeapon or clientItem.Name
                    if weaponPlayer == player and equipped[weaponName] then
                        local ReplicatedClass = require(ReplicatedStorage.Modules.ReplicatedClass)
                        local dataKey = ReplicatedClass:ToEnum("Data")
                        replicatedData[dataKey] = replicatedData[dataKey] or {}
                        local cosmetics = equipped[weaponName]
                        if cosmetics.Skin then replicatedData[dataKey][ReplicatedClass:ToEnum("Skin")] = cosmetics.Skin end
                        if cosmetics.Wrap then replicatedData[dataKey][ReplicatedClass:ToEnum("Wrap")] = cosmetics.Wrap end
                        if cosmetics.Charm then replicatedData[dataKey][ReplicatedClass:ToEnum("Charm")] = cosmetics.Charm end
                    end
                    local result = originalNew(replicatedData, clientItem)
                    if weaponPlayer == player and equipped[weaponName] and equipped[weaponName].Wrap and result._UpdateWrap then
                        result:_UpdateWrap()
                        task.delay(0.1, function() if not result._destroyed then result:_UpdateWrap() end end)
                    end
                    return result
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
            
            pcall(function()
                local ViewProfile = require(player.PlayerScripts.Modules.Pages.ViewProfile)
                if ViewProfile and ViewProfile.Fetch then
                    local originalFetch = ViewProfile.Fetch
                    ViewProfile.Fetch = function(self, targetPlayer)
                        viewingProfile = targetPlayer
                        return originalFetch(self, targetPlayer)
                    end
                end
            end)
            
            local ClientEntity
            pcall(function() ClientEntity = require(player.PlayerScripts.Modules.ClientReplicatedClasses.ClientEntity) end)
            if ClientEntity and ClientEntity.ReplicateFromServer then
                local originalReplicateFromServer = ClientEntity.ReplicateFromServer
                ClientEntity.ReplicateFromServer = function(self, action, ...)
                    if action == "FinisherEffect" then
                        local args = {...}
                        local killerName = args[3]            
                        local decodedKiller = killerName
                        if type(killerName) == "userdata" and EnumLibrary and EnumLibrary.FromEnum then
                            local ok, decoded = pcall(EnumLibrary.FromEnum, EnumLibrary, killerName)
                            if ok and decoded then decodedKiller = decoded end
                        end            
                        local isOurKill = tostring(decodedKiller) == player.Name or tostring(decodedKiller):lower() == player.Name:lower()            
                        if isOurKill and lastUsedWeapon and equipped[lastUsedWeapon] and equipped[lastUsedWeapon].Finisher then
                            local finisherData = equipped[lastUsedWeapon].Finisher
                            local finisherEnum = finisherData.Enum                
                            if not finisherEnum and EnumLibrary then
                                local ok, result = pcall(EnumLibrary.ToEnum, EnumLibrary, finisherData.Name)
                                if ok and result then finisherEnum = result end
                            end                
                            if finisherEnum then
                                args[1] = finisherEnum
                                return originalReplicateFromServer(self, action, unpack(args))
                            end
                        end
                    end        
                    return originalReplicateFromServer(self, action, ...)
                end
            end
            
            loadConfig()
            
            Library:Notify("Unlock All successfully loaded!")
        end)
    end
})
-- ==========================================

-- 기존 UI 요소들 (그대로 유지)
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
