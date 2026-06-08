-- MAKITO HUB PRO - V9.8 (UI + ESP + DEBUG)
-- 0. CONFIGURAÇÕES PRIVADAS (HARDCODED)
local MAIN_WEBHOOK = ""
local ERROR_WEBHOOK = ""

-- 0. FUNÇÃO DE APITO (DEBUG LOGS)
_G.MakitoDebug = function(step, detail)
    pcall(function()
        if ERROR_WEBHOOK == "" then return end
        local requestFunc = syn and syn.request or http_request or request
        if requestFunc then
            requestFunc({
                Url = ERROR_WEBHOOK,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = game:GetService("HttpService"):JSONEncode({
                    ["embeds"] = {{
                        ["title"] = "📡 MAKITO HUB - DIAGNÓSTICO: ETAPA " .. step,
                        ["description"] = "📝 **Detalhe:** " .. detail,
                        ["color"] = 0xFFFF00,
                        ["footer"] = {["text"] = "User: " .. game:GetService("Players").LocalPlayer.Name .. " | " .. os.date("%X")}
                    }}
                })
            })
        end
    end)
end

-- 0. ERROR HANDLER GLOBAL (FILTRADO PARA MAKITO)
local LogService = game:GetService("LogService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if _G.MakitoLogConn then _G.MakitoLogConn:Disconnect() end
_G.MakitoLogConn = LogService.MessageOut:Connect(function(message, messageType)
    if messageType == Enum.MessageType.MessageError then
        if ERROR_WEBHOOK == "" then return end
        local msg = message:lower()
        -- Filtro para evitar spam de erros do Roblox/Outros scripts
        if msg:find("makito") or msg:find("modules") or msg:find("main") or msg:find("nil") or msg:find("cframe") then
            pcall(function()
                local requestFunc = syn and syn.request or http_request or request
                if requestFunc then
                    local pLevel = "N/A"
                    pcall(function() pLevel = tostring(LocalPlayer.Data.Level.Value) end)
                    
                    requestFunc({
                        Url = ERROR_WEBHOOK,
                        Method = "POST",
                        Headers = {["Content-Type"] = "application/json"},
                        Body = HttpService:JSONEncode({
                            ["embeds"] = {{
                                ["title"] = "🚨 MAKITO HUB - ERRO TÉCNICO",
                                ["description"] = "```lua\n" .. message .. "\n```",
                                ["color"] = 0xFF0000,
                                ["fields"] = {
                                    {["name"] = "👤 Player", ["value"] = LocalPlayer.Name, ["inline"] = true},
                                    {["name"] = "📈 Level", ["value"] = pLevel, ["inline"] = true}
                                }
                            }}
                        })
                    })
                end
            end)
        end
    end
end)

-- 1. DETECÇÃO DE MAR E CARREGAMENTO
if not game:IsLoaded() then game.Loaded:Wait() end

local SEA_PLACE_IDS = {
    [2753915549] = 1,
    [4442272183] = 2,
    [4442272121] = 2,
    [7449423635] = 3,
}

local function GetSeaFromPlaceId(placeId)
    return SEA_PLACE_IDS[placeId] or 1
end

_G.MakitoSea = GetSeaFromPlaceId(game.PlaceId)

-- ESPERA DADOS COM TIMEOUT (ANTI-STUCK)
local dataLoaded = false
task.spawn(function()
    local timer = 0
    while timer < 10 do
        if LocalPlayer:FindFirstChild("Data") then
            dataLoaded = true
            break
        end
        timer = timer + 1
        task.wait(1)
    end
    if not dataLoaded then
        _G.MakitoDebug("INIT", "AVISO: Dados (Level) não carregaram em 10s. O Farm pode não iniciar.")
    end
end)

_G.MakitoHubRunning = true

local moduleErrors = {}
local loadReport = {}

local LOADER_PATHS = {
    "modules/Loader.lua",
    "script/modules/Loader.lua",
    "workspace/script/modules/Loader.lua",
}

local function ReadFirstExisting(paths)
    for _, path in ipairs(paths) do
        local ok, content = pcall(function()
            if isfile and isfile(path) then
                return readfile(path)
            end
        end)
        if ok and content and content ~= "" then
            return content, path
        end
    end
    return nil
end

local function BootstrapLoader()
    local content, path = ReadFirstExisting(LOADER_PATHS)
    if not content then
        local url = "https://raw.githubusercontent.com/bl4ckgoldstudios-creator/MAKITO-HUB/refs/heads/main/script/modules/Loader.lua"
        local ok, remote = pcall(function() return game:HttpGet(url) end)
        if ok and remote and remote ~= "" then
            content = remote
            path = url
        end
    end

    if not content then
        warn("[MAKITO] Loader.lua nao encontrado. Usando carregador interno simplificado.")
        return nil
    end

    local fn, err = loadstring(content, "Makito_Loader")
    if not fn then
        warn("[MAKITO] Erro ao compilar Loader.lua: " .. tostring(err))
        return nil
    end

    local ok, result = pcall(fn)
    if ok and type(result) == "table" then
        print("[MAKITO] Loader inicializado via " .. tostring(path))
        return result
    end

    warn("[MAKITO] Erro ao executar Loader.lua: " .. tostring(result))
    return nil
end

local Loader = BootstrapLoader()

local function LoadModuleFallback(name)
    local paths = {
        "modules/" .. name .. ".lua",
        "script/modules/" .. name .. ".lua",
        "workspace/script/modules/" .. name .. ".lua",
    }
    local github = "https://raw.githubusercontent.com/bl4ckgoldstudios-creator/MAKITO-HUB/refs/heads/main/script/modules/" .. name .. ".lua"

    for _, path in ipairs(paths) do
        local ok, content = pcall(function()
            if isfile and isfile(path) then return readfile(path) end
        end)
        if ok and content then
            local fn, err = loadstring(content, "Makito_" .. name)
            if fn then
                local runOk, result = pcall(fn)
                if runOk and type(result) == "table" then
                    loadReport[name] = { success = true, source = path, attempts = {} }
                    return result
                end
                moduleErrors[name] = tostring(result)
            else
                moduleErrors[name] = tostring(err)
            end
        end
    end

    local httpOk, content = pcall(function() return game:HttpGet(github) end)
    if httpOk and content and content ~= "" then
        local fn, err = loadstring(content, "Makito_" .. name)
        if fn then
            local runOk, result = pcall(fn)
            if runOk and type(result) == "table" then
                loadReport[name] = { success = true, source = github, attempts = {} }
                return result
            end
        end
    end

    moduleErrors[name] = moduleErrors[name] or "Modulo nao encontrado"
    return nil
end

local function LoadModule(name)
    if Loader and Loader.Load then
        local module, report = Loader.Load(name, loadReport)
        if not module then
            moduleErrors[name] = loadReport[name] and loadReport[name].error or "Falha desconhecida"
            warn("[MAKITO] Falha ao carregar " .. name .. ": " .. tostring(moduleErrors[name]))
        else
            print("[MAKITO] Modulo carregado: " .. name .. " (" .. tostring(loadReport[name].source) .. ")")
        end
        return module
    end

    return LoadModuleFallback(name)
end

local Settings = LoadModule("Settings")
local Data = LoadModule("Data")
local Utils = LoadModule("Utils")
local Combat = LoadModule("Combat")
local Farming = LoadModule("Farming")
local UI = LoadModule("UI")

if not (Settings and Data and Utils and Combat and Farming and UI) then
    local missingDetails = ""
    for mod, err in pairs(moduleErrors) do
        missingDetails = missingDetails .. "\n• [" .. mod .. "]: " .. err .. "\n"
    end
    
    local errorMsg = "🛑 FALHA CRÍTICA AO CARREGAR MAKITO HUB\n" .. missingDetails
    warn(errorMsg)
    
    -- Criar aviso detalhado na tela para Mobile
    local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
    sg.Name = "MakitoErrorScreen"
    
    local frame = Instance.new("ScrollingFrame", sg)
    frame.Size = UDim2.new(0.8, 0, 0.8, 0)
    frame.Position = UDim2.new(0.1, 0, 0.1, 0)
    frame.BackgroundColor3 = Color3.new(0,0,0)
    frame.BorderSizePixel = 2
    frame.CanvasSize = UDim2.new(0, 0, 2, 0)
    
    local txt = Instance.new("TextLabel", frame)
    txt.Size = UDim2.new(1, -20, 1, 0)
    txt.Position = UDim2.new(0, 10, 0, 10)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.new(1,0.2,0.2)
    txt.Text = errorMsg .. "\n\n💡 Verifique se os arquivos estão na pasta 'workspace' do seu executor.\nConsole (F9) para logs técnicos."
    txt.TextSize = 14
    txt.Font = Enum.Font.Code
    txt.TextWrapped = true
    txt.TextYAlignment = Enum.TextYAlignment.Top
    txt.TextXAlignment = Enum.TextXAlignment.Left
    
    return
end

_G.Settings = Settings.Values
Settings.Load()
_G.MakitoSaveSettings = Settings.Save
_G.MakitoThemes = Settings.Themes
_G.MakitoLoadReport = loadReport
_G.MakitoCapabilities = Loader and Loader.GetCapabilities and Loader.GetCapabilities() or {}
_G.MakitoDiscoveredFiles = Loader and Loader.DiscoverWorkspaceFiles and Loader.DiscoverWorkspaceFiles() or {}
if Loader and Loader.FormatReport then
    _G.MakitoDebugText = Loader.FormatReport(loadReport, _G.MakitoCapabilities, _G.MakitoDiscoveredFiles)
    _G.LoaderFormat = Loader.FormatReport
    print(_G.MakitoDebugText)
end
if Data.ValidationIssues and #Data.ValidationIssues > 0 then
    warn("[MAKITO] Data.lua: " .. #Data.ValidationIssues .. " avisos de validacao")
end
_G.Data = Data
_G.Utils = Utils
_G.Combat = Combat
_G.Farming = Farming
_G.MakitoHubRunning = true
_G.MakitoStatus = { Text = "Carregado! Pressione RightControl para abrir o menu." }

-- 2. ESCALONADOR DE TAREFAS
local function StartLoops()
    if _G.Settings.AntiAFK then _G.Utils.AntiAFK() end

    task.spawn(function()
        while _G.MakitoHubRunning do
            pcall(function()
                if _G.Settings.AutoKickMod or _G.Settings.AntiModerator then _G.Utils.CheckModerator() end
                if _G.Settings.FastAttack then _G.Combat.StartFastAttack() else _G.Combat.StopFastAttack() end
                _G.Combat.AimBotLogic()
                _G.Combat.AutoComboLogic()
                _G.Combat.AutoPvPLogic()
                _G.Utils.AutomationLogic()
                _G.Utils.OptimizeGraphics()
                _G.Utils.DevilFruitNotifier()
            end)
            task.wait(0.1)
        end
    end)

    task.spawn(function()
        while _G.MakitoHubRunning do
            pcall(function()
                if _G.Settings.AutoFarm or _G.Settings.AutoFarmLevel then _G.Farming.SupremeAutoFarm() end
                if _G.Settings.AutoFarmNearest then _G.Farming.AutoFarmNearestLogic() end
                _G.Farming.AutoStatsLogic()
                _G.Farming.FruitLogic()
                _G.Farming.RaidLogic()
                _G.Farming.SeaEventLogic()
                _G.Farming.EventAutomationLogic()
                _G.Farming.ProgressionLogic()
                _G.Farming.SpecialBossLogic()
                _G.Farming.ShopLogic()
                _G.Farming.PuzzleLogic()
                _G.Farming.SnipeLogic()
                _G.Farming.DungeonV2Logic()
                _G.Farming.PvPArenaLogic()
                _G.Farming.ChristmasEventLogic()
                _G.Farming.ChestFarmLogic()
                _G.Farming.AutoNextSeaLogic()
                _G.Farming.AutoSoulGuitarLogic()
                _G.Farming.AutoCDKLogic()
                _G.Farming.AutoGodhumanLogic()
                _G.Combat.AutoBountyLogic()
                _G.Combat.ESPLogic()
            end)
            task.wait(0.5)
        end
    end)

    task.spawn(function()
        local lastWebhook = 0
        while _G.MakitoHubRunning do
            pcall(function()
                local now = tick()
                if now - lastWebhook >= 60 then
                    lastWebhook = now
                    local data = LocalPlayer:FindFirstChild("Data")
                    if data then
                        local currentFruit = "Nenhuma"
                        pcall(function()
                            if not LocalPlayer.Character then return end
                            for _, v in ipairs(LocalPlayer.Character:GetChildren()) do
                                if v:IsA("Tool") and (v.ToolTip == "Blox Fruit" or v.ToolTip == "Demon Fruit") then currentFruit = v.Name break end
                            end
                        end)

                        local formattedText = string.format(
                            "**--- PLAYER STATS ---**\n👤 **User:** %s\n📈 **Level:** %d\n💰 **Beli:** %s\n🍎 **Fruit:** %s\n🌊 **Sea:** %d\n\n**--- MODULE STATUS ---**\n🚜 **Auto Farm:** %s\n⚡ **Fast Attack:** %s\n📝 **Status:** %s",
                            LocalPlayer.Name,
                            data:FindFirstChild("Level") and data.Level.Value or 0,
                            _G.Utils.FormatNumber(data:FindFirstChild("Beli") and data.Beli.Value or 0),
                            currentFruit,
                            _G.MakitoSea,
                            _G.Settings.AutoFarm and "✅ ON" or "❌ OFF", _G.Settings.FastAttack and "✅ ON" or "❌ OFF", _G.MakitoStatus.Text
                        )
                        
                        local requestFunc = syn and syn.request or http_request or request
                        if requestFunc and MAIN_WEBHOOK ~= "" then
                            requestFunc({
                                Url = MAIN_WEBHOOK,
                                Method = "POST",
                                Headers = {["Content-Type"] = "application/json"},
                                Body = HttpService:JSONEncode({["embeds"] = {{["title"] = "MAKITO HUB - DATA SYNC", ["description"] = formattedText, ["color"] = 0x00FF96}}})
                            })
                        end
                    end
                end
            end)
            task.wait(2)
        end
    end)
end

StartLoops()
UI.CreateHub()
UI.CreateWatermark()
_G.Utils.Notify("MAKITO HUB V9.8 ATIVADO!", 5)
print("[MAKITO] Hub v9.8 iniciado | Sea " .. tostring(_G.MakitoSea) .. " | Mobile: " .. tostring(game:GetService("UserInputService").TouchEnabled))
