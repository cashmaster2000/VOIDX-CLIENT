-- voidx.lua | VOID X | Blox Fruits Auto Farm + Auto Raid + FOV Aim Assist + Key Loop
-- v4: all features in one draggable GUI, single cleanup, re-executable

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

if not game:IsLoaded() then game.Loaded:Wait() end
local player = Players.LocalPlayer
while not player do task.wait() player = Players.LocalPlayer end
local camera = workspace.CurrentCamera

local env = (getgenv and getgenv()) or _G

-- Clean up this script and any older standalone versions
for _, name in ipairs({"VOIDX_CLEANUP", "COMBO_CLEANUP", "FOV_CLEANUP", "KEYLOOP_CLEANUP"}) do
    if env[name] then pcall(env[name]) end
end
local TOKEN = {}
env.VOIDX_TOKEN = TOKEN
local function alive() return env.VOIDX_TOKEN == TOKEN end

env.AutoFarmNearest = false
env.AutoRaid = false

-- ============ SETTINGS ============
local RADIUS = 150
local RAID_RADIUS = 600
local HEIGHT = 15
local AURA_RANGE = 120
local RAID_TYPE = "Flame"    -- Flame, Ice, Quake, Light, Dark, Spider, Rumble, Magma, Buddha, Sand, Phoenix, Dough
local BUY_WITH_FRUIT = false

local AIM = {
    Radius = 120,
    Thickness = 2,
    Color = Color3.fromRGB(150, 60, 255),
    LockedColor = Color3.fromRGB(0, 255, 140),
    FollowMouse = false,
    TargetPart = "Head",
    Smoothness = 0.25,
    TeamCheck = true,
    WallCheck = true,
    MaxDistance = 1000,
    TargetNPCs = true,       -- workspace.Enemies
    TargetPlayers = false,   -- set true to also aim at other players
    HoldKey = Enum.UserInputType.MouseButton2,
    AimToggleKey = Enum.KeyCode.RightControl,
    CircleToggleKey = Enum.KeyCode.RightShift,
}
local LOOP = {
    Key = Enum.KeyCode.L,
    Sequence = {"One", "Z", "X", "C", "Two", "Z", "Three", "Z", "X"},
    HoldTime = 0.05,
    KeyDelay = 0.15,
    LoopDelay = 0.30,
}
env.VOIDX_AIM = AIM
env.VOIDX_LOOP = LOOP

-- ============ STATE ============
local statusText = "Idle"
local function setStatus(s) statusText = s end

local target
local aimOn, loopOn, circleOn = false, false, true
local rmbHeld = false
local lockedTarget
local connections = {}
local refreshers = {}
local circle, ring

local function track(c) table.insert(connections, c) return c end
local function syncAll() for _, r in ipairs(refreshers) do r() end end

-- ============ GUI ============
local PURPLE = Color3.fromRGB(150, 60, 255)
local PINK = Color3.fromRGB(255, 40, 160)
local BLACK = Color3.fromRGB(10, 10, 14)
local PANEL = Color3.fromRGB(22, 20, 30)
local GREEN = Color3.fromRGB(0, 255, 140)
local RED = Color3.fromRGB(255, 70, 90)

local gui = Instance.new("ScreenGui")
gui.Name = "VOIDX"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function parentGui(g)
    local tries = {
        function() if gethui then g.Parent = gethui() end end,
        function() if syn and syn.protect_gui then syn.protect_gui(g) end g.Parent = game:GetService("CoreGui") end,
        function() g.Parent = game:GetService("CoreGui") end,
        function() g.Parent = player:WaitForChild("PlayerGui", 10) end,
    }
    for _, fn in ipairs(tries) do
        pcall(fn)
        if g.Parent then return true end
    end
    return false
end

if not parentGui(gui) then warn("[VOID X] Could not parent GUI.") end

local FULL_H = 292

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 200, 0, FULL_H)
main.Position = UDim2.new(0, 20, 0.2, 0)
main.BackgroundColor3 = BLACK
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", main)
stroke.Color = PURPLE
stroke.Thickness = 2

local title = Instance.new("Frame")
title.Name = "TitleBar"
title.Size = UDim2.new(1, 0, 0, 34)
title.BackgroundColor3 = PANEL
title.BorderSizePixel = 0
title.Parent = main
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -44, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 16
titleLabel.TextColor3 = PINK
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Text = "VOID X"
titleLabel.Parent = title

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 24)
minBtn.Position = UDim2.new(1, -34, 0, 5)
minBtn.BackgroundColor3 = BLACK
minBtn.TextColor3 = PURPLE
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16
minBtn.Text = "-"
minBtn.Parent = title
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

local body = Instance.new("Frame")
body.Name = "Body"
body.Size = UDim2.new(1, -20, 1, -44)
body.Position = UDim2.new(0, 10, 0, 40)
body.BackgroundTransparency = 1
body.Parent = main

local layout = Instance.new("UIListLayout", body)
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Generic toggle: get() reads state, set(v) changes it
local function makeToggle(text, order, get, set)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.LayoutOrder = order
    btn.BackgroundColor3 = PANEL
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = body
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", btn)
    s.Thickness = 1

    local function refresh()
        local on = get()
        btn.Text = text .. ": " .. (on and "ON" or "OFF")
        btn.TextColor3 = on and GREEN or RED
        s.Color = on and GREEN or RED
    end
    refresh()
    table.insert(refreshers, refresh)

    btn.MouseButton1Click:Connect(function()
        set(not get())
        syncAll()
    end)
end

local function idleIfNothingOn()
    if not (env.AutoFarmNearest or env.AutoRaid) then setStatus("Idle") end
end

makeToggle("AutoFarm", 1,
    function() return env.AutoFarmNearest end,
    function(v) env.AutoFarmNearest = v if not v then target = nil idleIfNothingOn() end end)

makeToggle("AutoRaid", 2,
    function() return env.AutoRaid end,
    function(v) env.AutoRaid = v if not v then target = nil idleIfNothingOn() end end)

makeToggle("Aim Assist", 3,
    function() return aimOn end,
    function(v) aimOn = v end)

makeToggle("Key Loop", 4,
    function() return loopOn end,
    function(v) loopOn = v end)

makeToggle("FOV Circle", 5,
    function() return circleOn end,
    function(v) circleOn = v end)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 36)
statusLabel.LayoutOrder = 6
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.TextColor3 = Color3.fromRGB(190, 170, 255)
statusLabel.TextWrapped = true
statusLabel.Text = "Loading..."
statusLabel.Parent = body

task.spawn(function()
    while alive() and gui.Parent do
        statusLabel.Text = statusText
        task.wait(0.3)
    end
end)

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    body.Visible = not minimized
    minBtn.Text = minimized and "+" or "-"
    main.Size = minimized and UDim2.new(0, 200, 0, 34) or UDim2.new(0, 200, 0, FULL_H)
end)

-- Dragging (title bar, mouse + touch)
local dragging, dragStart, startPos, dragInput
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
track(UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local d = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end))

print("[VOID X] GUI loaded.")

-- ============ FOV CIRCLE ============
local circleGui
if Drawing and Drawing.new then
    circle = Drawing.new("Circle")
    circle.NumSides = 64
    circle.ZIndex = 999
else
    circleGui = Instance.new("ScreenGui")
    circleGui.Name = "VOIDXCircle"
    circleGui.ResetOnSpawn = false
    circleGui.IgnoreGuiInset = true
    circleGui.DisplayOrder = 999998
    parentGui(circleGui)
    ring = Instance.new("Frame")
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.BackgroundTransparency = 1
    ring.BorderSizePixel = 0
    ring.Parent = circleGui
    Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", ring).Name = "Stroke"
end

local function screenPoint()
    if AIM.FollowMouse and not UserInputService.TouchEnabled then
        return UserInputService:GetMouseLocation()
    end
    local vp = camera.ViewportSize
    return Vector2.new(vp.X / 2, vp.Y / 2)
end

local function drawCircle(pos, color)
    if circle then
        circle.Visible = circleOn
        circle.Position = pos
        circle.Radius = AIM.Radius
        circle.Thickness = AIM.Thickness
        circle.Color = color
        circle.Filled = false
        circle.Transparency = 1
    else
        ring.Visible = circleOn
        ring.Position = UDim2.fromOffset(pos.X, pos.Y)
        ring.Size = UDim2.fromOffset(AIM.Radius * 2, AIM.Radius * 2)
        local st = ring:FindFirstChild("Stroke")
        st.Color = color
        st.Thickness = AIM.Thickness
    end
end

-- ============ AIM TARGETING ============
local function isVisible(part, model)
    local origin = camera.CFrame.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {player.Character, model}
    params.IgnoreWater = true
    return workspace:Raycast(origin, part.Position - origin, params) == nil
end

local function candidateModels()
    local list = {}
    if AIM.TargetPlayers then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                if not (AIM.TeamCheck and p.Team ~= nil and p.Team == player.Team) then
                    table.insert(list, p.Character)
                end
            end
        end
    end
    if AIM.TargetNPCs then
        local enemies = workspace:FindFirstChild("Enemies")
        if enemies then
            for _, m in ipairs(enemies:GetChildren()) do table.insert(list, m) end
        end
    end
    return list
end

local function getAimTarget(center)
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local best, bestDist = nil, AIM.Radius
    for _, model in ipairs(candidateModels()) do
        local hum = model:FindFirstChildOfClass("Humanoid")
        local part = model:FindFirstChild(AIM.TargetPart) or model:FindFirstChild("HumanoidRootPart")
        if hum and hum.Health > 0 and part
            and (part.Position - myRoot.Position).Magnitude <= AIM.MaxDistance then
            local sp, onScreen = camera:WorldToScreenPoint(part.Position)
            if onScreen then
                local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                if d <= bestDist and (not AIM.WallCheck or isVisible(part, model)) then
                    best, bestDist = part, d
                end
            end
        end
    end
    return best
end

track(RunService.RenderStepped:Connect(function()
    if not alive() then return end
    camera = workspace.CurrentCamera
    local center = screenPoint()
    lockedTarget = nil
    if aimOn or rmbHeld then
        lockedTarget = getAimTarget(center)
        if lockedTarget then
            local goal = CFrame.new(camera.CFrame.Position, lockedTarget.Position)
            camera.CFrame = camera.CFrame:Lerp(goal, math.clamp(AIM.Smoothness, 0.01, 1))
        end
    end
    drawCircle(center, lockedTarget and AIM.LockedColor or AIM.Color)
end))

-- ============ KEY LOOP ============
local function pressKey(keyName)
    local code = Enum.KeyCode[keyName]
    if not code then return end
    local ok = pcall(function()
        VirtualInputManager:SendKeyEvent(true, code, false, game)
        task.wait(LOOP.HoldTime)
        VirtualInputManager:SendKeyEvent(false, code, false, game)
    end)
    if not ok and keypress and keyrelease then
        pcall(function()
            keypress(code.Value)
            task.wait(LOOP.HoldTime)
            keyrelease(code.Value)
        end)
    end
end

task.spawn(function()
    while alive() do
        if loopOn then
            for _, key in ipairs(LOOP.Sequence) do
                if not (alive() and loopOn) then break end
                pressKey(key)
                task.wait(LOOP.KeyDelay)
            end
            task.wait(LOOP.LoopDelay)
        else
            task.wait(0.1)
        end
    end
end)

-- ============ KEYBINDS (PC) ============
track(UserInputService.InputBegan:Connect(function(input, processed)
    if input.UserInputType == AIM.HoldKey or input.KeyCode == AIM.HoldKey then
        rmbHeld = true
    end
    if processed or UserInputService:GetFocusedTextBox() then return end
    if input.KeyCode == AIM.CircleToggleKey then
        circleOn = not circleOn
    elseif input.KeyCode == AIM.AimToggleKey then
        aimOn = not aimOn
    elseif input.KeyCode == LOOP.Key then
        loopOn = not loopOn
    else
        return
    end
    syncAll()
end))

track(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == AIM.HoldKey or input.KeyCode == AIM.HoldKey then
        rmbHeld = false
    end
end))

-- ============ BLOX FRUITS LOGIC ============
if game.PlaceId ~= 2753915549 and game.PlaceId ~= 4442272183 and game.PlaceId ~= 7449423635 then
    setStatus("Not Blox Fruits (PlaceId " .. game.PlaceId .. ")")
    warn("[VOID X] Not a known Blox Fruits place. GUI shown, farming may not work.")
end

local CommF, RegisterAttack, RegisterHit
setStatus("Loading...")
task.spawn(function()
    pcall(function()
        local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
        CommF = remotes and remotes:WaitForChild("CommF_", 10)
    end)
    pcall(function()
        local Net = ReplicatedStorage:WaitForChild("Modules", 10):WaitForChild("Net", 10)
        RegisterAttack = Net:FindFirstChild("RE/RegisterAttack")
        RegisterHit = Net:FindFirstChild("RE/RegisterHit")
    end)
    if not RegisterAttack or not RegisterHit then
        warn("[VOID X] Attack remotes not found. Using click fallback only.")
    end
    if alive() and statusText == "Loading..." then setStatus("Idle") end
end)

local function getRoot(m) return m and m:FindFirstChild("HumanoidRootPart") end

local function isAlive(mob)
    local hum = mob:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0 and getRoot(mob)
end

local function findNearestMob(radius)
    local myRoot = getRoot(player.Character)
    local enemies = workspace:FindFirstChild("Enemies")
    if not (myRoot and enemies) then return nil end
    local closest, best = nil, radius
    for _, mob in ipairs(enemies:GetChildren()) do
        if isAlive(mob) then
            local d = (getRoot(mob).Position - myRoot.Position).Magnitude
            if d <= best then closest, best = mob, d end
        end
    end
    return closest
end

local function equipMelee()
    local char = player.Character
    if not char or char:FindFirstChildOfClass("Tool") then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    for _, t in ipairs(player.Backpack:GetChildren()) do
        if t:IsA("Tool") and t.ToolTip == "Melee" then hum:EquipTool(t) return end
    end
    local any = player.Backpack:FindFirstChildOfClass("Tool")
    if any then hum:EquipTool(any) end
end

local function killAura()
    local myRoot = getRoot(player.Character)
    local enemies = workspace:FindFirstChild("Enemies")
    if not (myRoot and enemies) then return end
    if RegisterAttack and RegisterHit then
        local hits, first = {}, nil
        for _, mob in ipairs(enemies:GetChildren()) do
            if isAlive(mob) and (getRoot(mob).Position - myRoot.Position).Magnitude <= AURA_RANGE then
                first = first or (mob:FindFirstChild("Head") or getRoot(mob))
                table.insert(hits, {mob, getRoot(mob)})
            end
        end
        if first then
            pcall(function()
                RegisterAttack:FireServer(0)
                RegisterHit:FireServer(first, hits)
            end)
        end
    end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(1280, 672))
        VirtualUser:Button1Up(Vector2.new(1280, 672))
    end)
end

local function inRaid()
    local ok, vis = pcall(function() return player.PlayerGui.Main.Timer.Visible end)
    local loc = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations")
    return (ok and vis) or (loc and loc:FindFirstChild("Island 1") ~= nil)
end

local function hasChip()
    local char = player.Character
    return player.Backpack:FindFirstChild("Special Microchip") or (char and char:FindFirstChild("Special Microchip"))
end

local function buyChip()
    if not CommF then return end
    pcall(function()
        if BUY_WITH_FRUIT then
            for _, t in ipairs(player.Backpack:GetChildren()) do
                if t:IsA("Tool") and t:FindFirstChild("Fruit") then
                    CommF:InvokeServer("LoadFruit", t.Name)
                    break
                end
            end
        end
        CommF:InvokeServer("RaidsNpc", "Select", RAID_TYPE)
    end)
end

local function startRaid()
    local myRoot = getRoot(player.Character)
    local map = workspace:FindFirstChild("Map")
    if not (myRoot and map) then return end
    for _, name in ipairs({"CircleIsland", "Boat Castle"}) do
        local isl = map:FindFirstChild(name)
        local summon = isl and isl:FindFirstChild("RaidSummon2")
        local btn = summon and summon:FindFirstChild("Button") and summon.Button:FindFirstChild("Main")
        if btn then
            myRoot.CFrame = btn.CFrame + Vector3.new(0, 4, 0)
            task.wait(0.4)
            local cd = btn:FindFirstChildOfClass("ClickDetector")
            if cd and fireclickdetector then fireclickdetector(cd) end
            return
        end
    end
end

local function currentIsland()
    local loc = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations")
    if not loc then return nil end
    for i = 5, 1, -1 do
        local isl = loc:FindFirstChild("Island " .. i)
        if isl then return isl, i end
    end
end

-- ============ MODE LOGIC ============
local raidActive = false

-- AutoRaid takes priority. It only fights while a raid is active.
local function combatMode()
    if env.AutoRaid then
        return raidActive and "raid" or nil
    end
    if env.AutoFarmNearest then
        return "farm"
    end
    return nil
end

task.spawn(function()
    while alive() do
        local ok, res = pcall(inRaid)
        raidActive = ok and res and true or false
        task.wait(0.25)
    end
end)

-- Hover loop
env.VOIDX_HB = RunService.Heartbeat:Connect(function()
    if not alive() then return end
    local mode = combatMode()
    if not mode then
        target = nil
        return
    end

    local myRoot = getRoot(player.Character)
    if not myRoot then return end

    if not (target and target.Parent and isAlive(target)) then
        target = findNearestMob(mode == "raid" and RAID_RADIUS or RADIUS)
    end

    if target then
        local tRoot = getRoot(target)
        myRoot.CFrame = CFrame.new(tRoot.Position + Vector3.new(0, HEIGHT, 0), tRoot.Position)
        myRoot.AssemblyLinearVelocity = Vector3.zero
        if mode == "farm" then
            setStatus("Killing: " .. target.Name)
        end
    elseif mode == "farm" then
        setStatus("Searching for mobs...")
    end
end)

-- Attack loop
task.spawn(function()
    while alive() do
        if combatMode() and target and isAlive(target) then
            pcall(equipMelee)
            pcall(killAura)
        end
        RunService.Heartbeat:Wait()
    end
end)

-- Raid loop (AutoRaid only)
task.spawn(function()
    while alive() do
        task.wait(0.5)
        if env.AutoRaid then
            pcall(function()
                if not raidActive then
                    target = nil
                    if not hasChip() then
                        setStatus("Buying chip (" .. RAID_TYPE .. ")")
                        buyChip()
                        task.wait(1.5)
                    end
                    if hasChip() then
                        setStatus("Starting raid")
                        startRaid()
                        task.wait(3)
                    else
                        setStatus("No chip, buy failed")
                    end
                else
                    local isl, num = currentIsland()
                    setStatus("Raid: island " .. tostring(num or "?") .. "/5")
                    if not findNearestMob(RAID_RADIUS) then
                        local myRoot = getRoot(player.Character)
                        if isl and myRoot then
                            local cf = isl:IsA("BasePart") and isl.CFrame
                                or (isl:IsA("Model") and isl:GetPivot())
                            if cf then
                                myRoot.CFrame = cf + Vector3.new(0, 30, 0)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ============ CLEANUP ============
env.VOIDX_CLEANUP = function()
    env.VOIDX_TOKEN = nil
    env.AutoFarmNearest = false
    env.AutoRaid = false
    aimOn, loopOn = false, false
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    if env.VOIDX_HB then pcall(function() env.VOIDX_HB:Disconnect() end) end
    if circle then pcall(function() circle:Remove() end) end
    if circleGui then pcall(function() circleGui:Destroy() end) end
    pcall(function() gui:Destroy() end)
    env.VOIDX_AIM, env.VOIDX_LOOP = nil, nil
end

if statusText == "Loading..." and CommF then setStatus("Idle") end
