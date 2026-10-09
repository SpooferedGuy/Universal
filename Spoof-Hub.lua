local Build = loadstring(game:HttpGet("https://pastebin.com/raw/eppGB6cG"))()
local UI = Build({
    Title = "Spoof Hub, by SpooferedGuy",
    ScriptName = "SpoofHub - Universal",
})

-- Tabs
local CombatTab = UI.CreateTab("Combat⚔️")
local PlayerTab = UI.CreateTab("Player👤")
local FarmTab = UI.CreateTab("NPCS⚡")
local ItemsTab = UI.CreateTab("Items🔑")
local TeleportsTab = UI.CreateTab("Teleports🧘‍♂️")
local TrollTab = UI.CreateTab("Troll😂")

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- ================= BODY LOCK / AIMBOT =================
local BodyLockEnabled = false
local BodyLockConnection = nil
local BodyLockRange = 10 -- Distância padrão

-- Função para encontrar o jogador mais próximo (baseada no seu script funcional)
local function getClosestPlayer()
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    
    if not root then return nil end

    local closestPlayer, shortestDist = nil, BodyLockRange
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") and p.Character.Humanoid.Health > 0 then
            local targetHRP = p.Character.HumanoidRootPart
            local dist = (root.Position - targetHRP.Position).Magnitude
            
            if dist < shortestDist then
                closestPlayer = p
                shortestDist = dist
            end
        end
    end
    return closestPlayer
end

-- Função para ativar o Body Lock
local function enableBodyLock()
    BodyLockEnabled = true
    
    if BodyLockConnection then
        BodyLockConnection:Disconnect()
    end
    
    BodyLockConnection = RunService.Heartbeat:Connect(function()
        if not BodyLockEnabled then return end
        
        local character = LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if not (character and root and humanoid) then return end
        
        local target = getClosestPlayer()
        if target and target.Character then
            local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
            if targetHrp then
                -- Faz o personagem olhar para o alvo mantendo a altura (não olha para cima/baixo)
                root.CFrame = CFrame.lookAt(root.Position, Vector3.new(targetHrp.Position.X, root.Position.Y, targetHrp.Position.Z))
            end
        end
    end)
end

-- Função para desativar o Body Lock
local function disableBodyLock()
    BodyLockEnabled = false
    if BodyLockConnection then
        BodyLockConnection:Disconnect()
        BodyLockConnection = nil
    end
end

-- ================= ESP Boxes =================
local ESPBoxes = {}
local ESPConnection = nil
local function createESP(player)
    if ESPBoxes[player] then return end
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255,0,0)
    box.Thickness = 1
    box.Filled = false
    ESPBoxes[player] = box
end

local function removeESP(player)
    if ESPBoxes[player] then
        ESPBoxes[player]:Remove()
        ESPBoxes[player] = nil
    end
end

local function updateESP()
    for player, box in pairs(ESPBoxes) do
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local scale = 1 / (pos.Z * math.tan(math.rad(Camera.FieldOfView / 2)) * 2) * 1000
                local size = Vector2.new(1.7*scale,2.5*scale)
                box.Size=size
                box.Position=Vector2.new(pos.X-size.X/2,pos.Y-size.Y/2)
                box.Visible=true
            else box.Visible=false end
        else box.Visible=false end
    end
end

local function enableESP()
    for _, p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then createESP(p) end end
    ESPConnection = RunService.RenderStepped:Connect(updateESP)
    Players.PlayerAdded:Connect(function(p) if p~=LocalPlayer then createESP(p) end end)
    Players.PlayerRemoving:Connect(removeESP)
end

local function disableESP()
    if ESPConnection then ESPConnection:Disconnect() ESPConnection=nil end
    for _, box in pairs(ESPBoxes) do box:Remove() end
    ESPBoxes={}
end

do -- scoped tab locals
CombatTab.AddToggle("ESP Box", false, function(state) if state then enableESP() else disableESP() end end)

-- ================= Name ESP (VERMELHO) =================
local NameESPEnabled = false
local NameESPConnections = {}
local function createNameESP(player)
    if player==LocalPlayer then return end
    local function attachESP()
        local char = player.Character
        if not char then return end
        local head = char:FindFirstChild("Head")
        if not head then return end
        local old = head:FindFirstChild("NameESP")
        if old then old:Destroy() end
        local billboard = Instance.new("BillboardGui")
        billboard.Name="NameESP"
        billboard.Adornee=head
        billboard.Size=UDim2.new(0,75,0,50)
        billboard.StudsOffset=Vector3.new(0,2,0)
        billboard.AlwaysOnTop=true
        billboard.Parent=head
        local label = Instance.new("TextLabel",billboard)
        label.Size=UDim2.new(1,0,1,0)
        label.BackgroundTransparency=1
        label.Text=player.Name
        label.TextColor3=Color3.new(1,0,0) -- Mudado para VERMELHO
        label.TextStrokeTransparency=0
        label.Font=Enum.Font.SourceSansBold
        label.TextScaled=true
    end
    if not NameESPConnections[player] then
        NameESPConnections[player] = player.CharacterAdded:Connect(function() if NameESPEnabled then task.wait(0.5) attachESP() end end)
    end
    if player.Character then attachESP() end
end

local function enableNameESP()
    NameESPEnabled = true
    for _, p in ipairs(Players:GetPlayers()) do createNameESP(p) end
    Players.PlayerAdded:Connect(function(p) if NameESPEnabled then createNameESP(p) end end)
end

local function disableNameESP()
    NameESPEnabled = false
    for _, p in ipairs(Players:GetPlayers()) do
        if NameESPConnections[p] then NameESPConnections[p]:Disconnect() NameESPConnections[p]=nil end
        if p.Character and p.Character:FindFirstChild("Head") then
            local gui = p.Character.Head:FindFirstChild("NameESP")
            if gui then gui:Destroy() end
        end
    end
end

CombatTab.AddToggle("ESP Name", false, function(state) if state then enableNameESP() else disableNameESP() end end)

-- ================= Highlight ESP =================
local HighlightEnabled = false
local HighlightConnections = {}
local function createHighlightESP(player)
    if player==LocalPlayer then return end
    local function attachHighlight()
        local char = player.Character
        if not char then return end
        local old = char:FindFirstChild("HighlightESP")
        if old then old:Destroy() end
        local highlight = Instance.new("Highlight")
        highlight.Name="HighlightESP"
        highlight.FillColor=Color3.new(1,0,0)
        highlight.FillTransparency=0.5
        highlight.OutlineColor=Color3.new(1,1,1)
        highlight.OutlineTransparency=0
        highlight.Adornee=char
        highlight.Parent=char
    end
    if not HighlightConnections[player] then
        HighlightConnections[player] = player.CharacterAdded:Connect(function() if HighlightEnabled then task.wait(0.5) attachHighlight() end end)
    end
    if player.Character then attachHighlight() end
end

local function enableHighlightESP()
    HighlightEnabled = true
    for _, p in ipairs(Players:GetPlayers()) do createHighlightESP(p) end
    Players.PlayerAdded:Connect(function(p) if HighlightEnabled then createHighlightESP(p) end end)
end

local function disableHighlightESP()
    HighlightEnabled = false
    for _, p in ipairs(Players:GetPlayers()) do
        if HighlightConnections[p] then HighlightConnections[p]:Disconnect() HighlightConnections[p]=nil end
        if p.Character then local hl=p.Character:FindFirstChild("HighlightESP") if hl then hl:Destroy() end end
    end
end

CombatTab.AddToggle("ESP Highlight", false, function(state) if state then enableHighlightESP() else disableHighlightESP() end end)

-- ================= Hitbox (LOOP FIXED) - COR VERMELHA =================
local HitboxEnabled = false
local HitboxSize = 50
local HitboxTransparency = 0.7
local HitboxLoopConnection = nil

local function applyCustomHitbox(player)
    if player ~= LocalPlayer and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
            hrp.Transparency = HitboxTransparency
            hrp.BrickColor = BrickColor.new("Really red")
            hrp.Material = Enum.Material.Neon
            hrp.CanCollide = false
        end
    end
end

local function resetHitbox(player)
    if player ~= LocalPlayer and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Size = Vector3.new(2, 2, 1)
            hrp.Transparency = 0
            hrp.BrickColor = BrickColor.new("Medium stone grey")
            hrp.Material = Enum.Material.Plastic
            hrp.CanCollide = true
        end
    end
end

local function hitboxLoop()
    if not HitboxEnabled then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            applyCustomHitbox(player)
        end
    end
end

local function setupCharacterHook(player)
    player.CharacterAdded:Connect(function()
        if HitboxEnabled then
            repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            applyCustomHitbox(player)
        end
    end)
end

local function enableHitbox()
    HitboxEnabled = true
    
    -- Aplica em todos os jogadores existentes
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            setupCharacterHook(player)
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                applyCustomHitbox(player)
            end
        end
    end
    
    -- Conecta para novos jogadores
    Players.PlayerAdded:Connect(setupCharacterHook)
    
    -- Inicia o loop contínuo
    if HitboxLoopConnection then
        HitboxLoopConnection:Disconnect()
    end
    HitboxLoopConnection = RunService.Heartbeat:Connect(hitboxLoop)
end

local function disableHitbox()
    HitboxEnabled = false
    
    -- Para o loop
    if HitboxLoopConnection then
        HitboxLoopConnection:Disconnect()
        HitboxLoopConnection = nil
    end
    
    -- Restaura todos os hitboxes ao normal
    for _, player in ipairs(Players:GetPlayers()) do
        resetHitbox(player)
    end
end

CombatTab.AddToggle("Custom Hitbox On/Off", false, function(state)
        if state then 
            enableHitbox() 
        else 
            disableHitbox() 
        end
    end)

-- Input for Hitbox Size
CombatTab.AddInput("Hitbox Size", "", function(value)
        local num = tonumber(value)
        if num then HitboxSize = num end
    end)

-- Slider for Hitbox Transparency
CombatTab.AddSlider("Hitbox Transparency", 0, 10, 7, function(value)
        HitboxTransparency = value / 10
    end)

-- PLAYER HEAD HITBOX

_G.PlayerHeadSize = 25
_G.PlayerHitboxEnabled = false
_G.PlayerHitboxTransparency = 0.5

-- Guarda as propriedades originais de cada Head
local OriginalHeadProperties = {}

local function saveOriginalProperties(head)
    if not OriginalHeadProperties[head] then
        OriginalHeadProperties[head] = {
            Size = head.Size,
            Transparency = head.Transparency,
            CanCollide = head.CanCollide,
            Massless = head.Massless
        }
    end
end

local function applyHeadHitbox(head)
    if not head then return end

    saveOriginalProperties(head)

    head.Size = Vector3.new(
        _G.PlayerHeadSize,
        _G.PlayerHeadSize,
        _G.PlayerHeadSize
    )

    head.Transparency = _G.PlayerHitboxTransparency
    head.CanCollide = false
    head.Massless = true
end

local function applyPlayerHitbox()
    if not _G.PlayerHitboxEnabled then return end

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            local character = player.Character
            if character then
                local head = character:FindFirstChild("Head")

                if head then
                    applyHeadHitbox(head)
                end
            end
        end
    end
end

local function restoreOriginalSizes()
    for head, properties in pairs(OriginalHeadProperties) do
        if head and head.Parent then
            head.Size = properties.Size
            head.Transparency = properties.Transparency
            head.CanCollide = properties.CanCollide
            head.Massless = properties.Massless
        end
    end

    -- Limpa a tabela para que os valores sejam salvos
    -- novamente caso o sistema seja ativado depois.
    OriginalHeadProperties = {}
end

-- Monitorar novos players
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        task.wait(0.5)

        if _G.PlayerHitboxEnabled and player ~= game.Players.LocalPlayer then
            local head = character:FindFirstChild("Head")

            if head then
                applyHeadHitbox(head)
            end
        end
    end)
end)

-- Também monitora personagens que já existem
for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer then
        player.CharacterAdded:Connect(function(character)
            task.wait(0.5)

            if _G.PlayerHitboxEnabled then
                local head = character:FindFirstChild("Head")

                if head then
                    applyHeadHitbox(head)
                end
            end
        end)
    end
end

-- Loop de manutenção
task.spawn(function()
    while true do
        task.wait(1)

        if _G.PlayerHitboxEnabled then
            applyPlayerHitbox()
        end
    end
end)

-- TOGGLE
CombatTab.AddToggle("Enable Player Head Hitbox", false, function(Value)
        _G.PlayerHitboxEnabled = Value

        if Value then
            applyPlayerHitbox()
        else
            restoreOriginalSizes()
        end
    end)

-- TAMANHO
CombatTab.AddInput("Hitbox Size", "Enter size (default: 25)", function(Text)
        local size = tonumber(Text)

        if size and size > 0 then
            _G.PlayerHeadSize = size

            if _G.PlayerHitboxEnabled then
                applyPlayerHitbox()
            end
        end
    end)

-- TRANSPARÊNCIA
CombatTab.AddSlider("Hitbox Transparency", 0, 10, 5, function(Value)
        _G.PlayerHitboxTransparency = Value / 10

        if _G.PlayerHitboxEnabled then
            applyPlayerHitbox()
        end
    end)

-- ================= BODY LOCK TOGGLE =================
CombatTab.AddToggle("Body Lock", false, function(state)
        if state then
            enableBodyLock()
        else
            disableBodyLock()
        end
    end)

-- ================= BODY LOCK DISTANCE INPUT =================
CombatTab.AddInput("Body Lock Distance", "", function(value)
        local num = tonumber(value)
        if num and num > 0 then
            BodyLockRange = num
        end
    end)

-- ================= AIM FOV / AIM 360 =================
local AimFOVSettings = {
    Enabled = false,
    Aim360Enabled = false,
    FOVSize = 60,
    TeamCheck = false,
    WallCheck = false,
    MaxDistance = 5000,
    MaxTransparency = 0,
    AimPart = "Head"
}

-- Círculo visual: usado somente pelo Aim FOV tradicional.
local FOVring = Drawing.new("Circle")
FOVring.Visible = false
FOVring.Thickness = 2
FOVring.Color = Color3.fromRGB(255, 0, 0)
FOVring.Filled = false
FOVring.NumSides = 64
FOVring.Radius = AimFOVSettings.FOVSize
FOVring.Transparency = AimFOVSettings.MaxTransparency

local function updateFOVCircle()
    if Camera and Camera.ViewportSize then
        FOVring.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVring.Radius = AimFOVSettings.FOVSize
        FOVring.Visible = AimFOVSettings.Enabled and not AimFOVSettings.Aim360Enabled
    end
end

local function lookAt(target)
    if not (AimFOVSettings.Enabled or AimFOVSettings.Aim360Enabled) then return end
    local origin = Camera.CFrame.Position
    local offset = target - origin
    if offset.Magnitude > 0.001 then
        Camera.CFrame = CFrame.lookAt(origin, target)
    end
end

local function isPlayerAlive(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return humanoid ~= nil and humanoid.Health > 0
end

local function isPlayerVisibleThroughWalls(player, trg_part)
    if not AimFOVSettings.WallCheck then return true end
    local character = LocalPlayer.Character
    local targetCharacter = player.Character
    local part = targetCharacter and targetCharacter:FindFirstChild(trg_part)
    if not character or not part then return false end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character}
    local direction = part.Position - Camera.CFrame.Position
    local result = workspace:Raycast(Camera.CFrame.Position, direction, params)
    return result ~= nil and result.Instance:IsDescendantOf(targetCharacter)
end

-- Aim FOV normal: escolhe o jogador mais próximo do centro da tela.
local function getClosestPlayerInFOV()
    if not AimFOVSettings.Enabled or AimFOVSettings.Aim360Enabled then return nil end
    local nearest, last = nil, math.huge
    local center = Camera.ViewportSize / 2

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer
            and (not AimFOVSettings.TeamCheck or player.Team ~= LocalPlayer.Team)
            and isPlayerAlive(player) then
            local character = player.Character
            local part = character and character:FindFirstChild(AimFOVSettings.AimPart)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                local screenDistance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                local worldDistance = (part.Position - Camera.CFrame.Position).Magnitude
                if onScreen and screenDistance < last
                    and screenDistance <= AimFOVSettings.FOVSize
                    and worldDistance <= AimFOVSettings.MaxDistance
                    and isPlayerVisibleThroughWalls(player, AimFOVSettings.AimPart) then
                    nearest, last = player, screenDistance
                end
            end
        end
    end
    return nearest
end

-- Aim 360: ignora a posição na tela e procura em todas as direções,
-- escolhendo o jogador vivo mais próximo dentro do limite em studs.
local function getClosestPlayer360()
    if not AimFOVSettings.Aim360Enabled then return nil end
    local nearest, shortestDistance = nil, AimFOVSettings.MaxDistance

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer
            and (not AimFOVSettings.TeamCheck or player.Team ~= LocalPlayer.Team)
            and isPlayerAlive(player) then
            local character = player.Character
            local part = character and character:FindFirstChild(AimFOVSettings.AimPart)
            if part then
                local distance = (part.Position - Camera.CFrame.Position).Magnitude
                if distance < shortestDistance
                    and isPlayerVisibleThroughWalls(player, AimFOVSettings.AimPart) then
                    nearest, shortestDistance = player, distance
                end
            end
        end
    end
    return nearest
end

RunService.RenderStepped:Connect(function()
    updateFOVCircle()
    local closest
    if AimFOVSettings.Aim360Enabled then
        closest = getClosestPlayer360()
    elseif AimFOVSettings.Enabled then
        closest = getClosestPlayerInFOV()
    end

    if closest and closest.Character then
        local part = closest.Character:FindFirstChild(AimFOVSettings.AimPart)
        if part then
            lookAt(part.Position)
            FOVring.Color = Color3.fromRGB(0, 255, 0)
            return
        end
    end
    FOVring.Color = Color3.fromRGB(255, 0, 0)
end)

CombatTab.AddToggle("Aim FOV", false, function(state)
    AimFOVSettings.Enabled = state
    if state then AimFOVSettings.Aim360Enabled = false end
    updateFOVCircle()
end)

CombatTab.AddToggle("Aim 360", false, function(state)
    AimFOVSettings.Aim360Enabled = state
    if state then AimFOVSettings.Enabled = false end
    updateFOVCircle()
end)

CombatTab.AddSlider("FOV Size", 10, 200, AimFOVSettings.FOVSize, function(value)
    AimFOVSettings.FOVSize = value
    updateFOVCircle()
end)

CombatTab.AddToggle("Team Check", false, function(state)
    AimFOVSettings.TeamCheck = state
end)

CombatTab.AddToggle("Wall Check", false, function(state)
    AimFOVSettings.WallCheck = state
end)

CombatTab.AddButton("Camlock (Enygma Locker)", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/meqHVUZh"))()
end)

-- ================= PlayerTab =================
local WalkSpeed = 16
local JumpPower = 50
local loopWalkSpeed = false
local loopJumpPower = false
local originalWalkSpeed = 16
local originalJumpPower = 50

-- ================= Loop Functions =================
local function startLoopWalkSpeed()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        originalWalkSpeed = humanoid.WalkSpeed
    end
    loopWalkSpeed = true
end

local function stopLoopWalkSpeed()
    loopWalkSpeed = false
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = originalWalkSpeed
    end
end

local function startLoopJumpPower()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        originalJumpPower = humanoid.JumpPower
    end
    loopJumpPower = true
end

local function stopLoopJumpPower()
    loopJumpPower = false
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = originalJumpPower
    end
end

-- Loop to constantly apply WalkSpeed & JumpPower
task.spawn(function()
    while true do
        task.wait(0.1)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if loopWalkSpeed then humanoid.WalkSpeed = WalkSpeed end
            if loopJumpPower then humanoid.JumpPower = JumpPower end
        end
    end
end)

-- ================= WalkSpeed Input & Toggle =================
PlayerTab.AddInput("WalkSpeed", "16", function(value)
        local num = tonumber(value)
        if num then
            WalkSpeed = num
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.WalkSpeed = WalkSpeed end
        end
    end)

PlayerTab.AddToggle("Loop WalkSpeed", false, function(state)
        if state then startLoopWalkSpeed() else stopLoopWalkSpeed() end
    end)

-- ================= JumpPower Input & Toggle =================
PlayerTab.AddInput("JumpPower", "50", function(value)
        local num = tonumber(value)
        if num then
            JumpPower = num
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.UseJumpPower = true
                humanoid.JumpPower = JumpPower
            end
        end
    end)

PlayerTab.AddToggle("Loop JumpPower", false, function(state)
        if state then startLoopJumpPower() else stopLoopJumpPower() end
    end)

-- ================= GRAVIDADE =================
local GravityValue = 196.2 -- Valor padrão do Roblox
local loopGravity = false
local originalGravity = Workspace.Gravity

local function startLoopGravity()
    originalGravity = Workspace.Gravity
    loopGravity = true
end

local function stopLoopGravity()
    loopGravity = false
    Workspace.Gravity = originalGravity
end

-- Loop para aplicar gravidade constantemente
task.spawn(function()
    while true do
        task.wait(0.1)
        if loopGravity then
            Workspace.Gravity = GravityValue
        end
    end
end)

-- Input para Gravidade
PlayerTab.AddInput("Gravity Value", "196.2", function(value)
        local num = tonumber(value)
        if num then
            GravityValue = num
            Workspace.Gravity = GravityValue
        end
    end)

-- Toggle para ativar/desativar loop da gravidade
PlayerTab.AddToggle("Loop Gravity", false, function(state)
        if state then 
            startLoopGravity() 
        else 
            stopLoopGravity() 
        end
    end)

-- ================= HIPHEIGHT =================
local HipHeightValue = 0 -- Valor padrão (normalmente 0 ou 2 dependendo do jogo)
local loopHipHeight = false
local originalHipHeight = 0

local function getHumanoid()
    if LocalPlayer.Character then
        return LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

local function startLoopHipHeight()
    local humanoid = getHumanoid()
    if humanoid then
        originalHipHeight = humanoid.HipHeight
    end
    loopHipHeight = true
end

local function stopLoopHipHeight()
    loopHipHeight = false
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.HipHeight = originalHipHeight
    end
end

-- Loop para aplicar HipHeight constantemente
task.spawn(function()
    while true do
        task.wait(0.1)
        if loopHipHeight then
            local humanoid = getHumanoid()
            if humanoid then
                humanoid.HipHeight = HipHeightValue
            end
        end
    end
end)

-- Input para HipHeight
PlayerTab.AddInput("HipHeight Value", "0", function(value)
        local num = tonumber(value)
        if num then
            HipHeightValue = num
            local humanoid = getHumanoid()
            if humanoid then humanoid.HipHeight = HipHeightValue end
        end
    end)

-- Toggle para ativar/desativar loop do HipHeight
PlayerTab.AddToggle("Loop HipHeight", false, function(state)
        if state then 
            startLoopHipHeight() 
        else 
            stopLoopHipHeight() 
        end
    end)

-- ================= Infinite Jump =================
local infiniteJumpEnabled = false
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

PlayerTab.AddToggle("Infinite Jump", false, function(state)
        infiniteJumpEnabled = state
    end)

-- ================= NoClip =================
local noclipEnabled = false
PlayerTab.AddToggle("NoClip", false, function(state)
        noclipEnabled = state
    end)

RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Script Local (Client-Sided)
-- Botão Toggle Anti-Fling na PlayerTab para Rayfield

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local isEnabled = false
local characterConnections = {}
local trackedCharacters = {}

local function applyCollisionState(character, enabled)
    if not character then return end
    
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.CanCollide = not enabled
        end
    end
end

local function setupCharacter(character)
    if not character or character == localPlayer.Character then return end
    
    if trackedCharacters[character] then
        for _, conn in ipairs(trackedCharacters[character]) do
            conn:Disconnect()
        end
        trackedCharacters[character] = nil
    end
    
    applyCollisionState(character, isEnabled)
    
    local connections = {}
    
    local childAddedConn = character.ChildAdded:Connect(function(part)
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.CanCollide = not isEnabled
        end
    end)
    table.insert(connections, childAddedConn)
    
    local steppedConn = RunService.Stepped:Connect(function()
        if character and character:IsDescendantOf(workspace) then
            for _, part in ipairs(character:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    local shouldCollide = not isEnabled
                    if part.CanCollide ~= shouldCollide then
                        part.CanCollide = shouldCollide
                    end
                end
            end
        end
    end)
    table.insert(connections, steppedConn)
    
    local destroyingConn = character.Destroying:Connect(function()
        if trackedCharacters[character] then
            for _, conn in ipairs(trackedCharacters[character]) do
                conn:Disconnect()
            end
            trackedCharacters[character] = nil
        end
    end)
    table.insert(connections, destroyingConn)
    
    trackedCharacters[character] = connections
end

local function trackPlayer(player)
    if player == localPlayer then return end
    
    if player.Character then
        setupCharacter(player.Character)
    end
    
    local charAddedConn = player.CharacterAdded:Connect(function(character)
        setupCharacter(character)
    end)
    
    characterConnections[player] = charAddedConn
end

local function untrackPlayer(player)
    if characterConnections[player] then
        characterConnections[player]:Disconnect()
        characterConnections[player] = nil
    end
    
    if player.Character and trackedCharacters[player.Character] then
        for _, conn in ipairs(trackedCharacters[player.Character]) do
            conn:Disconnect()
        end
        trackedCharacters[player.Character] = nil
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    trackPlayer(player)
end

Players.PlayerAdded:Connect(trackPlayer)
Players.PlayerRemoving:Connect(untrackPlayer)

local Toggle = PlayerTab.AddToggle("Anti-Fling", false, function(Value)
        isEnabled = Value
        
        for character, _ in pairs(trackedCharacters) do
            if character and character:IsDescendantOf(workspace) then
                applyCollisionState(character, isEnabled)
            end
        end
    end)

localPlayer.Chatted:Connect(function(msg)
    msg = msg:lower()
    if msg == ";af on" then
        isEnabled = true
        for character, _ in pairs(trackedCharacters) do
            if character and character:IsDescendantOf(workspace) then
                applyCollisionState(character, true)
            end
        end
    elseif msg == ";af off" then
        isEnabled = false
        for character, _ in pairs(trackedCharacters) do
            if character and character:IsDescendantOf(workspace) then
                applyCollisionState(character, false)
            end
        end
    end
end)

local function cleanup()
    for player, conn in pairs(characterConnections) do
        conn:Disconnect()
    end
    characterConnections = {}
    
    for character, conns in pairs(trackedCharacters) do
        for _, conn in ipairs(conns) do
            conn:Disconnect()
        end
    end
    trackedCharacters = {}
end

localPlayer.CharacterAdded:Connect(function()
    cleanup()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            trackPlayer(player)
        end
    end
end)

-- =========================
-- PLAYER XRAY
-- =========================

local XRayEnabled = false
local XRayTransparency = 0.7

local function setXRay(enabled)
    XRayEnabled = enabled

    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("BasePart") then
            if enabled then
                -- Não altera partes dos personagens dos jogadores
                local character = object:FindFirstAncestorOfClass("Model")

                if character and character:FindFirstChildOfClass("Humanoid") then
                    continue
                end

                object.LocalTransparencyModifier = XRayTransparency
            else
                object.LocalTransparencyModifier = 0
            end
        end
    end
end

PlayerTab.AddToggle("XRay", false, function(Value)
        setXRay(Value)
    end)

--// Prevent duplicate execution
if _G.FlyForRayfieldLoaded then return end
_G.FlyForRayfieldLoaded = true

--// Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

--// Player & Character
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

--// Configuration
local flySpeed = 50
local flyTransparency = 1
local FLYING = false
local CFloop

--// Control scheme
local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}

--// Flight Function (CFrame Mode only)
local function startCFrameFlyLoop()
    if not character or not character:FindFirstChild("Head") then return end 
    FLYING = true
    local Head = character.Head 
    Head.Anchored = true
    CFloop = RunService.Heartbeat:Connect(function(deltaTime)
        local effectiveSpeed = flySpeed * 2
        local moveDirection = humanoid.MoveDirection * (effectiveSpeed * deltaTime)
        local headCFrame, camera = Head.CFrame, workspace.CurrentCamera 
        local cameraCFrame = camera.CFrame
        local cameraOffset = headCFrame:ToObjectSpace(cameraCFrame).Position
        cameraCFrame = cameraCFrame * CFrame.new(-cameraOffset.X, -cameraOffset.Y, -cameraOffset.Z + 1)
        local cameraPosition, headPosition = cameraCFrame.Position, headCFrame.Position
        local objectSpaceVelocity = CFrame.new(cameraPosition, Vector3.new(headPosition.X, cameraPosition.Y, headPosition.Z)):VectorToObjectSpace(moveDirection)
        Head.CFrame = CFrame.new(headPosition) * (cameraCFrame - cameraPosition) * CFrame.new(objectSpaceVelocity)
    end)
end

--// Set Flying Function
local function setFlying(state)
    if FLYING == state or not character or not character.Parent then return end
    
    if state then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then 
                part.Transparency = flyTransparency 
            end
        end
        for _, part in ipairs(character:GetDescendants()) do 
            if part:IsA("BasePart") then 
                part.CanCollide = false 
            end 
        end
        startCFrameFlyLoop()
    else
        FLYING = false
        if CFloop then 
            CFloop:Disconnect()
            CFloop = nil 
        end
        if character and character:FindFirstChild("Head") then 
            character.Head.Anchored = false 
        end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
                if part.Name ~= "HumanoidRootPart" then 
                    part.Transparency = 0 
                end
            end
        end
    end
end

--// Keybind Handlers
local keyMap = {
    [Enum.KeyCode.W] = "F",
    [Enum.KeyCode.S] = "B",
    [Enum.KeyCode.A] = "L",
    [Enum.KeyCode.D] = "R",
    [Enum.KeyCode.Q] = "Q",
    [Enum.KeyCode.E] = "E"
}

local valueMap = {
    [Enum.KeyCode.W] = 1,
    [Enum.KeyCode.S] = -1,
    [Enum.KeyCode.A] = -1,
    [Enum.KeyCode.D] = 1,
    [Enum.KeyCode.Q] = -1,
    [Enum.KeyCode.E] = 1
}

UserInputService.InputBegan:Connect(function(input, gpe) 
    if gpe or not keyMap[input.KeyCode] then return end 
    CONTROL[keyMap[input.KeyCode]] = valueMap[input.KeyCode] 
end)

UserInputService.InputEnded:Connect(function(input) 
    if keyMap[input.KeyCode] then 
        CONTROL[keyMap[input.KeyCode]] = 0 
    end 
end)

--// Respawn Handler
player.CharacterAdded:Connect(function(newChar)
    if CFloop then 
        CFloop:Disconnect()
        CFloop = nil 
    end
    FLYING = false
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
end)

--// =============================================
--// PARA USAR NO SEU RAYFIELD HUB
--// Cole este código dentro do seu PlayerTab
--// =============================================

--// Primeiro, certifique-se que você já tem a Rayfield carregada e uma janela criada
--// Exemplo: local Window = Rayfield:CreateWindow(...)
--// Exemplo: local PlayerTab = UI.CreateTab("Player")

--// Toggle Fly no seu PlayerTab
local FlyToggle = PlayerTab.AddToggle("Fly spectator mode", false, function(Value)
        setFlying(Value)
    end)

--// Input de velocidade no seu PlayerTab
local SpeedInput = PlayerTab.AddInput("Fly Speed", "Enter speed (1-500)", function(Text)
        local speed = tonumber(Text)
        if speed and speed >= 1 and speed <= 500 then
            flySpeed = speed
        end
    end)

-- Estado do invisível
local isInvisible = false

-- Função que contém a lógica de invisibilidade
local function toggleInvisibility()
	if not game.Players.LocalPlayer.Character then return end
	isInvisible = not isInvisible
	
	local player = game.Players.LocalPlayer
	local char = player.Character
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	if isInvisible then
		local savedPosition = hrp.CFrame
		player.Character:MoveTo(Vector3.new(-25.95, 84, 3537.55)) -- posição invisível
		task.wait(0.15)
		
		local seat = Instance.new("Seat")
		seat.Name = "invischair"
		seat.Anchored = false
		seat.CanCollide = false
		seat.Transparency = 1
		seat.Position = Vector3.new(-25.95, 84, 3537.55)
		seat.Parent = workspace
		
		local weld = Instance.new("Weld")
		weld.Part0 = seat
		weld.Part1 = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
		weld.Parent = seat
		
		task.wait()
		seat.CFrame = savedPosition
		
		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("Decal") then
				part.Transparency = 0.5
			end
		end
	else
		local invisChair = workspace:FindFirstChild("invischair")
		if invisChair then invisChair:Destroy() end
		
		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("Decal") then
				part.Transparency = 0
			end
		end
	end
end

-- Botão Toggle Rayfield
PlayerTab.AddToggle("Invisibility", false, function(value)
		toggleInvisibility()
	end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local platform = nil
local connection = nil
local offsetY = -3.5 -- valor padrão

-- INPUT para mudar a altura
PlayerTab.AddInput("Platform height", "-3.5", function(Text)
		local number = tonumber(Text)
		if number then
			offsetY = number
		end
	end)

-- TOGGLE da plataforma
PlayerTab.AddToggle("Platform", false, function(Value)

		if Value then
			local character = player.Character or player.CharacterAdded:Wait()
			local hrp = character:WaitForChild("HumanoidRootPart")

			platform = Instance.new("Part")
			platform.Size = Vector3.new(6, 1, 6)
			platform.Anchored = true
			platform.CanCollide = true
			platform.Transparency = 0.7
			platform.Color = Color3.fromRGB(255, 0, 0)
			platform.Name = "FloatingPlatform"
			platform.Parent = workspace

			connection = RunService.RenderStepped:Connect(function()
				if character and hrp and platform then
					platform.Position = hrp.Position + Vector3.new(0, offsetY, 0)
				end
			end)

		else
			if connection then
				connection:Disconnect()
				connection = nil
			end

			if platform then
				platform:Destroy()
				platform = nil
			end
		end

	end)

-- ================= Anti-AFK =================
PlayerTab.AddButton("Anti-AFK", function()
        LocalPlayer.Idled:Connect(function()
            local vu = game:GetService("VirtualUser")
            vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end)

-- ================= Anti-Lag (sem notificação) =================
PlayerTab.AddButton("Anti-Lag", function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
                obj.Enabled = false
            elseif obj:IsA("Explosion") then
                obj:Destroy()
            elseif obj:IsA("Decal") then
                obj.Transparency = 1
            elseif obj:IsA("Texture") then
                obj:Destroy()
            end
        end
        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        lighting.FogEnd = 100000
        lighting.FogStart = 0
        lighting.FogColor = Color3.new(1,1,1)
        lighting.Brightness = 1

        -- Notificação removida conforme solicitado
    end)

-- ================= TP Tool =================
PlayerTab.AddButton("Give TP Tool", function()
        local player = game.Players.LocalPlayer
        local backpack = player:WaitForChild("Backpack")

        -- Remove a Tool antiga, se existir
        if backpack:FindFirstChild("EnygmaTp") then
            backpack:FindFirstChild("EnygmaTp"):Destroy()
        end
        if player.Character and player.Character:FindFirstChild("EnygmaTp") then
            player.Character:FindFirstChild("EnygmaTp"):Destroy()
        end

        -- Cria a Tool
        local mouse = player:GetMouse()
        local tool = Instance.new("Tool")
        tool.RequiresHandle = false
        tool.Name = "EnygmaTp"

        tool.Activated:Connect(function()
            local pos = mouse.Hit + Vector3.new(0, 2.5, 0)
            pos = CFrame.new(pos.X, pos.Y, pos.Z)
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = pos
            end
        end)
        tool.Parent = backpack
    end)

-- NPC HIGHLIGHT ESP (tab NPCS⚡ / FarmTab)
local NPCHighlightEnabled = false
local NPCHighlightConnection = nil
local NPCHighlights = {}

local function getNPCModelFromInstance(instance)
    local model = instance:IsA("Model") and instance or instance:FindFirstAncestorOfClass("Model")
    if not model or Players:GetPlayerFromCharacter(model) then return nil end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end
    return model
end

local function addNPCHighlight(model)
    if not NPCHighlightEnabled or not model or not model.Parent then return end
    if Players:GetPlayerFromCharacter(model) or NPCHighlights[model] then return end

    local highlight = model:FindFirstChild("Enygma_NPC_Highlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "Enygma_NPC_Highlight"
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Adornee = model
        highlight.Parent = model
    end
    NPCHighlights[model] = highlight
end

local function scanNPCHighlights()
    if not NPCHighlightEnabled then return end
    for _, instance in ipairs(workspace:GetDescendants()) do
        if instance:IsA("Humanoid") then
            local model = getNPCModelFromInstance(instance)
            if model then addNPCHighlight(model) end
        end
    end
end

local function disableNPCHighlight()
    NPCHighlightEnabled = false
    if NPCHighlightConnection then
        NPCHighlightConnection:Disconnect()
        NPCHighlightConnection = nil
    end
    for model, highlight in pairs(NPCHighlights) do
        if highlight and highlight.Parent then highlight:Destroy() end
        NPCHighlights[model] = nil
    end
    -- Também limpa instâncias antigas criadas pela versão anterior deste ESP.
    for _, instance in ipairs(workspace:GetDescendants()) do
        if instance:IsA("Highlight") and instance.Name == "NPC_ESP" then
            instance:Destroy()
        end
    end
end

local function enableNPCHighlight()
    disableNPCHighlight()
    NPCHighlightEnabled = true
    scanNPCHighlights()
    NPCHighlightConnection = workspace.DescendantAdded:Connect(function(instance)
        if not NPCHighlightEnabled then return end
        if instance:IsA("Humanoid") then
            task.defer(function()
                local model = getNPCModelFromInstance(instance)
                if model then addNPCHighlight(model) end
            end)
        elseif instance:IsA("Model") then
            task.defer(function()
                if instance:FindFirstChildOfClass("Humanoid") then
                    local model = getNPCModelFromInstance(instance)
                    if model then addNPCHighlight(model) end
                end
            end)
        end
    end)
end

FarmTab.AddToggle("NPC Highlight ESP", false, function(state)
    if state then
        enableNPCHighlight()
    else
        disableNPCHighlight()
    end
end)

end -- end scoped tab locals
do -- scoped tab locals

-- NPC Name ESP (Rayfield Toggle)

local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local NPCESP = false
local drawings = {}
local renderConn
local addConn

local function addESP(model)
if not NPCESP then return end
if Players:GetPlayerFromCharacter(model) then return end
if drawings[model] then return end

local root = model:FindFirstChild("HumanoidRootPart")
if not root then return end

local text = Drawing.new("Text")
text.Size = 16
text.Center = true
text.Outline = true
text.Color = Color3.fromRGB(255,0,0)
text.Text = model.Name
text.Visible = false

drawings[model] = text

end

local function enableESP()

-- NPCs existentes
for _,v in pairs(workspace:GetDescendants()) do
    if v:IsA("Humanoid") and v.Parent then
        addESP(v.Parent)
    end
end

-- NPCs novos / respawn
addConn = workspace.DescendantAdded:Connect(function(v)
    if v:IsA("Humanoid") and v.Parent then
        task.wait()
        addESP(v.Parent)
    end
end)

-- Atualizar posição do texto
renderConn = RunService.RenderStepped:Connect(function()
    for model,draw in pairs(drawings) do
        if model and model:FindFirstChild("HumanoidRootPart") then
            local pos, visible = Camera:WorldToViewportPoint(model.HumanoidRootPart.Position)

            if visible then
                draw.Position = Vector2.new(pos.X, pos.Y)
                draw.Visible = true
            else
                draw.Visible = false
            end
        else
            draw:Remove()
            drawings[model] = nil
        end
    end
end)

end

local function disableESP()

if addConn then addConn:Disconnect() end
if renderConn then renderConn:Disconnect() end

for _,v in pairs(drawings) do
    v:Remove()
end

drawings = {}

end

FarmTab.AddToggle("NPC Name ESP", false, function(v)
NPCESP = v
if v then
enableESP()
else
disableESP()
end
end)

-- =========================================================
-- NPC HITBOX 1: HUMANOIDROOTPART
-- =========================================================
-- Este sistema mexe SOMENTE no HumanoidRootPart dos NPCs.
local NPCBodyHitboxEnabled = false
local NPCBodyHitboxSize = 50
local NPCBodyHitboxTransparency = 0.7
local NPCBodyHitboxOriginals = {}
local NPCBodyHitboxConnection = nil

local function isNPCBodyModel(model)
    if not model or not model:IsA("Model") then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    return model:FindFirstChildOfClass("Humanoid") ~= nil
        and model:FindFirstChild("HumanoidRootPart") ~= nil
end

local function saveNPCBodyOriginal(root)
    if NPCBodyHitboxOriginals[root] then return end
    NPCBodyHitboxOriginals[root] = {
        Size = root.Size,
        Transparency = root.Transparency,
        CanCollide = root.CanCollide,
        Material = root.Material,
        BrickColor = root.BrickColor,
        Massless = root.Massless,
    }
end

local function applyNPCBodyHitbox(model)
    if not NPCBodyHitboxEnabled or not isNPCBodyModel(model) then return end
    local root = model:FindFirstChild("HumanoidRootPart")
    if not root then return end

    saveNPCBodyOriginal(root)
    pcall(function()
        root.Size = Vector3.new(NPCBodyHitboxSize, NPCBodyHitboxSize, NPCBodyHitboxSize)
        root.Transparency = NPCBodyHitboxTransparency
        root.BrickColor = BrickColor.new("Really blue")
        root.Material = Enum.Material.Neon
        root.CanCollide = false
        root.Massless = true
    end)
end

local function restoreNPCBodyHitbox()
    for root, original in pairs(NPCBodyHitboxOriginals) do
        if root and root.Parent then
            pcall(function()
                root.Size = original.Size
                root.Transparency = original.Transparency
                root.CanCollide = original.CanCollide
                root.Material = original.Material
                root.BrickColor = original.BrickColor
                root.Massless = original.Massless
            end)
        end
    end
    table.clear(NPCBodyHitboxOriginals)
end

local function scanNPCBodyHitbox()
    if not NPCBodyHitboxEnabled then return end
    for _, model in ipairs(workspace:GetDescendants()) do
        if model:IsA("Model") and isNPCBodyModel(model) then
            applyNPCBodyHitbox(model)
        end
    end
end

local function stopNPCBodyHitbox()
    NPCBodyHitboxEnabled = false
    if NPCBodyHitboxConnection then
        NPCBodyHitboxConnection:Disconnect()
        NPCBodyHitboxConnection = nil
    end
    restoreNPCBodyHitbox()
end

local function startNPCBodyHitbox()
    stopNPCBodyHitbox()
    NPCBodyHitboxEnabled = true
    scanNPCBodyHitbox()

    NPCBodyHitboxConnection = workspace.DescendantAdded:Connect(function(instance)
        if not NPCBodyHitboxEnabled then return end
        local model = instance:IsA("Model") and instance or instance:FindFirstAncestorOfClass("Model")
        if model then
            task.defer(function()
                if NPCBodyHitboxEnabled then
                    applyNPCBodyHitbox(model)
                end
            end)
        end
    end)
end

FarmTab.AddToggle("NPC Hitbox (RootPart)", false, function(Value)
        if Value then startNPCBodyHitbox() else stopNPCBodyHitbox() end
    end)

FarmTab.AddInput("RootPart Hitbox Size", "50", function(Text)
        local size = tonumber(Text)
        if size and size > 0 then
            NPCBodyHitboxSize = size
            if NPCBodyHitboxEnabled then scanNPCBodyHitbox() end
        end
    end)

FarmTab.AddSlider("RootPart Hitbox Transparency", 0, 10, 7, function(Value)
        NPCBodyHitboxTransparency = Value / 10
        if NPCBodyHitboxEnabled then scanNPCBodyHitbox() end
    end)

-- =========================================================
-- NPC HITBOX 2: HEAD
-- =========================================================
-- Este sistema mexe SOMENTE na Head dos NPCs.
local NPCHeadHitboxEnabled = false
local NPCHeadHitboxSize = 12
local NPCHeadHitboxTransparency = 0.6
local NPCHeadHitboxOriginals = {}
local NPCHeadHitboxConnection = nil

local function isNPCHeadModel(model)
    if not model or not model:IsA("Model") then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    return model:FindFirstChildOfClass("Humanoid") ~= nil
        and model:FindFirstChild("Head") ~= nil
end

local function saveNPCHeadOriginal(head)
    if NPCHeadHitboxOriginals[head] then return end
    NPCHeadHitboxOriginals[head] = {
        Size = head.Size,
        Transparency = head.Transparency,
        CanCollide = head.CanCollide,
        Massless = head.Massless,
    }
end

local function applyNPCHeadHitbox(model)
    if not NPCHeadHitboxEnabled or not isNPCHeadModel(model) then return end
    local head = model:FindFirstChild("Head")
    if not head then return end

    saveNPCHeadOriginal(head)
    pcall(function()
        head.Size = Vector3.new(NPCHeadHitboxSize, NPCHeadHitboxSize, NPCHeadHitboxSize)
        head.Transparency = NPCHeadHitboxTransparency
        head.CanCollide = false
        head.Massless = true
    end)
end

local function restoreNPCHeadHitbox()
    for head, original in pairs(NPCHeadHitboxOriginals) do
        if head and head.Parent then
            pcall(function()
                head.Size = original.Size
                head.Transparency = original.Transparency
                head.CanCollide = original.CanCollide
                head.Massless = original.Massless
            end)
        end
    end
    table.clear(NPCHeadHitboxOriginals)
end

local function scanNPCHeadHitbox()
    if not NPCHeadHitboxEnabled then return end
    for _, model in ipairs(workspace:GetDescendants()) do
        if model:IsA("Model") and isNPCHeadModel(model) then
            applyNPCHeadHitbox(model)
        end
    end
end

local function stopNPCHeadHitbox()
    NPCHeadHitboxEnabled = false
    if NPCHeadHitboxConnection then
        NPCHeadHitboxConnection:Disconnect()
        NPCHeadHitboxConnection = nil
    end
    restoreNPCHeadHitbox()
end

local function startNPCHeadHitbox()
    stopNPCHeadHitbox()
    NPCHeadHitboxEnabled = true
    scanNPCHeadHitbox()

    NPCHeadHitboxConnection = workspace.DescendantAdded:Connect(function(instance)
        if not NPCHeadHitboxEnabled then return end
        local model = instance:IsA("Model") and instance or instance:FindFirstAncestorOfClass("Model")
        if model then
            task.defer(function()
                if NPCHeadHitboxEnabled then
                    applyNPCHeadHitbox(model)
                end
            end)
        end
    end)
end

FarmTab.AddToggle("NPC Hitbox (Head)", false, function(Value)
        if Value then startNPCHeadHitbox() else stopNPCHeadHitbox() end
    end)

FarmTab.AddInput("Head Hitbox Size", "12", function(Text)
        local size = tonumber(Text)
        if size and size > 0 then
            NPCHeadHitboxSize = size
            if NPCHeadHitboxEnabled then scanNPCHeadHitbox() end
        end
    end)

FarmTab.AddSlider("Head Hitbox Transparency", 0, 10, 6, function(Value)
        NPCHeadHitboxTransparency = Value / 10
        if NPCHeadHitboxEnabled then scanNPCHeadHitbox() end
    end)

-- =============================================
-- SCRIPT COMPLETO AIMBOT NPC COM BOTÕES
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configurações
_G.AimbotNPC = false
_G.WallCheck = false
_G.FOV_Size = 150

-- Círculo FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 0
FOVCircle.Visible = false
FOVCircle.Radius = _G.FOV_Size

-- =============================================
-- BOTÕES PARA SUA FARM TAB
-- =============================================

-- Toggle Aimbot NPC
FarmTab.AddToggle("Aimbot NPC", false, function(Value)
        _G.AimbotNPC = Value
    end)

-- Toggle Wall Check
FarmTab.AddToggle("Wall Check", false, function(Value)
        _G.WallCheck = Value
    end)

-- Slider FOV Size
FarmTab.AddSlider("FOV Size", 10, 200, 150, function(Value)
        _G.FOV_Size = Value
        FOVCircle.Radius = Value
    end)

-- =============================================
-- LÓGICA DO AIMBOT NPC
-- =============================================

-- Função para encontrar NPCs
local function GetTarget()
    local target = nil
    local dist = _G.FOV_Size
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Humanoid") and v.Parent and v.Parent:FindFirstChild("Head") and v.Health > 0 then
            if v.Parent ~= LocalPlayer.Character then
                local head = v.Parent.Head
                -- Verifica se NÃO é um jogador (NPC)
                if not Players:GetPlayerFromCharacter(v.Parent) then
                    local pos, visible = Camera:WorldToViewportPoint(head.Position)
                    if visible then
                        local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if mag < dist then
                            -- Wall Check
                            if _G.WallCheck then
                                local parts = Camera:GetPartsObscuringTarget({Camera.CFrame.Position, head.Position}, {LocalPlayer.Character, v.Parent})
                                if #parts == 0 then 
                                    target = head
                                    dist = mag
                                end
                            else
                                target = head
                                dist = mag
                            end
                        end
                    end
                end
            end
        end
    end
    return target
end

-- Loop principal
RunService.RenderStepped:Connect(function()
    -- Centraliza o FOV no meio da tela
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Position = screenCenter
    FOVCircle.Radius = _G.FOV_Size
    
    -- Se o Aimbot NPC estiver ligado, busca o alvo
    if _G.AimbotNPC then
        local t = GetTarget()
        if t then
            -- Mira instantânea
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position)
        end
    end
end)

-- =========================================================
-- ITENS / TELEPORTES / TROLL
-- Em um bloco separado para não estourar o limite de locals do script principal.
-- =========================================================
local function SetupItemsTeleportsTroll()
    -- Rayfield Toggle - Item ESP

    local ESPEnabled = false
    local ESPColor = Color3.fromRGB(255,0,0)

    local function createESP(obj)
        if obj:FindFirstChild("ItemESP") then return end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ItemESP"
        billboard.Size = UDim2.new(0,70,0,30) -- tamanho menor
        billboard.AlwaysOnTop = true
        billboard.Adornee = obj
        billboard.Parent = obj

        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1,0,1,0)
        label.Text = obj.Name
        label.TextColor3 = ESPColor
        label.TextStrokeTransparency = 0
        label.TextScaled = true
        label.Font = Enum.Font.SourceSansBold
        label.Parent = billboard
    end

    local function removeESP()
        for _,v in pairs(workspace:GetDescendants()) do
            if v:FindFirstChild("ItemESP") then
                v.ItemESP:Destroy()
            end
        end
    end

    local function scan()
        for _,v in pairs(workspace:GetDescendants()) do
        
            if v:IsA("ProximityPrompt") or v:IsA("ClickDetector") then
                local parent = v.Parent
            
                if parent and parent:IsA("BasePart") then
                    createESP(parent)
                end
            end
        
            if v:IsA("Tool") then
                if v:FindFirstChild("Handle") then
                    createESP(v.Handle)
                end
            end
        
        end
    end

    workspace.DescendantAdded:Connect(function(v)
        task.wait(0.5)

        if not ESPEnabled then return end

        if v:IsA("ProximityPrompt") or v:IsA("ClickDetector") then
            local parent = v.Parent
            if parent and parent:IsA("BasePart") then
                createESP(parent)
            end
        end
    
        if v:IsA("Tool") then
            if v:FindFirstChild("Handle") then
                createESP(v.Handle)
            end
        end
    end)

    -- Toggle no Rayfield
end -- end scoped tab locals
do -- scoped tab locals
    ItemsTab.AddToggle("Item ESP", false, function(Value)
            ESPEnabled = Value
        
            if ESPEnabled then
                scan()
            else
                removeESP()
            end
        end)

    -- Highlight Item ESP (Rayfield)

    local HighlightEnabled = false
    local HighlightColor = Color3.fromRGB(255,0,0)

    local function createHighlight(obj)
        if obj:FindFirstChild("ItemHighlight") then return end

        local highlight = Instance.new("Highlight")
        highlight.Name = "ItemHighlight"
        highlight.FillColor = HighlightColor
        highlight.OutlineColor = HighlightColor
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = obj
    end

    local function removeHighlights()
        for _,v in pairs(workspace:GetDescendants()) do
            if v:FindFirstChild("ItemHighlight") then
                v.ItemHighlight:Destroy()
            end
        end
    end

    local function scanItems()
        for _,v in pairs(workspace:GetDescendants()) do
        
            if v:IsA("ProximityPrompt") or v:IsA("ClickDetector") then
                local parent = v.Parent
                if parent and parent:IsA("BasePart") then
                    createHighlight(parent)
                end
            end
        
            if v:IsA("Tool") then
                if v:FindFirstChild("Handle") then
                    createHighlight(v.Handle)
                end
            end
        
        end
    end

    workspace.DescendantAdded:Connect(function(v)
        task.wait(0.5)

        if not HighlightEnabled then return end

        if v:IsA("ProximityPrompt") or v:IsA("ClickDetector") then
            local parent = v.Parent
            if parent and parent:IsA("BasePart") then
                createHighlight(parent)
            end
        end
    
        if v:IsA("Tool") then
            if v:FindFirstChild("Handle") then
                createHighlight(v.Handle)
            end
        end
    end)

    ItemsTab.AddToggle("Item Highlight ESP", false, function(Value)
            HighlightEnabled = Value
        
            if HighlightEnabled then
                scanItems()
            else
                removeHighlights()
            end
        end)

    -- Botão Click All ClickDetectors

    local function clickAll()
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("ClickDetector") then
                fireclickdetector(v)
            end
        end
    end

    ItemsTab.AddButton("Click All ClickDetectors", function()
            clickAll()
        end)

    -- Touch Item by Name

    local ItemName = ""

    ItemsTab.AddInput("Item Name", "item", function(Text)
            ItemName = Text
        end)

    local function getTouchItem(name)
        local player = game.Players.LocalPlayer
        local char = player.Character
        if not char then return end
    
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name:lower():find(name:lower()) then
                v.CFrame = hrp.CFrame
            end
        end
    end

    ItemsTab.AddButton("Get Touch Item", function()
            if ItemName ~= "" then
                getTouchItem(ItemName)
            end
        end)

    -- Instant ProximityPrompt Button

    local function makePromptsInstant()
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                v.HoldDuration = 0
            end
        end
    end

    ItemsTab.AddButton("Instant ProximityPrompts", function()
            makePromptsInstant()
        end)

    -- Prompt Range Changer

    local PromptRange = 10

    ItemsTab.AddInput("Prompt Range", "Ex: 50", function(Text)
            local num = tonumber(Text)
            if num then
                PromptRange = num
            end
        end)

    local function setPromptRange()
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                v.MaxActivationDistance = PromptRange
            end
        end
    end

    ItemsTab.AddButton("Set Prompt Range", function()
            setPromptRange()
        end)

    -- Teleport / Loop TP / Loop Bring System

    local TargetName = ""
    local LoopTP = false
    local LoopBring = false

    local player = game.Players.LocalPlayer

    TeleportsTab.AddInput("Target Name", "Player / NPC / Item", function(Text)
            TargetName = Text
        end)

    local function findTarget()

        -- procurar players
        for _,p in pairs(game.Players:GetPlayers()) do
            if p.Name:lower():find(TargetName:lower()) then
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    return p.Character.HumanoidRootPart
                end
            end
        end

        -- procurar NPC / itens
        for _,v in pairs(workspace:GetDescendants()) do
            if v.Name:lower():find(TargetName:lower()) then
            
                if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
                    return v.HumanoidRootPart
                
                elseif v:IsA("BasePart") then
                    return v
                end
            
            end
        end

    end

    local function teleportBehindTarget()

        local char = player.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local target = findTarget()

        if hrp and target then
            local behind = target.CFrame.LookVector * -5
            local pos = target.Position + behind
            hrp.CFrame = CFrame.new(pos, target.Position)
        end

    end

    local function bringTarget()

        local char = player.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local target = findTarget()

        if hrp and target then
            local forward = hrp.CFrame.LookVector * 6
            local pos = hrp.Position + forward
            target.CFrame = CFrame.new(pos)
        end

    end

    TeleportsTab.AddButton("Teleport Behind Target", function()
            teleportBehindTarget()
        end)

    TeleportsTab.AddToggle("Loop Teleport Behind", false, function(Value)
            LoopTP = Value

            while LoopTP do
                teleportBehindTarget()
                task.wait(0.05)
            end
        end)

    TeleportsTab.AddToggle("Loop Bring", false, function(Value)
            LoopBring = Value

            while LoopBring do
                bringTarget()
                task.wait(0.05)
            end
        end) 

    -- Loop Bring All NPCs (EXECUTÁVEL)

    local player = game.Players.LocalPlayer
    local bringingEnabled = false
    local bringDistance = 5 -- Distância padrão
    local connection = nil

    local function isPlayerModel(model)
        return game.Players:GetPlayerFromCharacter(model) ~= nil
    end

    local function bringNPCs()
        local char = player.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") 
            and v:FindFirstChildOfClass("Humanoid") 
            and not isPlayerModel(v) then
            
                local hum = v:FindFirstChildOfClass("Humanoid")
                local targetHRP = v:FindFirstChild("HumanoidRootPart")
            
                if hum and targetHRP and hum.Health > 0 then
                    local offset = hrp.CFrame.LookVector * bringDistance
                    local pos = hrp.Position + offset + Vector3.new(0, 0, 0)
                
                    targetHRP.CFrame = CFrame.new(pos, hrp.Position)
                end
            end
        end
    end

    local function startBringing()
        if connection then connection:Disconnect() end
    
        connection = game:GetService("RunService").Heartbeat:Connect(function()
            if bringingEnabled then
                bringNPCs()
            end
        end)
    end

    -- Crie o Toggle na sua TeleportsTab
    TeleportsTab.AddToggle("bring NPCs", false, function(Value)
            bringingEnabled = Value
            if Value then
                startBringing()
            end
        end)

    -- Crie o Slider na sua TeleportsTab (0 a 50)
    TeleportsTab.AddSlider("Bring npc distance", 0, 50, bringDistance, function(Value)
            bringDistance = Value
        end)

    -- Loop Bring Players (de costas)

    local player = game.Players.LocalPlayer
    local LoopBringPlayers = false
    local PlayerDistance = 5

    local function bringPlayers()

        local char = player.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        for _,p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character then
            
                local targetHRP = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")

                if targetHRP and hum and hum.Health > 0 then
                
                    local offset = hrp.CFrame.LookVector * PlayerDistance
                    local pos = hrp.Position + offset + Vector3.new(0,0,0)
                
                    -- 👇 Agora ficam de costas pra você
                    targetHRP.CFrame = CFrame.new(pos, pos + hrp.CFrame.LookVector)
                
                end

            end
        end

    end

    -- Slider
    TeleportsTab.AddSlider("Player Bring Distance", 0, 50, 5, function(Value)
            PlayerDistance = Value
        end)

    -- Toggle
    TeleportsTab.AddToggle("Loop Bring Players ", false, function(Value)

            LoopBringPlayers = Value

            while LoopBringPlayers do
                bringPlayers()
                task.wait(0.05)
            end

        end)

    -- Random Player Behind Teleport (Fixed)

    local player = game.Players.LocalPlayer
    local RandomLoop = false
    local CurrentTarget = nil

    local function getRandomPlayer()
        local players = {}

        for _,p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")

                if hum and hrp and hum.Health > 0 then
                    table.insert(players, p)
                end
            end
        end

        if #players > 0 then
            return players[math.random(1,#players)]
        end
    end

    local function teleportBehindTarget(target)

        local char = player.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if not target.Character then return end

        local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
        local hum = target.Character:FindFirstChildOfClass("Humanoid")

        if targetHRP and hum and hum.Health > 0 then
            local behind = targetHRP.CFrame.LookVector * -5
            local pos = targetHRP.Position + behind
            hrp.CFrame = CFrame.new(pos, targetHRP.Position)
        else
            CurrentTarget = nil
        end

    end

    TeleportsTab.AddToggle("Random Player Behind TP", false, function(Value)

            RandomLoop = Value
            CurrentTarget = nil

            while RandomLoop do

                if not CurrentTarget then
                    CurrentTarget = getRandomPlayer()
                end

                if CurrentTarget then
                    teleportBehindTarget(CurrentTarget)
                end

                task.wait(0.05)
            end

        end)

    -- Spawn / Save Position System

    local player = game.Players.LocalPlayer
    local SavedCFrame = nil
    local SavedSpawn = nil
    local LoopSavedTP = false

    -- Botão para salvar posição atual
    TeleportsTab.AddButton("Save Position", function()
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                SavedCFrame = char.HumanoidRootPart.CFrame
            end
        end)

    -- Botão para teleportar para posição salva
    TeleportsTab.AddButton("Teleport To Saved Position", function()
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") and SavedCFrame then
                char.HumanoidRootPart.CFrame = SavedCFrame
            end
        end)

    -- Toggle loop teleport para posição salva
    TeleportsTab.AddToggle("Loop Teleport To Saved Position", false, function(Value)
            LoopSavedTP = Value
        
            while LoopSavedTP do
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") and SavedCFrame then
                    char.HumanoidRootPart.CFrame = SavedCFrame
                end
                task.wait(0.05)
            end
        end)

    -- Botão para definir spawn point
    TeleportsTab.AddButton("Set Spawn Point", function()
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                SavedSpawn = char.HumanoidRootPart.CFrame
            end
        end)

    -- Quando o jogador respawnar ele volta para o spawn salvo
    player.CharacterAdded:Connect(function(char)
        if SavedSpawn then
            task.wait(0.5)
            local hrp = char:WaitForChild("HumanoidRootPart")
            hrp.CFrame = SavedSpawn
        end
    end)

    CombatTab.AddButton("predict Lock(not mine)", function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Enygmaxit/Cam-Lock/main/obf_Wxr6QgzF76G1y2Ch77KN4Zt5Nz0A6GIl61gitv3mRR2t3V103al5d0g26s4KY04r.lua.txt"))()
        end)

    PlayerTab.AddButton("Fly GUI", function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/SpooferedGuy/Fly-Gui/main/fly-gui.lua"))()
        end)

    -- =================================
    -- Rayfield Fling Functions for TrollTab
    -- =================================

    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer

    local AllBool = false

    local GetPlayer = function(Name)
    Name = Name:lower()
    if Name == "all" or Name == "others" then
    AllBool = true
    return
    elseif Name == "random" then
    local GetPlayers = Players:GetPlayers()
    if table.find(GetPlayers,Player) then
    table.remove(GetPlayers,table.find(GetPlayers,Player))
    end
    return GetPlayers[math.random(#GetPlayers)]
    elseif Name ~= "random" and Name ~= "all" and Name ~= "others" then
    for _,x in next, Players:GetPlayers() do
    if x ~= Player then
    if x.Name:lower():match("^"..Name) then
    return x;
    elseif x.DisplayName:lower():match("^"..Name) then
    return x;
    end
    end
    end
    else
    return
    end
    end

    local SkidFling = function(TargetPlayer)
    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    local THumanoid
    local TRootPart
    local THead
    local Accessory
    local Handle

    if TCharacter:FindFirstChildOfClass("Humanoid") then  
        THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")  
    end  
    if THumanoid and THumanoid.RootPart then  
        TRootPart = THumanoid.RootPart  
    end  
    if TCharacter:FindFirstChild("Head") then  
        THead = TCharacter.Head  
    end  
    if TCharacter:FindFirstChildOfClass("Accessory") then  
        Accessory = TCharacter:FindFirstChildOfClass("Accessory")  
    end  
    if Accessory and Accessory:FindFirstChild("Handle") then  
        Handle = Accessory.Handle  
    end  

    if Character and Humanoid and RootPart then  
        if RootPart.Velocity.Magnitude < 50 then  
            getgenv().OldPos = RootPart.CFrame  
        end  
        if THumanoid and THumanoid.Sit and not AllBool then  
            return  
        end  

        if THead then  
            workspace.CurrentCamera.CameraSubject = THead  
        elseif not THead and Handle then  
            workspace.CurrentCamera.CameraSubject = Handle  
        elseif THumanoid and TRootPart then  
            workspace.CurrentCamera.CameraSubject = THumanoid  
        end  

        if not TCharacter:FindFirstChildWhichIsA("BasePart") then  
            return  
        end  

        local FPos = function(BasePart, Pos, Ang)  
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang  
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)  
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)  
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)  
        end  

        local SFBasePart = function(BasePart)  
            local TimeToWait = 2  
            local Time = tick()  
            local Angle = 0  
            repeat  
                if RootPart and THumanoid then  
                    if BasePart.Velocity.Magnitude < 50 then  
                        Angle = Angle + 100  
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))  
                        task.wait()  
                    else  
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(0, -1.5 ,0), CFrame.Angles(math.rad(-90), 0, 0))  
                        task.wait()  
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))  
                        task.wait()  
                    end  
                else  
                    break  
                end  
            until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetPlayer.Character or TargetPlayer.Parent ~= Players or not TargetPlayer.Character == TCharacter or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait  
        end  

        workspace.FallenPartsDestroyHeight = 0/0  
        local BV = Instance.new("BodyVelocity")  
        BV.Name = "EpixVel"  
        BV.Parent = RootPart  
        BV.Velocity = Vector3.new(9e8, 9e8, 9e8)  
        BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)  
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)  

        if TRootPart and THead then  
            if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then  
                SFBasePart(THead)  
            else  
                SFBasePart(TRootPart)  
            end  
        elseif TRootPart and not THead then  
            SFBasePart(TRootPart)  
        elseif not TRootPart and THead then  
            SFBasePart(THead)  
        elseif not TRootPart and not THead and Accessory and Handle then  
            SFBasePart(Handle)  
        else  
            return  
        end  

        BV:Destroy()  
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)  
        workspace.CurrentCamera.CameraSubject = Humanoid  

        repeat  
            RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)  
            Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))  
            Humanoid:ChangeState("GettingUp")  
            table.foreach(Character:GetChildren(), function(_, x)  
                if x:IsA("BasePart") then  
                    x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()  
                end  
            end)  
            task.wait()  
        until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25  
        workspace.FallenPartsDestroyHeight = getgenv().FPDH  
    else  
        return  
    end

    end

    -- Função para fling por nome
    local function FlingByName(PlayerName)
    AllBool = false

    if PlayerName:lower() == "all" or PlayerName:lower() == "others" then  
        for _, pl in next, Players:GetPlayers() do  
            if pl ~= Player then  
                pcall(function()  
                    SkidFling(pl)  
                end)  
            end  
        end  
        return  
    end  
  
    local target = GetPlayer(PlayerName)  
    if target and target ~= Player then  
        pcall(function()  
            SkidFling(target)  
        end)  
    end

    end

    -- Função para fling em todos
    local function FlingAll()
    for _, pl in next, Players:GetPlayers() do
    if pl ~= Player then
    pcall(function()
    SkidFling(pl)
    end)
    end
    end
    end

    -- Seção de Fling
    TrollTab.AddSection("Fling")

    -- Input para nome do jogador
    TrollTab.AddInput("Player Name", "user / all / random", function(Text)
    -- Armazena o nome para uso no botão
    getgenv().TargetName = Text
    end)

    -- Botão para executar fling
    TrollTab.AddButton("Execute Fling", function()
    if getgenv().TargetName and getgenv().TargetName ~= "" then
    FlingByName(getgenv().TargetName)
    end
    end)

    -- Botão para fling em todos
    TrollTab.AddButton("Fling All Players", function()
    FlingAll()
    end)

    -- =================================
    -- Apenas a função Touch Fling
    -- Adicione isso ao seu TrollTab existente
    -- =================================

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer

    local TouchFlingEnabled = false
    local TouchFlingThread = nil

    -- Criar detector anti-cheat
    if not ReplicatedStorage:FindFirstChild("juisdfj0i32i0eidsuf0iok") then
        local detection = Instance.new("Decal")
        detection.Name = "juisdfj0i32i0eidsuf0iok"
        detection.Parent = ReplicatedStorage
    end

    -- Função principal do Touch Fling
    local function TouchFling()
        local c, hrp, vel, movel = nil, nil, nil, 0.1

        while TouchFlingEnabled do
            RunService.Heartbeat:Wait()
            c = Player.Character
            hrp = c and c:FindFirstChild("HumanoidRootPart")

            if hrp then
                vel = hrp.Velocity
                hrp.Velocity = vel * 99999999 + Vector3.new(0, 99999999, 0)
                RunService.RenderStepped:Wait()
                hrp.Velocity = vel
                RunService.Stepped:Wait()
                hrp.Velocity = vel + Vector3.new(0, movel, 0)
                movel = -movel
            end
        end
    end

    -- Função para iniciar/parar
    local function ToggleTouchFling(Value)
        TouchFlingEnabled = Value
    
        if TouchFlingEnabled then
            if TouchFlingThread then
                TouchFlingThread = nil
            end
            TouchFlingThread = coroutine.create(TouchFling)
            coroutine.resume(TouchFlingThread)
        end
    end

    -- Adicione isso dentro do seu TrollTab existente
    TrollTab.AddToggle("Touch Fling", false, function(Value)
            ToggleTouchFling(Value)
        end)

    TrollTab.AddButton("Telekinesis gui", function()
            loadstring(game:HttpGet("https://pastebin.com/raw/db5jg8Nz"))()
        end)
end

SetupItemsTeleportsTroll()
end -- end scoped tab locals
