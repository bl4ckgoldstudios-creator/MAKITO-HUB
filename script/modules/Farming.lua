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
    
    pcall(function()
        local mainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
        local questGui = mainGui and mainGui:FindFirstChild("Quest")
        
        if questGui and questGui.Visible then
            local container = questGui:FindFirstChild("Container")
            local title = container and container:FindFirstChild("QuestTitle")
            local titleText = title and title.Text or ""
            
            if titleText ~= "" then
                if titleText:lower():find(BestQuest.Enemy:lower()) or titleText:lower():find(BestQuest.Name:lower()) then
                    hasQuest = true
                    _G.IsTalkingToNPC = false
                else
                    _G.IsTalkingToNPC = true
                    _G.Utils.SafeRemote("AbandonQuest")
                    task.wait(0.5)
                    _G.IsTalkingToNPC = false
                end
            end
        end
    end)

    if not hasQuest and _G.Settings and _G.Settings.AutoQuest then
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if not root then return BestQuest, false end
        if _G.LastQuestTime and tick() - _G.LastQuestTime < 2 then
            return BestQuest, false
        end

        local npcPos = BestQuest.Pos
        if not npcPos then return BestQuest, false end

        local dist = (root.Position - npcPos.Position).Magnitude
        
        if dist > 20 then
            _G.IsTalkingToNPC = true
            if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Indo ate NPC " .. (BestQuest.NPC or "Desconhecido") end
            _G.Utils.TweenTo(npcPos)
        else
            _G.IsTalkingToNPC = true
            if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Aceitando Missao " .. (BestQuest.Enemy or "Inimigo") end
            task.wait(0.2)
            _G.Utils.SafeRemote("StartQuest", BestQuest.Name, BestQuest.ID)
            _G.LastQuestTime = tick()
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
            v.HumanoidRootPart.CanCollide = false
            v.HumanoidRootPart.CFrame = targetPos
            v.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
            
            if v.Humanoid.PlatformStand ~= true then
                v.Humanoid.PlatformStand = true
            end
            
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

    if hum.Health / hum.MaxHealth < 0.2 then
        if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Recuperando Vida..." end
        _G.Combat.StopCombatLoop()
        root.CFrame = root.CFrame * CFrame.new(0, 100, 0)
        return
    end

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
        
        _G.Utils.SetNoClip(true)
        _G.Utils.Float(true)

        if not isQuestActive then 
            _G.Combat.StopCombatLoop()
            return 
        end

        local enemy = _G.Utils.GetNearestEnemy(Quest.Enemy)
        local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
        for _, v in ipairs(enemiesFolder:GetChildren()) do
            if v.Name:find(Quest.Enemy) and (v.Name:find("Boss") or v.Name:find("RAID")) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                enemy = v
                break
            end
        end

        if enemy and enemy:FindFirstChild("HumanoidRootPart") then
            local targetPos = enemy.HumanoidRootPart.CFrame * CFrame.new(0, _G.Settings.Distance or 12, 0)
            local dist = (root.Position - targetPos.Position).Magnitude
            if dist > 300 then
                _G.Utils.TweenTo(targetPos)
            else
                root.CFrame = targetPos
            end

            if _G.Settings.AutoMastery then
                FarmingModule.MasteryLogic(enemy)
            else
                FarmingModule.EquipWeapon(_G.Settings.MainWeapon or "Melee")
            end

            _G.Combat.StartCombatLoop()
            FarmingModule.BlackHoleBringMobs(enemy)
        else
            if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Aguardando Inimigos..." end
            local spawnPos = Quest.Spawn or Quest.Pos
            _G.Utils.TweenTo(spawnPos * CFrame.new(0, 50, 0))
        end
    end)
end

function FarmingModule.AutoNextSeaLogic()
    if not _G.Settings or not _G.Settings.AutoNextSea then return end
    local level = (LocalPlayer.Data and LocalPlayer.Data.Level.Value) or 0
    local sea = FarmingModule.GetSea()
    if sea == 1 and level >= 700 then
        _G.Utils.TweenTo(CFrame.new(4875, 5, 749))
        _G.Utils.SafeRemote("TravelMain")
    elseif sea == 2 and level >= 1500 then
        _G.Utils.TweenTo(CFrame.new(-1580, 7, -2980))
        _G.Utils.SafeRemote("TravelZou")
    end
end

-- SEA EVENTS & MIRAGE
function FarmingModule.SeaEventLogic()
    if not _G.Settings then return end
    
    if _G.Settings.AutoMirage then FarmingModule.MirageSolver() end

    local SeaEvents = workspace:FindFirstChild("SeaEvents") or workspace:FindFirstChild("Sea")
    if not SeaEvents then return end

    -- TERROR SHARK
    if _G.Settings.AutoTerrorShark then
        local ts = SeaEvents:FindFirstChild("Terrorshark") or SeaEvents:FindFirstChild("Terror Shark")
        if ts and ts:FindFirstChild("Humanoid") and ts.Humanoid.Health > 0 then
            _G.Utils.TweenTo(ts.HumanoidRootPart.CFrame * CFrame.new(0, 40, 0))
            _G.Combat.StartFastAttack()
            return
        end
    end

    -- LEVIATHAN
    if _G.Settings.AutoLeviathan then
        local levi = SeaEvents:FindFirstChild("Leviathan")
        if levi and levi:FindFirstChild("Head") then
            _G.Utils.TweenTo(levi.Head.CFrame * CFrame.new(0, 50, 0))
            _G.Combat.StartFastAttack()
            return
        end
    end

    -- SEA BEAST
    if _G.Settings.AutoSeaBeast then
        local sb = SeaEvents:FindFirstChild("Sea Beast") or SeaEvents:FindFirstChild("SeaBeast")
        if sb and sb:FindFirstChild("Humanoid") and sb.Humanoid.Health > 0 then
            _G.Utils.TweenTo(sb.HumanoidRootPart.CFrame * CFrame.new(0, 50, 0))
            _G.Combat.StartFastAttack()
            return
        end
    end
end

function FarmingModule.MirageSolver()
    if not _G.Settings or not _G.Settings.AutoMirage then return end
    local mirage = workspace:FindFirstChild("Mirage Island") or workspace:FindFirstChild("MirageIsland")
    if not mirage then return end

    if _G.Settings.AutoFindGear then
        local gear = workspace:FindFirstChild("BlueGear") or mirage:FindFirstChild("BlueGear")
        if gear then
            _G.Utils.Notify("⚙️ Engrenagem Encontrada!", 5)
            _G.Utils.TweenTo(gear.CFrame)
            return
        end
    end

    if _G.Settings.AutoMirageLever then
        local lever = workspace:FindFirstChild("Lever") or mirage:FindFirstChild("Lever")
        if lever then _G.Utils.TweenTo(lever.CFrame) return end
    end

    if _G.Settings.AutoMirageChests then
        for _, v in ipairs(workspace:GetChildren()) do
            if v.Name:find("Chest") and v:IsA("BasePart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - v.Position).Magnitude
                if dist < 1000 then
                    _G.Utils.TweenTo(v.CFrame)
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v, 0)
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v, 1)
                    return
                end
            end
        end
    end
end

-- ITEM & RESOURCE FARMING
function FarmingModule.AutoEctoplasmLogic()
    if not _G.Settings or not _G.Settings.AutoEctoplasm then return end
    if FarmingModule.GetSea() ~= 2 then return end

    local enemy = _G.Utils.GetNearestEnemy("Ship Officer") or _G.Utils.GetNearestEnemy("Ship Engineer")
    if enemy then
        FarmingModule.EquipWeapon(_G.Settings.MainWeapon or "Melee")
        _G.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0))
        _G.Combat.StartFastAttack()
    else
        _G.Utils.TweenTo(CFrame.new(923, 125, 32850))
    end
end

function FarmingModule.AutoVampireFangLogic()
    if not _G.Settings or not _G.Settings.AutoVampireFang then return end
    local enemy = _G.Utils.GetNearestEnemy("Vampire")
    if enemy then
        FarmingModule.EquipWeapon(_G.Settings.MainWeapon or "Melee")
        _G.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0))
        _G.Combat.StartFastAttack()
    else
        _G.Utils.TweenTo(CFrame.new(-3112, 77, -2391))
    end
end

function FarmingModule.AutoBoneLogic()
    if not _G.Settings or not _G.Settings.AutoBone then return end
    if FarmingModule.GetSea() ~= 3 then return end
    local enemy = _G.Utils.GetNearestEnemy("Reborn Skeleton") or _G.Utils.GetNearestEnemy("Living Zombie")
    if enemy then
        FarmingModule.EquipWeapon(_G.Settings.MainWeapon or "Melee")
        _G.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0))
        _G.Combat.StartFastAttack()
    else
        _G.Utils.TweenTo(CFrame.new(-9515, 164, -5785))
    end
end

-- BOSSES & SPECIAL EVENTS
function FarmingModule.AutoFarmBossesGlobal()
    if not _G.Settings or not _G.Settings.AutoFarmAllBosses then return end
    local enemies = workspace:FindFirstChild("Enemies") or workspace
    for _, v in ipairs(enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local name = v.Name:lower()
            if name:find("boss") or name:find("king") or name:find("admiral") then
                _G.Utils.TweenTo(v.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0))
                _G.Combat.StartFastAttack()
                return
            end
        end
    end
    if _G.Settings.AutoBossHop then _G.Utils.AdvancedHop() end
end

function FarmingModule.AutoFactoryPro()
    if not _G.Settings or not _G.Settings.AutoFactory then return end
    if FarmingModule.GetSea() ~= 2 then return end
    local core = workspace:FindFirstChild("Core")
    if core and core:FindFirstChild("Humanoid") and core.Humanoid.Health > 0 then
        _G.Utils.TweenTo(core.CFrame * CFrame.new(0, 20, 0))
        _G.Combat.StartFastAttack()
    end
end

function FarmingModule.AutoCastleRaid()
    if not _G.Settings or not _G.Settings.AutoCastleRaid then return end
    if FarmingModule.GetSea() ~= 3 then return end
    local enemies = workspace:FindFirstChild("Enemies") or workspace
    for _, v in ipairs(enemies:GetChildren()) do
        if v.Name:find("Pirate") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            _G.Utils.TweenTo(v.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0))
            _G.Combat.StartFastAttack()
            return
        end
    end
end

-- END-GAME QUESTS
function FarmingModule.AutoCDKLogic()
    if not _G.Settings or not _G.Settings.AutoCDK then return end
    if not _G.Utils.HasItem("Tushita") or not _G.Utils.HasItem("Yama") then return end
    _G.Utils.TweenTo(CFrame.new(-11475, 831, 330))
    _G.Utils.SafeRemote("CDKQuest", "Start")
end

function FarmingModule.AutoSoulGuitarLogic()
    if not _G.Settings or not _G.Settings.AutoSoulGuitar then return end
    local moon = game:GetService("Lighting").Sky.FullMoonMagnitude
    if moon > 0.9 then
        _G.Utils.TweenTo(CFrame.new(-9515, 164, -5785))
        _G.Utils.SafeRemote("SoulGuitarQuest", "Pray")
    end
end

function FarmingModule.AutoGodhumanLogic()
    if not _G.Settings or not _G.Settings.AutoGodhuman then return end
    _G.Utils.TweenTo(CFrame.new(-12463, 375, -7523))
    _G.Utils.SafeRemote("BuyFightingStyle", "Godhuman")
end

function FarmingModule.SanguineArtLogic()
    if not _G.Settings or not _G.Settings.AutoSanguineArt then return end
    if not _G.Utils.HasItem("Leviathan Heart") then return end
    _G.Utils.TweenTo(CFrame.new(-15200, 400, -11500))
    _G.Utils.SafeRemote("SanguineArt", "Learn")
end

-- RAIDS & DUNGEONS
function FarmingModule.RaidLogicRefined()
    if not _G.Settings or not _G.Settings.AutoRaid then return end
    local raidStatus = LocalPlayer.PlayerGui.Main:FindFirstChild("RaidStatus")
    if raidStatus and raidStatus.Visible then
        local enemy = _G.Utils.GetNearestEnemyAny()
        if enemy then
            local offset = _G.Settings.RaidMode == "Above" and 50 or -50
            LocalPlayer.Character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, offset, 0)
            _G.Combat.StartFastAttack()
        end
    else
        if _G.Settings.AutoBuyChip then _G.Utils.SafeRemote("Raids", "BuyChip", _G.Settings.SelectedRaid) end
        if _G.Settings.AutoStartRaid then _G.Utils.SafeRemote("Raids", "StartRaid") end
    end
end

-- UTILS & SHOP
function FarmingModule.ShopLogic()
    if not _G.Settings then return end
    if _G.Settings.AutoGacha then _G.Utils.SafeRemote("FruitGacha") end
    if _G.Settings.AutoBuyFightingStyle then
        local styles = {"Black Leg", "Electro", "Fishman Karate", "Dragon Breath", "Superhuman", "Death Step", "Sharkman Karate", "Electric Claw", "Dragon Talon", "Godhuman"}
        for _, style in ipairs(styles) do _G.Utils.SafeRemote("BuyFightingStyle", style) end
    end
end

function FarmingModule.AutoStatsLogic()
    if not _G.Settings or not _G.Settings.AutoStats then return end
    local points = LocalPlayer.Data:FindFirstChild("Points")
    if points and points.Value > 0 then
        _G.Utils.SafeRemote("AddPoint", _G.Settings.SelectedStat, points.Value)
    end
end

function FarmingModule.ChestFarmLogic()
    if not _G.Settings or not _G.Settings.AutoChest then return end
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Name:find("Chest") and v:IsA("BasePart") then
            _G.Utils.TweenTo(v.CFrame)
            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v, 0)
            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v, 1)
            break
        end
    end
end

return FarmingModule
