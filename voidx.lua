
-- VOID X CLIENT v2 | Tabbed GUI + Config | Blox Fruits (Sea 1/2/3)
-- Features: Auto Level, Grind, Chests, Fruits (+store), Auto Raid, Chalice Finder,
-- Elite Hunter, Cocoa Grinder, Auto Stats, Auto Haki, ESP, Server Hop, config saving.
-- Toggle GUI with the hide key (default RightControl).

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")

local genv = (getgenv and getgenv()) or _G
if genv.VoidXUnload then pcall(genv.VoidXUnload) end

local player = Players.LocalPlayer
local running = true
local CFG_FILE = "VoidXClient_v2.json"

local state = {
    -- farming
    chest=false, level=false, grind=false, fruit=false, store=false,
    raid=false, raidstart=true, awaken=false,
    chalice=false, elite=false, cocoa=false,
    -- visuals
    fruitesp=false, chestesp=false, fpsboost=false,
    -- misc
    hop=false, antiafk=true, noclip=true, fastattack=true, autoclick=true,
    bring=false, buso=true, autostats=false, infjump=false, autorejoin=true,
}
local cfg = {
    weaponType = "Melee", weaponName = "", height = 10, speed = 250,
    walkspeed = 16, raidType = "Flame", cocoaIdx = 0, statKey = "Melee",
    hopDelay = 30, toggleKey = "RightControl",
}
local WEAPON_TYPES = {"Melee", "Sword", "Gun", "Blox Fruit"}
local RAID_TYPES = {"Flame","Ice","Quake","Light","Dark","Spider","Rumble","Magma","Buddha","Sand","Phoenix","Dough"}
local STAT_KEYS = {"Melee","Defense","Sword","Gun","Demon Fruit"}
local HIDE_KEYS = {"RightControl","RightShift","Insert","Delete","End"}
local stats = {chests = 0, fruits = 0, kills = 0, raids = 0, chalices = 0}

---------------------------------------------------------------------
-- CONFIG SAVE / LOAD
---------------------------------------------------------------------
local function saveCfg()
    if not writefile then return end
    pcall(function()
        writefile(CFG_FILE, HttpService:JSONEncode({state = state, cfg = cfg}))
    end)
end
local function loadCfg()
    if not (readfile and isfile) then return end
    pcall(function()
        if not isfile(CFG_FILE) then return end
        local data = HttpService:JSONDecode(readfile(CFG_FILE))
        for k, v in pairs(data.state or {}) do
            if state[k] ~= nil and type(v) == "boolean" then state[k] = v end
        end
        for k, v in pairs(data.cfg or {}) do
            if cfg[k] ~= nil and type(v) == type(cfg[k]) then cfg[k] = v end
        end
    end)
end
loadCfg()

local conns = {}
local function keep(c) table.insert(conns, c) return c end

keep(player.Idled:Connect(function()
    if state.antiafk then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end))

---------------------------------------------------------------------
-- REMOTES
---------------------------------------------------------------------
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 15)
local CommF = Remotes and Remotes:WaitForChild("CommF_", 15)
local function comm(...)
    if not CommF then return nil end
    local args = table.pack(...)
    local ok, res = pcall(function() return CommF:InvokeServer(table.unpack(args, 1, args.n)) end)
    if ok then return res end
    return nil
end

-- Best-effort fast attack remotes (these change between game updates; clicking is the fallback)
local RegisterAttack, RegisterHit
pcall(function()
    local net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
    RegisterAttack = net and net:FindFirstChild("RE/RegisterAttack")
    RegisterHit = net and net:FindFirstChild("RE/RegisterHit")
end)

local Enemies = Workspace:FindFirstChild("Enemies") or Workspace:WaitForChild("Enemies", 15)

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
    Q(2525,9999,"Isle Champion","TikiQuest2",2,-16541,54,1051)
end
table.sort(QUESTS, function(a, b) return a[1] < b[1] end)

-- binary search by level
local function getQuest(lvl)
    local lo, hi = 1, #QUESTS
    while lo <= hi do
        local mid = (lo + hi) // 2
        local q = QUESTS[mid]
        if lvl < q[1] then hi = mid - 1
        elseif lvl > q[2] then lo = mid + 1
        else return q end
    end
    return QUESTS[math.clamp(hi, 1, #QUESTS)]
end

local COCOA = {}
for _, q in ipairs(QUESTS) do
    if q[4] == "ChocQuest1" or q[4] == "ChocQuest2" then table.insert(COCOA, q) end
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
local W, H, HEAD = 380, 300, 38
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

local uiScale = Instance.new("UIScale", frame)
uiScale.Scale = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) and 0.85 or 1

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

local currentStatus = "Ready"
local function setStatus(t)
    currentStatus = t
    headStatus.Text = t
end

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
local raidPage = newTab("Raid", 2)
local huntPage = newTab("Hunt", 3)
local configPage = newTab("Config", 4)
local visualPage = newTab("Visuals", 5)
local miscPage = newTab("Misc", 6)
local infoPage = newTab("Info", 7)

---------------------------------------------------------------------
-- UI COMPONENTS
---------------------------------------------------------------------
local function makeRow(page, height)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, height or 32)
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

local function makeToggle(page, name, key, onChange)
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
 
