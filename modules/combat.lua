local Combat = {}
Combat.killAuraEnabled = false
Combat.killAuraRadius = 250
Combat.killAuraCooldown = 0.2
Combat.lastKillAuraAttack = 0
Combat.speedHackEnabled = false
Combat.speedMultiplier = 2.0
Combat.originalSpeed = nil
Combat.infiniteEnergyEnabled = false
Combat.autoBlockEnabled = false
Combat.autoHealEnabled = false
Combat.healThreshold = 30
Combat.usePotions = true
Combat.useAbilities = true
Combat.lastHealTime = 0
Combat.running = false
Combat.killAuraTargets = {}
Combat.connections = {}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

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

local function teleportTo(targetPos, offset)
    if not targetPos then return false end
    local hrp = getHumanoidRootPart()
    if not hrp then return false end
    offset = offset or Vector3.new(0, 3, 0)
    local finalPos = targetPos + offset
    local tweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(finalPos)})
    tween:Play()
    tween.Completed:Wait()
    return true
end

local function teleportToEntity(entity, offset)
    if not entity then return false end
    local hrp = entity:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    return teleportTo(hrp.Position, offset)
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

local function findEnemiesInRadius(radius)
    local playerPos = getPosition()
    if not playerPos then return {} end
    local enemies = {}
    local player = getLocalPlayer()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            local hum = v:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local isPlayer = false
                for _, p in pairs(Players:GetPlayers()) do
                    if p.Character == v then
                        isPlayer = true
                        break
                    end
                end
                if isPlayer and v ~= getCharacter() then
                    local pos = v.HumanoidRootPart.Position
                    local dist = (pos - playerPos).magnitude
                    if dist < radius then
                        table.insert(enemies, {entity = v, distance = dist})
                    end
                elseif not isPlayer then
                    local isMob = false
                    for _, name in ipairs({"Bandit", "Pirate", "Marine", "Brute", "Mercenary", "Soldier", "Guard", "Shark", "Ghost", "Greybeard", "Diamond", "Kilo", "Cursed", "Don Swan", "Ice Admiral", "Thunder God", "Dark Beard", "Cyborg", "Fishman"}) do
                        if string.find(v.Name, name) then
                            isMob = true
                            break
                        end
                    end
                    if isMob then
                        local pos = v.HumanoidRootPart.Position
                        local dist = (pos - playerPos).magnitude
                        if dist < radius then
                            table.insert(enemies, {entity = v, distance = dist})
                        end
                    end
                end
            end
        end
    end
    table.sort(enemies, function(a, b) return a.distance < b.distance end)
    return enemies
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
    if dist > 20 then
        teleportToEntity(target, Vector3.new(0, 2, 0))
        task.wait(0.05)
    end
    local hum = getHumanoid()
    if not hum then return false end
    local tool = char:FindFirstChildWhichIsA("Tool")
    if tool then
        tool:Activate()
        return true
    else
        local attackAnim = hum:LoadAnimation(Instance.new("Animation"))
        if attackAnim then
            attackAnim:Play()
            task.wait(0.08)
            attackAnim:Stop()
            return true
        end
    end
    return false
end

local function heal()
    if not Combat.autoHealEnabled then return end
    if tick() - Combat.lastHealTime < 1 then return end
    local healthPercent = getHealthPercent()
    if healthPercent < Combat.healThreshold then
        local char = getCharacter()
        if not char then return end
        local backpack = getLocalPlayer().Backpack
        if Combat.usePotions and backpack then
            for _, item in pairs(backpack:GetChildren()) do
                if item:IsA("Tool") and string.find(item.Name, "Potion") then
                    item:Activate()
                    Combat.lastHealTime = tick()
                    return
                end
            end
        end
        if Combat.useAbilities then
            local abilities = char:FindFirstChild("Abilities")
            if abilities then
                local healAbility = abilities:FindFirstChild("Heal")
                if healAbility then
                    healAbility:FireServer()
                    Combat.lastHealTime = tick()
                    return
                end
            end
        end
    end
end

local function killAuraLoop()
    if not Combat.killAuraEnabled or not isAlive() then return end
    if tick() - Combat.lastKillAuraAttack < Combat.killAuraCooldown then return end
    local enemies = findEnemiesInRadius(Combat.killAuraRadius)
    if #enemies == 0 then return end
    local target = enemies[1].entity
    local success = attackTarget(target)
    if success then
        Combat.lastKillAuraAttack = tick()
    end
end

local function speedHackLoop()
    if not Combat.speedHackEnabled then
        if Combat.originalSpeed then
            local hum = getHumanoid()
            if hum then
                hum.WalkSpeed = Combat.originalSpeed
            end
            Combat.originalSpeed = nil
        end
        return
    end
    local hum = getHumanoid()
    if not hum then return end
    if not Combat.originalSpeed then
        Combat.originalSpeed = hum.WalkSpeed
    end
    hum.WalkSpeed = Combat.originalSpeed * Combat.speedMultiplier
end

local function infiniteEnergyLoop()
    if not Combat.infiniteEnergyEnabled then return end
    local char = getCharacter()
    if not char then return end
    local energy = char:FindFirstChild("Energy")
    local maxEnergy = char:FindFirstChild("MaxEnergy")
    if energy and maxEnergy then
        energy.Value = maxEnergy.Value
    end
end

local function autoBlockLoop()
    if not Combat.autoBlockEnabled then return end
    local char = getCharacter()
    if not char then return end
    local hum = getHumanoid()
    if not hum then return end
    if hum.Health > 0 then
        local block = char:FindFirstChild("Block")
        if block then
            block.Value = true
        end
    end
end

local function combatLoop()
    if not isAlive() then return end
    pcall(killAuraLoop)
    pcall(speedHackLoop)
    pcall(infiniteEnergyLoop)
    pcall(autoBlockLoop)
    pcall(heal)
end

function Combat.start()
    if Combat.running then return end
    Combat.running = true
    Combat.connection = RunService.Heartbeat:Connect(function()
        pcall(combatLoop)
    end)
    print("[Combat] Khoi dong chuc nang chien dau")
end

function Combat.stop()
    Combat.running = false
    if Combat.connection then
        Combat.connection:Disconnect()
        Combat.connection = nil
    end
    Combat.killAuraEnabled = false
    Combat.speedHackEnabled = false
    Combat.infiniteEnergyEnabled = false
    Combat.autoBlockEnabled = false
    Combat.autoHealEnabled = false
    if Combat.originalSpeed then
        local hum = getHumanoid()
        if hum then
            hum.WalkSpeed = Combat.originalSpeed
        end
        Combat.originalSpeed = nil
    end
    print("[Combat] Dung chuc nang chien dau")
end

function Combat.toggleKillAura(state)
    Combat.killAuraEnabled = state
end

function Combat.toggleSpeedHack(state)
    Combat.speedHackEnabled = state
    if not state then
        if Combat.originalSpeed then
            local hum = getHumanoid()
            if hum then
                hum.WalkSpeed = Combat.originalSpeed
            end
            Combat.originalSpeed = nil
        end
    end
end

function Combat.toggleInfiniteEnergy(state)
    Combat.infiniteEnergyEnabled = state
end

function Combat.toggleAutoBlock(state)
    Combat.autoBlockEnabled = state
end

function Combat.toggleAutoHeal(state)
    Combat.autoHealEnabled = state
end

function Combat.setKillAuraRadius(radius)
    Combat.killAuraRadius = math.clamp(radius, 50, 500)
end

function Combat.setSpeedMultiplier(multiplier)
    Combat.speedMultiplier = math.clamp(multiplier, 1.0, 5.0)
end

function Combat.setHealThreshold(threshold)
    Combat.healThreshold = math.clamp(threshold, 5, 90)
end

function Combat.setKillAuraCooldown(cooldown)
    Combat.killAuraCooldown = math.clamp(cooldown, 0.05, 1.0)
end

function Combat.getStatus()
    return {
        killAura = Combat.killAuraEnabled,
        killAuraRadius = Combat.killAuraRadius,
        speedHack = Combat.speedHackEnabled,
        speedMultiplier = Combat.speedMultiplier,
        infiniteEnergy = Combat.infiniteEnergyEnabled,
        autoBlock = Combat.autoBlockEnabled,
        autoHeal = Combat.autoHealEnabled,
        healThreshold = Combat.healThreshold,
        running = Combat.running,
    }
end

function Combat.attackNearest()
    local enemies = findEnemiesInRadius(Combat.killAuraRadius)
    if #enemies > 0 then
        attackTarget(enemies[1].entity)
    end
end

function Combat.resetSpeed()
    if Combat.originalSpeed then
        local hum = getHumanoid()
        if hum then
            hum.WalkSpeed = Combat.originalSpeed
        end
        Combat.originalSpeed = nil
    end
end

Combat.start()

return Combat
