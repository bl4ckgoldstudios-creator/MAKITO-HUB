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
        -- Verifica se já enviamos o comando de StartQuest recentemente (cache de 2 segundos)
        if _G.LastQuestTime and tick() - _G.LastQuestTime < 2 then
            return BestQuest, false
        end

        local npcPos = BestQuest.Pos
        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - npcPos.Position).Magnitude
        
        if dist > 15 then
            _G.IsTalkingToNPC = true -- Trava o farm enquanto vai ao NPC
            if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Indo ate NPC " .. BestQuest.NPC end
            _G.Utils.TweenTo(npcPos)
        else
            _G.IsTalkingToNPC = true
            if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Aceitando Missao " .. BestQuest.Enemy end
            _G.Utils.SafeRemote("StartQuest", BestQuest.Name, BestQuest.ID)
            _G.LastQuestTime = tick() -- Marca o tempo que pegou a missão
            task.wait(0.5)
            -- Não removemos o IsTalkingToNPC aqui, deixamos o próximo ciclo da UI confirmar
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
    if not _G.Settings or not _G.Settings.AutoMastery or not enemy or not enemy:FindFirstChild("Humanoid") then return end
    
    local healthPercent = (enemy.Humanoid.Health / enemy.Humanoid.MaxHealth) * 100
    local threshold = _G.Settings.MasteryHealth or 20
    
    if healthPercent <= threshold then
        FarmingModule.EquipWeapon(_G.Settings.MasteryWeapon)
        if _G.Settings.AutoSkill then
            local keys = {"Z", "X", "C", "V"}
            for _, key in ipairs(keys) do
                if _G.Settings["Skill" .. key] then
                    _G.Combat.UseSkill(key)
                end
            end
        end
    else
        FarmingModule.EquipWeapon(_G.Settings.Weapon)
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
        
        -- SÓ FARMA SE A MISSÃO ESTIVER REALMENTE ATIVA NA UI
        if not isQuestActive then 
            _G.Combat.StopFastAttack() -- Para de bater enquanto pega missão
            return 
        end

        local enemy = _G.Utils.GetNearestEnemy(Quest.Enemy)
        
        -- BOSS PRIORITY
        local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
        local boss = enemiesFolder:FindFirstChild(Quest.Enemy .. " [Boss]") or enemiesFolder:FindFirstChild(Quest.Enemy .. " [RAID BOSS]")
        if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
            enemy = boss
        end

        if enemy then
            if _G.Settings.AutoMastery or _G.Settings.AutoFarmMastery then
                FarmingModule.MasteryLogic(enemy)
            else
                FarmingModule.EquipWeapon(_G.Settings.Weapon)
            end
            
            if _G.Settings.BringMobs or _G.Settings.AutoFarmMaterials then
                FarmingModule.BlackHoleBringMobs(enemy)
            end
            
            -- POSITIONING V3 (FLOAT ABOVE)
            local offset = _G.Settings.Distance or 12
            local targetCF = enemy.HumanoidRootPart.CFrame * CFrame.new(0, offset, 0)
            
            -- Look at enemy to keep it in focus
            targetCF = CFrame.new(targetCF.Position, enemy.HumanoidRootPart.Position)
            
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - targetCF.Position).Magnitude
            
            -- Garantir Float e NoClip ativos durante o farm
            _G.Utils.Float(true)
            _G.Utils.SetNoClip(true)

            if dist > 2 then
                if dist > 150 or _G.Settings.InfiniteSpeed then
                    _G.Utils.TweenTo(targetCF)
                else
                    LocalPlayer.Character.HumanoidRootPart.CFrame = targetCF
                end
            end
            
            -- ATTACK ACTIVATION
            _G.Combat.StartFastAttack()
            
            -- AUTO SKILL (IF ENABLED)
            if _G.Settings.AutoSkill and not _G.Settings.AutoMastery and not _G.Settings.AutoFarmMastery then
                local keys = {"Z", "X", "C", "V"}
                for _, key in ipairs(keys) do
                    if _G.Settings["Skill" .. key] then
                        _G.Combat.UseSkill(key)
                    end
                end
            end
        else
            -- WAIT FOR SPAWN
            local waitPos = Quest.Spawn or Quest.Pos
            _G.Utils.TweenTo(waitPos * CFrame.new(0, 40, 0))
            if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Aguardando Spawn de " .. Quest.Enemy end
        end
    end)
end

function FarmingModule.ProgressionLogic()
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
end

function FarmingModule.EventAutomationLogic()
    if not _G.Settings then return end

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

function FarmingModule.AutoSoulGuitarLogic()
    if not _G.Settings or not _G.Settings.AutoSoulGuitar then return end
    local sea = FarmingModule.GetSea()
    if sea ~= 3 then return end
    if game:GetService("Lighting").Sky.FullMoonMagnitude > 0.9 then
        local gravePos = CFrame.new(-9515, 164, -5785)
        _G.Utils.TweenTo(gravePos)
        if (LocalPlayer.Character.HumanoidRootPart.Position - gravePos.Position).Magnitude < 10 then
            _G.Utils.SafeRemote("SoulGuitar", "Pray")
        end
    end
    local bones = (LocalPlayer.Data:FindFirstChild("Bones") and LocalPlayer.Data.Bones.Value) or 0
    if bones < 500 then
        local enemy = _G.Utils.GetNearestEnemy("Reborn Skeleton") or _G.Utils.GetNearestEnemy("Living Zombie")
        if enemy then
            FarmingModule.EquipWeapon(_G.Settings.Weapon)
            _G.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0))
            _G.Combat.StartFastAttack()
        end
    end
end

function FarmingModule.AutoCDKLogic()
    if not _G.Settings or not _G.Settings.AutoCDK then return end
    _G.Utils.TweenTo(CFrame.new(-11475, 831, 330))
    _G.Utils.SafeRemote("CDKQuest")
end

function FarmingModule.AutoGodhumanLogic()
    if not _G.Settings or not _G.Settings.AutoGodhuman then return end
    _G.Utils.TweenTo(CFrame.new(-12463, 375, -7523))
    _G.Utils.SafeRemote("BuyFightingStyle", "Godhuman")
end

function FarmingModule.AutoStatsLogic()
    if not _G.Settings or not _G.Settings.AutoStats or not _G.Settings.SelectedStat then return end
    
    local stats = LocalPlayer.Data:FindFirstChild("Points")
    if stats and stats.Value > 0 then
        _G.Utils.SafeRemote("AddPoint", _G.Settings.SelectedStat, stats.Value)
    end
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

function FarmingModule.ChristmasEventLogic()
    if not _G.Settings or not _G.Settings.AutoCollectCandy then return end
    
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
    local mirage = workspace:FindFirstChild("MirageIsland")
    if mirage then
        if _G.Settings.AutoFindGear then
            local gear = mirage:FindFirstChild("BlueGear") or workspace:FindFirstChild("BlueGear")
            if gear then
                _G.Utils.TweenTo(gear.CFrame)
                return
            end
        end
        
        if _G.Settings.AutoMirageLever then
            local lever = mirage:FindFirstChild("Lever") or workspace:FindFirstChild("Lever")
            if lever then
                _G.Utils.TweenTo(lever.CFrame)
                return
            end
        end

        _G.Utils.TweenTo(mirage:GetModelCFrame() * CFrame.new(0, 100, 0))
    end
end

return FarmingModule
