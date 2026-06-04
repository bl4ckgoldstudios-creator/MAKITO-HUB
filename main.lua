--[[
    MAKITO HUB - Blox Fruits Edition
    Version: 6.0 (SUPREME GOD MODE - 2000+ LINES RECONSTRUCTION)
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
    AutoFarm = false, FastAttack = false, AutoQuest = false, AutoNextSea = false, Weapon = "Melee", Distance = 10, TweenSpeed = 350, BringMobs = false, AutoFarmNearest = false,
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
    AutoDungeon = false,
    SelectedRaid = "Flame",
    -- PvP Settings
    SafeMode = true, AimAssist = false, AutoCombo = false, SelectedFruit = "Dough", PredictMovement = true, SelectedPlayer = "None", AutoBounty = false,
    BountyThreshold = 20, -- HP percentage to attack
    BountyHop = false, -- Server hop after kill
    KillAura = false, KillAuraDistance = 60, AttackAura = false, WalkOnWater = false, InfGeppo = true, FlyHack = false,
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
        {Name = "Submerged Island", Pos = CFrame.new(-19500, -500, -18000)} -- Estimated submerged position
    }
}

local QuestData = {
    [1] = { -- First Sea
        -- Pirate Starter
        {Min = 0, Name = "BanditQuest1", NPC = "Bandit Recruiter", ID = 1, Enemy = "Bandit", Pos = CFrame.new(1059, 15, 1550), Team = "Pirates"},
        -- Marine Starter
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
        {Min = 120, Name = "MarineQuest1", NPC = "Marine Quest Giver", ID = 1, Enemy = "Chief Petty Officer", Pos = CFrame.new(-2440, 19, 3065)},
        {Min = 130, Name = "MarineQuest1", NPC = "Marine Quest Giver", ID = 2, Enemy = "Vice Admiral", Pos = CFrame.new(-2440, 19, 3065)},
        {Min = 150, Name = "SkyQuest", NPC = "Sky Quest Giver", ID = 1, Enemy = "Sky Bandit", Pos = CFrame.new(-4842, 718, -2621)},
        {Min = 175, Name = "SkyQuest", NPC = "Sky Quest Giver", ID = 2, Enemy = "Dark Steward", Pos = CFrame.new(-4842, 718, -2621)},
        {Min = 190, Name = "PrisonQuest1", NPC = "Prison Quest Giver", ID = 1, Enemy = "Prisoner", Pos = CFrame.new(4875, 5, 749)},
        {Min = 210, Name = "PrisonQuest1", NPC = "Prison Quest Giver", ID = 2, Enemy = "Dangerous Prisoner", Pos = CFrame.new(4875, 5, 749)},
        {Min = 225, Name = "ColosseumQuest1", NPC = "Colosseum Quest Giver", ID = 1, Enemy = "Toga Warrior", Pos = CFrame.new(-1580, 7, -2980)},
        {Min = 250, Name = "ColosseumQuest1", NPC = "Colosseum Quest Giver", ID = 2, Enemy = "Gladiator", Pos = CFrame.new(-1580, 7, -2980)},
        {Min = 300, Name = "MagmaQuest", NPC = "Magma Quest Giver", ID = 1, Enemy = "Military Soldier", Pos = CFrame.new(-5313, 12, 8515)},
        {Min = 330, Name = "MagmaQuest", NPC = "Magma Quest Giver", ID = 2, Enemy = "Military Spy", Pos = CFrame.new(-5313, 12, 8515)},
        {Min = 350, Name = "MagmaQuest", NPC = "Magma Quest Giver", ID = 3, Enemy = "Magma Admiral", Pos = CFrame.new(-5313, 12, 8515)},
        {Min = 375, Name = "FishmanQuest", NPC = "Fishman Quest Giver", ID = 1, Enemy = "Fishman Warrior", Pos = CFrame.new(61122, 18, 1565)},
        {Min = 400, Name = "FishmanQuest", NPC = "Fishman Quest Giver", ID = 2, Enemy = "Fishman Commando", Pos = CFrame.new(61122, 18, 1565)},
        {Min = 425, Name = "FishmanQuest", NPC = "Fishman Quest Giver", ID = 3, Enemy = "Fishman Lord", Pos = CFrame.new(61122, 18, 1565)},
        {Min = 450, Name = "UpperSkyQuest1", NPC = "Mole", ID = 1, Enemy = "God's Guard", Pos = CFrame.new(-4560, 920, -1880)},
        {Min = 475, Name = "UpperSkyQuest1", NPC = "Mole", ID = 2, Enemy = "Shandia", Pos = CFrame.new(-4560, 920, -1880)},
        {Min = 525, Name = "UpperSkyQuest2", NPC = "Mole", ID = 1, Enemy = "Royal Squad", Pos = CFrame.new(-4950, 5600, -2150)},
        {Min = 550, Name = "UpperSkyQuest2", NPC = "Mole", ID = 2, Enemy = "Whisper", Pos = CFrame.new(-4950, 5600, -2150)},
        {Min = 575, Name = "UpperSkyQuest2", NPC = "Mole", ID = 3, Enemy = "Thunder God", Pos = CFrame.new(-4950, 5600, -2150)},
        {Min = 625, Name = "CyborgQuest1", NPC = "Cyborg Quest Giver", ID = 1, Enemy = "Galley Pirate", Pos = CFrame.new(6110, 10, 1450)},
        {Min = 650, Name = "CyborgQuest1", NPC = "Cyborg Quest Giver", ID = 2, Enemy = "Galley Captain", Pos = CFrame.new(6110, 10, 1450)},
        {Min = 675, Name = "CyborgQuest1", NPC = "Cyborg Quest Giver", ID = 3, Enemy = "Cyborg", Pos = CFrame.new(6110, 10, 1450)},
        -- Sea 1 Sub-Quests & Bosses
        {Min = 0, Name = "SaberExpert", NPC = "Saber Expert", ID = 0, Enemy = "Saber Expert", Pos = CFrame.new(-1461, 30, -51)},
        {Min = 0, Name = "Greybeard", NPC = "Greybeard", ID = 0, Enemy = "Greybeard", Pos = CFrame.new(-4800, 20, 4300)},
        {Min = 0, Name = "TheSaw", NPC = "The Saw", ID = 0, Enemy = "The Saw", Pos = CFrame.new(-1100, 15, 3900)},
        {Min = 0, Name = "Arlong", NPC = "Arlong", ID = 0, Enemy = "Arlong", Pos = CFrame.new(-1100, 15, 3900)},
        {Min = 0, Name = "Buggy", NPC = "Buggy", ID = 0, Enemy = "Buggy", Pos = CFrame.new(-1100, 15, 3900)},
        {Min = 0, Name = "Yeti", NPC = "Yeti", ID = 0, Enemy = "Yeti", Pos = CFrame.new(1147, 6, -1157)},
        {Min = 0, Name = "Shanks", NPC = "Shanks", ID = 0, Enemy = "Saber Expert", Pos = CFrame.new(-1450, 30, -50)},
        {Min = 0, Name = "Whisper", NPC = "Whisper", ID = 0, Enemy = "Whisper", Pos = CFrame.new(-4650, 920, -1850)},
        {Min = 0, Name = "ThunderGod", NPC = "Thunder God", ID = 0, Enemy = "Thunder God", Pos = CFrame.new(-5200, 5600, -2150)},
        {Min = 0, Name = "Cyborg", NPC = "Cyborg", ID = 0, Enemy = "Cyborg", Pos = CFrame.new(6130, 10, 1450)}
    },
    [2] = { -- Second Sea
        {Min = 700, Name = "Area1Quest", NPC = "Quest Giver", ID = 1, Enemy = "Raider", Pos = CFrame.new(-425, 72, 1836)},
        {Min = 725, Name = "Area1Quest", NPC = "Quest Giver", ID = 2, Enemy = "Mercenary", Pos = CFrame.new(-425, 72, 1836)},
        {Min = 775, Name = "Area2Quest", NPC = "Quest Giver", ID = 1, Enemy = "Swan Pirate", Pos = CFrame.new(634, 72, 918)},
        {Min = 800, Name = "Area2Quest", NPC = "Quest Giver", ID = 2, Enemy = "Factory Staff", Pos = CFrame.new(634, 72, 918)},
        {Min = 850, Name = "Area2Quest", NPC = "Quest Giver", ID = 3, Enemy = "Jeremy", Pos = CFrame.new(634, 72, 918)},
        {Min = 875, Name = "GreenZoneQuest", NPC = "Green Zone Quest Giver", ID = 1, Enemy = "Marine Soldier", Pos = CFrame.new(-2367, 72, -3054)},
        {Min = 900, Name = "GreenZoneQuest", NPC = "Green Zone Quest Giver", ID = 2, Enemy = "Marine Captain", Pos = CFrame.new(-2367, 72, -3054)},
        {Min = 925, Name = "GreenZoneQuest", NPC = "Green Zone Quest Giver", ID = 3, Enemy = "Fajita", Pos = CFrame.new(-2367, 72, -3054)},
        {Min = 950, Name = "ZombieQuest", NPC = "Graveyard Quest Giver", ID = 1, Enemy = "Zombie", Pos = CFrame.new(-5497, 47, -795)},
        {Min = 975, Name = "ZombieQuest", NPC = "Graveyard Quest Giver", ID = 2, Enemy = "Vampire", Pos = CFrame.new(-5497, 47, -795)},
        {Min = 1000, Name = "SnowMountainQuest", NPC = "Snow Mountain Quest Giver", ID = 1, Enemy = "Snow Trooper", Pos = CFrame.new(609, 401, -5372)},
        {Min = 1025, Name = "SnowMountainQuest", NPC = "Snow Mountain Quest Giver", ID = 2, Enemy = "Winter Warrior", Pos = CFrame.new(609, 401, -5372)},
        {Min = 1100, Name = "PunkQuest", NPC = "Punk Quest Giver", ID = 1, Enemy = "Lab Grunt", Pos = CFrame.new(-3056, 235, -10142)},
        {Min = 1125, Name = "PunkQuest", NPC = "Punk Quest Giver", ID = 2, Enemy = "Horned Warrior", Pos = CFrame.new(-3056, 235, -10142)},
        {Min = 1150, Name = "PunkQuest", NPC = "Punk Quest Giver", ID = 3, Enemy = "Magma Ninja", Pos = CFrame.new(-3056, 235, -10142)},
        {Min = 1175, Name = "PunkQuest", NPC = "Punk Quest Giver", ID = 4, Enemy = "Lava Pirate", Pos = CFrame.new(-3056, 235, -10142)},
        {Min = 1250, Name = "ShipQuest1", NPC = "Ship Quest Giver", ID = 1, Enemy = "Ship Officer", Pos = CFrame.new(1037, 125, 32911)},
        {Min = 1275, Name = "ShipQuest1", NPC = "Ship Quest Giver", ID = 2, Enemy = "Ship Engineer", Pos = CFrame.new(1037, 125, 32911)},
        {Min = 1300, Name = "ShipQuest2", NPC = "Ship Quest Giver", ID = 1, Enemy = "Ship Steward", Pos = CFrame.new(1037, 125, 32911)},
        {Min = 1325, Name = "ShipQuest2", NPC = "Ship Quest Giver", ID = 2, Enemy = "Cursed Captain", Pos = CFrame.new(1037, 125, 32911)},
        {Min = 1350, Name = "IceCastleQuest", NPC = "Ice Castle Quest Giver", ID = 1, Enemy = "Arctic Warrior", Pos = CFrame.new(6061, 26, -6370)},
        {Min = 1375, Name = "IceCastleQuest", NPC = "Ice Castle Quest Giver", ID = 2, Enemy = "Snow Lurker", Pos = CFrame.new(6061, 26, -6370)},
        {Min = 1400, Name = "IceCastleQuest", NPC = "Ice Castle Quest Giver", ID = 3, Enemy = "Awakened Ice Admiral", Pos = CFrame.new(6061, 26, -6370)},
        {Min = 1425, Name = "ForgottenQuest", NPC = "Forgotten Quest Giver", ID = 1, Enemy = "Sea Soldier", Pos = CFrame.new(-3056, 235, -10142)},
        {Min = 1450, Name = "ForgottenQuest", NPC = "Forgotten Quest Giver", ID = 2, Enemy = "Water Scout", Pos = CFrame.new(-3056, 235, -10142)},
        {Min = 1475, Name = "ForgottenQuest", NPC = "Forgotten Quest Giver", ID = 3, Enemy = "Tide Keeper", Pos = CFrame.new(-3056, 235, -10142)},
        -- Sea 2 Sub-Quests & Bosses
        {Min = 0, Name = "DonSwan", NPC = "Don Swan", ID = 0, Enemy = "Don Swan", Pos = CFrame.new(2289, 15, 800)},
        {Min = 0, Name = "CursedCaptain", NPC = "Cursed Captain", ID = 0, Enemy = "Cursed Captain", Pos = CFrame.new(900, 125, 33000)},
        {Min = 0, Name = "Darkbeard", NPC = "Darkbeard", ID = 0, Enemy = "Darkbeard", Pos = CFrame.new(3700, 15, -3500)},
        {Min = 0, Name = "Fajita", NPC = "Fajita", ID = 0, Enemy = "Fajita", Pos = CFrame.new(-2367, 72, -3054)},
        {Min = 0, Name = "Jeremy", NPC = "Jeremy", ID = 0, Enemy = "Jeremy", Pos = CFrame.new(2100, 450, 800)},
        {Min = 0, Name = "Diamond", NPC = "Diamond", ID = 0, Enemy = "Diamond", Pos = CFrame.new(-1550, 100, 100)},
        {Min = 0, Name = "TideKeeper", NPC = "Tide Keeper", ID = 0, Enemy = "Tide Keeper", Pos = CFrame.new(-3500, 10, -10500)},
        {Min = 0, Name = "IceAdmiral", NPC = "Awakened Ice Admiral", ID = 0, Enemy = "Awakened Ice Admiral", Pos = CFrame.new(6470, 30, -6260)}
    },
    [3] = { -- Third Sea
        {Min = 1500, Name = "IslandQuest1", NPC = "Port Town Quest Giver", ID = 1, Enemy = "Pirate Millionaire", Pos = CFrame.new(-8053, 10, 5233)},
        {Min = 1525, Name = "IslandQuest1", NPC = "Port Town Quest Giver", ID = 2, Enemy = "Pistol Billionaire", Pos = CFrame.new(-8053, 10, 5233)},
        {Min = 1575, Name = "HydraQuest1", NPC = "Hydra Island Quest Giver", ID = 1, Enemy = "Dragon Crew Warrior", Pos = CFrame.new(5259, 604, 346)},
        {Min = 1600, Name = "HydraQuest1", NPC = "Hydra Island Quest Giver", ID = 2, Enemy = "Dragon Crew Archer", Pos = CFrame.new(5259, 604, 346)},
        {Min = 1625, Name = "HydraQuest1", NPC = "Hydra Island Quest Giver", ID = 3, Enemy = "Female Island Soldier", Pos = CFrame.new(5259, 604, 346)},
        {Min = 1700, Name = "MarineTreeQuest", NPC = "Great Tree Quest Giver", ID = 1, Enemy = "Marine Commodore", Pos = CFrame.new(2200, 15, -7000)},
        {Min = 1725, Name = "MarineTreeQuest", NPC = "Great Tree Quest Giver", ID = 2, Enemy = "Rear Admiral", Pos = CFrame.new(2200, 15, -7000)},
        {Min = 1775, Name = "TurtleQuest1", NPC = "Floating Turtle Quest Giver 1", ID = 1, Enemy = "Fishman Raider", Pos = CFrame.new(-13233, 532, -7594)},
        {Min = 1800, Name = "TurtleQuest1", NPC = "Floating Turtle Quest Giver 1", ID = 2, Enemy = "Fishman Captain", Pos = CFrame.new(-13233, 532, -7594)},
        {Min = 1825, Name = "TurtleQuest1", NPC = "Floating Turtle Quest Giver 1", ID = 3, Enemy = "Forest Elf", Pos = CFrame.new(-13233, 532, -7594)},
        {Min = 1850, Name = "TurtleQuest2", NPC = "Floating Turtle Quest Giver 2", ID = 1, Enemy = "Marine Captain", Pos = CFrame.new(-13233, 532, -7594)},
        {Min = 1900, Name = "TurtleQuest2", NPC = "Floating Turtle Quest Giver 2", ID = 2, Enemy = "Beautiful Pirate", Pos = CFrame.new(-13233, 532, -7594)},
        {Min = 1975, Name = "HauntedQuest1", NPC = "Haunted Quest Giver", ID = 1, Enemy = "Reanimated Zombie", Pos = CFrame.new(-9515, 164, -5785)},
        {Min = 2000, Name = "HauntedQuest1", NPC = "Haunted Quest Giver", ID = 2, Enemy = "Demonic Soul", Pos = CFrame.new(-9515, 164, -5785)},
        {Min = 2025, Name = "HauntedQuest1", NPC = "Haunted Quest Giver", ID = 3, Enemy = "Possessed Mummy", Pos = CFrame.new(-9515, 164, -5785)},
        {Min = 2075, Name = "CandyQuest1", NPC = "Candy Quest Giver", ID = 1, Enemy = "Candy Rebel", Pos = CFrame.new(-1147, 14, -11514)},
        {Min = 2100, Name = "CandyQuest1", NPC = "Candy Quest Giver", ID = 2, Enemy = "Sweet Scout", Pos = CFrame.new(-1147, 14, -11514)},
        {Min = 2125, Name = "CandyQuest1", NPC = "Candy Quest Giver", ID = 3, Enemy = "Cookie Warrior", Pos = CFrame.new(-1147, 14, -11514)},
        {Min = 2150, Name = "CandyQuest1", NPC = "Candy Quest Giver", ID = 4, Enemy = "Cake Guard", Pos = CFrame.new(-1147, 14, -11514)},
        {Min = 2175, Name = "CandyQuest1", NPC = "Candy Quest Giver", ID = 5, Enemy = "Baking Soldier", Pos = CFrame.new(-1147, 14, -11514)},
        {Min = 2225, Name = "ChocolateQuest1", NPC = "Quest Giver", ID = 1, Enemy = "Cocoa Warrior", Pos = CFrame.new(-541, 70, -12133)},
        {Min = 2250, Name = "ChocolateQuest1", NPC = "Quest Giver", ID = 2, Enemy = "Chocolate Baron", Pos = CFrame.new(-541, 70, -12133)},
        {Min = 2275, Name = "CandyQuest1", NPC = "Candy Quest Giver", ID = 6, Enemy = "Sweet Thief", Pos = CFrame.new(-1147, 14, -11514)},
        {Min = 2300, Name = "ChocolateQuest1", NPC = "Quest Giver", ID = 1, Enemy = "Cookie Pirate", Pos = CFrame.new(-541, 70, -12133)},
        {Min = 2325, Name = "ChocolateQuest1", NPC = "Quest Giver", ID = 2, Enemy = "Cake Guard", Pos = CFrame.new(-541, 70, -12133)},
        {Min = 2350, Name = "ChocolateQuest1", NPC = "Quest Giver", ID = 3, Enemy = "Baking Staff", Pos = CFrame.new(-541, 70, -12133)},
        {Min = 2375, Name = "ChocolateQuest2", NPC = "Quest Giver", ID = 1, Enemy = "Cocoa Warrior", Pos = CFrame.new(-541, 70, -12133)},
        {Min = 2400, Name = "ChocolateQuest2", NPC = "Quest Giver", ID = 2, Enemy = "Chocolate Baron", Pos = CFrame.new(-541, 70, -12133)},
        {Min = 2425, Name = "ChocolateQuest2", NPC = "Quest Giver", ID = 3, Enemy = "Sweet Thief", Pos = CFrame.new(-541, 70, -12133)},
        -- Tiki Outpost (Sea 3)
        {Min = 2450, Name = "TikiQuest1", NPC = "Tiki Quest Giver 1", ID = 1, Enemy = "Isle Outlaw", Pos = CFrame.new(-16234, 12, 467), EnemyPos = CFrame.new(-16450, 45, 650)},
        {Min = 2475, Name = "TikiQuest1", NPC = "Tiki Quest Giver 1", ID = 2, Enemy = "Island Sailor", Pos = CFrame.new(-16234, 12, 467), EnemyPos = CFrame.new(-16600, 45, 300)},
        {Min = 2500, Name = "TikiQuest2", NPC = "Tiki Quest Giver 2", ID = 1, Enemy = "Sun-kissed Warrior", Pos = CFrame.new(-16234, 12, 467), EnemyPos = CFrame.new(-16450, 45, 650)},
        {Min = 2525, Name = "TikiQuest2", NPC = "Tiki Quest Giver 2", ID = 2, Enemy = "Island Champion", Pos = CFrame.new(-16234, 12, 467), EnemyPos = CFrame.new(-16800, 45, 550)},
        {Min = 2550, Name = "TikiQuest3", NPC = "Tiki Quest Giver 3", ID = 1, Enemy = "Serpent Hunter", Pos = CFrame.new(-16234, 12, 467), EnemyPos = CFrame.new(-16600, 45, 300)},
        {Min = 2575, Name = "TikiQuest3", NPC = "Tiki Quest Giver 3", ID = 2, Enemy = "Skull Slayer", Pos = CFrame.new(-16234, 12, 467), EnemyPos = CFrame.new(-16450, 45, 650)},
        -- Submerged Island (Lv 2600 - 2800)
        {Min = 2600, Name = "SubmergedQuest1", NPC = "Submerged Quest Giver", ID = 1, Enemy = "Reef Bandit", Pos = CFrame.new(-19500, -500, -18000), EnemyPos = CFrame.new(-19500, -500, -18500)},
        {Min = 2625, Name = "SubmergedQuest1", NPC = "Submerged Quest Giver", ID = 2, Enemy = "Coral Pirate", Pos = CFrame.new(-19500, -500, -18000), EnemyPos = CFrame.new(-19700, -500, -18700)},
        {Min = 2675, Name = "SubmergedQuest2", NPC = "Submerged Quest Giver", ID = 1, Enemy = "Sea Chanter", Pos = CFrame.new(-19800, -500, -18200), EnemyPos = CFrame.new(-19900, -500, -18900)},
        {Min = 2700, Name = "SubmergedQuest2", NPC = "Submerged Quest Giver", ID = 2, Enemy = "Ocean Prophet", Pos = CFrame.new(-19800, -500, -18200), EnemyPos = CFrame.new(-20100, -500, -19100)},
        {Min = 2750, Name = "SubmergedQuest3", NPC = "Submerged Quest Giver", ID = 1, Enemy = "High Disciple", Pos = CFrame.new(-20100, -500, -18400), EnemyPos = CFrame.new(-20300, -500, -19300)},
        {Min = 2775, Name = "SubmergedQuest3", NPC = "Submerged Quest Giver", ID = 2, Enemy = "Grand Devotee", Pos = CFrame.new(-20100, -500, -18400), EnemyPos = CFrame.new(-20500, -500, -19500)},
        -- Sea 3 Sub-Quests & Bosses
        {Min = 0, Name = "IndraBoss", NPC = "Rip_Indra", ID = 0, Enemy = "Rip_Indra", Pos = CFrame.new(-5400, 15, 1000)},
        {Min = 0, Name = "DoughKing", NPC = "Dough King", ID = 0, Enemy = "Dough King", Pos = CFrame.new(-800, 70, -12000)},
        {Min = 0, Name = "LeviathanBoss", NPC = "Leviathan", ID = 0, Enemy = "Leviathan", Pos = CFrame.new(-20000, 15, -20000)},
        {Min = 0, Name = "BigMom", NPC = "Big Mom", ID = 0, Enemy = "Big Mom", Pos = CFrame.new(-12000, 15, -12000)},
        {Min = 0, Name = "Stone", NPC = "Stone", ID = 0, Enemy = "Stone", Pos = CFrame.new(-1000, 15, 6000)},
        {Min = 0, Name = "BeautifulPirate", NPC = "Beautiful Pirate", ID = 0, Enemy = "Beautiful Pirate", Pos = CFrame.new(-12000, 330, -7000)},
        {Min = 0, Name = "KiloAdmiral", NPC = "Kilo Admiral", ID = 0, Enemy = "Kilo Admiral", Pos = CFrame.new(-460, 15, -11600)},
        {Min = 0, Name = "CakeQueen", NPC = "Cake Queen", ID = 0, Enemy = "Cake Queen", Pos = CFrame.new(-700, 15, -11000)},
        {Min = 0, Name = "SoulReaper", NPC = "Soul Reaper", ID = 0, Enemy = "Soul Reaper", Pos = CFrame.new(-9500, 160, -6000)}
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
    ["Gunpowder"] = {Enemy = "Marine Captain", Pos = CFrame.new(-2367, 72, -3054)},
    ["Mini Fang"] = {Enemy = "Forest Pirate", Pos = CFrame.new(-13233, 532, -7594)},
}

local RareNPCData = {
    [1] = {
        {Name = "Legendary Sword Dealer", Pos = CFrame.new(-690, 15, 1583)}, -- Spawn point check
        {Name = "Blox Fruit Gacha", Pos = CFrame.new(-690, 15, 1583)},
    },
    [2] = {
        {Name = "Manager", Pos = CFrame.new(-425, 72, 1836)},
        {Name = "Legendary Sword Dealer", Pos = CFrame.new(634, 72, 918)}, -- Spawn points
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
    
    -- Force Float during Tween to prevent falling
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
            -- Try multiple paths for CombatFramework (Update 29 compatibility)
            local framework = LocalPlayer.PlayerScripts:FindFirstChild("CombatFramework")
            if not framework then
                framework = LocalPlayer.PlayerScripts:FindFirstChild("CombatFrameworkR")
            end
            if not framework then
                -- Try in ReplicatedStorage
                framework = ReplicatedStorage:FindFirstChild("CombatFramework")
            end
            if framework then
                CombatFramework = require(framework)
            end
        end
        if CombatFramework and CombatFramework.activeController and CombatFramework.activeController.attack then
            -- Targeted Search for the internal controller table (the "Root")
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
    -- Heartbeat for maximum stability at high speeds
    FastAttackConn = RunService.Heartbeat:Connect(function()
        if _G.MakitoHubRunning and Settings.FastAttack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            GetFramework()
            
            if CombatFramework and CombatFramework.activeController then
                pcall(function()
                    -- REDZ HUB STYLE - SILENT LONG RANGE ATTACK
                    -- No clicks needed, just active when weapon is held
                    local currentTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if currentTool then
                        -- Set insane reach (120 is the sweet spot for "considerable distance")
                        CombatFramework.activeController.hitboxMagnitude = 120
                        
                        if CombatFrameworkRoot and CombatFrameworkRoot.activeController then
                            -- Instant reset of everything that causes delay or animation
                            CombatFrameworkRoot.activeController.timeToNextAttack = 0
                            CombatFrameworkRoot.activeController.attackCount = 0 
                            CombatFrameworkRoot.activeController.increment = 0
                            CombatFrameworkRoot.activeController.hitboxMagnitude = 120
                            
                            -- Force active state to allow hits without clicking
                            CombatFrameworkRoot.activeController.active = true
                        end

                        -- Attack Loop: Calls the internal attack function directly
                        -- This deals damage without triggering the "click" animation
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
    
    -- Animation Canceller (Aggressive Mode - 100% Invisible)
    task.spawn(function()
        while _G.MakitoHubRunning do
            task.wait()
            if Settings.FastAttack then
                pcall(function()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        local hum = LocalPlayer.Character.Humanoid
                        for _, anim in ipairs(hum:GetPlayingAnimationTracks()) do
                            -- Stop any animation that looks like an attack instantly
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

-- Start the Hyper Fast Attack
task.spawn(StartFastAttack)

-- KILL AURA V2 (REDZ HUB STYLE - COMBATFRAMEWORK BASED)
-- Ataca todos os inimigos próximos automaticamente sem animação
local KillAuraConn = nil

local function StopKillAura()
    if KillAuraConn then KillAuraConn:Disconnect() KillAuraConn = nil end
end

local function StartKillAura()
    StopKillAura()
    KillAuraConn = RunService.Heartbeat:Connect(function()
        if _G.MakitoHubRunning and Settings.KillAura and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            GetFramework()
            
            if CombatFramework and CombatFramework.activeController then
                pcall(function()
                    local currentTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if currentTool then
                        local myRoot = LocalPlayer.Character.HumanoidRootPart
                        local auraRange = Settings.KillAuraDistance or 60
                        
                        -- Set hitbox magnitude for long range
                        CombatFramework.activeController.hitboxMagnitude = auraRange
                        
                        if CombatFrameworkRoot and CombatFrameworkRoot.activeController then
                            CombatFrameworkRoot.activeController.timeToNextAttack = 0
                            CombatFrameworkRoot.activeController.attackCount = 0
                            CombatFrameworkRoot.activeController.increment = 0
                            CombatFrameworkRoot.activeController.hitboxMagnitude = auraRange
                            CombatFrameworkRoot.activeController.active = true
                        end

                        -- Attack all nearby enemies (players and mobs)
                        local targets = {}
                        
                        -- Check players
                        for _, v in ipairs(Players:GetPlayers()) do
                            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                                local dist = (v.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude
                                if dist <= auraRange then
                                    table.insert(targets, v.Character.HumanoidRootPart)
                                end
                            end
                        end
                        
                        -- Check mobs/enemies
                        local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
                        for _, v in ipairs(enemiesFolder:GetDescendants()) do
                            if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                local dist = (v.HumanoidRootPart.Position - myRoot.Position).Magnitude
                                if dist <= auraRange then
                                    table.insert(targets, v.HumanoidRootPart)
                                end
                            end
                        end
                        
                        -- Rapid fire attack on all targets
                        for _, target in ipairs(targets) do
                            if target and target.Parent then
                                -- Face the target
                                myRoot.CFrame = CFrame.new(myRoot.Position, target.Position)
                                
                                -- Execute multiple attacks per frame for insane DPS
                                for i = 1, 8 do
                                    CombatFramework.activeController.attack()
                                    if CombatFrameworkRoot and CombatFrameworkRoot.activeController then
                                        CombatFrameworkRoot.activeController.attackCount = 0
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)
end

-- Start Kill Aura
task.spawn(StartKillAura)

-- Animation Canceller for Kill Aura (100% Invisible)
task.spawn(function()
    while _G.MakitoHubRunning do
        task.wait()
        if Settings.KillAura then
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    local hum = LocalPlayer.Character.Humanoid
                    for _, anim in ipairs(hum:GetPlayingAnimationTracks()) do
                        -- Stop any animation that looks like an attack instantly
                        if anim.Name:lower():find("attack") or anim.Name:lower():find("slash") or anim.Name:lower():find("swing") or anim.Name:lower():find("punch") then
                            anim:Stop(0)
                        end
                    end
                end
            end)
        end
    end
end)

local function AutoClick()
    -- Clicks now handled by the Stepped connection for maximum speed
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
    
    -- Se for nível baixo e não tiver arma, tenta equipar o soco (Combat)
    local level = LocalPlayer.Data.Level.Value
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
        MakitoGui.ResetOnSpawn = false

        local Main = Instance.new("Frame", MakitoGui)
        Main.Size = UDim2.new(0, 600, 0, 400) -- Increased size for better visibility
        Main.Position = UDim2.new(0.5, -300, 0.5, -200)
        Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        Main.BorderSizePixel = 0
        Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

        MakeDraggable(Main)

        -- Gradient Background
        local MainGradient = Instance.new("UIGradient", Main)
        MainGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 20)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))
        })
        MainGradient.Rotation = 45

        local MainStroke = Instance.new("UIStroke", Main)
        MainStroke.Color = Settings.ThemeColor
        MainStroke.Thickness = 2
        MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local TopBar = Instance.new("Frame", Main)
        TopBar.Size = UDim2.new(1, 0, 0, 60)
        TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        TopBar.BorderSizePixel = 0
        Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 16)

        local Title = Instance.new("TextLabel", TopBar)
        Title.Size = UDim2.new(1, -120, 1, 0)
        Title.Position = UDim2.new(0, 20, 0, 0)
        Title.Text = "MAKITO HUB SUPREME V6.0"
        Title.TextColor3 = Settings.ThemeColor
        Title.Font = Enum.Font.GothamBold
        Title.TextSize = 20
        Title.BackgroundTransparency = 1
        Title.TextXAlignment = Enum.TextXAlignment.Left

        local SideBar = Instance.new("ScrollingFrame", Main)
        SideBar.Size = UDim2.new(0, 170, 1, -80)
        SideBar.Position = UDim2.new(0, 15, 0, 75)
        SideBar.BackgroundTransparency = 1
        SideBar.ScrollBarThickness = 0
        local SideBarLayout = Instance.new("UIListLayout", SideBar)
        SideBarLayout.Padding = UDim.new(0, 8)

        local Container = Instance.new("ScrollingFrame", Main)
        Container.Size = UDim2.new(1, -210, 1, -80)
        Container.Position = UDim2.new(0, 195, 0, 75)
        Container.BackgroundTransparency = 1
        Container.ScrollBarThickness = 4
        Container.ScrollBarImageColor3 = Settings.ThemeColor
        local ContainerLayout = Instance.new("UIListLayout", Container)
        ContainerLayout.Padding = UDim.new(0, 8)
        ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y + 20)
        end)

        -- Status Indicator
        local StatusDot = Instance.new("Frame", TopBar)
        StatusDot.Size = UDim2.new(0, 12, 0, 12)
        StatusDot.Position = UDim2.new(1, -100, 0.5, -6)
        StatusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        StatusDot.BorderSizePixel = 0
        Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1, 0)

        local StatusLabel = Instance.new("TextLabel", TopBar)
        StatusLabel.Size = UDim2.new(0, 80, 0, 20)
        StatusLabel.Position = UDim2.new(1, -85, 0.5, -10)
        StatusLabel.Text = "ONLINE"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        StatusLabel.Font = Enum.Font.GothamBold
        StatusLabel.TextSize = 12
        StatusLabel.BackgroundTransparency = 1

        local ServerLabel = Instance.new("TextLabel", TopBar)
        ServerLabel.Size = UDim2.new(0, 150, 0, 20)
        ServerLabel.Position = UDim2.new(1, -210, 0.5, -10)
        ServerLabel.Text = "FPS: -- | Ping: --ms"
        ServerLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
        ServerLabel.Font = Enum.Font.Gotham
        ServerLabel.TextSize = 11
        ServerLabel.BackgroundTransparency = 1

        task.spawn(function()
            while MakitoGui.Parent do
                local fps = math.floor(1/RunService.RenderStepped:Wait())
                local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                ServerLabel.Text = "FPS: " .. fps .. " | Ping: " .. ping .. "ms"
                task.wait(1)
            end
        end)

    local Tabs = {}
    local function NewTab(name, icon)
        local TabFrame = Instance.new("ScrollingFrame", Container)
        TabFrame.Size = UDim2.new(1, 0, 1, 0)
        TabFrame.BackgroundTransparency = 1
        TabFrame.Visible = false
        TabFrame.ScrollBarThickness = 3
        TabFrame.ScrollBarImageColor3 = Settings.ThemeColor
        TabFrame.CanvasSize = UDim2.new(0,0,0,0)
        local TabPadding = Instance.new("UIPadding", TabFrame)
        TabPadding.PaddingLeft = UDim.new(0, 5)
        TabPadding.PaddingRight = UDim.new(0, 10)
        
        local Layout = Instance.new("UIListLayout", TabFrame)
        Layout.Padding = UDim.new(0, 10)
        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
        end)
        
        local TabBtn = Instance.new("TextButton", SideBar)
        TabBtn.Size = UDim2.new(1, 0, 0, 40)
        TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        TabBtn.Text = name
        TabBtn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 14
        Instance.new("UICorner", TabBtn)
        
        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Tabs) do 
                t.Frame.Visible = false 
                t.Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
                t.Btn.TextColor3 = Color3.new(0.8,0.8,0.8) 
            end
            TabFrame.Visible = true
            TabBtn.BackgroundColor3 = Settings.ThemeColor
            TabBtn.TextColor3 = Color3.new(0,0,0)
        end)
        
        Tabs[name] = {Frame = TabFrame, Btn = TabBtn}
        return TabFrame
    end

    -- UI Components
    local function NewSection(parent, name)
        local label = Instance.new("TextLabel", parent)
        label.Size = UDim2.new(1, 0, 0, 35)
        label.Text = "   " .. name:upper()
        label.TextColor3 = Settings.ThemeColor
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
    end

    local function NewToggle(parent, name, setting, callback)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(1, 0, 0, 45)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        btn.Text = "      " .. name
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        local status = Instance.new("Frame", btn)
        status.Size = UDim2.new(0, 44, 0, 22)
        status.Position = UDim2.new(1, -55, 0.5, -11)
        status.BackgroundColor3 = Settings[setting] and Settings.ThemeColor or Color3.fromRGB(60, 60, 70)
        Instance.new("UICorner", status).CornerRadius = UDim.new(1, 0)

        local circle = Instance.new("Frame", status)
        circle.Size = UDim2.new(0, 18, 0, 18)
        circle.Position = Settings[setting] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        circle.BackgroundColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

        btn.MouseButton1Click:Connect(function()
            Settings[setting] = not Settings[setting]
            local goalPos = Settings[setting] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
            local goalCol = Settings[setting] and Settings.ThemeColor or Color3.fromRGB(60, 60, 70)
            TweenService:Create(circle, TweenInfo.new(0.3), {Position = goalPos}):Play()
            TweenService:Create(status, TweenInfo.new(0.3), {BackgroundColor3 = goalCol}):Play()
            callback(Settings[setting])
            SaveSettings()
        end)
    end

    local function NewButton(parent, name, callback)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(1, 0, 0, 42)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        btn.Text = name
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    local function NewDropdown(parent, name, options, setting, callback)
        local dFrame = Instance.new("Frame", parent)
        dFrame.Size = UDim2.new(1, 0, 0, 50)
        dFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        Instance.new("UICorner", dFrame).CornerRadius = UDim.new(0, 8)

        local label = Instance.new("TextLabel", dFrame)
        label.Size = UDim2.new(0.4, 0, 1, 0)
        label.Position = UDim2.new(0, 15, 0, 0)
        label.Text = name
        label.TextColor3 = Color3.new(1,1,1)
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left

        local btn = Instance.new("TextButton", dFrame)
        btn.Size = UDim2.new(0.5, 0, 0.7, 0)
        btn.Position = UDim2.new(0.45, 0, 0.15, 0)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        btn.Text = Settings[setting] or "Select..."
        btn.TextColor3 = Settings.ThemeColor
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local scrolling = Instance.new("ScrollingFrame", parent)
        scrolling.Size = UDim2.new(1, 0, 0, 0)
        scrolling.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        scrolling.BorderSizePixel = 0
        scrolling.Visible = false
        scrolling.ZIndex = 10
        scrolling.ScrollBarThickness = 2
        Instance.new("UICorner", scrolling).CornerRadius = UDim.new(0, 8)
        local layout = Instance.new("UIListLayout", scrolling)
        
        btn.MouseButton1Click:Connect(function()
            scrolling.Visible = not scrolling.Visible
            if scrolling.Visible then
                scrolling.Size = UDim2.new(1, 0, 0, math.min(#options * 35, 140))
            else
                scrolling.Size = UDim2.new(1, 0, 0, 0)
            end
        end)

        for _, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton", scrolling)
            optBtn.Size = UDim2.new(1, 0, 0, 30)
            optBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            optBtn.Text = opt
            optBtn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
            optBtn.Font = Enum.Font.Gotham
            optBtn.TextSize = 12
            optBtn.BorderSizePixel = 0
            
            optBtn.MouseButton1Click:Connect(function()
                Settings[setting] = opt
                btn.Text = opt
                scrolling.Visible = false
                scrolling.Size = UDim2.new(1, 0, 0, 0)
                callback(opt)
                SaveSettings()
            end)
        end
    end

    local function NewSearch(parent, placeholder, options, callback)
        local sFrame = Instance.new("Frame", parent)
        sFrame.Size = UDim2.new(1, 0, 0, 45)
        sFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        Instance.new("UICorner", sFrame)
        
        local box = Instance.new("TextBox", sFrame)
        box.Size = UDim2.new(1, -20, 1, 0)
        box.Position = UDim2.new(0, 10, 0, 0)
        box.PlaceholderText = placeholder or "Search..."
        box.Text = ""
        box.TextColor3 = Color3.new(1,1,1)
        box.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
        box.Font = Enum.Font.Gotham
        box.TextSize = 14
        box.BackgroundTransparency = 1
        
        box:GetPropertyChangedSignal("Text"):Connect(function()
            local text = box.Text:lower()
            callback(text)
        end)
    end

    local function NewSlider(parent, name, min, max, default, setting, callback)
        local sFrame = Instance.new("Frame", parent)
        sFrame.Size = UDim2.new(1, 0, 0, 65)
        sFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        Instance.new("UICorner", sFrame).CornerRadius = UDim.new(0, 8)

        local label = Instance.new("TextLabel", sFrame)
        label.Size = UDim2.new(1, -20, 0, 30)
        label.Position = UDim2.new(0, 15, 0, 5)
        label.Text = name .. ": " .. tostring(Settings[setting] or default)
        label.TextColor3 = Color3.new(1,1,1)
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left

        local bar = Instance.new("Frame", sFrame)
        bar.Size = UDim2.new(1, -40, 0, 6)
        bar.Position = UDim2.new(0, 20, 0, 45)
        bar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new((Settings[setting] or default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Settings.ThemeColor
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local circle = Instance.new("Frame", fill)
        circle.Size = UDim2.new(0, 16, 0, 16)
        circle.Position = UDim2.new(1, -8, 0.5, -8)
        circle.BackgroundColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

        local dragging = false
        local function Update(input)
            local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * pos)
            Settings[setting] = val
            label.Text = name .. ": " .. tostring(val)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            callback(val)
            SaveSettings()
        end

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                Update(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                Update(input)
            end
        end)
    end

    -- TAB: FARMING
    local FarmTab = NewTab("Auto Farm")
    NewSection(FarmTab, "Main Progression")
    NewToggle(FarmTab, "Auto Farm Level", "AutoFarm", function(v) end)
    NewToggle(FarmTab, "Auto Farm Nearest (No Quest)", "AutoFarmNearest", function(v) end)
    NewToggle(FarmTab, "Auto Quest", "AutoQuest", function(v) end)
    NewToggle(FarmTab, "Auto Next Sea", "AutoNextSea", function(v) end)
    NewToggle(FarmTab, "Bring Mobs", "BringMobs", function(v) end)
    NewSlider(FarmTab, "Farm Distance", 0, 30, 10, "Distance", function(v) end)
    NewSlider(FarmTab, "Tween Speed", 100, 500, 350, "TweenSpeed", function(v) end)
    NewDropdown(FarmTab, "Weapon", {"Melee", "Sword", "Fruit"}, "Weapon", function(v) end)
    
    NewSection(FarmTab, "Combat & Skills")
    NewToggle(FarmTab, "Auto Use Skills", "AutoSkill", function(v) end)
    NewToggle(FarmTab, "Use [Z] Skill", "SkillZ", function(v) end)
    NewToggle(FarmTab, "Use [X] Skill", "SkillX", function(v) end)
    NewToggle(FarmTab, "Use [C] Skill", "SkillC", function(v) end)
    NewToggle(FarmTab, "Use [V] Skill", "SkillV", function(v) end)

    NewSection(FarmTab, "Boss Farm")
    NewToggle(FarmTab, "Auto Farm All Bosses", "AutoBoss", function(v) end)
    NewToggle(FarmTab, "Hop if Boss not found", "AutoBossHop", function(v) end)

    NewSection(FarmTab, "Auto Mastery")
    NewToggle(FarmTab, "Auto Mastery Mode", "AutoMastery", function(v) end)
    NewDropdown(FarmTab, "Mastery Weapon", {"Sword", "Fruit", "Gun"}, "MasteryWeapon", function(v) end)
    
    NewSection(FarmTab, "Auto Stats")
    NewToggle(FarmTab, "Auto Stats", "AutoStats", function(v) end)
    NewDropdown(FarmTab, "Stat Type", {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"}, "SelectedStat", function(v) end)

    -- TAB: RAID
    local RaidTab = NewTab("Raid")
    NewSection(RaidTab, "Automation")
    NewToggle(RaidTab, "Auto Raid Level", "AutoRaid", function(v) end)
    NewToggle(RaidTab, "Auto Buy Chip", "AutoBuyChip", function(v) end)
    NewToggle(RaidTab, "Auto Next Island", "AutoNextIsland", function(v) end)
    NewToggle(RaidTab, "Auto Awaken Fruit", "AutoAwaken", function(v) end)
    
    NewSection(RaidTab, "Settings")
    NewDropdown(RaidTab, "Select Raid", {"Flame", "Ice", "Quake", "Light", "Dark", "Spider", "Rumble", "Magma", "Buddha", "Sand"}, "SelectedRaid", function(v) end)
    NewToggle(RaidTab, "Auto Dungeon Farm", "AutoDungeon", function(v) end)
    
    NewButton(RaidTab, "TP to Raid Lab", function()
        TweenTo(CFrame.new(-495, 300, -2850))
    end)

    -- TAB: COMBAT
    local CombatTab = NewTab("Combat")
    NewSection(CombatTab, "Attack Mods")
    NewToggle(CombatTab, "Fast Attack V17", "FastAttack", function(v) end)
    NewToggle(CombatTab, "Kill Aura V2 (Redz Style)", "KillAura", function(v) end)
    NewSlider(CombatTab, "Kill Aura Distance", 10, 150, 60, "KillAuraDistance", function(v) end)
    NewToggle(CombatTab, "Safe Mode (Anti-Player)", "SafeMode", function(v) end)
    NewToggle(CombatTab, "Auto Haki", "AutoHaki", function(v) end)
    NewToggle(CombatTab, "Auto Ken", "AutoKen", function(v) end)
    
    NewSection(CombatTab, "Auto Combo")
    NewToggle(CombatTab, "Enable Auto Combo", "AutoCombo", function(v) end)
    NewDropdown(CombatTab, "Select Fruit", {"Dough", "Kitsune", "Leopard"}, "SelectedFruit", function(v) end)

    NewSection(CombatTab, "Auto Bounty Hunter")
    NewToggle(CombatTab, "Enable Auto Bounty", "AutoBounty", function(v) end)
    NewToggle(CombatTab, "Server Hop after Kill", "BountyHop", function(v) end)

    NewSection(CombatTab, "Aim & Assist")
    NewToggle(CombatTab, "Aim Assist (Silent Aim)", "AimAssist", function(v) end)
    NewToggle(CombatTab, "Predict Movement", "PredictMovement", function(v) end)

    NewSection(CombatTab, "Player Hacks")
    NewToggle(CombatTab, "No Clip", "NoClip", function(v) end)
    NewToggle(CombatTab, "Fly Hack", "FlyHack", function(v) end)
    NewToggle(CombatTab, "Walk On Water", "WalkOnWater", function(v) end)
    NewToggle(CombatTab, "Infinite Geppo", "InfGeppo", function(v) end)
    NewToggle(CombatTab, "Infinite Energy", "InfEnergy", function(v) end)

    -- TAB: EVENTS
    local EventTab = NewTab("Events")
    NewSection(EventTab, "Sea Events")
    NewToggle(EventTab, "Auto Sea Events", "AutoSeaEvent", function(v) end)
    NewToggle(EventTab, "Auto Mirage Island", "AutoMirage", function(v) end)
    NewToggle(EventTab, "Auto Kitsune Wisp", "AutoKitsune", function(v) end)
    
    NewSection(EventTab, "World Events")
    NewToggle(EventTab, "Auto Factory", "AutoFactory", function(v) end)
    NewToggle(EventTab, "Auto Dough King", "AutoDoughKing", function(v) end)
    NewToggle(EventTab, "Auto Cake Prince", "AutoCakePrince", function(v) end)
    NewToggle(EventTab, "Auto Bone Farm", "AutoBone", function(v) end)

    NewSection(EventTab, "Race V4")
    NewToggle(EventTab, "Auto Race V4 Helper", "AutoRaceV4", function(v) end)
    NewToggle(EventTab, "Auto Trial", "AutoTrial", function(v) end)
    NewButton(EventTab, "Pull Lever (Temple of Time)", function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("TempleManager", "PullLever")
    end)

    NewSection(EventTab, "Bosses")
    NewToggle(EventTab, "Auto Elite Hunter", "AutoEliteHunter", function(v) end)
    NewToggle(EventTab, "Auto Cake Prince", "AutoCakePrince", function(v) end)

    -- TAB: ITEMS
    local ItemTab = NewTab("Items")
    NewSection(ItemTab, "Legendary Puzzles")
    NewToggle(ItemTab, "Auto Soul Guitar", "AutoSoulGuitar", function(v) end)
    NewToggle(ItemTab, "Auto CDK", "AutoCDK", function(v) end)
    NewToggle(ItemTab, "Auto Godhuman", "AutoGodhuman", function(v) end)

    NewSection(ItemTab, "Auto Materials")
    NewToggle(ItemTab, "Auto Farm Material", "AutoFarmMaterial", function(v) end)
    local materialList = {}
    for mat, _ in pairs(MaterialData) do table.insert(materialList, mat) end
    NewDropdown(ItemTab, "Select Material", materialList, "SelectedMaterial", function(v) end)

    -- TAB: TELEPORTS
    local TeleportTab = NewTab("Teleports")
    NewSection(TeleportTab, "Search Island")
    local IslandButtons = {}
    NewSearch(TeleportTab, "Type island name...", {}, function(text)
        for name, btn in pairs(IslandButtons) do
            btn.Visible = name:lower():find(text) ~= nil
        end
    end)

    NewSection(TeleportTab, "Island Teleports")
    for _, island in ipairs(SeaData[GetSea()] or {}) do
        local btn = NewButton(TeleportTab, "Go to " .. island.Name, function()
            TweenTo(island.Pos)
        end)
        IslandButtons[island.Name] = btn
    end
    
    NewSection(TeleportTab, "Sea Teleports")
    NewButton(TeleportTab, "Go to Sea 1", function() ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelMain") end)
    NewButton(TeleportTab, "Go to Sea 2", function() ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelDressrosa") end)
    NewButton(TeleportTab, "Go to Sea 3", function() ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelZou") end)

    NewSection(TeleportTab, "Rare NPCs")
    for _, npc in ipairs(RareNPCData[GetSea()] or {}) do
        NewButton(TeleportTab, "Go to " .. npc.Name, function()
            TweenTo(npc.Pos)
        end)
    end

    -- TAB: MISC
    local MiscTab = NewTab("Misc")
    NewSection(MiscTab, "Discord Webhook")
    NewToggle(MiscTab, "Enable Webhook", "WebhookEnabled", function(v) end)
    NewButton(MiscTab, "Set Webhook URL", function()
        -- In a real environment, you'd use an Input Box. For now, we'll suggest using a command or file edit.
        Notify("Cole sua URL no arquivo de configurações!", 5)
    end)
    NewButton(MiscTab, "Test Webhook", function()
        SendWebhook("TESTE DE CONEXÃO", "Seu MAKITO HUB está conectado com sucesso!", 0x00ff96)
    end)

    NewSection(MiscTab, "Fruit Management")
    NewToggle(MiscTab, "Auto Fruit Finder (TP)", "AutoFruitFinder", function(v) end)
    NewToggle(MiscTab, "Auto Buy Fruit (Gacha)", "AutoBuyFruit", function(v) end)
    NewToggle(MiscTab, "Auto Sniper Mode", "AutoSnipe", function(v) end)
    NewToggle(MiscTab, "Auto Store Fruits", "AutoStoreFruit", function(v) end)

    NewSection(MiscTab, "Game Optimization")
    NewToggle(MiscTab, "Anti-AFK", "AntiAFK", function(v) end)
    NewToggle(MiscTab, "Auto Rejoin", "AutoRejoin", function(v) end)
    NewButton(MiscTab, "Server Hop", function()
        ServerHop()
    end)

    NewSection(MiscTab, "Themes")
    NewDropdown(MiscTab, "UI Theme", {"Default", "Neon Red", "Deep Blue", "Golden", "Purple Night"}, "CurrentTheme", function(v)
        Settings.ThemeColor = Themes[v]
        MainStroke.Color = Settings.ThemeColor
        Notify("Tema alterado para " .. v, 3)
        -- Update all UI elements color if needed
    end)
    
    NewSection(MiscTab, "Character Mods")
    NewButton(MiscTab, "Unlock FPS", function() if setfpscap then setfpscap(999) end end)
    NewButton(MiscTab, "Stop Makito Hub", function()
        _G.MakitoHubRunning = false
        MakitoGui:Destroy()
        Notify("MAKITO HUB ENCERRADO.", 5)
    end)
    
    -- TAB: VISUAL
    local VisualTab = NewTab("Visuals")
    NewSection(VisualTab, "ESP")
    NewToggle(VisualTab, "ESP Players", "EspPlayers", function(v) end)
    NewToggle(VisualTab, "ESP Fruits", "EspFruits", function(v) end)
    NewToggle(VisualTab, "ESP Chests", "EspChests", function(v) end)
    NewToggle(VisualTab, "ESP Flowers", "EspFlower", function(v) end)
    
    NewSection(VisualTab, "Farming")
    NewToggle(VisualTab, "Auto Farm Chests (TP)", "AutoChest", function(v) end)
    
    NewSection(VisualTab, "Environment")
    NewToggle(VisualTab, "Full Bright", "FullBright", function(v)
        if v then
            game:GetService("Lighting").Ambient = Color3.new(1,1,1)
            game:GetService("Lighting").Brightness = 2
        else
            game:GetService("Lighting").Ambient = Color3.new(0.5,0.5,0.5)
            game:GetService("Lighting").Brightness = 1
        end
    end)
    
    NewSection(VisualTab, "Mobile Optimization")
    NewToggle(VisualTab, "Remove Textures", "RemoveTextures", function(v)
        if v then
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("Texture") or v:IsA("Decal") then
                    v.Transparency = 1
                end
            end
        end
    end)
    NewToggle(VisualTab, "Remove Shadows", "RemoveShadows", function(v)
        game:GetService("Lighting").GlobalShadows = not v
    end)
    NewToggle(VisualTab, "Low Graphics Mode", "LowGraphics", function(v)
        if v then
            settings().Rendering.QualityLevel = 1
        else
            settings().Rendering.QualityLevel = 10
        end
    end)

    -- TAB: SHOP
    local ShopTab = NewTab("Shop")
    NewSection(ShopTab, "Fighting Styles")
    NewButton(ShopTab, "Buy Black Leg (150k)", function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyBlackLeg") end)
    NewButton(ShopTab, "Buy Electro (500k)", function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyElectro") end)
    NewButton(ShopTab, "Buy Fishman Karate (750k)", function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyFishmanKarate") end)
    NewButton(ShopTab, "Buy Dragon Step (1.5k Fragments)", function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "DragonStep", "Requirement") end)
    NewButton(ShopTab, "Buy Superhuman (3m)", function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySuperhuman") end)
    NewButton(ShopTab, "Buy Death Step (2.5m + 5k Frag)", function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyDeathStep") end)
    NewButton(ShopTab, "Buy Sharkman Karate (2.5m + 5k Frag)", function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySharkmanKarate") end)
    NewButton(ShopTab, "Buy Electric Claw (3m + 5k Frag)", function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyElectricClaw") end)
    NewButton(ShopTab, "Buy Dragon Talon (3m + 5k Frag)", function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyDragonTalon") end)
    NewButton(ShopTab, "Buy Godhuman (5m + 5k Frag)", function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyGodhuman") end)

    NewSection(ShopTab, "Abilities")
    NewButton(ShopTab, "Buy Geppo (10k)", function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", "Geppo") end)
    NewButton(ShopTab, "Buy Buso Haki (25k)", function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", "Buso") end)
    NewButton(ShopTab, "Buy Soru (100k)", function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", "Soru") end)
    NewButton(ShopTab, "Buy Ken Haki (750k)", function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", "Ken") end)

    -- TAB: INFO
    local InfoTab = NewTab("Info")
    NewSection(InfoTab, "Player Statistics")
    local LevelLabel = Instance.new("TextLabel", InfoTab)
    LevelLabel.Size = UDim2.new(1, 0, 0, 30)
    LevelLabel.Text = "Level: " .. tostring(LocalPlayer.Data.Level.Value)
    LevelLabel.TextColor3 = Color3.new(1,1,1)
    LevelLabel.BackgroundTransparency = 1
    LevelLabel.Font = Enum.Font.Gotham
    LevelLabel.TextSize = 14
    LevelLabel.TextXAlignment = Enum.TextXAlignment.Left

    local MoneyLabel = Instance.new("TextLabel", InfoTab)
    MoneyLabel.Size = UDim2.new(1, 0, 0, 30)
    MoneyLabel.Text = "Beli: $" .. tostring(LocalPlayer.Data.Beli.Value)
    MoneyLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    MoneyLabel.BackgroundTransparency = 1
    MoneyLabel.Font = Enum.Font.Gotham
    MoneyLabel.TextSize = 14
    MoneyLabel.TextXAlignment = Enum.TextXAlignment.Left

    local FragLabel = Instance.new("TextLabel", InfoTab)
    FragLabel.Size = UDim2.new(1, 0, 0, 30)
    FragLabel.Text = "Fragments: " .. tostring(LocalPlayer.Data.Fragments.Value)
    FragLabel.TextColor3 = Color3.fromRGB(200, 100, 255)
    FragLabel.BackgroundTransparency = 1
    FragLabel.Font = Enum.Font.Gotham
    FragLabel.TextSize = 14
    FragLabel.TextXAlignment = Enum.TextXAlignment.Left

    task.spawn(function()
        while MakitoGui.Parent do
            LevelLabel.Text = "Level: " .. tostring(LocalPlayer.Data.Level.Value)
            MoneyLabel.Text = "Beli: $" .. tostring(LocalPlayer.Data.Beli.Value)
            FragLabel.Text = "Fragments: " .. tostring(LocalPlayer.Data.Fragments.Value)
            task.wait(1)
        end
    end)

    NewSection(InfoTab, "Inventory Highlights")
    NewButton(InfoTab, "Copy Inventory to Clipboard", function()
        local inv = ""
        for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do inv = inv .. v.Name .. ", " end
        setclipboard(inv)
        Notify("Inventário copiado!", 3)
    end)

    -- Initialize first tab
    Tabs["Auto Farm"].Frame.Visible = true
    Tabs["Auto Farm"].Btn.BackgroundColor3 = Settings.ThemeColor
    Tabs["Auto Farm"].Btn.TextColor3 = Color3.new(0,0,0)

    -- Minimize Button
    local MinBtn = Instance.new("TextButton", MakitoGui)
    MinBtn.Size = UDim2.new(0, 50, 0, 50)
    MinBtn.Position = UDim2.new(0, 20, 0, 20)
    MinBtn.Text = "M"
    MinBtn.BackgroundColor3 = Settings.ThemeColor
    MinBtn.TextColor3 = Color3.new(0,0,0)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 24
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(1, 0)
    MinBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

    -- TAB: CREDITS
    local CreditTab = NewTab("Credits")
    NewSection(CreditTab, "Development")
    NewButton(CreditTab, "Developer: Lucas", function() setclipboard("Lucas") end)
    NewButton(CreditTab, "Version: 6.0 Supreme", function() end)
    NewSection(CreditTab, "Support")
    NewButton(CreditTab, "Join Discord", function() setclipboard("https://discord.gg/makitohub") end)
end

-- Keybinds Handler
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Settings.KillSwitchKey then
        _G.MakitoHubRunning = false
        Notify("MAKITO HUB ENCERRADO PELO KEYBIND.", 5)
        -- Cleanup UI
        local gui = ParentGui:FindFirstChild("MakitoHubSupremeV6")
        if gui then gui:Destroy() end
    end
end)

-- BONE FARM LOGIC
local function AutoBoneLogic()
    if not Settings.AutoBone then return end
    pcall(function()
        local Quest = {Enemy = "Reborn Skeleton", Pos = CFrame.new(-9515, 164, -5785)}
        local Enemy = GetNearestEnemy(Quest.Enemy)
        if Enemy then
            EquipWeapon()
            TweenTo(Enemy.HumanoidRootPart.CFrame * CFrame.new(0, Settings.Distance, 0))
            AutoClick()
        else
            TweenTo(Quest.Pos)
        end
        -- Auto Exchange Bones
        if LocalPlayer.Data.Bones.Value >= 50 then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("Bones", "Buy", 1, 1)
        end
    end)
end

-- RACE V4 LOGIC
local function AutoRaceV4Logic()
    if not Settings.AutoRaceV4 then return end
    pcall(function()
        -- Auto Trial Logic
        if Settings.AutoTrial then
            local Trial = workspace:FindFirstChild("Trial") -- Simplified check
            if Trial then
                -- Auto kill trial mobs or player
                local Enemy = GetNearestEnemy()
                if Enemy then
                    EquipWeapon()
                    TweenTo(Enemy.HumanoidRootPart.CFrame)
                    AutoClick()
                end
            end
        end
        
        -- Auto Mirage Lever Helper
        if Settings.AutoMirageLever then
            local Lever = workspace:FindFirstChild("Lever") -- Mirage Lever name
            if Lever then TweenTo(Lever.CFrame) end
        end
    end)
end

-- AUTO MATERIAL LOGIC
local function AutoFarmMaterialLogic()
    if not Settings.AutoFarmMaterial then return end
    pcall(function()
        local data = MaterialData[Settings.SelectedMaterial]
        if data then
            local Enemy = GetNearestEnemy(data.Enemy)
            if Enemy then
                EquipWeapon()
                LocalPlayer.Character.HumanoidRootPart.CFrame = Enemy.HumanoidRootPart.CFrame * CFrame.new(0, Settings.Distance, 0)
                AutoClick()
            else
                TweenTo(data.Pos)
            end
        end
    end)
end

-- WORLD EVENTS LOGIC
local function AutoFactoryLogic()
    if not Settings.AutoFactory then return end
    pcall(function()
        local core = workspace:FindFirstChild("Core")
        if core and core:FindFirstChild("Humanoid") then
            TweenTo(core.PrimaryPart.CFrame * CFrame.new(0, 15, 0))
            EquipWeapon()
            AutoClick()
        else
            -- Check if Factory is open
            local door = workspace:FindFirstChild("Factory") and workspace.Factory:FindFirstChild("Door")
            if door and door.CanCollide == false then
                TweenTo(CFrame.new(432, 210, -432)) -- Inside Factory
            end
        end
    end)
end

local function AutoDoughKingLogic()
    if not Settings.AutoDoughKing and not Settings.AutoCakePrince then return end
    pcall(function()
        local EnemyName = Settings.AutoDoughKing and "Dough King" or "Cake Prince"
        local Enemy = GetNearestEnemy(EnemyName)
        if Enemy then
            Notify(EnemyName .. " DETECTADO!", 5)
            EquipWeapon()
            LocalPlayer.Character.HumanoidRootPart.CFrame = Enemy.HumanoidRootPart.CFrame * CFrame.new(0, Settings.Distance, 0)
            AutoClick()
        else
            -- TP to spawn area
            TweenTo(CFrame.new(-700, 15, -11000))
        end
    end)
end

-- SEA EVENTS LOGIC (ADVANCED)
local function AutoSeaEventsLogic()
    if not Settings.AutoSeaEvent and not Settings.AutoMirage and not Settings.AutoKitsune then return end
    pcall(function()
        -- Priority 1: Mirage Island
        if Settings.AutoMirage then
            local Mirage = workspace:FindFirstChild("Mirage Island")
            if Mirage then
                Notify("MIRAGE ISLAND ENCONTRADA!", 5)
                TweenTo(Mirage:GetModelCFrame())
                if Settings.AutoFindGear then
                    for _, v in ipairs(Mirage:GetDescendants()) do
                        if v.Name == "Gear" then TweenTo(v.CFrame) end
                    end
                end
                return -- Stop other sea events if Mirage is found
            end
        end

        -- Priority 2: Kitsune Island
        if Settings.AutoKitsune then
            local Island = workspace:FindFirstChild("Kitsune Island")
            if Island then
                TweenTo(Island:GetModelCFrame())
                for _, v in ipairs(workspace:GetChildren()) do
                    if v.Name == "Azure Wisp" then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
                        task.wait(0.1)
                    end
                end
                return
            end
        end

        -- Priority 3: General Sea Events
        if Settings.AutoSeaEvent then
            local SeaEvents = {"Terror Shark", "Piranha", "Ship Raid", "Sea Beast"}
            for _, event in ipairs(SeaEvents) do
                local Target = GetNearestEnemy(event)
                if Target then
                    EquipWeapon()
                    TweenTo(Target.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                    AutoClick()
                    return
                end
            end
            
            local Levi = workspace:FindFirstChild("Leviathan")
            if Levi then
                Notify("LEVIATHAN DETECTADO!", 5)
                TweenTo(Levi:GetModelCFrame())
                AutoClick()
                -- Logic for Heart/Shield
                for _, v in ipairs(workspace:GetChildren()) do
                    if v.Name == "Frozen Dimension" then
                        TweenTo(v.CFrame)
                    end
                end
            end
            
            -- Shark Anchor Logic
            local TerrorShark = GetNearestEnemy("Terror Shark")
            if TerrorShark and TerrorShark:FindFirstChild("Anchor") then
                Notify("TERROR SHARK COM ANCORA! FOCANDO...", 10)
                TweenTo(TerrorShark.HumanoidRootPart.CFrame * CFrame.new(0, 35, 0))
                EquipWeapon()
                AutoClick()
            end
        end
    end)
end

-- FRUIT SYSTEM
local function AutoFruitLogic()
    -- Auto Buy Fruit (Gacha)
    task.spawn(function()
        while _G.MakitoHubRunning do
            task.wait(5)
            if Settings.AutoBuyFruit then
                pcall(function()
                    local result = ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "Buy")
                    if result and Settings.AutoSnipe then
                        for _, snipe in ipairs(Settings.SnipeFruits) do
                            if result:find(snipe) then
                                Notify("SNIPER: VOCÊ GANHOU UMA " .. snipe:upper() .. "!", 10)
                                SendWebhook("FRUIT SNIPED", "O MAKITO HUB snipou uma " .. snipe .. " no Gacha!", 0x00ffff)
                                break
                            end
                        end
                    end
                end)
            end
        end
    end)
    
    -- Auto Store Fruit
    task.spawn(function()
        while _G.MakitoHubRunning do
            task.wait(2)
            if Settings.AutoStoreFruit then
                pcall(function()
                    for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
                        if v:IsA("Tool") and (v.Name:find("Fruit") or v:FindFirstChild("Fruit")) then
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", v:FindFirstChild("Fruit") and v.Fruit.Value or v.Name, v)
                        end
                    end
                end)
            end
        end
    end)

    -- Auto Fruit Finder (TP)
    task.spawn(function()
        while _G.MakitoHubRunning do
            task.wait(1)
            if Settings.AutoFruitFinder then
                pcall(function()
                    for _, v in ipairs(workspace:GetChildren()) do
                        if v:IsA("Tool") and v.Name:find("Fruit") and v:FindFirstChild("Handle") then
                            Notify("FRUTA ENCONTRADA: " .. v.Name .. "! TELEPORTANDO...", 5)
                            SendWebhook("FRUTA ENCONTRADA", "O MAKITO HUB encontrou uma " .. v.Name .. " jogada no chão!", 0xff00ff)
                            TweenTo(v.Handle.CFrame)
                            task.wait(1)
                        end
                    end
                end)
            end
        end
    end)
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
                    {["name"] = "Level", ["value"] = tostring(LocalPlayer.Data.Level.Value), ["inline"] = true}
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

-- Initialize Fruit System
task.spawn(AutoFruitLogic)

-- CHEST FARM LOGIC
local function AutoChestLogic()
    task.spawn(function()
        while _G.MakitoHubRunning do
            task.wait(1)
            if Settings.AutoChest then
                pcall(function()
                    local function FarmChest(v)
                        if v.Name:find("Chest") then
                            local handle = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart", true)
                            if handle then
                                TweenTo(handle.CFrame)
                                task.wait(0.5)
                            end
                        end
                    end

                    for _, v in ipairs(workspace:GetChildren()) do
                        if not Settings.AutoChest then break end
                        FarmChest(v)
                    end
                    local chestFolder = workspace:FindFirstChild("Chests")
                    if chestFolder then
                        for _, v in ipairs(chestFolder:GetChildren()) do
                            if not Settings.AutoChest then break end
                            FarmChest(v)
                        end
                    end
                end)
            end
        end
    end)
end

-- BOSS FARM LOGIC
local function AutoBossLogic()
    task.spawn(function()
        while _G.MakitoHubRunning do
            task.wait(1)
            if Settings.AutoBoss then
                pcall(function()
                    local Sea = GetSea()
                    local BossList = QuestData[Sea]
                    local foundAnyBoss = false
                    for _, boss in ipairs(BossList) do
                        if boss.ID == 0 then -- ID 0 means Boss in our DB
                            local Target = GetNearestEnemy(boss.Enemy)
                            if Target then
                                foundAnyBoss = true
                                EquipWeapon()
                                LocalPlayer.Character.HumanoidRootPart.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0, Settings.Distance, 0)
                                AutoClick()
                                break
                            end
                        end
                    end
                    
                    if not foundAnyBoss and Settings.AutoBossHop then
                        Notify("NENHUM BOSS ENCONTRADO. TROCANDO DE SERVIDOR...", 5)
                        task.wait(2)
                        ServerHop()
                    end
                end)
            end
        end
    end)
end

-- PVP & HACKS LOGIC
local function GetBountyTarget()
    local target, minDist = nil, math.huge
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
            -- Safe Mode check (ignore if they are in safe zone or too high bounty)
            local dist = (v.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if dist < minDist then
                minDist = dist
                target = v.Character
            end
        end
    end
    return target
end

-- Aim Assist Logic
RunService.RenderStepped:Connect(function()
    if Settings.AimAssist and _G.MakitoHubRunning then
        local target = GetBountyTarget()
        if target then
            local pos = target.HumanoidRootPart.Position
            local camera = workspace.CurrentCamera
            if Settings.PredictMovement then
                pos = pos + (target.HumanoidRootPart.Velocity * 0.1)
            end
            camera.CFrame = CFrame.new(camera.CFrame.Position, pos)
        end
    end
end)

local function AutoPvPLogic()
    task.spawn(function()
        while _G.MakitoHubRunning do
            task.wait(0.1)
            
            -- Auto Bounty Logic (Mauro Hub Style)
            if Settings.AutoBounty then
                pcall(function()
                    local target = GetBountyTarget()
                    if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
                        -- Check if target is safe
                        local isSafe = false
                        if target:FindFirstChild("SafeZone") or target.Humanoid.Health > target.Humanoid.MaxHealth then isSafe = true end
                        
                        if not isSafe then
                            EquipWeapon()
                            -- Smart Positioning: Behind or Above
                            local pos = target.HumanoidRootPart.CFrame * CFrame.new(0, 5, 2)
                            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos.Position, target.HumanoidRootPart.Position)
                            
                            AutoClick()
                            if Settings.AutoCombo then
                                ExecuteCombo(target)
                            end
                        end
                        
                        -- Check if killed
                        if target.Humanoid.Health <= 0 then
                            Notify("ALVO ELIMINADO! +BOUNTY", 5)
                            SendWebhook("BOUNTY GAINED", "O MAKITO HUB eliminou " .. target.Name .. "!", 0xff0000)
                            if Settings.BountyHop then
                                task.wait(2)
                                ServerHop()
                            end
                        end
                    else
                        -- No target, maybe hop?
                        if Settings.BountyHop then ServerHop() end
                    end
                end)
            end

            if Settings.KillAura then
                 pcall(function()
                     for _, v in ipairs(Players:GetPlayers()) do
                         if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
                             local dist = (v.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                             if dist < 60 then
                                 EquipWeapon()
                                 -- Fast Aura Attacks
                                 AutoClick()
                                 if Settings.AutoCombo and dist < 30 then
                                     ExecuteCombo(v.Character)
                                 end
                             end
                         end
                     end
                 end)
             end
            
            if Settings.WalkSpeed ~= 16 then
                LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
            end
            if Settings.JumpPower ~= 50 then
                LocalPlayer.Character.Humanoid.JumpPower = Settings.JumpPower
            end
        end
    end)
end

-- 6. LOGIC & TASK SCHEDULER (THE BRAIN)
local function CheckSeaTravel()
    if not Settings.AutoNextSea then return end
    local level = LocalPlayer.Data.Level.Value
    local sea = GetSea()
    
    if sea == 1 and level >= 700 then
        Notify("PROSSEGUINDO PARA O SEA 2...", 10)
        -- Quest for Sea 2 (Ice Admiral)
        if not HasItem("Library Key") then
            -- Logic to kill Ice Admiral or talk to Military Detective
            ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelDressrosa")
        end
    elseif sea == 2 and level >= 1500 then
        Notify("PROSSEGUINDO PARA O SEA 3...", 10)
        -- Logic for Sea 3 (Don Swan & Rip Indra)
        ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelZou")
    elseif sea == 3 and level >= 2600 then
        -- Travel logic for Submerged Island handled by Auto Farm Quest positions
    end
end

local function GetNearestEnemy(EnemyName)
    local Nearest, MaxDist = nil, math.huge
    local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace

    -- Normalização do nome para busca mais flexível
    local searchName = EnemyName and EnemyName:lower() or nil

    pcall(function()
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
    end)

    -- Fallback agressivo para o Workspace (comum no Sea 1)
    if not Nearest then
        pcall(function()
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
        end)
    end

    return Nearest
end

local function Float(enabled)
    pcall(function()
        local root = LocalPlayer.Character.HumanoidRootPart
        local hum = LocalPlayer.Character.Humanoid
        if enabled then
            if not root:FindFirstChild("MakitoFloat") then
                local bv = Instance.new("BodyVelocity", root)
                bv.Name = "MakitoFloat"
                bv.Velocity = Vector3.new(0, 0, 0)
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            end
            if not root:FindFirstChild("MakitoGyro") then
                local bg = Instance.new("BodyGyro", root)
                bg.Name = "MakitoGyro"
                bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                bg.P = 30000 -- High power to prevent rotation jitter
                bg.CFrame = root.CFrame
            end
            -- Disabling physics states that cause the "falling" loop
            hum.PlatformStand = true
            -- Set state to Physics to bypass gravity logic
            if hum:GetState() ~= Enum.HumanoidStateType.Physics then
                hum:ChangeState(Enum.HumanoidStateType.Physics)
            end
            root.Anchored = false
        else
            if root:FindFirstChild("MakitoFloat") then root.MakitoFloat:Destroy() end
            if root:FindFirstChild("MakitoGyro") then root.MakitoGyro:Destroy() end
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            root.Anchored = false
        end
    end)
end

local function GetQuestData()
    local level = 0
    pcall(function()
        level = LocalPlayer.Data.Level.Value
    end)

    local sea = GetSea()
    local data = QuestData[sea]
    if not data then return nil end

    local myTeam = LocalPlayer.Team and LocalPlayer.Team.Name or "Pirates"

    -- 1. Check if we already have an active quest in the UI
    local MainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
    if MainGui and MainGui:FindFirstChild("Quest") and MainGui.Quest.Visible then
        local questText = ""
        pcall(function()
            questText = MainGui.Quest.Container.QuestTitle.Title.Text:lower()
        end)

        -- Custom titles mapping (Blox Fruits quest titles vs enemy names)
        local TitleMap = {
            ["skull slayer"] = "Skull Slayer",
            ["outlaw hunter"] = "Isle Outlaw",
            ["island sailor"] = "Island Sailor",
            ["island champion"] = "Island Champion",
            ["sun-kissed warrior"] = "Sun-kissed Warrior",
            ["serpent hunter"] = "Serpent Hunter"
        }

        for title, enemy in pairs(TitleMap) do
            if questText:find(title) then
                for _, q in ipairs(data) do
                    if q.Enemy == enemy then return q end
                end
            end
        end

        for _, q in ipairs(data) do
            if questText:find(q.Enemy:lower()) or q.Name:lower():find(questText) then
                return q -- We already have a valid quest, stick with it!
            end
        end
    end

    -- 2. If no quest active, pick the best one for our level
    local bestQuest = nil
    for _, q in ipairs(data) do
        if level >= q.Min then 
            -- Para o nível 0-10, respeita o time do jogador
            if q.Min == 0 and q.Team and q.Team ~= myTeam then
                continue
            end

            if not bestQuest or q.Min > bestQuest.Min then 
                bestQuest = q 
            end 
        end
    end
    return bestQuest
end

-- RAID LOGIC
local function CheckRaid()
    local RaidGui = LocalPlayer.PlayerGui:FindFirstChild("Raid")
    if RaidGui and RaidGui.Visible then return true end
    -- Check if in raid map (using coordinates)
    if (LocalPlayer.Character.HumanoidRootPart.Position - Vector3.new(-3000, 0, -3000)).Magnitude < 5000 then return true end
    return false
end

task.spawn(function()
    while _G.MakitoHubRunning do
        task.wait(0.1)
        if Settings.AutoRaid then
            pcall(function()
                if not CheckRaid() then
                    -- Buy Chip and Start
                    if Settings.AutoBuyChip then
                        -- Check if already have chip
                        local hasChip = false
                        for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
                            if v.Name:find("Chip") or v.Name:find("Microchip") then hasChip = true break end
                        end
                        
                        if not hasChip then
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("RaidsNpc", "Select", Settings.SelectedRaid)
                        end
                    end
                    -- TP to Start Button
                    TweenTo(CFrame.new(-495, 300, -2850)) -- Raid Lab
                    if (LocalPlayer.Character.HumanoidRootPart.Position - Vector3.new(-495, 300, -2850)).Magnitude < 10 then
                        fireclickdetector(workspace.Map.CircleIsland.RaidSummon.Button.ClickDetector)
                    end
                else
                    -- In Raid
                    local Enemy = GetNearestEnemy()
                    if Enemy then
                        EquipWeapon()
                        LocalPlayer.Character.HumanoidRootPart.CFrame = Enemy.HumanoidRootPart.CFrame * CFrame.new(0, Settings.Distance, 0)
                        AutoClick()
                    else
                        -- No enemies, go to center of island to trigger next wave/island
                        if Settings.AutoNextIsland then
                            -- Logic to find the next island CFrame
                            -- This is usually done by finding the island's main part
                        end
                    end
                    
                    -- Auto Awaken at end
                    if Settings.AutoAwaken then
                        local AwakenNPC = workspace:FindFirstChild("Awakening Scientist") or workspace:FindFirstChild("Mysterious Force")
                        if AwakenNPC then
                            TweenTo(AwakenNPC.HumanoidRootPart.CFrame)
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("Awakener", "Check")
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("Awakener", "Awaken")
                        end
                    end
                end
            end)
        end
    end
end)

-- PUZZLE LOGIC (SOUL GUITAR, CDK, GODHUMAN)
local function HasItem(itemName)
    return LocalPlayer.Backpack:FindFirstChild(itemName) or LocalPlayer.Character:FindFirstChild(itemName) or (ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", itemName, "Check"))
end

local function AutoSoulGuitarLogic()
    if not Settings.AutoSoulGuitar or HasItem("Soul Guitar") then return end
    pcall(function()
        local sea = GetSea()
        if sea ~= 3 then Notify("Vá para o Sea 3 para Soul Guitar", 5) return end
        
        -- Step 1: Pray at night
        local time = Lighting.TimeOfDay
        if time >= "18:00:00" or time <= "06:00:00" then
            TweenTo(CFrame.new(-10500, 150, -6000)) -- Grave
            ReplicatedStorage.Remotes.CommF_:InvokeServer("Pray")
        end
        
        -- Step 2: Kill Zombies (Simultaneously)
        local Zombies = {}
        for _, v in ipairs(workspace.Enemies:GetChildren()) do
            if v.Name == "Living Zombie" then table.insert(Zombies, v) end
        end
        
        if #Zombies > 0 then
            EquipWeapon()
            for _, z in ipairs(Zombies) do
                if z:FindFirstChild("HumanoidRootPart") then
                    z.HumanoidRootPart.CFrame = Zombies[1].HumanoidRootPart.CFrame
                    z.HumanoidRootPart.CanCollide = false
                end
            end
            LocalPlayer.Character.HumanoidRootPart.CFrame = Zombies[1].HumanoidRootPart.CFrame * CFrame.new(0, 10, 0)
            AutoClick()
        end
    end)
end

local function AutoCDKLogic()
    if not Settings.AutoCDK or (HasItem("Cursed Dual Katana")) then return end
    pcall(function()
        -- Yama Quest: Haze of Misery (Kill all ghosts with purple marks)
        if LocalPlayer.PlayerGui.Main:FindFirstChild("Haze") then
            for _, v in ipairs(workspace.Enemies:GetChildren()) do
                if v.Name == "Ghost" and v:FindFirstChild("Highlight") then
                    TweenTo(v.HumanoidRootPart.CFrame)
                    EquipWeapon()
                    AutoClick()
                    return
                end
            end
        end
        
        -- Tushita Quest: Holy Torch
        if not HasItem("Tushita") and not LocalPlayer.Character:FindFirstChild("Holy Torch") then
            -- TP to Hydra Island Secret Door
            TweenTo(CFrame.new(5259, 388, 2275))
        end
        
        -- Final CDK Room
        if HasItem("Tushita") and HasItem("Yama") then
            TweenTo(CFrame.new(-12500, 350, -7500)) -- Mansion CDK Room
        end
    end)
end

local function AutoGodhumanLogic()
    if not Settings.AutoGodhuman then return end
    pcall(function()
        -- Material Locations
        local MatsData = {
            ["Dragon Scale"] = {Enemy = "Dragon Crew Warrior", Pos = CFrame.new(5259, 604, 346)},
            ["Fish Tail"] = {Enemy = "Fishman Raider", Pos = CFrame.new(-13233, 532, -7594)},
            ["Magma Ore"] = {Enemy = "Military Soldier", Pos = CFrame.new(-5313, 12, 8515)},
            ["Mystic Droplet"] = {Enemy = "Sea Soldier", Pos = CFrame.new(-3056, 235, -10142)}
        }
        
        -- Check materials in inventory
        for mat, data in pairs(MatsData) do
            -- Farm mat logic
            local Enemy = GetNearestEnemy(data.Enemy)
            if Enemy then
                TweenTo(Enemy.HumanoidRootPart.CFrame * CFrame.new(0, Settings.Distance, 0))
                EquipWeapon()
                AutoClick()
                return
            else
                TweenTo(data.Pos)
            end
        end
        
        -- Buy Godhuman NPC if all mats done
        TweenTo(CFrame.new(-2800, 250, -6300)) -- Ancient Monk
    end)
end

local function AutoSaberLogic()
    if not Settings.AutoSaber then return end
    pcall(function()
        -- Buttons Puzzle
        local Buttons = {
            CFrame.new(-160, 35, 15), -- Button 1
            CFrame.new(-180, 35, 10), -- Button 2
            -- ... all buttons
        }
        for _, btn in ipairs(Buttons) do
            TweenTo(btn)
            task.wait(1)
        end
        -- Kill Shanks
        local Shanks = GetNearestEnemy("Saber Expert")
        if Shanks then TweenTo(Shanks.HumanoidRootPart.CFrame) AutoClick() end
    end)
end

local FarmPosLock = nil
-- DUNGEON AUTO FARM LOGIC
local function AutoDungeonLogic()
    task.spawn(function()
        while _G.MakitoHubRunning do
            task.wait(0.5)
            if Settings.AutoDungeon then
                pcall(function()
                    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
                    
                    -- Check if in dungeon
                    local dungeonFolder = workspace:FindFirstChild("Dungeon")
                    if dungeonFolder then
                        -- Find nearest enemy in dungeon
                        local NearestEnemy = nil
                        local MinDist = math.huge
                        
                        for _, v in ipairs(dungeonFolder:GetDescendants()) do
                            if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                local dist = (v.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                if dist < MinDist then
                                    MinDist = dist
                                    NearestEnemy = v
                                end
                            end
                        end
                        
                        if NearestEnemy then
                            EquipWeapon()
                            Float(true)
                            LocalPlayer.Character.HumanoidRootPart.CFrame = NearestEnemy.HumanoidRootPart.CFrame * CFrame.new(0, Settings.Distance, 0)
                        end
                    else
                        -- TP to dungeon entrance if not in dungeon
                        local sea = GetSea()
                        if sea == 3 then
                            -- Sea 3 Dungeon location (Castle on the Sea)
                            TweenTo(CFrame.new(-5400, 15, 1000))
                        elseif sea == 2 then
                            -- Sea 2 Dungeon location (Factory)
                            TweenTo(CFrame.new(634, 72, 918))
                        end
                    end
                end)
            end
        end
    end)
end

-- AUTO FARM NEAREST LOGIC (Redz Hub Style - No Quest Needed)
local function AutoFarmNearestLogic()
    task.spawn(function()
        while _G.MakitoHubRunning do
            task.wait(0.1)
            if Settings.AutoFarmNearest then
                pcall(function()
                    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
                    
                    -- Find nearest enemy regardless of quest
                    local NearestEnemy = nil
                    local MinDist = math.huge
                    local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
                    
                    for _, v in ipairs(enemiesFolder:GetDescendants()) do
                        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            local dist = (v.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                            if dist < MinDist and dist < 500 then -- 500 stud range
                                MinDist = dist
                                NearestEnemy = v
                            end
                        end
                    end
                    
                    if NearestEnemy then
                        EquipWeapon()
                        Float(true)
                        
                        -- Lock position to enemy
                        local targetCF = NearestEnemy.HumanoidRootPart.CFrame * CFrame.new(0, Settings.Distance, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                        LocalPlayer.Character.HumanoidRootPart.CFrame = targetCF
                        
                        -- Bring nearby mobs if enabled
                        if Settings.BringMobs then
                            for _, v in ipairs(enemiesFolder:GetDescendants()) do
                                if v:IsA("Model") and v.Name == NearestEnemy.Name and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                    local distToMain = (v.HumanoidRootPart.Position - NearestEnemy.HumanoidRootPart.Position).Magnitude
                                    if distToMain < 150 then
                                        v.HumanoidRootPart.CanCollide = false
                                        v.HumanoidRootPart.CFrame = NearestEnemy.HumanoidRootPart.CFrame
                                    end
                                end
                            end
                        end
                    else
                        Float(false)
                    end
                end)
            end
        end
    end)
end

-- Main Automation Loop
task.spawn(function()
    while true do
        task.wait(0.15)
        if not _G.MakitoHubRunning then 
            if FarmPosLock then FarmPosLock:Disconnect() FarmPosLock = nil end
            continue 
        end
        
        pcall(function()
            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
            
            if Settings.AutoFarm then
                local Quest = GetQuestData()
                local MainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
                local HasQuest = MainGui and MainGui:FindFirstChild("Quest") and MainGui.Quest.Visible
                
                if Quest then
                    if not HasQuest then
                        -- NO QUEST: Go pick one if AutoQuest is on
                        if FarmPosLock then FarmPosLock:Disconnect() FarmPosLock = nil end
                        if Settings.AutoQuest then
                            local npcPos = Quest.Pos
                            -- Try to find actual NPC model
                            local npcModel = workspace:FindFirstChild(Quest.NPC, true)
                            if npcModel and npcModel:FindFirstChild("HumanoidRootPart") then
                                npcPos = npcModel.HumanoidRootPart.CFrame
                            end

                            TweenTo(npcPos * CFrame.new(0, 10, 0))

                            if (LocalPlayer.Character.HumanoidRootPart.Position - npcPos.Position).Magnitude < 20 then
                                -- Try starting quest with fallback for different remote names
                                pcall(function()
                                    ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", Quest.Name, Quest.ID)
                                end)
                                pcall(function()
                                    ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest")
                                end)
                                pcall(function()
                                    ReplicatedStorage.Remotes["CommF_"]:InvokeServer("StartQuest", Quest.Name, Quest.ID)
                                end)
                                task.wait(1)
                            end
                        end
                    else
                        -- HAVE QUEST: Go kill mobs
                        local Enemy = GetNearestEnemy(Quest.Enemy)
                        
                        -- If no enemy found, go wait at spawn zone
                        if not Enemy then
                            if FarmPosLock then FarmPosLock:Disconnect() FarmPosLock = nil end
                            local waitPos = Quest.EnemyPos or Quest.Pos
                            
                            -- Use direct CFrame for nearby waiting to avoid tween loop
                            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - waitPos.Position).Magnitude
                            if dist < 50 then
                                Float(true)
                                LocalPlayer.Character.HumanoidRootPart.CFrame = waitPos * CFrame.new(0, 30, 0)
                            else
                                TweenTo(waitPos * CFrame.new(0, 30, 0))
                            end
                        else
                            -- Found Enemy: Attack
                            EquipWeapon()
                            
                            -- Safe Mode: Check for nearby players
                            local playerNearby = false
                            if Settings.SafeMode then
                                for _, p in ipairs(Players:GetPlayers()) do
                                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                        local dist = (p.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                        if dist < 250 then playerNearby = true break end
                                    end
                                end
                            end

                            if playerNearby then
                                -- Stop farming and float high if player nearby
                                if FarmPosLock then FarmPosLock:Disconnect() FarmPosLock = nil end
                                Float(true)
                                LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 100, 0)
                                task.wait(1)
                                return
                            end

                            if not isTweening then
                                Float(true)
                                -- INSANE STABILITY: Lock CFrame on Heartbeat (Eliminates Jitter)
                                local targetCF = Enemy.HumanoidRootPart.CFrame * CFrame.new(0, Settings.Distance, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                                
                                if not FarmPosLock then
                                    FarmPosLock = RunService.Heartbeat:Connect(function()
                                        if Settings.AutoFarm and not isTweening and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                            LocalPlayer.Character.HumanoidRootPart.CFrame = targetCF
                                        else
                                            if FarmPosLock then FarmPosLock:Disconnect() FarmPosLock = nil end
                                        end
                                    end)
                                end
                                
                                -- Grouping Mobs (Bring Mobs)
                                if Settings.BringMobs then
                                    local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
                                    for _, v in ipairs(enemiesFolder:GetChildren()) do
                                        if v.Name == Enemy.Name and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                            local distToMain = (v.HumanoidRootPart.Position - Enemy.HumanoidRootPart.Position).Magnitude
                                            if distToMain < 150 then
                                                -- Force mobs to stay slightly apart or overlapping but with collisions handled correctly
                                                v.HumanoidRootPart.CanCollide = false
                                                v.HumanoidRootPart.CFrame = Enemy.HumanoidRootPart.CFrame
                                                -- Disable animations to prevent the mob from moving away from the CFrame lock
                                                if v.Humanoid:FindFirstChild("Animator") then v.Humanoid.Animator:Destroy() end
                                            end
                                        end
                                    end
                                end
                            end
                            -- AutoClick removed: Fast Attack now handles damage automatically without clicking
                        end
                    end
                end
            else
                if FarmPosLock then FarmPosLock:Disconnect() FarmPosLock = nil end
                Float(false)
            end
        end)
    end
end)

-- Stats Loop
task.spawn(function()
    while _G.MakitoHubRunning do
        task.wait(1)
        if Settings.AutoStats then
            pcall(function()
                local points = 0
                if LocalPlayer.Data and LocalPlayer.Data:FindFirstChild("StatsPoints") then
                    points = LocalPlayer.Data.StatsPoints.Value
                end
                if points > 0 then
                    -- Try multiple remote methods
                    pcall(function()
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", Settings.SelectedStat, points)
                    end)
                    pcall(function()
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", Settings.SelectedStat)
                    end)
                end
            end)
        end
    end
end)

-- Misc Features
local FlyBV = nil
local FlyBG = nil
local function EnableFly()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    
    if not FlyBV then
        FlyBV = Instance.new("BodyVelocity", root)
        FlyBV.Name = "MakitoFlyBV"
        FlyBV.Velocity = Vector3.new(0, 0, 0)
        FlyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    end
    
    if not FlyBG then
        FlyBG = Instance.new("BodyGyro", root)
        FlyBG.Name = "MakitoFlyBG"
        FlyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        FlyBG.P = 50000
        FlyBG.CFrame = root.CFrame
    end
    
    LocalPlayer.Character.Humanoid.PlatformStand = true
end

local function DisableFly()
    if FlyBV then FlyBV:Destroy() FlyBV = nil end
    if FlyBG then FlyBG:Destroy() FlyBG = nil end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = false
    end
end

task.spawn(function()
    while _G.MakitoHubRunning do
        task.wait(0.1)
        pcall(function()
            if Settings.FlyHack then
                EnableFly()
            else
                DisableFly()
            end

            if Settings.InfEnergy and LocalPlayer.Character then
                -- Try multiple energy value names (Update 29 compatibility)
                if LocalPlayer.Character:FindFirstChild("Energy") then
                    LocalPlayer.Character.Energy.Value = 100
                elseif LocalPlayer.Character:FindFirstChild("Stamina") then
                    LocalPlayer.Character.Stamina.Value = 100
                elseif LocalPlayer.Character:FindFirstChild("Mana") then
                    LocalPlayer.Character.Mana.Value = 100
                end
            end

            if Settings.NoClip and LocalPlayer.Character then
                for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            elseif not Settings.NoClip and LocalPlayer.Character then
                -- Restore collision when NoClip is off
                for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                        v.CanCollide = true
                    end
                end
            end

            if Settings.WalkOnWater then
                -- Water walking logic
            end
        end)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Settings.InfGeppo and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- 7. VISUALS (ESP SYSTEM)
local function CreateESP(part, name, color, isPlayer)
    if part:FindFirstChild("MakitoESP") then 
        local bg = part.MakitoESP
        if isPlayer and part.Parent:FindFirstChild("Humanoid") then
            local hum = part.Parent.Humanoid
            local healthPercent = hum.Health / hum.MaxHealth
            bg.HealthBar.Main.Size = UDim2.new(healthPercent, 0, 1, 0)
            bg.Info.Text = string.format("%s [%d m]", name, math.floor((part.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude))
        end
        return 
    end
    
    local bg = Instance.new("BillboardGui", part)
    bg.Name = "MakitoESP"
    bg.AlwaysOnTop = true
    bg.Size = UDim2.new(0, 150, 0, 40)
    bg.DistanceLowerLimit = 0
    bg.ExtentsOffset = Vector3.new(0, 3, 0)
    
    local label = Instance.new("TextLabel", bg)
    label.Name = "Info"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = name
    label.TextColor3 = color
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextStrokeTransparency = 0
    
    if isPlayer then
        local healthBack = Instance.new("Frame", bg)
        healthBack.Name = "HealthBar"
        healthBack.Size = UDim2.new(0.8, 0, 0, 4)
        healthBack.Position = UDim2.new(0.1, 0, 0, 22)
        healthBack.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
        healthBack.BorderSizePixel = 0
        
        local healthMain = Instance.new("Frame", healthBack)
        healthMain.Name = "Main"
        healthMain.Size = UDim2.new(1, 0, 1, 0)
        healthMain.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        healthMain.BorderSizePixel = 0
        
        -- Adicionar Tracer
        local beam = Instance.new("Beam", part)
        beam.Name = "MakitoTracer"
        -- Lógica de Tracer simplificada para mobile
    end
end

task.spawn(function()
    while _G.MakitoHubRunning do
        task.wait(0.5)
        pcall(function()
            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
            
            -- ESP Players
            if Settings.EspPlayers then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        CreateESP(p.Character.HumanoidRootPart, p.Name, Color3.new(1,0.2,0.2), true)
                    end
                end
            else
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.HumanoidRootPart:FindFirstChild("MakitoESP") then
                        p.Character.HumanoidRootPart.MakitoESP:Destroy()
                    end
                end
            end
            
            -- ESP Fruits
            if Settings.EspFruits then
                for _, v in ipairs(workspace:GetChildren()) do
                    if v:IsA("Tool") and v.Name:find("Fruit") and v:FindFirstChild("Handle") then
                        CreateESP(v.Handle, v.Name, Color3.new(1, 0, 1), false)
                    end
                end
            end
            
            -- ESP Chests (Improved Detection)
            if Settings.EspChests then
                local function CheckChest(v)
                    if v.Name:find("Chest") then
                        local handle = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart", true)
                        if handle then
                            local chestColor = Color3.new(1, 0.8, 0) -- Default Yellow
                            if v.Name:find("1") then chestColor = Color3.fromRGB(192, 192, 192) -- Silver
                            elseif v.Name:find("2") then chestColor = Color3.fromRGB(255, 215, 0) -- Gold
                            elseif v.Name:find("3") then chestColor = Color3.fromRGB(0, 255, 255) -- Diamond/Blue
                            end
                            CreateESP(handle, v.Name, chestColor, false)
                        end
                    end
                end

                for _, v in ipairs(workspace:GetChildren()) do
                    CheckChest(v)
                end
                -- Fallback for specific chest folders
                local chestFolder = workspace:FindFirstChild("Chests")
                if chestFolder then
                    for _, v in ipairs(chestFolder:GetChildren()) do
                        CheckChest(v)
                    end
                end
            end
        end)
    end
end)

-- 8. COMBAT & COMBO SYSTEM (ADVANCED)
local function UseSkill(key, holdTime)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[key], false, game)
        if holdTime then task.wait(holdTime) end
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[key], false, game)
    end)
end

local function ExecuteAutoSkills()
    if not Settings.AutoSkill then return end
    if Settings.SkillZ then UseSkill("Z") end
    if Settings.SkillX then UseSkill("X") end
    if Settings.SkillC then UseSkill("C") end
    if Settings.SkillV then UseSkill("V") end
end

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

-- 9. INITIALIZATION
task.spawn(AutoPvPLogic)
task.spawn(AutoBossLogic)
task.spawn(AutoChestLogic)
task.spawn(AutoFarmNearestLogic)
task.spawn(AutoDungeonLogic)
task.spawn(CreateHub)
Notify("MAKITO HUB SUPREME V6.0 INICIADO!", 5)
print("[Makito Hub] Welcome, Lucas. System ready.")

-- Additional Tips for User
print([[
    --- MAKITO HUB TIPS ---
    1. Use 'Fast Attack' for 2x faster farming.
    2. 'Safe Mode' prevents kicks on public servers.
    3. 'Auto Mirage' works best with 'Auto Find Gear'.
    4. Keep 'NoClip' ON while tweening.
]])

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)
