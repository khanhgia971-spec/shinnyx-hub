
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local function getLocalPlayer()
    return Players.LocalPlayer
end

function API.getPlayer()
    return getLocalPlayer()
end

function API.getCharacter()
    local player = getLocalPlayer()
    if not player then return nil end
    return player.Character
end

function API.getHumanoid()
    local char = API.getCharacter()
    if not char then return nil end
    return char:FindFirstChild("Humanoid")
end

function API.getHumanoidRootPart()
    local char = API.getCharacter()
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

function API.getPosition()
    local hrp = API.getHumanoidRootPart()
    if not hrp then return nil end
    return hrp.Position
end

function API.isAlive()
    local hum = API.getHumanoid()
    if not hum then return false end
    return hum.Health > 0
end

function API.getHealth()
    local hum = API.getHumanoid()
    if not hum then return 0 end
    return hum.Health
end

function API.getMaxHealth()
    local hum = API.getHumanoid()
    if not hum then return 0 end
    return hum.MaxHealth
end

function API.getHealthPercent()
    local health = API.getHealth()
    local maxHealth = API.getMaxHealth()
    if maxHealth == 0 then return 0 end
    return (health / maxHealth) * 100
end

function API.getEnergy()
    local char = API.getCharacter()
    if not char then return 0 end
    local energy = char:FindFirstChild("Energy")
    if not energy then return 0 end
    return energy.Value
end

function API.getMaxEnergy()
    local char = API.getCharacter()
    if not char then return 0 end
    local maxEnergy = char:FindFirstChild("MaxEnergy")
    if not maxEnergy then return 0 end
    return maxEnergy.Value
end

function API.getEnergyPercent()
    local energy = API.getEnergy()
    local maxEnergy = API.getMaxEnergy()
    if maxEnergy == 0 then return 0 end
    return (energy / maxEnergy) * 100
end

function API.getLevel()
    local player = getLocalPlayer()
    if not player then return 0 end
    local level = player:FindFirstChild("Level")
    if not level then return 0 end
    return level.Value
end

function API.getBeli()
    local player = getLocalPlayer()
    if not player then return 0 end
    local beli = player:FindFirstChild("Beli")
    if not beli then return 0 end
    return beli.Value
end

function API.getFruits()
    local player = getLocalPlayer()
    if not player then return {} end
    local fruits = {}
    local inv = player:FindFirstChild("Inventory")
    if not inv then return fruits end
    for _, child in pairs(inv:GetChildren()) do
        if child:IsA("Tool") and string.find(child.Name, "Fruit") then
            table.insert(fruits, child.Name)
        end
    end
    return fruits
end

function API.getCurrentIsland()
    local pos = API.getPosition()
    if not pos then return "Unknown" end
    -- Check known island coordinates (simplified)
    local islands = {
        {name = "Jungle", pos = Vector3.new(-1000, 100, 0)},
        {name = "Pirate Village", pos = Vector3.new(-500, 50, 800)},
        {name = "Kingdom of Rose", pos = Vector3.new(2000, 150, 1000)},
        {name = "Graveyard", pos = Vector3.new(-1500, 80, -1500)},
        {name = "Sea of Treats", pos = Vector3.new(3000, 120, -2000)},
        {name = "Floating Turtle", pos = Vector3.new(-2500, 300, 2500)},
        {name = "Mansion", pos = Vector3.new(1000, 200, -3000)},
    }
    local nearest = "Unknown"
    local nearestDist = math.huge
    for _, island in ipairs(islands) do
        local dist = (pos - island.pos).magnitude
        if dist < nearestDist then
            nearestDist = dist
            nearest = island.name
        end
    end
    return nearest
end

function API.getAllPlayers()
    local list = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= getLocalPlayer() then
            table.insert(list, player)
        end
    end
    return list
end

function API.getEntities()
    local entities = {players = {}, npcs = {}, bosses = {}, fruits = {}, chests = {}}
    local char = API.getCharacter()
    local hrp = API.getHumanoidRootPart()
    if not hrp then return entities end
    local pos = hrp.Position
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            local hum = v:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local name = v.Name
                local isPlayer = false
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Character == v then
                        isPlayer = true
                        break
                    end
                end
                if isPlayer then
                    table.insert(entities.players, v)
                elseif string.find(name, "Boss") or string.find(name, "Greybeard") or string.find(name, "Diamond") or string.find(name, "Kilo") or string.find(name, "Cursed") then
                    table.insert(entities.bosses, v)
                else
                    table.insert(entities.npcs, v)
                end
            end
        elseif v:IsA("Model") and v:FindFirstChild("Handle") and v:FindFirstChild("TouchInterest") then
            table.insert(entities.chests, v)
        elseif v:IsA("Part") and v.Name == "Fruit" and v.Parent and v.Parent:IsA("Model") then
            table.insert(entities.fruits, v.Parent)
        end
    end
    return entities
end

function API.findNearestEntity(entities, maxDist)
    local pos = API.getPosition()
    if not pos then return nil, math.huge end
    local nearest = nil
    local nearestDist = math.huge
    for _, entity in ipairs(entities) do
        local hrp = entity:FindFirstChild("HumanoidRootPart")
        if hrp then
            local dist = (hrp.Position - pos).magnitude
            if dist < maxDist and dist < nearestDist then
                nearest = entity
                nearestDist = dist
            end
        end
    end
    return nearest, nearestDist
end

function API.findNearestNPC(maxDist)
    local entities = API.getEntities()
    return API.findNearestEntity(entities.npcs, maxDist)
end

function API.findNearestBoss(maxDist)
    local entities = API.getEntities()
    return API.findNearestEntity(entities.bosses, maxDist)
end

function API.findNearestFruit(maxDist)
    local entities = API.getEntities()
    return API.findNearestEntity(entities.fruits, maxDist)
end

function API.findNearestChest(maxDist)
    local entities = API.getEntities()
    return API.findNearestEntity(entities.chests, maxDist)
end

function API.findNearestPlayer(maxDist)
    local entities = API.getEntities()
    return API.findNearestEntity(entities.players, maxDist)
end

function API.teleport(targetPos)
    local hrp = API.getHumanoidRootPart()
    if not hrp then return false end
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
    tween:Play()
    tween.Completed:Wait()
    return true
end

function API.teleportToIsland(islandName)
    local islands = {
        Jungle = Vector3.new(-1000, 100, 0),
        PirateVillage = Vector3.new(-500, 50, 800),
        KingdomOfRose = Vector3.new(2000, 150, 1000),
        Graveyard = Vector3.new(-1500, 80, -1500),
        SeaOfTreats = Vector3.new(3000, 120, -2000),
        FloatingTurtle = Vector3.new(-2500, 300, 2500),
        Mansion = Vector3.new(1000, 200, -3000),
    }
    local pos = islands[islandName]
    if not pos then return false end
    return API.teleport(pos)
end

function API.teleportToEntity(entity)
    if not entity then return false end
    local hrp = entity:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    return API.teleport(hrp.Position + Vector3.new(0, 5, 0))
end

function API.teleportToNPC(npcName)
    local entities = API.getEntities()
    for _, npc in ipairs(entities.npcs) do
        if string.find(npc.Name, npcName) then
            return API.teleportToEntity(npc)
        end
    end
    return false
end

function API.teleportToBoss(bossName)
    local entities = API.getEntities()
    for _, boss in ipairs(entities.bosses) do
        if string.find(boss.Name, bossName) then
            return API.teleportToEntity(boss)
        end
    end
    return false
end

function API.teleportToFruit()
    local fruit, dist = API.findNearestFruit(10000)
    if fruit then
        return API.teleportToEntity(fruit)
    end
    return false
end

function API.attackTarget(target)
    if not target then return false end
    local hrp = API.getHumanoidRootPart()
    if not hrp then return false end
    local targetHrp = target:FindFirstChild("HumanoidRootPart")
    if not targetHrp then return false end
    local dist = (targetHrp.Position - hrp.Position).magnitude
    if dist > 50 then
        API.teleportToEntity(target)
        task.wait(0.1)
    end
    local char = API.getCharacter()
    if not char then return false end
    local tool = char:FindFirstChildWhichIsA("Tool")
    if tool then
        tool:Activate()
        return true
    end
    local hum = API.getHumanoid()
    if hum then
        local anim = hum:LoadAnimation(Instance.new("Animation"))
        if anim then
            anim:Play()
            task.wait(0.1)
            anim:Stop()
            return true
        end
    end
    return false
end

function API.useAbility(abilityName)
    local char = API.getCharacter()
    if not char then return false end
    local abilities = char:FindFirstChild("Abilities")
    if not abilities then return false end
    local ability = abilities:FindFirstChild(abilityName)
    if not ability then return false end
    ability:FireServer()
    return true
end

function API.heal()
    local char = API.getCharacter()
    if not char then return false end
    local healthPercent = API.getHealthPercent()
    if healthPercent > 90 then return false end
    local backpack = getLocalPlayer().Backpack
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and string.find(item.Name, "Potion") then
                item:Activate()
                return true
            end
        end
    end
    return API.useAbility("Heal")
end

function API.getServerTime()
    return tick()
end

function API.getGameTime()
    return Workspace.DistributedGameTime
end

function API.getFPS()
    local stats = game:GetService("Stats")
    local fps = stats.FPS
    if fps then
        return fps.Value
    end
    return 60
end

function API.getMemoryUsage()
    local stats = game:GetService("Stats")
    local memory = stats.Memory
    if memory then
        return memory.Value
    end
    return 0
end

function API.isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function API.isPC()
    return not UserInputService.TouchEnabled and UserInputService.KeyboardEnabled
end

function API.getScreenSize()
    local viewport = game:GetService("ViewportSize")
    return viewport
end

function API.getMouseLocation()
    return UserInputService:GetMouseLocation()
end

function API.updateCache()
    API.lastCacheUpdate = tick()
end

function API.isCacheValid()
    return tick() - API.lastCacheUpdate < API.cacheTimeout
end

function API.setCacheTimeout(timeout)
    if timeout and timeout > 0 then
        API.cacheTimeout = timeout
    end
end

return API
