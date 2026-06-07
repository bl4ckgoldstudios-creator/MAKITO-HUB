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

-- WEBHOOK SYSTEM
function UtilsModule.SendWebhook(url, title, message, color)
    if not url or url == "" or url == "None" then return end
    
    local data = {
        ["embeds"] = {{
            ["title"] = title or "MAKITO HUB LOG",
            ["description"] = message or "",
            ["color"] = color or 65280, -- Verde padrão
            ["footer"] = {["text"] = "Makito Hub - " .. os.date("%X")}
        }}
    }
    
    pcall(function()
        (syn and syn.request or http_request or request)({
            Url = url,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)
end

-- ENEMY FINDER
function UtilsModule.GetNearestEnemy(name)
    local nearest = nil
    local minDist = math.huge
    local enemies = workspace:FindFirstChild("Enemies") or workspace
    
    for _, v in ipairs(enemies:GetChildren()) do
        if v.Name == name and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = v
            end
        end
    end
    return nearest
end

function UtilsModule.GetNearestEnemyAny()
    local nearest = nil
    local minDist = math.huge
    local enemies = workspace:FindFirstChild("Enemies") or workspace
    
    for _, v in ipairs(enemies:GetChildren()) do
        if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = v
            end
        end
    end
    return nearest
end

-- ESP SYSTEM (PLAYER, CHEST, FRUIT)
local ESPObjects = {}

function UtilsModule.CreateESP(obj, text, color)
    if not obj or ESPObjects[obj] then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "MakitoESP"
    billboard.Adornee = obj
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = CoreGui
    
    local label = Instance.new("TextLabel", billboard)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = text
    label.TextColor3 = color
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    
    if _G.Settings.BoxESP then
        local box = Instance.new("BoxHandleAdornment", CoreGui)
        box.Name = "MakitoBox"
        box.Adornee = obj
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Transparency = 0.5
        box.Color3 = color
        box.Size = obj.Size
    end
    
    ESPObjects[obj] = billboard
end

function UtilsModule.ClearESP()
    for _, v in pairs(ESPObjects) do v:Destroy() end
    ESPObjects = {}
end

-- SERVER UTILITIES (INSPIRADO NO ALCHEMY)
function UtilsModule.ServerHop()
    local Http = game:GetService("HttpService")
    local TPS = game:GetService("TeleportService")
    local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
    
    local function ListServers(cursor)
        local raw = game:HttpGet(Api .. (cursor and "&cursor=" .. cursor or ""))
        return Http:JSONDecode(raw)
    end
    
    local nextCursor = nil
    for i = 1, 10 do
        local servers = ListServers(nextCursor)
        for _, server in ipairs(servers.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TPS:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                return
            end
        end
        if servers.nextPageCursor then
            nextCursor = servers.nextPageCursor
        else
            break
        end
    end
end

function UtilsModule.Rejoin()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end

-- WORLD VISUALS
function UtilsModule.SetFullBright(enabled)
    if enabled then
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 14
        game:GetService("Lighting").FogEnd = 100000
        game:GetService("Lighting").GlobalShadows = false
    else
        game:GetService("Lighting").Brightness = 1
        game:GetService("Lighting").GlobalShadows = true
    end
end

function UtilsModule.RemoveFog(enabled)
    if enabled then
        game:GetService("Lighting").FogEnd = 100000
        for _, v in pairs(game:GetService("Lighting"):GetDescendants()) do
            if v:IsA("Atmosphere") then v:Destroy() end
        end
    end
end

-- PROTEÇÕES E MISC (ESTILO ALCHEMY)
local StreamerConn = nil
function UtilsModule.SetStreamerMode(enabled)
    if enabled then
        StreamerConn = RunService.RenderStepped:Connect(function()
            pcall(function()
                local mainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
                if mainGui then
                    if mainGui:FindFirstChild("Data") then mainGui.Data.Visible = false end
                    if mainGui:FindFirstChild("Bounty") then mainGui.Bounty.Visible = false end
                end
                -- Esconde o nome no Watermark se necessário
            end)
        end)
    else
        if StreamerConn then StreamerConn:Disconnect() StreamerConn = nil end
        pcall(function()
            local mainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
            if mainGui then
                if mainGui:FindFirstChild("Data") then mainGui.Data.Visible = true end
                if mainGui:FindFirstChild("Bounty") then mainGui.Bounty.Visible = true end
            end
        end)
    end
end

local OverlayGui = nil
function UtilsModule.SetScreenOverlay(type) -- "None", "Black", "White"
    if OverlayGui then OverlayGui:Destroy() OverlayGui = nil end
    if type == "None" then return end
    
    OverlayGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    OverlayGui.Name = "MakitoOverlay"
    OverlayGui.DisplayOrder = 9999
    
    local frame = Instance.new("Frame", OverlayGui)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = type == "Black" and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
    frame.BorderSizePixel = 0
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 50)
    label.Position = UDim2.new(0, 0, 0.5, -25)
    label.BackgroundTransparency = 1
    label.Text = "MAKITO HUB - " .. type:upper() .. " SCREEN MODE ACTIVE\n(Pressione Shift+F1 para alternar GUI)"
    label.TextColor3 = type == "Black" and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 20
end

function UtilsModule.AntiAFK()
    local virtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        virtualUser:CaptureController()
        virtualUser:ClickButton2(Vector2.new())
    end)
end

function UtilsModule.ChatSpam(message, delay)
    task.spawn(function()
        while _G.Settings.ChatSpam do
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
            task.wait(delay or 5)
        end
    end)
end

-- MODERATOR CHECK (SAFE EXIT)
function UtilsModule.CheckModerator()
    for _, v in ipairs(Players:GetPlayers()) do
        if v:GetRankInGroup(2769967) >= 100 then -- Grupo oficial Blox Fruits
            LocalPlayer:Kick("MODERADOR DETECTADO: " .. v.Name)
        end
    end
end

-- FORMATTING UTILS
function UtilsModule.FormatNumber(val)
    local formatted = tostring(val)
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')
        if (k == 0) then break end
    end
    return formatted
end

return UtilsModule
