--!strict
local FarmingModule = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Internal State
local Makito = getgenv().Makito
local PosMon = nil
local _B = false
local bMon = ""
local Qname = ""
local Qdata = 0
local CFrameQuest = CFrame.new(0, 0, 0)
local CFrameMon = CFrame.new(0, 0, 0)
local RequestEntrancePos = nil

-- Teleport functions from example
local function BTP(pos)
    pcall(function()
        if (pos.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude >= 1500 and LocalPlayer.Character.Humanoid.Health > 0 then
            repeat
                wait()
                LocalPlayer.Character.HumanoidRootPart.CFrame = pos
                wait(0.05)
                LocalPlayer.Character.Head:Destroy()
                LocalPlayer.Character.HumanoidRootPart.CFrame = pos
            until (pos.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 1500 and LocalPlayer.Character.Humanoid.Health > 0
        end
    end)
end

local function TP1(pos)
    local distance = (pos.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    if LocalPlayer.Character.Humanoid.Sit then
        LocalPlayer.Character.Humanoid.Sit = false
    end
    pcall(function()
        local tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart, TweenInfo.new(distance / 210, Enum.EasingStyle.Linear), {CFrame = pos})
        tween:Play()
    end)
    if distance <= 250 then
        LocalPlayer.Character.HumanoidRootPart.CFrame = pos
    end
end

-- Check Quest function from example
function FarmingModule.CheckQuest()
    local level = LocalPlayer.Data.Level.Value
    local world = Makito.Sea or 1
    local questData = Makito.Data and Makito.Data.QuestData and Makito.Data.QuestData[world]
    if not questData then return end
    
    for _, quest in ipairs(questData) do
        if level >= quest.Min and (not quest.Max or level <= quest.Max) then
            bMon = quest.Enemy
            Qname = quest.Name
            Qdata = quest.LevelQuest
            CFrameQuest = quest.CFrameQuest
            CFrameMon = quest.CFrameMon
            RequestEntrancePos = quest.RequestEntrancePos
            break
        end
    end
end

-- Auto Haki from example
function FarmingModule.AutoHaki()
    if not LocalPlayer.Character:FindFirstChild("HasBuso") then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
    end
end

-- Equip Weapon from example
function FarmingModule.EquipWeapon(weapon)
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            if tool.ToolTip == weapon then
                LocalPlayer.Character.Humanoid:EquipTool(tool)
            end
        end
    end
end

-- Bring Enemy from example
function FarmingModule.BringEnemy()
    if not Makito.Settings or not Makito.Settings.AutoFarm or not PosMon then return end
    
    local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
    local enemies = enemiesFolder:GetChildren()
    
    for _, mob in pairs(enemies) do
        if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            local mobRoot = mob:FindFirstChild("HumanoidRootPart")
            if mobRoot then
                mobRoot.CFrame = CFrame.new(PosMon)
                mobRoot.CanCollide = false
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

-- Kill functions from example
function FarmingModule.Kill(targetModel)
    if not targetModel or not targetModel:FindFirstChild("HumanoidRootPart") then return end
    
    if not targetModel:GetAttribute("Locked") then
        targetModel:SetAttribute("Locked", targetModel.HumanoidRootPart.CFrame)
    end
    
    PosMon = (targetModel:GetAttribute("Locked")).Position
    _B = true
    FarmingModule.BringEnemy()
    
    local weapon = Makito.Settings and Makito.Settings.MainWeapon or "Melee"
    FarmingModule.EquipWeapon(weapon)
    
    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    local mobHeight = Makito.Settings and Makito.Settings.MobHeight or 20
    Makito.Utils._tp(targetModel.HumanoidRootPart.CFrame * CFrame.new(0, mobHeight, 0))
end

function FarmingModule.Kill2(targetModel)
    if not targetModel then return end
    
    if not targetModel:GetAttribute("Locked") then
        targetModel:SetAttribute("Locked", targetModel.HumanoidRootPart.CFrame)
    end
    
    PosMon = (targetModel:GetAttribute("Locked")).Position
    FarmingModule.BringEnemy()
    
    local weapon = Makito.Settings and Makito.Settings.MainWeapon or "Melee"
    FarmingModule.EquipWeapon(weapon)
    
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

function FarmingModule.Sword(targetModel)
    if not targetModel then return end
    
    if not targetModel:GetAttribute("Locked") then
        targetModel:SetAttribute("Locked", targetModel.HumanoidRootPart.CFrame)
    end
    
    PosMon = (targetModel:GetAttribute("Locked")).Position
    FarmingModule.BringEnemy()
    FarmingModule.EquipWeapon("Sword")
    Makito.Utils._tp(targetModel.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
end

function FarmingModule.Mas(targetModel)
    if not targetModel then return end
    
    if not targetModel:GetAttribute("Locked") then
        targetModel:SetAttribute("Locked", targetModel.HumanoidRootPart.CFrame)
    end
    
    PosMon = (targetModel:GetAttribute("Locked")).Position
    FarmingModule.BringEnemy()
    
    if targetModel.Humanoid.Health <= (Makito.Settings and Makito.Settings.MasteryHealth or 20) then
        Makito.Utils._tp(targetModel.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))
        Makito.Utils.UseSkills("Blox Fruit", "Z")
        Makito.Utils.UseSkills("Blox Fruit", "X")
        Makito.Utils.UseSkills("Blox Fruit", "C")
    else
        FarmingModule.EquipWeapon("Melee")
        Makito.Utils._tp(targetModel.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
    end
end

function FarmingModule.Masgun(targetModel)
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
        FarmingModule.EquipWeapon("Melee")
        Makito.Utils._tp(targetModel.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
    end
end

-- Get Best Quest from our Data
function FarmingModule.GetBestQuest(questData)
    local level = LocalPlayer.Data.Level.Value
    local world = Makito.Sea or 1
    local currentQuests = questData and questData[world]
    if not currentQuests then return nil end
    
    for i = #currentQuests, 1, -1 do
        local quest = currentQuests[i]
        if level >= quest.Min then
            return quest
        end
    end
    return currentQuests[1]
end

-- Quest Handler
function FarmingModule.SupremeQuestHandler(questData)
    local bestQuest = FarmingModule.GetBestQuest(questData)
    if not bestQuest then return nil, false end
    
    -- Update vars from example
    bMon = bestQuest.Enemy
    Qname = bestQuest.Name
    Qdata = bestQuest.LevelQuest
    CFrameQuest = bestQuest.CFrameQuest
    CFrameMon = bestQuest.CFrameMon
    RequestEntrancePos = bestQuest.RequestEntrancePos
    
    -- Check if we have the quest
    local hasQuest = false
    pcall(function()
        local questGui = LocalPlayer.PlayerGui.Main:FindFirstChild("Quest")
        if questGui and questGui.Visible then
            local title = questGui.Container.QuestTitle.Title.Text
            if string.find(title, bMon) then
                hasQuest = true
            else
                ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest")
            end
        end
    end)
    
    if not hasQuest and Makito.Settings and Makito.Settings.AutoQuest then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return bestQuest, false end
        
        -- Use Request Entrance if available (from example)
        if RequestEntrancePos then
            if _G.AutoFarm and (CFrameQuest.Position - root.Position).Magnitude > 10000 then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", RequestEntrancePos)
            end
        end
        
        -- Teleport to quest NPC
        local distance = (root.Position - CFrameQuest.Position).Magnitude
        if distance > 20 then
            if Makito.Settings and Makito.Settings.BypassTP then
                BTP(CFrameQuest)
            else
                TP1(CFrameQuest)
            end
        else
            ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", Qname, Qdata)
        end
    end
    
    return bestQuest, hasQuest
end

-- Main Auto Farm Loop from example
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
    
    -- Check quest from example
    FarmingModule.CheckQuest()
    
    -- Check if we have quest
    local hasQuest = false
    pcall(function()
        local questGui = LocalPlayer.PlayerGui.Main:FindFirstChild("Quest")
        if questGui and questGui.Visible then
            local title = questGui.Container.QuestTitle.Title.Text
            if string.find(title, bMon) then
                hasQuest = true
            else
                ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest")
            end
        end
    end)
    
    if not hasQuest and Makito.Settings.AutoQuest then
        -- Use Request Entrance if available (from example)
        if RequestEntrancePos then
            if _G.AutoFarm and (CFrameQuest.Position - root.Position).Magnitude > 10000 then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", RequestEntrancePos)
            end
        end
        
        -- Teleport to quest NPC
        local distance = (root.Position - CFrameQuest.Position).Magnitude
        if distance > 20 then
            if Makito.Settings and Makito.Settings.BypassTP then
                BTP(CFrameQuest)
            else
                TP1(CFrameQuest)
            end
        else
            ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", Qname, Qdata)
        end
    elseif hasQuest then
        -- Find and kill the mob
        local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
        for _, mob in pairs(enemiesFolder:GetChildren()) do
            if mob.Name == bMon and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                PosMon = mob.HumanoidRootPart.Position
                FarmingModule.BringEnemy()
                
                -- Auto Haki
                FarmingModule.AutoHaki()
                
                -- Equip weapon
                local weapon = Makito.Settings and Makito.Settings.MainWeapon or "Melee"
                FarmingModule.EquipWeapon(weapon)
                
                -- Teleport to mob and attack (from example)
                -- Position rotation type (from example)
                local TypePos = 1
                local finalPos
                if TypePos == 1 then
                    finalPos = CFrame.new(0, Makito.Settings and Makito.Settings.MobHeight or 20, -30)
                elseif TypePos == 2 then
                    finalPos = CFrame.new(30, Makito.Settings and Makito.Settings.MobHeight or 20, 0)
                elseif TypePos == 3 then
                    finalPos = CFrame.new(0, Makito.Settings and Makito.Settings.MobHeight or 20, 30)
                elseif TypePos == 4 then
                    finalPos = CFrame.new(-30, Makito.Settings and Makito.Settings.MobHeight or 20, 0)
                end
                
                TP1(mob.HumanoidRootPart.CFrame * finalPos)
                mob.HumanoidRootPart.CanCollide = false
                mob.Humanoid.WalkSpeed = 0
                mob.Humanoid.JumpPower = 0
                mob.HumanoidRootPart.Size = Vector3.new(70, 70, 70)
                
                -- Start combat loop
                Makito.Combat.StartCombatLoop()
                return
            end
        end
        
        -- If no mob found, teleport to spawn position
        Makito.Utils.TweenTo(CFrameMon * CFrame.new(0, 50, 0))
    end
end

-- Boss Quest function from example
function FarmingModule.QuestB()
    if not Makito.Sea then return end
    
    if Makito.Sea == 1 then
        local findBoss = "The Gorilla King"
        if findBoss == "The Gorilla King" then
            bMon = "The Gorilla King"
            Qname = "JungleQuest"
            Qdata = 3
            CFrameQuest = CFrame.new(-1601.6553955078, 36.85213470459, 153.38809204102)
            CFrameMon = CFrame.new(-1088.75977, 8.13463783, -488.559906, -0.707134247, 0, 0.707079291, 0, 1, 0, -0.707079291, 0, -0.707134247)
        end
        -- Add more bosses for World 1, 2, 3 as needed
    end
end

-- Update Automation
function FarmingModule.UpdateAutomation()
    if not Makito.Settings then return end
    
    pcall(function()
        if Makito.Settings.AutoFarm then
            FarmingModule.SupremeAutoFarm()
        end
        
        -- Boss Farm
        if Makito.Settings.AutoFarmBoss or (Makito.Settings.SelectedBosses and #Makito.Settings.SelectedBosses > 0) then
            -- Add boss farming logic here
        end
    end)
end

-- Initialize
function FarmingModule.Initialize()
    -- Set globals for example compatibility
    _G.AutoFarm = false
    _G.SafeFarm = true
    
    -- Bring Enemy loop
    task.spawn(function()
        while Makito and Makito.Running do
            if Makito.Settings and Makito.Settings.AutoFarm and _B then
                FarmingModule.BringEnemy()
                wait(3)
                _B = false
                wait(5)
            else
                _B = false
                wait(1)
            end
        end
    end)
    
    -- Update _G.AutoFarm based on settings
    task.spawn(function()
        while Makito and Makito.Running do
            if Makito.Settings then
                _G.AutoFarm = Makito.Settings.AutoFarm or false
                _G.SafeFarm = Makito.Settings.SafeFarm or true
            end
            wait(0.5)
        end
    end)
    
    print("✅ [MAKITO] Farming Module inicializado!")
end

return FarmingModule
