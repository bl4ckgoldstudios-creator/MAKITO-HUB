--!strict
local SettingsModule = {}
local HttpService = game:GetService("HttpService")

-- Caminho do arquivo de configuração persistente
local CONFIG_PATH = "makito_config.json"

-- Valores padrão do Hub (V11.0 - FULL PRO)
local DEFAULT_VALUES = {
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
    
    -- Segurança & Atualizações (NEW)
    StealthSecurity = true,
    AutoUpdateEnabled = true,
    EncryptedLogs = true,
    
    -- Atalhos de Teclado (NEW)
    Keybinds = {
        ToggleHub = "RightControl",
        ToggleKillAura = "K",
        ToggleAutoFarm = "F",
        ToggleESP = "E",
    },
    
    -- Resolução & Layout (NEW)
    UIScale = 1.0,
    UIPosition = {X = 0.1, Y = 0.1},
}

SettingsModule.Values = {}

SettingsModule.Themes = {
    ["Default"] = Color3.fromRGB(0, 255, 150),
    ["Neon Red"] = Color3.fromRGB(255, 0, 50),
    ["Deep Blue"] = Color3.fromRGB(0, 100, 255),
    ["Golden"] = Color3.fromRGB(255, 200, 0),
    ["Purple Night"] = Color3.fromRGB(150, 0, 255)
}

-- Serializa valores para JSON (converte Color3 para strings)
local function SerializeForSave(data)
    local result = {}
    for key, value in pairs(data) do
        if type(value) == "Color3" then
            result[key] = string.format("RGB(%d,%d,%d)", value.R*255, value.G*255, value.B*255)
        elseif type(value) ~= "function" then
            result[key] = value
        end
    end
    return result
end

-- Deserializa valores do JSON
local function DeserializeFromSave(data)
    local result = {}
    for key, value in pairs(data) do
        if type(value) == "string" and value:sub(1, 4) == "RGB(" then
            -- Parse Color3 from "RGB(r,g,b)"
            local r, g, b = value:match("RGB%((%d+),(%d+),(%d+)%)")
            if r and g and b then
                result[key] = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
            end
        else
            result[key] = value
        end
    end
    return result
end

function SettingsModule.Save()
    local success, err = pcall(function()
        local toSave = SerializeForSave(SettingsModule.Values)
        writefile(CONFIG_PATH, HttpService:JSONEncode(toSave))
        print("✅ [MAKITO] Configurações salvas!")
    end)
    
    if not success then
        warn("❌ [MAKITO] Falha ao salvar configurações:", err)
    end
end

function SettingsModule.Load()
    local success, content = pcall(readfile, CONFIG_PATH)
    
    if success and content then
        local ok, data = pcall(HttpService.JSONDecode, HttpService, content)
        if ok then
            -- Mescla os dados carregados com o padrão
            SettingsModule.Values = {}
            for key, defaultValue in pairs(DEFAULT_VALUES) do
                SettingsModule.Values[key] = data[key] ~= nil and DeserializeFromSave(data)[key] or defaultValue
            end
            print("✅ [MAKITO] Configurações carregadas!")
            return true
        end
    end
    
    -- Se falhar, usa os valores padrão
    SettingsModule.Values = table.clone(DEFAULT_VALUES)
    print("ℹ️ [MAKITO] Usando configurações padrão")
    return false
end

-- Inicializa o módulo
SettingsModule.Load()

return SettingsModule

