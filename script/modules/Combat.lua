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
    if CombatFramework and CombatFrameworkRoot then return end
    pcall(function()
        -- Tenta vários caminhos possíveis para o framework
        local possiblePaths = {
            LocalPlayer.PlayerScripts:FindFirstChild("CombatFramework"),
            LocalPlayer.PlayerScripts:FindFirstChild("CombatFrameworkR"),
            ReplicatedStorage:FindFirstChild("CombatFramework"),
            LocalPlayer.PlayerScripts:FindFirstChild("CombatHandler")
        }
        
        for _, framework in ipairs(possiblePaths) do
            if framework then
                local success, result = pcall(require, framework)
                if success then
                    CombatFramework = result
                    break
                end
            end
        end

        if CombatFramework then
            -- Tenta localizar o controller ativo
            local controller = CombatFramework.activeController or CombatFramework.controller
            if not controller then
                -- Fallback para busca em tabelas internas se o path padrão falhar
                for _, v in pairs(CombatFramework) do
                    if type(v) == "table" and (v.activeController or v.controller) then
                        controller = v.activeController or v.controller
                        break
                    end
                end
            end

            if controller and (controller.attack or controller.Attack) then
                local attackFn = controller.attack or controller.Attack
                local success, upvalues = pcall(debug.getupvalues, attackFn)
                if success and upvalues then
                    for _, v in pairs(upvalues) do
                        if type(v) == "table" and (v.activeController or v.controller) then
                            CombatFrameworkRoot = v
                            break
                        end
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
    FastAttackConn = RunService.Heartbeat:Connect(function()
        if _G.MakitoHubRunning and _G.Settings.FastAttack then
            pcall(function()
                GetFramework()
                if CombatFramework and CombatFramework.activeController then
                    local controller = CombatFrameworkRoot and CombatFrameworkRoot.activeController or CombatFramework.activeController
                    
                    -- BYPASS DE COOLDOWN SUPREMO (ULTRA PACKET BURST)
                    controller.hitboxMagnitude = 150 -- Alcance máximo seguro
                    controller.attackCount = 0
                    controller.timeToNextAttack = 0
                    controller.increment = 0
                    controller.active = true
                    controller.blocking = false
                    
                    -- MULTI-HIT V23: EXPLOSÃO DE DANOS
                    -- Simula um volume massivo de ataques simultâneos
                    local burstRate = (_G.Settings.Weapon == "Fruit" and 15 or 40)
                    for i = 1, burstRate do
                        task.spawn(function()
                            pcall(function()
                                CombatFramework.activeController.attack()
                            end)
                        end)
                    end
                    
                    -- ANTI-LAG: Limpeza de memória ocasional
                    if tick() % 10 < 0.1 then collectgarbage("step") end
                end
            end)
        end
    end)
end

-- REDZ HUB STYLE KILL AURA V3 (SILENT & CONTINUOUS)
local KillAuraConn = nil

function CombatModule.StopKillAura()
    if KillAuraConn then KillAuraConn:Disconnect() KillAuraConn = nil end
end

function CombatModule.StartKillAura()
    CombatModule.StopKillAura()
    
    KillAuraConn = RunService.Heartbeat:Connect(function()
        if _G.MakitoHubRunning and _G.Settings.KillAura then
            pcall(function()
                GetFramework()
                if CombatFramework and CombatFramework.activeController then
                    local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
                    local playerPos = LocalPlayer.Character.HumanoidRootPart.Position
                    local auraDist = _G.Settings.KillAuraDistance or 60
                    
                    for _, v in ipairs(enemiesFolder:GetChildren()) do
                        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                            local enemyPos = v.HumanoidRootPart.Position
                            local dist = (enemyPos - playerPos).Magnitude
                            
                            if dist <= auraDist then
                                -- REDZ STYLE: Continuous Damage Packet
                                -- Simula ataques ultra-rápidos sem animação para cada inimigo no raio
                                local controller = CombatFrameworkRoot and CombatFrameworkRoot.activeController or CombatFramework.activeController
                                
                                controller.hitboxMagnitude = 150
                                controller.active = true
                                controller.timeToNextAttack = 0
                                
                                -- BURST DAMAGE: 10 hits por inimigo por frame de aura
                                for i = 1, 10 do
                                    task.spawn(function()
                                        pcall(function()
                                            CombatFramework.activeController.attack()
                                        end)
                                    end)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end

function CombatModule.KillAuraLogic()
    -- Função mantida para compatibilidade com o main.lua anterior
    if _G.Settings.KillAura then
        if not KillAuraConn then CombatModule.StartKillAura() end
    else
        CombatModule.StopKillAura()
    end
end

-- AIMBOT SKILLS (AUTO-TARGET NEAREST PLAYER/NPC)
function CombatModule.AimBotLogic()
    if not _G.Settings.AimBot then return end
    
    local target = nil
    local minDist = math.huge
    
    -- PRIORIZA JOGADORES SE ESTIVER EM PVP, SENÃO NPCS
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
            if dist < 250 and dist < minDist then
                minDist = dist
                target = v.Character.HumanoidRootPart
            end
        end
    end
    
    if target then
        local cam = workspace.CurrentCamera
        cam.CFrame = CFrame.new(cam.CFrame.Position, target.Position)
    end
end

-- AUTO BOUNTY / PLAYER HUNTER
function CombatModule.AutoBountyLogic()
    if not _G.Settings.AutoBounty then return end
    
    local targetName = _G.Settings.SelectedPlayer
    local target = Players:FindFirstChild(targetName)
    
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Character.Humanoid.Health > 0 then
        local targetCF = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
        _G.Utils.TweenTo(targetCF)
        
        -- AUTO ATTACK
        _G.Settings.FastAttack = true
        _G.Settings.KillAura = true
        
        -- AUTO COMBO
        if _G.Settings.AutoCombo then
            local fruit = _G.Settings.SelectedFruit
            local combo = _G.Data.Combos[fruit]
            if combo then
                for _, step in ipairs(combo) do
                    CombatModule.UseSkill(step.Key)
                    task.wait(step.Wait)
                end
            end
        end
    end
end

function CombatModule.UseSkill(key, holdTime)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[key], false, game)
        if holdTime then task.wait(holdTime) end
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[key], false, game)
    end)
end

return CombatModule
