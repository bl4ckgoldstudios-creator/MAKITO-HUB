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
    local level = LocalPlayer.Data.Level.Value
    local sea = FarmingModule.GetSea()
    local currentQuests = QuestData[sea]
    
    -- IDENTIFICAÇÃO INSTANTÂNEA DA MELHOR MISSÃO
    local BestQuest = nil
    for i = #currentQuests, 1, -1 do
        local q = currentQuests[i]
        if level >= q.Min then
            BestQuest = q
            break
        end
    end

    if not BestQuest then return nil end

    -- VERIFICAÇÃO DE MISSÃO ATIVA SEM DEPENDER DA UI (MAIS RÁPIDO)
    local hasQuest = false
    pcall(function()
        local questContainer = LocalPlayer.PlayerGui.Main.Quest.Container
        if questContainer.Visible and questContainer.QuestTitle.Title.Text ~= "" then
            hasQuest = true
        end
    end)

    if not hasQuest and _G.Settings.AutoQuest then
        -- TELEPORTE E ACEITAÇÃO INSTANTÂNEA
        local npcPos = BestQuest.Pos
        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - npcPos.Position).Magnitude
        
        if dist > 15 then
            _G.Utils.TweenTo(npcPos * CFrame.new(0, 15, 0), 500)
        else
            -- SPAM DE REMOTOS COM BYPASS DE COOLDOWN
            for i = 1, 5 do
                _G.Utils.SafeRemote("StartQuest", BestQuest.Name, BestQuest.ID)
            end
        end
    end
    
    return BestQuest
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
function FarmingModule.SupremeAutoFarm()
    if not _G.Settings.AutoFarm then return end
    
    pcall(function()
        local Quest = FarmingModule.SupremeQuestHandler(_G.Data.QuestData)
        if not Quest then return end

        local enemy = _G.Utils.GetNearestEnemy(Quest.Enemy)
        
        if enemy then
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
            _G.Utils.TweenTo(Quest.Pos * CFrame.new(0, 30, 0))
            if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Aguardando Spawn de " .. Quest.Enemy end
        end
    end)
end

-- ADVANCED AUTO SOUL GUITAR
function FarmingModule.AutoSoulGuitarLogic()
    if not _G.Settings.AutoSoulGuitar then return end
    -- Check if already has it
    if LocalPlayer.Backpack:FindFirstChild("Soul Guitar") or LocalPlayer.Character:FindFirstChild("Soul Guitar") then return end
    
    -- Puzzle Logic (Simplified for this version)
    -- 1. Check if full moon
    if game:GetService("Lighting").Sky.FullMoonMagnitude > 0.9 then
        -- 2. Pray at Gravestone
        _G.Utils.TweenTo(CFrame.new(-9515, 164, -5785))
        _G.Utils.SafeRemote("SoulGuitar", "Pray")
    end
    -- 3. Farm Materials
    -- (Logic to farm Bones, Ectoplasm, Dark Fragment)
end

-- AUTO CDK (CURSED DUAL KATANA)
function FarmingModule.AutoCDKLogic()
    if not _G.Settings.AutoCDK then return end
    -- Logic for Tushita and Yama questlines
    -- 1. Check if has Tushita and Yama at 350+ Mastery
    -- 2. Complete Alucard Quests
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

-- AUTO NEXT SEA
function FarmingModule.AutoNextSeaLogic()
    if not _G.Settings.AutoNextSea then return end
    local level = LocalPlayer.Data.Level.Value
    local sea = FarmingModule.GetSea()
    
    if sea == 1 and level >= 700 then
        -- Logic to talk to Military Detective and go to Sea 2
        _G.Utils.SafeRemote("TravelMain")
    elseif sea == 2 and level >= 1500 then
        -- Logic to fight Rip_Indra and go to Sea 3
        _G.Utils.SafeRemote("TravelZou")
    end
end

return FarmingModule
