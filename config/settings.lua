local Settings = {}

Settings.defaults = {
    autoFarm = {
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
    },
    teleport = {
        cooldown = 1.0,
        lastIsland = "Jungle",
        lastSea = "Sea1",
    },
    esp = {
        enabled = true,
        players = true,
        bosses = true,
        fruits = true,
        chests = true,
        npcs = false,
        colorPlayers = Color3.fromRGB(0, 255, 0),
        colorBosses = Color3.fromRGB(255, 0, 0),
        colorFruits = Color3.fromRGB(255, 255, 0),
        colorChests = Color3.fromRGB(0, 255, 255),
        colorNpcs = Color3.fromRGB(0, 150, 255),
        opacity = 0.8,
        textSize = 14,
        maxDistance = 5000,
        showNames = true,
        showDistance = true,
        showHealth = true,
        showBox = true,
        outlineThickness = 1,
        updateInterval = 0.2,
    },
    combat = {
        killAura = true,
        killAuraRadius = 250,
        killAuraCooldown = 0.2,
        speedHack = false,
        speedMultiplier = 2.0,
        infiniteEnergy = true,
        autoBlock = true,
        autoHeal = true,
        healThreshold = 30,
        usePotions = true,
        useAbilities = true,
    },
    general = {
        theme = "dark",
        fontSize = "medium",
        language = "vi",
        autoUpdate = true,
        showFPS = false,
        showCoords = false,
        antiAFK = true,
        notifications = true,
        soundEffects = false,
        dragEnabled = true,
        opacity = 0.9,
        startupTab = "Farm",
    },
    hotkeys = {
        toggleGUI = "F1",
        toggleFarm = "F2",
        toggleESP = "F3",
        toggleCombat = "F4",
        teleportFruit = "F5",
        heal = "F6",
    },
    profiles = {
        current = "default",
        list = {
            default = {
                autoFarm = {},
                teleport = {},
                esp = {},
                combat = {},
                general = {},
            },
        },
    },
}

Settings.current = nil
Settings.profile = nil

local function deepClone(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = deepClone(v)
        else
            copy[k] = v
        end
    end
    return copy
end

local function mergeTables(tbl1, tbl2)
    local result = deepClone(tbl1)
    for k, v in pairs(tbl2) do
        if type(v) == "table" and type(result[k]) == "table" then
            result[k] = mergeTables(result[k], v)
        else
            result[k] = v
        end
    end
    return result
end

function Settings.load()
    local data = nil
    if readfile then
        data = pcall(readfile, "shinyyx_settings.json") and readfile("shinyyx_settings.json") or nil
    elseif syn and syn.readFile then
        data = pcall(syn.readFile, "shinyyx_settings.json") and syn.readFile("shinyyx_settings.json") or nil
    end
    if data then
        local success, parsed = pcall(function() return game:GetService("HttpService"):JSONDecode(data) end)
        if success and parsed then
            Settings.current = mergeTables(Settings.defaults, parsed)
        else
            Settings.current = deepClone(Settings.defaults)
        end
    else
        Settings.current = deepClone(Settings.defaults)
    end
    Settings.profile = Settings.current.profiles.current or "default"
    return Settings.current
end

function Settings.save()
    if not Settings.current then return false end
    local json = game:GetService("HttpService"):JSONEncode(Settings.current)
    if writefile then
        pcall(function() writefile("shinyyx_settings.json", json) end)
        return true
    elseif syn and syn.writeFile then
        pcall(function() syn.writeFile("shinyyx_settings.json", json) end)
        return true
    end
    return false
end

function Settings.get()
    if not Settings.current then
        Settings.load()
    end
    return Settings.current
end

function Settings.getSection(section)
    if not Settings.current then Settings.load() end
    return Settings.current[section] or {}
end

function Settings.getKey(section, key)
    local sec = Settings.getSection(section)
    return sec[key]
end

function Settings.setKey(section, key, value)
    if not Settings.current then Settings.load() end
    if not Settings.current[section] then
        Settings.current[section] = {}
    end
    Settings.current[section][key] = value
    Settings.save()
end

function Settings.updateSection(section, newValues)
    if not Settings.current then Settings.load() end
    if not Settings.current[section] then
        Settings.current[section] = {}
    end
    for k, v in pairs(newValues) do
        Settings.current[section][k] = v
    end
    Settings.save()
end

function Settings.resetToDefault()
    Settings.current = deepClone(Settings.defaults)
    Settings.save()
end

function Settings.resetSection(section)
    if not Settings.current then Settings.load() end
    Settings.current[section] = deepClone(Settings.defaults[section] or {})
    Settings.save()
end

function Settings.createProfile(name)
    if not Settings.current then Settings.load() end
    if Settings.current.profiles.list[name] then
        return false
    end
    local newProfile = {
        autoFarm = deepClone(Settings.defaults.autoFarm),
        teleport = deepClone(Settings.defaults.teleport),
        esp = deepClone(Settings.defaults.esp),
        combat = deepClone(Settings.defaults.combat),
        general = deepClone(Settings.defaults.general),
    }
    Settings.current.profiles.list[name] = newProfile
    Settings.save()
    return true
end

function Settings.loadProfile(name)
    if not Settings.current then Settings.load() end
    if not Settings.current.profiles.list[name] then
        return false
    end
    local profile = Settings.current.profiles.list[name]
    for section, data in pairs(profile) do
        if Settings.current[section] then
            Settings.current[section] = mergeTables(Settings.current[section], data)
        else
            Settings.current[section] = deepClone(data)
        end
    end
    Settings.current.profiles.current = name
    Settings.profile = name
    Settings.save()
    return true
end

function Settings.deleteProfile(name)
    if not Settings.current then Settings.load() end
    if name == "default" then return false end
    if Settings.current.profiles.list[name] then
        Settings.current.profiles.list[name] = nil
        if Settings.current.profiles.current == name then
            Settings.current.profiles.current = "default"
            Settings.profile = "default"
        end
        Settings.save()
        return true
    end
    return false
end

function Settings.getCurrentProfile()
    return Settings.profile or "default"
end

function Settings.getProfiles()
    if not Settings.current then Settings.load() end
    local list = {}
    for name, _ in pairs(Settings.current.profiles.list) do
        table.insert(list, name)
    end
    return list
end

function Settings.exportProfile(name)
    if not Settings.current then Settings.load() end
    local profile = Settings.current.profiles.list[name]
    if not profile then return nil end
    return game:GetService("HttpService"):JSONEncode(profile)
end

function Settings.importProfile(name, jsonData)
    if not Settings.current then Settings.load() end
    local success, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(jsonData)
    end)
    if not success then return false end
    Settings.current.profiles.list[name] = data
    Settings.save()
    return true
end

function Settings.setAutoFarmConfig(config)
    Settings.updateSection("autoFarm", config)
end

function Settings.setTeleportConfig(config)
    Settings.updateSection("teleport", config)
end

function Settings.setESPConfig(config)
    Settings.updateSection("esp", config)
end

function Settings.setCombatConfig(config)
    Settings.updateSection("combat", config)
end

function Settings.setGeneralConfig(config)
    Settings.updateSection("general", config)
end

function Settings.setHotkeys(config)
    Settings.updateSection("hotkeys", config)
end

function Settings.getAutoFarmConfig()
    return Settings.getSection("autoFarm")
end

function Settings.getTeleportConfig()
    return Settings.getSection("teleport")
end

function Settings.getESPConfig()
    return Settings.getSection("esp")
end

function Settings.getCombatConfig()
    return Settings.getSection("combat")
end

function Settings.getGeneralConfig()
    return Settings.getSection("general")
end

function Settings.getHotkeys()
    return Settings.getSection("hotkeys")
end

Settings.load()

return Settings
