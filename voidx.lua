-- VOID X CLIENT | Tabbed GUI + Config | Blox Fruits (Sea 1/2/3)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local speed = 250
local running = true
local state = {
    chest=false, level=false, grind=false, fruit=false, store=false,
    fruitesp=false, chestesp=false, hop=false, antiafk=true, noclip=true,
    fastattack=true, autoclick=true, bring=false,
}
local cfg = {weaponType = "Melee", weaponName = nil, height = 10}
local WEAPON_TYPES = {"Melee", "Sword", "Gun", "Blox Fruit"}
local stats = {chests = 0, fruits = 0, kills = 0}

local conns = {}
local function keep(c) table.insert(conns, c) return c end

keep(player.Idled:Connect(function()
    if state.antiafk then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end))

---------------------------------------------------------------------
-- SEA DETECTION + QUEST TABLES
---------------------------------------------------------------------
local SEA = ({[2753915549] = 1, [4442272183] = 2, [7449423635] = 3})[game.PlaceId] or 1
local QUESTS = {}
local function Q(minL, maxL, mob, quest, idx, x, y, z)
    table.insert(QUESTS, {minL, maxL, mob, quest, idx, Vector3.new(x, y, z)})
end

if SEA == 1 then
    Q(1,9,"Bandit","BanditQuest1",1,1059,16,1550)
    Q(10,14,"Monkey","JungleQuest",1,-1598,36,153)
    Q(15,29,"Gorilla","JungleQuest",2,-1598,36,153)
    Q(30,39,"Pirate","BuggyQuest1",1,-1140,5,3825)
    Q(40,59,"Brute","BuggyQuest1",2,-1140,5,3825)
    Q(60,74,"Desert Bandit","DesertQuest",1,897,6,4390)
    Q(75,89,"Desert Officer","DesertQuest",2,897,6,4390)
    Q(90,99,"Snow Bandit","SnowQuest",1,1387,87,-1298)
    Q(100,119,"Snowman","SnowQuest",2,1387,87,-1298)
    Q(120,149,"Chief Petty Officer","MarineQuest2",1,-5035,29,4324)
    Q(150,174,"Sky Bandit","SkyQuest",1,-4842,718,-2624)
    Q(175,189,"Dark Master","SkyQuest",2,-4842,718,-2624)
    Q(190,209,"Prisoner","PrisonerQuest",1,5311,1,475)
    Q(210,249,"Dangerous Prisoner","PrisonerQuest",2,5311,1,475)
    Q(250,274,"Toga Warrior","ColosseumQuest",1,-1580,6,-2986)
    Q(275,299,"Gladiator","ColosseumQuest",2,-1580,6,-2986)
    Q(300,324,"Military Soldier","MagmaQuest",1,-5313,11,8515)
    Q(325,374,"Military Spy","MagmaQuest",2,-5313,11,8515)
    Q(375,399,"Fishman Warrior","FishmanQuest",1,61122,18,1567)
    Q(400,449,"Fishman Commando","FishmanQuest",2,61122,18,1567)
    Q(450,474,"God's Guard","SkyExp1Quest",1,-4721,845,-1953)
    Q(475,524,"Shanda","SkyExp1Quest",2,-7859,5544,-381)
    Q(525,549,"Royal Squad","SkyExp2Quest",1,-7903,5636,-1412)
    Q(550,624,"Royal Soldier","SkyExp2Quest",2,-7903,5636,-1412)
    Q(625,649,"Galley Pirate","FountainQuest",1,5258,39,4052)
    Q(650,699,"Galley Captain","FountainQuest",2,5258,39,4052)
elseif SEA == 2 then
    Q(700,724,"Raider","Area1Quest",1,-429,71,1836)
    Q(725,774,"Mercenary","Area1Quest",2,-429,71,1836)
    Q(775,799,"Swan Pirate","Area2Quest",1,638,71,918)
    Q(800,874,"Factory Staff","Area2Quest",2,638,71,918)
    Q(875,899,"Marine Lieutenant","MarineQuest3",1,-2440,73,-3217)
    Q(900,949,"Marine Captain","MarineQuest3",2,-2440,73,-3217)
    Q(950,974,"Zombie","ZombieQuest",1,-5497,48,-795)
    Q(975,999,"Vampire","ZombieQuest",2,-5497,48,-795)
    Q(1000,1049,"Snow Trooper","SnowMountainQuest",1,609,400,-5372)
    Q(1050,1099,"Winter Warrior","SnowMountainQuest",2,609,400,-5372)
    Q(1100,1124,"Lab Subordinate","IceSideQuest",1,-6064,15,-4902)
    Q(1125,1174,"Horned Warrior","IceSideQuest",2,-6064,15,-4902)
    Q(1175,1199,"Magma Ninja","FireSideQuest",1,-5428,15,-5299)
    Q(1200,1249,"Lava Pirate","FireSideQuest",2,-5428,15,-5299)
    Q(1250,1274,"Ship Deckhand","ShipQuest1",1,1037,125,32911)
    Q(1275,1299,"Ship Engineer","ShipQuest1",2,1037,125,32911)
    Q(1300,1324,"Ship Steward","ShipQuest2",1,968,125,33244)
    Q(1325,1349,"Ship Officer","ShipQuest2",2,968,125,33244)
    Q(1350,1374,"Arctic Warrior","FrostQuest",1,5669,28,-6482)
    Q(1375,1424,"Snow Lurker","FrostQuest",2,5669,28,-6482)
    Q(1425,1449,"Sea Soldier","ForgottenQuest",1,-3054,235,-10142)
    Q(1450,1499,"Water Fighter","ForgottenQuest",2,-3054,235,-10142)
else
    Q(1500,1524,"Pirate Millionaire","PiratePortQuest",1,-290,43,5577)
    Q(1525,1574,"Pistol Billionaire","PiratePortQuest",2,-290,43,5577)
    Q(1575,1599,"Dragon Crew Warrior","AmazonQuest",1,5833,51,-1103)
    Q(1600,1624,"Dragon Crew Archer","AmazonQuest",2,5833,51,-1103)
    Q(1625,1649,"Female Islander","AmazonQuest2",1,5448,602,748)
    Q(1650,1699,"Giant Islander","AmazonQuest2",2,5448,602,748)
    Q(1700,1724,"Marine Commodore","MarineTreeIsland",1,2180,29,-6738)
    Q(1725,1774,"Marine Rear Admiral","MarineTreeIsland",2,2180,29,-6738)
    Q(1775,1799,"Fishman Raider","DeepForestIsland3",1,-10581,331,-8757)
    Q(1800,1824,"Fishman Captain","DeepForestIsland3",2,-10581,331,-8757)
    Q(1825,1849,"Forest Pirate","DeepForestIsland",1,-13234,331,-7625)
    Q(1850,1899,"Mythological Pirate","DeepForestIsland",2,-13234,331,-7625)
    Q(1900,1924,"Jungle Pirate","DeepForestIsland2",1,-12680,389,-9902)
    Q(1925,1974,"Musketeer Pirate","DeepForestIsland2",2,-12680,389,-9902)
    Q(1975,1999,"Reborn Skeleton","HauntedQuest1",1,-9479,141,5566)
    Q(2000,2024,"Living Zombie","HauntedQuest1",2,-9479,141,5566)
    Q(2025,2049,"Demonic Soul","HauntedQuest2",1,-9516,172,6078)
    Q(2050,2074,"Posessed Mummy","HauntedQuest2",2,-9516,172,6078)
    Q(2075,2099,"Peanut Scout","NutsIslandQuest",1,-2105,38,-10194)
    Q(2100,2124,"Peanut President","NutsIslandQuest",2,-2105,38,-10194)
    Q(2125,2149,"Ice Cream Chef","IceCreamIslandQuest",1,-820,66,-10965)
    Q(2150,2199,"Ice Cream Commander","IceCreamIslandQuest",2,-820,66,-10965)
    Q(2200,2224,"Cookie Crafter","CakeQuest1",1,-2021,38,-12028)
    Q(2225,2249,"Cake Guard","CakeQuest1",2,-2021,38,-12028)
    Q(2250,2274,"Baking Staff","CakeQuest2",1,-1927,38,-12842)
    Q(2275,2299,"Head Baker","CakeQuest2",2,-1927,38,-12842)
    Q(2300,2324,"Cocoa Warrior","ChocQuest1",1,233,30,-12201)
    Q(2325,2349,"Chocolate Bar Battler","ChocQuest1",2,233,30,-12201)
    Q(2350,2374,"Sweet Thief","ChocQuest2",1,151,30,-12775)
    Q(2375,2399,"Candy Rebel","ChocQuest2",2,151,30,-12775)
    Q(2400,2424,"Candy Pirate","CandyQuest1",1,-1149,14,-14445)
    Q(2425,2449,"Snow Demon","CandyQuest1",2,-1149,14,-14445)
    Q(2450,2474,"Isle Outlaw","TikiQuest1",1,-16548,55,-172)
    Q(2475,2499,"Island Boy","TikiQuest1",2,-16548,55,-172)
    Q(2500,2524,"Sun-kissed Warrior","TikiQuest2",1,-16541,54,1051)
    Q(2525,2800,"Isle Champion","TikiQuest2",2,-16541,54,1051)
    Q(2801,9999,"Isle Champion","TikiQuest2",2,-16541,54,1051)
end

local WAYPOINTS, seenWP = {}, {}
for _, q in ipairs(QUESTS) do
    local k = tostring(q[6])
    if not seenWP[k] then
        seenWP[k] = true
        table.insert(WAYPOINTS, q[6] + Vector3.new(0, 60, 0))
    end
end

---------------------------------------------------------------------
-- THEME + GUI ROOT
---------------------------------------------------------------------
local C = {
    bg=Color3.fromRGB(8,6,14), panel=Color3.fromRGB(20,13,34),
    purple=Color3.fromRGB(150,60,255), pink=Color3.fromRGB(255,45,185),
    text=Color3.fromRGB(240,230,255), dim=Color3.fromRGB(145,128,175),
    off=Color3.fromRGB(42,33,62),
}
local W, H, HEAD = 360, 270, 38
local minimized = false

local guiParent = (gethui and gethui()) or game:GetService("CoreGui")
pcall(function()
    local old = guiParent:FindFirstChild("VoidXClient")
    if old then old:Destroy() end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "VoidXClient"
gui.ResetOnSpawn = false
gui.Parent = guiParent

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, W, 0, H)
frame.Position = UDim2.new(0.5, -W/2, 0.06, 0)
frame.BackgroundColor3 = C.bg
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2
stroke.Color = Color3.new(1, 1, 1)
local grad = Instance.new("UIGradient", stroke)
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.purple),
    ColorSequenceKeypoint.new(0.5, C.pink),
    ColorSequenceKeypoint.new(1, C.purple),
})
keep(RunService.Heartbeat:Connect(function() grad.Rotation = (grad.Rotation + 1.5) % 360 end))

local function makeDraggable(handle, target)
    local dragging, dragStart, startPos, moved = false, nil, nil, false
    keep(handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging, moved = true, false
            dragStart, startPos = input.Position, target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end))
    keep(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            if d.Magnitude > 6 then moved = true end
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                        startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
    return function() return moved end
end

---------------------------------------------------------------------
-- HEADER
---------------------------------------------------------------------
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, HEAD)
header.BackgroundColor3 = C.panel
header.BorderSizePixel = 0
header.Active = true
header.Parent = frame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)
makeDraggable(header, frame)

local function newLabel(parent, text, size, pos, textSize, color, align, font)
    local l = Instance.new("TextLabel")
    l.Size, l.Position = size, pos
    l.BackgroundTransparency = 1
    l.Text = text
    l.Font = font or Enum.Font.GothamBold
    l.TextSize = textSize
    l.TextColor3 = color
    l.TextXAlignment = align or Enum.TextXAlignment.Left
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.Parent = parent
    return l
end

local title = newLabel(header, "VOID X CLIENT", UDim2.new(0, 130, 1, 0), UDim2.new(0, 12, 0, 0), 15, Color3.new(1,1,1), nil, Enum.Font.GothamBlack)
Instance.new("UIGradient", title).Color = ColorSequence.new(C.purple, C.pink)
local headStatus = newLabel(header, "Ready", UDim2.new(1, -230, 1, 0), UDim2.new(0, 145, 0, 0), 10, C.dim, Enum.TextXAlignment.Left, Enum.Font.Gotham)

local function headerButton(text, xOff, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 26, 0, 26)
    b.Position = UDim2.new(1, xOff, 0.5, -13)
    b.BackgroundColor3 = C.off
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    b.TextColor3 = color
    b.AutoButtonColor = false
    b.Parent = header
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end
local minBtn = headerButton("–", -62, C.pink)
local closeBtn = headerButton("×", -32, C.purple)

---------------------------------------------------------------------
-- BODY: sidebar + pages
---------------------------------------------------------------------
local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -HEAD)
body.Position = UDim2.new(0, 0, 0, HEAD)
body.BackgroundTransparency = 1
body.Parent = frame

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 80, 1, -10)
sidebar.Position = UDim2.new(0, 6, 0, 4)
sidebar.BackgroundColor3 = C.panel
sidebar.BorderSizePixel = 0
sidebar.Parent = body
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)
local sl = Instance.new("UIListLayout", sidebar)
sl.Padding = UDim.new(0, 5)
sl.SortOrder = Enum.SortOrder.LayoutOrder
local sp = Instance.new("UIPadding", sidebar)
sp.PaddingTop, sp.PaddingLeft, sp.PaddingRight = UDim.new(0, 6), UDim.new(0, 5), UDim.new(0, 5)

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -96, 1, -10)
content.Position = UDim2.new(0, 90, 0, 4)
content.BackgroundTransparency = 1
content.Parent = body

local pages, tabButtons, onTabSelected = {}, {}, {}
local order = 0
local function nextOrder() order += 1 return order end

local function selectTab(name)
    for n, p in pairs(pages) do p.Visible = (n == name) end
    for n, b in pairs(tabButtons) do
        local on = (n == name)
        TweenService:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = on and C.purple or C.off,
            TextColor3 = on and Color3.new(1, 1, 1) or C.dim,
        }):Play()
    end
    if onTabSelected[name] then onTabSelected[name]() end
end

local function newTab(name, layoutOrder)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 28)
    b.LayoutOrder = layoutOrder
    b.BackgroundColor3 = C.off
    b.Text = name
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.TextColor3 = C.dim
    b.AutoButtonColor = false
    b.Parent = sidebar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    local p = Instance.new("ScrollingFrame")
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 3
    p.ScrollBarImageColor3 = C.pink
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.CanvasSize = UDim2.new(0, 0, 0, 0)
    p.Visible = false
    p.Parent = content
    local l = Instance.new("UIListLayout", p)
    l.Padding = UDim.new(0, 6)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    local pad = Instance.new("UIPadding", p)
    pad.PaddingRight, pad.PaddingBottom = UDim.new(0, 6), UDim.new(0, 6)

    b.MouseButton1Click:Connect(function() selectTab(name) end)
    pages[name], tabButtons[name] = p, b
    return p
end

local farmPage = newTab("Farm", 1)
local configPage = newTab("Config", 2)
local visualPage = newTab("Visuals", 3)
local miscPage = newTab("Misc", 4)
local infoPage = newTab("Info", 5)

---------------------------------------------------------------------
-- UI COMPONENTS
---------------------------------------------------------------------
local function makeRow(page)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 32)
    row.LayoutOrder = nextOrder()
    row.BackgroundColor3 = C.panel
    row.BorderSizePixel = 0
    row.Parent = page
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 9)
    return row
end

local function makeSection(page, text)
    local l = newLabel(page, text, UDim2.new(1, 0, 0, 18), UDim2.new(0, 0, 0, 0), 11, C.pink)
    l.LayoutOrder = nextOrder()
end

local function makeToggle(page, name, key)
    local row = makeRow(page)
    newLabel(row, name, UDim2.new(1, -62, 1, 0), UDim2.new(0, 10, 0, 0), 12, C.text)

    local track = Instance.new("TextButton")
    track.Size = UDim2.new(0, 42, 0, 20)
    track.Position = UDim2.new(1, -50, 0.5, -10)
    track.BackgroundColor3 = C.off
    track.Text = ""
    track.AutoButtonColor = false
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    local ts = Instance.new("UIStroke", track)
    ts.Color, ts.Thickness = C.purple, 1

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = C.dim
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local function apply(on, instant)
        local info = TweenInfo.new(instant and 0 or 0.2)
        TweenService:Create(track, info, {BackgroundColor3 = on and C.pink or C.off}):Play()
        TweenService:Create(ts, info, {Color = on and C.pink or C.purple}):Play()
        TweenService:Create(knob, info, {
            Position = on and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
            BackgroundColor3 = on and Color3.new(1, 1, 1) or C.dim,
        }):Play()
    end
    track.MouseButton1Click:Connect(function()
        state[key] = not state[key]
        apply(state[key])
    end)
    apply(state[key], true)
end

local function makeButton(page, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 32)
    b.LayoutOrder = nextOrder()
    b.BackgroundColor3 = C.off
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.TextColor3 = C.text
    b.AutoButtonColor = false
    b.Parent = page
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 9)
    local s = Instance.new("UIStroke", b)
    s.Color, s.Thickness = C.purple, 1
    b.MouseButton1Click:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = C.purple}):Play()
        task.delay(0.15, function()
            TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = C.off}):Play()
        end)
        callback()
    end)
    return b
end

local function makeStepper(page, getText, onChange, step)
    local row = makeRow(page)
    local lbl = newLabel(row, getText(), UDim2.new(1, -80, 1, 0), UDim2.new(0, 10, 0, 0), 12, C.text)
    local function btn(text, xOff, delta)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 28, 0, 22)
        b.Position = UDim2.new(1, xOff, 0.5, -11)
        b.BackgroundColor3 = C.off
        b.Text = text
        b.Font = Enum.Font.GothamBold
        b.TextSize = 15
        b.TextColor3 = C.pink
        b.AutoButtonColor = false
        b.Parent = row
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
        b.MouseButton1Click:Connect(function()
            onChange(delta)
            lbl.Text = getText()
        end)
    end
    btn("-", -66, -step)
    btn("+", -34, step)
end

local function makeInfo(page)
    local row = makeRow(page)
    return newLabel(row, "", UDim2.new(1, -16, 1, 0), UDim2.new(0, 10, 0, 0), 11, C.text, nil, Enum.Font.Gotham)
end

---------------------------------------------------------------------
-- FARM TAB
---------------------------------------------------------------------
makeSection(farmPage, "COLLECT")
makeToggle(farmPage, "Collect All Chests", "chest")
makeToggle(farmPage, "Auto Fruit", "fruit")
makeToggle(farmPage, "Auto Store Fruit", "store")
makeSection(farmPage, "COMBAT")
makeToggle(farmPage, "Auto Farm Level", "level")
makeToggle(farmPage, "Auto Grind Closest Mob", "grind")

---------------------------------------------------------------------
-- CONFIG TAB (weapon + combat settings)
---------------------------------------------------------------------
makeSection(configPage, "WEAPON")
local weaponInfo = makeInfo(configPage)
local typeBtn
typeBtn = makeButton(configPage, "Weapon Type: " .. cfg.weaponType, function()
    local idx = table.find(WEAPON_TYPES, cfg.weaponType) or 1
    cfg.weaponType = WEAPON_TYPES[idx % #WEAPON_TYPES + 1]
    cfg.weaponName = nil -- type mode = auto pick by type
    typeBtn.Text = "Weapon Type: " .. cfg.weaponType
    if onTabSelected.Config then onTabSelected.Config() end
end)
makeSection(configPage, "OR PICK A SPECIFIC TOOL")

local weaponHolder = Instance.new("Frame")
weaponHolder.Size = UDim2.new(1, 0, 0, 0)
weaponHolder.AutomaticSize = Enum.AutomaticSize.Y
weaponHolder.BackgroundTransparency = 1
weaponHolder.LayoutOrder = nextOrder()
weaponHolder.Parent = configPage
local wl = Instance.new("UIListLayout", weaponHolder)
wl.Padding = UDim.new(0, 4)

local function updateWeaponLabel()
    weaponInfo.Text = cfg.weaponName and ("Using: " .. cfg.weaponName)
        or ("Using: Auto (" .. cfg.weaponType .. ")")
end

local function rebuildWeaponList()
    for _, c in ipairs(weaponHolder:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local seen = {}
    local function add(t)
        if t:IsA("Tool") and not seen[t.Name] then
            seen[t.Name] = true
            local selected = (cfg.weaponName == t.Name)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 28)
            b.BackgroundColor3 = selected and C.pink or C.off
            b.Text = ("%s  [%s]"):format(t.Name, (t.ToolTip ~= "" and t.ToolTip) or "?")
            b.Font = Enum.Font.GothamBold
            b.TextSize = 11
            b.TextColor3 = selected and Color3.new(1, 1, 1) or C.text
            b.TextTruncate = Enum.TextTruncate.AtEnd
            b.AutoButtonColor = false
            b.Parent = weaponHolder
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            b.MouseButton1Click:Connect(function()
                cfg.weaponName = t.Name
                updateWeaponLabel()
                rebuildWeaponList()
            end)
        end
    end
    local char = player.Character
    if char then for _, t in ipairs(char:GetChildren()) do add(t) end end
    for _, t in ipairs(player.Backpack:GetChildren()) do add(t) end
    updateWeaponLabel()
end
onTabSelected.Config = rebuildWeaponList

makeButton(configPage, "Refresh Tool List", rebuildWeaponList)
makeButton(configPage, "Clear Pick (Auto by Type)", function()
    cfg.weaponName = nil
    rebuildWeaponList()
end)

makeSection(configPage, "COMBAT SETTINGS")
makeToggle(configPage, "Fast Attack (Remotes)", "fastattack")
makeToggle(configPage, "Auto Click / Activate", "autoclick")
makeToggle(configPage, "Bring Mobs", "bring")
makeStepper(configPage, function() return "Hover Height: " .. cfg.height end, function(d)
    cfg.height = math.clamp(cfg.height + d, 2, 40)
end, 2)

---------------------------------------------------------------------
-- VISUALS / MISC / INFO TABS
---------------------------------------------------------------------
makeSection(visualPage, "ESP")
makeToggle(visualPage, "Fruit ESP", "fruitesp")
makeToggle(visualPage, "Chest ESP", "chestesp")

local destroyGui = function() end

makeSection(miscPage, "MOVEMENT")
makeStepper(miscPage, function() return "Speed: " .. speed end, function(d)
    speed = math.clamp(speed + d, 100, 400)
end, 25)
makeToggle(miscPage, "Noclip While Farming", "noclip")
makeSection(miscPage, "SERVER")
makeToggle(miscPage, "Auto Server Hop", "hop")
makeToggle(miscPage, "Anti-AFK", "antiafk")
local hopNowBtn = makeButton(miscPage, "Server Hop Now", function() end)
makeButton(miscPage, "Rejoin Server", function()
    pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
end)

makeSection(infoPage, "STATS")
local infoStats = makeInfo(infoPage)
local infoLevel = makeInfo(infoPage)
local infoStatus = makeInfo(infoPage)
makeSection(infoPage, "CLIENT")
makeButton(infoPage, "Unload VOID X", function() destroyGui() end)

selectTab("Farm")

---------------------------------------------------------------------
-- WINDOW CONTROLS + FLOATING BUTTON
---------------------------------------------------------------------
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 40, 0, 40)
openBtn.Position = UDim2.new(0, 10, 0.5, -20)
openBtn.BackgroundColor3 = C.bg
openBtn.Text = "V"
openBtn.Font = Enum.Font.GothamBlack
openBtn.TextSize = 20
openBtn.TextColor3 = C.pink
openBtn.AutoButtonColor = false
openBtn.Visible = false
openBtn.Parent = gui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
local os = Instance.new("UIStroke", openBtn)
os.Thickness, os.Color = 2, C.purple
local openMoved = makeDraggable(openBtn, openBtn)

openBtn.MouseButton1Click:Connect(function()
    if openMoved() then return end
    frame.Visible = true
    openBtn.Visible = false
end)
closeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    openBtn.Visible = true
end)
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    minBtn.Text = minimized and "+" or "–"
    TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, W, 0, minimized and HEAD or H)
    }):Play()
end)

---------------------------------------------------------------------
-- STATUS / INFO
---------------------------------------------------------------------
local lastStatus = "Ready"
local function refreshUI(msg)
    if msg then lastStatus = msg end
    headStatus.Text = lastStatus
    infoStatus.Text = "Status: " .. lastStatus
    infoStats.Text = ("Chests %d | Fruits %d | Kills %d"):format(stats.chests, stats.fruits, stats.kills)
end

task.spawn(function()
    while running do
        local ok, lvl = pcall(function() return player.Data.Level.Value end)
        infoLevel.Text = ("Sea %d | Level %s"):format(SEA, ok and tostring(lvl) or "?")
        task.wait(1)
    end
end)

---------------------------------------------------------------------
-- HELPERS
---------------------------------------------------------------------
local function anyFarm()
    return state.chest or state.fruit or state.level or state.grind
end

local function getRoot()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health > 0 then
        return char:FindFirstChild("HumanoidRootPart"), char, hum
    end
end

local function posOf(obj)
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then return obj:GetPivot().Position end
    if obj:IsA("Tool") then
        local h = obj:FindFirstChild("Handle")
        return h and h.Position
    end
end

local function partOf(o)
    if o:IsA("BasePart") then return o end
    if o:IsA("Tool") then return o:FindFirstChild("Handle") end
    return o:FindFirstChildWhichIsA("BasePart", true)
end

local visited = {}
local function keyOf(obj)
    local p = posOf(obj)
    if not p then return nil end
    return ("%d,%d,%d"):format(p.X // 8, p.Y // 8, p.Z // 8)
end
local function fresh(c)
    local k = keyOf(c)
    return k and (not visited[k] or tick() - visited[k] > 180)
end
local function markVisited(c)
    local k = keyOf(c)
    if k then visited[k] = tick() end
end

local function getChests(includeVisited)
    local list, seen = {}, {}
    local function add(c)
        if c.Parent and not seen[c] and (includeVisited or fresh(c)) then
            seen[c] = true
            table.insert(list, c)
        end
    end
    for _, c in ipairs(CollectionService:GetTagged("_ChestTagged")) do add(c) end
    local folder = workspace:FindFirstChild("ChestModels")
    if folder then
        for _, c in ipairs(folder:GetChildren()) do add(c) end
    end
    for _, c in ipairs(workspace:GetChildren()) do
        if c.Name:match("^Chest%d*$") then add(c) end
    end
    return list
end

local function getFruits()
    local list = {}
    for _, o in ipairs(workspace:GetChildren()) do
        if o:IsA("Tool") and o.Name:find("Fruit") and o:FindFirstChild("Handle") then
            table.insert(list, o)
        end
    end
    return list
end

local function nearest(list, root)
    local best, bestDist
    for _, o in ipairs(list) do
        if o.Parent then
            local p = posOf(o)
            if p then
                local d = (p - root.Position).Magnitude
                if not bestDist or d < bestDist then best, bestDist = o, d end
            end
        end
    end
    return best, bestDist
end

local function flyTo(root, pos, stillValid)
    local dist = (pos - root.Position).Magnitude
    local tween = TweenService:Create(root,
        TweenInfo.new(math.max(dist / speed, 0.1), Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(pos)})
    tween:Play()
    local t0 = tick()
    while running and stillValid() and tween.PlaybackState == Enum.PlaybackState.Playing and tick() - t0 < 45 do
        task.wait()
    end
    local arrived = tween.PlaybackState == Enum.PlaybackState.Completed
    tween:Cancel()
    return arrived and stillValid()
end

local function collect(root, obj)
    local p = posOf(obj)
    if not p then return false end
    flyTo(root, p + Vector3.new(0, 2, 0), anyFarm)
    markVisited(obj)
    if anyFarm() then
        local p2 = posOf(obj)
        if p2 then root.CFrame = CFrame.new(p2) end
        if firetouchinterest then
            local part = partOf(obj)
            if part then
                pcall(function()
                    firetouchinterest(root, part, 0)
                    firetouchinterest(root, part, 1)
                end)
            end
        end
        task.wait(0.4)
        return true
    end
    return false
end

keep(RunService.Stepped:Connect(function()
    if not (state.noclip and anyFarm()) then return end
    local _, char = getRoot()
    if char then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end))

---------------------------------------------------------------------
-- COMBAT (weapon select, equip, click, fast attack, bring mobs)
---------------------------------------------------------------------
local function aliveMobs()
    local list = {}
    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, m in ipairs(enemies:GetChildren()) do
            local hum = m:FindFirstChildOfClass("Humanoid")
            local hrp = m:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then table.insert(list, m) end
        end
    end
    return list
end

local function nearestMobByName(name, root)
    local best, bestDist
    for _, m in ipairs(aliveMobs()) do
        if m.Name == name then
            local d = (m.HumanoidRootPart.Position - root.Position).Magnitude
            if not bestDist or d < bestDist then best, bestDist = m, d end
        end
    end
    return best
end

local function nearestMobAny(root)
    local best, bestDist
    for _, m in ipairs(aliveMobs()) do
        local d = (m.HumanoidRootPart.Position - root.Position).Magnitude
        if not bestDist or d < bestDist then best, bestDist = m, d end
    end
    return best
end

-- Is this tool the weapon the player picked? (used to find it AND to protect it from Auto Store)
local function isSelectedWeapon(t)
    if not t:IsA("Tool") then return false end
    if cfg.weaponName then return t.Name == cfg.weaponName end
    return t.ToolTip == cfg.weaponType
end

local function findWeapon()
    local char = player.Character
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if isSelectedWeapon(t) then return t end
        end
    end
    for _, t in ipairs(player.Backpack:GetChildren()) do
        if isSelectedWeapon(t) then return t end
    end
end

local function equipWeapon()
    local _, char, hum = getRoot()
    if not hum then return end
    local tool = findWeapon()
    if not tool then
        refreshUI("Weapon not found: " .. (cfg.weaponName or cfg.weaponType))
        return
    end
    if tool.Parent ~= char then
        pcall(function() hum:UnequipTools() end)
        hum:EquipTool(tool)
    end
    return tool
end

local function clickOnce(tool)
    pcall(function() tool:Activate() end)
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(1280, 672))
        VirtualUser:Button1Up(Vector2.new(1280, 672))
    end)
end

-- Best-effort: fires the game's own attack remotes. The names/args can change after updates.
local function fastHit(rootPos)
    local mods = ReplicatedStorage:FindFirstChild("Modules")
    local net = mods and mods:FindFirstChild("Net")
    local atk = net and net:FindFirstChild("RE/RegisterAttack")
    local hit = net and net:FindFirstChild("RE/RegisterHit")
    if not (atk and hit) then return end
    local targets, first = {}, nil
    for _, m in ipairs(aliveMobs()) do
        local h = m:FindFirstChild("HumanoidRootPart")
        if h and (h.Position - rootPos).Magnitude <= 60 then
            local part = m:FindFirstChild("Head") or h
            table.insert(targets, {m, part})
            first = first or part
        end
    end
    if not first then return end
    pcall(function()
        atk:FireServer(0)
        hit:FireServer(first, targets)
    end)
end

local function bringMobs(target)
    local thrp = target:FindFirstChild("HumanoidRootPart")
    if not thrp then return end
    for _, m in ipairs(aliveMobs()) do
        if m ~= target and m.Name == target.Name then
            local h = m.HumanoidRootPart
            if (h.Position - thrp.Position).Magnitude < 250 then
                h.CFrame = thrp.CFrame
                h.CanCollide = false
            end
        end
    end
end

local function attackMob(mob, flagKey)
    local hum = mob:FindFirstChildOfClass("Humanoid")
    local hrp = mob:FindFirstChild("HumanoidRootPart")
    if not (hum and hrp) then return end
    pcall(function()
        if sethiddenproperty then sethiddenproperty(player, "SimulationRadius", math.huge) end
    end)
    local t0 = tick()
    while running and state[flagKey] and mob.Parent and hum.Health > 0 and tick() - t0 < 60 do
        local r = getRoot()
        if not r then break end
        local tool = equipWeapon()
        r.CFrame = hrp.CFrame * CFrame.new(0, cfg.height, 0) * CFrame.Angles(math.rad(-90), 0, 0)
        r.AssemblyLinearVelocity = Vector3.zero
        if state.bring then bringMobs(mob) end
        if tool then
            if state.fastattack then fastHit(r.Position) end
            if state.autoclick then clickOnce(tool) end
        end
        task.wait(0.1)
    end
    if hum.Health <= 0 then stats.kills += 1 end
end

local function grindStep(root)
    local mob = nearestMobAny(root)
    if not mob then
        refreshUI("Grind: no mobs loaded...")
        task.wait(1)
        return
    end
    refreshUI("Grinding " .. mob.Name)
    flyTo(root, mob.HumanoidRootPart.Position + Vector3.new(0, cfg.height, 0), function() return state.grind and mob.Parent end)
    attackMob(mob, "grind")
    refreshUI()
end

local function currentQuest()
    local ok, lvl = pcall(function() return player.Data.Level.Value end)
    if not ok then return end
    for _, q in ipairs(QUESTS) do
        if lvl >= q[1] and lvl <= q[2] then
            return {mob=q[3], name=q[4], index=q[5], pos=q[6], lvl=lvl}
        end
    end
    return nil, lvl
end

local function questActive()
    local ok, vis = pcall(function() return player.PlayerGui.Main.Quest.Visible end)
    return ok and vis
end

local function levelStep(root)
    local q, lvl = currentQuest()
    if not q then
        refreshUI("No quest data for level " .. tostring(lvl or "?") .. " (Sea " .. SEA .. ")")
        task.wait(2)
        return
    end
    if not questActive() then
        refreshUI("Getting quest: " .. q.mob)
        if flyTo(root, q.pos + Vector3.new(0, 3, 0), function() return state.level end) then
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local remote = remotes and remotes:FindFirstChild("CommF_")
            if remote then pcall(function() remote:InvokeServer("StartQuest", q.name, q.index) end) end
            task.wait(0.6)
        end
        return
    end
    local mob = nearestMobByName(q.mob, root)
    if not mob then
        refreshUI("Searching for " .. q.mob .. "...")
        flyTo(root, q.pos + Vector3.new(0, 25, 0), function() return state.level and not nearestMobByName(q.mob, root) end)
        task.wait(0.5)
        return
    end
    refreshUI("Farming " .. q.mob .. " (Lv " .. q.lvl .. ")")
    attackMob(mob, "level")
    refreshUI()
end

---------------------------------------------------------------------
-- CHEST SWEEP + SERVER HOP
---------------------------------------------------------------------
local wpIndex = 0
local function sweepStep(root)
    wpIndex = wpIndex % #WAYPOINTS + 1
    local wp = WAYPOINTS[wpIndex]
    refreshUI(("Scanning area %d/%d..."):format(wpIndex, #WAYPOINTS))
    pcall(function() player:RequestStreamAroundAsync(wp) end)
    flyTo(root, wp, function() return state.chest and #getChests() == 0 end)
    task.wait(1.5)
end

local hopping = false
local function serverHop()
    if hopping then return end
    hopping = true
    refreshUI("Finding new server...")
    local ok, servers = pcall(function()
        local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)
        return game:GetService("HttpService"):JSONDecode(game:HttpGet(url))
    end)
    if ok and servers and servers.data then
        for _, s in ipairs(servers.data) do
            if s.id ~= game.JobId and s.playing < s.maxPlayers - 1 then
                pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, player) end)
                task.wait(8)
            end
        end
    end
    hopping = false
end
hopNowBtn.MouseButton1Click:Connect(function() task.spawn(serverHop) end)

---------------------------------------------------------------------
-- MAIN LOOP: fruit > visible chests > level > grind > chest sweep
---------------------------------------------------------------------
task.spawn(function()
    local lapStart
    while running do
        task.wait(0.1)
        local root = getRoot()
        if root and anyFarm() then
            local target, kind
            if state.fruit then
                local f = nearest(getFruits(), root)
                if f then target, kind = f, "fruit" end
            end
            if not target and state.chest then
                local c = nearest(getChests(), root)
                if c then target, kind = c, "chest" end
            end

            if target then
                lapStart = nil
                refreshUI("Collecting " .. kind .. "...")
                if collect(root, target) then
                    if kind == "fruit" then stats.fruits += 1 else stats.chests += 1 end
                    refreshUI("Collected " .. kind)
                end
            elseif state.level then
                levelStep(root)
            elseif state.grind then
                grindStep(root)
            elseif state.chest then
                lapStart = lapStart or tick()
                sweepStep(root)
                if wpIndex == #WAYPOINTS and state.hop and tick() - lapStart > 5 then
                    serverHop()
                    lapStart = nil
                end
            else
                task.wait(1)
            end
        end
    end
end)

---------------------------------------------------------------------
-- AUTO STORE FRUIT (never stores the fruit you picked as your weapon)
---------------------------------------------------------------------
task.spawn(function()
    while running do
        task.wait(2)
        if state.store then
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local remote = remotes and remotes:FindFirstChild("CommF_")
            if remote then
                for _, c in ipairs({player.Backpack, player.Character}) do
                    if c then
                        for _, tool in ipairs(c:GetChildren()) do
                            if tool:IsA("Tool") and tool.Name:find("Fruit") and not isSelectedWeapon(tool) then
                                local name = tool:GetAttribute("OriginalName") or tool.Name
                                pcall(function() remote:InvokeServer("StoreFruit", name, tool) end)
                                task.wait(0.5)
                            end
                        end
                    end
                end
            end
        end
    end
end)

---------------------------------------------------------------------
-- ESP (fruit + chest)
---------------------------------------------------------------------
local function setESP(part, tagName, text, color, on)
    local tag = part:FindFirstChild(tagName)
    if on then
        if not tag then
            tag = Instance.new("BillboardGui")
            tag.Name = tagName
            tag.Size = UDim2.new(0, 160, 0, 40)
            tag.AlwaysOnTop = true
            tag.StudsOffset = Vector3.new(0, 3, 0)
            tag.Parent = part
            local t = Instance.new("TextLabel")
            t.Name = "T"
            t.Size = UDim2.new(1, 0, 1, 0)
            t.BackgroundTransparency = 1
            t.Font = Enum.Font.GothamBold
            t.TextSize = 14
            t.TextColor3 = color
            t.TextStrokeColor3 = C.purple
            t.TextStrokeTransparency = 0
            t.Parent = tag
        end
        tag.T.Text = text
    elseif tag then
        tag:Destroy()
    end
end

task.spawn(function()
    while running do
        task.wait(0.5)
        local root = getRoot()
        for _, f in ipairs(getFruits()) do
            local h = f:FindFirstChild("Handle")
            if h then
                local d = root and math.floor((h.Position - root.Position).Magnitude) or 0
                setESP(h, "FruitESP", ("%s\n[%dm]"):format(f.Name, d), C.pink, state.fruitesp)
            end
        end
        for _, c in ipairs(getChests(true)) do
            local part = partOf(c)
            if part then
                local d = root and math.floor((part.Position - root.Position).Magnitude) or 0
                setESP(part, "ChestESP", ("Chest\n[%dm]"):format(d), Color3.fromRGB(255, 220, 90), state.chestesp)
            end
        end
    end
end)

---------------------------------------------------------------------
-- UNLOAD
---------------------------------------------------------------------
destroyGui = function()
    running = false
    for k in pairs(state) do state[k] = false end
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    pcall(function()
        for _, d in ipairs(workspace:GetDescendants()) do
            if d.Name == "FruitESP" or d.Name == "ChestESP" then d:Destroy() end
        end
    end)
    gui:Destroy()
end

rebuildWeaponList()
refreshUI("Ready (Sea " .. SEA .. ")")
