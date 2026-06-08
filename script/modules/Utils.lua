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
local InstanceCache = {
    Enemies = {},
    NPCs = {},
    Items = {},
    LastUpdate = 0
}

-- SISTEMA DE ESP MASTER (UNIVERSAL)
function UtilsModule.CreateESP(obj, name, color, type)
    if ESPObjects[obj] then return end
    
    local folder = CoreGui:FindFirstChild("MakitoESP") or Instance.new("Folder", CoreGui)
    folder.Name = "MakitoESP"
    
    -- CORES NEON ULTRA-CHAMATIVAS (ESTILO GAMER)
    local neonColor = color
    if type == "Player" then neonColor = Color3.fromRGB(0, 255, 255) -- Cyan Neon
    elseif type == "NPC" then neonColor = Color3.fromRGB(255, 0, 255) -- Magenta Neon
    elseif type == "Chest" then neonColor = Color3.fromRGB(255, 255, 0) -- Yellow Neon
    elseif type == "Fruit" then neonColor = Color3.fromRGB(0, 255, 0) -- Green Neon
    end

    local bg = Instance.new("BillboardGui")
    bg.Name = "ESP"
    bg.Adornee = obj
    bg.AlwaysOnTop = true
    bg.Size = UDim2.new(0, 120, 0, 40) -- Maior para visibilidade
    bg.StudsOffset = Vector3.new(0, 4, 0)
    bg.Parent = folder
    
    local label = Instance.new("TextLabel", bg)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = name or obj.Name
    label.TextColor3 = neonColor
    label.TextStrokeTransparency = 0.2
    label.TextStrokeColor3 = Color3.new(0,0,0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    
    local distLabel = Instance.new("TextLabel", bg)
    distLabel.BackgroundTransparency = 1
    distLabel.Size = UDim2.new(1, 0, 0, 15)
    distLabel.Position = UDim2.new(0, 0, 0, 18)
    distLabel.TextColor3 = Color3.new(1, 1, 1)
    distLabel.TextStrokeTransparency = 0.5
    distLabel.Font = Enum.Font.GothamBold
    distLabel.TextSize = 11
    
    -- BOX ESP AGRESSIVO
    local box = nil
    if _G.Settings.BoxESP then
        box = Instance.new("SelectionBox")
        box.Name = "Box"
        box.Adornee = obj
        box.Color3 = neonColor
        box.LineThickness = 0.1 -- Mais grosso
        box.Transparency = 0.3
        box.SurfaceTransparency = 0.8
        box.SurfaceColor3 = neonColor
        box.Parent = obj
    end

    ESPObjects[obj] = {Gui = bg, Label = label, Dist = distLabel, Box = box, Type = type}
    
    obj.AncestryChanged:Connect(function()
        if not obj:IsDescendantOf(workspace) then
            if bg then bg:Destroy() end
            if box then box:Destroy() end
            ESPObjects[obj] = nil
        end
    end)
end

function UtilsModule.UpdateESP()
    task.spawn(function()
        while _G.MakitoHubRunning do
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            
            for obj, data in pairs(ESPObjects) do
                if obj and obj.Parent and root then
                    local targetRoot = obj:IsA("Model") and (obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart) or obj:IsA("BasePart") and obj
                    if targetRoot then
                        local dist = math.floor((root.Position - targetRoot.Position).Magnitude)
                        data.Dist.Text = "[" .. dist .. "m]"
                        
                        -- Toggle Visibility based on Settings
                        local visible = false
                        if data.Type == "Player" and _G.Settings.EspPlayers then visible = true
                        elseif data.Type == "NPC" and _G.Settings.NpcESP then visible = true
                        elseif data.Type == "Chest" and _G.Settings.EspChests then visible = true
                        elseif data.Type == "Fruit" and _G.Settings.EspFruits then visible = true
                        end
                        
                        data.Gui.Enabled = visible
                        if data.Box then data.Box.Visible = visible and _G.Settings.BoxESP end
                    else
                        data.Gui:Destroy()
                        if data.Box then data.Box:Destroy() end
                        ESPObjects[obj] = nil
                    end
                else
                    if data.Gui then data.Gui:Destroy() end
                    if data.Box then data.Box:Destroy() end
                    ESPObjects[obj] = nil
                end
            end
            task.wait(0.1)
        end
    end)
end

-- SISTEMA DE CACHE INTELIGENTE (EVITA LAG DE BUSCA)
function UtilsModule.UpdateInstanceCache()
    -- Cache de Inimigos Vivos (Atualiza mais rápido: 0.1s)
    if tick() - (InstanceCache.LastEnemyUpdate or 0) > 0.1 then
        InstanceCache.LastEnemyUpdate = tick()
        local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
        local newEnemies = {}
        for _, v in ipairs(enemiesFolder:GetChildren()) do
            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                newEnemies[v.Name] = v
                table.insert(newEnemies, v)
                
                -- Auto-ESP for NPCs/Enemies
                if _G.Settings.NpcESP then
                    UtilsModule.CreateESP(v, v.Name, Color3.fromRGB(255, 80, 80), "NPC")
                end
            end
        end
        InstanceCache.Enemies = newEnemies
    end
    
    -- Cache de NPCs (Atualiza mais devagar: 5s)
    if tick() - (InstanceCache.LastNPCUpdate or 0) > 5 then
        InstanceCache.LastNPCUpdate = tick()
        local npcsFolder = workspace:FindFirstChild("NPCs") or workspace
        local newNPCs = {}
        for _, v in ipairs(npcsFolder:GetChildren()) do
            if v:IsA("Model") or v:FindFirstChild("HumanoidRootPart") then
                newNPCs[v.Name] = v
                
                if _G.Settings.NpcESP then
                    UtilsModule.CreateESP(v, v.Name, Color3.fromRGB(255, 200, 200), "NPC")
                end
            end
        end
        InstanceCache.NPCs = newNPCs
    end

    -- Discovery de Players
    if _G.Settings.EspPlayers then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                UtilsModule.CreateESP(p.Character.HumanoidRootPart, p.Name, Color3.fromRGB(100, 200, 255), "Player")
            end
        end
    end

    -- Discovery de Frutas e Baús
    if _G.Settings.EspFruits or _G.Settings.EspChests then
        for _, v in ipairs(workspace:GetChildren()) do
            if _G.Settings.EspFruits and (v.Name:find("Fruit") or v:FindFirstChild("Handle")) and v:IsA("Tool") then
                UtilsModule.CreateESP(v, v.Name, Color3.fromRGB(255, 60, 60), "Fruit")
            elseif _G.Settings.EspChests and v.Name:find("Chest") then
                UtilsModule.CreateESP(v, v.Name, Color3.fromRGB(255, 200, 0), "Chest")
            end
        end
    end
end

function UtilsModule.GetInstanceCache()
    return InstanceCache
end

-- SEGURANÇA E BYPASS
function UtilsModule.CheckModerator()
    for _, p in ipairs(Players:GetPlayers()) do
        if p:GetRankInGroup(2830050) > 0 or p:FindFirstChild("Moderator") then
            if _G.Settings.AutoKickMod then
                LocalPlayer:Kick("🛡️ MAKITO HUB: Moderador [" .. p.Name .. "] detectado no servidor.")
            elseif _G.Settings.AutoModeratorHop then
                UtilsModule.ServerHop()
            end
        end
    end
end

function UtilsModule.SecurityBypass()
    -- Bypass básico de teleporte e velocidade
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            -- Remove detecção de queda e velocidade excessiva localmente
            if char:FindFirstChild("Humanoid") then
                char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            end
        end
    end)
end

function UtilsModule.UpdateGlobalStatus()
    if not _G.MakitoStatus then return end
    
    local level = LocalPlayer.Data.Level.Value
    local fragments = LocalPlayer.Data.Fragments.Value
    local beli = LocalPlayer.Data.Beli.Value
    
    _G.MakitoStatus.Text = string.format("Lvl: %d | Beli: %d | Frag: %d", level, beli, fragments)
end

function UtilsModule.AutoBuildStats()
    if not _G.Settings.AutoStats or not _G.Settings.SelectedStat then return end
    
    local statName = _G.Settings.SelectedStat
    if statName == "Demon Fruit" then statName = "Blox Fruit" end
    
    local points = LocalPlayer.Data.StatsPoints.Value
    if points > 0 then
        _G.Utils.SafeRemote("AddPoint", statName, points)
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
    local gyro = root:FindFirstChild("MakitoGyro")
    
    if enabled then
        if not float then
            float = Instance.new("BodyVelocity")
            float.Name = "MakitoFloat"
            float.Velocity = Vector3.new(0, 0, 0)
            float.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            float.Parent = root
        end
        if not gyro then
            gyro = Instance.new("BodyGyro")
            gyro.Name = "MakitoGyro"
            gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            gyro.CFrame = root.CFrame
            gyro.Parent = root
        end
    else
        if float then float:Destroy() end
        if gyro then gyro:Destroy() end
    end
end

local NoClipConn = nil
local CharacterParts = {}
function UtilsModule.SetNoClip(enabled)
    if enabled then
        if NoClipConn then return end
        
        -- Cache de partes do personagem para evitar GetDescendants em loop
        local function UpdateCache()
            CharacterParts = {}
            if LocalPlayer.Character then
                for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        table.insert(CharacterParts, v)
                    end
                end
            end
        end
        
        UpdateCache()
        local charConn = LocalPlayer.CharacterAdded:Connect(UpdateCache)

        NoClipConn = RunService.Stepped:Connect(function()
            if not _G.Settings or not (_G.Settings.AutoFarm or _G.Settings.NoClip) then
                if NoClipConn then NoClipConn:Disconnect() NoClipConn = nil end
                if charConn then charConn:Disconnect() end
                return
            end
            
            for _, v in ipairs(CharacterParts) do
                if v and v.Parent then
                    v.CanCollide = false
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

function UtilsModule.DevilFruitNotifier()
    if not _G.Settings.DevilFruitNotifier then return end
    
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Tool") and (v.Name:find("Fruit") or v:FindFirstChild("Handle")) then
            local name = v.Name
            if not _G.NotifiedFruits then _G.NotifiedFruits = {} end
            if not _G.NotifiedFruits[v] then
                _G.NotifiedFruits[v] = true
                -- Notificação simples via console e mensagem na tela
                warn("🍎 [MAKITO HUB] FRUTA DETECTADA: " .. name)
                if game:GetService("StarterGui") then
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "🍎 Fruta Detectada!",
                        Text = "Uma " .. name .. " apareceu no mapa!",
                        Duration = 10
                    })
                end
            end
        end
    end
end

function UtilsModule.AutoHakiShop()
    if not _G.Settings.AutoBuyHaki then return end
    -- Compra Haki se o player estiver perto do NPC e tiver dinheiro
    local npc = workspace.NPCs:FindFirstChild("Ability Teacher")
    if npc and (LocalPlayer.Character.HumanoidRootPart.Position - npc.HumanoidRootPart.Position).Magnitude < 20 then
        UtilsModule.SafeRemote("BuyHaki", "Buso")
        UtilsModule.SafeRemote("BuyHaki", "Soru")
        UtilsModule.SafeRemote("BuyHaki", "Geppo")
    end
end

function UtilsModule.ServerHop()
    local Http = game:GetService("HttpService")
    local TPS = game:GetService("TeleportService")
    local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
    local _Servers = Http:JSONDecode(game:HttpGet(Api))
    local _Next = _Servers.nextPageCursor
    for i, v in pairs(_Servers.data) do
        if v.playing < v.maxPlayers and v.id ~= game.JobId then
            TPS:TeleportToPlaceInstance(game.PlaceId, v.id, LocalPlayer)
        end
    end
end

function UtilsModule.Rejoin()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end

function UtilsModule.AutomationLogic()
    -- Lógica de automação geral (Haki, Ken, etc)
    if _G.Settings.AutoHaki then
        local char = LocalPlayer.Character
        if char and not char:FindFirstChild("HasBuso") then
            UtilsModule.SafeRemote("Buso")
        end
    end
end

-- UTILS - FUNÇÕES AUXILIARES E PERFORMANCE
function UtilsModule.FormatNumber(val)
    local formatted = tostring(val)
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k == 0) then break end
    end
    return formatted
end

function UtilsModule.GetDistanceTo(obj)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not obj then return math.huge end
    
    local pos = obj:IsA("BasePart") and obj.Position or obj:IsA("Model") and (obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart) and (obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart).Position or typeof(obj) == "Vector3" and obj or typeof(obj) == "CFrame" and obj.Position
    if not pos then return math.huge end
    
    return (root.Position - pos).Magnitude
end

function UtilsModule.Notify(text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "MAKITO HUB",
            Text = text,
            Duration = duration or 5,
            Icon = "rbxassetid://10747383861"
        })
    end)
end

function UtilsModule.ExtremePerformance()
    if not _G.Settings.ExtremePerformance then return end
    
    -- Redução agressiva de renderização
    settings().Rendering.QualityLevel = 1
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        elseif v:IsA("Explosion") then
            v.Visible = false
        end
    end
end

function UtilsModule.LogInventory()
    local inventory = {}
    for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if v:IsA("Tool") then table.insert(inventory, v.Name) end
    end
    print("📦 [MAKITO] Inventário Atual: " .. table.concat(inventory, ", "))
end

function UtilsModule.HasItem(itemName)
    if LocalPlayer.Backpack:FindFirstChild(itemName) then return true end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(itemName) then return true end
    
    -- Verifica no Data (Blox Fruits específico)
    local inventory = LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Inventory")
    if inventory and inventory:FindFirstChild(itemName) then return true end
    
    return false
end

function UtilsModule.GetMaterialCount(materialName)
    local data = LocalPlayer:FindFirstChild("Data")
    if data then
        local mat = data:FindFirstChild(materialName)
        if mat then return mat.Value end
        
        -- Alguns materiais ficam dentro de pastas específicas
        local inventory = data:FindFirstChild("Inventory")
        if inventory and inventory:FindFirstChild(materialName) then
            return inventory[materialName].Value
        end
    end
    return 0
end

function UtilsModule.AdvancedHop()
    UtilsModule.Notify("Troca de servidor avançada iniciada...", 5)
    UtilsModule.ServerHop()
end

function UtilsModule.AutoChestLogic()
    if not _G.Settings.AutoChest then return end
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Name:find("Chest") and v:IsA("BasePart") then
            local dist = UtilsModule.GetDistanceTo(v)
            if dist < 500 then
                UtilsModule.TweenTo(v.CFrame)
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v, 0)
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v, 1)
                task.wait(0.2)
            end
        end
    end
end

function UtilsModule.ClearESP()
    for obj, data in pairs(ESPObjects) do
        if data.Gui then data.Gui:Destroy() end
        if data.Box then data.Box:Destroy() end
    end
    ESPObjects = {}
end

function UtilsModule.PassesESPFilter(name, distance)
    if _G.Settings.EspMaxDistance and distance > _G.Settings.EspMaxDistance then return false end
    if _G.Settings.EspFilterName and _G.Settings.EspFilterName ~= "" then
        if not name:lower():find(_G.Settings.EspFilterName:lower()) then return false end
    end
    return true
end

function UtilsModule.ColorFromSettings(settingName, defaultColor)
    if _G.Settings[settingName] then
        local c = _G.Settings[settingName]
        if typeof(c) == "Color3" then return c end
        if typeof(c) == "table" and c.R and c.G and c.B then
            return Color3.new(c.R, c.G, c.B)
        end
    end
    return defaultColor
end

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

-- ESP SYSTEM ELITE (CENTRALIZADO)
local ESPLoopActive = false
function UtilsModule.StartESPLoop()
    if ESPLoopActive then return end
    ESPLoopActive = true
    
    task.spawn(function()
        while ESPLoopActive do
            for id, container in pairs(ESPObjects) do
                local obj = container.Object
                local label = container.Label
                local text = container.OriginalText
                
                if obj and obj.Parent and label then
                    local dist = UtilsModule.GetDistanceTo(obj)
                    label.Text = string.format("%s [%dm]", text, math.floor(dist))
                else
                    UtilsModule.RemoveESPById(id)
                end
            end
            task.wait(0.5)
        end
    end)
end

function UtilsModule.CreateESP(obj, text, color, type)
    if not obj or not obj.Parent then return end
    
    local id = obj:GetDebugId()
    if ESPObjects[id] then 
        -- Apenas atualiza a cor se já existir
        if ESPObjects[id].Label then ESPObjects[id].Label.TextColor3 = color end
        return 
    end
    
    UtilsModule.StartESPLoop()
    
    local container = { Object = obj, OriginalText = text }
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "MakitoESP_" .. id
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
    
    container.Billboard = billboard
    container.Label = label

    if _G.Settings and _G.Settings.BoxESP then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "MakitoBox_" .. id
        box.Adornee = obj
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Transparency = 0.6
        box.Color3 = color
        box.Size = obj:IsA("BasePart") and obj.Size or Vector3.new(4, 6, 4)
        box.Parent = CoreGui
        container.Box = box
    end

    if _G.Settings and _G.Settings.LineESP then
        local line = Instance.new("LineHandleAdornment")
        line.Name = "MakitoLine_" .. id
        line.Adornee = workspace.CurrentCamera
        line.AlwaysOnTop = true
        line.ZIndex = 5
        line.Color3 = color
        line.Thickness = 2
        line.Length = 0
        line.Parent = CoreGui
        
        local conn = RunService.RenderStepped:Connect(function()
            if not line or not line.Parent or not obj or not obj.Parent then return end
            pcall(function()
                local cam = workspace.CurrentCamera
                local startPos = cam.CFrame.Position + cam.CFrame.LookVector * 1
                local endPos = obj.Position
                line.CFrame = CFrame.new(startPos, endPos)
                line.Length = (startPos - endPos).Magnitude
            end)
        end)
        container.Line = line
        container.LineConn = conn
    end

    ESPObjects[id] = container
end

function UtilsModule.RemoveESPById(id)
    local container = ESPObjects[id]
    if container then
        if container.Billboard then container.Billboard:Destroy() end
        if container.Box then container.Box:Destroy() end
        if container.Line then container.Line:Destroy() end
        if container.LineConn then container.LineConn:Disconnect() end
        ESPObjects[id] = nil
    end
end

function UtilsModule.ClearESP()
    for id, _ in pairs(ESPObjects) do 
        UtilsModule.RemoveESPById(id)
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
    UtilsModule.UpdateInstanceCache()
    local nearest = nil
    local minDist = math.huge
    
    for _, v in ipairs(InstanceCache.Enemies) do
        if v.Name:find(name) then
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
    UtilsModule.UpdateInstanceCache()
    local nearest = nil
    local minDist = math.huge
    
    for _, v in ipairs(InstanceCache.Enemies) do
        local dist = UtilsModule.GetDistanceTo(v.HumanoidRootPart)
        if dist < minDist then
            minDist = dist
            nearest = v
        end
    end
    return nearest
end

function UtilsModule.CheckModerator()
    for _, v in ipairs(Players:GetPlayers()) do
        if v:GetRankInGroup(4442272) >= 100 then
            if _G.Settings.AutoModeratorHop then
                UtilsModule.Notify("MODERADOR DETECTADO: " .. v.Name .. ". Trocando de servidor...", 10)
                UtilsModule.ServerHop()
            elseif _G.Settings.AutoModeratorShutdown then
                LocalPlayer:Kick("MODERADOR DETECTADO: " .. v.Name .. "\nO MAKITO HUB te protegeu de um possivel banimento.")
            else
                UtilsModule.Notify("⚠️ MODERADOR NO SERVIDOR: " .. v.Name, 5)
            end
        end
    end
end

-- AUTOMATION & BUFFS
function UtilsModule.AutomationLogic()
    if not _G.Settings then return end
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if hum then
        if _G.Settings.WalkSpeed and _G.Settings.WalkSpeed > 16 then
            hum.WalkSpeed = _G.Settings.WalkSpeed
        end
        if _G.Settings.JumpPower and _G.Settings.JumpPower > 50 then
            hum.JumpPower = _G.Settings.JumpPower
        end
    end

    -- AUTO BUFFS
    if _G.Settings.AutoHaki then
        if char and not char:FindFirstChild("HasBuso") then
            UtilsModule.SafeRemote("Buso")
        end
    end

    if _G.Settings.AutoKen then
        pcall(function()
            local ken = LocalPlayer.PlayerGui:FindFirstChild("Ken")
            if not ken or not ken.Visible then
                local vim = game:GetService("VirtualInputManager")
                vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.05)
                vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end
        end)
    end

    if _G.Settings.InfEnergy then
        LocalPlayer.Character:SetAttribute("Energy", 999999)
        LocalPlayer.Character:SetAttribute("MaxEnergy", 999999)
    end

    if _G.Settings.InfGeppo then
        LocalPlayer.Character:SetAttribute("JumpCount", 0)
    end

    if _G.Settings.WalkOnWater then
        pcall(function()
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local ray = Ray.new(root.Position, Vector3.new(0, -10, 0))
                local part, pos = workspace:FindPartOnRayWithIgnoreList(ray, {char})
                if part and (part.Name == "Water" or part.Name == "Sea") then
                    local platform = workspace:FindFirstChild("MakitoWaterPlatform")
                    if not platform then
                        platform = Instance.new("Part", workspace)
                        platform.Name = "MakitoWaterPlatform"
                        platform.Size = Vector3.new(20, 1, 20)
                        platform.Transparency = 1
                        platform.Anchored = true
                        platform.CanCollide = true
                    end
                    platform.CFrame = CFrame.new(root.Position.X, part.Position.Y + part.Size.Y/2, root.Position.Z)
                else
                    local platform = workspace:FindFirstChild("MakitoWaterPlatform")
                    if platform then platform:Destroy() end
                end
            end
        end)
    end
    
    -- Auto Redeem Codes
    if _G.Settings.AutoRedeemCodes then
        local codes = {"REWARDDUNGEON", "NEWTROLL", "KITT_RESET", "Sub2CaptainMaui", "Sub2Fer999", "JCWK", "Magicbus", "Starcodeheo", "JCWK", "BIGNEWS", "FUDD10", "SUB2GAMERROBOT_EXP1", "Sub2NoobMaster123", "Sub2UncleKizaru", "Sub2Daigrock", "Axiore", "TantaiGaming", "StrawHatMaine"}
        for _, code in ipairs(codes) do
            _G.Utils.SafeRemote("RedeemCode", code)
        end
        _G.Settings.AutoRedeemCodes = false -- Só roda uma vez
    end
end

-- VISUAL OPTIMIZATIONS
function UtilsModule.OptimizeGraphics()
    if not _G.Settings then return end
    
    if _G.Settings.LowGraphics or _G.Settings.RemoveTextures or _G.Settings.PerformanceMode then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsA("MeshPart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("Texture") or v:IsA("Decal") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            end
        end
    end

    if _G.Settings.RemoveShadows or _G.Settings.PerformanceMode then
        game:GetService("Lighting").GlobalShadows = false
    end

    if _G.Settings.FPSBooster or _G.Settings.PerformanceMode then
        if setfpscap then setfpscap(999) end
        settings().Rendering.QualityLevel = 1
    end
    
    if _G.Settings.WhiteScreen then
        local gui = game:GetService("CoreGui"):FindFirstChild("MakitoWhiteScreen")
        if not gui then
            gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
            gui.Name = "MakitoWhiteScreen"
            local f = Instance.new("Frame", gui)
            f.Size = UDim2.new(1, 0, 1, 0)
            f.BackgroundColor3 = Color3.new(1, 1, 1)
            f.BorderSizePixel = 0
        end
    else
        local gui = game:GetService("CoreGui"):FindFirstChild("MakitoWhiteScreen")
        if gui then gui:Destroy() end
    end
end

-- SECURITY & ANTI-BAN PRO
function UtilsModule.SecurityBypass()
    if not _G.Settings or not _G.Settings.SecurityMode then return end
    
    -- Randomização de Wait para evitar detecção de padrão
    _G.SafeWait = function(min, max)
        task.wait(math.random(min * 100, max * 100) / 100)
    end

    -- Anti-Admin Avançado
    task.spawn(function()
        while task.wait(5) do
            for _, v in ipairs(game:GetService("Players"):GetPlayers()) do
                if v:GetRankInGroup(4442272) >= 100 or v:IsA("Player") and (v.Name:lower():find("admin") or v.Name:lower():find("staff") or v.Name:lower():find("mod")) then
                    if _G.Settings.AutoKickMod then
                        LocalPlayer:Kick("�️ [MAKITO] PROTEÇÃO ATIVA: Administrador detectado no servidor.")
                    end
                end
            end
        end
    end)

    -- Bypass de Teleporte (Velocidade Variável)
    _G.Settings.TweenSpeed = math.random(320, 380)
end

-- INVENTORY LOGS (PARA PRODUÇÃO)
function UtilsModule.LogInventory()
    if not _G.Settings or not _G.Settings.WebhookEnabled then return end
    
    local inventory = {}
    for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
        table.insert(inventory, v.Name)
    end
    for _, v in ipairs(LocalPlayer.Character:GetChildren()) do
        if v:IsA("Tool") then table.insert(inventory, v.Name) end
    end
    
    UtilsModule.SendWebhook({
        msg = "🎒 **Inventário Atualizado**\n" .. table.concat(inventory, ", ")
    })
end

-- PERFORMANCE MODE (PRO)
function UtilsModule.ExtremePerformance()
    if not _G.Settings or not _G.Settings.PerformanceMode then return end
    
    settings().Rendering.QualityLevel = 1
    game:GetService("Lighting").GlobalShadows = false
    game:GetService("Lighting").FogEnd = 9e9
    
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        end
    end
end

-- SERVER HOP AVANÇADO (PROCURA BOSS/EVENTO)
function UtilsModule.AdvancedHop(targetBoss)
    local HttpService = game:GetService("HttpService")
    local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    
    local function GetServers()
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(Api))
        end)
        return success and result or nil
    end

    local servers = GetServers()
    if servers then
        for _, server in ipairs(servers.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                UtilsModule.Notify("Trocando para servidor mais vazio...", 5)
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id)
                break
            end
        end
    end
end

-- MONITOR DE STATUS GLOBAL (ESTILO REDZ PRO)
function UtilsModule.UpdateGlobalStatus()
    local status = {
        Mirage = "Não Detectada",
        Moon = "Normal",
        Bosses = {},
        CakePrince = "N/A",
        SeaEvents = "Nenhum",
        FullMoon = false,
        MirageSpawned = false
    }
    
    pcall(function()
        -- Mirage Island Check
        if workspace:FindFirstChild("Mirage Island") or workspace:FindFirstChild("MirageIsland") then
            status.Mirage = "🏝️ SPAWNADA!"
            status.MirageSpawned = true
        end
        
        -- Full Moon Check
        local moonMagnitude = game:GetService("Lighting").Sky.FullMoonMagnitude
        if moonMagnitude > 0.9 then
            status.Moon = "🌕 LUA CHEIA!"
            status.FullMoon = true
        elseif moonMagnitude > 0.5 then
            status.Moon = "🌗 Crescente"
        end
        
        -- Cake Prince Tracker (Dough King Mobs)
        -- Tenta pegar via Remote primeiro
        local cakeMsg = UtilsModule.SafeRemote("CakePrince", "Check")
        
        if cakeMsg and type(cakeMsg) == "string" then
            status.CakePrince = cakeMsg
        else
            -- Fallback: Se o remote não retornar nada ou falhar, tentamos inferir se possível
            -- (Geralmente o remote CommF_ com "CakePrince" e "Check" funciona no Blox Fruits)
            status.CakePrince = "Aguardando Dados..."
        end

        -- Boss Monitor (Melhorado)
        local enemies = workspace:FindFirstChild("Enemies") or workspace
        local bossNames = {
            "rip_indra", "Darkbeard", "Order", "Beautiful Pirate", "Cake Prince", "Dough King",
            "Soul Reaper", "Rengoku", "Deandre", "Diablo", "Urban", "Captain Elephant", "Island Empress"
        }
        
        for _, bossName in ipairs(bossNames) do
            local v = enemies:FindFirstChild(bossName) or enemies:FindFirstChild(bossName .. " [Boss]")
            if v and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                table.insert(status.Bosses, bossName)
            end
        end

        -- Sea Events Monitor
        local seaEventsFolder = workspace:FindFirstChild("SeaEvents")
        if seaEventsFolder then
            for _, v in ipairs(seaEventsFolder:GetChildren()) do
                if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                    status.SeaEvents = v.Name
                    break
                end
            end
        end
    end)
    
    _G.MakitoGlobalStatus = status
    return status
end

-- AUTO CHEST (BERRY FARM)
function UtilsModule.AutoChestLogic()
    if not _G.Settings or not _G.Settings.AutoChest then return end
    
    pcall(function()
        for _, v in ipairs(workspace:GetChildren()) do
            if v.Name:find("Chest") and v:IsA("BasePart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - v.Position).Magnitude
                if dist < 5000 then -- Limite de segurança para evitar ban
                    UtilsModule.SetNoClip(true)
                    LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
                    task.wait(0.1)
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v, 0)
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v, 1)
                end
            end
        end
    end)
end

function UtilsModule.HasItem(name)
    for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if v.Name == name then return true end
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(name) then
        return true
    end
    return false
end

function UtilsModule.GetMaterialCount(name)
    local count = 0
    pcall(function()
        -- Verifica no inventário do jogador (Data.Inventory ou similar dependendo da versão)
        local inventory = LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Inventory")
        if inventory and inventory:FindFirstChild(name) then
            count = inventory[name].Value
        else
            -- Fallback: conta itens no backpack se forem empilháveis
            for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if v.Name == name then count = count + 1 end
            end
        end
    end)
    return count
end

-- AUTO HAKI COLOR / SHOP
function UtilsModule.AutoHakiShop()
    if not _G.Settings or not _G.Settings.AutoBuyHakiColor then return end
    
    local npc = workspace.NPCs:FindFirstChild("Master of Aura")
    if npc then
        UtilsModule.TweenTo(npc.HumanoidRootPart.CFrame)
        UtilsModule.SafeRemote("HakiColorShop", "Buy")
    end
end

return UtilsModule
