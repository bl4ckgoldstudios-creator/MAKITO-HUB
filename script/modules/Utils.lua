local UtilsModule = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

local isTweening = false
local currentTween = nil
local ESPObjects = {}

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
function UtilsModule.SetScreenOverlay(type)
    if OverlayGui then OverlayGui:Destroy() OverlayGui = nil end
    if type == "None" then return end
    
    OverlayGui = Instance.new("ScreenGui", CoreGui)
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
        while _G.Settings and _G.Settings.ChatSpam do
            local events = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            local sayMsg = events and events:FindFirstChild("SayMessageRequest")
            if sayMsg then
                sayMsg:FireServer(message, "All")
            end
            task.wait(delay or 5)
        end
    end)
end

-- MOVIMENTAÇÃO GOD-MODE (INFINITE SPEED & NO-CLIP)
function UtilsModule.Float(enabled)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local float = root:FindFirstChild("MakitoFloat")
    if enabled then
        if not float then
            float = Instance.new("BodyVelocity")
            float.Name = "MakitoFloat"
            float.Velocity = Vector3.new(0, 0, 0)
            float.MaxForce = Vector3.new(0, math.huge, 0)
            float.Parent = root
        end
    else
        if float then float:Destroy() end
    end
end

local NoClipConn = nil
function UtilsModule.SetNoClip(enabled)
    if enabled then
        if NoClipConn then return end
        NoClipConn = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide then
                        v.CanCollide = false
                    end
                end
            end
        end)
    else
        if NoClipConn then NoClipConn:Disconnect() NoClipConn = nil end
    end
end

function UtilsModule.TweenTo(cf, speed)
    if not _G.MakitoHubRunning or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    local dist = (root.Position - cf.Position).Magnitude
    
    if dist < 5 then 
        isTweening = false 
        if currentTween then currentTween:Cancel() end 
        UtilsModule.Float(false)
        UtilsModule.SetNoClip(false)
        return 
    end
    
    isTweening = true
    if currentTween then currentTween:Cancel() end
    
    UtilsModule.Float(true)
    UtilsModule.SetNoClip(true)
    
    local tweenSpeed = speed or (_G.Settings and _G.Settings.TweenSpeed) or 350
    if dist < 150 then tweenSpeed = tweenSpeed * 0.5 end 

    local tweenInfo = TweenInfo.new(dist/tweenSpeed, Enum.EasingStyle.Linear)
    currentTween = TweenService:Create(root, tweenInfo, {CFrame = cf})
    currentTween:Play()
    
    currentTween.Completed:Connect(function(state) 
        if state == Enum.PlaybackState.Completed then
            isTweening = false 
            UtilsModule.Float(false)
            UtilsModule.SetNoClip(false)
        end
    end)
end

-- SUPREME ANTI-STUCK V2
local lastPos = Vector3.new()
local stuckTicks = 0
task.spawn(function()
    while _G.MakitoHubRunning do
        task.wait(1)
        if isTweening and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local currentPos = LocalPlayer.Character.HumanoidRootPart.Position
            if (currentPos - lastPos).Magnitude < 2 then
                stuckTicks = stuckTicks + 1
                if stuckTicks >= 4 then
                    -- Tenta desatolar movendo pra cima ou pro lado
                    LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 100, 0)
                    stuckTicks = 0
                end
            else
                stuckTicks = 0
            end
            lastPos = currentPos
        end
    end
end)

-- SISTEMA DE PROTEÇÃO ANTI-BAN (PACKET THROTTLING)
local lastRemoteCall = 0
function UtilsModule.SafeRemote(remoteName, ...)
    local now = tick()
    if now - lastRemoteCall < 0.1 then
        task.wait(0.1 - (now - lastRemoteCall))
    end
    lastRemoteCall = tick()
    
    local args = {...}
    local success, result = pcall(function()
        local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if remote then
            return remote:InvokeServer(remoteName, unpack(args))
        end
    end)
    return success, result
end

-- ESP SYSTEM ELITE
function UtilsModule.CreateESP(obj, text, color, type)
    if not obj or ESPObjects[obj] then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "MakitoESP_" .. (type or "Generic")
    billboard.Adornee = obj
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = CoreGui
    
    local label = Instance.new("TextLabel", billboard)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = text
    label.TextColor3 = color
    label.Font = Enum.Font.GothamBold
    label.TextSize = (_G.Settings and _G.Settings.EspTextSize) or 13
    label.TextStrokeTransparency = 0.5
    
    task.spawn(function()
        while billboard and billboard.Parent do
            local dist = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and 
                         math.floor((LocalPlayer.Character.HumanoidRootPart.Position - obj.Position).Magnitude) or 0
            label.Text = string.format("%s [%dm]", text, dist)
            task.wait(0.5)
        end
    end)
    
    if _G.Settings and _G.Settings.BoxESP then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "MakitoBox"
        box.Adornee = obj
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Transparency = 0.6
        box.Color3 = color
        box.Size = obj:IsA("BasePart") and obj.Size or Vector3.new(4, 6, 4)
        box.Parent = CoreGui
        ESPObjects[obj .. "_box"] = box
    end

    if _G.Settings and (_G.Settings.LineESP or _G.Settings.EspTracer) then
        local line = Instance.new("LineHandleAdornment")
        line.Name = "MakitoLine"
        line.Adornee = workspace.CurrentCamera
        line.AlwaysOnTop = true
        line.ZIndex = 5
        line.Color3 = color
        line.Thickness = 2
        line.Length = 0
        line.Parent = CoreGui
        
        task.spawn(function()
            while line and line.Parent do
                pcall(function()
                    local cam = workspace.CurrentCamera
                    local startPos = cam.CFrame.Position + cam.CFrame.LookVector * 1
                    local endPos = obj.Position
                    line.CFrame = CFrame.new(startPos, endPos)
                    line.Length = (startPos - endPos).Magnitude
                end)
                task.wait()
            end
        end)
        ESPObjects[obj .. "_line"] = line
    end
    
    ESPObjects[obj] = billboard
end

function UtilsModule.ClearESP()
    for _, v in pairs(ESPObjects) do 
        pcall(function() v:Destroy() end)
    end
    ESPObjects = {}
end

function UtilsModule.GetDistanceTo(obj)
    if not obj then return math.huge end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return math.huge end
    local pos = obj:IsA("BasePart") and obj.Position or obj:IsA("Model") and obj:GetModelCFrame().Position or obj
    return (root.Position - pos).Magnitude
end

function UtilsModule.PassesESPFilter(name, dist)
    if not _G.Settings then return true end
    if dist > (_G.Settings.EspMaxDistance or 2500) then return false end
    if _G.Settings.EspFilterName and _G.Settings.EspFilterName ~= "" then
        local filters = _G.Settings.EspFilterName:lower():split(",")
        local found = false
        for _, f in ipairs(filters) do
            if name:lower():find(f:gsub("^%s*(.-)%s*$", "%1")) then
                found = true
                break
            end
        end
        return found
    end
    return true
end

function UtilsModule.ColorFromSettings(setting, default)
    if _G.Settings and _G.Settings[setting] then
        return _G.Settings[setting]
    end
    return default
end

function UtilsModule.ServerHop()
    local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
    local function ListServers(cursor)
        local raw = game:HttpGet(Api .. (cursor and "&cursor=" .. cursor or ""))
        return HttpService:JSONDecode(raw)
    end
    
    local nextCursor = nil
    for i = 1, 10 do
        local servers = ListServers(nextCursor)
        for _, server in ipairs(servers.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
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
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

function UtilsModule.SetFullBright(enabled)
    if enabled then
        game:GetService("Lighting").Ambient = Color3.new(1, 1, 1)
        game:GetService("Lighting").Brightness = 2
    else
        game:GetService("Lighting").Ambient = Color3.new(0, 0, 0)
        game:GetService("Lighting").Brightness = 1
    end
end

function UtilsModule.RemoveFog(enabled)
    if enabled then
        game:GetService("Lighting").FogEnd = 9e9
        for _, v in ipairs(game:GetService("Lighting"):GetChildren()) do
            if v:IsA("Atmosphere") then v.Density = 0 end
        end
    end
end

function UtilsModule.Notify(text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "MAKITO HUB",
            Text = text,
            Duration = duration or 5
        })
    end)
end

function UtilsModule.GetNearestEnemy(name)
    local nearest = nil
    local minDist = math.huge
    local enemies = workspace:FindFirstChild("Enemies") or workspace
    
    for _, v in ipairs(enemies:GetChildren()) do
        if v.Name:find(name) and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local dist = UtilsModule.GetDistanceTo(v.HumanoidRootPart)
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
            local dist = UtilsModule.GetDistanceTo(v.HumanoidRootPart)
            if dist < minDist then
                minDist = dist
                nearest = v
            end
        end
    end
    return nearest
end

function UtilsModule.CheckModerator()
    for _, v in ipairs(Players:GetPlayers()) do
        if v:GetRankInGroup(4442272) >= 100 then
            LocalPlayer:Kick("MODERADOR DETECTADO: " .. v.Name .. "\nO MAKITO HUB te protegeu de um possivel banimento.")
        end
    end
end

return UtilsModule
