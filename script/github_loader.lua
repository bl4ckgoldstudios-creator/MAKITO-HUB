--[[
    MAKITO HUB - GITHUB LOADER (SIMPLES E EFICAZ)
    Carrega todos os módulos diretamente do repositório GitHub
]]

local GITHUB_BASE = "https://raw.githubusercontent.com/bl4ckgoldstudios-creator/MAKITO-HUB/refs/heads/main/script"
local HttpService = game:GetService("HttpService")

-- Função para baixar arquivos
local function Download(path)
    local url = GITHUB_BASE .. "/" .. path
    local success, result = pcall(function()
        return HttpService:GetAsync(url, true)
    end)
    if success then
        return result
    else
        warn("❌ Falha ao baixar: " .. path .. " | " .. tostring(result))
        return nil
    end
end

-- 1. Inicializa o ambiente global
local Makito = {}
getgenv().Makito = Makito
Makito.Version = "11.0"
Makito.Running = true

-- 2. Baixa e carrega todos os módulos
local modules = {
    "Settings", "Data", "Utils", "Combat", "Farming", "UI", "Security", "Updater"
}

for _, name in ipairs(modules) do
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
                print("✅ Módulo carregado: " .. name)
            else
                warn("❌ Erro no módulo " .. name .. ": " .. tostring(mod))
            end
        else
            warn("❌ Erro de sintaxe em " .. name .. ": " .. tostring(err))
        end
    end
end

-- 3. Baixa e executa o main.lua (ou execute o código diretamente)
-- Vamos executar o código do main.lua diretamente, pois já temos os módulos carregados
local mainCode = Download("main.lua")
if mainCode then
    -- Vamos extrair apenas a parte de inicialização do main.lua (já temos os módulos)
    local initCode = [[
        -- SERVICES
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local HttpService = game:GetService("HttpService")
        local LogService = game:GetService("LogService")
        local LocalPlayer = Players.LocalPlayer
        
        -- DETECÇÃO DE AMBIENTE
        if not game:IsLoaded() then game.Loaded:Wait() end
        local SEA_PLACE_IDS = {
            [2753915549] = 1, [4442272183] = 2, [4442272121] = 2, [7449423635] = 3
        }
        Makito.Sea = SEA_PLACE_IDS[game.PlaceId] or 1
        
        -- KEYBIND HANDLER
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
        
        -- INICIALIZAÇÃO
        if Makito.Utils then
            Makito.Utils.AntiAFK()
            Makito.Utils.SecurityBypass()
            Makito.Utils.InitializeExampleFeatures()
            
            -- Remover efeitos de Death e Respawn
            pcall(function()
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                if ReplicatedStorage.Effect and ReplicatedStorage.Effect.Container then
                    if ReplicatedStorage.Effect.Container:FindFirstChild("Death") then
                        ReplicatedStorage.Effect.Container.Death:Destroy()
                    end
                    if ReplicatedStorage.Effect.Container:FindFirstChild("Respawn") then
                        ReplicatedStorage.Effect.Container.Respawn:Destroy()
                    end
                end
            end)
            
            -- Inicializa módulos
            if Makito.Farming then Makito.Farming.Initialize() end
            if Makito.Combat then Makito.Combat.Initialize() end
            if Makito.Security then Makito.Security.Initialize() end
            if Makito.Updater then Makito.Updater.Initialize() end
            
            -- Auto-save on exit
            game:BindToClose(function()
                if Makito.SettingsModule and Makito.SettingsModule.Save then
                    Makito.SettingsModule.Save()
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
                Makito.UI.CreateHub()
                Makito.UI.CreateWatermark()
            end
        end
        
        print("🚀 [MAKITO HUB PRO] V" .. Makito.Version .. " Inicializado com sucesso!")
    ]]
    
    -- Executa o código de inicialização
    local fn, err = loadstring(initCode, "MAKITO_INIT")
    if fn then
        fn()
    else
        warn("❌ Erro na inicialização: " .. tostring(err))
    end
else
    warn("❌ Não foi possível baixar o main.lua!")
end
