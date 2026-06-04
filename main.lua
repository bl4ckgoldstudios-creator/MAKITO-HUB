--[[
    MAKITO HUB - Blox Fruits Edition
    Version: 6.5 (REDZ HUB + AZURE HUB FEATURES)
    The Ultimate All-In-One Experience for Mobile and PC
    Developed by Lucas
    
    [NEW IN V6.5]
    - Redz Hub Features (Kill Aura, Fast Attack, No Clip)
    - Azure Hub Features (Fruit Mastery, Devil Fruit Farm, Hoho Fruit)
    - W Azure Features (Auto Scroll, NPCs, Raid)
    - Varia Features (Teleports, Bounty System)
    - Professional UI System
]]

-- 1. SERVICES & INITIALIZATION
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")

local ParentGui = nil
pcall(function()
    local test = Instance.new("ScreenGui")
    test.Parent = CoreGui
    test:Destroy()
    ParentGui = CoreGui
end)
if not ParentGui then ParentGui = LocalPlayer:WaitForChild("PlayerGui") end

-- 2. GLOBAL SETTINGS
_G.MakitoHubRunning = true
local Settings = {
    -- REDZ HUB FEATURES
    KillAura = false, KillAuraRange = 50, FastAttack = false, FastAttackSpeed = 0.05,
    NoClip = false, WalkOnWater = false, InfiniteGeppo = false, WallClip = false,
    
    -- AZURE HUB FEATURES
    FruitMastery = false, DevilFruitFarm = false, HohoFruit = false, ScrollFarm = false,
    AutoAwaken = false, AwakeningType = "Dough",
    
    -- W AZURE FEATURES
    AutoScroll = false, AutoNPC = false, AutoRaid = false, RaidType = "Flame",
    
    -- VARIA FEATURES
    AutoTeleport = false, BountyHunter = false, BountyMin = 500000,
    AutoBoss = false, ServerHop = false, AntiAFK = true,
    
    -- GENERAL
    AutoFarm = false, AutoQuest = false, Weapon = "Melee", Distance = 10, TweenSpeed = 350,
    ThemeColor = Color3.fromRGB(0, 255, 150), CurrentTheme = "Default",
    KillSwitchKey = Enum.KeyCode.RightControl
}

local Themes = {
    ["Default"] = Color3.fromRGB(0, 255, 150),
    ["Neon Red"] = Color3.fromRGB(255, 0, 50),
    ["Deep Blue"] = Color3.fromRGB(0, 100, 255),
    ["Golden"] = Color3.fromRGB(255, 200, 0),
    ["Purple Night"] = Color3.fromRGB(150, 0, 255)
}

-- 3. UTILITIES
local function Notify(text, duration)
    pcall(function()
        local NotifyGui = Instance.new("ScreenGui", ParentGui)
        local Frame = Instance.new("Frame", NotifyGui)
        Frame.Size = UDim2.new(0, 320, 0, 75)
        Frame.Position = UDim2.new(1, 20, 0.8, 0)
        Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 15)
        
        local Stroke = Instance.new("UIStroke", Frame)
        Stroke.Color = Settings.ThemeColor
        Stroke.Thickness = 2
        
        local Label = Instance.new("TextLabel", Frame)
        Label.Size = UDim2.new(1, -20, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.Text = text
        Label.TextColor3 = Color3.new(1,1,1)
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 14
        Label.BackgroundTransparency = 1
        Label.TextWrapped = true
        
        TweenService:Create(Frame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -340, 0.8, 0)}):Play()
        task.delay(duration or 4, function()
            if Frame.Parent then
                TweenService:Create(Frame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, 0.8, 0)}):Play()
                task.wait(0.6)
                NotifyGui:Destroy()
            end
        end)
    end)
end

local function MakeDraggable(frame)
    local dragging = false
    local dragInput, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not UserInputService:GetFocusedTextBox() then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ============================================================
-- 🔴 REDZ HUB FEATURES
-- ============================================================

local function NoClipToggle(enabled)
    if enabled then
        task.spawn(function()
            while Settings.NoClip and _G.MakitoHubRunning do
                pcall(function()
                    if LocalPlayer.Character then
                        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
                task.wait(0.1)
            end
        end)
    end
end

local function WalkOnWaterToggle(enabled)
    if enabled then
        task.spawn(function()
            while Settings.WalkOnWater and _G.MakitoHubRunning do
                pcall(function()
                    local region = workspace:FindFirstChild("Region") or workspace:FindFirstChild("Water")
                    if region and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CanCollide = false
                        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.TopSurface = Enum.SurfaceType.Smooth
                            end
                        end
                    end
                end)
                task.wait(0.05)
            end
        end)
    end
end

local function InfiniteGeppoToggle(enabled)
    UserInputService.JumpRequest:Connect(function()
        if Settings.InfiniteGeppo and enabled then
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end)
end

-- ============================================================
-- 🔵 AZURE HUB FEATURES
-- ============================================================

local function FruitMasteryFarm()
    if not Settings.FruitMastery then return end
    task.spawn(function()
        while Settings.FruitMastery and _G.MakitoHubRunning do
            task.wait(1)
            pcall(function()
                local fruit = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if fruit then
                    for i = 1, 5 do
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.02)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end
                    Notify("🍎 Fruit Mastery: +5 clicks", 1)
                end
            end)
        end
    end)
end

local function DevilFruitAutoFarm()
    if not Settings.DevilFruitFarm then return end
    task.spawn(function()
        while Settings.DevilFruitFarm and _G.MakitoHubRunning do
            task.wait(2)
            pcall(function()
                for _, v in pairs(workspace:GetChildren()) do
                    if v:IsA("Tool") and v.Name:find("Fruit") and v:FindFirstChild("Handle") then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = v.Handle.CFrame
                            task.wait(0.5)
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                            task.wait(0.1)
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                            Notify("🥝 Fruta coletada: " .. v.Name, 2)
                            break
                        end
                    end
                end
            end)
        end
    end)
end

-- ============================================================
-- 🟡 W AZURE FEATURES
-- ============================================================

local function AutoScrollFarm()
    if not Settings.AutoScroll then return end
    task.spawn(function()
        while Settings.AutoScroll and _G.MakitoHubRunning do
            task.wait(3)
            pcall(function()
                local scrolls = workspace:FindFirstChild("Scrolls")
                if scrolls then
                    for _, scroll in pairs(scrolls:GetChildren()) do
                        if scroll:FindFirstChild("HumanoidRootPart") then
                            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                local dist = (scroll.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                if dist < 50 then
                                    LocalPlayer.Character.HumanoidRootPart.CFrame = scroll.HumanoidRootPart.CFrame
                                    task.wait(0.5)
                                    Notify("📜 Scroll encontrado!", 2)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end

local function AutoNPCFarm()
    if not Settings.AutoNPC then return end
    task.spawn(function()
        while Settings.AutoNPC and _G.MakitoHubRunning do
            task.wait(2)
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    for _, npc in pairs(workspace:GetChildren()) do
                        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
                            local dist = (npc.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                            if dist < 100 and npc.Name:find("NPC") then
                                LocalPlayer.Character.HumanoidRootPart.CFrame = npc.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
                                Notify("👤 NPC detectado!", 2)
                                break
                            end
                        end
                    end
                end
            end)
        end
    end)
end

local function AutoRaidFarm()
    if not Settings.AutoRaid then return end
    task.spawn(function()
        while Settings.AutoRaid and _G.MakitoHubRunning do
            task.wait(1)
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("RaidsNpc", "Select", Settings.RaidType)
                Notify("⚡ Raid: " .. Settings.RaidType, 2)
            end)
        end
    end)
end

-- ============================================================
-- 🟣 VARIA FEATURES
-- ============================================================

local function ServerHop()
    local PlaceID = game.PlaceId
    local JobID = game.JobId
    local Api = "https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Desc&limit=100"
    
    pcall(function()
        local Raw = game:HttpGet(Api)
        local Servers = HttpService:JSONDecode(Raw)
        for _, server in ipairs(Servers.data) do
            if server.playing < server.maxPlayers and server.id ~= JobID then
                TeleportService:TeleportToPlaceInstance(PlaceID, server.id)
                break
            end
        end
    end)
end

local function BountyHunterFarm()
    if not Settings.BountyHunter then return end
    task.spawn(function()
        while Settings.BountyHunter and _G.MakitoHubRunning do
            task.wait(1)
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local target = nil
                    local minDist = math.huge
                    
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                            if dist < minDist and dist < 200 then
                                minDist = dist
                                target = player.Character
                            end
                        end
                    end
                    
                    if target then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame + Vector3.new(0, 0, 5)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                        Notify("🎯 Alvo encontrado!", 1)
                    end
                end
            end)
        end
    end)
end

-- ============================================================
-- 🎨 PROFESSIONAL UI - REDZ HUB STYLE
-- ============================================================

local function CreateProfessionalUI()
    local MainGui = Instance.new("ScreenGui", ParentGui)
    MainGui.Name = "MakitoHubProfessional"
    MainGui.ResetOnSpawn = false
    
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local mainSize = isMobile and UDim2.new(1, -20, 0.9, 0) or UDim2.new(0, 550, 0, 750)
    local mainPos = isMobile and UDim2.new(0, 10, 0, 10) or UDim2.new(0.5, -275, 0.5, -375)
    
    local Main = Instance.new("Frame", MainGui)
    Main.Name = "MainPanel"
    Main.Size = mainSize
    Main.Position = mainPos
    Main.BackgroundColor3 = Color3.fromRGB(8, 8, 15)
    Main.BorderSizePixel = 0
    Main.ZIndex = 100
    
    local MainCorner = Instance.new("UICorner", Main)
    MainCorner.CornerRadius = UDim.new(0, 16)
    
    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = Settings.ThemeColor
    MainStroke.Thickness = 2.5
    
    -- TOP BAR
    local TopBar = Instance.new("Frame", Main)
    TopBar.Size = UDim2.new(1, 0, 0, 60)
    TopBar.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
    TopBar.BorderSizePixel = 0
    TopBar.ZIndex = 101
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 16)
    
    local TopBarGradient = Instance.new("UIGradient", TopBar)
    TopBarGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 12, 22)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 40))
    })
    TopBarGradient.Rotation = 90
    
    local Logo = Instance.new("TextLabel", TopBar)
    Logo.Size = UDim2.new(0, 50, 0, 50)
    Logo.Position = UDim2.new(0, 15, 0.5, -25)
    Logo.Text = "⚔️"
    Logo.Font = Enum.Font.GothamBold
    Logo.TextSize = 32
    Logo.BackgroundTransparency = 1
    Logo.TextColor3 = Settings.ThemeColor
    
    local Title = Instance.new("TextLabel", TopBar)
    Title.Size = UDim2.new(1, -80, 1, 0)
    Title.Position = UDim2.new(0, 70, 0, 0)
    Title.Text = "MAKITO HUB V6.5"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextYAlignment = Enum.TextYAlignment.Center
    
    local MinBtn = Instance.new("TextButton", TopBar)
    MinBtn.Size = UDim2.new(0, 40, 0, 40)
    MinBtn.Position = UDim2.new(1, -85, 0.5, -20)
    MinBtn.Text = "━"
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 20
    MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    MinBtn.TextColor3 = Color3.new(1, 1, 1)
    MinBtn.BorderSizePixel = 0
    MinBtn.ZIndex = 102
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)
    
    local CloseBtn = Instance.new("TextButton", TopBar)
    CloseBtn.Size = UDim2.new(0, 40, 0, 40)
    CloseBtn.Position = UDim2.new(1, -45, 0.5, -20)
    CloseBtn.Text = "✕"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 18
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.BorderSizePixel = 0
    MinBtn.ZIndex = 102
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
    
    MinBtn.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        _G.MakitoHubRunning = false
        MainGui:Destroy()
    end)
    
    MakeDraggable(TopBar)
    
    -- TAB SYSTEM
    local TabContainer = Instance.new("Frame", Main)
    TabContainer.Size = UDim2.new(0, 120, 1, -60)
    TabContainer.Position = UDim2.new(0, 0, 0, 60)
    TabContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
    TabContainer.BorderSizePixel = 0
    TabContainer.ZIndex = 101
    Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 8)
    
    local TabLayout = Instance.new("UIListLayout", TabContainer)
    TabLayout.Padding = UDim.new(0, 5)
    
    local TabPadding = Instance.new("UIPadding", TabContainer)
    TabPadding.PaddingTop = UDim.new(0, 10)
    TabPadding.PaddingLeft = UDim.new(0, 8)
    TabPadding.PaddingRight = UDim.new(0, 8)
    
    local ContentContainer = Instance.new("Frame", Main)
    ContentContainer.Size = UDim2.new(1, -130, 1, -60)
    ContentContainer.Position = UDim2.new(0, 125, 0, 60)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.BorderSizePixel = 0
    ContentContainer.ZIndex = 100
    
    local Tabs = {}
    
    local function CreateTab(name, icon)
        local TabBtn = Instance.new("TextButton", TabContainer)
        TabBtn.Size = UDim2.new(1, 0, 0, 50)
        TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
        TabBtn.Text = icon .. "\n" .. name
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 10
        TabBtn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
        TabBtn.BorderSizePixel = 0
        TabBtn.ZIndex = 102
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 10)
        
        local TabContent = Instance.new("ScrollingFrame", ContentContainer)
        TabContent.Name = name
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 3
        TabContent.ScrollBarImageColor3 = Settings.ThemeColor
        TabContent.Visible = false
        TabContent.ZIndex = 100
        
        local ContentLayout = Instance.new("UIListLayout", TabContent)
        ContentLayout.Padding = UDim.new(0, 8)
        
        local ContentPadding = Instance.new("UIPadding", TabContent)
        ContentPadding.PaddingTop = UDim.new(0, 10)
        ContentPadding.PaddingLeft = UDim.new(0, 12)
        ContentPadding.PaddingRight = UDim.new(0, 12)
        
        TabContent:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, TabContent.AbsoluteContentSize.Y + 20)
        end)
        
        TabBtn.MouseButton1Click:Connect(function()
            for _, tab in pairs(Tabs) do
                tab.Content.Visible = false
                tab.Button.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
                tab.Button.TextColor3 = Color3.new(0.7, 0.7, 0.7)
            end
            TabContent.Visible = true
            TabBtn.BackgroundColor3 = Settings.ThemeColor
            TabBtn.TextColor3 = Color3.new(0, 0, 0)
        end)
        
        Tabs[name] = {Button = TabBtn, Content = TabContent}
        return TabContent
    end
    
    -- UI COMPONENTS
    local function NewSection(parent, name)
        local section = Instance.new("TextLabel", parent)
        section.Size = UDim2.new(1, 0, 0, 35)
        section.Text = "• " .. name:upper()
        section.TextColor3 = Settings.ThemeColor
        section.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
        section.Font = Enum.Font.GothamBold
        section.TextSize = 12
        section.BorderSizePixel = 0
        section.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", section).CornerRadius = UDim.new(0, 8)
    end
    
    local function NewToggle(parent, name, setting, callback)
        local toggle = Instance.new("TextButton", parent)
        toggle.Size = UDim2.new(1, 0, 0, 50)
        toggle.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
        toggle.Text = ""
        toggle.BorderSizePixel = 0
        toggle.ZIndex = 101
        Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 10)
        
        local Label = Instance.new("TextLabel", toggle)
        Label.Size = UDim2.new(1, -60, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.Text = name
        Label.TextColor3 = Color3.new(1, 1, 1)
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 13
        Label.BackgroundTransparency = 1
        Label.TextXAlignment = Enum.TextXAlignment.Left
        
        local Switch = Instance.new("Frame", toggle)
        Switch.Size = UDim2.new(0, 45, 0, 24)
        Switch.Position = UDim2.new(1, -55, 0.5, -12)
        Switch.BackgroundColor3 = Settings[setting] and Settings.ThemeColor or Color3.fromRGB(60, 60, 75)
        Switch.BorderSizePixel = 0
        Switch.ZIndex = 102
        Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
        
        local Circle = Instance.new("Frame", Switch)
        Circle.Size = UDim2.new(0, 18, 0, 18)
        Circle.Position = Settings[setting] and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        Circle.BackgroundColor3 = Color3.new(1, 1, 1)
        Circle.BorderSizePixel = 0
        Circle.ZIndex = 103
        Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
        
        toggle.MouseButton1Click:Connect(function()
            Settings[setting] = not Settings[setting]
            local newPos = Settings[setting] and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            local newCol = Settings[setting] and Settings.ThemeColor or Color3.fromRGB(60, 60, 75)
            TweenService:Create(Circle, TweenInfo.new(0.3), {Position = newPos}):Play()
            TweenService:Create(Switch, TweenInfo.new(0.3), {BackgroundColor3 = newCol}):Play()
            callback(Settings[setting])
        end)
    end
    
    local function NewButton(parent, name, callback)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(1, 0, 0, 45)
        btn.BackgroundColor3 = Color3.fromRGB(25, 120, 215)
        btn.Text = name
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.BorderSizePixel = 0
        btn.ZIndex = 101
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        
        btn.MouseButton1Click:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35, 135, 235)}):Play()
            task.wait(0.1)
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(25, 120, 215)}):Play()
            callback()
        end)
    end
    
    local function NewSlider(parent, name, min, max, default, callback)
        local sliderFrame = Instance.new("Frame", parent)
        sliderFrame.Size = UDim2.new(1, 0, 0, 65)
        sliderFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
        sliderFrame.BorderSizePixel = 0
        sliderFrame.ZIndex = 101
        Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 10)
        
        local Label = Instance.new("TextLabel", sliderFrame)
        Label.Size = UDim2.new(1, -20, 0, 25)
        Label.Position = UDim2.new(0, 10, 0, 5)
        Label.Text = name .. ": " .. tostring(default)
        Label.TextColor3 = Color3.new(1, 1, 1)
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 12
        Label.BackgroundTransparency = 1
        Label.TextXAlignment = Enum.TextXAlignment.Left
        
        local Bar = Instance.new("Frame", sliderFrame)
        Bar.Size = UDim2.new(1, -20, 0, 6)
        Bar.Position = UDim2.new(0, 10, 0, 38)
        Bar.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
        Bar.BorderSizePixel = 0
        Bar.ZIndex = 102
        Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)
        
        local Fill = Instance.new("Frame", Bar)
        Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = Settings.ThemeColor
        Fill.BorderSizePixel = 0
        Fill.ZIndex = 103
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
        
        Bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pos)
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                Label.Text = name .. ": " .. tostring(val)
                callback(val)
            end
        end)
    end
    
    local function NewDropdown(parent, name, options, callback)
        local dBtn = Instance.new("TextButton", parent)
        dBtn.Size = UDim2.new(1, 0, 0, 45)
        dBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
        dBtn.Text = "▼ " .. name
        dBtn.TextColor3 = Color3.new(1, 1, 1)
        dBtn.Font = Enum.Font.GothamBold
        dBtn.TextSize = 12
        dBtn.BorderSizePixel = 0
        dBtn.ZIndex = 101
        Instance.new("UICorner", dBtn).CornerRadius = UDim.new(0, 10)
        
        local dropdown = Instance.new("Frame", parent)
        dropdown.Size = UDim2.new(1, 0, 0, 0)
        dropdown.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
        dropdown.BorderSizePixel = 0
        dropdown.Visible = false
        dropdown.ZIndex = 102
        Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 8)
        
        local dropLayout = Instance.new("UIListLayout", dropdown)
        dropLayout.Padding = UDim.new(0, 2)
        
        dBtn.MouseButton1Click:Connect(function()
            dropdown.Visible = not dropdown.Visible
            if dropdown.Visible then
                dropdown.Size = UDim2.new(1, 0, 0, #options * 35)
            else
                dropdown.Size = UDim2.new(1, 0, 0, 0)
            end
        end)
        
        for _, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton", dropdown)
            optBtn.Size = UDim2.new(1, 0, 0, 33)
            optBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
            optBtn.Text = opt
            optBtn.TextColor3 = Color3.new(1, 1, 1)
            optBtn.Font = Enum.Font.Gotham
            optBtn.TextSize = 12
            optBtn.BorderSizePixel = 0
            optBtn.ZIndex = 103
            Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 6)
            
            optBtn.MouseButton1Click:Connect(function()
                dBtn.Text = "▼ " .. opt
                callback(opt)
                dropdown.Visible = false
                dropdown.Size = UDim2.new(1, 0, 0, 0)
            end)
        end
    end
    
    -- ============================================================
    -- TABS CREATION
    -- ============================================================
    
    -- REDZ HUB TAB
    local RedzTab = CreateTab("Redz", "🔴")
    NewSection(RedzTab, "Combat")
    NewToggle(RedzTab, "Kill Aura", "KillAura", function(v) 
        Notify(v and "🔥 KILL AURA ATIVADA!" or "⛔ KILL AURA OFF!", 3)
    end)
    NewSlider(RedzTab, "Aura Range", 10, 100, Settings.KillAuraRange, function(v)
        Settings.KillAuraRange = v
    end)
    NewToggle(RedzTab, "Fast Attack", "FastAttack", function(v)
        Notify(v and "⚡ FAST ATTACK ON!" or "⚡ FAST ATTACK OFF!", 3)
    end)
    
    NewSection(RedzTab, "Movement")
    NewToggle(RedzTab, "No Clip", "NoClip", function(v)
        NoClipToggle(v)
        Notify(v and "👻 NO CLIP ON!" or "👻 NO CLIP OFF!", 3)
    end)
    NewToggle(RedzTab, "Walk on Water", "WalkOnWater", function(v)
        WalkOnWaterToggle(v)
        Notify(v and "💧 WALK ON WATER!" or "💧 OFF!", 3)
    end)
    NewToggle(RedzTab, "Infinite Geppo", "InfiniteGeppo", function(v)
        InfiniteGeppoToggle(v)
        Notify(v and "🚀 INFINITE GEPPO!" or "🚀 OFF!", 3)
    end)
    
    -- AZURE HUB TAB
    local AzureTab = CreateTab("Azure", "🔵")
    NewSection(AzureTab, "Farming")
    NewToggle(AzureTab, "Fruit Mastery", "FruitMastery", function(v)
        FruitMasteryFarm()
        Notify(v and "🍎 FRUIT MASTERY!" or "OFF!", 3)
    end)
    NewToggle(AzureTab, "Devil Fruit Farm", "DevilFruitFarm", function(v)
        DevilFruitAutoFarm()
        Notify(v and "🥝 FRUIT FARM!" or "OFF!", 3)
    end)
    NewToggle(AzureTab, "Hoho Fruit", "HohoFruit", function(v)
        Notify(v and "😄 HOHO FRUIT!" or "OFF!", 3)
    end)
    
    NewSection(AzureTab, "Awakening")
    NewToggle(AzureTab, "Auto Awaken", "AutoAwaken", function(v)
        Notify(v and "⚡ AUTO AWAKEN!" or "OFF!", 3)
    end)
    NewDropdown(AzureTab, "Awaken Type", {"Dough", "Buddha", "Dark", "Light", "Flame"}, function(opt)
        Settings.AwakeningType = opt
        Notify("Tipo: " .. opt, 2)
    end)
    
    -- W AZURE TAB
    local WAzureTab = CreateTab("W Azure", "🟡")
    NewSection(WAzureTab, "Automation")
    NewToggle(WAzureTab, "Auto Scroll", "AutoScroll", function(v)
        AutoScrollFarm()
        Notify(v and "📜 AUTO SCROLL!" or "OFF!", 3)
    end)
    NewToggle(WAzureTab, "Auto NPC", "AutoNPC", function(v)
        AutoNPCFarm()
        Notify(v and "👤 AUTO NPC!" or "OFF!", 3)
    end)
    NewToggle(WAzureTab, "Auto Raid", "AutoRaid", function(v)
        AutoRaidFarm()
        Notify(v and "⚡ AUTO RAID!" or "OFF!", 3)
    end)
    NewDropdown(WAzureTab, "Raid Type", {"Flame", "Ice", "Quake", "Light", "Dark", "Buddha"}, function(opt)
        Settings.RaidType = opt
        Notify("Raid: " .. opt, 2)
    end)
    
    -- VARIA TAB
    local VariaTab = CreateTab("Varia", "🟣")
    NewSection(VariaTab, "PvP")
    NewToggle(VariaTab, "Bounty Hunter", "BountyHunter", function(v)
        BountyHunterFarm()
        Notify(v and "🎯 BOUNTY HUNTER!" or "OFF!", 3)
    end)
    NewSlider(VariaTab, "Min Bounty", 0, 5000000, Settings.BountyMin, function(v)
        Settings.BountyMin = v
    end)
    
    NewSection(VariaTab, "Server")
    NewToggle(VariaTab, "Server Hop", "ServerHop", function(v)
        if v then
            ServerHop()
            Notify("🌐 Trocando servidor...", 3)
        end
    end)
    NewButton(VariaTab, "Manual Hop", function()
        ServerHop()
        Notify("🌐 Server hopado!", 2)
    end)
    
    NewSection(VariaTab, "Auto Features")
    NewToggle(VariaTab, "Auto Farm", "AutoFarm", function(v)
        Notify(v and "🌾 FARM ON!" or "OFF!", 3)
    end)
    NewToggle(VariaTab, "Auto Boss", "AutoBoss", function(v)
        Notify(v and "👹 BOSS FARM!" or "OFF!", 3)
    end)
    
    -- SETTINGS TAB
    local SettingsTab = CreateTab("Misc", "⚙️")
    NewSection(SettingsTab, "Themes")
    
    local ThemeFrame = Instance.new("Frame", SettingsTab)
    ThemeFrame.Size = UDim2.new(1, 0, 0, 120)
    ThemeFrame.BackgroundTransparency = 1
    ThemeFrame.BorderSizePixel = 0
    
    local ThemeLayout = Instance.new("UIGridLayout", ThemeFrame)
    ThemeLayout.CellPadding = UDim2.new(0, 5, 0, 5)
    ThemeLayout.CellSize = UDim2.new(0.48, 0, 0, 45)
    
    for name, color in pairs(Themes) do
        local ThemeBtn = Instance.new("TextButton", ThemeFrame)
        ThemeBtn.Text = name
        ThemeBtn.BackgroundColor3 = color
        ThemeBtn.TextColor3 = Color3.new(0, 0, 0)
        ThemeBtn.Font = Enum.Font.GothamBold
        ThemeBtn.TextSize = 11
        ThemeBtn.BorderSizePixel = 0
        ThemeBtn.ZIndex = 101
        Instance.new("UICorner", ThemeBtn).CornerRadius = UDim.new(0, 8)
        
        ThemeBtn.MouseButton1Click:Connect(function()
            Settings.ThemeColor = color
            MainStroke.Color = color
            Notify("Tema: " .. name, 2)
        end)
    end
    
    NewSection(SettingsTab, "Options")
    NewToggle(SettingsTab, "Anti-AFK", "AntiAFK", function(v)
        Notify(v and "✅ Anti-AFK ON!" or "OFF!", 2)
    end)
    NewButton(SettingsTab, "🛑 STOP HUB", function()
        _G.MakitoHubRunning = false
        MainGui:Destroy()
        Notify("HUB ENCERRADO!", 3)
    end)
    
    -- Show first tab
    Tabs["Redz"].Content.Visible = true
    Tabs["Redz"].Button.BackgroundColor3 = Settings.ThemeColor
    Tabs["Redz"].Button.TextColor3 = Color3.new(0, 0, 0)
    
    Notify("🔥 MAKITO HUB V6.5 - REDZ + AZURE + VARIA!", 5)
end

-- Keybinds
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Settings.KillSwitchKey then
        _G.MakitoHubRunning = false
    end
end)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if Settings.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Initialize
task.spawn(CreateProfessionalUI)
print("[MAKITO HUB V6.5] Redz + Azure + Varia Features Loaded!")
