local SettingsModule = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

_G.MakitoHubRunning = true

SettingsModule.Values = {
    -- Safety Settings
    AutoModeratorHop = true, AutoModeratorShutdown = false,
    -- Auto Farm Settings
    AutoFarm = false, FastAttack = false, AutoQuest = false, AutoNextSea = false, Weapon = "Melee", Distance = 10, TweenSpeed = 350, BringMobs = false, AutoFarmNearest = false,
    AutoSkill = false, SkillZ = true, SkillX = true, SkillC = true, SkillV = true,
    AutoMastery = false, MasteryHealth = 20, MasteryWeapon = "Sword",
    FastAttackSpeed = 0.05, AutoHaki = false, AutoKen = false, AutoStats = false, SelectedStat = "Melee",
    -- Sea Events
    AutoSeaEvent = false, AutoMirage = false, AutoFindGear = false, AutoKitsune = false, AutoLeviathan = false, AutoMirageLever = false,
    AutoEliteHunter = false, AutoFactory = false, AutoDoughKing = false, AutoCakePrince = false, AutoBone = false,
    AutoTerrorShark = false, AutoRipIndra = false, AutoBeautifulPirate = false, AutoLaw = false,
    AutoBoss = false, AutoBossHop = true,
    AutoRaceV4 = false, AutoTrial = false,
    AutoSeaBeast = false, AutoRumbling = false, AutoShipRaid = false,
    -- Items & Puzzles
    AutoSoulGuitar = false, AutoCDK = false, AutoSaber = false, AutoPole = false, AutoGodhuman = false,
    AutoYama = false, AutoTushita = false, AutoRengoku = false, AutoMidnightBlade = false,
    AutoFarmMaterial = false, SelectedMaterial = "Dragon Scale",
    AutoBuySaber = false, AutoBuyPole = false, AutoBuyGodhuman = false, AutoBuyCDK = false, AutoBuySoulGuitar = false,
    AutoBuyFightingStyle = false, AutoBuyLegendarySword = false, AutoBuyAccessory = false,
    -- Raid Settings
    AutoRaid = false, AutoBuyChip = false, AutoStartRaid = false, AutoNextIsland = false, AutoAwaken = false, KillAuraRaid = false,
    AutoRaidHop = false, RaidHopDelay = 60,
    AutoDungeon = false,
    SelectedRaid = "Flame",
    -- PvP Settings
    SafeMode = true, AimAssist = false, AutoCombo = false, SelectedFruit = "Dough", PredictMovement = true, SelectedPlayer = "None", AutoBounty = false,
    BountyThreshold = 20,
    BountyHop = false,
    KillAura = false, KillAuraDistance = 60, AttackAura = false, WalkOnWater = false, InfGeppo = true, FlyHack = false,
    WalkSpeed = 16, JumpPower = 50, InfEnergy = true,
    AimBot = false, PlayerESP = false, BoxESP = false, LineESP = false,
    -- Teleport Settings
    SelectedIsland = "None",
    -- Visual (ESP)
    EspPlayers = false, EspFruits = false, EspChests = false, EspFlower = false, FullBright = false, FPSBooster = false, NoClip = false, EspBox = false, EspTracer = false,
    AutoChest = false,
    LowGraphics = false, RemoveTextures = false, RemoveShadows = false, WhiteScreen = false,
    RemoveFog = false,
    -- Misc
    AutoRejoin = true, AntiAFK = true, WebhookEnabled = false, 
    AutoBuyFruit = false, AutoStoreFruit = true, AutoFruitFinder = false, AutoSnipe = false,
    SnipeFruits = {"Dough", "Kitsune", "Leopard", "Dragon", "Spirit", "Control", "Venom", "Shadow"},
    SnipeFruitsRaw = "Dough,Kitsune,Leopard,Dragon,Spirit,Control,Venom,Shadow",
    AutoBringFruit = false, AutoGacha = false,
    ThemeColor = Color3.fromRGB(0, 255, 150), CurrentTheme = "Default",
    KillSwitchKey = Enum.KeyCode.RightControl
}

SettingsModule.Themes = {
    ["Default"] = Color3.fromRGB(0, 255, 150),
    ["Neon Red"] = Color3.fromRGB(255, 0, 50),
    ["Deep Blue"] = Color3.fromRGB(0, 100, 255),
    ["Golden"] = Color3.fromRGB(255, 200, 0),
    ["Purple Night"] = Color3.fromRGB(150, 0, 255)
}

function SettingsModule.Save()
    pcall(function()
        if writefile then 
            writefile("MakitoHub_Configs.json", HttpService:JSONEncode(_G.Settings or SettingsModule.Values)) 
        end
    end)
end

function SettingsModule.Load()
    pcall(function()
        if isfile and isfile("MakitoHub_Configs.json") then
            local decoded = HttpService:JSONDecode(readfile("MakitoHub_Configs.json"))
            for k, v in pairs(decoded) do 
                if _G.Settings then
                    _G.Settings[k] = v 
                else
                    SettingsModule.Values[k] = v
                end
            end
        end
    end)
    -- FORCE DISABLE CRITICALS ON START
    local target = _G.Settings or SettingsModule.Values
    local disabled = {
        "AutoFarm", "AutoQuest", "FastAttack", "BringMobs", "AutoFarmNearest",
        "KillAura", "AimBot", "AutoBounty", "AutoCombo", "AutoStats",
        "AutoChest", "AutoCollectFruit", "AutoBringFruit", "AutoFruitFinder",
        "AutoSnipe", "AutoBuyFruit", "AutoGacha", "AutoBuyChip",
        "AutoStartRaid", "AutoDungeon", "AutoNextIsland", "AutoAwaken",
        "AutoSeaBeast", "AutoRumbling", "AutoShipRaid", "AutoLeviathan",
        "AutoKitsune", "AutoTerrorShark", "AutoEliteHunter", "AutoFactory",
        "AutoDoughKing", "AutoCakePrince", "AutoBuyFightingStyle",
        "AutoBuyLegendarySword", "AutoBuyAccessory", "AutoNextSea",
        "AutoSoulGuitar", "AutoCDK", "AutoGodhuman", "AutoKickMod",
        "AntiAFK", "ChatSpam"
    }
    for _, name in ipairs(disabled) do
        target[name] = false
    end
end

return SettingsModule
