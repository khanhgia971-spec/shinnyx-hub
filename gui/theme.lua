local Theme = {}

Theme.colors = {
    background = Color3.fromRGB(10, 10, 10),
    backgroundSecondary = Color3.fromRGB(15, 15, 15),
    panel = Color3.fromRGB(20, 20, 20),
    panelTransparent = Color3.fromRGB(20, 20, 20),
    border = Color3.fromRGB(42, 42, 42),
    accent = Color3.fromRGB(0, 212, 255),
    accentSecondary = Color3.fromRGB(255, 0, 110),
    accentGreen = Color3.fromRGB(0, 255, 100),
    accentYellow = Color3.fromRGB(255, 200, 0),
    accentRed = Color3.fromRGB(255, 50, 50),
    text = Color3.fromRGB(255, 255, 255),
    textSecondary = Color3.fromRGB(170, 170, 170),
    textMuted = Color3.fromRGB(100, 100, 100),
    shadow = Color3.fromRGB(0, 0, 0),
    success = Color3.fromRGB(0, 200, 80),
    warning = Color3.fromRGB(255, 180, 0),
    danger = Color3.fromRGB(220, 40, 40),
}

Theme.fonts = {
    main = Enum.Font.GothamMedium,
    bold = Enum.Font.GothamBold,
    light = Enum.Font.Gotham,
    mono = Enum.Font.Code,
    title = Enum.Font.GothamBold,
}

Theme.sizes = {
    textSmall = 12,
    textNormal = 14,
    textLarge = 16,
    textTitle = 20,
    textHuge = 24,
    buttonHeight = 44,
    toggleHeight = 32,
    sliderHeight = 6,
    tabHeight = 40,
    cornerRadius = 12,
    cornerSmall = 6,
    cornerLarge = 16,
    padding = 10,
    margin = 8,
}

Theme.opacity = {
    background = 0.15,
    panel = 0.4,
    panelSolid = 1.0,
    border = 0.3,
    shadow = 0.6,
    button = 0.2,
    buttonHover = 0.4,
    buttonActive = 0.6,
    disabled = 0.3,
}

Theme.animations = {
    duration = 0.3,
    durationFast = 0.15,
    durationSlow = 0.6,
    easing = Enum.EasingStyle.Quad,
    easingIn = Enum.EasingStyle.Quad,
    easingOut = Enum.EasingStyle.Quad,
    easingBounce = Enum.EasingStyle.Bounce,
}

Theme.shadow = {
    enabled = true,
    size = 20,
    image = "rbxassetid://1316048111",
    transparency = 0.7,
    color = Color3.fromRGB(0, 0, 0),
}

Theme.borders = {
    enabled = true,
    thickness = 1,
    color = Color3.fromRGB(42, 42, 42),
}

function Theme.getColor(name)
    return Theme.colors[name] or Color3.fromRGB(255, 255, 255)
end

function Theme.setColor(name, color)
    if Theme.colors[name] then
        Theme.colors[name] = color
        return true
    end
    return false
end

function Theme.getFont(name)
    return Theme.fonts[name] or Enum.Font.GothamMedium
end

function Theme.getSize(name)
    return Theme.sizes[name] or 14
end

function Theme.getOpacity(name)
    return Theme.opacity[name] or 1.0
end

function Theme.getAnimation(name)
    return Theme.animations[name] or 0.3
end

function Theme.createCorner(instance, radius)
    radius = radius or Theme.sizes.cornerRadius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = instance
    return corner
end

function Theme.createShadow(instance)
    if not Theme.shadow.enabled then return nil end
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, Theme.shadow.size, 1, Theme.shadow.size)
    shadow.Position = UDim2.new(0, -Theme.shadow.size / 2, 0, -Theme.shadow.size / 2)
    shadow.BackgroundTransparency = 1
    shadow.Image = Theme.shadow.image
    shadow.ImageColor3 = Theme.shadow.color
    shadow.ImageTransparency = Theme.shadow.transparency
    shadow.ZIndex = -1
    shadow.Parent = instance
    return shadow
end

function Theme.createBorder(instance, thickness, color)
    if not Theme.borders.enabled then return nil end
    thickness = thickness or Theme.borders.thickness
    color = color or Theme.borders.color
    instance.BorderSizePixel = thickness
    instance.BorderColor3 = color
    return instance
end

function Theme.styleButton(button, variant)
    variant = variant or "primary"
    if variant == "primary" then
        button.BackgroundColor3 = Theme.colors.accent
        button.BackgroundTransparency = 0.2
        button.TextColor3 = Theme.colors.text
        button.Font = Theme.fonts.bold
        button.TextSize = Theme.sizes.textLarge
    elseif variant == "secondary" then
        button.BackgroundColor3 = Theme.colors.panel
        button.BackgroundTransparency = 0.3
        button.TextColor3 = Theme.colors.textSecondary
        button.Font = Theme.fonts.main
        button.TextSize = Theme.sizes.textNormal
    elseif variant == "danger" then
        button.BackgroundColor3 = Theme.colors.danger
        button.BackgroundTransparency = 0.3
        button.TextColor3 = Theme.colors.text
        button.Font = Theme.fonts.bold
        button.TextSize = Theme.sizes.textNormal
    elseif variant == "success" then
        button.BackgroundColor3 = Theme.colors.success
        button.BackgroundTransparency = 0.3
        button.TextColor3 = Theme.colors.text
        button.Font = Theme.fonts.bold
        button.TextSize = Theme.sizes.textNormal
    else
        button.BackgroundColor3 = Theme.colors.panel
        button.BackgroundTransparency = 0.2
        button.TextColor3 = Theme.colors.text
        button.Font = Theme.fonts.main
        button.TextSize = Theme.sizes.textNormal
    end
    Theme.createCorner(button, Theme.sizes.cornerSmall)
    return button
end

function Theme.styleToggle(toggle, isActive)
    if isActive then
        toggle.BackgroundColor3 = Theme.colors.accent
        toggle.Text = "BAT"
    else
        toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        toggle.Text = "TAT"
    end
    toggle.TextColor3 = Theme.colors.text
    toggle.TextSize = Theme.sizes.textSmall
    toggle.Font = Theme.fonts.bold
    Theme.createCorner(toggle, Theme.sizes.cornerSmall)
    return toggle
end

function Theme.styleSlider(slider, fill, handle, value)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Theme.createCorner(slider, Theme.sizes.cornerSmall)
    fill.BackgroundColor3 = Theme.colors.accent
    Theme.createCorner(fill, Theme.sizes.cornerSmall)
    if handle then
        handle.BackgroundColor3 = Theme.colors.accent
        handle.Text = ""
        Theme.createCorner(handle, Theme.sizes.cornerLarge)
    end
    return slider, fill, handle
end

function Theme.styleDropdown(dropdown)
    dropdown.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    dropdown.TextColor3 = Theme.colors.text
    dropdown.TextSize = Theme.sizes.textNormal
    dropdown.Font = Theme.fonts.main
    Theme.createCorner(dropdown, Theme.sizes.cornerSmall)
    return dropdown
end

function Theme.styleInput(input)
    input.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    input.TextColor3 = Theme.colors.text
    input.TextSize = Theme.sizes.textNormal
    input.Font = Theme.fonts.main
    Theme.createCorner(input, Theme.sizes.cornerSmall)
    return input
end

function Theme.styleLabel(label, variant)
    variant = variant or "normal"
    if variant == "title" then
        label.TextColor3 = Theme.colors.accent
        label.TextSize = Theme.sizes.textTitle
        label.Font = Theme.fonts.bold
    elseif variant == "subtitle" then
        label.TextColor3 = Theme.colors.textSecondary
        label.TextSize = Theme.sizes.textLarge
        label.Font = Theme.fonts.main
    elseif variant == "normal" then
        label.TextColor3 = Theme.colors.text
        label.TextSize = Theme.sizes.textNormal
        label.Font = Theme.fonts.main
    elseif variant == "muted" then
        label.TextColor3 = Theme.colors.textMuted
        label.TextSize = Theme.sizes.textSmall
        label.Font = Theme.fonts.light
    else
        label.TextColor3 = Theme.colors.text
        label.TextSize = Theme.sizes.textNormal
        label.Font = Theme.fonts.main
    end
    label.BackgroundTransparency = 1
    return label
end

function Theme.styleFrame(frame, variant)
    variant = variant or "panel"
    if variant == "panel" then
        frame.BackgroundColor3 = Theme.colors.panel
        frame.BackgroundTransparency = Theme.opacity.panel
        frame.BorderSizePixel = Theme.borders.thickness
        frame.BorderColor3 = Theme.colors.border
    elseif variant == "solid" then
        frame.BackgroundColor3 = Theme.colors.panel
        frame.BackgroundTransparency = 0
        frame.BorderSizePixel = 0
    elseif variant == "transparent" then
        frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 0
    elseif variant == "accent" then
        frame.BackgroundColor3 = Theme.colors.accent
        frame.BackgroundTransparency = 0.1
        frame.BorderSizePixel = 1
        frame.BorderColor3 = Theme.colors.accent
    end
    Theme.createCorner(frame, Theme.sizes.cornerRadius)
    return frame
end

function Theme.styleScroll(scroll)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Theme.colors.accent
    scroll.ScrollBarImageTransparency = 0.5
    return scroll
end

function Theme.getGradient(color1, color2, direction)
    local gradient = Instance.new("UIGradient")
    if direction == "horizontal" then
        gradient.Rotation = 0
    elseif direction == "vertical" then
        gradient.Rotation = 90
    elseif direction == "diagonal" then
        gradient.Rotation = 45
    else
        gradient.Rotation = 0
    end
    local stop1 = Instance.new("NumberSequenceKeypoint")
    stop1.Time = 0
    stop1.Value = 1
    local stop2 = Instance.new("NumberSequenceKeypoint")
    stop2.Time = 1
    stop2.Value = 0
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(1, color2)
    })
    gradient.Transparency = NumberSequence.new({
        stop1,
        stop2
    })
    return gradient
end

function Theme.applyThemeToUI(uiObject)
    if uiObject:IsA("Frame") then
        Theme.styleFrame(uiObject, "panel")
    elseif uiObject:IsA("TextLabel") then
        Theme.styleLabel(uiObject, "normal")
    elseif uiObject:IsA("TextButton") then
        Theme.styleButton(uiObject, "primary")
    elseif uiObject:IsA("ScrollingFrame") then
        Theme.styleScroll(uiObject)
    end
    for _, child in pairs(uiObject:GetChildren()) do
        Theme.applyThemeToUI(child)
    end
end

function Theme.createLoadingSpinner(parent, size)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, size or 40, 0, size or 40)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local spinner = Instance.new("ImageLabel")
    spinner.Size = UDim2.new(1, 0, 1, 0)
    spinner.BackgroundTransparency = 1
    spinner.Image = "rbxassetid://15288181666"
    spinner.ImageColor3 = Theme.colors.accent
    spinner.Parent = frame

    local spinTween = TweenService:Create(
        spinner,
        TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true),
        {Rotation = 360}
    )
    spinTween:Play()

    return frame, spinTween
end

function Theme.createNotification(parent, text, duration, type)
    type = type or "info"
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.8, 0, 0, 50)
    frame.Position = UDim2.new(0.1, 0, 1, -60)
    frame.BackgroundColor3 = Theme.colors.panel
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 1
    frame.Parent = parent
    Theme.createCorner(frame, Theme.sizes.cornerRadius)

    if type == "success" then
        frame.BorderColor3 = Theme.colors.success
    elseif type == "warning" then
        frame.BorderColor3 = Theme.colors.warning
    elseif type == "error" then
        frame.BorderColor3 = Theme.colors.danger
    else
        frame.BorderColor3 = Theme.colors.accent
    end

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.colors.text
    label.TextSize = Theme.sizes.textNormal
    label.Font = Theme.fonts.main
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Theme.colors.textSecondary
    closeBtn.TextSize = 16
    closeBtn.Font = Theme.fonts.bold
    closeBtn.Parent = frame
    closeBtn.MouseButton1Click:Connect(function()
        frame:Destroy()
    end)

    frame:TweenPosition(UDim2.new(0.1, 0, 1, -60), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    if duration then
        task.wait(duration)
        frame:TweenPosition(UDim2.new(0.1, 0, 1, 10), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.3, true)
        task.wait(0.3)
        frame:Destroy()
    end

    return frame
end

return Theme
