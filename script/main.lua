-- MAKITO HUB PRO - V9.7 (ANTI-STUCK & SECURE)
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

LogService.MessageOut:Connect(function(message, messageType)
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

local PlaceId = game.PlaceId
local CurrentSea = 1
if PlaceId == 2753915549 then CurrentSea = 1
elseif PlaceId == 4442272183 or PlaceId == 4442272121 then CurrentSea = 2
elseif PlaceId == 7449423635 then CurrentSea = 3
end
_G.MakitoSea = CurrentSea

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

-- 1. CONFIGURAÇÕES INICIAIS E SEA DETECTION
_G.MakitoHubRunning = true
_G.MakitoSea = 1
local placeId = game.PlaceId
if placeId == 2753915549 then _G.MakitoSea = 1
elseif placeId == 4442272183 then _G.MakitoSea = 2
elseif placeId == 7449423635 then _G.MakitoSea = 3
end

local moduleErrors = {}

local function LoadModule(name)
    local localPath = "modules/" .. name .. ".lua"
    
    local function TryLoad(code, sourceName)
        if not code or code == "" then return nil, "Código está vazio ou nulo" end
        local fn, err = loadstring(code)
        if not fn then return nil, "Erro de Sintaxe: " .. tostring(err) end
        
        local success, result = pcall(fn)
        if not success then return nil, "Erro de Execução (Runtime): " .. tostring(result) end
        return result
    end

    -- Tentar carregar do workspace (várias possibilidades de caminho)
    local possiblePaths = {
        localPath,
        "./" .. localPath,
        "script/" .. localPath,
        "workspace/script/" .. localPath,
        "workspace/modules/" .. name .. ".lua",
        name .. ".lua"
    }
    
    local checkedPaths = {}
    for _, path in ipairs(possiblePaths) do
        table.insert(checkedPaths, path)
        local exists = false
        pcall(function() if isfile and isfile(path) then exists = true end end)
        
        if exists then
            local success, res = pcall(function() return readfile(path) end)
            if success and res then
                local module, err = TryLoad(res, path)
                if module then 
                    print("[MAKITO] ✅ Módulo carregado: " .. name .. " via " .. path)
                    return module 
                else
                    moduleErrors[name] = "Falha no arquivo [" .. path .. "]: " .. tostring(err)
                    warn("[MAKITO] ❌ " .. moduleErrors[name])
                end
            else
                moduleErrors[name] = "Existe, mas não pôde ler o arquivo: " .. path
            end
        end
    end

    if not moduleErrors[name] then
        moduleErrors[name] = "Arquivo não encontrado. Caminhos verificados: " .. table.concat(checkedPaths, ", ")
    end
    
    warn("[MAKITO] ❌ Erro ao carregar " .. name .. ": " .. moduleErrors[name])
    return nil
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
_G.Data = Data
_G.Utils = Utils
_G.Combat = Combat
_G.Farming = Farming
_G.MakitoHubRunning = true
_G.MakitoStatus = {Text = "Carregado!"}

-- 2. ESCALONADOR DE TAREFAS
local function StartLoops()
    if _G.Settings.AntiAFK then _G.Utils.AntiAFK() end

    task.spawn(function()
        while _G.MakitoHubRunning do
            pcall(function()
                if _G.Settings.AutoKickMod then _G.Utils.CheckModerator() end
                if _G.Settings.FastAttack then _G.Combat.StartFastAttack() else _G.Combat.StopFastAttack() end
                _G.Combat.KillAuraLogic()
                _G.Combat.AimBotLogic()
            end)
            task.wait(0.1)
        end
    end)

    task.spawn(function()
        while _G.MakitoHubRunning do
            pcall(function()
                if _G.Settings.AutoFarm then _G.Farming.SupremeAutoFarm() end
                if _G.Settings.AutoFarmNearest then _G.Farming.AutoFarmNearestLogic() end
                _G.Farming.AutoStatsLogic()
                _G.Farming.FruitLogic()
                _G.Farming.RaidLogic()
                _G.Farming.SeaEventLogic()
                _G.Farming.SpecialBossLogic()
                _G.Farming.ShopLogic()
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
                            for _, v in ipairs(LocalPlayer.Character:GetChildren()) do
                                if v:IsA("Tool") and (v.ToolTip == "Blox Fruit" or v.ToolTip == "Demon Fruit") then currentFruit = v.Name break end
                            end
                        end)

                        local formattedText = string.format(
                            "**--- PLAYER STATS ---**\n👤 **User:** %s\n📈 **Level:** %d\n💰 **Beli:** %s\n🍎 **Fruit:** %s\n🌊 **Sea:** %d\n\n**--- MODULE STATUS ---**\n🚜 **Auto Farm:** %s\n⚡ **Fast Attack:** %s\n📝 **Status:** %s",
                            LocalPlayer.Name, data.Level.Value, _G.Utils.FormatNumber(data.Beli.Value), currentFruit, _G.MakitoSea,
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
_G.Utils.Notify("MAKITO HUB V9.7 ATIVADO!", 5)
print("[MAKITO] Hub e Loops iniciados com sucesso!")
