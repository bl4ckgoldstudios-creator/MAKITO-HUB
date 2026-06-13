
--!strict
local CombatModule = {}

-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- INTERNAL STATE
local Makito = getgenv().Makito
local combatLoop: RBXScriptConnection? = nil

-- ==================================================
-- FUNÇÕES UTILITÁRIAS (DO EXEMPLO)
-- ==================================================
function CombatModule.Alive(model)
    if not model then return false end
    local Humanoid = model:FindFirstChild("Humanoid")
    return Humanoid and Humanoid.Health > 0
end

function CombatModule.Pos(model, dist)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    return (root.Position - model.Position).Magnitude <= dist
end

function CombatModule.Dist(model, dist)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    local mobRoot = model:FindFirstChild("HumanoidRootPart")
    if not mobRoot then return false end
    return (root.Position - mobRoot.Position).Magnitude <= dist
end

function CombatModule.DistH(model, dist)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    local mobRoot = model:FindFirstChild("HumanoidRootPart")
    if not mobRoot then return false end
    return (root.Position - mobRoot.Position).Magnitude > dist
end

-- ==================================================
-- SISTEMA DE ATTACK (DO EXEMPLO)
-- ==================================================
function CombatModule.Kill(model, enabled)
    if not model or not enabled then return end
    
    if not Makito.Farming then return end
    
    if not model:GetAttribute("Locked") then
        model:SetAttribute("Locked", model.HumanoidRootPart.CFrame)
    end
    
    local PosMon = (model:GetAttribute("Locked")).Position
    Makito.Farming.BringEnemy()
    
    local MainWeapon = Makito.Settings and Makito.Settings.MainWeapon or "Melee"
    Makito.Farming.EquipWeaponByToolTip(MainWeapon)
    
    local Equipped = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not Equipped then return end
    
    local ToolTip = Equipped.ToolTip
    if ToolTip == "Blox Fruit" then
        Makito.Utils._tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(0, math.rad(90), 0))
    else
        Makito.Utils._tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0) * CFrame.Angles(0, math.rad(180), 0))
    end
end

function CombatModule.Kill2(model, enabled)
    if not model or not enabled then return end
    
    if not Makito.Farming then return end
    
    if not model:GetAttribute("Locked") then
        model:SetAttribute("Locked", model.HumanoidRootPart.CFrame)
    end
    
    local PosMon = (model:GetAttribute("Locked")).Position
    Makito.Farming.BringEnemy()
    
    local MainWeapon = Makito.Settings and Makito.Settings.MainWeapon or "Melee"
    Makito.Farming.EquipWeaponByToolTip(MainWeapon)
    
    local Equipped = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not Equipped then return end
    
    local ToolTip = Equipped.ToolTip
    if ToolTip == "Blox Fruit" then
        Makito.Utils._tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(0, math.rad(90), 0))
    else
        Makito.Utils._tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 30, 8) * CFrame.Angles(0, math.rad(180), 0))
    end
end

function CombatModule.KillSea(model, enabled)
    if not model or not enabled then return end
    
    if not Makito.Farming then return end
    
    if not model:GetAttribute("Locked") then
        model:SetAttribute("Locked", model.HumanoidRootPart.CFrame)
    end
    
    local PosMon = (model:GetAttribute("Locked")).Position
    Makito.Farming.BringEnemy()
    
    local MainWeapon = Makito.Settings and Makito.Settings.MainWeapon or "Melee"
    Makito.Farming.EquipWeaponByToolTip(MainWeapon)
    
    local Equipped = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not Equipped then return end
    
    local ToolTip = Equipped.ToolTip
    if ToolTip == "Blox Fruit" then
        Makito.Utils._tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(0, math.rad(90), 0))
    else
        Makito.Utils.notween(model.HumanoidRootPart.CFrame * CFrame.new(0, 50, 8))
        task.wait(0.85)
        Makito.Utils.notween(model.HumanoidRootPart.CFrame * CFrame.new(0, 400, 0))
        task.wait(1)
    end
end

function CombatModule.Sword(model, enabled)
    if not model or not enabled then return end
    
    if not Makito.Farming then return end
    
    if not model:GetAttribute("Locked") then
        model:SetAttribute("Locked", model.HumanoidRootPart.CFrame)
    end
    
    local PosMon = (model:GetAttribute("Locked")).Position
    Makito.Farming.BringEnemy()
    Makito.Farming.EquipWeaponByToolTip("Sword")
    Makito.Utils._tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
end

function CombatModule.Mas(model, enabled)
    if not model or not enabled then return end
    
    if not Makito.Farming then return end
    
    if not model:GetAttribute("Locked") then
        model:SetAttribute("Locked", model.HumanoidRootPart.CFrame)
    end
    
    local PosMon = (model:GetAttribute("Locked")).Position
    Makito.Farming.BringEnemy()
    
    local HealthM = Makito.Settings and Makito.Settings.MasteryHealth or 20
    if model.Humanoid.Health <= HealthM then
        Makito.Utils._tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))
        Makito.Utils.UseSkills("Blox Fruit", "Z")
        Makito.Utils.UseSkills("Blox Fruit", "X")
        Makito.Utils.UseSkills("Blox Fruit", "C")
    else
        Makito.Farming.EquipWeaponByToolTip("Melee")
        Makito.Utils._tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
    end
end

function CombatModule.Masgun(model, enabled)
    if not model or not enabled then return end
    
    if not Makito.Farming then return end
    
    if not model:GetAttribute("Locked") then
        model:SetAttribute("Locked", model.HumanoidRootPart.CFrame)
    end
    
    local PosMon = (model:GetAttribute("Locked")).Position
    Makito.Farming.BringEnemy()
    
    local HealthM = Makito.Settings and Makito.Settings.MasteryHealth or 20
    if model.Humanoid.Health <= HealthM then
        Makito.Utils._tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 35, 8))
        Makito.Utils.UseSkills("Gun", "Z")
        Makito.Utils.UseSkills("Gun", "X")
    else
        Makito.Farming.EquipWeaponByToolTip("Melee")
        Makito.Utils._tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
    end
end

-- ==================================================
-- NAMECALL HOOK PARA FARM DE MASTERY (DO EXEMPLO)
-- ==================================================
function CombatModule.StartNamecallHook()
    local J = getrawmetatable(game)
    local i = J.__namecall
    
    setreadonly(J, false)
    J.__namecall = newcclosure(function(...)
        local method = getnamecallmethod()
        local args = {...}
        
        if tostring(method) == "FireServer" then
            if tostring(args[1]) == "RemoteEvent" then
                if tostring(args[2]) ~= "true" and tostring(args[2]) ~= "false" then
                    if Makito.Settings and (
                        Makito.Settings.FarmMastery_G or 
                        Makito.Settings.FarmMastery_Dev or 
                        Makito.Settings.FarmMastery_S
                    ) then
                        -- Ajustar a posição para alvo
                        -- args[2] = MousePos
                        return i(unpack(args))
                    end
                end
            end
        end
        
        return i(...)
    end)
    setreadonly(J, true)
    
    print("✅ [MAKITO] Namecall Hook inicializado!")
end

-- ==================================================
-- COMBAT LOOP (ORIGINAL MAKITO HUB)
-- ==================================================
function CombatModule.StartCombatLoop()
    if combatLoop then return end
    
    combatLoop = RunService.Heartbeat:Connect(function()
        if not Makito.Settings then return end
        
        -- Fast Attack
        if Makito.Settings.FastAttack then
            CombatModule.FastAttack()
        end
        
        -- Kill Aura
        if Makito.Settings.KillAura then
            CombatModule.KillAura()
        end
    end)
    
    print("✅ [MAKITO] Combat Loop iniciado!")
end

function CombatModule.StopCombatLoop()
    if combatLoop then
        combatLoop:Disconnect()
        combatLoop = nil
    end
end

-- ==================================================
-- FAST ATTACK
-- ==================================================
function CombatModule.FastAttack()
    -- Implementar Fast Attack
end

-- ==================================================
-- KILL AURA
-- ==================================================
function CombatModule.KillAura()
    -- Implementar Kill Aura
end

-- ==================================================
-- INICIALIZAÇÃO DO COMBAT
-- ==================================================
function CombatModule.Initialize()
    CombatModule.StartNamecallHook()
    print("✅ [MAKITO] Combat Module inicializado!")
end

return CombatModule
