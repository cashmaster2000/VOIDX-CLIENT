-- voidx.lua | VOID X | Blox Fruits Auto Farm Nearest + Auto Raid (draggable GUI)
-- v3: separate AutoFarm / AutoRaid modes, GUI builds first, safe parenting, re-executable

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
title.
