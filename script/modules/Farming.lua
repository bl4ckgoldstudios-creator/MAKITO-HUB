local FarmingModule = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

function FarmingModule.GetSea()
    local placeId = game.PlaceId
    if placeId == 2753915549 then return 1
    elseif placeId == 4442272183 then return 2
    elseif placeId == 7449423635 then return 3
    end
    return 1
end

function FarmingModule.GetQuestData(QuestData)
    local sea = FarmingModule.GetSea()
    local data = QuestData[sea]
    if not data then return nil end
    
    local level = LocalPlayer.Data.Level.Value
    for i = #data, 1, -1 do
        local q = data[i]
        if level >= q.Min then return q end
    end
    return data[1]
end

-- SUPREME QUEST HANDLER (ZERO DELAY)
function FarmingModule.SupremeQuestHandler(QuestData)
    local data = LocalPlayer:FindFirstChild("Data")
    if not data or not data:FindFirstChild("Level") then return nil end
    
    local level = data.Level.Value
    local sea = FarmingModule.GetSea()
    local currentQuests = QuestData[sea]
    if not currentQuests then return nil end
    
    -- IDENTIFICAÇÃO INSTANTÂNEA DA MELHOR MISSÃO
    local BestQuest = nil
    for i = #currentQuests, 1, -1 do
        local q = currentQuests[i]
        if level >= q.Min then
            BestQuest = q
            break
        end
    end

    if not BestQuest then 
        warn("[MAKITO ERROR]: Nenhuma missao encontrada para o Level " .. tostring(level))
        return nil 
    end

    -- VERIFICAÇÃO DE POSIÇÃO DO NPC
    if not BestQuest.Pos then
        warn("[MAKITO ERROR]: CFrame do NPC nulo para a missao: " .. BestQuest.Name)
        return BestQuest
    end

    -- VERIFICAÇÃO DE MISSÃO ATIVA (ROBUSTA)
    local hasQuest = false
    pcall(function()
        local questGui = LocalPlayer.PlayerGui:FindFirstChild("Main") and LocalPlayer.PlayerGui.Main:FindFirstChild("Quest")
        if questGui and questGui.Visible and questGui.Container.QuestTitle.Title.Text ~= "" then
            hasQuest = true
        end
    end)

    if not hasQuest and _G.Settings.AutoQuest then
        -- TELEPORTE E ACEITAÇÃO INSTANTÂNEA
        local npcPos = BestQuest.Pos
        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - npcPos.Position).Magnitude
        
        if dist > 15 then
            if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Indo ate NPC " .. BestQuest.NPC end
            _G.Utils.TweenTo(npcPos * CFrame.new(0, 15, 0), 500)
        else
            if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Aceitando Missao " .. BestQuest.Enemy end
            -- INTERAÇÃO COM NPC E START QUEST
            _G.Utils.SafeRemote("StartQuest", BestQuest.Name, BestQuest.ID)
        end
    end
    
    return BestQuest
end

function FarmingModule.EquipWeapon(weaponName)
    local target = weaponName == "Melee" and "Melee" or weaponName == "Sword" and "Sword" or "Fruit"
    
    for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if v:IsA("Tool") then
            if target == "Melee" and v.ToolTip == "Melee" then
                LocalPlayer.Character.Humanoid:EquipTool(v)
                break
            elseif target == "Sword" and v.ToolTip == "Sword" then
                LocalPlayer.Character.Humanoid:EquipTool(v)
                break
            elseif target == "Fruit" and (v.ToolTip == "Blox Fruit" or v.ToolTip == "Demon Fruit") then
                LocalPlayer.Character.Humanoid:EquipTool(v)
                break
            end
        end
    end
end

-- BLACK HOLE BRING MOBS (CLUSTER TOTAL)
function FarmingModule.BlackHoleBringMobs(targetEnemy)
    if not _G.Settings.BringMobs or not targetEnemy or not targetEnemy:FindFirstChild("HumanoidRootPart") then return end
    
    local targetPos = targetEnemy.HumanoidRootPart.CFrame
    local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
    
    for _, v in ipairs(enemiesFolder:GetChildren()) do
        if v.Name == targetEnemy.Name and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            -- TRAVA DE CFRAME AGRESSIVA
            v.HumanoidRootPart.CanCollide = false
            v.HumanoidRootPart.CFrame = targetPos
            v.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
            
            -- DESATIVAÇÃO DE IA E ANIMAÇÕES
            if v.Humanoid.Sit ~= true then v.Humanoid.Sit = true end
            
            -- ANTI-RESET SERVER-SIDE (BYPASS)
            pcall(function()
                if v:FindFirstChild("Data") and v.Data:FindFirstChild("SpawnPos") then
                    v.Data.SpawnPos.Value = targetPos.Position
                end
            end)
        end
    end
end

-- SUPREME AUTO FARM LOGIC
local lastDebugTick = 0
function FarmingModule.SupremeAutoFarm()
    if not _G.Settings.AutoFarm then return end
    
    -- ETAPA 1: BOTÃO PRESSIONADO
    if tick() - lastDebugTick > 30 then -- Debug a cada 30s para não dar spam
        lastDebugTick = tick()
        if _G.MakitoDebug then _G.MakitoDebug(1, "Botão pressionado. Flag _G.Settings.AutoFarm está TRUE.") end
    end

    pcall(function()
        local Quest = FarmingModule.SupremeQuestHandler(_G.Data.QuestData)
        
        -- ETAPA 2: BUSCA DE DADOS
        if not Quest then
            if _G.MakitoDebug then _G.MakitoDebug(2, "FALHA: Nenhuma missao encontrada para o Level " .. tostring(LocalPlayer.Data.Level.Value)) end
            return
        end

        -- ETAPA 3: VERIFICAÇÃO DE CFRAME
        if not Quest.Pos then
            if _G.MakitoDebug then _G.MakitoDebug(3, "FALHA: CFrame do NPC nulo para a missao: " .. Quest.Name) end
            return
        end

        local enemy = _G.Utils.GetNearestEnemy(Quest.Enemy)
        
        if enemy then
            -- ETAPA 4: MOVIMENTO
            if _G.MakitoStatus and _G.MakitoStatus.Text ~= "Status: Atacando " .. Quest.Enemy then
                if _G.MakitoDebug then _G.MakitoDebug(4, "Iniciando movimento Tween ate o monstro: " .. Quest.Enemy) end
            end

            -- 1. EQUIPAMENTO
            FarmingModule.EquipWeapon(_G.Settings.Weapon)
            
            -- 2. AGRUPAMENTO BLACK HOLE
            FarmingModule.BlackHoleBringMobs(enemy)
            
            -- 3. POSICIONAMENTO ELITE (ABAIXO OU ACIMA DO CLUSTER)
            local offset = _G.Settings.Distance or 10
            local targetCF = enemy.HumanoidRootPart.CFrame * CFrame.new(0, offset, 0) * CFrame.Angles(math.rad(-90), 0, 0)
            
            -- MOVIMENTAÇÃO SEM STUCK
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - targetCF.Position).Magnitude
            if dist > 50 then
                _G.Utils.TweenTo(targetCF)
            else
                _G.Utils.Float(true)
                LocalPlayer.Character.HumanoidRootPart.CFrame = targetCF
            end
            
            -- 4. COMBATE ULTRA
            _G.Combat.StartFastAttack()
        else
            -- ESPERA INTELIGENTE NO SPAWN
            local waitPos = Quest.Spawn or Quest.Pos
            _G.Utils.TweenTo(waitPos * CFrame.new(0, 30, 0))
            if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Aguardando Spawn de " .. Quest.Enemy end
        end
    end)
end

-- FRUIT FINDER & COLLECTOR (INSPIRED BY ALCHEMY)
function FarmingModule.FruitLogic()
    if _G.Settings.AutoFruitESP then
        _G.Utils.ClearESP()
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Tool") and (v.Name:find("Fruit") or v:FindFirstChild("Handle")) then
                _G.Utils.CreateESP(v, "🍎 " .. v.Name, Color3.fromRGB(255, 0, 0))
            end
        end
    end

    if _G.Settings.AutoCollectFruit then
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Tool") and (v.Name:find("Fruit") or v:FindFirstChild("Handle")) then
                local handle = v:FindFirstChild("Handle") or v
                local targetCF = handle.CFrame
                _G.Utils.TweenTo(targetCF)
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, handle, 0)
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, handle, 1)
                break
            end
        end
    end

    if _G.Settings.AutoStoreFruit then
        for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if v:IsA("Tool") and (v.ToolTip == "Blox Fruit" or v.ToolTip == "Demon Fruit") then
                _G.Utils.SafeRemote("StoreFruit", v.Name, v)
            end
        end
    end
end

function FarmingModule.AutoFarmNearestLogic()
    if not _G.Settings.AutoFarmNearest then return end
    
    local enemy = _G.Utils.GetNearestEnemyAny()
    if enemy then
        FarmingModule.EquipWeapon(_G.Settings.Weapon)
        _G.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0))
        _G.Combat.StartFastAttack()
    end
end

-- DUNGEON & RAID AUTOMATION
function FarmingModule.RaidLogic()
    if _G.Settings.AutoBuyChip then
        _G.Utils.SafeRemote("Raids", "BuyChip", _G.Settings.SelectedRaid)
    end
    
    if _G.Settings.AutoStartRaid then
        _G.Utils.SafeRemote("Raids", "StartRaid")
    end
    
    if _G.Settings.AutoDungeon then
        local island = workspace:FindFirstChild("Island") -- Nome genérico, ajustar conforme o jogo
        if island then
            local enemy = _G.Utils.GetNearestEnemyAny()
            if enemy then
                _G.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0))
                _G.Combat.StartFastAttack()
            end
        end
    end
    
    if _G.Settings.AutoNextIsland then
        -- Lógica de avançar para a próxima ilha da raid (teleporte para o centro da próxima)
    end
    
    if _G.Settings.AutoAwaken then
        _G.Utils.SafeRemote("AwakenSkill")
    end
end

-- SHOP & INSTÂNCIAS
function FarmingModule.ShopLogic()
    if _G.Settings.AutoBuyFightingStyle then
        local styles = {"Godhuman", "Superhuman", "Electric Claw", "Dragon Talon", "Death Step", "Sharkman Karate"}
        for _, style in ipairs(styles) do
            _G.Utils.SafeRemote("BuyFightingStyle", style)
        end
    end
    
    if _G.Settings.AutoBuyLegendarySword then
        local swords = {"Shisui", "Wando", "Sadi"}
        for _, sword in ipairs(swords) do
            _G.Utils.SafeRemote("LegendarySwordDealer", sword)
        end
    end
    
    if _G.Settings.AutoGacha then
        _G.Utils.SafeRemote("FruitGacha")
    end
end

-- CHEST FARM
function FarmingModule.ChestFarmLogic()
    if not _G.Settings.AutoChest then return end
    
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Name:find("Chest") and v:IsA("Part") then
            if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Coletando Baú..." end
            _G.Utils.TweenTo(v.CFrame)
            task.wait(0.2)
        end
    end
end

-- ADVANCED AUTO SOUL GUITAR
function FarmingModule.AutoSoulGuitarLogic()
    if not _G.Settings.AutoSoulGuitar then return end
    
    local hasSoulGuitar = LocalPlayer.Backpack:FindFirstChild("Soul Guitar") or LocalPlayer.Character:FindFirstChild("Soul Guitar")
    if hasSoulGuitar then return end
    
    local sea = FarmingModule.GetSea()
    if sea ~= 3 then return end

    -- 1. Check if Full Moon
    local isFullMoon = game:GetService("Lighting").Sky.FullMoonMagnitude > 0.9
    
    if isFullMoon then
        -- Go to Gravestone
        local gravePos = CFrame.new(-9515, 164, -5785)
        _G.Utils.TweenTo(gravePos)
        
        if (LocalPlayer.Character.HumanoidRootPart.Position - gravePos.Position).Magnitude < 10 then
            _G.Utils.SafeRemote("SoulGuitar", "Pray")
        end
    end

    -- 2. Material Farm for Soul Guitar
    -- Needs: 500 Bones, 250 Ectoplasm, 1 Dark Fragment
    local bones = LocalPlayer.Data:FindFirstChild("Bones") and LocalPlayer.Data.Bones.Value or 0
    
    if bones < 500 then
        if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Farmando Ossos para Soul Guitar (" .. bones .. "/500)" end
        local enemy = _G.Utils.GetNearestEnemy("Reborn Skeleton") or _G.Utils.GetNearestEnemy("Living Zombie")
        if enemy then
            FarmingModule.EquipWeapon(_G.Settings.Weapon)
            _G.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0))
            _G.Combat.StartFastAttack()
        end
    end
end

-- AUTO CDK (CURSED DUAL KATANA)
function FarmingModule.AutoCDKLogic()
    if not _G.Settings.AutoCDK then return end
    
    local hasCDK = LocalPlayer.Backpack:FindFirstChild("Cursed Dual Katana") or LocalPlayer.Character:FindFirstChild("Cursed Dual Katana")
    if hasCDK then return end

    -- Needs Yama and Tushita at 350 Mastery
    local yama = LocalPlayer.Backpack:FindFirstChild("Yama") or LocalPlayer.Character:FindFirstChild("Yama")
    local tushita = LocalPlayer.Backpack:FindFirstChild("Tushita") or LocalPlayer.Character:FindFirstChild("Tushita")
    
    if yama and tushita then
        -- Mastery Check Logic here
        -- If mastery < 350, go farm mastery
    else
        -- Logic to get Yama/Tushita
        if not yama then
            -- Go to Hydra Island Secret Room
        end
    end
end

-- AUTO GODHUMAN
function FarmingModule.AutoGodhumanLogic()
    if not _G.Settings.AutoGodhuman then return end
    
    -- Needs multiple materials and 400 mastery on all V2 fighting styles
    -- This is a complex chain, starting with material farm
    local mat = _G.Settings.SelectedMaterial or "Dragon Scale"
    local data = _G.Data.MaterialData[mat]
    
    if data then
        if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Farmando " .. mat end
        local enemy = _G.Utils.GetNearestEnemy(data.Enemy)
        if enemy then
            FarmingModule.EquipWeapon(_G.Settings.Weapon)
            _G.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0))
            _G.Combat.StartFastAttack()
        else
            _G.Utils.TweenTo(data.Pos)
        end
    end
end

-- AUTO RACE V4 (TRIAL SOLVER)
function FarmingModule.AutoTrialLogic()
    if not _G.Settings.AutoTrial then return end
    
    local trialPart = workspace:FindFirstChild("TrialPart") -- Example name
    if trialPart then
        _G.Utils.TweenTo(trialPart.CFrame)
        -- Solver logic for specific race trials
        if LocalPlayer.Data.Race.Value == "Mink" then
            -- Auto pathfind through maze
        elseif LocalPlayer.Data.Race.Value == "Human" then
            -- Auto kill trial boss
        end
    end
end

-- AUTO STATS
function FarmingModule.AutoStatsLogic()
    if not _G.Settings.AutoStats then return end
    
    local stat = _G.Settings.SelectedStat
    local remoteStat = stat == "Melee" and "Melee" or stat == "Defense" and "Defense" or stat == "Sword" and "Sword" or stat == "Gun" and "Gun" or "Demon Fruit"
    
    local points = LocalPlayer.Data.StatsPoints.Value
    if points > 0 then
        _G.Utils.SafeRemote("AddPoint", remoteStat, points)
    end
end

-- AUTO NEXT SEA
function FarmingModule.AutoNextSeaLogic()
    if not _G.Settings.AutoNextSea then return end
    local level = LocalPlayer.Data.Level.Value
    local sea = FarmingModule.GetSea()
    
    if sea == 1 and level >= 700 then
        _G.Utils.TweenTo(CFrame.new(-4842, 718, -2621))
        _G.Utils.SafeRemote("TravelMain")
    elseif sea == 2 and level >= 1500 then
        _G.Utils.TweenTo(CFrame.new(-5400, 15, 1000))
        _G.Utils.SafeRemote("TravelZou")
    end
end

-- FRUIT SYSTEM (SNIPER, STORE, FINDER)
function FarmingModule.FruitLogic()
    -- 1. Fruit Finder & Sniper
    if _G.Settings.AutoFruitFinder or _G.Settings.AutoSnipe then
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Tool") and (v.Name:find("Fruit") or v:FindFirstChild("Handle")) then
                if _G.Settings.AutoSnipe then
                    local isRare = false
                    for _, rare in ipairs(_G.Settings.SnipeFruits or {}) do
                        if v.Name:find(rare) then isRare = true break end
                    end
                    if isRare then
                        if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: SNIPING " .. v.Name end
                        _G.Utils.TweenTo(v.Handle.CFrame)
                    end
                elseif _G.Settings.AutoFruitFinder then
                    _G.Utils.TweenTo(v.Handle.CFrame)
                end
            end
        end
    end

    -- 2. Auto Store Fruit
    if _G.Settings.AutoStoreFruit then
        local fruit = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
        if fruit and (fruit.ToolTip == "Blox Fruit" or fruit.ToolTip == "Demon Fruit") then
            _G.Utils.SafeRemote("StoreFruit", fruit.Name, fruit)
        end
    end

    -- 3. Auto Bring Fruit (Magnetic)
    if _G.Settings.AutoBringFruit then
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Tool") and (v.Name:find("Fruit") or v:FindFirstChild("Handle")) then
                v.Handle.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
            end
        end
    end

    -- 4. Shop Sniper (Auto Buy)
    if _G.Settings.AutoBuyFruit then
        for _, rare in ipairs(_G.Settings.SnipeFruits or {}) do
            _G.Utils.SafeRemote("BuyFruit", rare)
        end
    end
end

-- LEVIATHAN SOLVER & SEA 3 ADVANCED
function FarmingModule.LeviathanLogic()
    if not _G.Settings.AutoLeviathan then return end
    
    local SeaEvents = workspace:FindFirstChild("SeaEvents") or workspace:FindFirstChild("Sea")
    if not SeaEvents then return end

    local Leviathan = SeaEvents:FindFirstChild("Leviathan")
    if Leviathan then
        if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: MATANDO LEVIATHAN" end
        -- Position above the head to avoid most attacks
        local head = Leviathan:FindFirstChild("Head") or Leviathan.PrimaryPart
        if head then
            _G.Utils.TweenTo(head.CFrame * CFrame.new(0, 50, 0))
            _G.Combat.StartFastAttack()
            
            -- Auto Use Skills for max damage
            _G.Combat.UseSkill("Z")
            _G.Combat.UseSkill("X")
            _G.Combat.UseSkill("C")
        end
    else
        -- Search for Leviathan Gates or Cold Zone
        if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Procurando Leviathan..." end
    end
end

return FarmingModule
