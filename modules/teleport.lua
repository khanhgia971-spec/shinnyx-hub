local Teleport = {}
Teleport.lastTeleportTime = 0
Teleport.cooldown = 1.0
Teleport.history = {}
Teleport.favorites = {}
Teleport.isTeleporting = false

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function getLocalPlayer()
    return Players.LocalPlayer
end

local function getCharacter()
    local player = getLocalPlayer()
    if not player then return nil end
    return player.Character
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
    local char = getCharacter()
    if not char then return false end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return false end
    return hum.Health > 0
end

local function teleportTo(targetPos, offset)
    if not targetPos then return false end
    if not isAlive() then return false end
    local hrp = getHumanoidRootPart()
    if not hrp then return false end
    offset = offset or Vector3.new(0, 3, 0)
    local finalPos = targetPos + offset
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear)
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

local islands = {
    Sea1 = {
        Jungle = Vector3.new(-1000, 100, 0),
        PirateVillage = Vector3.new(-500, 50, 800),
        Desert = Vector3.new(300, 80, -1200),
        FrozenVillage = Vector3.new(-1500, 60, 1500),
        MarineFort = Vector3.new(800, 50, 2000),
        SkyIsland = Vector3.new(0, 400, 0),
    },
    Sea2 = {
        KingdomOfRose = Vector3.new(2000, 150, 1000),
        Graveyard = Vector3.new(-1500, 80, -1500),
        SnowMountain = Vector3.new(-2000, 200, 500),
        HotAndCold = Vector3.new(1500, 100, -2000),
        CursedShip = Vector3.new(-800, 50, 3000),
        IceCastle = Vector3.new(2500, 200, -1000),
    },
    Sea3 = {
        SeaOfTreats = Vector3.new(3000, 120, -2000),
        FloatingTurtle = Vector3.new(-2500, 300, 2500),
        Mansion = Vector3.new(1000, 200, -3000),
        DarkArena = Vector3.new(2500, 150, -1500),
        HauntedCastle = Vector3.new(-3000, 250, -500),
        CandyLand = Vector3.new(3500, 100, 1500),
    }
}

local npcs = {
    QuestGiver = "Quest Giver",
    Shop = "Shop",
    BloxFruitDealer = "Blox Fruit Dealer",
    Master = "Master",
    Blacksmith = "Blacksmith",
    Doctor = "Doctor",
    Bartender = "Bartender",
}

local bosses = {
    Greybeard = "Greybeard",
    Diamond = "Diamond",
    KiloAdmiral = "Kilo Admiral",
    CursedCaptain = "Cursed Captain",
    DonSwan = "Don Swan",
    IceAdmiral = "Ice Admiral",
    ThunderGod = "Thunder God",
    DarkBeard = "Dark Beard",
    Cyborg = "Cyborg",
    FishmanLord = "Fishman Lord",
}

function Teleport.setCooldown(seconds)
    if seconds and seconds > 0 then
        Teleport.cooldown = seconds
    end
end

function Teleport.getCooldown()
    return Teleport.cooldown
end

function Teleport.canTeleport()
    return tick() - Teleport.lastTeleportTime >= Teleport.cooldown and not Teleport.isTeleporting
end

function Teleport.toIsland(sea, islandName)
    if not Teleport.canTeleport() then return false, "Dang trong thoi gian cho" end
    local seaData = islands[sea]
    if not seaData then return false, "Khong tim thay sea" end
    local pos = seaData[islandName]
    if not pos then return false, "Khong tim thay dao" end
    Teleport.isTeleporting = true
    local success = teleportTo(pos)
    Teleport.isTeleporting = false
    if success then
        Teleport.lastTeleportTime = tick()
        table.insert(Teleport.history, {type = "island", name = islandName, time = os.time()})
        if #Teleport.history > 50 then table.remove(Teleport.history, 1) end
        return true, "Da dich chuyen den " .. islandName
    else
        return false, "Khong the dich chuyen"
    end
end

function Teleport.toIslandByName(islandName)
    for sea, data in pairs(islands) do
        for name, pos in pairs(data) do
            if name == islandName then
                return Teleport.toIsland(sea, name)
            end
        end
    end
    return false, "Khong tim thay dao"
end

function Teleport.toNPC(npcName)
    if not Teleport.canTeleport() then return false, "Dang trong thoi gian cho" end
    local playerPos = getPosition()
    if not playerPos then return false, "Khong lay duoc vi tri" end
    local nearest = nil
    local nearestDist = math.huge
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            if string.find(v.Name, npcName) or string.find(v.Name, npcs[npcName] or "") then
                local pos = v.HumanoidRootPart.Position
                local dist = (pos - playerPos).magnitude
                if dist < nearestDist then
                    nearest = v
                    nearestDist = dist
                end
            end
        end
    end
    if not nearest then return false, "Khong tim thay NPC" end
    Teleport.isTeleporting = true
    local success = teleportToEntity(nearest)
    Teleport.isTeleporting = false
    if success then
        Teleport.lastTeleportTime = tick()
        table.insert(Teleport.history, {type = "npc", name = npcName, time = os.time()})
        return true, "Da dich chuyen den NPC " .. npcName
    else
        return false, "Khong the dich chuyen"
    end
end

function Teleport.toBoss(bossName)
    if not Teleport.canTeleport() then return false, "Dang trong thoi gian cho" end
    local playerPos = getPosition()
    if not playerPos then return false, "Khong lay duoc vi tri" end
    local nearest = nil
    local nearestDist = math.huge
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            local hum = v:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                if string.find(v.Name, bossName) or string.find(v.Name, bosses[bossName] or "") then
                    local pos = v.HumanoidRootPart.Position
                    local dist = (pos - playerPos).magnitude
                    if dist < nearestDist then
                        nearest = v
                        nearestDist = dist
                    end
                end
            end
        end
    end
    if not nearest then return false, "Khong tim thay boss" end
    Teleport.isTeleporting = true
    local success = teleportToEntity(nearest, Vector3.new(0, 5, 0))
    Teleport.isTeleporting = false
    if success then
        Teleport.lastTeleportTime = tick()
        table.insert(Teleport.history, {type = "boss", name = bossName, time = os.time()})
        return true, "Da dich chuyen den boss " .. bossName
    else
        return false, "Khong the dich chuyen"
    end
end

function Teleport.toFruit()
    if not Teleport.canTeleport() then return false, "Dang trong thoi gian cho" end
    local playerPos = getPosition()
    if not playerPos then return false, "Khong lay duoc vi tri" end
    local nearest = nil
    local nearestDist = math.huge
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Part") and v.Name == "Fruit" and v.Parent and v.Parent:IsA("Model") then
            local pos = v.Position
            local dist = (pos - playerPos).magnitude
            if dist < nearestDist then
                nearest = v.Parent
                nearestDist = dist
            end
        end
    end
    if not nearest then return false, "Khong tim thay trai cay" end
    Teleport.isTeleporting = true
    local success = teleportToEntity(nearest)
    Teleport.isTeleporting = false
    if success then
        Teleport.lastTeleportTime = tick()
        table.insert(Teleport.history, {type = "fruit", name = "Fruit", time = os.time()})
        return true, "Da dich chuyen den trai cay"
    else
        return false, "Khong the dich chuyen"
    end
end

function Teleport.toChest()
    if not Teleport.canTeleport() then return false, "Dang trong thoi gian cho" end
    local playerPos = getPosition()
    if not playerPos then return false, "Khong lay duoc vi tri" end
    local nearest = nil
    local nearestDist = math.huge
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Handle") and v:FindFirstChild("TouchInterest") then
            local pos = v:FindFirstChild("Handle") and v.Handle.Position or v.PrimaryPart and v.PrimaryPart.Position
            if pos then
                local dist = (pos - playerPos).magnitude
                if dist < nearestDist then
                    nearest = v
                    nearestDist = dist
                end
            end
        end
    end
    if not nearest then return false, "Khong tim thay rung" end
    Teleport.isTeleporting = true
    local success = teleportToEntity(nearest)
    Teleport.isTeleporting = false
    if success then
        Teleport.lastTeleportTime = tick()
        table.insert(Teleport.history, {type = "chest", name = "Chest", time = os.time()})
        return true, "Da dich chuyen den rung"
    else
        return false, "Khong the dich chuyen"
    end
end

function Teleport.toCustom(x, y, z)
    if not Teleport.canTeleport() then return false, "Dang trong thoi gian cho" end
    local pos = Vector3.new(x, y, z)
    Teleport.isTeleporting = true
    local success = teleportTo(pos)
    Teleport.isTeleporting = false
    if success then
        Teleport.lastTeleportTime = tick()
        table.insert(Teleport.history, {type = "custom", name = string.format("%.1f, %.1f, %.1f", x, y, z), time = os.time()})
        return true, "Da dich chuyen den toa do tuy chinh"
    else
        return false, "Khong the dich chuyen"
    end
end

function Teleport.toCoordinates(vec)
    return Teleport.toCustom(vec.X, vec.Y, vec.Z)
end

function Teleport.getIslands()
    local result = {}
    for sea, data in pairs(islands) do
        for name, pos in pairs(data) do
            table.insert(result, {sea = sea, name = name, pos = pos})
        end
    end
    return result
end

function Teleport.getIslandsBySea(sea)
    local result = {}
    local data = islands[sea]
    if not data then return result end
    for name, pos in pairs(data) do
        table.insert(result, {name = name, pos = pos})
    end
    return result
end

function Teleport.getNPCs()
    local result = {}
    for key, name in pairs(npcs) do
        table.insert(result, {key = key, name = name})
    end
    return result
end

function Teleport.getBosses()
    local result = {}
    for key, name in pairs(bosses) do
        table.insert(result, {key = key, name = name})
    end
    return result
end

function Teleport.addFavorite(type, name)
    if not Teleport.favorites[type] then Teleport.favorites[type] = {} end
    if not table.find(Teleport.favorites[type], name) then
        table.insert(Teleport.favorites[type], name)
        return true
    end
    return false
end

function Teleport.removeFavorite(type, name)
    if not Teleport.favorites[type] then return false end
    for i, v in ipairs(Teleport.favorites[type]) do
        if v == name then
            table.remove(Teleport.favorites[type], i)
            return true
        end
    end
    return false
end

function Teleport.getFavorites(type)
    return Teleport.favorites[type] or {}
end

function Teleport.clearHistory()
    Teleport.history = {}
end

function Teleport.getHistory()
    return Teleport.history
end

function Teleport.getLastTeleport()
    if #Teleport.history > 0 then
        return Teleport.history[#Teleport.history]
    end
    return nil
end

function Teleport.getStatus()
    return {
        canTeleport = Teleport.canTeleport(),
        cooldown = Teleport.cooldown,
        lastTeleport = Teleport.lastTeleportTime,
        remainingCooldown = math.max(0, Teleport.cooldown - (tick() - Teleport.lastTeleportTime)),
        isTeleporting = Teleport.isTeleporting,
    }
end

return Teleport
