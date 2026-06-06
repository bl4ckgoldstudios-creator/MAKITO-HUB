-- MAKITO HUB PRO - SUPREME EDITION (REVISADO)
-- 0. ERROR HANDLER GLOBAL (PRIMEIRA LINHA)
local LogService = game:GetService("LogService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local lastErrorTick = 0
local errorCount = 0

LogService.MessageOut:Connect(function(message, messageType)
    if messageType == Enum.MessageType.MessageError then
        local now = tick()
        if (message:find("Makito") or message:find("modules") or message:find("main")) and (now - lastErrorTick > 10) then
            lastErrorTick = now
            errorCount = errorCount + 1
            if errorCount <= 5 then
                task.spawn(function()
                    local errorMsg = string.format("🚨 **MAKITO HUB - SYSTEM ERROR**\n📅 **Data/Hora:** %s\n👤 **User:** %s\n❌ **Erro:** ```%s```", os.date("%X"), LocalPlayer.Name, message)
                    if _G.Settings and (_G.Settings.ErrorWebhookURL or _G.Settings.WebhookURL) then
                        local targetWebhook = (_G.Settings.ErrorWebhookURL ~= "" and _G.Settings.ErrorWebhookURL ~= "None") and _G.Settings.ErrorWebhookURL or _G.Settings.WebhookURL
                        pcall(function()
                            (syn and syn.request or http_request or request)({
                                Url = targetWebhook,
                                Method = "POST",
                                Headers = {["Content-Type"] = "application/json"},
                                Body = HttpService:JSONEncode({["embeds"] = {{["title"] = "MAKITO HUB - SYSTEM CRASH", ["description"] = errorMsg, ["color"] = 0xFF0000}}})
                            })
                        end)
                    end
                end)
            end
        end
    end
end)
task.spawn(function() while task.wait(60) do errorCount = 0 end end)

-- 1. SMART MODULE LOADER
local function LoadModule(name)
    local localPath = "modules/" .. name .. ".lua"
    local githubBase = "https://raw.githubusercontent.com/bl4ckgoldstudios-creator/MAKITO-HUB/refs/heads/main/script/modules/"
    local success, result = pcall(function()
        if isfile and isfile(localPath) then return loadstring(readfile(localPath))()
        else return loadstring(game:HttpGet(githubBase .. name .. ".lua"))() end
    end)
    if success and result then return result end
    warn("[MAKITO ELITE ERROR]: Falha no modulo " .. name .. " -> " .. tostring(result))
    return nil
end

local Settings = LoadModule("Settings")
local Data = LoadModule("Data")
local Utils = LoadModule("Utils")
local Combat = LoadModule("Combat")
local Farming = LoadModule("Farming")
local UI = LoadModule("UI")

if not (Settings and Data and Utils and Combat and Farming and UI) then
    LocalPlayer:Kick("ERRO CRITICO: Falha ao carregar Makito. Verifique sua conexao.")
    return
end

-- INICIALIZAÇÃO GLOBAL (IMPORTANTE: ANTES DA UI)
_G.Settings = Settings.Values
Settings.Load() -- Carrega configs salvas
_G.Data = Data
_G.Utils = Utils
_G.Combat = Combat
_G.Farming = Farming
_G.MakitoHubRunning = true
_G.MakitoStatus = {Text = "Carregado!"}

-- 2. ESCALONADOR DE TAREFAS (LOOP SIMPLIFICADO)
local function StartLoops()
    -- HIGH PRIORITY (100ms)
    task.spawn(function()
        while _G.MakitoHubRunning do
            pcall(function()
                if _G.Settings.FastAttack then _G.Combat.StartFastAttack() else _G.Combat.StopFastAttack() end
                _G.Combat.KillAuraLogic()
                _G.Combat.AimBotLogic()
            end)
            task.wait(0.1)
        end
    end)

    -- MEDIUM PRIORITY (500ms)
    task.spawn(function()
        while _G.MakitoHubRunning do
            pcall(function()
                if _G.Settings.AutoFarm then _G.Farming.SupremeAutoFarm() end
                if _G.Settings.AutoFarmNearest then _G.Farming.AutoFarmNearestLogic() end
                
                _G.Farming.AutoSoulGuitarLogic()
                _G.Farming.AutoCDKLogic()
                _G.Farming.AutoGodhumanLogic()
                _G.Farming.AutoTrialLogic()
                _G.Farming.AutoNextSeaLogic()
                _G.Farming.AutoStatsLogic()
                _G.Farming.FruitLogic()
                _G.Farming.LeviathanLogic()
                _G.Farming.RaidLogic()
                _G.Farming.ShopLogic()
                _G.Farming.ChestFarmLogic()
                _G.Combat.AutoBountyLogic()
            end)
            task.wait(0.5)
        end
    end)

    -- VISUALS & WEBHOOK (2s)
    task.spawn(function()
        local lastWebhook = 0
        while _G.MakitoHubRunning do
            pcall(function()
                _G.Utils.SetFullBright(_G.Settings.FullBright)
                _G.Utils.RemoveFog(_G.Settings.RemoveFog)
                
                -- Webhook Sync (60s)
                if tick() - lastWebhook >= 60 then
                    lastWebhook = tick()
                    -- Lógica do Webhook simplificada (enviar via Utils)
                    local data = LocalPlayer:FindFirstChild("Data")
                    if data then
                        local stats = string.format("Level: %d | Beli: %s | Status: %s", data.Level.Value, _G.Utils.FormatNumber(data.Beli.Value), _G.MakitoStatus.Text)
                        _G.Utils.SendWebhook(_G.Settings.WebhookURL, "MAKITO HUB - DATA SYNC", stats, 0x00FF96)
                    end
                end
            end)
            task.wait(2.0)
        end
    end)
end

-- 3. START
StartLoops()
UI.CreateHub()
Utils.Notify("MAKITO HUB ATIVADO!", 5)
