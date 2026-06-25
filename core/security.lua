
local Security = {}

local base64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function encodeBase64(input)
    local bytes = { string.byte(input, 1, #input) }
    local result = {}
    for i = 1, #bytes, 3 do
        local a = bytes[i]
        local b = bytes[i + 1] or 0
        local c = bytes[i + 2] or 0
        local n = (a * 0x10000) + (b * 0x100) + c
        local chars = {
            base64Chars:sub((math.floor(n / 0x40000) % 0x40) + 1, (math.floor(n / 0x40000) % 0x40) + 1),
            base64Chars:sub((math.floor(n / 0x1000) % 0x40) + 1, (math.floor(n / 0x1000) % 0x40) + 1),
            base64Chars:sub((math.floor(n / 0x40) % 0x40) + 1, (math.floor(n / 0x40) % 0x40) + 1),
            base64Chars:sub((n % 0x40) + 1, (n % 0x40) + 1)
        }
        local padding = #bytes - i + 1
        if padding == 1 then
            chars[3] = "="
            chars[4] = "="
        elseif padding == 2 then
            chars[4] = "="
        end
        result[#result + 1] = table.concat(chars)
    end
    return table.concat(result)
end

local function decodeBase64(input)
    input = input:gsub("[^A-Za-z0-9+/=]", "")
    local result = {}
    for i = 1, #input, 4 do
        local chars = {
            input:sub(i, i):byte(),
            input:sub(i + 1, i + 1):byte(),
            input:sub(i + 2, i + 2):byte(),
            input:sub(i + 3, i + 3):byte()
        }
        local values = {}
        for j = 1, 4 do
            local c = chars[j]
            if c and c ~= 61 then
                local idx = base64Chars:find(string.char(c), 1, true)
                if idx then
                    values[j] = idx - 1
                else
                    values[j] = 0
                end
            else
                values[j] = 0
            end
        end
        local n = (values[1] or 0) * 0x40000 + (values[2] or 0) * 0x1000 + (values[3] or 0) * 0x40 + (values[4] or 0)
        local a = math.floor(n / 0x10000)
        local b = math.floor((n % 0x10000) / 0x100)
        local c = n % 0x100
        result[#result + 1] = string.char(a)
        if input:sub(i + 2, i + 2) ~= "=" then
            result[#result + 1] = string.char(b)
        end
        if input:sub(i + 3, i + 3) ~= "=" then
            result[#result + 1] = string.char(c)
        end
    end
    return table.concat(result)
end

local xorKey = 0x55
local function xorEncode(str)
    local result = {}
    for i = 1, #str do
        result[i] = string.char(bit32.bxor(string.byte(str, i), xorKey))
    end
    return table.concat(result)
end

local function xorDecode(str)
    return xorEncode(str)
end

function Security.obfuscate(str)
    if type(str) ~= "string" then return str end
    local encoded = xorEncode(str)
    return encodeBase64(encoded)
end

function Security.deobfuscate(obfuscated)
    if type(obfuscated) ~= "string" then return obfuscated end
    local decoded = decodeBase64(obfuscated)
    return xorDecode(decoded)
end

function Security.obfuscateTable(tbl)
    if type(tbl) ~= "table" then return tbl end
    local result = {}
    for k, v in pairs(tbl) do
        local newKey = type(k) == "string" and Security.obfuscate(k) or k
        if type(v) == "string" then
            result[newKey] = Security.obfuscate(v)
        elseif type(v) == "table" then
            result[newKey] = Security.obfuscateTable(v)
        else
            result[newKey] = v
        end
    end
    return result
end

function Security.deobfuscateTable(tbl)
    if type(tbl) ~= "table" then return tbl end
    local result = {}
    for k, v in pairs(tbl) do
        local newKey = type(k) == "string" and Security.deobfuscate(k) or k
        if type(v) == "string" then
            result[newKey] = Security.deobfuscate(v)
        elseif type(v) == "table" then
            result[newKey] = Security.deobfuscateTable(v)
        else
            result[newKey] = v
        end
    end
    return result
end

function Security.generateRandomString(length)
    length = length or 16
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = {}
    for i = 1, length do
        result[i] = chars:sub(math.random(1, #chars), math.random(1, #chars))
    end
    return table.concat(result)
end

function Security.spoofFunctionName(func, newName)
    if type(func) ~= "function" then return func end
    local env = getfenv(func)
    local oldName = nil
    for k, v in pairs(env) do
        if v == func then
            oldName = k
            break
        end
    end
    if oldName then
        env[oldName] = nil
    end
    local spoofed = func
    if newName then
        env[newName] = spoofed
    else
        local randomName = Security.generateRandomString(12)
        env[randomName] = spoofed
    end
    return spoofed
end

function Security.signatureSpoof(func)
    if type(func) ~= "function" then return func end
    local env = getfenv(func)
    local newName = Security.generateRandomString(16)
    env[newName] = func
    return function(...)
        return env[newName](...)
    end
end

function Security.isDebugging()
    local success, result = pcall(function()
        return debug and debug.getinfo and debug.getinfo(1)
    end)
    if success and result then
        return true
    end
    local success2, result2 = pcall(function()
        return getfenv and getfenv() and getfenv(0)
    end)
    if not success2 then
        return true
    end
    return false
end

function Security.antiDebug()
    if Security.isDebugging() then
        while true do
            task.wait(1)
        end
    end
end

function Security.antiDecompile()
    local env = getfenv(0)
    if env.print then
        local oldPrint = env.print
        env.print = function(...)
            local args = {...}
            for i, v in ipairs(args) do
                if type(v) == "string" and string.find(v, "decompile") then
                    oldPrint("Access Denied")
                    return
                end
            end
            return oldPrint(...)
        end
    end
end

function Security.checkEnvironment()
    local required = {
        "game", "workspace", "players", "ReplicatedStorage",
        "RunService", "TweenService", "UserInputService"
    }
    local missing = {}
    for _, name in ipairs(required) do
        local obj = _G[name] or getfenv(0)[name]
        if not obj then
            table.insert(missing, name)
        end
    end
    if #missing > 0 then
        return false, missing
    end
    return true, {}
end

function Security.sandboxEnvironment()
    local safeEnv = {}
    local allowed = {
        "print", "warn", "error", "tostring", "tonumber",
        "type", "pairs", "ipairs", "next", "select",
        "string", "table", "math", "bit32", "task",
        "Vector3", "Color3", "CFrame", "UDim2", "Instance",
        "game", "workspace", "players", "ReplicatedStorage"
    }
    for _, name in ipairs(allowed) do
        safeEnv[name] = _G[name] or getfenv(0)[name]
    end
    safeEnv.getfenv = nil
    safeEnv.setfenv = nil
    safeEnv.loadstring = nil
    safeEnv.dostring = nil
    safeEnv.debug = nil
    return safeEnv
end

function Security.protectTable(tbl)
    if type(tbl) ~= "table" then return tbl end
    local proxy = {}
    local mt = {
        __index = function(t, k)
            return tbl[k]
        end,
        __newindex = function(t, k, v)
            if k == "protected" then
                return
            end
            tbl[k] = v
        end,
        __metatable = false
    }
    setmetatable(proxy, mt)
    return proxy
end

function Security.unprotectTable(protected)
    if type(protected) ~= "table" then return protected end
    local mt = getmetatable(protected)
    if mt and mt.__index then
        return mt.__index
    end
    return protected
end

function Security.encryptString(str, key)
    if not key then key = xorKey end
    local result = {}
    for i = 1, #str do
        local byte = string.byte(str, i)
        local keyByte = string.byte(key, (i - 1) % #key + 1)
        result[i] = string.char(bit32.bxor(byte, keyByte))
    end
    return table.concat(result)
end

function Security.decryptString(str, key)
    return Security.encryptString(str, key)
end

function Security.hashString(str)
    local h = 0
    for i = 1, #str do
        h = (h * 31 + string.byte(str, i)) % 2^32
    end
    return string.format("%08x", h)
end

function Security.hashTable(tbl)
    local str = ""
    for k, v in pairs(tbl) do
        str = str .. tostring(k) .. tostring(v)
    end
    return Security.hashString(str)
end

function Security.randomizeFunction(func)
    if type(func) ~= "function" then return func end
    local env = getfenv(func)
    local oldName = nil
    for k, v in pairs(env) do
        if v == func then
            oldName = k
            break
        end
    end
    if oldName then
        env[oldName] = nil
    end
    local newName = Security.generateRandomString(20)
    env[newName] = func
    return env[newName]
end

function Security.wrapFunction(func, wrapper)
    if type(func) ~= "function" then return func end
    return function(...)
        return wrapper(func, ...)
    end
end

function Security.hookFunction(original, hook)
    if type(original) ~= "function" then return original end
    return function(...)
        hook(...)
        return original(...)
    end
end

function Security.validateModule(module, expectedHash)
    if type(module) ~= "table" then return false end
    local hash = Security.hashTable(module)
    if expectedHash and hash ~= expectedHash then
        return false
    end
    return true
end

function Security.stripComments(code)
    if type(code) ~= "string" then return code end
    local result = {}
    local inString = false
    local inComment = false
    local inLineComment = false
    for i = 1, #code do
        local char = code:sub(i, i)
        if char == '"' and not inComment and not inLineComment then
            inString = not inString
            result[#result + 1] = char
        elseif char == "'" and not inComment and not inLineComment then
            inString = not inString
            result[#result + 1] = char
        elseif char == "-" and code:sub(i + 1, i + 1) == "-" and not inString then
            inLineComment = true
        elseif char == "\n" and inLineComment then
            inLineComment = false
            result[#result + 1] = char
        elseif char == "-" and code:sub(i + 1, i + 1) == "[" and code:sub(i + 2, i + 2) == "[" and not inString then
            inComment = true
        elseif char == "]" and code:sub(i + 1, i + 1) == "]" and code:sub(i + 2, i + 2) == "-" and inComment then
            inComment = false
            i = i + 2
        elseif not inLineComment and not inComment then
            result[#result + 1] = char
        end
    end
    return table.concat(result)
end

function Security.generateKey()
    return Security.generateRandomString(32)
end

function Security.generateIV()
    return Security.generateRandomString(16)
end

function Security.secureCompare(str1, str2)
    if #str1 ~= #str2 then return false end
    local result = 0
    for i = 1, #str1 do
        result = bit32.bor(result, bit32.bxor(string.byte(str1, i), string.byte(str2, i)))
    end
    return result == 0
end

function Security.maskSensitive(str, visible)
    visible = visible or 4
    if #str <= visible * 2 then return string.rep("*", #str) end
    local prefix = str:sub(1, visible)
    local suffix = str:sub(-visible)
    local masked = string.rep("*", #str - visible * 2)
    return prefix .. masked .. suffix
end

return Security
