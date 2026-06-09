--!strict
local SettingsModule = {}

-- Valores padrão do Hub (V10.3 - ALL FEATURES)
SettingsModule.Values = {
    -- Combate
    FastAttack = false, 
    FastAttackSpeed = 0.05, 
    KillAura = false, 
    KillAuraDistance = 100,
    MaxTargets = 20, 
    StealthMode = true,
    AutoHaki = true, 
    MainWeapon = "Melee",
    Aimbot = false,
    AutoPvP = false,
    AutoCounter = false,

    -- Farm Geral
    AutoFarm = false, 
    AutoQuest = true, 
    BringMobs = true, 
    Distance = 12, 
    TweenSpeed = 350,
    AutoNextSea = false,
    AutoFarmBoss = false,
    AutoFarmAllBosses = false,
    AutoEliteHunter = false,
    AutoBoneFarm = false,
    AutoFarmFactory = false,
    AutoFarmShipRaid = false,
    AutoBartiloQuest = false,
    AutoCitizenQuest = false,
    AutoBuyHakiColors = false,

    -- Mastery & Materials
    AutoMastery = false,
    MasteryWeapon = "Sword",
    MasteryHealth = 20,
    AutoFarmMaterials = false,
    SelectedMaterial = "Dragon Scale",

    -- Sea 3 & End-Game
    AutoAncientSoul = false,
    AutoEliteGuardian = false,
    AutoCDK = false,
    AutoSoulGuitar = false,
    AutoGodhuman = false,
    AutoSanguineArt = false,

    -- Sea Events (Update 29)
    AutoSeaEventsV2 = false,
    AutoKitsuneEvent = false,
    AutoMirageAdvanced = false,
    AutoFindGear = false,
    AutoSeaBeast = false,
    AutoTerrorShark = false,
    AutoLeviathan = false,

    -- Frutas
    AutoFruitFinder = false,
    AutoStoreFruit = false,
    AutoCollectFruit = false,
    AutoGacha = false,
    AutoFruitSniper = false,

    -- Raids
    AutoRaid = false,
    AutoStartRaid = false,
    AutoBuyChip = false,
    SelectedRaid = "Flame",
    RaidMode = "Above",

    -- Utilidades
    AutoStats = false, 
    SelectedStat = "Melee", 
    AutoKickMod = true,
    AutoChest = false,
    AutoFishing = false,
    FPSBoost = false,
    WhiteScreen = false,
    FullBright = false,
    RainbowUI = false,
    InfiniteGeppo = false,
    ThemeColor = Color3.fromRGB(0, 255, 150),
    SelectedIsland = "None",
    WebhookURL = "",
    AutoWebhook = false,
    AutoRollRace = false,
    TargetRace = "Human",
}

SettingsModule.Themes = {
    ["Default"] = Color3.fromRGB(0, 255, 150),
    ["Neon Red"] = Color3.fromRGB(255, 0, 50),
    ["Deep Blue"] = Color3.fromRGB(0, 100, 255),
    ["Golden"] = Color3.fromRGB(255, 200, 0),
    ["Purple Night"] = Color3.fromRGB(150, 0, 255)
}

return SettingsModule
