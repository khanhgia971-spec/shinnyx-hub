
local Tabs = {}
Tabs.buttons = {}
Tabs.currentTab = nil
Tabs.callback = nil
Tabs.container = nil
Tabs.parent = nil
Tabs.config = {
    tabHeight = 40,
    tabFont = Enum.Font.GothamMedium,
    tabTextSize = 13,
    activeColor = Color3.fromRGB(0, 212, 255),
    inactiveColor = Color3.fromRGB(60, 60, 60),
    activeTextColor = Color3.fromRGB(255, 255, 255),
    inactiveTextColor = Color3.fromRGB(170, 170, 170),
    backgroundColor = Color3.fromRGB(20, 20, 20),
    backgroundTransparency = 0.5,
    cornerRadius = 6,
}

function Tabs.setConfig(newConfig)
    for k, v in pairs(newConfig) do
        Tabs.config[k] = v
    end
end

local function createCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or Tabs.config.cornerRadius)
    corner.Parent = instance
    return corner
end

function Tabs.create(parent, tabNames, defaultTab, onTabChange)
    if Tabs.container then
        Tabs.container:Destroy()
        Tabs.container = nil
    end
    Tabs.parent = parent
    Tabs.callback = onTabChange
    Tabs.buttons = {}

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, Tabs.config.tabHeight)
    container.Position = UDim2.new(0, 0, 0, 0)
    container.BackgroundColor3 = Tabs.config.backgroundColor
    container.BackgroundTransparency = Tabs.config.backgroundTransparency
    container.Parent = parent
    Tabs.container = container

    local count = #tabNames
    for i, name in ipairs(tabNames) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1 / count, -2, 1, -4)
        btn.Position = UDim2.new((i - 1) / count, 1, 0, 2)
        btn.BackgroundColor3 = Tabs.config.inactiveColor
        btn.BackgroundTransparency = 0.3
        btn.Text = name
        btn.TextColor3 = Tabs.config.inactiveTextColor
        btn.TextSize = Tabs.config.tabTextSize
        btn.Font = Tabs.config.tabFont
        btn.Name = "Tab_" .. name
        btn.Parent = container
        createCorner(btn, Tabs.config.cornerRadius)
        btn.MouseButton1Click:Connect(function()
            Tabs.switchTo(name)
        end)
        Tabs.buttons[name] = btn
    end

    if defaultTab and Tabs.buttons[defaultTab] then
        Tabs.switchTo(defaultTab)
    elseif tabNames and #tabNames > 0 then
        Tabs.switchTo(tabNames[1])
    end

    return container, Tabs.buttons
end

function Tabs.switchTo(tabName)
    if not Tabs.buttons[tabName] then
        return false
    end
    for name, btn in pairs(Tabs.buttons) do
        if name == tabName then
            btn.BackgroundColor3 = Tabs.config.activeColor
            btn.BackgroundTransparency = 0.2
            btn.TextColor3 = Tabs.config.activeTextColor
        else
            btn.BackgroundColor3 = Tabs.config.inactiveColor
            btn.BackgroundTransparency = 0.3
            btn.TextColor3 = Tabs.config.inactiveTextColor
        end
    end
    Tabs.currentTab = tabName
    if Tabs.callback then
        Tabs.callback(tabName)
    end
    return true
end

function Tabs.getCurrentTab()
    return Tabs.currentTab
end

function Tabs.getButton(tabName)
    return Tabs.buttons[tabName]
end

function Tabs.getAllButtons()
    return Tabs.buttons
end

function Tabs.addTab(tabName, afterIndex)
    if not Tabs.container then
        return false
    end
    if Tabs.buttons[tabName] then
        return false
    end
    local count = #Tabs.buttons + 1
    local newBtn = Instance.new("TextButton")
    newBtn.Size = UDim2.new(1 / count, -2, 1, -4)
    newBtn.BackgroundColor3 = Tabs.config.inactiveColor
    newBtn.BackgroundTransparency = 0.3
    newBtn.Text = tabName
    newBtn.TextColor3 = Tabs.config.inactiveTextColor
    newBtn.TextSize = Tabs.config.tabTextSize
    newBtn.Font = Tabs.config.tabFont
    newBtn.Name = "Tab_" .. tabName
    newBtn.Parent = Tabs.container
    createCorner(newBtn, Tabs.config.cornerRadius)
    newBtn.MouseButton1Click:Connect(function()
        Tabs.switchTo(tabName)
    end)
    Tabs.buttons[tabName] = newBtn
    -- Update positions of all buttons
    local idx = 0
    for _, btn in pairs(Tabs.buttons) do
        idx = idx + 1
        btn.Size = UDim2.new(1 / count, -2, 1, -4)
        btn.Position = UDim2.new((idx - 1) / count, 1, 0, 2)
    end
    return true
end

function Tabs.removeTab(tabName)
    if not Tabs.buttons[tabName] then
        return false
    end
    local btn = Tabs.buttons[tabName]
    btn:Destroy()
    Tabs.buttons[tabName] = nil
    if Tabs.currentTab == tabName then
        Tabs.currentTab = nil
        local first = next(Tabs.buttons)
        if first then
            Tabs.switchTo(first)
        end
    end
    -- Update positions
    local count = #Tabs.buttons
    local idx = 0
    for _, btn in pairs(Tabs.buttons) do
        idx = idx + 1
        btn.Size = UDim2.new(1 / count, -2, 1, -4)
        btn.Position = UDim2.new((idx - 1) / count, 1, 0, 2)
    end
    return true
end

function Tabs.renameTab(oldName, newName)
    if not Tabs.buttons[oldName] then
        return false
    end
    local btn = Tabs.buttons[oldName]
    btn.Text = newName
    btn.Name = "Tab_" .. newName
    Tabs.buttons[newName] = btn
    Tabs.buttons[oldName] = nil
    if Tabs.currentTab == oldName then
        Tabs.currentTab = newName
    end
    return true
end

function Tabs.setActiveColor(color)
    Tabs.config.activeColor = color
    if Tabs.currentTab and Tabs.buttons[Tabs.currentTab] then
        Tabs.buttons[Tabs.currentTab].BackgroundColor3 = color
    end
end

function Tabs.setInactiveColor(color)
    Tabs.config.inactiveColor = color
    for name, btn in pairs(Tabs.buttons) do
        if name ~= Tabs.currentTab then
            btn.BackgroundColor3 = color
        end
    end
end

function Tabs.setActiveTextColor(color)
    Tabs.config.activeTextColor = color
    if Tabs.currentTab and Tabs.buttons[Tabs.currentTab] then
        Tabs.buttons[Tabs.currentTab].TextColor3 = color
    end
end

function Tabs.setInactiveTextColor(color)
    Tabs.config.inactiveTextColor = color
    for name, btn in pairs(Tabs.buttons) do
        if name ~= Tabs.currentTab then
            btn.TextColor3 = color
        end
    end
end

function Tabs.setTabHeight(height)
    Tabs.config.tabHeight = height
    if Tabs.container then
        Tabs.container.Size = UDim2.new(1, 0, 0, height)
    end
end

function Tabs.setFont(font, size)
    Tabs.config.tabFont = font
    Tabs.config.tabTextSize = size
    for _, btn in pairs(Tabs.buttons) do
        btn.Font = font
        btn.TextSize = size
    end
end

function Tabs.destroy()
    if Tabs.container then
        Tabs.container:Destroy()
        Tabs.container = nil
    end
    Tabs.buttons = {}
    Tabs.currentTab = nil
    Tabs.callback = nil
end

function Tabs.getContainer()
    return Tabs.container
end

function Tabs.getTabNames()
    local names = {}
    for name, _ in pairs(Tabs.buttons) do
        table.insert(names, name)
    end
    return names
end

function Tabs.count()
    local count = 0
    for _ in pairs(Tabs.buttons) do
        count = count + 1
    end
    return count
end

function Tabs.isTabActive(tabName)
    return Tabs.currentTab == tabName
end

function Tabs.highlightTab(tabName, highlightColor)
    local btn = Tabs.buttons[tabName]
    if not btn then return false end
    local originalColor = btn.BackgroundColor3
    btn.BackgroundColor3 = highlightColor or Color3.fromRGB(255, 200, 0)
    task.wait(0.3)
    if Tabs.currentTab == tabName then
        btn.BackgroundColor3 = Tabs.config.activeColor
    else
        btn.BackgroundColor3 = originalColor
    end
    return true
end

function Tabs.blinkTab(tabName, times, interval)
    times = times or 3
    interval = interval or 0.2
    local btn = Tabs.buttons[tabName]
    if not btn then return false end
    local isActive = Tabs.currentTab == tabName
    local activeColor = isActive and Tabs.config.activeColor or btn.BackgroundColor3
    local blinkColor = Color3.fromRGB(255, 100, 100)
    for i = 1, times do
        btn.BackgroundColor3 = blinkColor
        task.wait(interval)
        btn.BackgroundColor3 = activeColor
        task.wait(interval)
    end
    return true
end

function Tabs.resetAll()
    for name, btn in pairs(Tabs.buttons) do
        btn.BackgroundColor3 = Tabs.config.inactiveColor
        btn.TextColor3 = Tabs.config.inactiveTextColor
        btn.BackgroundTransparency = 0.3
    end
    Tabs.currentTab = nil
end

return Tabs
