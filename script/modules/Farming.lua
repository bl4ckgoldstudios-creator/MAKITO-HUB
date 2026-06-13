--!strict
local FarmingModule = {}

-- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- INTERNAL STATE
local Makito = getgenv().Makito

-- ==================================================
-- DADOS DO EXEMPLO: BOSSES E QUESTS
-- ==================================================
local BossData = {
    World1 = {
        "The Gorilla King", "Bobby", "The Saw", "Yeti", "Mob Leader",
        "Vice Admiral", "Saber Expert", "Warden", "Chief Warden", "Swan",
        "Magma Admiral", "Fishman Lord", "Wysper", "Thunder God", "Cyborg",
        "Ice Admiral", "Greybeard"
    },
    World2 = {
        "Diamond", "Jeremy", "Fajita", "Don Swan", "Smoke Admiral",
        "Awakened Ice Admiral", "Tide Keeper", "Darkbeard", "Cursed Captain", "Order"
    },
    World3 = {
        "Stone", "Hydra Leader", "Kilo Admiral", "Captain Elephant",
        "Beautiful Pirate", "Cake Queen", "Longma", "Soul Reaper"
    }
}

local MaterialData = {
    World1 = {"Leather + Scrap Metal", "Angel Wings", "Magma Ore", "Fish Tail"},
    World2 = {"Leather + Scrap Metal", "Radioactive Material", "Ectoplasm", "Mystic Droplet", "Magma Ore", "Vampire Fang"},
    World3 = {"Scrap Metal", "Demonic Wisp", "Conjured Cocoa", "Dragon Scale", "Gunpowder", "Fish Tail", "Mini Tusk"}
}

-- ==================================================
-- VARIÁVEIS GLOBAIS DO FARM (DO EXEMPLO)
-- ==================================================
local PosMon = nil
local _B = false
local bMon = ""
local Qname = ""
local Qdata = 0
local PosQBoss = CFrame.new(0, 0, 0)
local PosB = CFrame.new(0, 0, 0)

-- ==================================================
-- 1. EQUIPAMENTO
-- ==================================================
function FarmingModule.EquipWeapon(weaponName: string)
    if not weaponName then return end
    
    if LocalPlayer.Backpack:FindFirstChild(weaponName) then
        LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild(weaponName))
    end
end

function FarmingModule.EquipWeaponByToolTip(toolTip: string)
    if not toolTip then return end
    
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == toolTip then
            FarmingModule.EquipWeapon(tool.Name)
        end
    end
end

-- ==================================================
-- 2. FUNÇÕES DE KILL (DO EXEMPLO)
-- ==================================================
function FarmingModule.Kill(targetModel: Model)
    if not (targetModel and targetModel:FindFirstChild("HumanoidRootPart")) then return end
    
    local hrp = targetModel.HumanoidRootPart
    
    if not targetModel:GetAttribute("Locked") then
        targetModel:SetAttribute("Locked", hrp.CFrame)
    end
    
    PosMon = (targetModel:GetAttribute("Locked")).Position
    _B = true
    FarmingModule.BringEnemy()
    
    local MainWeapon = Makito.Settings and Makito.Settings.MainWeapon or "Melee"
    FarmingModule.EquipWeaponByToolTip(MainWeapon)
    
    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    local MobHeight = Makito.Settings and Makito.Settings.MobHeight or 20
    Makito.Utils._tp(hrp.CFrame * CFrame.new(0, MobHeight, 0))
end

function FarmingModule.Kill2(targetModel: Model)
    if not targetModel then return end
    
    if not targetModel:GetAttribute("Locked") then
        targetModel:SetAttribute("Locked", targetModel.HumanoidRootPart.CFrame)
    end
    
    PosMon = (targetModel:GetAttribute("Locked")).Position
    FarmingModule.BringEnemy()
    
    local MainWeapon = Makito.Settings and Makito.Settings.MainWeapon or "Melee"
    FarmingModule.EquipWeaponByToolTip(MainWeapon)
    
    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool then
        local toolTip = tool.ToolTip
        
        if toolTip == "Blox Fruit" then
            Makito.Utils._tp((targetModel.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0)) * CFrame.Angles(0, math.rad(90), 0))
        else
            Makito.Utils._tp((targetModel.HumanoidRootPart.CFrame * CFrame.new(0, 20, 8)) * CFrame.Angles(0, math.rad(180), 0))
        end
    end
end

function FarmingModule.Sword(targetModel: Model)
    if not targetModel then return end
    
    if not targetModel:GetAttribute("Locked") then
        targetModel:SetAttribute("Locked", targetModel.HumanoidRootPart.CFrame)
    end
    
    PosMon = (targetModel:GetAttribute("Locked")).Position
    FarmingModule.BringEnemy()
    FarmingModule.EquipWeaponByToolTip("Sword")
    Makito.Utils._tp(targetModel.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
end

function FarmingModule.Mas(targetModel: Model)
    if not targetModel then return end
    
    if not targetModel:GetAttribute("Locked") then
        targetModel:SetAttribute("Locked", targetModel.HumanoidRootPart.CFrame)
    end
    
    PosMon = (targetModel:GetAttribute("Locked")).Position
    FarmingModule.BringEnemy()
    
    if targetModel.Humanoid.Health <= (Makito.Settings and Makito.Settings.MasteryHealth or 20) then
        Makito.Utils._tp(targetModel.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))
        Makito.Utils.UseFruitSkills()
    else
        FarmingModule.EquipWeaponByToolTip("Melee")
        Makito.Utils._tp(targetModel.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
    end
end

function FarmingModule.Masgun(targetModel: Model)
    if not targetModel then return end
    
    if not targetModel:GetAttribute("Locked") then
        targetModel:SetAttribute("Locked", targetModel.HumanoidRootPart.CFrame)
    end
    
    PosMon = (targetModel:GetAttribute("Locked")).Position
    FarmingModule.BringEnemy()
    
    if targetModel.Humanoid.Health <= (Makito.Settings and Makito.Settings.MasteryHealth or 20) then
        Makito.Utils._tp(targetModel.HumanoidRootPart.CFrame * CFrame.new(0, 35, 8))
        Makito.Utils.UseSkills("Gun", "Z")
        Makito.Utils.UseSkills("Gun", "X")
    else
        FarmingModule.EquipWeaponByToolTip("Melee")
        Makito.Utils._tp(targetModel.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
    end
end

-- ==================================================
-- 3. BRING ENEMY (VERSÃO MELHORADA DO EXEMPLO)
-- ==================================================
local function IsRaidMob(mob)
    local mobName = mob.Name:lower()
    
    if mobName:find("raid") or mobName:find("microchip") or mobName:find("island") then
        return true
    end
    
    if mob:GetAttribute("IsRaid") or mob:GetAttribute("RaidMob") or mob:GetAttribute("IsBoss") then
        return true
    end
    
    local hum = mob:FindFirstChild("Humanoid")
    if hum and hum.WalkSpeed == 0 then
        return true
    end
    
    if mob.Parent and tostring(mob.Parent):lower():find("_worldorigin") then
        return true
    end
    
    return false
end

function FarmingModule.BringEnemy()
    if not Makito.Settings or not Makito.Settings.AutoFarm then return end
    if not PosMon then return end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
    local enemies = enemiesFolder:GetChildren()
    local BringRange = Makito.Settings.BringRange or 300
    
    for _, mob in pairs(enemies) do
        if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            local mobRoot = mob:FindFirstChild("HumanoidRootPart")
            if mobRoot then
                if (mobRoot.Position - PosMon).Magnitude <= BringRange then
                    mobRoot.CFrame = CFrame.new(PosMon)
                    mobRoot.CanCollide = true
                    mob.Humanoid.WalkSpeed = 0
                    mob.Humanoid.JumpPower = 0
                    if mob.Humanoid:FindFirstChild("Animator") then
                        mob.Humanoid.Animator:Destroy()
                    end
                    LocalPlayer.SimulationRadius = math.huge
                end
            end
        end
    end
end

-- ==================================================
-- 4. QUEST BOSS (DO EXEMPLO)
-- ==================================================
function FarmingModule.QuestB()
    if not Makito.Sea then return end
    
    if Makito.Sea == 1 then
        local FindBoss = "The Gorilla King"
        if FindBoss == "The Gorilla King" then
            bMon = "The Gorilla King"
            Qname = "JungleQuest"
            Qdata = 3
            PosQBoss = CFrame.new(-1601.6553955078, 36.85213470459, 153.38809204102)
            PosB = CFrame.new(-1088.75977, 8.13463783, -488.559906, -0.707134247, 0, .707079291, 0, 1, 0, -0.707079291, 0, -0.707134247)
        end
        -- Adicione outros bosses aqui
    elseif Makito.Sea == 2 then
        -- World 2 Bosses
    elseif Makito.Sea == 3 then
        -- World 3 Bosses
    end
end

-- ==================================================
-- 5. SUPREME AUTO FARM (ORIGINAL + EXEMPLO)
-- ==================================================
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

    if Makito.Data and Makito.Data.QuestData then
        local quest, isQuestActive = FarmingModule.SupremeQuestHandler(Makito.Data.QuestData)
        
        if quest then
            if isQuestActive then
                local enemy = Makito.Utils.GetNearestEnemy(quest.Enemy)
                if enemy and enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") then
                    -- Usar o sistema do exemplo: Kill
                    FarmingModule.Kill(enemy)
                    
                    -- Iniciar combat loop
                    Makito.Combat.StartCombatLoop()
                else
                    local spawnPos = quest.Spawn or quest.Pos
                    Makito.Utils.TweenTo(spawnPos * CFrame.new(0, 50, 0))
                end
            end
        end
    end
end

-- ==================================================
-- 6. OUTRAS FUNÇÕES DE FARM (ORIGINAL MAKITO)
-- ==================================================
function FarmingModule.AutoFarmAllBosses()
    if not Makito.Settings or not Makito.Data then return end
    
    local enemies = workspace:FindFirstChild("Enemies") or workspace
    
    local bossesToFarm
    if Makito.Settings.AutoFarmAllBosses then
        bossesToFarm = {}
        for _, boss in ipairs(Makito.Data.BossData or {}) do
            table.insert(bossesToFarm, boss.Name)
        end
    elseif Makito.Settings.SelectedBosses and #Makito.Settings.SelectedBosses > 0 then
        bossesToFarm = Makito.Settings.SelectedBosses
    else
        return
    end
    
    for _, bossName in ipairs(bossesToFarm) do
        for _, obj in ipairs(enemies:GetChildren()) do
            if obj.Name:find(bossName) and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                Makito.Utils.TweenTo(obj.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0))
                FarmingModule.EquipWeaponByToolTip(Makito.Settings.MainWeapon or "Melee")
                Makito.Combat.StartCombatLoop()
                return
            end
        end
    end
end

-- ==================================================
-- 7. LOOP DE AUTOMAÇÃO
-- ==================================================
function FarmingModule.UpdateAutomation()
    if not Makito.Settings then return end
    
    pcall(function()
        if Makito.Settings.AutoFarm then FarmingModule.SupremeAutoFarm() end
        
        -- Boss Farm
        if Makito.Settings.AutoFarmAllBosses or (Makito.Settings.SelectedBosses and #Makito.Settings.SelectedBosses > 0) then
            FarmingModule.AutoFarmAllBosses()
        end
    end)
end

-- ==================================================
-- 8. INICIALIZAÇÃO
-- ==================================================
function FarmingModule.Initialize()
    -- Iniciar loop de Bring Enemy (do exemplo)
    task.spawn(function()
        while Makito and Makito.Running do
            if Makito.Settings and Makito.Settings.AutoFarm then
                _B = true
                FarmingModule.BringEnemy()
                task.wait(3)
                _B = false
                task.wait(5)
            else
                _B = false
                task.wait(1)
            end
        end
    end)
    
    print("✅ [MAKITO] Farming Module inicializado!")
end

return FarmingModule
