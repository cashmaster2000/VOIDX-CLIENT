-- Loader.lua | Blox Fruits Auto Farm Nearest + Auto Raid
-- Execute this file in your executor.

-- LOADER CHECKS
local BLOX_FRUITS_PLACES = {
    [2753915549] = "Sea 1",
    [4442272183] = "Sea 2",
    [7449423635] = "Sea 3",
}

if not game:IsLoaded() then game.Loaded:Wait() end

if not BLOX_FRUITS_PLACES[game.PlaceId] then
    warn("[Loader] Not in Blox Fruits. Aborting.")
    return
end

if getgenv().BF_LOADER_RAN then
    warn("[Loader] Already running. Rejoin to reload.")
    return
end
getgenv().BF_LOADER_RAN = true

print("[Loader] Blox Fruits detected: " .. BLOX_FRUITS_PLACES[game.PlaceId])

-- MAIN SCRIPT
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

-- SETTINGS
local RADIUS = 150           -- normal farm radius (studs)
local RAID_RADIUS = 600      -- search radius while in a raid
local HEIGHT = 15            -- hover height above mob
local AURA_RANGE = 120       -- kill aura range
local RAID_TYPE = "Flame"    -- Flame, Ice, Quake, Light, Dark, Spider, Rumble, Magma, Buddha, Sand, Phoenix, Dough
local BUY_WITH_FRUIT = false -- best-effort fruit trade, leave false if you have Beli

getgenv().AutoFarmNearest = false
getgenv().AutoRaid = false

local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

local RegisterAttack, RegisterHit
pcall(function()
    local Net = ReplicatedStorage:WaitForChild("Modules", 5):WaitForChild("Net", 5)
    RegisterAttack = Net:FindFirstChild("RE/RegisterAttack")
    RegisterHit = Net:FindFirstChild("RE/RegisterHit")
end)

-- HELPERS
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
    for _, t in ipairs(player.Backpack:GetChildren()) do
        if t:IsA("Tool") and t.ToolTip == "Melee" then
            char.Humanoid:EquipTool(t) return
        end
    end
    local any = player.Backpack:FindFirstChildOfClass("Tool")
    if any then char.Humanoid:EquipTool(any) end
end

-- Kill aura: hits every alive mob in range at once
local function killAura()
    local myRoot = getRoot(player.Character)
    local enemies = workspace:FindFirstChild("Enemies")
    if not (myRoot and enemies and RegisterAttack and RegisterHit) then return end
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
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(1280, 672))
        VirtualUser:Button1Up(Vector2.new(1280, 672))
    end)
end

-- RAID HELPERS
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
    if not myRoot then return end
    local map = workspace:FindFirstChild("Map")
    if not map then return end
    for _, name in ipairs({"CircleIsland", "Boat Castle"}) do
        local isl = map:FindFirstChild(name)
        local summon = isl and isl:FindFirstChild("RaidSummon2")
        local main = summon and summon:FindFirstChild("Button") and summon.Button:FindFirstChild("Main")
        if main then
            myRoot.CFrame = main.CFrame + Vector3.new(0, 4, 0)
            task.wait(0.4)
            local cd = main:FindFirstChildOfClass("ClickDetector")
            if cd and fireclickdetector then fireclickdetector(cd) end
            return
        end
    end
end

-- Highest-numbered island currently spawned (1-5)
local function currentIsland()
    local loc = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations")
    if not loc then return nil end
    for i = 5, 1, -1 do
        local isl = loc:FindFirstChild("Island " .. i)
        if isl then return isl, i end
    end
end

-- HOVER LOOP
local target
RunService.Heartbeat:Connect(function()
    if not (getgenv().AutoFarmNearest or getgenv().AutoRaid) then return end
    local myRoot = getRoot(player.Character)
    if not myRoot then return end

    local raiding = getgenv().AutoRaid and inRaid()
    if not (target and target.Parent and isAlive(target)) then
        target = findNearestMob(raiding and RAID_RADIUS or RADIUS)
    end
    if target then
        local tRoot = getRoot(target)
        myRoot.CFrame = CFrame.new(tRoot.Position + Vector3.new(0, HEIGHT, 0), tRoot.Position)
        myRoot.AssemblyLinearVelocity = Vector3.zero
    end
end)

-- ATTACK LOOP
task.spawn(function()
    while true do
        if (getgenv().AutoFarmNearest or getgenv().AutoRaid) and target and isAlive(target) then
            equipMelee()
            killAura()
        end
        RunService.Heartbeat:Wait()
    end
end)

-- RAID LOOP
task.spawn(function()
    while true do
        task.wait(0.5)
        if getgenv().AutoRaid then
            if not inRaid() then
                target = nil
                if not hasChip() then
                    buyChip()
                    task.wait(1.5)
                end
                if hasChip() then
                    startRaid()
                    task.wait(3)
                end
            else
                if not findNearestMob(RAID_RADIUS) then
                    local isl = currentIsland()
                    local myRoot = getRoot(player.Character)
                    if isl and myRoot then
                        local cf = isl:IsA("BasePart") and isl.CFrame or (isl:IsA("Model") and isl:GetPivot())
                        if cf then myRoot.CFrame = cf + Vector3.new(0, 30, 0) end
                    end
                end
            end
        end
    end
end)

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AutoFarmGui"
gui.ResetOnSpawn = false
gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local function makeButton(text, yScale, flag)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 140, 0, 40)
    btn.Position = UDim2.new(0, 10, yScale, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 70, 70)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Text = text .. ": OFF"
    btn.Parent = gui
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        getgenv()[flag] = not getgenv()[flag]
        local on = getgenv()[flag]
        btn.Text = text .. ": " .. (on and "ON" or "OFF")
        btn.TextColor3 = on and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 70, 70)
        if not on then target = nil end
    end)
end

makeButton("AutoFarm", 0.35, "AutoFarmNearest")
makeButton("AutoRaid", 0.43, "AutoRaid")

print("[Loader] Loaded. Use the AutoFarm and AutoRaid buttons.")
