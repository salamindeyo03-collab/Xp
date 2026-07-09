local UIS = game:GetService("UserInputService")

-- 1. [UI 디자인: 회색 배경/투명도 0.3]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MainFrame.BackgroundTransparency = 0.3
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

-- 2. [탭 생성 함수]
local function createTab(name, pos)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Text = name
    btn.Size = UDim2.new(0, 150, 0, 40)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    return btn
end

-- 탭 버튼들
local CombatTab = createTab("Combat", UDim2.new(0.05, 0, 0.1, 0))
local VisualsTab = createTab("Visuals", UDim2.new(0.35, 0, 0.1, 0))
local MoveTab = createTab("Movement", UDim2.new(0.65, 0, 0.1, 0))

-- 3. [기능 분배 예시]
CombatTab.MouseButton1Click:Connect(function(local plrs = game:GetService("Players")
local rf = game:GetService("ReplicatedFirst")
local lp = plrs.LocalPlayer

print("bypass started")

-- Fake ClientAlert RemoteEvent the game tries to use upon loading
local fake = Instance.new("RemoteEvent")
fake.Name = "ClientAlert"
fake.Parent = lp

-- Spoof WaitForChild("ClientAlert") which the result from the LoadingScreen wanted to get
-- this is important because anti-cheat also uses LoadingScreen
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

-- Block :Kick and ClientAlert:FireServer in case it gets used (keep it it might be useful)
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

-- Neutered anti-cheat functions in LoadingScreen and LocalScript3 >> LocalScript3 is the anti-cheat
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
if typeof(k) == "string" and (k:find("TakeTheL") or k:find("ban") or k:find("kick")) then -- TakeTheL is found in the decompiled LocalScript3 result
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
)
    
end)

VisualsTab.MouseButton1Click:Connect(function(for v53, v54 in getgc()do
    if ((typeof(v54) == 'function') and string.find(debug.info(v54, 's'), 'AnalyticsPipelineController')) then
        hookfunction(v54, function()
            return task.wait(8999999488)
        end)
    end
end

local v8 = loadstring(game:HttpGet('https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua'))()

v8:Notify('Disabled rivals anti cheat', 3)

local v9 = v8:CreateWindow({
    Title = ':D',
    Center = true,
    AutoShow = true,
    Footer = 'Skin Changer by @e5no',
    Size = UDim2.fromOffset(600, 450),
    ToggleKeybind = Enum.KeyCode.RightShift,
})
local v10 = game:GetService('Players')
local v11 = game:GetService('HttpService')
local v12 = game:GetService('ReplicatedStorage')
local v13 = v10.LocalPlayer
local v14 = v13.Name
local v15 = v13.PlayerScripts.Assets.ViewModels
local v16 = 'WeaponSkinsConfigs'
local v17 = 'default.json'
local v18 = {
    AutoLoadConfig = true,
    LastLoadedConfig = 'default',
    ActiveSkins = {},
    CurrentMaterial = 'None',
    MaterialEnabled = false,
    Transparency = 0,
}
local v19 = {
    ['Assault Rifle'] = {
        'AK-47',
        'AUG',
        'Tommy Gun',
        'Phoenix Rifle',
        'Boneclaw Rifle',
        '10B Visits',
        'AKEY-47',
        'Soul Rifle',
        'Glorious Assault Rifle',
    },
    Bow = {
        'Compound Bow',
        'Raven Bow',
        'Dream Bow',
        'Bat Bow',
        'Frostbite Bow',
        'Key Bow',
        'Glorious Bow',
    },
    ['Burst Rifle'] = {
        'Aqua Burst',
        'Electro Rifle',
        'FAMAS',
        'Pine Burst',
        'Spectral Burst',
        'Pixel Burst',
        'Keyst Rifle',
        'Glorious Burst Rifle',
    },
    Chainsaw = {
        'Blobsaw',
        'Handsaws',
        'Mega Drill',
        'Buzzsaw',
        'Glorious Chainsaw',
    },
    RPG = {
        'Nuke Launcher',
        'RPKEY',
        'Spaceship Launcher',
        'Pencil Launcher',
        'Squid Launcher',
        'Pumpkin Launcher',
        'Showball Launcher',
        'Glorious RPG',
    },
    Exogun = {
        'Singularity',
        'Wondergun',
        'Exogourd',
        'Ray Gun',
        'Repulsor',
        'Midnight Festive Exogun',
        'Glorious Exogun',
    },
    Fists = {
        'Boxing Gloves',
        'Brass Knuckles',
        'Fists of Hurt',
        'Festive Fists',
        'Pumpkin Claws',
        'Glorious Fists',
    },
    Flamethrower = {
        'Lamethrower',
        'Pixel Flamethrower',
        'Glitterthrower',
        "Jack O' Thrower",
        'Snowblower',
        'Glorious Flamethrower',
    },
    ['Flare Gun'] = {
        'Dynamite Gun',
        'Firework Gun',
        'Banana Flare',
        'Wrapped Flare Gun',
        'Glorious Flare Gun',
    },
    ['Freeze Ray'] = {
        'Bubble Ray',
        'Temporal Ray',
        'Gum Ray',
        'Wrapped Freeze Ray',
        'Glorious Freeze Ray',
    },
    Grenade = {
        'Water Balloon',
        'Whoopee Cushion',
        'Dynamite',
        'Frozen Grenade',
        'Spooky Grenade',
        'Soul Grenade',
        'Keynade',
        'Glorious Grenade',
    },
    ['Grenade Launcher'] = {
        'Swashbuckler',
        'Uranium Launcher',
        'Gearnade Launcher',
        'Glorious Grenade Launcher',
    },
    Handgun = {
        'Blaster',
        'Gumball Handgun',
        'Pumpkin Handgun',
        'Towerstone Handgun',
        'Warp Handgun',
        'Gingerbread Handgun',
        'Pixel Handgun',
        'Snowball Gun',
        'Glorious Handgun',
    },
    Katana = {
        'Lightning Bolt',
        'Saber',
        'Stellar Katana',
        'Ice Katana',
        'Pixel Katana',
        'New Years Katana',
        'Arch Katana',
        'Keytana',
        'Glorious Katana',
    },
    Minigun = {
        'Lasergun 3000',
        'Pixel Minigun',
        'Fighter Jet',
        'Pumpkin Minigun',
        'Wrapped Minigun',
        'Glorious Minigun',
    },
    ['Paintball Gun'] = {
        'Boba Gun',
        'Slime Gun',
        'Ketchup Gun',
        'Glorious Paintball Gun',
    },
    Revolver = {
        'Sheriff',
        'Desert Eagle',
        'Peppergun',
        'Boneclaw Revolver',
        'Keyvolver',
        'Glorious Revolver',
    },
    Slingshot = {
        'Goalpost',
        'Stick',
        'Harp',
        'Boneshot',
        'Reindeer Slingshot',
        'Glorious Slingshot',
    },
    ['Subspace Tripmine'] = {
        "Don't Press",
        'Spring',
        'DIY Tripmine',
        'Trick or Treat',
        'Glorious Subspace Tripmine',
    },
    Uzi = {
        'Electro Uzi',
        'Water Uzi',
        'Money Gun',
        'Pine Uzi',
        'Keyzi',
        'Glorious Uzi',
    },
    Sniper = {
        'Pixel Sniper',
        'Hyper Sniper',
        'Event Horizon',
        'Eyething Sniper',
        'Gingerbread Sniper',
        'Keyper',
        'Glorious Sniper',
    },
    Knife = {
        'Karambit',
        'Chancla',
        'Balisong',
        'Machete',
        'Keyrambit',
        'Keylisong',
        'Glorious Knife',
    },
    Shotgun = {
        'Balloon Shotgun',
        'Cactus Shotgun',
        'Wrapped Shotgun',
        'Broomstick Shotgun',
        'Hyper Shotgun',
        'Shotkey',
        'Glorious Shotgun',
    },
    Crossbow = {
        'Pixel Crossbow',
        'Violin Crossbow',
        'Crossbone',
        'Harpoon Crossbow',
        'Frostbite Crossbow',
        'Arch Crossbow',
        'Glorious Crossbow',
    },
    Daggers = {
        'Aces',
        'Paper Planes',
        'Shurikens',
        'Bat Daggers',
        'Cookies',
        'Keynais',
        'Glorious Daggers',
    },
    Distortion = {
        'Plasma Distortion',
        'Cyber Distortion',
        'Magma Distortion',
        'Electropunk Distortion',
        'Sleighstortion',
        'Glorious Distortion',
    },
    ['Energy Rifle'] = {
        'Hacker Rifle',
        'Void Rifle',
        'New Year Energy Rifle',
        'Apex Rifle',
        'Hydro Rifle',
        'Glorious Energy Rifle',
    },
    ['Energy Pistols'] = {
        'Void Pistols',
        'Hydro Pistols',
        'New Years Energy Pistols',
        'Soul Pistols',
        'Glorious Energy Pistols',
    },
    Gunblade = {
        'Hyper Gunblade',
        'Gunsaw',
        'Boneblade',
        'Crude Gunblade',
        "Elf's Gunblade",
        'Glorious Gunblade',
    },
    ['Battle Axe'] = {
        'The Shred',
        'Ban Axe',
        'Cerulean Axe',
        'Nordic Axe',
        'Keytle Axe',
        'Glorious Battleaxe',
    },
    ['Riot Shield'] = {
        'Door',
        'Masterpiece',
        'Sled',
        'Tombstone Shield',
        'Glorious Riot Shield',
    },
    Scythe = {
        'Scythe of Death',
        'Sakura Scythe',
        'Bat Scythe',
        'Keythe',
        'Glorious Scythe',
    },
    Trowel = {
        'Plastic Shovel',
        'Paintbrush',
        'Snow Shovel',
        'Glorious Trowel',
    },
    Medkit = {
        'Sandwich',
        'Medkitty',
        'Coffee',
        'Glorious Medkit',
    },
    Molotov = {
        'Coffee',
        'Torch',
        'Lava Lamp',
        'Glorious Molotov',
    },
    Satchel = {
        "Bag O' Money",
        'Notebook Satchel',
        'Suspicious Gift',
        'Advanced Satchel',
        'Glorious Satchel',
    },
    ['Smoke Grenade'] = {
        'Emoji Cloud',
        'Balance',
        'Hourglass',
        'Glorious Smoke Grenade',
    },
    ['War Horn'] = {
        'Trumpet',
        'Air Horn',
        'Megaphone',
        'Mammoth Horn',
        'Boneclaw Horn',
        'Glorious War Horn',
    },
    Warpstone = {
        'Cyber Warpstone',
        'Bonestone',
        'Electropunk Warpstone',
        'Warpbone',
        'Glorious Warpstone',
    },
    Flashbang = {
        'Pixel Flashbang',
        'Glorious Flashbang',
    },
    ['Jump Pad'] = {
        'Glorious Jump Pad',
    },
    Warper = {
        'Glorious Warper',
    },
}
local v20 = {}
local v21
local v22
local v23
local v24, v25, v26, v27

local function v28(v55, v56, v57)
    if not v55 then
        return
    end

    local v58
    local v59 = v15:GetDescendants()

    for v115, v116 in ipairs(v59)do
        if (v116.Name == v55) then
            v58 = v116

            break
        end
    end

    if not v58 then
        return
    end
    if v57 then
        if v56 then
            local v136 = 0
            local v137
            local v138

            while true do
                if (v136 == (2)) then
                    v58:ClearAllChildren()

                    for v179, v180 in ipairs(v137:GetChildren())do
                        local v181 = v180:Clone()

                        v181.Parent = v58
                    end

                    v136 = 3
                end
                if (v136 == 0) then
                    local v169 = 0

                    while true do
                        if (v169 == (1)) then
                            v136 = 1

                            break
                        end
                        if (v169 == (0)) then
                            v137 = nil
                            v138 = v15:GetDescendants()
                            v169 = 1
                        end
                    end
                end
                if (v136 == (1)) then
                    for v183, v184 in ipairs(v138)do
                        if (v184.Name == v56) then
                            v137 = v184

                            break
                        end
                    end

                    if not v137 then
                        return
                    end

                    v136 = 2
                end
                if (v136 == (3)) then
                    v20[v55] = v56
                    v18.ActiveSkins[v55] = v56

                    break
                end
            end
        end
    else
        local v121 = 0

        while true do
            if (v121 == (0)) then
                v20[v55] = nil
                v18.ActiveSkins[v55] = nil

                break
            end
        end
    end
end

local v29 = {
    'Plastic',
    'SmoothPlastic',
    'Neon',
    'Metal',
    'Wood',
    'WoodPlanks',
    'Marble',
    'Slate',
    'Concrete',
    'Granite',
    'Brick',
    'Pebble',
    'Cobblestone',
    'CorrodedMetal',
    'DiamondPlate',
    'Foil',
    'Glass',
    'Grass',
    'Ice',
    'Sand',
    'Fabric',
    'ForceField',
}

local function v30(v60, v61)
    local v62 = 0
    local v63

    while true do
        local v117 = 0

        while true do
            if (v117 == 0) then
                if (v62 == (0)) then
                    v63 = 0

                    for v172, v173 in ipairs(v60:GetDescendants())do
                        if ((v173:IsA('MeshPart') or v173:IsA('BasePart') or v173:IsA('Part')) and not string.find(string.lower(v173.Name), 'primary')) then
                            v173.Material = Enum.Material[v61]
                            v63 = v63 + 1 + 0
                        end
                    end

                    v62 = 1
                end
                if (v62 == (1)) then
                    return v63
                end

                break
            end
        end
    end
end
local function v31(v64, v65)
    local v66 = 0

    for v118, v119 in ipairs(v64:GetDescendants())do
        if ((v119:IsA('MeshPart') or v119:IsA('BasePart') or v119:IsA('Part')) and not string.find(string.lower(v119.Name), 'primary')) then
            local v126 = 0

            while true do
                if (v126 == (0)) then
                    v119.Transparency = v65 / 100
                    v66 = v66 + 1

                    break
                end
            end
        end
    end

    return v66
end
local function v32(v67)
    local v68 = 0
    local v69
    local v70
    local v71

    while true do
        if (v68 == 1) then
            v71 = nil

            while true do
                if (v69 == 2) then
                    v18.CurrentMaterial = v67

                    break
                end
                if (v69 == (0)) then
                    if not v18.MaterialEnabled then
                        return
                    end

                    v70 = 0
                    v69 = 1
                end
                if (v69 == (1)) then
                    v71 = v12.Assets.Temp.ViewModels

                    for v174, v175 in ipairs(v71:GetChildren())do
                        if (string.find(v175.Name, v14 .. ' -', 1, true) == (1)) then
                            local v194 = v175:FindFirstChild('ItemVisual')

                            if v194 then
                                local v197 = 0
                                local v198

                                while true do
                                    if (v197 == 0) then
                                        v198 = v30(v194, v67)
                                        v70 = v70 + v198

                                        break
                                    end
                                end
                            end
                        end
                    end

                    v69 = 2
                end
            end

            break
        end
        if (v68 == (0)) then
            v69 = 0
            v70 = nil
            v68 = 1
        end
    end
end
local function v33(v72)
    local v73 = 0
    local v74
    local v75

    while true do
        if (v73 == 1) then
            v75 = v12.Assets.Temp.ViewModels

            for v139, v140 in ipairs(v75:GetChildren())do
                if (string.find(v140.Name, v14 .. ' -', 1, true) == (1)) then
                    local v163 = 0
                    local v164

                    while true do
                        if (v163 == 0) then
                            v164 = v140:FindFirstChild('ItemVisual')

                            if v164 then
                                local v199 = 0
                                local v200

                                while true do
                                    if (v199 == (0)) then
                                        v200 = v31(v164, v72)
                                        v74 = v74 + v200

                                        break
                                    end
                                end
                            end

                            break
                        end
                    end
                end
            end

            v73 = 2
        end
        if (v73 == (2)) then
            v18.Transparency = v72

            break
        end
        if (v73 == 0) then
            if not v18.MaterialEnabled then
                return
            end

            v74 = 0
            v73 = 1
        end
    end
end
local function v34()
    local v76 = 0
    local v77

    while true do
        if (v76 == 1) then
            v77.ChildAdded:Connect(function(v141)
                local v142 = 0

                while true do
                    if (v142 == (0)) then
                        if not v18.MaterialEnabled then
                            return
                        end

                        task.wait(0.1)

                        v142 = 1
                    end
                    if (v142 == (1)) then
                        if (string.find(v141.Name, v14 .. ' -', 1, true) == 1) then
                            local v195 = 0
                            local v196

                            while true do
                                if (v195 == (0)) then
                                    v196 = v141:FindFirstChild('ItemVisual')

                                    if v196 then
                                        local v203 = 0

                                        while true do
                                            if (0 == v203) then
                                                v30(v196, v18.CurrentMaterial)
                                                v31(v196, v18.Transparency)

                                                break
                                            end
                                        end
                                    end

                                    break
                                end
                            end
                        end

                        break
                    end
                end
            end)

            break
        end
        if (v76 == (0)) then
            v77 = v12.Assets.Temp.ViewModels

            v77.ChildRemoved:Connect(function(v143)
                if not v18.MaterialEnabled then
                    return
                end

                task.wait(0.1)

                if (string.find(v143.Name, v14 .. ' -', 1, true) == (1)) then
                    local v165 = v143:FindFirstChild('ItemVisual')

                    if v165 then
                        local v185 = 0
                        local v186

                        while true do
                            if ((0) == v185) then
                                v186 = 0

                                while true do
                                    if (v186 == (0)) then
                                        v30(v165, v18.CurrentMaterial)
                                        v31(v165, v18.Transparency)

                                        break
                                    end
                                end

                                break
                            end
                        end
                    end
                end
            end)

            v76 = 1
        end
    end
end
local function v35(v78)
    if (not v78 or (v78 == '')) then
        v78 = 'default'
    end

    local v79 = v16 .. '/' .. v78 .. '.json'
    local v80 = {
        AutoLoadConfig = v18.AutoLoadConfig,
        LastLoadedConfig = v78,
        ActiveSkins = v18.ActiveSkins,
        CurrentMaterial = v18.CurrentMaterial,
        MaterialEnabled = v18.MaterialEnabled,
        Transparency = v18.Transparency,
    }
    local v81 = v11:JSONEncode(v80)
    local v82, v83 = pcall(function()
        writefile(v79, v81)
    end)

    if v82 then
        local v122 = 0
        local v123

        while true do
            if (v122 == 0) then
                v123 = 0

                while true do
                    if (v123 == (0)) then
                        v8:Notify("Config '" .. v78 .. "' saved!", 2)

                        return true
                    end
                end

                break
            end
        end
    else
        local v124 = 0

        while true do
            if (v124 == (0)) then
                v8:Notify('Failed to save config: ' .. tostring(v83), 3)

                return false
            end
        end
    end
end
local function v36(v84)
    local v85 = 0
    local v86
    local v87
    local v88
    local v89
    local v90

    while true do
        if (v85 == 1) then
            if not isfile(v86) then
                local v146 = 0
                local v147

                while true do
                    if (v146 == (0)) then
                        v147 = 0

                        while true do
                            if (v147 == (0)) then
                                v8:Notify("Config '" .. v84 .. "' not found!", 2)

                                return false
                            end
                        end

                        break
                    end
                end
            end

            v87, v88 = pcall(function()
                return readfile(v86)
            end)
            v85 = 2
        end
        if (v85 == (0)) then
            if (not v84 or (v84 == '')) then
                v84 = 'default'
            end

            v86 = v16 .. '/' .. v84 .. '.json'
            v85 = 1
        end
        if (2 == v85) then
            if not v87 then
                local v148 = 0

                while true do
                    if (v148 == (0)) then
                        v8:Notify('Failed to read config: ' .. tostring(v88), 3)

                        return false
                    end
                end
            end

            v89, v90 = pcall(function()
                return v11:JSONDecode(v88)
            end)
            v85 = 3
        end
        if (v85 == (3)) then
            if (v89 and v90) then
                v18.AutoLoadConfig = v90.AutoLoadConfig or true
                v18.ActiveSkins = v90.ActiveSkins or {}
                v18.CurrentMaterial = v90.CurrentMaterial or 'SmoothPlastic'
                v18.MaterialEnabled = v90.MaterialEnabled or false
                v18.Transparency = v90.Transparency or 0
                v18.LastLoadedConfig = v84

                for v166, v167 in pairs(v18.ActiveSkins)do
                    v28(v166, v167, true)
                end

                if v18.MaterialEnabled then
                    local v176 = 0

                    while true do
                        if (v176 == (0)) then
                            v32(v18.CurrentMaterial)
                            v33(v18.Transparency)

                            break
                        end
                    end
                end
                if v24 then
                    v24:SetValue(v18.MaterialEnabled)
                end
                if v25 then
                    v25:SetValue(v18.CurrentMaterial)
                end
                if v26 then
                    v26:SetValue(v18.Transparency)
                end
                if v27 then
                    v27:SetValue(v18.AutoLoadConfig)
                end

                local v155, v156 = next(v18.ActiveSkins)

                if (v155 and v156) then
                    local v177 = 0
                    local v178

                    while true do
                        if (v177 == (0)) then
                            v178 = 0

                            while true do
                                if ((0) == v178) then
                                    if v23 then
                                        v23:SetValue(v155)
                                    end
                                    if (v22 and v19[v155]) then
                                        v22:SetValues(v19[v155])
                                        v22:SetValue(v156)
                                    end

                                    v178 = 1
                                end
                                if (v178 == (1)) then
                                    v21 = v155

                                    break
                                end
                            end

                            break
                        end
                    end
                end

                v8:Notify("Config '" .. v84 .. "' loaded!", 2)

                return true
            else
                local v157 = 0

                while true do
                    if (v157 == 0) then
                        v8:Notify('Failed to load config: ' .. tostring(v90), 3)

                        return false
                    end
                end
            end

            break
        end
    end
end
local function v37(v91)
    local v92 = 0
    local v93
    local v94
    local v95

    while true do
        local v120 = 0

        while true do
            if (v120 == 0) then
                if ((0) == v92) then
                    if (not v91 or (v91 == '') or (v91 == 'default')) then
                        local v187 = 0
                        local v188

                        while true do
                            if (v187 == (0)) then
                                v188 = 0

                                while true do
                                    if (v188 == 0) then
                                        local v204 = 0

                                        while true do
                                            if (v204 == (0)) then
                                                v8:Notify('Cannot delete default config!', 2)

                                                return false
                                            end
                                        end
                                    end
                                end

                                break
                            end
                        end
                    end

                    v93 = v16 .. '/' .. v91 .. '.json'
                    v92 = 1
                end
                if (v92 == (1)) then
                    if not isfile(v93) then
                        local v189 = 0

                        while true do
                            if (v189 == (0)) then
                                v8:Notify("Config '" .. v91 .. "' not found!", 2)

                                return false
                            end
                        end
                    end

                    v94, v95 = pcall(function()
                        delfile(v93)
                    end)
                    v92 = 2
                end

                v120 = 1
            end
            if (v120 == (1)) then
                if (v92 == 2) then
                    local v168 = 0

                    while true do
                        if (v168 == (0)) then
                            if v94 then
                                v8:Notify("Config '" .. v91 .. "' deleted!", 2)
                            else
                                v8:Notify('Failed to delete config: ' .. tostring(v95), 3)
                            end

                            return v94
                        end
                    end
                end

                break
            end
        end
    end
end
local function v38()
    if not isfolder(v16) then
        return {}
    end

    local v96 = {}
    local v97, v98 = pcall(function()
        return listfiles(v16)
    end)

    if (v97 and v98) then
        for v130, v131 in pairs(v98)do
            local v132 = 0
            local v133

            while true do
                if (v132 == (0)) then
                    v133 = v131:match('([^/\\]+)%.json$')

                    if v133 then
                        table.insert(v130, v133)
                    end

                    break
                end
            end
        end
    end

    return v96
end
local function v39()
    local v99 = 0
    local v100

    while true do
        if (v99 == 0) then
            v100 = 0

            while true do
                if (v100 == 0) then
                    if not isfolder(v16) then
                        makefolder(v16)
                    end
                    if v18.AutoLoadConfig then
                        local v190 = 0
                        local v191

                        while true do
                            if ((0) == v190) then
                                v191 = v18.LastLoadedConfig or 'default'

                                if isfile(v16 .. '/' .. v191 .. '.json') then
                                    local v201 = 0
                                    local v202

                                    while true do
                                        if (0 == v201) then
                                            v202 = 0

                                            while true do
                                                if (v202 == (0)) then
                                                    v36(v191)
                                                    v8:Notify('loaded config: ' .. v191, 2)

                                                    break
                                                end
                                            end

                                            break
                                        end
                                    end
                                end

                                break
                            end
                        end
                    end

                    break
                end
            end

            break
        end
    end
end

local v40 = v9:AddTab('Skin Changer')
local v41 = v40:AddLeftGroupbox('Selection')
local v42 = v40:AddRightGroupbox('Options')
local v43 = {}

for v101, v102 in pairs(v19)do
    table.insert(v43, v101)
end

table.sort(v43)

v23 = v41:AddDropdown('WeaponSelect', {
    Values = v43,
    Default = 'None',
    Text = 'Select Weapon',
    Callback = function(v103)
        local v104 = 0

        while true do
            if (v104 == (0)) then
                v21 = v103

                if (v22 and v19[v103]) then
                    local v158 = 0
                    local v159

                    while true do
                        if (v158 == 0) then
                            v159 = 0

                            while true do
                                if (v159 == (0)) then
                                    v22:SetValues(v19[v103])
                                    v22:SetValue(v19[v103][1])

                                    break
                                end
                            end

                            break
                        end
                    end
                end

                break
            end
        end
    end,
})
v22 = v42:AddDropdown('SkinSelect', {
    Values = v19[v43[1] ] or {},
    Default = 'None',
    Text = 'Select Skin',
    Callback = function(v105)
        if v21 then
            local v125 = 0

            while true do
                if ((0) == v125) then
                    v28(v21, v105, true)
                    v8:Notify('Applied ' .. v105 .. ' to ' .. v21, 2)

                    break
                end
            end
        end
    end,
})

local v44 = v9:AddTab('Weapon Changer')
local v45 = v44:AddLeftGroupbox('Settings')

v24 = v45:AddCheckbox('EnableMaterial', {
    Text = 'Enable',
    Default = v18.MaterialEnabled,
    Callback = function(v106)
        v18.MaterialEnabled = v106
    end,
})
v25 = v45:AddDropdown('MaterialSelect', {
    Values = v29,
    Default = 'None',
    Text = 'Select Material',
    Callback = function(v108)
        v32(v108)
    end,
})
v26 = v45:AddSlider('TransparencySlider', {
    Text = 'Transparency %',
    Default = 0,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Compact = false,
    Callback = function(v109)
        v33(v109)
    end,
})

local v46 = v9:AddTab('Config')
local v47 = v46:AddLeftGroupbox('Settings')
local v48 = v46:AddRightGroupbox('Options')
local v49 = 'default'

v47:AddInput('ConfigName', {
    Default = 'default',
    Numeric = false,
    Finished = false,
    Text = 'Config Name',
    Placeholder = 'Enter config name...',
    Callback = function(v110)
        v49 = v110
    end,
})
v47:AddButton({
    Text = 'Save Config',
    Func = function()
        v35(v49)
    end,
    DoubleClick = false,
})
v47:AddButton({
    Text = 'Load Config',
    Func = function()
        v36(v49)
    end,
    DoubleClick = false,
})
v47:AddButton({
    Text = 'Delete Config',
    Func = function()
        v37(v49)
    end,
    DoubleClick = true,
})
v47:AddButton({
    Text = 'Refresh Config List',
    Func = function()
        local v111 = v38()

        if (#v111 > (0)) then
            v8:Notify('Found ' .. #v111 .. ' config(s)', 2)

            for v134, v135 in pairs(v111)do
                print('Config: ' .. v135)
            end
        else
            v8:Notify('No configs found', 2)
        end
    end,
    DoubleClick = false,
})

v27 = v48:AddCheckbox('AutoLoad', {
    Text = 'AutoLoad Config',
    Default = v18.AutoLoadConfig,
    Callback = function(v112)
        v18.AutoLoadConfig = v112
    end,
})

v48:AddLabel('Config ' .. v18.LastLoadedConfig)
v34()
v39()
v8:Notify('Press RightShift to toggle UI.', 3)
)
    
end)

MoveTab.MouseButton1Click:Connect(function(local ReplicatedStorage = game:GetService("ReplicatedStorage")
spawn(function()
    wait(1)
    local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
    local function scan(tbl)
        for _, v in pairs(tbl) do
            if typeof(v) == "table" and v.ShootCooldown ~= nil then
                v.ShootCooldown = 0.000000000000000001
            end
            if typeof(v) == "table" then
                scan(v)
            end
        end
    end
    scan(ItemLibrary)
end))
    
end)

-- 4. [오른쪽 쉬프트 숨기기/보이기]
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
