-- VOID X CLIENT | Blox Fruits: Chest + Fruit + Store + ESP + Server Hop
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local speed = 250
local state = {chest = false, fruit = false, store = false, esp = false, hop = false}
local stats = {chests = 0, fruits = 0}

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
local FULL_H, HEAD_H = 350, 40
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
frame.Position = UDim2.new(0.5, -120, 0.1, 0)
frame.BackgroundColor3 = C.bg
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

-- Animated gradient border
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

-- Header
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
local tg = Instance.new("UIGradient", title)
tg.Color = ColorSequence.new(C.purple, C.pink)

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

-- Body
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

local counter = makeLabel("Chests: 0  |  Fruits: 0", UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 4), 12, C.pink)
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

makeToggle("Auto Chest", "chest", 1)
makeToggle("Auto Fruit", "fruit", 2)
makeToggle("Auto Store Fruit", "store", 3)
makeToggle("Fruit ESP", "esp", 4)
makeToggle("Server Hop", "hop", 5)

-- Speed row
local speedRow = makeRow(28 + 5 * 40)
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

local statusLabel = makeLabel("Idle", UDim2.new(1, -20, 0, 18), UDim2.new(0, 10, 0, 28 + 5 * 40 + 40), 11, C.dim, nil, Enum.Font.Gotham)
statusLabel.Parent = body

-- Dragging (header only, mouse + touch)
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

-- Minimize
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    minBtn.Text = minimized and "+" or "–"
    TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 240, 0, minimized and HEAD_H or FULL_H)
    }):Play()
end)

local function refreshUI(msg)
    counter.Text = ("Chests: %d  |  Fruits: %d"):format(stats.chests, stats.fruits)
    if msg then statusLabel.Text = msg end
end

-- Helpers
local function getRoot()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health > 0 then
        return char:FindFirstChild("HumanoidRootPart"), char
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

local function getChests()
    local list = {}
    for _, c in ipairs(CollectionService:GetTagged("_ChestTagged")) do table.insert(list, c) end
    if #list == 0 then
        local folder = workspace:FindFirstChild("ChestModels")
        if folder then
            for _, c in ipairs(folder:GetChildren()) do table.insert(list, c) end
        end
    end
    if #list == 0 then
        for _, c in ipairs(workspace:GetChildren()) do
            if c.Name:match("^Chest%d*$") then table.insert(list, c) end
        end
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

local function goTo(root, obj, dist, stillValid)
    local target = posOf(obj)
    if not target then return false end
    local tween = TweenService:Create(
        root,
        TweenInfo.new(math.max(dist / speed, 0.1), Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(target + Vector3.new(0, 2, 0))}
    )
    tween:Play()
    local t0 = tick()
    while stillValid() and obj.Parent and tween.PlaybackState == Enum.PlaybackState.Playing
    and tick() - t0 < 30 do
        task.wait()
    end
    tween:Cancel()
    if stillValid() and obj.Parent then
        local p = posOf(obj)
        if p then root.CFrame = CFrame.new(p) end
        task.wait(0.3)
        return true
    end
    return false
end

-- Noclip while farming
RunService.Stepped:Connect(function()
    if not (state.chest or state.fruit) then return end
    local _, char = getRoot()
    if char then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

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

-- Main farm loop (fruits take priority over chests)
task.spawn(function()
    local emptySince
    while true do
        task.wait(0.1)
        local root = getRoot()
        if root and (state.chest or state.fruit) then
            local target, dist, kind

            if state.fruit then
                local f, d = nearest(getFruits(), root)
                if f then target, dist, kind = f, d, "fruit" end
            end
            if not target and state.chest then
                local c, d = nearest(getChests(), root)
                if c then target, dist, kind = c, d, "chest" end
            end

            if target then
                emptySince = nil
                refreshUI("Going to " .. kind .. "...")
                local ok = goTo(root, target, dist, function() return state.chest or state.fruit end)
                if ok then
                    if kind == "fruit" then stats.fruits += 1 else stats.chests += 1 end
                    refreshUI("Collected " .. kind)
                end
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

-- Fruit ESP (neon pink)
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
