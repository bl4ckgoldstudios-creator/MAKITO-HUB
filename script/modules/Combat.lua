local CombatModule = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local CombatFramework = nil
local CombatFrameworkRoot = nil
local FastAttackConn = nil

local function GetFramework()
    pcall(function()
        if not CombatFramework then
            -- BUSCA EXAUSTIVA: Procura em todos os caminhos possíveis, incluindo novos caminhos de 2026
            local paths = {
                LocalPlayer.PlayerScripts:FindFirstChild("CombatFramework"),
                LocalPlayer.PlayerScripts:FindFirstChild("CombatFrameworkR"),
                ReplicatedStorage:FindFirstChild("CombatFramework"),
                ReplicatedStorage:FindFirstChild("CombatFrameworkR"),
                LocalPlayer.PlayerGui:FindFirstChild("CombatFramework") -- Alguns exploits injetam aqui
            }
            
            for _, framework in ipairs(paths) do
                if framework then
                    CombatFramework = require(framework)
                    break
                end
            end
        end

        -- Validação do activeController (pode ser renomeado para 'controller' ou 'ctrl')
        if CombatFramework then
            local controller = CombatFramework.activeController or CombatFramework.controller or CombatFramework.ctrl
            if controller and (controller.attack or controller.Attack) then
                local attackFunc = controller.attack or controller.Attack
                local upvalues = debug.getupvalues(attackFunc)
                for _, v in pairs(upvalues) do
                    if type(v) == "table" and (v.activeController or v.controller) then
                        CombatFrameworkRoot = v
                        break
                    end
                end
            end
        end
    end)
end

function CombatModule.StopFastAttack()
    if FastAttackConn then FastAttackConn:Disconnect() FastAttackConn = nil end
end

function CombatModule.StartFastAttack()
    CombatModule.StopFastAttack()
    
    -- REDZ STYLE ULTRA: Hook into the internal attack clock
    FastAttackConn = RunService.Heartbeat:Connect(function()
        if _G.MakitoHubRunning and _G.Settings.FastAttack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                GetFramework()
                if CombatFramework and CombatFramework.activeController then
                    local currentTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if currentTool then
                        -- Aumenta drasticamente o alcance e remove o delay
                        CombatFramework.activeController.hitboxMagnitude = 120
                        
                        if CombatFrameworkRoot and CombatFrameworkRoot.activeController then
                            local controller = CombatFrameworkRoot.activeController
                            controller.timeToNextAttack = 0
                            controller.attackCount = 0
                            controller.increment = 0
                            controller.hitboxMagnitude = 120
                            controller.active = true
                            
                            -- NO-DELAY ATTACK: Ignora o cooldown interno do script do jogo
                            controller.blocking = false
                            controller.focusStart = 0
                        end

                        -- MULTI-HIT PACKET: Simula múltiplos ataques em um único frame
                        -- Isso é o que torna o Redz Hub tão rápido
                        local multiHit = (_G.Settings.Weapon == "Fruit" and 10 or 25)
                        for i = 1, multiHit do
                            task.spawn(function()
                                pcall(function()
                                    CombatFramework.activeController.attack()
                                end)
                            end)
                        end
                    end
                end
            end)
        end
    end)
end

function CombatModule.UseSkill(key, holdTime)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[key], false, game)
        if holdTime then task.wait(holdTime) end
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[key], false, game)
    end)
end

function CombatModule.MasteryAutoSwitch(enemy, targetWeapon)
    if not _G.Settings.AutoMastery or not enemy or not enemy:FindFirstChild("Humanoid") then return end
    
    local hpPercent = (enemy.Humanoid.Health / enemy.Humanoid.MaxHealth) * 100
    local threshold = _G.Settings.MasteryHealth or 20
    
    if hpPercent <= threshold then
        -- Troca para a arma de maestria para o golpe final
        local weapon = LocalPlayer.Backpack:FindFirstChild(targetWeapon) or LocalPlayer.Character:FindFirstChild(targetWeapon)
        if weapon and weapon.Parent == LocalPlayer.Backpack then
            LocalPlayer.Character.Humanoid:EquipTool(weapon)
        end
    else
        -- Usa a arma principal (geralmente Melee) para tirar o HP inicial rápido
        local mainWeapon = _G.Settings.Weapon or "Melee"
        local weapon = LocalPlayer.Backpack:FindFirstChild(mainWeapon) or LocalPlayer.Character:FindFirstChild(mainWeapon)
        if weapon and weapon.Parent == LocalPlayer.Backpack then
            LocalPlayer.Character.Humanoid:EquipTool(weapon)
        end
    end
end

-- TASK SCHEDULER (Simples)
CombatModule.Tasks = {}
function CombatModule.AddTask(name, func, priority)
    CombatModule.Tasks[name] = {Func = func, Priority = priority or 1}
end

task.spawn(function()
    while _G.MakitoHubRunning do
        task.wait(0.1)
        for name, taskData in pairs(CombatModule.Tasks) do
            pcall(taskData.Func)
        end
    end
end)

function CombatModule.AutoBountyLogic()
    if not _G.Settings.AutoBounty then return end
    
    local target = nil
    local maxDist = _G.Settings.KillAuraDistance or 1000
    
    -- Find target player
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
            local hpPercent = (p.Character.Humanoid.Health / p.Character.Humanoid.MaxHealth) * 100
            if hpPercent <= (_G.Settings.BountyThreshold or 100) then
                local dist = (p.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if dist < maxDist then
                    target = p
                    break
                end
            end
        end
    end
    
    if target then
        if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Caçando " .. target.Name end
        local root = LocalPlayer.Character.HumanoidRootPart
        local targetRoot = target.Character.HumanoidRootPart
        
        -- Movimentação Predictiva
        local velocity = targetRoot.Velocity
        local predictedPos = targetRoot.CFrame * CFrame.new(velocity.X/5, 0, velocity.Z/5)
        
        _G.Utils.TweenTo(predictedPos * CFrame.new(0, _G.Settings.Distance, 0))
        
        -- Auto Combo Execution
        if _G.Settings.AutoCombo then
            CombatModule.ExecuteCombo(target.Character)
        else
            CombatModule.StartFastAttack()
        end
    end
end

function CombatModule.ExecuteCombo(target)
    if not _G.Settings.AutoCombo or not target then return end
    local fruit = _G.Settings.SelectedFruit
    local combo = _G.Data.Combos[fruit]
    if combo then
        for _, step in ipairs(combo) do
            if not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 then break end
            CombatModule.UseSkill(step.Key)
            task.wait(step.Wait or 0.5)
        end
    end
end

return CombatModule
