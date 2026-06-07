local UIModule = {}

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Tabs = {}
local CurrentTab = nil

-- UTILS PARA DESIGN
local function Ripple(obj)
    obj.ClipsDescendants = true
    obj.MouseButton1Click:Connect(function()
        local mouse = LocalPlayer:GetMouse()
        local ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.Parent = obj
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.6
        ripple.ZIndex = obj.ZIndex + 1
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0, mouse.X - obj.AbsolutePosition.X, 0, mouse.Y - obj.AbsolutePosition.Y)
        
        local corner = Instance.new("UICorner", ripple)
        corner.CornerRadius = UDim.new(1, 0)
        
        TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, obj.AbsoluteSize.X * 1.5, 0, obj.AbsoluteSize.X * 1.5),
            BackgroundTransparency = 1
        }):Play()
        
        task.wait(0.5)
        ripple:Destroy()
    end)
end

function UIModule.CreateHub()
    local MakitoGui = Instance.new("ScreenGui")
    MakitoGui.Name = "MakitoHub"
    pcall(function() MakitoGui.Parent = CoreGui end)
    if not MakitoGui.Parent then MakitoGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    MakitoGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = MakitoGui
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0, 550, 0, 350)
    MainFrame.ClipsDescendants = true

    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, 10)

    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Color = Color3.fromRGB(0, 255, 150)
    UIStroke.Thickness = 1.5

    -- SIDEBAR
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = MainFrame
    Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Sidebar.BorderSizePixel = 0
    Sidebar.Size = UDim2.new(0, 140, 1, 0)

    local SidebarCorner = Instance.new("UICorner", Sidebar)
    SidebarCorner.CornerRadius = UDim.new(0, 10)

    local SidebarTitle = Instance.new("TextLabel")
    SidebarTitle.Name = "Title"
    SidebarTitle.Parent = Sidebar
    SidebarTitle.Size = UDim2.new(1, 0, 0, 50)
    SidebarTitle.BackgroundTransparency = 1
    SidebarTitle.Font = Enum.Font.GothamBold
    SidebarTitle.Text = "MAKITO HUB"
    SidebarTitle.TextColor3 = Color3.fromRGB(0, 255, 150)
    SidebarTitle.TextSize = 18

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = Sidebar
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 5, 0, 60)
    TabContainer.Size = UDim2.new(1, -10, 1, -70)
    TabContainer.ScrollBarThickness = 0
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)

    local TabList = Instance.new("UIListLayout")
    TabList.Parent = TabContainer
    TabList.Padding = UDim.new(0, 5)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder

    -- CONTENT AREA
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Parent = MainFrame
    ContentArea.BackgroundTransparency = 1
    ContentArea.Position = UDim2.new(0, 150, 0, 10)
    ContentArea.Size = UDim2.new(1, -160, 1, -20)

    -- DRAG LOGIC
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- FLOATING ICON
    local FloatingBtn = Instance.new("ImageButton")
    FloatingBtn.Name = "MakitoFloatingBtn"
    FloatingBtn.Parent = MakitoGui
    FloatingBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
    FloatingBtn.Size = UDim2.new(0, 50, 0, 50)
    FloatingBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    FloatingBtn.Image = "rbxassetid://6031280224"
    FloatingBtn.Draggable = true

    local FloatingCorner = Instance.new("UICorner", FloatingBtn)
    FloatingCorner.CornerRadius = UDim.new(1, 0)

    local FloatingStroke = Instance.new("UIStroke", FloatingBtn)
    FloatingStroke.Color = Color3.fromRGB(0, 255, 150)
    FloatingStroke.Thickness = 1.5

    FloatingBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    -- ABAS DO HUB
    local MainTab = UIModule.NewTab("Main", TabContainer, ContentArea)
    UIModule.NewSection(MainTab, "Auto Farm Elite")
    UIModule.NewToggle(MainTab, "Supreme Auto Farm", "AutoFarm")
    UIModule.NewToggle(MainTab, "Auto Farm Nearest", "AutoFarmNearest")
    UIModule.NewToggle(MainTab, "Bring Mobs (Black Hole)", "BringMobs")
    UIModule.NewToggle(MainTab, "Auto Quest", "AutoQuest")
    UIModule.NewToggle(MainTab, "Auto Next Sea", "AutoNextSea")
    UIModule.NewDropdown(MainTab, "Select Weapon", {"Melee", "Sword", "Fruit"}, "Weapon")
    UIModule.NewSlider(MainTab, "Farm Distance", 0, 30, 10, "Distance")

    local CombatTab = UIModule.NewTab("Combat", TabContainer, ContentArea)
    UIModule.NewSection(CombatTab, "Attack Framework")
    UIModule.NewToggle(CombatTab, "Fast Attack (Ultra)", "FastAttack")
    UIModule.NewToggle(CombatTab, "Kill Aura (Safe)", "KillAura")
    UIModule.NewToggle(CombatTab, "Auto Skill", "AutoSkill")
    UIModule.NewSection(CombatTab, "PVP / Bounty")
    UIModule.NewToggle(CombatTab, "Auto Bounty (Hop)", "AutoBounty")
    UIModule.NewToggle(CombatTab, "Aimbot (Cam)", "Aimbot")
    UIModule.NewDropdown(CombatTab, "Skill Priority", {"Z", "X", "C", "V"}, "SkillPriority")

    local SeaTab = UIModule.NewTab("Sea Events", TabContainer, ContentArea)
    UIModule.NewSection(SeaTab, "World Events")
    UIModule.NewToggle(SeaTab, "Auto Sea Beast", "AutoSeaBeast")
    UIModule.NewToggle(SeaTab, "Auto Terror Shark", "AutoTerrorShark")
    UIModule.NewToggle(SeaTab, "Auto Leviathan", "AutoLeviathan")
    UIModule.NewToggle(SeaTab, "Auto Kitsune Island", "AutoKitsune")
    UIModule.NewToggle(SeaTab, "Auto Mirage Island", "AutoMirage")
    UIModule.NewSection(SeaTab, "Raid Bosses")
    UIModule.NewToggle(SeaTab, "Auto Factory", "AutoFactory")
    UIModule.NewToggle(SeaTab, "Auto Elite Hunter", "AutoEliteHunter")

    local FruitTab = UIModule.NewTab("Devil Fruit", TabContainer, ContentArea)
    UIModule.NewSection(FruitTab, "Automation")
    UIModule.NewToggle(FruitTab, "Auto Gacha (Fruit)", "AutoGacha")
    UIModule.NewToggle(FruitTab, "Auto Store Fruits", "AutoStoreFruit")
    UIModule.NewToggle(FruitTab, "Auto Collect Fruits", "AutoCollectFruit")
    UIModule.NewToggle(FruitTab, "Auto Bring Fruits", "AutoBringFruit")
    UIModule.NewSection(FruitTab, "Sniper")
    UIModule.NewTextBox(FruitTab, "Snipe List", "Ex: Dragon,Kitsune", "SnipeFruitsRaw")

    local VisualsTab = UIModule.NewTab("Visuals / ESP", TabContainer, ContentArea)
    UIModule.NewSection(VisualsTab, "ESP Master")
    UIModule.NewToggle(VisualsTab, "Player ESP", "EspPlayers")
    UIModule.NewToggle(VisualsTab, "NPC / Enemy ESP", "NpcESP")
    UIModule.NewToggle(VisualsTab, "Chest ESP", "EspChests")
    UIModule.NewToggle(VisualsTab, "Fruit ESP", "EspFruits")
    UIModule.NewSection(VisualsTab, "ESP Style")
    UIModule.NewToggle(VisualsTab, "Show Box", "BoxESP")
    UIModule.NewToggle(VisualsTab, "Show Tracers (Lines)", "LineESP")
    UIModule.NewSection(VisualsTab, "World")
    UIModule.NewToggle(VisualsTab, "Full Bright", "FullBright", function(v) _G.Utils.SetFullBright(v) end)
    UIModule.NewToggle(VisualsTab, "Remove Fog", "RemoveFog", function(v) _G.Utils.RemoveFog(v) end)

    local StatsTab = UIModule.NewTab("Stats", TabContainer, ContentArea)
    UIModule.NewSection(StatsTab, "Auto Stats")
    UIModule.NewToggle(StatsTab, "Enable Auto Stats", "AutoStats")
    UIModule.NewDropdown(StatsTab, "Select Stat", {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"}, "SelectedStat")
    UIModule.NewSection(StatsTab, "Mastery")
    UIModule.NewToggle(StatsTab, "Auto Mastery", "AutoMastery")
    UIModule.NewDropdown(StatsTab, "Mastery Weapon", {"Melee", "Sword", "Fruit"}, "MasteryWeapon")
    UIModule.NewSlider(StatsTab, "Health % to Switch", 0, 100, 20, "MasteryHealth")

    local TeleportTab = UIModule.NewTab("Teleport", TabContainer, ContentArea)
    UIModule.NewSection(TeleportTab, "Island Teleport (Tween)")
    
    local islandNames = {}
    local currentSeaIslands = _G.Data and _G.Data.GetIslands(_G.MakitoSea) or {}
    for _, island in ipairs(currentSeaIslands) do
        table.insert(islandNames, island.Name)
    end
    
    UIModule.NewDropdown(TeleportTab, "Select Island", islandNames, "SelectedIsland")
    UIModule.NewButton(TeleportTab, "Teleport to Selected Island", function()
        if _G.Settings and _G.Settings.SelectedIsland then
            local island = _G.Data.GetIslandByName(_G.Settings.SelectedIsland, _G.MakitoSea)
            if island then
                _G.Utils.TweenTo(island.Pos)
            end
        end
    end)

    UIModule.NewSection(TeleportTab, "World Teleport")
    UIModule.NewButton(TeleportTab, "Travel to Sea 2 (Lvl 700+)", function() 
        _G.Utils.TweenTo(CFrame.new(-10332, 730, 7866))
        _G.Utils.SafeRemote("TravelMain") 
    end)
    UIModule.NewButton(TeleportTab, "Travel to Sea 3 (Lvl 1500+)", function() 
        _G.Utils.TweenTo(CFrame.new(-541, 314, -2821))
        _G.Utils.SafeRemote("TravelZou") 
    end)

    local ShopTab = UIModule.NewTab("Shop & Items", TabContainer, ContentArea)
    UIModule.NewSection(ShopTab, "Fighting Styles")
    UIModule.NewToggle(ShopTab, "Auto Buy All Styles", "AutoBuyFightingStyle")
    UIModule.NewButton(ShopTab, "Buy Godhuman", function() _G.Farming.BuyItem("FightingStyle", "Godhuman") end)
    UIModule.NewSection(ShopTab, "Legendary Swords")
    UIModule.NewToggle(ShopTab, "Auto Buy Swords", "AutoBuyLegendarySword")
    UIModule.NewButton(ShopTab, "Buy CDK", function() _G.Farming.BuyItem("Weapon", "Cursed Dual Katana") end)

    local MiscTab = UIModule.NewTab("Misc / Config", TabContainer, ContentArea)
    UIModule.NewSection(MiscTab, "Protections")
    UIModule.NewToggle(MiscTab, "Auto Kick Moderator", "AutoKickMod")
    UIModule.NewToggle(MiscTab, "Streamer Mode", "StreamerMode", function(v) _G.Utils.SetStreamerMode(v) end)
    UIModule.NewSection(MiscTab, "Performance")
    UIModule.NewButton(MiscTab, "Optimize FPS (Potato PC)", function() 
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic
            elseif v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
        end
    end)
    UIModule.NewSection(MiscTab, "Server")
    UIModule.NewButton(MiscTab, "Server Hop", function() _G.Utils.ServerHop() end)
    UIModule.NewButton(MiscTab, "Rejoin Server", function() _G.Utils.Rejoin() end)

    return MakitoGui, MainFrame
end

function UIModule.NewTab(name, container, contentArea)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = name .. "Tab"
    TabBtn.Parent = container
    TabBtn.Size = UDim2.new(1, 0, 0, 30)
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabBtn.BorderSizePixel = 0
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.TextSize = 13

    local TabCorner = Instance.new("UICorner", TabBtn)
    TabCorner.CornerRadius = UDim.new(0, 6)
    
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Parent = contentArea
    Page.BackgroundTransparency = 1
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)

    local PageList = Instance.new("UIListLayout")
    PageList.Parent = Page
    PageList.Padding = UDim.new(0, 8)
    PageList.SortOrder = Enum.SortOrder.LayoutOrder
    
    PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 20)
    end)

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Page.Visible = false
            t.Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            t.Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end
        Page.Visible = true
        TabBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
        TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        CurrentTab = name
    end)

    Tabs[name] = {Btn = TabBtn, Page = Page}
    
    if not CurrentTab then
        Page.Visible = true
        TabBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
        TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        CurrentTab = name
    end

    return Page
end

function UIModule.NewSection(parent, name)
    local Label = Instance.new("TextLabel")
    Label.Parent = parent
    Label.Size = UDim2.new(1, 0, 0, 25)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.Text = "--- " .. name:upper() .. " ---"
    Label.TextColor3 = Color3.fromRGB(0, 255, 150)
    Label.TextSize = 12
end

function UIModule.NewToggle(parent, name, setting, callback)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = parent
    ToggleBtn.Size = UDim2.new(1, -10, 0, 35)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Font = Enum.Font.GothamSemibold
    ToggleBtn.Text = "  " .. name
    ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    ToggleBtn.TextSize = 13
    ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left

    local Corner = Instance.new("UICorner", ToggleBtn)
    Corner.CornerRadius = UDim.new(0, 6)

    local Status = Instance.new("Frame")
    Status.Parent = ToggleBtn
    Status.AnchorPoint = Vector2.new(1, 0.5)
    Status.Position = UDim2.new(1, -10, 0.5, 0)
    Status.Size = UDim2.new(0, 40, 0, 20)
    Status.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

    local StatusCorner = Instance.new("UICorner", Status)
    StatusCorner.CornerRadius = UDim.new(1, 0)

    local Circle = Instance.new("Frame")
    Circle.Parent = Status
    Circle.Position = UDim2.new(0, 2, 0.5, 0)
    Circle.AnchorPoint = Vector2.new(0, 0.5)
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    
    local CircleCorner = Instance.new("UICorner", Circle)
    CircleCorner.CornerRadius = UDim.new(1, 0)

    local function SetState(val)
        if _G.Settings then _G.Settings[setting] = val end
        if val then
            TweenService:Create(Status, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0, 255, 150)}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.3), {Position = UDim2.new(1, -18, 0.5, 0)}):Play()
        else
            TweenService:Create(Status, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.3), {Position = UDim2.new(0, 2, 0.5, 0)}):Play()
        end
        if callback then callback(val) end
    end

    ToggleBtn.MouseButton1Click:Connect(function()
        local nextVal = not (_G.Settings and _G.Settings[setting])
        SetState(nextVal)
    end)

    if _G.Settings and _G.Settings[setting] then
        SetState(true)
    end
end

function UIModule.NewButton(parent, name, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = parent
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Btn.BorderSizePixel = 0
    Btn.Font = Enum.Font.GothamSemibold
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.TextSize = 13
    
    local Corner = Instance.new("UICorner", Btn)
    Corner.CornerRadius = UDim.new(0, 6)
    
    Ripple(Btn)
    Btn.MouseButton1Click:Connect(callback)
end

function UIModule.NewDropdown(parent, name, options, setting, callback)
    local Dropdown = Instance.new("Frame")
    Dropdown.Parent = parent
    Dropdown.Size = UDim2.new(1, -10, 0, 35)
    Dropdown.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Dropdown.BorderSizePixel = 0
    
    local Corner = Instance.new("UICorner", Dropdown)
    Corner.CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Parent = Dropdown
    Label.Size = UDim2.new(1, -30, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamSemibold
    Label.Text = name .. ": " .. ((_G.Settings and _G.Settings[setting]) or "Nenhum")
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Btn = Instance.new("TextButton")
    Btn.Parent = Dropdown
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""

    local ListFrame = Instance.new("Frame")
    ListFrame.Parent = parent
    ListFrame.Size = UDim2.new(1, -10, 0, 0)
    ListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    ListFrame.BorderSizePixel = 0
    ListFrame.Visible = false
    ListFrame.ClipsDescendants = true
    
    local ListCorner = Instance.new("UICorner", ListFrame)
    ListCorner.CornerRadius = UDim.new(0, 6)
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Parent = ListFrame
    ListLayout.Padding = UDim.new(0, 2)

    local function Toggle()
        ListFrame.Visible = not ListFrame.Visible
        local targetSize = ListFrame.Visible and (#options * 32 + 5) or 0
        TweenService:Create(ListFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, -10, 0, targetSize)}):Play()
    end

    Btn.MouseButton1Click:Connect(Toggle)

    for _, opt in ipairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Parent = ListFrame
        OptBtn.Size = UDim2.new(1, 0, 0, 30)
        OptBtn.BackgroundTransparency = 1
        OptBtn.Font = Enum.Font.Gotham
        OptBtn.Text = opt
        OptBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        OptBtn.TextSize = 12
        
        OptBtn.MouseButton1Click:Connect(function()
            if _G.Settings then _G.Settings[setting] = opt end
            Label.Text = name .. ": " .. opt
            if callback then callback(opt) end
            Toggle()
        end)
    end
end

function UIModule.NewSlider(parent, name, min, max, default, setting, callback)
    local Slider = Instance.new("Frame")
    Slider.Parent = parent
    Slider.Size = UDim2.new(1, -10, 0, 50)
    Slider.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    
    local Corner = Instance.new("UICorner", Slider)
    Corner.CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Parent = Slider
    Label.Size = UDim2.new(1, -20, 0, 25)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamSemibold
    Label.Text = name .. ": " .. ((_G.Settings and _G.Settings[setting]) or default)
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Bar = Instance.new("Frame")
    Bar.Parent = Slider
    Bar.Size = UDim2.new(1, -20, 0, 6)
    Bar.Position = UDim2.new(0, 10, 0, 32)
    Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    
    local Fill = Instance.new("Frame")
    Fill.Parent = Bar
    Fill.Size = UDim2.new((((_G.Settings and _G.Settings[setting]) or default) - min)/(max-min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)

    local function Update(input)
        local percent = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * percent)
        Fill.Size = UDim2.new(percent, 0, 1, 0)
        Label.Text = name .. ": " .. val
        if _G.Settings then _G.Settings[setting] = val end
        if callback then callback(val) end
    end

    local dragging = false
    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            Update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end
    end)
end

function UIModule.NewTextBox(parent, name, placeholder, setting, callback)
    local Box = Instance.new("TextBox")
    Box.Parent = parent
    Box.Size = UDim2.new(1, -10, 0, 35)
    Box.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Box.BorderSizePixel = 0
    Box.Font = Enum.Font.GothamSemibold
    Box.PlaceholderText = placeholder
    Box.Text = (_G.Settings and _G.Settings[setting]) or ""
    Box.TextColor3 = Color3.fromRGB(200, 200, 200)
    Box.TextSize = 12
    
    local Corner = Instance.new("UICorner", Box)
    Corner.CornerRadius = UDim.new(0, 6)
    
    Box.FocusLost:Connect(function()
        if _G.Settings then _G.Settings[setting] = Box.Text end
        if callback then callback(Box.Text) end
    end)
end

function UIModule.CreateWatermark()
    local watermark = Instance.new("ScreenGui")
    watermark.Name = "MakitoWatermark"
    pcall(function() watermark.Parent = CoreGui end)
    if not watermark.Parent then watermark.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    watermark.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    watermark.ResetOnSpawn = false

    local Frame = Instance.new("Frame")
    Frame.Parent = watermark
    Frame.AnchorPoint = Vector2.new(0.5, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderSizePixel = 0
    Frame.Position = UDim2.new(0.5, 0, 0, 10)
    Frame.Size = UDim2.new(0, 300, 0, 25)

    local UICorner = Instance.new("UICorner", Frame)
    UICorner.CornerRadius = UDim.new(0, 8)
    
    local UIStroke = Instance.new("UIStroke", Frame)
    UIStroke.Color = Color3.fromRGB(0, 255, 150)
    UIStroke.Thickness = 1.5

    local TextLabel = Instance.new("TextLabel", Frame)
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextSize = 13
    TextLabel.RichText = true

    task.spawn(function()
        while task.wait(1) do
            local fps = math.floor(1 / task.wait())
            local ping = "N/A"
            pcall(function()
                ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString():split(" ")[1]
            end)
            local time = os.date("%X")
            TextLabel.Text = string.format("MAKITO <font color='#00FF96'>HUB</font> | FPS: %d | PING: %s | %s", fps, ping, time)
        end
    end)
    
    return watermark
end

return UIModule
