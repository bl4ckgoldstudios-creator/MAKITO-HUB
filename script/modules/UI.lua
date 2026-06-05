local UIModule = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Tabs = {}
local CurrentTab = nil

-- UTILS PARA DESIGN
local function Ripple(obj)
    obj.ClipsDescendants = true
    obj.MouseButton1Click:Connect(function()
        local ripple = Instance.new("CircleValue") -- Placeholder para lógica de círculo
        -- Lógica de animação de clique aqui
    end)
end

function UIModule.CreateWindow(title, themeColor)
    local MakitoGui = Instance.new("ScreenGui")
    MakitoGui.Name = "MakitoHub_Elite"
    MakitoGui.ResetOnSpawn = false
    
    pcall(function() MakitoGui.Parent = CoreGui end)
    if not MakitoGui.Parent then MakitoGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local MainFrame = Instance.new("Frame", MakitoGui)
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 650, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -325, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    MainFrame.BorderSizePixel = 0
    
    -- EFEITO DE SOMBRA E BORDA NEON
    local Shadow = Instance.new("ImageLabel", MainFrame)
    Shadow.Name = "Shadow"
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(1, 50, 1, 50)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://6014264795"
    Shadow.ImageColor3 = Color3.new(0,0,0)
    Shadow.ImageTransparency = 0.5
    Shadow.ZIndex = 0

    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 12)
    
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = themeColor
    MainStroke.Thickness = 2
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Transparency = 0.4

    -- GLOW TOP BAR
    local TopGlow = Instance.new("Frame", MainFrame)
    TopGlow.Size = UDim2.new(1, 0, 0, 2)
    TopGlow.BackgroundColor3 = themeColor
    TopGlow.BorderSizePixel = 0
    Instance.new("UIGradient", TopGlow).Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1)
    })

    -- SIDEBAR (DESIGN SLIM)
    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 180, 1, -40)
    Sidebar.Position = UDim2.new(0, 10, 0, 30)
    Sidebar.BackgroundTransparency = 1
    
    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Size = UDim2.new(1, 0, 1, 0)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    
    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.Padding = UDim.new(0, 8)

    -- CONTENT AREA
    local ContentHolder = Instance.new("Frame", MainFrame)
    ContentHolder.Name = "ContentHolder"
    ContentHolder.Size = UDim2.new(1, -210, 1, -40)
    ContentHolder.Position = UDim2.new(0, 200, 0, 30)
    ContentHolder.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    
    local ContentCorner = Instance.new("UICorner", ContentHolder)
    ContentCorner.CornerRadius = UDim.new(0, 10)

    -- HEADER / TITLE
    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(0, 200, 0, 30)
    Title.Position = UDim2.new(0, 15, 0, 5)
    Title.Text = "MAKITO <font color='#FFFFFF'>ELITE</font>"
    Title.RichText = true
    Title.TextColor3 = themeColor
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1

    function UIModule.NewTab(name)
        local TabBtn = Instance.new("TextButton", TabContainer)
        TabBtn.Size = UDim2.new(1, 0, 0, 38)
        TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        TabBtn.Text = "    " .. name
        TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 13
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        
        local TabBtnCorner = Instance.new("UICorner", TabBtn)
        TabBtnCorner.CornerRadius = UDim.new(0, 8)
        
        local TabBtnStroke = Instance.new("UIStroke", TabBtn)
        TabBtnStroke.Color = themeColor
        TabBtnStroke.Thickness = 1
        TabBtnStroke.Transparency = 0.8
        TabBtnStroke.Enabled = false

        local Page = Instance.new("ScrollingFrame", ContentHolder)
        Page.Size = UDim2.new(1, -20, 1, -20)
        Page.Position = UDim2.new(0, 10, 0, 10)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = themeColor
        
        local PageList = Instance.new("UIListLayout", Page)
        PageList.Padding = UDim.new(0, 10)

        TabBtn.MouseButton1Click:Connect(function()
            if CurrentTab then
                TweenService:Create(CurrentTab.Btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(20, 20, 25), TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
                CurrentTab.Btn.UIStroke.Enabled = false
                CurrentTab.Page.Visible = false
            end
            CurrentTab = {Btn = TabBtn, Page = Page}
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundColor3 = themeColor, TextColor3 = Color3.fromRGB(10, 10, 10)}):Play()
            TabBtn.UIStroke.Enabled = true
            Page.Visible = true
        end)

        Tabs[name] = {Btn = TabBtn, Page = Page}
        return Page
    end

    function UIModule.NewToggle(tab, name, settingName, callback)
        local ToggleFrame = Instance.new("Frame", tab)
        ToggleFrame.Size = UDim2.new(1, 0, 0, 45)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
        Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)
        
        local Label = Instance.new("TextLabel", ToggleFrame)
        Label.Size = UDim2.new(1, -70, 1, 0)
        Label.Position = UDim2.new(0, 15, 0, 0)
        Label.Text = name
        Label.TextColor3 = Color3.fromRGB(220, 220, 220)
        Label.Font = Enum.Font.GothamSemibold
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.BackgroundTransparency = 1

        local Switch = Instance.new("TextButton", ToggleFrame)
        Switch.Size = UDim2.new(0, 44, 0, 22)
        Switch.Position = UDim2.new(1, -55, 0.5, -11)
        Switch.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        Switch.Text = ""
        local SwitchCorner = Instance.new("UICorner", Switch)
        SwitchCorner.CornerRadius = UDim.new(1, 0)
        
        local Indicator = Instance.new("Frame", Switch)
        Indicator.Size = UDim2.new(0, 18, 0, 18)
        Indicator.Position = UDim2.new(0, 2, 0.5, -9)
        Indicator.BackgroundColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

        local function Update()
            local enabled = _G.Settings[settingName]
            TweenService:Create(Switch, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundColor3 = enabled and themeColor or Color3.fromRGB(40, 40, 45)}):Play()
            TweenService:Create(Indicator, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = enabled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}):Play()
            if callback then callback(enabled) end
        end

        Switch.MouseButton1Click:Connect(function()
            _G.Settings[settingName] = not _G.Settings[settingName]
            Update()
        end)
        
        Update()
    end

    -- DRAGGING
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = input.Position startPos = MainFrame.Position end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    return MakitoGui, MainFrame
end

function UIModule.CreateHub()
    local theme = _G.Settings.ThemeColor or Color3.fromRGB(0, 255, 150)
    local Gui, Main = UIModule.CreateWindow("MAKITO HUB", theme)

    -- ABAS PADRÃO (EXEMPLO)
    local CombatTab = UIModule.NewTab("Combat")
    UIModule.NewToggle(CombatTab, "Fast Attack V22", "FastAttack")
    UIModule.NewToggle(CombatTab, "Kill Aura Seletivo", "KillAura")

    local FarmTab = UIModule.NewTab("Auto Farm")
    UIModule.NewToggle(FarmTab, "Auto Farm Level", "AutoFarm")
    UIModule.NewToggle(FarmTab, "Bring Mobs Pro", "BringMobs")

    -- Ativar primeira aba
    Tabs["Combat"].Btn.BackgroundColor3 = theme
    Tabs["Combat"].Btn.TextColor3 = Color3.new(0,0,0)
    Tabs["Combat"].Btn.UIStroke.Enabled = true
    Tabs["Combat"].Page.Visible = true
    CurrentTab = {Btn = Tabs["Combat"].Btn, Page = Tabs["Combat"].Page}
end

return UIModule
