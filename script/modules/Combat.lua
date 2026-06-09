--!strict
local CombatModule = {}

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- INTERNAL STATE
local Makito = getgenv().Makito
local FastAttackConn: RBXScriptConnection? = nil
local CombatFramework: any = nil
local lastFrameworkCheck = 0
local lastAttackTime = 0

-- 1. ACESSO AO MOTOR INTERNO (Otimizado com cache persistente)
local function GetFramework()
    local now = tick()
    if CombatFramework and CombatFramework.activeController then return CombatFramework end
    if now - lastFrameworkCheck < 2 then return nil end -- Throttling para evitar lag de GC
    lastFrameworkCheck = now

    pcall(function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and v.activeController and (v.activeController.attack or v.activeController.Attack) then
                CombatFramework = v
                break
            end
        end
    end)
    return CombatFramework
end

-- 2. MOTOR DE ATAQUE (ULTRA FAST + BYPASS)
local function AttackNoAnim()
    local framework = GetFramework()
    if framework and framework.activeController then
        local ac = framework.activeController
        
        -- Bypass de Cooldowns e Animações
        ac.hitboxMagnitude = 60
        ac.attackCount = 0
        ac.timeToNextAttack = 0
        ac.increment = 0
        
        if ac.attack then ac:attack()
        elseif ac.Attack then ac:Attack() end
    end
end

-- 3. KILL AURA (DANO SILENCIOSO E MULTI-TARGET)
local function UltraKillAura()
    if not Makito.Settings or not Makito.Settings.KillAura then return end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or (char.Humanoid and char.Humanoid.Health <= 0) then return end

    local weapon = char:FindFirstChildOfClass("Tool")
    if not weapon or (weapon.ToolTip ~= "Melee" and weapon.ToolTip ~= "Sword" and weapon.ToolTip ~= "Blox Fruit") then
        if Makito.Farming then Makito.Farming.EquipWeapon(Makito.Settings.MainWeapon or "Melee") end
        return
    end
    
    local remote = ReplicatedStorage:FindFirstChild("CommF_", true)
    if not remote or not remote:IsA("RemoteFunction") then return end
    
    -- Stealth vs Rage logic
    local range = Makito.Settings.KillAuraDistance or 100
    if Makito.Settings.StealthMode then
        range = math.clamp(range, 0, 45) -- Alcance legítimo
    end

    local targets = {}
    local maxTargets = Makito.Settings.MaxTargets or 20
    
    -- Busca de alvos via Cache otimizado
    if Makito.Utils then
        local cache = Makito.Utils.GetInstanceCache and Makito.Utils.GetInstanceCache() or {Enemies = {}}
        for _, enemy in ipairs(cache.Enemies) do
            if #targets >= maxTargets then break end
            local eRoot = enemy:FindFirstChild("HumanoidRootPart")
            if eRoot and (root.Position - eRoot.Position).Magnitude <= range then
                table.insert(targets, eRoot)
            end
        end
    end
    
    -- Disparo de Dano
    if #targets > 0 then
        if Makito.Settings.AutoHaki and not char:FindFirstChild("HasBuso") then
            remote:InvokeServer("Buso")
        end
        
        for _, target in ipairs(targets) do
            task.spawn(function()
                remote:InvokeServer("Attack", target)
            end)
        end
    end
end

-- 4. LOOP DE COMBATE UNIFICADO
function CombatModule.StartCombatLoop()
    if FastAttackConn then return end
    
    FastAttackConn = RunService.RenderStepped:Connect(function()
        if not Makito.Settings or not (Makito.Settings.FastAttack or Makito.Settings.KillAura) then
            CombatModule.StopCombatLoop()
            return
        end

        local now = tick()
        local attackSpeed = Makito.Settings.FastAttackSpeed or 0.05
        
        -- Stealth Mode Throttling
        if Makito.Settings.StealthMode then
            attackSpeed = math.max(attackSpeed, 0.15)
        end

        if now - lastAttackTime >= attackSpeed then
            lastAttackTime = now
            AttackNoAnim()
            if Makito.Settings.KillAura then UltraKillAura() end
        end
    end)
end

function CombatModule.StopCombatLoop()
    if FastAttackConn then
        FastAttackConn:Disconnect()
        FastAttackConn = nil
    end
end

return CombatModule
    if _G.Settings.SelectedFruit == "Dough" then
        local skills = {"Z", "X", "C", "V"}
        for _, skill in ipairs(skills) do
            task.spawn(function()
                remote:InvokeServer("Skill", skill)
            end)
            task.wait(0.2)
        end
    end
end

return CombatModule
