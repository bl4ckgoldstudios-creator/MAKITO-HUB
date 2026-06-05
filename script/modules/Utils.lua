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
            Title = "MAKITO HUB",
            Text = text,
            Duration = duration or 5
        })
    end)
    print("[MAKITO HUB]: " .. text)
end

function UtilsModule.TweenTo(cf, speed)
    if not _G.MakitoHubRunning or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    local dist = (root.Position - cf.Position).Magnitude
    
    -- ANTICHEAT BYPASS: Magnitude Check Prevention
    -- Se a distância for muito grande, fazemos o tween em "pedaços" ou saltos seguros
    if dist > 2000 then
        -- Opcional: Implementar Safe Teleport (Server Hop ou espera)
    end

    if dist < 5 then 
        isTweening = false 
        if currentTween then currentTween:Cancel() end 
        return 
    end
    
    isTweening = true
    if currentTween then currentTween:Cancel() end
    
    -- Force Float & NoClip
    if not root:FindFirstChild("MakitoFloat") then
        local bv = Instance.new("BodyVelocity", root)
        bv.Name = "MakitoFloat"
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    end
    
    -- Dinamic Speed based on distance (Bypass Speed Anticheat)
    local tweenSpeed = speed or _G.Settings.TweenSpeed or 350
    if dist < 250 then tweenSpeed = tweenSpeed * 0.8 end -- Slower when close for precision

    -- BEZIER / JITTER BYPASS: Adiciona uma pequena variação para não ser uma linha reta perfeita
    local targetCF = cf * CFrame.new(math.random(-1,1)/10, 0, math.random(-1,1)/10)

    currentTween = TweenService:Create(root, TweenInfo.new(dist/tweenSpeed, Enum.EasingStyle.Linear), {CFrame = targetCF})
    currentTween:Play()
    
    currentTween.Completed:Connect(function() 
        isTweening = false 
        -- Restore Collision safely
    end)
    
    pcall(function()
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end)
end

function UtilsModule.CheckModerator()
    local Moderators = {1, 156711358} -- Exemplo de IDs conhecidos
    for _, player in ipairs(Players:GetPlayers()) do
        if player:GetRankInGroup(2442) >= 100 or table.find(Moderators, player.UserId) then
            if _G.Settings.AutoModeratorShutdown then
                LocalPlayer:Kick("SEGURANÇA: MODERADOR " .. player.Name .. " DETECTADO.")
            else
                UtilsModule.Notify("MODERADOR DETECTADO! PULANDO SERVIDOR...", 10)
                UtilsModule.ServerHop()
            end
        end
    end
end

function UtilsModule.ServerHop()
    local PlaceID = game.PlaceId
    local JobID = game.JobId
    local Api = "https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Desc&limit=100"
    local function ListServers(cursor)
        local Raw = game:HttpGet(Api .. (cursor and "&cursor=" .. cursor or ""))
        return HttpService:JSONDecode(Raw)
    end
    
    local Servers = ListServers()
    for _, server in ipairs(Servers.data) do
        if server.playing < server.maxPlayers and server.id ~= JobID then
            TeleportService:TeleportToPlaceInstance(PlaceID, server.id)
            break
        end
    end
end

function UtilsModule.GetNearestEnemy(EnemyName)
    local Nearest, MaxDist = nil, math.huge
    local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
    local searchName = EnemyName and EnemyName:lower() or nil

    pcall(function()
        for _, v in ipairs(enemiesFolder:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                local vName = v.Name:lower()
                if not searchName or vName == searchName or vName:find(searchName) then
                    local dist = (v.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if dist < MaxDist then
                        MaxDist = dist
                        Nearest = v
                    end
                end
            end
        end
    end)

    if not Nearest then
        pcall(function()
            for _, v in ipairs(workspace:GetChildren()) do
                if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                    local vName = v.Name:lower()
                    if not searchName or vName == searchName or vName:find(searchName) then
                        local dist = (v.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if dist < MaxDist then
                            MaxDist = dist
                            Nearest = v
                        end
                    end
                end
            end
        end)
    end
    return Nearest
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
            if not root:FindFirstChild("MakitoGyro") then
                local bg = Instance.new("BodyGyro", root)
                bg.Name = "MakitoGyro"
                bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                bg.P = 30000
                bg.CFrame = root.CFrame
            end
            hum.PlatformStand = true
            if hum:GetState() ~= Enum.HumanoidStateType.Physics then
                hum:ChangeState(Enum.HumanoidStateType.Physics)
            end
            root.Anchored = false
        else
            if root:FindFirstChild("MakitoFloat") then root.MakitoFloat:Destroy() end
            if root:FindFirstChild("MakitoGyro") then root.MakitoGyro:Destroy() end
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            root.Anchored = false
        end
    end)
end

function UtilsModule.GetRates(StartTime, StartLevel, StartMoney)
    local elapsed = os.time() - StartTime
    if elapsed <= 0 then return 0, 0 end
    
    local levelsGained = LocalPlayer.Data.Level.Value - StartLevel
    local moneyGained = LocalPlayer.Data.Beli.Value - StartMoney
    
    local levelsPerHour = math.floor((levelsGained / elapsed) * 3600)
    local moneyPerHour = math.floor((moneyGained / elapsed) * 3600)
    
    return levelsPerHour, moneyPerHour
end

-- SAFE REMOTE CALL: Evita detecção de spam de pacotes e lida com renomeações
local CachedRemote = nil
function UtilsModule.SafeRemote(remoteName, ...)
    pcall(function(...)
        if not CachedRemote then
            -- Procura pelo remoto principal (pode ser renomeado em 2026)
            local potentialRemotes = {
                ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_"),
                ReplicatedStorage:FindFirstChild("CommF_"),
                ReplicatedStorage:FindFirstChild("RemoteEvent"),
                ReplicatedStorage:FindFirstChild("MainRemote")
            }
            for _, r in ipairs(potentialRemotes) do
                if r and (r:IsA("RemoteFunction") or r:IsA("RemoteEvent")) then
                    CachedRemote = r
                    break
                end
            end
        end

        if CachedRemote then
            if CachedRemote:IsA("RemoteFunction") then
                CachedRemote:InvokeServer(remoteName, ...)
            else
                CachedRemote:FireServer(remoteName, ...)
            end
        end
    end, ...)
end

-- PACKET SIMULATOR: Simula o tráfego de um jogador real
function UtilsModule.SimulatePlayer()
    task.spawn(function()
        while _G.MakitoHubRunning do
            task.wait(math.random(10, 30))
            pcall(function()
                -- Simula pulo ou movimento aleatório ocasional
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.Jump = true
                end
            end)
        end
    end)
end

-- 2026 DEBUG SYSTEM: Logs para depuração no executor
function UtilsModule.Log(msg, level)
    local prefix = "[MAKITO V7]"
    local colors = {info = "white", warn = "yellow", err = "red"}
    local color = colors[level or "info"]
    
    -- Se o executor suportar rconsolprint ou similar
    if rconsoleprint then
        rconsoleprint(prefix .. " " .. msg .. "\n", color)
    else
        print(prefix .. " " .. msg)
    end
end

-- HEARTBEAT MONITOR
task.spawn(function()
    while _G.MakitoHubRunning do
        task.wait(60)
        UtilsModule.Log("System Heartbeat: OK | Memory: " .. math.floor(collectgarbage("count")) .. "KB")
    end
end)

-- CHARACTER MODS
function UtilsModule.WalkOnWater(enabled)
    local waterCheck = workspace:FindFirstChild("WaterWalkingPart")
    if enabled then
        if not waterCheck then
            local part = Instance.new("Part", workspace)
            part.Name = "WaterWalkingPart"
            part.Size = Vector3.new(5000, 2, 5000)
            part.Transparency = 1
            part.Anchored = true
            part.CanCollide = true
            
            task.spawn(function()
                while _G.MakitoHubRunning and _G.Settings.WalkOnWater do
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        part.Position = Vector3.new(LocalPlayer.Character.HumanoidRootPart.Position.X, -1, LocalPlayer.Character.HumanoidRootPart.Position.Z)
                    end
                    task.wait()
                end
                part:Destroy()
            end)
        end
    else
        if waterCheck then waterCheck:Destroy() end
    end
end

function UtilsModule.FPSBooster(enabled)
    if enabled then
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("Texture") or v:IsA("Decal") then
                v.Transparency = 1
            elseif v:IsA("BasePart") and v.Material ~= Enum.Material.SmoothPlastic then
                v.Material = Enum.Material.SmoothPlastic
            end
        end
        game:GetService("Lighting").GlobalShadows = false
        settings().Rendering.QualityLevel = 1
    end
end

return UtilsModule
