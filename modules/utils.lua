local Utils = {}


function Utils.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function Utils.lerp(a, b, t)
    return a + (b - a) * t
end

function Utils.lerpColor(c1, c2, t)
    return Color3.new(
        Utils.lerp(c1.R, c2.R, t),
        Utils.lerp(c1.G, c2.G, t),
        Utils.lerp(c1.B, c2.B, t)
    )
end

function Utils.lerpVector(v1, v2, t)
    return Vector3.new(
        Utils.lerp(v1.X, v2.X, t),
        Utils.lerp(v1.Y, v2.Y, t),
        Utils.lerp(v1.Z, v2.Z, t)
    )
end

function Utils.distance(pos1, pos2)
    return (pos1 - pos2).magnitude
end

function Utils.distance2D(pos1, pos2)
    return math.sqrt((pos1.X - pos2.X)^2 + (pos1.Z - pos2.Z)^2)
end

function Utils.isInRange(pos1, pos2, range)
    return Utils.distance(pos1, pos2) <= range
end

function Utils.round(value, decimals)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    return math.floor(value * factor + 0.5) / factor
end

function Utils.randomRange(min, max)
    return math.random() * (max - min) + min
end

function Utils.randomInt(min, max)
    return math.random(min, max)
end

-- Vector utilities
function Utils.vectorToString(vec)
    return string.format("(%.1f, %.1f, %.1f)", vec.X, vec.Y, vec.Z)
end

function Utils.stringToVector(str)
    local x, y, z = string.match(str, "(%d+%.?%d*),?%s*(%d+%.?%d*),?%s*(%d+%.?%d*)")
    if x and y and z then
        return Vector3.new(tonumber(x), tonumber(y), tonumber(z))
    end
    return nil
end

function Utils.vectorAverage(vectors)
    local sum = Vector3.new(0, 0, 0)
    for _, v in ipairs(vectors) do
        sum = sum + v
    end
    return sum / #vectors
end

function Utils.vectorDirection(from, to)
    local dir = to - from
    local mag = dir.magnitude
    if mag == 0 then return Vector3.new(0, 0, 0) end
    return dir / mag
end

function Utils.angleBetween(v1, v2)
    local dot = v1.Dot(v2)
    local mag = v1.magnitude * v2.magnitude
    if mag == 0 then return 0 end
    return math.acos(Utils.clamp(dot / mag, -1, 1))
end

-- Time utilities
function Utils.formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    if hours > 0 then
        return string.format("%02d:%02d:%02d", hours, minutes, secs)
    else
        return string.format("%02d:%02d", minutes, secs)
    end
end

function Utils.formatTimeLong(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    local parts = {}
    if hours > 0 then table.insert(parts, hours .. "h") end
    if minutes > 0 then table.insert(parts, minutes .. "m") end
    if secs > 0 or #parts == 0 then table.insert(parts, secs .. "s") end
    return table.concat(parts, " ")
end

function Utils.getTimestamp()
    return os.time()
end

function Utils.getDateString()
    return os.date("%Y-%m-%d %H:%M:%S")
end

function Utils.isToday(timestamp)
    return os.date("%Y-%m-%d", timestamp) == os.date("%Y-%m-%d")
end

-- String utilities
function Utils.stringStartsWith(str, prefix)
    return string.sub(str, 1, #prefix) == prefix
end

function Utils.stringEndsWith(str, suffix)
    return string.sub(str, -#suffix) == suffix
end

function Utils.stringContains(str, pattern)
    return string.find(str, pattern) ~= nil
end

function Utils.stringSplit(str, delimiter)
    local result = {}
    for token in string.gmatch(str, "[^" .. delimiter .. "]+") do
        table.insert(result, token)
    end
    return result
end

function Utils.stringTrim(str)
    return string.gsub(str, "^%s*(.-)%s*$", "%1")
end

function Utils.stringCapitalize(str)
    return string.gsub(str, "^%l", string.upper)
end

function Utils.stringToColor(str)
    local colors = {
        red = Color3.fromRGB(255, 0, 0),
        green = Color3.fromRGB(0, 255, 0),
        blue = Color3.fromRGB(0, 0, 255),
        yellow = Color3.fromRGB(255, 255, 0),
        cyan = Color3.fromRGB(0, 255, 255),
        magenta = Color3.fromRGB(255, 0, 255),
        white = Color3.fromRGB(255, 255, 255),
        black = Color3.fromRGB(0, 0, 0),
        orange = Color3.fromRGB(255, 128, 0),
        pink = Color3.fromRGB(255, 100, 150),
        purple = Color3.fromRGB(128, 0, 255),
        gray = Color3.fromRGB(128, 128, 128),
    }
    return colors[str:lower()] or Color3.fromRGB(255, 255, 255)
end

function Utils.colorToHex(color)
    return string.format("#%02X%02X%02X", color.R * 255, color.G * 255, color.B * 255)
end

function Utils.hexToColor(hex)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1, 2), 16) or 0
    local g = tonumber(hex:sub(3, 4), 16) or 0
    local b = tonumber(hex:sub(5, 6), 16) or 0
    return Color3.fromRGB(r, g, b)
end

-- Table utilities
function Utils.tableClone(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = Utils.tableClone(v)
        else
            copy[k] = v
        end
    end
    return copy
end

function Utils.tableMerge(tbl1, tbl2)
    local result = Utils.tableClone(tbl1)
    for k, v in pairs(tbl2) do
        result[k] = v
    end
    return result
end

function Utils.tableFind(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then return k end
    end
    return nil
end

function Utils.tableFindKey(tbl, key)
    return tbl[key] ~= nil
end

function Utils.tableContains(tbl, value)
    return Utils.tableFind(tbl, value) ~= nil
end

function Utils.tableCount(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

function Utils.tableKeys(tbl)
    local keys = {}
    for k, _ in pairs(tbl) do
        table.insert(keys, k)
    end
    return keys
end

function Utils.tableValues(tbl)
    local values = {}
    for _, v in pairs(tbl) do
        table.insert(values, v)
    end
    return values
end

function Utils.tableShuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

function Utils.tableSort(tbl, comparator)
    table.sort(tbl, comparator)
    return tbl
end

-- Number utilities
function Utils.isNumber(value)
    return type(value) == "number" and not math.isnan(value)
end

function Utils.isInteger(value)
    return type(value) == "number" and math.floor(value) == value
end

function Utils.sign(value)
    if value > 0 then return 1
    elseif value < 0 then return -1
    else return 0 end
end

function Utils.percent(part, total)
    if total == 0 then return 0 end
    return (part / total) * 100
end

-- File utilities (for executors that support writefile/readfile)
function Utils.saveFile(path, content)
    if writefile then
        pcall(function() writefile(path, content) end)
        return true
    elseif syn and syn.writeFile then
        pcall(function() syn.writeFile(path, content) end)
        return true
    end
    return false
end

function Utils.loadFile(path)
    if readfile then
        return pcall(readfile, path) and readfile(path) or nil
    elseif syn and syn.readFile then
        return pcall(syn.readFile, path) and syn.readFile(path) or nil
    end
    return nil
end

function Utils.fileExists(path)
    if isfile then
        return isfile(path)
    elseif syn and syn.isFile then
        return syn.isFile(path)
    end
    return false
end

function Utils.listFiles(path)
    if listfiles then
        return listfiles(path) or {}
    elseif syn and syn.listFiles then
        return syn.listFiles(path) or {}
    end
    return {}
end

-- Misc utilities
function Utils.waitForChild(parent, name, timeout)
    timeout = timeout or 5
    local start = tick()
    while tick() - start < timeout do
        local child = parent:FindFirstChild(name)
        if child then return child end
        task.wait(0.05)
    end
    return nil
end

function Utils.waitForClass(parent, className, timeout)
    timeout = timeout or 5
    local start = tick()
    while tick() - start < timeout do
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA(className) then
                return child
            end
        end
        task.wait(0.05)
    end
    return nil
end

function Utils.createSignal()
    local callbacks = {}
    return {
        connect = function(self, callback)
            table.insert(callbacks, callback)
        end,
        fire = function(self, ...)
            for _, cb in ipairs(callbacks) do
                pcall(cb, ...)
            end
        end,
        disconnect = function(self)
            callbacks = {}
        end,
    }
end

function Utils.debounce(func, delay)
    local timer = nil
    return function(...)
        if timer then
            task.cancel(timer)
        end
        timer = task.delay(delay, function()
            timer = nil
            func(...)
        end)
    end
end

function Utils.throttle(func, interval)
    local lastRun = 0
    return function(...)
        local now = tick()
        if now - lastRun >= interval then
            lastRun = now
            func(...)
        end
    end
end

function Utils.retry(func, maxAttempts, delay)
    maxAttempts = maxAttempts or 3
    delay = delay or 0.5
    for attempt = 1, maxAttempts do
        local success, result = pcall(func)
        if success then
            return result
        end
        if attempt < maxAttempts then
            task.wait(delay * attempt)
        end
    end
    return nil
end

function Utils.getPlatform()
    local uis = game:GetService("UserInputService")
    if uis.TouchEnabled and not uis.KeyboardEnabled then
        return "mobile"
    elseif uis.KeyboardEnabled and not uis.TouchEnabled then
        return "pc"
    else
        return "unknown"
    end
end

function Utils.isMobile()
    return Utils.getPlatform() == "mobile"
end

function Utils.getScreenSize()
    local viewport = game:GetService("ViewportSize")
    return Vector2.new(viewport.X, viewport.Y)
end

return Utils
