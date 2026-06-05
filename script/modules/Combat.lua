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
        local paths = {
            LocalPlayer.PlayerScripts:FindFirstChild("CombatFramework"),
            LocalPlayer.PlayerScripts:FindFirstChild("CombatFrameworkR"),
            ReplicatedStorage:FindFirstChild("CombatFramework")
        }
        for _, framework in ipairs(paths) do
            if framework then
                CombatFramework = require(framework)
                break
            end
        end
        if CombatFramework then
            local controller = CombatFramework.activeController or CombatFramework.controller
            if controller and (controller.attack or controller.Attack) then
                local upvalues = debug.getupvalues(controller.attack or controller.Attack)
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

function CombatModule.UseSkill(key, holdTime)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[key], false, game)
        if holdTime then task.wait(holdTime) end
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[key], false, game)
    end)
end

return CombatModule
