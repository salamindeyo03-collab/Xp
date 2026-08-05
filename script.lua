--[[
    LinoriaLib UI + Rivals Skin Changer
    사용법: 실행 후 우측 Shift 키로 UI 열림/닫힘. UI Settings 탭에서 Save/Load 가능.
]]

local repo = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

-- ═══════════════════════════════════════════════
-- SKIN LISTS (이전 데이터 그대로 유지)
-- ═══════════════════════════════════════════════
local SkinLists = {
    ["Assault Rifle"] = {"Default", "AK-47", "AUG", "Tommy Gun", "Boneclaw Rifle", "Gingerbread AUG", "AKEY-47", "100K Visits", "10 Billion Visits", "Phoenix Rifle"},
    ["Bow"] = {"Default", "Compound Bow", "Raven Bow", "Dream Bow", "Bat Bow", "Frostbite Bow", "Beloved Bow", "Balloon Bow", "Glorious Bow", "Key Bow", "Arch Bow"},
    ["Burst Rifle"] = {"Default", "Electro Burst", "Aqua Burst", "FAMAS", "Spectral Burst", "Pine Burst"},
    ["Crossbow"] = {"Default", "Pixel Crossbow", "Harpoon Crossbow", "Violin Crossbow", "Crossbone", "Frostbite Crossbow", "Arch Crossbow", "Glorious Crossbow"},
    ["Distortion"] = {"Default", "Plasma Distortion", "Magma Distortion", "Cyber Distortion", "Expirement D15", "Sleighstortion"},
    ["Energy Rifle"] = {"Default", "Hacker Rifle", "Hydro Rifle", "Void Rifle", "Soul Rifle", "New Years Energy Rifle"},
    ["Flamethrower"] = {"Default", "Pixel Flamethrower", "Lamethrower", "Glitterthrower", "Jack O' Thrower", "Snowblower", "Keythrower", "Rainbowthrower"},
    ["Grenade Launcher"] = {"Default", "Swashbuckler", "Uranium Launcher", "Gearnade Launcher", "Skull Grenade Launcher", "Snowball Launcher"},
    ["Gunblade"] = {"Default", "Hyper Gunblade", "Crude Gunblade", "Gunsaw", "Boneblade", "Elf's Gunblade"},
    ["Minigun"] = {"Default", "Lasergun 3000", "Pixel Minigun", "Fighter Jet", "Pumpkin Minigun", "Wrapped Minigun"},
    ["Paintball Gun"] = {"Default", "Slime Gun", "Boba Gun", "Ketchup Gun", "Brain Gun", "Snowball Gun"},
    ["RPG"] = {"Default", "Nuke Launcher", "Spaceship Launcher", "Squid Launcher", "Pumpkin Launcher", "Firework Launcher"},
    ["Shotgun"] = {"Default", "Balloon Shotgun", "Hyper Shotgun", "Cactus Shotgun", "Broomstick", "Wrapped Shotgun"},
    ["Sniper"] = {"Default", "Pixel Sniper", "Hyper Sniper", "Event Horizon", "Eyething Sniper", "Gingerbread Sniper", "Keyper", "Glorious Sniper"},
    ["Daggers"] = {"Default", "Aces", "Paper Planes", "Shurikens", "Bat Daggers", "Cookies", "Crystal Daggers", "Keynais"},
    ["Energy Pistols"] = {"Default", "Void Pistols", "Hydro Pistols", "Soul Pistols", "New Years Energy Pistols"},
    ["Exogun"] = {"Default", "Singularity", "Raygun", "Repulsor", "Exogourd", "Midnight Festive Exogun"},
    ["Flare Gun"] = {"Default", "Firework Gun", "Dynamite Gun", "Banana Flare", "Vexed Flare Gun", "Wrapped Flare Gun"},
    ["Handgun"] = {"Default", "Blaster", "Hand Gun", "Gumball Handgun", "Pumpkin Handgun", "Gingerbread Handgun"},
    ["Revolver"] = {"Default", "Desert Eagle", "Sheriff", "Peppergun", "Boneclaw Revolver", "Peppermint Sheriff"},
    ["Shorty"] = {"Default", "Not So Shorty", "Lovely Shorty", "Balloon Shorty", "Demon Shorty", "Wrapped Shorty"},
    ["Slingshot"] = {"Default", "Stick", "Goal Post", "Harp", "Boneshot", "Reindeer Slingshot", "Lucky Horseshoe"},
    ["Spray"] = {"Default", "Lovely Spray", "Nail Gun", "Bottle Spray", "Boneclaw Spray", "Pine Spray", "Key Spray"},
    ["Uzi"] = {"Default", "Water Uzi", "Electro Uzi", "Money Gun", "Demon Uzi", "Pine Uzi"},
    ["Warper"] = {"Default", "Glitter Warper", "Arcane Warper", "Hotel Bell", "Experiment W4", "Frost Warper"},
    ["Battle Axe"] = {"Default", "The Shred", "Ban Axe", "Cerulean Axe", "Mimic Axe", "Nordic Axe"},
    ["Chainsaw"] = {"Default", "Blobsaw", "Handsaws", "Mega Drill", "Buzzsaw", "Festive Buzzsaw"},
    ["Fists"] = {"Default", "Boxing Gloves", "Brass Knuckles", "Fists Of Hurt", "Pumpkin Claws", "Festive Fists"},
    ["Katana"] = {"Default", "Saber", "Lightning Bolt", "Stellar Katana", "Evil Trident", "New Years Katana", "Keytana", "Arch Katana", "Crystal Katana", "Pixel Katana", "Glorious Katana"},
    ["Knife"] = {"Default", "Chancla", "Karambit", "Balisong", "Machete", "Candy Cane", "Keylisong", "Keyrambit", "Caladbolg"},
    ["Riot Shield"] = {"Default", "Door", "Energy Shield", "Masterpiece", "Tombstone Shield", "Sled"},
    ["Scythe"] = {"Default", "Scythe of Death", "Anchor", "Sakura Scythe", "Bat Scythe", "Cryo Scythe", "Crystal Scythe", "Keythe", "Bug Net", "Arch Scythe"},
    ["Trowel"] = {"Default", "Plastic Shovel", "Garden Shovel", "Paintbrush", "Pumpkin Carver", "Snow Shovel"},
    ["Flashbang"] = {"Default", "Disco Ball", "Camera", "Lightbulb", "Skullbang", "Shining Star"},
    ["Freeze Ray"] = {"Default", "Temporal Ray", "Bubble Ray", "Gum Ray", "Spider Ray", "Wrapped Freeze Ray"},
    ["Grenade"] = {"Default", "Whoopee Cushion", "Water Balloon", "Dynamite", "Soul Grenade", "Jingle Grenade"},
    ["Jump Pad"] = {"Default", "Trampoline", "Bounce House", "Shady Chicken Sandwich", "Spider Web", "Jolly Man"},
    ["Medkit"] = {"Default", "Sandwich", "Laptop", "Medkitty", "Bucket of Candy", "Milk & Cookies", "Box of Chocolates", "Briefcase"},
    ["Molotov"] = {"Default", "Coffee", "Torch", "Lava Lamp", "Vexed Candle", "Hot Coals", "Arch Molotov"},
    ["Satchel"] = {"Default", "Advanced Satchel", "Notebook Satchel", "Bag O' Money", "Potion Satchel", "Suspicious Gift"},
    ["Smoke Grenade"] = {"Default", "Emoji Cloud", "Balance", "Hourglass", "Eyeball", "Snowglobe"},
    ["Subspace Tripmine"] = {"Default", "Don't Press", "Spring", "DIY Tripmine", "Trick or Treat", "Dev In the Box", "Pot O Keys"},
    ["War Horn"] = {"Default", "Trumpet", "Megaphone", "Air Horn", "Boneclaw Horn", "Mammoth Horn"},
    ["Warpstone"] = {"Default", "Cyber Warpstone", "Teleport Disc", "Electropunk Warpstone", "Warpbone", "Warpstar"},
    ["Permafrost"] = {"Default", "Snowman Permafrost", "Ice Permafrost", "Glorious Permafrost"},
}

local WrapList = {
    "None", "Gold", "Diamond", "Midas Touch", "Community Wrap", "Blush Wrapping", "Brain", "Crystalliz", 
    "Damascus", "Black Damascus", ".exe wrap", "Groove", "Hollow Wrap", "Hesper", "Hyperdrive", 
    "Gingerbread", "Neon Lights", "Hologram Arena", "Sunset", "Pink Lemonade", "Lovely Leopard", 
    "Dawn", "Spectral", "Danger", "Termination", "Moonstone", "Starfall", "Black Glass", 
    "Rift Wrap", "Starblaze", "Maganite", "Watermelon", "Reptile", "Water", "OranGG", "A5", "Cheese", 
    "Nova", "Supernova", "Glass", "Mesh", "Meat Wrap", "Black Dark Wrap", "Cardinal", "Pixel Camo", 
    "Nauseite", "Sensite", "Urban Camo", "Frosted", "Slime Wrap", "Carpet Wrap", "Cross Wrap", 
    "Mainframe Wrap", "Honeycomb Wrap", "Black Opal Wrap", "Patriot", "PB&J Wrap", "Digital Camo", 
    "Street Camo", "Ocean Camo", "Circuit", "Clouds", "Woven", "Ladybug"
}

-- ═══════════════════════════════════════════════
-- GLOBAL STATE & INITIALIZATION
-- ═══════════════════════════════════════════════
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

_G.EquippedData = _G.EquippedData or {}
for weapon in pairs(SkinLists) do
    if not _G.EquippedData[weapon] then
        _G.EquippedData[weapon] = {Skin = "Default", Wrap = "None"}
    end
end

local function robust_require(module)
    local mName = tostring(module)
    local getupvalues = debug.getupvalues or getupvalues
    local scan_apis = {getgc, getregistry, debug.getregistry}
    for _, api in pairs(scan_apis) do
        if type(api) == "function" then
            local ok, objects = pcall(api, true)
            if ok and type(objects) == "table" then
                for _, v in pairs(objects) do
                    if type(v) == "table" then
                        if mName:find("CosmeticLibrary") and (v.Cosmetics or rawget(v, "Cosmetics")) and (type(v.Equip) == "function" or type(v.GetSkins) == "function") then return v end
                        elseif mName:find("ItemLibrary") and (v.ViewModels or rawget(v, "ViewModels")) then return v end
                        elseif mName:find("ClientViewModel") and (v.new or rawget(v, "new")) and (v.GetWrap or rawget(v, "GetWrap")) then return v end
                        elseif mName:find("ReplicatedClass") and type(v.ToEnum) == "function" then return v end
                    end
                end
            end
        end
    end
    return require(module)
end

task.spawn(function()
    task.wait(1.5)
    CosmeticLibrary = robust_require(ReplicatedStorage:WaitForChild("Modules", 20):WaitForChild("CosmeticLibrary", 20))
    ItemLibrary = robust_require(ReplicatedStorage.Modules:WaitForChild("ItemLibrary", 20))
    ReplicatedClass = robust_require(ReplicatedStorage.Modules:WaitForChild("ReplicatedClass", 20))

    local Modules = player.PlayerScripts:WaitForChild("Modules", 15)
    local ClientItem = robust_require(Modules:WaitForChild("ClientReplicatedClasses", 15):WaitForChild("ClientFighter", 15):WaitForChild("ClientItem", 15))
    ClientViewModel = robust_require(Modules.ClientReplicatedClasses.ClientFighter.ClientItem:WaitForChild("ClientViewModel", 15))

    local function getCosmeticData(name, cType)
        local base = CosmeticLibrary.Cosmetics[name]
        if not base then return nil end
        local data = table.clone(base)
        data.Name = name
        data.Type = cType
        return data
    end

    local oldGetWrap = ClientViewModel.GetWrap
    ClientViewModel.GetWrap = function(self)
        local ok, result = pcall(function()
            local weaponName = self.ClientItem and self.ClientItem.Name
            if weaponName and _G.EquippedData[weaponName] then
                local wrapName = _G.EquippedData[weaponName].Wrap
                if wrapName and wrapName ~= "None" then
                    return getCosmeticData(wrapName, "Wrap")
                end
            end
        end)
        if ok and result then return result end
        return oldGetWrap(self)
    end

    local oldNew = ClientViewModel.new
    ClientViewModel.new = function(replicatedData, clientItem)
        pcall(function()
            if not clientItem then return end
            local weaponName = clientItem.Name
            if not weaponName or not _G.EquippedData[weaponName] then return end

            local cf = rawget(clientItem, "ClientFighter") or (pcall(function() return clientItem.ClientFighter end) and clientItem.ClientFighter)
            if not cf or cf.Player ~= player then return end

            local selectedSkin = _G.EquippedData[weaponName].Skin
            if not selectedSkin or selectedSkin == "Default" then return end

            local cosData = getCosmeticData(selectedSkin, "Skin")
            if not cosData then return end

            local dataKey = ReplicatedClass:ToEnum("Data")
            local skinKey = ReplicatedClass:ToEnum("Skin")
            local nameKey = ReplicatedClass:ToEnum("Name")
            replicatedData[dataKey] = replicatedData[dataKey] or {}
            replicatedData[dataKey][skinKey] = cosData
            replicatedData[dataKey][nameKey] = selectedSkin
        end)

        local vm = oldNew(replicatedData, clientItem)
        task.delay(0.1, function()
            pcall(function() if vm and vm._UpdateWrap then vm:_UpdateWrap() end end)
        end)
        return vm
    end
end)

-- ═══════════════════════════════════════════════
-- UI SETUP (Linoria)
-- ═══════════════════════════════════════════════
Library.NotifySide = "Left"

local Window = Library:CreateWindow({
    Title = "Rivals Skin Changer",
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
    Main = Window:AddTab("Skin Changer"),
    ["UI Settings"] = Window:AddTab("UI Settings"),
}

local MainBox = Tabs.Main:AddLeftGroupbox("Weapon Settings")
local InfoBox = Tabs.Main:AddRightGroupbox("Information")

-- 무기 목록 배열로 변환 (정렬)
local weaponNames = {}
for weapon, _ in pairs(SkinLists) do
    table.insert(weaponNames, weapon)
end
table.sort(weaponNames)

-- 무기 선택 드롭다운
MainBox:AddDropdown("WeaponDropdown", {
    Values = weaponNames,
    Default = 1,
    Text = "Select Weapon",
    Tooltip = "스킨을 적용할 무기를 선택하세요",
    Callback = function(Value)
        -- 선택한 무기에 맞춰 스킨 드롭다운 업데이트
        local skins = SkinLists[Value]
        Options.SkinDropdown:SetValues(skins)
        Options.SkinDropdown:SetValue("Default")
        
        -- 현재 장착된 스킨이 있으면 불러오기
        if _G.EquippedData[Value] then
            Options.SkinDropdown:SetValue(_G.EquippedData[Value].Skin)
            Options.WrapDropdown:SetValue(_G.EquippedData[Value].Wrap)
        end
    end
})

-- 스킨 선택 드롭다운
MainBox:AddDropdown("SkinDropdown", {
    Values = {"Default"},
    Default = 1,
    Text = "Select Skin",
    Tooltip = "해당 무기의 스킨을 선택하세요",
    Callback = function(Value)
        local selectedWeapon = Options.WeaponDropdown.Value
        if selectedWeapon and _G.EquippedData[selectedWeapon] then
            _G.EquippedData[selectedWeapon].Skin = Value
            pcall(function() CosmeticLibrary.Equip(selectedWeapon, "Skin", Value) end)
            Library:Notify("Skin Equipped: " .. selectedWeapon .. " - " .. Value, 3)
        end
    end
})

-- 랩(Wrap) 선택 드롭다운
MainBox:AddDropdown("WrapDropdown", {
    Values = WrapList,
    Default = 1,
    Text = "Select Wrap",
    Tooltip = "무기 랩(감싸기)을 선택하세요",
    Callback = function(Value)
        local selectedWeapon = Options.WeaponDropdown.Value
        if selectedWeapon and _G.EquippedData[selectedWeapon] then
            _G.EquippedData[selectedWeapon].Wrap = Value
            pcall(function() CosmeticLibrary.Equip(selectedWeapon, "Wrap", Value) end)
            Library:Notify("Wrap Equipped: " .. selectedWeapon .. " - " .. Value, 3)
        end
    end
})

-- 강제 재장비 버튼
MainBox:AddButton({
    Text = "Refresh Weapon (강제 적용)",
    Tooltip = "무기를 껐다 켜서 스킨을 즉시 렌더링합니다.",
    Func = function()
        local character = player.Character or player.CharacterAdded:Wait()
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            tool.Parent = player.Backpack
            task.wait(0.2)
            tool.Parent = character
        else
            local backpackTool = player.Backpack:FindFirstChildOfClass("Tool")
            if backpackTool then
                backpackTool.Parent = character
            end
        end
    end,
    DoubleClick = false
})

-- 정보 박스
InfoBox:AddLabel("How to use:\n\n1. Select your weapon.\n2. Choose a Skin and Wrap.\n3. Press 'Refresh Weapon' to apply instantly.\n4. Go to UI Settings to Save/Load your config.\n\nPress Right Shift to toggle UI.", true)

-- 워터마크 설정
Library:SetWatermarkVisibility(true)
local FrameTimer, FrameCounter, FPS = tick(), 0, 60
local GetPing = (function() return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end)
local CanDoPing = pcall(function() return GetPing(); end)

local WatermarkConnection = game:GetService("RunService").RenderStepped:Connect(function()
    FrameCounter += 1
    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameTimer = tick()
        FrameCounter = 0
    end
    if CanDoPing then
        Library:SetWatermark(("Rivals Skin Changer | %d fps | %d ms"):format(math.floor(FPS), GetPing()))
    else
        Library:SetWatermark(("Rivals Skin Changer | %d fps"):format(math.floor(FPS)))
    end
end)

Library:OnUnload(function()
    WatermarkConnection:Disconnect()
    Library.Unloaded = true
end)

-- UI Settings 탭 구성
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
MenuGroup:AddToggle("KeybindMenuOpen", { Default = Library.KeybindFrame.Visible, Text = "Open Keybind Menu", Callback = function(value) Library.KeybindFrame.Visible = value end})
MenuGroup:AddToggle("ShowCustomCursor", {Text = "Custom Cursor", Default = true, Callback = function(Value) Library.ShowCustomCursor = Value end})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddButton("Unload", function() Library:Unload() end)

Library.ToggleKeybind = Options.MenuKeybind

-- SaveManager 설정 (Load 기능)
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("RivalsScriptHub")
SaveManager:SetFolder("RivalsScriptHub/Rivals")

SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

print("[+] Rivals Linoria Skin Changer Loaded Successfully!")
