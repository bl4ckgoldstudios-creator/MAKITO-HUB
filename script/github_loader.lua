--[[
    MAKITO HUB - GITHUB LOADER V2 (ROBUSTO E DEBUG)
    Carrega todos os módulos diretamente do repositório GitHub com logs detalhados
]]

local GITHUB_BASE = "https://raw.githubusercontent.com/bl4ckgoldstudios-creator/MAKITO-HUB/refs/heads/main/script"
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

print("🚀 [MAKITO LOADER] Iniciando carregamento do GitHub...")

-- Função para baixar arquivos com retry
local function Download(path, retries)
    retries = retries or 3
    local url = GITHUB_BASE .. "/" .. path
    local lastError = nil
    
    for i = 1, retries do
        local success, result = pcall(function()
            return HttpService:GetAsync(url, true)
        end)
        if success then
            print("✅ Baixado com sucesso: " .. path)
            return result
        else
            lastError = result
            warn("⚠️ Tentativa " .. i .. "/" .. retries .. " falhou para " .. path .. ": " .. tostring(result))
            task.wait(0.5)
        end
    end
    
    warn("❌ Falha definitiva ao baixar: " .. path .. " | Erro: " .. tostring(lastError))
    return nil
end

-- 1. Inicializa o ambiente global
print("📦 [1/4] Inicializando ambiente global...")
local Makito = {}
getgenv().Makito = Makito
Makito.Version = "11.0"
Makito.Running = true

-- 2. Baixa e carrega todos os módulos NA ORDEM CORRETA!
print("📦 [2/4] Carregando módulos...")
local modulesOrder = {
    "Settings",  -- Primeiro, pois outros módulos dependem dele
    "Data",
    "Utils",
    "Combat",
    "Farming",
    "UI",
    "Security",
    "Updater"
}

for _, name in ipairs(modulesOrder) do
    print("⏳ Carregando módulo: " .. name)
    local content = Download("modules/" .. name .. ".lua")
    if content then
        local fn, err = loadstring(content, "Makito_" .. name)
        if fn then
            local success, mod = pcall(fn)
            if success then
                if name == "Settings" then
                    Makito.Settings = mod.Values
                    Makito.SettingsModule = mod
                else
                    Makito[name] = mod
                end
                print("✅ Módulo carregado com sucesso: " .. name)
            else
                warn("❌ ERRO NO MÓDULO " .. name .. ": " .. tostring(mod))
            end
        else
            warn("❌ ERRO DE SINTAXE EM " .. name .. ": " .. tostring(err))
        end
    else
        warn("❌ NÃO FOI POSSÍVEL BAIXAR O MÓDULO: " .. name)
    end
end

-- 3. Verifica se todos os módulos essenciais estão carregados
print("📦 [3/4] Verificando módulos essenciais...")
local requiredModules = {
    "Settings", "Data", "Utils", "Combat", "Farming", "UI", "Security", "Updater"
}
local missingModules = {}

for _, name in ipairs(requiredModules) do
    if not Makito[name] and name ~= "Settings" then
        table.insert(missingModules, name)
    elseif name == "Settings" and not Makito.Settings then
        table.insert(missingModules, name)
    end
end

if #missingModules > 0 then
    warn("❌ MÓDULOS FALTANDO: " .. table.concat(missingModules, ", "))
else
    print("✅ Todos os módulos essenciais estão carregados!")
end

-- 4. Inicializa o script
print("📦 [4/4] Inicializando o MAKITO HUB...")
if Makito.Utils then
    Makito.Utils.AntiAFK()
    Makito.Utils.SecurityBypass()
    Makito.Utils.InitializeExampleFeatures()
    
    -- Remover efeitos de Death e Respawn
    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        if ReplicatedStorage:FindFirstChild("Effect") and ReplicatedStorage.Effect:FindFirstChild("Container") then
            if ReplicatedStorage.Effect.Container:FindFirstChild("Death") then
                ReplicatedStorage.Effect.Container.Death:Destroy()
            end
            if ReplicatedStorage.Effect.Container:FindFirstChild("Respawn") then
                ReplicatedStorage.Effect.Container.Respawn:Destroy()
            end
        end
    end)
    
    -- Inicializa módulos
    if Makito.Farming then
        print("🔄 Inicializando Farming...")
        Makito.Farming.Initialize()
    end
    if Makito.Combat then
        print("🔄 Inicializando Combat...")
        Makito.Combat.Initialize()
    end
    if Makito.Security then
        print("🔄 Inicializando Security...")
        Makito.Security.Initialize()
    end
    if Makito.Updater then
        print("🔄 Inicializando Updater...")
        Makito.Updater.Initialize()
    end
    
    -- Auto-save on exit
    game:BindToClose(function()
        if Makito.SettingsModule and Makito.SettingsModule.Save then
            Makito.SettingsModule.Save()
        end
    end)
    
    -- Keybind handler
    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end
        if Makito.Settings and Makito.Settings.Keybinds then
            local keyName = input.KeyCode.Name
            if keyName == Makito.Settings.Keybinds.ToggleHub and Makito.UI then
                Makito.UI.ToggleHub()
            elseif keyName == Makito.Settings.Keybinds.ToggleKillAura and Makito.Settings then
                Makito.Settings.KillAura = not Makito.Settings.KillAura
                print("Kill Aura:", Makito.Settings.KillAura)
            elseif keyName == Makito.Settings.Keybinds.ToggleAutoFarm and Makito.Settings then
                Makito.Settings.AutoFarm = not Makito.Settings.AutoFarm
                print("Auto Farm:", Makito.Settings.AutoFarm)
            end
        end
    end)
    
    -- Loop Global
    task.spawn(function()
        while Makito.Running do
            pcall(function()
                Makito.Utils.UpdateInstanceCache()
                Makito.Utils.AutoBuildStats()
                Makito.Utils.ApplyVisualSettings()
                
                if Makito.Farming and Makito.Farming.UpdateAutomation then
                    Makito.Farming.UpdateAutomation()
                end
                
                if Makito.Settings and (Makito.Settings.FastAttack or Makito.Settings.KillAura) then
                    Makito.Combat.StartCombatLoop()
                else
                    Makito.Combat.StopCombatLoop()
                end
            end)
            task.wait(0.5)
        end
    end)
    
    -- UI
    if Makito.UI then
        print("🔄 Criando UI...")
        Makito.UI.CreateHub()
        Makito.UI.CreateWatermark()
    end
    
    print("🎉 [MAKITO HUB PRO] V" .. Makito.Version .. " INICIALIZADO COM SUCESSO!")
else
    warn("❌ [MAKITO HUB] Utils não está carregado! Impossível inicializar.")
end
