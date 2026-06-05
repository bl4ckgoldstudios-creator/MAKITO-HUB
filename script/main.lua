-- MAKITO HUB - Blox Fruits Edition (MODULAR VERSION)
-- Entry Point: main.lua

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 1. LOAD MODULES (SMART LOADER PC/GITHUB)
 local function LoadModule(name)
     local localPath = "modules/" .. name .. ".lua"
     local githubBase = "https://raw.githubusercontent.com/bl4ckgoldstudios-creator/MAKITO-HUB/refs/heads/main/script/modules/"
     
     print("[MAKITO DEBUG]: Tentando carregar " .. name)
     
     local success, result = pcall(function()
         if isfile and isfile(localPath) then
             print("[MAKITO DEBUG]: Carregando local: " .. localPath)
             return loadstring(readfile(localPath))()
         else
             local url = githubBase .. name .. ".lua"
             print("[MAKITO DEBUG]: Baixando do GitHub: " .. url)
             local content = game:HttpGet(url)
             if content and content ~= "" then
                 return loadstring(content)()
             else
                 error("Conteudo vazio retornado do GitHub")
             end
         end
     end)
     
     if success then
         print("[MAKITO DEBUG]: Modulo " .. name .. " carregado com sucesso!")
         return result
     else
         local err = "[MAKITO HUB ERROR]: Falha ao carregar modulo " .. name .. " -> " .. tostring(result)
         warn(err)
         -- Tenta notificar na tela se o Utils ja existir
         pcall(function() 
             game:GetService("StarterGui"):SetCore("SendNotification", {
                 Title = "Erro de Carregamento",
                 Text = "Falha no modulo: " .. name,
                 Duration = 10
             })
         end)
         return nil
     end
 end

local Settings = LoadModule("Settings")
local Data = LoadModule("Data")
local Utils = LoadModule("Utils")
local Combat = LoadModule("Combat")
local Farming = LoadModule("Farming")
local UI = LoadModule("UI")

_G.Settings = Settings.Values
_G.Data = Data
_G.Utils = Utils
_G.Combat = Combat
_G.Farming = Farming

-- 2. INITIALIZATION
Settings.Load()

-- PROGRESS TRACKING
local StartLevel = LocalPlayer.Data.Level.Value
local StartMoney = LocalPlayer.Data.Beli.Value
local StartTime = os.time()

-- MODERATOR DETECTOR
task.spawn(function()
    while _G.MakitoHubRunning do
        Utils.CheckModerator()
        task.wait(30)
    end
end)

Combat.AddTask("MainFarm", function()
    if not _G.Settings.AutoFarm then return end
    
    pcall(function()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

        local Quest = Farming.GetQuestData(Data.QuestData)
        local MainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
        local HasQuest = MainGui and MainGui:FindFirstChild("Quest") and MainGui.Quest.Visible

        if Quest then
            if not HasQuest and _G.Settings.AutoQuest then
                if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Pegando Missão [" .. Quest.Enemy .. "]" end
                Farming.TakeQuest(Quest)
            else
                local enemy = Utils.GetNearestEnemy(Quest.Enemy)
                if enemy then
                    if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Farmando " .. enemy.Name end
                    
                    -- Maestria ou Arma Selecionada
                    if _G.Settings.AutoMastery then
                        Combat.MasteryAutoSwitch(enemy, _G.Settings.MasteryWeapon)
                    else
                        Farming.EquipWeapon(_G.Settings.Weapon)
                    end
                    
                    -- Movimentação Adaptativa (Posicionamento Superior)
                    local targetCF = enemy.HumanoidRootPart.CFrame * CFrame.new(0, _G.Settings.Distance, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    
                    -- Se o inimigo estiver longe, usa Tween, se estiver perto, trava o CFrame (Estabilidade Redz)
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - targetCF.Position).Magnitude
                    if dist > 50 then
                        Utils.TweenTo(targetCF)
                    else
                        Utils.Float(true)
                        LocalPlayer.Character.HumanoidRootPart.CFrame = targetCF
                    end
                    
                    -- Bring Mobs & Fast Attack
                    Farming.BringMobs(enemy)
                    Combat.StartFastAttack()
                    
                    -- Auto Skills
                    if _G.Settings.AutoSkill then
                        Combat.UseSkill("Z")
                        Combat.UseSkill("X")
                        Combat.UseSkill("C")
                        Combat.UseSkill("V")
                    end
                else
                    if _G.MakitoStatus then _G.MakitoStatus.Text = "Status: Esperando Spawn..." end
                    local waitPos = Quest.Pos
                    Utils.TweenTo(waitPos * CFrame.new(0, 30, 0))
                end
            end
        end
    end)
end)

Combat.AddTask("SpecialFarms", function()
    Farming.AutoBoneLogic()
    Farming.AutoEliteHunter()
    Farming.AutoRaidLogic()
    Farming.AutoCakeLogic()
end)

Combat.AddTask("PvP", function()
    Combat.AutoBountyLogic()
end)

Combat.AddTask("SeaEvents", function()
    Farming.SeaEventLogic()
    Farming.SpecialIslandLogic()
end)

Combat.AddTask("ChestFarm", function()
    Farming.AutoChestLogic()
end)

-- PERFORMANCE OPTIMIZATION
task.spawn(function()
    while _G.MakitoHubRunning do
        task.wait(2)
        pcall(function()
            Utils.WalkOnWater(_G.Settings.WalkOnWater)
            if _G.Settings.FPSBooster then Utils.FPSBooster(true) end
            
            if _G.Settings.WhiteScreen then
                game:GetService("RunService"):Set3dRenderingEnabled(false)
            else
                game:GetService("RunService"):Set3dRenderingEnabled(true)
            end
        end)
    end
end)

-- START UI
if UI then
    UI.CreateHub()
    Utils.Notify("MAKITO HUB SUPREME V7.0 INICIADO!", 5)
else
    warn("[MAKITO HUB FATAL]: UI Module not found. Script stopped.")
end
