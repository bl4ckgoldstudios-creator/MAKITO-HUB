--[[
    MAKITO HUB PRO - V11.0 (FULL PRODUCTION READY)
    World Class Blox Fruits Scripting Framework with Security & Auto-Update
    
    Maintainer: LuaMasterX (June 2026)
    Risk Level: Low (Standard) / High (Rage Mode)
    
    ✅ FULL FEATURES: Auto Farm, Auto Boss, Auto Raid, Sea Events, Security, Auto-Update
]]
--!strict
-- 0. GLOBAL INITIALIZATION
local Makito = {}
getgenv().Makito = Makito
Makito.Version = "11.0"
Makito.Running = true
Makito.IsTalkingToNPC = false
-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LogService = game:GetService("LogService")
local LocalPlayer = Players.LocalPlayer
-- CONFIGURAÇÕES PRIVADAS
local ERROR_WEBHOOK = ""
-- 1. DIAGNÓSTICO E LOGGING
Makito.Debug = function(step: string, detail: string)
    task.spawn(function()
        local webhook = (Makito.Settings and Makito.Settings.ErrorWebhookURL) or ERROR_WEBHOOK
        if not webhook or webhook == "" then return end
        
        local requestFunc = syn and syn.request or http_request or request
        if requestFunc then
            pcall(requestFunc, {
                Url = webhook,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({
                    ["embeds"] = {{
                        ["title"] = "📡 MAKITO HUB - DIAGNÓSTICO: " .. step,
                        ["description"] = "📝 **Detalhe:** " .. detail,
                        ["color"] = 0x00FF00,
                        ["footer"] = {["text"] = "User: " .. LocalPlayer.Name .. " | " .. os.date("%X")}
                    }}
                })
            })
        end
    end)
end
-- 2. ERROR HANDLER
local function ShowErrorPanel(errorMsg: string)
    if game:GetService("CoreGui"):FindFirstChild("MakitoErrorScreen") then return end
    
    local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
    sg.Name = "MakitoErrorScreen"
    
    local frame = Instance.new("ScrollingFrame", sg)
    frame.Size = UDim2.new(0.8, 0, 0.6, 0)
    frame.Position = UDim2.new(0.1, 0, 0.2, 0)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    frame.BorderSizePixel = 0
    frame.CanvasSize = UDim2.new(0, 0, 2, 0)
    
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)
    
    local txt = Instance.new("TextLabel", frame)
    txt.Size = UDim2.new(1, -20, 1, 0)
    txt.Position = UDim2.new(0, 10, 0, 10)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.fromRGB(255, 80, 80)
    txt.Text = "🛑 ERRO CRÍTICO DETECTADO\n\n" .. errorMsg .. "\n\n💡 Verifique o console (F9) ou reporte ao suporte."
    txt.TextSize = 16
    txt.Font = Enum.Font.Code
    txt.TextWrapped = true
    txt.TextYAlignment = Enum.TextYAlignment.Top
    txt.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeBtn = Instance.new("TextButton", sg)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(0.9, -40, 0.2, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    
    closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)
end
if Makito.LogConn then Makito.LogConn:Disconnect() end
Makito.LogConn = LogService.MessageOut:Connect(function(message, messageType)
    if messageType == Enum.MessageType.MessageError then
        local msg = message:lower()
        if msg:find("makito") or msg:find("nil") or msg:find("cframe") then
            ShowErrorPanel(message)
            Makito.Debug("RUNTIME_ERROR", message)
        end
    end
end)
-- 3. DETECÇÃO DE AMBIENTE
if not game:IsLoaded() then game.Loaded:Wait() end
local SEA_PLACE_IDS = {
    [2753915549] = 1, [4442272183] = 2, [4442272121] = 2, [7449423635] = 3
}
Makito.Sea = SEA_PLACE_IDS[game.PlaceId] or 1
local function WaitForData()
    local timeout = tick() + 15
    while tick() < timeout do
        if LocalPlayer:FindFirstChild("Data") then return true end
        task.wait(0.5)
    end
    return false
end
if not WaitForData() then
    warn("⚠️ [MAKITO] Dados do jogador não carregaram. Funcionalidades podem falhar.")
end
-- 4. CARREGAMENTO DE MÓDULOS (USANDO LOADER MODULAR)
local Loader = nil
local report = {}
local caps = {}
-- Carrega o Loader primeiro (o Loader é auto-contido)
local function LoadLoaderModule()
    local loaderPossiblePaths = {
        "modules/Loader.lua",
        "MakitoHub/modules/Loader.lua",
        "script/modules/Loader.lua",
        "./modules/Loader.lua"
    }
    
    for _, path in ipairs(loaderPossiblePaths) do
        local ok, content = pcall(readfile, path)
        if ok and content then
            local fn, err = loadstring(content, "Makito_Loader")
            if fn then
                local success, mod = pcall(fn)
                if success and type(mod) == "table" then
                    return mod
                else
                    warn("❌ Erro no Loader: " .. tostring(err))
                end
            end
        end
    end
    
    return nil
end
Loader = LoadLoaderModule()
if Loader then
    caps = Loader.GetCapabilities()
    print("📋 [MAKITO] Executor detectado: " .. caps.executor)
    
    -- Carrega os módulos principais usando o Loader (incluindo os novos)
    local modulesToLoad = {"Settings", "Data", "Utils", "Combat", "Farming", "UI", "Security", "Updater"}
    for _, name in ipairs(modulesToLoad) do
        local module, _ = Loader.Load(name, report)
        
        if module then
            if name == "Settings" then
                Makito.Settings = module.Values
                Makito.SettingsModule = module
            else
                Makito[name] = module
            end
            print("✅ Módulo carregado: " .. name)
        else
            warn("⚠️ Falha ao carregar módulo: " .. name)
        end
    end
    
    -- Imprime o relatório de carregamento detalhado
    local discovered = Loader.DiscoverWorkspaceFiles()
    print(Loader.FormatReport(report, caps, discovered))
else
    warn("⚠️ [MAKITO] Loader não encontrado. Usando carregamento de fallback básico.")
    
    -- Fallback caso Loader não exista
    local function SafeLoad(name: string, path: string)
        local possiblePaths = {
            path,
            "MakitoHub/" .. path,
            "script/" .. path,
            "./" .. path
        }
        
        local content = nil
        for _, p in ipairs(possiblePaths) do
            local ok, res = pcall(readfile, p)
            if ok and res then
                content = res
                break
            end
        end
        if not content then 
            warn("⚠️ [MAKITO] Arquivo não encontrado: " .. path)
            return nil 
        end
        
        local fn, err = loadstring(content, "Makito_" .. name)
        if not fn then 
            warn("❌ Erro de sintaxe em " .. name .. ": " .. tostring(err))
            return nil 
        end
        
        local success, result = pcall(fn)
        if not success then
            warn("❌ Erro de runtime em " .. name .. ": " .. tostring(result))
            return nil
        end
        
        if name == "Settings" then
            Makito.Settings = result.Values
            Makito.SettingsModule = result
            return result
        end
        
        return result
    end
    local modules = {"Settings", "Data", "Utils", "Combat", "Farming", "UI", "Security", "Updater"}
    for _, name in ipairs(modules) do
        local path = "modules/" .. name .. ".lua"
        local module = SafeLoad(name, path)
        if module then
            if name ~= "Settings" then
                Makito[name] = module
            end
            print("✅ Módulo carregado (fallback): " .. name)
        else
            warn("⚠️ Falha ao carregar módulo (fallback): " .. name)
        end
    end
end
-- 4.1 - KEYBIND HANDLER (NEW)
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
-- 5. INICIALIZAÇÃO E LOOP GLOBAL
if Makito.Utils then
    Makito.Utils.AntiAFK()
    Makito.Utils.SecurityBypass()
    Makito.Utils.InitializeExampleFeatures()
    
    -- Destruir efeitos de Death e Respawn (do exemplo)
    pcall(function()
        if game:GetService("ReplicatedStorage").Effect.Container:FindFirstChild("Death") then
            game:GetService("ReplicatedStorage").Effect.Container.Death:Destroy()
        end
        if game:GetService("ReplicatedStorage").Effect.Container:FindFirstChild("Respawn") then
            game:GetService("ReplicatedStorage").Effect.Container.Respawn:Destroy()
        end
    end)
    
    -- Hookfunctions do exemplo para silenciar erros/death effects
    if hookfunction then
        pcall(function()
            hookfunction(require(game:GetService("ReplicatedStorage").Effect.Container.Death), function() end)
        end)
        pcall(function()
            hookfunction(require(game:GetService("ReplicatedStorage"):WaitForChild("GuideModule")).ChangeDisplayedNPC, function() end)
        end)
        -- pcall(function()
        --     hookfunction(error, function() end)
        -- end)
        -- pcall(function()
        --     hookfunction(warn, function() end)
        -- end)
        
        -- Remover Rocks do Workspace
        pcall(function()
            local Rock = workspace:FindFirstChild("Rocks")
            if Rock then Rock:Destroy() end
        end)
        
        -- Remover DarkFog e Foam/Water
        pcall(function()
            local Lighting = game:GetService("Lighting")
            local lightingLayers = Lighting:FindFirstChild("LightingLayers")
            if lightingLayers then
                local darkFog = lightingLayers:FindFirstChild("DarkFog")
                if darkFog then darkFog:Destroy() end
            end
            local Water = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Foam;")
            if Water then Water:Destroy() end
        end)
    end
    
    -- Inicializa módulos de Farming e Combat (Novos)
    if Makito.Farming then
        Makito.Farming.Initialize()
    end
    if Makito.Combat then
        Makito.Combat.Initialize()
    end
    
    -- Inicializa módulos de Segurança e Atualizações (NEW)
    if Makito.Security then
        Makito.Security.Initialize()
    end
    if Makito.Updater then
        Makito.Updater.Initialize()
    end
    
    -- Auto-save configs on exit (NEW)
    game:BindToClose(function()
        if Makito.SettingsModule and Makito.SettingsModule.Save then
            Makito.SettingsModule.Save()
        end
    end)
    
    -- Loop Global de Automação (Coesão Total)
    task.spawn(function()
        while Makito.Running do
            local success, err = pcall(function()
                -- 1. Atualização de Cache e Status
                Makito.Utils.UpdateInstanceCache()
                Makito.Utils.AutoBuildStats()
                Makito.Utils.ApplyVisualSettings()
                
                -- 2. Orquestração de Farming e Eventos
                if Makito.Farming and Makito.Farming.UpdateAutomation then
                    Makito.Farming.UpdateAutomation()
                end
                
                -- 3. Lógica de Combate Reativa
                if Makito.Settings and (Makito.Settings.FastAttack or Makito.Settings.KillAura) then
                    Makito.Combat.StartCombatLoop()
                else
                    Makito.Combat.StopCombatLoop()
                end
                -- 4. Webhook Stats (A cada 10 minutos)
                if Makito.Settings and Makito.Settings.AutoWebhook then
                    if not _G.LastWebhook or tick() - _G.LastWebhook > 600 then
                        _G.LastWebhook = tick()
                        Makito.Debug("STATS_UPDATE", string.format(
                            "Level: %d | Beli: %d | Frags: %d",
                            LocalPlayer.Data.Level.Value, LocalPlayer.Data.Beli.Value, LocalPlayer.Data.Fragments.Value
                        ))
                    end
                end
            end)
            
            if not success then
                warn("⚠️ [MAKITO LOOP ERROR]: " .. tostring(err))
            end
            task.wait(0.5)
        end
    end)
    
    -- Inicializa UI e Watermark
    if Makito.UI then
        Makito.UI.CreateHub()
        Makito.UI.CreateWatermark()
    end
end
print("🚀 [MAKITO HUB PRO] V" .. Makito.Version .. " Inicializado com sucesso!")
