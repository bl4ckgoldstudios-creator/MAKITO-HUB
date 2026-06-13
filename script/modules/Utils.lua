
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
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- INTERNAL STATE
local Makito = getgenv().Makito
local isTweening = false
local currentTween: Tween? = nil
local ESPObjects: {[Instance]: ESPData} = {}

-- ==================================================
-- FUNÇÃO _tbl DO EXEMPLO (para require hook)
-- ==================================================
local function _tbl(t)
    return setmetatable(t or {}, {
        __index = function()
            return _tbl()
        end,
        __call = function()
            return _tbl()
        end
    })
end
local InstanceCache = {
    Enemies = {} :: {any},
    NPCs = {} :: {any},
    Items = {} :: {any},
    LastEnemyUpdate = 0,
    LastNPCUpdate = 0
}

-- ==================================================
-- SISTEMA DO EXEMPLO: RIP INDRA PART (TELEPORT)
-- ==================================================
local RipIndraPart: Part? = nil
local shouldTween = false
local TweenSpeedFar = 300
local TweenSpeedNear = 900

local function CreateRipIndraPart()
    if RipIndraPart then return end
    
    RipIndraPart = Instance.new("Part", workspace)
    RipIndraPart.Name = "Rip_Indra"
    RipIndraPart.Anchored = true
    RipIndraPart.CanCollide = false
    RipIndraPart.CanTouch = false
    RipIndraPart.Transparency = 1
end

-- ==================================================
-- TELEPORT COM TWEEN (_tp DO EXEMPLO)
-- ==================================================
function UtilsModule._tp(targetCFrame: CFrame)
    if not RipIndraPart then CreateRipIndraPart() end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    shouldTween = true
    getgenv().OnFarm = false

    if root.Anchored then
        root.Anchored = false
        task.wait()
    end

    local dist = (targetCFrame.Position - root.Position).Magnitude
    local speed = dist &lt;= 90 and TweenSpeedNear or TweenSpeedFar

    local info = TweenInfo.new(dist / speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(RipIndraPart, info, {CFrame = targetCFrame})

    if char.Humanoid.Sit == true then
        RipIndraPart.CFrame = CFrame.new(RipIndraPart.Position.X, targetCFrame.Y, RipIndraPart.Position.Z)
    end

    tween:Play()

    task.spawn(function()
        while tween.PlaybackState == Enum.PlaybackState.Playing do
            if not shouldTween then
                tween:Cancel()
                break
            end
            task.wait(.1)
        end
        getgenv().OnFarm = true
    end)
end

function UtilsModule.notween(targetCFrame: CFrame)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = targetCFrame
    end
end

function UtilsModule.TeleportToTarget(targetCFrame: CFrame)
    UtilsModule._tp(targetCFrame)
end

-- ==================================================
-- AUTO KEN (OBSERVATION HAKI DO EXEMPLO)
-- ==================================================
function UtilsModule.StartAutoKen()
    task.spawn(function()
        local commE = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommE")
        
        local function HasKen()
            local char = LocalPlayer.Character
            return char and CollectionService:HasTag(char, "Ken")
        end
        
        while Makito and Makito.Settings do
            task.wait(0.2)
            
            if not Makito.Settings.AutoKen then continue end
            
            local char = LocalPlayer.Character
            if not char then continue end
            
            pcall(function()
                if not HasKen() then
                    commE:FireServer("Ken", true)
                end
            end)
        end
    end)
end

-- ==================================================
-- AUTO TEAM (DO EXEMPLO)
-- ==================================================
function UtilsModule.SetTeam(teamName: string)
    if not teamName then return end
    
    pcall(function()
        local commF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF")
        if commF then
            commF:InvokeServer("SetTeam", teamName)
        end
    end)
end

function UtilsModule.StartAutoTeam()
    task.spawn(function()
        while Makito and Makito.Running do
            task.wait(1)
            
            if not Makito.Settings or not Makito.Settings.AutoTeamEnabled then continue end
            
            local desiredTeam = Makito.Settings.AutoTeam
            if not desiredTeam or desiredTeam == "" then continue end
            
            pcall(function()
                if not LocalPlayer.Team or LocalPlayer.Team.Name ~= desiredTeam then
                    UtilsModule.SetTeam(desiredTeam)
                end
            end)
        end
    end)
end

-- ==================================================
-- USE SKILLS (DO EXEMPLO)
-- ==================================================
function UtilsModule.UseSkills(weaponType: string, skillKey: string)
    if not Makito.Farming then return end
    
    if weaponType == "Melee" then
        Makito.Farming.EquipWeaponByToolTip("Melee")
    elseif weaponType == "Sword" then
        Makito.Farming.EquipWeaponByToolTip("Sword")
    elseif weaponType == "Blox Fruit" then
        Makito.Farming.EquipWeaponByToolTip("Blox Fruit")
    elseif weaponType == "Gun" then
        Makito.Farming.EquipWeaponByToolTip("Gun")
    end
    task.wait()
    
    local vim = game:GetService("VirtualInputManager")
    
    if skillKey == "Z" then
        vim:SendKeyEvent(true, "Z", false, game)
        vim:SendKeyEvent(false, "Z", false, game)
    elseif skillKey == "X" then
        vim:SendKeyEvent(true, "X", false, game)
        vim:SendKeyEvent(false, "X", false, game)
    elseif skillKey == "C" then
        vim:SendKeyEvent(true, "C", false, game)
        vim:SendKeyEvent(false, "C", false, game)
    elseif skillKey == "V" then
        vim:SendKeyEvent(true, "V", false, game)
        vim:SendKeyEvent(false, "V", false, game)
    elseif skillKey == "F" then
        vim:SendKeyEvent(true, "F", false, game)
        vim:SendKeyEvent(false, "F", false, game)
    elseif skillKey == "Y" then
        vim:SendKeyEvent(true, "Y", false, game)
        vim:SendKeyEvent(false, "Y", false, game)
    end
end

function UtilsModule.UseFruitSkills()
    if not Makito.Settings then return end
    
    Makito.Farming.EquipWeaponByToolTip("Blox Fruit")
    task.wait()
    
    if Makito.Settings.FruitSkills then
        if Makito.Settings.FruitSkills.Z then
            UtilsModule.UseSkills("Blox Fruit", "Z")
        end
        if Makito.Settings.FruitSkills.X then
            UtilsModule.UseSkills("Blox Fruit", "X")
        end
        if Makito.Settings.FruitSkills.C then
            UtilsModule.UseSkills("Blox Fruit", "C")
        end
        if Makito.Settings.FruitSkills.V then
            UtilsModule.UseSkills("Blox Fruit", "V")
        end
        if Makito.Settings.FruitSkills.F then
            UtilsModule.UseSkills("Blox Fruit", "F")
        end
    end
end

-- ==================================================
-- LOW CPU / FPS BOOST (DO EXEMPLO)
-- ==================================================
function UtilsModule.LowCPU()
    if not Makito.Settings or not Makito.Settings.LowCPU then return end
    
    Lighting.Ambient = Color3.new(0.695, 0.695, 0.695)
    Lighting.ColorShift_Bottom = Color3.new(0.695, 0.695, 0.695)
    Lighting.ColorShift_Top = Color3.new(0.695, 0.695, 0.695)
    Lighting.Brightness = 2
    Lighting.FogEnd = 1e10
    Lighting.GlobalShadows = false
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    
    task.spawn(function()
        while Makito and Makito.Settings and Makito.Settings.LowCPU do
            task.wait(1)
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("Part") or obj:IsA("UnionOperation") or obj:IsA("CornerWedgePart") or obj:IsA("TrussPart") then
                        obj.Material = Enum.Material.Plastic
                        obj.Reflectance = 0
                    elseif obj:IsA("Decal") or obj:IsA("Texture") then
                        obj.Transparency = 1
                    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                        obj.Lifetime = NumberRange.new(0)
                    elseif obj:IsA("Explosion") then
                        obj.BlastPressure = 1
                        obj.BlastRadius = 1
                    elseif obj:IsA("Fire") or obj:IsA("SpotLight") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                        obj.Enabled = false
                    elseif obj:IsA("MeshPart") then
                        obj.Material = Enum.Material.Plastic
                        obj.Reflectance = 0
                    end
                end
            end)
        end
    end)
end

-- ==================================================
-- FULL BRIGHT (DO EXEMPLO)
-- ==================================================
function UtilsModule.ApplyFullBright()
    if not Makito.Settings or not Makito.Settings.FullBright then return end
    
    Lighting.Ambient = Color3.new(0.695, 0.695, 0.695)
    Lighting.ColorShift_Bottom = Color3.new(0.695, 0.695, 0.695)
    Lighting.ColorShift_Top = Color3.new(0.695, 0.695, 0.695)
    Lighting.Brightness = 2
    Lighting.FogEnd = 1e10
end

-- ==================================================
-- STATS SETTINGS (DO EXEMPLO)
-- ==================================================
function UtilsModule.statsSetings(statType: string, value: any)
    if not Makito.Settings then return end
    
    if statType == "Melee" then
        if LocalPlayer.Data.Points.Value ~= 0 then
            ReplicatedStorage.Remotes.CommF:InvokeServer("AddPoint", "Melee", value)
        end
    elseif statType == "Defense" then
        if LocalPlayer.Data.Points.Value ~= 0 then
            ReplicatedStorage.Remotes.CommF:InvokeServer("AddPoint", "Defense", value)
        end
    elseif statType == "Sword" then
        if LocalPlayer.Data.Points.Value ~= 0 then
            ReplicatedStorage.Remotes.CommF:InvokeServer("AddPoint", "Sword", value)
        end
    elseif statType == "Gun" then
        if LocalPlayer.Data.Points.Value ~= 0 then
            ReplicatedStorage.Remotes.CommF:InvokeServer("AddPoint", "Gun", value)
        end
    elseif statType == "Devil" then
        if LocalPlayer.Data.Points.Value ~= 0 then
            ReplicatedStorage.Remotes.CommF:InvokeServer("AddPoint", "Devil", value)
        end
    end
end

-- ==================================================
-- FUNÇÕES DE VERIFICAÇÃO (DO EXEMPLO)
-- ==================================================
function UtilsModule.Alive(obj: Instance)
    if not obj then return false end
    local hum = obj:FindFirstChild("Humanoid")
    return hum and hum.Health &gt; 0
end

function UtilsModule.Pos(pos: Vector3, maxDist: number)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    return (root.Position - pos).Magnitude &lt;= maxDist
end

function UtilsModule.Dist(obj: Instance, maxDist: number)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    local hrp = obj:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    return (root.Position - hrp.Position).Magnitude &lt;= maxDist
end

function UtilsModule.DistH(obj: Instance, minDist: number)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    local hrp = obj:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    return (root.Position - hrp.Position).Magnitude &gt; minDist
end

function UtilsModule.CheckBoat()
    local boats = workspace:FindFirstChild("Boats")
    if not boats then return false end
    
    for _, boat in pairs(boats:GetChildren()) do
        if boat:FindFirstChild("Owner") and tostring(boat.Owner.Value) == tostring(LocalPlayer.Name) then
            return boat
        end
    end
    return false
end

function UtilsModule.CheckEnemiesBoat()
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return false end
    
    for _, obj in ipairs(enemies:GetChildren()) do
        if obj.Name == "Fish Boat" and obj:FindFirstChild("Health") and obj.Health.Value &gt; 0 then
            return true
        end
    end
    return false
end

function UtilsModule.CheckPirateGrandBrigade()
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return false end
    
    for _, obj in ipairs(enemies:GetChildren()) do
        if (obj.Name == "Pirate Grand Brigade" or obj.Name == "Pirate Brigade") and obj:FindFirstChild("Health") and obj.Health.Value &gt; 0 then
            return true
        end
    end
    return false
end

function UtilsModule.CheckShark()
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return false end
    
    for _, obj in ipairs(enemies:GetChildren()) do
        if obj.Name == "Shark" and UtilsModule.Alive(obj) then
            return true
        end
    end
    return false
end

function UtilsModule.CheckTerrorShark()
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return false end
    
    for _, obj in ipairs(enemies:GetChildren()) do
        if obj.Name == "Terror Shark" and UtilsModule.Alive(obj) then
            return true
        end
    end
    return false
end

function UtilsModule.CheckPiranha()
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return false end
    
    for _, obj in ipairs(enemies:GetChildren()) do
        if obj.Name == "Piranha" and UtilsModule.Alive(obj) then
            return true
        end
    end
    return false
end

function UtilsModule.CheckFishCrew()
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return false end
    
    for _, obj in ipairs(enemies:GetChildren()) do
        if (obj.Name == "Fish Crew Member" or obj.Name == "Haunted Crew Member") and UtilsModule.Alive(obj) then
            return true
        end
    end
    return false
end

function UtilsModule.CheckHauntedCrew()
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return false end
    
    for _, obj in ipairs(enemies:GetChildren()) do
        if obj.Name == "Haunted Crew Member" and UtilsModule.Alive(obj) then
            return true
        end
    end
    return false
end

function UtilsModule.CheckSeaBeast()
    local seaBeasts = workspace:FindFirstChild("Sea Beasts") or workspace
    return seaBeasts:FindFirstChild("Sea Beast") ~= nil
end

function UtilsModule.CheckLeviathan()
    local seaBeasts = workspace:FindFirstChild("Sea Beasts") or workspace
    return seaBeasts:FindFirstChild("Leviathan") ~= nil
end

-- ==================================================
-- SISTEMA ESP (ORIGINAL MAKITO)
-- ==================================================
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

-- ==================================================
-- CACHE DE INSTÂNCIAS (ORIGINAL MAKITO)
-- ==================================================
function UtilsModule.UpdateInstanceCache()
    local now = tick()
    
    if now - InstanceCache.LastEnemyUpdate &gt; 0.5 then
        InstanceCache.LastEnemyUpdate = now
        local newEnemies = {}
        local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
        
        for _, v in ipairs(enemiesFolder:GetChildren()) do
            if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
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

-- ==================================================
-- MOVIMENTAÇÃO (ORIGINAL MAKITO + EXEMPLO)
-- ==================================================
function UtilsModule.TweenTo(cf: CFrame, speed: number?)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local dist = (root.Position - cf.Position).Magnitude
    if dist &lt; 5 then
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

-- ==================================================
-- SEGURANÇA E OUTROS (ORIGINAL MAKITO)
-- ==================================================
function UtilsModule.SecurityBypass()
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end
    end)
    
    game:GetService("UserInputService").JumpRequest:Connect(function()
        if Makito.Settings and Makito.Settings.InfiniteGeppo then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
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
                for _, v in ipairs(char:GetChildren()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
    elseif Makito.NoClipConn then
        Makito.NoClipConn:Disconnect()
        Makito.NoClipConn = nil
    end
end

-- ==================================================
-- REMOTOS (ORIGINAL MAKITO)
-- ==================================================
function UtilsModule.SafeRemote(name: string, ...: any)
    local remote = ReplicatedStorage:FindFirstChild("CommF", true)
    if remote and remote:IsA("RemoteFunction") then
        return remote:InvokeServer(name, ...)
    end
    return nil
end

-- ==================================================
-- BUSCA DE INIMIGOS (ORIGINAL MAKITO)
-- ==================================================
function UtilsModule.GetNearestEnemy(enemyName: string)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local nearest = nil
    local dist = math.huge
    
    for _, v in ipairs(InstanceCache.Enemies) do
        if v.Name:find(enemyName) then
            local hrp = v:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            local d = (root.Position - hrp.Position).Magnitude
            if d &lt; dist then
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
        local hrp = v:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local d = (root.Position - hrp.Position).Magnitude
        if d &lt; dist then
            dist = d
            nearest = v
        end
    end
    return nearest
end

-- ==================================================
-- UTILITÁRIOS GERAIS (ORIGINAL MAKITO)
-- ==================================================
function UtilsModule.HasItem(itemName: string)
    if LocalPlayer.Backpack:FindFirstChild(itemName) then return true end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(itemName) then return true end
    
    local inventory = LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Inventory")
    if inventory and inventory:FindFirstChild(itemName) then return true end
    return false
end

function UtilsModule.ServerHop()
    local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&amp;limit=100"
    local ok, servers = pcall(function() return HttpService:JSONDecode(game:HttpGet(Api)) end)
    if ok and servers then
        for _, v in pairs(servers.data) do
            if v.playing &lt; v.maxPlayers and v.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, LocalPlayer)
                break
            end
        end
    end
end

function UtilsModule.Rejoin()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

function UtilsModule.AutoBuildStats()
    if not Makito.Settings or not Makito.Settings.AutoStats then return end
    local points = LocalPlayer.Data.Points.Value
    if points &gt; 0 then
        UtilsModule.SafeRemote("AddPoint", Makito.Settings.SelectedStat, points)
    end
end

function UtilsModule.AutoKen()
    task.spawn(function()
        while Makito and Makito.Settings do
            task.wait(0.2)
            if not Makito.Settings.AutoHaki then continue end
            
            local char = LocalPlayer.Character
            if not char then continue end
            
            pcall(function()
                local commE = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("CommE")
                if commE then
                    commE:FireServer("Ken", true)
                end
            end)
        end
    end)
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

function UtilsModule.GetConnectionEnemies(a)
    for i,v in pairs(ReplicatedStorage:GetChildren()) do
        if v:IsA("Model") and ((typeof(a) == "table" and table.find(a, v.Name)) or v.Name == a) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            return v
        end
    end
    for i,v in next,workspace.Enemies:GetChildren() do
        if v:IsA("Model") and ((typeof(a) == "table" and table.find(a, v.Name)) or v.Name == a) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            return v
        end
    end
end

function UtilsModule.Hop()
    pcall(function()
        for count = math.random(1, math.random(40, 75)), 100 do
            local remote = ReplicatedStorage.__ServerBrowser:InvokeServer(count)
            for _, v in next, remote do
                if tonumber(v['Count']) < 12 then TeleportService:TeleportToPlaceInstance(game.PlaceId, _) end
            end
        end
    end)
end

function UtilsModule.GetInfinityAbility(Method, Var)
    local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end
    if Method == "Soru" and Var then
        for _,gc in next, getgc() do
            if LocalPlayer.Character.Soru then
                if ((typeof(gc) == "function") and (getfenv(gc).script == LocalPlayer.Character.Soru)) then
                    for _, v in next, getupvalues(gc) do
                        if (typeof(v) == "table") then
                            repeat task.wait(0.1) v.LastUse = 0 until not Var or (LocalPlayer.Character.Humanoid.Health <= 0)
                        end
                    end
                end
            end
        end
    elseif Method == "Energy" and Var then
        local Energy = LocalPlayer.Character.Energy.Value
        LocalPlayer.Character.Energy.Changed:Connect(function()
            if Var then LocalPlayer.Character.Energy.Value = Energy end
        end)
    elseif Method == "Observation" and Var then
        local VisionRadius = LocalPlayer.VisionRadius
        VisionRadius.Value = math.huge
    end
end

function UtilsModule.ApplyVisualSettings()
    if not Makito.Settings then return end
    
    if Makito.Settings.WhiteScreen then
        local Lighting = game:GetService("Lighting")
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
        Lighting.ColorShift_Top = Color3.new(1, 1, 1)
        Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
        Lighting.FogEnd = 1e8
        Lighting.GlobalShadows = false
    end
    
    if Makito.Settings.FullBright then
        UtilsModule.ApplyFullBright()
    end
end

-- ==================================================
-- ANTI-CHEAT BYPASS (DO EXEMPLO)
-- ==================================================
function UtilsModule.InitializeAntiCheat()
    -- Hook Namecall para bloquear remotes de detecção
    pcall(function()
        if getrawmetatable and setreadonly and newcclosure then
            local grm = getrawmetatable(game)
            setreadonly(grm, false)
            local old = grm.__namecall
            grm.__namecall = newcclosure(function(self, ...)
                local args = {...}
                local arg1 = tostring(args[1])
                if arg1 == "TeleportDetect" or arg1 == "CHECKER_1" or arg1 == "CHECKER" or arg1 == "GUI_CHECK" or arg1 == "OneMoreTime" or arg1 == "checkingSPEED" or arg1 == "BANREMOTE" or arg1 == "PERMAIDBAN" or arg1 == "KICKREMOTE" or arg1 == "BR_KICKPC" or arg1 == "BR_KICKMOBILE" then
                    return
                end
                return old(self, ...)
            end)
            setreadonly(grm, true)
        end
    end)
    
    -- Hook require para bloquear errors de carregamento
    pcall(function()
        local _require = require
        require = function(...)
            local success, result = pcall(_require, ...)
            return success and result or _tbl()
        end
    end)
    
    -- Desabilitar screenshots de denúncia
    _G.setfflag = true
    task.spawn(function()
        while _G.setfflag do
            task.wait()
            if setfflag then
                setfflag("AbuseReportScreenshot", "False")
                setfflag("AbuseReportScreenshotPercentage", "0")
            end
        end
    end)
end

-- ==================================================
-- SAFE FARM (DO EXEMPLO)
-- ==================================================
function UtilsModule.StartSafeFarm()
    _G.SafeFarm = true
    task.spawn(function()
        while _G.SafeFarm do
            task.wait()
            pcall(function()
                -- Remover LocalScripts de detecção do Character
                if LocalPlayer.Character then
                    for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                        if v:IsA("LocalScript") then
                            local name = v.Name
                            if name == "General" or name == "Shiftlock" or name == "FallDamage" or name == "4444" or name == "CamBob" or name == "JumpCD" or name == "Looking" or name == "Run" then
                                v:Destroy()
                            end
                        end
                    end
                end
                
                -- Remover LocalScripts de detecção do PlayerScripts
                if LocalPlayer.PlayerScripts then
                    for _, v in pairs(LocalPlayer.PlayerScripts:GetDescendants()) do
                        if v:IsA("LocalScript") then
                            local name = v.Name
                            if name == "RobloxMotor6DBugFix" or name == "Clans" or name == "Codes" or name == "CustomForceField" or name == "MenuBloodSp" or name == "PlayerList" then
                                v:Destroy()
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- ==================================================
-- INICIALIZAÇÃO DAS FUNCIONALIDADES DO EXEMPLO
-- ==================================================
function UtilsModule.InitializeExampleFeatures()
    CreateRipIndraPart()
    UtilsModule.StartAutoKen()
    UtilsModule.StartAutoTeam()
    UtilsModule.InitializeAntiCheat()
    UtilsModule.StartSafeFarm()
end

return UtilsModule
