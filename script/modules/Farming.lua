--!strict
local FarmingModule = {}

-- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- INTERNAL STATE
local Makito = getgenv().Makito

-- 1. QUEST HANDLER
function FarmingModule.GetBestQuest(QuestData: any)
    local level = LocalPlayer.Data.Level.Value
    local sea = Makito.Sea
    local currentQuests = QuestData[sea]
    if not currentQuests then return nil end
    
    for i = #currentQuests, 1, -1 do
        local q = currentQuests[i]
        if level >= q.Min then return q end
    end
    return currentQuests[1]
end

function FarmingModule.SupremeQuestHandler(QuestData: any)
    local bestQuest = FarmingModule.GetBestQuest(QuestData)
    if not bestQuest then return nil, false end

    local hasQuest = false
    pcall(function()
        local questGui = LocalPlayer.PlayerGui.Main:FindFirstChild("Quest")
        if questGui and questGui.Visible then
            local title = questGui.Container.QuestTitle.Text
            if title:lower():find(bestQuest.Enemy:lower()) or title:lower():find(bestQuest.Name:lower()) then
                hasQuest = true
            else
                Makito.Utils.SafeRemote("AbandonQuest")
            end
        end
    end)

    if not hasQuest and Makito.Settings and Makito.Settings.AutoQuest then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return bestQuest, false end

        local npcPos = bestQuest.Pos
        local dist = (root.Position - npcPos.Position).Magnitude
        
        if dist > 20 then
            Makito.Utils.TweenTo(npcPos)
        else
            Makito.Utils.SafeRemote("StartQuest", bestQuest.Name, bestQuest.ID)
        end
    end
    
    return bestQuest, hasQuest
end

-- 2. GERENCIAMENTO DE ARMAS
function FarmingModule.EquipWeapon(weaponType: string)
    local char = LocalPlayer.Character
    if not char then return end

    local tool = char:FindFirstChildOfClass("Tool")
    if tool and tool.ToolTip:find(weaponType) then return end

    for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if v:IsA("Tool") and v.ToolTip:find(weaponType) then
            char.Humanoid:EquipTool(v)
            break
        end
    end
end

-- 3. FARM LOGIC
function FarmingModule.SupremeAutoFarm()
    if not Makito.Settings or not Makito.Settings.AutoFarm then return end
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not hum or hum.Health <= 0 then return end

    if hum.Health / hum.MaxHealth < 0.2 then
        Makito.Combat.StopCombatLoop()
        root.CFrame = root.CFrame * CFrame.new(0, 100, 0)
        return
    end

    local quest, isQuestActive = FarmingModule.SupremeQuestHandler(Makito.Data.QuestData)
    if not quest then return end

    if not isQuestActive then
        Makito.Combat.StopCombatLoop()
        return
    end

    local enemy = Makito.Utils.GetNearestEnemy(quest.Enemy)
    if enemy and enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") then
        local targetPos = enemy.HumanoidRootPart.CFrame * CFrame.new(0, Makito.Settings.Distance or 12, 0)
        
        if (root.Position - targetPos.Position).Magnitude > 300 then
            Makito.Utils.TweenTo(targetPos)
        else
            root.CFrame = targetPos
        end

        -- Lógica de Mastery
        if Makito.Settings.AutoMastery and enemy:FindFirstChild("Humanoid") then
            if enemy.Humanoid.Health / enemy.Humanoid.MaxHealth <= (Makito.Settings.MasteryHealth / 100) then
                FarmingModule.EquipWeapon(Makito.Settings.MasteryWeapon)
            else
                FarmingModule.EquipWeapon(Makito.Settings.MainWeapon or "Melee")
            end
        else
            FarmingModule.EquipWeapon(Makito.Settings.MainWeapon or "Melee")
        end

        Makito.Combat.StartCombatLoop()
        
        if Makito.Settings.BringMobs then
            FarmingModule.BlackHoleBringMobs(enemy)
        end
    else
        local spawnPos = quest.Spawn or quest.Pos
        Makito.Utils.TweenTo(spawnPos * CFrame.new(0, 50, 0))
    end
end

function FarmingModule.BlackHoleBringMobs(targetEnemy: Model)
    local targetPos = targetEnemy.HumanoidRootPart.CFrame
    local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
    
    for _, v in ipairs(enemiesFolder:GetChildren()) do
        if v.Name:find(targetEnemy.Name:split(" [")[1]) and v:FindFirstChild("HumanoidRootPart") then
            v.HumanoidRootPart.CanCollide = false
            v.HumanoidRootPart.CFrame = targetPos
            v.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        end
    end
end

-- 4. EVENTOS E ITENS
function FarmingModule.UpdateAutomation()
    if not Makito.Settings then return end
    
    pcall(function()
        if Makito.Settings.AutoFarm then FarmingModule.SupremeAutoFarm() end
        if Makito.Settings.AutoChest then FarmingModule.ChestFarmLogic() end
        if Makito.Settings.AutoDungeonMode then FarmingModule.DungeonModeLogic() end
        if Makito.Settings.AutoValentineEvent then FarmingModule.ValentineEventLogic() end
        if Makito.Settings.AutoFishing then FarmingModule.FishingLogic() end
        
        -- Bosses e Elite
        if Makito.Settings.AutoFarmAllBosses then FarmingModule.AutoFarmAllBosses() end
        if Makito.Settings.AutoEliteHunter then FarmingModule.AutoEliteHunter() end
        
        if Makito.Settings.AutoBoneFarm then FarmingModule.AutoBoneFarm() end
        if Makito.Settings.AutoFarmFactory then FarmingModule.FactoryFarmLogic() end
        if Makito.Settings.AutoFarmShipRaid then FarmingModule.ShipRaidLogic() end
        if Makito.Settings.AutoFarmMaterials then FarmingModule.AutoFarmMaterials() end
        if Makito.Settings.AutoBartiloQuest then FarmingModule.BartiloQuestLogic() end
        if Makito.Settings.AutoCitizenQuest then FarmingModule.CitizenQuestLogic() end
        if Makito.Settings.AutoBuyHakiColors then FarmingModule.AutoBuyHakiColors() end
        if Makito.Settings.AutoNextSea then FarmingModule.AutoNextSea() end
        
        -- Frutas
        if Makito.Settings.AutoCollectFruit then FarmingModule.AutoCollectFruit() end
        if Makito.Settings.AutoStoreFruit then FarmingModule.AutoStoreFruit() end
        if Makito.Settings.AutoGacha then FarmingModule.AutoGacha() end

        -- Sea Events
        if Makito.Settings.AutoSeaBeast or Makito.Settings.AutoTerrorShark or Makito.Settings.AutoLeviathan or Makito.Settings.AutoKitsuneEvent then
            FarmingModule.SeaEventLogic()
        end
        
        -- End-Game
        if Makito.Settings.AutoCDK then FarmingModule.AutoCDKLogic() end
        if Makito.Settings.AutoSoulGuitar then FarmingModule.AutoSoulGuitarLogic() end
        if Makito.Settings.AutoGodhuman then FarmingModule.AutoGodhumanLogic() end
        if Makito.Settings.AutoSanguineArt then FarmingModule.SanguineArtLogic() end
        
        -- Raid
        if Makito.Settings.AutoRaid then FarmingModule.RaidLogic() end
    end)
end

function FarmingModule.AutoFarmAllBosses()
    local enemies = workspace:FindFirstChild("Enemies") or workspace
    for _, v in ipairs(enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and (v.Name:find("Boss") or Makito.Data.IsBoss(v.Name)) then
            Makito.Utils.TweenTo(v.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0))
            FarmingModule.EquipWeapon(Makito.Settings.MainWeapon)
            Makito.Combat.StartCombatLoop()
            return
        end
    end
end

function FarmingModule.AutoEliteHunter()
    local elite = Makito.Utils.SafeRemote("EliteHunter", "GetTask")
    if elite and elite ~= "None" then
        local enemy = Makito.Utils.GetNearestEnemy(elite)
        if enemy then
            Makito.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0))
            Makito.Combat.StartCombatLoop()
        end
    end
end

function FarmingModule.AutoCollectFruit()
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Tool") and (v.Name:find("Fruit") or v:FindFirstChild("Handle")) then
            Makito.Utils.TweenTo(v.Handle.CFrame)
            return
        end
    end
end

function FarmingModule.AutoStoreFruit()
    for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if v:IsA("Tool") and v.Name:find("Fruit") then
            Makito.Utils.SafeRemote("StoreFruit", v.Name, v)
        end
    end
end

function FarmingModule.AutoGacha()
    if not _G.LastGacha or tick() - _G.LastGacha > 7200 then
        local res = Makito.Utils.SafeRemote("Cousin", "BuyFruit")
        if res then _G.LastGacha = tick() end
    end
end

function FarmingModule.RaidLogic()
    if not Makito.Settings.AutoRaid then return end
    
    -- Auto Buy Chip
    if Makito.Settings.AutoBuyChip then
        Makito.Utils.SafeRemote("Raids", "BuyChip", Makito.Settings.SelectedRaid)
    end
    
    -- Auto Start
    if Makito.Settings.AutoStartRaid then
        Makito.Utils.SafeRemote("Raids", "StartRaid")
    end
    
    -- Dungeon Logic inside Raid
    FarmingModule.DungeonModeLogic()
end

function FarmingModule.AutoBoneFarm()
    if Makito.Sea ~= 3 then return end
    local enemies = {"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy"}
    local nearest = nil
    local dist = math.huge
    
    for _, name in ipairs(enemies) do
        local enemy = Makito.Utils.GetNearestEnemy(name)
        if enemy then
            local d = (LocalPlayer.Character.HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
            if d < dist then
                dist = d
                nearest = enemy
            end
        end
    end

    if nearest then
        Makito.Utils.TweenTo(nearest.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0))
        FarmingModule.EquipWeapon(Makito.Settings.MainWeapon)
        Makito.Combat.StartCombatLoop()
    else
        Makito.Utils.TweenTo(CFrame.new(-9515, 164, -5785)) -- Haunted Castle
    end
end

function FarmingModule.FactoryFarmLogic()
    if Makito.Sea ~= 2 then return end
    local factory = workspace:FindFirstChild("Factory")
    if not factory then return end
    
    local core = factory:FindFirstChild("Core")
    if core and core:FindFirstChild("Humanoid") and core.Humanoid.Health > 0 then
        Makito.Utils.TweenTo(core.CFrame * CFrame.new(0, 20, 0))
        Makito.Combat.StartCombatLoop()
    end
end

function FarmingModule.ShipRaidLogic()
    if Makito.Sea ~= 2 then return end
    local seaEvents = workspace:FindFirstChild("SeaEvents")
    if not seaEvents then return end
    
    for _, v in ipairs(seaEvents:GetChildren()) do
        if v.Name:find("Ship") and v:FindFirstChild("HumanoidRootPart") then
            Makito.Utils.TweenTo(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
            Makito.Combat.StartCombatLoop()
            return
        end
    end
end

function FarmingModule.AutoFarmMaterials()
    local selected = Makito.Settings.SelectedMaterial
    local data = Makito.Data.MaterialData[selected]
    if not data then return end
    
    local enemy = Makito.Utils.GetNearestEnemy(data.Enemy)
    if enemy then
        Makito.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0))
        FarmingModule.EquipWeapon(Makito.Settings.MainWeapon)
        Makito.Combat.StartCombatLoop()
    else
        Makito.Utils.TweenTo(data.Pos)
    end
end

function FarmingModule.BartiloQuestLogic()
    if Makito.Sea ~= 2 then return end
    -- Step 1: Kill 50 Swan Pirates
    -- Step 2: Kill Jeremy
    -- Step 3: Free Gladiators (Code)
    local quest = Makito.Utils.SafeRemote("BartiloQuest", "GetStatus")
    if quest == "KillSwanPirates" then
        local enemy = Makito.Utils.GetNearestEnemy("Swan Pirate")
        if enemy then
            Makito.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0))
            Makito.Combat.StartCombatLoop()
        else
            Makito.Utils.TweenTo(CFrame.new(-650, 72, 2100))
        end
    elseif quest == "KillJeremy" then
        local jeremy = Makito.Utils.GetNearestEnemy("Jeremy")
        if jeremy then
            Makito.Utils.TweenTo(jeremy.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0))
            Makito.Combat.StartCombatLoop()
        else
            Makito.Utils.TweenTo(CFrame.new(-2367, 72, -3054))
        end
    elseif quest == "FreeGladiators" then
        -- This step is usually manual or requires specific CFrame clicks
        Makito.Utils.TweenTo(CFrame.new(-1850, 7, -2980)) -- Colosseum
    end
end

function FarmingModule.CitizenQuestLogic()
    if Makito.Sea ~= 3 then return end
    -- Kill 50 Forest Pirates and Captain Elephant
    local quest = Makito.Utils.SafeRemote("CitizenQuest", "GetStatus")
    if quest == "KillForestPirates" then
        local enemy = Makito.Utils.GetNearestEnemy("Forest Pirate")
        if enemy then
            Makito.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0))
            Makito.Combat.StartCombatLoop()
        else
            Makito.Utils.TweenTo(CFrame.new(-13233, 532, -7594))
        end
    elseif quest == "KillCaptainElephant" then
        local boss = Makito.Utils.GetNearestEnemy("Captain Elephant")
        if boss then
            Makito.Utils.TweenTo(boss.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0))
            Makito.Combat.StartCombatLoop()
        else
            Makito.Utils.TweenTo(CFrame.new(-13233, 532, -7594))
        end
    end
end

function FarmingModule.AutoBuyHakiColors()
    local npc = workspace:FindFirstChild("Master of Auras")
    if npc then
        Makito.Utils.TweenTo(npc.WorldPivot)
        Makito.Utils.SafeRemote("HakiColorDealer", "Buy")
    end
end

function FarmingModule.AutoNextSea()
    local level = LocalPlayer.Data.Level.Value
    if Makito.Sea == 1 and level >= 700 then
        -- Go to Sea 2 (Military Detective NPC)
        Makito.Utils.TweenTo(CFrame.new(-4807, 23, 4335))
        Makito.Utils.SafeRemote("TravelMain")
    elseif Makito.Sea == 2 and level >= 1500 then
        -- Go to Sea 3 (Mr. Captain NPC at Green Bit)
        Makito.Utils.TweenTo(CFrame.new(-2840, 10, 5318))
        Makito.Utils.SafeRemote("TravelDressrosa")
    end
end

-- Outras lógicas (Chest, Dungeon, Valentine, SeaEvents, End-Game) permanecem as mesmas ou foram integradas
function FarmingModule.ChestFarmLogic()
    if not Makito.Settings.AutoChest then return end
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Name:find("Chest") and v:IsA("BasePart") then
            Makito.Utils.TweenTo(v.CFrame)
            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v, 0)
            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v, 1)
            break
        end
    end
end

function FarmingModule.DungeonModeLogic()
    local dungeonFolder = workspace:FindFirstChild("Dungeons") or workspace:FindFirstChild("DungeonV2")
    if dungeonFolder or Makito.Utils.SafeRemote("IsInRaid") then
        local enemy = Makito.Utils.GetNearestEnemyAny()
        if enemy then
            local targetPos = enemy.HumanoidRootPart.CFrame
            if Makito.Settings.RaidMode == "Above" then
                targetPos = targetPos * CFrame.new(0, 50, 0)
            else
                targetPos = targetPos * CFrame.new(0, -15, 0)
            end
            Makito.Utils.TweenTo(targetPos)
            Makito.Combat.StartCombatLoop()
        end
    end
end

-- ... lógicas de Valentine, Fishing, SeaEvents, End-Game (já implementadas ou simplificadas) ...
function FarmingModule.ValentineEventLogic()
    if Makito.Settings.AutoCollectHearts then
        local enemy = Makito.Utils.GetNearestEnemyAny()
        if enemy then
            Makito.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0))
            Makito.Combat.StartCombatLoop()
        end
    end
    if Makito.Settings.AutoValentineGacha then
        Makito.Utils.SafeRemote("ValentineDealer", "Gacha")
    end
end

function FarmingModule.FishingLogic()
    local rod = LocalPlayer.Backpack:FindFirstChild("Fishing Rod") or LocalPlayer.Character:FindFirstChild("Fishing Rod")
    if not rod then return end
    if not LocalPlayer.Character:FindFirstChild("Fishing Rod") then
        LocalPlayer.Humanoid:EquipTool(rod)
    end
    local fishingGui = LocalPlayer.PlayerGui:FindFirstChild("FishingGui")
    if fishingGui and fishingGui.Visible then
        local indicator = fishingGui:FindFirstChild("Indicator")
        if indicator and indicator.Position.X.Scale > 0.4 and indicator.Position.X.Scale < 0.6 then
            Makito.Utils.SafeRemote("Fishing", "Catch")
        end
    else
        Makito.Utils.SafeRemote("Fishing", "Cast")
    end
end

function FarmingModule.SeaEventLogic()
    local SeaEvents = workspace:FindFirstChild("SeaEvents") or workspace:FindFirstChild("Sea")
    if not SeaEvents then return end

    if Makito.Settings.AutoTerrorShark then
        local ts = SeaEvents:FindFirstChild("Terrorshark") or SeaEvents:FindFirstChild("Terror Shark")
        if ts and ts:FindFirstChild("Humanoid") and ts.Humanoid.Health > 0 then
            Makito.Utils.TweenTo(ts.HumanoidRootPart.CFrame * CFrame.new(0, 40, 0))
            Makito.Combat.StartCombatLoop()
            return
        end
    end

    if Makito.Settings.AutoLeviathan then
        local levi = SeaEvents:FindFirstChild("Leviathan")
        if levi and levi:FindFirstChild("Head") then
            Makito.Utils.TweenTo(levi.Head.CFrame * CFrame.new(0, 50, 0))
            Makito.Combat.StartCombatLoop()
            return
        end
    end

    if Makito.Settings.AutoSeaBeast then
        local sb = SeaEvents:FindFirstChild("Sea Beast") or SeaEvents:FindFirstChild("SeaBeast")
        if sb and sb:FindFirstChild("Humanoid") and sb.Humanoid.Health > 0 then
            Makito.Utils.TweenTo(sb.HumanoidRootPart.CFrame * CFrame.new(0, 50, 0))
            Makito.Combat.StartCombatLoop()
            return
        end
    end

    if Makito.Settings.AutoKitsuneEvent then
        local island = SeaEvents:FindFirstChild("Kitsune Island")
        if island then
            local ember = island:FindFirstChild("Azure Ember") or island:FindFirstChild("AzureEmber")
            if ember then
                Makito.Utils.TweenTo(ember.CFrame)
            else
                Makito.Utils.TweenTo(island.WorldPivot * CFrame.new(0, 50, 0))
            end
            return
        end
    end
end

function FarmingModule.AutoCDKLogic()
    if not Makito.Utils.HasItem("Tushita") or not Makito.Utils.HasItem("Yama") then return end
    Makito.Utils.TweenTo(CFrame.new(-11475, 831, 330))
    Makito.Utils.SafeRemote("CDKQuest", "Start")
end

function FarmingModule.AutoSoulGuitarLogic()
    local moon = game:GetService("Lighting").Sky.FullMoonMagnitude
    if moon > 0.9 then
        Makito.Utils.TweenTo(CFrame.new(-9515, 164, -5785))
        Makito.Utils.SafeRemote("SoulGuitarQuest", "Pray")
    end
end

function FarmingModule.AutoGodhumanLogic()
    Makito.Utils.TweenTo(CFrame.new(-12463, 375, -7523))
    Makito.Utils.SafeRemote("BuyFightingStyle", "Godhuman")
end

function FarmingModule.SanguineArtLogic()
    if not Makito.Utils.HasItem("Leviathan Heart") then return end
    Makito.Utils.TweenTo(CFrame.new(-15200, 400, -11500))
    Makito.Utils.SafeRemote("SanguineArt", "Learn")
end

return FarmingModule
