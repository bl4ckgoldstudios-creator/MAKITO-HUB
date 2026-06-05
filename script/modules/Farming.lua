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

    local MainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
    if MainGui and MainGui:FindFirstChild("Quest") and MainGui.Quest.Visible then
        local questText = ""
        pcall(function()
            questText = MainGui.Quest.Container.QuestTitle.Title.Text:lower()
        end)
        
        local TitleMap = {
            ["skull slayer"] = "Skull Slayer",
            ["outlaw hunter"] = "Isle Outlaw",
            ["island sailor"] = "Island Sailor",
            ["island champion"] = "Island Champion",
            ["sun-kissed warrior"] = "Sun-kissed Warrior",
            ["serpent hunter"] = "Serpent Hunter"
        }

        for title, enemy in pairs(TitleMap) do
            if questText:find(title) then
                for _, q in ipairs(data) do
                    if q.Enemy == enemy then return q end
                end
            end
        end
    end

    local level = LocalPlayer.Data.Level.Value
    for i = #data, 1, -1 do
        local q = data[i]
        if level >= q.Min then
            return q
        end
    end
    return data[1]
end

function FarmingModule.EquipWeapon(weaponName)
    local weapon = LocalPlayer.Backpack:FindFirstChild(weaponName) or LocalPlayer.Character:FindFirstChild(weaponName)
    if weapon and weapon.Parent == LocalPlayer.Backpack then
        LocalPlayer.Character.Humanoid:EquipTool(weapon)
    end
end

-- CLUSTER BRING MOBS: Agrupa mobs de forma ultra eficiente
function FarmingModule.BringMobs(targetEnemy, radius)
    if not _G.Settings.BringMobs or not targetEnemy then return end
    
    local radius = radius or 250
    local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
    
    for _, v in ipairs(enemiesFolder:GetChildren()) do
        if v.Name == targetEnemy.Name and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local dist = (v.HumanoidRootPart.Position - targetEnemy.HumanoidRootPart.Position).Magnitude
            if dist < radius then
                -- Otimização de Física para reduzir Lag
                v.HumanoidRootPart.CanCollide = false
                v.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
                v.HumanoidRootPart.CFrame = targetEnemy.HumanoidRootPart.CFrame
                
                -- Desativa IA de movimento
                if v.Humanoid.Sit ~= true then v.Humanoid.Sit = true end
                
                -- Anti-Reset: Impede que o mob volte para o spawn original
                if v:FindFirstChild("Data") and v.Data:FindFirstChild("SpawnPos") then
                    v.Data.SpawnPos.Value = targetEnemy.HumanoidRootPart.Position
                end
            end
        end
    end
end

-- INSTANT QUEST: Pega a missão instantaneamente
function FarmingModule.TakeQuest(Quest)
    if not Quest then return end
    
    local npcPos = Quest.Pos
    local npcModel = workspace:FindFirstChild(Quest.NPC, true)
    if npcModel and npcModel:FindFirstChild("HumanoidRootPart") then
        npcPos = npcModel.HumanoidRootPart.CFrame
    end

    -- Tween ultra rápido apenas se estiver longe
    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - npcPos.Position).Magnitude
    if dist > 15 then
        _G.Utils.TweenTo(npcPos * CFrame.new(0, 10, 0), 500)
    end

    -- Spam de remotos para garantir que pegou a missão
    if dist < 20 then
        for i = 1, 3 do
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", Quest.Name, Quest.ID)
            end)
        end
        task.wait(0.1)
    end
end

-- ADVANCED SEA EVENTS
function FarmingModule.SeaEventLogic()
    if not _G.Settings.AutoSeaEvent then return end
    
    local SeaEvents = workspace:FindFirstChild("SeaEvents") or workspace:FindFirstChild("Sea")
    if not SeaEvents then return end

    for _, v in ipairs(SeaEvents:GetChildren()) do
        if v.Name == "Terror Shark" or v.Name == "Piranha" or v.Name == "Sea Beast" then
            -- Lógica de combate específica para mar
            _G.Utils.TweenTo(v.PrimaryPart.CFrame * CFrame.new(0, 50, 0))
            _G.Combat.StartFastAttack()
        end
    end
end

-- KITSUNE ISLAND & MIRAGE
function FarmingModule.SpecialIslandLogic()
    if _G.Settings.AutoKitsune then
        local Kitsune = workspace:FindFirstChild("KitsuneIsland")
        if Kitsune then
            _G.Utils.Notify("ILHA KITSUNE ENCONTRADA!", 10)
            _G.Utils.TweenTo(Kitsune.PrimaryPart.CFrame)
            -- Auto Collect Azure Flames
        end
    end
end

-- AUTO CHEST ULTRA-FAST
function FarmingModule.AutoChestLogic()
    if not _G.Settings.AutoChest then return end
    
    local function Collect(v)
        if v:IsA("BasePart") or v:FindFirstChildWhichIsA("BasePart") then
            local part = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart")
            _G.Utils.TweenTo(part.CFrame, 600) -- Velocidade máxima para baús
            task.wait(0.1)
        end
    end

    for _, v in ipairs(workspace:GetChildren()) do
        if v.Name:find("Chest") then
            Collect(v)
        end
    end
    
    local chestFolder = workspace:FindFirstChild("Chests")
    if chestFolder then
        for _, v in ipairs(chestFolder:GetChildren()) do
            Collect(v)
        end
    end
end

-- AUTO BONE FARM
function FarmingModule.AutoBoneLogic()
    if not _G.Settings.AutoBone then return end
    
    local enemy = _G.Utils.GetNearestEnemy("Reborn Skeleton") or _G.Utils.GetNearestEnemy("Living Zombie") or _G.Utils.GetNearestEnemy("Demonic Soul") or _G.Utils.GetNearestEnemy("Posessed Mummy")
    if enemy then
        FarmingModule.EquipWeapon(_G.Settings.Weapon)
        _G.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, _G.Settings.Distance, 0))
        _G.Combat.StartFastAttack()
        
        -- Auto Exchange Bones if near Death King
        if LocalPlayer.Data:FindFirstChild("Bones") and LocalPlayer.Data.Bones.Value >= 50 then
            _G.Utils.SafeRemote("Bones", "Buy", 1, 1)
        end
    else
        -- Go to Haunted Castle
        _G.Utils.TweenTo(CFrame.new(-9515, 164, -5785))
    end
end

-- AUTO ELITE HUNTER
function FarmingModule.AutoEliteHunter()
    if not _G.Settings.AutoEliteHunter then return end
    
    local elites = {"Deandre", "Diablo", "Urban"}
    local target = nil
    
    for _, name in ipairs(elites) do
        local enemy = _G.Utils.GetNearestEnemy(name)
        if enemy then target = enemy break end
    end
    
    if target then
        if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Matando Elite [" .. target.Name .. "]" end
        FarmingModule.EquipWeapon(_G.Settings.Weapon)
        _G.Utils.TweenTo(target.HumanoidRootPart.CFrame * CFrame.new(0, _G.Settings.Distance, 0))
        _G.Combat.StartFastAttack()
    else
        -- Check if quest is active
        local MainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
        local HasQuest = MainGui and MainGui:FindFirstChild("Quest") and MainGui.Quest.Visible
        
        if not HasQuest then
            if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Pegando Missão Elite" end
            _G.Utils.TweenTo(CFrame.new(-5400, 15, 1000)) -- Castle on the Sea
            if (LocalPlayer.Character.HumanoidRootPart.Position - Vector3.new(-5400, 15, 1000)).Magnitude < 20 then
                _G.Utils.SafeRemote("EliteHunter", "Progress")
            end
        else
            if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Procurando Elite..." end
            -- Optional: Server Hop if not found
        end
    end
end

-- AUTO RAID SYSTEM
function FarmingModule.AutoRaidLogic()
    if not _G.Settings.AutoRaid then return end
    
    -- Auto Buy Chip
    if _G.Settings.AutoBuyChip and not LocalPlayer.Backpack:FindFirstChild("Special Microchip") and not LocalPlayer.Character:FindFirstChild("Special Microchip") then
        _G.Utils.SafeRemote("Raids", "Buy", _G.Settings.SelectedRaid)
    end
    
    -- Auto Start Raid
    if (LocalPlayer.Character.HumanoidRootPart.Position - Vector3.new(-495, 300, -2850)).Magnitude < 10 then
        _G.Utils.SafeRemote("Raids", "Start")
    end
    
    -- In-Raid Logic
    local raidFolder = workspace:FindFirstChild("Sea") -- Raids usually happen here
    if raidFolder then
        local enemy = _G.Utils.GetNearestEnemy() -- Attack anything
        if enemy then
            FarmingModule.EquipWeapon(_G.Settings.Weapon)
            _G.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, _G.Settings.Distance, 0))
            _G.Combat.StartFastAttack()
        end
    end
end

-- AUTO DOUGH KING / CAKE PRINCE
function FarmingModule.AutoCakeLogic()
    if not _G.Settings.AutoDoughKing and not _G.Settings.AutoCakePrince then return end
    
    local target = _G.Settings.AutoDoughKing and "Dough King" or "Cake Prince"
    local enemy = _G.Utils.GetNearestEnemy(target)
    
    if enemy then
        if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Matando " .. target end
        FarmingModule.EquipWeapon(_G.Settings.Weapon)
        _G.Utils.TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, _G.Settings.Distance, 0))
        _G.Combat.StartFastAttack()
    else
        -- Go to Mirror World
        if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Indo para Mirror World" end
        _G.Utils.TweenTo(CFrame.new(-1147, 14, -11514))
    end
end

return FarmingModule
