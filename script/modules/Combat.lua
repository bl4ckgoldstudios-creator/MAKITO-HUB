local CombatModule = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FastAttackConn = nil
local KillAuraConn = nil
local CombatFramework = nil
local CombatFrameworkRoot = nil

-- CACHE DE REMOTOS PARA PERFORMANCE
local CommF = nil
local function GetCommF()
    if CommF then return CommF end
    pcall(function()
        CommF = ReplicatedStorage:FindFirstChild("CommF_", true) or 
                ReplicatedStorage:WaitForChild("Remotes", 5):WaitForChild("CommF_", 5)
    end)
    if CommF then
        warn("✅ [MAKITO] Remote CommF_ Encontrado!")
    else
        warn("❌ [MAKITO] Remote CommF_ NÃO Encontrado!")
    end
    return CommF
end

local lastFrameworkCheck = 0
local function GetFramework()
    local success, result = pcall(function()
        if CombatFramework and CombatFramework.activeController then 
            return CombatFramework 
        end
        
        -- Só verifica no GC a cada 5 segundos para economizar CPU
        local now = tick()
        if now - lastFrameworkCheck < 5 then return nil end
        lastFrameworkCheck = now

        for _, v in pairs(getgc(true)) do
            if type(v) == "table" then
                if v.activeController and (v.activeController.attack or v.activeController.Attack) then
                    CombatFramework = v
                    warn("✅ [MAKITO] Combat Framework Encontrado!")
                    return v
                elseif v.Attack and v.AttackCD then
                    CombatFramework = {activeController = v}
                    warn("✅ [MAKITO] Combat Framework (Variação) Encontrado!")
                    return CombatFramework
                end
            end
        end
    end)
    return success and result or nil
end

-- DETECÇÃO DE ARMA ROBUSTA
local function IsCombatWeapon(tool)
    if not tool or not tool:IsA("Tool") then return false end
    local tt = tool.ToolTip
    local name = tool.Name:lower()
    
    -- Verifica por ToolTip ou por nomes comuns se o ToolTip falhar
    if tt == "Melee" or tt == "Sword" or tt == "Blox Fruit" then return true end
    if name:find("sword") or name:find("blade") or name:find("katana") or name:find("saber") then return true end
    if name:find("combat") or name:find("dark step") or name:find("electro") or name:find("fishman") then return true end
    
    -- Update 29: Fruits with M1 support (Control, Kitsune, T-Rex, etc.)
    local m1Fruits = {"control", "kitsune", "t-rex", "mammoth", "leopard", "ice", "light", "magma"}
    for _, f in ipairs(m1Fruits) do
        if name:find(f) then return true end
    end
    
    return false
end

-- FALLBACK: ATAQUE VIA INPUT SE O FRAMEWORK FALHAR (EVITA CLICAR NA UI)
local function FallbackAttack()
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        local vpSize = workspace.CurrentCamera.ViewportSize
        -- Clica no centro da tela para evitar arrastar botões ou clicar em UIs nas bordas
        local centerX, centerY = vpSize.X / 2, vpSize.Y / 2
        
        vim:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
        task.wait()
        vim:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
    end)
end

function CombatModule.StopCombatLoop()
    if FastAttackConn then
        FastAttackConn:Disconnect()
        FastAttackConn = nil
        warn("⏹️ [MAKITO] Loop de Combate Parado")
    end
end

-- SISTEMA UNIFICADO: FAST ATTACK + KILL AURA (VERSÃO ELITE REFINADA)
local activeTargets = {}
function CombatModule.StartCombatLoop()
    if FastAttackConn then return end
    warn("🚀 [MAKITO] Motor de Combate Elite Iniciado")
    
    local lastRemoteAttack = 0
    FastAttackConn = RunService.Stepped:Connect(function()
        if not _G.Settings or (not _G.Settings.FastAttack and not _G.Settings.KillAura) then 
            CombatModule.StopCombatLoop()
            return 
        end
        
        -- SEGURANÇA: Bloqueia se estiver em animação de diálogo, sentado ou stunado
        if _G.IsTalkingToNPC then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 or hum.Sit then return end
        
        pcall(function()
            local root = char.HumanoidRootPart
            local weapon = char:FindFirstChildOfClass("Tool")
            if not weapon or not IsCombatWeapon(weapon) then return end
            
            local now = tick()
            local attackDelay = _G.Settings.FastAttackSpeed or 0.01
            local attackDist = _G.Settings.KillAuraDistance or 150
            
            local framework = GetFramework()
            local enemies = workspace:FindFirstChild("Enemies") or workspace
            local myPos = root.Position
            
            -- 1. SINCRONIZAÇÃO DE FRAMEWORK (MODO SILENCIOSO)
            if framework and framework.activeController then
                local controller = framework.activeController
                controller.hitboxMagnitude = attackDist
                controller.attackCount = 0
                controller.timeToNextAttack = 0
                controller.increment = 0
            end

            -- 2. LOGICA DE DANO REFINADA (KILL AURA PRO)
            if now - lastRemoteAttack >= attackDelay then
                local remote = GetCommF()
                if remote then
                    local potentialTargets = {}
                    
                    -- Varredura inteligente: filtra e ordena por prioridade
                    for _, v in ipairs(enemies:GetChildren()) do
                        local eRoot = v:FindFirstChild("HumanoidRootPart")
                        local eHum = v:FindFirstChild("Humanoid")
                        
                        if eRoot and eHum and eHum.Health > 0 then
                            local dist = (myPos - eRoot.Position).Magnitude
                            if dist <= attackDist then
                                -- Raycast para evitar bater através de paredes impossíveis (Anti-Cheat Bypass)
                                local ray = Ray.new(myPos, (eRoot.Position - myPos).Unit * dist)
                                local part = workspace:FindPartOnRayWithIgnoreList(ray, {char, v, workspace:FindFirstChild("Map")})
                                
                                if not part then -- Linha de visão limpa
                                    table.insert(potentialTargets, {part = eRoot, health = eHum.Health, dist = dist})
                                end
                            end
                        end
                    end
                    
                    -- Ordena: Prioriza quem tem MENOS vida (Kill Confirmation)
                    table.sort(potentialTargets, function(a, b) return a.health < b.health end)
                    
                    -- Dispara o Remote para os alvos selecionados (Limite de 15 para estabilidade)
                    local count = 0
                    for _, target in ipairs(potentialTargets) do
                        if count >= 15 then break end
                        remote:InvokeServer("Attack", target.part)
                        count = count + 1
                    end
                    
                    -- 3. AUTO-CLICK DINÂMICO (Se não houver alvo no raio, garante o Fast Attack manual)
                    if count == 0 and _G.Settings.FastAttack then
                        local nearest = _G.Utils.GetNearestEnemyAny()
                        if nearest and (myPos - nearest.HumanoidRootPart.Position).Magnitude < 40 then
                            remote:InvokeServer("Attack", nearest.HumanoidRootPart)
                        end
                    end
                    
                    lastRemoteAttack = now
                end
            end
        end)
    end)
end

function CombatModule.StopFastAttack()
    CombatModule.StopCombatLoop()
end

function CombatModule.StartFastAttack()
    CombatModule.StartCombatLoop()
end

function CombatModule.StopKillAura()
    -- Função mantida para compatibilidade, mas a lógica agora é interna ao Fast Attack
end

function CombatModule.StartKillAura()
    -- Função mantida para compatibilidade, mas a lógica agora é interna ao Fast Attack
end

function CombatModule.KillAuraLogic()
    if _G.Settings and _G.Settings.KillAura then
        CombatModule.StartKillAura()
    else
        CombatModule.StopKillAura()
    end
end

function CombatModule.AimBotLogic(customTarget)
    if not _G.Settings or (not _G.Settings.Aimbot and not customTarget) then return end
    
    local target = customTarget
    if not target then
        local nearest = nil
        local minDist = math.huge
        for _, v in ipairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = v.Character.HumanoidRootPart
                end
            end
        end
        target = nearest
    end
    
    if target then
        local cam = workspace.CurrentCamera
        cam.CFrame = CFrame.new(cam.CFrame.Position, target.Position)
    end
end

function CombatModule.AutoBountyLogic()
    if not _G.Settings or not _G.Settings.AutoBounty then return end
    local target = nil
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            target = v
            break
        end
    end
    
    if target then
        _G.Utils.TweenTo(target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0))
        CombatModule.StartFastAttack()
        CombatModule.AimBotLogic(target.Character.HumanoidRootPart)
    end
end

function CombatModule.AutoPvPLogic()
    if not _G.Settings or not _G.Settings.AutoPvP then return end
    
    local target = nil
    local minDist = 500
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
            if dist < minDist then
                minDist = dist
                target = v
            end
        end
    end
    
    if target then
        CombatModule.AimBotLogic(target.Character.HumanoidRootPart)
        if _G.Settings.AutoCombo then
            CombatModule.AutoComboLogic(target.Character)
        else
            CombatModule.StartFastAttack()
        end
        
        -- Auto Race Skill
        if _G.Settings.AutoRaceSkill then
            local raceAction = LocalPlayer.PlayerGui:FindFirstChild("RaceAction")
            if raceAction and raceAction.Visible then
                local vim = game:GetService("VirtualInputManager")
                vim:SendKeyEvent(true, Enum.KeyCode.T, false, game)
                task.wait(0.05)
                vim:SendKeyEvent(false, Enum.KeyCode.T, false, game)
            end
        end
    end
end

function CombatModule.UseSkill(key)
    pcall(function()
        local virtualInput = game:GetService("VirtualInputManager")
        virtualInput:SendKeyEvent(true, key, false, game)
        task.wait(0.05)
        virtualInput:SendKeyEvent(false, key, false, game)
    end)
end

function CombatModule.AutoComboLogic(customTarget)
    if not _G.Settings or not _G.Settings.AutoCombo or not _G.Settings.SelectedFruit then return end
    
    local combo = _G.Data.Combos[_G.Settings.SelectedFruit]
    if not combo then return end

    local target = customTarget
    if not target then
        local nearest = nil
        local minDist = 150
        for _, v in ipairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = v.Character
                end
            end
        end
        target = nearest
    end

    if target then
        for _, step in ipairs(combo) do
            if not _G.Settings.AutoCombo then break end
            if not target or not target:FindFirstChild("HumanoidRootPart") or target.Humanoid.Health <= 0 then break end
            
            CombatModule.AimBotLogic(target.HumanoidRootPart)
            CombatModule.UseSkill(step.Key)
            task.wait(step.Wait or 0.5)
        end
    end
end

function CombatModule.ESPLogic()
    if not _G.Utils then return end
    
    local anyEspEnabled = _G.Settings and (
        _G.Settings.EspPlayers or 
        _G.Settings.NpcESP or 
        _G.Settings.EspChests or 
        _G.Settings.EspFruits or 
        _G.Settings.AutoFruitESP or 
        _G.Settings.EspFlower or
        _G.Settings.IslandESP or
        _G.Settings.BossESP
    )

    if not anyEspEnabled then
        _G.Utils.ClearESP()
        return
    end

    local playerColor = _G.Utils.ColorFromSettings("EspPlayerColor", Color3.fromRGB(100, 200, 255))
    local npcColor = _G.Utils.ColorFromSettings("EspNpcColor", Color3.fromRGB(255, 80, 80))
    local chestColor = _G.Utils.ColorFromSettings("EspChestColor", Color3.fromRGB(255, 200, 0))
    local fruitColor = _G.Utils.ColorFromSettings("EspFruitColor", Color3.fromRGB(255, 60, 60))
    local flowerColor = _G.Utils.ColorFromSettings("EspFlowerColor", Color3.fromRGB(255, 120, 255))
    local islandColor = Color3.fromRGB(255, 255, 255)
    local bossColor = Color3.fromRGB(255, 0, 0)

    if _G.Settings and (_G.Settings.PlayerESP or _G.Settings.EspPlayers) then
        for _, v in ipairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local root = v.Character.HumanoidRootPart
                local hum = v.Character:FindFirstChild("Humanoid")
                if hum then
                    local text = string.format("👤 %s (%d%%)", v.Name, math.floor((hum.Health / hum.MaxHealth) * 100))
                    if _G.Utils.PassesESPFilter(v.Name, _G.Utils.GetDistanceTo(root)) then
                        _G.Utils.CreateESP(root, text, playerColor, "Player")
                    end
                end
            end
        end
    end

    if _G.Settings and (_G.Settings.NpcESP or _G.Settings.BossESP) then
        local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
        for _, v in ipairs(enemiesFolder:GetChildren()) do
            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                local isBoss = v.Name:find("Boss") or v.Name:find("King") or v.Name:find("Admiral")
                if (isBoss and _G.Settings.BossESP) or (not isBoss and _G.Settings.NpcESP) then
                    local text = string.format("%s %s (%d HP)", isBoss and "👹" or "👾", v.Name, math.floor(v.Humanoid.Health))
                    if _G.Utils.PassesESPFilter(v.Name, _G.Utils.GetDistanceTo(v.HumanoidRootPart)) then
                        _G.Utils.CreateESP(v.HumanoidRootPart, text, isBoss and bossColor or npcColor, isBoss and "Boss" or "NPC")
                    end
                end
            end
        end
    end

    if _G.Settings and (_G.Settings.EspChests or _G.Settings.ChestESP) then
        for _, v in ipairs(workspace:GetChildren()) do
            if v.Name:find("Chest") and v:IsA("BasePart") then
                if _G.Utils.PassesESPFilter(v.Name, _G.Utils.GetDistanceTo(v)) then
                    _G.Utils.CreateESP(v, "💰 Baú", chestColor, "Chest")
                end
            end
        end
    end

    if _G.Settings and (_G.Settings.EspFruits or _G.Settings.FruitESP or _G.Settings.AutoFruitESP) then
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Tool") and (v.Name:find("Fruit") or v:FindFirstChild("Handle")) then
                local handle = v:FindFirstChild("Handle") or v
                if _G.Utils.PassesESPFilter(v.Name, _G.Utils.GetDistanceTo(handle)) then
                    _G.Utils.CreateESP(handle, "🍎 " .. v.Name, fruitColor, "Fruit")
                end
            end
        end
    end

    if _G.Settings and (_G.Settings.EspFlower or _G.Settings.FlowerESP) then
        for _, v in ipairs(workspace:GetChildren()) do
            if v.Name:find("Flower") and v:IsA("BasePart") then
                local color = v.Name:find("Red") and Color3.new(1, 0, 0) or v.Name:find("Blue") and Color3.new(0, 0, 1) or flowerColor
                if _G.Utils.PassesESPFilter(v.Name, _G.Utils.GetDistanceTo(v)) then
                    _G.Utils.CreateESP(v, "🌸 " .. v.Name, color, "Flower")
                end
            end
        end
    end

    if _G.Settings and _G.Settings.IslandESP then
        local sea = _G.Data.GetSea()
        local islands = _G.Data.SeaData[sea]
        if islands then
            for _, island in ipairs(islands) do
                local text = "🏝️ " .. island.Name
                _G.Utils.CreateESP(island.Pos.Position, text, islandColor, "Island")
            end
        end
    end
end

return CombatModule
