local UIModule = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Tabs = {}
local CurrentTab = nil
local Watermark = {}

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

    -- Keyboard Toggle (RightControl)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
            MainFrame.Visible = not MainFrame.Visible
        end
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
        DropdownFrame.Name = name .. "Dropdown"
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
        List.ZIndex = 10
        Instance.new("UICorner", List)
        local ListLayout = Instance.new("UIListLayout", List)

        local function Refresh(newOptions)
            for _, v in ipairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
            for _, opt in ipairs(newOptions) do
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
            List.Size = UDim2.new(1, 0, 0, #newOptions * 30)
        end

        Refresh(options)

        OpenBtn.MouseButton1Click:Connect(function()
            List.Visible = not List.Visible
        end)

        return {Refresh = Refresh}
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

    function UIModule.NewButton(tab, name, callback)
        local Button = Instance.new("TextButton", tab)
        Button.Size = UDim2.new(1, 0, 0, 35)
        Button.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        Button.Text = name
        Button.TextColor3 = Color3.new(1,1,1)
        Button.Font = Enum.Font.GothamMedium
        Button.TextSize = 13
        Instance.new("UICorner", Button)
        Ripple(Button)

        Button.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
    end

    return MakitoGui, MainFrame
end

function UIModule.CreateHub()
    local theme = _G.Settings.ThemeColor or Color3.fromRGB(0, 255, 150)
    local Gui, Main = UIModule.CreateWindow("MAKITO HUB", theme)

    -- TODAS AS ABAS RESTAURADAS
    local SupremeTab = UIModule.NewTab("Supreme (Elite)")
    UIModule.NewSection(SupremeTab, "God-Mode Combat")
    UIModule.NewToggle(SupremeTab, "Instant Kill (Packet Burst)", "FastAttack")
    UIModule.NewToggle(SupremeTab, "Anti-Ban Protection", "SafeMode")
    UIModule.NewSection(SupremeTab, "World Control")
    UIModule.NewToggle(SupremeTab, "Infinite Speed + NoClip", "InfiniteSpeed")
    UIModule.NewToggle(SupremeTab, "Black Hole (Bring All)", "BringMobs")
    UIModule.NewSection(SupremeTab, "Sea 3 Elite")
    UIModule.NewButton(SupremeTab, "Solve Mirage Puzzle", function() _G.Farming.MirageSolver() end)
    UIModule.NewButton(SupremeTab, "Kill Leviathan (Auto Position)", function() _G.Settings.AutoLeviathan = true end)
    UIModule.NewButton(SupremeTab, "Auto Kitsune (Azure Farm)", function() _G.Settings.AutoKitsune = true end)

    local MainTab = UIModule.NewTab("Main")
    UIModule.NewSection(MainTab, "Auto Farm")
    UIModule.NewToggle(MainTab, "Auto Farm Level", "AutoFarm")
    UIModule.NewToggle(MainTab, "Auto Farm Nearest", "AutoFarmNearest")
    UIModule.NewToggle(MainTab, "Auto Quest", "AutoQuest")
    UIModule.NewToggle(MainTab, "Bring Mobs", "BringMobs")
    UIModule.NewSlider(MainTab, "Farm Distance", 0, 50, 10, "Distance")
    UIModule.NewDropdown(MainTab, "Select Weapon", {"Melee", "Sword", "Fruit"}, "Weapon")
    UIModule.NewSection(MainTab, "Automation")
    UIModule.NewToggle(MainTab, "Anti-AFK", "AntiAFK")

    local CombatTab = UIModule.NewTab("Combat & PvP")
    UIModule.NewSection(CombatTab, "Attack")
    UIModule.NewToggle(CombatTab, "Fast Attack V23", "FastAttack")
    UIModule.NewToggle(CombatTab, "Kill Aura Silent V3", "KillAura")
    UIModule.NewSection(CombatTab, "PvP & Bounty")
    local playerList = {}
    for _, v in ipairs(Players:GetPlayers()) do table.insert(playerList, v.Name) end
    UIModule.PlayerDropdown = UIModule.NewDropdown(CombatTab, "Select Player", playerList, "SelectedPlayer")
    
    task.spawn(function()
        while task.wait(5) do
            local newList = {}
            for _, v in ipairs(Players:GetPlayers()) do table.insert(newList, v.Name) end
            if UIModule.PlayerDropdown then UIModule.PlayerDropdown.Refresh(newList) end
        end
    end)
    UIModule.NewButton(CombatTab, "Teleport to Player", function()
        local target = Players:FindFirstChild(_G.Settings.SelectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            _G.Utils.TweenTo(target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
        end
    end)
    UIModule.NewToggle(CombatTab, "Auto Bounty / Kill", "AutoBounty")
    UIModule.NewToggle(CombatTab, "AimBot Skills", "AimBot")
    UIModule.NewSection(CombatTab, "Visuals")
    UIModule.NewToggle(CombatTab, "Player ESP", "PlayerESP")
    UIModule.NewToggle(CombatTab, "Box ESP", "BoxESP")
    UIModule.NewToggle(CombatTab, "Line ESP", "LineESP")

    local TeleportTab = UIModule.NewTab("Teleport")
    UIModule.NewSection(TeleportTab, "Islands")
    
    local currentSea = _G.Farming.GetSea()
    local islandOptions = {}
    for _, island in ipairs(_G.Data.SeaData[currentSea] or {}) do table.insert(islandOptions, island.Name) end
    
    UIModule.IslandDropdown = UIModule.NewDropdown(TeleportTab, "Select Island", islandOptions, "SelectedIsland")
    
    task.spawn(function()
        local lastSea = currentSea
        while task.wait(5) do
            local sea = _G.Farming.GetSea()
            if sea ~= lastSea then
                lastSea = sea
                local newList = {}
                for _, island in ipairs(_G.Data.SeaData[sea] or {}) do table.insert(newList, island.Name) end
                if UIModule.IslandDropdown then UIModule.IslandDropdown.Refresh(newList) end
            end
        end
    end)

    UIModule.NewButton(TeleportTab, "Teleport to Island", function()
        local sea = _G.Farming.GetSea()
        local selected = _G.Settings.SelectedIsland
        for _, island in ipairs(_G.Data.SeaData[sea] or {}) do
            if island.Name == selected then
                _G.Utils.TweenTo(island.Pos)
                break
            end
        end
    end)
    UIModule.NewSection(TeleportTab, "World Travel")
    UIModule.NewButton(TeleportTab, "Travel to First Sea", function() _G.Utils.SafeRemote("TravelMain") end)
    UIModule.NewButton(TeleportTab, "Travel to Second Sea", function() _G.Utils.SafeRemote("TravelZou") end)
    UIModule.NewButton(TeleportTab, "Travel to Third Sea", function() _G.Utils.SafeRemote("TravelDressrosa") end)
    UIModule.NewSection(TeleportTab, "Quick TP")
    UIModule.NewButton(TeleportTab, "Teleport to Cafe", function() 
        if _G.Farming.GetSea() == 2 then _G.Utils.TweenTo(CFrame.new(-382, 73, 291)) end
    end)
    UIModule.NewButton(TeleportTab, "Teleport to Mansion", function() 
        if _G.Farming.GetSea() == 3 then _G.Utils.TweenTo(CFrame.new(-12463, 332, -7548)) end
    end)

    local FruitTab = UIModule.NewTab("Devil Fruit")
    UIModule.NewSection(FruitTab, "Gacha & Shop")
    UIModule.NewToggle(FruitTab, "Auto Buy Fruits (Sniper)", "AutoBuyFruit")
    UIModule.NewToggle(FruitTab, "Auto Random Fruit (Gacha)", "AutoGacha")
    UIModule.NewSection(FruitTab, "World Fruits")
    UIModule.NewToggle(FruitTab, "Teleport to Spawned Fruit", "AutoFruitFinder")
    UIModule.NewToggle(FruitTab, "Auto Bring Fruits", "AutoBringFruit")
    UIModule.NewToggle(FruitTab, "Auto Store Fruits", "AutoStoreFruit")
    UIModule.NewToggle(FruitTab, "Fruit ESP", "AutoFruitESP")
    UIModule.NewToggle(FruitTab, "Auto Collect Fruits", "AutoCollectFruit")
    UIModule.NewTextBox(FruitTab, "Snipe List", "Ex: Dragon,Kitsune", "SnipeFruitsRaw", function(val)
        local fruits = {}
        for s in val:gmatch("([^,]+)") do 
            local clean = s:gsub("^%s*(.-)%s*$", "%1")
            table.insert(fruits, clean)
        end
        _G.Settings.SnipeFruits = fruits
    end)

    local MiscTab = UIModule.NewTab("Misc")
    UIModule.NewSection(MiscTab, "Safety & Protection")
    UIModule.NewToggle(MiscTab, "Auto Kick Moderator", "AutoKickMod")
    UIModule.NewToggle(MiscTab, "Streamer Mode", "StreamerMode", function(v) _G.Utils.SetStreamerMode(v) end)
    UIModule.NewDropdown(MiscTab, "Screen Overlay", {"None", "Black", "White"}, "OverlayType", function(v) _G.Utils.SetScreenOverlay(v) end)
    UIModule.NewSection(MiscTab, "Server")
    UIModule.NewButton(MiscTab, "Server Hop", function() _G.Utils.ServerHop() end)
    UIModule.NewButton(MiscTab, "Rejoin Server", function() _G.Utils.Rejoin() end)
    UIModule.NewSection(MiscTab, "Visuals")
    UIModule.NewButton(MiscTab, "Full Bright", function() _G.Utils.SetFullBright(true) end)
    UIModule.NewButton(MiscTab, "Remove Fog", function() 
        game:GetService("Lighting").FogEnd = 9e9
        for _, v in ipairs(game:GetService("Lighting"):GetChildren()) do
            if v:IsA("Atmosphere") then v:Destroy() end
        end
    end)
    UIModule.NewSection(MiscTab, "Social")
    UIModule.NewTextBox(MiscTab, "Spam Message", "Ex: Makito Hub on Top!", "SpamMessage")
    UIModule.NewToggle(MiscTab, "Chat Spam", "ChatSpam", function(v) if v then _G.Utils.ChatSpam(_G.Settings.SpamMessage) end end)
    UIModule.NewSection(MiscTab, "Performance")
    UIModule.NewButton(MiscTab, "Boost FPS", function() 
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") then
                v.Material = Enum.Material.SmoothPlastic
                if v:IsA("Decal") then v.Transparency = 1 end
            end
        end
    end)

    local DungeonTab = UIModule.NewTab("Dungeon & Raid")
    UIModule.NewSection(DungeonTab, "Raids")
    UIModule.NewDropdown(DungeonTab, "Select Chip", {"Flame", "Ice", "Quake", "Light", "Dark", "String", "Rumble", "Magma", "Human: Buddha", "Sand", "Bird: Phoenix", "Dough"}, "SelectedRaid")
    UIModule.NewToggle(DungeonTab, "Auto Buy Chip", "AutoBuyChip")
    UIModule.NewToggle(DungeonTab, "Auto Start Raid", "AutoStartRaid")
    UIModule.NewSection(DungeonTab, "Automation")
    UIModule.NewToggle(DungeonTab, "Auto Farm Dungeon", "AutoDungeon")
    UIModule.NewToggle(DungeonTab, "Auto Next Island", "AutoNextIsland")
    UIModule.NewToggle(DungeonTab, "Auto Awaken", "AutoAwaken")

    local SeaTab = UIModule.NewTab("Sea Events")
    UIModule.NewSection(SeaTab, "Farm")
    UIModule.NewToggle(SeaTab, "Auto Sea Beast", "AutoSeaBeast")
    UIModule.NewToggle(SeaTab, "Auto Rumbling Waters", "AutoRumbling")
    UIModule.NewToggle(SeaTab, "Auto Ship Raid", "AutoShipRaid")
    UIModule.NewSection(SeaTab, "Bosses & Tracker")
    UIModule.NewToggle(SeaTab, "Auto Leviathan", "AutoLeviathan")
    UIModule.NewToggle(SeaTab, "Auto Kitsune", "AutoKitsune")
    UIModule.NewToggle(SeaTab, "Auto Terrorshark", "AutoTerrorShark")

    local ShopTab = UIModule.NewTab("Shop & Itens")
    UIModule.NewSection(ShopTab, "Abilities (One Click)")
    UIModule.NewButton(ShopTab, "Buy Geppo (Skyjump)", function() _G.Farming.BuyItem("Ability", "Skyjump") end)
    UIModule.NewButton(ShopTab, "Buy Buso Haki (Enhancement)", function() _G.Farming.BuyItem("Ability", "Enhancement") end)
    UIModule.NewButton(ShopTab, "Buy Soru (Flash Step)", function() _G.Farming.BuyItem("Ability", "FlashStep") end)
    UIModule.NewButton(ShopTab, "Buy Ken Haki (Observation)", function() _G.Farming.BuyItem("Ability", "Observation") end)
    
    UIModule.NewSection(ShopTab, "Auto Buy (Toggles)")
    UIModule.NewToggle(ShopTab, "Auto Buy Fighting Styles", "AutoBuyFightingStyle")
    UIModule.NewToggle(ShopTab, "Auto Buy Legendary Swords", "AutoBuyLegendarySword")
    UIModule.NewToggle(ShopTab, "Auto Buy Accessories", "AutoBuyAccessory")
    
    UIModule.NewSection(ShopTab, "Legendary Items")
    UIModule.NewToggle(ShopTab, "Auto Soul Guitar", "AutoSoulGuitar")
    UIModule.NewToggle(ShopTab, "Auto CDK", "AutoCDK")
    UIModule.NewToggle(ShopTab, "Auto Godhuman", "AutoGodhuman")
    
    UIModule.NewSection(ShopTab, "Misc Shop")
    UIModule.NewButton(ShopTab, "Refund Stats", function() _G.Utils.SafeRemote("RefundPoints") end)
    UIModule.NewButton(ShopTab, "Reroll Race", function() _G.Utils.SafeRemote("RerollRace") end)

    local StatsTab = UIModule.NewTab("Stats")
    UIModule.NewSection(StatsTab, "Distribution")
    UIModule.NewToggle(StatsTab, "Auto Point Stats", "AutoStats")
    UIModule.NewDropdown(StatsTab, "Select Stat", {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"}, "SelectedStat")

    local VisualsTab = UIModule.NewTab("Visuals / ESP")
    UIModule.NewSection(VisualsTab, "ESP Master")
    UIModule.NewToggle(VisualsTab, "Player ESP", "EspPlayers")
    UIModule.NewToggle(VisualsTab, "NPC / Enemy ESP", "NpcESP")
    UIModule.NewToggle(VisualsTab, "Chest ESP", "EspChests")
    UIModule.NewToggle(VisualsTab, "Fruit ESP", "EspFruits")
    UIModule.NewToggle(VisualsTab, "Flower ESP (Race V2)", "EspFlower")
    UIModule.NewSection(VisualsTab, "ESP Style")
    UIModule.NewToggle(VisualsTab, "Show Box", "BoxESP")
    UIModule.NewToggle(VisualsTab, "Show Tracers (Lines)", "LineESP")
    UIModule.NewSection(VisualsTab, "World Visuals")
    UIModule.NewToggle(VisualsTab, "Full Bright", "FullBright", function(v) _G.Utils.SetFullBright(v) end)
    UIModule.NewToggle(VisualsTab, "Remove Fog", "RemoveFog", function(v) _G.Utils.RemoveFog(v) end)
    UIModule.NewToggle(VisualsTab, "FPS Booster", "FPSBooster")
    UIModule.NewSection(VisualsTab, "Automation")
    UIModule.NewButton(VisualsTab, "Auto Collect Chests", function() _G.Settings.AutoChest = not _G.Settings.AutoChest end)

    local ConfigTab = UIModule.NewTab("Config")
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

function UIModule.CreateWatermark()
    local watermark = Instance.new("ScreenGui")
    watermark.Name = "MakitoWatermark"
    pcall(function() watermark.Parent = CoreGui end)
    if not watermark.Parent then 
        pcall(function() watermark.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
    end
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
            pcall(function()
                local elapsed = task.wait()
                local fps = elapsed > 0 and math.floor(1 / elapsed) or 0
                local ping = "N/A"
                local stats = game:GetService("Stats")
                local pingItem = stats:FindFirstChild("Network") and stats.Network:FindFirstChild("ServerStatsItem") and stats.Network.ServerStatsItem:FindFirstChild("Data Ping")
                if pingItem then
                    ping = pingItem:GetValueString():split(" ")[1]
                end
                local time = os.date("%X")
                TextLabel.Text = string.format("MAKITO <font color='#00FF96'>HUB</font> | FPS: %d | PING: %s | %s", fps, ping, time)
            end)
        end
    end)
    
    return watermark
end

return UIModule
