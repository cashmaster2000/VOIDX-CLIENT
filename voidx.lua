-- VOID X CLIENT | Blox Fruits: Chests + Fruit + Auto Level + Store + ESP + Hop
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
local state = {chest = false, fruit = false, level = false, store = false, esp = false, hop = false}
local stats = {chests = 0, fruits = 0, kills = 0}

-- Anti-AFK
player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- QUEST TABLE (Sea 1). Edit if the game updates.
-- {minLevel, maxLevel, mobName, questName, questIndex, questGiverPosition}
local QUESTS = {
    {1, 9,     "Bandit",           "BanditQuest1",   1, Vector3.new(1059, 16, 1550)},
    {10, 14,   "Monkey",           "JungleQuest",    1, Vector3.new(-1598, 36, 153)},
    {15, 29,   "Gorilla",          "JungleQuest",    2, Vector3.new(-1598, 36, 153)},
    {30, 39,   "Pirate",           "BuggyQuest1",    1, Vector3.new(-1140, 5, 3825)},
    {40, 59,   "Brute",            "BuggyQuest1",    2, Vector3.new(-1140, 5, 3825)},
    {60, 74,   "Desert Bandit",    "DesertQuest",    1, Vector3.new(897, 6, 4390)},
    {75, 89,   "Desert Officer",   "DesertQuest",    2, Vector3.new(897, 6, 4390)},
    {90, 99,   "Snow Bandit",      "SnowQuest",      1, Vector3.new(1387, 87, -1298)},
    {100, 119, "Snowman",          "SnowQuest",      2, Vector3.new(1387, 87, -1298)},
    {120, 149, "Chief Petty Officer", "MarineQuest2", 1, Vector3.new(-5035, 29, 4324)},
    {150, 174, "Sky Bandit",       "SkyQuest",       1, Vector3.new(-4842, 718, -2624)},
    {175, 189, "Dark Master",      "SkyQuest",       2, Vector3.new(-4842, 718, -2624)},
    {190, 209, "Prisoner",         "PrisonerQuest",  1, Vector3.new(5311, 1, 475)},
    {210, 249, "Dangerous Prisoner","PrisonerQuest", 2, Vector3.new(5311, 1, 475)},
    {250, 274, "Toga Warrior",     "ColosseumQuest", 1, Vector3.new(-1580, 6, -2986)},
    {275, 299, "Gladiator",        "ColosseumQuest", 2, Vector3.new(-1580, 6, -2986)},
    {300, 324, "Military Soldier", "MagmaQuest",     1, Vector3.new(-5313, 11, 8515)},
    {325, 374, "Military Spy",     "MagmaQuest",     2, Vector3.new(-5313, 11, 8515)},
}

-- THEME
local C = {
    bg     = Color3.fromRGB(8, 6, 14),
    panel  = Color3.fromRGB(20, 13, 34),
    purple = Color3.fromRGB(150, 60, 255),
    pink   = Color3.fromRGB(255, 45, 185),
    text   = Color3.fromRGB(240, 230, 255),
    dim    = Color3.fromRGB(145, 128, 175),
    off    = Color3.fromRGB(42, 33, 62),
}
local FULL_H, HEAD_H = 375, 40
local minimized = false

-- GUI root
local parent = (gethui and gethui()) or game:GetService("CoreGui")
pcall(function()
    local old = parent:FindFirstChild("VoidXClient")
    if old then old:Destroy() end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "VoidXClient"
gui.ResetOnSpawn = false
gui.Parent = parent

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, FULL_H)
frame.Position = UDim2.new(0.5, -120, 0.08, 0)
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
RunService.Heartbeat:Connect(function()
    grad.Rotation = (grad.Rotation + 1.5) % 360
end)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, HEAD_H)
header.BackgroundColor3 = C.panel
header.BorderSizePixel = 0
header.Active = true
header.Parent = frame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 14, 0, 0)
title.BackgroundTransparency = 1
title.Text = "VOID X CLIENT"
title.Font = Enum.Font.GothamBlack
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = header
Instance.new("UIGradient", title).Color = ColorSequence.new(C.purple, C.pink)

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -36, 0.5, -14)
minBtn.BackgroundColor3 = C.off
minBtn.Text = "–"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
minBtn.TextColor3 = C.pink
minBtn.AutoButtonColor = false
minBtn.Parent = header
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -HEAD_H)
body.Position = UDim2.new(0, 0, 0, HEAD_H)
body.BackgroundTransparency = 1
body.Parent = frame

local function makeLabel(text, size, pos, textSize, color, align, font)
    local l = Instance.new("TextLabel")
    l.Size = size
    l.Position = pos
    l.BackgroundTransparency = 1
    l.Text = text
    l.Font = font or Enum.Font.GothamBold
    l.TextSize = textSize
    l.TextColor3 = color
    l.TextXAlignment = align or Enum.TextXAlignment.Center
    return l
end

local counter = makeLabel("", UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 4), 12, C.pink)
counter.Parent = body

local function makeRow(y)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -16, 0, 34)
    row.Position = UDim2.new(0, 8, 0, y)
    row.BackgroundColor3 = C.panel
    row.BorderSizePixel = 0
    row.Parent = body
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
    return row
end

local function makeToggle(name, key, index)
    local row = makeRow(28 + (index - 1) * 40)
    makeLabel(name, UDim2.new(1, -70, 1, 0), UDim2.new(0, 12, 0, 0), 13, C.text, Enum.TextXAlignment.Left).Parent = row

    local track = Instance.new("TextButton")
    track.Size = UDim2.new(0, 46, 0, 22)
    track.Position = UDim2.new(1, -56, 0.5, -11)
    track.BackgroundColor3 = C.off
    track.Text = ""
    track.AutoButtonColor = false
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    local ts = Instance.new("UIStroke", track)
    ts.Color = C.purple
    ts.Thickness = 1

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = C.dim
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    track.MouseButton1Click:Connect(function()
        state[key] = not state[key]
        local on = state[key]
        local info = TweenInfo.new(0.2)
        TweenService:Create(track, info, {BackgroundColor3 = on and C.pink or C.off}):Play()
        TweenService:Create(ts, info, {Color = on and C.pink or C.purple}):Play()
        TweenService:Create(knob, info, {
            Position = on and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
            BackgroundColor3 = on and Color3.new(1, 1, 1) or C.dim,
        }):Play()
    end)
end

makeToggle("Collect All Chests", "chest", 1)
makeToggle("Auto Farm Level", "level", 2)
makeToggle("Auto Fruit", "fruit", 3)
makeToggle("Auto Store Fruit", "store", 4)
makeToggle("Fruit ESP", "esp", 5)
makeToggle("Server Hop", "hop", 6)

local speedRow = makeRow(28 + 6 * 40)
local speedLabel = makeLabel("Speed: " .. speed, UDim2.new(1, -90, 1, 0), UDim2.new(0, 12, 0, 0), 13, C.text, Enum.TextXAlignment.Left)
speedLabel.Parent = speedRow

local function speedButton(text, xOffset, delta)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 30, 0, 24)
    b.Position = UDim2.new(1, xOffset, 0.5, -12)
    b.BackgroundColor3 = C.off
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    b.TextColor3 = C.pink
    b.AutoButtonColor = false
    b.Parent = speedRow
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(function()
        speed = math.clamp(speed + delta, 100, 400)
        speedLabel.Text = "Speed: " .. speed
    end)
end
speedButton("-", -72, -25)
speedButton("+", -38, 25)

local statusLabel = makeLabel("Idle", UDim2.new(1, -20, 0, 18), UDim2.new(0, 10, 0, 28 + 6 * 40 + 40), 11, C.dim, nil, Enum.Font.Gotham)
statusLabel.Parent = body

-- Dragging (header, mouse + touch)
do
    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                       startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    minBtn.Text = minimized and "+" or "–"
    TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 240, 0, minimized and HEAD_H or FULL_H)
    }):Play()
end)

local function refreshUI(msg)
    counter.Text = ("Chests: %d | Fruits: %d | Kills: %d"):format(stats.chests, stats.fruits, stats.kills)
    if msg then statusLabel.Text = msg end
end

-- Helpers
local function anyFarm()
    return state.chest or state.fruit or state.level
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

-- Chests: tag, then ChestModels folder, then any "Chest" named object
local function getChests()
    local list, seen = {}, {}
    local function add(c)
        if c.Parent and not seen[c] then
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

-- Fly to a position. Returns true if arrived.
local function flyTo(root, pos, stillValid)
    local dist = (pos - root.Position).Magnitude
    local tween = TweenService:Create(
        root,
        TweenInfo.new(math.max(dist / speed, 0.1), Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(pos)}
    )
    tween:Play()
    local t0 = tick()
    while stillValid() and tween.PlaybackState == Enum.PlaybackState.Playing and tick() - t0 < 45 do
        task.wait()
    end
    local arrived = tween.PlaybackState == Enum.PlaybackState.Completed
    tween:Cancel()
    return arrived and stillValid()
end

-- Collect one object (chest/fruit)
local function collect(root, obj)
    local p = posOf(obj)
    if not p then return false end
    local ok = flyTo(root, p + Vector3.new(0, 2, 0), anyFarm)
    if anyFarm() and obj.Parent then
        local p2 = posOf(obj)
        if p2 then root.CFrame = CFrame.new(p2) end
        if firetouchinterest then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
            if part then
                pcall(function()
                    firetouchinterest(root, part, 0)
                    firetouchinterest(root, part, 1)
                end)
            end
        end
        task.wait(0.35)
        return true
    end
    return ok
end

-- Noclip while farming
RunService.Stepped:Connect(function()
    if not anyFarm() then return end
    local _, char = getRoot()
    if char then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- AUTO FARM LEVEL
local function currentQuest()
    local ok, lvl = pcall(function() return player.Data.Level.Value end)
    if not ok then return end
    for _, q in ipairs(QUESTS) do
        if lvl >= q[1] and lvl <= q[2] then
            return {mob = q[3], name = q[4], index = q[5], pos = q[6], lvl = lvl}
        end
    end
    return nil, lvl
end

local function questActive()
    local ok, vis = pcall(function() return player.PlayerGui.Main.Quest.Visible end)
    return ok and vis
end

local function equipMelee()
    local _, char, hum = getRoot()
    if not hum then return end
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") and t.ToolTip == "Melee" then return end
    end
    for _, t in ipairs(player.Backpack:GetChildren()) do
        if t:IsA("Tool") and t.ToolTip == "Melee" then
            hum:EquipTool(t)
            return
        end
    end
end

local function nearestMob(name, root)
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return end
    local best, bestDist
    for _, m in ipairs(enemies:GetChildren()) do
        local hum = m:FindFirstChildOfClass("Humanoid")
        local hrp = m:FindFirstChild("HumanoidRootPart")
        if m.Name == name and hum and hrp and hum.Health > 0 then
            local d = (hrp.Position - root.Position).Magnitude
            if not bestDist or d < bestDist then best, bestDist = m, d end
        end
    end
    return best
end

local function levelStep(root)
    local q, lvl = currentQuest()
    if not q then
        refreshUI("No quest data for level " .. tostring(lvl or "?"))
        task.wait(2)
        return
    end

    if not questActive() then
        refreshUI("Getting quest: " .. q.mob)
        if flyTo(root, q.pos + Vector3.new(0, 3, 0), function() return state.level end) then
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local remote = remotes and remotes:FindFirstChild("CommF_")
            if remote then
                pcall(function() remote:InvokeServer("StartQuest", q.name, q.index) end)
            end
            task.wait(0.6)
        end
        return
    end

    local mob = nearestMob(q.mob, root)
    if not mob then
        refreshUI("Searching for " .. q.mob .. "...")
        flyTo(root, q.pos + Vector3.new(0, 25, 0), function() return state.level and not nearestMob(q.mob, root) end)
        task.wait(0.5)
        return
    end

    refreshUI("Farming " .. q.mob .. " (Lv " .. q.lvl .. ")")
    equipMelee()
    local hum = mob:FindFirstChildOfClass("Humanoid")
    local hrp = mob:FindFirstChild("HumanoidRootPart")
    local t0 = tick()
    while state.level and mob.Parent and hum.Health > 0 and tick() - t0 < 60 do
        local r = getRoot()
        if not r then break end
        r.CFrame = hrp.CFrame * CFrame.new(0, 12, 0) * CFrame.Angles(math.rad(-90), 0, 0)
        r.AssemblyLinearVelocity = Vector3.zero
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(1280, 672))
        end)
        task.wait(0.1)
    end
    if hum.Health <= 0 then stats.kills += 1 end
    refreshUI()
end

-- Server hop
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

-- Main loop: fruits > chests > level
task.spawn(function()
    local emptySince
    while true do
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
                emptySince = nil
                refreshUI("Collecting " .. kind .. "...")
                if collect(root, target) and not target.Parent then
                    if kind == "fruit" then stats.fruits += 1 else stats.chests += 1 end
                    refreshUI("Collected " .. kind)
                end
            elseif state.level then
                emptySince = nil
                levelStep(root)
            else
                emptySince = emptySince or tick()
                refreshUI("Nothing left")
                if state.hop and tick() - emptySince > 5 then
                    serverHop()
                    emptySince = nil
                end
                task.wait(1.5)
            end
        end
    end
end)

-- Auto store fruit
task.spawn(function()
    while true do
        task.wait(2)
        if state.store then
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local remote = remotes and remotes:FindFirstChild("CommF_")
            if remote then
                for _, c in ipairs({player.Backpack, player.Character}) do
                    if c then
                        for _, tool in ipairs(c:GetChildren()) do
                            if tool:IsA("Tool") and tool.Name:find("Fruit") then
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

-- Fruit ESP
task.spawn(function()
    while true do
        task.wait(0.5)
        for _, f in ipairs(getFruits()) do
            local handle = f:FindFirstChild("Handle")
            local tag = handle and handle:FindFirstChild("FruitESP")
            if state.esp and handle then
                if not tag then
                    tag = Instance.new("BillboardGui")
                    tag.Name = "FruitESP"
                    tag.Size = UDim2.new(0, 160, 0, 40)
                    tag.AlwaysOnTop = true
                    tag.StudsOffset = Vector3.new(0, 3, 0)
                    tag.Parent = handle
                    local t = Instance.new("TextLabel")
                    t.Name = "T"
                    t.Size = UDim2.new(1, 0, 1, 0)
                    t.BackgroundTransparency = 1
                    t.Font = Enum.Font.GothamBold
                    t.TextSize = 14
                    t.TextColor3 = C.pink
                    t.TextStrokeColor3 = C.purple
                    t.TextStrokeTransparency = 0
                    t.Parent = tag
                end
                local root = getRoot()
                local d = root and math.floor((handle.Position - root.Position).Magnitude) or 0
                tag.T.Text = ("%s\n[%dm]"):format(f.Name, d)
            elseif tag then
                tag:Destroy()
            end
        end
    end
end)

refreshUI("Ready")
