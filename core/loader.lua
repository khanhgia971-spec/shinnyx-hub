--[[
    ═══════════════════════════════════════════════════════════
    FILE: loader.lua
    VERSION: 1.0.0
    DESCRIPTION: Quan ly tai module, cache, kiem tra tinh toan ven, hot-reload
    ═══════════════════════════════════════════════════════════
]]

local Loader = {}
Loader.cache = {}
Loader.hashes = {}
Loader.dependencies = {}
Loader.loading = {}
Loader.retryCount = 3
Loader.retryDelay = 0.5
Loader.baseUrl = "https://raw.githubusercontent.com/khanhgia971-spec/shinnyx-hub/main/"

local function simpleHash(str)
    local h = 0
    for i = 1, #str do
        h = (h * 31 + string.byte(str, i)) % 2^32
    end
    return tostring(h)
end

local function getModuleContent(moduleName, subfolder)
    local path = subfolder and (subfolder .. "/" .. moduleName) or moduleName
    local url = Loader.baseUrl .. path .. ".lua"
    local success, content = pcall(function()
        return game:HttpGet(url)
    end)
    if not success then
        return nil, "Khong the tai module: " .. moduleName
    end
    return content, nil
end

function Loader.loadModule(moduleName, subfolder, forceReload)
    if not moduleName or type(moduleName) ~= "string" then
        error("Loader: moduleName phai la chuoi")
    end
    local key = subfolder and (subfolder .. "/" .. moduleName) or moduleName
    if not forceReload and Loader.cache[key] then
        return Loader.cache[key]
    end
    if Loader.loading[key] then
        local timeout = 0
        while Loader.loading[key] and timeout < 30 do
            task.wait(0.1)
            timeout = timeout + 1
        end
        if Loader.cache[key] then
            return Loader.cache[key]
        end
        error("Loader: Timeout cho module " .. key)
    end
    Loader.loading[key] = true
    local content, err = getModuleContent(moduleName, subfolder)
    if not content then
        Loader.loading[key] = nil
        error("Loader: " .. err)
    end
    local hash = simpleHash(content)
    local fn, compileErr = loadstring(content, "@" .. key .. ".lua")
    if not fn then
        Loader.loading[key] = nil
        error("Loader: Loi bien dich module " .. key .. ": " .. tostring(compileErr))
    end
    local success, module = pcall(fn)
    if not success then
        Loader.loading[key] = nil
        error("Loader: Loi thuc thi module " .. key .. ": " .. tostring(module))
    end
    Loader.cache[key] = module
    Loader.hashes[key] = hash
    Loader.loading[key] = nil
    return module
end

function Loader.loadModuleWithRetry(moduleName, subfolder, forceReload, retries)
    retries = retries or Loader.retryCount
    local lastErr = nil
    for attempt = 1, retries do
        local success, result = pcall(function()
            return Loader.loadModule(moduleName, subfolder, forceReload)
        end)
        if success then
            return result
        else
            lastErr = tostring(result)
            if attempt < retries then
                task.wait(Loader.retryDelay * attempt)
            end
        end
    end
    error("Loader: Tai module that bai sau " .. tostring(retries) .. " lan: " .. lastErr)
end

function Loader.loadAllCore(forceReload)
    local coreModules = {"api", "security"}
    local loaded = {}
    for _, name in ipairs(coreModules) do
        local mod = Loader.loadModuleWithRetry(name, "core", forceReload)
        loaded[name] = mod
        task.wait(0.05)
    end
    return loaded
end

function Loader.loadAllGUI(forceReload)
    local guiModules = {"theme", "tabs", "main_gui"}
    local loaded = {}
    for _, name in ipairs(guiModules) do
        local mod = Loader.loadModuleWithRetry(name, "gui", forceReload)
        loaded[name] = mod
        task.wait(0.05)
    end
    return loaded
end

function Loader.loadAllModules(forceReload)
    local modules = {"auto_farm", "teleport", "esp", "combat", "utils"}
    local loaded = {}
    for _, name in ipairs(modules) do
        local mod = Loader.loadModuleWithRetry(name, "modules", forceReload)
        loaded[name] = mod
        task.wait(0.05)
    end
    return loaded
end

function Loader.loadConfig(forceReload)
    return Loader.loadModuleWithRetry("settings", "config", forceReload)
end

function Loader.loadEverything(forceReload)
    local result = {
        core = Loader.loadAllCore(forceReload),
        gui = Loader.loadAllGUI(forceReload),
        modules = Loader.loadAllModules(forceReload),
        config = Loader.loadConfig(forceReload),
    }
    return result
end

function Loader.checkIntegrity(moduleName, subfolder)
    local key = subfolder and (subfolder .. "/" .. moduleName) or moduleName
    if not Loader.hashes[key] then
        return false, "Module chua duoc load"
    end
    local content, err = getModuleContent(moduleName, subfolder)
    if not content then
        return false, err
    end
    local currentHash = simpleHash(content)
    if currentHash ~= Loader.hashes[key] then
        return false, "Hash khong khop: " .. key
    end
    return true, "OK"
end

function Loader.checkAllIntegrity()
    local results = {}
    local allOk = true
    for key, hash in pairs(Loader.hashes) do
        local parts = {}
        for part in string.gmatch(key, "[^/]+") do
            table.insert(parts, part)
        end
        local moduleName = parts[#parts]
        local subfolder = #parts > 1 and table.concat(parts, "/", 1, #parts - 1) or nil
        local ok, msg = Loader.checkIntegrity(moduleName, subfolder)
        results[key] = {ok = ok, msg = msg}
        if not ok then allOk = false end
    end
    return allOk, results
end

function Loader.hotReload(moduleName, subfolder)
    local key = subfolder and (subfolder .. "/" .. moduleName) or moduleName
    Loader.cache[key] = nil
    Loader.hashes[key] = nil
    Loader.loading[key] = nil
    return Loader.loadModuleWithRetry(moduleName, subfolder, true)
end

function Loader.clearCache()
    Loader.cache = {}
    Loader.hashes = {}
    Loader.loading = {}
end

function Loader.getLoadedModules()
    local list = {}
    for key, _ in pairs(Loader.cache) do
        table.insert(list, key)
    end
    return list
end

function Loader.isLoaded(moduleName, subfolder)
    local key = subfolder and (subfolder .. "/" .. moduleName) or moduleName
    return Loader.cache[key] ~= nil
end

function Loader.getModuleHash(moduleName, subfolder)
    local key = subfolder and (subfolder .. "/" .. moduleName) or moduleName
    return Loader.hashes[key]
end

function Loader.setBaseUrl(url)
    if type(url) == "string" and url ~= "" then
        Loader.baseUrl = url
    end
end

function Loader.getBaseUrl()
    return Loader.baseUrl
end

function Loader.setRetryConfig(count, delay)
    if count and count > 0 then Loader.retryCount = count end
    if delay and delay > 0 then Loader.retryDelay = delay end
end

return Loader
