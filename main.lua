--[[
    MAKITO HUB - Blox Fruits Edition
    Version: 6.2 (WITH KILL AURA REDZ STYLE)
    The Ultimate All-In-One Experience for Mobile and PC
    Developed by Lucas
    
    [NEW IN V6.2]
    - KILL AURA REDZ HUB STYLE (Damage without animation)
    - Auto proximity attack system
    - Invisible hitbox expansion
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
local CollectionService = game:GetService("CollectionService")

-- Parent Selection for UI
local ParentGui = nil
pcall(function()
    local test = Instance.new("ScreenGui")
    test.Parent = CoreGui
    test:Destroy()
    ParentGui = CoreGui
end)
if not ParentGui then ParentGui = LocalPlayer:WaitForChild("PlayerGui") end

-- 2. GLOBAL SETTINGS & SAVE SYSTEM
_G.MakitoHubRunning = true
local Settings = {
    -- Auto Farm Settings
    AutoFarm = false, FastAttack = false, AutoQuest = false, AutoNextSea = false, Weapon = "Melee", Distance = 10, TweenSpeed = 350, BringMobs = false,
    AutoSkill = false, SkillZ = true, SkillX = true, SkillC = true, SkillV = true,
    AutoMastery = false, MasteryHealth = 20, MasteryWeapon = "Sword",
    FastAttackSpeed = 0.05, AutoHaki = false, AutoKen = false, AutoStats = false, SelectedStat = "Melee",
    -- Sea Events
    AutoSeaEvent = false, AutoMirage = false, AutoFindGear = false, AutoKitsune = false, AutoLeviathan = false, AutoMirageLever = false,
    AutoEliteHunter = false, AutoFactory = false, AutoDoughKing = false, AutoCakePrince = false, AutoBone = false,
    AutoBoss = false, AutoBossHop = true,
    AutoRaceV4 = false, AutoTrial = false,
    -- Items & Puzzles
    AutoSoulGuitar = false, AutoCDK = false, AutoSaber = false, AutoPole = false, AutoGodhuman = false,
    AutoYama = false, AutoTushita = false, AutoRengoku = false, AutoMidnightBlade = false,
    AutoFarmMaterial = false, SelectedMaterial = "Dragon Scale",
    -- Raid Settings
    AutoRaid = false, AutoBuyChip = false, AutoNextIsland = false, AutoAwaken = false, KillAuraRaid = false,
    SelectedRaid = "Flame",
    -- PvP Settings & KILL AURA
    SafeMode = true, AimAssist = false, AutoCombo = false, SelectedFruit = "Dough", PredictMovement = true, SelectedPlayer = "None", AutoBounty = false,
    BountyThreshold = 20, BountyHop = false, 
    KillAura = false,           -- NEW: Kill Aura activation
    KillAuraRange = 50,         -- NEW: Detection range
    KillAuraSpeed = 0.02,       -- NEW: Attack speed
    KillAuraOnlyEnemies = true, -- NEW: Only attack mobs (not players)
    AttackAura = false, WalkOnWater = false, InfGeppo = true, FlyHack = false,
    WalkSpeed = 16, JumpPower = 50, InfEnergy = true,
    -- Visual (ESP)
    EspPlayers = false, EspFruits = false, EspChests = false, EspFlower = false, FullBright = false, FPSBooster = false, NoClip = false,
    AutoChest = false,
    LowGraphics = false, RemoveTextures = false, RemoveShadows = false,
    -- Misc
    AutoRejoin = true, AntiAFK = true, WebhookEnabled = false, WebhookURL = "",
    AutoBuyFruit = false, AutoStoreFruit = true, AutoFruitFinder = false, AutoSnipe = false,
    SnipeFruits = {"Dough", "Kitsune", "Leopard", "Dragon", "Spirit", "Control", "Venom", "Shadow"},
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

local function ServerHop()
    local PlaceID = game.PlaceId
    local JobID = game.JobId
    local Api = "https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Desc&limit=100"
    local function ListServers(cursor)
        local Raw = game:HttpGet(Api .. (cursor and "&cursor=" .. cursor or ""))
        return HttpService:JSONDecode(Raw)
    end
    
    local Servers = ListServers()
    for _, server in ipairs(Servers.data) do
        if server.playing < server.maxPlayers and server.id ~= JobID then
            TeleportService:TeleportToPlaceInstance(PlaceID, server.id)
            break
        end
    end
end

local function SaveSettings()
    pcall(function()
        if writefile then writefile("MakitoHub_V6_Settings.json", HttpService:JSONEncode(Settings)) end
    end)
end

local function LoadSettings()
    pcall(function()
        if isfile and isfile("MakitoHub_V6_Settings.json") then
            local decoded = HttpService:JSONDecode(readfile("MakitoHub_V6_Settings.json"))
            for k, v in pairs(decoded) do Settings[k] = v end
        end
    end)
    Settings.AutoFarm = false
    Settings.AutoQuest = false
    Settings.FastAttack = false
    Settings.BringMobs = false
    Settings.KillAura = false
end
LoadSettings()
_G.Settings = Settings

-- 3. DATABASE
local SeaData = {
    [1] = {
        {Name = "Starter Island (Pirate)", Pos = CFrame.new(1059, 15, 1550)},
        {Name = "Jungle", Pos = CFrame.new(-1612, 37, 149)},
        {Name = "Pirate Village", Pos = CFrame.new(-1181, 4, 3850)},
        {Name = "Desert", Pos = CFrame.new(1094, 6, 4195)},
        {Name = "Middle Town", Pos = CFrame.new(-690, 15, 1583)},
        {Name = "Frozen Village", Pos = CFrame.new(1147, 6, -1157)},
        {Name = "Marinefort", Pos = CFrame.new(-2533, 6, 3110)},
        {Name = "Skylands", Pos = CFrame.new(-4842, 718, -2621)},
        {Name = "Prison", Pos = CFrame.new(4875, 5, 749)},
        {Name = "Magma Village", Pos = CFrame.new(-5313, 12, 8515)},
        {Name = "Underwater City", Pos = CFrame.new(61122, 18, 1565)}
    }
}

local QuestData = {
    [1] = {
        {Min = 0, Name = "BanditQuest1", NPC = "Bandit Recruiter", ID = 1, Enemy = "Bandit", Pos = CFrame.new(1059, 15, 1550), Team = "Pirates"},
        {Min = 15, Name = "MonkeyQuest1", NPC = "Monkey Quest Giver", ID = 1, Enemy = "Monkey", Pos = CFrame.new(-1598, 37, 153)},
        {Min = 20, Name = "MonkeyQuest1", NPC = "Monkey Quest Giver", ID = 2, Enemy = "Gorilla", Pos = CFrame.new(-1598, 37, 153)},
        {Min = 25, Name = "MonkeyQuest1", NPC = "Monkey Quest Giver", ID = 3, Enemy = "Gorilla King", Pos = CFrame.new(-1598, 37, 153)},
    }
}

-- 4. CORE UTILS
local function GetSea()
    local pID = game.PlaceId
    if pID == 2753915549 then return 1 elseif pID == 4442272183 then return 2 elseif pID == 7449423635 then return 3 end
    return 1
end

local function Notify(text, duration)
    pcall(function()
        local NotifyGui = Instance.new("ScreenGui", ParentGui)
        local Frame = Instance.new("Frame", NotifyGui)
        Frame.Size = UDim2.new(0, 280, 0, 60)
        Frame.Position = UDim2.new(1, 20, 0.8, 0)
        Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        Instance.new("UICorner", Frame)
        local Stroke = Instance.new("UIStroke", Frame)
        Stroke.Color = Settings.ThemeColor
        Stroke.Thickness = 1.5
        
        local Label = Instance.new("TextLabel", Frame)
        Label.Size = UDim2.new(1, -20, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 14
        Label.BackgroundTransparency = 1
        Label.TextWrapped = true
        
        TweenService:Create(Frame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -300, 0.8, 0)}):Play()
        task.delay(duration or 4, function()
            TweenService:Create(Frame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, 0.8, 0)}):Play()
            task.wait(0.6)
            NotifyGui:Destroy()
        end)
    end)
end

local function HasItem(itemName)
    if not LocalPlayer.Backpack or not LocalPlayer.Character then return false end
    if LocalPlayer.Backpack:FindFirstChild(itemName) then return true end
    if LocalPlayer.Character:FindFirstChild(itemName) then return true end
    return false
end

local function GetNearestEnemy(EnemyName)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local Nearest, MaxDist = nil, math.huge
    local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
    local searchName = EnemyName and EnemyName:lower() or nil
    
    for _, v in ipairs(enemiesFolder:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
            local vName = v.Name:lower()
            if not searchName or vName == searchName or vName:find(searchName) then
                local dist = (v.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if dist < MaxDist then
                    MaxDist = dist
                    Nearest = v
                end
            end
        end
    end
    
    if not Nearest then
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                local vName = v.Name:lower()
                if not searchName or vName == searchName or vName:find(searchName) then
                    local dist = (v.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if dist < MaxDist then
                        MaxDist = dist
                        Nearest = v
                    end
                end
            end
        end
    end
    
    return Nearest
end

-- COMBAT FRAMEWORK
local CombatFramework = nil
local CombatFrameworkRoot = nil
local FastAttackConn = nil

local function GetFramework()
    pcall(function()
        if not CombatFramework then
            local framework = LocalPlayer.PlayerScripts:FindFirstChild("CombatFramework")
            if framework then
                CombatFramework = require(framework)
            end
        end
        if CombatFramework and CombatFramework.activeController and CombatFramework.activeController.attack then
            local upvalues = debug.getupvalues(CombatFramework.activeController.attack)
            for _, v in pairs(upvalues) do
                if type(v) == "table" and v.activeController then
                    CombatFrameworkRoot = v
                end
            end
        end
    end)
end

-- ============================================================
-- 🔥 KILL AURA REDZ STYLE - NOVO SISTEMA V6.2
-- ============================================================

local KillAuraConn = nil

local function StopKillAura()
    if KillAuraConn then 
        KillAuraConn:Disconnect() 
        KillAuraConn = nil 
    end
end

local function StartKillAura()
    StopKillAura()
    
    KillAuraConn = RunService.Heartbeat:Connect(function()
        if _G.MakitoHubRunning and Settings.KillAura and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            GetFramework()
            
            pcall(function()
                local playerRoot = LocalPlayer.Character.HumanoidRootPart
                local currentTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                
                -- Precisa ter uma arma equipada
                if not currentTool then return end
                
                -- Busca todos os inimigos próximos
                local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
                local foundEnemies = {}
                
                for _, v in ipairs(enemiesFolder:GetChildren()) do
                    if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                        if v.Humanoid.Health > 0 then
                            local dist = (v.HumanoidRootPart.Position - playerRoot.Position).Magnitude
                            
                            -- Se está dentro do range de ataque
                            if dist < Settings.KillAuraRange then
                                table.insert(foundEnemies, {Model = v, Distance = dist})
                            end
                        end
                    end
                end
                
                -- Fallback para mobs no workspace
                if #foundEnemies == 0 then
                    for _, v in ipairs(workspace:GetChildren()) do
                        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                            if v.Humanoid.Health > 0 then
                                local dist = (v.HumanoidRootPart.Position - playerRoot.Position).Magnitude
                                if dist < Settings.KillAuraRange then
                                    table.insert(foundEnemies, {Model = v, Distance = dist})
                                end
                            end
                        end
                    end
                end
                
                -- Se achou inimigos, ataca TODOS
                if #foundEnemies > 0 then
                    -- Ordena por distância (pega os mais pertos primeiro)
                    table.sort(foundEnemies, function(a, b) return a.Distance < b.Distance end)
                    
                    -- Ataca cada inimigo
                    if CombatFramework and CombatFramework.activeController then
                        for _ = 1, 3 do  -- 3 ataques por frame para velocidade
                            -- REDZ HUB STYLE: Expande hitbox silenciosamente
                            CombatFramework.activeController.hitboxMagnitude = Settings.KillAuraRange
                            
                            if CombatFrameworkRoot and CombatFrameworkRoot.activeController then
                                CombatFrameworkRoot.activeController.timeToNextAttack = 0
                                CombatFrameworkRoot.activeController.attackCount = 0
                                CombatFrameworkRoot.activeController.increment = 0
                                CombatFrameworkRoot.activeController.hitboxMagnitude = Settings.KillAuraRange
                                CombatFrameworkRoot.activeController.active = true
                            end
                            
                            -- Chama attack() direto (sem click, sem animação)
                            CombatFramework.activeController.attack()
                        end
                    end
                end
            end)
        elseif not Settings.KillAura then
            StopKillAura()
        end
    end)
    
    -- Kill animation canceller para Kill Aura também
    task.spawn(function()
        while _G.MakitoHubRunning and Settings.KillAura do
            task.wait()
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    local hum = LocalPlayer.Character.Humanoid
                    for _, anim in ipairs(hum:GetPlayingAnimationTracks()) do
                        if anim.Name:lower():find("attack") or anim.Name:lower():find("slash") or anim.Name:lower():find("swing") or anim.Name:lower():find("punch") then
                            anim:Stop(0)
                        end
                    end
                end
            end)
        end
    end)
end

-- Inicia Kill Aura
task.spawn(StartKillAura)

-- ============================================================

local function EquipWeapon()
    local Character = LocalPlayer.Character
    if not Character then return end
    local weaponName = Settings.Weapon
    
    local level = pcall(function() return LocalPlayer.Data.Level.Value end) and LocalPlayer.Data.Level.Value or 0
    if level < 20 and weaponName == "Melee" then
        for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if v:IsA("Tool") and (v.Name == "Combat" or v:FindFirstChild("Combat")) then
                Character.Humanoid:EquipTool(v)
                return
            end
        end
    end

    for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if v:IsA("Tool") and (v.ToolTip == weaponName or v.Name:lower():find(weaponName:lower()) or (weaponName == "Melee" and (v:FindFirstChild("Combat") or v.Name == "Combat"))) then
            Character.Humanoid:EquipTool(v)
            break
        end
    end
end

local function Notify(text, duration)
    pcall(function()
        local NotifyGui = Instance.new("ScreenGui", ParentGui)
        local Frame = Instance.new("Frame", NotifyGui)
        Frame.Size = UDim2.new(0, 280, 0, 60)
        Frame.Position = UDim2.new(1, 20, 0.8, 0)
        Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        Instance.new("UICorner", Frame)
        local Stroke = Instance.new("UIStroke", Frame)
        Stroke.Color = Settings.ThemeColor
        Stroke.Thickness = 1.5
        
        local Label = Instance.new("TextLabel", Frame)
        Label.Size = UDim2.new(1, -20, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 14
        Label.BackgroundTransparency = 1
        Label.TextWrapped = true
        
        TweenService:Create(Frame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -300, 0.8, 0)}):Play()
        task.delay(duration or 4, function()
            TweenService:Create(Frame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, 0.8, 0)}):Play()
            task.wait(0.6)
            NotifyGui:Destroy()
        end)
    end)
end

local function CreateHub()
    local MakitoGui = Instance.new("ScreenGui", ParentGui)
    MakitoGui.Name = "MakitoHubSupremeV6"
    
    local Main = Instance.new("Frame", MakitoGui)
    Main.Size = UDim2.new(0, 400, 0, 250)
    Main.Position = UDim2.new(0.5, -200, 0.5, -125)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = Settings.ThemeColor
    MainStroke.Thickness = 2

    local TopBar = Instance.new("Frame", Main)
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    TopBar.BorderSizePixel = 0
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)
    
    local Title = Instance.new("TextLabel", TopBar)
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.Text = "MAKITO HUB V6.2 - KILL AURA"
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Kill Aura Toggle
    local KillAuraToggle = Instance.new("TextButton", Main)
    KillAuraToggle.Size = UDim2.new(1, -20, 0, 50)
    KillAuraToggle.Position = UDim2.new(0, 10, 0, 60)
    KillAuraToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    KillAuraToggle.Text = "⚔️ KILL AURA (OFF)"
    KillAuraToggle.TextColor3 = Color3.new(1,1,1)
    KillAuraToggle.Font = Enum.Font.GothamBold
    KillAuraToggle.TextSize = 14
    Instance.new("UICorner", KillAuraToggle)
    
    KillAuraToggle.MouseButton1Click:Connect(function()
        Settings.KillAura = not Settings.KillAura
        KillAuraToggle.Text = Settings.KillAura and "⚔️ KILL AURA (ON)" or "⚔️ KILL AURA (OFF)"
        KillAuraToggle.BackgroundColor3 = Settings.KillAura and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(25, 25, 35)
        Notify(Settings.KillAura and "🔥 KILL AURA ATIVADA!" or "⛔ KILL AURA DESATIVADA", 3)
        SaveSettings()
        if Settings.KillAura then
            StartKillAura()
        else
            StopKillAura()
        end
    end)

    -- Range Slider
    local RangeLabel = Instance.new("TextLabel", Main)
    RangeLabel.Size = UDim2.new(1, -20, 0, 25)
    RangeLabel.Position = UDim2.new(0, 10, 0, 120)
    RangeLabel.Text = "Range: " .. tostring(Settings.KillAuraRange) .. "m"
    RangeLabel.TextColor3 = Color3.new(1,1,1)
    RangeLabel.Font = Enum.Font.Gotham
    RangeLabel.TextSize = 12
    RangeLabel.BackgroundTransparency = 1

    local RangeBar = Instance.new("Frame", Main)
    RangeBar.Size = UDim2.new(1, -20, 0, 6)
    RangeBar.Position = UDim2.new(0, 10, 0, 150)
    RangeBar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    Instance.new("UICorner", RangeBar)
    
    local RangeFill = Instance.new("Frame", RangeBar)
    RangeFill.Size = UDim2.new((Settings.KillAuraRange - 10) / 80, 0, 1, 0)
    RangeFill.BackgroundColor3 = Settings.ThemeColor
    Instance.new("UICorner", RangeFill)

    RangeBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local pos = math.clamp((input.Position.X - RangeBar.AbsolutePosition.X) / RangeBar.AbsoluteSize.X, 0, 1)
            Settings.KillAuraRange = math.floor(10 + (80 * pos))
            RangeFill.Size = UDim2.new(pos, 0, 1, 0)
            RangeLabel.Text = "Range: " .. tostring(Settings.KillAuraRange) .. "m"
            SaveSettings()
        end
    end)

    Notify("MAKITO HUB V6.2 - KILL AURA ATIVADO!", 5)
end

-- Keybinds
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Settings.KillSwitchKey then
        _G.MakitoHubRunning = false
        Notify("MAKITO HUB ENCERRADO", 3)
        local gui = ParentGui:FindFirstChild("MakitoHubSupremeV6")
        if gui then gui:Destroy() end
    end
end)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Initialize
task.spawn(CreateHub)
print("[MAKITO HUB V6.2] Kill Aura Redz Style Iniciado!")
print("[MAKITO HUB] Ative Kill Aura e se aproxime de inimigos para atacar automaticamente!")
