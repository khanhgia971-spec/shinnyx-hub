local AutoFarm = {}
AutoFarm.isRunning = false
AutoFarm.loopConnection = nil
AutoFarm.lastAttackTime = 0
AutoFarm.lastHealTime = 0
AutoFarm.lastQuestTime = 0
AutoFarm.currentTarget = nil
AutoFarm.targetType = nil
AutoFarm.questCache = {}
AutoFarm.bossCache = {}
AutoFarm.fruitCache = {}
AutoFarm.chestCache = {}
AutoFarm.stats = {
    mobsKilled = 0,
    bossesKilled = 0,
    chestsOpened = 0,
    fruitsCollected = 0,
    questsCompleted = 0,
    totalXP = 0,
    totalBeli = 0,
    startTime = 0,
    runtime = 0,
}

local config = {
    enabled = true,
    radius = 400,
    attackCooldown = 0.3,
    healThreshold = 25,
    farmIsland = "Jungle",
    questMode = true,
    mobMode = true,
    bossMode = false,
    chestMode = true,
    fruitMode = true,
    targetMobs = {"Bandit", "Pirate", "Marine", "Brute", "Mercenary", "Soldier", "Guard", "Shark", "Ghost"},
    targetBosses = {"Greybeard", "Diamond", "Kilo Admiral", "Cursed Captain", "Don Swan", "Ice Admiral", "Thunder God"},
    autoHeal = true,
    healPotions = true,
    useAbilities = true,
    waitBetweenAttacks = 0.2,
    maxDistanceToTarget = 50,
    antiAFK = true,
    lootChests = true,
    collectDrops = true,
    prioritizeFruits = true,
    prioritizeBosses = false,
    prioritizeChests = false,
    useGun = false,
    useSword = true,
    useMelee = true,
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local function getLocalPlayer()
    return Players.LocalPlayer
end

local function getCharacter()
    local player = getLocalPlayer()
    if not player then return nil end
    return player.Character
end

local function getHumanoid()
    local char = getCharacter()
    if not char then return nil end
    return char:FindFirstChild("Humanoid")
end

local function getHumanoidRootPart()
    local char = getCharacter()
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function getPosition()
    local hrp = getHumanoidRootPart()
    if not hrp then return nil end
    return hrp.Position
end

local function isAlive()
    local hum = getHumanoid()
    if not hum then return false end
    return hum.Health > 0
end

local function getHealth()
    local hum = getHumanoid()
    if not hum then return 0 end
    return hum.Health
end

local function getMaxHealth()
    local hum = getHumanoid()
    if not hum then return 0 end
    return hum.MaxHealth
end

local function getHealthPercent()
    local health = getHealth()
    local maxHealth = getMaxHealth()
    if maxHealth == 0 then return 0 end
    return (health / maxHealth) * 100
end

local function getLevel()
    local player = getLocalPlayer()
    if not player then return 0 end
    local level = player:FindFirstChild("Level")
    if not level then return 0 end
    return level.Value
end

local function getBeli()
    local player = getLocalPlayer()
    if not player then return 0 end
    local beli = player:FindFirstChild("Beli")
    if not beli then return 0 end
    return beli.Value
end

local function getEnergy()
    local char = getCharacter()
    if not char then return 0 end
    local energy = char:FindFirstChild("Energy")
    if not energy then return 0 end
    return energy.Value
end

local function getMaxEnergy()
    local char = getCharacter()
    if not char then return 0 end
    local maxEnergy = char:FindFirstChild("MaxEnergy")
    if not maxEnergy then return 0 end
    return maxEnergy.Value
end

local function getEnergyPercent()
    local energy = getEnergy()
    local maxEnergy = getMaxEnergy()
    if maxEnergy == 0 then return 0 end
    return (energy / maxEnergy) * 100
end

local function getCurrentIsland()
    local pos = getPosition()
    if not pos then return "Unknown" end
    local islands = {
        {name = "Jungle", pos = Vector3.new(-1000, 100, 0)},
        {name = "Pirate Village", pos = Vector3.new(-500, 50, 800)},
        {name = "Kingdom of Rose", pos = Vector3.new(2000, 150, 1000)},
        {name = "Graveyard", pos = Vector3.new(-1500, 80, -1500)},
        {name = "Sea of Treats", pos = Vector3.new(3000, 120, -2000)},
        {name = "Floating Turtle", pos = Vector3.new(-2500, 300, 2500)},
        {name = "Mansion", pos = Vector3.new(1000, 200, -3000)},
        {name = "Ice Island", pos = Vector3.new(-1800, 60, 2000)},
        {name = "Dark Arena", pos = Vector3.new(2500, 150, -1500)},
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

local function teleportTo(targetPos)
    local hrp = getHumanoidRootPart()
    if not hrp then return false end
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
    tween:Play()
    tween.Completed:Wait()
    return true
end

local function teleportToEntity(entity)
    if not entity then return false end
    local hrp = entity:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    return teleportTo(hrp.Position + Vector3.new(0, 3, 0))
end

local function isEntityAlive(entity)
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

local function distanceBetween(pos1, pos2)
    if not pos1 or not pos2 then return math.huge end
    return (pos1 - pos2).magnitude
end

local function findNearestMob(radius, ignoreList)
    local playerPos = getPosition()
    if not playerPos then return nil, math.huge end
    local nearest = nil
    local nearestDist = math.huge
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            local hum = v:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local isMob = false
                for _, name in ipairs(config.targetMobs) do
                    if string.find(v.Name, name) then
                        isMob = true
                        break
                    end
                end
                if isMob then
                    local pos = v.HumanoidRootPart.Position
                    local dist = (pos - playerPos).magnitude
                    if dist < radius and dist < nearestDist then
                        local isIgnored = false
                        if ignoreList then
                            for _, ign in ipairs(ignoreList) do
                                if v == ign then isIgnored = true break end
                            end
                        end
                        if not isIgnored then
                            nearest = v
                            nearestDist = dist
                        end
                    end
                end
            end
        end
    end
    return nearest, nearestDist
end

local function findNearestBoss(radius)
    local playerPos = getPosition()
    if not playerPos then return nil, math.huge end
    local nearest = nil
    local nearestDist = math.huge
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            local hum = v:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local isBoss = false
                for _, name in ipairs(config.targetBosses) do
                    if string.find(v.Name, name) then
                        isBoss = true
                        break
                    end
                end
                if isBoss then
                    local pos = v.HumanoidRootPart.Position
                    local dist = (pos - playerPos).magnitude
                    if dist < radius and dist < nearestDist then
                        nearest = v
                        nearestDist = dist
                    end
                end
            end
        end
    end
    return nearest, nearestDist
end

local function findNearestChest(radius)
    local playerPos = getPosition()
    if not playerPos then return nil, math.huge end
    local nearest = nil
    local nearestDist = math.huge
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Handle") and v:FindFirstChild("TouchInterest") then
            local pos = v:FindFirstChild("Handle") and v.Handle.Position or v.PrimaryPart and v.PrimaryPart.Position
            if pos then
                local dist = (pos - playerPos).magnitude
                if dist < radius and dist < nearestDist then
                    nearest = v
                    nearestDist = dist
                end
            end
        end
    end
    return nearest, nearestDist
end

local function findNearestFruit(radius)
    local playerPos = getPosition()
    if not playerPos then return nil, math.huge end
    local nearest = nil
    local nearestDist = math.huge
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Part") and v.Name == "Fruit" and v.Parent and v.Parent:IsA("Model") then
            local pos = v.Position
            local dist = (pos - playerPos).magnitude
            if dist < radius and dist < nearestDist then
                nearest = v.Parent
                nearestDist = dist
            end
        end
    end
    return nearest, nearestDist
end

local function findAllEntities()
    local entities = {mobs = {}, bosses = {}, chests = {}, fruits = {}}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            local hum = v:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local isBoss = false
                for _, name in ipairs(config.targetBosses) do
                    if string.find(v.Name, name) then
                        isBoss = true
                        break
                    end
                end
                if isBoss then
                    table.insert(entities.bosses, v)
                else
                    local isMob = false
                    for _, name in ipairs(config.targetMobs) do
                        if string.find(v.Name, name) then
                            isMob = true
                            break
                        end
                    end
                    if isMob then
                        table.insert(entities.mobs, v)
                    end
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

local function attackTarget(target)
    if not target or not target:FindFirstChild("HumanoidRootPart") then return false end
    local char = getCharacter()
    if not char then return false end
    local hrp = getHumanoidRootPart()
    if not hrp then return false end
    local targetPos = target.HumanoidRootPart.Position
    local currentPos = hrp.Position
    local dist = (targetPos - currentPos).magnitude
    if dist > config.maxDistanceToTarget then
        teleportTo(targetPos + Vector3.new(0, 3, 0))
        task.wait(0.05)
    end
    local hum = getHumanoid()
    if not hum then return false end
    local tool = char:FindFirstChildWhichIsA("Tool")
    if tool and (config.useMelee or config.useSword or config.useGun) then
        if config.useGun and string.find(tool.Name, "Gun") then
            tool:Activate()
        elseif config.useSword and string.find(tool.Name, "Sword") then
            tool:Activate()
        elseif config.useMelee then
            tool:Activate()
        else
            tool:Activate()
        end
        return true
    else
        local attackAnim = hum:LoadAnimation(Instance.new("Animation"))
        if attackAnim then
            attackAnim:Play()
            task.wait(0.1)
            attackAnim:Stop()
            return true
        end
    end
    return false
end

local function heal()
    if not config.autoHeal then return end
    local hum = getHumanoid()
    if not hum then return end
    local healthPercent = getHealthPercent()
    if healthPercent < config.healThreshold then
        local char = getCharacter()
        if char then
            local backpack = getLocalPlayer().Backpack
            if config.healPotions and backpack then
                for _, item in pairs(backpack:GetChildren()) do
                    if item:IsA("Tool") and string.find(item.Name, "Potion") then
                        item:Activate()
                        AutoFarm.lastHealTime = tick()
                        return
                    end
                end
            end
            local abilities = char:FindFirstChild("Abilities")
            if abilities then
                local healAbility = abilities:FindFirstChild("Heal")
                if healAbility then
                    healAbility:FireServer()
                    AutoFarm.lastHealTime = tick()
                    return
                end
            end
        end
    end
end

local function handleQuest()
    if not config.questMode then return end
    if tick() - AutoFarm.lastQuestTime < 5 then return end
    local playerPos = getPosition()
    if not playerPos then return end
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            if string.find(v.Name, "NPC") or string.find(v.Name, "Quest") or string.find(v.Name, "Giver") then
                local npcPos = v.HumanoidRootPart.Position
                local dist = (npcPos - playerPos).magnitude
                if dist < 100 then
                    local args = {[1] = v}
                    local questEvent = ReplicatedStorage:FindFirstChild("QuestEvent")
                    if questEvent then
                        questEvent:FireServer(unpack(args))
                        AutoFarm.lastQuestTime = tick()
                        AutoFarm.stats.questsCompleted = AutoFarm.stats.questsCompleted + 1
                        task.wait(0.5)
                        return
                    end
                end
            end
        end
    end
end

local function antiAFK()
    if not config.antiAFK then return end
    local hrp = getHumanoidRootPart()
    if not hrp then return end
    local currentPos = hrp.Position
    local randomOffset = Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
    local newPos = currentPos + randomOffset
    teleportTo(newPos)
end

local function collectDrops()
    if not config.collectDrops then return end
    local playerPos = getPosition()
    if not playerPos then return end
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Part") and v:IsA("BasePart") and string.find(v.Name, "Drop") or string.find(v.Name, "Loot") then
            local dist = (v.Position - playerPos).magnitude
            if dist < 50 then
                v.CFrame = playerPos + Vector3.new(0, 2, 0)
            end
        end
    end
end

local function useAbilities()
    if not config.useAbilities then return end
    local char = getCharacter()
    if not char then return end
    local abilities = char:FindFirstChild("Abilities")
    if not abilities then return end
    for _, ability in pairs(abilities:GetChildren()) do
        if ability:IsA("RemoteEvent") or ability:IsA("RemoteFunction") then
            ability:FireServer()
            task.wait(0.1)
        end
    end
end

local function farmLoop()
    if not config.enabled then
        AutoFarm.isRunning = false
        return
    end
    if not isAlive() then
        task.wait(1)
        return
    end
    if tick() - AutoFarm.lastHealTime > 2 then
        heal()
    end
    if tick() - AutoFarm.lastAttackTime > 60 then
        antiAFK()
    end
    collectDrops()
    if math.random(1, 10) == 1 then
        useAbilities()
    end
    local target = nil
    local targetType = nil
    local dist = math.huge
    local entities = findAllEntities()
    if config.fruitMode and config.prioritizeFruits then
        local fruit, d = findNearestFruit(config.radius)
        if fruit and d < dist then
            target = fruit
            targetType = "fruit"
            dist = d
        end
    end
    if config.bossMode and config.prioritizeBosses and not target then
        local boss, d = findNearestBoss(config.radius)
        if boss and d < dist then
            target = boss
            targetType = "boss"
            dist = d
        end
    end
    if config.chestMode and config.prioritizeChests and not target then
        local chest, d = findNearestChest(config.radius)
        if chest and d < dist then
            target = chest
            targetType = "chest"
            dist = d
        end
    end
    if config.mobMode and not target then
        local mob, d = findNearestMob(config.radius, {})
        if mob and d < dist then
            target = mob
            targetType = "mob"
            dist = d
        end
    end
    if not target then
        if config.bossMode and not target then
            local boss, d = findNearestBoss(config.radius * 1.5)
            if boss and d < dist then
                target = boss
                targetType = "boss"
                dist = d
            end
        end
        if config.chestMode and not target then
            local chest, d = findNearestChest(config.radius)
            if chest and d < dist then
                target = chest
                targetType = "chest"
                dist = d
            end
        end
        if config.fruitMode and not target then
            local fruit, d = findNearestFruit(config.radius)
            if fruit and d < dist then
                target = fruit
                targetType = "fruit"
                dist = d
            end
        end
    end
    if target and tick() - AutoFarm.lastAttackTime > config.attackCooldown then
        if targetType == "fruit" or targetType == "chest" then
            teleportToEntity(target)
            AutoFarm.lastAttackTime = tick()
            if targetType == "fruit" then
                AutoFarm.stats.fruitsCollected = AutoFarm.stats.fruitsCollected + 1
            elseif targetType == "chest" then
                AutoFarm.stats.chestsOpened = AutoFarm.stats.chestsOpened + 1
            end
        else
            local success = attackTarget(target)
            if success then
                AutoFarm.lastAttackTime = tick()
                AutoFarm.currentTarget = target
                AutoFarm.targetType = targetType
                if targetType == "mob" then
                    AutoFarm.stats.mobsKilled = AutoFarm.stats.mobsKilled + 1
                elseif targetType == "boss" then
                    AutoFarm.stats.bossesKilled = AutoFarm.stats.bossesKilled + 1
                end
                AutoFarm.stats.totalXP = AutoFarm.stats.totalXP + getLevel() * 10
                AutoFarm.stats.totalBeli = AutoFarm.stats.totalBeli + getBeli()
            end
        end
    end
    if config.questMode and tick() - AutoFarm.lastQuestTime > 5 then
        handleQuest()
    end
    if AutoFarm.currentTarget and AutoFarm.currentTarget:FindFirstChild("Humanoid") then
        local hum = AutoFarm.currentTarget:FindFirstChild("Humanoid")
        if hum and hum.Health <= 0 then
            AutoFarm.currentTarget = nil
            AutoFarm.targetType = nil
        end
    end
    AutoFarm.stats.runtime = tick() - AutoFarm.stats.startTime
end

function AutoFarm.start()
    if AutoFarm.isRunning then
        return false
    end
    AutoFarm.isRunning = true
    AutoFarm.lastAttackTime = tick()
    AutoFarm.lastHealTime = tick()
    AutoFarm.lastQuestTime = tick()
    AutoFarm.stats.startTime = tick()
    AutoFarm.stats.runtime = 0
    print("[AutoFarm] Khoi dong farm...")
    AutoFarm.loopConnection = RunService.Heartbeat:Connect(function()
        pcall(farmLoop)
    end)
    return true
end

function AutoFarm.stop()
    if not AutoFarm.isRunning then
        return false
    end
    AutoFarm.isRunning = false
    if AutoFarm.loopConnection then
        AutoFarm.loopConnection:Disconnect()
        AutoFarm.loopConnection = nil
    end
    print("[AutoFarm] Dung farm.")
    return true
end

function AutoFarm.restart()
    AutoFarm.stop()
    task.wait(0.5)
    AutoFarm.start()
end

function AutoFarm.getStatus()
    return {
        running = AutoFarm.isRunning,
        currentTarget = AutoFarm.currentTarget,
        targetType = AutoFarm.targetType,
        lastAttack = AutoFarm.lastAttackTime,
        stats = AutoFarm.stats,
        config = config
    }
end

function AutoFarm.updateConfig(newVals)
    for k, v in pairs(newVals) do
        config[k] = v
    end
end

function AutoFarm.setRadius(radius)
    config.radius = math.clamp(radius, 50, 1000)
end

function AutoFarm.setAttackCooldown(cooldown)
    config.attackCooldown = math.clamp(cooldown, 0.05, 2.0)
end

function AutoFarm.setHealThreshold(threshold)
    config.healThreshold = math.clamp(threshold, 5, 90)
end

function AutoFarm.addTargetMob(name)
    if not table.find(config.targetMobs, name) then
        table.insert(config.targetMobs, name)
    end
end

function AutoFarm.removeTargetMob(name)
    for i, v in ipairs(config.targetMobs) do
        if v == name then
            table.remove(config.targetMobs, i)
            break
        end
    end
end

function AutoFarm.addTargetBoss(name)
    if not table.find(config.targetBosses, name) then
        table.insert(config.targetBosses, name)
    end
end

function AutoFarm.removeTargetBoss(name)
    for i, v in ipairs(config.targetBosses) do
        if v == name then
            table.remove(config.targetBosses, i)
            break
        end
    end
end

function AutoFarm.getStats()
    return AutoFarm.stats
end

function AutoFarm.resetStats()
    AutoFarm.stats = {
        mobsKilled = 0,
        bossesKilled = 0,
        chestsOpened = 0,
        fruitsCollected = 0,
        questsCompleted = 0,
        totalXP = 0,
        totalBeli = 0,
        startTime = tick(),
        runtime = 0,
    }
end

function AutoFarm.getConfig()
    return config
end

function AutoFarm.setFarmIsland(island)
    config.farmIsland = island
end

function AutoFarm.getFarmIsland()
    return config.farmIsland
end

function AutoFarm.toggleFeature(feature, state)
    if feature == "quest" then config.questMode = state
    elseif feature == "mob" then config.mobMode = state
    elseif feature == "boss" then config.bossMode = state
    elseif feature == "chest" then config.chestMode = state
    elseif feature == "fruit" then config.fruitMode = state
    elseif feature == "heal" then config.autoHeal = state
    elseif feature == "abilities" then config.useAbilities = state
    elseif feature == "afk" then config.antiAFK = state
    elseif feature == "loot" then config.lootChests = state
    elseif feature == "drops" then config.collectDrops = state
    end
end

function AutoFarm.isFeatureEnabled(feature)
    if feature == "quest" then return config.questMode
    elseif feature == "mob" then return config.mobMode
    elseif feature == "boss" then return config.bossMode
    elseif feature == "chest" then return config.chestMode
    elseif feature == "fruit" then return config.fruitMode
    elseif feature == "heal" then return config.autoHeal
    elseif feature == "abilities" then return config.useAbilities
    elseif feature == "afk" then return config.antiAFK
    elseif feature == "loot" then return config.lootChests
    elseif feature == "drops" then return config.collectDrops
    end
    return false
end

return AutoFarm
