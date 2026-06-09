--!strict
local UtilsModule = {}

-- TYPES
type ESPData = {
    Gui: BillboardGui,
    Label: TextLabel,
    Dist: TextLabel,
    Box: SelectionBox?,
    Type: string
}

-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- INTERNAL STATE
local Makito = getgenv().Makito
local isTweening = false
local currentTween: Tween? = nil
local ESPObjects: {[Instance]: ESPData} = {}
local InstanceCache = {
    Enemies = {} :: {any},
    NPCs = {} :: {any},
    Items = {} :: {any},
    LastEnemyUpdate = 0,
    LastNPCUpdate = 0
}

-- 1. SISTEMA DE ESP
function UtilsModule.CreateESP(obj: Instance, name: string, color: Color3, type: string)
    if ESPObjects[obj] then return end
    
    local folder = CoreGui:FindFirstChild("MakitoESP") or Instance.new("Folder", CoreGui)
    folder.Name = "MakitoESP"
    
    local neonColor = color
    if type == "Player" then neonColor = Color3.fromRGB(0, 255, 255)
    elseif type == "NPC" then neonColor = Color3.fromRGB(255, 0, 255)
    elseif type == "Chest" then neonColor = Color3.fromRGB(255, 255, 0)
    elseif type == "Fruit" then neonColor = Color3.fromRGB(0, 255, 0)
    elseif type == "Mirage" then neonColor = Color3.fromRGB(0, 0, 255)
    elseif type == "Gear" then neonColor = Color3.fromRGB(255, 255, 255)
    end

    local bg = Instance.new("BillboardGui")
    bg.Name = "ESP"
    bg.Adornee = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart")) or obj
    bg.AlwaysOnTop = true
    bg.Size = UDim2.new(0, 100, 0, 30)
    bg.StudsOffset = Vector3.new(0, 3, 0)
    bg.Parent = folder
    
    local label = Instance.new("TextLabel", bg)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0.6, 0)
    label.Text = name or obj.Name
    label.TextColor3 = neonColor
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    
    local distLabel = Instance.new("TextLabel", bg)
    distLabel.BackgroundTransparency = 1
    distLabel.Size = UDim2.new(1, 0, 0.4, 0)
    distLabel.Position = UDim2.new(0, 0, 0.6, 0)
    distLabel.TextColor3 = Color3.new(1, 1, 1)
    distLabel.TextSize = 10
    
    local box: SelectionBox? = nil
    if Makito.Settings and Makito.Settings.BoxESP then
        box = Instance.new("SelectionBox")
        box.Adornee = obj
        box.Color3 = neonColor
        box.LineThickness = 0.05
        box.Parent = obj
    end

    ESPObjects[obj] = {Gui = bg, Label = label, Dist = distLabel, Box = box, Type = type}
    
    local conn: RBXScriptConnection
    conn = obj.AncestryChanged:Connect(function()
        if not obj:IsDescendantOf(workspace) then
            if bg then bg:Destroy() end
            if box then box:Destroy() end
            ESPObjects[obj] = nil
            conn:Disconnect()
        end
    end)
end

-- 2. CACHE INTELIGENTE
function UtilsModule.UpdateInstanceCache()
    local now = tick()
    
    if now - InstanceCache.LastEnemyUpdate > 0.5 then
        InstanceCache.LastEnemyUpdate = now
        local newEnemies = {}
        local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
        
        for _, v in ipairs(enemiesFolder:GetChildren()) do
            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                table.insert(newEnemies, v)
                if Makito.Settings and Makito.Settings.NpcESP then
                    UtilsModule.CreateESP(v, v.Name, Color3.fromRGB(255, 80, 80), "NPC")
                end
            end
        end
        InstanceCache.Enemies = newEnemies
    end
    
    if Makito.Settings then
        if Makito.Settings.EspPlayers then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    UtilsModule.CreateESP(p.Character.HumanoidRootPart, p.Name, Color3.fromRGB(100, 200, 255), "Player")
                end
            end
        end
        if Makito.Settings.EspFruits then
            for _, v in ipairs(workspace:GetChildren()) do
                if v:IsA("Tool") and (v.Name:find("Fruit") or v:FindFirstChild("Handle")) then
                    UtilsModule.CreateESP(v:FindFirstChild("Handle") or v, v.Name, Color3.fromRGB(0, 255, 0), "Fruit")
                end
            end
        end

        if Makito.Settings.AutoMirageAdvanced then
            local mirage = workspace:FindFirstChild("Mirage Island")
            if mirage then
                UtilsModule.CreateESP(mirage, "MIRAGE ISLAND", Color3.fromRGB(0, 0, 255), "Mirage")
                
                -- Search for Blue Gear
                for _, v in ipairs(mirage:GetDescendants()) do
                    if v.Name == "Blue Gear" or v.Name == "Gear" then
                        UtilsModule.CreateESP(v, "BLUE GEAR", Color3.fromRGB(255, 255, 255), "Gear")
                    end
                end
            end
        end
    end
end

function UtilsModule.GetInstanceCache()
    return InstanceCache
end

-- 3. MOVIMENTAÇÃO
function UtilsModule.TweenTo(cf: CFrame, speed: number?)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local dist = (root.Position - cf.Position).Magnitude
    if dist < 5 then
        if currentTween then currentTween:Cancel() end
        isTweening = false
        return
    end

    isTweening = true
    local targetSpeed = speed or (Makito.Settings and Makito.Settings.TweenSpeed) or 350
    local duration = dist / targetSpeed
    
    if currentTween then currentTween:Cancel() end
    
    UtilsModule.Float(true)
    UtilsModule.SetNoClip(true)
    
    currentTween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = cf})
    currentTween:Play()
    
    currentTween.Completed:Once(function()
        isTweening = false
        UtilsModule.Float(false)
        UtilsModule.SetNoClip(false)
    end)
end

-- 4. SEGURANÇA
function UtilsModule.SecurityBypass()
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end
    end)
    
    -- Infinite Geppo
    game:GetService("UserInputService").JumpRequest:Connect(function()
        if Makito.Settings and Makito.Settings.InfiniteGeppo then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

function UtilsModule.ApplyVisualSettings()
    -- White Screen (Extreme FPS Boost)
    if Makito.Settings and Makito.Settings.WhiteScreen then
        if not game:GetService("RunService"):IsStudio() then
            game:GetService("RunService"):Set3dRenderingEnabled(false)
        end
    else
        game:GetService("RunService"):Set3dRenderingEnabled(true)
    end

    -- Full Bright
    if Makito.Settings and Makito.Settings.FullBright then
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 14
        game:GetService("Lighting").FogEnd = 100000
        game:GetService("Lighting").GlobalShadows = false
        game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
    
    -- FPS Boost
    if Makito.Settings and Makito.Settings.FPSBoost then
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            end
        end
    end
end

function UtilsModule.Float(enabled: boolean)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local float = root:FindFirstChild("MakitoFloat")
    if enabled then
        if not float then
            float = Instance.new("BodyVelocity")
            float.Name = "MakitoFloat"
            float.Velocity = Vector3.new(0, 0, 0)
            float.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            float.Parent = root
        end
    elseif float then
        float:Destroy()
    end
end

function UtilsModule.SetNoClip(enabled: boolean)
    if enabled then
        if Makito.NoClipConn then return end
        Makito.NoClipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, v in ipairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
    elseif Makito.NoClipConn then
        Makito.NoClipConn:Disconnect()
        Makito.NoClipConn = nil
    end
end

-- 5. REMOTOS
function UtilsModule.SafeRemote(name: string, ...: any)
    local remote = ReplicatedStorage:FindFirstChild("CommF_", true)
    if remote and remote:IsA("RemoteFunction") then
        return remote:InvokeServer(name, ...)
    end
    return nil
end

-- 6. WORLD STATUS
function UtilsModule.GetWorldStatus()
    local status = {
        RipIndra = "🔴 Desativado",
        DoughKing = "🔴 Desativado",
        CakeCounter = "Desconhecido",
        ActiveBosses = {} :: {string}
    }

    pcall(function()
        if workspace:FindFirstChild("Enemies") then
            for _, v in ipairs(workspace.Enemies:GetChildren()) do
                if v.Name:find("rip_indra") then
                    status.RipIndra = "🟢 VIVO"
                    break
                end
            end
        end

        if Makito.Sea == 3 then
            local counter = UtilsModule.GetCakeCounter()
            if counter then
                local countNum = tonumber(counter) or 0
                status.CakeCounter = tostring(500 - countNum) .. " restantes"
                if countNum >= 500 then
                    status.DoughKing = "🟢 PRONTO (Fale c/ NPC)"
                end
            end
            
            if workspace:FindFirstChild("Enemies") then
                for _, v in ipairs(workspace.Enemies:GetChildren()) do
                    if v.Name:find("Dough King") or v.Name:find("Cake Prince") then
                        status.DoughKing = "⚔️ EM COMBATE"
                        break
                    end
                end
            end
        end

        local enemies = workspace:FindFirstChild("Enemies") or workspace
        for _, v in ipairs(enemies:GetChildren()) do
            if v:FindFirstChild("Humanoid") and v.Name:find("Boss") then
                table.insert(status.ActiveBosses, v.Name)
            end
        end
    end)

    return status
end

-- 7. BUSCA DE INIMIGOS
function UtilsModule.GetNearestEnemy(enemyName: string)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local nearest = nil
    local dist = math.huge
    
    for _, v in ipairs(InstanceCache.Enemies) do
        if v.Name:find(enemyName) then
            local d = (root.Position - v.HumanoidRootPart.Position).Magnitude
            if d < dist then
                dist = d
                nearest = v
            end
        end
    end
    return nearest
end

function UtilsModule.GetNearestEnemyAny()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local nearest = nil
    local dist = math.huge
    
    for _, v in ipairs(InstanceCache.Enemies) do
        local d = (root.Position - v.HumanoidRootPart.Position).Magnitude
        if d < dist then
            dist = d
            nearest = v
        end
    end
    return nearest
end

-- 8. UTILITÁRIOS GERAIS
function UtilsModule.HasItem(itemName: string)
    if LocalPlayer.Backpack:FindFirstChild(itemName) then return true end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(itemName) then return true end
    
    local inventory = LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Inventory")
    if inventory and inventory:FindFirstChild(itemName) then return true end
    return false
end

function UtilsModule.ServerHop()
    local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
    local ok, servers = pcall(function() return HttpService:JSONDecode(game:HttpGet(Api)) end)
    if ok and servers then
        for _, v in pairs(servers.data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, LocalPlayer)
                break
            end
        end
    end
end

function UtilsModule.Rejoin()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

function UtilsModule.UpdateGlobalStatus()
    -- Lógica de atualização de status global para UI
end

function UtilsModule.AutoBuildStats()
    if not Makito.Settings or not Makito.Settings.AutoStats then return end
    local points = LocalPlayer.Data.StatsPoints.Value
    if points > 0 then
        UtilsModule.SafeRemote("AddPoint", Makito.Settings.SelectedStat, points)
    end
end

function UtilsModule.AntiAFK()
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end

function UtilsModule.Notify(text: string, duration: number?)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "MAKITO HUB",
            Text = text,
            Duration = duration or 5
        })
    end)
end

function UtilsModule.GetCakeCounter()
    return UtilsModule.SafeRemote("GetCakeCounter")
end

return UtilsModule
