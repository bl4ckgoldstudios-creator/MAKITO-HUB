local UIModule = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Tabs = {}

function UIModule.CreateWindow(title, themeColor)
    local MakitoGui = Instance.new("ScreenGui")
    MakitoGui.Name = "MakitoHub"
    MakitoGui.ResetOnSpawn = false
    
    -- Parent Selection
    pcall(function()
        MakitoGui.Parent = CoreGui
    end)
    if not MakitoGui.Parent then MakitoGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local MainFrame = Instance.new("Frame", MakitoGui)
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 550, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    
    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 8)
    
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = themeColor
    MainStroke.Thickness = 2
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Sidebar for Tabs
    local Sidebar = Instance.new("ScrollingFrame", MainFrame)
    Sidebar.Size = UDim2.new(0, 150, 1, -10)
    Sidebar.Position = UDim2.new(0, 5, 0, 5)
    Sidebar.BackgroundTransparency = 1
    Sidebar.ScrollBarThickness = 2
    
    local SidebarLayout = Instance.new("UIListLayout", Sidebar)
    SidebarLayout.Padding = UDim.new(0, 5)

    -- Container for Tab Content
    local Container = Instance.new("Frame", MainFrame)
    Container.Size = UDim2.new(1, -165, 1, -10)
    Container.Position = UDim2.new(0, 160, 0, 5)
    Container.BackgroundTransparency = 1

    function UIModule.NewTab(name)
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(1, -5, 0, 30)
        TabBtn.Text = name
        TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        TabBtn.TextColor3 = Color3.new(1,1,1)
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.TextSize = 14
        Instance.new("UICorner", TabBtn)

        local TabFrame = Instance.new("ScrollingFrame", Container)
        TabFrame.Size = UDim2.new(1, 0, 1, 0)
        TabFrame.BackgroundTransparency = 1
        TabFrame.Visible = false
        TabFrame.ScrollBarThickness = 2
        
        local TabLayout = Instance.new("UIListLayout", TabFrame)
        TabLayout.Padding = UDim.new(0, 5)

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Tabs) do
                t.Frame.Visible = false
                t.Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            end
            TabFrame.Visible = true
            TabBtn.BackgroundColor3 = themeColor
        end)

        Tabs[name] = {Frame = TabFrame, Btn = TabBtn}
        return TabFrame
    end

    function UIModule.NewSection(tab, title)
        local Label = Instance.new("TextLabel", tab)
        Label.Size = UDim2.new(1, 0, 0, 20)
        Label.Text = "--- " .. title .. " ---"
        Label.BackgroundTransparency = 1
        Label.TextColor3 = themeColor
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 14
    end

    function UIModule.NewToggle(tab, name, settingName, callback)
        local Btn = Instance.new("TextButton", tab)
        Btn.Size = UDim2.new(1, 0, 0, 30)
        Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Btn.Text = name .. ": OFF"
        Btn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        Btn.Font = Enum.Font.Gotham
        Instance.new("UICorner", Btn)

        local function Update()
            local enabled = _G.Settings[settingName]
            Btn.Text = name .. ": " .. (enabled and "ON" or "OFF")
            Btn.TextColor3 = enabled and themeColor or Color3.new(0.8, 0.8, 0.8)
            if callback then callback(enabled) end
        end

        Btn.MouseButton1Click:Connect(function()
            _G.Settings[settingName] = not _G.Settings[settingName]
            Update()
        end)
        
        Update()
    end

    -- Minimize Button
    local MinBtn = Instance.new("TextButton", MakitoGui)
    MinBtn.Size = UDim2.new(0, 50, 0, 50)
    MinBtn.Position = UDim2.new(0, 20, 0, 20)
    MinBtn.Text = "M"
    MinBtn.BackgroundColor3 = themeColor
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)
    
    MinBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)

    UIModule.Notify("Interface Carregada com Sucesso!", 5)
    return MakitoGui, MainFrame, MainStroke
end

function UIModule.CreateHub()
    local theme = _G.Settings.ThemeColor or Color3.fromRGB(0, 255, 150)
    local Gui, Main, Stroke = UIModule.CreateWindow("MAKITO HUB", theme)

    local FarmTab = UIModule.NewTab("Auto Farm")
    UIModule.NewSection(FarmTab, "Progresso Principal")
    UIModule.NewToggle(FarmTab, "Auto Farm Level", "AutoFarm")
    UIModule.NewToggle(FarmTab, "Auto Quest", "AutoQuest")
    UIModule.NewToggle(FarmTab, "Bring Mobs", "BringMobs")
    UIModule.NewToggle(FarmTab, "Fast Attack", "FastAttack")

    local MiscTab = UIModule.NewTab("Misc")
    UIModule.NewToggle(MiscTab, "Auto Stats", "AutoStats")
    UIModule.NewToggle(MiscTab, "Walk on Water", "WalkOnWater")
    UIModule.NewToggle(MiscTab, "FPS Booster", "FPSBooster")
    UIModule.NewToggle(MiscTab, "White Screen", "WhiteScreen")

    -- Set first tab visible
    for _, t in pairs(Tabs) do
        t.Frame.Visible = true
        t.Btn.BackgroundColor3 = theme
        break
    end
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
