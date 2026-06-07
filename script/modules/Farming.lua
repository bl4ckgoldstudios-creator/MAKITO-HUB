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

-- SUPREME QUEST HANDLER V2 (ULTRA FAST)
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
    local questName = ""
    pcall(function()
        local mainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
        local questGui = mainGui and (mainGui:FindFirstChild("Quest") or mainGui:FindFirstChild("QuestGui"))
        
        if questGui and questGui.Visible then
            local title = questGui:FindFirstChild("Title", true) or questGui:FindFirstChild("QuestTitle", true)
            if title and title:IsA("TextLabel") and title.Text ~= "" and title.Text ~= "Missão" then
                hasQuest = true
                questName = title.Text
            end
        end
    end)

    if hasQuest and not questName:find(BestQuest.Enemy) then
        _G.Utils.SafeRemote("AbandonQuest")
        hasQuest = false
    end

    if not hasQuest and _G.Settings and _G.Settings.AutoQuest then
        local npcPos = BestQuest.Pos
        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - npcPos.Position).Magnitude
        
        if dist > 15 then
            if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Indo ate NPC " .. BestQuest.NPC end
            _G.Utils.TweenTo(npcPos)
        else
            if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Aceitando Missao " .. BestQuest.Enemy end
            _G.Utils.SafeRemote("StartQuest", BestQuest.Name, BestQuest.ID)
        end
    end
    
    return BestQuest
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
            -- ULTRA BRING LOGIC
            v.HumanoidRootPart.CanCollide = false
            v.HumanoidRootPart.Size = Vector3.new(50, 50, 50) -- Big Hitbox
            v.HumanoidRootPart.CFrame = targetPos
            v.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
            
            if v.Humanoid.PlatformStand ~= true then
                v.Humanoid.PlatformStand = true
            end
            
            -- Anti-Despawn Bypass
            pcall(function()
                if v:FindFirstChild("Data") and v.Data:FindFirstChild("SpawnPos") then
                    v.Data.SpawnPos.Value = targetPos.Position
                end
            end)
        end
    end
end

function FarmingModule.SupremeAutoFarm()
    if not _G.Settings or not _G.Settings.AutoFarm then return end
    
    -- AUTO NEXT SEA INTEGRATION
    if _G.Settings.AutoNextSea then
        local level = (LocalPlayer.Data and LocalPlayer.Data.Level.Value) or 0
        if (FarmingModule.GetSea() == 1 and level >= 700) or (FarmingModule.GetSea() == 2 and level >= 1500) then
            FarmingModule.AutoNextSeaLogic()
            return
        end
    end

    pcall(function()
        local Quest = FarmingModule.SupremeQuestHandler(_G.Data.QuestData)
        if not Quest then return end

        local enemy = _G.Utils.GetNearestEnemy(Quest.Enemy)
        
        -- BOSS PRIORITY
        local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
        local boss = enemiesFolder:FindFirstChild(Quest.Enemy .. " [Boss]") or enemiesFolder:FindFirstChild(Quest.Enemy .. " [RAID BOSS]")
        if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
            enemy = boss
        end

        if enemy then
            if _G.Settings.AutoMastery then
                FarmingModule.MasteryLogic(enemy)
            else
                FarmingModule.EquipWeapon(_G.Settings.Weapon)
            end
            
            FarmingModule.BlackHoleBringMobs(enemy)
            
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
            if _G.Settings.AutoSkill and not _G.Settings.AutoMastery then
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

function FarmingModule.SeaEventLogic()
    if not _G.Settings then return end
    
    local SeaEvents = workspace:FindFirstChild("SeaEvents") or workspace:FindFirstChild("Sea")
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
    _G.Utils.SafeRemote("AddPoint", _G.Settings.SelectedStat, 1)
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
        _G.Utils.TweenTo(mirage:GetModelCFrame())
    end
end

return FarmingModule
