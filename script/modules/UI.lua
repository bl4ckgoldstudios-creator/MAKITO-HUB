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
        local ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.Parent = obj
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.6
        ripple.ZIndex = obj.ZIndex + 1
        local corner = Instance.new("UICorner", ripple)
        corner.CornerRadius = UDim.new(1, 0)
        
        local mousePos = UserInputService:GetMouseLocation()
        local objPos = obj.AbsolutePosition
        ripple.Position = UDim2.new(0, mousePos.X - objPos.X, 0, (mousePos.Y - 36) - objPos.Y)
        
        local size = math.max(obj.AbsoluteSize.X, obj.AbsoluteSize.Y) * 1.5
        ripple:TweenSizeAndPosition(UDim2.new(0, size, 0, size), UDim2.new(0.5, -size/2, 0.5, -size/2), "Out", "Quad", 0.5, true)
        TweenService:Create(ripple, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        task.wait(0.5)
        ripple:Destroy()
    end)
end

function UIModule.CreateWindow(title, themeColor)
    local MakitoGui = Instance.new("ScreenGui")
    MakitoGui.Name = "MAKITO_HUB"
    MakitoGui.ResetOnSpawn = false
    
    pcall(function() MakitoGui.Parent = CoreGui end)
    if not MakitoGui.Parent then MakitoGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    -- Floating Icon for Mobile
    local FloatingBtn = Instance.new("ImageButton", MakitoGui)
    FloatingBtn.Name = "FloatingBtn"
    FloatingBtn.Size = UDim2.new(0, 50, 0, 50)
    FloatingBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
    FloatingBtn.BackgroundColor3 = themeColor
    FloatingBtn.Image = "rbxassetid://6031070538" -- Icone de Hub
    FloatingBtn.Draggable = true -- Suporte nativo para mover o ícone
    local FloatingCorner = Instance.new("UICorner", FloatingBtn)
    FloatingCorner.CornerRadius = UDim.new(1, 0)
    
    local MainFrame = Instance.new("Frame", MakitoGui)
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 550, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = true
    
    FloatingBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)

    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 10)
    
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = themeColor
    MainStroke.Thickness = 2

    local StatusLabel = Instance.new("TextLabel", MainFrame)
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Size = UDim2.new(1, -160, 0, 20)
    StatusLabel.Position = UDim2.new(0, 160, 1, -20)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Status: Pronto"
    StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextSize = 11
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

    task.spawn(function()
        while task.wait(0.5) do
            if _G.MakitoStatus then
                StatusLabel.Text = _G.MakitoStatus.Text
            end
        end
    end)

    -- Dragging & Resizing Logic
    local dragging, dragInput, dragStart, startPos
    local resizing, resizeStart, startSize
    
    local function UpdateInput(input)
        if dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        elseif resizing then
            local delta = input.Position - resizeStart
            local newSizeX = math.clamp(startSize.X.Offset + delta.X, 400, 800)
            local newSizeY = math.clamp(startSize.Y.Offset + delta.Y, 250, 600)
            MainFrame.Size = UDim2.new(0, newSizeX, 0, newSizeY)
        end
    end

    MainFrame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    -- Resizer Corner
    local Resizer = Instance.new("ImageLabel", MainFrame)
    Resizer.Name = "Resizer"
    Resizer.Size = UDim2.new(0, 20, 0, 20)
    Resizer.Position = UDim2.new(1, -20, 1, -20)
    Resizer.BackgroundTransparency = 1
    Resizer.Image = "rbxassetid://6032400334" -- Icone de redimensionar
    Resizer.ImageColor3 = themeColor
    Resizer.Active = true

    Resizer.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            resizing = true
            resizeStart = input.Position
            startSize = MainFrame.Size
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then resizing = false end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            UpdateInput(input)
        end
    end)

    -- Sidebar (Suporte a Scroll para Mobile)
    local Sidebar = Instance.new("ScrollingFrame", MainFrame)
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 140, 1, -20)
    Sidebar.Position = UDim2.new(0, 10, 0, 10)
    Sidebar.BackgroundTransparency = 1
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    Sidebar.ScrollBarThickness = 0
    Sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
    
    local TabList = Instance.new("UIListLayout", Sidebar)
    TabList.Padding = UDim.new(0, 5)
    TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Sidebar.CanvasSize = UDim2.new(0, 0, 0, TabList.AbsoluteContentSize.Y)
    end)

    -- Content Area
    local ContentHolder = Instance.new("Frame", MainFrame)
    ContentHolder.Name = "ContentHolder"
    ContentHolder.Size = UDim2.new(1, -170, 1, -20)
    ContentHolder.Position = UDim2.new(0, 160, 0, 10)
    ContentHolder.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    
    local ContentCorner = Instance.new("UICorner", ContentHolder)
    ContentCorner.CornerRadius = UDim.new(0, 8)

    function UIModule.NewTab(name)
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(1, 0, 0, 38)
        TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        TabBtn.Text = "    " .. name
        TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 13
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        Ripple(TabBtn) -- Aplica o efeito de clique
        
        local TabBtnCorner = Instance.new("UICorner", TabBtn)
        TabBtnCorner.CornerRadius = UDim.new(0, 8)

        local Page = Instance.new("ScrollingFrame", ContentHolder)
        Page.Size = UDim2.new(1, -10, 1, -10)
        Page.Position = UDim2.new(0, 5, 0, 5)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 4
        Page.ScrollBarImageColor3 = themeColor
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        
        local PageList = Instance.new("UIListLayout", Page)
        PageList.Padding = UDim.new(0, 8)
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y)
        end)

        TabBtn.MouseButton1Click:Connect(function()
            if CurrentTab then
                CurrentTab.Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                CurrentTab.Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
                CurrentTab.Page.Visible = false
            end
            CurrentTab = {Btn = TabBtn, Page = Page}
            TabBtn.BackgroundColor3 = themeColor
            TabBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
            Page.Visible = true
        end)

        Tabs[name] = {Btn = TabBtn, Page = Page}
        return Page
    end

    function UIModule.NewSection(tab, title)
        local Label = Instance.new("TextLabel", tab)
        Label.Size = UDim2.new(1, 0, 0, 25)
        Label.Text = "--- " .. title .. " ---"
        Label.BackgroundTransparency = 1
        Label.TextColor3 = themeColor
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 12
    end

    function UIModule.NewToggle(tab, name, settingName, callback)
        local ToggleBtn = Instance.new("TextButton", tab)
        ToggleBtn.Size = UDim2.new(1, 0, 0, 35)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        ToggleBtn.Text = name .. ": OFF"
        ToggleBtn.TextColor3 = Color3.new(1,1,1)
        ToggleBtn.Font = Enum.Font.Gotham
        ToggleBtn.TextSize = 13
        Instance.new("UICorner", ToggleBtn)

        local function Update()
            local enabled = _G.Settings[settingName]
            ToggleBtn.Text = name .. ": " .. (enabled and "ON" or "OFF")
            ToggleBtn.TextColor3 = enabled and themeColor or Color3.new(1,1,1)
            if callback then callback(enabled) end
        end

        ToggleBtn.MouseButton1Click:Connect(function()
            _G.Settings[settingName] = not _G.Settings[settingName]
            Update()
        end)
        Update()
    end

    function UIModule.NewSlider(tab, name, min, max, default, settingName, callback)
        local SliderFrame = Instance.new("Frame", tab)
        SliderFrame.Size = UDim2.new(1, 0, 0, 45)
        SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Instance.new("UICorner", SliderFrame)

        local Label = Instance.new("TextLabel", SliderFrame)
        Label.Size = UDim2.new(1, 0, 0, 20)
        Label.Text = name .. ": " .. default
        Label.TextColor3 = Color3.new(1,1,1)
        Label.BackgroundTransparency = 1
        Label.Font = Enum.Font.Gotham

        local Bar = Instance.new("TextButton", SliderFrame)
        Bar.Size = UDim2.new(0.9, 0, 0, 5)
        Bar.Position = UDim2.new(0.05, 0, 0.7, 0)
        Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Bar.Text = ""
        
        local Fill = Instance.new("Frame", Bar)
        Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
        Fill.BackgroundColor3 = themeColor

        Bar.MouseButton1Down:Connect(function()
            local move; move = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + (max - min) * pos)
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    Label.Text = name .. ": " .. val
                    _G.Settings[settingName] = val
                    if callback then callback(val) end
                end
            end)
            local release; release = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    move:Disconnect()
                    release:Disconnect()
                end
            end)
        end)
    end

    function UIModule.NewDropdown(tab, name, options, settingName, callback)
        local DropdownFrame = Instance.new("Frame", tab)
        DropdownFrame.Size = UDim2.new(1, 0, 0, 40)
        DropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Instance.new("UICorner", DropdownFrame)

        local Label = Instance.new("TextLabel", DropdownFrame)
        Label.Size = UDim2.new(1, -10, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.Text = name .. ": " .. (_G.Settings[settingName] or "None")
        Label.TextColor3 = Color3.new(1,1,1)
        Label.BackgroundTransparency = 1
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local OpenBtn = Instance.new("TextButton", DropdownFrame)
        OpenBtn.Size = UDim2.new(1, 0, 1, 0)
        OpenBtn.BackgroundTransparency = 1
        OpenBtn.Text = ""

        local List = Instance.new("Frame", tab)
        List.Size = UDim2.new(1, 0, 0, #options * 30)
        List.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        List.Visible = false
        Instance.new("UICorner", List)
        local ListLayout = Instance.new("UIListLayout", List)

        for _, opt in ipairs(options) do
            local OptBtn = Instance.new("TextButton", List)
            OptBtn.Size = UDim2.new(1, 0, 0, 30)
            OptBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            OptBtn.Text = opt
            OptBtn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
            OptBtn.Font = Enum.Font.Gotham
            Instance.new("UICorner", OptBtn)

            OptBtn.MouseButton1Click:Connect(function()
                _G.Settings[settingName] = opt
                Label.Text = name .. ": " .. opt
                List.Visible = false
                if callback then callback(opt) end
            end)
        end

        OpenBtn.MouseButton1Click:Connect(function()
            List.Visible = not List.Visible
        end)
    end

    function UIModule.NewTextBox(tab, name, placeholder, settingName, callback)
        local BoxFrame = Instance.new("Frame", tab)
        BoxFrame.Size = UDim2.new(1, 0, 0, 40)
        BoxFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Instance.new("UICorner", BoxFrame)

        local Input = Instance.new("TextBox", BoxFrame)
        Input.Size = UDim2.new(1, -20, 1, 0)
        Input.Position = UDim2.new(0, 10, 0, 0)
        Input.BackgroundTransparency = 1
        Input.Text = _G.Settings[settingName] or ""
        Input.PlaceholderText = name .. ": " .. placeholder
        Input.TextColor3 = Color3.new(1,1,1)
        Input.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
        Input.Font = Enum.Font.Gotham
        Input.TextSize = 13
        Input.TextXAlignment = Enum.TextXAlignment.Left

        Input.FocusLost:Connect(function(enterPressed)
            _G.Settings[settingName] = Input.Text
            if callback then callback(Input.Text) end
        end)
    end

    return MakitoGui, MainFrame
end

function UIModule.CreateHub()
    local theme = _G.Settings.ThemeColor or Color3.fromRGB(0, 255, 150)
    local Gui, Main = UIModule.CreateWindow("MAKITO HUB", theme)

    -- TODAS AS ABAS RESTAURADAS
    local MainTab = UIModule.NewTab("Main")
    UIModule.NewSection(MainTab, "Auto Farm")
    UIModule.NewToggle(MainTab, "Auto Farm Level", "AutoFarm")
    UIModule.NewToggle(MainTab, "Auto Quest", "AutoQuest")
    UIModule.NewToggle(MainTab, "Bring Mobs", "BringMobs")
    UIModule.NewSlider(MainTab, "Farm Distance", 0, 50, 10, "Distance")
    UIModule.NewDropdown(MainTab, "Select Weapon", {"Melee", "Sword", "Fruit"}, "Weapon")

    local CombatTab = UIModule.NewTab("Combat")
    UIModule.NewSection(CombatTab, "Attack")
    UIModule.NewToggle(CombatTab, "Fast Attack V23", "FastAttack")
    UIModule.NewToggle(CombatTab, "Kill Aura Silent V3", "KillAura")
    UIModule.NewSection(CombatTab, "PvP")
    UIModule.NewToggle(CombatTab, "Auto Bounty", "AutoBounty")
    UIModule.NewToggle(CombatTab, "Auto Combo", "AutoCombo")
    UIModule.NewDropdown(CombatTab, "Selected Fruit", {"Dough", "Kitsune", "Leopard", "Dragon", "Spirit", "Venom", "Control", "Portal", "Gravity", "Magma", "Rumble", "Light", "Ice", "Quake", "Dark", "Spider", "Love", "Sound", "Phoenix", "Blizzard", "Rocket", "Smoke", "Spin", "Spring", "Chop", "Diamond", "Rubber", "Barrier", "Ghost", "Soul", "Falcon", "Pain", "T-Rex", "Mammoth", "Dough V2"}, "SelectedFruit")

    local StatsTab = UIModule.NewTab("Stats")
    UIModule.NewSection(StatsTab, "Distribution")
    UIModule.NewToggle(StatsTab, "Auto Stats", "AutoStats")
    UIModule.NewDropdown(StatsTab, "Selected Stat", {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"}, "SelectedStat")

    local ItemsTab = UIModule.NewTab("Items")
    UIModule.NewSection(ItemsTab, "Lendários")
    UIModule.NewToggle(ItemsTab, "Auto Soul Guitar", "AutoSoulGuitar")
    UIModule.NewToggle(ItemsTab, "Auto CDK", "AutoCDK")
    UIModule.NewToggle(ItemsTab, "Auto Godhuman", "AutoGodhuman")
    UIModule.NewDropdown(ItemsTab, "Selected Material", {"Dragon Scale", "Fish Tail", "Mystic Droplet", "Vampire Fang", "Magma Ore"}, "SelectedMaterial")

    local SeaTab = UIModule.NewTab("Sea Events")
    UIModule.NewSection(SeaTab, "Sea 3")
    UIModule.NewToggle(SeaTab, "Auto Leviathan", "AutoLeviathan")
    UIModule.NewToggle(SeaTab, "Auto Kitsune", "AutoKitsune")
    UIModule.NewToggle(SeaTab, "Auto Sea Events", "AutoSeaEvent")
    UIModule.NewSection(SeaTab, "Race V4")
    UIModule.NewToggle(SeaTab, "Auto Trial", "AutoTrial")

    local FruitTab = UIModule.NewTab("Fruits")
    UIModule.NewSection(FruitTab, "Automation")
    UIModule.NewToggle(FruitTab, "Auto Fruit Finder", "AutoFruitFinder")
    UIModule.NewToggle(FruitTab, "Auto Store Fruit", "AutoStoreFruit")
    UIModule.NewToggle(FruitTab, "Auto Snipe Fruit", "AutoSnipe")
    UIModule.NewTextBox(FruitTab, "Snipe List", "Ex: Dragon,Kitsune", "SnipeFruitsRaw", function(val)
        local fruits = {}
        for s in val:gmatch("([^,]+)") do 
            local clean = s:gsub("^%s*(.-)%s*$", "%1") -- Trim equivalent
            table.insert(fruits, clean) 
        end
        _G.Settings.SnipeFruits = fruits
    end)

    local VisualsTab = UIModule.NewTab("Visuals")
    UIModule.NewToggle(VisualsTab, "FPS Booster", "FPSBooster")
    UIModule.NewToggle(VisualsTab, "White Screen", "WhiteScreen")
    UIModule.NewSection(VisualsTab, "Themes")
    UIModule.NewDropdown(VisualsTab, "Hub Theme", {"Default", "Neon Red", "Deep Blue", "Golden", "Purple Night"}, "CurrentTheme", function(themeName)
        local themes = {
            ["Default"] = Color3.fromRGB(0, 255, 150),
            ["Neon Red"] = Color3.fromRGB(255, 0, 50),
            ["Deep Blue"] = Color3.fromRGB(0, 100, 255),
            ["Golden"] = Color3.fromRGB(255, 200, 0),
            ["Purple Night"] = Color3.fromRGB(150, 0, 255)
        }
        local color = themes[themeName]
        if color then
            _G.Settings.ThemeColor = color
            Main.UIStroke.Color = color
            -- Adicionar lógica para atualizar todos os botões/elementos com o novo tema
        end
    end)

    local MiscTab = UIModule.NewTab("Misc")
    UIModule.NewToggle(MiscTab, "Anti AFK", "AntiAFK")
    UIModule.NewToggle(MiscTab, "Walk on Water", "WalkOnWater")

    local ConfigTab = UIModule.NewTab("Config")
    UIModule.NewSection(ConfigTab, "Discord Webhook")
    UIModule.NewTextBox(ConfigTab, "Webhook URL", "Paste URL here", "WebhookURL")
    UIModule.NewSection(ConfigTab, "Script Control")
    UIModule.NewToggle(ConfigTab, "Enable Script", "MakitoHubRunning", function(val)
        _G.MakitoHubRunning = val
    end)
    
    -- Ativar primeira aba
    Tabs["Main"].Btn.BackgroundColor3 = theme
    Tabs["Main"].Btn.TextColor3 = Color3.new(0,0,0)
    Tabs["Main"].Page.Visible = true
    CurrentTab = {Btn = Tabs["Main"].Btn, Page = Tabs["Main"].Page}
end

function UIModule.Notify(text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "MAKITO HUB",
            Text = text,
            Duration = duration or 5
        })
    end)
end

return UIModule
