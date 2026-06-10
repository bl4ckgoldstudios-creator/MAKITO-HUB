--!strict
local UIModule = {}

-- SERVICES
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- INTERNAL STATE
local Makito = getgenv().Makito
local Tabs = {}
local CurrentTab = nil

-- UTILS PARA DESIGN
local function Ripple(obj: any)
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
    MainFrame.Size = UDim2.new(0, 620, 0, 420)

    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 8)

    local themeColor = (Makito.Settings and Makito.Settings.ThemeColor) or Color3.fromRGB(0, 255, 150)

    local Glow = Instance.new("ImageLabel")
    Glow.Name = "Glow"
    Glow.Parent = MainFrame
    Glow.AnchorPoint = Vector2.new(0.5, 0.5)
    Glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Glow.Size = UDim2.new(1, 80, 1, 80)
    Glow.BackgroundTransparency = 1
    Glow.Image = "rbxassetid://6014264795"
    Glow.ImageColor3 = themeColor
    Glow.ImageTransparency = 0.7
    Glow.ZIndex = -2

    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = themeColor
    MainStroke.Thickness = 2
    MainStroke.Transparency = 0.2
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- SISTEMA RGB
    task.spawn(function()
        while Makito.Running do
            if Makito.Settings and Makito.Settings.RainbowUI then
                local hue = tick() % 5 / 5
                local color = Color3.fromHSV(hue, 0.8, 1)
                MainStroke.Color = color
                Glow.ImageColor3 = color
                task.wait()
            else
                task.wait(1)
            end
        end
    end)

    -- DRAG LOGIC
    local dragging, dragStart, startPos
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

    -- SIDEBAR
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = MainFrame
    Sidebar.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
    Sidebar.BorderSizePixel = 0
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    Sidebar.ZIndex = 2
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)
    
    local SidebarTitle = Instance.new("TextLabel")
    SidebarTitle.Name = "Title"
    SidebarTitle.Parent = Sidebar
    SidebarTitle.Size = UDim2.new(1, 0, 0, 60)
    SidebarTitle.BackgroundTransparency = 1
    SidebarTitle.Font = Enum.Font.GothamBold
    SidebarTitle.RichText = true
    SidebarTitle.Text = "MAKITO <font color='#00FF96'>HUB</font>"
    SidebarTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    SidebarTitle.TextSize = 22

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = Sidebar
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 10, 0, 65)
    TabContainer.Size = UDim2.new(1, -20, 1, -75)
    TabContainer.ScrollBarThickness = 1
    TabContainer.ScrollBarImageColor3 = themeColor
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)

    local TabList = Instance.new("UIListLayout")
    TabList.Parent = TabContainer
    TabList.Padding = UDim.new(0, 6)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder

    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Parent = MainFrame
    ContentArea.BackgroundTransparency = 1
    ContentArea.Position = UDim2.new(0, 170, 0, 15)
    ContentArea.Size = UDim2.new(1, -180, 1, -30)
    ContentArea.ZIndex = 2

    -- HOME
    local HomeTab = UIModule.NewTab("HOME", "rbxassetid://10747373176", TabContainer, ContentArea)
    UIModule.NewSection(HomeTab, "DASHBOARD")
    local StatLabel = Instance.new("TextLabel", HomeTab)
    StatLabel.Size = UDim2.new(1, 0, 0, 120)
    StatLabel.BackgroundTransparency = 1
    StatLabel.Font = Enum.Font.GothamBold
    StatLabel.TextColor3 = Color3.new(1,1,1)
    StatLabel.TextSize = 14
    StatLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatLabel.RichText = true
    task.spawn(function()
        while task.wait(1) do
            pcall(function()
                StatLabel.Text = string.format(
                    "👤 <font color='#00FF96'>PLAYER:</font> %s\n📈 <font color='#00FF96'>LEVEL:</font> %d\n💰 <font color='#00FF96'>BELI:</font> %d\n✨ <font color='#00FF96'>FRAGS:</font> %d\n⚔️ <font color='#00FF96'>SEA:</font> %d",
                    LocalPlayer.Name, LocalPlayer.Data.Level.Value, LocalPlayer.Data.Beli.Value, LocalPlayer.Data.Fragments.Value, Makito.Sea
                )
            end)
        end
    end)

    -- WORLD
    local WorldTab = UIModule.NewTab("WORLD", "rbxassetid://10747373176", TabContainer, ContentArea)
    UIModule.NewSection(WorldTab, "World Status")
    local WorldLabel = Instance.new("TextLabel", WorldTab)
    WorldLabel.Size = UDim2.new(1, 0, 0, 150)
    WorldLabel.BackgroundTransparency = 1
    WorldLabel.Font = Enum.Font.GothamBold
    WorldLabel.TextColor3 = Color3.new(1,1,1)
    WorldLabel.TextSize = 13
    WorldLabel.TextXAlignment = Enum.TextXAlignment.Left
    WorldLabel.RichText = true
    task.spawn(function()
        while Makito.Running do
            if Makito.Utils then
                local status = Makito.Utils.GetWorldStatus()
                WorldLabel.Text = string.format(
                    "🗡️ <font color='#00FF96'>Rip Indra:</font> %s\n🍩 <font color='#00FF96'>Dough King:</font> %s\n👥 <font color='#00FF96'>Mobs p/ Spawn:</font> %s\n\n👹 <font color='#00FF96'>Bosses Vivos:</font>\n<font color='#CCCCCC'>%s</font>",
                    status.RipIndra, status.DoughKing, status.CakeCounter, table.concat(status.ActiveBosses, ", ")
                )
            end
            task.wait(2)
        end
    end)

    -- FARMING
    local FarmTab = UIModule.NewTab("FARMING", "rbxassetid://10747373111", TabContainer, ContentArea)
    UIModule.NewSection(FarmTab, "Main Farm")
    UIModule.NewToggle(FarmTab, "Auto Farm Level", "AutoFarm")
    UIModule.NewToggle(FarmTab, "Auto Quest", "AutoQuest")
    UIModule.NewToggle(FarmTab, "Auto Next Sea", "AutoNextSea")
    UIModule.NewToggle(FarmTab, "Auto Elite Hunter", "AutoEliteHunter")
    UIModule.NewToggle(FarmTab, "Auto Bone Farm (S3)", "AutoBoneFarm")
    UIModule.NewToggle(FarmTab, "Auto Factory (S2)", "AutoFarmFactory")
    UIModule.NewToggle(FarmTab, "Auto Ship Raid (S2)", "AutoFarmShipRaid")
    UIModule.NewToggle(FarmTab, "Auto Bartilo Quest (S2)", "AutoBartiloQuest")
    UIModule.NewToggle(FarmTab, "Auto Citizen Quest (S3)", "AutoCitizenQuest")
    UIModule.NewToggle(FarmTab, "Auto Buy Haki Colors", "AutoBuyHakiColors")
    
    UIModule.NewSection(FarmTab, "Boss Farm")
    UIModule.NewToggle(FarmTab, "Auto Farm All Bosses", "AutoFarmAllBosses")
    
    -- Boss Selection
    UIModule.NewSection(FarmTab, "Select Bosses to Farm")
    local BossSelectionFrame = Instance.new("Frame", FarmTab)
    BossSelectionFrame.Size = UDim2.new(1, -10, 0, 200)
    BossSelectionFrame.BackgroundColor3 = Color3.fromRGB(15,15,20)
    Instance.new("UICorner", BossSelectionFrame).CornerRadius = UDim.new(0, 6)
    
    local BossScroll = Instance.new("ScrollingFrame", BossSelectionFrame)
    BossScroll.Size = UDim2.new(1, 0, 1, 0)
    BossScroll.BackgroundTransparency = 1
    BossScroll.ScrollBarThickness = 2
    local BossListLayout = Instance.new("UIListLayout", BossScroll)
    BossListLayout.Padding = UDim.new(0, 5)
    
    -- Preencher a lista de bosses
    task.spawn(function()
        if Makito and Makito.Data then
            for _, bossData in ipairs(Makito.Data.BossData) do
                local BossToggle = Instance.new("TextButton", BossScroll)
                BossToggle.Size = UDim2.new(1, -10, 0, 25)
                BossToggle.Position = UDim2.new(0, 5, 0, 0)
                BossToggle.BackgroundColor3 = Color3.fromRGB(25,25,30)
                BossToggle.Text = "  " .. bossData.Name .. " (S" .. bossData.Sea .. ")"
                BossToggle.TextColor3 = Color3.new(0.8,0.8,0.8)
                BossToggle.TextSize = 11
                BossToggle.TextXAlignment = Enum.TextXAlignment.Left
                Instance.new("UICorner", BossToggle).CornerRadius = UDim.new(0, 4)
                
                -- Função para atualizar o estado do toggle
                local function UpdateBossToggle()
                    local isSelected = false
                    if Makito.Settings and Makito.Settings.SelectedBosses then
                        for _, name in ipairs(Makito.Settings.SelectedBosses) do
                            if name == bossData.Name then
                                isSelected = true
                                break
                            end
                        end
                    end
                    BossToggle.TextColor3 = isSelected and Color3.new(1,1,1) or Color3.new(0.6,0.6,0.6)
                    BossToggle.BackgroundColor3 = isSelected and ((Makito.Settings and Makito.Settings.ThemeColor) or Color3.fromRGB(0,255,150)) or Color3.fromRGB(25,25,30)
                end
                
                BossToggle.MouseButton1Click:Connect(function()
                    if not Makito.Settings then return end
                    if not Makito.Settings.SelectedBosses then Makito.Settings.SelectedBosses = {} end
                    
                    -- Verifica se o boss já está selecionado
                    local foundIndex = nil
                    for i, name in ipairs(Makito.Settings.SelectedBosses) do
                        if name == bossData.Name then
                            foundIndex = i
                            break
                        end
                    end
                    
                    if foundIndex then
                        -- Remove da seleção
                        table.remove(Makito.Settings.SelectedBosses, foundIndex)
                    else
                        -- Adiciona à seleção
                        table.insert(Makito.Settings.SelectedBosses, bossData.Name)
                    end
                    
                    UpdateBossToggle()
                    
                    -- Desativa o "Auto Farm All Bosses" se selecionarmos individualmente
                    if Makito.Settings.SelectedBosses and #Makito.Settings.SelectedBosses > 0 then
                        Makito.Settings.AutoFarmAllBosses = false
                    end
                end)
                
                UpdateBossToggle()
            end
        end
    end)

    -- COMBAT
    local CombatTab = UIModule.NewTab("COMBAT", "rbxassetid://10747383424", TabContainer, ContentArea)
    UIModule.NewSection(CombatTab, "Attack Settings")
    UIModule.NewToggle(CombatTab, "Fast Attack Pro", "FastAttack")
    UIModule.NewToggle(CombatTab, "Kill Aura Elite", "KillAura")
    UIModule.NewToggle(CombatTab, "Stealth Mode", "StealthMode")
    UIModule.NewSlider(CombatTab, "Killaura Distance", 10, 300, 100, "KillAuraDistance")
    UIModule.NewToggle(CombatTab, "Auto Haki", "AutoHaki")
    UIModule.NewDropdown(CombatTab, "Main Weapon", {"Melee", "Sword", "Fruit"}, "MainWeapon")

    -- SEA EVENTS
    local SeaTab = UIModule.NewTab("SEA EVENTS", "rbxassetid://10747373176", TabContainer, ContentArea)
    UIModule.NewSection(SeaTab, "Sea Events V2")
    UIModule.NewToggle(SeaTab, "Auto Sea Beast", "AutoSeaBeast")
    UIModule.NewToggle(SeaTab, "Auto Terror Shark", "AutoTerrorShark")
    UIModule.NewToggle(SeaTab, "Auto Leviathan", "AutoLeviathan")
    UIModule.NewToggle(SeaTab, "Auto Kitsune Event", "AutoKitsuneEvent")
    UIModule.NewToggle(SeaTab, "Auto Mirage Finder", "AutoMirageAdvanced")

    -- FRUITS
    local FruitTab = UIModule.NewTab("FRUITS", "rbxassetid://10747373176", TabContainer, ContentArea)
    UIModule.NewSection(FruitTab, "Fruit Automation")
    UIModule.NewToggle(FruitTab, "Auto Collect Fruits", "AutoCollectFruit")
    UIModule.NewToggle(FruitTab, "Auto Store Fruits", "AutoStoreFruit")
    UIModule.NewToggle(FruitTab, "Auto Random Gacha", "AutoGacha")
    UIModule.NewToggle(FruitTab, "Fruit Finder ESP", "AutoFruitFinder")

    -- AUTO ITEMS (NEW)
    local ItemsTab = UIModule.NewTab("AUTO ITEMS", "rbxassetid://10747373176", TabContainer, ContentArea)
    UIModule.NewSection(ItemsTab, "Powerful Items")
    UIModule.NewToggle(ItemsTab, "Auto Cursed Dual Katana", "AutoCDK")
    UIModule.NewToggle(ItemsTab, "Auto Soul Guitar", "AutoSoulGuitar")
    UIModule.NewToggle(ItemsTab, "Auto Godhuman", "AutoGodhuman")
    UIModule.NewToggle(ItemsTab, "Auto Sanguine Art", "AutoSanguineArt")
    UIModule.NewToggle(ItemsTab, "Auto Shark Anchor", "AutoSharkAnchor")
    UIModule.NewSection(ItemsTab, "Swords & Haki")
    UIModule.NewToggle(ItemsTab, "Auto Tushita", "AutoTushita")
    UIModule.NewToggle(ItemsTab, "Auto Yama", "AutoYama")
    UIModule.NewToggle(ItemsTab, "Auto Saber", "AutoSaber")
    UIModule.NewToggle(ItemsTab, "Auto Rainbow Haki", "AutoRainbowHaki")
    UIModule.NewToggle(ItemsTab, "Auto Observation V2", "AutoObservationV2")
    UIModule.NewToggle(ItemsTab, "Auto Dark Coat", "AutoDarkCoat")

    -- RAID
    local RaidTab = UIModule.NewTab("RAID", "rbxassetid://10747373176", TabContainer, ContentArea)
    UIModule.NewSection(RaidTab, "Raid Settings")
    UIModule.NewToggle(RaidTab, "Auto Raid", "AutoRaid")
    UIModule.NewToggle(RaidTab, "Auto Start Raid", "AutoStartRaid")
    UIModule.NewToggle(RaidTab, "Auto Buy Chip", "AutoBuyChip")
    UIModule.NewDropdown(RaidTab, "Select Raid", {"Flame", "Ice", "Quake", "Light", "Dark", "Spider", "Rumble", "Magma", "Buddha", "Sand", "Dough"}, "SelectedRaid")
    UIModule.NewDropdown(RaidTab, "Raid Mode", {"Above", "Below"}, "RaidMode")

    -- VISUALS
    local VisualTab = UIModule.NewTab("VISUALS", "rbxassetid://10747372992", TabContainer, ContentArea)
    UIModule.NewSection(VisualTab, "ESP System")
    UIModule.NewToggle(VisualTab, "Player ESP", "EspPlayers")
    UIModule.NewToggle(VisualTab, "NPC ESP", "NpcESP")
    UIModule.NewToggle(VisualTab, "Chest ESP", "EspChests")
    UIModule.NewToggle(VisualTab, "Fruit ESP", "EspFruits")
    UIModule.NewToggle(VisualTab, "Box ESP", "BoxESP")

    -- SETTINGS
    local SettingsTab = UIModule.NewTab("SETTINGS", "rbxassetid://10747373176", TabContainer, ContentArea)
    UIModule.NewSection(SettingsTab, "Customization")
    UIModule.NewToggle(SettingsTab, "Rainbow UI", "RainbowUI")
    UIModule.NewToggle(SettingsTab, "Infinite Geppo", "InfiniteGeppo")
    UIModule.NewToggle(SettingsTab, "FPS Boost", "FPSBoost")
    UIModule.NewToggle(SettingsTab, "White Screen (CPU Save)", "WhiteScreen")
    UIModule.NewToggle(SettingsTab, "Full Bright", "FullBright")
    UIModule.NewSlider(SettingsTab, "Tween Speed", 100, 500, 350, "TweenSpeed")
    UIModule.NewButton(SettingsTab, "Server Hop", function() Makito.Utils.ServerHop() end)
    UIModule.NewButton(SettingsTab, "Rejoin", function() Makito.Utils.Rejoin() end)
    UIModule.NewSection(SettingsTab, "Race Management")
    UIModule.NewToggle(SettingsTab, "Auto Roll Race (3k Frags)", "AutoRollRace")
    UIModule.NewDropdown(SettingsTab, "Target Race", {"Human", "Mink", "Fishman", "Skypian"}, "TargetRace")
    UIModule.NewSection(SettingsTab, "Webhooks")
    UIModule.NewToggle(SettingsTab, "Send Stats to Webhook", "AutoWebhook")
    -- In a real scenario, we'd need a TextBox for WebhookURL, but for now we'll assume it's set in Settings.lua
    -- or provided via _G.

    return MakitoGui, MainFrame
end

function UIModule.NewTab(name: string, iconId: string, container: any, contentArea: any)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = name .. "Tab"
    TabBtn.Parent = container
    TabBtn.Size = UDim2.new(1, 0, 0, 42)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = ""
    
    local Icon = Instance.new("ImageLabel", TabBtn)
    Icon.Size = UDim2.new(0, 20, 0, 20)
    Icon.Position = UDim2.new(0, 10, 0.5, -10)
    Icon.BackgroundTransparency = 1
    Icon.Image = iconId
    Icon.ImageColor3 = Color3.fromRGB(150, 150, 150)

    local Label = Instance.new("TextLabel", TabBtn)
    Label.Size = UDim2.new(1, -40, 1, 0)
    Label.Position = UDim2.new(0, 40, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(150, 150, 150)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Page = Instance.new("ScrollingFrame", contentArea)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local List = Instance.new("UIListLayout", Page)
    List.Padding = UDim.new(0, 10)
    List.SortOrder = Enum.SortOrder.LayoutOrder

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Page.Visible = false end
        Page.Visible = true
        CurrentTab = name
    end)

    Tabs[name] = {Btn = TabBtn, Page = Page}
    if not CurrentTab then Page.Visible = true CurrentTab = name end
    return Page
end

function UIModule.NewSection(parent: any, name: string)
    local Label = Instance.new("TextLabel", parent)
    Label.Size = UDim2.new(1, 0, 0, 25)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.Text = "—— " .. name:upper() .. " ——"
    Label.TextColor3 = (Makito.Settings and Makito.Settings.ThemeColor) or Color3.fromRGB(0, 255, 150)
    Label.TextSize = 12
end

function UIModule.NewToggle(parent: any, name: string, setting: string, callback: any?)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Btn.Font = Enum.Font.GothamBold
    Btn.Text = "  " .. name
    Btn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    Btn.TextSize = 12
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local function Update()
        local val = Makito.Settings[setting]
        Btn.TextColor3 = val and Color3.new(1, 1, 1) or Color3.new(0.6, 0.6, 0.6)
        Btn.BackgroundColor3 = val and ((Makito.Settings and Makito.Settings.ThemeColor) or Color3.fromRGB(0, 255, 150)) or Color3.fromRGB(20, 20, 25)
    end

    Btn.MouseButton1Click:Connect(function()
        Makito.Settings[setting] = not Makito.Settings[setting]
        Update()
        if callback then callback(Makito.Settings[setting]) end
    end)
    Update()
end

function UIModule.NewButton(parent: any, name: string, callback: any)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Btn.Font = Enum.Font.GothamBold
    Btn.Text = name
    Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.TextSize = 12
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Btn.MouseButton1Click:Connect(callback)
end

function UIModule.NewDropdown(parent: any, name: string, options: {string}, setting: string, callback: any?)
    local Drop = Instance.new("TextButton", parent)
    Drop.Size = UDim2.new(1, -10, 0, 35)
    Drop.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Drop.Font = Enum.Font.GothamBold
    Drop.Text = "  " .. name .. ": " .. tostring(Makito.Settings[setting])
    Drop.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    Drop.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", Drop).CornerRadius = UDim.new(0, 6)

    local List = Instance.new("Frame", parent)
    List.Size = UDim2.new(1, -10, 0, 0)
    List.Visible = false
    List.ClipsDescendants = true
    Instance.new("UIListLayout", List)

    Drop.MouseButton1Click:Connect(function()
        List.Visible = not List.Visible
        List.Size = List.Visible and UDim2.new(1, -10, 0, #options * 30) or UDim2.new(1, -10, 0, 0)
    end)

    for _, opt in ipairs(options) do
        local b = Instance.new("TextButton", List)
        b.Size = UDim2.new(1, 0, 0, 30)
        b.Text = opt
        b.MouseButton1Click:Connect(function()
            Makito.Settings[setting] = opt
            Drop.Text = "  " .. name .. ": " .. opt
            List.Visible = false
            List.Size = UDim2.new(1, -10, 0, 0)
            if callback then callback(opt) end
        end)
    end
end

function UIModule.NewSlider(parent: any, name: string, min: number, max: number, default: number, setting: string, callback: any?)
    local Slider = Instance.new("Frame", parent)
    Slider.Size = UDim2.new(1, -10, 0, 50)
    Slider.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Instance.new("UICorner", Slider).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel", Slider)
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.new(1,1,1)
    Label.Text = name .. ": " .. Makito.Settings[setting]

    local Bar = Instance.new("Frame", Slider)
    Bar.Size = UDim2.new(1, -20, 0, 4)
    Bar.Position = UDim2.new(0, 10, 0, 35)
    Bar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)

    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new((Makito.Settings[setting] - min)/(max-min), 0, 1, 0)
    Fill.BackgroundColor3 = (Makito.Settings and Makito.Settings.ThemeColor) or Color3.fromRGB(0, 255, 150)
    
    local dragging = false
    local function Update(input: any)
        local percent = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * percent)
        Fill.Size = UDim2.new(percent, 0, 1, 0)
        Label.Text = name .. ": " .. val
        Makito.Settings[setting] = val
        if callback then callback(val) end
    end
    
    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true Update(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end
    end)
end

function UIModule.CreateWatermark()
    local watermark = Instance.new("ScreenGui")
    watermark.Name = "MakitoWatermark"
    pcall(function() watermark.Parent = CoreGui end)
    if not watermark.Parent then watermark.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    
    local Frame = Instance.new("Frame")
    Frame.Parent = watermark
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    Frame.Position = UDim2.new(0.5, -150, 0, 10)
    Frame.Size = UDim2.new(0, 300, 0, 25)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    
    local TextLabel = Instance.new("TextLabel", Frame)
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.TextColor3 = Color3.new(1,1,1)
    TextLabel.TextSize = 12

    task.spawn(function()
        while task.wait(1) do
            local fps = math.floor(1 / task.wait())
            TextLabel.Text = "MAKITO HUB | FPS: " .. fps .. " | " .. os.date("%X")
        end
    end)
end

return UIModule
