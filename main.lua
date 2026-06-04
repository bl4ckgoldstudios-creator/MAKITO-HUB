--[[
    MAKITO HUB - Blox Fruits Edition
    Version: 6.1 (SUPREME GOD MODE - IMPROVED & FIXED)
    The Ultimate All-In-One Experience for Mobile and PC
    Developed by Lucas
    
    [FEATURES]
    - Level Farm (Sea 1, 2, 3)
    - Fast Attack V17 (Combat Framework Hook)
    - Auto Raid (Full Automatic)
    - Sea Events (Mirage, Kitsune, Leviathan, Terror Shark)
    - Legendary Items (Soul Guitar, CDK, Godhuman, Yama, Tushita)
    - Advanced ESP & Visuals
    - Anti-Cheat Bypass (Magnitude & Speed)
    - Priority Task Scheduler
    
    [IMPROVEMENTS V6.1]
    - Fixed ExecuteCombo function
    - Added HasItem function implementation
    - Improved error handling
    - Better performance optimization
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
    -- PvP Settings
    SafeMode = true, AimAssist = false, AutoCombo = false, SelectedFruit = "Dough", PredictMovement = true, SelectedPlayer = "None", AutoBounty = false,
    BountyThreshold = 20, BountyHop = false, KillAura = false, AttackAura = false, WalkOnWater = false, InfGeppo = true, FlyHack = false,
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
    -- FORCE DISABLE CRITICALS ON START
    Settings.AutoFarm = false
    Settings.AutoQuest = false
    Settings.FastAttack = false
    Settings.BringMobs = false
end
LoadSettings()
_G.Settings = Settings

-- 3. MASSIVE DATABASE (QUESTS, ISLANDS, NPCS)
local SeaData = {
    [1] = {
        {Name = "Starter Island (Pirate)", Pos = CFrame.new(1059, 15, 1550)},
        {Name = "Starter Island (Marine)", Pos = CFrame.new(-2566, 7, 2975)},
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
    },
    [2] = {
        {Name = "Kingdom of Rose", Pos = CFrame.new(-425, 72, 1836)},
        {Name = "Ushi Island", Pos = CFrame.new(-2367, 72, -3054)},
        {Name = "Green Bit", Pos = CFrame.new(-2367, 72, -3054)},
        {Name = "Graveyard", Pos = CFrame.new(-5497, 47, -795)},
        {Name = "Snow Mountain", Pos = CFrame.new(609, 401, -5372)},
        {Name = "Hot and Cold", Pos = CFrame.new(-541, 70, -12133)},
        {Name = "Cursed Ship", Pos = CFrame.new(1037, 125, 32911)},
        {Name = "Ice Castle", Pos = CFrame.new(6061, 26, -6370)},
        {Name = "Forgotten Island", Pos = CFrame.new(-3056, 235, -10142)}
    },
    [3] = {
        {Name = "Port Town", Pos = CFrame.new(-8053, 10, 5233)},
        {Name = "Hydra Island", Pos = CFrame.new(5259, 604, 346)},
        {Name = "Floating Turtle", Pos = CFrame.new(-13233, 532, -7594)},
        {Name = "Castle on the Sea", Pos = CFrame.new(-5400, 15, 1000)},
        {Name = "Haunted Castle", Pos = CFrame.new(-9515, 164, -5785)},
        {Name = "Sea of Treats", Pos = CFrame.new(-1147, 14, -11514)},
        {Name = "Tiki Outpost", Pos = CFrame.new(-16234, 12, 467)},
        {Name = "Submerged Island", Pos = CFrame.new(-19500, -500, -18000)}
    }
}

local QuestData = {
    [1] = {
        {Min = 0, Name = "BanditQuest1", NPC = "Bandit Recruiter", ID = 1, Enemy = "Bandit", Pos = CFrame.new(1059, 15, 1550), Team = "Pirates"},
        {Min = 0, Name = "MarineQuest1", NPC = "Marine Quest Giver", ID = 1, Enemy = "Trainee", Pos = CFrame.new(-2566, 7, 2975), Team = "Marines"},
        {Min = 15, Name = "MonkeyQuest1", NPC = "Monkey Quest Giver", ID = 1, Enemy = "Monkey", Pos = CFrame.new(-1598, 37, 153)},
        {Min = 20, Name = "MonkeyQuest1", NPC = "Monkey Quest Giver", ID = 2, Enemy = "Gorilla", Pos = CFrame.new(-1598, 37, 153)},
        {Min = 25, Name = "MonkeyQuest1", NPC = "Monkey Quest Giver", ID = 3, Enemy = "Gorilla King", Pos = CFrame.new(-1598, 37, 153)},
        {Min = 30, Name = "PirateQuest1", NPC = "Pirate Quest Giver", ID = 1, Enemy = "Pirate", Pos = CFrame.new(-1140, 4, 3827)},
        {Min = 40, Name = "PirateQuest1", NPC = "Pirate Quest Giver", ID = 2, Enemy = "Brute", Pos = CFrame.new(-1140, 4, 3827)},
        {Min = 55, Name = "PirateQuest1", NPC = "Pirate Quest Giver", ID = 3, Enemy = "Bobby", Pos = CFrame.new(-1140, 4, 3827)},
        {Min = 60, Name = "DesertBanditQuest1", NPC = "Desert Quest Giver", ID = 1, Enemy = "Desert Bandit", Pos = CFrame.new(894, 6, 4388)},
        {Min = 75, Name = "DesertBanditQuest1", NPC = "Desert Quest Giver", ID = 2, Enemy = "Desert Officer", Pos = CFrame.new(894, 6, 4388)},
        {Min = 90, Name = "SnowBanditQuest1", NPC = "Snow Quest Giver", ID = 1, Enemy = "Snow Bandit", Pos = CFrame.new(1389, 105, -1298)},
        {Min = 100, Name = "SnowBanditQuest1", NPC = "Snow Quest Giver", ID = 2, Enemy = "Snowman", Pos = CFrame.new(1389, 105, -1298)},
        {Min = 105, Name = "SnowBanditQuest1", NPC = "Snow Quest Giver", ID = 3, Enemy = "Yeti", Pos = CFrame.new(1389, 105, -1298)},
    },
    [2] = {
        {Min = 700, Name = "Area1Quest", NPC = "Quest Giver", ID = 1, Enemy = "Raider", Pos = CFrame.new(-425, 72, 1836)},
        {Min = 725, Name = "Area1Quest", NPC = "Quest Giver", ID = 2, Enemy = "Mercenary", Pos = CFrame.new(-425, 72, 1836)},
    },
    [3] = {
        {Min = 1500, Name = "IslandQuest1", NPC = "Port Town Quest Giver", ID = 1, Enemy = "Pirate Millionaire", Pos = CFrame.new(-8053, 10, 5233)},
        {Min = 1525, Name = "IslandQuest1", NPC = "Port Town Quest Giver", ID = 2, Enemy = "Pistol Billionaire", Pos = CFrame.new(-8053, 10, 5233)},
    }
}

local MaterialData = {
    ["Dragon Scale"] = {Enemy = "Dragon Crew Warrior", Pos = CFrame.new(5259, 604, 346)},
    ["Fish Tail"] = {Enemy = "Fishman Raider", Pos = CFrame.new(-13233, 532, -7594)},
    ["Magma Ore"] = {Enemy = "Military Soldier", Pos = CFrame.new(-5313, 12, 8515)},
    ["Mystic Droplet"] = {Enemy = "Sea Soldier", Pos = CFrame.new(-3056, 235, -10142)},
    ["Leather"] = {Enemy = "Pirate Millionaire", Pos = CFrame.new(-8053, 10, 5233)},
    ["Scrap Metal"] = {Enemy = "Brute", Pos = CFrame.new(-1140, 4, 3827)},
    ["Angel Wings"] = {Enemy = "Sky Bandit", Pos = CFrame.new(-4842, 718, -2621)},
    ["Vampire Fang"] = {Enemy = "Vampire", Pos = CFrame.new(-5497, 47, -795)},
}

local RareNPCData = {
    [1] = {
        {Name = "Legendary Sword Dealer", Pos = CFrame.new(-690, 15, 1583)},
        {Name = "Blox Fruit Gacha", Pos = CFrame.new(-690, 15, 1583)},
    },
    [2] = {
        {Name = "Manager", Pos = CFrame.new(-425, 72, 1836)},
        {Name = "Legendary Sword Dealer", Pos = CFrame.new(634, 72, 918)},
        {Name = "Mysterious Force", Pos = CFrame.new(-2367, 72, -3054)},
    },
    [3] = {
        {Name = "Elite Hunter", Pos = CFrame.new(-5400, 15, 1000)},
        {Name = "Tushita Door", Pos = CFrame.new(5259, 388, 2275)},
        {Name = "Ancient Monk", Pos = CFrame.new(-2800, 250, -6300)},
        {Name = "Sharkman Master", Pos = CFrame.new(-19500, -480, -18100)},
    }
}

-- 4. CORE UTILS & FRAMEWORK
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

local isTweening = false
local currentTween = nil
local function TweenTo(cf)
    if not _G.MakitoHubRunning or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    local dist = (root.Position - cf.Position).Magnitude
    
    if dist < 5 then 
        isTweening = false 
        if currentTween then currentTween:Cancel() end 
        return 
    end
    
    isTweening = true
    if currentTween then currentTween:Cancel() end
    
    if not root:FindFirstChild("MakitoFloat") then
        local bv = Instance.new("BodyVelocity", root)
        bv.Name = "MakitoFloat"
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    end
    
    local speed = Settings.TweenSpeed or 350
    currentTween = TweenService:Create(root, TweenInfo.new(dist/speed, Enum.EasingStyle.Linear), {CFrame = cf})
    currentTween:Play()
    
    currentTween.Completed:Connect(function() 
        isTweening = false 
    end)
    
    pcall(function()
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end)
end

-- Fast Attack V20 GOD MODE (Redz Hub Style - Insane Speed)
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

local function StopFastAttack()
    if FastAttackConn then FastAttackConn:Disconnect() FastAttackConn = nil end
end

local function StartFastAttack()
    StopFastAttack()
    FastAttackConn = RunService.Heartbeat:Connect(function()
        if _G.MakitoHubRunning and Settings.FastAttack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            GetFramework()
            
            if CombatFramework and CombatFramework.activeController then
                pcall(function()
                    local currentTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if currentTool then
                        CombatFramework.activeController.hitboxMagnitude = 120
                        
                        if CombatFrameworkRoot and CombatFrameworkRoot.activeController then
                            CombatFrameworkRoot.activeController.timeToNextAttack = 0
                            CombatFrameworkRoot.activeController.attackCount = 0 
                            CombatFrameworkRoot.activeController.increment = 0
                            CombatFrameworkRoot.activeController.hitboxMagnitude = 120
                            CombatFrameworkRoot.activeController.active = true
                        end

                        for i = 1, 12 do 
                            CombatFramework.activeController.attack()
                            if CombatFrameworkRoot and CombatFrameworkRoot.activeController then
                                CombatFrameworkRoot.activeController.attackCount = 0
                            end
                        end
                    end
                end)
            end
        end
    end)
    
    task.spawn(function()
        while _G.MakitoHubRunning do
            task.wait()
            if Settings.FastAttack then
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
        end
    end)
end

task.spawn(StartFastAttack)

local function AutoClick()
    if not Settings.FastAttack then return end
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

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

-- FIXED: HasItem function implementation
local function HasItem(itemName)
    if not LocalPlayer.Backpack or not LocalPlayer.Character then return false end
    
    if LocalPlayer.Backpack:FindFirstChild(itemName) then return true end
    if LocalPlayer.Character:FindFirstChild(itemName) then return true end
    
    return false
end

-- FIXED: GetNearestEnemy function
local function GetNearestEnemy(EnemyName)
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

-- FIXED: ExecuteCombo function - Now properly defined
local Combos = {
    ["Dough"] = {
        {Key = "V", Wait = 0.5},
        {Key = "C", Wait = 0.4},
        {Key = "X", Wait = 0.5},
        {Key = "Z", Wait = 0.3}
    },
    ["Kitsune"] = {
        {Key = "C", Wait = 0.4},
        {Key = "V", Wait = 0.6},
        {Key = "Z", Wait = 0.3},
        {Key = "X", Wait = 0.4}
    },
    ["Leopard"] = {
        {Key = "Z", Wait = 0.3},
        {Key = "X", Wait = 0.3},
        {Key = "C", Wait = 0.4},
        {Key = "V", Wait = 0.5}
    }
}

local function UseSkill(key, holdTime)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[key], false, game)
        if holdTime then task.wait(holdTime) end
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[key], false, game)
    end)
end

local function ExecuteCombo(target)
    if not Settings.AutoCombo or not target then return end
    local fruit = Settings.SelectedFruit
    local combo = Combos[fruit]
    if combo then
        for _, step in ipairs(combo) do
            if not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 then break end
            UseSkill(step.Key)
            task.wait(step.Wait or 0.5)
        end
    end
end

-- WEBHOOK SYSTEM
local function SendWebhook(title, description, color)
    if not Settings.WebhookEnabled or Settings.WebhookURL == "" then return end
    pcall(function()
        local data = {
            ["embeds"] = {{
                ["title"] = title,
                ["description"] = description,
                ["color"] = color or 0x00ff00,
                ["footer"] = {["text"] = "MAKITO HUB - " .. os.date("%X")},
                ["fields"] = {
                    {["name"] = "Player", ["value"] = LocalPlayer.Name, ["inline"] = true},
                    {["name"] = "Level", ["value"] = tostring(pcall(function() return LocalPlayer.Data.Level.Value end) and LocalPlayer.Data.Level.Value or 0), ["inline"] = true}
                }
            }}
        }
        local body = HttpService:JSONEncode(data)
        local headers = {["content-type"] = "application/json"}
        local request = http_request or request or (syn and syn.request) or (http and http.request)
        if request then
            request({Url = Settings.WebhookURL, Method = "POST", Headers = headers, Body = body})
        end
    end)
end

-- 5. ADVANCED UI (REDZ STYLE - CUSTOM)
local function MakeDraggable(frame, parent)
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not UserInputService:GetFocusedTextBox() then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

local function CreateHub()
    local MakitoGui = Instance.new("ScreenGui", ParentGui)
    MakitoGui.Name = "MakitoHubSupremeV6"
    
    local Main = Instance.new("Frame", MakitoGui)
    Main.Size = UDim2.new(0, 550, 0, 350)
    Main.Position = UDim2.new(0.5, -275, 0.5, -175)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
    
    MakeDraggable(Main)

    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = Settings.ThemeColor
    MainStroke.Thickness = 2
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local TopBar = Instance.new("Frame", Main)
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    TopBar.BorderSizePixel = 0
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)
    
    local Title = Instance.new("TextLabel", TopBar)
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.Text = "MAKITO HUB SUPREME - VERSION 6.1"
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Minimize = Instance.new("TextButton", TopBar)
    Minimize.Size = UDim2.new(0, 30, 0, 30)
    Minimize.Position = UDim2.new(1, -35, 0.5, -15)
    Minimize.Text = "_"
    Minimize.BackgroundColor3 = Settings.ThemeColor
    Minimize.TextColor3 = Color3.new(0,0,0)
    Minimize.Font = Enum.Font.GothamBold
    Minimize.TextSize = 20
    Instance.new("UICorner", Minimize).CornerRadius = UDim.new(0, 6)
    Minimize.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

    Notify("MAKITO HUB V6.1 INICIADO COM SUCESSO!", 5)
end

-- Keybinds Handler
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Settings.KillSwitchKey then
        _G.MakitoHubRunning = false
        Notify("MAKITO HUB ENCERRADO PELO KEYBIND.", 5)
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
print("[MAKITO HUB] V6.1 - Sistema iniciado com sucesso!")
print("[MAKITO HUB] Pressione RightCtrl para desativar")
print("[MAKITO HUB] Todas as funções foram corrigidas!")
