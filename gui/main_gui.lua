

local MainGUI = {}
MainGUI.instance = nil
MainGUI.screenGui = nil
MainGUI.isVisible = true
MainGUI.dragging = false
MainGUI.dragOffset = Vector2.new(0, 0)
MainGUI.currentTab = "Farm"
MainGUI.tabs = {"Farm", "Dich chuyen", "ESP", "Chien dau", "Tien ich", "Cai dat"}
MainGUI.callbacks = {}
MainGUI.elements = {}
MainGUI.config = {
    size = UDim2.new(0, 420, 0, 580),
    position = UDim2.new(0.5, -210, 0.5, -290),
    backgroundColor = Color3.fromRGB(10, 10, 10),
    panelColor = Color3.fromRGB(20, 20, 20),
    accentColor = Color3.fromRGB(0, 212, 255),
    accentSecondary = Color3.fromRGB(255, 0, 110),
    textColor = Color3.fromRGB(255, 255, 255),
    textSecondary = Color3.fromRGB(170, 170, 170),
    borderColor = Color3.fromRGB(42, 42, 42),
    cornerRadius = 12,
    transparency = 0.15,
    font = Enum.Font.GothamMedium,
    titleFont = Enum.Font.GothamBold,
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local function getLocalPlayer()
    return Players.LocalPlayer
end

local function createCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or MainGUI.config.cornerRadius)
    corner.Parent = instance
    return corner
end

local function createShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316048111"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ZIndex = -1
    shadow.Parent = parent
    return shadow
end

local function createTitleBar(parent, title)
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = MainGUI.config.panelColor
    titleBar.BackgroundTransparency = 0.3
    titleBar.Parent = parent

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, MainGUI.config.cornerRadius)
    titleCorner.Parent = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 20, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "✨ ShinyyX Hub ✨"
    titleLabel.TextColor3 = MainGUI.config.accentColor
    titleLabel.TextSize = 20
    titleLabel.Font = MainGUI.config.titleFont
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = MainGUI.config.accentSecondary
    closeBtn.BackgroundTransparency = 0.3
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = MainGUI.config.titleFont
    closeBtn.Parent = titleBar
    createCorner(closeBtn, 6)
    closeBtn.MouseButton1Click:Connect(function()
        MainGUI.hide()
    end)

    return titleBar
end

local function createTabContainer(parent, tabs)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 40)
    container.Position = UDim2.new(0, 0, 0, 40)
    container.BackgroundColor3 = MainGUI.config.panelColor
    container.BackgroundTransparency = 0.5
    container.Parent = parent

    local buttons = {}
    for i, name in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1 / #tabs, -2, 1, -4)
        btn.Position = UDim2.new((i - 1) / #tabs, 1, 0, 2)
        btn.BackgroundColor3 = MainGUI.config.panelColor
        btn.BackgroundTransparency = 0.5
        btn.Text = name
        btn.TextColor3 = MainGUI.config.textColor
        btn.TextSize = 13
        btn.Font = MainGUI.config.font
        btn.Name = "Tab_" .. name
        btn.Parent = container
        createCorner(btn, 6)
        btn.MouseButton1Click:Connect(function()
            MainGUI.switchTab(name)
        end)
        buttons[name] = btn
    end
    return container, buttons
end

local function createContentArea(parent)
    local area = Instance.new("Frame")
    area.Size = UDim2.new(1, -20, 1, -110)
    area.Position = UDim2.new(0, 10, 0, 85)
    area.BackgroundColor3 = MainGUI.config.panelColor
    area.BackgroundTransparency = 0.4
    area.Parent = parent
    createCorner(area, 8)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = MainGUI.config.accentColor
    scroll.ScrollBarImageTransparency = 0.5
    scroll.Parent = area

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    return area, scroll, layout
end

local function createToggle(parent, labelText, initial, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 44)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, -10, 1, 0)
    label.Text = labelText
    label.TextColor3 = MainGUI.config.textColor
    label.TextSize = 15
    label.Font = MainGUI.config.font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.BackgroundTransparency = 1
    label.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 55, 0, 32)
    toggleBtn.Position = UDim2.new(0.85, 0, 0.5, -16)
    toggleBtn.BackgroundColor3 = initial and MainGUI.config.accentColor or Color3.fromRGB(60, 60, 60)
    toggleBtn.Text = initial and "BAT" or "TAT"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 13
    toggleBtn.Font = MainGUI.config.titleFont
    toggleBtn.Parent = frame
    createCorner(toggleBtn, 6)

    local state = initial
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and MainGUI.config.accentColor or Color3.fromRGB(60, 60, 60)
        toggleBtn.Text = state and "BAT" or "TAT"
        if callback then callback(state) end
    end)

    return frame, toggleBtn
end

local function createSlider(parent, labelText, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 56)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0.4, 0)
    label.Text = labelText
    label.TextColor3 = MainGUI.config.textColor
    label.TextSize = 14
    label.Font = MainGUI.config.font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.BackgroundTransparency = 1
    label.Parent = frame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.25, 0, 0.4, 0)
    valueLabel.Position = UDim2.new(0.75, 0, 0, 0)
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = MainGUI.config.accentColor
    valueLabel.TextSize = 15
    valueLabel.Font = MainGUI.config.titleFont
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.TextYAlignment = Enum.TextYAlignment.Center
    valueLabel.BackgroundTransparency = 1
    valueLabel.Parent = frame

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(0.9, 0, 0.25, 0)
    sliderBg.Position = UDim2.new(0, 0, 0.55, 0)
    sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderBg.Parent = frame
    createCorner(sliderBg, 4)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = MainGUI.config.accentColor
    fill.Parent = sliderBg
    createCorner(fill, 4)

    local handle = Instance.new("TextButton")
    handle.Size = UDim2.new(0, 16, 0, 16)
    handle.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    handle.BackgroundColor3 = MainGUI.config.accentColor
    handle.Text = ""
    handle.BackgroundTransparency = 0
    handle.Parent = sliderBg
    createCorner(handle, 8)

    local dragging = false
    local function updateSlider(x)
        local sliderPos = sliderBg.AbsolutePosition
        local sliderSize = sliderBg.AbsoluteSize
        local rel = math.clamp((x - sliderPos.X) / sliderSize.X, 0, 1)
        local val = min + (max - min) * rel
        val = math.round(val * 10) / 10
        fill.Size = UDim2.new(rel, 0, 1, 0)
        handle.Position = UDim2.new(rel, -8, 0.5, -8)
        valueLabel.Text = tostring(val)
        if callback then callback(val) end
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input.Position.X)
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            updateSlider(input.Position.X)
        end
    end)

    RunService.Heartbeat:Connect(function()
        if dragging then
            local mouse = UserInputService:GetMouseLocation()
            updateSlider(mouse.X)
        end
    end)

    return frame, handle
end

local function createDropdown(parent, labelText, options, defaultIdx, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 48)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Text = labelText
    label.TextColor3 = MainGUI.config.textColor
    label.TextSize = 14
    label.Font = MainGUI.config.font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.BackgroundTransparency = 1
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, 0, 0.8, 0)
    btn.Position = UDim2.new(0.5, 0, 0.1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = options[defaultIdx] or options[1]
    btn.TextColor3 = MainGUI.config.textColor
    btn.TextSize = 14
    btn.Font = MainGUI.config.font
    btn.Parent = frame
    createCorner(btn, 6)

    local idx = defaultIdx or 1
    local isOpen = false
    local menu = nil

    btn.MouseButton1Click:Connect(function()
        if isOpen and menu then
            menu:Destroy()
            isOpen = false
            return
        end
        isOpen = true
        menu = Instance.new("Frame")
        menu.Size = UDim2.new(0.5, 0, 0, 0)
        menu.Position = UDim2.new(0.5, 0, 1, 2)
        menu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        menu.BackgroundTransparency = 0.1
        menu.ClipsDescendants = true
        menu.Parent = frame
        createCorner(menu, 6)

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 2)
        list.Parent = menu

        local height = 0
        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 32)
            optBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            optBtn.Text = opt
            optBtn.TextColor3 = MainGUI.config.textColor
            optBtn.TextSize = 13
            optBtn.Font = MainGUI.config.font
            optBtn.Parent = menu
            createCorner(optBtn, 4)
            optBtn.MouseButton1Click:Connect(function()
                btn.Text = opt
                idx = i
                if callback then callback(opt, i) end
                menu:Destroy()
                isOpen = false
            end)
            height = height + 34
        end
        menu.Size = UDim2.new(0.5, 0, 0, height)
        menu:TweenSize(UDim2.new(0.5, 0, 0, height), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
    end)

    return frame, btn
end

local function createButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 44)
    btn.Position = UDim2.new(0.05, 0, 0, 0)
    btn.BackgroundColor3 = MainGUI.config.accentColor
    btn.BackgroundTransparency = 0.2
    btn.Text = text
    btn.TextColor3 = MainGUI.config.textColor
    btn.TextSize = 16
    btn.Font = MainGUI.config.titleFont
    btn.Parent = parent
    createCorner(btn, 8)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function createInput(parent, labelText, placeholder, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 44)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.3, 0, 1, 0)
    label.Text = labelText
    label.TextColor3 = MainGUI.config.textColor
    label.TextSize = 14
    label.Font = MainGUI.config.font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.BackgroundTransparency = 1
    label.Parent = frame

    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0.6, 0, 0.8, 0)
    inputBox.Position = UDim2.new(0.38, 0, 0.1, 0)
    inputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    inputBox.Text = ""
    inputBox.PlaceholderText = placeholder or ""
    inputBox.TextColor3 = MainGUI.config.textColor
    inputBox.TextSize = 14
    inputBox.Font = MainGUI.config.font
    inputBox.Parent = frame
    createCorner(inputBox, 6)

    inputBox.FocusLost:Connect(function()
        if callback then callback(inputBox.Text) end
    end)

    return frame, inputBox
end

local function buildTabContent(tabName, container)
    local scroll = container:FindFirstChildOfClass("ScrollingFrame")
    if not scroll then return end
    for _, child in pairs(scroll:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("ScrollingFrame") then
            child:Destroy()
        end
    end

    local layout = scroll:FindFirstChildOfClass("UIListLayout")
    if not layout then
        layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 6)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = scroll
    end

    if tabName == "Farm" then
        local toggle1, _ = createToggle(scroll, "Bat/Tat Auto Farm", true, function(v)
            print("Auto Farm: " .. tostring(v))
        end)
        local slider1, _ = createSlider(scroll, "Ban kinh farm", 100, 800, 400, function(v)
            print("Radius: " .. tostring(v))
        end)
        local slider2, _ = createSlider(scroll, "Thoi gian don danh", 0.1, 1.0, 0.3, function(v)
            print("Cooldown: " .. tostring(v))
        end)
        local slider3, _ = createSlider(scroll, "Nguong mau tu dong hoi", 10, 90, 25, function(v)
            print("Heal threshold: " .. tostring(v))
        end)
        local drop1, _ = createDropdown(scroll, "Chon dao farm", {"Jungle", "Pirate Village", "Kingdom of Rose", "Graveyard", "Sea of Treats", "Floating Turtle"}, 1, function(opt)
            print("Island: " .. opt)
        end)
        local toggle2, _ = createToggle(scroll, "Farm nhiem vu (quest)", true, function(v)
            print("Quest: " .. tostring(v))
        end)
        local toggle3, _ = createToggle(scroll, "Farm quai (mob)", true, function(v)
            print("Mob: " .. tostring(v))
        end)
        local toggle4, _ = createToggle(scroll, "Farm boss", false, function(v)
            print("Boss: " .. tostring(v))
        end)
        local toggle5, _ = createToggle(scroll, "Mo rung", true, function(v)
            print("Chest: " .. tostring(v))
        end)
        local toggle6, _ = createToggle(scroll, "San trai ac quy", true, function(v)
            print("Fruit: " .. tostring(v))
        end)
        local toggle7, _ = createToggle(scroll, "Su dung ky nang", true, function(v)
            print("Use abilities: " .. tostring(v))
        end)
        createButton(scroll, "Bat dau Farm", function()
            print("Start farm")
        end)
        createButton(scroll, "Dung Farm", function()
            print("Stop farm")
        end)
    elseif tabName == "Dich chuyen" then
        local drop1, _ = createDropdown(scroll, "Dich chuyen den dao", {"Jungle", "Pirate Village", "Kingdom of Rose", "Graveyard", "Sea of Treats", "Floating Turtle", "Mansion"}, 1, function(opt)
            print("Teleport to island: " .. opt)
        end)
        local drop2, _ = createDropdown(scroll, "Dich chuyen den NPC", {"Quest Giver", "Shop", "Blox Fruit Dealer", "Master", "Blacksmith"}, 1, function(opt)
            print("Teleport to NPC: " .. opt)
        end)
        local drop3, _ = createDropdown(scroll, "Dich chuyen den boss", {"Greybeard", "Diamond", "Kilo Admiral", "Cursed Captain", "Don Swan", "Ice Admiral"}, 1, function(opt)
            print("Teleport to boss: " .. opt)
        end)
        createButton(scroll, "Dich chuyen den trai cay gan nhat", function()
            print("Fruit teleport")
        end)
        local slider1, _ = createSlider(scroll, "Thoi gian cho giua cac lan tp", 0.5, 3.0, 1.0, function(v)
            print("Teleport cooldown: " .. tostring(v))
        end)
        createButton(scroll, "Dich chuyen tuy chinh (nhap toa do X Y Z)", function()
            print("Custom TP")
        end)
    elseif tabName == "ESP" then
        local toggle1, _ = createToggle(scroll, "ESP nguoi choi", true, function(v)
            print("Player ESP: " .. tostring(v))
        end)
        local toggle2, _ = createToggle(scroll, "ESP boss", true, function(v)
            print("Boss ESP: " .. tostring(v))
        end)
        local toggle3, _ = createToggle(scroll, "ESP trai cay", true, function(v)
            print("Fruit ESP: " .. tostring(v))
        end)
        local toggle4, _ = createToggle(scroll, "ESP rung", true, function(v)
            print("Chest ESP: " .. tostring(v))
        end)
        local toggle5, _ = createToggle(scroll, "ESP NPC", false, function(v)
            print("NPC ESP: " .. tostring(v))
        end)
        local drop1, _ = createDropdown(scroll, "Mau ESP nguoi choi", {"Xanh", "Do", "Vang", "Tim", "Cam", "Hong"}, 1, function(opt)
            print("Player color: " .. opt)
        end)
        local drop2, _ = createDropdown(scroll, "Mau ESP boss", {"Do", "Vang", "Xanh", "Hong", "Tim"}, 1, function(opt)
            print("Boss color: " .. opt)
        end)
        local drop3, _ = createDropdown(scroll, "Mau ESP trai cay", {"Vang", "Xanh", "Do", "Cam"}, 1, function(opt)
            print("Fruit color: " .. opt)
        end)
        local slider1, _ = createSlider(scroll, "Do mo cua ESP", 0.2, 1.0, 0.8, function(v)
            print("Opacity: " .. tostring(v))
        end)
    elseif tabName == "Chien dau" then
        local toggle1, _ = createToggle(scroll, "Kill Aura (tu dong danh gan)", true, function(v)
            print("Kill Aura: " .. tostring(v))
        end)
        local slider1, _ = createSlider(scroll, "Ban kinh Kill Aura", 100, 500, 250, function(v)
            print("Kill radius: " .. tostring(v))
        end)
        local slider2, _ = createSlider(scroll, "Speed Hack (he so)", 1.0, 5.0, 2.0, function(v)
            print("Speed: " .. tostring(v))
        end)
        local toggle2, _ = createToggle(scroll, "Vo han nang luong", true, function(v)
            print("Infinite energy: " .. tostring(v))
        end)
        local toggle3, _ = createToggle(scroll, "Tu dong block", true, function(v)
            print("Auto block: " .. tostring(v))
        end)
        local toggle4, _ = createToggle(scroll, "Tu dong hoi mau", true, function(v)
            print("Auto heal: " .. tostring(v))
        end)
        local toggle5, _ = createToggle(scroll, "Su dung thuoc hoi mau", true, function(v)
            print("Use potions: " .. tostring(v))
        end)
        local toggle6, _ = createToggle(scroll, "Su dung ky nang tan cong", true, function(v)
            print("Use attack abilities: " .. tostring(v))
        end)
        createButton(scroll, "Dat lai thong so chien dau", function()
            print("Reset combat")
        end)
    elseif tabName == "Tien ich" then
        local toggle1, _ = createToggle(scroll, "Chong AFK", true, function(v)
            print("Anti AFK: " .. tostring(v))
        end)
        local toggle2, _ = createToggle(scroll, "Hien thi FPS", false, function(v)
            print("FPS counter: " .. tostring(v))
        end)
        local toggle3, _ = createToggle(scroll, "Hien thi toa do", false, function(v)
            print("Coord display: " .. tostring(v))
        end)
        local toggle4, _ = createToggle(scroll, "Thong bao trong game", true, function(v)
            print("Notifications: " .. tostring(v))
        end)
        local toggle5, _ = createToggle(scroll, "Tu dong cap nhat", true, function(v)
            print("Auto update: " .. tostring(v))
        end)
        createButton(scroll, "Chuyen server khac", function()
            print("Server hop")
        end)
        createButton(scroll, "Tai lai giao dien", function()
            print("Reload UI")
        end)
    elseif tabName == "Cai dat" then
        createButton(scroll, "Luu cau hinh", function()
            print("Save config")
        end)
        createButton(scroll, "Tai cau hinh", function()
            print("Load config")
        end)
        createButton(scroll, "Dat lai mac dinh", function()
            print("Reset default")
        end)
        local toggle1, _ = createToggle(scroll, "Tu dong cap nhat", true, function(v)
            print("Auto update: " .. tostring(v))
        end)
        local toggle2, _ = createToggle(scroll, "Che do toi (Dark mode)", true, function(v)
            print("Dark mode: " .. tostring(v))
        end)
        local drop1, _ = createDropdown(scroll, "Kich thuoc chu", {"Nho", "Trung binh", "Lon"}, 2, function(opt)
            print("Font size: " .. opt)
        end)
        createButton(scroll, "Xem thong tin hub", function()
            print("Hub info")
        end)
    end

    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
end

function MainGUI.create()
    if MainGUI.screenGui then
        MainGUI.screenGui:Destroy()
        MainGUI.screenGui = nil
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ShinyyXHub"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = MainGUI.config.size
    mainFrame.Position = MainGUI.config.position
    mainFrame.BackgroundColor3 = MainGUI.config.backgroundColor
    mainFrame.BackgroundTransparency = MainGUI.config.transparency
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = MainGUI.config.borderColor
    mainFrame.ClipsDescendants = false
    mainFrame.Parent = screenGui
    createCorner(mainFrame)
    createShadow(mainFrame)

    local titleBar = createTitleBar(mainFrame, "✨ ShinyyX Hub ✨")
    local tabContainer, tabButtons = createTabContainer(mainFrame, MainGUI.tabs)
    local contentArea, scroll, layout = createContentArea(mainFrame)

    MainGUI.screenGui = screenGui
    MainGUI.instance = mainFrame
    MainGUI.tabButtons = tabButtons
    MainGUI.scroll = scroll
    MainGUI.layout = layout
    MainGUI.contentArea = contentArea

    MainGUI.switchTab(MainGUI.currentTab)

    local dragStart = nil
    local dragFrame = nil
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragStart = input.Position
            dragFrame = mainFrame
        end
    end)
    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and dragStart and dragFrame then
            local delta = input.Position - dragStart
            dragFrame.Position = UDim2.new(
                dragFrame.Position.X.Scale,
                dragFrame.Position.X.Offset + delta.X,
                dragFrame.Position.Y.Scale,
                dragFrame.Position.Y.Offset + delta.Y
            )
            dragStart = input.Position
        end
    end)
    mainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragStart = nil
            dragFrame = nil
        end
    end)

    return screenGui
end

function MainGUI.show()
    if MainGUI.screenGui then
        MainGUI.screenGui.Enabled = true
        MainGUI.isVisible = true
        return
    end
    MainGUI.create()
    MainGUI.isVisible = true
end

function MainGUI.hide()
    if MainGUI.screenGui then
        MainGUI.screenGui.Enabled = false
        MainGUI.isVisible = false
    end
end

function MainGUI.toggle()
    if MainGUI.isVisible then
        MainGUI.hide()
    else
        MainGUI.show()
    end
end

function MainGUI.switchTab(tabName)
    MainGUI.currentTab = tabName
    for name, btn in pairs(MainGUI.tabButtons or {}) do
        if name == tabName then
            btn.BackgroundColor3 = MainGUI.config.accentColor
            btn.BackgroundTransparency = 0.3
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = MainGUI.config.panelColor
            btn.BackgroundTransparency = 0.5
            btn.TextColor3 = MainGUI.config.textSecondary
        end
    end
    if MainGUI.scroll then
        buildTabContent(tabName, MainGUI.contentArea)
    end
end

function MainGUI.destroy()
    if MainGUI.screenGui then
        MainGUI.screenGui:Destroy()
        MainGUI.screenGui = nil
        MainGUI.instance = nil
        MainGUI.isVisible = false
    end
end

function MainGUI.setSize(width, height)
    MainGUI.config.size = UDim2.new(0, width, 0, height)
    if MainGUI.instance then
        MainGUI.instance.Size = MainGUI.config.size
    end
end

function MainGUI.setPosition(scaleX, offsetX, scaleY, offsetY)
    MainGUI.config.position = UDim2.new(scaleX, offsetX, scaleY, offsetY)
    if MainGUI.instance then
        MainGUI.instance.Position = MainGUI.config.position
    end
end

function MainGUI.setAccentColor(color)
    MainGUI.config.accentColor = color
end

function MainGUI.setSecondaryAccent(color)
    MainGUI.config.accentSecondary = color
end

function MainGUI.getCurrentTab()
    return MainGUI.currentTab
end

function MainGUI.refresh()
    if MainGUI.scroll then
        buildTabContent(MainGUI.currentTab, MainGUI.contentArea)
    end
end

return MainGUI
