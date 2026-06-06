-- MAKITO HUB PRO - SUPREME EDITION (HARDCODED & SECURE)
-- 0. CONFIGURAÇÕES PRIVADAS (HARDCODED)
local MAIN_WEBHOOK = "https://discord.com/api/webhooks/1512940585630306394/_QzLsr01ddelFxufLiu3sFkEHJ132lrhup1NI9CXxKVBOn-pK6aM3_97qo3F8fqufaw5"
local ERROR_WEBHOOK = "https://discord.com/api/webhooks/1512945637950488708/YwhaSTr1x65zuB9bUMmzEW1WQUDB-wR36sM6bhzeS7zW_QmZVMEV1P54u9BxKMpURiJZ"

-- 0. ERROR HANDLER GLOBAL (LINHA 1 - IMEDIATO)
local LogService = game:GetService("LogService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

LogService.MessageOut:Connect(function(message, messageType)
    if messageType == Enum.MessageType.MessageError then
        pcall(function()
            local data = {
                ["embeds"] = {{
                    ["title"] = "🚨 MAKITO HUB - CRITICAL ERROR",
                    ["description"] = "```lua\n" .. message .. "\n```",
                    ["color"] = 0xFF0000,
                    ["fields"] = {
                        {["name"] = "👤 Player", ["value"] = LocalPlayer.Name, ["inline"] = true},
                        {["name"] = "📈 Level", ["value"] = tostring(LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data.Level.Value or "Unknown"), ["inline"] = true},
                        {["name"] = "🕒 Time", ["value"] = os.date("%X"), ["inline"] = true}
                    }
                }}
            }
            (syn and syn.request or http_request or request)({
                Url = ERROR_WEBHOOK,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            })
        end)
    end
end)

-- 1. SMART MODULE LOADER
local function LoadModule(name)
    local localPath = "modules/" .. name .. ".lua"
    local githubBase = "https://raw.githubusercontent.com/bl4ckgoldstudios-creator/MAKITO-HUB/refs/heads/main/script/modules/"
    local success, result = pcall(function()
        if isfile and isfile(localPath) then return loadstring(readfile(localPath))()
        else return loadstring(game:HttpGet(githubBase .. name .. ".lua"))() end
    end)
    if success and result then return result end
    warn("[MAKITO ERROR]: Falha ao carregar modulo " .. name .. " -> " .. tostring(result))
    return nil
end

local Settings = LoadModule("Settings")
local Data = LoadModule("Data")
local Utils = LoadModule("Utils")
local Combat = LoadModule("Combat")
local Farming = LoadModule("Farming")
local UI = LoadModule("UI")

if not (Settings and Data and Utils and Combat and Farming and UI) then
    LocalPlayer:Kick("ERRO CRITICO: Falha na conexao com Makito Hub.")
    return
end

-- 2. INICIALIZAÇÃO GLOBAL
_G.Settings = Settings.Values
Settings.Load() -- Sincroniza JSON local (Apenas flags do jogo)
_G.Data = Data
_G.Utils = Utils
_G.Combat = Combat
_G.Farming = Farming
_G.MakitoHubRunning = true
_G.MakitoStatus = {Text = "Carregado!"}

-- 3. ESCALONADOR DE TAREFAS (REVISADO)
local function StartLoops()
    -- LOOP DE ALTA PRIORIDADE (100ms)
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

    -- LOOP DE MÉDIA PRIORIDADE (500ms)
    task.spawn(function()
        while _G.MakitoHubRunning do
            pcall(function()
                -- AUTO FARM LEVEL (VERIFICAÇÃO DE FLAG CORRETA)
                if _G.Settings.AutoFarm then 
                    _G.Farming.SupremeAutoFarm() 
                end
                
                if _G.Settings.AutoFarmNearest then 
                    _G.Farming.AutoFarmNearestLogic() 
                end
                
                -- OUTRAS FUNÇÕES
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

    -- LOOP DE TELEMETRIA (FORMATO DETALHADO FIXO)
    task.spawn(function()
        local lastWebhook = 0
        while _G.MakitoHubRunning do
            pcall(function()
                _G.Utils.SetFullBright(_G.Settings.FullBright)
                _G.Utils.RemoveFog(_G.Settings.RemoveFog)
                
                local now = tick()
                if now - lastWebhook >= 60 then
                    lastWebhook = now
                    local data = LocalPlayer:FindFirstChild("Data")
                    if data then
                        -- DETECÇÃO DE FRUTA
                        local currentFruit = "Nenhuma"
                        for _, v in ipairs(LocalPlayer.Character:GetChildren()) do
                            if v:IsA("Tool") and (v.ToolTip == "Blox Fruit" or v.ToolTip == "Demon Fruit") then
                                currentFruit = v.Name break
                            end
                        end
                        if currentFruit == "Nenhuma" then
                            for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
                                if v:IsA("Tool") and (v.ToolTip == "Blox Fruit" or v.ToolTip == "Demon Fruit") then
                                    currentFruit = v.Name break
                                end
                            end
                        end

                        local formattedText = string.format(
                            "**--- PLAYER STATS ---**\n" ..
                            "👤 **User:** %s\n" ..
                            "📈 **Level:** %d\n" ..
                            "💰 **Beli:** %s\n" ..
                            "💎 **Fragments:** %s\n" ..
                            "🍎 **Fruit:** %s\n" ..
                            "🌊 **Sea:** %d\n\n" ..
                            "**--- MODULE STATUS ---**\n" ..
                            "🚜 **Auto Farm:** %s\n" ..
                            "🎯 **Auto Bounty:** %s\n" ..
                            "⚔️ **Kill Aura:** %s\n" ..
                            "⚡ **Fast Attack:** %s\n\n" ..
                            "**--- CURRENT STATUS ---**\n" ..
                            "📝 %s",
                            LocalPlayer.Name,
                            data.Level.Value,
                            _G.Utils.FormatNumber(data.Beli.Value),
                            _G.Utils.FormatNumber(data.Fragments.Value),
                            currentFruit,
                            _G.Farming.GetSea(),
                            _G.Settings.AutoFarm and "✅ ON" or "❌ OFF",
                            _G.Settings.AutoBounty and "✅ ON" or "❌ OFF",
                            _G.Settings.KillAura and "✅ ON" or "❌ OFF",
                            _G.Settings.FastAttack and "✅ ON" or "❌ OFF",
                            _G.MakitoStatus.Text
                        )
                        
                        -- ENVIO DIRETO PARA URL FIXA
                        pcall(function()
                            (syn and syn.request or http_request or request)({
                                Url = MAIN_WEBHOOK,
                                Method = "POST",
                                Headers = {["Content-Type"] = "application/json"},
                                Body = HttpService:JSONEncode({
                                    ["embeds"] = {{
                                        ["title"] = "MAKITO HUB - DATA SYNC (SECURE)",
                                        ["description"] = formattedText,
                                        ["color"] = 0x00FF96
                                    }}
                                })
                            })
                        end)
                    end
                end
            end)
            task.wait(2)
        end
    end)
end

-- 4. START
StartLoops()
UI.CreateHub()
_G.Utils.Notify("MAKITO HUB V9.1 ATIVADO!", 5)
