-- ================================================================
-- SeisenUI  ·  Charcoal Edition
-- Deep charcoal surfaces · Steel-blue accent · Compact elements
-- ================================================================
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local Stats            = game:GetService("Stats")
local LocalPlayer      = Players.LocalPlayer

local IconsLoaded, Icons = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Seisen88/Seisen-Library/main/addons/source.lua"))()
end)

local Library = {
    Toggles = {}, Options = {}, Labels = {}, Flags = {},
    Registry = {}, OpenDropdowns = {},
    ScreenGui = nil, NotificationContainer = nil,
    Icons = IconsLoaded and Icons or nil,
    KeybindFrame = nil, KeybindRows = {}, KeybindConnections = {},
    Theme = {
        Background    = Color3.fromRGB(16,  16,  20),
        Sidebar       = Color3.fromRGB(12,  12,  15),
        SidebarActive = Color3.fromRGB(26,  26,  34),
        Content       = Color3.fromRGB(20,  20,  25),
        Element       = Color3.fromRGB(28,  28,  36),
        ElementHover  = Color3.fromRGB(36,  36,  46),
        InputBg       = Color3.fromRGB(22,  22,  28),
        Border        = Color3.fromRGB(46,  46,  58),
        BorderLight   = Color3.fromRGB(62,  62,  78),
        Accent        = Color3.fromRGB(155, 155, 170),
        AccentHover   = Color3.fromRGB(180, 180, 195),
        AccentDark    = Color3.fromRGB(44,  44,  56),
        Text          = Color3.fromRGB(225, 225, 232),
        TextDim       = Color3.fromRGB(128, 128, 145),
        TextMuted     = Color3.fromRGB(62,  62,  78),
        Toggle        = Color3.fromRGB(155, 155, 170),
        ToggleOff     = Color3.fromRGB(36,  36,  48),
        Success       = Color3.fromRGB(72,  196, 118),
        Warning       = Color3.fromRGB(245, 168,  40),
        Error         = Color3.fromRGB(232,  82,  82),
        Info          = Color3.fromRGB(155, 155, 170),
    },
    ToggleKeybind = nil,
    IsMobile = false
}

-- ── Keybind panel row ────────────────────────────────────────────
function Library:RegisterKeybindRow(name, getKeyFn, isToggle, getValueFn)
    if not self.KeybindFrame then return end
    local container = self.KeybindFrame:FindFirstChildWhichIsA("ScrollingFrame")
    if not container then return end
    local function n(class, props)
        local i = Instance.new(class)
        for k, v in pairs(props) do i[k] = v end
        return i
    end
    local row = n("Frame", { Size = UDim2.new(1, -8, 0, 22), BackgroundTransparency = 1, BorderSizePixel = 0 })
    local keyBadge = n("TextLabel", {
        Size = UDim2.new(0, 50, 1, -4), Position = UDim2.new(0, 0, 0, 2),
        BackgroundColor3 = self.Theme.Element, Text = "NONE",
        TextColor3 = self.Theme.Accent, Font = Enum.Font.GothamBold,
        TextSize = 10, BorderSizePixel = 0, Parent = row
    })
    n("UICorner", { CornerRadius = UDim.new(0, 5), Parent = keyBadge })
    n("TextLabel", {
        Size = UDim2.new(1, isToggle and -86 or -56, 1, 0), Position = UDim2.new(0, 56, 0, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0, Text = name,
        TextColor3 = self.Theme.Text, Font = Enum.Font.Gotham, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = row
    })
    local stateLabel
    if isToggle then
        stateLabel = n("TextLabel", {
            Size = UDim2.new(0, 28, 1, 0), Position = UDim2.new(1, -28, 0, 0),
            BackgroundTransparency = 1, BorderSizePixel = 0, Text = "OFF",
            TextColor3 = self.Theme.TextMuted, Font = Enum.Font.GothamBold, TextSize = 10, Parent = row
        })
    end
    local function update()
        local key = getKeyFn()
        local hasKey = key and key ~= Enum.KeyCode.Unknown
        row.Visible = hasKey
        if hasKey then keyBadge.Text = ShortKey(key) end
        if isToggle and stateLabel then
            local on = getValueFn and getValueFn()
            stateLabel.Text = on and "ON" or "OFF"
            stateLabel.TextColor3 = on and self.Theme.Accent or self.Theme.TextMuted
        end
    end
    update()
    row.Parent = container
    table.insert(self.KeybindRows, { update = update, row = row })
    task.defer(function()
        local key = getKeyFn()
        if key and key ~= Enum.KeyCode.Unknown then
            if self.KeybindFrame and not self.KeybindFrame.Visible then
                self.KeybindFrame.Visible = true
                if self._refreshKeybindEmptyHint then self._refreshKeybindEmptyHint() end
                if self.Toggles and self.Toggles["BuiltIn_ShowKeybinds"] then
                    self.Toggles["BuiltIn_ShowKeybinds"].Value = true
                end
            end
        end
    end)
    return update
end

-- ── Game ID lock ─────────────────────────────────────────────────
function Library:SetGameId(gameId)
    local currentId = game.GameId
    local authorized = false
    if type(gameId) == "table" then
        for _, id in ipairs(gameId) do
            if currentId == id then authorized = true break end
        end
    else
        authorized = (currentId == gameId)
    end
    if not authorized then
        Library:Notify({ Title = "Unauthorized Game", Content = "This script won't work on this game.", Duration = 5 })
        return false
    end
    return true
end

-- ── Theme registry ───────────────────────────────────────────────
function Library:RegisterElement(element, themeProperty, targetProperty)
    table.insert(self.Registry, {
        Element = element,
        ThemeProperty = themeProperty,
        TargetProperty = targetProperty or "BackgroundColor3"
    })
end

function Library:UpdateColorsUsingRegistry()
    if self.Theme.Element then
        self.Theme.InputBg     = self.Theme.Element:Lerp(Color3.new(0,0,0), 0.18)
        self.Theme.ElementHover = self.Theme.Element:Lerp(Color3.new(1,1,1), 0.1)
        self.Theme.BorderLight  = self.Theme.Border:Lerp(Color3.new(1,1,1), 0.2)
    end
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

function Library:SetTheme(overrides)
    for k, v in pairs(overrides or {}) do self.Theme[k] = v end
    self:UpdateColorsUsingRegistry()
end

-- ── Config persistence ───────────────────────────────────────────
function Library:SaveConfig(name)
    if not writefile then return end
    name = name or "default"
    local data = {}
    for flag, obj in pairs(self.Toggles) do
        if flag and obj.Value ~= nil then data[flag] = obj.Value end
    end
    for flag, obj in pairs(self.Options) do
        if flag and obj.Value ~= nil then data[flag] = obj.Value end
    end
    local ok, encoded = pcall(function()
        local parts = {}
        for k, v in pairs(data) do
            local vStr
            if type(v) == "boolean" then vStr = tostring(v)
            elseif type(v) == "number" then vStr = tostring(v)
            elseif type(v) == "string" then vStr = '"' .. v:gsub('"', '\\"') .. '"'
            elseif typeof(v) == "Color3" then
                vStr = string.format('{"__c3":[%d,%d,%d]}', math.floor(v.R*255), math.floor(v.G*255), math.floor(v.B*255))
            elseif type(v) == "table" then
                local arr = {}
                for _, item in ipairs(v) do table.insert(arr, '"' .. tostring(item) .. '"') end
                vStr = "[" .. table.concat(arr, ",") .. "]"
            else vStr = '"' .. tostring(v) .. '"'
            end
            table.insert(parts, '"' .. k .. '":' .. vStr)
        end
        return "{" .. table.concat(parts, ",") .. "}"
    end)
    if ok then pcall(writefile, "SeisenConfig_" .. name .. ".json", encoded) end
end

function Library:LoadConfig(name)
    if not readfile then return end
    name = name or "default"
    local path = "SeisenConfig_" .. name .. ".json"
    local ok, raw = pcall(readfile, path)
    if not ok or not raw or raw == "" then return end
    local function parseVal(s)
        s = s:match("^%s*(.-)%s*$")
        if s == "true" then return true end
        if s == "false" then return false end
        local n = tonumber(s)
        if n then return n end
        local c3 = s:match('"__c3":%[(%d+),(%d+),(%d+)%]')
        if c3 then
            local r, g, b = s:match('"__c3":%[(%d+),(%d+),(%d+)%]')
            return Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
        end
        if s:sub(1,1) == "[" then
            local arr = {}
            for item in s:gmatch('"([^"]*)"') do table.insert(arr, item) end
            return arr
        end
        return s:match('^"(.*)"$') or s
    end
    for key, val in raw:gmatch('"([^"]+)":(%b{})') do
        local v = parseVal(val)
        if self.Toggles[key] then pcall(function() self.Toggles[key]:SetValue(v) end)
        elseif self.Options[key] then pcall(function() self.Options[key]:SetValue(v) end) end
    end
    for key, val in raw:gmatch('"([^"]+)":([^,{}%[%]]+)') do
        local v = parseVal(val)
        if self.Toggles[key] then pcall(function() self.Toggles[key]:SetValue(v) end)
        elseif self.Options[key] then pcall(function() self.Options[key]:SetValue(v) end) end
    end
    for key, val in raw:gmatch('"([^"]+)":(%b[])') do
        local v = parseVal(val)
        if self.Options[key] then pcall(function() self.Options[key]:SetValue(v) end) end
    end
end

-- ── Dropdown close-all ───────────────────────────────────────────
function Library:CloseAllDropdowns()
    for _, closeFn in ipairs(self.OpenDropdowns) do
        pcall(closeFn)
    end
    self.OpenDropdowns = {}
end

-- ── Icon helpers ─────────────────────────────────────────────────
function Library:GetIcon(iconName)
    if not iconName or iconName == "" then return nil end
    if type(iconName) == "number" then
        return { Url = "rbxassetid://" .. tostring(iconName), ImageRectOffset = Vector2.zero, ImageRectSize = Vector2.zero, Custom = true }
    end
    if type(iconName) == "string" and iconName:match("^rbxassetid://") then
        return { Url = iconName, ImageRectOffset = Vector2.zero, ImageRectSize = Vector2.zero, Custom = true }
    end
    if self.Icons then
        local ok, icon = pcall(function() return self.Icons.GetAsset(iconName) end)
        if ok and icon and icon.Url and icon.Url ~= "" then return icon end
    end
    return nil
end

function Library:ApplyIcon(element, iconName)
    local iconData = self:GetIcon(iconName)
    if not iconData then element.Image = "" return end
    element.Image = iconData.Url or ""
    element.ImageRectOffset = iconData.ImageRectOffset or Vector2.zero
    element.ImageRectSize   = iconData.ImageRectSize   or Vector2.zero
end

-- ── Core helpers ─────────────────────────────────────────────────
local function Create(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    for _, child in pairs(children or {}) do child.Parent = obj end
    return obj
end

local function Tween(obj, props, duration)
    if not obj then return end
    local tween = TweenService:Create(obj, TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    if tween then tween:Play() end
end

local KEY_SHORT = {
    LeftShift="LSHIFT", RightShift="RSHIFT",
    LeftControl="LCTRL", RightControl="RCTRL",
    LeftAlt="LALT", RightAlt="RALT",
    LeftSuper="LWIN", RightSuper="RWIN",
    Return="ENTER", BackSpace="BKSP",
    CapsLock="CAPS", Space="SPACE",
    Tab="TAB", Delete="DEL", Insert="INS",
    Home="HOME", End="END", PageUp="PGup", PageDown="PGdn",
}
local function ShortKey(key)
    if not key or key == Enum.KeyCode.Unknown then return "NONE" end
    return KEY_SHORT[key.Name] or key.Name:upper():sub(1, 7)
end

-- ── Notifications ────────────────────────────────────────────────
-- Charcoal card with a top accent bar and coloured stroke.
function Library:Notify(notifyOpts)
    local nTitle    = notifyOpts.Title    or "Notification"
    local nContent  = notifyOpts.Content  or ""
    local nDuration = notifyOpts.Duration or 3
    local nImage    = notifyOpts.Image
    local nType     = notifyOpts.Type or "info"
    local theme     = self.Theme

    local typeColor = notifyOpts.Color or (
        nType == "success" and theme.Success or
        nType == "warning" and theme.Warning or
        nType == "error"   and theme.Error   or
        theme.Info
    )
    if not nImage then
        nImage = nType == "success" and "check-circle"
            or nType == "warning"   and "alert-triangle"
            or nType == "error"     and "x-circle"
            or "info"
    end

    -- Build container once
    if not self.NotificationContainer then
        local guiParent = RunService:IsStudio() and LocalPlayer.PlayerGui or game.CoreGui
        local sg = Instance.new("ScreenGui")
        sg.Name = "SeisenNotify"; sg.ResetOnSpawn = false
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.DisplayOrder = 10; sg.Parent = guiParent
        self.NotificationContainer = Create("Frame", {
            Name = "NotificationContainer",
            Size = UDim2.new(0, 310, 1, 0),
            Position = UDim2.new(1, -326, 0, 0),
            BackgroundTransparency = 1,
            ClipsDescendants = false,
            Parent = sg, ZIndex = 500
        }, {
            Create("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
            }),
            Create("UIPadding", { PaddingBottom = UDim.new(0, 18) })
        })
    end

    local slot = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        BorderSizePixel = 0,
        Parent = self.NotificationContainer,
    })

    -- Charcoal card — coloured stroke, 12px corner, slides from right
    local card = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.Element,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, 22, 0, 0),
        ClipsDescendants = false,
        BorderSizePixel = 0,
        Parent = slot, ZIndex = 500,
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
        Create("UIStroke",  { Color = typeColor, Thickness = 1, Transparency = 0.55 }),
        Create("UIPadding", {
            PaddingTop = UDim.new(0, 11), PaddingBottom = UDim.new(0, 13),
            PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 10),
        }),
    })

    -- Top accent bar (horizontal strip, different from original vertical stripe)
    local stripe = Create("Frame", {
        Size = UDim2.new(0.42, 0, 0, 2),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundColor3 = typeColor,
        BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 501,
        Parent = card,
    }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

    local icon = Create("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 0, 0, 2),
        BackgroundTransparency = 1,
        ImageColor3 = typeColor, ImageTransparency = 1,
        ZIndex = 501, Parent = card,
    })
    self:ApplyIcon(icon, nImage)

    local titleLbl = Create("TextLabel", {
        Size = UDim2.new(1, -44, 0, 18),
        Position = UDim2.new(0, 22, 0, 0),
        BackgroundTransparency = 1,
        Text = nTitle, TextColor3 = theme.Text, TextTransparency = 1,
        Font = Enum.Font.GothamBold, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 501, Parent = card,
    })

    local closeBtn = Create("TextButton", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -16, 0, 1),
        BackgroundTransparency = 1,
        Text = "X", TextColor3 = theme.TextMuted, TextTransparency = 1,
        Font = Enum.Font.GothamBold, TextSize = 9,
        AutoButtonColor = false, ZIndex = 502, Parent = card,
    })
    closeBtn.MouseEnter:Connect(function() Tween(closeBtn, { TextColor3 = theme.Text }) end)
    closeBtn.MouseLeave:Connect(function() Tween(closeBtn, { TextColor3 = theme.TextMuted }) end)

    local contentLbl = Create("TextLabel", {
        Size = UDim2.new(1, -22, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 22, 0, 21),
        BackgroundTransparency = 1,
        Text = nContent, TextColor3 = theme.TextDim, TextTransparency = 1,
        Font = Enum.Font.Gotham, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
        ZIndex = 501, Parent = card,
    })

    local barBg = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, 8),
        BackgroundColor3 = theme.Border, BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 501, Parent = card,
    }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

    local bar = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = typeColor, BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 501, Parent = barBg,
    }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

    local dismissed = false
    local function dismiss()
        if dismissed then return end
        dismissed = true
        Tween(card,       { BackgroundTransparency = 1, Position = UDim2.new(1, 22, 0, 0) }, 0.28)
        Tween(stripe,     { BackgroundTransparency = 1 }, 0.18)
        Tween(titleLbl,   { TextTransparency = 1 }, 0.18)
        Tween(contentLbl, { TextTransparency = 1 }, 0.18)
        Tween(icon,       { ImageTransparency = 1 }, 0.18)
        Tween(closeBtn,   { TextTransparency = 1 }, 0.18)
        Tween(barBg,      { BackgroundTransparency = 1 }, 0.18)
        Tween(bar,        { BackgroundTransparency = 1 }, 0.18)
        task.delay(0.32, function() slot:Destroy() end)
    end
    closeBtn.MouseButton1Click:Connect(dismiss)

    Tween(card,       { BackgroundTransparency = 0.05, Position = UDim2.new(0, 0, 0, 0) }, 0.3)
    Tween(stripe,     { BackgroundTransparency = 0.15 }, 0.3)
    Tween(titleLbl,   { TextTransparency = 0 }, 0.3)
    Tween(contentLbl, { TextTransparency = 0.08 }, 0.3)
    Tween(icon,       { ImageTransparency = 0 }, 0.3)
    Tween(closeBtn,   { TextTransparency = 0.45 }, 0.3)
    Tween(barBg,      { BackgroundTransparency = 0.45 }, 0.3)
    Tween(bar,        { BackgroundTransparency = 0 }, nDuration)

    task.delay(nDuration, dismiss)
end

-- ── Drag helper ──────────────────────────────────────────────────
local function MakeDraggable(handle, frame, onClick)
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local dragging = true
            local dragStart = input.Position
            local startPos  = frame.Position
            local hasMoved  = false
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
                    inputChanged:Disconnect(); inputEnded:Disconnect()
                    if onClick and not hasMoved then onClick() end
                end
            end)
        end
    end)
end

-- ── Tooltip ───────────────────────────────────────────────────────
local TooltipFrame, TooltipLabel, TooltipConnection
Library.TooltipThread = nil

function Library:CreateTooltipFrame()
    if not self.ScreenGui or TooltipFrame then return end
    TooltipFrame = Create("Frame", {
        Name = "Tooltip", Size = UDim2.new(0, 200, 0, 30),
        BackgroundColor3 = self.Theme.Element, BorderSizePixel = 0,
        Visible = false, ZIndex = 1000, Parent = self.ScreenGui
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("UIStroke",  { Color = self.Theme.Border, Thickness = 1 }),
        Create("UIPadding", { PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 9), PaddingTop = UDim.new(0, 7), PaddingBottom = UDim.new(0, 7) })
    })
    TooltipLabel = Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "",
        TextColor3 = self.Theme.TextDim, Font = Enum.Font.Gotham, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true, Parent = TooltipFrame
    })
    TooltipConnection = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and TooltipFrame.Visible then
            local m = UserInputService:GetMouseLocation()
            TooltipFrame.Position = UDim2.fromOffset(m.X + 15, m.Y + 10)
        end
    end)
end

function Library:ShowTooltip(text)
    if not TooltipFrame then self:CreateTooltipFrame() end
    if not TooltipFrame or not text or text == "" then return end
    TooltipLabel.Text = text
    local ts = game:GetService("TextService"):GetTextSize(text, 11, Enum.Font.Gotham, Vector2.new(280, 1000))
    TooltipFrame.Size = UDim2.new(0, math.min(ts.X + 24, 300), 0, ts.Y + 20)
    TooltipFrame.Visible = true
    local m = UserInputService:GetMouseLocation()
    TooltipFrame.Position = UDim2.fromOffset(m.X + 15, m.Y + 10)
end

function Library:HideTooltip()
    if self.TooltipThread then task.cancel(self.TooltipThread) self.TooltipThread = nil end
    if TooltipFrame then TooltipFrame.Visible = false end
end

-- ── Common properties ────────────────────────────────────────────
function Library:ApplyCommonProperties(element, options, elementObj)
    local tooltip         = options.Tooltip
    local disabledTooltip = options.DisabledTooltip
    local isDisabled      = options.Disabled or false
    local isVisible       = options.Visible ~= false
    elementObj._disabled  = isDisabled
    elementObj._visible   = isVisible
    elementObj._tooltip   = tooltip
    elementObj._disabledTooltip = disabledTooltip
    element.Visible = isVisible
    if isDisabled then
        element.BackgroundTransparency = 0.6
        for _, child in pairs(element:GetDescendants()) do
            if child:IsA("TextLabel") then child.TextTransparency = 0.5
            elseif child:IsA("TextButton") or child:IsA("ImageButton") then child.Active = false end
        end
    end
    if tooltip or disabledTooltip then
        element.MouseEnter:Connect(function()
            local tip = elementObj._disabled and elementObj._disabledTooltip or elementObj._tooltip
            if not tip then return end
            if Library.TooltipThread then task.cancel(Library.TooltipThread) end
            Library.TooltipThread = task.delay(0.2, function() Library:ShowTooltip(tip) end)
        end)
        element.MouseLeave:Connect(function() Library:HideTooltip() end)
    end
    function elementObj:SetVisible(v) self._visible = v; element.Visible = v end
    function elementObj:SetDisabled(d)
        self._disabled = d
        element.BackgroundTransparency = d and 0.6 or 0
        for _, child in pairs(element:GetDescendants()) do
            if child:IsA("TextLabel") then child.TextTransparency = d and 0.5 or 0
            elseif child:IsA("TextButton") or child:IsA("ImageButton") then child.Active = not d end
        end
    end
    function elementObj:SetTooltip(t) self._tooltip = t end
    return elementObj
end

-- ── Label ─────────────────────────────────────────────────────────
function Library:CreateLabel(parent, options)
    local text = options.Text or options.Name or "Label"
    local flag = options.Flag
    local label = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, options.Height or 16),
        BackgroundTransparency = 1,
        Text = text, TextColor3 = self.Theme.TextDim,
        Font = Enum.Font.Gotham, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextWrapped = options.TextWrapped, Parent = parent
    })
    self:RegisterElement(label, "TextDim", "TextColor3")
    local labelObj = { SetText = function(s, t) label.Text = t end, Instance = label }
    if flag then self.Labels = self.Labels or {}; self.Labels[flag] = labelObj end
    return labelObj
end

-- ── Button ────────────────────────────────────────────────────────
-- Charcoal default, AccentDark bg + Accent stroke on hover (full fill, no strip)
function Library:CreateButton(parent, options)
    local btnName    = options.Name or "Button"
    local callback   = options.Callback or function() end
    local doubleClick = options.DoubleClick or false
    local confirmText = options.ConfirmText
    local isRisky    = options.Risky or false
    local riskyColor = Color3.fromRGB(232, 82, 82)

    local btn = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = self.Theme.InputBg,
        Text = btnName,
        TextColor3 = isRisky and riskyColor or self.Theme.TextDim,
        Font = Enum.Font.GothamMedium, TextSize = 12,
        AutoButtonColor = false, ClipsDescendants = true,
        Parent = parent
    }, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })

    local btnStroke
    if not isRisky then
        btnStroke = Instance.new("UIStroke")
        btnStroke.Color     = self.Theme.Border
        btnStroke.Thickness = 1
        btnStroke.Parent    = btn
    end

    self:RegisterElement(btn, "InputBg")
    if not isRisky then
        self:RegisterElement(btnStroke, "Border", "Color")
        table.insert(self.Registry, { Callback = function(t)
            if btn and btn.Parent then btn.TextColor3 = t.TextDim end
        end })
    end

    local lastClick = 0; local waitingConfirm = false
    btn.MouseEnter:Connect(function()
        if isRisky then
            Tween(btn, { BackgroundColor3 = Color3.fromRGB(72, 22, 22), TextColor3 = riskyColor })
        else
            Tween(btn, { BackgroundColor3 = self.Theme.AccentDark, TextColor3 = self.Theme.Text })
            Tween(btnStroke, { Color = self.Theme.Accent })
        end
    end)
    btn.MouseLeave:Connect(function()
        if isRisky then
            Tween(btn, { BackgroundColor3 = self.Theme.InputBg, TextColor3 = riskyColor })
        else
            Tween(btn, { BackgroundColor3 = self.Theme.InputBg, TextColor3 = self.Theme.TextDim })
            Tween(btnStroke, { Color = self.Theme.Border })
        end
        if waitingConfirm then waitingConfirm = false; btn.Text = btnName end
    end)

    local function flashClick()
        -- Background flash — no child Frames so AutomaticSize parents never expand
        local flash = isRisky and Color3.fromRGB(90, 28, 28) or self.Theme.BorderLight
        local rest  = isRisky and Color3.fromRGB(72, 22, 22)  or self.Theme.InputBg
        Tween(btn, { BackgroundColor3 = flash }, 0.05)
        task.delay(0.07, function() if btn and btn.Parent then Tween(btn, { BackgroundColor3 = rest }, 0.2) end end)
    end

    btn.MouseButton1Click:Connect(function()
        local btnObj = self.Options[options.Flag]
        if btnObj and btnObj._disabled then return end
        flashClick()
        if confirmText and not waitingConfirm then
            waitingConfirm = true; btn.Text = confirmText; return
        end
        waitingConfirm = false; btn.Text = btnName
        if doubleClick then
            local now = tick()
            if now - lastClick < 0.4 then callback(); lastClick = 0
            else lastClick = now end
        else callback() end
    end)

    local btnObj = { Instance = btn, Type = "Button" }
    self:ApplyCommonProperties(btn, options, btnObj)
    if options.Flag then self.Options[options.Flag] = btnObj end
    return btnObj
end

-- ── Toggle ────────────────────────────────────────────────────────
-- 40×20 pill switch, 14×14 knob — slimmer than original 42×22
function Library:CreateToggle(parent, options)
    local toggleName = options.Name or "Toggle"
    local default    = options.Default or false
    local callback   = options.Callback or function() end
    local flag       = options.Flag
    local state      = default
    local keybind    = options.Keybind or Enum.KeyCode.Unknown
    local hasKeybind = options.Keybind ~= nil

    local toggle = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Parent = parent
    })
    local toggleLabel = Create("TextLabel", {
        Size = self.IsMobile and UDim2.new(1, -48, 1, 0) or UDim2.new(1, -112, 1, 0),
        BackgroundTransparency = 1, Text = toggleName,
        TextColor3 = self.Theme.Text, Font = Enum.Font.Gotham, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = toggle
    })
    self:RegisterElement(toggleLabel, "Text", "TextColor3")

    -- 40×20 switch
    local switchBg = Create("Frame", {
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -40, 0.5, -10),
        BackgroundColor3 = state and self.Theme.Toggle or self.Theme.ToggleOff,
        BorderSizePixel = 0, Parent = toggle
    }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

    -- 14×14 knob
    local knob = Create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0, Parent = switchBg
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Create("UIStroke", { Color = Color3.new(0,0,0), Transparency = 0.88, Thickness = 1 })
    })

    -- Keybind badge — accent text, InputBg bg
    local keybindStroke = Create("UIStroke", { Color = self.Theme.Border, Thickness = 1 })
    local keybindBtn = Create("TextButton", {
        Size = UDim2.new(0, 38, 0, 16),
        Position = UDim2.new(1, -100, 0.5, -8),
        BackgroundColor3 = self.Theme.InputBg,
        Text = ShortKey(keybind),
        TextColor3 = self.Theme.Accent, Font = Enum.Font.GothamBold, TextSize = 9,
        AutoButtonColor = false,
        Visible = hasKeybind and (not self.IsMobile),
        ZIndex = 2, Parent = toggle
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 5) }),
        keybindStroke
    })

    -- clearBtn positioned at top-right of keybindBtn
    local clearBtn = Create("TextButton", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(1, -69, 0.5, -15),
        BackgroundColor3 = Color3.fromRGB(180, 50, 50),
        Text = "", AutoButtonColor = false, ZIndex = 4,
        Visible = hasKeybind and (not self.IsMobile) and (keybind ~= Enum.KeyCode.Unknown),
        Parent = toggle
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, -1),
            BackgroundTransparency = 1,
            Text = "x", TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold, TextSize = 8,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 5
        })
    })

    if hasKeybind then
        self:RegisterElement(keybindBtn, "InputBg")
        self:RegisterElement(keybindStroke, "Border", "Color")
    end
    table.insert(self.Registry, { Callback = function(t)
        Tween(switchBg, { BackgroundColor3 = state and t.Toggle or t.ToggleOff })
    end })

    local function updateClearBtn()
        clearBtn.Visible = hasKeybind and (not self.IsMobile) and (keybind ~= Enum.KeyCode.Unknown)
    end

    local toggleObj = {
        Value = state, Keybind = keybind, Type = "Toggle",
        SetValue = function(s, val)
            state = val; s.Value = val
            Tween(switchBg, { BackgroundColor3 = val and self.Theme.Toggle or self.Theme.ToggleOff })
            Tween(knob, { Position = val and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7) })
            callback(val)
            if s._kbUpdate then pcall(s._kbUpdate) end
        end,
        SetKeybind = function(s, key)
            if not hasKeybind then return end
            keybind = key or Enum.KeyCode.Unknown; s.Keybind = keybind
            keybindBtn.Text = ShortKey(keybind)
            updateClearBtn()
            if s._kbUpdate then pcall(s._kbUpdate) end
            if self._refreshKeybindEmptyHint then self._refreshKeybindEmptyHint() end
        end,
    }

    local switchBtn = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = toggle
    })
    switchBtn.MouseButton1Click:Connect(function() toggleObj:SetValue(not state) end)

    if hasKeybind then
        local listening = false
        keybindBtn.MouseButton1Click:Connect(function() listening = true; keybindBtn.Text = "..." end)
        clearBtn.MouseButton1Click:Connect(function()
            listening = false; keybind = Enum.KeyCode.Unknown
            toggleObj.Keybind = Enum.KeyCode.Unknown; keybindBtn.Text = "NONE"; updateClearBtn()
            if toggleObj._kbUpdate then pcall(toggleObj._kbUpdate) end
            if self._refreshKeybindEmptyHint then self._refreshKeybindEmptyHint() end
        end)

        local _kbConn = UserInputService.InputBegan:Connect(function(input, processed)
            if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                if input.KeyCode == Enum.KeyCode.Backspace then
                    keybind = Enum.KeyCode.Unknown; toggleObj.Keybind = Enum.KeyCode.Unknown
                    keybindBtn.Text = "NONE"
                else
                    keybind = input.KeyCode; toggleObj.Keybind = input.KeyCode
                    keybindBtn.Text = ShortKey(input.KeyCode)
                end
                updateClearBtn()
                if toggleObj._kbUpdate then pcall(toggleObj._kbUpdate) end
                if self._refreshKeybindEmptyHint then self._refreshKeybindEmptyHint() end
            elseif keybind ~= Enum.KeyCode.Unknown and input.KeyCode == keybind and not processed then
                if not toggleObj._disabled then toggleObj:SetValue(not state) end
            end
        end)
        table.insert(self.KeybindConnections, _kbConn)
    end

    self:ApplyCommonProperties(toggle, options, toggleObj)
    if flag then self.Toggles[flag] = toggleObj end

    if hasKeybind then
        local kbUpdate = self:RegisterKeybindRow(toggleName or flag,
            function() return toggleObj.Keybind end, true, function() return toggleObj.Value end)
        toggleObj._kbUpdate = kbUpdate
    end
    if self._refreshKeybindEmptyHint then self._refreshKeybindEmptyHint() end
    if default then callback(true) end
    return toggleObj
end

-- ── Slider ────────────────────────────────────────────────────────
-- 32px frame, 6px track, 14×14 knob, accent-coloured value label
function Library:CreateSlider(parent, options)
    local sliderName = options.Name or "Slider"
    local min        = options.Min or 0
    local max        = options.Max or 100
    local default    = options.Default or min
    local callback   = options.Callback or function() end
    local flag       = options.Flag
    local increment  = options.Increment or 1
    local suffix     = options.Suffix or ""
    local prefix     = options.Prefix or ""
    local value      = default

    local slider = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Parent = parent
    })
    Create("TextLabel", {
        Size = UDim2.new(1, -52, 0, 16), BackgroundTransparency = 1,
        Text = sliderName, TextColor3 = self.Theme.Text,
        Font = Enum.Font.Gotham, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = slider
    })
    local function fmtVal(v) return prefix .. tostring(v) .. suffix end
    local valLabel = Create("TextLabel", {
        Size = UDim2.new(0, 52, 0, 16), Position = UDim2.new(1, -52, 0, 0),
        BackgroundTransparency = 1, Text = fmtVal(value),
        TextColor3 = self.Theme.Accent, Font = Enum.Font.GothamBold, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right, Parent = slider
    })

    -- 6px track
    local bar = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0, 20),
        BackgroundColor3 = self.Theme.ToggleOff, Text = "", AutoButtonColor = false, Parent = slider
    }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

    local fill = Create("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = self.Theme.Accent, BorderSizePixel = 0, Parent = bar
    }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

    -- 14×14 knob with accent stroke
    local knob = Create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0, ZIndex = 2, Parent = bar
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Create("UIStroke", { Color = self.Theme.Accent, Transparency = 0.45, Thickness = 1.5 })
    })

    -- Floating drag tooltip
    local dragTip = Create("Frame", {
        Size = UDim2.new(0, 50, 0, 20),
        Position = UDim2.new((default - min) / (max - min), 0, 0, -26),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = self.Theme.Element,
        BorderSizePixel = 0, Visible = false, ZIndex = 10, Parent = bar,
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Create("UIStroke", { Color = self.Theme.Accent, Thickness = 1, Transparency = 0.5 }),
    })
    local dragTipLabel = Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Text = fmtVal(value), TextColor3 = self.Theme.Accent,
        Font = Enum.Font.GothamBold, TextSize = 10, Parent = dragTip,
    })

    self:RegisterElement(bar, "ToggleOff")
    self:RegisterElement(fill, "Accent")

    local sliderObj = {
        Value = value, Type = "Slider",
        SetValue = function(s, val)
            val = math.clamp(math.floor(val / increment + 0.5) * increment, min, max)
            value = val; s.Value = val
            local pct = (val - min) / (max - min)
            valLabel.Text = fmtVal(val)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            knob.Position = UDim2.new(pct, 0, 0.5, 0)
            callback(val)
        end
    }

    local sliding = false
    bar.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 and i.UserInputType ~= Enum.UserInputType.Touch then return end
        if sliderObj._disabled then return end
        sliding = true; dragTip.Visible = true
        local function applyX(x)
            local pct = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local newVal = math.floor((min + (max - min) * pct) / increment + 0.5) * increment
            value = newVal; sliderObj.Value = newVal
            valLabel.Text = fmtVal(newVal); dragTipLabel.Text = fmtVal(newVal)
            dragTip.Position = UDim2.new(pct, 0, 0, -26)
            fill.Size = UDim2.new(pct, 0, 1, 0); knob.Position = UDim2.new(pct, 0, 0.5, 0)
            callback(newVal)
        end
        applyX(i.Position.X)
        local startX = i.Position.X; local lastX = startX; local startVal = value
        local moveConn = UserInputService.InputChanged:Connect(function(mi)
            if mi.UserInputType == Enum.UserInputType.MouseMovement or mi.UserInputType == Enum.UserInputType.Touch then
                lastX = mi.Position.X
            end
        end)
        local rsConn = RunService.RenderStepped:Connect(function()
            if not sliding then return end
            local delta = lastX - startX
            local newVal = math.clamp(
                math.floor((startVal + (delta / bar.AbsoluteSize.X) * (max - min)) / increment + 0.5) * increment,
                min, max)
            if newVal ~= value then
                value = newVal; sliderObj.Value = newVal
                local pct = (newVal - min) / (max - min)
                valLabel.Text = fmtVal(newVal); dragTipLabel.Text = fmtVal(newVal)
                dragTip.Position = UDim2.new(pct, 0, 0, -26)
                fill.Size = UDim2.new(pct, 0, 1, 0); knob.Position = UDim2.new(pct, 0, 0.5, 0)
                callback(newVal)
            end
        end)
        local relConn
        relConn = UserInputService.InputEnded:Connect(function(ri)
            if ri.UserInputType == Enum.UserInputType.MouseButton1 or ri.UserInputType == Enum.UserInputType.Touch then
                sliding = false; dragTip.Visible = false
                rsConn:Disconnect(); moveConn:Disconnect(); relConn:Disconnect()
            end
        end)
    end)

    self:ApplyCommonProperties(slider, options, sliderObj)
    if flag then self.Options[flag] = sliderObj end
    return sliderObj
end

-- ── Keybind ───────────────────────────────────────────────────────
function Library:CreateKeybind(parent, options)
    local keybindName = options.Name or "Keybind"
    local default     = options.Default or Enum.KeyCode.Unknown
    local callback    = options.Callback or function() end
    local flag        = options.Flag
    local currentKey  = default

    local keybind = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = parent
    })
    local nameLabel = Create("TextLabel", {
        Size = UDim2.new(0.5, -5, 1, 0), BackgroundTransparency = 1,
        Text = keybindName, TextColor3 = self.Theme.Text,
        Font = Enum.Font.Gotham, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = keybind
    })
    local keyButton = Create("TextButton", {
        Size = UDim2.new(0.5, -5, 0, 26),
        Position = UDim2.new(0.5, 5, 0.5, -13),
        BackgroundColor3 = self.Theme.InputBg,
        Text = ShortKey(currentKey),
        TextColor3 = self.Theme.Accent, Font = Enum.Font.GothamBold, TextSize = 11,
        Parent = keybind
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
    })
    self:RegisterElement(nameLabel,  "Text",  "TextColor3")
    self:RegisterElement(keyButton,  "InputBg")
    self:RegisterElement(keyButton,  "Accent", "TextColor3")

    local clearBtn = Create("TextButton", {
        Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -20, 0.5, -10),
        BackgroundColor3 = Color3.fromRGB(180, 50, 50), Text = "X",
        TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.GothamBold, TextSize = 9,
        AutoButtonColor = false, ZIndex = 3,
        Visible = (currentKey ~= Enum.KeyCode.Unknown), Parent = keybind
    }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

    local function updateClearBtn() clearBtn.Visible = (currentKey ~= Enum.KeyCode.Unknown) end

    local function updateKeybindClearBtn() clearBtn.Visible = (currentKey ~= Enum.KeyCode.Unknown) end

    local keybindObj = {
        Value = currentKey, Type = "Keybind",
        SetValue = function(s, key)
            currentKey = key; s.Value = key
            keyButton.Text = ShortKey(key)
            updateKeybindClearBtn()
            callback(key)
        end
    }


    local listening = false
    keyButton.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true; keyButton.Text = "..."; keyButton.TextColor3 = self.Theme.Accent
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, processed)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                conn:Disconnect(); listening = false
                local newKey = input.KeyCode
                if newKey == Enum.KeyCode.Escape or newKey == Enum.KeyCode.Backspace then
                    newKey = Enum.KeyCode.Unknown
                end
                keybindObj:SetValue(newKey)
                keyButton.TextColor3 = self.Theme.Accent
            end
        end)
    end)
    clearBtn.MouseButton1Click:Connect(function()
        keybindObj:SetValue(Enum.KeyCode.Unknown)
    end)

    self:ApplyCommonProperties(keybind, options, keybindObj)
    if flag then self.Options[flag] = keybindObj end
    return keybindObj
end

-- ── Dropdown ──────────────────────────────────────────────────────
-- Charcoal: InputBg field, Border stroke, opens downward with scroll
function Library:CreateDropdown(parent, options)
    local dropName   = options.Name or "Dropdown"
    local items      = options.Options or options.Items or {}
    local default    = options.Default
    local callback   = options.Callback or function() end
    local flag       = options.Flag
    local isMulti    = options.Multi or false
    local maxVisible = options.MaxVisible or 6

    local value      = isMulti and {} or (default or (items[1] or nil))
    if isMulti and default then
        if type(default) == "table" then value = default
        else value = { default } end
    end

    local ITEM_H  = 26
    local DROP_H  = 32

    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, DROP_H + 4),
        BackgroundTransparency = 1, ClipsDescendants = false, Parent = parent
    })

    local field = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, DROP_H),
        BackgroundColor3 = self.Theme.InputBg,
        Text = "", AutoButtonColor = false, ClipsDescendants = false, Parent = container
    }, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })

    local fieldStroke = Instance.new("UIStroke")
    fieldStroke.Color = self.Theme.Border; fieldStroke.Thickness = 1; fieldStroke.Parent = field
    self:RegisterElement(field, "InputBg"); self:RegisterElement(fieldStroke, "Border", "Color")

    local fieldLabel = Create("TextLabel", {
        Size = UDim2.new(1, -28, 1, 0), Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1, Text = "",
        TextColor3 = self.Theme.Text, Font = Enum.Font.Gotham, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = field
    })
    self:RegisterElement(fieldLabel, "Text", "TextColor3")

    local chevron = Create("ImageLabel", {
        Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -22, 0.5, -7),
        BackgroundTransparency = 1, ImageColor3 = self.Theme.TextDim, ZIndex = 2, Parent = field
    })
    self:ApplyIcon(chevron, "chevron-down")
    self:RegisterElement(chevron, "TextDim", "ImageColor3")

    local nameLabel = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 0, DROP_H + 1),
        BackgroundTransparency = 1, Text = dropName,
        TextColor3 = self.Theme.TextDim, Font = Enum.Font.Gotham, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = container
    })
    self:RegisterElement(nameLabel, "TextDim", "TextColor3")
    container.Size = UDim2.new(1, 0, 0, DROP_H + 18)

    -- Panel
    local panelHeight = math.min(#items, maxVisible) * ITEM_H + 8
    local panel = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, panelHeight),
        Position = UDim2.new(0, 0, 0, DROP_H + 2),
        BackgroundColor3 = self.Theme.Element,
        BorderSizePixel = 0, ScrollBarThickness = 3,
        ScrollBarImageColor3 = self.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, #items * ITEM_H + 4),
        Visible = false, ZIndex = 50, Parent = container
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("UIStroke", { Color = self.Theme.Border, Thickness = 1 }),
        Create("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 6) }),
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) })
    })
    self:RegisterElement(panel, "Element")

    local function getDisplayText()
        if isMulti then
            local keys = {}; for k in pairs(value) do table.insert(keys, k) end
            return #keys == 0 and "None" or table.concat(keys, ", ")
        else return value or "None" end
    end
    fieldLabel.Text = getDisplayText()

    local itemButtons = {}
    local function rebuildItems(list)
        for _, b in pairs(itemButtons) do b:Destroy() end; itemButtons = {}
        panel.CanvasSize = UDim2.new(0, 0, 0, #list * ITEM_H + 4)
        local newH = math.min(#list, maxVisible) * ITEM_H + 8
        panel.Size = UDim2.new(1, 0, 0, newH)
        for i, item in ipairs(list) do
            local isSelected = isMulti and (value[item] == true) or (value == item)
            local btn = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, ITEM_H - 2),
                BackgroundColor3 = isSelected and self.Theme.AccentDark or self.Theme.Element,
                Text = "", AutoButtonColor = false, LayoutOrder = i, ZIndex = 52, Parent = panel
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                Create("TextLabel", {
                    Size = UDim2.new(1, isMulti and -26 or -10, 1, 0), Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1, Text = tostring(item),
                    TextColor3 = isSelected and self.Theme.Accent or self.Theme.Text,
                    Font = Enum.Font.Gotham, TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 53
                })
            })
            if isMulti then
                Create("Frame", {
                    Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -20, 0.5, -7),
                    BackgroundColor3 = isSelected and self.Theme.Accent or self.Theme.InputBg,
                    ZIndex = 53, Parent = btn
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    Create("UIStroke", { Color = self.Theme.Border, Thickness = 1 }),
                    (isSelected and Create("TextLabel", {
                        Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
                        Text = "✓", TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 10, ZIndex = 54
                    }) or nil)
                })
            end
            btn.MouseEnter:Connect(function()
                if not (isMulti and value[item]) and value ~= item then
                    Tween(btn, { BackgroundColor3 = self.Theme.ElementHover })
                end
            end)
            btn.MouseLeave:Connect(function()
                Tween(btn, { BackgroundColor3 = (isMulti and value[item]) or (value == item) and self.Theme.AccentDark or self.Theme.Element })
            end)
            btn.MouseButton1Click:Connect(function()
                if isMulti then
                    if value[item] then value[item] = nil else value[item] = true end
                else value = item end
                fieldLabel.Text = getDisplayText()
                rebuildItems(list)
                callback(value)
            end)
            table.insert(itemButtons, btn)
        end
    end
    rebuildItems(items)

    local isOpen = false
    local function openPanel()
        isOpen = true
        if self._mainWindow then
            panel.Parent = self._mainWindow
            local scale = self._windowScale and self._windowScale.Scale or 1
            panel.Position = UDim2.fromOffset(
                (field.AbsolutePosition.X - self._mainWindow.AbsolutePosition.X) / scale,
                (field.AbsolutePosition.Y - self._mainWindow.AbsolutePosition.Y) / scale + DROP_H + 2
            )
            panel.Size = UDim2.new(0, field.AbsoluteSize.X / scale, 0, panelHeight)
        end
        panel.Visible = true
        Tween(chevron, { ImageColor3 = self.Theme.Accent })
        Tween(fieldStroke, { Color = self.Theme.Accent })
        table.insert(self.OpenDropdowns, function()
            if isOpen then
                isOpen = false
                panel.Visible = false
                panel.Parent = container
                panel.Position = UDim2.new(0, 0, 0, DROP_H + 2)
                panel.Size = UDim2.new(1, 0, 0, panelHeight)
                Tween(chevron, { ImageColor3 = self.Theme.TextDim })
                Tween(fieldStroke, { Color = self.Theme.Border })
            end
        end)
    end
    local function closePanel()
        isOpen = false
        panel.Visible = false
        panel.Parent = container
        panel.Position = UDim2.new(0, 0, 0, DROP_H + 2)
        panel.Size = UDim2.new(1, 0, 0, panelHeight)
        Tween(chevron, { ImageColor3 = self.Theme.TextDim })
        Tween(fieldStroke, { Color = self.Theme.Border })
    end

    field.MouseButton1Click:Connect(function()
        local wasOpen = isOpen
        self:CloseAllDropdowns()
        if not wasOpen then openPanel() end
    end)

    local dropObj = {
        Value = isMulti and value or value, Type = "Dropdown", Multi = isMulti,
        SetValue = function(s, val)
            if isMulti then
                value = {}
                if type(val) == "table" then for k, v in pairs(val) do if v then value[k] = true end end end
            else value = val end
            s.Value = value; fieldLabel.Text = getDisplayText(); rebuildItems(items); callback(value)
        end,
        Refresh = function(s, newList, reset)
            items = newList; if reset then value = isMulti and {} or nil end
            s.Value = value; fieldLabel.Text = getDisplayText(); rebuildItems(newList)
        end,
    }

    self:ApplyCommonProperties(container, options, dropObj)
    if flag then self.Options[flag] = dropObj end
    return dropObj
end

-- ── Textbox ───────────────────────────────────────────────────────
function Library:CreateTextbox(parent, options)
    local boxName    = options.Name or "Textbox"
    local placeholder = options.Placeholder or ""
    local default    = options.Default or ""
    local callback   = options.Callback or function() end
    local flag       = options.Flag
    local clearOnFocus = options.ClearTextOnFocus ~= false

    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1, Parent = parent
    })
    Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1,
        Text = boxName, TextColor3 = self.Theme.TextDim,
        Font = Enum.Font.Gotham, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = container
    })
    local field = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 0, 16),
        BackgroundColor3 = self.Theme.InputBg, Parent = container
    }, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })

    local fieldStroke = Instance.new("UIStroke")
    fieldStroke.Color = self.Theme.Border; fieldStroke.Thickness = 1; fieldStroke.Parent = field
    self:RegisterElement(field, "InputBg"); self:RegisterElement(fieldStroke, "Border", "Color")

    local textbox = Create("TextBox", {
        Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1, Text = default,
        PlaceholderText = placeholder, PlaceholderColor3 = self.Theme.TextMuted,
        TextColor3 = self.Theme.Text, Font = Enum.Font.Gotham, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = clearOnFocus,
        Parent = field
    })
    self:RegisterElement(textbox, "Text", "TextColor3")

    textbox.Focused:Connect(function() Tween(fieldStroke, { Color = self.Theme.Accent }) end)
    textbox.FocusLost:Connect(function()
        Tween(fieldStroke, { Color = self.Theme.Border })
        callback(textbox.Text)
    end)

    local boxObj = {
        Value = textbox.Text, Type = "Input",
        SetValue = function(s, v) textbox.Text = v; s.Value = v; callback(v) end
    }
    textbox:GetPropertyChangedSignal("Text"):Connect(function() boxObj.Value = textbox.Text end)

    self:ApplyCommonProperties(container, options, boxObj)
    if flag then self.Options[flag] = boxObj end
    return boxObj
end

-- ── Checkbox ──────────────────────────────────────────────────────
-- Distinct from Toggle — square box with a checkmark, no switch
function Library:CreateCheckbox(parent, options)
    local cbName  = options.Name or "Checkbox"
    local default = options.Default or false
    local callback = options.Callback or function() end
    local flag    = options.Flag
    local state   = default

    local row = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1,
        Text = "", AutoButtonColor = false, Parent = parent
    })

    local box = Create("Frame", {
        Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 0, 0.5, -8),
        BackgroundColor3 = state and self.Theme.Accent or self.Theme.InputBg,
        BorderSizePixel = 0, Parent = row
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        Create("UIStroke", { Color = state and self.Theme.Accent or self.Theme.Border, Thickness = 1 })
    })
    local checkMark = Create("TextLabel", {
        Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
        Text = state and "✓" or "", TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold, TextSize = 11, Parent = box
    })
    local label = Create("TextLabel", {
        Size = UDim2.new(1, -24, 1, 0), Position = UDim2.new(0, 24, 0, 0),
        BackgroundTransparency = 1, Text = cbName,
        TextColor3 = self.Theme.Text, Font = Enum.Font.Gotham, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row
    })
    self:RegisterElement(label, "Text", "TextColor3")
    local boxStroke = box:FindFirstChildWhichIsA("UIStroke")

    local cbObj = {
        Value = state, Type = "Toggle",
        SetValue = function(s, v)
            state = v; s.Value = v
            Tween(box, { BackgroundColor3 = v and self.Theme.Accent or self.Theme.InputBg })
            Tween(boxStroke, { Color = v and self.Theme.Accent or self.Theme.Border })
            checkMark.Text = v and "✓" or ""
            callback(v)
        end
    }
    row.MouseButton1Click:Connect(function()
        if cbObj._disabled then return end
        cbObj:SetValue(not state)
    end)

    self:ApplyCommonProperties(row, options, cbObj)
    if flag then self.Toggles[flag] = cbObj end
    if default then callback(true) end
    return cbObj
end

-- ── ColorPicker ───────────────────────────────────────────────────
-- Compact inline picker: hue strip + SV square + hex input
function Library:CreateColorPicker(parent, options)
    local cpName  = options.Name or "Color"
    local default = options.Default or Color3.fromRGB(82, 148, 246)
    local callback = options.Callback or function() end
    local flag    = options.Flag

    local H, S, V = Color3.toHSV(default)
    local value   = default

    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Parent = parent
    })

    local previewBtn = Create("TextButton", {
        Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(0, 0, 0.5, -12),
        BackgroundColor3 = value, Text = "", AutoButtonColor = false, Parent = container
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Create("UIStroke", { Color = self.Theme.Border, Thickness = 1 })
    })

    local cpNameLabel = Create("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0), Position = UDim2.new(0, 30, 0, 0),
        BackgroundTransparency = 1, Text = cpName,
        TextColor3 = self.Theme.Text, Font = Enum.Font.Gotham, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = container
    })
    self:RegisterElement(cpNameLabel, "Text", "TextColor3")

    local hexLabel = Create("TextLabel", {
        Size = UDim2.new(0, 60, 0, 20), Position = UDim2.new(1, -62, 0.5, -10),
        BackgroundColor3 = self.Theme.InputBg,
        Text = "#" .. value:ToHex():upper(),
        TextColor3 = self.Theme.Accent, Font = Enum.Font.Code, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Center, Parent = container
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Create("UIStroke", { Color = self.Theme.Border, Thickness = 1 })
    })

    -- Picker panel (opens below)
    local pickerOpen = false
    local pickerPanel = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 124),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = self.Theme.Element,
        BorderSizePixel = 0, Visible = false, ZIndex = 60, Parent = container
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
        Create("UIStroke", { Color = self.Theme.Border, Thickness = 1 }),
        Create("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })
    })
    container.Size = UDim2.new(1, 0, 0, 28)

    -- SV Square (120×80)
    local svFrame = Create("ImageLabel", {
        Size = UDim2.new(1, -20, 0, 80),
        BackgroundColor3 = Color3.fromHSV(H, 1, 1),
        Image = "rbxassetid://4155801252",
        ImageColor3 = Color3.new(1,1,1),
        ZIndex = 61, Parent = pickerPanel
    }, { Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })

    local svCursor = Create("Frame", {
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new(S, -5, 1-V, -5),
        BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, ZIndex = 63, Parent = svFrame
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Create("UIStroke", { Color = Color3.new(0,0,0), Thickness = 1.5 })
    })

    -- Hue strip (right side, 10px wide)
    local hueStrip = Create("ImageLabel", {
        Size = UDim2.new(0, 10, 0, 80), Position = UDim2.new(1, 0, 0, 0),
        Image = "rbxassetid://698052001",
        ZIndex = 61, Parent = pickerPanel
    }, { Create("UICorner", { CornerRadius = UDim.new(0, 4) }) })

    local hueCursor = Create("Frame", {
        Size = UDim2.new(1, 4, 0, 4),
        Position = UDim2.new(0, -2, H, -2),
        BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, ZIndex = 63, Parent = hueStrip
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Create("UIStroke", { Color = Color3.new(0,0,0), Thickness = 1 })
    })

    local function applyColor()
        value = Color3.fromHSV(H, S, V)
        previewBtn.BackgroundColor3 = value
        hexLabel.Text = "#" .. value:ToHex():upper()
        svFrame.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
        callback(value)
    end

    local function dragSV(input)
        local relX = math.clamp((input.Position.X - svFrame.AbsolutePosition.X) / svFrame.AbsoluteSize.X, 0, 1)
        local relY = math.clamp((input.Position.Y - svFrame.AbsolutePosition.Y) / svFrame.AbsoluteSize.Y, 0, 1)
        S = relX; V = 1 - relY
        svCursor.Position = UDim2.new(S, -5, 1-V, -5); applyColor()
    end
    local function dragHue(input)
        local relY = math.clamp((input.Position.Y - hueStrip.AbsolutePosition.Y) / hueStrip.AbsoluteSize.Y, 0, 1)
        H = relY; hueCursor.Position = UDim2.new(0, -2, H, -2); applyColor()
    end

    local function hookDrag(frame, fn)
        local dragging = false
        frame.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true; fn(i)
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then fn(i) end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
        end)
    end
    hookDrag(svFrame, dragSV); hookDrag(hueStrip, dragHue)

    previewBtn.MouseButton1Click:Connect(function()
        pickerOpen = not pickerOpen
        pickerPanel.Visible = pickerOpen
        container.Size = pickerOpen and UDim2.new(1, 0, 0, 156) or UDim2.new(1, 0, 0, 28)
    end)

    local cpObj = {
        Value = value, Type = "ColorPicker",
        SetValue = function(s, col)
            value = col; s.Value = col; H, S, V = Color3.toHSV(col)
            previewBtn.BackgroundColor3 = col; hexLabel.Text = "#" .. col:ToHex():upper()
            svFrame.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
            svCursor.Position = UDim2.new(S, -5, 1-V, -5)
            hueCursor.Position = UDim2.new(0, -2, H, -2)
            callback(col)
        end
    }

    self:ApplyCommonProperties(container, options, cpObj)
    if flag then self.Options[flag] = cpObj end
    return cpObj
end

-- ── ProgressBar ───────────────────────────────────────────────────
function Library:CreateProgressBar(parent, options)
    local pbName  = options.Name or "Progress"
    local max     = options.Max or 100
    local value   = options.Default or 0
    local suffix  = options.Suffix or ""
    local flag    = options.Flag

    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Parent = parent
    })
    local topRow = Create("Frame", { Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Parent = container })
    Create("TextLabel", {
        Size = UDim2.new(0.6, 0, 1, 0), BackgroundTransparency = 1,
        Text = pbName, TextColor3 = self.Theme.TextDim,
        Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = topRow
    })
    local valLabel = Create("TextLabel", {
        Size = UDim2.new(0.4, 0, 1, 0), Position = UDim2.new(0.6, 0, 0, 0),
        BackgroundTransparency = 1, Text = tostring(value) .. suffix,
        TextColor3 = self.Theme.Accent, Font = Enum.Font.GothamBold, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right, Parent = topRow
    })
    local track = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 8), Position = UDim2.new(0, 0, 0, 18),
        BackgroundColor3 = self.Theme.ToggleOff, Parent = container
    }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
    local fill = Create("Frame", {
        Size = UDim2.new(value / max, 0, 1, 0), BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0, Parent = track
    }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

    local pbObj = {
        Value = value, Type = "ProgressBar",
        SetValue = function(s, v)
            v = math.clamp(v, 0, max); value = v; s.Value = v
            Tween(fill, { Size = UDim2.new(v / max, 0, 1, 0) })
            valLabel.Text = tostring(v) .. suffix
        end,
        SetMax = function(s, m) max = m; s:SetValue(value) end
    }
    if flag then self.Options[flag] = pbObj end
    return pbObj
end

-- ── Image ─────────────────────────────────────────────────────────
function Library:CreateImage(parent, options)
    local imgId  = options.Image or "rbxassetid://0"
    local size   = options.Size or UDim2.new(1, 0, 0, 80)
    local corner = options.Corner or 8

    local frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, (size.Y.Offset > 0 and size.Y.Offset or 80) + 4),
        BackgroundTransparency = 1, Parent = parent
    })
    Create("ImageLabel", {
        Size = size, BackgroundColor3 = self.Theme.Element,
        Image = imgId, ScaleType = Enum.ScaleType.Fit, Parent = frame
    }, { Create("UICorner", { CornerRadius = UDim.new(0, corner) }) })

    return { Instance = frame }
end

-- ── Viewport ──────────────────────────────────────────────────────
function Library:CreateViewport(parent, options)
    local vpSize = options.Size or UDim2.new(1, 0, 0, 100)
    local model  = options.Model

    local vp = Create("ViewportFrame", {
        Size = vpSize, BackgroundColor3 = self.Theme.Element, Parent = parent
    }, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })

    local cam = Instance.new("Camera"); cam.Parent = vp; vp.CurrentCamera = cam
    if model then
        local clone = model:Clone(); clone.Parent = vp
        local cf, size = clone:GetBoundingBox()
        cam.CFrame = CFrame.new(cf.Position + Vector3.new(0, size.Y * 0.3, size.Z * 2.2), cf.Position)
    end
    return { Instance = vp, Viewport = vp, Camera = cam }
end

-- ── DependencyBox ─────────────────────────────────────────────────
-- Hides/shows based on another toggle's value
function Library:CreateDependencyBox(parent, options)
    local dependsOn   = options.DependsOn
    local invert      = options.Invert or false
    local children    = {}

    local box = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true, Parent = parent
    }, {
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) })
    })

    local function update(v)
        local show = invert and not v or v
        box.Visible = show
    end
    if dependsOn and self.Toggles[dependsOn] then
        update(self.Toggles[dependsOn].Value)
        local orig = self.Toggles[dependsOn].SetValue
        self.Toggles[dependsOn].SetValue = function(s, val)
            orig(s, val); update(val)
        end
    end

    return { Instance = box, Frame = box }
end

-- ── TooltipLabel ──────────────────────────────────────────────────
function Library:CreateTooltipLabel(parent, options)
    local text    = options.Text or ""
    local tooltip = options.Tooltip or ""

    local row = Create("Frame", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Parent = parent })
    local label = Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0), BackgroundTransparency = 1,
        Text = text, TextColor3 = self.Theme.TextDim,
        Font = Enum.Font.Gotham, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row
    })
    local icon = Create("TextButton", {
        Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -16, 0.5, -8),
        BackgroundColor3 = self.Theme.Element,
        Text = "?", TextColor3 = self.Theme.TextDim,
        Font = Enum.Font.GothamBold, TextSize = 9, AutoButtonColor = false, Parent = row
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Create("UIStroke", { Color = self.Theme.Border, Thickness = 1 })
    })
    icon.MouseEnter:Connect(function() self:ShowTooltip(tooltip) end)
    icon.MouseLeave:Connect(function() self:HideTooltip() end)

    local tipObj = { SetText = function(s, t) label.Text = t end }
    return tipObj
end

-- ── SearchableDropdown ────────────────────────────────────────────
function Library:CreateSearchableDropdown(parent, options)
    local sdName   = options.Name or "Search"
    local items    = options.Options or options.Items or {}
    local callback = options.Callback or function() end
    local flag     = options.Flag
    local value    = options.Default or nil

    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 1, Parent = parent
    })
    Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Text = sdName,
        TextColor3 = self.Theme.TextDim, Font = Enum.Font.Gotham, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = container
    })

    local searchField = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 0, 16),
        BackgroundColor3 = self.Theme.InputBg, Parent = container
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("UIStroke", { Color = self.Theme.Border, Thickness = 1 })
    })
    local searchBox = Create("TextBox", {
        Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1, Text = "",
        PlaceholderText = "Search " .. sdName .. "...", PlaceholderColor3 = self.Theme.TextMuted,
        TextColor3 = self.Theme.Text, Font = Enum.Font.Gotham, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = searchField
    })
    self:RegisterElement(searchBox, "Text", "TextColor3")

    -- Results panel
    local ITEM_H = 24; local maxVis = options.MaxVisible or 5
    local panelH = math.min(#items, maxVis) * ITEM_H + 8
    local panel = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, panelH), Position = UDim2.new(0, 0, 0, 44),
        BackgroundColor3 = self.Theme.Element, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = self.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0), Visible = false, ZIndex = 55, Parent = container
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("UIStroke", { Color = self.Theme.Border, Thickness = 1 }),
        Create("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 4) }),
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) })
    })
    container.Size = UDim2.new(1, 0, 0, 44)

    local fieldStroke = searchField:FindFirstChildWhichIsA("UIStroke")
    local resultBtns  = {}

    local function setResult(item)
        value = item; searchBox.Text = item or ""; panel.Visible = false
        container.Size = UDim2.new(1, 0, 0, 44)
        if fieldStroke then Tween(fieldStroke, { Color = self.Theme.Border }) end
        callback(value)
    end

    local function filterItems(query)
        for _, b in pairs(resultBtns) do b:Destroy() end; resultBtns = {}
        local filtered = {}
        for _, it in ipairs(items) do
            if query == "" or tostring(it):lower():find(query:lower(), 1, true) then
                table.insert(filtered, it)
            end
        end
        panel.CanvasSize = UDim2.new(0, 0, 0, #filtered * ITEM_H + 4)
        local ph = math.min(#filtered, maxVis) * ITEM_H + 8
        panel.Size = UDim2.new(1, 0, 0, ph)
        container.Size = UDim2.new(1, 0, 0, 44 + ph + 2)
        for _, it in ipairs(filtered) do
            local btn = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, ITEM_H - 2),
                BackgroundColor3 = self.Theme.Element, Text = tostring(it),
                TextColor3 = self.Theme.Text, Font = Enum.Font.Gotham, TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false,
                ZIndex = 56, Parent = panel
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                Create("UIPadding", { PaddingLeft = UDim.new(0, 8) })
            })
            btn.MouseEnter:Connect(function() Tween(btn, { BackgroundColor3 = self.Theme.ElementHover }) end)
            btn.MouseLeave:Connect(function() Tween(btn, { BackgroundColor3 = self.Theme.Element }) end)
            btn.MouseButton1Click:Connect(function() setResult(it) end)
            table.insert(resultBtns, btn)
        end
        panel.Visible = #filtered > 0
    end

    searchBox.Focused:Connect(function()
        if fieldStroke then Tween(fieldStroke, { Color = self.Theme.Accent }) end
        filterItems(searchBox.Text)
    end)
    searchBox:GetPropertyChangedSignal("Text"):Connect(function() filterItems(searchBox.Text) end)
    searchBox.FocusLost:Connect(function()
        task.delay(0.15, function() panel.Visible = false; container.Size = UDim2.new(1, 0, 0, 44)
            if fieldStroke then Tween(fieldStroke, { Color = self.Theme.Border }) end end)
    end)

    local sdObj = {
        Value = value, Type = "Dropdown",
        SetValue = function(s, v) setResult(v) end,
        Refresh = function(s, newList, reset)
            items = newList; if reset then value = nil; searchBox.Text = "" end
            s.Value = value
        end
    }
    self:ApplyCommonProperties(container, options, sdObj)
    if flag then self.Options[flag] = sdObj end
    return sdObj
end

-- ── Paragraph ─────────────────────────────────────────────────────
-- Title + wrapped body text, optional RichText
function Library:CreateParagraph(parent, options)
    local title   = options.Title or options.Name or ""
    local body    = options.Content or options.Text or ""

    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y, Parent = parent
    }, {
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3) })
    })

    local titleLbl
    if title ~= "" then
        titleLbl = Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
            Text = title, TextColor3 = self.Theme.Text,
            Font = Enum.Font.GothamBold, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 1, Parent = container
        })
        self:RegisterElement(titleLbl, "Text", "TextColor3")
    end

    local bodyLbl = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, Text = body,
        TextColor3 = self.Theme.TextDim, Font = Enum.Font.Gotham, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, RichText = true,
        LayoutOrder = 2, Parent = container
    })
    self:RegisterElement(bodyLbl, "TextDim", "TextColor3")

    local obj = {
        SetTitle = function(_, t) if titleLbl then titleLbl.Text = t end end,
        SetContent = function(_, t) bodyLbl.Text = t end,
    }
    return obj
end

-- ── Badge / Tag ───────────────────────────────────────────────────
-- Inline colored label badge — useful for status, counters, labels
function Library:CreateBadge(parent, options)
    local label      = options.Name or ""
    local text       = options.Text or "Badge"
    local badgeColor = options.Color or self.Theme.Accent
    local style      = options.Style or "pill"  -- "pill" or "square"

    local row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Parent = parent
    })

    if label ~= "" then
        Create("TextLabel", {
            Size = UDim2.new(1, -62, 1, 0), BackgroundTransparency = 1,
            Text = label, TextColor3 = self.Theme.Text,
            Font = Enum.Font.Gotham, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = row
        })
    end

    local badge = Create("TextLabel", {
        Size = UDim2.new(0, 56, 0, 18),
        Position = UDim2.new(1, -58, 0.5, -9),
        BackgroundColor3 = badgeColor,
        BackgroundTransparency = 0.78,
        Text = text, TextColor3 = badgeColor,
        Font = Enum.Font.GothamBold, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Center, Parent = row
    }, {
        Create("UICorner", { CornerRadius = style == "pill" and UDim.new(1, 0) or UDim.new(0, 4) }),
        Create("UIStroke", { Color = badgeColor, Transparency = 0.6, Thickness = 1 }),
    })

    local obj = {
        SetText  = function(_, t) badge.Text = t end,
        SetColor = function(_, c)
            badge.BackgroundColor3 = c; badge.TextColor3 = c
            local s = badge:FindFirstChildWhichIsA("UIStroke")
            if s then s.Color = c end
        end,
        Instance = badge,
    }
    return obj
end

-- ── Space ──────────────────────────────────────────────────────────
-- Explicit vertical gap between elements
function Library:CreateSpace(parent, options)
    local height = (options and options.Height) or 8
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, height),
        BackgroundTransparency = 1, Parent = parent
    })
    return {}
end

-- ── CodeBlock ─────────────────────────────────────────────────────
-- Monospace code display with copy-to-clipboard button
function Library:CreateCodeBlock(parent, options)
    local code     = options.Code or ""
    local language = options.Language or "lua"
    local height   = options.Height or 58

    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, height + 26),
        BackgroundTransparency = 1, Parent = parent
    })

    local header = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = self.Theme.Border, BorderSizePixel = 0, Parent = container
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("TextLabel", {
            Size = UDim2.new(1, -52, 1, 0), Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1, Text = language:upper(),
            TextColor3 = self.Theme.TextDim, Font = Enum.Font.GothamBold, TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    })
    -- Square bottom corners of header
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 8), Position = UDim2.new(0, 0, 1, -8),
        BackgroundColor3 = self.Theme.Border, BorderSizePixel = 0, Parent = header
    })
    self:RegisterElement(header, "Border")

    local copyBtn = Create("TextButton", {
        Size = UDim2.new(0, 44, 0, 16), Position = UDim2.new(1, -46, 0.5, -8),
        BackgroundColor3 = self.Theme.Element,
        Text = "Copy", TextColor3 = self.Theme.TextDim,
        Font = Enum.Font.GothamBold, TextSize = 9, AutoButtonColor = false, Parent = header
    }, { Create("UICorner", { CornerRadius = UDim.new(0, 4) }) })

    local codeArea = Create("Frame", {
        Size = UDim2.new(1, 0, 0, height),
        Position = UDim2.new(0, 0, 0, 24),
        BackgroundColor3 = self.Theme.InputBg,
        ClipsDescendants = true, Parent = container
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6) })
    })
    -- Square top corners of code area
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 8), BackgroundColor3 = self.Theme.InputBg,
        BorderSizePixel = 0, Parent = codeArea
    })
    self:RegisterElement(codeArea, "InputBg")

    local codeLbl = Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Text = code, TextColor3 = self.Theme.Accent,
        Font = Enum.Font.Code, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true, RichText = false, Parent = codeArea
    })
    self:RegisterElement(codeLbl, "Accent", "TextColor3")

    copyBtn.MouseButton1Click:Connect(function()
        copyBtn.Text = "✓ Done"
        pcall(function() setclipboard(code) end)
        task.delay(1.5, function() if copyBtn and copyBtn.Parent then copyBtn.Text = "Copy" end end)
    end)
    copyBtn.MouseEnter:Connect(function() Tween(copyBtn, { TextColor3 = self.Theme.Text }) end)
    copyBtn.MouseLeave:Connect(function() Tween(copyBtn, { TextColor3 = self.Theme.TextDim }) end)

    return {
        SetCode = function(_, c) code = c; codeLbl.Text = c end,
        Instance = container,
    }
end

-- ── MultiButton ───────────────────────────────────────────────────
-- Horizontal row of equal-width buttons (HStack equivalent)
function Library:CreateMultiButton(parent, options)
    local buttons = options.Buttons or {}
    local n = math.max(#buttons, 1)

    local row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Parent = parent
    }, {
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4)
        })
    })

    for i, btnOpts in ipairs(buttons) do
        local isRisky   = btnOpts.Risky or false
        local riskyColor = Color3.fromRGB(232, 82, 82)
        local slotW = math.floor((1 / n) * 1000) / 1000
        local btn = Create("TextButton", {
            Size = UDim2.new(slotW, i == n and 0 or -4, 1, 0),
            BackgroundColor3 = self.Theme.InputBg,
            Text = btnOpts.Name or "Button",
            TextColor3 = isRisky and riskyColor or self.Theme.TextDim,
            Font = Enum.Font.GothamMedium, TextSize = 11,
            AutoButtonColor = false, LayoutOrder = i, Parent = row
        }, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })

        if not isRisky then
            local s = Instance.new("UIStroke")
            s.Color = self.Theme.Border; s.Thickness = 1; s.Parent = btn
            btn.MouseEnter:Connect(function()
                Tween(btn, { BackgroundColor3 = self.Theme.AccentDark, TextColor3 = self.Theme.Text })
                Tween(s, { Color = self.Theme.Accent })
            end)
            btn.MouseLeave:Connect(function()
                Tween(btn, { BackgroundColor3 = self.Theme.InputBg, TextColor3 = self.Theme.TextDim })
                Tween(s, { Color = self.Theme.Border })
            end)
        else
            btn.MouseEnter:Connect(function() Tween(btn, { BackgroundColor3 = Color3.fromRGB(72, 22, 22) }) end)
            btn.MouseLeave:Connect(function() Tween(btn, { BackgroundColor3 = self.Theme.InputBg }) end)
        end

        btn.MouseButton1Click:Connect(function()
            local flash = isRisky and Color3.fromRGB(90, 28, 28) or self.Theme.BorderLight
            local rest  = isRisky and Color3.fromRGB(72, 22, 22) or self.Theme.InputBg
            Tween(btn, { BackgroundColor3 = flash }, 0.05)
            task.delay(0.07, function() if btn and btn.Parent then Tween(btn, { BackgroundColor3 = rest }, 0.2) end end)
            if btnOpts.Callback then pcall(btnOpts.Callback) end
        end)
    end

    return { Instance = row }
end

-- ── Popup ──────────────────────────────────────────────────────────
-- Standalone modal overlay with title, content and action buttons
function Library:CreatePopup(options)
    if not self.ScreenGui then return end
    local title   = options.Title or "Popup"
    local content = options.Content or ""
    local buttons = options.Buttons or { { Name = "Close", Callback = function() end } }

    local overlay = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.55, ZIndex = 200, Parent = self.ScreenGui
    })

    local card = Create("Frame", {
        Size = UDim2.new(0, 320, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = self.Theme.Element,
        BackgroundTransparency = 1, ZIndex = 201, Parent = overlay
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
        Create("UIStroke", { Color = self.Theme.Border, Thickness = 1 }),
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0) }),
    })

    -- Title bar
    local titleBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1,
        LayoutOrder = 1, ZIndex = 201, Parent = card
    }, {
        Create("UIPadding", { PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16) }),
        Create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            Text = title, TextColor3 = self.Theme.Text,
            Font = Enum.Font.GothamBold, TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 202
        })
    })

    -- Divider
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = self.Theme.Border,
        BorderSizePixel = 0, LayoutOrder = 2, ZIndex = 201, Parent = card
    })

    -- Body
    Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, Text = content,
        TextColor3 = self.Theme.TextDim, Font = Enum.Font.Gotham, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
        LayoutOrder = 3, ZIndex = 202, Parent = card
    }, { Create("UIPadding", { PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) }) })

    -- Divider before buttons
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = self.Theme.Border,
        BorderSizePixel = 0, LayoutOrder = 4, ZIndex = 201, Parent = card
    })

    -- Button row
    local btnRow = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1,
        LayoutOrder = 5, ZIndex = 201, Parent = card
    }, {
        Create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }),
        Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Right })
    })

    local popupObj
    popupObj = {
        Close = function()
            Tween(card, { BackgroundTransparency = 1 }, 0.18)
            Tween(overlay, { BackgroundTransparency = 1 }, 0.18)
            task.delay(0.2, function() if overlay and overlay.Parent then overlay:Destroy() end end)
        end
    }

    for i, btnOpts in ipairs(buttons) do
        local isAccent = btnOpts.Style == "accent"
        local b = Create("TextButton", {
            Size = UDim2.new(0, 90, 1, -2), AutoButtonColor = false,
            BackgroundColor3 = isAccent and self.Theme.Accent or self.Theme.InputBg,
            Text = btnOpts.Name or "OK",
            TextColor3 = isAccent and Color3.new(1,1,1) or self.Theme.Text,
            Font = Enum.Font.GothamMedium, TextSize = 11,
            LayoutOrder = i, ZIndex = 202, Parent = btnRow
        }, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
        b.MouseButton1Click:Connect(function()
            if btnOpts.Callback then pcall(btnOpts.Callback) end
            popupObj.Close()
        end)
    end

    -- Fade in
    Tween(card, { BackgroundTransparency = 0 }, 0.22)

    return popupObj
end

-- ── Divider ───────────────────────────────────────────────────────
function Library:CreateDivider(parent, options)
    local text   = options and options.Text or ""
    local height = text ~= "" and 20 or 8

    local div = Create("Frame", {
        Size = UDim2.new(1, 0, 0, height), BackgroundTransparency = 1, Parent = parent
    })
    if text ~= "" then
        Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1, Text = text:upper(),
            TextColor3 = self.Theme.TextMuted, Font = Enum.Font.GothamBold, TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = div
        })
        Create("Frame", {
            Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0, 14),
            BackgroundColor3 = self.Theme.Border, BorderSizePixel = 0, Parent = div
        })
    else
        Create("Frame", {
            Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = self.Theme.Border, BorderSizePixel = 0, Parent = div
        })
    end
    return { Instance = div }
end

-- ── Dialog ────────────────────────────────────────────────────────
-- Stored modal with Show/Close methods. Unlike Popup, call :Show() when needed.
function Library:CreateDialog(options)
    if not self.ScreenGui then return { Show = function() end, Close = function() end } end
    local title    = options.Title or "Dialog"
    local content  = options.Content or ""
    local buttons  = options.Buttons or { { Name = "Close" } }
    local iconName = options.Icon

    local overlay = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1,
        Visible = false, ZIndex = 300, Parent = self.ScreenGui
    })

    local card = Create("Frame", {
        Size = UDim2.new(0, 340, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.45, 0),
        BackgroundColor3 = self.Theme.Element, BorderSizePixel = 0, ZIndex = 301,
        Parent = overlay
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 14) }),
        Create("UIStroke", { Color = self.Theme.Border, Thickness = 1 }),
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
    })

    -- Header row (icon + title + close X)
    local headerRow = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1,
        LayoutOrder = 1, ZIndex = 301, Parent = card
    }, {
        Create("UIPadding", { PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 12) })
    })
    if iconName then
        local ico = Create("ImageLabel", {
            Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 0, 0.5, -9),
            BackgroundTransparency = 1, ImageColor3 = self.Theme.Accent, ZIndex = 302, Parent = headerRow
        })
        self:ApplyIcon(ico, iconName)
    end
    local icoOff = iconName and 26 or 0
    Create("TextLabel", {
        Size = UDim2.new(1, -(icoOff + 28), 1, 0), Position = UDim2.new(0, icoOff, 0, 0),
        BackgroundTransparency = 1, Text = title,
        TextColor3 = self.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 302, Parent = headerRow
    })
    local xBtn = Create("TextButton", {
        Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -24, 0.5, -12),
        BackgroundTransparency = 1, Text = "✕",
        TextColor3 = self.Theme.TextMuted, Font = Enum.Font.GothamBold, TextSize = 11,
        AutoButtonColor = false, ZIndex = 302, Parent = headerRow
    })

    Create("Frame", { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = self.Theme.Border, BorderSizePixel = 0, LayoutOrder = 2, ZIndex = 301, Parent = card })

    Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, Text = content,
        TextColor3 = self.Theme.TextDim, Font = Enum.Font.Gotham, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
        LayoutOrder = 3, ZIndex = 302, Parent = card
    }, { Create("UIPadding", { PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12) }) })

    Create("Frame", { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = self.Theme.Border, BorderSizePixel = 0, LayoutOrder = 4, ZIndex = 301, Parent = card })

    local btnRow = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 46), BackgroundTransparency = 1,
        LayoutOrder = 5, ZIndex = 301, Parent = card
    }, {
        Create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 9), PaddingBottom = UDim.new(0, 9) }),
        Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Right })
    })

    local dialogObj
    dialogObj = {
        Show = function()
            overlay.Visible = true
            Tween(overlay, { BackgroundTransparency = 0.5 }, 0.18)
            card.Position = UDim2.new(0.5, 0, 0.42, 0)
            Tween(card, { Position = UDim2.new(0.5, 0, 0.45, 0) }, 0.22)
        end,
        Close = function()
            Tween(overlay, { BackgroundTransparency = 1 }, 0.18)
            task.delay(0.2, function() if overlay and overlay.Parent then overlay.Visible = false end end)
        end,
    }
    xBtn.MouseButton1Click:Connect(dialogObj.Close)

    for i, bOpts in ipairs(buttons) do
        local isPrimary = bOpts.Style == "primary" or bOpts.Primary
        local b = Create("TextButton", {
            Size = UDim2.new(0, 94, 1, -2), AutoButtonColor = false,
            BackgroundColor3 = isPrimary and self.Theme.Accent or self.Theme.InputBg,
            Text = bOpts.Name or "OK",
            TextColor3 = isPrimary and Color3.new(1,1,1) or self.Theme.Text,
            Font = Enum.Font.GothamMedium, TextSize = 11,
            LayoutOrder = i, ZIndex = 302, Parent = btnRow
        }, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
        b.MouseButton1Click:Connect(function()
            if bOpts.Callback then pcall(bOpts.Callback) end
            dialogObj.Close()
        end)
    end

    return dialogObj
end

-- ── Key System ────────────────────────────────────────────────────
-- Key-gate dialog shown before the main window. Pass Key/Keys in CreateWindow opts.
function Library:_ShowKeySystem(options, onSuccess)
    if not self.ScreenGui then return end
    local validKeys  = {}
    if type(options.Key)  == "string" then validKeys[options.Key:upper()]  = true end
    if type(options.Keys) == "table"  then for _, k in ipairs(options.Keys) do validKeys[k:upper()] = true end end
    local keyLink  = options.KeyLink or nil
    local title    = options.KeyTitle or "Key Required"
    local saveFile = options.SaveKey ~= false

    -- try saved key first
    if saveFile then
        pcall(function()
            local saved = readfile and readfile("SeisenKey.txt") or ""
            if validKeys[saved:upper():gsub("%s", "")] then
                task.defer(onSuccess); return
            end
        end)
    end

    local overlay = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45,
        ZIndex = 500, Parent = self.ScreenGui
    })

    local card = Create("Frame", {
        Size = UDim2.new(0, 320, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.48, 0),
        BackgroundColor3 = self.Theme.Element, ZIndex = 501, Parent = overlay
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 14) }),
        Create("UIStroke", { Color = self.Theme.Accent, Thickness = 1, Transparency = 0.55 }),
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
    })

    local headPad = Create("Frame", { Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1, LayoutOrder = 1, Parent = card }, {
        Create("UIPadding", { PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16) }),
    })
    Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 8),
        BackgroundTransparency = 1, Text = title,
        TextColor3 = self.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 502, Parent = headPad
    })
    Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 0, 30),
        BackgroundTransparency = 1, Text = "Enter your key to continue",
        TextColor3 = self.Theme.TextDim, Font = Enum.Font.Gotham, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 502, Parent = headPad
    })

    local bodyPad = Create("Frame", { Size = UDim2.new(1, 0, 0, 68), BackgroundTransparency = 1, LayoutOrder = 2, Parent = card }, {
        Create("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) }),
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) }),
    })

    local inputFrame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = self.Theme.InputBg,
        LayoutOrder = 1, ZIndex = 502, Parent = bodyPad
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("UIStroke", { Color = self.Theme.Border, Thickness = 1 }),
    })
    local keyInput = Create("TextBox", {
        Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1, Text = "",
        PlaceholderText = "Paste your key here...", PlaceholderColor3 = self.Theme.TextMuted,
        TextColor3 = self.Theme.Text, Font = Enum.Font.Gotham, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 503, Parent = inputFrame
    })

    local statusLbl = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Text = "",
        TextColor3 = self.Theme.Error, Font = Enum.Font.Gotham, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Center, LayoutOrder = 2, ZIndex = 502, Parent = bodyPad
    })

    local btnRow = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, LayoutOrder = 3, Parent = card
    }, {
        Create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 8) }),
        Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Center })
    })

    if keyLink then
        local linkBtn = Create("TextButton", {
            Size = UDim2.new(0.46, 0, 1, -2), BackgroundColor3 = self.Theme.InputBg,
            Text = "Get Key", TextColor3 = self.Theme.Accent,
            Font = Enum.Font.GothamMedium, TextSize = 11, AutoButtonColor = false,
            LayoutOrder = 1, ZIndex = 502, Parent = btnRow
        }, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
        linkBtn.MouseButton1Click:Connect(function() pcall(function() setclipboard(keyLink) end) linkBtn.Text = "Copied!" task.delay(2, function() linkBtn.Text = "Get Key" end) end)
    end

    local submitBtn = Create("TextButton", {
        Size = UDim2.new(keyLink and 0.46 or 0.6, 0, 1, -2), BackgroundColor3 = self.Theme.Accent,
        Text = "Submit", TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false,
        LayoutOrder = 2, ZIndex = 502, Parent = btnRow
    }, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })

    local function trySubmit()
        local entered = keyInput.Text:upper():gsub("%s", "")
        if validKeys[entered] then
            statusLbl.Text = ""
            Tween(overlay, { BackgroundTransparency = 1 }, 0.25)
            task.delay(0.28, function() pcall(function() overlay:Destroy() end) end)
            if saveFile then pcall(function() if writefile then writefile("SeisenKey.txt", keyInput.Text) end end) end
            onSuccess()
        else
            statusLbl.Text = "Invalid key — please try again."
            Tween(inputFrame, { BackgroundColor3 = Color3.fromRGB(60, 20, 20) }, 0.1)
            task.delay(0.6, function() Tween(inputFrame, { BackgroundColor3 = self.Theme.InputBg }, 0.3) end)
        end
    end

    submitBtn.MouseButton1Click:Connect(trySubmit)
    keyInput.FocusLost:Connect(function(enter) if enter then trySubmit() end end)
end

-- ── HStack ────────────────────────────────────────────────────────
-- Horizontal container — add elements side-by-side with equal slots
function Library:CreateHStack(parent, options)
    local cols      = options.Columns or 2
    local gap       = options.Gap or 6
    local height    = options.Height or 0

    local row = Create("Frame", {
        Size = height > 0 and UDim2.new(1, 0, 0, height) or UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = height == 0 and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
        Parent = parent
    }, {
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, gap),
            VerticalAlignment = Enum.VerticalAlignment.Top,
        })
    })

    local slots = {}
    for i = 1, cols do
        local slot = Create("Frame", {
            Size = UDim2.new(1/cols, i < cols and -math.ceil(gap*(cols-1)/cols) or 0, 0, 0),
            BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = i, Parent = row
        }, {
            Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) })
        })
        slots[i] = slot
    end

    local stackObj = {
        Instance = row,
        Slots    = slots,
        GetSlot  = function(_, i) return slots[i] end,
    }
    return stackObj
end

-- ── VStack ────────────────────────────────────────────────────────
-- Vertical container with optional divider between children
function Library:CreateVStack(parent, options)
    local gap = options and options.Gap or 4

    local stack = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = (options and options.Background) and self.Theme.InputBg or Color3.new(0,0,0),
        BackgroundTransparency = (options and options.Background) and 0 or 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = parent
    }, {
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, gap) })
    })
    if options and options.Background then
        if not stack:FindFirstChildWhichIsA("UICorner") then
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = stack })
        end
    end

    local stackObj = {
        Instance = stack,
        Add = function(_, createFn, opts)
            return createFn(stack, opts)
        end,
    }
    return stackObj
end

-- ── TabSection ───────────────────────────────────────────────────
-- Underline-style tab selector — visual alternative to pill Tabbox
function Library:CreateTabSection(parent, options)
    local tabs    = options.Tabs or {}
    local default = options.Default or tabs[1]
    local flag    = options.Flag
    local TAB_H   = 28

    local wrapper = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y,
        Parent = parent
    }, {
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) })
    })

    -- Underline tab bar
    local tabBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, TAB_H),
        BackgroundTransparency = 1, LayoutOrder = 1, Parent = wrapper
    }, {
        Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0) }),
        -- Bottom border line
        Create("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = self.Theme.Border, BorderSizePixel = 0 })
    })

    local tabFrames  = {}
    local tabButtons = {}
    local indicators = {}
    local activeTab  = nil

    local function activateTab(name)
        activeTab = name
        for tName, frame in pairs(tabFrames) do
            frame.Visible = tName == name
        end
        for tName, btn in pairs(tabButtons) do
            local active = tName == name
            Tween(btn, { TextColor3 = active and self.Theme.Text or self.Theme.TextDim })
        end
        for tName, ind in pairs(indicators) do
            Tween(ind, { BackgroundTransparency = tName == name and 0 or 1 })
        end
        if flag then self.Options[flag] = { Value = name } end
    end

    for i, tabName in ipairs(tabs) do
        local tabSlot = Create("Frame", {
            Size = UDim2.new(1/#tabs, 0, 1, 0),
            BackgroundTransparency = 1, LayoutOrder = i, Parent = tabBar
        })
        local btn = Create("TextButton", {
            Size = UDim2.new(1, 0, 1, -2), BackgroundTransparency = 1,
            Text = tabName, TextColor3 = self.Theme.TextDim,
            Font = Enum.Font.GothamMedium, TextSize = 11,
            AutoButtonColor = false, Parent = tabSlot
        })
        -- Underline indicator
        local ind = Create("Frame", {
            Size = UDim2.new(0.6, 0, 0, 2),
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new(0.5, 0, 1, 0),
            BackgroundColor3 = self.Theme.Accent, BackgroundTransparency = 1,
            BorderSizePixel = 0, Parent = tabSlot
        }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

        local content = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y, Visible = false,
            LayoutOrder = 2, Parent = wrapper
        }, {
            Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) }),
            Create("UIPadding", { PaddingTop = UDim.new(0, 4) })
        })

        tabFrames[tabName]  = content
        tabButtons[tabName] = btn
        indicators[tabName] = ind
        btn.MouseButton1Click:Connect(function() activateTab(tabName) end)
    end

    activateTab(default or tabs[1])

    local tsObj = {
        GetTab = function(_, name) return tabFrames[name] end,
        SetTab = function(_, name) activateTab(name) end,
    }
    if flag then self.Options[flag] = tsObj end
    return tsObj
end

-- ── Inline Tabbox ─────────────────────────────────────────────────
-- Horizontal tab selector with per-tab content containers
-- options.Tabs = { "Tab1", "Tab2" }; options.Side = "Left"|"Right"|nil (full-width)
function Library:CreateTabbox(parent, options)
    local tabs    = options.Tabs or {}
    local default = options.Default or tabs[1]
    local flag    = options.Flag

    local TAB_H = 26

    -- wrapper stacks header + active content vertically
    local wrapper = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = parent
    }, {
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) })
    })

    local tabHeader = Create("Frame", {
        Size = UDim2.new(1, 0, 0, TAB_H),
        BackgroundColor3 = self.Theme.ToggleOff,
        ClipsDescendants = true,
        LayoutOrder = 1,
        Parent = wrapper
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
    })
    self:RegisterElement(tabHeader, "ToggleOff")

    local tabFrames  = {}
    local tabButtons = {}
    local activeTab  = nil

    local function activateTab(name)
        activeTab = name
        for tName, frame in pairs(tabFrames) do
            frame.Visible = tName == name
        end
        for tName, btn in pairs(tabButtons) do
            local active = tName == name
            Tween(btn, { BackgroundColor3 = active and self.Theme.Accent or Color3.new(0,0,0) })
            Tween(btn, { BackgroundTransparency = active and 0 or 1 })
            local lbl = btn:FindFirstChildWhichIsA("TextLabel")
            if lbl then Tween(lbl, { TextColor3 = active and self.Theme.Text or self.Theme.TextDim }) end
        end
        if flag then self.Options[flag] = { Value = name } end
    end

    local n = math.max(#tabs, 1)
    for i, tabName in ipairs(tabs) do
        local btn = Create("TextButton", {
            Size     = UDim2.new(1/n, -2, 1, -4),
            Position = UDim2.new((i-1)/n, 1, 0, 2),
            BackgroundTransparency = 1,
            BackgroundColor3 = self.Theme.Accent,
            Text = "",
            AutoButtonColor = false,
            Parent = tabHeader
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
            Create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = tabName,
                TextColor3 = self.Theme.TextDim,
                Font = Enum.Font.GothamMedium,
                TextSize = 11,
                TextTruncate = Enum.TextTruncate.AtEnd
            })
        })
        local content = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = false,
            LayoutOrder = 2,
            Parent = wrapper
        }, {
            Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) }),
            Create("UIPadding", { PaddingTop = UDim.new(0, 2) })
        })
        tabFrames[tabName]  = content
        tabButtons[tabName] = btn
        btn.MouseButton1Click:Connect(function() activateTab(tabName) end)
    end

    activateTab(default or tabs[1])

    local tbObj = {
        ActiveTab = activeTab, Tabs = tabFrames,
        GetTab  = function(s, name) return tabFrames[name] end,
        SetTab  = function(s, name) activateTab(name) end,
    }
    if flag then self.Options[flag] = tbObj end
    return tbObj
end

-- ================================================================
-- PHASE 4 · Window Shell
-- ================================================================

-- ── SetScale ──────────────────────────────────────────────────────
function Library:SetScale(scale)
    if self._windowScale then
        self._windowScale.Scale = math.clamp(scale, 0.5, 2)
    end
end

-- ── OnUnload ──────────────────────────────────────────────────────
function Library:OnUnload(fn)
    self._unloadFn = fn
end

-- ── Toggle (show/hide) ────────────────────────────────────────────
function Library:Toggle()
    if not self.ScreenGui then return end
    local mw = self._mainWindow
    local ms = self._mainWindowScale
    if not mw or not ms then
        self.ScreenGui.Enabled = not self.ScreenGui.Enabled
        return
    end
    if mw.Visible then
        TweenService:Create(ms, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Scale = 0 }):Play()
        task.delay(0.32, function() if mw and mw.Parent then mw.Visible = false end end)
    else
        mw.Visible = true
        TweenService:Create(ms, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Scale = 1 }):Play()
    end
end

-- ── MakeDraggable ─────────────────────────────────────────────────
local function MakeDraggable(handle, frame, onClick)
    local dragging, dragStart, startPos = false, nil, nil
    local moved = false

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            moved     = false
            dragStart = input.Position
            startPos  = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if delta.Magnitude > 3 then moved = true end
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            if not moved and onClick then onClick() end
            dragging = false
        end
    end)
end

-- ── CreateWindow ─────────────────────────────────────────────────
function Library:CreateWindow(options)
    local winName   = options.Name or "Seisen Hub"
    local subtitle  = options.SubTitle or ""
    local version   = options.Version or ""
    local icon      = options.Icon or ""
    local keybind   = options.ToggleKeybind or Enum.KeyCode.LeftAlt
    local configUI  = options.ConfigSettings or false
    self.ToggleKeybind = keybind

    -- ── ScreenGui ────────────────────────────────────────────────
    local gui = Instance.new("ScreenGui")
    gui.Name              = "SeisenHub"
    gui.ResetOnSpawn      = false
    gui.ZIndexBehavior    = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder      = 999
    gui.IgnoreGuiInset    = true
    pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    self.ScreenGui = gui

    -- UIScale for SetScale support
    local scale = Instance.new("UIScale"); scale.Scale = 1; scale.Parent = gui
    self._windowScale = scale

    -- ── Notification container ───────────────────────────────────
    local notifContainer = Create("Frame", {
        Name = "NotificationContainer",
        Size = UDim2.new(0, 300, 1, 0),
        Position = UDim2.new(1, -310, 0, 0),
        BackgroundTransparency = 1,
        Parent = gui
    }, { Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 6),
    }) })
    self.NotificationContainer = notifContainer

    -- ── Main window frame ────────────────────────────────────────
    local WIN_W, WIN_H = 680, 480
    local SIDE_W       = 150

    local main = Create("Frame", {
        Name = "SeisenHub_Window",
        Size = UDim2.new(0, WIN_W, 0, WIN_H),
        Position = UDim2.new(0.5, -WIN_W / 2, 0.5, -WIN_H / 2),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0, ClipsDescendants = false,
        Parent = gui
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
        Create("UIStroke", { Color = self.Theme.Border, Thickness = 1.5 }),
    })
    self:RegisterElement(main, "Background")
    self:RegisterElement(main:FindFirstChildWhichIsA("UIStroke"), "Border", "Color")

    -- Subtle drop shadow
    Create("ImageLabel", {
        Size = UDim2.new(1, 40, 1, 40), Position = UDim2.new(0, -20, 0, -20),
        BackgroundTransparency = 1, ZIndex = -1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0), ImageTransparency = 0.7,
        ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = main
    })

    -- ── Sidebar ──────────────────────────────────────────────────
    local sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, SIDE_W, 1, 0),
        BackgroundColor3 = self.Theme.Sidebar,
        BorderSizePixel = 0, ClipsDescendants = true, Parent = main
    }, { Create("UICorner", { CornerRadius = UDim.new(0, 12) }) })
    -- Right-side clip (squared corners on right edge)
    Create("Frame", {
        Size = UDim2.new(0, 12, 1, 0), Position = UDim2.new(1, -12, 0, 0),
        BackgroundColor3 = self.Theme.Sidebar, BorderSizePixel = 0, Parent = sidebar
    })
    self:RegisterElement(sidebar, "Sidebar")

    -- ── Header bar inside sidebar ─────────────────────────────────
    local sideHeader = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundTransparency = 1, Parent = sidebar
    })

    -- Logo icon
    local logoFrame = Create("Frame", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 11, 0, 12),
        BackgroundColor3 = self.Theme.Accent,
        Parent = sideHeader
    }, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
    self:RegisterElement(logoFrame, "Accent")

    if icon ~= "" then
        Create("ImageLabel", {
            Size = UDim2.new(0.75, 0, 0.75, 0),
            Position = UDim2.new(0.125, 0, 0.125, 0),
            BackgroundTransparency = 1,
            Image = icon, Parent = logoFrame
        })
    else
        Create("TextLabel", {
            Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
            Text = "S", TextColor3 = Color3.new(1,1,1),
            Font = Enum.Font.GothamBold, TextSize = 14, Parent = logoFrame
        })
    end

    -- Hub name (small, above subtitle)
    Create("TextLabel", {
        Size = UDim2.new(1, -48, 0, 14), Position = UDim2.new(0, 46, 0, 12),
        BackgroundTransparency = 1, Text = winName,
        TextColor3 = self.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = sideHeader
    })
    Create("TextLabel", {
        Size = UDim2.new(1, -48, 0, 12), Position = UDim2.new(0, 46, 0, 27),
        BackgroundTransparency = 1, Text = subtitle ~= "" and subtitle or version,
        TextColor3 = self.Theme.TextDim, Font = Enum.Font.Gotham, TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = sideHeader
    })

    -- (window controls moved to content header right side)

    -- ── Sidebar tab list ──────────────────────────────────────────
    local sideScroll = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -54), Position = UDim2.new(0, 0, 0, 54),
        BackgroundTransparency = 1, ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0), Parent = sidebar
    }, {
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 2)
        }),
        Create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 4) })
    })

    -- ── Divider inside sidebar (for sections) ─────────────────────
    -- Exposed via Window:AddSidebarSection / AddSidebarDivider below

    -- ── Content panel ─────────────────────────────────────────────
    local content = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -SIDE_W, 1, 0),
        Position = UDim2.new(0, SIDE_W, 0, 0),
        BackgroundColor3 = self.Theme.Content,
        BorderSizePixel = 0, ClipsDescendants = true, Parent = main
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 12) })
    })
    -- Squared left edge
    Create("Frame", {
        Size = UDim2.new(0, 12, 1, 0), Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = self.Theme.Content, BorderSizePixel = 0, Parent = content
    })
    self:RegisterElement(content, "Content")

    -- Content top bar (title + search hint)
    local contentHeader = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1, Parent = content
    })
    local activeTitle = Create("TextLabel", {
        Size = UDim2.new(1, -90, 1, 0), Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1, Text = "",
        TextColor3 = self.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = contentHeader
    })
    self:RegisterElement(activeTitle, "Text", "TextColor3")

        -- ── Window controls (icon buttons on content header right) ───────
    local function makeWinBtn(pos, bgColor, iconName, tooltipText)
        local btn = Create("TextButton", {
            Size = UDim2.new(0, 22, 0, 22), Position = pos,
            BackgroundColor3 = bgColor, BackgroundTransparency = 0.82,
            Text = "", AutoButtonColor = false, ZIndex = 3, Parent = contentHeader
        }, { Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
        local ico = Create("ImageLabel", {
            Size = UDim2.new(0, 12, 0, 12), AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1, ImageColor3 = bgColor,
            ZIndex = 4, Parent = btn
        })
        self:ApplyIcon(ico, iconName)
        btn.MouseEnter:Connect(function() Tween(btn, { BackgroundTransparency = 0.55 }) end)
        btn.MouseLeave:Connect(function() Tween(btn, { BackgroundTransparency = 0.82 }) end)
        return btn
    end
    local closeBtn = makeWinBtn(UDim2.new(1, -26, 0.5, -11), self.Theme.Error,    "x",          "Close")
    local minBtn   = makeWinBtn(UDim2.new(1, -51, 0.5, -11), self.Theme.Warning,  "minus",      "Minimize")
    local maxBtn   = makeWinBtn(UDim2.new(1, -76, 0.5, -11), self.Theme.Success,  "maximize-2", "Maximize")

    closeBtn.MouseButton1Click:Connect(function()
        Tween(main, { Size = UDim2.new(0, 0, 0, 0) }, 0.25)
        task.delay(0.26, function()
            if self._unloadFn then pcall(self._unloadFn) end
            gui:Destroy()
        end)
    end)
    local minimised = false
    minBtn.MouseButton1Click:Connect(function()
        minimised = not minimised
        Tween(main, { Size = minimised and UDim2.new(0, WIN_W, 0, 36) or UDim2.new(0, WIN_W, 0, WIN_H) }, 0.22)
        Tween(minBtn, { BackgroundTransparency = minimised and 0.45 or 0 })
    end)
    local maximised = false
    maxBtn.MouseButton1Click:Connect(function()
        maximised = not maximised
        local nW = maximised and math.floor(WIN_W * 1.28) or WIN_W
        local nH = maximised and math.floor(WIN_H * 1.28) or WIN_H
        Tween(main, { Size = UDim2.new(0, nW, 0, nH), Position = UDim2.new(0.5, -nW/2, 0.5, -nH/2) }, 0.22)
        Tween(maxBtn, { BackgroundTransparency = maximised and 0.45 or 0 })
    end)

    -- Thin accent line under content header
    Create("Frame", {
        Size = UDim2.new(1, -16, 0, 1), Position = UDim2.new(0, 8, 0, 35),
        BackgroundColor3 = self.Theme.Border, BorderSizePixel = 0, Parent = content
    })

    -- Pages folder (holds tab scroll frames)
    local pages = Instance.new("Folder"); pages.Name = "Pages"; pages.Parent = content

    -- ── Resize handle ─────────────────────────────────────────────
    local resizeHandle = Create("ImageButton", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(1, -14, 1, -14),
        BackgroundTransparency = 1, ImageColor3 = self.Theme.TextMuted,
        ZIndex = 5, Parent = main
    })
    self:ApplyIcon(resizeHandle, "corner-down-right")
    self:RegisterElement(resizeHandle, "TextMuted", "ImageColor3")

    local resizing = false; local resizeStart, startSize
    resizeHandle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true; resizeStart = i.Position
            startSize = Vector2.new(main.AbsoluteSize.X, main.AbsoluteSize.Y)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if resizing and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - resizeStart
            local nW = math.max(420, startSize.X + d.X)
            local nH = math.max(300, startSize.Y + d.Y)
            main.Size = UDim2.new(0, nW, 0, nH)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
    end)

    -- ── Draggable ─────────────────────────────────────────────────
    MakeDraggable(sideHeader, main)
    MakeDraggable(contentHeader, main)

    -- ── Toggle keybind ────────────────────────────────────────────
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == keybind then
            self:Toggle()
        end
    end)

    -- ── Loading screen ────────────────────────────────────────────
    local mainScale = Instance.new("UIScale")
    mainScale.Scale = 0
    mainScale.Parent = main
    self._mainWindowScale = mainScale
    self._mainWindow      = main
    main.Visible = false

    -- Phase 1: floating splash text (no background, just text over the game)
    local splashText = Create("TextLabel", {
        Name = "SplashText",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "", TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBlack, TextSize = 32,
        ZIndex = 1200, Parent = gui
    })

    -- Loading card, parented to gui (not main), fully transparent to start
    local loadScreen = Create("Frame", {
        Size = UDim2.fromOffset(340, 100),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = self.Theme.Element,
        BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 1100, Parent = gui
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
        Create("UIStroke", { Color = self.Theme.Border, Thickness = 1, Transparency = 1 }),
    })
    local loadTitle = Create("TextLabel", {
        Size = UDim2.new(1, -40, 0, 26), Position = UDim2.new(0, 20, 0, 14),
        BackgroundTransparency = 1, Text = winName,
        TextColor3 = self.Theme.Text, TextTransparency = 1,
        Font = Enum.Font.GothamBold, TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 1101, Parent = loadScreen
    })
    local loadSub = Create("TextLabel", {
        Size = UDim2.new(1, -40, 0, 18), Position = UDim2.new(0, 20, 0, 44),
        BackgroundTransparency = 1,
        Text = subtitle ~= "" and subtitle or version,
        TextColor3 = self.Theme.TextDim, TextTransparency = 1,
        Font = Enum.Font.Gotham, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 1101, Parent = loadScreen
    })
    local loadStatus = Create("TextLabel", {
        Size = UDim2.new(1, -40, 0, 16), Position = UDim2.new(0, 20, 0, 64),
        BackgroundTransparency = 1, Text = "Loading Assets...",
        TextColor3 = self.Theme.TextDim, TextTransparency = 1,
        Font = Enum.Font.GothamMedium, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 1101, Parent = loadScreen
    })
    local loadWater = Create("TextLabel", {
        Size = UDim2.new(1, -15, 0, 15), Position = UDim2.new(0, 0, 1, -18),
        BackgroundTransparency = 1, Text = "Seisen Library",
        TextColor3 = self.Theme.TextMuted or self.Theme.TextDim, TextTransparency = 1,
        Font = Enum.Font.Gotham, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 1101, Parent = loadScreen
    })

    task.spawn(function()
        -- Key System gate (runs before splash if Key/Keys option set)
        if options.Key or options.Keys then
            local keyPassed = false
            self:_ShowKeySystem(options, function() keyPassed = true end)
            repeat task.wait(0.08) until keyPassed
        end

        -- Phase 1: typewriter (floating text, no background)
        local fullText = "Seisen Library"
        for i = 1, #fullText do
            splashText.Text = fullText:sub(1, i)
            task.wait(0.06)
        end
        task.wait(1)
        local fadeTween = TweenService:Create(splashText, TweenInfo.new(0.6), { TextTransparency = 1 })
        fadeTween:Play(); fadeTween.Completed:Wait()
        splashText:Destroy()
        task.wait(0.2)

        -- Loading card fade-in
        local stroke = loadScreen:FindFirstChildWhichIsA("UIStroke")
        Tween(loadScreen, { BackgroundTransparency = 0.06 }, 0.35)
        if stroke then Tween(stroke, { Transparency = 0.25 }, 0.35) end
        Tween(loadTitle,  { TextTransparency = 0 }, 0.35)
        Tween(loadSub,    { TextTransparency = 0 }, 0.35)
        Tween(loadStatus, { TextTransparency = 0 }, 0.35)
        Tween(loadWater,  { TextTransparency = 0 }, 0.35)
        task.wait(0.5)

        loadStatus.Text = "Loading Assets..."
        task.wait(0.55)
        loadStatus.Text = "Initializing UI..."
        task.wait(0.55)
        loadStatus.Text = "Complete!"
        task.wait(0.45)

        -- Phase 3: fade out loading card
        Tween(loadScreen, { BackgroundTransparency = 1 }, 0.35)
        if stroke then Tween(stroke, { Transparency = 1 }, 0.35) end
        Tween(loadTitle,  { TextTransparency = 1 }, 0.35)
        Tween(loadSub,    { TextTransparency = 1 }, 0.35)
        Tween(loadStatus, { TextTransparency = 1 }, 0.35)
        Tween(loadWater,  { TextTransparency = 1 }, 0.35)
        task.wait(0.4)
        pcall(function() loadScreen:Destroy() end)

        -- Phase 4: scale in main window
        main.Visible = true
        TweenService:Create(mainScale, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Scale = 1 }):Play()
    end)

    -- ── Tab & sidebar API ─────────────────────────────────────────
    local tabOrder   = 0
    local tabList    = {}   -- { name, page, sideBtn }
    local activeTab  = nil

    local function switchTab(entry)
        if activeTab then
            activeTab.page.Visible = false
            Tween(activeTab.btn, { BackgroundColor3 = Color3.new(0,0,0) })
            Tween(activeTab.btn, { BackgroundTransparency = 1 })
            local lbl = activeTab.btn:FindFirstChildWhichIsA("TextLabel")
            local ico = activeTab.btn:FindFirstChild("_icon")
            if lbl then Tween(lbl, { TextColor3 = self.Theme.TextDim }) end
            if ico then Tween(ico, { ImageColor3 = self.Theme.TextDim }) end
        end
        activeTab = entry
        entry.page.Visible = true
        Tween(entry.btn, { BackgroundColor3 = self.Theme.SidebarActive, BackgroundTransparency = 0 })
        local lbl = entry.btn:FindFirstChildWhichIsA("TextLabel")
        local ico = entry.btn:FindFirstChild("_icon")
        if lbl then Tween(lbl, { TextColor3 = self.Theme.Text }) end
        if ico then Tween(ico, { ImageColor3 = self.Theme.Accent }) end
        activeTitle.Text = entry.name
    end

    -- ── Window object ─────────────────────────────────────────────
    local Window = {}

    function Window:AddSidebarSection(label)
        Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text = label:upper(),
            TextColor3 = Library.Theme.TextMuted,
            Font = Enum.Font.GothamBold, TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = tabOrder, Parent = sideScroll
        })
        tabOrder = tabOrder + 1
    end

    function Window:AddSidebarDivider()
        Create("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = Library.Theme.Border,
            BorderSizePixel = 0, LayoutOrder = tabOrder, Parent = sideScroll
        })
        tabOrder = tabOrder + 1
    end

    function Window:AddTab(name, iconName)
        tabOrder = tabOrder + 1
        local page = Create("ScrollingFrame", {
            Name = name, Size = UDim2.new(1, 0, 1, -38),
            Position = UDim2.new(0, 0, 0, 38),
            BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 3, ScrollBarImageColor3 = Library.Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false, Parent = content
        }, {
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 0),
                FillDirection = Enum.FillDirection.Horizontal,
                Wraps = false
            }),
            Create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) })
        })

        -- Auto-grow canvas
        local ll = page:FindFirstChildWhichIsA("UIListLayout")
        ll.Changed:Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, ll.AbsoluteContentSize.Y + 16)
        end)

        -- Sidebar pill button
        local btn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = Color3.new(0,0,0),
            BackgroundTransparency = 1,
            Text = "", AutoButtonColor = false,
            LayoutOrder = tabOrder, Parent = sideScroll
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        })

        -- Icon
        local iconImg; do
            local iconData = Library:GetIcon(iconName or "")
            if iconData and Library.Icons then
                iconImg = Create("ImageLabel", {
                    Name = "_icon",
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(0, 10, 0.5, -7),
                    BackgroundTransparency = 1,
                    Image = iconData.Image or "",
                    ImageRectOffset = iconData.ImageRectOffset or Vector2.new(0,0),
                    ImageRectSize = iconData.ImageRectSize or Vector2.new(0,0),
                    ImageColor3 = Library.Theme.TextDim,
                    Parent = btn
                })
            end
        end

        local lbl = Create("TextLabel", {
            Size = UDim2.new(1, iconImg and -28 or -12, 1, 0),
            Position = UDim2.new(0, iconImg and 28 or 10, 0, 0),
            BackgroundTransparency = 1, Text = name,
            TextColor3 = Library.Theme.TextDim,
            Font = Enum.Font.GothamMedium, TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = btn
        })

        -- Hover effect
        btn.MouseEnter:Connect(function()
            if activeTab and activeTab.btn == btn then return end
            Tween(btn, { BackgroundColor3 = Library.Theme.SidebarActive, BackgroundTransparency = 0 })
        end)
        btn.MouseLeave:Connect(function()
            if activeTab and activeTab.btn == btn then return end
            Tween(btn, { BackgroundTransparency = 1 })
        end)

        local entry = { name = name, page = page, btn = btn }
        table.insert(tabList, entry)
        btn.MouseButton1Click:Connect(function() switchTab(entry) end)

        -- First tab auto-activates
        if #tabList == 1 then switchTab(entry) end

        -- Two-column layout helpers
        local leftCol, rightCol

        local function ensureColumns()
            if leftCol then return end
            local colLayout = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = 1, Parent = page
            }, {
                Create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 8),
                    VerticalAlignment = Enum.VerticalAlignment.Top
                })
            })
            leftCol = Create("Frame", {
                Size = UDim2.new(0.5, -4, 0, 0),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = 1, Parent = colLayout
            }, { Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) }) })
            rightCol = Create("Frame", {
                Size = UDim2.new(0.5, -4, 0, 0),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = 2, Parent = colLayout
            }, { Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) }) })
        end

        local Tab = {}

        function Tab:AddLeftSection(sectionName, iconName2)
            ensureColumns()
            return Library:CreateSection(leftCol, sectionName, iconName2)
        end
        function Tab:AddRightSection(sectionName, iconName2)
            ensureColumns()
            return Library:CreateSection(rightCol, sectionName, iconName2)
        end
        function Tab:CreateSection(opts)
            ensureColumns()
            local side = opts and opts.Side or "Left"
            local col  = (side == "Right") and rightCol or leftCol
            return Library:CreateSection(col, opts and opts.Name or "Section", nil)
        end

        return Tab
    end

    function Window:SetScale(s) Library:SetScale(s) end

    return Window
end

-- ================================================================
-- PHASE 5 · Section System + AddXxx methods
-- ================================================================

-- ── CreateSection ────────────────────────────────────────────────
-- Returns a section object with all AddXxx methods the original API exposes.
function Library:CreateSection(parent, name, iconName)
    local SECTION_ORDER = 0

    local section = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = self.Theme.Element,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = parent
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
        Create("UIStroke", { Color = self.Theme.Border, Thickness = 1 })
    })
    self:RegisterElement(section, "Element")
    self:RegisterElement(section:FindFirstChildWhichIsA("UIStroke"), "Border", "Color")

    -- Section header bar
    local header = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = self.Theme.InputBg,
        BorderSizePixel = 0, Parent = section
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 10) })
    })
    -- Squared bottom corners via overlay
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = self.Theme.InputBg, BorderSizePixel = 0, Parent = header
    })
    self:RegisterElement(header, "InputBg")

    -- Section icon (optional)
    local iconOffset = 10
    if iconName then
        local iconData = self:GetIcon(iconName)
        if iconData and self.Icons then
            Create("ImageLabel", {
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(0, 10, 0.5, -6),
                BackgroundTransparency = 1,
                Image = iconData.Image or "",
                ImageRectOffset = iconData.ImageRectOffset or Vector2.new(0,0),
                ImageRectSize = iconData.ImageRectSize or Vector2.new(0,0),
                ImageColor3 = self.Theme.Accent, Parent = header
            })
            iconOffset = 28
        end
    end

    local titleLabel = Create("TextLabel", {
        Size = UDim2.new(1, -(iconOffset + 8), 1, 0),
        Position = UDim2.new(0, iconOffset, 0, 0),
        BackgroundTransparency = 1, Text = name or "",
        TextColor3 = self.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = header
    })
    self:RegisterElement(titleLabel, "Text", "TextColor3")

    -- Content container
    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 28),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = section
    }, {
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) }),
        Create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 8) })
    })

    local function nextOrder() SECTION_ORDER = SECTION_ORDER + 1; return SECTION_ORDER end

    -- ── Section object with all AddXxx ───────────────────────────
    local S = {}

    function S:AddLabel(opts)
        local f = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = container
        })
        return Library:CreateLabel(f, opts)
    end

    function S:AddButton(opts)
        local f = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1,
            LayoutOrder = nextOrder(), Parent = container
        })
        return Library:CreateButton(f, opts)
    end

    function S:AddToggle(opts)
        local f = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = container
        })
        return Library:CreateToggle(f, opts)
    end

    function S:AddSlider(opts)
        local f = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = container
        })
        return Library:CreateSlider(f, opts)
    end

    function S:AddKeybind(opts)
        local f = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = container
        })
        return Library:CreateKeybind(f, opts)
    end

    function S:AddDropdown(opts)
        local f = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = container
        })
        return Library:CreateDropdown(f, opts)
    end

    function S:AddTextbox(opts)
        local f = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = container
        })
        return Library:CreateTextbox(f, opts)
    end

    function S:AddCheckbox(opts)
        local f = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = container
        })
        return Library:CreateCheckbox(f, opts)
    end

    function S:AddColorPicker(opts)
        local f = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = container
        })
        return Library:CreateColorPicker(f, opts)
    end

    function S:AddProgressBar(opts)
        local f = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = container
        })
        return Library:CreateProgressBar(f, opts)
    end

    function S:AddImage(opts)
        local f = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = container
        })
        return Library:CreateImage(f, opts)
    end

    function S:AddViewport(opts)
        local f = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = container
        })
        return Library:CreateViewport(f, opts)
    end

    function S:AddDependencyBox(opts)
        local f = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = container
        })
        return Library:CreateDependencyBox(f, opts)
    end

    function S:AddTooltipLabel(opts)
        local f = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = container
        })
        return Library:CreateTooltipLabel(f, opts)
    end

    function S:AddSearchableDropdown(opts)
        local f = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = container
        })
        return Library:CreateSearchableDropdown(f, opts)
    end

    function S:AddDivider(text)
        local f = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = container
        })
        return Library:CreateDivider(f, type(text) == "string" and { Text = text } or text)
    end

    -- Inline tabbox inside a section
    function S:AddLeftTabbox(opts)
        opts = opts or {}; opts.Side = "Left"
        local f = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = container
        })
        return Library:CreateTabbox(f, opts)
    end
    function S:AddRightTabbox(opts)
        opts = opts or {}; opts.Side = "Right"
        local f = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = container
        })
        return Library:CreateTabbox(f, opts)
    end

    function S:AddParagraph(opts)
        local f = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = container
        })
        return Library:CreateParagraph(f, opts)
    end

    function S:AddBadge(opts)
        local f = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1,
            LayoutOrder = nextOrder(), Parent = container
        })
        return Library:CreateBadge(f, opts)
    end

    function S:AddSpace(height)
        local f = Create("Frame", {
            Size = UDim2.new(1, 0, 0, type(height) == "number" and height or 8),
            BackgroundTransparency = 1, LayoutOrder = nextOrder(), Parent = container
        })
        return {}
    end

    function S:AddCodeBlock(opts)
        local h = (opts and opts.Height or 58) + 26
        local f = Create("Frame", {
            Size = UDim2.new(1, 0, 0, h), BackgroundTransparency = 1,
            LayoutOrder = nextOrder(), Parent = container
        })
        return Library:CreateCodeBlock(f, opts)
    end

    function S:AddMultiButton(opts)
        local f = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1,
            LayoutOrder = nextOrder(), Parent = container
        })
        return Library:CreateMultiButton(f, opts)
    end

    function S:AddTabSection(opts)
        local f = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = container
        })
        return Library:CreateTabSection(f, opts)
    end

    function S:AddHStack(opts)
        local f = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = container
        })
        return Library:CreateHStack(f, opts)
    end

    function S:AddVStack(opts)
        local f = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = container
        })
        return Library:CreateVStack(f, opts)
    end

    -- SaveManager compatibility: tab:CreateSection({Name,Side})
    -- already handled in Tab:CreateSection above; expose on Section too
    function S:CreateSection(opts)
        return Library:CreateSection(container, opts and opts.Name or "Section", nil)
    end

    return S
end

-- ── AddSidebarSection alias ──────────────────────────────────────
-- ThemeManager calls Library:BuildThemeSection(tab) which in turn
-- calls tab:AddRightSection or tab:CreateSection. Both are wired
-- through Tab (from Window:AddTab), so nothing extra needed here.

-- ================================================================
-- PHASE 6 · Config Settings built-in tab
-- ================================================================

-- Called by CreateWindow if options.ConfigSettings == true
-- Inserts WalkSpeed / JumpPower / Fly / AntiAFK / FPS-boost toggles
-- into the content as a dedicated internal page accessible via the
-- sidebar.  Exposed as a real AddTab so ThemeManager / SaveManager
-- still get a normal SettingsTab to build into.
function Library:_BuildConfigTab(window)
    window:AddSidebarDivider()
    window:AddSidebarSection("Player")
    local configTab = window:AddTab("Config", "cog")
    local configLeft = configTab:AddLeftSection("Character", "person-standing")

    -- WalkSpeed
    configLeft:AddSlider({
        Name = "WalkSpeed", Min = 8, Max = 200, Default = 16,
        Flag = "CFG_WalkSpeed",
        Callback = function(v)
            pcall(function()
                LocalPlayer.Character.Humanoid.WalkSpeed = v
            end)
        end
    })
    -- JumpPower
    configLeft:AddSlider({
        Name = "JumpPower", Min = 7, Max = 300, Default = 50,
        Flag = "CFG_JumpPower",
        Callback = function(v)
            pcall(function()
                LocalPlayer.Character.Humanoid.JumpPower = v
            end)
        end
    })

    local configRight = configTab:AddRightSection("Misc", "sparkles")
    -- Anti AFK
    configRight:AddToggle({
        Name = "Anti AFK", Flag = "CFG_AntiAFK", Default = false,
        Callback = function(v)
            if v then
                local VPS = game:GetService("VirtualUser")
                LocalPlayer.Idled:Connect(function()
                    VPS:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    VPS:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end)
            end
        end
    })
    -- FPS Boost
    configRight:AddToggle({
        Name = "FPS Boost", Flag = "CFG_FPSBoost", Default = false,
        Callback = function(v)
            local ls = game:GetService("Lighting")
            if v then
                ls.GlobalShadows = false
                ls.FogEnd = 9e9
                game:GetService("RenderSettings").QualityLevel = Enum.QualityLevel.Level01
            else
                ls.GlobalShadows = true
                game:GetService("RenderSettings").QualityLevel = Enum.QualityLevel.Automatic
            end
        end
    })
    -- Fullbright
    configRight:AddToggle({
        Name = "Fullbright", Flag = "CFG_Fullbright", Default = false,
        Callback = function(v)
            pcall(function()
                game:GetService("Lighting").Brightness = v and 2 or 1
                game:GetService("Lighting").ClockTime  = v and 14 or 14
            end)
        end
    })

    return configTab
end

-- ================================================================
-- PHASE 7 · Widget · Profile · Keybind panel · Final wiring
-- ================================================================

-- ── Widget (floating mini HUD) ────────────────────────────────────
function Library:CreateWidget(options)
    if not self.ScreenGui then return end
    local opts     = options or {}
    local title    = opts.Title or "Seisen"
    local showFPS  = opts.ShowFPS ~= false
    local showPing = opts.ShowPing ~= false

    local widget = Create("Frame", {
        Name = "Widget",
        Size = UDim2.new(0, 130, 0, 52),
        Position = UDim2.new(0, 12, 0, 12),
        BackgroundColor3 = self.Theme.Element,
        BorderSizePixel = 0, ZIndex = 10,
        Parent = self.ScreenGui
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
        Create("UIStroke", { Color = self.Theme.Border, Thickness = 1 })
    })
    self:RegisterElement(widget, "Element")

    -- Circular accent icon
    local iconCircle = Create("Frame", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(0, 10, 0.5, -16),
        BackgroundColor3 = self.Theme.Accent, ZIndex = 11, Parent = widget
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Create("TextLabel", {
            Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
            Text = title:sub(1,1):upper(), TextColor3 = Color3.new(1,1,1),
            Font = Enum.Font.GothamBold, TextSize = 14, ZIndex = 12
        })
    })
    self:RegisterElement(iconCircle, "Accent")

    local titleLbl = Create("TextLabel", {
        Size = UDim2.new(1, -52, 0, 14), Position = UDim2.new(0, 48, 0, 8),
        BackgroundTransparency = 1, Text = title,
        TextColor3 = self.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11, Parent = widget
    })
    self:RegisterElement(titleLbl, "Text", "TextColor3")

    local statsLbl = Create("TextLabel", {
        Size = UDim2.new(1, -52, 0, 12), Position = UDim2.new(0, 48, 0, 26),
        BackgroundTransparency = 1, Text = "",
        TextColor3 = self.Theme.TextDim, Font = Enum.Font.Gotham, TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11, Parent = widget
    })
    self:RegisterElement(statsLbl, "TextDim", "TextColor3")

    -- Stats update loop
    local statsConn = RunService.Heartbeat:Connect(function()
        local parts = {}
        if showFPS then
            table.insert(parts, math.floor(1 / RunService.RenderStepped:Wait()) .. " FPS")
        end
        if showPing then
            local ping = Stats.Network.ServerStatsItem and
                Stats.Network.ServerStatsItem["Data Ping"] and
                Stats.Network.ServerStatsItem["Data Ping"]:GetValue() or 0
            table.insert(parts, math.floor(ping) .. "ms")
        end
        statsLbl.Text = table.concat(parts, "  ·  ")
    end)

    MakeDraggable(widget, widget)

    return { Instance = widget, _statsConn = statsConn }
end

-- ── Profile section builder ───────────────────────────────────────
-- Inserts avatar / name / username row into a section.
function Library:BuildProfileSection(section)
    local lp = LocalPlayer
    local nameStr  = lp.DisplayName
    local userStr  = "@" .. lp.Name

    local row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1
    })

    -- Avatar thumbnail
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size48x48
    local imgUrl    = ""
    pcall(function()
        imgUrl = Players:GetUserThumbnailAsync(lp.UserId, thumbType, thumbSize)
    end)
    local avatar = Create("ImageLabel", {
        Size = UDim2.new(0, 38, 0, 38), Position = UDim2.new(0, 0, 0.5, -19),
        BackgroundColor3 = self.Theme.InputBg, Image = imgUrl, Parent = row
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Create("UIStroke", { Color = self.Theme.Accent, Thickness = 1.5 })
    })
    self:RegisterElement(avatar, "InputBg")

    Create("TextLabel", {
        Size = UDim2.new(1, -48, 0, 18), Position = UDim2.new(0, 46, 0, 5),
        BackgroundTransparency = 1, Text = nameStr,
        TextColor3 = self.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row
    })
    Create("TextLabel", {
        Size = UDim2.new(1, -48, 0, 12), Position = UDim2.new(0, 46, 0, 24),
        BackgroundTransparency = 1, Text = userStr,
        TextColor3 = self.Theme.TextDim, Font = Enum.Font.Gotham, TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row
    })

    if section and section.AddImage then
        -- section is a Section object — wrap raw frame
    end
    -- return the raw frame so caller can parent it
    return row
end

-- ── Keybind panel builder ─────────────────────────────────────────
-- Builds the floating keybind overlay for all registered rows.
function Library:BuildKeybindPanel()
    if not self.ScreenGui then return end
    if self.KeybindFrame then return end

    local panel = Create("Frame", {
        Name = "KeybindPanel",
        Size = UDim2.new(0, 200, 0, 0),
        Position = UDim2.new(0, 12, 1, -12),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = self.Theme.Element,
        BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 20, Visible = false, Parent = self.ScreenGui
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
        Create("UIStroke", { Color = self.Theme.Border, Thickness = 1 }),
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) }),
        Create("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })
    })
    self:RegisterElement(panel, "Element")
    self.KeybindFrame = panel

    local emptyHint = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1,
        Text = "No keybinds set.", TextColor3 = self.Theme.TextMuted,
        Font = Enum.Font.Gotham, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Center,
        LayoutOrder = 999, Parent = panel
    })

    self._refreshKeybindEmptyHint = function()
        emptyHint.Visible = #self.KeybindRows == 0
        panel.Visible     = #self.KeybindRows > 0
    end
    self:_refreshKeybindEmptyHint()
end

-- ── Final wiring: patch CreateWindow to attach config tab ─────────
do
    local _orig = Library.CreateWindow
    Library.CreateWindow = function(self, options)
        local win = _orig(self, options)
        if options and options.ConfigSettings then
            self:_BuildConfigTab(win)
        end
        -- Build the keybind panel once the gui exists
        task.defer(function() self:BuildKeybindPanel() end)
        return win
    end
end

-- ── SetGameId ─────────────────────────────────────────────────────
-- Already defined in Phase 1 — kept compatible.

return Library

