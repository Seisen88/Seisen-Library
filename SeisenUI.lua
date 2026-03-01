local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local IconsLoaded, Icons = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Seisen88/Seisen-Library/main/addons/source.lua"))()
end)
local Library = {
    Toggles = {},
    Options = {},
    Labels = {},
    Flags = {},
    Registry = {},
    OpenDropdowns = {},
    ScreenGui = nil,
    NotificationContainer = nil,
    Icons = IconsLoaded and Icons or nil,
    Theme = {
        Background = Color3.fromRGB(15, 15, 18),
        Sidebar = Color3.fromRGB(12, 12, 14),
        SidebarActive = Color3.fromRGB(25, 25, 28),
        Content = Color3.fromRGB(20, 20, 24),
        Element = Color3.fromRGB(25, 25, 30),
        ElementHover = Color3.fromRGB(35, 35, 40),
        Border = Color3.fromRGB(45, 45, 50),
        Accent = Color3.fromRGB(0, 200, 100),
        AccentHover = Color3.fromRGB(0, 220, 110),
        Text = Color3.fromRGB(240, 240, 240),
        TextDim = Color3.fromRGB(140, 140, 150),
        TextMuted = Color3.fromRGB(80, 80, 90),
        Toggle = Color3.fromRGB(0, 200, 100),
        ToggleOff = Color3.fromRGB(40, 40, 45)
    },
    ToggleKeybind = nil
}

-- Game ID lock: call Library:SetGameId(id) or Library:SetGameId({id1, id2})
-- Checks game.GameId (Universe ID). Shows a notification and halts execution if unauthorized.
function Library:SetGameId(gameId)
    local currentId = game.GameId
    local authorized = false

    if type(gameId) == "table" then
        for _, id in ipairs(gameId) do
            if currentId == id then
                authorized = true
                break
            end
        end
    else
        authorized = (currentId == gameId)
    end

    if not authorized then
        Library:Notify({
            Title = "Unauthorized Game",
            Content = "This script won't work on this game.",
            Duration = 5
        })
        return false
    end

    return true
end

function Library:RegisterElement(element, themeProperty, targetProperty)
    table.insert(self.Registry, {
        Element = element,
        ThemeProperty = themeProperty,
        TargetProperty = targetProperty or "BackgroundColor3"
    })
end
function Library:UpdateColorsUsingRegistry()
    for _, entry in ipairs(self.Registry) do
        if entry.Callback then
            task.spawn(entry.Callback, self.Theme)
        elseif entry.Element and entry.Element.Parent then
            local color = self.Theme[entry.ThemeProperty]
            if color then
                pcall(function()
                    TweenService:Create(entry.Element, TweenInfo.new(0.2), {
                        [entry.TargetProperty] = color
                    }):Play()
                end)
            end
        end
    end
end
function Library:CloseAllDropdowns()
    for _, dropdown in ipairs(self.OpenDropdowns) do
        if dropdown.Close then
            dropdown.Close()
        end
    end
    self.OpenDropdowns = {}
end
function Library:GetIcon(iconName)
    if not iconName or iconName == "" then return nil end
    

    if type(iconName) == "number" then
        iconName = "rbxassetid://" .. tostring(iconName)
    end

    if self.Icons then
        local success, icon = pcall(function()
            return self.Icons.GetAsset(iconName)
        end)
        if success and icon then
            return icon
        end
    end
    return {
        Url = iconName,
        ImageRectOffset = Vector2.zero,
        ImageRectSize = Vector2.zero,
        Custom = true
    }
end
function Library:ApplyIcon(element, iconName)
    local iconData = self:GetIcon(iconName)
    if not iconData then
        element.Image = ""
        return
    end
    element.Image = iconData.Url or ""
    element.ImageRectOffset = iconData.ImageRectOffset or Vector2.zero
    element.ImageRectSize = iconData.ImageRectSize or Vector2.zero
end
local function Create(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    for _, child in pairs(children or {}) do
        child.Parent = obj
    end
    return obj
end
local function Tween(obj, props, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

function Library:Notify(notifyOpts)
    local nTitle    = notifyOpts.Title    or "Notification"
    local nContent  = notifyOpts.Content  or ""
    local nDuration = notifyOpts.Duration or 3
    local nImage    = notifyOpts.Image    or "rbxassetid://10709791437"
    local theme     = self.Theme

    -- Create a standalone container if CreateWindow hasn't been called yet
    if not self.NotificationContainer then
        local guiParent = RunService:IsStudio() and LocalPlayer.PlayerGui or game.CoreGui
        local sg = Instance.new("ScreenGui")
        sg.Name = "SeisenNotify"
        sg.ResetOnSpawn = false
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.Parent = guiParent
        self.NotificationContainer = Create("Frame", {
            Name = "NotificationContainer",
            Size = UDim2.new(0, 300, 1, 0),
            Position = UDim2.new(0.5, -150, 0, 10),
            BackgroundTransparency = 1,
            Parent = sg,
            ZIndex = 500
        }, {
            Create("UIListLayout", {
                Padding = UDim.new(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Top,
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            }),
            Create("UIPadding", {PaddingTop = UDim.new(0, 10)})
        })
    end

    local notifyFrame = Create("Frame", {
        Size = UDim2.new(0, 280, 0, 0),
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = theme.Background,
        BackgroundTransparency = 1,
        Parent = self.NotificationContainer,
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Create("UIStroke", {Color = theme.Border, Thickness = 1}),
        Create("UIPadding", {PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)})
    })
    self:RegisterElement(notifyFrame, "Background")
    self:RegisterElement(notifyFrame:FindFirstChild("UIStroke"), "Border", "Color")
    local icon = Create("ImageLabel", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 0, 0, 2),
        BackgroundTransparency = 1,
        ImageColor3 = theme.Accent,
        Parent = notifyFrame
    })
    self:ApplyIcon(icon, nImage)
    local titleLbl = Create("TextLabel", {
        Size = UDim2.new(1, -30, 0, 14),
        Position = UDim2.new(0, 30, 0, 0),
        BackgroundTransparency = 1,
        Text = nTitle,
        TextColor3 = theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notifyFrame
    })
    local contentLbl = Create("TextLabel", {
        Size = UDim2.new(1, -30, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 30, 0, 18),
        BackgroundTransparency = 1,
        Text = nContent,
        TextColor3 = theme.TextMuted,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = notifyFrame
    })
    local barBg = Create("Frame", {
        Size = UDim2.new(1, 4, 0, 2),
        Position = UDim2.new(0, -2, 1, 10),
        BackgroundColor3 = theme.Border,
        BorderSizePixel = 0,
        Parent = notifyFrame
    })
    local bar = Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        Parent = barBg
    })
    notifyFrame.BackgroundTransparency = 1
    titleLbl.TextTransparency = 1
    contentLbl.TextTransparency = 1
    icon.ImageTransparency = 1
    Tween(notifyFrame, {BackgroundTransparency = 0.1}, 0.3)
    Tween(titleLbl,    {TextTransparency = 0},        0.3)
    Tween(contentLbl,  {TextTransparency = 0.2},      0.3)
    Tween(icon,        {ImageTransparency = 0},        0.3)
    Tween(bar, {Size = UDim2.new(1, 0, 1, 0)}, nDuration)
    task.delay(nDuration, function()
        Tween(notifyFrame, {BackgroundTransparency = 1}, 0.5)
        Tween(titleLbl,    {TextTransparency = 1},       0.5)
        Tween(contentLbl,  {TextTransparency = 1},       0.5)
        Tween(icon,        {ImageTransparency = 1},      0.5)
        Tween(bar,         {BackgroundTransparency = 1}, 0.5)
        Tween(barBg,       {BackgroundTransparency = 1}, 0.5)
        Tween(notifyFrame:FindFirstChild("UIStroke"), {Transparency = 1}, 0.5)
        task.wait(0.5)
        notifyFrame:Destroy()
    end)
end

local function MakeDraggable(handle, frame, onClick)
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local dragging = true
            local dragStart = input.Position
            local startPos = frame.Position
            local hasMoved = false
            local inputChanged, inputEnded
            inputChanged = UserInputService.InputChanged:Connect(function(i)
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    local delta = i.Position - dragStart
                    if delta.Magnitude > 5 then
                        hasMoved = true
                        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                    end
                end
            end)
            inputEnded = UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                    inputChanged:Disconnect()
                    inputEnded:Disconnect()
                    if onClick and not hasMoved then
                        onClick()
                    end
                end
            end)
        end
    end)
end
local TooltipFrame = nil
local TooltipLabel = nil
local TooltipConnection = nil
Library.TooltipThread = nil
function Library:CreateTooltipFrame()
    if not self.ScreenGui then return end
    if TooltipFrame then return end
    TooltipFrame = Create("Frame", {
        Name = "Tooltip",
        Size = UDim2.new(0, 200, 0, 30),
        BackgroundColor3 = Color3.fromRGB(30, 30, 35),
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 1000,
        Parent = self.ScreenGui
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        Create("UIStroke", {Color = Color3.fromRGB(60, 60, 65), Thickness = 1}),
        Create("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8)})
    })
    TooltipLabel = Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Color3.fromRGB(220, 220, 220),
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true,
        Parent = TooltipFrame
    })
    TooltipConnection = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and TooltipFrame.Visible then
            local mousePos = UserInputService:GetMouseLocation()
            TooltipFrame.Position = UDim2.fromOffset(mousePos.X + 15, mousePos.Y + 10)
        end
    end)
end
function Library:ShowTooltip(text)
    if not TooltipFrame then self:CreateTooltipFrame() end
    if not TooltipFrame or not text or text == "" then return end
    TooltipLabel.Text = text
    local TextService = game:GetService("TextService")
    local size = TextService:GetTextSize(text, 11, Enum.Font.Gotham, Vector2.new(280, 1000))
    TooltipFrame.Size = UDim2.new(0, math.min(size.X + 24, 300), 0, size.Y + 20)
    TooltipFrame.Visible = true
    local mousePos = UserInputService:GetMouseLocation()
    TooltipFrame.Position = UDim2.fromOffset(mousePos.X + 15, mousePos.Y + 10)
end
function Library:HideTooltip()
    if self.TooltipThread then
        task.cancel(self.TooltipThread)
        self.TooltipThread = nil
    end
    if TooltipFrame then
        TooltipFrame.Visible = false
    end
end
function Library:ApplyCommonProperties(element, options, elementObj)
    local theme = self.Theme
    local tooltip = options.Tooltip
    local disabledTooltip = options.DisabledTooltip
    local isDisabled = options.Disabled or false
    local isVisible = options.Visible ~= false
    local isRisky = options.Risky or false
    elementObj._disabled = isDisabled
    elementObj._visible = isVisible
    elementObj._tooltip = tooltip
    elementObj._disabledTooltip = disabledTooltip
    elementObj._risky = isRisky
    element.Visible = isVisible
    if isRisky then
        local riskyColor = Color3.fromRGB(255, 100, 80)
        for _, child in pairs(element:GetDescendants()) do
            if child:IsA("TextLabel") and child.Name ~= "Value" then
            end
        end
    end
    if isDisabled then
        element.BackgroundTransparency = 0.6
        for _, child in pairs(element:GetDescendants()) do
            if child:IsA("TextLabel") then
                child.TextTransparency = 0.5
            elseif child:IsA("TextButton") or child:IsA("ImageButton") then
                child.Active = false
            end
        end
    end
    if tooltip or disabledTooltip then
        element.MouseEnter:Connect(function()
            local currentTooltip = elementObj._disabled and elementObj._disabledTooltip or elementObj._tooltip
            if not currentTooltip then return end
            if Library.TooltipThread then task.cancel(Library.TooltipThread) end
            Library.TooltipThread = task.delay(0.2, function()
                Library:ShowTooltip(currentTooltip)
            end)
        end)
        element.MouseLeave:Connect(function()
            Library:HideTooltip()
        end)
    end
    function elementObj:SetVisible(visible)
        self._visible = visible
        element.Visible = visible
    end
    function elementObj:SetDisabled(disabled)
        self._disabled = disabled
        element.BackgroundTransparency = disabled and 0.6 or 0
        for _, child in pairs(element:GetDescendants()) do
            if child:IsA("TextLabel") then
                child.TextTransparency = disabled and 0.5 or 0
            elseif child:IsA("TextButton") or child:IsA("ImageButton") then
                child.Active = not disabled
            end
        end
    end
    function elementObj:SetTooltip(newTooltip)
        self._tooltip = newTooltip
    end
    return elementObj
end
function Library:CreateLabel(parent, options)
    local text = options.Text or options.Name or "Label"
    local flag = options.Flag
    local label = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, options.Height or 16),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextWrapped = options.TextWrapped,
        Parent = parent
    })
    self:RegisterElement(label, "TextDim", "TextColor3")
    local labelObj = {SetText = function(s, t) label.Text = t end, Instance = label}
    if flag then 
        self.Labels = self.Labels or {}
        self.Labels[flag] = labelObj 
    end
    return labelObj
end
function Library:CreateButton(parent, options)
    local btnName = options.Name or "Button"
    local callback = options.Callback or function() end
    local doubleClick = options.DoubleClick or false
    local confirmText = options.ConfirmText
    local isRisky = options.Risky or false
    local btn = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundColor3 = self.Theme.Element,
        Text = btnName,
        TextColor3 = isRisky and Color3.fromRGB(255, 100, 80) or self.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        AutoButtonColor = false,
        Parent = parent
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 4)})
    })
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = isRisky and Color3.fromRGB(180, 60, 60) or self.Theme.Border
    btnStroke.Thickness = 1
    btnStroke.Parent = btn
    self:RegisterElement(btn, "Element")
    if not isRisky then
        self:RegisterElement(btnStroke, "Border", "Color")
        self:RegisterElement(btn, "Text", "TextColor3")
    end
    local lastClick = 0
    local waitingConfirm = false
    btn.MouseEnter:Connect(function()
        Tween(btn, {BackgroundColor3 = self.Theme.ElementHover})
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, {BackgroundColor3 = self.Theme.Element})
        if waitingConfirm then
            waitingConfirm = false
            btn.Text = btnName
        end
    end)
    btn.MouseButton1Click:Connect(function()
        local btnObj = self.Options[options.Flag]
        if btnObj and btnObj._disabled then return end
        if confirmText and not waitingConfirm then
            waitingConfirm = true
            btn.Text = confirmText
            return
        end
        waitingConfirm = false
        btn.Text = btnName
        if doubleClick then
            local now = tick()
            if now - lastClick < 0.4 then
                callback()
                lastClick = 0
            else
                lastClick = now
            end
        else
            callback()
        end
    end)
    local btnObj = {
        Instance = btn,
        Type = "Button"
    }
    self:ApplyCommonProperties(btn, options, btnObj)
    if options.Flag then self.Options[options.Flag] = btnObj end
    return btnObj
end
function Library:CreateToggle(parent, options)
    local toggleName = options.Name or "Toggle"
    local default = options.Default or false
    local callback = options.Callback or function() end
    local flag = options.Flag
    local state = default
    local keybind = options.Keybind or Enum.KeyCode.Unknown
    local toggle = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Parent = parent
    })
    local toggleLabel = Create("TextLabel", {
        Size = UDim2.new(1, -90, 1, 0),
        BackgroundTransparency = 1,
        Text = toggleName,
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = toggle
    })
    self:RegisterElement(toggleLabel, "Text", "TextColor3")
    local indicator = Create("Frame", {
        Size = UDim2.new(0, 8, 0, 8),
        Position = UDim2.new(1, -14, 0.5, -4),
        BackgroundColor3 = state and self.Theme.Accent or self.Theme.ToggleOff,
        BorderSizePixel = 0,
        Parent = toggle
    }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
    local switchBg = Create("Frame", {
        Size = UDim2.new(0, 36, 0, 18),
        Position = UDim2.new(1, -36, 0.5, -9), 
        BackgroundColor3 = state and self.Theme.Toggle or self.Theme.ToggleOff,
        BorderSizePixel = 0,
        Parent = toggle
    }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
    local knob = Create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Parent = switchBg
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
        Create("UIStroke", {Color = Color3.new(0,0,0), Transparency = 0.9, Thickness = 1})
    })
    local keybindBtn = Create("TextButton", {
        Size = UDim2.new(0, 40, 0, 16),
        Position = UDim2.new(1, -85, 0.5, -8), 
        BackgroundColor3 = self.Theme.Element,
        Text = (keybind ~= Enum.KeyCode.Unknown) and keybind.Name:upper() or "NONE",
        TextColor3 = self.Theme.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        AutoButtonColor = false,
        ZIndex = 2,
        Parent = toggle
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 4)})})
    self:RegisterElement(keybindBtn, "Element")
    table.insert(self.Registry, {
        Callback = function(theme)
            local tTheme = theme or self.Theme
            Tween(switchBg, {BackgroundColor3 = state and tTheme.Toggle or tTheme.ToggleOff})
            Tween(indicator, {BackgroundColor3 = state and tTheme.Accent or tTheme.ToggleOff})
        end
    })
    local toggleObj = {
        Value = state,
        Type = "Toggle",
        SetValue = function(s, val)
            state = val
            s.Value = val
            Tween(switchBg, {BackgroundColor3 = val and self.Theme.Toggle or self.Theme.ToggleOff})
            Tween(knob, {Position = val and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)})
            Tween(indicator, {BackgroundColor3 = val and self.Theme.Accent or self.Theme.ToggleOff})
            callback(val)
        end
    }
    local switchBtn = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = toggle
    })
    switchBtn.MouseButton1Click:Connect(function() toggleObj:SetValue(not state) end)
    local listening = false
    keybindBtn.MouseButton1Click:Connect(function()
        listening = true
        keybindBtn.Text = "..."
    end)
    UserInputService.InputBegan:Connect(function(input, processed)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            keybind = input.KeyCode
            keybindBtn.Text = input.KeyCode.Name:upper()
            listening = false
        elseif keybind ~= Enum.KeyCode.Unknown and input.KeyCode == keybind and not processed then
            if not toggleObj._disabled then
                toggleObj:SetValue(not state)
            end
        end
    end)
    self:ApplyCommonProperties(toggle, options, toggleObj)
    if flag then self.Toggles[flag] = toggleObj end
    if default then callback(true) end
    return toggleObj
end
function Library:CreateSlider(parent, options)
    local sliderName = options.Name or "Slider"
    local min = options.Min or 0
    local max = options.Max or 100
    local default = options.Default or min
    local callback = options.Callback or function() end
    local flag = options.Flag
    local increment = options.Increment or 1
    local suffix = options.Suffix or ""
    local prefix = options.Prefix or ""
    local hideMax = options.HideMax or false
    local value = default
    local slider = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Parent = parent
    })
    Create("TextLabel", {
        Size = UDim2.new(1, -40, 0, 16),
        BackgroundTransparency = 1,
        Text = sliderName,
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = slider
    })
    local function formatValue(v)
        return prefix .. tostring(v) .. suffix
    end
    local valLabel = Create("TextLabel", {
        Size = UDim2.new(0, 60, 0, 16),
        Position = UDim2.new(1, -60, 0, 0),
        BackgroundTransparency = 1,
        Text = formatValue(value),
        TextColor3 = self.Theme.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = slider
    })
    local bar = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundColor3 = self.Theme.ToggleOff,
        Text = "",
        AutoButtonColor = false,
        Parent = slider
    }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
    local fill = Create("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Parent = bar
    }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
    local sliderKnob = Create("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = bar
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
        Create("UIStroke", {Color = Color3.new(0,0,0), Transparency = 0.8, Thickness = 1})
    })
    self:RegisterElement(bar, "ToggleOff")
    self:RegisterElement(fill, "Accent")
    local sliderObj = {
        Value = value,
        Type = "Slider",
        SetValue = function(s, val)
            val = math.clamp(val, min, max)
            val = math.floor(val / increment + 0.5) * increment
            value = val
            s.Value = val
            valLabel.Text = formatValue(val)
            fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
            sliderKnob.Position = UDim2.new((val - min) / (max - min), 0, 0.5, 0)
            callback(val)
        end
    }
    local sliding = false
    bar.InputBegan:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
            if sliderObj._disabled then return end
            sliding = true
            local clickPct = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local rawVal = min + (max - min) * clickPct
            local clickVal = math.floor(rawVal / increment + 0.5) * increment
            value = clickVal
            sliderObj.Value = clickVal
            valLabel.Text = formatValue(clickVal)
            fill.Size = UDim2.new((clickVal - min) / (max - min), 0, 1, 0)
            sliderKnob.Position = UDim2.new((clickVal - min) / (max - min), 0, 0.5, 0)
            callback(clickVal)
            local startPos = i.Position.X
            local startValue = clickVal
            local connection
            connection = game:GetService("RunService").RenderStepped:Connect(function()
                if not sliding then
                    connection:Disconnect()
                    return
                end
                local mouseProxy = game:GetService("Players").LocalPlayer:GetMouse()
                local delta = mouseProxy.X - startPos
                local currentBarWidth = bar.AbsoluteSize.X
                local valueDelta = (delta / currentBarWidth) * (max - min)
                local rawVal = math.clamp(startValue + valueDelta, min, max)
                local newVal = math.floor(rawVal / increment + 0.5) * increment
                if newVal ~= value then
                    value = newVal
                    sliderObj.Value = newVal
                    valLabel.Text = formatValue(newVal)
                    fill.Size = UDim2.new((newVal - min) / (max - min), 0, 1, 0)
                    sliderKnob.Position = UDim2.new((newVal - min) / (max - min), 0, 0.5, 0)
                    callback(newVal)
                end
            end)
            local releaseConnection
            releaseConnection = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                    connection:Disconnect()
                    releaseConnection:Disconnect()
                end
            end)
        end 
    end)
    self:ApplyCommonProperties(slider, options, sliderObj)
    if flag then self.Options[flag] = sliderObj end
    return sliderObj
end
function Library:CreateKeybind(parent, options)
    local keybindName = options.Name or "Keybind"
    local default = options.Default or Enum.KeyCode.Unknown
    local callback = options.Callback or function() end
    local flag = options.Flag
    local currentKey = default
    
    local keybind = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent = parent
    })
    local nameLabel = Create("TextLabel", {
        Size = UDim2.new(0.5, -5, 1, 0),
        BackgroundTransparency = 1,
        Text = keybindName,
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = keybind
    })
    local keyButton = Create("TextButton", {
        Size = UDim2.new(0.5, -5, 0, 28),
        Position = UDim2.new(0.5, 5, 0.5, -14),
        BackgroundColor3 = self.Theme.Element,
        Text = tostring(currentKey.Name),
        TextColor3 = self.Theme.TextDim,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Parent = keybind
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
        Create("UIStroke", {Color = self.Theme.Border, Thickness = 1})
    })
    self:RegisterElement(nameLabel, "Text", "TextColor3")
    self:RegisterElement(keyButton, "Element")
    self:RegisterElement(keyButton:FindFirstChild("UIStroke"), "Border", "Color")
    self:RegisterElement(keyButton, "TextDim", "TextColor3")
    
    local listening = false
    local keybindObj = {
        Value = currentKey,
        Type = "Keybind",
        SetValue = function(s, key)
            currentKey = key
            s.Value = key
            keyButton.Text = tostring(key.Name)
            callback(key)
        end
    }
    
    keyButton.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyButton.Text = "..."
        keyButton.TextColor3 = self.Theme.Accent
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, processed)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                connection:Disconnect()
                listening = false
                
                local newKey = input.KeyCode
                if newKey == Enum.KeyCode.Escape or newKey == Enum.KeyCode.Backspace then
                    newKey = Enum.KeyCode.Unknown
                end
                
                keybindObj:SetValue(newKey)
                keyButton.TextColor3 = self.Theme.TextDim
            end
        end)
    end)
    
    self:ApplyCommonProperties(keybind, options, keybindObj)
    if flag then self.Options[flag] = keybindObj end
    return keybindObj
end
function Library:CreateDropdown(parent, options)
    local dropName = options.Name or "Dropdown"
    local opts = options.Options or {}
    local isMulti = options.Multi or false
    local default = options.Default or (isMulti and {} or opts[1])
    local callback = options.Callback or function() end
    local flag = options.Flag
    local isOpen = false
    local currentVal = default
    local function getDisplayVal()
        if isMulti then
            if type(currentVal) == "table" then
                if #currentVal == 0 then return "None" end
                return table.concat(currentVal, ", ")
            else
                return tostring(currentVal) 
            end
        else
            return tostring(currentVal)
        end
    end
    local drop = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundTransparency = 1,
        ClipsDescendants = false, 
        Parent = parent,
        ZIndex = 50
    })
    Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = dropName,
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = drop
    })
    local selectBtn = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundColor3 = self.Theme.Element,
        Text = "",
        AutoButtonColor = false,
        Parent = drop
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 4)})
    })
    local displayLabel = Create("TextLabel", {
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = getDisplayVal(),
        TextColor3 = self.Theme.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = selectBtn
    })
    local arrow = Create("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -20, 0.5, -8),
        BackgroundTransparency = 1,
        ImageColor3 = self.Theme.TextDim,
        Parent = selectBtn
    })
    self:ApplyIcon(arrow, "chevron-down")
    local dropStroke = Instance.new("UIStroke")
    dropStroke.Color = self.Theme.Border
    dropStroke.Thickness = 1
    dropStroke.Parent = selectBtn
    self:RegisterElement(selectBtn, "Element")
    self:RegisterElement(dropStroke, "Border", "Color")
    self:RegisterElement(displayLabel, "TextDim", "TextColor3")
    local list = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 5),
        BackgroundColor3 = self.Theme.Sidebar,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = self.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        ZIndex = 1100,
        Parent = selectBtn
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
        Create("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}),
        Create("UIPadding", {PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5)}),
        Create("UIStroke", {Color = self.Theme.Border, Thickness = 1})
    })

    local listScale = Instance.new("UIScale")
    listScale.Parent = list

    local posConnection
    local function updateListPosition()
        if isOpen and selectBtn and selectBtn.Parent then
            local scale = self.MainScale and self.MainScale.Scale or 1
            listScale.Scale = scale
            
            local absPos = selectBtn.AbsolutePosition
            local absSize = selectBtn.AbsoluteSize
            





            
            list.Position = UDim2.fromOffset(absPos.X / scale, (absPos.Y + absSize.Y + 5) / scale)
            list.Size = UDim2.new(0, absSize.X / scale, 0, math.min(#opts * 22 + 10, 150))
        end
    end
    local dropObj = {
        Value = currentVal,
        Multi = isMulti,
        Type = "Dropdown",
        SetValue = function(s, val)
            if isMulti then
                if type(val) == "table" then

                    local validValues = {}
                    for _, v in ipairs(val) do
                        for _, opt in ipairs(opts) do
                            if tostring(v) == tostring(opt) then
                                table.insert(validValues, v)
                                break
                            end
                        end
                    end
                    currentVal = validValues
                else

                    local found = false
                    local index = -1
                    for i, v in ipairs(currentVal) do
                        if v == val then
                            found = true
                            index = i
                            break
                        end
                    end
                    if found then
                        table.remove(currentVal, index)
                    else
                        table.insert(currentVal, val)
                    end
                end
                s.Value = currentVal
                displayLabel.Text = getDisplayVal()
                callback(currentVal)
            else

                local isValid = false
                for _, opt in ipairs(opts) do
                    if tostring(val) == tostring(opt) then
                        isValid = true
                        break
                    end
                end
                

                if not isValid and #opts > 0 then
                    val = opts[1]
                end
                
                currentVal = val
                s.Value = val
                displayLabel.Text = tostring(val)
                callback(val)
                isOpen = false
                list.Visible = false
                Tween(arrow, {Rotation = 0})
            end
            for _, child in pairs(list:GetChildren()) do
                if child:IsA("TextButton") then
                    local isActive = false
                    if isMulti then
                        for _, v in ipairs(currentVal) do
                            if tostring(v) == child.Text then
                                isActive = true
                                break
                            end
                        end
                    else
                        isActive = (child.Text == tostring(currentVal))
                    end
                    child.TextColor3 = isActive and self.Theme.Accent or self.Theme.TextDim
                end
            end
        end
    }
    local function populate()
        for _, child in pairs(list:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, opt in ipairs(opts) do
            local isActive = false
            if isMulti and type(currentVal) == "table" then
                for _, v in ipairs(currentVal) do
                    if v == opt then isActive = true break end
                end
            else
                isActive = (opt == currentVal)
            end
            local btn = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Text = tostring(opt),
                TextColor3 = isActive and self.Theme.Accent or self.Theme.TextDim,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = list,
                ZIndex = 110
            })
            btn.MouseButton1Click:Connect(function()
                dropObj:SetValue(opt)
            end)
        end
        local h = math.min(#opts * 22 + 10, 150)
        list.Size = UDim2.new(1, 0, 0, h)
        list.CanvasSize = UDim2.new(0, 0, 0, #opts * 22 + 10)
    end
    populate()
    function dropObj:Refresh(newOptions, keepCurrent)
        opts = newOptions or {}
        if not keepCurrent then
            currentVal = isMulti and {} or (opts[1])
            dropObj.Value = currentVal
            displayLabel.Text = getDisplayVal()
            callback(currentVal)
        end
        populate()
    end
    -- Full-screen invisible blocker: sits behind the list, above everything else.
    -- Clicking the list/options → list's higher ZIndex wins, blocker never fires.
    -- Clicking anywhere outside → blocker fires → close.
    local blocker = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 98,   -- list is ZIndex 1100, blocker is just below; covers all regular UI
        Visible = false,
        Parent = self.ScreenGui,
    })

    local function closeDropdown()
        isOpen = false
        list.Visible = false
        blocker.Visible = false
        list.Parent = selectBtn
        if posConnection then posConnection:Disconnect() posConnection = nil end
        Tween(arrow, {Rotation = 0})
        for i = #self.OpenDropdowns, 1, -1 do
            local d = self.OpenDropdowns[i]
            if d and d._selectBtn == selectBtn then
                table.remove(self.OpenDropdowns, i)
                break
            end
        end
    end

    blocker.MouseButton1Click:Connect(function()
        closeDropdown()
    end)

    selectBtn.MouseButton1Click:Connect(function()
        if not isOpen then
            self:CloseAllDropdowns()
        end
        isOpen = not isOpen

        if isOpen then
            blocker.Visible = true
            list.Parent = self.ScreenGui
            list.Visible = true
            updateListPosition()
            posConnection = game:GetService("RunService").RenderStepped:Connect(updateListPosition)

            table.insert(self.OpenDropdowns, {
                _selectBtn = selectBtn,
                Close = function()
                    closeDropdown()
                end
            })
        else
            blocker.Visible = false
            list.Visible = false
            list.Parent = selectBtn
            if posConnection then posConnection:Disconnect() posConnection = nil end
        end

        Tween(arrow, {Rotation = isOpen and 180 or 0})
    end)

    selectBtn.Destroying:Connect(function()
        if posConnection then posConnection:Disconnect() end
        if blocker and blocker.Parent then blocker:Destroy() end
        list:Destroy()
    end)
    table.insert(self.Registry, {
        Callback = function(theme)
            local tTheme = theme or self.Theme
            for _, child in pairs(list:GetChildren()) do
                if child:IsA("TextButton") then
                     local isActive = false
                    if isMulti then
                        for _, v in ipairs(currentVal) do
                            if tostring(v) == child.Text then
                                isActive = true
                                break
                            end
                        end
                    else
                        isActive = (child.Text == tostring(currentVal))
                    end
                    child.TextColor3 = isActive and tTheme.Accent or tTheme.TextDim
                end
            end
        end
    })
    if flag then self.Options[flag] = dropObj end
    return dropObj
end
function Library:Toggle()
    if self.ScreenGui then
        self.ScreenGui.Enabled = not self.ScreenGui.Enabled
    end
end

function Library:Unload()
    -- Call the UnloadCallback first (for user cleanup like stopping loops)
    if self.UnloadCallback then
        pcall(self.UnloadCallback)
    end
    
    -- Turn off all toggles to trigger their cleanup callbacks
    pcall(function()
        for flag, toggle in pairs(self.Toggles) do
            if toggle.SetValue and toggle.Value then
                pcall(function()
                    toggle:SetValue(false)
                end)
            end
        end
    end)

    -- Reset player stats that sliders may have changed but have no toggle
    pcall(function()
        local char = LocalPlayer and LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
                hum.UseJumpPower = true
                hum.JumpPower = 50
            end
        end
    end)
    
    -- Cancel any running tooltip thread
    if self.TooltipThread then
        pcall(function() task.cancel(self.TooltipThread) end)
        self.TooltipThread = nil
    end
    
    -- Disconnect tooltip connection
    if TooltipConnection then
        pcall(function() TooltipConnection:Disconnect() end)
        TooltipConnection = nil
    end
    
    -- Destroy tooltip frame
    if TooltipFrame then
        pcall(function() TooltipFrame:Destroy() end)
        TooltipFrame = nil
        TooltipLabel = nil
    end
    
    -- Close all open dropdowns
    pcall(function()
        for _, dropdown in ipairs(self.OpenDropdowns) do
            if dropdown.Close then
                pcall(dropdown.Close)
            end
        end
    end)
    
    -- Clear all tables
    self.Toggles = {}
    self.Options = {}
    self.Labels = {}
    self.Flags = {}
    self.Registry = {}
    self.OpenDropdowns = {}
    
    -- Destroy the main ScreenGui
    if self.ScreenGui then
        pcall(function() self.ScreenGui:Destroy() end)
        self.ScreenGui = nil
    end
    
    -- Clear references
    self.MainWindow = nil
    self.Widget = nil
    self.MainScale = nil
    
    print("Seisen UI fully unloaded and cleaned up")
end

local function createTabbox(name, parent, theme, gui, Create, Tween, Library)
    local tabbox = Create("Frame", {
        Name = name or "Tabbox",
        Size = UDim2.new(1, 0, 0, 150),
        BackgroundColor3 = theme.Element,
        BackgroundTransparency = 0.5,
        ClipsDescendants = true,
        Parent = parent
    }, {
        Create("UIPadding", {PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6)}),
        Create("UICorner", {CornerRadius = UDim.new(0, 6)})
    })
    local tabboxStroke = Instance.new("UIStroke")
    tabboxStroke.Color = theme.Border
    tabboxStroke.Thickness = 1
    tabboxStroke.Parent = tabbox
    Library:RegisterElement(tabbox, "Element")
    Library:RegisterElement(tabboxStroke, "Border", "Color")
    local tabHeader = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.fromScale(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        ClipsDescendants = true,
        Parent = tabbox
    }, {
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder
        }),
        Create("UIPadding", {PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2)})
    })
    local tabContent = Create("Frame", {
        Size = UDim2.new(1, 0, 1, -30),
        Position = UDim2.new(0, 0, 0, 28),
        BackgroundColor3 = theme.Sidebar,
        BackgroundTransparency = 0.5,
        ClipsDescendants = true,
        Parent = tabbox
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Create("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8)})
    })
    local TabboxFuncs = {}
    local tabs = {}
    local activeTab = nil
    local updateTabboxSize
    function TabboxFuncs:AddTab(tabName)
        local tabBtn = Create("TextButton", {
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = Library.Theme.ToggleOff,
            BackgroundTransparency = 0.5,
            Text = tabName,
            TextColor3 = theme.TextDim,
            Font = Enum.Font.GothamMedium,
            TextSize = 11,
            AutoButtonColor = false,
            Parent = tabHeader
        }, {
            Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
            Create("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})
        })
        local tabPage = Create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = tabContent
        }, {
            Create("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}),
            Create("UIPadding", {PaddingRight = UDim.new(0, 4)})
        })
        table.insert(tabs, {btn = tabBtn, page = tabPage})
        local layout = tabPage:FindFirstChildOfClass("UIListLayout")
        if layout then
            layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateTabboxSize)
        end
        local function activateTab()
            for _, t in ipairs(tabs) do
                t.page.Visible = false
                t.btn.BackgroundTransparency = 0.5
                t.btn.BackgroundColor3 = Library.Theme.ToggleOff
                t.btn.TextColor3 = Library.Theme.TextDim
            end
            tabPage.Visible = true
            tabBtn.BackgroundTransparency = 0
            tabBtn.BackgroundColor3 = Library.Theme.Accent
            tabBtn.TextColor3 = Library.Theme.Text
            activeTab = tabPage
            updateTabboxSize()
        end
        tabBtn.MouseButton1Click:Connect(activateTab)
        if #tabs == 1 then
            activateTab()
        end
        local TabPageFuncs = {}
        function TabPageFuncs:AddLabel(opts)
            return Library:CreateLabel(tabPage, opts)
        end
        function TabPageFuncs:AddToggle(opts)
            return Library:CreateToggle(tabPage, opts)
        end
        function TabPageFuncs:AddButton(opts)
            return Library:CreateButton(tabPage, opts)
        end
        function TabPageFuncs:AddSlider(opts)
            return Library:CreateSlider(tabPage, opts)
        end
        function TabPageFuncs:AddDropdown(opts)
            return Library:CreateDropdown(tabPage, opts)
        end
        function TabPageFuncs:AddKeybind(opts)
            return Library:CreateKeybind(tabPage, opts)
        end
        return TabPageFuncs
    end
    local updateThread
    updateTabboxSize = function()
        if updateThread then task.cancel(updateThread) end
        updateThread = task.defer(function()
            task.wait()
            local height = 0
            if activeTab then
                local layout = activeTab:FindFirstChildOfClass("UIListLayout")
                if layout then
                    height = layout.AbsoluteContentSize.Y
                end
            end
            tabbox.Size = UDim2.new(1, 0, 0, math.max(80, height + 60))
        end)
    end
    task.defer(updateTabboxSize)
    table.insert(Library.Registry, {
        Callback = function()
            for _, t in ipairs(tabs) do
                if t.page == activeTab then
                    t.btn.BackgroundColor3 = Library.Theme.Accent
                    t.btn.TextColor3 = Library.Theme.Text
                else
                    t.btn.BackgroundColor3 = Library.Theme.ToggleOff
                    t.btn.TextColor3 = Library.Theme.TextDim
                end
            end
        end
    })
    return TabboxFuncs
end
function Library:CreateWindow(options)
    local name = options.Name or options.Title or "Seisen Library"
    local theme = options.Theme or self.Theme
    if RunService:IsStudio() then
        if LocalPlayer.PlayerGui:FindFirstChild("SeisenUI") then
            LocalPlayer.PlayerGui.SeisenUI:Destroy()
        end
    else
        if game.CoreGui:FindFirstChild("SeisenUI") then
            game.CoreGui.SeisenUI:Destroy()
        end
    end
    local gui = Create("ScreenGui", {
        Name = "SeisenUI",
        Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game.CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    self.ScreenGui = gui
    local viewport = workspace.CurrentCamera.ViewportSize
    local isSmallScreen = viewport.X < 800 or (UserInputService.TouchEnabled and not UserInputService.MouseEnabled)
    local initialWidth = 680
    local initialHeight = 560
    local targetScale = 1
    if isSmallScreen then
        initialWidth = 670
        initialHeight = 350
        if viewport.X < 650 then
            targetScale = viewport.X / 900
        else
            targetScale = 0.75 
        end
        targetScale = math.clamp(targetScale, 0.4, 0.9)
    end
    local windowSize = UDim2.fromOffset(initialWidth, initialHeight)
    local main = Create("Frame", {
        Name = "Main",
        Size = windowSize,
        Position = UDim2.new(0.5, -initialWidth/2 * targetScale, 0.5, -initialHeight/2 * targetScale),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Parent = gui
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 8)})
    })
    local mainScale = Instance.new("UIScale")
    mainScale.Scale = 0
    mainScale.Parent = main
    self.MainScale = mainScale
    
    self:RegisterElement(main, "Background")
    local sizeLabel = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -14),
        BackgroundTransparency = 1,
        Text = string.format("%d x %d", initialWidth, initialHeight),
        TextColor3 = theme.TextDim,
        Font = Enum.Font.RobotoMono,
        TextSize = 10,
        TextTransparency = 0.5,
        ZIndex = 300,
        Parent = main
    })
    local sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 150, 1, 0),
        BackgroundColor3 = theme.Sidebar,
        BorderSizePixel = 0,
        Parent = main
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 8)})
    })
    self:RegisterElement(sidebar, "Sidebar")
    local sidebarCover = Create("Frame", {
        Size = UDim2.new(0, 10, 1, 0),
        Position = UDim2.new(1, -10, 0, 0),
        BackgroundColor3 = theme.Sidebar,
        BorderSizePixel = 0,
        Parent = sidebar
    })
    self:RegisterElement(sidebarCover, "Sidebar")
    local controls = Create("Frame", {
        Name = "WindowControls",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Parent = sidebar,
        LayoutOrder = 1
    }, {
        Create("UIPadding", {PaddingLeft = UDim.new(0, 14), PaddingTop = UDim.new(0, 10)})
    })
    local controlList = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = controls
    })
    local function createTrafficLight(color, callback, hoverIcon)
        local btn = Create("TextButton", {
            Size = UDim2.new(0, 12, 0, 12),
            BackgroundColor3 = color,
            Text = "",
            AutoButtonColor = false,
            Parent = controls
        }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
        local icon = Create("ImageLabel", {
            Size = UDim2.new(0, 8, 0, 8),
            Position = UDim2.new(0.5, -4, 0.5, -4),
            BackgroundTransparency = 1,
            Image = hoverIcon,
            ImageTransparency = 1,
            ImageColor3 = Color3.new(0,0,0),
            Parent = btn
        })
        btn.MouseEnter:Connect(function() 
            icon.ImageTransparency = 0.5 
        end)
        btn.MouseLeave:Connect(function() 
            icon.ImageTransparency = 1 
        end)
        if callback then
            btn.MouseButton1Click:Connect(callback)
        end
        return btn
    end
    local closeBtn = createTrafficLight(Color3.fromRGB(255, 95, 87), function() Library:Unload() end, "rbxassetid://10747384351")
    local minBtn = createTrafficLight(Color3.fromRGB(255, 189, 46), nil, "rbxassetid://10747384534")
    local maxBtn = createTrafficLight(Color3.fromRGB(39, 201, 63), nil, "rbxassetid://10747384661")
    local searchContainer = Create("Frame", {
        Name = "SidebarSearch",
        Size = UDim2.new(1, -20, 0, 32),
        Position = UDim2.new(0, 10, 0, 40),
        BackgroundColor3 = theme.Background,
        Parent = sidebar,
        LayoutOrder = 2
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        Create("UIStroke", {Color = theme.Border, Thickness = 1})
    })
    local searchIcon = Create("ImageLabel", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, 10, 0.5, -7),
        BackgroundTransparency = 1,
        ImageColor3 = theme.TextDim,
        Parent = searchContainer
    })
    Library:ApplyIcon(searchIcon, "search")
    local searchInput = Create("TextBox", {
        Size = UDim2.new(1, -34, 1, 0),
        Position = UDim2.new(0, 34, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Search",
        PlaceholderColor3 = theme.TextMuted,
        TextColor3 = theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = searchContainer
    })
    self:RegisterElement(searchContainer, "Background")
    self:RegisterElement(searchContainer:FindFirstChild("UIStroke"), "Border", "Color")
    self:RegisterElement(searchIcon, "TextDim", "ImageColor3")
    self:RegisterElement(searchInput, "Text", "TextColor3")
    self:RegisterElement(searchInput, "TextMuted", "PlaceholderColor3")
    local tabList = Create("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, 0, 1, -130),
        Position = UDim2.new(0, 0, 0, 80),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Parent = sidebar,
        LayoutOrder = 3
    }, {
        Create("UIListLayout", {
            Padding = UDim.new(0, 2),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
    })
    local pages
    local function contentSearch(query)
        query = query:lower()
        if not pages then return end
        for _, pageFrame in ipairs(pages:GetChildren()) do
            if pageFrame:IsA("ScrollingFrame") then
                local leftCol = pageFrame:FindFirstChild("Left")
                local rightCol = pageFrame:FindFirstChild("Right")
                for _, col in ipairs({leftCol, rightCol}) do
                    if col then
                        for _, section in ipairs(col:GetChildren()) do
                            if section:IsA("Frame") then
                                if query == "" then
                                    section.Visible = true
                                else
                                    local matches = false
                                    for _, child in ipairs(section:GetDescendants()) do
                                        if (child:IsA("TextLabel") or child:IsA("TextButton")) and child.Text then
                                            if child.Text:lower():find(query, 1, true) then
                                                matches = true
                                                break
                                            end
                                        end
                                    end
                                    section.Visible = matches
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    searchInput:GetPropertyChangedSignal("Text"):Connect(function()
        contentSearch(searchInput.Text)
    end)
    local watermark = Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 14),
        Position = UDim2.new(0, 10, 1, -75),
        BackgroundTransparency = 1,
        Text = "UI Library by Seisen",
        TextColor3 = theme.TextMuted,
        Font = Enum.Font.Gotham,
        TextSize = 9,
        Parent = sidebar
    })
    self:RegisterElement(watermark, "TextMuted", "TextColor3")
    local profileSection = Create("Frame", {
        Name = "PlayerProfile",
        Size = UDim2.new(1, -10, 0, 50),
        Position = UDim2.new(0, 5, 1, -55),
        BackgroundColor3 = theme.Element,
        BackgroundTransparency = 0.5,
        ClipsDescendants = true,
        Parent = sidebar
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 6)})
    })
    local profileStroke = Instance.new("UIStroke")
    profileStroke.Color = theme.Border
    profileStroke.Thickness = 1
    profileStroke.Parent = profileSection
    self:RegisterElement(profileSection, "Element")
    self:RegisterElement(profileStroke, "Border", "Color")
    local avatarImage = Create("ImageLabel", {
        Name = "Avatar",
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(0, 7, 0.5, -18),
        BackgroundColor3 = theme.ToggleOff,
        Image = "",
        Parent = profileSection
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)})
    })
    pcall(function()
        local userId = LocalPlayer.UserId
        local thumbType = Enum.ThumbnailType.HeadShot
        local thumbSize = Enum.ThumbnailSize.Size100x100
        local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
        avatarImage.Image = content
    end)
    local playerName = Create("TextLabel", {
        Name = "PlayerName",
        Size = UDim2.new(1, -55, 0, 16),
        Position = UDim2.new(0, 48, 0, 8),
        BackgroundTransparency = 1,
        Text = LocalPlayer.DisplayName,
        TextColor3 = theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = profileSection
    })
    local username = Create("TextLabel", {
        Name = "Username",
        Size = UDim2.new(1, -55, 0, 12),
        Position = UDim2.new(0, 48, 0, 26),
        BackgroundTransparency = 1,
        Text = "@" .. LocalPlayer.Name,
        TextColor3 = theme.TextMuted,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = profileSection
    })
    local content = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -150, 1, 0),
        Position = UDim2.new(0, 150, 0, 0),
        BackgroundColor3 = theme.Content,
        BorderSizePixel = 0,
        Parent = main
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 8)})
    })
    self:RegisterElement(content, "Content")
    local header = Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = content,
    })
    
    local splashText = Create("TextLabel", {
        Name = "SplashText",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBlack,
        TextSize = 32,
        Parent = gui,
        ZIndex = 1200
    })

    local loadingScreen = Create("Frame", {
        Name = "LoadingScreen",
        Size = UDim2.fromOffset(360, 100),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = theme.Background,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = gui,
        ZIndex = 1100
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Create("UIStroke", {Color = theme.Border, Thickness = 1, Transparency = 1})
    })

    local loadingTopText = Create("TextLabel", {
        Name = "TopText",
        Size = UDim2.new(1, -15, 0, 25),
        BackgroundTransparency = 1,
        Text = options.SubTitle or options.Name or "V1.0.0",
        TextColor3 = theme.TextMuted,
        TextTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = loadingScreen,
        ZIndex = 1101
    })
    
    local loadingLabel = Create("TextLabel", {
        Name = "LoadingText",
        Size = UDim2.new(1, -40, 0, 30),
        Position = UDim2.new(0, 20, 0.5, -15),
        BackgroundTransparency = 1,
        Text = "Loading...",
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = loadingScreen,
        ZIndex = 1101
    })

    local loadingSubLabel = Create("TextLabel", {
        Name = "LoadingSubText",
        Size = UDim2.new(1, -40, 0, 15),
        Position = UDim2.new(0, 20, 0.65, 0),
        BackgroundTransparency = 1,
        Text = "by " .. (options.Author or LocalPlayer.Name),
        TextColor3 = theme.TextDim,
        TextTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = loadingScreen,
        ZIndex = 1101
    })
    
    local loadingWatermark = Create("TextLabel", {
        Name = "LoadingWatermark",
        Size = UDim2.new(1, -15, 0, 15),
        Position = UDim2.new(0, 0, 1, -25),
        BackgroundTransparency = 1,
        Text = "Seisen Library",
        TextColor3 = theme.TextMuted,
        TextTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextYAlignment = Enum.TextYAlignment.Bottom,
        Parent = loadingScreen,
        ZIndex = 1101
    })

    local widget = Create("Frame", {
        Size = UDim2.new(0, 120, 0, 60),
        Position = UDim2.new(0.1, 0, 0.1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = gui,
        ZIndex = 200
    })
    local widgetScale = Instance.new("UIScale")
    widgetScale.Scale = targetScale
    widgetScale.Parent = widget
    local currentToggleTween
    
    local isFirstLoad = true
    
    local function playLoadingAnimation(onComplete)
        local fullText = "Seisen Library"
        splashText.Text = ""
        main.Visible = false
        widget.Visible = false
        
        -- Phase 1: Wait for Seisen Library splash text
        for i = 1, #fullText do
            splashText.Text = string.sub(fullText, 1, i)
            task.wait(0.06)
        end
        
        task.wait(1) -- Hold the text
        
        -- Fade out splash text
        local fadeSplash = TweenService:Create(splashText, TweenInfo.new(0.6), {TextTransparency = 1})
        fadeSplash:Play()
        fadeSplash.Completed:Wait()
        splashText:Destroy()
        
        task.wait(0.2) -- Brief pause between sequences
        
        -- Phase 2: Proceed with the loading card
        Tween(loadingScreen, {BackgroundTransparency = 0}, 0.5)
        Tween(loadingScreen:FindFirstChild("UIStroke"), {Transparency = 0}, 0.5)
        Tween(loadingTopText, {TextTransparency = 0}, 0.5)
        Tween(loadingLabel, {TextTransparency = 0}, 0.5)
        Tween(loadingSubLabel, {TextTransparency = 0}, 0.5)
        Tween(loadingWatermark, {TextTransparency = 0}, 0.5)
        
        -- Simulate card loading process
        task.wait(0.5)
        loadingLabel.Text = "Loading Assets..."
        task.wait(0.6)
        loadingLabel.Text = "Initializing UI..."
        task.wait(0.6)
        loadingLabel.Text = "Almost Ready..."
        task.wait(0.6)
        loadingLabel.Text = "Complete!"
        task.wait(0.5)
        
        -- Phase 3: Fade out loading card
        Tween(loadingTopText, {TextTransparency = 1}, 0.5)
        Tween(loadingLabel, {TextTransparency = 1}, 0.5)
        Tween(loadingSubLabel, {TextTransparency = 1}, 0.5)
        Tween(loadingWatermark, {TextTransparency = 1}, 0.5)
        Tween(loadingScreen:FindFirstChild("UIStroke"), {Transparency = 1}, 0.5)
        local fadeOut = TweenService:Create(loadingScreen, TweenInfo.new(0.5), {BackgroundTransparency = 1})
        fadeOut:Play()
        
        fadeOut.Completed:Wait()
        loadingScreen:Destroy()
        
        task.wait(0.2) -- Final pause before executing window
        
        -- Phase 4: Execute the library window
        onComplete()
    end
    
    local function toggleWindow(visible)
        if currentToggleTween then currentToggleTween:Cancel() end
        if visible then
            main.Visible = true
            widget.Visible = false
            currentToggleTween = TweenService:Create(mainScale, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Scale = targetScale})
            currentToggleTween:Play()
        else
            Library:CloseAllDropdowns()
            currentToggleTween = TweenService:Create(mainScale, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Scale = 0})
            currentToggleTween:Play()
            
            local c
            c = currentToggleTween.Completed:Connect(function(playbackState)
                c:Disconnect()
                if playbackState == Enum.PlaybackState.Completed then
                    main.Visible = false
                    widget.Visible = true
                end
            end)
        end
    end

    playLoadingAnimation(function()
        main.Visible = true
        TweenService:Create(mainScale, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Scale = targetScale}):Play()
    end)
    function Library:Toggle(visible)
        if visible == nil then
            visible = not main.Visible
        end
        toggleWindow(visible)
    end
    Library.MainWindow = main
    Library.Widget = widget
    local isMaximized = false
    local normalSize = UDim2.new(0, 600, 0, 500)
    local normalPosition = UDim2.new(0.5, -300, 0.5, -250)
    local function toggleMaximize()
        if isMaximized then
            Tween(main, {Size = normalSize, Position = normalPosition}, 0.3)
            isMaximized = false
        else
            local screenSize = gui.AbsoluteSize
            Tween(main, {
                Size = UDim2.new(0, screenSize.X - 40, 0, screenSize.Y - 40),
                Position = UDim2.new(0, 20, 0, 20)
            }, 0.3)
            isMaximized = true
        end
    end
    minBtn.MouseButton1Click:Connect(function() toggleMaximize() end)
    maxBtn.MouseButton1Click:Connect(function() toggleWindow(false) end)
    MakeDraggable(widget, widget, function() toggleWindow(true) end)
    local widgetLogo = Create("ImageLabel", {
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0.5, -20, 0, 0),
        BackgroundTransparency = 1,
        BackgroundColor3 = Color3.new(0, 0, 0),
        Parent = widget
    })
    local widgetIcon = options.Icon or "rbxassetid://7072718336"
    Library:ApplyIcon(widgetLogo, widgetIcon)
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = widgetLogo})
    local widgetTitle = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 42),
        BackgroundTransparency = 1,
        Text = options.Name or "Seisen Library",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextStrokeTransparency = 0.5,
        Parent = widget
    })
    local widgetStats = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 26),
        Position = UDim2.new(0, 0, 0, 56),
        BackgroundTransparency = 1,
        Text = "60 fps\n50 ms",
        TextColor3 = Color3.fromRGB(200, 200, 200),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextStrokeTransparency = 0.5,
        Parent = widget
    })
    local RunService = game:GetService("RunService")
    local Stats = game:GetService("Stats")
    local lastUpdate = 0
    RunService.RenderStepped:Connect(function(dt)
        local now = tick()
        if now - lastUpdate > 0.5 and widget.Visible then
            local fps = math.floor(1 / dt)
            local ping = math.round(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            widgetStats.Text = string.format("%d fps\n%d ms", fps, ping)
            lastUpdate = now
        end
    end)
    local contentCover = Create("Frame", {
        Size = UDim2.new(0, 10, 1, 0),
        BackgroundColor3 = theme.Content,
        BorderSizePixel = 0,
        Parent = content
    })
    self:RegisterElement(contentCover, "Content")
    local titleLabel = Create("TextLabel", {
        Size = UDim2.new(0, 200, 0, 40),
        Position = UDim2.new(0, 15, 0, 5),
        BackgroundTransparency = 1,
        Text = name:upper():gsub("(%w+)%s*(%w*)", function(a, b) 
            if b and b ~= "" then
                return '<font color="#ffffff">' .. a .. '</font> <font color="#9090a0">' .. b .. '</font>'
            end
            return '<font color="#ffffff">' .. a .. '</font>'
        end),
        RichText = true,
        TextColor3 = theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })
    if options.Version or options.SubTitle then
        local badgeContainer = Create("Frame", {
            Name = "BadgeContainer",
            AnchorPoint = Vector2.new(1, 0),
            Size = UDim2.new(0, 300, 1, 0),
            Position = UDim2.new(1, -15, 0, 0),
            BackgroundTransparency = 1,
            Parent = header
        }, {
             Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal, 
                Padding = UDim.new(0, 8), 
                VerticalAlignment = Enum.VerticalAlignment.Center,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                SortOrder = Enum.SortOrder.LayoutOrder
            })
        })
        local function createBadge(text, color, layoutOrder)
             Create("TextLabel", {
                 Name = "Badge",
                 AutomaticSize = Enum.AutomaticSize.X,
                 Size = UDim2.new(0, 0, 0, 24),
                 BackgroundColor3 = color,
                 Text = text,
                 TextColor3 = Color3.new(0,0,0),
                 Font = Enum.Font.GothamBold,
                 TextSize = 13,
                 Parent = badgeContainer,
                 LayoutOrder = layoutOrder
             }, {
                 Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
                 Create("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
             })
        end
        if options.Version then
             createBadge(options.Version, theme.Accent, 1)
        end
        if options.SubTitle then
             createBadge(options.SubTitle, Color3.fromRGB(64, 164, 255), 2)
        end
    end
    local notificationContainer = Create("Frame", {
        Name = "NotificationContainer",
        Size = UDim2.new(0, 300, 1, 0),
        Position = UDim2.new(0.5, -150, 0, 10),
        BackgroundTransparency = 1,
        Parent = gui,
        ZIndex = 500
    }, {
        Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        }),
        Create("UIPadding", {PaddingTop = UDim.new(0, 10)})
    })
    Library.NotificationContainer = notificationContainer
    pages = Create("Folder", {Name = "Pages", Parent = content})
    MakeDraggable(sidebar, main)
    MakeDraggable(header, main)
    local resizeHandle = Create("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -16, 1, -16),
        BackgroundTransparency = 1,
        ImageColor3 = theme.TextDim,
        Parent = main,
        ZIndex = 200
    })
    Library:ApplyIcon(resizeHandle, "move-diagonal-2")
    Library:RegisterElement(resizeHandle, "TextDim", "ImageColor3")
    local resizing = false
    local minSize = Vector2.new(400, 300)
    local ghostFrame = nil
    resizeHandle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            local startSize = Vector2.new(main.Size.X.Offset, main.Size.Y.Offset)
            local startPos = i.Position
            local inputChanged
            local inputEnded
            inputChanged = UserInputService.InputChanged:Connect(function(input)
                local isValid = false
                local currentPos = input.Position
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    isValid = true
                elseif input.UserInputType == Enum.UserInputType.Touch and input == i then
                    isValid = true
                end
                if isValid then
                    local currentScale = mainScale.Scale
                    local deltaX = (currentPos.X - startPos.X) / currentScale
                    local deltaY = (currentPos.Y - startPos.Y) / currentScale
                    local newX = startSize.X + deltaX
                    local newY = startSize.Y + deltaY
                    newX = math.max(newX, minSize.X)
                    newY = math.max(newY, minSize.Y)
                    main.Size = UDim2.fromOffset(newX, newY)
                    sizeLabel.Text = string.format("%d x %d", math.floor(newX), math.floor(newY))
                end
            end)
            inputEnded = UserInputService.InputEnded:Connect(function(input)
                local isRelease = false
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                     isRelease = true
                elseif input.UserInputType == Enum.UserInputType.Touch and input == i then
                     isRelease = true
                end
                if isRelease then
                    resizing = false
                    if inputChanged then inputChanged:Disconnect() end
                    if inputEnded then inputEnded:Disconnect() end
                end
            end)
        end
    end)
    if options.ToggleKeybind then
        Library.ToggleKeybind = options.ToggleKeybind
        Library.KeybindEnabled = true -- Initialize as enabled
    end
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and Library.KeybindEnabled and Library.ToggleKeybind and input.KeyCode == Library.ToggleKeybind then
            Library:Toggle()
        end
    end)
    local WindowFuncs = {}
    function WindowFuncs:Notify(opts)
        Library:Notify(opts)
    end
    local firstTab = true
    local activeTab = nil
    function WindowFuncs:SetScale(scale)
        mainScale.Scale = scale
    end
    function WindowFuncs:AddSidebarSection(sectionName)
        local section = Create("TextLabel", {
            Name = "Section_" .. sectionName,
            Size = UDim2.new(1, -24, 0, 20),
            BackgroundTransparency = 1,
            Text = sectionName:upper(),
            TextColor3 = theme.TextMuted,
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = tabList
        }, {
             Create("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingTop = UDim.new(0, 6)})
        })
        Library:RegisterElement(section, "TextMuted", "TextColor3")
    end
    function WindowFuncs:AddSidebarDivider()
        local divContainer = Create("Frame", {
            Name = "Divider",
            Size = UDim2.new(1, 0, 0, 14),
            BackgroundTransparency = 1,
            Parent = tabList
        })
        local line = Create("Frame", {
            Size = UDim2.new(1, -24, 0, 1),
            Position = UDim2.new(0, 12, 0.5, 0),
            BackgroundColor3 = theme.Border,
            BorderSizePixel = 0,
            Parent = divContainer
        })
        Library:RegisterElement(line, "Border")
    end
    function WindowFuncs:CreateTab(tabOptions, iconArg, subtitleArg)
        local tabName, tabSubtitle, tabIconName
        if type(tabOptions) == "string" then
            tabName = tabOptions
            tabIconName = iconArg or "home"
            tabSubtitle = subtitleArg or tabOptions
        else
            tabName = tabOptions.Name or "Tab"
            tabIconName = tabOptions.Icon or "home"
            tabSubtitle = tabOptions.Subtitle or tabName
        end
        local tabBtn = Create("TextButton", {
            Name = tabName,
            Size = UDim2.new(1, -16, 0, 34),
            BackgroundColor3 = theme.Sidebar,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            Parent = tabList,
            LayoutOrder = type(tabOptions) == "table" and tabOptions.LayoutOrder or 0
        }, {
             Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
             Create("UIStroke", {Color = theme.Border, Thickness = 1, Transparency = 0.5})
        })
        Library:RegisterElement(tabBtn:FindFirstChild("UIStroke"), "Border", "Color")
        local iconProps = {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 12, 0.5, -8),
            BackgroundTransparency = 1,
            ImageColor3 = theme.TextDim,
            Parent = tabBtn
        }
        Library:ApplyIcon(Create("ImageLabel", iconProps), tabIconName)
        local tabLabel = Create("TextLabel", {
            Size = UDim2.new(1, -45, 1, 0),
            Position = UDim2.new(0, 35, 0, 0),
            BackgroundTransparency = 1,
            Text = tabName,
            TextColor3 = theme.TextDim,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ClipsDescendants = true,
            Parent = tabBtn
        })
        local page = Create("ScrollingFrame", {
            Name = tabName,
            Size = UDim2.new(1, -20, 1, -55),
            Position = UDim2.new(0, 10, 0, 50),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = theme.Accent,
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Parent = pages
        })
        local leftCol = Create("Frame", {
            Name = "Left",
            Size = UDim2.new(0.5, -5, 1, 0),
            BackgroundTransparency = 1,
            Parent = page
        }, {
            Create("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder})
        })
        local rightCol = Create("Frame", {
            Name = "Right",
            Size = UDim2.new(0.5, -5, 1, 0),
            Position = UDim2.new(0.5, 5, 0, 0),
            BackgroundTransparency = 1,
            Parent = page
        }, {
            Create("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder})
        })
        local updateThread
        local function updateCanvas()
            if updateThread then task.cancel(updateThread) end
            updateThread = task.defer(function()
                local leftH = leftCol:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y
                local rightH = rightCol:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y
                page.CanvasSize = UDim2.new(0, 0, 0, math.max(leftH, rightH) + 10)
            end)
        end
        leftCol:FindFirstChildOfClass("UIListLayout"):GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        rightCol:FindFirstChildOfClass("UIListLayout"):GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        local function activate()
            if activeTab == tabBtn then return end
            for _, t in pairs(tabList:GetChildren()) do
                if t:IsA("TextButton") and t ~= tabBtn then
                    Tween(t, {BackgroundTransparency = 1, BackgroundColor3 = theme.Sidebar})
                    local lbl = t:FindFirstChild("TextLabel")
                    local icon = t:FindFirstChildOfClass("ImageLabel")
                    if lbl then Tween(lbl, {TextColor3 = theme.TextDim}) end
                    if icon then Tween(icon, {ImageColor3 = theme.TextDim}) end
                end
            end
            for _, p in pairs(pages:GetChildren()) do p.Visible = false end
            activeTab = tabBtn
            page.Visible = true
            Tween(tabBtn, {BackgroundTransparency = 0, BackgroundColor3 = theme.Element})
            Tween(tabLabel, {TextColor3 = theme.Text})
            local icon = tabBtn:FindFirstChildOfClass("ImageLabel")
            if icon then Tween(icon, {ImageColor3 = theme.Text}) end
        end
        tabBtn.MouseEnter:Connect(function()
            if activeTab ~= tabBtn then
                Tween(tabBtn, {BackgroundTransparency = 0.8, BackgroundColor3 = theme.ElementHover})
                Tween(tabLabel, {TextColor3 = theme.Text})
                local icon = tabBtn:FindFirstChildOfClass("ImageLabel")
                if icon then Tween(icon, {ImageColor3 = theme.Text}) end
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if activeTab ~= tabBtn then
                Tween(tabBtn, {BackgroundTransparency = 1, BackgroundColor3 = theme.Sidebar})
                Tween(tabLabel, {TextColor3 = theme.TextDim})
                local icon = tabBtn:FindFirstChildOfClass("ImageLabel")
                if icon then Tween(icon, {ImageColor3 = theme.TextDim}) end
            end
        end)
        tabBtn.MouseButton1Click:Connect(activate)
        if firstTab then
            activate()
            firstTab = false
        end
        local TabFuncs = {}
        function TabFuncs:CreateSection(sectionOptions, sideArg, iconArg)
            local sectionName, side, sectionIconName
            if type(sectionOptions) == "string" then
                sectionName = sectionOptions
                side = sideArg or "Left"
                sectionIconName = iconArg
            else
                sectionName = sectionOptions.Name or "Section"
                side = sectionOptions.Side or "Left"
                sectionIconName = sectionOptions.Icon
            end
            local parent = (side == "Right") and rightCol or leftCol
            local section = Create("Frame", {
                Name = sectionName,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = theme.Element,
                BackgroundTransparency = 0.5,
                ClipsDescendants = true,
                Parent = parent
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 6)})
            })
            local sectionStroke = Instance.new("UIStroke")
            sectionStroke.Color = theme.Border
            sectionStroke.Thickness = 1
            sectionStroke.Parent = section
            Create("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 8), Parent = section})
            Library:RegisterElement(section, "Element")
            Library:RegisterElement(sectionStroke, "Border", "Color")
            
            if sectionIconName then
                local iconProps = {
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(0, 0, 0, 2),
                    BackgroundTransparency = 1,
                    ImageColor3 = theme.Text,
                    Parent = section
                }
                Library:ApplyIcon(Create("ImageLabel", iconProps), sectionIconName)
            end

            local titleLabel = Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 18),
                Position = sectionIconName and UDim2.new(0, 18, 0, 0) or UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = sectionName,
                TextColor3 = theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = section
            })
            local container = Create("Frame", {
                Name = "Container",
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Position = UDim2.new(0, 0, 0, 22),
                BackgroundColor3 = theme.Sidebar,
                BackgroundTransparency = 0.5,
                ClipsDescendants = true,
                Parent = section
            }, {
                Create("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}),
                Create("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10)}),
                Create("UICorner", {CornerRadius = UDim.new(0, 8)})
            })
            Library:RegisterElement(container, "Sidebar")
            local SectionFuncs = {}
            function SectionFuncs:AddToggle(toggleOptions)
                return Library:CreateToggle(container, toggleOptions)
            end
            function SectionFuncs:AddButton(btnOptions)
                return Library:CreateButton(container, btnOptions)
            end
            function SectionFuncs:AddSlider(sliderOptions)
                return Library:CreateSlider(container, sliderOptions)
            end
            function SectionFuncs:AddDropdown(dropOptions)
                return Library:CreateDropdown(container, dropOptions)
            end
            function SectionFuncs:AddTextbox(boxOptions)
                local boxName = boxOptions.Name or "Input"
                local default = boxOptions.Default or ""
                local placeholder = boxOptions.Placeholder or ""
                local callback = boxOptions.Callback or function() end
                local flag = boxOptions.Flag
                local box = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 38),
                    BackgroundTransparency = 1,
                    Parent = container
                })
                Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text = boxName,
                    TextColor3 = theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = box
                })
                local input = Create("TextBox", {
                    Size = UDim2.new(1, 0, 0, 18),
                    Position = UDim2.new(0, 0, 0, 16),
                    BackgroundColor3 = theme.Element,
                    Text = default,
                    PlaceholderText = placeholder,
                    TextColor3 = theme.Text,
                    PlaceholderColor3 = theme.TextMuted,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    Parent = box
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
                    Create("UIPadding", {PaddingLeft = UDim.new(0, 8)})
                })
                local inputStroke = Instance.new("UIStroke")
                inputStroke.Color = theme.Border
                inputStroke.Thickness = 1
                inputStroke.Parent = input
                Library:RegisterElement(input, "Element")
                Library:RegisterElement(inputStroke, "Border", "Color")
                local inputObj = {
                    Value = default,
                    Type = "Input",
                    SetValue = function(self, val)
                        self.Value = val
                        input.Text = val
                    end
                }
                input.FocusLost:Connect(function()
                    inputObj.Value = input.Text
                    callback(input.Text)
                end)
                if flag then Library.Options[flag] = inputObj end
            end
            function SectionFuncs:AddLabel(labelOptions)
                labelOptions.Height = labelOptions.Height or 18
                labelOptions.TextWrapped = true
                return Library:CreateLabel(container, labelOptions)
            end
            function SectionFuncs:AddCheckbox(checkOptions)
                local checkName = checkOptions.Name or "Checkbox"
                local default = checkOptions.Default or false
                local callback = checkOptions.Callback or function() end
                local flag = checkOptions.Flag
                local state = default
                local check = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 22),
                    BackgroundTransparency = 1,
                    Parent = container
                })
                local box = Create("TextButton", {
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(0, 0, 0.5, -9),
                    BackgroundColor3 = theme.Element,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = check
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(1, 0)})
                })
                local boxStroke = Instance.new("UIStroke")
                boxStroke.Color = theme.Border
                boxStroke.Thickness = 1
                boxStroke.Parent = box
                local inner = Create("Frame", {
                    Size = state and UDim2.new(0, 10, 0, 10) or UDim2.new(0, 0, 0, 0),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = theme.Accent,
                    BorderSizePixel = 0,
                    Parent = box
                }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
                Library:RegisterElement(boxStroke, "Border", "Color")
                Library:RegisterElement(inner, "Accent")
                table.insert(Library.Registry, {
                    Callback = function(theme)
                        local tTheme = theme or Library.Theme
                        box.BackgroundColor3 = tTheme.Element
                    end
                })
                Create("TextLabel", {
                    Size = UDim2.new(1, -30, 1, 0),
                    Position = UDim2.new(0, 26, 0, 0),
                    BackgroundTransparency = 1,
                    Text = checkName,
                    TextColor3 = theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = check
                })
                local checkObj = {
                    Value = state,
                    SetValue = function(self, val)
                        state = val
                        self.Value = val
                        Tween(inner, {Size = val and UDim2.new(0, 10, 0, 10) or UDim2.new(0, 0, 0, 0)})
                        callback(val)
                    end
                }
                box.MouseButton1Click:Connect(function()
                    checkObj:SetValue(not state)
                end)
                if flag then Library.Toggles[flag] = checkObj end
                if default then callback(true) end
            end
            function SectionFuncs:AddKeybind(keybindOptions)
                return Library:CreateKeybind(container, keybindOptions)
            end
            function SectionFuncs:AddColorPicker(colorOptions)
                local colorName = colorOptions.Name or "Color"
                local default = colorOptions.Default or Color3.fromRGB(255, 255, 255)
                local callback = colorOptions.Callback or function() end
                local flag = colorOptions.Flag
                local currentColor = default
                local picker = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Parent = container
                })
                Create("TextLabel", {
                    Size = UDim2.new(0, 100, 1, 0),
                    BackgroundTransparency = 1,
                    Text = colorName,
                    TextColor3 = theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = picker
                })
                local colorBox = Create("TextButton", {
                    Size = UDim2.new(0, 40, 0, 18),
                    Position = UDim2.new(1, -45, 0.5, -9),
                    BackgroundColor3 = currentColor,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = picker
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 4)})
                })
                local colorBoxStroke = Instance.new("UIStroke")
                colorBoxStroke.Color = theme.Border
                colorBoxStroke.Thickness = 1
                colorBoxStroke.Parent = colorBox
                Library:RegisterElement(colorBoxStroke, "Border", "Color")
                local popup = Create("Frame", {
                    Size = UDim2.new(0, 150, 0, 100),
                    Position = UDim2.new(1, 5, 0, 0),
                    BackgroundColor3 = theme.Element,
                    Visible = false,
                    ZIndex = 200,
                    Parent = colorBox
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                    Create("UIStroke", {Color = theme.Border, Thickness = 1, ZIndex = 200})
                })
                local popupScale = Create("UIScale", {Parent = popup, Scale = 1})
                local presets = {
                    Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 127, 0),
                    Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 255, 0),
                    Color3.fromRGB(0, 255, 255), Color3.fromRGB(0, 0, 255),
                    Color3.fromRGB(127, 0, 255), Color3.fromRGB(255, 0, 255),
                    Color3.fromRGB(255, 255, 255), Color3.fromRGB(128, 128, 128),
                    Color3.fromRGB(64, 64, 64), Color3.fromRGB(0, 0, 0)
                }
                local presetContainer = Create("Frame", {
                    Size = UDim2.new(1, -10, 0, 50),
                    Position = UDim2.new(0, 5, 0, 5),
                    BackgroundTransparency = 1,
                    Parent = popup
                }, {
                    Create("UIGridLayout", {CellSize = UDim2.new(0, 22, 0, 22), CellPadding = UDim2.new(0, 4, 0, 4)})
                })
                local colorObj = {
                    Value = currentColor,
                    Type = "ColorPicker",
                    SetValue = function(self, color)
                        currentColor = color
                        self.Value = color
                        colorBox.BackgroundColor3 = color
                        callback(color)
                    end
                }
                for _, preset in ipairs(presets) do
                    local presetBtn = Create("TextButton", {
                        BackgroundColor3 = preset,
                        Text = "",
                        ZIndex = 201,
                        Parent = presetContainer
                    }, {Create("UICorner", {CornerRadius = UDim.new(0, 4)})})
                    presetBtn.MouseButton1Click:Connect(function()
                        colorObj:SetValue(preset)
                        popup.Visible = false
                    end)
                end
                local RunService = game:GetService("RunService")
                local connection = nil
                local function updatePosition()
                    if popup.Visible and colorBox.Parent then
                        if mainScale then popupScale.Scale = mainScale.Scale end
                        popup.Position = UDim2.fromOffset(
                            colorBox.AbsolutePosition.X - (popup.AbsoluteSize.X * popupScale.Scale) - 5, 
                            colorBox.AbsolutePosition.Y
                        )
                    end
                end
                colorBox.MouseButton1Click:Connect(function()
                    popup.Visible = not popup.Visible
                    if popup.Visible then
                        popup.Parent = gui
                        updatePosition()
                        connection = RunService.RenderStepped:Connect(updatePosition)
                    else
                        popup.Parent = colorBox
                        if connection then connection:Disconnect() connection = nil end
                    end
                end)
                colorBox.Destroying:Connect(function()
                    if connection then connection:Disconnect() end
                    popup:Destroy()
                end)
                if flag then Library.Options[flag] = colorObj end
            end
            function SectionFuncs:AddDivider(text)
                local divider = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Parent = container
                })
                if text and text ~= "" then
                    Create("TextLabel", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text = "— " .. text .. " —",
                        TextColor3 = theme.TextMuted,
                        Font = Enum.Font.Gotham,
                        TextSize = 10,
                        Parent = divider
                    })
                else
                    Create("Frame", {
                        Size = UDim2.new(1, 0, 0, 1),
                        Position = UDim2.new(0, 0, 0.5, 0),
                        BackgroundColor3 = theme.Border,
                        BorderSizePixel = 0,
                        Parent = divider
                    })
                end
            end
            function SectionFuncs:AddTabbox(tabboxOptions)
                local tabboxName = tabboxOptions.Name or "Tabbox"
                local tabbox = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = theme.Element,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Parent = container
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 6)})
                })
                local tabHeader = Create("ScrollingFrame", {
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundTransparency = 1,
                    ScrollBarThickness = 0,
                    CanvasSize = UDim2.fromScale(0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.X,
                    ClipsDescendants = true,
                    Parent = tabbox
                }, {
                    Create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDim.new(0, 2),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    }),
                    Create("UIPadding", {PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2)})
                })
                local tabContent = Create("Frame", {
                    Size = UDim2.new(1, -10, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Position = UDim2.new(0, 5, 0, 28),
                    BackgroundTransparency = 1,
                    Parent = tabbox
                })
                local TabboxFuncs = {}
                local tabs = {}
                local activeTab = nil
                function TabboxFuncs:AddTab(name)
                    local tabBtn = Create("TextButton", {
                        AutomaticSize = Enum.AutomaticSize.X,
                        Size = UDim2.new(0, 0, 1, -4),
                        BackgroundColor3 = theme.ToggleOff,
                        BackgroundTransparency = 0.5,
                        Text = name,
                        TextColor3 = theme.TextDim,
                        Font = Enum.Font.Gotham,
                        TextSize = 11,
                        AutoButtonColor = false,
                        Parent = tabHeader
                    }, {
                        Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
                        Create("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
                    })
                    local tabPage = Create("Frame", {
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        Visible = false,
                        Parent = tabContent
                    }, {
                        Create("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}),
                        Create("UIPadding", {PaddingBottom = UDim.new(0, 8)})
                    })
                    table.insert(tabs, {btn = tabBtn, page = tabPage})
                    local function activate()
                        for _, t in ipairs(tabs) do
                            t.page.Visible = false
                            t.btn.BackgroundTransparency = 0.5
                            t.btn.BackgroundColor3 = theme.ToggleOff
                            t.btn.TextColor3 = theme.TextDim
                        end
                        tabPage.Visible = true
                        tabBtn.BackgroundTransparency = 0
                        tabBtn.BackgroundColor3 = theme.Accent
                        tabBtn.TextColor3 = theme.Text
                        activeTab = tabPage
                    end

                    tabBtn.MouseButton1Click:Connect(activate)

                    if #tabs == 1 then
                        activate()
                    end
                    local TabPageFuncs = {}
                    setmetatable(TabPageFuncs, {__index = function(_, key)
                        if SectionFuncs[key] then
                            return function(self, opts)
                                local originalParent = container
                                container = tabPage
                                local result = SectionFuncs[key](self, opts)
                                container = originalParent
                                return result
                            end
                        end
                    end})
                    return TabPageFuncs
                end
                return TabboxFuncs
            end
            function SectionFuncs:AddDependencyBox(dependencyOptions)
                local dependsOn = dependencyOptions.DependsOn
                local depBox = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    Parent = container
                }, {
                    Create("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder})
                })
                local innerContainer = container
                container = depBox
                local DepFuncs = {}
                setmetatable(DepFuncs, {__index = SectionFuncs})
                local function updateVisibility()
                    local toggle = Library.Toggles[dependsOn]
                    if toggle then
                        local visible = toggle.Value
                        local layout = depBox:FindFirstChildOfClass("UIListLayout")
                        local height = visible and layout.AbsoluteContentSize.Y or 0
                        Tween(depBox, {Size = UDim2.new(1, 0, 0, height)})
                    end
                end
                task.defer(function()
                    if Library.Toggles[dependsOn] then
                        local originalSet = Library.Toggles[dependsOn].SetValue
                        Library.Toggles[dependsOn].SetValue = function(self, val)
                            originalSet(self, val)
                            updateVisibility()
                        end
                        updateVisibility()
                    end
                end)
                container = innerContainer
                return DepFuncs
            end
            function SectionFuncs:AddImage(imageOptions)
                local imagePath = imageOptions.Image or ""
                local height = imageOptions.Height or 100
                local imgFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, height),
                    BackgroundTransparency = 1,
                    Parent = container
                })
                Create("ImageLabel", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Image = imagePath,
                    ScaleType = Enum.ScaleType.Fit,
                    Parent = imgFrame
                })
                return {
                    SetImage = function(self, newImage)
                        imgFrame:FindFirstChildOfClass("ImageLabel").Image = newImage
                    end
                }
            end
            function SectionFuncs:AddViewport(viewportOptions)
                local height = viewportOptions.Height or 100
                local vpFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, height),
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    Parent = container
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 6)})
                })
                local viewport = Create("ViewportFrame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Parent = vpFrame
                })
                return {
                    Viewport = viewport,
                    SetModel = function(self, model)
                        for _, c in pairs(viewport:GetChildren()) do c:Destroy() end
                        if model then
                            local clone = model:Clone()
                            clone.Parent = viewport
                        end
                    end
                }
            end
            function SectionFuncs:AddPassthrough(passthroughOptions)
                local element = passthroughOptions.Element
                local height = passthroughOptions.Height or 50
                local passFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, height),
                    BackgroundTransparency = 1,
                    Parent = container
                })
                if element then
                    element.Parent = passFrame
                    element.Size = UDim2.new(1, 0, 1, 0)
                end
                return passFrame
            end
            return SectionFuncs
        end
        TabFuncs.AddSection = TabFuncs.CreateSection
        function TabFuncs:AddLeftTabbox(name)
            return createTabbox(name, leftCol, theme, gui, Create, Tween, Library)
        end
        function TabFuncs:AddRightTabbox(name)
            return createTabbox(name, rightCol, theme, gui, Create, Tween, Library)
        end
        function TabFuncs:AddLeftSection(name, icon)
            return TabFuncs:CreateSection(name, "Left", icon)
        end
        function TabFuncs:AddRightSection(name, icon)
            return TabFuncs:CreateSection(name, "Right", icon)
        end
        return TabFuncs
    end
    WindowFuncs.AddTab = WindowFuncs.CreateTab

    if options.ConfigSettings then
        local SettingsTab = WindowFuncs:CreateTab({ Name = "Settings", Icon = "settings", LayoutOrder = 9999 })
        local PlayerGroup = SettingsTab:AddLeftSection("Player Settings", "user")
        local UIGroup = SettingsTab:AddRightSection("UI Settings", "monitor")
        
        local walkSpeedValue = 16
        local walkSpeedConnection = nil
        local walkSpeedCharConnection = nil

        PlayerGroup:AddToggle({
            Name = "WalkSpeed",
            Default = false,
            Flag = "BuiltIn_WalkSpeedToggle",
            Callback = function(v)
                pcall(function()
                    if v then
                        -- Enable walkspeed
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                            LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeedValue
                        end
                        
                        -- Character added connection
                        if not walkSpeedCharConnection then
                            walkSpeedCharConnection = LocalPlayer.CharacterAdded:Connect(function(char)
                                task.wait(0.5)
                                local hum = char:FindFirstChild("Humanoid")
                                if hum then
                                    hum.WalkSpeed = walkSpeedValue
                                end
                            end)
                        end

                        -- Heartbeat connection to enforce walkspeed
                        if not walkSpeedConnection then
                            walkSpeedConnection = game:GetService("RunService").Heartbeat:Connect(function()
                                if LocalPlayer.Character then
                                    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                                    if hum and hum.WalkSpeed ~= walkSpeedValue then
                                        hum.WalkSpeed = walkSpeedValue
                                    end
                                end
                            end)
                        end
                    else
                        -- Disable walkspeed - disconnect and reset
                        if walkSpeedConnection then
                            walkSpeedConnection:Disconnect()
                            walkSpeedConnection = nil
                        end
                        if walkSpeedCharConnection then
                            walkSpeedCharConnection:Disconnect()
                            walkSpeedCharConnection = nil
                        end
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                            LocalPlayer.Character.Humanoid.WalkSpeed = 16
                        end
                    end
                end)
            end
        })

        PlayerGroup:AddSlider({
            Name = "WalkSpeed Value",
            Min = 16,
            Max = 300,
            Default = 16,
            Flag = "BuiltIn_WalkSpeed",
            Callback = function(v)
                walkSpeedValue = v
                -- Only apply if currently enabled
                if walkSpeedConnection and LocalPlayer.Character then
                    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                    if hum then
                        hum.WalkSpeed = v
                    end
                end
            end
        })

        PlayerGroup:AddDivider()
        PlayerGroup:AddSlider({
            Name = "JumpPower",
            Min = 50,
            Max = 300,
            Default = 50,
            Flag = "BuiltIn_JumpPower",
            Callback = function(v)
                pcall(function()
                    local hum = LocalPlayer.Character.Humanoid
                    hum.UseJumpPower = true
                    hum.JumpPower = v
                end)
            end
        })
        PlayerGroup:AddDivider()
        local flying = false
        local flyVel
        local flySpeed = 50
        PlayerGroup:AddToggle({
            Name = "Fly",
            Default = false,
            Flag = "BuiltIn_Fly",
            Keybind = Enum.KeyCode.F3,
            Callback = function(v)
                flying = v
                if flying then
                    pcall(function()
                        local hrp = LocalPlayer.Character.HumanoidRootPart
                        flyVel = Instance.new("BodyVelocity")
                        flyVel.MaxForce = Vector3.new(1, 1, 1) * 10^6
                        flyVel.Velocity = Vector3.zero
                        flyVel.Parent = hrp
                        
                        task.spawn(function()
                            while flying and hrp and hrp.Parent do
                                local cam = workspace.CurrentCamera
                                local dir = Vector3.zero
                                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
                                
                                flyVel.Velocity = dir * flySpeed
                                task.wait()
                            end
                            if flyVel then flyVel:Destroy() end
                        end)
                    end)
                else
                    if flyVel then flyVel:Destroy() end
                end
            end
        })

        PlayerGroup:AddSlider({
            Name = "Fly Speed",
            Min = 10,
            Max = 200,
            Default = 50,
            Increment = 5,
            Flag = "BuiltIn_FlySpeed",
            Callback = function(v)
                flySpeed = v
            end
        })
        PlayerGroup:AddDivider()
        local antiAfk = false
        PlayerGroup:AddToggle({
            Name = "Anti-AFK",
            Default = false,
            Flag = "BuiltIn_AntiAFK",
            Callback = function(v)
                antiAfk = v
                if antiAfk then
                    task.spawn(function()
                        local VirtualUser = game:GetService("VirtualUser")
                        while antiAfk do
                            VirtualUser:CaptureController()
                            VirtualUser:ClickButton2(Vector2.zero)
                            task.wait(30)
                        end
                    end)
                end
            end
        })

        -- FPS Boost
        local fpsBoostEnabled = false
        local originalSettings = {}
        local savedEffects = {}   -- { [obj] = { type="effect", enabled=bool } }
        local savedMeshes  = {}   -- { [obj] = originalRenderFidelity }
        PlayerGroup:AddToggle({
            Name = "FPS Boost",
            Default = false,
            Flag = "BuiltIn_FPSBoost",
            Tooltip = "Optimize graphics for better performance",
            Callback = function(v)
                fpsBoostEnabled = v
                local Lighting = game:GetService("Lighting")
                
                if fpsBoostEnabled then
                    -- Save and apply Lighting settings
                    originalSettings.GlobalShadows = Lighting.GlobalShadows
                    originalSettings.FogEnd = Lighting.FogEnd
                    originalSettings.Brightness = Lighting.Brightness
                    Lighting.GlobalShadows = false
                    Lighting.FogEnd = 100000
                    Lighting.Brightness = 1
                    
                    -- Save and disable effects / degrade mesh fidelity
                    savedEffects = {}
                    savedMeshes  = {}
                    for _, obj in pairs(workspace:GetDescendants()) do
                        pcall(function()
                            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                                savedEffects[obj] = obj.Enabled
                                obj.Enabled = false
                            elseif obj:IsA("MeshPart") then
                                savedMeshes[obj] = obj.RenderFidelity
                                obj.RenderFidelity = Enum.RenderFidelity.Performance
                            end
                        end)
                    end
                    
                    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                else
                    -- Restore Lighting
                    if originalSettings.GlobalShadows ~= nil then
                        Lighting.GlobalShadows = originalSettings.GlobalShadows
                        Lighting.FogEnd = originalSettings.FogEnd
                        Lighting.Brightness = originalSettings.Brightness
                    end
                    settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic

                    -- Restore effects
                    for obj, wasEnabled in pairs(savedEffects) do
                        pcall(function()
                            if obj and obj.Parent then
                                obj.Enabled = wasEnabled
                            end
                        end)
                    end
                    savedEffects = {}

                    -- Restore mesh fidelity
                    for obj, fidelity in pairs(savedMeshes) do
                        pcall(function()
                            if obj and obj.Parent then
                                obj.RenderFidelity = fidelity
                            end
                        end)
                    end
                    savedMeshes = {}
                end
            end
        })

        PlayerGroup:AddToggle({
            Name = "Auto Hide UI",
            Default = false,
            Flag = "BuiltIn_AutoHideUI",
            Tooltip = "Automatically hide the UI when the script loads",
            Callback = function(v)
                if v then
                    task.defer(function()
                        Library:Toggle(false)
                    end)
                end
            end
        })

        -- UI Settings Section
        -- Script Information Section
        UIGroup:AddLabel({ Text = "Script by: Seisen" })
        
        -- Get current game name dynamically
        local gameName = "Unknown Game"
        pcall(function()
            local MarketplaceService = game:GetService("MarketplaceService")
            local success, info = pcall(function()
                return MarketplaceService:GetProductInfo(game.PlaceId)
            end)
            if success and info then
                gameName = info.Name
            end
        end)
        
        UIGroup:AddLabel({ Text = "Game: " .. gameName })
        UIGroup:AddButton({
            Name = "Join Discord",
            Callback = function()
                setclipboard("https://discord.gg/F4sAf6z8Ph")
            end
        })



    end
    return WindowFuncs
end

function Library:OnUnload(callback)
    self.UnloadCallback = callback
end

function Library:Unload()
    -- Call the UnloadCallback first (for user cleanup like stopping loops)
    if self.UnloadCallback then
        pcall(self.UnloadCallback)
    end
    
    -- Turn off all toggles to trigger their cleanup callbacks
    pcall(function()
        for flag, toggle in pairs(self.Toggles) do
            if toggle.SetValue and toggle.Value then
                pcall(function()
                    toggle:SetValue(false)
                end)
            end
        end
    end)

    -- Reset player stats that sliders may have changed but have no toggle
    pcall(function()
        local char = LocalPlayer and LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
                hum.UseJumpPower = true
                hum.JumpPower = 50
            end
        end
    end)
    
    -- Cancel any running tooltip thread
    if self.TooltipThread then
        pcall(function() task.cancel(self.TooltipThread) end)
        self.TooltipThread = nil
    end
    
    -- Disconnect tooltip connection
    if TooltipConnection then
        pcall(function() TooltipConnection:Disconnect() end)
        TooltipConnection = nil
    end
    
    -- Destroy tooltip frame
    if TooltipFrame then
        pcall(function() TooltipFrame:Destroy() end)
        TooltipFrame = nil
        TooltipLabel = nil
    end
    
    -- Close all open dropdowns
    pcall(function()
        for _, dropdown in ipairs(self.OpenDropdowns) do
            if dropdown.Close then
                pcall(dropdown.Close)
            end
        end
    end)
    
    -- Clear all tables
    self.Toggles = {}
    self.Options = {}
    self.Labels = {}
    self.Flags = {}
    self.Registry = {}
    self.OpenDropdowns = {}
    
    -- Destroy the main ScreenGui
    if self.ScreenGui then
        pcall(function() self.ScreenGui:Destroy() end)
        self.ScreenGui = nil
    end
    
    -- Clear references
    self.MainWindow = nil
    self.Widget = nil
    self.MainScale = nil
    
    print("Seisen UI fully unloaded and cleaned up")
end
return Library

