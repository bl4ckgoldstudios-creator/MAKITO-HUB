local UtilsModule = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

local currentTween = nil
local isTweening = false

function UtilsModule.Notify(text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "MAKITO ELITE",
            Text = text,
            Duration = duration or 5
        })
    end)
end

-- MOVIMENTAÇÃO ELITE (NON-LINEAR TWEEN)
function UtilsModule.TweenTo(cf, speed)
    if not _G.MakitoHubRunning or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    local dist = (root.Position - cf.Position).Magnitude
    
    if dist < 5 then 
        isTweening = false 
        if currentTween then currentTween:Cancel() end 
        return 
    end
    
    isTweening = true
    if currentTween then currentTween:Cancel() end
    
    -- BYPASS DE GRAVIDADE E COLISÃO
    UtilsModule.Float(true)
    
    -- VELOCIDADE ADAPTATIVA (MAIS REALISTA)
    local tweenSpeed = speed or _G.Settings.TweenSpeed or 350
    if dist < 300 then tweenSpeed = tweenSpeed * 0.7 end -- Desacelera na chegada para precisão
    
    -- JITTER BYPASS (MICRO-VARIAÇÕES PARA ENGANAR ANTICHEAT)
    local jitter = Vector3.new(math.random(-10, 10)/100, 0, math.random(-10, 10)/100)
    local targetCF = cf * CFrame.new(jitter)

    -- TWEEN COM CURVA DE ACELERAÇÃO (SINE) EM VEZ DE LINEAR
    currentTween = TweenService:Create(root, TweenInfo.new(dist/tweenSpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = targetCF})
    currentTween:Play()
    
    currentTween.Completed:Connect(function() 
        isTweening = false 
    end)
    
    -- DESATIVAR COLISÃO DE FORMA AGRESSIVA
    pcall(function()
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end)
end

function UtilsModule.Float(enabled)
    pcall(function()
        local root = LocalPlayer.Character.HumanoidRootPart
        local hum = LocalPlayer.Character.Humanoid
        if enabled then
            if not root:FindFirstChild("MakitoFloat") then
                local bv = Instance.new("BodyVelocity", root)
                bv.Name = "MakitoFloat"
                bv.Velocity = Vector3.new(0, 0, 0)
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            end
            hum.PlatformStand = true
        else
            if root:FindFirstChild("MakitoFloat") then root.MakitoFloat:Destroy() end
            hum.PlatformStand = false
        end
    end)
end

-- SISTEMA DE PROTEÇÃO ANTI-BAN (PACKET THROTTLING)
local lastRemoteCall = 0
function UtilsModule.SafeRemote(remoteName, ...)
    local now = tick()
    if now - lastRemoteCall < 0.1 then -- Limite de 10 chamadas por segundo
        task.wait(0.1 - (now - lastRemoteCall))
    end
    lastRemoteCall = tick()
    
    pcall(function(...)
        local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if remote then
            remote:InvokeServer(remoteName, ...)
        end
    end, ...)
end

return UtilsModule
