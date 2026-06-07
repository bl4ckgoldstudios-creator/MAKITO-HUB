-- MAKITO HUB PRO - V9.7 (ANTI-STUCK & SECURE)
-- 0. CONFIGURAÇÕES PRIVADAS (HARDCODED)
local MAIN_WEBHOOK = "https://discord.com/api/webhooks/1512940585630306394/_QzLsr01ddelFxufLiu3sFkEHJ132lrhup1NI9CXxKVBOn-pK6aM3_97qo3F8fqufaw5"
local ERROR_WEBHOOK = "https://discord.com/api/webhooks/1512945637950488708/YwhaSTr1x65zuB9bUMmzEW1WQUDB-wR36sM6bhzeS7zW_QmZVMEV1P54u9BxKMpURiJZ"

-- 0. FUNÇÃO DE APITO (DEBUG LOGS)
_G.MakitoDebug = function(step, detail)
    pcall(function()
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

local function LoadModule(name)
    local localPath = "modules/" .. name .. ".lua"
    local githubBase = "https://raw.githubusercontent.com/bl4ckgoldstudios-creator/MAKITO-HUB/refs/heads/main/script/modules/"
    
    local function TryLoad(source, isRaw)
        local code = isRaw and source or game:HttpGet(source)
        local fn, err = loadstring(code)
        if not fn then return false, "Syntax Error in " .. name .. ": " .. tostring(err) end
        
        local success, result = pcall(fn)
        if not success then return false, "Runtime Error in " .. name .. ": " .. tostring(result) end
        return true, result
    end

    -- Tentar Local primeiro (várias formas de path)
    if isfile then
        local paths = {localPath, "./" .. localPath, "script/" .. localPath}
        for _, path in ipairs(paths) do
            if isfile(path) then
                local success, res = TryLoad(readfile(path), true)
                if success then return res end -- RETORNA O MÓDULO (TABELA)
                warn("[MAKITO] Falha ao carregar local " .. path .. ": " .. tostring(res))
            end
        end
    end

    -- Tentar GitHub como fallback
    local githubSuccess, githubRes = pcall(function() 
        local success, res = TryLoad(githubBase .. name .. ".lua", false)
        if success then return res end
        return nil
    end)
    
    if githubSuccess and githubRes then return githubRes end
    
    warn("[MAKITO] Não foi possível carregar o módulo: " .. name)
    return nil
end

local Settings = LoadModule("Settings")
local Data = LoadModule("Data")
local Utils = LoadModule("Utils")
local Combat = LoadModule("Combat")
local Farming = LoadModule("Farming")
local UI = LoadModule("UI")

if not (Settings and Data and Utils and Combat and Farming and UI) then
    local missing = {}
    if not Settings then table.insert(missing, "Settings") end
    if not Data then table.insert(missing, "Data") end
    if not Utils then table.insert(missing, "Utils") end
    if not Combat then table.insert(missing, "Combat") end
    if not Farming then table.insert(missing, "Farming") end
    if not UI then table.insert(missing, "UI") end
    
    local errorMsg = "FALHA AO CARREGAR MAKITO HUB\nModulos ausentes: " .. table.concat(missing, ", ")
    warn(errorMsg)
    
    -- Criar aviso na tela antes de fechar
    local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local txt = Instance.new("TextLabel", sg)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundColor3 = Color3.new(0,0,0)
    txt.TextColor3 = Color3.new(1,0,0)
    txt.Text = errorMsg .. "\n\nVerifique o Console (F9) para mais detalhes."
    txt.TextSize = 20
    txt.Font = Enum.Font.GothamBold
    
    task.wait(10)
    LocalPlayer:Kick(errorMsg)
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
    _G.Utils.AntiAFK() -- Inicia Anti-AFK por padrão

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
                        if requestFunc then
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
