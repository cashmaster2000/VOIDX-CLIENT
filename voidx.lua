-- voidx.lua | VOID X | Blox Fruits Auto Farm Nearest + Auto Raid (draggable GUI)
-- v2: GUI builds FIRST, safe parenting, no hard abort, re-executable

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

if not game:IsLoaded() then game.Loaded:Wait() end
local player = Players.LocalPlayer
while not player do task.wait() player = Players.LocalPlayer end

local env = (getgenv and getgenv()) or _G

-- Clean up any previous run (lets you re-execute without rejoining)
if env.VOIDX_CLEANUP then pcall(env.VOIDX_CLEANUP) end
local TOKEN = {}
env.VOIDX_TOKEN = TOKEN
local function alive() return env.VOIDX_TOKEN == TOKEN end

env.AutoFarmNearest = false
env.AutoRaid = false

-- SETTINGS
local RADIUS = 150
local RAID_RADIUS = 600
local HEIGHT = 15
local AURA_RANGE = 120
local RAID_TYPE = "Flame"    -- Flame, Ice, Quake, Light, Dark, Spider, Rumble, Magma, Buddha, Sand, Phoenix, Dough
local BUY_WITH_FRUIT = false

local statusText = "Idle"
local function setStatus(s) statusText = s end

local target

-- ============ GUI (built first so it always shows) ============
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

local function safeParent(g)
    -- try several parents until one sticks
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

if not safeParent(gui) then
    warn("[VOID X] Could not parent GUI.")
end

env.VOIDX_CLEANUP = function()
    env.VOIDX_TOKEN = nil
    env.AutoFarmNearest = false
    env.AutoRaid = false
    pcall(function() gui:Destroy() end)
    if env.VOIDX_HB then pcall(function() env.VOIDX_HB:Disconnect() end) end
end

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 200, 0, 190)
main.Position = UDim2.new(0, 20, 0.3, 0)
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
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local function makeToggle(text, flag, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.LayoutOrder = order
    btn.BackgroundColor3 = PANEL
    btn.TextColor3 = RED
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Text = text .. ": OFF"
    btn.Parent = body
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", btn)
    s.Color = RED
    s.Thickness = 1
    btn.MouseButton1Click:Connect(function()
        env[flag] = not env[flag]
        local on = env[flag]
        btn.Text = text .. ": " .. (on and "ON" or "OFF")
        btn.TextColor3 = on and GREEN or RED
        s.Color = on and GREEN or RED
        if not on then
            target = nil
            if not (env.AutoFarmNearest or env.AutoRaid) then setStatus("Idle") end
        end
    end)
end

makeToggle("AutoFarm", "AutoFarmNearest", 1)
makeToggle("AutoRaid", "AutoRaid", 2)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 40)
statusLabel.LayoutOrder = 3
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
    main.Size = minimized and UDim2.new(0, 200, 0, 34) or UDim2.new(0, 200, 0, 190)
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
UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local d = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

print("[VOID X] GUI loaded.")

-- ============ GAME LOGIC ============
if game.PlaceId ~= 2753915549 and game.PlaceId ~= 4442272183 and game.PlaceId ~= 7449423635 then
    setStatus("Not Blox Fruits (PlaceId " .. game.PlaceId .. ")")
    warn("[VOID X] Not a known Blox Fruits place. GUI shown, farming may not work.")
end

local CommF, RegisterAttack, RegisterHit
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
setStatus("Loading...")

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

-- Hover loop
env.VOIDX_HB = RunService.Heartbeat:Connect(function()
    if not alive() then return end
    if not (env.AutoFarmNearest or env.AutoRaid) then return end
    local myRoot = getRoot(player.Character)
    if not myRoot then return end

    local raiding = env.AutoRaid and inRaid()
    if not (target and target.Parent and isAlive(target)) then
        target = findNearestMob(raiding and RAID_RADIUS or RADIUS)
    end
    if target then
        local tRoot = getRoot(target)
        myRoot.CFrame = CFrame.new(tRoot.Position + Vector3.new(0, HEIGHT, 0), tRoot.Position)
        myRoot.AssemblyLinearVelocity = Vector3.zero
        setStatus("Killing: " .. target.Name)
    elseif env.AutoFarmNearest then
        setStatus("Searching for mobs...")
    end
end)

-- Attack loop
task.spawn(function()
    while alive() do
        if (env.AutoFarmNearest or env.AutoRaid) and target and isAlive(target) then
            pcall(equipMelee)
            pcall(killAura)
        end
        RunService.Heartbeat:Wait()
    end
end)

-- Raid loop
task.spawn(function()
    while alive() do
        task.wait(0.5)
        if env.AutoRaid then
            pcall(function()
                if not inRaid() then
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
                            local cf = isl:IsA("BasePart") and isl.CFrame or (isl:IsA("Model") and isl:GetPivot())
                            if cf then myRoot.CFrame = cf + Vector3.new(0, 30, 0) end
                        end
                    end
                end
            end)
        end
    end
end)
