--[[
    MAKITO HUB - Blox Fruits Edition
    Version: 6.3 (PROFESSIONAL REDZ STYLE UI)
    The Ultimate All-In-One Experience for Mobile and PC
    Developed by Lucas
    
    [NEW IN V6.3]
    - Professional Redz Hub Style UI
    - Mobile & PC Responsive Design
    - Tab System with Smooth Animations
    - Modern Dark Theme
    - Touch-Friendly Controls
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
    AutoFarm = false, FastAttack = false, AutoQuest = false, KillAura = false,
    KillAuraRange = 50, Weapon = "Melee", Distance = 10, TweenSpeed = 350,
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
        Frame.Size = UDim2.new(0, 300, 0, 70)
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
        Label.TextSize = 15
        Label.BackgroundTransparency = 1
        Label.TextWrapped = true
        
        TweenService:Create(Frame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -320, 0.8, 0)}):Play()
        task.delay(duration or 4, function()
            TweenService:Create(Frame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, 0.8, 0)}):Play()
            task.wait(0.6)
            NotifyGui:Destroy()
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
-- 🎨 PROFESSIONAL UI - REDZ HUB STYLE
-- ============================================================

local function CreateProfessionalUI()
    -- Main Container
    local MainGui = Instance.new("ScreenGui", ParentGui)
    MainGui.Name = "MakitoHubProfessional"
    MainGui.ResetOnSpawn = false
    
    -- Detect if mobile
    local UserInputService = game:GetService("UserInputService")
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    
    -- Responsive sizes
    local mainSize = isMobile and UDim2.new(1, -20, 0.9, 0) or UDim2.new(0, 550, 0, 700)
    local mainPos = isMobile and UDim2.new(0, 10, 0, 10) or UDim2.new(0.5, -275, 0.5, -350)
    
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
    MainStroke.Transparency = 0.3
    
    -- ✨ SHADOW EFFECT
    local Shadow = Instance.new("TextLabel", Main)
    Shadow.Size = UDim2.new(1, 0, 1, 0)
    Shadow.Position = UDim2.new(0, 0, 0, 0)
    Shadow.BackgroundTransparency = 1
    Shadow.Text = ""
    Shadow.ZIndex = 0
    
    local ShadowStroke = Instance.new("UIStroke", Shadow)
    ShadowStroke.Color = Color3.new(0, 0, 0)
    ShadowStroke.Thickness = 5
    ShadowStroke.Transparency = 0.6
    Instance.new("UICorner", Shadow).CornerRadius = UDim.new(0, 16)
    
    -- TOP BAR (DRAGGABLE)
    local TopBar = Instance.new("Frame", Main)
    TopBar.Name = "TopBar"
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
    
    -- Logo & Title
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
    Title.Text = "MAKITO HUB V6.3"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextYAlignment = Enum.TextYAlignment.Center
    
    -- Close & Minimize Buttons
    local ButtonSize = 40
    local MinBtn = Instance.new("TextButton", TopBar)
    MinBtn.Size = UDim2.new(0, ButtonSize, 0, ButtonSize)
    MinBtn.Position = UDim2.new(1, -(ButtonSize * 2 + 15), 0.5, -ButtonSize/2)
    MinBtn.Text = "━"
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 20
    MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    MinBtn.TextColor3 = Color3.new(1, 1, 1)
    MinBtn.BorderSizePixel = 0
    MinBtn.ZIndex = 102
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)
    
    local CloseBtn = Instance.new("TextButton", TopBar)
    CloseBtn.Size = UDim2.new(0, ButtonSize, 0, ButtonSize)
    CloseBtn.Position = UDim2.new(1, -10 - ButtonSize, 0.5, -ButtonSize/2)
    CloseBtn.Text = "✕"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 18
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.ZIndex = 102
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
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 120, 1, -60)
    TabContainer.Position = UDim2.new(0, 0, 0, 60)
    TabContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
    TabContainer.BorderSizePixel = 0
    TabContainer.ZIndex = 101
    
    Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 8)
    
    local TabLayout = Instance.new("UIListLayout", TabContainer)
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local TabPadding = Instance.new("UIPadding", TabContainer)
    TabPadding.PaddingTop = UDim.new(0, 10)
    TabPadding.PaddingBottom = UDim.new(0, 10)
    TabPadding.PaddingLeft = UDim.new(0, 8)
    TabPadding.PaddingRight = UDim.new(0, 8)
    
    -- CONTENT AREA
    local ContentContainer = Instance.new("Frame", Main)
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -130, 1, -60)
    ContentContainer.Position = UDim2.new(0, 125, 0, 60)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.BorderSizePixel = 0
    ContentContainer.ZIndex = 100
    
    local Tabs = {}
    
    local function CreateTab(name, icon)
        -- Tab Button
        local TabBtn = Instance.new("TextButton", TabContainer)
        TabBtn.Size = UDim2.new(1, 0, 0, 50)
        TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
        TabBtn.Text = icon .. "\n" .. name
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 11
        TabBtn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
        TabBtn.BorderSizePixel = 0
        TabBtn.ZIndex = 102
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 10)
        
        -- Content Frame
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
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        
        local ContentPadding = Instance.new("UIPadding", TabContent)
        ContentPadding.PaddingTop = UDim.new(0, 10)
        ContentPadding.PaddingBottom = UDim.new(0, 10)
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
        section.TextSize = 13
        section.BorderSizePixel = 0
        section.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", section).CornerRadius = UDim.new(0, 8)
        return section
    end
    
    local function NewToggle(parent, name, setting, callback)
        local toggle = Instance.new("TextButton", parent)
        toggle.Size = UDim2.new(1, 0, 0, 55)
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
        Label.TextSize = 14
        Label.BackgroundTransparency = 1
        Label.TextXAlignment = Enum.TextXAlignment.Left
        
        local Switch = Instance.new("Frame", toggle)
        Switch.Name = "Switch"
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
        
        return toggle
    end
    
    local function NewButton(parent, name, callback)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(1, 0, 0, 48)
        btn.BackgroundColor3 = Color3.fromRGB(25, 120, 215)
        btn.Text = name
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.BorderSizePixel = 0
        btn.ZIndex = 101
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        
        btn.MouseButton1Click:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35, 135, 235)}):Play()
            task.wait(0.1)
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(25, 120, 215)}):Play()
            callback()
        end)
        
        return btn
    end
    
    local function NewSlider(parent, name, min, max, default, callback)
        local sliderFrame = Instance.new("Frame", parent)
        sliderFrame.Size = UDim2.new(1, 0, 0, 70)
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
        Label.TextSize = 13
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
    
    -- ============================================================
    -- CREATE TABS
    -- ============================================================
    
    -- COMBAT TAB
    local CombatTab = CreateTab("Combat", "⚔️")
    NewSection(CombatTab, "Attack")
    NewToggle(CombatTab, "Kill Aura", "KillAura", function(v) 
        Notify(v and "🔥 KILL AURA ATIVADA!" or "⛔ KILL AURA DESATIVADA", 3)
    end)
    NewSlider(CombatTab, "Aura Range", 10, 100, Settings.KillAuraRange, function(v)
        Settings.KillAuraRange = v
    end)
    NewToggle(CombatTab, "Fast Attack", "FastAttack", function(v) 
        Notify(v and "⚡ FAST ATTACK ON!" or "⚡ FAST ATTACK OFF!", 3)
    end)
    
    NewSection(CombatTab, "Skills")
    NewToggle(CombatTab, "Auto Skill", "AutoSkill", function(v) end)
    NewButton(CombatTab, "🛡️ Safe Mode", function()
        Notify("Safe Mode Ativado!", 3)
    end)
    
    -- FARM TAB
    local FarmTab = CreateTab("Farm", "🌾")
    NewSection(FarmTab, "Leveling")
    NewToggle(FarmTab, "Auto Farm", "AutoFarm", function(v)
        Notify(v and "🌾 FARM INICIADO!" or "🌾 FARM PARADO!", 3)
    end)
    NewToggle(FarmTab, "Auto Quest", "AutoQuest", function(v) end)
    NewSlider(FarmTab, "Distance", 5, 30, Settings.Distance, function(v)
        Settings.Distance = v
    end)
    
    NewSection(FarmTab, "Weapons")
    NewToggle(FarmTab, "Auto Weapon", "FastAttack", function(v) end)
    NewButton(FarmTab, "Equip Weapon", function()
        Notify("Arma equipada!", 2)
    end)
    
    -- VISUALS TAB
    local VisualsTab = CreateTab("Visuals", "👁️")
    NewSection(VisualsTab, "ESP")
    NewToggle(VisualsTab, "ESP Players", "EspPlayers", function(v) end)
    NewToggle(VisualsTab, "ESP Fruits", "EspFruits", function(v) end)
    NewToggle(VisualsTab, "ESP Chests", "EspChests", function(v) end)
    
    NewSection(VisualsTab, "Environment")
    NewToggle(VisualsTab, "Full Bright", "FullBright", function(v)
        if v then
            Lighting.Ambient = Color3.new(1,1,1)
            Lighting.Brightness = 2
        else
            Lighting.Ambient = Color3.new(0.5,0.5,0.5)
            Lighting.Brightness = 1
        end
    end)
    
    -- MISC TAB
    local MiscTab = CreateTab("Misc", "⚙️")
    NewSection(MiscTab, "Server")
    NewButton(MiscTab, "Server Hop", function()
        Notify("Procurando novo servidor...", 3)
    end)
    NewButton(MiscTab, "Auto Rejoin", function()
        Notify("Rejoin ativado!", 2)
    end)
    
    NewSection(MiscTab, "Theme")
    local ThemeFrame = Instance.new("Frame", MiscTab)
    ThemeFrame.Size = UDim2.new(1, 0, 0, 120)
    ThemeFrame.BackgroundTransparency = 1
    ThemeFrame.BorderSizePixel = 0
    
    local ThemeLayout = Instance.new("UIGridLayout", ThemeFrame)
    ThemeLayout.CellPadding = UDim2.new(0, 5, 0, 5)
    ThemeLayout.CellSize = UDim2.new(0.48, 0, 0, 50)
    ThemeLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
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
            Notify("Tema alterado para " .. name, 3)
        end)
    end
    
    NewSection(MiscTab, "Info")
    NewButton(MiscTab, "Stop Hub", function()
        _G.MakitoHubRunning = false
        MainGui:Destroy()
        Notify("MAKITO HUB ENCERRADO", 3)
    end)
    
    -- Show first tab
    Tabs["Combat"].Content.Visible = true
    Tabs["Combat"].Button.BackgroundColor3 = Settings.ThemeColor
    Tabs["Combat"].Button.TextColor3 = Color3.new(0, 0, 0)
    
    Notify("🎨 MAKITO HUB V6.3 INICIADO!", 5)
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
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Initialize
task.spawn(CreateProfessionalUI)
print("[MAKITO HUB V6.3] Professional UI Iniciada!")
