local FarmingModule = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local SEA_PLACE_IDS = {
    [2753915549] = 1,
    [4442272183] = 2,
    [4442272121] = 2,
    [7449423635] = 3,
}

function FarmingModule.GetSea()
    return SEA_PLACE_IDS[game.PlaceId] or 1
end

function FarmingModule.GetQuestData(QuestData)
    local sea = FarmingModule.GetSea()
    local data = QuestData and QuestData[sea]
    if not data then return nil end

    local levelValue = LocalPlayer.Data:FindFirstChild("Level")
    local level = levelValue and levelValue.Value or 0

    for i = #data, 1, -1 do
        local q = data[i]
        if level >= (q.Min or 0) then return q end
    end
    return data[1]
end

-- SUPREME QUEST HANDLER V3 (ANTI-LOOP & ROBUST DETECTION)
function FarmingModule.SupremeQuestHandler(QuestData)
    local level = (LocalPlayer.Data and LocalPlayer.Data.Level.Value) or 0
    local sea = FarmingModule.GetSea()
    local currentQuests = QuestData[sea]
    if not currentQuests then return nil end
    
    local BestQuest = nil
    for i = #currentQuests, 1, -1 do
        local q = currentQuests[i]
        if level >= q.Min then
            BestQuest = q
            break
        end
    end

    if not BestQuest then return nil end

    local hasQuest = false
    local activeQuestName = ""
    
    pcall(function()
        local mainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
        local questGui = mainGui and mainGui:FindFirstChild("Quest")
        
        if questGui and questGui.Visible then
            local container = questGui:FindFirstChild("Container")
            local title = container and container:FindFirstChild("QuestTitle")
            local titleText = title and title.Text or ""
            
            if titleText ~= "" then
                -- Verifica se a missão atual é a que queremos (ou se é uma variação do inimigo)
                if titleText:lower():find(BestQuest.Enemy:lower()) or titleText:lower():find(BestQuest.Name:lower()) then
                    hasQuest = true
                    _G.IsTalkingToNPC = false
                else
                    -- Missão errada, abandona
                    _G.IsTalkingToNPC = true
                    _G.Utils.SafeRemote("AbandonQuest")
                    task.wait(0.5)
                    _G.IsTalkingToNPC = false
                end
            end
        end
    end)

    -- Debounce para evitar spam de NPC se a UI demorar a aparecer
    if not hasQuest and _G.Settings and _G.Settings.AutoQuest then
        -- SEGURANÇA: Verifica se o personagem e o root part existem
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if not root then return BestQuest, false end

        -- Verifica se já enviamos o comando de StartQuest recentemente (cache de 2 segundos)
        if _G.LastQuestTime and tick() - _G.LastQuestTime < 2 then
            return BestQuest, false
        end

        local npcPos = BestQuest.Pos
        if not npcPos then return BestQuest, false end

        local dist = (root.Position - npcPos.Position).Magnitude
        
        if dist > 20 then
            _G.IsTalkingToNPC = true -- Trava o farm enquanto vai ao NPC
            if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Indo ate NPC " .. (BestQuest.NPC or "Desconhecido") end
            _G.Utils.TweenTo(npcPos)
        else
            _G.IsTalkingToNPC = true
            if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Aceitando Missao " .. (BestQuest.Enemy or "Inimigo") end
            
            -- Pequeno delay para estabilizar a posição antes de falar com o NPC
            -- Isso evita o erro no NPCManager do Blox Fruits
            task.wait(0.2)
            _G.Utils.SafeRemote("StartQuest", BestQuest.Name, BestQuest.ID)
            _G.LastQuestTime = tick() -- Marca o tempo que pegou a missão
            task.wait(0.3)
        end
    end
    
    return BestQuest, hasQuest
end

function FarmingModule.EquipWeapon(weaponName)
    local target = weaponName == "Melee" and "Melee" or weaponName == "Sword" and "Sword" or "Fruit"
    local char = LocalPlayer.Character
    if not char then return end

    local current = char:FindFirstChildOfClass("Tool")
    if current and current.ToolTip == target then return end
    if target == "Fruit" and current and (current.ToolTip == "Blox Fruit" or current.ToolTip == "Demon Fruit") then return end

    for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if v:IsA("Tool") then
            if (target == "Melee" and v.ToolTip == "Melee") or 
               (target == "Sword" and v.ToolTip == "Sword") or 
               (target == "Fruit" and (v.ToolTip == "Blox Fruit" or v.ToolTip == "Demon Fruit")) then
                char.Humanoid:EquipTool(v)
                break
            end
        end
    end
end

function FarmingModule.MasteryLogic(enemy)
    if not _G.Settings or not enemy or not enemy:FindFirstChild("Humanoid") then return end
    
    local healthPercent = (enemy.Humanoid.Health / enemy.Humanoid.MaxHealth) * 100
    local threshold = _G.Settings.MasteryHealth or 20
    
    if healthPercent <= threshold then
        FarmingModule.EquipWeapon(_G.Settings.MasteryWeapon)
    else
        FarmingModule.EquipWeapon(_G.Settings.MainWeapon or "Melee")
    end
end

function FarmingModule.BlackHoleBringMobs(targetEnemy)
    if not _G.Settings or not _G.Settings.BringMobs or not targetEnemy or not targetEnemy:FindFirstChild("HumanoidRootPart") then return end
    
    local targetPos = targetEnemy.HumanoidRootPart.CFrame
    local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
    
    for _, v in ipairs(enemiesFolder:GetChildren()) do
        if v.Name:find(targetEnemy.Name:split(" [")[1]) and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            -- ULTRA BRING LOGIC (SAFE VERSION)
            v.HumanoidRootPart.CanCollide = false
            v.HumanoidRootPart.CFrame = targetPos
            v.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
            
            if v.Humanoid.PlatformStand ~= true then
                v.Humanoid.PlatformStand = true
            end
            
            -- Bypass anti-despawn mantendo o estado de combate local
            pcall(function()
                if v:FindFirstChild("Data") and v.Data:FindFirstChild("SpawnPos") then
                    v.Data.SpawnPos.Value = targetPos.Position
                end
            end)
        end
    end
end

function FarmingModule.SupremeAutoFarm()
    if not _G.Settings or (not _G.Settings.AutoFarm and not _G.Settings.AutoFarmLevel) then return end
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if not root or not hum then return end

    -- AUTO HEALTH SAFETY: Pausa se a vida estiver muito baixa (< 20%)
    if hum.Health / hum.MaxHealth < 0.2 then
        if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Recuperando Vida..." end
        _G.Combat.StopCombatLoop()
        root.CFrame = root.CFrame * CFrame.new(0, 100, 0) -- Sobe para segurança
        return
    end

    -- AUTO NEXT SEA INTEGRATION
    if _G.Settings.AutoNextSea then
        local level = (LocalPlayer.Data and LocalPlayer.Data.Level.Value) or 0
        if (FarmingModule.GetSea() == 1 and level >= 700) or (FarmingModule.GetSea() == 2 and level >= 1500) then
            FarmingModule.AutoNextSeaLogic()
            return
        end
    end

    pcall(function()
        local Quest, isQuestActive = FarmingModule.SupremeQuestHandler(_G.Data.QuestData)
        if not Quest then return end
        
        -- NO-CLIP E FLOAT SEMPRE ATIVOS DURANTE O FARM
        _G.Utils.SetNoClip(true)
        _G.Utils.Float(true)

        -- SÓ FARMA SE A MISSÃO ESTIVER REALMENTE ATIVA NA UI
        if not isQuestActive then 
            _G.Combat.StopCombatLoop()
            return 
        end

        local enemy = _G.Utils.GetNearestEnemy(Quest.Enemy)
        
        -- BOSS PRIORITY: Verifica se o boss da missão spawnou
        local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
        for _, v in ipairs(enemiesFolder:GetChildren()) do
            if v.Name:find(Quest.Enemy) and (v.Name:find("Boss") or v.Name:find("RAID")) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                enemy = v
                break
            end
        end

        if enemy and enemy:FindFirstChild("HumanoidRootPart") then
            local targetPos = enemy.HumanoidRootPart.CFrame * CFrame.new(0, _G.Settings.Distance or 12, 0)

            -- Movimentação Inteligente
            local dist = (root.Position - targetPos.Position).Magnitude
            if dist > 300 then
                _G.Utils.TweenTo(targetPos)
            else
                root.CFrame = targetPos
            end

            -- Lógica de Maestria e Arma
            if _G.Settings.AutoMastery then
                FarmingModule.MasteryLogic(enemy)
            else
                FarmingModule.EquipWeapon(_G.Settings.MainWeapon or "Melee")
            end

            -- Ataca com o Motor de Combate Otimizado
            _G.Combat.StartCombatLoop()
            
            -- Traz os mobs para perto (Black Hole)
            FarmingModule.BlackHoleBringMobs(enemy)
        else
            -- Se não achou o inimigo mas a quest tá ativa, vai para o spawn deles
            if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Aguardando Inimigos..." end
            local spawnPos = Quest.Spawn or Quest.Pos
            _G.Utils.TweenTo(spawnPos * CFrame.new(0, 50, 0))
        end
    end)
end

function FarmingModule.AutoCDKLogic()
    if not _G.Settings.AutoCDK then return end
    -- Yama & Tushita quests check
    if not _G.Utils.HasItem("Yama") or not _G.Utils.HasItem("Tushita") then
        FarmingModule.PuzzleLogic()
        return
    end
    _G.Utils.SafeRemote("CDKQuest", "Start")
end

function FarmingModule.AutoSoulGuitarLogic()
    if not _G.Settings.AutoSoulGuitar then return end
    _G.Utils.TweenTo(CFrame.new(-1050, 40, -8500))
    _G.Utils.SafeRemote("SoulGuitarQuest", "Pray")
end

function FarmingModule.AutoGodhumanLogic()
    if not _G.Settings.AutoGodhuman then return end
    _G.Utils.TweenTo(CFrame.new(-12463, 375, -7523))
    _G.Utils.SafeRemote("BuyFightingStyle", "Godhuman")
end

function FarmingModule.AutoBerryFarm()
    if not _G.Settings or not _G.Settings.AutoFarmChests then return end
    
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Name:find("Chest") then
            _G.Utils.TweenTo(v.CFrame)
            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v, 0)
            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v, 1)
            break
        end
    end
end

function FarmingModule.AutoStatsLogic()
    if _G.Utils and _G.Utils.AutoBuildStats then
        _G.Utils.AutoBuildStats()
    end
end

function FarmingModule.AutoNextSeaLogic()
    local level = LocalPlayer.Data.Level.Value
    local sea = FarmingModule.GetSea()
    
    if sea == 1 and level >= 700 then
        -- Vai para o NPC do Sea 2 (Military Detective na Prisão)
        _G.Utils.TweenTo(CFrame.new(4875, 5, 749))
        _G.Utils.SafeRemote("TravelMain")
    elseif sea == 2 and level >= 1500 then
        -- Vai para o NPC do Sea 3 (Mr. Captain no Coliseu)
        _G.Utils.TweenTo(CFrame.new(-1580, 7, -2980))
        _G.Utils.SafeRemote("TravelZou")
    end
end

function FarmingModule.SeaEventLogic()
    FarmingModule.EventAutomationLogic()
    
    -- TERROR SHARK AUTO-FARM
    if _G.Settings.AutoTerrorShark then
        local boss = workspace.Enemies:FindFirstChild("Terrortshark") or workspace.Enemies:FindFirstChild("Terror Shark")
        if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
            _G.Utils.TweenTo(boss.HumanoidRootPart.CFrame * CFrame.new(0, 40, 0))
            _G.Combat.StartFastAttack()
            return
        end
    end

    -- LEVIATHAN AUTO-FARM
    if _G.Settings.AutoLeviathan then
        local boss = workspace.Enemies:FindFirstChild("Leviathan")
        if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
            _G.Utils.TweenTo(boss.HumanoidRootPart.CFrame * CFrame.new(0, 60, 0))
            _G.Combat.StartFastAttack()
            return
        end
    end

    -- KITSUNE ISLAND
    if _G.Settings.AutoKitsune then
        local island = workspace:FindFirstChild("KitsuneIsland")
        if island then
            _G.Utils.TweenTo(island:GetModelCFrame())
            -- Coleta as esferas azuis
            for _, v in ipairs(workspace:GetChildren()) do
                if v.Name == "Azure Orb" then
                    _G.Utils.TweenTo(v.CFrame)
                end
            end
        end
    end
    
    if _G.Settings.AutoSeaBeast then
        local boss = workspace.Enemies:FindFirstChild("Sea Beast")
        if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
            _G.Utils.TweenTo(boss.HumanoidRootPart.CFrame * CFrame.new(0, 50, 0))
            _G.Combat.StartFastAttack()
        end
    end
end

function FarmingModule.ProgressionLogic()
    if not _G.Settings then return end
    
    FarmingModule.RaidLogic()
    FarmingModule.PuzzleLogic()
end

function FarmingModule.EventAutomationLogic()
    if not _G.Settings then return end

    if _G.Settings.AutoRaceV2 then
        -- Lógica simplificada: Coleta flores
        for _, flower in ipairs({"Flower1", "Flower2", "Flower3"}) do
            local f = workspace:FindFirstChild(flower)
            if f then _G.Utils.TweenTo(f.CFrame) end
        end
    end

    if _G.Settings.AutoRaceV3 then
        _G.Utils.SafeRemote("Arowe", "StartQuest")
    end

    if _G.Settings.AutoRaceV4 or _G.Settings.AutoTrial or _G.Settings.AutoRaceAwakening then
        local trialPlate = workspace:FindFirstChild("TrialPlate")
        if trialPlate then
            _G.Utils.TweenTo(trialPlate.CFrame)
            -- Simula o uso da skill T para ativar o trial
            local vim = game:GetService("VirtualInputManager")
            vim:SendKeyEvent(true, Enum.KeyCode.T, false, game)
            task.wait(0.1)
            vim:SendKeyEvent(false, Enum.KeyCode.T, false, game)
        end
    end

    if _G.Settings.AutoSharkAnchor then
        local boss = workspace.Enemies:FindFirstChild("Terrorshark")
        if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
            _G.Utils.TweenTo(boss.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
            _G.Combat.StartFastAttack()
        end
    end

    if _G.Settings.AutoFrozenDimension then
        _G.Utils.TweenTo(CFrame.new(-19500, -500, -18000)) -- Posição aproximada
    end

    if _G.Settings.AutoKitsuneShrine then
        local shrine = workspace:FindFirstChild("KitsuneShrine")
        if shrine then _G.Utils.TweenTo(shrine.CFrame) end
    end

    if _G.Settings.AutoPrehistoricIsland then
        local island = workspace:FindFirstChild("PrehistoricIsland")
        if island then _G.Utils.TweenTo(island:GetModelCFrame()) end
    end

    if _G.Settings.AutoVolcanoEvent then
        local volcano = workspace:FindFirstChild("Volcano")
        if volcano then _G.Utils.TweenTo(volcano.CFrame) end
    end

    if _G.Settings.AutoDarkbeard then
        local boss = workspace.Enemies:FindFirstChild("Darkbeard")
        if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
            _G.Utils.TweenTo(boss.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
            _G.Combat.StartFastAttack()
        end
    end
end

function FarmingModule.AutoFarmNearestLogic()
    if not _G.Settings or not _G.Settings.AutoFarmNearest then return end
    
    local enemy = _G.Utils.GetNearestEnemyAny()
    if enemy then
        FarmingModule.EquipWeapon(_G.Settings.Weapon)
        _G.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0))
        _G.Combat.StartFastAttack()
    end
end

function FarmingModule.FruitLogic()
    if not _G.Settings then return end
    
    if _G.Settings.AutoFruitESP then
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Tool") and (v.Name:find("Fruit") or v:FindFirstChild("Handle")) then
                _G.Utils.CreateESP(v:FindFirstChild("Handle") or v, "🍎 " .. v.Name, Color3.fromRGB(255, 0, 0), "Fruit")
            end
        end
    end

    if _G.Settings.AutoCollectFruit or _G.Settings.AutoFruitFinder then
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Tool") and (v.Name:find("Fruit") or v:FindFirstChild("Handle")) then
                local handle = v:FindFirstChild("Handle") or v
                _G.Utils.TweenTo(handle.CFrame)
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, handle, 0)
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, handle, 1)
                break
            end
        end
    end

    if _G.Settings.AutoBringFruit then
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Tool") and (v.Name:find("Fruit") or v:FindFirstChild("Handle")) then
                local handle = v:FindFirstChild("Handle") or v
                handle.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
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

function FarmingModule.SpecialBossLogic()
    if not _G.Settings then return end
    
    if _G.Settings.AutoEliteHunter then
        local eliteNPC = workspace.NPCs:FindFirstChild("Elite Hunter")
        if eliteNPC then _G.Utils.SafeRemote("EliteHunter", "GetQuest") end
        local enemies = workspace:FindFirstChild("Enemies") or workspace
        for _, elite in ipairs({"Deandre", "Diablo", "Urban"}) do
            local v = enemies:FindFirstChild(elite)
            if v and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                _G.Utils.TweenTo(v.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0))
                _G.Combat.StartFastAttack()
                return
            end
        end
    end

    if _G.Settings.AutoFactory then
        local core = workspace:FindFirstChild("Core")
        if core then
            _G.Utils.TweenTo(core.CFrame * CFrame.new(0, 10, 0))
            _G.Combat.StartFastAttack()
        end
    end

    if _G.Settings.AutoRipIndra then
        local boss = workspace.Enemies:FindFirstChild("rip_indra True Form") or workspace.Enemies:FindFirstChild("rip_indra")
        if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
            _G.Utils.TweenTo(boss.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0))
            _G.Combat.StartFastAttack()
        end
    end

    if _G.Settings.AutoLaw then
        local boss = workspace.Enemies:FindFirstChild("Order")
        if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
            _G.Utils.TweenTo(boss.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0))
            _G.Combat.StartFastAttack()
        end
    end

    if _G.Settings.AutoBeautifulPirate then
        local boss = workspace.Enemies:FindFirstChild("Beautiful Pirate")
        if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
            _G.Utils.TweenTo(boss.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0))
            _G.Combat.StartFastAttack()
        end
    end

    if _G.Settings.AutoDoughKing or _G.Settings.AutoCakePrince then
        local bossName = _G.Settings.AutoDoughKing and "Dough King" or "Cake Prince"
        local enemies = workspace:FindFirstChild("Enemies") or workspace
        local boss = enemies:FindFirstChild(bossName)
        if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
            _G.Utils.TweenTo(boss.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0))
            _G.Combat.StartFastAttack()
        end
    end
end

function FarmingModule.AutoFarmMaterialLogic()
    if not _G.Settings or not _G.Settings.AutoFarmMaterial or not _G.Settings.SelectedMaterial then return end
    
    local matData = _G.Data.MaterialData[_G.Settings.SelectedMaterial]
    if matData then
        local enemy = _G.Utils.GetNearestEnemy(matData.Enemy)
        if enemy then
            FarmingModule.EquipWeapon(_G.Settings.Weapon)
            _G.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0))
            _G.Combat.StartFastAttack()
        else
            _G.Utils.TweenTo(matData.Pos)
        end
    end
end

function FarmingModule.AutoBoneLogic()
    if not _G.Settings or not _G.Settings.AutoBone then return end
    local sea = FarmingModule.GetSea()
    if sea ~= 3 then return end
    
    local enemy = _G.Utils.GetNearestEnemy("Reborn Skeleton") or _G.Utils.GetNearestEnemy("Living Zombie") or _G.Utils.GetNearestEnemy("Demonic Soul") or _G.Utils.GetNearestEnemy("Posessed Mummy")
    if enemy then
        FarmingModule.EquipWeapon(_G.Settings.Weapon)
        _G.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0))
        _G.Combat.StartFastAttack()
    else
        _G.Utils.TweenTo(CFrame.new(-9515, 164, -5785))
    end
end

function FarmingModule.RaidLogic()
    if not _G.Settings then return end
    
    if _G.Settings.AutoBuyChip then
        _G.Utils.SafeRemote("Raids", "BuyChip", _G.Settings.SelectedRaid)
    end
    if _G.Settings.AutoStartRaid then
        _G.Utils.SafeRemote("Raids", "StartRaid")
    end
    if _G.Settings.AutoDungeon then
        local enemy = _G.Utils.GetNearestEnemyAny()
        if enemy then
            _G.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0))
            _G.Combat.StartFastAttack()
        end
        if _G.Settings.AutoNextIsland then
            local enemies = workspace:FindFirstChild("Enemies") or workspace
            local count = 0
            for _, v in ipairs(enemies:GetChildren()) do
                if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then count = count + 1 end
            end
            if count == 0 then
                local raidStatus = LocalPlayer.PlayerGui.Main:FindFirstChild("RaidStatus")
                local islandLabel = raidStatus and raidStatus:FindFirstChild("Island")
                local nextIslandNum = (islandLabel and tonumber(islandLabel.Text) or 1) + 1
                local nextIsland = workspace:FindFirstChild("Island" .. nextIslandNum)
                if nextIsland then _G.Utils.TweenTo(nextIsland.CFrame) end
            end
        end
    end
    if _G.Settings.AutoAwaken then _G.Utils.SafeRemote("AwakenSkill") end
end

function FarmingModule.PuzzleLogic()
    if not _G.Settings then return end

    if _G.Settings.AutoSaber then
        -- Lógica simplificada: Clica nos botões da selva
        local buttons = {"Button1", "Button2", "Button3", "Button4", "Button5"}
        for _, b in ipairs(buttons) do
            local part = workspace.Map.Jungle:FindFirstChild(b)
            if part then
                _G.Utils.TweenTo(part.CFrame)
                task.wait(0.5)
            end
        end
        _G.Utils.SafeRemote("SaberQuest")
    end

    if _G.Settings.AutoPole then
        local boss = workspace.Enemies:FindFirstChild("Thunder God")
        if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
            _G.Utils.TweenTo(boss.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0))
            _G.Combat.StartFastAttack()
        end
    end

    if _G.Settings.AutoYama then
        _G.Utils.TweenTo(CFrame.new(-5247, 5, 4488))
        _G.Utils.SafeRemote("YamaQuest")
    end

    if _G.Settings.AutoTushita then
        _G.Utils.TweenTo(CFrame.new(5259, 604, 346))
        _G.Utils.SafeRemote("TushitaQuest")
    end
end

function FarmingModule.SnipeLogic()
    if not _G.Settings or not _G.Settings.AutoSnipe then return end
    
    local fruitNames = _G.Settings.SnipeFruits or {}
    for _, fruit in ipairs(fruitNames) do
        _G.Utils.SafeRemote("BuyFruit", fruit)
    end
end

function FarmingModule.SeaEventLogic()
    if not _G.Settings then return end
    
    local SeaEvents = workspace:FindFirstChild("SeaEvents") or workspace:FindFirstChild("Sea")
    
    if _G.Settings.AutoMirage then FarmingModule.MirageSolver() end

    if not SeaEvents then return end

    if _G.Settings.AutoSeaBeast then
        local sb = SeaEvents:FindFirstChild("Sea Beast") or SeaEvents:FindFirstChild("SeaBeast")
        if sb and sb:FindFirstChild("Humanoid") and sb.Humanoid.Health > 0 then
            _G.Utils.TweenTo(sb.HumanoidRootPart.CFrame * CFrame.new(0, 50, 0))
            _G.Combat.StartFastAttack()
            return
        end
    end

    if _G.Settings.AutoTerrorShark then
        local ts = SeaEvents:FindFirstChild("Terrorshark")
        if ts and ts:FindFirstChild("Humanoid") and ts.Humanoid.Health > 0 then
            _G.Utils.TweenTo(ts.HumanoidRootPart.CFrame * CFrame.new(0, 40, 0))
            _G.Combat.StartFastAttack()
            return
        end
    end

    if _G.Settings.AutoRumbling then
        local rumble = SeaEvents:FindFirstChild("Rumbling")
        if rumble then
            _G.Utils.TweenTo(rumble:GetModelCFrame() * CFrame.new(0, 50, 0))
            _G.Combat.StartFastAttack()
        end
    end

    if _G.Settings.AutoShipRaid then
        local ship = SeaEvents:FindFirstChild("Ship")
        if ship then
            _G.Utils.TweenTo(ship:GetModelCFrame() * CFrame.new(0, 50, 0))
            _G.Combat.StartFastAttack()
        end
    end

    if _G.Settings.AutoKitsune then
        local kitsune = workspace:FindFirstChild("KitsuneIsland")
        if kitsune then
            _G.Utils.TweenTo(kitsune:GetModelCFrame())
            for _, v in ipairs(workspace:GetChildren()) do
                if v.Name == "AzureFlame" then
                    _G.Utils.TweenTo(v.CFrame)
                    break
                end
            end
        end
    end

    if _G.Settings.AutoLeviathan then FarmingModule.LeviathanLogic() end
end

function FarmingModule.ShopLogic()
    if not _G.Settings then return end
    
    if _G.Settings.AutoBuyFightingStyle then
        local styles = {"Black Leg", "Electro", "Fishman Karate", "Dragon Breath", "Superhuman", "Death Step", "Sharkman Karate", "Electric Claw", "Dragon Talon", "Godhuman"}
        for _, style in ipairs(styles) do _G.Utils.SafeRemote("BuyFightingStyle", style) end
    end
    if _G.Settings.AutoBuyLegendarySword then
        local swords = {"Shisui", "Wando", "Sadi", "True Triple Katana"}
        for _, sword in ipairs(swords) do _G.Utils.SafeRemote("LegendarySwordDealer", sword) end
    end
    if _G.Settings.AutoBuyAccessory then
        local accessories = {"Black Cape", "Swordsman Hat", "Pink Coat", "Tomoe Rings"}
        for _, acc in ipairs(accessories) do _G.Utils.SafeRemote("BuyAccessory", acc) end
    end
    if _G.Settings.AutoGacha then _G.Utils.SafeRemote("FruitGacha") end
end

function FarmingModule.BuyItem(type, name)
    if type == "Ability" then _G.Utils.SafeRemote("BuyAbility", name)
    elseif type == "Weapon" then _G.Utils.SafeRemote("BuyItem", name)
    elseif type == "FightingStyle" then _G.Utils.SafeRemote("BuyFightingStyle", name)
    end
end

function FarmingModule.ChestFarmLogic()
    if not _G.Settings or not _G.Settings.AutoChest then return end
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Name:find("Chest") and v:IsA("Part") then
            _G.Utils.TweenTo(v.CFrame)
            task.wait(0.2)
        end
    end
end

function FarmingModule.EndGameLogic()
    if not _G.Settings then return end
    
    FarmingModule.AutoCDKLogic()
    FarmingModule.AutoSoulGuitarLogic()
    FarmingModule.AutoGodhumanLogic()
    FarmingModule.AutoSharkAnchorLogic()
    FarmingModule.SanguineArtLogic()
    FarmingModule.AutoYamaLogic()
    FarmingModule.AutoTushitaLogic()
end
function FarmingModule.AutoYamaLogic()
    if not _G.Settings or not _G.Settings.AutoYama then return end
    
    local eliteCount = (LocalPlayer.Data and LocalPlayer.Data.EliteHunterCount.Value) or 0
    if eliteCount < 30 then
        _G.Utils.Notify("Elite Hunter Count: " .. eliteCount .. "/30. Farmando...", 5)
        _G.Settings.AutoEliteHunter = true
        return
    else
        _G.Settings.AutoEliteHunter = false
        -- Posição da Yama na Hydra Island
        local yamaPos = CFrame.new(-5247, 5, 4488)
        _G.Utils.TweenTo(yamaPos)
        if (LocalPlayer.Character.HumanoidRootPart.Position - yamaPos.Position).Magnitude < 10 then
            _G.Utils.SafeRemote("PullYama")
        end
    end
end

-- 2. AUTO TUSHITA (INDRAL CHECK & TORCH PUZZLE)
function FarmingModule.AutoTushitaLogic()
    if not _G.Settings or not _G.Settings.AutoTushita then return end
    
    -- Verifica se Rip Indra está spawnado
    local indra = workspace.Enemies:FindFirstChild("Rip Indra")
    if not indra then
        _G.Utils.Notify("Aguardando Rip Indra para iniciar Tushita...", 10)
        return
    end

    -- Posição da porta da Tushita (Hydra Island Waterfall)
    local doorPos = CFrame.new(-5247, 5, 4488) 
    _G.Utils.TweenTo(doorPos)
    
    -- Lógica de tochas (Simplificada por CFrame)
    local torches = {
        CFrame.new(-12463, 332, -7548), -- Tocha 1
        CFrame.new(-13233, 532, -7594), -- Tocha 2
        CFrame.new(-11475, 831, 330),   -- Tocha 3
        CFrame.new(-10500, 330, -5760), -- Tocha 4
        CFrame.new(-9515, 164, -5785)   -- Tocha 5
    }
    
    for i, tPos in ipairs(torches) do
        _G.Utils.TweenTo(tPos)
        task.wait(1) -- Tempo para acender
    end
end

-- 3. AUTO CDK (CURSED DUAL KATANA QUESTLINE)
function FarmingModule.AutoCDKLogic()
    if not _G.Settings or not _G.Settings.AutoCDK then return end
    
    if not _G.Utils.HasItem("Tushita") or not _G.Utils.HasItem("Yama") then
        _G.Utils.Notify("Necessário Yama e Tushita (350+ Mastery)!", 5)
        return
    end

    -- Inicia as missões de CDK no NPC
    local cryptPos = CFrame.new(-11475, 831, 330)
    _G.Utils.TweenTo(cryptPos)
    
    -- Yama Quests (Pain, Haze, etc.)
    -- Tushita Quests (Dock, Fog, etc.)
    -- Aqui entra a lógica de verificação de cada pergaminho
    _G.Utils.SafeRemote("CDKQuest", "Start")
end

-- 4. AUTO SHARK ANCHOR (MONSTER MAGNET & BOSS FARM)
function FarmingModule.AutoSharkAnchorLogic()
    if not _G.Settings or not _G.Settings.AutoSharkAnchor then return end
    
    -- Verifica se tem o Monster Magnet no inventário
    if not _G.Utils.HasItem("Monster Magnet") then
        _G.Utils.Notify("Crafting Monster Magnet...", 5)
        _G.Utils.SafeRemote("SharkAnchorCraft", "MonsterMagnet")
        return
    end

    -- Caça o Terror Shark especial (Anchor Boss)
    local boss = workspace.Enemies:FindFirstChild("Terrorshark")
    if boss and boss:FindFirstChild("Anchor") then
        _G.Utils.Notify("🚨 ANCHOR BOSS DETECTADO!", 5)
        _G.Utils.TweenTo(boss.HumanoidRootPart.CFrame * CFrame.new(0, 40, 0))
        _G.Combat.StartCombatLoop()
    else
        _G.Utils.Notify("Navegando em busca do Anchor Boss...", 5)
        _G.Settings.AutoSeaEvent = true
    end
end

-- 5. AUTO SOUL GUITAR (FULL PUZZLE)
function FarmingModule.AutoSoulGuitarLogic()
    if not _G.Settings or not _G.Settings.AutoSoulGuitar then return end
    
    local moon = game:GetService("Lighting").Sky.FullMoonMagnitude
    if moon < 0.9 then
        _G.Utils.Notify("Aguardando Lua Cheia para Soul Guitar...", 10)
        return
    end

    local gravePos = CFrame.new(-9515, 164, -5785)
    _G.Utils.TweenTo(gravePos)
    
    -- Sequência de Puzzles (Placas, Zumbis, Troféus, Tubos)
    _G.Utils.SafeRemote("SoulGuitarQuest", "Pray")
    task.wait(1)
    _G.Utils.SafeRemote("SoulGuitarQuest", "CompletePuzzle")
end

-- 6. AUTO GODHUMAN (DETAILED MATERIAL FARM)
function FarmingModule.AutoGodhumanLogic()
    if not _G.Settings or not _G.Settings.AutoGodhuman then return end
    
    local mats = {
        {Name = "Fish Tail", Count = 20, Enemy = "Fishman Warrior"},
        {Name = "Magma Ore", Count = 20, Enemy = "Military Soldier"},
        {Name = "Dragon Scale", Count = 10, Enemy = "Dragon Crew Warrior"},
        {Name = "Mystic Droplet", Count = 10, Enemy = "Sea Soldier"}
    }

    for _, m in ipairs(mats) do
        if _G.Utils.GetMaterialCount(m.Name) < m.Count then
            _G.Utils.Notify("Farmando Material: " .. m.Name, 5)
            local enemy = _G.Utils.GetNearestEnemy(m.Enemy)
            if enemy then
                _G.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0))
                _G.Combat.StartCombatLoop()
            end
            return
        end
    end

    -- Compra Godhuman no NPC Ancient Monk
    _G.Utils.TweenTo(CFrame.new(-12463, 375, -7523))
    _G.Utils.SafeRemote("BuyFightingStyle", "Godhuman")
end

-- AUTO BOSS SYSTEM PRO
function FarmingModule.AutoBossPro()
    if not _G.Settings or not _G.Settings.AutoBoss then return end
    
    local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
    local bossToHunt = _G.Settings.SelectedBoss
    
    local targetBoss = nil
    if bossToHunt and bossToHunt ~= "All Bosses" then
        targetBoss = enemiesFolder:FindFirstChild(bossToHunt)
    else
        -- Procura qualquer boss vivo
        for _, v in ipairs(enemiesFolder:GetChildren()) do
            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                local name = v.Name:lower()
                if name:find("boss") or name:find("king") or name:find("admiral") then
                    targetBoss = v
                    break
                end
            end
        end
    end

    if targetBoss then
        _G.Utils.Notify("👾 Atacando Boss: " .. targetBoss.Name, 5)
        FarmingModule.EquipWeapon(_G.Settings.Weapon)
        _G.Utils.TweenTo(targetBoss.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0))
        _G.Combat.StartCombatLoop()
    elseif _G.Settings.AutoBossHop then
        _G.Utils.Notify("Nenhum Boss encontrado. Trocando servidor...", 5)
        _G.Utils.AdvancedHop()
    end
end

function FarmingModule.AutoStatsLogic()
    if not _G.Settings or not _G.Settings.AutoStats or not _G.Settings.SelectedStat then return end
    
    local points = LocalPlayer.Data:FindFirstChild("Points")
    if points and points.Value > 0 then
        _G.Utils.SafeRemote("AddPoint", _G.Settings.SelectedStat, points.Value)
    end
end

-- AUTO BERRY (MELHORADO)
function FarmingModule.AutoBerryFarm()
    if not _G.Settings or not _G.Settings.AutoBerry then return end
    
    -- Combina Chest Farm com quests rapidas se possivel
    _G.Utils.AutoChestLogic()
end

function FarmingModule.AutoNextSeaLogic()
    if not _G.Settings or not _G.Settings.AutoNextSea then return end
    local level = (LocalPlayer.Data and LocalPlayer.Data.Level.Value) or 0
    if FarmingModule.GetSea() == 1 and level >= 700 then
        _G.Utils.TweenTo(CFrame.new(-10332, 730, 7866))
        _G.Utils.SafeRemote("TravelMain")
    elseif FarmingModule.GetSea() == 2 and level >= 1500 then
        _G.Utils.TweenTo(CFrame.new(-541, 314, -2821))
        _G.Utils.SafeRemote("TravelZou")
    end
end

function FarmingModule.DungeonV2Logic()
    if not _G.Settings or not _G.Settings.AutoDungeonV2 then return end
    
    -- Lógica para o novo sistema de Dungeon do Update 29 (Lucien)
    local dungeonFolder = workspace:FindFirstChild("Dungeons") or workspace:FindFirstChild("DungeonV2")
    if dungeonFolder then
        local enemy = _G.Utils.GetNearestEnemyAny()
        if enemy then
            _G.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0))
            _G.Combat.StartFastAttack()
        end
        
        -- Auto Collect Trinkets
        if _G.Settings.AutoCollectTrinkets then
            for _, v in ipairs(dungeonFolder:GetChildren()) do
                if v.Name:find("Trinket") or v:FindFirstChild("Handle") then
                    _G.Utils.TweenTo(v:FindFirstChild("Handle").CFrame or v.CFrame)
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v:FindFirstChild("Handle") or v, 0)
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v:FindFirstChild("Handle") or v, 1)
                end
            end
        end
    else
        -- Se não estiver na dungeon, vai até o NPC Lucien
        if _G.Settings.AutoLucienQuest then
            local lucien = workspace.NPCs:FindFirstChild("Lucien")
            if lucien then
                _G.Utils.TweenTo(lucien.HumanoidRootPart.CFrame)
                _G.Utils.SafeRemote("LucienQuest", "StartDungeon")
            end
        end
    end
end

function FarmingModule.PvPArenaLogic()
    if not _G.Settings or not _G.Settings.AutoPvPArena then return end
    
    local arena = workspace:FindFirstChild("PvPArena")
    if arena then
        local opponent = _G.Utils.GetNearestEnemyAny() -- Na arena, o oponente é considerado inimigo
        if opponent then
            _G.Utils.TweenTo(opponent.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0))
            _G.Combat.StartFastAttack()
            _G.Combat.AimBotLogic(opponent.HumanoidRootPart)
        end
    end
end

function FarmingModule.SanguineArtLogic()
    if not _G.Settings.AutoSanguineArt then return end
    
    -- Verifica se tem o Leviathan Heart
    if not _G.Utils.HasItem("Leviathan Heart") then
        _G.Utils.Notify("Leviathan Heart necessário! Iniciando Sea Events...", 5)
        _G.Settings.AutoLeviathan = true
        return
    end

    -- Vai até o Shafi (NPC do Sanguine Art em Tiki Outpost)
    _G.Utils.TweenTo(CFrame.new(-15200, 400, -11500))
    _G.Utils.SafeRemote("SanguineArt", "Learn")
end

function FarmingModule.SeaEventsV2()
    if not _G.Settings.AutoSeaEventsV2 then return end
    
    local seaFolder = workspace:FindFirstChild("SeaEvents") or workspace:FindFirstChild("Sea")
    if not seaFolder then return end

    -- Piranhas / Sharks
    for _, v in ipairs(seaFolder:GetChildren()) do
        if (v.Name == "Piranha" or v.Name == "Shark") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            _G.Utils.TweenTo(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
            _G.Combat.StartFastAttack()
            return
        end
    end

    -- Ghost Ships
    local ship = seaFolder:FindFirstChild("Ghost Ship") or seaFolder:FindFirstChild("Ship")
    if ship and ship:FindFirstChild("Humanoid") then
        _G.Utils.TweenTo(ship:GetModelCFrame() * CFrame.new(0, 60, 0))
        _G.Combat.StartFastAttack()
    end
end

function FarmingModule.KitsuneEventLogic()
    if not _G.Settings.AutoKitsuneEvent then return end
    
    local kitsuneIsland = workspace:FindFirstChild("KitsuneIsland")
    if kitsuneIsland then
        _G.Utils.TweenTo(kitsuneIsland:GetModelCFrame())
        -- Lógica de coleta de Azure Flames
        for _, v in ipairs(workspace:GetChildren()) do
            if v.Name == "AzureFlame" or v.Name == "Azure Orb" then
                _G.Utils.TweenTo(v.CFrame)
                task.wait(0.1)
            end
        end
    else
        -- Se não tiver a ilha, vai para o mar profundo (Tiki Outpost area)
        _G.Utils.TweenTo(CFrame.new(-18000, 20, -15000))
    end
end

function FarmingModule.AutoAwakeningLogic()
    if not _G.Settings.AutoAwakening then return end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    -- Verifica se está na sala do Awakening (pós-raid)
    local awakeningNPC = workspace.NPCs:FindFirstChild("Awakening Scientist")
    if awakeningNPC then
        _G.Utils.TweenTo(awakeningNPC.HumanoidRootPart.CFrame)
        _G.Utils.SafeRemote("Awakening", "Check")
    end
end

-- AUTO ECTOPLASM (CURSED SHIP)
function FarmingModule.AutoEctoplasmLogic()
    if not _G.Settings or not _G.Settings.AutoEctoplasm then return end
    if FarmingModule.GetSea() ~= 2 then return end

    local enemy = _G.Utils.GetNearestEnemy("Ship Officer") or _G.Utils.GetNearestEnemy("Ship Engineer") or _G.Utils.GetNearestEnemy("Ship Steward") or _G.Utils.GetNearestEnemy("Ship Deckhand")
    if enemy then
        FarmingModule.EquipWeapon(_G.Settings.MainWeapon or "Melee")
        _G.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0))
        _G.Combat.StartFastAttack()
    else
        _G.Utils.TweenTo(CFrame.new(923, 125, 32850)) -- Entrada do Cursed Ship
    end
end

-- AUTO VAMPIRE FANG (GRAVEYARD)
function FarmingModule.AutoVampireFangLogic()
    if not _G.Settings or not _G.Settings.AutoVampireFang then return end
    
    local enemy = _G.Utils.GetNearestEnemy("Vampire")
    if enemy then
        FarmingModule.EquipWeapon(_G.Settings.MainWeapon or "Melee")
        _G.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0))
        _G.Combat.StartFastAttack()
    else
        _G.Utils.TweenTo(CFrame.new(-3112, 77, -2391)) -- Spawn dos Vampiros (Sea 2)
    end
end

-- AUTO DARK BLADE V2 QUEST
function FarmingModule.AutoDarkBladeV2()
    if not _G.Settings or not _G.Settings.AutoDarkBladeV2 then return end
    if not _G.Utils.HasItem("Dark Blade") then return end

    -- Lógica das 3 Cartas (Son, Robot, Dog)
    _G.Utils.Notify("Iniciando Quest Dark Blade V2...", 5)
    _G.Utils.TweenTo(CFrame.new(-1242, 16, -12140)) -- NPC Alchemist/Indra area
    _G.Utils.SafeRemote("DarkBladeV2", "Start")
end

-- AUTO CASTLE RAID (SEA 3)
function FarmingModule.AutoCastleRaid()
    if not _G.Settings or not _G.Settings.AutoCastleRaid then return end
    if FarmingModule.GetSea() ~= 3 then return end

    local enemies = workspace:FindFirstChild("Enemies") or workspace
    local raidInimigo = nil
    for _, v in ipairs(enemies:GetChildren()) do
        if v.Name:find("Pirate") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            raidInimigo = v
            break
        end
    end

    if raidInimigo then
        _G.Utils.Notify("🛡️ Defendendo o Castelo!", 5)
        _G.Utils.TweenTo(raidInimigo.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0))
        _G.Combat.StartFastAttack()
    end
end

-- AUTO FACTORY PRO (SEA 2)
function FarmingModule.AutoFactoryPro()
    if not _G.Settings or not _G.Settings.AutoFactory then return end
    if FarmingModule.GetSea() ~= 2 then return end

    local core = workspace:FindFirstChild("Core")
    if core and core:FindFirstChild("Humanoid") and core.Humanoid.Health > 0 then
        _G.Utils.Notify("🏭 Destruindo a Fábrica!", 5)
        _G.Utils.TweenTo(core.CFrame * CFrame.new(0, 20, 0))
        _G.Combat.StartFastAttack()
    end
end

function FarmingModule.AutoFarmBossesGlobal()
    if not _G.Settings.AutoFarmAllBosses then return end
    
    local enemies = workspace:FindFirstChild("Enemies") or workspace
    for _, v in ipairs(enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local name = v.Name:lower()
            if name:find("boss") or name:find("king") or name:find("admiral") or name:find("rip") then
                _G.Utils.TweenTo(v.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0))
                _G.Combat.StartFastAttack()
                return
            end
        end
    end
    
    if _G.Settings.AutoBossHop then _G.Utils.AdvancedHop() end
end
    -- Lógica para coletar Candy (Moeda de Evento)
    local candyFolder = workspace:FindFirstChild("Candy") or workspace:FindFirstChild("ChristmasEvent")
    if candyFolder then
        for _, v in ipairs(candyFolder:GetChildren()) do
            if v.Name:find("Candy") then
                _G.Utils.TweenTo(v.CFrame)
                task.wait(0.1)
            end
        end
    end
    
    if _G.Settings.AutoCandyGacha then
        _G.Utils.SafeRemote("CandyGacha", "Roll")
    end
end

function FarmingModule.LeviathanLogic()
    if not _G.Settings or not _G.Settings.AutoLeviathan then return end
    local SeaEvents = workspace:FindFirstChild("SeaEvents") or workspace:FindFirstChild("Sea")
    if not SeaEvents then return end
    local Leviathan = SeaEvents:FindFirstChild("Leviathan")
    if Leviathan then
        local head = Leviathan:FindFirstChild("Head") or Leviathan.PrimaryPart
        if head then
            _G.Utils.TweenTo(head.CFrame * CFrame.new(0, 50, 0))
            _G.Combat.StartFastAttack()
        end
    end
end

function FarmingModule.MirageSolver()
    if not _G.Settings or not _G.Settings.AutoMirage then return end
    
    local mirage = workspace:FindFirstChild("Mirage Island") or workspace:FindFirstChild("MirageIsland")
    if mirage then
        -- 1. Engrenagem (Busca Otimizada: BlueGear costuma estar no Workspace ou na Ilha)
        if _G.Settings.AutoFindGear then
            local gear = workspace:FindFirstChild("BlueGear") or mirage:FindFirstChild("BlueGear")
            if gear then
                _G.Utils.Notify("⚙️ Engrenagem Encontrada!", 5)
                _G.Utils.TweenTo(gear.CFrame)
                return
            end
        end
        
        -- 2. Alavanca (Lever)
        if _G.Settings.AutoMirageLever then
            local lever = workspace:FindFirstChild("Lever") or mirage:FindFirstChild("Lever")
            if lever then
                _G.Utils.TweenTo(lever.CFrame)
                return
            end
        end

        -- 3. Baús (Usa busca de proximidade em vez de GetDescendants em loop)
        if _G.Settings.AutoMirageChests then
            for _, v in ipairs(workspace:GetChildren()) do
                if v.Name:find("Chest") and v:IsA("BasePart") then
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - v.Position).Magnitude
                    if dist < 1000 then -- Só foca em baús da ilha
                        _G.Utils.TweenTo(v.CFrame)
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v, 0)
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v, 1)
                        task.wait(0.1)
                        return
                    end
                end
            end
        end

        -- 4. Vendedor (Advanced Dealer)
        if _G.Settings.AutoMirageDealer then
            local dealer = mirage:FindFirstChild("Advanced Fruit Dealer")
            if dealer then
                _G.Utils.TweenTo(dealer:GetModelCFrame())
                return
            end
        end

        -- Safe Spot se nada estiver ativo
        _G.Utils.TweenTo(mirage:GetModelCFrame() * CFrame.new(0, 200, 0))
    end
end

-- AUTO CYBORG (CORE BRAIN)
function FarmingModule.AutoCyborgLogic()
    if not _G.Settings or not _G.Settings.AutoCyborg then return end
    
    if not _G.Utils.HasItem("Core Brain") then
        _G.Utils.Notify("Farmando Core Brain (Law Boss)...", 5)
        _G.Settings.AutoLaw = true
        return
    end

    -- Se tem o Core Brain, vai para a sala secreta
    local cyborgRoom = CFrame.new(-6430, 250, -4500)
    _G.Utils.TweenTo(cyborgRoom)
    _G.Utils.SafeRemote("CyborgQuest", "Buy")
end

-- AUTO RANDOM BONE (DEATH KING)
function FarmingModule.AutoRandomBoneLogic()
    if not _G.Settings or not _G.Settings.AutoRandomBone then return end
    
    local deathKing = workspace.NPCs:FindFirstChild("Death King")
    if deathKing then
        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - deathKing:GetModelCFrame().Position).Magnitude
        if dist > 15 then
            _G.Utils.TweenTo(deathKing:GetModelCFrame())
        else
            _G.Utils.SafeRemote("DeathKing", "Random")
        end
    end
end

-- AUTO RACE V2 (FLOWER QUEST)
function FarmingModule.AutoRaceV2Logic()
    if not _G.Settings or not _G.Settings.AutoRaceV2 then return end
    if _G.MakitoSea ~= 2 then return end -- Só funciona no Sea 2
    
    local quest = LocalPlayer.PlayerGui.Main.Quest
    local questTitle = quest.Visible and quest.Container.QuestTitle.Text or ""
    
    if not questTitle:find("Alchemist") then
        _G.Utils.TweenTo(CFrame.new(-1242, 16, -12140))
        _G.Utils.SafeRemote("Alchemist", "StartQuest")
        return
    end

    -- Busca Flores (Busca por nome exato e proximidade)
    local flowerNames = {"Flower1", "Flower2", "Flower3"}
    for _, name in ipairs(flowerNames) do
        if not _G.Utils.HasItem(name) then
            -- Tenta achar no Workspace
            for _, v in ipairs(workspace:GetChildren()) do
                if v.Name == name or (v:IsA("BasePart") and v.Name:find("Flower") and v.Name:find(name:sub(-1))) then
                    _G.Utils.TweenTo(v.CFrame)
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v, 0)
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v, 1)
                    return
                end
            end
        end
    end
    
    -- Se tem as 3, entrega
    if _G.Utils.HasItem("Flower1") and _G.Utils.HasItem("Flower2") and _G.Utils.HasItem("Flower3") then
        _G.Utils.TweenTo(CFrame.new(-1242, 16, -12140))
        _G.Utils.SafeRemote("Alchemist", "CompleteQuest")
    end
end

-- AUTO RACE V3 (AROWE QUEST)
function FarmingModule.AutoRaceV3Logic()
    if not _G.Settings or not _G.Settings.AutoRaceV3 then return end
    if _G.MakitoSea ~= 2 then return end
    
    local race = LocalPlayer.Data.Race.Value
    _G.Utils.TweenTo(CFrame.new(-2840, 10, 5318))
    
    -- Lógica específica por raça
    if race == "Mink" then
        -- Coletar 30 baús
        if _G.Utils.GetMaterialCount("ChestsCollected") < 30 then
            _G.Farming.ChestFarmLogic()
            return
        end
    elseif race == "Human" then
        -- Matar 3 bosses (Diamond, Jeremy, Fajita)
        local bosses = {"Diamond", "Jeremy", "Fajita"}
        for _, b in ipairs(bosses) do
            local enemy = _G.Utils.GetNearestEnemy(b)
            if enemy then
                _G.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))
                _G.Combat.StartFastAttack()
                return
            end
        end
    end
    
    _G.Utils.SafeRemote("Arowe", "StartQuest")
    _G.Utils.SafeRemote("Arowe", "CompleteQuest")
end

-- AUTO DOUGH KING & CAKE PRINCE (REFINADO)
function FarmingModule.AutoDoughKing()
    if not _G.Settings or (not _G.Settings.AutoDoughKing and not _G.Settings.AutoCakePrince) then return end
    
    local status = _G.Utils.UpdateGlobalStatus()
    local cakeMsg = status.CakePrince
    local mobsLeft = tonumber(cakeMsg:match("%d+")) or 0
    
    -- LÓGICA DE CÁLICE DOCE (SWEET CHALICE)
    if _G.Settings.AutoDoughKing and not _G.Utils.HasItem("Sweet Chalice") then
        if _G.Utils.HasItem("God's Chalice") then
            local cocoaCount = _G.Utils.GetMaterialCount("Conjured Cocoa")
            if cocoaCount >= 10 then
                _G.Utils.Notify("🍭 Indo craftar Cálice Doce (Sweet Crafter)...", 5)
                local sweetCrafterPos = CFrame.new(-1210, 16, -12160)
                _G.Utils.TweenTo(sweetCrafterPos)
                if (LocalPlayer.Character.HumanoidRootPart.Position - sweetCrafterPos.Position).Magnitude < 15 then
                    _G.Utils.SafeRemote("ChocolateCraft", "SweetChalice")
                end
                return
            else
                _G.Utils.Notify("🍫 Farmando Conjured Cocoa (" .. cocoaCount .. "/10)...", 5)
                local enemy = _G.Utils.GetNearestEnemy("Cocoa Warrior")
                if enemy then
                    _G.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0))
                    _G.Combat.StartFastAttack()
                else
                    _G.Utils.TweenTo(CFrame.new(-1147, 14, -11514))
                end
                return
            end
        end
    end

    local bossName = _G.Settings.AutoDoughKing and "Dough King" or "Cake Prince"
    local enemies = workspace:FindFirstChild("Enemies") or workspace
    local boss = enemies:FindFirstChild(bossName)
    
    if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
        _G.Utils.Notify("🚨 ATACANDO " .. bossName:upper() .. "!", 5)
        _G.Utils.TweenTo(boss.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))
        _G.Combat.StartFastAttack()
    elseif mobsLeft > 0 then
        local enemy = _G.Utils.GetNearestEnemy("Cake Guard") or _G.Utils.GetNearestEnemy("Baking Staff") or _G.Utils.GetNearestEnemy("Cookie Crafter")
        if enemy then
            _G.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0))
            _G.Combat.StartFastAttack()
        else
            _G.Utils.TweenTo(CFrame.new(-1147, 14, -11514))
        end
    else
        if _G.Settings.AutoDoughKing then
            _G.Utils.SafeRemote("CakePrince", "Summon")
        end
    end
end

-- AUTO HALLOW SCYTHE (FOICE)
function FarmingModule.AutoHallowScythe()
    if not _G.Settings or not _G.Settings.AutoHallowScythe then return end
    
    local enemies = workspace:FindFirstChild("Enemies") or workspace
    local boss = enemies:FindFirstChild("Soul Reaper")
    
    if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
        _G.Utils.Notify("🚨 SOUL REAPER DETECTADO!", 5)
        _G.Utils.TweenTo(boss.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))
        _G.Combat.StartFastAttack()
    else
        local time = game:GetService("Lighting").ClockTime
        if time >= 18 or time <= 5 then
            local npc = workspace.NPCs:FindFirstChild("Death King") or workspace.NPCs:FindFirstChild("Grave")
            if npc then
                _G.Utils.TweenTo(npc:GetModelCFrame())
                _G.Utils.SafeRemote("Revenant", "Pray")
            end
        end
        FarmingModule.AutoBoneLogic()
    end
end

-- AUTO RENGOKU
function FarmingModule.AutoRengoku()
    if not _G.Settings or not _G.Settings.AutoRengoku then return end
    
    local enemies = workspace:FindFirstChild("Enemies") or workspace
    local boss = enemies:FindFirstChild("Awakened Ice Admiral")
    
    if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
        _G.Utils.Notify("🚨 ATACANDO AWAKENED ICE ADMIRAL!", 5)
        _G.Utils.TweenTo(boss.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))
        _G.Combat.StartFastAttack()
    else
        -- Farm de chaves nos mobs se o boss não estiver vivo
        local enemy = _G.Utils.GetNearestEnemy("Arctic Warrior") or _G.Utils.GetNearestEnemy("Snow Lurker")
        if enemy then
            _G.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0))
            _G.Combat.StartFastAttack()
        else
            _G.Utils.TweenTo(CFrame.new(6061, 26, -6370))
        end
    end
end

-- AUTO INDIVIDUAL FIGHTING STYLES (V1 & V2)
function FarmingModule.AutoFightingStylesLogic()
    if not _G.Settings then return end
    
    local styles = {
        {Set = "AutoBlackLeg", Name = "Black Leg", Pos = CFrame.new(-1140, 4, 3827)},
        {Set = "AutoElectro", Name = "Electro", Pos = CFrame.new(-4842, 718, -2621)},
        {Set = "AutoFishmanKarate", Name = "Fishman Karate", Pos = CFrame.new(61122, 18, 1565)},
        {Set = "AutoDragonBreath", Name = "Dragon Breath", Pos = CFrame.new(-425, 72, 1836)},
        {Set = "AutoSuperhuman", Name = "Superhuman", Pos = CFrame.new(-2367, 72, -3054)},
        {Set = "AutoDeathStep", Name = "Death Step", Pos = CFrame.new(6061, 26, -6370)},
        {Set = "AutoSharkmanKarate", Name = "Sharkman Karate", Pos = CFrame.new(-3056, 235, -10142)},
        {Set = "AutoElectricClaw", Name = "Electric Claw", Pos = CFrame.new(-13233, 532, -7594)},
        {Set = "AutoDragonTalon", Name = "Dragon Talon", Pos = CFrame.new(-9515, 164, -5785)},
        {Set = "AutoGodhumanIndividual", Name = "Godhuman", Pos = CFrame.new(-12463, 375, -7523)}
    }

    for _, style in ipairs(styles) do
        if _G.Settings[style.Set] then
            -- Bypass se já estiver equipado ou tiver o item
            if LocalPlayer.Backpack:FindFirstChild(style.Name) or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(style.Name)) then
                continue
            end
            
            _G.Utils.Notify("Adquirindo Estilo: " .. style.Name, 5)
            _G.Utils.TweenTo(style.Pos)
            _G.Utils.SafeRemote("BuyFightingStyle", style.Name)
        end
    end
end

-- RAID REFINEMENT (ULTRA EFFICIENCY)
function FarmingModule.RaidLogicRefined()
    if not _G.Settings or not _G.Settings.AutoRaid then return end
    
    local raidStatus = LocalPlayer.PlayerGui.Main:FindFirstChild("RaidStatus")
    if raidStatus and raidStatus.Visible then
        local enemy = _G.Utils.GetNearestEnemyAny()
        if enemy then
            -- POSITIONING V4 (SAFE & FAST)
            local offset = _G.Settings.RaidMode == "Above" and 50 or -50
            local targetCF = enemy.HumanoidRootPart.CFrame * CFrame.new(0, offset, 0)
            
            -- No-Clip e Float são essenciais aqui
            _G.Utils.SetNoClip(true)
            _G.Utils.Float(true)

            if (LocalPlayer.Character.HumanoidRootPart.Position - targetCF.Position).Magnitude > 5 then
                LocalPlayer.Character.HumanoidRootPart.CFrame = targetCF
            end
            
            _G.Combat.StartFastAttack()
            
            -- Agrupa mobs se estiver em "Below" para acelerar o kill
            if _G.Settings.RaidMode == "Below" then
                FarmingModule.BlackHoleBringMobs(enemy)
            end
        else
            -- Próxima Ilha
            if _G.Settings.AutoNextIsland then
                local islandLabel = raidStatus:FindFirstChild("Island")
                local islandNum = islandLabel and tonumber(islandLabel.Text) or 1
                local nextIsland = workspace:FindFirstChild("Island" .. islandNum)
                if nextIsland then
                    _G.Utils.TweenTo(nextIsland.CFrame * CFrame.new(0, 100, 0))
                end
            end
        end
    else
        -- Buy Chip & Start Logic
        if _G.Settings.AutoBuyChip then
            _G.Utils.SafeRemote("Raids", "BuyChip", _G.Settings.SelectedRaid)
        end
        if _G.Settings.AutoStartRaid then
            _G.Utils.SafeRemote("Raids", "StartRaid")
        end
    end
end

-- END-GAME AUTOMATION (GODHUMAN, CDK, SOUL GUITAR)
function FarmingModule.EndGameLogic()
    if not _G.Settings then return end

    if _G.Settings.AutoGodhuman then
        local materials = {
            {Name = "Fish Tail", Count = 20, Enemy = "Fishman Warrior"},
            {Name = "Magma Ore", Count = 20, Enemy = "Military Soldier"},
            {Name = "Dragon Scale", Count = 10, Enemy = "Dragon Crew Warrior"},
            {Name = "Mystic Droplet", Count = 10, Enemy = "Sea Soldier"}
        }
        for _, mat in ipairs(materials) do
            if _G.Utils.GetMaterialCount(mat.Name) < mat.Count then
                _G.Settings.AutoFarmMaterial = true
                _G.Settings.SelectedMaterial = mat.Name
                return
            end
        end
        _G.Utils.TweenTo(CFrame.new(-12463, 375, -7523))
        _G.Utils.SafeRemote("BuyFightingStyle", "Godhuman")
    end

    if _G.Settings.AutoCDK then
        if not _G.Utils.HasItem("Tushita") or not _G.Utils.HasItem("Yama") then
            _G.Utils.Notify("Você precisa da Tushita e Yama maestria 350+!", 10)
            return
        end
        _G.Utils.TweenTo(CFrame.new(-11475, 831, 330))
        _G.Utils.SafeRemote("CDKQuest", "Start")
    end

    if _G.Settings.AutoSoulGuitar then
        local moon = game:GetService("Lighting").Sky.FullMoonMagnitude
        if moon > 0.9 then
            _G.Utils.TweenTo(CFrame.new(-9515, 164, -5785))
            _G.Utils.SafeRemote("SoulGuitarQuest", "Pray")
        end
    end

    -- Auto Observation V2 (Hungry Man Quest)
    if _G.Settings.AutoObservationV2 then
        pcall(function()
            local quest = LocalPlayer.PlayerGui.Main.Quest
            if not quest.Visible or not quest.Container.QuestTitle.Text:find("Hungry Man") then
                _G.Utils.TweenTo(CFrame.new(-12463, 332, -7548))
                _G.Utils.SafeRemote("HungryMan", "StartQuest")
            end
            
            local fruits = {"Apple", "Banana", "Pineapple"}
            for _, fruitName in ipairs(fruits) do
                if not _G.Utils.HasItem(fruitName) then
                    local fruitObj = workspace:FindFirstChild(fruitName)
                    if fruitObj then
                        _G.Utils.TweenTo(fruitObj.CFrame)
                    end
                    return
                end
            end
            -- Se tem todas as frutas, entrega pro Hungry Man
            _G.Utils.TweenTo(CFrame.new(-12463, 332, -7548))
            _G.Utils.SafeRemote("HungryMan", "BuyKenV2")
        end)
    end
end

-- SHOP LOGIC REFINADA
function FarmingModule.ShopLogic()
    if not _G.Settings then return end
    
    if _G.Settings.AutoBuyAbilities then
        local abilities = {"Buso", "Geppo", "Soru"}
        for _, ability in ipairs(abilities) do
            _G.Utils.SafeRemote("BuyAbility", ability)
        end
    end

    if _G.Settings.AutoBuyFightingStyle then
        local styles = {"Black Leg", "Electro", "Fishman Karate", "Dragon Breath", "Superhuman", "Death Step", "Sharkman Karate", "Electric Claw", "Dragon Talon", "Godhuman"}
        for _, style in ipairs(styles) do _G.Utils.SafeRemote("BuyFightingStyle", style) end
    end
    if _G.Settings.AutoBuyLegendarySword then
        local swords = {"Shisui", "Wando", "Sadi", "True Triple Katana"}
        for _, sword in ipairs(swords) do _G.Utils.SafeRemote("LegendarySwordDealer", sword) end
    end
    if _G.Settings.AutoBuyAccessory then
        local accessories = {"Black Cape", "Swordsman Hat", "Pink Coat", "Tomoe Rings"}
        for _, acc in ipairs(accessories) do _G.Utils.SafeRemote("BuyAccessory", acc) end
    end
    if _G.Settings.AutoGacha then _G.Utils.SafeRemote("FruitGacha") end
end

return FarmingModule
