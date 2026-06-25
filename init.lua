
local HubName = "ShinyyX Hub ✨"
local HubVersion = "1.0.0"
local GithubRaw = "https://raw.githubusercontent.com/khanhgia971-spec/shinnyx-hub/main/"

local function checkEnv()
    if not game then error("Khong tim thay game") end
    if not workspace then error("Khong tim thay workspace") end
    local executor = syn and "Synapse" or krnl and "Krnl" or script_context and "ScriptWare" or "Unknown"
    if executor == "Unknown" then
        warn("Trinh thuc thi khong xac dinh, co the khong on dinh")
    end
    return true
end

if getgenv().SHINYXX_LOADED then
    warn("Hub da duoc tai, dang reset...")
    if getgenv().SHINYXX_GUI then
        pcall(function() getgenv().SHINYXX_GUI:Destroy() end)
        getgenv().SHINYXX_GUI = nil
    end
end
getgenv().SHINYXX_LOADED = true

local function loadModule(path)
    local url = GithubRaw .. path
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success then
        error("Tai module that bai: " .. path .. "\n" .. tostring(result))
    end
    return result
end

local function createMainGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ShinyyXHub"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 420, 0, 580)
    mainFrame.Position = UDim2.new(0.5, -210, 0.5, -290)
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = Color3.fromRGB(42, 42, 42)
    mainFrame.ClipsDescendants = false
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame

    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316048111"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ZIndex = -1
    shadow.Parent = mainFrame

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    titleBar.BackgroundTransparency = 0.3
    titleBar.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 20, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "✨ ShinyyX Hub ✨"
    titleLabel.TextColor3 = Color3.fromRGB(0, 212, 255)
    titleLabel.TextSize = 20
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 110)
    closeBtn.BackgroundTransparency = 0.3
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 6)
    cCorner.Parent = closeBtn
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        getgenv().SHINYXX_LOADED = false
    end)

    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 0, 40)
    tabContainer.Position = UDim2.new(0, 0, 0, 40)
    tabContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    tabContainer.BackgroundTransparency = 0.5
    tabContainer.Parent = mainFrame

    local tabs = {"Farm", "Dich chuyen", "ESP", "Chien dau", "Tien ich", "Cai dat"}
    local tabButtons = {}
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 1, -110)
    contentFrame.Position = UDim2.new(0, 10, 0, 85)
    contentFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    contentFrame.BackgroundTransparency = 0.4
    contentFrame.Parent = mainFrame
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 8)
    contentCorner.Parent = contentFrame

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 212, 255)
    scroll.Parent = contentFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    local function createToggle(parent, labelText, initial, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 40)
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.8, -10, 1, 0)
        label.Text = labelText
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 16
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.BackgroundTransparency = 1
        label.Parent = frame

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 50, 0, 30)
        toggle.Position = UDim2.new(0.85, 0, 0.5, -15)
        toggle.BackgroundColor3 = initial and Color3.fromRGB(0, 212, 255) or Color3.fromRGB(60, 60, 60)
        toggle.Text = initial and "BAT" or "TAT"
        toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggle.TextSize = 12
        toggle.Font = Enum.Font.GothamBold
        toggle.Parent = frame
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 6)
        toggleCorner.Parent = toggle
        local state = initial
        toggle.MouseButton1Click:Connect(function()
            state = not state
            toggle.BackgroundColor3 = state and Color3.fromRGB(0, 212, 255) or Color3.fromRGB(60, 60, 60)
            toggle.Text = state and "BAT" or "TAT"
            if callback then callback(state) end
        end)
        return frame
    end

    local function createSlider(parent, labelText, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 50)
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 0.5, 0)
        label.Text = labelText
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 15
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.BackgroundTransparency = 1
        label.Parent = frame

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.2, 0, 0.5, 0)
        valueLabel.Position = UDim2.new(0.8, 0, 0, 0)
        valueLabel.Text = tostring(default)
        valueLabel.TextColor3 = Color3.fromRGB(0, 212, 255)
        valueLabel.TextSize = 15
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.BackgroundTransparency = 1
        valueLabel.Parent = frame

        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(0.9, 0, 0.3, 0)
        slider.Position = UDim2.new(0, 0, 0.6, 0)
        slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        slider.Parent = frame
        local sCorner = Instance.new("UICorner")
        sCorner.CornerRadius = UDim.new(0, 4)
        sCorner.Parent = slider

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 212, 255)
        fill.Parent = slider
        local fCorner = Instance.new("UICorner")
        fCorner.CornerRadius = UDim.new(0, 4)
        fCorner.Parent = fill

        local dragging = false
        local function updateSlider(x)
            local rel = math.clamp((x - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            local val = min + (max - min) * rel
            val = math.round(val * 10) / 10
            fill.Size = UDim2.new(rel, 0, 1, 0)
            valueLabel.Text = tostring(val)
            if callback then callback(val) end
        end
        slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateSlider(input.Position.X)
            end
        end)
        slider.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        game:GetService("RunService").Heartbeat:Connect(function()
            if dragging then
                local mouse = game:GetService("UserInputService"):GetMouseLocation()
                updateSlider(mouse.X)
            end
        end)
        return frame
    end

    local function createDropdown(parent, labelText, options, defaultIdx, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 45)
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.4, 0, 1, 0)
        label.Text = labelText
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 15
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.BackgroundTransparency = 1
        label.Parent = frame

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.5, 0, 0.8, 0)
        btn.Position = UDim2.new(0.5, 0, 0.1, 0)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        btn.Text = options[defaultIdx] or options[1]
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamMedium
        btn.Parent = frame
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        local idx = defaultIdx or 1
        btn.MouseButton1Click:Connect(function()
            local menu = Instance.new("Frame")
            menu.Size = UDim2.new(0.5, 0, 0, 0)
            menu.Position = UDim2.new(0.5, 0, 1, 2)
            menu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            menu.BackgroundTransparency = 0.1
            menu.ClipsDescendants = true
            menu.Parent = frame
            local menuCorner = Instance.new("UICorner")
            menuCorner.CornerRadius = UDim.new(0, 6)
            menuCorner.Parent = menu
            local list = Instance.new("UIListLayout")
            list.Padding = UDim.new(0, 2)
            list.Parent = menu
            local height = 0
            for i, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 30)
                optBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                optBtn.Text = opt
                optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                optBtn.TextSize = 14
                optBtn.Font = Enum.Font.GothamMedium
                optBtn.Parent = menu
                local oCorner = Instance.new("UICorner")
                oCorner.CornerRadius = UDim.new(0, 4)
                oCorner.Parent = optBtn
                optBtn.MouseButton1Click:Connect(function()
                    btn.Text = opt
                    idx = i
                    if callback then callback(opt, i) end
                    menu:Destroy()
                end)
                height = height + 32
            end
            menu.Size = UDim2.new(0.5, 0, 0, height)
            menu:TweenSize(UDim2.new(0.5, 0, 0, height), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
        end)
        return frame
    end

    local function createButton(parent, text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 40)
        btn.Position = UDim2.new(0.05, 0, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(0, 212, 255)
        btn.BackgroundTransparency = 0.2
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 16
        btn.Font = Enum.Font.GothamBold
        btn.Parent = parent
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    local function clearContent()
        for _, child in pairs(scroll:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("ScrollingFrame") then
                child:Destroy()
            end
        end
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    end

    local function buildTab(tabName)
        clearContent()
        if tabName == "Farm" then
            createToggle(scroll, "Bat/Tat Auto Farm", true, function(v) print("Auto Farm: " .. tostring(v)) end)
            createSlider(scroll, "Ban kinh farm", 100, 800, 400, function(v) print("Radius: " .. tostring(v)) end)
            createSlider(scroll, "Thoi gian don danh", 0.1, 1.0, 0.3, function(v) print("Cooldown: " .. tostring(v)) end)
            createSlider(scroll, "Nguong mau tu dong hoi", 10, 90, 25, function(v) print("Heal threshold: " .. tostring(v)) end)
            createDropdown(scroll, "Chon dao farm", {"Jungle", "Pirate Village", "Kingdom of Rose", "Graveyard", "Sea of Treats"}, 1, function(opt) print("Island: " .. opt) end)
            createToggle(scroll, "Farm nhiem vu (quest)", true, function(v) print("Quest: " .. tostring(v)) end)
            createToggle(scroll, "Farm quai (mob)", true, function(v) print("Mob: " .. tostring(v)) end)
            createToggle(scroll, "Farm boss", false, function(v) print("Boss: " .. tostring(v)) end)
            createToggle(scroll, "Mo rung", true, function(v) print("Chest: " .. tostring(v)) end)
            createToggle(scroll, "San trai ac quy", true, function(v) print("Fruit: " .. tostring(v)) end)
            createButton(scroll, "Bat dau Farm", function() print("Start farm") end)
            createButton(scroll, "Dung Farm", function() print("Stop farm") end)
        elseif tabName == "Dich chuyen" then
            createDropdown(scroll, "Dich chuyen den dao", {"Jungle", "Pirate Village", "Kingdom of Rose", "Graveyard", "Sea of Treats", "Floating Turtle", "Mansion"}, 1, function(opt) print("Teleport to island: " .. opt) end)
            createDropdown(scroll, "Dich chuyen den NPC", {"Quest Giver", "Shop", "Blox Fruit Dealer", "Master"}, 1, function(opt) print("Teleport to NPC: " .. opt) end)
            createDropdown(scroll, "Dich chuyen den boss", {"Greybeard", "Diamond", "Kilo Admiral", "Cursed Captain", "Don Swan"}, 1, function(opt) print("Teleport to boss: " .. opt) end)
            createButton(scroll, "Dich chuyen den trai cay gan nhat", function() print("Fruit teleport") end)
            createSlider(scroll, "Thoi gian cho giua cac lan tp", 0.5, 3.0, 1.0, function(v) print("Teleport cooldown: " .. tostring(v)) end)
            createButton(scroll, "Dich chuyen tuy chinh (nhap toa do)", function() print("Custom TP") end)
        elseif tabName == "ESP" then
            createToggle(scroll, "ESP nguoi choi", true, function(v) print("Player ESP: " .. tostring(v)) end)
            createToggle(scroll, "ESP boss", true, function(v) print("Boss ESP: " .. tostring(v)) end)
            createToggle(scroll, "ESP trai cay", true, function(v) print("Fruit ESP: " .. tostring(v)) end)
            createToggle(scroll, "ESP rung", true, function(v) print("Chest ESP: " .. tostring(v)) end)
            createToggle(scroll, "ESP NPC", false, function(v) print("NPC ESP: " .. tostring(v)) end)
            createDropdown(scroll, "Mau ESP nguoi choi", {"Xanh", "Do", "Vang", "Tim", "Cam"}, 1, function(opt) print("Player color: " .. opt) end)
            createDropdown(scroll, "Mau ESP boss", {"Do", "Vang", "Xanh", "Hong"}, 1, function(opt) print("Boss color: " .. opt) end)
            createSlider(scroll, "Do mo cua ESP", 0.3, 1.0, 0.8, function(v) print("Opacity: " .. tostring(v)) end)
        elseif tabName == "Chien dau" then
            createToggle(scroll, "Kill Aura (tu dong danh gan)", true, function(v) print("Kill Aura: " .. tostring(v)) end)
            createSlider(scroll, "Ban kinh Kill Aura", 100, 500, 250, function(v) print("Kill radius: " .. tostring(v)) end)
            createSlider(scroll, "Speed Hack (he so)", 1.0, 5.0, 2.0, function(v) print("Speed: " .. tostring(v)) end)
            createToggle(scroll, "Vô han nang luong", true, function(v) print("Infinite energy: " .. tostring(v)) end)
            createToggle(scroll, "Tu dong block", true, function(v) print("Auto block: " .. tostring(v)) end)
            createToggle(scroll, "Tu dong hoi mau", true, function(v) print("Auto heal: " .. tostring(v)) end)
            createToggle(scroll, "Su dung thuoc hoi mau", true, function(v) print("Use potions: " .. tostring(v)) end)
        elseif tabName == "Tien ich" then
            createToggle(scroll, "Chong AFK", true, function(v) print("Anti AFK: " .. tostring(v)) end)
            createToggle(scroll, "Hien thi FPS", false, function(v) print("FPS counter: " .. tostring(v)) end)
            createToggle(scroll, "Hien thi toa do", false, function(v) print("Coord display: " .. tostring(v)) end)
            createToggle(scroll, "Thong bao trong game", true, function(v) print("Notifications: " .. tostring(v)) end)
            createButton(scroll, "Chuyen server khac", function() print("Server hop") end)
        elseif tabName == "Cai dat" then
            createButton(scroll, "Luu cau hinh", function() print("Save config") end)
            createButton(scroll, "Tai cau hinh", function() print("Load config") end)
            createButton(scroll, "Dat lai mac dinh", function() print("Reset default") end)
            createToggle(scroll, "Tu dong cap nhat", true, function(v) print("Auto update: " .. tostring(v)) end)
        end
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end

    for i, name in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1 / #tabs, -2, 1, -4)
        btn.Position = UDim2.new((i - 1) / #tabs, 1, 0, 2)
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        btn.BackgroundTransparency = 0.5
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamMedium
        btn.Parent = tabContainer
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        btn.MouseButton1Click:Connect(function()
            buildTab(name)
        end)
        tabButtons[name] = btn
    end

    buildTab("Farm")
    return screenGui
end

local function main()
    checkEnv()
    local gui = createMainGUI()
    getgenv().SHINYXX_GUI = gui
    print("ShinyyX Hub da khoi dong thanh cong!")
end

local success, err = pcall(main)
if not success then
    warn("Loi khoi dong: " .. tostring(err))
    task.wait(3)
    pcall(main)
end
