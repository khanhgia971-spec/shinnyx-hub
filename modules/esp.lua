llocal ESP = {}
ESP.enabled = true
ESP.players = true
ESP.bosses = true
ESP.fruits = true
ESP.chests = true
ESP.npcs = false
ESP.drawings = {}
ESP.updateInterval = 0.2
ESP.lastUpdate = 0
ESP.rendering = false
ESP.colorPlayers = Color3.fromRGB(0, 255, 0)
ESP.colorBosses = Color3.fromRGB(255, 0, 0)
ESP.colorFruits = Color3.fromRGB(255, 255, 0)
ESP.colorChests = Color3.fromRGB(0, 255, 255)
ESP.colorNpcs = Color3.fromRGB(0, 150, 255)
ESP.opacity = 0.8
ESP.textSize = 14
ESP.font = Enum.Font.GothamMedium
ESP.maxDistance = 5000
ESP.showNames = true
ESP.showDistance = true
ESP.showHealth = true
ESP.showBox = true
ESP.outlineThickness = 1

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local function getLocalPlayer()
    return Players.LocalPlayer
end

local function getCharacter()
    local player = getLocalPlayer()
    if not player then return nil end
    return player.Character
end

local function getPosition()
    local char = getCharacter()
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    return hrp.Position
end

local function isAlive(entity)
    if not entity then return false end
    local hum = entity:FindFirstChild("Humanoid")
    if not hum then return false end
    return hum.Health > 0
end

local function getEntityPosition(entity)
    if not entity then return nil end
    local hrp = entity:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    return hrp.Position
end

local function isOnScreen(position)
    if not position then return false end
    local screenPos, onScreen = Camera:WorldToScreenPoint(position)
    return onScreen
end

local function getScreenPosition(position)
    local screenPos, onScreen = Camera:WorldToScreenPoint(position)
    if not onScreen then return nil end
    return Vector2.new(screenPos.X, screenPos.Y)
end

local function getEntitySize(entity)
    local hrp = entity:FindFirstChild("HumanoidRootPart")
    if not hrp then return 2 end
    local size = hrp.Size
    return math.max(size.X, size.Z) * 0.8
end

local function createDrawing(type)
    if type == "box" then
        local box = Drawing.new("Square")
        box.Thickness = ESP.outlineThickness
        box.Transparency = 1
        box.Color = Color3.fromRGB(255, 255, 255)
        box.Filled = false
        box.Visible = false
        box.ZIndex = 2
        return box
    elseif type == "name" then
        local label = Drawing.new("Text")
        label.Center = true
        label.Outline = true
        label.OutlineColor = Color3.fromRGB(0, 0, 0)
        label.Transparency = 1
        label.Size = ESP.textSize
        label.Color = Color3.fromRGB(255, 255, 255)
        label.Visible = false
        label.ZIndex = 3
        return label
    elseif type == "distance" then
        local dist = Drawing.new("Text")
        dist.Center = true
        dist.Outline = true
        dist.OutlineColor = Color3.fromRGB(0, 0, 0)
        dist.Transparency = 1
        dist.Size = ESP.textSize - 2
        dist.Color = Color3.fromRGB(200, 200, 200)
        dist.Visible = false
        dist.ZIndex = 1
        return dist
    elseif type == "health" then
        local bar = Drawing.new("Square")
        bar.Thickness = 1
        bar.Transparency = 1
        bar.Filled = true
        bar.Visible = false
        bar.ZIndex = 1
        return bar
    end
    return nil
end

function ESP.createEntityDrawings()
    return {
        box = createDrawing("box"),
        name = createDrawing("name"),
        distance = createDrawing("distance"),
        health = createDrawing("health"),
        active = false,
    }
end

function ESP.getDrawingsForEntity(entity)
    if not ESP.drawings[entity] then
        ESP.drawings[entity] = ESP.createEntityDrawings()
    end
    return ESP.drawings[entity]
end

function ESP.removeDrawingsForEntity(entity)
    if ESP.drawings[entity] then
        for _, d in pairs(ESP.drawings[entity]) do
            if d and d.Remove then
                pcall(d.Remove, d)
            end
        end
        ESP.drawings[entity] = nil
    end
end

function ESP.clearDrawings()
    for entity, drawings in pairs(ESP.drawings) do
        for _, d in pairs(drawings) do
            if d and d.Remove then
                pcall(d.Remove, d)
            end
        end
    end
    ESP.drawings = {}
end

function ESP.updateEntity(entity, entityType, color)
    if not entity or not ESP.enabled then
        if ESP.drawings[entity] then
            ESP.hideEntity(entity)
        end
        return
    end
    local playerPos = getPosition()
    if not playerPos then return end
    local entityPos = getEntityPosition(entity)
    if not entityPos then
        ESP.hideEntity(entity)
        return
    end
    local dist = (entityPos - playerPos).magnitude
    if dist > ESP.maxDistance then
        ESP.hideEntity(entity)
        return
    end
    if not isAlive(entity) then
        ESP.hideEntity(entity)
        return
    end
    local screenPos = getScreenPosition(entityPos)
    if not screenPos then
        ESP.hideEntity(entity)
        return
    end
    local drawings = ESP.getDrawingsForEntity(entity)
    local size = getEntitySize(entity)
    local scale = math.clamp(ESP.maxDistance / dist, 0.5, 2)
    local boxSize = size * 30 * scale
    local boxPos = screenPos - Vector2.new(boxSize / 2, boxSize / 2)
    local healthPercent = 1
    local hum = entity:FindFirstChild("Humanoid")
    if hum then
        healthPercent = hum.Health / hum.MaxHealth
    end
    if drawings.box then
        drawings.box.Position = boxPos
        drawings.box.Size = Vector2.new(boxSize, boxSize)
        drawings.box.Color = color
        drawings.box.Transparency = 1 - ESP.opacity
        drawings.box.Visible = true
    end
    if drawings.name and ESP.showNames then
        local nameText = entity.Name
        if entityType == "player" then
            local player = Players:GetPlayerFromCharacter(entity)
            if player then nameText = player.Name end
        end
        drawings.name.Text = nameText
        drawings.name.Position = Vector2.new(screenPos.X, screenPos.Y - boxSize / 2 - 16)
        drawings.name.Color = color
        drawings.name.Transparency = 1 - ESP.opacity
        drawings.name.Size = ESP.textSize
        drawings.name.Visible = true
    end
    if drawings.distance and ESP.showDistance then
        drawings.distance.Text = string.format("%.0fm", dist)
        drawings.distance.Position = Vector2.new(screenPos.X, screenPos.Y + boxSize / 2 + 4)
        drawings.distance.Transparency = 1 - ESP.opacity
        drawings.distance.Visible = true
    end
    if drawings.health and ESP.showHealth then
        drawings.health.Position = Vector2.new(screenPos.X - boxSize / 2, screenPos.Y + boxSize / 2 + 16)
        drawings.health.Size = Vector2.new(boxSize, 4)
        drawings.health.Color = Color3.fromRGB(
            255 * (1 - healthPercent),
            255 * healthPercent,
            0
        )
        drawings.health.Transparency = 0.3
        drawings.health.Visible = true
    end
    drawings.active = true
end

function ESP.hideEntity(entity)
    if not ESP.drawings[entity] then return end
    local drawings = ESP.drawings[entity]
    for _, d in pairs(drawings) do
        if d and d.Visible ~= nil then
            d.Visible = false
        end
    end
    drawings.active = false
end

function ESP.isEntityVisible(entity)
    if not ESP.drawings[entity] then return false end
    return ESP.drawings[entity].active
end

function ESP.isEntityInFruitList(entity)
    for _, v in pairs(ESP.fruitList or {}) do
        if v == entity then return true end
    end
    return false
end

function ESP.render()
    if not ESP.enabled then
        ESP.clearDrawings()
        return
    end
    if tick() - ESP.lastUpdate < ESP.updateInterval then return end
    ESP.lastUpdate = tick()
    if ESP.rendering then return end
    ESP.rendering = true
    pcall(function()
        local playerPos = getPosition()
        if not playerPos then ESP.rendering = false return end
        local entities = {}
        if ESP.players then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= getLocalPlayer() then
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        table.insert(entities, {entity = char, type = "player", color = ESP.colorPlayers})
                    end
                end
            end
        end
        if ESP.bosses then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                    local hum = v:FindFirstChild("Humanoid")
                    if hum and hum.Health > 0 then
                        local isBoss = false
                        for _, name in ipairs({"Greybeard", "Diamond", "Kilo", "Cursed", "Don Swan", "Ice Admiral", "Thunder God", "Dark Beard", "Cyborg", "Fishman"}) do
                            if string.find(v.Name, name) then
                                isBoss = true
                                break
                            end
                        end
                        if isBoss then
                            table.insert(entities, {entity = v, type = "boss", color = ESP.colorBosses})
                        end
                    end
                end
            end
        end
        if ESP.fruits then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("Part") and v.Name == "Fruit" and v.Parent and v.Parent:IsA("Model") then
                    table.insert(entities, {entity = v.Parent, type = "fruit", color = ESP.colorFruits})
                end
            end
        end
        if ESP.chests then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChild("Handle") and v:FindFirstChild("TouchInterest") then
                    table.insert(entities, {entity = v, type = "chest", color = ESP.colorChests})
                end
            end
        end
        if ESP.npcs then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                    local hum = v:FindFirstChild("Humanoid")
                    if hum and hum.Health > 0 then
                        if string.find(v.Name, "NPC") or string.find(v.Name, "Quest") or string.find(v.Name, "Giver") or string.find(v.Name, "Shop") then
                            table.insert(entities, {entity = v, type = "npc", color = ESP.colorNpcs})
                        end
                    end
                end
            end
        end
        local processed = {}
        for _, data in ipairs(entities) do
            local entity = data.entity
            local key = tostring(entity)
            if not processed[key] then
                processed[key] = true
                ESP.updateEntity(entity, data.type, data.color)
            end
        end
        for entity, _ in pairs(ESP.drawings) do
            local found = false
            for _, data in ipairs(entities) do
                if data.entity == entity then
                    found = true
                    break
                end
            end
            if not found then
                ESP.hideEntity(entity)
            end
        end
    end)
    ESP.rendering = false
end

function ESP.toggleEnabled(state)
    ESP.enabled = state
    if not state then
        ESP.clearDrawings()
    end
end

function ESP.togglePlayer(state)
    ESP.players = state
end

function ESP.toggleBoss(state)
    ESP.bosses = state
end

function ESP.toggleFruit(state)
    ESP.fruits = state
end

function ESP.toggleChest(state)
    ESP.chests = state
end

function ESP.toggleNPC(state)
    ESP.npcs = state
end

function ESP.setColor(type, color)
    if type == "player" then ESP.colorPlayers = color
    elseif type == "boss" then ESP.colorBosses = color
    elseif type == "fruit" then ESP.colorFruits = color
    elseif type == "chest" then ESP.colorChests = color
    elseif type == "npc" then ESP.colorNpcs = color
    end
end

function ESP.setOpacity(opacity)
    ESP.opacity = math.clamp(opacity, 0.1, 1)
end

function ESP.setMaxDistance(distance)
    ESP.maxDistance = distance
end

function ESP.setUpdateInterval(interval)
    ESP.updateInterval = math.max(interval, 0.05)
end

function ESP.start()
    if ESP.running then return end
    ESP.running = true
    ESP.connection = RunService.Heartbeat:Connect(function()
        ESP.render()
    end)
end

function ESP.stop()
    ESP.running = false
    if ESP.connection then
        ESP.connection:Disconnect()
        ESP.connection = nil
    end
    ESP.clearDrawings()
end

ESP.start()

return ESP
