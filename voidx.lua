-- VOID X CLIENT v3.0.1 | Tabbed GUI + Config + Module Pack | Blox Fruits (Sea 1/2/3)
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

local title = newLabel(header, "VOID X CLIENT", UDim2.new(0, 140, 1, 0), UDim2.new(0, 12, 0, 0), 15, Color3.new(1,1,1), nil, Enum.Font.GothamBlack)
Instance.new("UIGradient", title).Color = ColorSequence.new(C.purple, C.pink)
local headStatus = newLabel(header, "Ready", UDim2.new(1, -222, 1, 0), UDim2.new(0, 154, 0, 0), 10, C.dim, Enum.TextXAlignment.Left, Enum.Font.Gotham)

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
-- BODY: sidebar (scrolling) + pages
---------------------------------------------------------------------
local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -HEAD)
body.Position = UDim2.new(0, 0, 0, HEAD)
body.BackgroundTransparency = 1
body.Parent = frame

local sidebar = Instance.new("ScrollingFrame")
sidebar.ScrollBarThickness = 2
sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
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
local function nextOrder()
    order += 1
    return order
end

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

local toggleSetters = {}
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
    toggleSetters[key] = apply
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
    cfg.weaponName = nil
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
wl.SortOrder = Enum.SortOrder.LayoutOrder

local function updateWeaponLabel()
    weaponInfo.Text = cfg.weaponName and ("Using: " .. cfg.weaponName)
        or ("Using: Auto (" .. cfg.weaponType .. ")")
end

local function rebuildWeaponList()
    for _, c in ipairs(weaponHolder:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local seen, count = {}, 0
    local function add(t)
        if t:IsA("Tool") and not seen[t.Name] then
            seen[t.Name] = true
            count += 1
            local selected = (cfg.weaponName == t.Name)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 28)
            b.LayoutOrder = count
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
local openStroke = Instance.new("UIStroke", openBtn)
openStroke.Thickness, openStroke.Color = 2, C.purple
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

-- Tween to a position. Uses the Completed event so it never hangs or misreads state.
local function flyTo(root, pos, stillValid)
    local dist = (pos - root.Position).Magnitude
    local tween = TweenService:Create(root,
        TweenInfo.new(math.max(dist / speed, 0.1), Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(pos)})
    local done, arrived = false, false
    local c = tween.Completed:Connect(function(st)
        done = true
        arrived = (st == Enum.PlaybackState.Completed)
    end)
    tween:Play()
    local t0 = tick()
    while running and not done and root.Parent and stillValid() and tick() - t0 < 45 do
        task.wait()
    end
    c:Disconnect()
    if not done then tween:Cancel() end
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

-- Best-effort: fires the game's own attack remotes. Names/args can change after updates.
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
                    task.spawn(serverHop)
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
-- FRUIT / CHEST ESP
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

---------------------------------------------------------------------
-- MODULE PACK (wrapped in a function to stay under Lua's local limit)
---------------------------------------------------------------------
local function loadModulePack()
local VERSION = "3.0.1"
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")
local setters = toggleSetters or {}
local startTime = tick()

for k, v in pairs({
    boss=false, elite=false, bones=false, autostats=false, autohaki=false,
    sniper=false, notifyfruit=true, events=true,
    fly=false, waterwalk=false, customwalk=false, customjump=false, noclipall=false,
    lowgfx=false, perf=false, autorejoin=true,
    espplayer=false, espnpc=false, espisland=false, espboss=false, espelite=false,
    espflower=false, espseabeast=false, espmirage=false, espgear=false, espweapon=false,
    notifications=true, webhook=false, autosave=false,
}) do state[k] = v end
cfg.stat, cfg.flySpeed, cfg.walk, cfg.jump = "Melee", 60, 50, 80
cfg.webhookUrl, cfg.theme, cfg.toggleKey = "", 1, "RightShift"

local function setToggle(key, val)
    state[key] = val
    if setters[key] then setters[key](val) end
end

local lastError = "none"
local function try(label, fn)
    local ok, err = pcall(fn)
    if not ok then lastError = label .. ": " .. tostring(err):sub(1, 60) end
end

local function onChange(key, fn)
    local last = state[key]
    task.spawn(function()
        while running do
            if state[key] ~= last then
                last = state[key]
                try(key, function() fn(last) end)
            end
            task.wait(0.3)
        end
    end)
end

local function fmt(n)
    local s = tostring(math.floor(tonumber(n) or 0)):reverse():gsub("(%d%d%d)", "%1,"):reverse()
    return (s:gsub("^,", ""))
end

local function invoke(...)
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local r = remotes and remotes:FindFirstChild("CommF_")
    if not r then return nil end
    local args = {...}
    local ok, res = pcall(function() return r:InvokeServer(table.unpack(args)) end)
    return ok and res or nil
end

local function set(t) local s = {} for _, n in ipairs(t) do s[n] = true end return s end
local BOSS = set({"The Gorilla King","Bobby","Yeti","Mob Leader","Vice Admiral","Saber Expert","Warden",
    "Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Diamond","Jeremy",
    "Fajita","Don Swan","Smoke Admiral","Awakened Ice Admiral","Tide Keeper","Darkbeard","Order",
    "Cursed Captain","Stone","Island Empress","Kilo Admiral","Captain Elephant","Beautiful Pirate",
    "Longma","Cake Queen","Soul Reaper","Dough King","Cake Prince","Greybeard"})
local ELITE = set({"Diablo", "Urban", "Deandre"})
local BONES = set({"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy"})

-- Approximate shop prices (beli)
local FRUIT_VALUE = {rocket=5000, spin=7500, blade=30000, spring=60000, bomb=80000, smoke=100000,
    spike=180000, flame=250000, ice=350000, sand=420000, dark=500000, eagle=550000, diamond=600000,
    light=650000, rubber=750000, ghost=940000, magma=960000, quake=1000000, buddha=1200000, love=1300000,
    creation=1400000, spider=1500000, sound=1700000, phoenix=1800000, portal=1900000, rumble=2100000,
    pain=2300000, blizzard=2400000, gravity=2500000, mammoth=2700000, ["t-rex"]=2700000, dough=2800000,
    shadow=2900000, venom=3000000, control=3200000, spirit=3400000, dragon=3500000, leopard=5000000,
    kitsune=8000000}
local function fruitValue(name)
    local l = name:lower()
    for k, v in pairs(FRUIT_VALUE) do if l:find(k, 1, true) then return v end end
    return 0
end

---------------------------------------------------------------------
-- NOTIFICATIONS + DISCORD WEBHOOK
---------------------------------------------------------------------
local httpReq = (syn and syn.request) or http_request or request or (fluxus and fluxus.request)
local function sendWebhook(text)
    if not (state.webhook and httpReq and cfg.webhookUrl:find("discord")) then return end
    task.spawn(function()
        pcall(function()
            httpReq({Url = cfg.webhookUrl, Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({content = "[VOID X] " .. text})})
        end)
    end)
end

local toastHolder = Instance.new("Frame")
toastHolder.Size = UDim2.new(0, 200, 0, 220)
toastHolder.Position = UDim2.new(1, -210, 0, 10)
toastHolder.BackgroundTransparency = 1
toastHolder.Parent = gui
local tl = Instance.new("UIListLayout", toastHolder)
tl.Padding = UDim.new(0, 6)
tl.HorizontalAlignment = Enum.HorizontalAlignment.Right

local function notify(text)
    sendWebhook(text)
    if not state.notifications then return end
    local f = Instance.new("TextLabel")
    f.Size = UDim2.new(0, 190, 0, 34)
    f.BackgroundColor3 = C.panel
    f.Text = text
    f.Font = Enum.Font.GothamBold
    f.TextSize = 11
    f.TextWrapped = true
    f.TextColor3 = C.text
    f.Parent = toastHolder
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", f)
    s.Color, s.Thickness = C.pink, 1
    task.delay(4, function() if f.Parent then f:Destroy() end end)
end

---------------------------------------------------------------------
-- EXTRA UI COMPONENTS
---------------------------------------------------------------------
local function makeInput(page, placeholder, default, onSubmit)
    local row = makeRow(page)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -16, 0, 22)
    box.Position = UDim2.new(0, 8, 0.5, -11)
    box.BackgroundColor3 = C.off
    box.Text = default or ""
    box.PlaceholderText = placeholder
    box.PlaceholderColor3 = C.dim
    box.TextColor3 = C.text
    box.Font = Enum.Font.Gotham
    box.TextSize = 11
    box.ClearTextOnFocus = false
    box.Parent = row
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 7)
    box.FocusLost:Connect(function() onSubmit(box.Text) end)
    return box
end

local function makeList(page)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 0)
    holder.AutomaticSize = Enum.AutomaticSize.Y
    holder.BackgroundTransparency = 1
    holder.LayoutOrder = nextOrder()
    holder.Parent = page
    local layout = Instance.new("UIListLayout", holder)
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    return function(items, onPick)
        for _, c in ipairs(holder:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for i, it in ipairs(items) do
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 28)
            b.LayoutOrder = i
            b.BackgroundColor3 = C.off
            b.Text = it.label
            b.Font = Enum.Font.GothamBold
            b.TextSize = 11
            b.TextColor3 = C.text
            b.TextTruncate = Enum.TextTruncate.AtEnd
            b.AutoButtonColor = false
            b.Parent = holder
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            b.MouseButton1Click:Connect(function() onPick(it) end)
        end
    end
end

local autoPage = newTab("Auto", 6)
local fruitPage = newTab("Fruits", 7)
local tpPage = newTab("Teleport", 8)
local playerPage = newTab("Player", 9)
local settingsPage = newTab("Settings", 10)

---------------------------------------------------------------------
-- TELEPORT HELPERS
---------------------------------------------------------------------
local function tpTo(pos)
    local root, char = getRoot()
    if not root then return end
    task.spawn(function()
        local c = RunService.Stepped:Connect(function()
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end)
        flyTo(root, pos, function() return running end)
        c:Disconnect()
    end)
end

local function getMirage()
    local m = workspace:FindFirstChild("Map")
    return m and m:FindFirstChild("MysticIsland")
end

---------------------------------------------------------------------
-- AUTO TAB
---------------------------------------------------------------------
makeSection(autoPage, "BOSSES / MOBS")
makeToggle(autoPage, "Auto Farm Boss", "boss")
makeToggle(autoPage, "Auto Farm Elite Pirates", "elite")
makeToggle(autoPage, "Auto Farm Bones (Sea 3)", "bones")

makeSection(autoPage, "MASTERY FARM (grinds with that type)")
local function masteryFarm(typeName)
    cfg.weaponType, cfg.weaponName = typeName, nil
    typeBtn.Text = "Weapon Type: " .. typeName
    if onTabSelected.Config then onTabSelected.Config() end
    setToggle("grind", true)
    notify("Mastery farm: " .. typeName)
end
makeButton(autoPage, "Fighting Style Mastery", function() masteryFarm("Melee") end)
makeButton(autoPage, "Sword Mastery", function() masteryFarm("Sword") end)
makeButton(autoPage, "Gun Mastery", function() masteryFarm("Gun") end)
makeButton(autoPage, "Fruit Mastery", function() masteryFarm("Blox Fruit") end)

makeSection(autoPage, "PROGRESSION")
makeToggle(autoPage, "Auto Distribute Stats", "autostats")
local STATS = {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"}
local statBtn
statBtn = makeButton(autoPage, "Stat: " .. cfg.stat, function()
    local i = table.find(STATS, cfg.stat) or 1
    cfg.stat = STATS[i % #STATS + 1]
    statBtn.Text = "Stat: " .. cfg.stat
end)
makeToggle(autoPage, "Auto Buy Haki / Abilities", "autohaki")
makeButton(autoPage, "Buy Geppo", function() notify("Geppo: " .. tostring(invoke("BuyHaki", "Geppo"))) end)
makeButton(autoPage, "Buy Buso", function() notify("Buso: " .. tostring(invoke("BuyHaki", "Buso"))) end)
makeButton(autoPage, "Buy Soru", function() notify("Soru: " .. tostring(invoke("BuyHaki", "Soru"))) end)

makeSection(autoPage, "BUY FIGHTING STYLES (tap one)")
local fillStyles = makeList(autoPage)
fillStyles({
    {label="Black Leg", r="BuyBlackLeg"}, {label="Electro", r="BuyElectro"},
    {label="Fishman Karate", r="BuyFishmanKarate"}, {label="Dragon Claw", r="BuyDragonClaw"},
    {label="Superhuman", r="BuySuperhuman"}, {label="Death Step", r="BuyDeathStep"},
    {label="Sharkman Karate", r="BuySharkmanKarate"}, {label="Electric Claw", r="BuyElectricClaw"},
    {label="Dragon Talon", r="BuyDragonTalon"}, {label="Godhuman", r="BuyGodhuman"},
}, function(it) notify(it.label .. ": " .. tostring(invoke(it.r))) end)

local function matching(names)
    local out = {}
    for _, m in ipairs(aliveMobs()) do if names[m.Name] then table.insert(out, m) end end
    return out
end
local function nearestOf(list, root)
    local best, bd
    for _, m in ipairs(list) do
        local d = (m.HumanoidRootPart.Position - root.Position).Magnitude
        if not bd or d < bd then best, bd = m, d end
    end
    return best
end

local lastElite = 0
task.spawn(function()
    while running do
        task.wait(0.2)
        try("autofarm", function()
            local root = getRoot()
            if not root or state.level or state.grind or state.chest or state.fruit then return end
            local flag, names, label
            if state.boss then flag, names, label = "boss", BOSS, "Boss"
            elseif state.elite then flag, names, label = "elite", ELITE, "Elite"
            elseif state.bones then flag, names, label = "bones", BONES, "Bones"
            else return end
            local m = nearestOf(matching(names), root)
            if m then
                refreshUI(label .. ": " .. m.Name)
                flyTo(root, m.HumanoidRootPart.Position + Vector3.new(0, cfg.height, 0),
                    function() return state[flag] and m.Parent end)
                attackMob(m, flag)
            elseif flag == "elite" then
                if tick() - lastElite > 15 then
                    lastElite = tick()
                    refreshUI("Elite quest: " .. tostring(invoke("EliteHunter")))
                end
                task.wait(1)
            elseif flag == "bones" then
                if SEA == 3 then
                    flyTo(root, Vector3.new(-9479, 170, 5566), function() return state.bones and #matching(names) == 0 end)
                else
                    refreshUI("Bones farm is Sea 3 only")
                end
                task.wait(1)
            else
                refreshUI("Boss: none spawned")
                task.wait(2)
            end
        end)
    end
end)

keep(RunService.Stepped:Connect(function()
    local farming = (state.boss or state.elite or state.bones) and state.noclip
    if not (state.noclipall or farming) then return end
    local _, char = getRoot()
    if char then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end))

task.spawn(function()
    local lastHaki = 0
    while running do
        task.wait(3)
        try("stats", function()
            if state.autostats then
                local pts = player.Data.Points.Value
                if pts > 0 then invoke("AddPoint", cfg.stat, pts) end
            end
            if state.autohaki and tick() - lastHaki > 20 then
                lastHaki = tick()
                for _, h in ipairs({"Geppo", "Buso", "Soru"}) do invoke("BuyHaki", h) task.wait(0.5) end
            end
        end)
    end
end)

---------------------------------------------------------------------
-- FRUITS TAB
---------------------------------------------------------------------
makeSection(fruitPage, "FINDING")
makeToggle(fruitPage, "Fruit Notifier", "notifyfruit")
makeToggle(fruitPage, "Fruit Sniper (auto + hop)", "sniper")
makeButton(fruitPage, "Fruit Finder (go to nearest)", function()
    local root = getRoot()
    if not root then return end
    local f = nearest(getFruits(), root)
    if f then
        tpTo(posOf(f) + Vector3.new(0, 3, 0))
        notify("Going to " .. f.Name)
    else
        notify("No fruit loaded")
    end
end)
local fruitTimerLbl = makeInfo(fruitPage)
local fruitValueLbl = makeInfo(fruitPage)

makeSection(fruitPage, "SHOP / INVENTORY")
local fillStock = makeList(fruitPage)
makeButton(fruitPage, "Check Shop Stock", function()
    task.spawn(function()
        local res = invoke("GetFruits")
        if type(res) ~= "table" then notify("Stock check failed") return end
        local items = {}
        for _, f in ipairs(res) do
            if type(f) == "table" and f.OnSale then
                table.insert(items, {label = ("%s  $%s"):format(tostring(f.Name), fmt(f.Price))})
            end
        end
        fillStock(items, function() end)
        notify(#items .. " fruits on sale")
    end)
end)
makeButton(fruitPage, "Fruit Inventory", function()
    task.spawn(function()
        local res = invoke("getInventoryFruits")
        if type(res) ~= "table" then notify("Inventory check failed") return end
        local items = {}
        for _, f in ipairs(res) do
            table.insert(items, {label = type(f) == "table" and tostring(f.Name) or tostring(f)})
        end
        fillStock(items, function() end)
        notify(#items .. " fruits stored")
    end)
end)
makeButton(fruitPage, "Random Fruit (spends beli)", function()
    notify("Random fruit: " .. tostring(invoke("Cousin", "Buy")))
end)
makeButton(fruitPage, "Find Fruit Dealer", function()
    local npcs = workspace:FindFirstChild("NPCs")
    if npcs then
        for _, n in ipairs(npcs:GetChildren()) do
            if n.Name:lower():find("dealer") then
                local p = posOf(n)
                if p then
                    tpTo(p + Vector3.new(0, 4, 0))
                    notify("Going to " .. n.Name)
                    return
                end
            end
        end
    end
    notify("Dealer not loaded (fly near first)")
end)

local seenFruit = setmetatable({}, {__mode = "k"})
local lastFruitSeen, fruitMissingSince = nil, tick()
task.spawn(function()
    while running do
        task.wait(1)
        try("fruits", function()
            local fruits, total = getFruits(), 0
            for _, f in ipairs(fruits) do
                local v = fruitValue(f.Name)
                total += v
                if not seenFruit[f] then
                    seenFruit[f] = true
                    if state.notifyfruit then notify(("Fruit: %s ($%s)"):format(f.Name, fmt(v))) end
                end
            end
            if #fruits > 0 then
                lastFruitSeen, fruitMissingSince = tick(), nil
            else
                fruitMissingSince = fruitMissingSince or tick()
            end
            if state.sniper then
                if not state.fruit then setToggle("fruit", true) end
                if fruitMissingSince and tick() - fruitMissingSince > 6 then
                    fruitMissingSince = nil
                    task.spawn(serverHop)
                end
            end
            fruitTimerLbl.Text = lastFruitSeen
                and ("Last fruit seen %dm ago"):format(math.floor((tick() - lastFruitSeen) / 60))
                or "No fruit seen this session"
            fruitValueLbl.Text = ("On map: %d fruits (~$%s)"):format(#fruits, fmt(total))
        end)
    end
end)

---------------------------------------------------------------------
-- TELEPORT TAB
---------------------------------------------------------------------
makeSection(tpPage, "ISLANDS (this sea)")
local islands, seenI = {}, {}
for _, q in ipairs(QUESTS) do
    local k = tostring(q[6])
    if not seenI[k] then
        seenI[k] = true
        table.insert(islands, {label = ("%s area (Lv %d+)"):format(q[3], q[1]), pos = q[6] + Vector3.new(0, 40, 0)})
    end
end
if SEA == 3 then table.insert(islands, {label = "Haunted Castle", pos = Vector3.new(-9479, 170, 5566)}) end
local fillIslands = makeList(tpPage)
fillIslands(islands, function(it)
    tpTo(it.pos)
    notify("Flying to " .. it.label)
end)

makeSection(tpPage, "MIRAGE / EVENTS")
makeButton(tpPage, "Teleport to Mirage Island", function()
    local m = getMirage()
    if m then tpTo(posOf(m) + Vector3.new(0, 200, 0)) else notify("Mirage Island not spawned") end
end)
makeButton(tpPage, "Find Blue Gear", function()
    local m = getMirage()
    if m then
        for _, d in ipairs(m:GetDescendants()) do
            if d:IsA("BasePart") and d.Name:lower():find("gear") then
                tpTo(d.Position + Vector3.new(0, 5, 0))
                notify("Going to " .. d.Name)
                return
            end
        end
    end
    notify("No gear found")
end)

makeSection(tpPage, "COORDINATES")
makeInput(tpPage, "x, y, z", "", function(text)
    local x, y, z = text:match("(-?[%d%.]+)[,%s]+(-?[%d%.]+)[,%s]+(-?[%d%.]+)")
    if x then
        tpTo(Vector3.new(tonumber(x) or 0, tonumber(y) or 0, tonumber(z) or 0))
    else
        notify("Use format: x, y, z")
    end
end)

makeSection(tpPage, "TELEPORT TO PLAYER")
local fillPlayers = makeList(tpPage)
local function refreshPlayers()
    local items = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then table.insert(items, {label = p.Name, plr = p}) end
    end
    fillPlayers(items, function(it)
        local hrp = it.plr.Character and it.plr.Character:FindFirstChild("HumanoidRootPart")
        if hrp then tpTo(hrp.Position + Vector3.new(0, 5, 0)) else notify("Player not loaded") end
    end)
end
makeButton(tpPage, "Refresh Player List", refreshPlayers)

makeSection(tpPage, "SERVER FINDER")
local fillServers = makeList(tpPage)
makeButton(tpPage, "Find Servers", function()
    notify("Fetching servers...")
    task.spawn(function()
        local ok, data = pcall(function()
            local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=50"):format(game.PlaceId)
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        if not (ok and data and data.data) then notify("Server list failed") return end
        local items = {}
        for _, s in ipairs(data.data) do
            if s.id ~= game.JobId then
                table.insert(items, {label = ("%d/%d players | ping %s"):format(s.playing, s.maxPlayers, tostring(s.ping or "?")), id = s.id})
            end
        end
        fillServers(items, function(it)
            pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, it.id, player) end)
        end)
    end)
end)

---------------------------------------------------------------------
-- PLAYER TAB (movement + performance)
---------------------------------------------------------------------
makeSection(playerPage, "MOVEMENT")
makeToggle(playerPage, "Fly (move + look up/down)", "fly")
makeStepper(playerPage, function() return "Fly Speed: " .. cfg.flySpeed end, function(d)
    cfg.flySpeed = math.clamp(cfg.flySpeed + d, 20, 200)
end, 10)
makeToggle(playerPage, "Walk on Water", "waterwalk")
makeToggle(playerPage, "No Clip (always)", "noclipall")
makeToggle(playerPage, "Custom WalkSpeed", "customwalk")
makeStepper(playerPage, function() return "WalkSpeed: " .. cfg.walk end, function(d)
    cfg.walk = math.clamp(cfg.walk + d, 16, 200)
end, 10)
makeToggle(playerPage, "Custom Jump Power", "customjump")
makeStepper(playerPage, function() return "Jump Power: " .. cfg.jump end, function(d)
    cfg.jump = math.clamp(cfg.jump + d, 50, 300)
end, 10)

local flyBV
onChange("fly", function(on)
    if not on and flyBV then
        flyBV:Destroy()
        flyBV = nil
    end
end)
keep(RunService.Heartbeat:Connect(function()
    if not state.fly then return end
    local root, _, hum = getRoot()
    if not root then return end
    if not flyBV or flyBV.Parent ~= root then
        if flyBV then flyBV:Destroy() end
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        flyBV.Velocity = Vector3.zero
        flyBV.Parent = root
    end
    local look = workspace.CurrentCamera.CFrame.LookVector
    local md = hum.MoveDirection
    local vel = md * cfg.flySpeed
    local flat = Vector3.new(look.X, 0, look.Z)
    if flat.Magnitude > 0.01 and md.Magnitude > 0.01 then
        vel += Vector3.new(0, look.Y * cfg.flySpeed * md:Dot(flat.Unit), 0)
    end
    if hum.Jump then vel += Vector3.new(0, cfg.flySpeed, 0) end
    flyBV.Velocity = vel
end))

local waterOrig
onChange("waterwalk", function(on)
    local map = workspace:FindFirstChild("Map")
    local plane = map and map:FindFirstChild("WaterBase-Plane")
    if not plane then notify("Water plane not found") return end
    waterOrig = waterOrig or plane.Size
    plane.Size = on and Vector3.new(waterOrig.X, 112, waterOrig.Z) or waterOrig
    plane.CanCollide = true
end)

task.spawn(function()
    while running do
        task.wait(0.3)
        try("walkjump", function()
            local _, _, hum = getRoot()
            if not hum then return end
            if state.customwalk then hum.WalkSpeed = cfg.walk end
            if state.customjump then
                hum.UseJumpPower = true
                hum.JumpPower = cfg.jump
            end
        end)
    end
end)

makeSection(playerPage, "SERVER / PERFORMANCE")
makeToggle(playerPage, "Auto Rejoin on Kick", "autorejoin")
keep(GuiService.ErrorMessageChanged:Connect(function(msg)
    if state.autorejoin and msg and msg ~= "" then
        task.wait(2)
        pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
    end
end))
makeToggle(playerPage, "Reduce Graphics", "lowgfx")
makeToggle(playerPage, "Performance Mode (30fps cap)", "perf")
makeButton(playerPage, "FPS Booster (one-way)", function()
    task.spawn(function()
        local n = 0
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") then
                d.Enabled = false
            elseif d:IsA("Decal") or d:IsA("Texture") then
                d.Transparency = 1
            elseif d:IsA("BasePart") then
                d.Material = Enum.Material.SmoothPlastic
                d.CastShadow = false
            end
            n += 1
            if n % 400 == 0 then task.wait() end
        end
        notify("FPS booster applied (rejoin to undo)")
    end)
end)

local gfxOrig
onChange("lowgfx", function(on)
    if on then
        gfxOrig = gfxOrig or {shadows = Lighting.GlobalShadows, quality = settings().Rendering.QualityLevel}
        Lighting.GlobalShadows = false
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    elseif gfxOrig then
        Lighting.GlobalShadows = gfxOrig.shadows
        settings().Rendering.QualityLevel = gfxOrig.quality
    end
end)
onChange("perf", function(on)
    if setfpscap then setfpscap(on and 30 or 60) end
    setToggle("lowgfx", on)
end)

makeSection(playerPage, "BOUNTY CHECKER")
local fillBounty = makeList(playerPage)
makeButton(playerPage, "Check Bounties", function()
    local items = {}
    for _, p in ipairs(Players:GetPlayers()) do
        local ok, b = pcall(function() return p.leaderstats["Bounty/Honor"].Value end)
        table.insert(items, {label = ("%s  %s"):format(p.Name, ok and fmt(b) or "?"), b = ok and b or 0})
    end
    table.sort(items, function(a, b) return a.b > b.b end)
    fillBounty(items, function() end)
end)

---------------------------------------------------------------------
-- ESP ENGINE (one loop, many kinds)
---------------------------------------------------------------------
local function folderItems(parent, filter)
    local out = {}
    if parent then
        for _, o in ipairs(parent:GetChildren()) do
            local part = partOf(o)
            if part and (not filter or filter(o)) then table.insert(out, {part, o.Name}) end
        end
    end
    return out
end
local function mobItems(names)
    local out = {}
    for _, m in ipairs(matching(names)) do table.insert(out, {m.HumanoidRootPart, m.Name}) end
    return out
end

local ESPS = {
    {key="espplayer", name="PlayerESP", color=Color3.fromRGB(255, 80, 80), find=function()
        local out = {}
        for _, p in ipairs(Players:GetPlayers()) do
            local ch = p ~= player and p.Character
            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
            if hrp then
                local hum = ch:FindFirstChildOfClass("Humanoid")
                table.insert(out, {hrp, p.Name .. (hum and (" HP " .. math.floor(hum.Health)) or "")})
            end
        end
        return out
    end},
    {key="espnpc", name="NPCESP", color=Color3.fromRGB(120, 220, 255), find=function()
        return folderItems(workspace:FindFirstChild("NPCs"))
    end},
    {key="espisland", name="IslandESP", color=Color3.fromRGB(120, 255, 160), find=function()
        return folderItems(workspace:FindFirstChild("Map"))
    end},
    {key="espboss", name="BossESP", color=Color3.fromRGB(255, 120, 60), find=function() return mobItems(BOSS) end},
    {key="espelite", name="EliteESP", color=Color3.fromRGB(255, 60, 200), find=function() return mobItems(ELITE) end},
    {key="espflower", name="FlowerESP", color=Color3.fromRGB(255, 160, 220), find=function()
        local out = {}
        for _, o in ipairs(workspace:GetChildren()) do
            if o.Name:match("^Flower%d") then
                local p = partOf(o)
                if p then table.insert(out, {p, o.Name}) end
            end
        end
        return out
    end},
    {key="espseabeast", name="SeaBeastESP", color=Color3.fromRGB(80, 160, 255), find=function()
        return folderItems(workspace:FindFirstChild("SeaBeasts"))
    end},
    {key="espmirage", name="MirageESP", color=Color3.fromRGB(180, 140, 255), find=function()
        local m = getMirage()
        local p = m and partOf(m)
        return p and {{p, "Mirage Island"}} or {}
    end},
    {key="espgear", name="GearESP", color=Color3.fromRGB(90, 200, 255), find=function()
        local out, m = {}, getMirage()
        if m then
            for _, d in ipairs(m:GetDescendants()) do
                if d:IsA("BasePart") and d.Name:lower():find("gear") and #out < 10 then
                    table.insert(out, {d, d.Name})
                end
            end
        end
        return out
    end},
    {key="espweapon", name="WeaponESP", color=Color3.fromRGB(255, 220, 90), find=function()
        local out = {}
        for _, o in ipairs(workspace:GetChildren()) do
            if o:IsA("Tool") and not o.Name:find("Fruit") and o:FindFirstChild("Handle") then
                table.insert(out, {o.Handle, o.Name})
            end
        end
        return out
    end},
}

makeSection(visualPage, "MORE ESP")
local ESP_LABELS = {espplayer="Player ESP", espnpc="NPC ESP", espisland="Island ESP", espboss="Boss ESP",
    espelite="Elite Hunter ESP", espflower="Flower ESP", espseabeast="Sea Beast ESP", espmirage="Mirage ESP",
    espgear="Blue Gear ESP", espweapon="Weapon ESP"}
for _, k in ipairs(ESPS) do makeToggle(visualPage, ESP_LABELS[k.key], k.key) end

local espTags = {}
local function clearKind(key)
    for _, tag in pairs(espTags[key] or {}) do pcall(function() tag:Destroy() end) end
    espTags[key] = {}
end
task.spawn(function()
    while running do
        task.wait(0.5)
        local root = getRoot()
        for _, k in ipairs(ESPS) do
            espTags[k.key] = espTags[k.key] or {}
            if state[k.key] then
                try(k.key, function()
                    local live = {}
                    for _, it in ipairs(k.find()) do
                        local part = it[1]
                        if part and part.Parent then
                            live[part] = true
                            local tag = espTags[k.key][part]
                            if not tag or not tag.Parent then
                                tag = Instance.new("BillboardGui")
                                tag.Name = k.name
                                tag.Size = UDim2.new(0, 150, 0, 40)
                                tag.AlwaysOnTop = true
                                tag.StudsOffset = Vector3.new(0, 3, 0)
                                tag.Parent = part
                                local t = Instance.new("TextLabel")
                                t.Name = "T"
                                t.Size = UDim2.new(1, 0, 1, 0)
                                t.BackgroundTransparency = 1
                                t.Font = Enum.Font.GothamBold
                                t.TextSize = 13
                                t.TextColor3 = k.color
                                t.TextStrokeTransparency = 0
                                t.Parent = tag
                                espTags[k.key][part] = tag
                            end
                            local d = root and math.floor((part.Position - root.Position).Magnitude) or 0
                            tag.T.Text = ("%s\n[%dm]"):format(it[2], d)
                        end
                    end
                    for part, tag in pairs(espTags[k.key]) do
                        if not live[part] then
                            tag:Destroy()
                            espTags[k.key][part] = nil
                        end
                    end
                end)
            elseif next(espTags[k.key]) then
                clearKind(k.key)
            end
        end
    end
end)

---------------------------------------------------------------------
-- EVENT WATCHER (Mirage, sea beasts, boss spawns)
---------------------------------------------------------------------
makeSection(miscPage, "EVENTS")
makeToggle(miscPage, "Event Notifier", "events")
task.spawn(function()
    local hadMirage, lastBeasts = getMirage() ~= nil, 0
    local seenBoss = setmetatable({}, {__mode = "k"})
    while running do
        task.wait(2)
        try("events", function()
            if not state.events then return end
            local mirage = getMirage() ~= nil
            if mirage and not hadMirage then notify("Mirage Island spawned!") end
            hadMirage = mirage
            local sb = workspace:FindFirstChild("SeaBeasts")
            local count = sb and #sb:GetChildren() or 0
            if count > lastBeasts then notify("Sea beast spawned!") end
            lastBeasts = count
            for _, m in ipairs(matching(BOSS)) do
                if not seenBoss[m] then
                    seenBoss[m] = true
                    notify("Boss spawned: " .. m.Name)
                end
            end
        end)
    end
end)

---------------------------------------------------------------------
-- INFO TAB ADDITIONS
---------------------------------------------------------------------
makeSection(infoPage, "PLAYER")
local infoWealth = makeInfo(infoPage)
local infoRace = makeInfo(infoPage)
makeSection(infoPage, "SERVER + SESSION")
local infoServer = makeInfo(infoPage)
local infoSession = makeInfo(infoPage)
local infoErr = makeInfo(infoPage)

local function dv(name)
    local ok, v = pcall(function() return player.Data[name].Value end)
    return ok and v or "?"
end
task.spawn(function()
    while running do
        task.wait(1)
        try("info", function()
            local okB, bounty = pcall(function() return player.leaderstats["Bounty/Honor"].Value end)
            infoWealth.Text = ("Beli %s | Frags %s | Bounty %s"):format(fmt(dv("Beli")), fmt(dv("Fragments")), okB and fmt(bounty) or "?")
            infoRace.Text = ("Race %s | Fruit %s"):format(tostring(dv("Race")), tostring(dv("DevilFruit")))
            infoServer.Text = ("Players %d/%d | Ping %dms | Up %dm"):format(#Players:GetPlayers(), Players.MaxPlayers,
                math.floor(player:GetNetworkPing() * 1000), math.floor(workspace.DistributedGameTime / 60))
            local mins = math.max((tick() - startTime) / 60, 0.01)
            infoSession.Text = ("Session %dm | Kills/hr %d"):format(math.floor(mins), math.floor(stats.kills / mins * 60))
            infoErr.Text = "Last error: " .. lastError
        end)
    end
end)

---------------------------------------------------------------------
-- SETTINGS TAB (config, theme, keybind, webhook, updates)
---------------------------------------------------------------------
local CONFIG_FILE = "VoidX_BloxFruits.json"
local canFile = writefile and readfile and isfile

local THEMES = {
    {name="Void",  purple=Color3.fromRGB(150, 60, 255), pink=Color3.fromRGB(255, 45, 185)},
    {name="Blood", purple=Color3.fromRGB(150, 20, 40),  pink=Color3.fromRGB(255, 60, 60)},
    {name="Ocean", purple=Color3.fromRGB(30, 100, 220), pink=Color3.fromRGB(0, 220, 255)},
    {name="Toxic", purple=Color3.fromRGB(20, 140, 60),  pink=Color3.fromRGB(120, 255, 60)},
}
local function same(a, b) return (a.R - b.R)^2 + (a.G - b.G)^2 + (a.B - b.B)^2 < 0.0004 end
local function applyTheme(idx)
    local t = THEMES[idx]
    if not t then return end
    local oldP, oldK, newP, newK = C.pink, C.purple, t.pink, t.purple
    for _, d in ipairs(gui:GetDescendants()) do
        for _, prop in ipairs({"BackgroundColor3", "TextColor3", "Color", "ScrollBarImageColor3"}) do
            pcall(function()
                local v = d[prop]
                if typeof(v) == "Color3" then
                    if same(v, oldP) then d[prop] = newP elseif same(v, oldK) then d[prop] = newK end
                end
            end)
        end
        if d:IsA("UIGradient") then
            local kps = {}
            for _, kp in ipairs(d.Color.Keypoints) do
                local c = kp.Value
                if same(c, oldP) then c = newP elseif same(c, oldK) then c = newK end
                table.insert(kps, ColorSequenceKeypoint.new(kp.Time, c))
            end
            d.Color = ColorSequence.new(kps)
        end
    end
    C.pink, C.purple = newP, newK
    cfg.theme = idx
end

local function snapshot()
    return HttpService:JSONEncode({state = state, cfg = cfg, speed = speed})
end
local function saveConfig(silent)
    if not canFile then
        if not silent then notify("Executor has no file access") end
        return
    end
    local ok = pcall(function() writefile(CONFIG_FILE, snapshot()) end)
    if not silent then notify(ok and "Config saved" or "Save failed") end
end
local function loadConfig(silent)
    if not (canFile and isfile(CONFIG_FILE)) then
        if not silent then notify("No saved config") end
        return
    end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(CONFIG_FILE)) end)
    if not (ok and type(data) == "table") then notify("Config unreadable") return end
    for k, v in pairs(data.state or {}) do
        if state[k] ~= nil and type(v) == "boolean" then setToggle(k, v) end
    end
    local savedTheme = (data.cfg or {}).theme
    for k, v in pairs(data.cfg or {}) do
        if (cfg[k] ~= nil or k == "weaponName") and k ~= "theme" then cfg[k] = v end
    end
    if tonumber(data.speed) then speed = math.clamp(data.speed, 100, 400) end
    if savedTheme and savedTheme ~= cfg.theme then applyTheme(savedTheme) end
    typeBtn.Text = "Weapon Type: " .. cfg.weaponType
    statBtn.Text = "Stat: " .. cfg.stat
    rebuildWeaponList()
    if not silent then notify("Config loaded") end
end

makeSection(settingsPage, "CONFIG")
makeButton(settingsPage, "Save Configuration", function() saveConfig(false) end)
makeButton(settingsPage, "Load Configuration", function() loadConfig(false) end)
makeToggle(settingsPage, "Auto Save Settings", "autosave")
task.spawn(function()
    local lastSnap
    while running do
        task.wait(10)
        if state.autosave then
            local s = snapshot()
            if s ~= lastSnap then
                lastSnap = s
                saveConfig(true)
            end
        end
    end
end)

makeSection(settingsPage, "UI")
local themeBtn
themeBtn = makeButton(settingsPage, "Theme: " .. THEMES[1].name, function()
    local i = (cfg.theme % #THEMES) + 1
    applyTheme(i)
    themeBtn.Text = "Theme: " .. THEMES[i].name
end)
local KEYS = {"RightShift", "RightControl", "Insert", "Delete", "K"}
local keyBtn
keyBtn = makeButton(settingsPage, "Hide/Show Key (PC): " .. cfg.toggleKey, function()
    local i = table.find(KEYS, cfg.toggleKey) or 1
    cfg.toggleKey = KEYS[i % #KEYS + 1]
    keyBtn.Text = "Hide/Show Key (PC): " .. cfg.toggleKey
end)
keep(UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    local ok, kc = pcall(function() return Enum.KeyCode[cfg.toggleKey] end)
    if ok and input.KeyCode == kc then
        frame.Visible = not frame.Visible
        openBtn.Visible = not frame.Visible
    end
end))

makeSection(settingsPage, "NOTIFICATIONS")
makeToggle(settingsPage, "On-screen Notifications", "notifications")
makeToggle(settingsPage, "Discord Webhook", "webhook")
makeInput(settingsPage, "Discord webhook URL", "", function(text) cfg.webhookUrl = text end)
makeButton(settingsPage, "Test Webhook", function()
    if not httpReq then notify("Executor can't send HTTP requests") return end
    sendWebhook("Test message from VOID X")
    notify("Test sent (needs Webhook toggle on)")
end)

makeSection(settingsPage, "CONTROL")
local FARM_KEYS = {"chest", "level", "grind", "fruit", "boss", "elite", "bones", "sniper"}
makeButton(settingsPage, "Stop All Farming", function()
    for _, k in ipairs(FARM_KEYS) do setToggle(k, false) end
    notify("All farming stopped")
end)
makeButton(settingsPage, "Start Core Farm", function()
    for _, k in ipairs({"chest", "fruit", "level"}) do setToggle(k, true) end
    notify("Chest + Fruit + Level started")
end)
makeButton(settingsPage, "Check for Updates", function()
    task.spawn(function()
        local ok, src = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/cashmaster2000/VOIDX-CLIENT/refs/heads/main/voidx.lua")
        end)
        if not ok then notify("Update check failed") return end
        local remote = src:match('local VERSION = "([%d%.]+)"')
        if not remote then
            notify("No version tag in remote file")
        elseif remote ~= VERSION then
            notify("Update available: v" .. remote)
        else
            notify("Up to date (v" .. VERSION .. ")")
        end
    end)
end)

-- Unload cleanup for the new features
local baseDestroy = destroyGui
destroyGui = function()
    for key in pairs(espTags) do pcall(clearKind, key) end
    pcall(function() if flyBV then flyBV:Destroy() end end)
    pcall(function() toastHolder:Destroy() end)
    baseDestroy()
end

loadConfig(true)
end

-- A failure inside the module pack must never kill the base hub.
local packOk, packErr = pcall(loadModulePack)
if not packOk then
    warn("[VOID X] module pack error: " .. tostring(packErr))
    refreshUI("Module pack error (see console)")
end

rebuildWeaponList()
if packOk then refreshUI("Ready (Sea " .. SEA .. ")") end
