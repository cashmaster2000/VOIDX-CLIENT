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

---------------------------------------------------------------------
-- KEY SYSTEM
---------------------------------------------------------------------
-- Keys are stored as hashes, so the plain keys are not in this file.
-- Generate keys + hashes with keygen.py, then paste the hash lines below.
-- Value = expiry as a unix timestamp, or 0 for a key that never expires.
local KEYS = {
    ["6cb2512366dac788"] = 0,
    ["4401aba94fdb11da"] = 0,
    ["e1ad6403133476a4"] = 1798319528, -- expires ~2026-12-26
}
-- Optional: raw-text URL (GitHub raw / pastebin raw) with one entry per line: "hash" or "hash,expiry".
-- Lets you add or revoke keys without editing the script. Leave "" to use only the table above.
local KEY_URL = ""
local KEY_LINK = "https://your-key-link-here" -- shown by the "Get Key" button
local KEY_FILE = "VoidXKey.txt"

local function fnv(s, seed)
    local h = seed
    for i = 1, #s do
        h = bit32.bxor(h, s:byte(i))
        h = ((h % 256) * 16777216 + h * 403) % 4294967296
    end
    return string.format("%08x", h)
end
local function hashKey(k) return fnv(k, 2166136261) .. fnv(k, 0x9747B28C) end

-- returns ok, message
local function checkKey(key)
    key = (key or ""):gsub("%s+", "")
    if key == "" then return false, "Enter a key" end
    local h = hashKey(key)
    local exp = KEYS[h]
    if exp == nil and KEY_URL ~= "" then
        local ok, body = pcall(function() return game:HttpGet(KEY_URL) end)
        if ok and type(body) == "string" then
            for line in body:gmatch("[^\r\n]+") do
                local lh, le = line:match("^%s*(%x+)%s*,?%s*(%d*)")
                if lh == h then exp = tonumber(le) or 0 break end
            end
        elseif not ok then
            return false, "Could not reach key server"
        end
    end
    if exp == nil then return false, "Invalid key" end
    if exp ~= 0 and os.time() > exp then return false, "Key expired" end
    return true, exp == 0 and "Key accepted (lifetime)" or ("Key accepted (expires " .. os.date("%Y-%m-%d", exp) .. ")")
end

local function keyGate()
    -- saved key from a previous run
    if readfile and isfile then
        local ok, saved = pcall(function() return isfile(KEY_FILE) and readfile(KEY_FILE) or nil end)
        if ok and saved and (checkKey(saved)) then return true end
    end

    local parent = (gethui and gethui()) or game:GetService("CoreGui")
    pcall(function()
        local old = parent:FindFirstChild("VoidXKeyGate")
        if old then old:Destroy() end
    end)
    local g = Instance.new("ScreenGui")
    g.Name = "VoidXKeyGate"
    g.ResetOnSpawn = false
    g.Parent = parent

    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 320, 0, 190)
    f.Position = UDim2.new(0.5, -160, 0.5, -95)
    f.BackgroundColor3 = Color3.fromRGB(8, 6, 14)
    f.BorderSizePixel = 0
    f.Parent = g
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 14)
    local st = Instance.new("UIStroke", f)
    st.Thickness, st.Color = 2, Color3.fromRGB(150, 60, 255)

    local function lbl(text, y, h, size, color, font)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -24, 0, h)
        l.Position = UDim2.new(0, 12, 0, y)
        l.BackgroundTransparency = 1
        l.Text, l.TextSize, l.TextColor3 = text, size, color
        l.Font = font or Enum.Font.GothamBold
        l.Parent = f
        return l
    end
    lbl("VOID X CLIENT", 12, 26, 18, Color3.new(1, 1, 1), Enum.Font.GothamBlack)
    local msg = lbl("Enter your key to continue", 40, 18, 12, Color3.fromRGB(145, 128, 175), Enum.Font.Gotham)

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -24, 0, 34)
    box.Position = UDim2.new(0, 12, 0, 68)
    box.BackgroundColor3 = Color3.fromRGB(20, 13, 34)
    box.PlaceholderText = "VX-XXXX-XXXX-XXXX"
    box.Text = ""
    box.ClearTextOnFocus = false
    box.Font, box.TextSize = Enum.Font.GothamBold, 14
    box.TextColor3 = Color3.fromRGB(240, 230, 255)
    box.PlaceholderColor3 = Color3.fromRGB(100, 88, 125)
    box.Parent = f
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 9)

    local function btn(text, x, w, color)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, w, 0, 34)
        b.Position = UDim2.new(0, x, 0, 112)
        b.BackgroundColor3 = color
        b.Text = text
        b.Font, b.TextSize = Enum.Font.GothamBold, 13
        b.TextColor3 = Color3.new(1, 1, 1)
        b.AutoButtonColor = true
        b.Parent = f
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 9)
        return b
    end
    local submit = btn("Submit", 12, 140, Color3.fromRGB(150, 60, 255))
    local getKey = btn("Get Key", 168, 140, Color3.fromRGB(42, 33, 62))
    local closeB = btn("Close", 12, 296, Color3.fromRGB(42, 33, 62))
    closeB.Position = UDim2.new(0, 12, 0, 152)
    closeB.Size = UDim2.new(0, 296, 0, 28)

    local result, busy = nil, false
    submit.MouseButton1Click:Connect(function()
        if busy then return end
        busy = true
        msg.Text = "Checking..."
        local ok, text = checkKey(box.Text)
        msg.Text = text
        msg.TextColor3 = ok and Color3.fromRGB(90, 230, 140) or Color3.fromRGB(255, 90, 110)
        if ok then
            if writefile then pcall(writefile, KEY_FILE, (box.Text:gsub("%s+", ""))) end
            task.wait(0.8)
            result = true
        end
        busy = false
    end)
    getKey.MouseButton1Click:Connect(function()
        if setclipboard then
            pcall(setclipboard, KEY_LINK)
            msg.Text = "Key link copied to clipboard"
        else
            msg.Text = KEY_LINK
        end
        msg.TextColor3 = Color3.fromRGB(145, 128, 175)
    end)
    closeB.MouseButton1Click:Connect(function() result = false end)

    while result == nil and g.Parent do task.wait(0.1) end
    g:Destroy()
    return result == true
end

if not keyGate() then return end

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
        TweenService:Create(ts, info, {Color = on and C.pink or C.purple}):Play()
        TweenService:Create(knob, info, {
            Position = on and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
            BackgroundColor3 = on and Color3.new(1, 1, 1) or C.dim,
        }):Play()
    end
    track.MouseButton1Click:Connect(function()
        state[key] = not state[key]
        apply(state[key])
        if onChange then pcall(onChange, state[key]) end
        saveCfg()
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
            saveCfg()
        end)
    end
    btn("-", -66, -step)
    btn("+", -34, step)
end

local function makeInfo(page, height)
    local row = makeRow(page, height)
    local l = newLabel(row, "", UDim2.new(1, -16, 1, -8), UDim2.new(0, 10, 0, 4), 11, C.text, nil, Enum.Font.Gotham)
    if height and height > 40 then
        l.TextWrapped = true
        l.TextTruncate = Enum.TextTruncate.None
        l.TextYAlignment = Enum.TextYAlignment.Top
    end
    return l
end

local function cycle(list, current)
    local idx = table.find(list, current) or 0
    return list[idx % #list + 1]
end

---------------------------------------------------------------------
-- GAME HELPERS
---------------------------------------------------------------------
local function hrp() local c = player.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function hum() local c = player.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function alive() local h = hum() return h ~= nil and h.Health > 0 end

local function notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = "VOID X", Text = text, Duration = 5})
    end)
end

local function playerLevel()
    local ok, v = pcall(function() return player.Data.Level.Value end)
    return ok and v or 1
end

local function posOf(inst)
    if inst:IsA("BasePart") then return inst.Position end
    return inst:GetPivot().Position
end

-- busy flag drives hover + noclip
local busyUntil = 0
local function touch(t) busyUntil = os.clock() + (t or 1.5) end
local function isBusy() return os.clock() < busyUntil end

local skipUntil = setmetatable({}, {__mode = "k"})
local function skip(obj, secs) skipUntil[obj] = os.clock() + secs end
local function skipped(obj) return (skipUntil[obj] or 0) > os.clock() end

local function touchPart(part)
    local r = hrp()
    if r and part and firetouchinterest then
        pcall(function() firetouchinterest(r, part, 0) firetouchinterest(r, part, 1) end)
    end
end

-- tween movement ------------------------------------------------------
local curTween
local function stopTween()
    if curTween then pcall(function() curTween:Cancel() end) curTween = nil end
end

local function goTo(pos)
    local r = hrp()
    if not r then return false end
    touch()
    local dist = (r.Position - pos).Magnitude
    if dist > 60 then
        stopTween()
        local dur = dist / math.max(cfg.speed, 50)
        local tw = TweenService:Create(r, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
        curTween = tw
        tw:Play()
        local t0 = os.clock()
        while running and alive()
            and tw.PlaybackState ~= Enum.PlaybackState.Completed
            and tw.PlaybackState ~= Enum.PlaybackState.Cancelled
            and os.clock() - t0 < dur + 2 do
            touch()
            task.wait(0.05)
        end
        if curTween ~= tw then return false end
        curTween = nil
    end
    r = hrp()
    if running and r then r.CFrame = CFrame.new(pos) end
    return true
end

-- hover + noclip + walkspeed ------------------------------------------
keep(RunService.Heartbeat:Connect(function()
    local r = hrp()
    if r then
        local bv = r:FindFirstChild("VoidXHover")
        if isBusy() then
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Name = "VoidXHover"
                bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                bv.Velocity = Vector3.zero
                bv.Parent = r
            end
        elseif bv then
            bv:Destroy()
        end
    end
    local h = hum()
    if h and not isBusy() and cfg.walkspeed ~= 16 and h.WalkSpeed ~= cfg.walkspeed then
        h.WalkSpeed = cfg.walkspeed
    end
end))

keep(RunService.Stepped:Connect(function()
    if state.noclip and isBusy() then
        local c = player.Character
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end))

keep(UserInputService.JumpRequest:Connect(function()
    if state.infjump then
        local h = hum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

-- tools / weapons -----------------------------------------------------
local function eachTool(fn)
    for _, container in ipairs({player.Character, player.Backpack}) do
        if container then
            for _, t in ipairs(container:GetChildren()) do
                if t:IsA("Tool") then
                    local r = fn(t)
                    if r then return r end
                end
            end
        end
    end
end

local function findWeapon()
    return eachTool(function(t)
        if cfg.weaponName ~= "" then
            if t.Name == cfg.weaponName then return t end
        elseif t.ToolTip == cfg.weaponType then
            return t
        end
    end)
end

local function equip()
    local t, h = findWeapon(), hum()
    if t and h and t.Parent ~= player.Character then pcall(function() h:EquipTool(t) end) end
end

local function hasToolLike(pattern)
    return eachTool(function(t) if t.Name:find(pattern, 1, true) then return t end end)
end

-- enemies -------------------------------------------------------------
local function valid(e)
    local h = e:FindFirstChildOfClass("Humanoid")
    local r = e:FindFirstChild("HumanoidRootPart")
    if h and r and h.Health > 0 then return r end
end

local function findMob(names, maxDist)
    local r = hrp()
    if not r or not Enemies then return nil end
    local best, bd = nil, maxDist or math.huge
    for _, e in ipairs(Enemies:GetChildren()) do
        if (not names or names[e.Name]) then
            local er = valid(e)
            if er then
                local d = (er.Position - r.Position).Magnitude
                if d < bd then best, bd = e, d end
            end
        end
    end
    return best
end

local function findSpawn(mobName)
    local wo = Workspace:FindFirstChild("_WorldOrigin")
    local sp = wo and wo:FindFirstChild("EnemySpawns")
    local r = hrp()
    if not sp or not r then return nil end
    local best, bd
    for _, s in ipairs(sp:GetChildren()) do
        if s:IsA("BasePart") and s.Name:find(mobName, 1, true) then
            local d = (s.Position - r.Position).Magnitude
            if not bd or d < bd then best, bd = s.Position, d end
        end
    end
    return best
end

pcall(function()
    if sethiddenproperty then sethiddenproperty(player, "SimulationRadius", math.huge) end
end)

local function bringNear(mob)
    local mr = mob:FindFirstChild("HumanoidRootPart")
    if not mr then return end
    for _, e in ipairs(Enemies:GetChildren()) do
        if e ~= mob and e.Name == mob.Name then
            local er = valid(e)
            if er and (er.Position - mr.Position).Magnitude < 300 then
                pcall(function()
                    er.CFrame = mr.CFrame
                    er.CanCollide = false
                    e.Humanoid.WalkSpeed = 0
                end)
            end
        end
    end
end

-- attacking -----------------------------------------------------------
local lastAtk = 0
local function fastHit()
    local r = hrp()
    if not r then return end
    local list, first = {}, nil
    for _, e in ipairs(Enemies:GetChildren()) do
        local er = valid(e)
        if er and (er.Position - r.Position).Magnitude < 70 then
            local part = e:FindFirstChild("Head") or er
            first = first or part
            table.insert(list, {e, part})
        end
    end
    if first then
        RegisterAttack:FireServer(0)
        RegisterHit:FireServer(first, list)
    end
end

local function attackOnce()
    if not state.autoclick then return end
    local now = os.clock()
    if now - lastAtk < (state.fastattack and 0.05 or 0.25) then return end
    lastAtk = now
    local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
    if tool then pcall(function() tool:Activate() end) end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(1280, 672))
        VirtualUser:Button1Up(Vector2.new(1280, 672))
    end)
    if state.fastattack and RegisterAttack and RegisterHit then pcall(fastHit) end
end

local function killMob(mob, maxTime, height)
    local t0 = os.clock()
    maxTime = maxTime or 45
    height = height or cfg.height
    while running and mob.Parent and valid(mob) and os.clock() - t0 < maxTime do
        if not alive() then return end
        local r, mr = hrp(), mob:FindFirstChild("HumanoidRootPart")
        if not r or not mr then return end
        touch()
        equip()
        if state.bring then bringNear(mob) end
        r.CFrame = CFrame.new(mr.Position + Vector3.new(0, height, 0), mr.Position)
        attackOnce()
        task.wait(0.08)
    end
    if not mob.Parent or not valid(mob) then stats.kills += 1 end
end

-- quests --------------------------------------------------------------
local function questActive()
    local ok, vis = pcall(function() return player.PlayerGui.Main.Quest.Visible end)
    return ok and vis
end
local function questMatches(q)
    local ok, txt = pcall(function() return player.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text end)
    return ok and txt ~= nil and string.find(txt, q[3], 1, true) ~= nil
end

local wpIdx = 1
local function farmQuest(q, label)
    if not (questActive() and questMatches(q)) then
        if questActive() then comm("AbandonQuest") task.wait(0.3) end
        setStatus(label .. ": quest " .. q[3])
        goTo(q[6] + Vector3.new(0, 3, 0))
        task.wait(0.4)
        comm("StartQuest", q[4], q[5])
        task.wait(0.4)
    end
    local mob = findMob({[q[3]] = true})
    if mob then
        setStatus(label .. ": " .. q[3])
        killMob(mob)
        return true
    end
    setStatus(label .. ": searching " .. q[3])
    local sp = findSpawn(q[3])
    goTo((sp or q[6]) + Vector3.new(0, 30, 0))
    task.wait(0.5)
    return true
end

---------------------------------------------------------------------
-- FARM TASKS (each returns true if it did something)
---------------------------------------------------------------------
local function doLevel()
    return farmQuest(getQuest(playerLevel()), "Level")
end

local function doGrind()
    local mob = findMob(nil, 1500)
    if mob then
        setStatus("Grind: " .. mob.Name)
        killMob(mob)
        return true
    end
    setStatus("Grind: moving")
    goTo(WAYPOINTS[wpIdx])
    wpIdx = wpIdx % #WAYPOINTS + 1
    task.wait(1)
    return true
end

local function cocoaTarget()
    if cfg.cocoaIdx > 0 and COCOA[cfg.cocoaIdx] then return COCOA[cfg.cocoaIdx] end
    local lvl = playerLevel()
    for _, q in ipairs(COCOA) do
        if lvl <= q[2] then return q end
    end
    return COCOA[#COCOA]
end
local function doCocoa()
    if SEA ~= 3 or #COCOA == 0 then setStatus("Cocoa grinder needs Sea 3") return false end
    return farmQuest(cocoaTarget(), "Cocoa")
end

-- chests
local visitedChest = setmetatable({}, {__mode = "k"})
local function nearestChest()
    local r = hrp()
    if not r then return nil end
    local best, bd
    for _, c in ipairs(CollectionService:GetTagged("_ChestTagged")) do
        if c.Parent and not c:GetAttribute("IsDisabled") and not skipped(c) then
            local d = (posOf(c) - r.Position).Magnitude
            if not bd or d < bd then best, bd = c, d end
        end
    end
    return best, bd
end
local function doChest()
    local c, d = nearestChest()
    if not c then return false end
    setStatus("Chest: " .. math.floor(d) .. " studs")
    goTo(posOf(c))
    stats.chests += 1
    skip(c, 8)
    task.wait(0.2)
    return true
end

-- fruits
local function findFruit()
    local r = hrp()
    if not r then return nil end
    local best, bd
    for _, o in ipairs(Workspace:GetChildren()) do
        if o:IsA("Tool") and o.Name:find("Fruit") and o:FindFirstChild("Handle") and not skipped(o) then
            local d = (o.Handle.Position - r.Position).Magnitude
            if not bd or d < bd then best, bd = o, d end
        end
    end
    return best
end
local function doFruit()
    local f = findFruit()
    if not f then return false end
    setStatus("Fruit: " .. f.Name)
    local h = f:FindFirstChild("Handle")
    if h then
        goTo(h.Position)
        touchPart(h)
        task.wait(0.4)
    end
    if f.Parent ~= Workspace then
        stats.fruits += 1
        notify("Picked up " .. f.Name)
    else
        skip(f, 10)
    end
    return true
end

-- elite hunter
local ELITE = {Diablo = true, Urban = true, Deandre = true}
local function doElite()
    local boss = findMob(ELITE)
    if boss then
        setStatus("Elite: " .. boss.Name)
        killMob(boss, 150, 12)
        return true
    end
    comm("EliteHunter")
    setStatus("Elite: waiting for spawn")
    return false
end

-- chalice finder
local CHALICE = {["God's Chalice"] = true, ["Fist of Darkness"] = true}
local chaliceNotified = {}
local function doChalice()
    local owned = eachTool(function(t) if CHALICE[t.Name] then return t end end)
    if owned then
        if not chaliceNotified[owned.Name] then
            chaliceNotified[owned.Name] = true
            stats.chalices += 1
            notify("Found: " .. owned.Name .. "!")
        end
        setStatus("Chalice owned: " .. owned.Name)
        return false
    end
    for _, o in ipairs(Workspace:GetChildren()) do
        if o:IsA("Tool") and CHALICE[o.Name] and o:FindFirstChild("Handle") and not skipped(o) then
            setStatus("Chalice: grabbing " .. o.Name)
            goTo(o.Handle.Position)
            touchPart(o.Handle)
            skip(o, 10)
            task.wait(0.4)
            return true
        end
    end
    return doElite()
end

-- raid
local function raidIslands()
    local wo = Workspace:FindFirstChild("_WorldOrigin")
    local locs = wo and wo:FindFirstChild("Locations")
    local out = {}
    if locs then
        for i = 1, 5 do
            local isl = locs:FindFirstChild("Island " .. i)
            if isl then table.insert(out, isl) end
        end
    end
    return out
end

local function raidButton()
    local ok, btn = pcall(function()
        local root = (SEA == 2) and Workspace.Map.CircleIsland.RaidSummon2 or Workspace.Map["Boat Castle"].RaidSummon2
        return root.Button.Main
    end)
    return ok and btn or nil
end

local raidWasActive, lastRaidStart = false, 0
local function startRaid()
    if not hasToolLike("Microchip") then
        comm("RaidsNpc", "Select", cfg.raidType)
        task.wait(1)
    end
    if not hasToolLike("Microchip") then
        setStatus("Raid: no chip (needs fruit/fragments)")
        lastRaidStart = os.clock() - 17
        return
    end
    local btn = raidButton()
    local cd = btn and btn:FindFirstChildOfClass("ClickDetector")
    if btn and cd and fireclickdetector then
        setStatus("Raid: starting " .. cfg.raidType)
        goTo(btn.Position + Vector3.new(0, 6, 0))
        task.wait(0.3)
        pcall(fireclickdetector, cd)
        lastRaidStart = os.clock()
    else
        setStatus("Raid: button/fireclickdetector missing")
        lastRaidStart = os.clock() - 10
    end
end

local function doRaid()
    if SEA == 1 then setStatus("Raids need Sea 2/3") return false end
    local isl = raidIslands()
    if #isl > 0 then
        raidWasActive = true
        local mob = findMob(nil, 450)
        if mob then
            setStatus("Raid: island " .. #isl)
            killMob(mob)
            return true
        end
        local r = hrp()
        local target = posOf(isl[#isl])
        if r and (r.Position - target).Magnitude > 120 then
            setStatus("Raid: moving to island " .. #isl)
            goTo(target + Vector3.new(0, 40, 0))
        end
        task.wait(0.3)
        return true
    end
    if raidWasActive then
        raidWasActive = false
        stats.raids += 1
        notify("Raid finished")
        if state.awaken then
            comm("Awakener", "Check")
            task.wait(0.5)
            comm("Awakener", "Awaken")
        end
    end
    if not state.raidstart then return false end
    if os.clock() - lastRaidStart < 25 then
        setStatus("Raid: waiting for spawn")
        return true
    end
    startRaid()
    return true
end

-- dispatcher: highest-priority active task wins so loops never fight over movement
local TASKS = {
    {"raid", doRaid}, {"fruit", doFruit}, {"chalice", doChalice}, {"elite", doElite},
    {"chest", doChest}, {"cocoa", doCocoa}, {"level", doLevel}, {"grind", doGrind},
}
task.spawn(function()
    while running do
        local ran = false
        if alive() then
            for _, t in ipairs(TASKS) do
                if state[t[1]] then
                    local ok, res = pcall(t[2])
                    if not ok then
                        warn("[VoidX] " .. t[1] .. ": " .. tostring(res))
                        task.wait(1)
                    elseif res then
                        ran = true
                        break
                    end
                end
            end
        end
        if ran then touch() task.wait() else task.wait(0.3) end
    end
end)

---------------------------------------------------------------------
-- BACKGROUND LOOPS
---------------------------------------------------------------------
local function bgLoop(key, interval, fn)
    task.spawn(function()
        while running do
            if state[key] then
                local ok, err = pcall(fn)
                if not ok then warn("[VoidX] " .. key .. ": " .. tostring(err)) end
            end
            task.wait(interval)
        end
    end)
end

bgLoop("store", 2, function()
    for _, t in ipairs(player.Backpack:GetChildren()) do
        if t:IsA("Tool") and t.Name:find("Fruit") then
            comm("StoreFruit", t:GetAttribute("OriginalName") or t.Name, t)
            task.wait(0.3)
        end
    end
end)

bgLoop("autostats", 3, function()
    local pts = player.Data.Points.Value
    if pts > 0 then comm("AddPoint", cfg.statKey, pts) end
end)

bgLoop("buso", 2, function()
    local c = player.Character
    if c and not c:FindFirstChild("HasBuso") then comm("Buso") end
end)

-- server hop
local hopping = false
local function hopServer()
    if hopping then return false end
    hopping = true
    setStatus("Hopping server...")
    local ok, body = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
    end)
    if ok then
        local okd, data = pcall(function() return HttpService:JSONDecode(body) end)
        if okd and data and data.data then
            local cands = {}
            for _, s in ipairs(data.data) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers - 1 then table.insert(cands, s.id) end
            end
            if #cands > 0 then
                saveCfg()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, cands[math.random(#cands)], player)
                task.delay(15, function() hopping = false end)
                return true
            end
        end
    end
    setStatus("Hop failed")
    hopping = false
    return false
end

local idleFor = 0
bgLoop("hop", 1, function()
    if not (state.fruit or state.chest) then idleFor = 0 return end
    local noFruit = (not state.fruit) or (findFruit() == nil)
    local noChest = (not state.chest) or (nearestChest() == nil)
    idleFor = (noFruit and noChest) and idleFor + 1 or 0
    if idleFor >= cfg.hopDelay then
        idleFor = 0
        hopServer()
    end
end)

-- auto rejoin on kick/disconnect
task.spawn(function()
    pcall(function()
        local overlay = game:GetService("CoreGui"):WaitForChild("RobloxPromptGui", 10):WaitForChild("promptOverlay", 10)
        keep(overlay.ChildAdded:Connect(function(c)
            if state.autorejoin and c.Name == "ErrorPrompt" then
                task.wait(2)
                TeleportService:Teleport(game.PlaceId, player)
            end
        end))
    end)
end)

-- ESP
local esp = {fruit = {}, chest = {}}
local function clearEsp(kind)
    for _, e in pairs(esp[kind]) do
        pcall(function() e.hl:Destroy() e.bb:Destroy() end)
    end
    esp[kind] = {}
end
local function updateEsp(kind, items, color)
    local r = hrp()
    local alivSet = {}
    for _, it in ipairs(items) do
        alivSet[it.inst] = true
        local e = esp[kind][it.inst]
        if not e then
            local hl = Instance.new("Highlight")
            hl.FillColor, hl.OutlineColor, hl.FillTransparency = color, Color3.new(1, 1, 1), 0.5
            hl.Adornee = it.inst
            hl.Parent = gui
            local bb = Instance.new("BillboardGui")
            bb.Size = UDim2.new(0, 140, 0, 22)
            bb.AlwaysOnTop = true
            bb.StudsOffset = Vector3.new(0, 3, 0)
            bb.Adornee = it.part
            bb.Parent = gui
            local lbl = newLabel(bb, "", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 12, color, Enum.TextXAlignment.Center)
            lbl.TextStrokeTransparency = 0.4
            e = {hl = hl, bb = bb, lbl = lbl}
            esp[kind][it.inst] = e
        end
        local d = r and math.floor((it.part.Position - r.Position).Magnitude) or 0
        e.lbl.Text = it.label .. " [" .. d .. "]"
    end
    for inst, e in pairs(esp[kind]) do
        if not alivSet[inst] or not inst.Parent then
            pcall(function() e.hl:Destroy() e.bb:Destroy() end)
            esp[kind][inst] = nil
        end
    end
end

task.spawn(function()
    while running do
        pcall(function()
            if state.fruitesp then
                local items = {}
                for _, o in ipairs(Workspace:GetChildren()) do
                    if o:IsA("Tool") and o.Name:find("Fruit") and o:FindFirstChild("Handle") then
                        table.insert(items, {inst = o, part = o.Handle, label = o.Name})
                    end
                end
                updateEsp("fruit", items, C.pink)
            else
                clearEsp("fruit")
            end
            if state.chestesp then
                local items = {}
                for _, c in ipairs(CollectionService:GetTagged("_ChestTagged")) do
                    local part = c:IsA("BasePart") and c or c:FindFirstChildWhichIsA("BasePart", true)
                    if c.Parent and part and not c:GetAttribute("IsDisabled") then
                        table.insert(items, {inst = c, part = part, label = "Chest"})
                    end
                end
                updateEsp("chest", items, Color3.fromRGB(255, 215, 80))
            else
                clearEsp("chest")
            end
        end)
        task.wait(1)
    end
end)

local function fpsBoost(on)
    if not on then return end
    task.spawn(function()
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
        local n = 0
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Trail") then
                pcall(function() v.Enabled = false end)
            end
            n += 1
            if n % 400 == 0 then task.wait() end
        end
    end)
end

---------------------------------------------------------------------
-- UNLOAD
---------------------------------------------------------------------
local function unload()
    running = false
    saveCfg()
    stopTween()
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    clearEsp("fruit")
    clearEsp("chest")
    local r = hrp()
    if r then
        local bv = r:FindFirstChild("VoidXHover")
        if bv then bv:Destroy() end
    end
    pcall(function() gui:Destroy() end)
end
genv.VoidXUnload = unload

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
makeInfo(farmPage, 44).Text = "Priority: Raid > Fruit > Chalice > Elite > Chests > Cocoa > Level > Grind"

---------------------------------------------------------------------
-- RAID TAB
---------------------------------------------------------------------
makeSection(raidPage, "AUTO RAID (Sea 2 / 3)")
makeToggle(raidPage, "Auto Raid", "raid")
makeToggle(raidPage, "Auto Start Raid", "raidstart")
makeToggle(raidPage, "Auto Awaken After", "awaken")
local raidBtn
raidBtn = makeButton(raidPage, "Raid Type: " .. cfg.raidType, function()
    cfg.raidType = cycle(RAID_TYPES, cfg.raidType)
    raidBtn.Text = "Raid Type: " .. cfg.raidType
    saveCfg()
end)
makeInfo(raidPage, 56).Text = "Buys the chip for the selected type, starts the raid, clears each island, then awakens (if on). Needs a fruit in storage or enough fragments."

---------------------------------------------------------------------
-- HUNT TAB
---------------------------------------------------------------------
makeSection(huntPage, "CHALICE")
makeToggle(huntPage, "Auto Chalice Finder", "chalice")
makeToggle(huntPage, "Auto Elite Hunter", "elite")
makeSection(huntPage, "COCOA (SEA 3)")
makeToggle(huntPage, "Auto Cocoa Grinder", "cocoa")
local cocoaBtn
local function cocoaLabel()
    if cfg.cocoaIdx > 0 and COCOA[cfg.cocoaIdx] then return "Cocoa Target: " .. COCOA[cfg.cocoaIdx][3] end
    return "Cocoa Target: Auto (by level)"
end
cocoaBtn = makeButton(huntPage, cocoaLabel(), function()
    cfg.cocoaIdx = (cfg.cocoaIdx + 1) % (#COCOA + 1)
    cocoaBtn.Text = cocoaLabel()
    saveCfg()
end)
makeInfo(huntPage, 56).Text = "Finder grabs dropped God's Chalice / Fist of Darkness, otherwise kills Elite bosses (Diablo, Urban, Deandre) and notifies you when you own one."

---------------------------------------------------------------------
-- CONFIG TAB (weapon + combat settings)
---------------------------------------------------------------------
makeSection(configPage, "WEAPON")
local weaponInfo = makeInfo(configPage)
local typeBtn
local weaponHolder

local function updateWeaponLabel()
    weaponInfo.Text = (cfg.weaponName ~= "") and ("Using: " .. cfg.weaponName) or ("Auto: first " .. cfg.weaponType)
end

local function refreshWeaponList()
    for _, c in ipairs(weaponHolder:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
    makeButton(weaponHolder, "Auto (by type)", function()
        cfg.weaponName = ""
        updateWeaponLabel()
        saveCfg()
    end)
    eachTool(function(t)
        makeButton(weaponHolder, t.Name .. "  (" .. t.ToolTip .. ")", function()
            cfg.weaponName = t.Name
            updateWeaponLabel()
            saveCfg()
        end)
    end)
end

typeBtn = makeButton(configPage, "Weapon Type: " .. cfg.weaponType, function()
    cfg.weaponType = cycle(WEAPON_TYPES, cfg.weaponType)
    cfg.weaponName = ""
    typeBtn.Text = "Weapon Type: " .. cfg.weaponType
    saveCfg()
    updateWeaponLabel()
end)
makeSection(configPage, "OR PICK A SPECIFIC TOOL")

weaponHolder = Instance.new("Frame")
weaponHolder.Size = UDim2.new(1, 0, 0, 0)
weaponHolder.AutomaticSize = Enum.AutomaticSize.Y
weaponHolder.BackgroundTransparency = 1
weaponHolder.LayoutOrder = nextOrder()
weaponHolder.Parent = configPage
local wl = Instance.new("UIListLayout", weaponHolder)
wl.Padding = UDim.new(0, 4)

onTabSelected.Config = function()
    updateWeaponLabel()
    refreshWeaponList()
end

makeSection(configPage, "FARM SETTINGS")
makeStepper(configPage, function() return "Tween Speed: " .. cfg.speed end,
    function(d) cfg.speed = math.clamp(cfg.speed + d, 100, 350) end, 25)
makeStepper(configPage, function() return "Hover Height: " .. cfg.height end,
    function(d) cfg.height = math.clamp(cfg.height + d, 4, 30) end, 2)
makeStepper(configPage, function() return "Hop After (s): " .. cfg.hopDelay end,
    function(d) cfg.hopDelay = math.clamp(cfg.hopDelay + d, 10, 120) end, 5)
local statBtn
statBtn = makeButton(configPage, "Auto Stat: " .. cfg.statKey, function()
    cfg.statKey = cycle(STAT_KEYS, cfg.statKey)
    statBtn.Text = "Auto Stat: " .. cfg.statKey
    saveCfg()
end)

---------------------------------------------------------------------
-- VISUALS TAB
---------------------------------------------------------------------
makeSection(visualPage, "ESP")
makeToggle(visualPage, "Fruit ESP", "fruitesp")
makeToggle(visualPage, "Chest ESP", "chestesp")
makeSection(visualPage, "PERFORMANCE")
makeToggle(visualPage, "FPS Boost", "fpsboost", fpsBoost)

---------------------------------------------------------------------
-- MISC TAB
---------------------------------------------------------------------
makeSection(miscPage, "COMBAT")
makeToggle(miscPage, "Fast Attack", "fastattack")
makeToggle(miscPage, "Auto Click", "autoclick")
makeToggle(miscPage, "Bring Mobs", "bring")
makeToggle(miscPage, "Auto Haki (Buso)", "buso")
makeToggle(miscPage, "Auto Stats", "autostats")
makeSection(miscPage, "MOVEMENT")
makeToggle(miscPage, "Noclip (while farming)", "noclip")
makeToggle(miscPage, "Infinite Jump", "infjump")
makeStepper(miscPage, function() return "Walk Speed: " .. cfg.walkspeed end,
    function(d) cfg.walkspeed = math.clamp(cfg.walkspeed + d, 16, 120) end, 8)
makeSection(miscPage, "SERVER")
makeToggle(miscPage, "Auto Server Hop", "hop")
makeToggle(miscPage, "Auto Rejoin on Kick", "autorejoin")
makeToggle(miscPage, "Anti AFK", "antiafk")
makeButton(miscPage, "Hop Server Now", function() task.spawn(hopServer) end)
makeButton(miscPage, "Rejoin", function()
    saveCfg()
    TeleportService:Teleport(game.PlaceId, player)
end)
local keyBtn
keyBtn = makeButton(miscPage, "Hide Key: " .. cfg.toggleKey, function()
    cfg.toggleKey = cycle(HIDE_KEYS, cfg.toggleKey)
    keyBtn.Text = "Hide Key: " .. cfg.toggleKey
    saveCfg()
end)
makeButton(miscPage, "Save Config", function() saveCfg() notify("Config saved") end)
makeButton(miscPage, "Unload", unload)

---------------------------------------------------------------------
-- INFO TAB
---------------------------------------------------------------------
makeSection(infoPage, "STATS")
local infoLabel = makeInfo(infoPage, 110)
task.spawn(function()
    while running do
        if infoPage.Visible then
            infoLabel.Text = string.format(
                "Sea %d  |  Level %d\nChests: %d\nFruits: %d\nKills: %d\nRaids: %d\nChalices: %d\nStatus: %s",
                SEA, playerLevel(), stats.chests, stats.fruits, stats.kills, stats.raids, stats.chalices, currentStatus)
        end
        task.wait(0.5)
    end
end)

---------------------------------------------------------------------
-- WINDOW CONTROLS + KEYBIND
---------------------------------------------------------------------
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    body.Visible = not minimized
    TweenService:Create(frame, TweenInfo.new(0.2), {Size = UDim2.new(0, W, 0, minimized and HEAD or H)}):Play()
end)
closeBtn.MouseButton1Click:Connect(unload)

keep(UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode[cfg.toggleKey] then gui.Enabled = not gui.Enabled end
end))

if state.fpsboost then fpsBoost(true) end
selectTab("Farm")
notify("VOID X v2 loaded - " .. cfg.toggleKey .. " hides the menu")
