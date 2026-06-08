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
    MainFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0, 650, 0, 450)
    MainFrame.ClipsDescendants = false -- Para permitir o brilho externo (Glow)

    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 10)

    -- EFEITO DE BRILHO EXTERNO (NEON GLOW)
    local Glow = Instance.new("ImageLabel")
    Glow.Name = "Glow"
    Glow.Parent = MainFrame
    Glow.AnchorPoint = Vector2.new(0.5, 0.5)
    Glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Glow.Size = UDim2.new(1, 100, 1, 100)
    Glow.BackgroundTransparency = 1
    Glow.Image = "rbxassetid://6014264795"
    Glow.ImageColor3 = _G.Settings.ThemeColor or Color3.fromRGB(0, 255, 150)
    Glow.ImageTransparency = 0.6
    Glow.ZIndex = -2

    -- BORDA NEON AGRESSIVA
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = _G.Settings.ThemeColor or Color3.fromRGB(0, 255, 150)
    MainStroke.Thickness = 2.5
    MainStroke.Transparency = 0.2
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- GRADIENTE DE FUNDO "GAMER"
    local MainGradient = Instance.new("UIGradient", MainFrame)
    MainGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 25)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(5, 5, 10)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
    })
    MainGradient.Rotation = 45

    -- SIDEBAR COM DESIGN IMPACTANTE
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = MainFrame
    Sidebar.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
    Sidebar.BorderSizePixel = 0
    Sidebar.Size = UDim2.new(0, 200, 1, 0)
    Sidebar.ZIndex = 2

    local SidebarCorner = Instance.new("UICorner", Sidebar)
    SidebarCorner.CornerRadius = UDim.new(0, 10)
    
    local SidebarStroke = Instance.new("UIStroke", Sidebar)
    SidebarStroke.Color = _G.Settings.ThemeColor or Color3.fromRGB(0, 255, 150)
    SidebarStroke.Thickness = 1.5
    SidebarStroke.Transparency = 0.8

    local SidebarTitle = Instance.new("TextLabel")
    SidebarTitle.Name = "Title"
    SidebarTitle.Parent = Sidebar
    SidebarTitle.Size = UDim2.new(1, 0, 0, 80)
    SidebarTitle.BackgroundTransparency = 1
    SidebarTitle.Font = Enum.Font.GothamBold
    SidebarTitle.Text = "MAKITO <font color='#00FF96'>AI</font>"
    SidebarTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    SidebarTitle.TextSize = 28
    SidebarTitle.RichText = true
    
    -- Efeito de Sombra no Título
    local TitleShadow = SidebarTitle:Clone()
    TitleShadow.Name = "Shadow"
    TitleShadow.Parent = SidebarTitle
    TitleShadow.Position = UDim2.new(0, 2, 0, 2)
    TitleShadow.TextColor3 = Color3.fromRGB(0, 0, 0)
    TitleShadow.ZIndex = -1

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = Sidebar
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 15, 0, 90)
    TabContainer.Size = UDim2.new(1, -30, 1, -110)
    TabContainer.ScrollBarThickness = 0
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)

    local TabList = Instance.new("UIListLayout")
    TabList.Parent = TabContainer
    TabList.Padding = UDim.new(0, 10)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder

    -- CONTENT AREA COM DESIGN PREMIUM
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Parent = MainFrame
    ContentArea.BackgroundTransparency = 1
    ContentArea.Position = UDim2.new(0, 215, 0, 20)
    ContentArea.Size = UDim2.new(1, -235, 1, -40)
    ContentArea.ZIndex = 2

    -- SISTEMA RGB (OPCIONAL)
    if _G.Settings.RainbowUI then
        task.spawn(function()
            while _G.MakitoHubRunning do
                local hue = tick() % 5 / 5
                local color = Color3.fromHSV(hue, 0.8, 1)
                MainStroke.Color = color
                Glow.ImageColor3 = color
                SidebarStroke.Color = color
                task.wait()
            end
        end)
    end

    -- DRAG LOGIC (COM FEEDBACK VISUAL)
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            TweenService:Create(MainStroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            dragging = false 
            TweenService:Create(MainStroke, TweenInfo.new(0.3), {Transparency = 0.2}):Play()
        end
    end)

    -- FLOATING ICON AGRESSIVO
    local FloatingBtn = Instance.new("ImageButton")
    FloatingBtn.Name = "MakitoFloatingBtn"
    FloatingBtn.Parent = MakitoGui
    FloatingBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
    FloatingBtn.Size = UDim2.new(0, 65, 0, 65)
    FloatingBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    FloatingBtn.Image = "rbxassetid://10747383861"
    FloatingBtn.ImageColor3 = _G.Settings.ThemeColor or Color3.fromRGB(0, 255, 150)
    FloatingBtn.Draggable = true

    local FloatingCorner = Instance.new("UICorner", FloatingBtn)
    FloatingCorner.CornerRadius = UDim.new(1, 0)

    local FloatingStroke = Instance.new("UIStroke", FloatingBtn)
    FloatingStroke.Color = _G.Settings.ThemeColor or Color3.fromRGB(0, 255, 150)
    FloatingStroke.Thickness = 2.5
    
    local FloatingGlow = Instance.new("ImageLabel", FloatingBtn)
    FloatingGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    FloatingGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    FloatingGlow.Size = UDim2.new(1, 40, 1, 40)
    FloatingGlow.BackgroundTransparency = 1
    FloatingGlow.Image = "rbxassetid://6014264795"
    FloatingGlow.ImageColor3 = _G.Settings.ThemeColor or Color3.fromRGB(0, 255, 150)
    FloatingGlow.ZIndex = -1

    FloatingBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
        if MainFrame.Visible then
            MainFrame:TweenSize(UDim2.new(0, 650, 0, 450), "Out", "Back", 0.5, true)
        end
    end)

    -- ABAS DO HUB (LAYOUT IMPACTANTE)
    local HomeTab = UIModule.NewTab("HOME", "rbxassetid://10747373176", TabContainer, ContentArea)
    UIModule.NewSection(HomeTab, "DASHBOARD")
    
    local Dash = Instance.new("Frame", HomeTab)
    Dash.Size = UDim2.new(1, -10, 0, 150)
    Dash.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    local DashCorner = Instance.new("UICorner", Dash)
    DashCorner.CornerRadius = UDim.new(0, 12)
    local DashStroke = Instance.new("UIStroke", Dash)
    DashStroke.Color = _G.Settings.ThemeColor or Color3.fromRGB(0, 255, 150)
    DashStroke.Thickness = 1
    DashStroke.Transparency = 0.8
    
    local StatLabel = Instance.new("TextLabel", Dash)
    StatLabel.Size = UDim2.new(1, -40, 1, -40)
    StatLabel.Position = UDim2.new(0, 20, 0, 20)
    StatLabel.BackgroundTransparency = 1
    StatLabel.Font = Enum.Font.GothamBold
    StatLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatLabel.TextSize = 16
    StatLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatLabel.RichText = true
    
    task.spawn(function()
        while task.wait(0.5) do
            local level = LocalPlayer.Data.Level.Value
            local beli = LocalPlayer.Data.Beli.Value
            local fragments = LocalPlayer.Data.Fragments.Value
            local bounty = LocalPlayer.leaderstats["Bounty/Honor"].Value
            StatLabel.Text = string.format(
                "� <font color='#00FF96'>PLAYER:</font> %s\n� <font color='#00FF96'>LEVEL:</font> %d\n💰 <font color='#00FF96'>BELI:</font> %d\n✨ <font color='#00FF96'>FRAGS:</font> %d\n⚔️ <font color='#00FF96'>BOUNTY:</font> %d",
                LocalPlayer.Name, level, beli, fragments, bounty
            )
        end
    end)

    local MainTab = UIModule.NewTab("FARMING", "rbxassetid://10747373111", TabContainer, ContentArea)
    UIModule.NewSection(MainTab, "Supreme Farming")
    UIModule.NewToggle(MainTab, "Auto Farm Level", "AutoFarmLevel")
    UIModule.NewToggle(MainTab, "Kill Aura Elite", "KillAura")
    UIModule.NewToggle(MainTab, "Fast Attack Pro", "FastAttack")
    UIModule.NewToggle(MainTab, "Bring Mobs (Black Hole)", "BringMobs")
    UIModule.NewToggle(MainTab, "Auto Next Sea", "AutoNextSea")
    UIModule.NewDropdown(MainTab, "Select Weapon", {"Melee", "Sword", "Fruit"}, "MainWeapon")
    
    if _G.MakitoSea == 3 then
        UIModule.NewSection(MainTab, "Sea 3 - Automation")
        UIModule.NewToggle(MainTab, "Auto Elite Hunter", "AutoEliteHunter")
        UIModule.NewToggle(MainTab, "Auto Dough King", "AutoDoughKing")
    end

    local CombatTab = UIModule.NewTab("Combat", "rbxassetid://10747383424", TabContainer, ContentArea)
    UIModule.NewSection(CombatTab, "PVP Utilities")
    UIModule.NewToggle(CombatTab, "Aimbot Skill", "Aimbot")
    UIModule.NewToggle(CombatTab, "Auto Bounty (Hop)", "AutoBounty")
    UIModule.NewSlider(CombatTab, "Kill Aura Range", 50, 300, 150, "KillAuraDistance")

    local VisualsTab = UIModule.NewTab("Visuals", "rbxassetid://10747372992", TabContainer, ContentArea)
    UIModule.NewSection(VisualsTab, "ESP System")
    UIModule.NewToggle(VisualsTab, "Player ESP", "EspPlayers")
    UIModule.NewToggle(VisualsTab, "NPC ESP", "NpcESP")
    UIModule.NewToggle(VisualsTab, "Chest ESP", "EspChests")
    UIModule.NewToggle(VisualsTab, "Fruit ESP", "EspFruits")
    UIModule.NewSection(VisualsTab, "Customization")
    UIModule.NewToggle(VisualsTab, "Show Boxes", "BoxESP")
    UIModule.NewToggle(VisualsTab, "Full Bright", "FullBright")

    local MiscTab = UIModule.NewTab("SETTINGS", "rbxassetid://10747373176", TabContainer, ContentArea)
    UIModule.NewSection(MiscTab, "APPEARANCE")
    UIModule.NewToggle(MiscTab, "RAINBOW UI (RGB)", "RainbowUI")
    UIModule.NewDropdown(MiscTab, "SELECT THEME", {"Default", "Neon Red", "Deep Blue", "Golden", "Purple Night"}, "CurrentTheme", function(v)
        if _G.MakitoThemes[v] then
            _G.Settings.ThemeColor = _G.MakitoThemes[v]
            -- Força atualização visual imediata (opcional, o script já lê _G.Settings)
        end
    end)
    
    UIModule.NewSection(MiscTab, "OPTIMIZATION")
    UIModule.NewButton(MiscTab, "BOOST FPS (POTATO MODE)", function() 
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic
            elseif v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
        end
    end)
    UIModule.NewSection(MiscTab, "SERVER")
    UIModule.NewButton(MiscTab, "SERVER HOP", function() _G.Utils.ServerHop() end)
    UIModule.NewButton(MiscTab, "REJOIN", function() _G.Utils.Rejoin() end)
    
    UIModule.NewSection(MiscTab, "WEBHOOKS")
    UIModule.NewTextBox(MiscTab, "MAIN WEBHOOK URL", "Insira a URL do Discord aqui...", "MainWebhookURL")
    UIModule.NewTextBox(MiscTab, "ERROR WEBHOOK URL", "URL para logs de erro...", "ErrorWebhookURL")
    UIModule.NewButton(MiscTab, "TEST WEBHOOK", function()
        _G.Utils.Notify("Enviando teste de webhook...", 5)
        _G.MakitoDebug("TEST", "Teste manual de webhook realizado com sucesso!")
    end)

    UIModule.NewSection(MiscTab, "HUB CONFIG")
    UIModule.NewButton(MiscTab, "SAVE CONFIG", function() _G.MakitoSaveSettings() end)

    return MakitoGui, MainFrame
end

function UIModule.NewTab(name, iconId, container, contentArea)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = name .. "Tab"
    TabBtn.Parent = container
    TabBtn.Size = UDim2.new(1, 0, 0, 42)
    TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    TabBtn.BackgroundTransparency = 1
    TabBtn.BorderSizePixel = 0
    TabBtn.Text = ""

    local TabCorner = Instance.new("UICorner", TabBtn)
    TabCorner.CornerRadius = UDim.new(0, 4) -- Bordas mais afiadas para estilo Gamer
    
    local Indicator = Instance.new("Frame")
    Indicator.Name = "Indicator"
    Indicator.Parent = TabBtn
    Indicator.BackgroundColor3 = _G.Settings.ThemeColor or Color3.fromRGB(0, 255, 150)
    Indicator.BorderSizePixel = 0
    Indicator.Position = UDim2.new(0, 0, 0, 5)
    Indicator.Size = UDim2.new(0, 3, 1, -10)
    Indicator.BackgroundTransparency = 1

    local Icon = Instance.new("ImageLabel")
    Icon.Name = "Icon"
    Icon.Parent = TabBtn
    Icon.AnchorPoint = Vector2.new(0, 0.5)
    Icon.Position = UDim2.new(0, 15, 0.5, 0)
    Icon.Size = UDim2.new(0, 22, 0, 22)
    Icon.BackgroundTransparency = 1
    Icon.Image = iconId or "rbxassetid://10747373176"
    Icon.ImageColor3 = Color3.fromRGB(150, 150, 150)

    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Parent = TabBtn
    Label.AnchorPoint = Vector2.new(0, 0.5)
    Label.Position = UDim2.new(0, 48, 0.5, 0)
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.Text = name:upper()
    Label.TextColor3 = Color3.fromRGB(150, 150, 150)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Parent = contentArea
    Page.BackgroundTransparency = 1
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.Visible = false
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = _G.Settings.ThemeColor or Color3.fromRGB(0, 255, 150)
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)

    local PageList = Instance.new("UIListLayout")
    PageList.Parent = Page
    PageList.Padding = UDim.new(0, 15)
    PageList.SortOrder = Enum.SortOrder.LayoutOrder
    
    PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 20)
    end)

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Page.Visible = false
            TweenService:Create(t.Btn.Icon, TweenInfo.new(0.3), {ImageColor3 = Color3.fromRGB(150, 150, 150), ImageTransparency = 0.5}):Play()
            TweenService:Create(t.Btn.Label, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
            TweenService:Create(t.Btn.Indicator, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            TweenService:Create(t.Btn, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        end
        Page.Visible = true
        local themeColor = _G.Settings.ThemeColor or Color3.fromRGB(0, 255, 150)
        TweenService:Create(Icon, TweenInfo.new(0.3), {ImageColor3 = themeColor, ImageTransparency = 0}):Play()
        TweenService:Create(Label, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TweenService:Create(Indicator, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
        TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.8, BackgroundColor3 = themeColor}):Play()
        CurrentTab = name
    end)

    Tabs[name] = {Btn = TabBtn, Page = Page}
    
    if not CurrentTab then
        Page.Visible = true
        local themeColor = _G.Settings.ThemeColor or Color3.fromRGB(0, 255, 150)
        Icon.ImageColor3 = themeColor
        Icon.ImageTransparency = 0
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Indicator.BackgroundTransparency = 0
        TabBtn.BackgroundTransparency = 0.8
        TabBtn.BackgroundColor3 = themeColor
        CurrentTab = name
    end

    return Page
end

function UIModule.NewSection(parent, name)
    local Container = Instance.new("Frame")
    Container.Parent = parent
    Container.Size = UDim2.new(1, -10, 0, 30)
    Container.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel")
    Label.Parent = Container
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.Text = name:upper()
    Label.TextColor3 = _G.Settings.ThemeColor or Color3.fromRGB(0, 255, 150)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Line = Instance.new("Frame")
    Line.Parent = Container
    Line.Size = UDim2.new(1, 0, 0, 1)
    Line.Position = UDim2.new(0, 0, 1, 0)
    Line.BackgroundColor3 = _G.Settings.ThemeColor or Color3.fromRGB(0, 255, 150)
    Line.BorderSizePixel = 0
    
    local Gradient = Instance.new("UIGradient", Line)
    Gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.5, 0.5),
        NumberSequenceKeypoint.new(1, 1)
    })
end

function UIModule.NewToggle(parent, name, setting, callback)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = parent
    ToggleBtn.Size = UDim2.new(1, -10, 0, 48)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Text = "      " .. name:upper()
    ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    ToggleBtn.TextSize = 12
    ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left

    local Corner = Instance.new("UICorner", ToggleBtn)
    Corner.CornerRadius = UDim.new(0, 6)
    
    local Stroke = Instance.new("UIStroke", ToggleBtn)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Thickness = 1.5
    Stroke.Transparency = 0.95

    local Status = Instance.new("Frame")
    Status.Parent = ToggleBtn
    Status.AnchorPoint = Vector2.new(1, 0.5)
    Status.Position = UDim2.new(1, -15, 0.5, 0)
    Status.Size = UDim2.new(0, 48, 0, 24)
    Status.BackgroundColor3 = Color3.fromRGB(20, 20, 25)

    local StatusCorner = Instance.new("UICorner", Status)
    StatusCorner.CornerRadius = UDim.new(0, 4)

    local StatusStroke = Instance.new("UIStroke", Status)
    StatusStroke.Color = Color3.fromRGB(255, 255, 255)
    StatusStroke.Thickness = 1
    StatusStroke.Transparency = 0.9

    local Circle = Instance.new("Frame")
    Circle.Parent = Status
    Circle.Position = UDim2.new(0, 4, 0.5, 0)
    Circle.AnchorPoint = Vector2.new(0, 0.5)
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    
    local CircleCorner = Instance.new("UICorner", Circle)
    CircleCorner.CornerRadius = UDim.new(0, 2)

    local function SetState(val)
        if _G.Settings then _G.Settings[setting] = val end
        local themeColor = _G.Settings.ThemeColor or Color3.fromRGB(0, 255, 150)
        if val then
            TweenService:Create(Status, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundColor3 = themeColor, BackgroundTransparency = 0.8}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = UDim2.new(1, -20, 0.5, 0), BackgroundColor3 = themeColor}):Play()
            TweenService:Create(Stroke, TweenInfo.new(0.3), {Transparency = 0.6, Color = themeColor}):Play()
            TweenService:Create(StatusStroke, TweenInfo.new(0.3), {Color = themeColor, Transparency = 0.5}):Play()
        else
            TweenService:Create(Status, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundColor3 = Color3.fromRGB(20, 20, 25), BackgroundTransparency = 0}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = UDim2.new(0, 4, 0.5, 0), BackgroundColor3 = Color3.fromRGB(150, 150, 150)}):Play()
            TweenService:Create(Stroke, TweenInfo.new(0.3), {Transparency = 0.95, Color = Color3.fromRGB(255, 255, 255)}):Play()
            TweenService:Create(StatusStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(255, 255, 255), Transparency = 0.9}):Play()
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
    Btn.Size = UDim2.new(1, -10, 0, 42)
    Btn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    Btn.BorderSizePixel = 0
    Btn.Font = Enum.Font.GothamSemibold
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    Btn.TextSize = 13
    
    local Corner = Instance.new("UICorner", Btn)
    Corner.CornerRadius = UDim.new(0, 10)
    
    local Stroke = Instance.new("UIStroke", Btn)
    Stroke.Color = _G.Settings.ThemeColor or Color3.fromRGB(0, 255, 150)
    Stroke.Thickness = 1.2
    Stroke.Transparency = 0.92

    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(28, 28, 35)}):Play()
        TweenService:Create(Stroke, TweenInfo.new(0.3), {Transparency = 0.4}):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(22, 22, 28)}):Play()
        TweenService:Create(Stroke, TweenInfo.new(0.3), {Transparency = 0.92}):Play()
    end)
    
    Ripple(Btn)
    Btn.MouseButton1Click:Connect(callback)
end

function UIModule.NewDropdown(parent, name, options, setting, callback)
    local Dropdown = Instance.new("Frame")
    Dropdown.Parent = parent
    Dropdown.Size = UDim2.new(1, -10, 0, 40)
    Dropdown.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    Dropdown.BorderSizePixel = 0
    
    local Corner = Instance.new("UICorner", Dropdown)
    Corner.CornerRadius = UDim.new(0, 10)

    local Stroke = Instance.new("UIStroke", Dropdown)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.96

    local Label = Instance.new("TextLabel")
    Label.Parent = Dropdown
    Label.Size = UDim2.new(1, -40, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamSemibold
    Label.Text = name .. ": <font color='#00FF96'>" .. ((_G.Settings and _G.Settings[setting]) or "None") .. "</font>"
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.RichText = true

    local Arrow = Instance.new("ImageLabel", Dropdown)
    Arrow.AnchorPoint = Vector2.new(1, 0.5)
    Arrow.Position = UDim2.new(1, -10, 0.5, 0)
    Arrow.Size = UDim2.new(0, 16, 0, 16)
    Arrow.BackgroundTransparency = 1
    Arrow.Image = "rbxassetid://10747373176" -- Placeholder arrow
    Arrow.ImageColor3 = Color3.fromRGB(150, 150, 150)

    local Btn = Instance.new("TextButton")
    Btn.Parent = Dropdown
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""

    local ListFrame = Instance.new("Frame")
    ListFrame.Parent = parent
    ListFrame.Size = UDim2.new(1, -10, 0, 0)
    ListFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    ListFrame.BorderSizePixel = 0
    ListFrame.Visible = false
    ListFrame.ClipsDescendants = true
    
    local ListCorner = Instance.new("UICorner", ListFrame)
    ListCorner.CornerRadius = UDim.new(0, 10)
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Parent = ListFrame
    ListLayout.Padding = UDim.new(0, 4)
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local function Toggle()
        ListFrame.Visible = not ListFrame.Visible
        local targetSize = ListFrame.Visible and (#options * 34 + 10) or 0
        TweenService:Create(ListFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(1, -10, 0, targetSize)}):Play()
        TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = ListFrame.Visible and 180 or 0}):Play()
    end

    Btn.MouseButton1Click:Connect(Toggle)

    for _, opt in ipairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Parent = ListFrame
        OptBtn.Size = UDim2.new(0.95, 0, 0, 30)
        OptBtn.BackgroundTransparency = 0.95
        OptBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        OptBtn.Font = Enum.Font.Gotham
        OptBtn.Text = opt
        OptBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
        OptBtn.TextSize = 12
        
        local OptCorner = Instance.new("UICorner", OptBtn)
        OptCorner.CornerRadius = UDim.new(0, 6)

        OptBtn.MouseButton1Click:Connect(function()
            if _G.Settings then _G.Settings[setting] = opt end
            Label.Text = name .. ": <font color='#00FF96'>" .. opt .. "</font>"
            if callback then callback(opt) end
            Toggle()
        end)
    end
end

function UIModule.NewSlider(parent, name, min, max, default, setting, callback)
    local Slider = Instance.new("Frame")
    Slider.Parent = parent
    Slider.Size = UDim2.new(1, -10, 0, 65)
    Slider.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    
    local Corner = Instance.new("UICorner", Slider)
    Corner.CornerRadius = UDim.new(0, 12)

    local Stroke = Instance.new("UIStroke", Slider)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.96

    local Label = Instance.new("TextLabel")
    Label.Parent = Slider
    Label.Size = UDim2.new(1, -30, 0, 30)
    Label.Position = UDim2.new(0, 15, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamSemibold
    local curVal = (_G.Settings and _G.Settings[setting]) or default
    Label.Text = name .. ": <font color='#00FF96'>" .. curVal .. "</font>"
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.RichText = true

    local Bar = Instance.new("Frame")
    Bar.Parent = Slider
    Bar.Size = UDim2.new(1, -30, 0, 6)
    Bar.Position = UDim2.new(0, 15, 0, 45)
    Bar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    
    local BarCorner = Instance.new("UICorner", Bar)
    BarCorner.CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame")
    Fill.Parent = Bar
    Fill.Size = UDim2.new((curVal - min)/(max-min), 0, 1, 0)
    Fill.BackgroundColor3 = _G.Settings.ThemeColor or Color3.fromRGB(0, 255, 150)
    
    local FillCorner = Instance.new("UICorner", Fill)
    FillCorner.CornerRadius = UDim.new(1, 0)

    local function Update(input)
        local percent = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * percent)
        TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
        Label.Text = name .. ": <font color='#00FF96'>" .. val .. "</font>"
        if _G.Settings then _G.Settings[setting] = val end
        if callback then callback(val) end
    end

    local dragging = false
    Slider.InputBegan:Connect(function(input)
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
    local Container = Instance.new("Frame")
    Container.Parent = parent
    Container.Size = UDim2.new(1, -10, 0, 45)
    Container.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    
    local Corner = Instance.new("UICorner", Container)
    Corner.CornerRadius = UDim.new(0, 10)

    local Stroke = Instance.new("UIStroke", Container)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.96

    local Box = Instance.new("TextBox")
    Box.Parent = Container
    Box.Size = UDim2.new(1, -20, 1, 0)
    Box.Position = UDim2.new(0, 10, 0, 0)
    Box.BackgroundTransparency = 1
    Box.Font = Enum.Font.GothamSemibold
    Box.PlaceholderText = placeholder
    Box.Text = (_G.Settings and _G.Settings[setting]) or ""
    Box.TextColor3 = Color3.fromRGB(200, 200, 200)
    Box.TextSize = 13
    
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
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    Frame.BorderSizePixel = 0
    Frame.Position = UDim2.new(0.5, 0, 0, 15)
    Frame.Size = UDim2.new(0, 320, 0, 30)

    local UICorner = Instance.new("UICorner", Frame)
    UICorner.CornerRadius = UDim.new(0, 10)
    
    local UIStroke = Instance.new("UIStroke", Frame)
    UIStroke.Color = _G.Settings.ThemeColor or Color3.fromRGB(0, 255, 150)
    UIStroke.Thickness = 1.5
    UIStroke.Transparency = 0.4

    local TextLabel = Instance.new("TextLabel", Frame)
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextSize = 12
    TextLabel.RichText = true

    task.spawn(function()
        while task.wait(1) do
            local fps = math.floor(1 / task.wait())
            local ping = "N/A"
            pcall(function()
                ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString():split(" ")[1]
            end)
            local time = os.date("%X")
            TextLabel.Text = string.format("MAKITO <font color='#00FF96'>AI</font> | FPS: %d | PING: %s | %s", fps, ping, time)
        end
    end)
    
    return watermark
end

return UIModule
