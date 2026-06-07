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
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

local function GetFramework()
    local success, result = pcall(function()
        if CombatFramework and CombatFramework.activeController then 
            return CombatFramework 
        end
        
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" then
                -- Busca por padrões conhecidos do framework do Blox Fruits
                if v.activeController and (v.activeController.attack or v.activeController.Attack) then
                    CombatFramework = v
                    return v
                elseif v.Attack and v.AttackCD then -- Outra variação comum
                    CombatFramework = {activeController = v}
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
    if tt == "Melee" or tt == "Sword" then return true end
    if name:find("sword") or name:find("blade") or name:find("katana") or name:find("saber") then return true end
    if name:find("combat") or name:find("dark step") or name:find("electro") or name:find("fishman") then return true end
    
    return false
end

-- FALLBACK: ATAQUE VIA INPUT SE O FRAMEWORK FALHAR
local function FallbackAttack()
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait()
        vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

function CombatModule.StopFastAttack()
    if FastAttackConn then
        FastAttackConn:Disconnect()
        FastAttackConn = nil
    end
end

-- SISTEMA UNIFICADO: FAST ATTACK + KILL AURA (VERSÃO UNIVERSAL)
function CombatModule.StartFastAttack()
    if FastAttackConn then return end
    
    local lastAttack = 0
    FastAttackConn = RunService.Stepped:Connect(function()
        if not _G.Settings or not _G.Settings.FastAttack then 
            CombatModule.StopFastAttack()
            return 
        end
        
        local now = tick()
        local attackDelay = _G.Settings.FastAttackSpeed or 0.05
        local attackDist = _G.Settings.KillAuraDistance or 60
        
        if now - lastAttack < attackDelay then return end
        
        pcall(function()
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            
            local weapon = char:FindFirstChildOfClass("Tool")
            if not weapon or not IsCombatWeapon(weapon) then return end
            
            local framework = GetFramework()
            local enemies = workspace:FindFirstChild("Enemies") or workspace
            local myPos = char.HumanoidRootPart.Position
            local foundTarget = false
            
            if framework and framework.activeController then
                local controller = framework.activeController
                local attackMethod = controller.attack or controller.Attack
                
                -- BYPASS DE DELAY E ANIMAÇÃO
                controller.hitboxMagnitude = attackDist
                controller.attackCount = 0
                controller.timeToNextAttack = 0
                controller.increment = 0
                
                local count = 0
                for _, v in ipairs(enemies:GetChildren()) do
                    if count >= 8 then break end -- Aumentado limite levemente
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                        local dist = (myPos - v.HumanoidRootPart.Position).Magnitude
                        if dist <= attackDist then 
                            foundTarget = true
                            count = count + 1
                            
                            -- Executa o ataque do framework
                            if attackMethod then attackMethod() end
                            
                            -- Remote call com throttling interno
                            if now - lastAttack >= attackDelay then
                                CommF:InvokeServer("Attack", v.HumanoidRootPart)
                                lastAttack = now
                            end
                        end
                    end
                end
            end

            -- SE O FRAMEWORK FALHAR OU NÃO HOUVER ALVO NO FRAMEWORK
            if not foundTarget or not framework then
                -- Verifica alvos manualmente para o Remote Fallback
                for _, v in ipairs(enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                        local dist = (myPos - v.HumanoidRootPart.Position).Magnitude
                        if dist <= attackDist then
                            foundTarget = true
                            FallbackAttack()
                            if now - lastAttack >= attackDelay then
                                CommF:InvokeServer("Attack", v.HumanoidRootPart)
                                lastAttack = now
                            end
                            break -- Ataca um por vez no fallback para evitar lag de input
                        end
                    end
                end
                
                -- Auto-click puro se ainda não achou nada (para farm de clique)
                if not foundTarget and now - lastAttack >= attackDelay then
                    FallbackAttack()
                    lastAttack = now
                end
            end
        end)
    end)
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

function CombatModule.UseSkill(key)
    pcall(function()
        local virtualInput = game:GetService("VirtualInputManager")
        virtualInput:SendKeyEvent(true, key, false, game)
        task.wait(0.05)
        virtualInput:SendKeyEvent(false, key, false, game)
    end)
end

function CombatModule.AutoComboLogic()
    if not _G.Settings or not _G.Settings.AutoCombo or not _G.Settings.SelectedFruit then return end
    
    local combo = _G.Data.Combos[_G.Settings.SelectedFruit]
    if not combo then return end

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

    if nearest then
        for _, step in ipairs(combo) do
            if not _G.Settings.AutoCombo then break end
            CombatModule.AimBotLogic(nearest.HumanoidRootPart)
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
        _G.Settings.EspFlower
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
    local showHealth = _G.Settings and _G.Settings.EspShowHealth ~= false

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

    if _G.Settings and _G.Settings.NpcESP then
        local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
        for _, v in ipairs(enemiesFolder:GetChildren()) do
            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                local isBoss = v.Name:find("Boss") or v.Name:find("King") or v.Name:find("Admiral")
                if not _G.Settings.EspBossOnly or isBoss then
                    local text = string.format("👾 %s (%d HP)", v.Name, math.floor(v.Humanoid.Health))
                    if _G.Utils.PassesESPFilter(v.Name, _G.Utils.GetDistanceTo(v.HumanoidRootPart)) then
                        _G.Utils.CreateESP(v.HumanoidRootPart, text, npcColor, "NPC")
                    end
                end
            end
        end
    end

    if _G.Settings and _G.Settings.EspChests then
        for _, v in ipairs(workspace:GetChildren()) do
            if v.Name:find("Chest") and v:IsA("BasePart") then
                if _G.Utils.PassesESPFilter(v.Name, _G.Utils.GetDistanceTo(v)) then
                    _G.Utils.CreateESP(v, "💰 Baú", chestColor, "Chest")
                end
            end
        end
    end

    if _G.Settings and (_G.Settings.EspFruits or _G.Settings.AutoFruitESP) then
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Tool") and (v.Name:find("Fruit") or v:FindFirstChild("Handle")) then
                local handle = v:FindFirstChild("Handle") or v
                if _G.Utils.PassesESPFilter(v.Name, _G.Utils.GetDistanceTo(handle)) then
                    _G.Utils.CreateESP(handle, "🍎 " .. v.Name, fruitColor, "Fruit")
                end
            end
        end
    end

    if _G.Settings and _G.Settings.EspFlower then
        for _, v in ipairs(workspace:GetChildren()) do
            if v.Name:find("Flower") and v:IsA("BasePart") then
                local color = v.Name:find("Red") and Color3.new(1, 0, 0) or v.Name:find("Blue") and Color3.new(0, 0, 1) or flowerColor
                if _G.Utils.PassesESPFilter(v.Name, _G.Utils.GetDistanceTo(v)) then
                    _G.Utils.CreateESP(v, "🌸 " .. v.Name, color, "Flower")
                end
            end
        end
    end
end

return CombatModule
