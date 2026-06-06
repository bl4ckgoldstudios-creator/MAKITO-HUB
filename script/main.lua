-- MAKITO HUB PRO - SUPREME EDITION
-- Versão: 8.1 (Início do Refinamento)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- 0. AUTO-UPDATE CHECK
local CurrentVersion = "8.1"
pcall(function()
    local versionUrl = "https://raw.githubusercontent.com/bl4ckgoldstudios-creator/MAKITO-HUB/refs/heads/main/version.txt"
    local onlineVersion = game:HttpGet(versionUrl):gsub("%s+", "")
    if onlineVersion ~= CurrentVersion then
        warn("[MAKITO HUB]: Nova versao disponivel (" .. onlineVersion .. ")! Re-execute o script.")
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "ATUALIZAÇÃO DISPONÍVEL",
            Text = "Versão " .. onlineVersion .. " detectada no GitHub!",
            Duration = 15
        })
    end
end)

-- 0. ERROR HANDLER GLOBAL (ANTI-CRASH LOG)
local LogService = game:GetService("LogService")
local lastErrorTick = 0
local errorCount = 0

LogService.MessageOut:Connect(function(message, messageType)
    if messageType == Enum.MessageType.MessageError then
        local now = tick()
        -- Filtro: Apenas erros do Makito ou módulos, com cooldown de 10s para spam e limite de 5 por minuto
        if (message:find("Makito") or message:find("modules") or message:find("main")) and (now - lastErrorTick > 10) then
            lastErrorTick = now
            errorCount = errorCount + 1
            
            if errorCount <= 5 then -- Limite de segurança para evitar ban de webhook
                task.spawn(function()
                    local errorMsg = string.format(
                        "🚨 **MAKITO HUB - SYSTEM ERROR**\n" ..
                        "📅 **Data/Hora:** %s\n" ..
                        "👤 **User:** %s\n" ..
                        "💻 **Versão:** %s\n\n" ..
                        "❌ **Erro:** ```%s```",
                        os.date("%X"),
                        LocalPlayer.Name,
                        CurrentVersion,
                        message
                    )
                    
                    if _G.Settings and (_G.Settings.ErrorWebhookURL or _G.Settings.WebhookURL) then
                        local targetWebhook = (_G.Settings.ErrorWebhookURL ~= "" and _G.Settings.ErrorWebhookURL ~= "None") and _G.Settings.ErrorWebhookURL or _G.Settings.WebhookURL
                        _G.Utils.SendWebhook(targetWebhook, "MAKITO HUB - SYSTEM CRASH/ERROR", errorMsg, 0xFF0000)
                    end
                end)
            end
        end
    end
end)

-- Reseta contador de erros a cada minuto
task.spawn(function()
    while task.wait(60) do errorCount = 0 end
end)

-- 1. SMART MODULE LOADER
local function LoadModule(name)
    local localPath = "modules/" .. name .. ".lua"
    local githubBase = "https://raw.githubusercontent.com/bl4ckgoldstudios-creator/MAKITO-HUB/refs/heads/main/script/modules/"
    
    local success, result = pcall(function()
        if isfile and isfile(localPath) then
            return loadstring(readfile(localPath))()
        else
            return loadstring(game:HttpGet(githubBase .. name .. ".lua"))()
        end
    end)
    
    if success and result then 
        print("[MAKITO ELITE]: Modulo " .. name .. " carregado.")
        return result 
    end
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
    LocalPlayer:Kick("ERRO CRITICO: Falha ao carregar Makito Elite. Verifique sua conexao.")
    return
end

_G.Settings = Settings.Values
_G.Data = Data
_G.Utils = Utils
_G.Combat = Combat
_G.Farming = Farming
_G.MakitoHubRunning = true
_G.MakitoStatus = {Text = "Carregado!"}

-- 2. INICIALIZAÇÃO
Settings.Load()
_G.Settings = Settings.Values -- Garante que a global está atualizada após o load

-- 3. ESCALONADOR DE TAREFAS (PRIORITY SCHEDULER)
local Scheduler = {
    High = {},   -- 100ms (Combate/Movimento)
    Medium = {}, -- 500ms (Quest/Farm)
    Low = {}     -- 2000ms (Stats/Visuals)
}

function AddTask(priority, name, func) Scheduler[priority][name] = func end

-- TAREFAS DE ALTA PRIORIDADE
AddTask("High", "Combat", function()
    if _G.Settings.FastAttack then Combat.StartFastAttack() else Combat.StopFastAttack() end
    Combat.KillAuraLogic()
    Combat.AimBotLogic()
end)

-- TAREFAS DE MÉDIA PRIORIDADE
AddTask("Medium", "Farm", function()
    Farming.SupremeAutoFarm()
    Farming.AutoFarmNearestLogic()
end)

AddTask("Medium", "AutomationLoop", function()
    Farming.AutoSoulGuitarLogic()
    Farming.AutoCDKLogic()
    Farming.AutoGodhumanLogic()
    Farming.AutoTrialLogic()
    Farming.AutoNextSeaLogic()
    Farming.AutoStatsLogic()
    Farming.FruitLogic()
    Farming.LeviathanLogic()
    Farming.RaidLogic()
    Farming.ShopLogic()
    Farming.ChestFarmLogic()
    Combat.AutoBountyLogic()
end)

AddTask("Medium", "Visuals", function()
    Utils.SetFullBright(_G.Settings.FullBright)
    Utils.RemoveFog(_G.Settings.RemoveFog)
    
    -- ESP UPDATE LOOP
    Utils.ClearESP()
    if _G.Settings.PlayerESP then
        for _, v in ipairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                Utils.CreateESP(v.Character.HumanoidRootPart, v.Name .. " [" .. math.floor(v.Character.Humanoid.Health) .. "]", Color3.new(1, 0, 0))
            end
        end
    end
    if _G.Settings.EspFruits then
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Tool") and (v.Name:find("Fruit") or v:FindFirstChild("Handle")) then
                Utils.CreateESP(v.Handle, v.Name, Color3.new(1, 1, 0))
            end
        end
    end
    if _G.Settings.EspChests then
        for _, v in ipairs(workspace:GetChildren()) do
            if v.Name:find("Chest") then
                Utils.CreateESP(v, "Chest", Color3.new(0, 1, 0))
            end
        end
    end
end)

local lastWebhookTick = 0
AddTask("Medium", "Webhook", function()
    if _G.Settings.WebhookURL and _G.Settings.WebhookURL ~= "" and _G.Settings.WebhookURL ~= "None" then
        local now = tick()
        if now - lastWebhookTick >= 60 then
            lastWebhookTick = now
            
            pcall(function()
                local data = LocalPlayer:FindFirstChild("Data")
                if not data then return end
                
                local level = data:FindFirstChild("Level") and data.Level.Value or 0
                local beli = data:FindFirstChild("Beli") and data.Beli.Value or 0
                local fragments = data:FindFirstChild("Fragments") and data.Fragments.Value or 0
                
                -- Detectar Fruta Atual
                local currentFruit = "Nenhuma"
                for _, v in ipairs(LocalPlayer.Character:GetChildren()) do
                    if v:IsA("Tool") and (v.ToolTip == "Blox Fruit" or v.ToolTip == "Demon Fruit") then
                        currentFruit = v.Name
                        break
                    end
                end
                if currentFruit == "Nenhuma" then
                    for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
                        if v:IsA("Tool") and (v.ToolTip == "Blox Fruit" or v.ToolTip == "Demon Fruit") then
                            currentFruit = v.Name
                            break
                        end
                    end
                end

                local sea = Farming.GetSea()
                local statusText = _G.MakitoStatus and _G.MakitoStatus.Text or "N/A"
                
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
                    level,
                    Utils.FormatNumber(beli),
                    Utils.FormatNumber(fragments),
                    currentFruit,
                    sea,
                    _G.Settings.AutoFarm and "✅ ON" or "❌ OFF",
                    _G.Settings.AutoBounty and "✅ ON" or "❌ OFF",
                    _G.Settings.KillAura and "✅ ON" or "❌ OFF",
                    _G.Settings.FastAttack and "✅ ON" or "❌ OFF",
                    statusText
                )

                Utils.SendWebhook(_G.Settings.WebhookURL, "MAKITO HUB - DATA SYNC (IA)", formattedText, 0x00FF96)
            end)
        end
    end
end)

-- TAREFAS DE BAIXA PRIORIDADE
AddTask("Low", "Protection", function()
    Utils.CheckModerator()
end)

-- EXECUTOR DO ESCALONADOR
task.spawn(function()
    while _G.MakitoHubRunning do
        for _, func in pairs(Scheduler.High) do pcall(func) end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while _G.MakitoHubRunning do
        for _, func in pairs(Scheduler.Medium) do pcall(func) end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while _G.MakitoHubRunning do
        for _, func in pairs(Scheduler.Low) do pcall(func) end
        task.wait(2.0)
    end
end)

-- 4. START UI
UI.CreateHub()
Utils.Notify("MAKITO HUB V8.0 ATIVADO!", 5)
