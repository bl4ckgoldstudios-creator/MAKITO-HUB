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
_G.MakitoStatus = {Text = "Iniciando..."}

-- 2. INICIALIZAÇÃO
Settings.Load()

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
    Combat.KillAuraLogic() -- GERENCIA O INÍCIO/FIM DA KILL AURA V3
end)

-- TAREFAS DE MÉDIA PRIORIDADE
AddTask("Medium", "Farm", function()
    Farming.SupremeAutoFarm()
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
end)

AddTask("Medium", "Webhook", function()
    if _G.Settings.WebhookURL and _G.Settings.WebhookURL ~= "" then
        local level = LocalPlayer.Data.Level.Value
        if not _G.LastWebhookLevel or level >= _G.LastWebhookLevel + 10 then
            _G.LastWebhookLevel = level
            Utils.SendWebhook(_G.Settings.WebhookURL, "MAKITO HUB - PROGRESSO", "Level Atual: " .. level .. "\nMar: " .. Farming.GetSea(), 0x00FF96)
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
