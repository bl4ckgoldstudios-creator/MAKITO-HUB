local SettingsModule = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

_G.MakitoHubRunning = true

SettingsModule.Values = {
    -- Combate
    FastAttack = false, FastAttackSpeed = 0.01, KillAura = false, KillAuraDistance = 150,
    AimBot = false, Aimbot = false, AutoCombo = false, AutoBounty = false, AutoPvP = false,
    AutoHaki = false, AutoKen = false, AutoEquipWeapon = true, AutoRaceSkill = false,
    Weapon = "Melee", SelectedFruit = "Dough",

    -- Farm
    AutoFarm = false, AutoFarmLevel = false, AutoFarmNearest = false, AutoFarmBoss = false,
    AutoFarmEliteHunter = false, AutoFarmMaterials = false, AutoFarmMastery = false,
    AutoFarmBones = false, AutoFarmFragments = false, AutoFarmChests = false,
    AutoFarmSeaEvents = false, AutoFarmPirateRaid = false, AutoFarmFactory = false,
    AutoFarmCastleRaid = false, AutoFarmMaterial = false, SelectedMaterial = "Dragon Scale",
    BringMobs = false, Distance = 10, TweenSpeed = 350, MasteryHealth = 20, MasteryWeapon = "Sword",

    -- Frutas
    AutoFruitSniper = false, AutoCollectFruits = false, AutoFruitESP = false,
    AutoStoreFruits = true, AutoBuyRandomFruit = false, AutoFindMirageIsland = false,
    AutoGearFarm = false, AutoCollectFruit = false, AutoBringFruit = false, AutoFruitFinder = false,
    AutoSnipe = false, AutoGacha = false, AutoBuyFruit = false, AutoStoreFruit = true,
    SnipeFruits = {"Dough", "Kitsune", "Leopard", "Dragon", "Spirit", "Control", "Venom", "Shadow"},
    SnipeFruitsRaw = "Dough,Kitsune,Leopard,Dragon,Spirit,Control,Venom,Shadow",

    -- Esp / Visual
    PlayerESP = false, NpcESP = false, BossESP = false, ChestESP = false,
    FlowerESP = false, IslandESP = false, FruitESP = false, DevilFruitNotifier = false,
    DistanceDisplay = true, HealthDisplay = true, EspPlayers = false, EspFruits = false,
    EspChests = false, EspFlower = false, EspBox = false, EspTracer = false,
    EspMaxDistance = 2500, EspTextSize = 13, EspShowDistance = true, EspShowHealth = true,
    EspFilterName = "", EspBossOnly = false,
    EspPlayerColor = { R = 100, G = 200, B = 255 },
    EspNpcColor = { R = 255, G = 80, B = 80 },
    EspChestColor = { R = 255, G = 200, B = 0 },
    EspFruitColor = { R = 255, G = 60, B = 60 },
    EspFlowerColor = { R = 255, G = 120, B = 255 },

    -- Teleportes
    SelectedIsland = "None",

    -- Missões e Progressão
    AutoQuest = false, AutoNextSea = false, AutoRaceV2 = false, AutoRaceV3 = false,
    AutoRaceV4 = false, AutoGodHuman = false, AutoSoulGuitar = false, AutoCDK = false,
    AutoTushita = false, AutoYama = false, AutoSharkAnchor = false,
    AutoGodhuman = false, AutoSaber = false, AutoPole = false, AutoMidnightBlade = false,
    AutoRengoku = false, AutoHallowScythe = false, AutoObservationV2 = false,
    AutoBuyAbilities = false,

    -- Estilos de Luta Individual
    AutoBlackLeg = false, AutoElectro = false, AutoFishmanKarate = false, AutoDragonBreath = false,
    AutoSuperhuman = false, AutoDeathStep = false, AutoSharkmanKarate = false, AutoElectricClaw = false,
    AutoDragonTalon = false, AutoGodhumanIndividual = false,

    -- Eventos
    AutoLeviathan = false, AutoTerrorShark = false, AutoFrozenDimension = false,
    AutoKitsuneShrine = false, AutoPrehistoricIsland = false, AutoVolcanoEvent = false,
    AutoSeaEvent = false, AutoMirage = false, AutoFindGear = false, AutoMirageLever = false,
    AutoSeaBeast = false, AutoRumbling = false, AutoShipRaid = false,

    -- Utilidades
    AntiAFK = false, ServerHop = false, Rejoin = false, FPSBoost = false,
    WhiteScreen = false, RemoveEffects = false, RemoveFog = false, AutoRedeemCodes = false,
    AutoStats = false, SelectedStat = "Melee", AntiModerator = false, PerformanceMode = false,
    AutoKickMod = false, AutoModeratorHop = true, AutoModeratorShutdown = false,
    WalkSpeed = 16, JumpPower = 50, InfEnergy = true, InfGeppo = true, WalkOnWater = false,
    LowGraphics = false, RemoveTextures = false, RemoveShadows = false, FullBright = false,
    FPSBooster = false, NoClip = false,

    -- Raids
    AutoRaid = false, AutoBuyChip = false, AutoSelectRaid = "Flame", AutoAwakening = false,
    AutoCompleteRaid = false, AutoStartRaid = false, AutoNextIsland = false, KillAuraRaid = false,
    AutoRaidHop = false, RaidHopDelay = 60, AutoDungeon = false, AutoDungeonV2 = false,
    AutoCollectTrinkets = false, AutoEquipBestTrinket = true, AutoLucienQuest = false,
    SelectedRaid = "Flame", AutoAwaken = false, RaidMode = "Above", -- "Above" ou "Below"

    -- Loja
    AutoBuyFightingStyles = false, AutoBuyWeapons = false, AutoBuyHaki = false,
    AutoBuyAbilities = false, AutoBuySwords = false, AutoBuyFightingStyle = false,
    AutoBuyLegendarySword = false, AutoBuyAccessory = false,

    -- Especiais
    AutoMirage = false, AutoBlueGear = false, AutoTrial = false, AutoRaceAwakening = false,
    AutoDoughKing = false, AutoRipIndra = false, AutoDarkbeard = false, AutoLaw = false,
    AutoBeautifulPirate = false, AutoCakePrince = false, AutoEliteHunter = false,
    AutoFactory = false, AutoBoss = false, AutoBossHop = true,

    -- Misc
    WebhookEnabled = false, WebhookURL = "",
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
        if not writefile then return end
        local source = _G.Settings or SettingsModule.Values
        local toSave = {}
        for k, v in pairs(source) do
            local valueType = typeof(v)
            if valueType ~= "Color3" and valueType ~= "EnumItem" and valueType ~= "Instance" then
                toSave[k] = v
            end
        end
        writefile("MakitoHub_Configs.json", HttpService:JSONEncode(toSave))
    end)
end

function SettingsModule.Load()
    pcall(function()
        if isfile and isfile("MakitoHub_Configs.json") then
            local decoded = HttpService:JSONDecode(readfile("MakitoHub_Configs.json"))
            local target = _G.Settings or SettingsModule.Values
            for k, v in pairs(decoded) do
                target[k] = v
            end
            if target.CurrentTheme and SettingsModule.Themes[target.CurrentTheme] then
                target.ThemeColor = SettingsModule.Themes[target.CurrentTheme]
            end
        end
    end)
    -- FORCE DISABLE CRITICALS ON START
    local target = _G.Settings or SettingsModule.Values
    local disabled = {
        "AutoFarm", "AutoFarmLevel", "AutoQuest", "FastAttack", "BringMobs", "AutoFarmNearest",
        "KillAura", "AimBot", "Aimbot", "AutoBounty", "AutoCombo", "AutoStats",
        "AutoChest", "AutoCollectFruit", "AutoBringFruit", "AutoFruitFinder",
        "AutoSnipe", "AutoGacha", "AutoBuyChip", "AutoRaid",
        "AutoStartRaid", "AutoDungeon", "AutoNextIsland", "AutoAwaken",
        "AutoSeaBeast", "AutoRumbling", "AutoShipRaid", "AutoLeviathan",
        "AutoKitsune", "AutoTerrorShark", "AutoEliteHunter", "AutoFactory",
        "AutoDoughKing", "AutoCakePrince", "AutoBuyFightingStyle",
        "AutoBuyLegendarySword", "AutoBuyAccessory", "AutoNextSea",
        "AutoSoulGuitar", "AutoCDK", "AutoGodhuman", "AutoKickMod",
        "AntiAFK", "ChatSpam", "AutoRedeemCodes", "AutoPvP",
        "AutoHallowScythe", "AutoBlackLeg", "AutoElectro", "AutoFishmanKarate",
        "AutoDragonBreath", "AutoSuperhuman", "AutoDeathStep", "AutoSharkmanKarate",
        "AutoElectricClaw", "AutoDragonTalon", "AutoGodhumanIndividual"
    }
    for _, name in ipairs(disabled) do
        target[name] = false
    end
end

return SettingsModule
