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
    if CombatFramework and CombatFrameworkRoot then return end
    pcall(function()
        local possiblePaths = {
            LocalPlayer.PlayerScripts:FindFirstChild("CombatFramework"),
            LocalPlayer.PlayerScripts:FindFirstChild("CombatFrameworkR"),
            ReplicatedStorage:FindFirstChild("CombatFramework")
        }
        
        for _, framework in ipairs(possiblePaths) do
            if framework then
                local success, result = pcall(require, framework)
                if success and type(result) == "table" then
                    CombatFramework = result
                    break
                end
            end
        end

        if CombatFramework then
            -- Busca recursiva pelo controlador ativo nos upvalues
            local controller = CombatFramework.activeController
            if not controller then
                for _, v in pairs(CombatFramework) do
                    if type(v) == "table" and v.activeController then
                        controller = v.activeController
                        break
                    end
                end
            end

            if controller and (controller.attack or controller.Attack) then
                local attackFn = controller.attack or controller.Attack
                local upvalues = debug.getupvalues(attackFn)
                for _, v in pairs(upvalues) do
                    if type(v) == "table" and v.activeController then
                        CombatFrameworkRoot = v
                        break
                    end
                end
            end
        end
    end)
end

function CombatModule.StopFastAttack()
    if FastAttackConn then
        FastAttackConn:Disconnect()
        FastAttackConn = nil
    end
end

function CombatModule.StartFastAttack()
    if FastAttackConn then return end
    
    FastAttackConn = RunService.PostSimulation:Connect(function()
        if not _G.Settings or not _G.Settings.FastAttack then return end
        
        pcall(function()
            GetFramework()
            local weapon = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if not weapon or (weapon.ToolTip ~= "Melee" and weapon.ToolTip ~= "Sword") then return end
            
            local activeController = CombatFramework and CombatFramework.activeController
            if not activeController and CombatFrameworkRoot then
                activeController = CombatFrameworkRoot.activeController
            end

            if activeController then
                -- Otimização extrema (Estilo Redz)
                activeController.hitboxMagnitude = 100 -- Magnitude aumentada para alcance
                activeController.attackCount = 0
                activeController.timeToNextAttack = 0
                activeController.increment = 0
                activeController.active = true
                
                -- Spam de ataque contínuo
                for i = 1, 3 do
                    if activeController.attack then
                        activeController.attack()
                    elseif activeController.Attack then
                        activeController.Attack()
                    end
                end
            end
        end)
    end)
end

function CombatModule.StopKillAura()
    if KillAuraConn then
        KillAuraConn:Disconnect()
        KillAuraConn = nil
    end
end

function CombatModule.StartKillAura()
    if KillAuraConn then return end
    
    KillAuraConn = RunService.Stepped:Connect(function()
        if not _G.Settings or not _G.Settings.KillAura then return end
        
        pcall(function()
            local enemies = workspace:FindFirstChild("Enemies") or workspace
            local myPos = LocalPlayer.Character.HumanoidRootPart.Position
            local targets = {}
            
            for _, v in ipairs(enemies:GetChildren()) do
                if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                    local dist = (myPos - v.HumanoidRootPart.Position).Magnitude
                    if dist <= 100 then -- Alcance da Aura
                        table.insert(targets, v.HumanoidRootPart)
                    end
                end
            end

            if #targets > 0 then
                GetFramework()
                local activeController = CombatFramework and CombatFramework.activeController
                if not activeController and CombatFrameworkRoot then
                    activeController = CombatFrameworkRoot.activeController
                end

                if activeController then
                    -- Redz Hub Style: Ataca todos os alvos simultaneamente via Framework
                    for _, target in ipairs(targets) do
                        if activeController.attack then
                            activeController.attack()
                        elseif activeController.Attack then
                            activeController.Attack()
                        end
                        -- Dano direto via Remoto (Garantia de Hitbox)
                        CommF:InvokeServer("Attack", target)
                    end
                end
            end
        end)
    end)
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
