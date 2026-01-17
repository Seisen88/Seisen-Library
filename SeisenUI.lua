local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- Load Lucide icons (from our own source)
local IconsLoaded, Icons = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Seisen88/Seisen-Library/main/addons/source.lua"))()
end)

local Library = {
    Toggles = {},
    Options = {},
    Labels = {},
    Flags = {},
    Registry = {}, -- For live theme updates
    OpenDropdowns = {}, -- Track open dropdowns for click-away
    ScreenGui = nil, -- Reference to main GUI
    Icons = IconsLoaded and Icons or nil, -- Lucide icons module
    Theme = {
        Background = Color3.fromRGB(15, 15, 18), -- Darker Black/Gray
        Sidebar = Color3.fromRGB(12, 12, 14),
        SidebarActive = Color3.fromRGB(25, 25, 28),
        Content = Color3.fromRGB(20, 20, 24),
        Element = Color3.fromRGB(25, 25, 30),
        ElementHover = Color3.fromRGB(35, 35, 40),
        Border = Color3.fromRGB(45, 45, 50),
        Accent = Color3.fromRGB(0, 200, 100), -- Green
        AccentHover = Color3.fromRGB(0, 220, 110),
        Text = Color3.fromRGB(240, 240, 240),
        TextDim = Color3.fromRGB(140, 140, 150),
        TextMuted = Color3.fromRGB(80, 80, 90),
        Toggle = Color3.fromRGB(0, 200, 100), -- Green
        ToggleOff = Color3.fromRGB(40, 40, 45)
    },
    ToggleKeybind = nil -- Global toggle keybind
}



-- Registry functions for live theme updates
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

-- Close all open dropdowns
function Library:CloseAllDropdowns()
    for _, dropdown in ipairs(self.OpenDropdowns) do
        if dropdown.Close then
            dropdown.Close()
        end
    end
    self.OpenDropdowns = {}
end

-- Get Lucide icon by name
-- Returns: { Url, ImageRectOffset, ImageRectSize } or nil
-- Get Lucide icon or custom asset
-- Returns: { Url, ImageRectOffset, ImageRectSize } or nil
function Library:GetIcon(iconName)
    if not iconName or iconName == "" then return nil end
    
    -- 1. Try Lucide (returns table)
    if self.Icons then
        local success, icon = pcall(function()
            return self.Icons.GetAsset(iconName)
        end)
        if success and icon then
            return icon
        end
    end
    
    -- 2. Fallback: Treat as Custom Asset ID (Return normalized table)
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

-- Utilities
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

-- Tooltip System
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
    
    -- Update tooltip position on mouse move
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
    -- Constrain to 280px (300 max - 20 padding) to account for wrapping
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

-- Common Properties Helper
-- Applies: Tooltip, DisabledTooltip, Disabled, Visible, Risky to any element
function Library:ApplyCommonProperties(element, options, elementObj)
    local theme = self.Theme
    local tooltip = options.Tooltip
    local disabledTooltip = options.DisabledTooltip
    local isDisabled = options.Disabled or false
    local isVisible = options.Visible ~= false -- Default true
    local isRisky = options.Risky or false
    
    -- Store state
    elementObj._disabled = isDisabled
    elementObj._visible = isVisible
    elementObj._tooltip = tooltip
    elementObj._disabledTooltip = disabledTooltip
    elementObj._risky = isRisky
    
    -- Apply initial visibility
    element.Visible = isVisible
    
    -- Apply risky styling (red/orange accent)
    if isRisky then
        local riskyColor = Color3.fromRGB(255, 100, 80)
        -- Find text labels and buttons to apply risky color
        for _, child in pairs(element:GetDescendants()) do
            if child:IsA("TextLabel") and child.Name ~= "Value" then
                -- child.TextColor3 = riskyColor
            end
        end
    end
    
    -- Apply disabled state
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
    
    -- Tooltip on hover
    if tooltip or disabledTooltip then
        element.MouseEnter:Connect(function()
            local currentTooltip = elementObj._disabled and elementObj._disabledTooltip or elementObj._tooltip
            if not currentTooltip then return end
            
            -- Cancel any pending tooltip
            if Library.TooltipThread then task.cancel(Library.TooltipThread) end
            
            -- Delay before showing (1.5 seconds)
            Library.TooltipThread = task.delay(1.5, function()
                Library:ShowTooltip(currentTooltip)
            end)
        end)
        
        element.MouseLeave:Connect(function()
            Library:HideTooltip()
        end)
    end
    
    -- SetVisible method
    function elementObj:SetVisible(visible)
        self._visible = visible
        element.Visible = visible
    end
    
    -- SetDisabled method
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
    
    -- SetTooltip method
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
    
    -- Click handling with DoubleClick and Confirm support
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
        
        -- Confirm text functionality
        if confirmText and not waitingConfirm then
            waitingConfirm = true
            btn.Text = confirmText
            return
        end
        waitingConfirm = false
        btn.Text = btnName
        
        -- Double click functionality
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
    
    -- Apply common properties
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
        Size = UDim2.new(1, -130, 1, 0),
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
    
    -- Apply common properties
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
    
    -- Helper to format the value with prefix/suffix
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
            -- Apply increment rounding
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
        if i.UserInputType == Enum.UserInputType.MouseButton1 then 
            if sliderObj._disabled then return end
            sliding = true
            
            -- Immediately set value based on click position
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
                -- Recalculate barWidth each frame to account for scaling
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
            
            -- Disconnect on release
            local releaseConnection
            releaseConnection = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = false
                    connection:Disconnect()
                    releaseConnection:Disconnect()
                end
            end)
        end 
    end)
    
    -- Apply common properties
    self:ApplyCommonProperties(slider, options, sliderObj)
    
    if flag then self.Options[flag] = sliderObj end
    return sliderObj
end

function Library:CreateDropdown(parent, options)
    local dropName = options.Name or "Dropdown"
    local opts = options.Options or {}
    local default = options.Default or opts[1]
    local callback = options.Callback or function() end
    local flag = options.Flag
    
    -- Dropdown state
    local isOpen = false
    local currentVal = default
    
    local drop = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundTransparency = 1,
        ClipsDescendants = false, -- Important for overlay
        Parent = parent,
        ZIndex = 10 -- Higher ZIndex to float above
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
        Text = tostring(currentVal),
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
    
    -- Dropdown List Container
    local list = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 5),
        BackgroundColor3 = self.Theme.Sidebar,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = self.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        ZIndex = 20, -- Topmost
        Parent = selectBtn -- Parented to button so it moves with it
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
        Create("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}),
        Create("UIPadding", {PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5)}),
        Create("UIStroke", {Color = self.Theme.Border, Thickness = 1})
    })
    
    local dropObj = {
        Value = currentVal,
        SetValue = function(s, val)
            currentVal = val
            s.Value = val
            displayLabel.Text = tostring(val)
            callback(val)
            
            -- Close
            isOpen = false
            list.Visible = false
            Tween(arrow, {Rotation = 0})
            
            -- Update Highlight
            for _, child in pairs(list:GetChildren()) do
                if child:IsA("TextButton") then
                    child.TextColor3 = (child.Text == tostring(val)) and self.Theme.Accent or self.Theme.TextDim
                end
            end
        end
    }
    
    local function populate()
        for _, child in pairs(list:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        for _, opt in ipairs(opts) do
            local btn = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Text = tostring(opt),
                TextColor3 = (opt == currentVal) and self.Theme.Accent or self.Theme.TextDim,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = list,
                ZIndex = 21
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
    
    selectBtn.MouseButton1Click:Connect(function()
        if not isOpen then
            self:CloseAllDropdowns()
        end
        
        isOpen = not isOpen
        list.Visible = isOpen
        Tween(arrow, {Rotation = isOpen and 180 or 0})
        
        if isOpen then
            table.insert(self.OpenDropdowns, {Close = function() 
                isOpen = false
                list.Visible = false
                Tween(arrow, {Rotation = 0})
            end})
        end
    end)
    
    table.insert(self.Registry, {
        Callback = function(theme)
            local tTheme = theme or self.Theme
            for _, child in pairs(list:GetChildren()) do
                if child:IsA("TextButton") then
                    child.TextColor3 = (child.Text == tostring(currentVal)) and tTheme.Accent or tTheme.TextDim
                end
            end
        end
    })
    
    if flag then self.Options[flag] = dropObj end
    return dropObj
end

-- Toggle UI visibility
function Library:Toggle()
    if self.ScreenGui then
        self.ScreenGui.Enabled = not self.ScreenGui.Enabled
    end
end

-- Unload/Destroy UI
function Library:Unload()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
        self.ScreenGui = nil
    end
end

-- Helper function to create a tabbox (used by AddLeftTabbox/AddRightTabbox)
local function createTabbox(name, parent, theme, gui, Create, Tween, Library)
    local tabbox = Create("Frame", {
        Name = name or "Tabbox",
        Size = UDim2.new(1, 0, 0, 150),
        BackgroundColor3 = theme.Element,
        BackgroundTransparency = 0.5,
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
    
    -- Tab Header (buttons)
    local tabHeader = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Parent = tabbox
    }, {
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
    })
    
    -- Tab Content Container
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
    
    -- Forward declare update function
    local updateTabboxSize
    
    function TabboxFuncs:AddTab(tabName)
        local tabBtn = Create("TextButton", {
            Size = UDim2.new(0, 70, 1, 0),
            BackgroundColor3 = theme.ToggleOff,
            BackgroundTransparency = 0.5,
            Text = tabName,
            TextColor3 = theme.TextDim,
            Font = Enum.Font.GothamMedium,
            TextSize = 11,
            AutoButtonColor = false,
            Parent = tabHeader
        }, {Create("UICorner", {CornerRadius = UDim.new(0, 4)})})
        
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
        
        -- Connect to size changes (Once per tab)
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
        
        -- Return TabPageFuncs with element creation methods
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
        
        return TabPageFuncs
    end
    
    -- Auto-resize tabbox based on content
    local updateThread
    updateTabboxSize = function()
        if updateThread then task.cancel(updateThread) end
        updateThread = task.defer(function()
            task.wait() -- Wait one frame for layout to update
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
    local name = options.Name or options.Title or "Seisen UI"
    local theme = options.Theme or self.Theme
    
    -- Remove existing UI if present
    if RunService:IsStudio() then
        if LocalPlayer.PlayerGui:FindFirstChild("SeisenUI") then
            LocalPlayer.PlayerGui.SeisenUI:Destroy()
        end
    else
        if game.CoreGui:FindFirstChild("SeisenUI") then
            game.CoreGui.SeisenUI:Destroy()
        end
    end

    -- Screen GUI
    local gui = Create("ScreenGui", {
        Name = "SeisenUI",
        Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game.CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    self.ScreenGui = gui
    
    -- Main Frame
    local main = Create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 600, 0, 600), -- Wider default size
        Position = UDim2.new(0.5, -300, 0.5, -300),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Parent = gui
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 8)})
    })
    
    local mainScale = Instance.new("UIScale")
    mainScale.Parent = main
    self.MainScale = mainScale
    
    -- Register main frame for theme updates
    self:RegisterElement(main, "Background")
    
    -- Sidebar
    local sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 150, 1, 0), -- Wider sidebar for full tab names
        BackgroundColor3 = theme.Sidebar,
        BorderSizePixel = 0,
        Parent = main
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 8)})
    })
    
    self:RegisterElement(sidebar, "Sidebar")
    
    -- Cover right corners of sidebar
    local sidebarCover = Create("Frame", {
        Size = UDim2.new(0, 10, 1, 0),
        Position = UDim2.new(1, -10, 0, 0),
        BackgroundColor3 = theme.Sidebar,
        BorderSizePixel = 0,
        Parent = sidebar
    })
    
    self:RegisterElement(sidebarCover, "Sidebar")
    
    -- Window Controls (Traffic Lights) - Top Left of Sidebar
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
            ImageTransparency = 1, -- Initial hidden
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

    -- Close (Red), Minimize (Yellow), Maximize/Expand (Green)
    local closeBtn = createTrafficLight(Color3.fromRGB(255, 95, 87), function() Library:Unload() end, "rbxassetid://10747384351") -- lucide 'x'
    local minBtn = createTrafficLight(Color3.fromRGB(255, 189, 46), nil, "rbxassetid://10747384534") -- Connected later
    local maxBtn = createTrafficLight(Color3.fromRGB(39, 201, 63), nil, "rbxassetid://10747384661") -- Connected later

    -- Search Bar
    local searchContainer = Create("Frame", {
        Name = "SidebarSearch",
        Size = UDim2.new(1, -20, 0, 32),
        Position = UDim2.new(0, 10, 0, 40),
        BackgroundColor3 = theme.Background, -- Slightly darker/lighter than sidebar
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
    
    -- Search Filtering (defined after tabList and pages are created)

    -- Tab List
    local tabList = Create("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, 0, 1, -130), -- Adjusted for header/search + profile
        Position = UDim2.new(0, 0, 0, 80), -- Pushed down by controls + search
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
    
    -- Forward declare pages (defined later)
    local pages
    
    -- Content Search (filters sections inside pages - shows ENTIRE section if any content matches)
    local function contentSearch(query)
        query = query:lower()
        
        if not pages then return end
        
        -- Search through all page content
        for _, pageFrame in ipairs(pages:GetChildren()) do
            if pageFrame:IsA("ScrollingFrame") then
                -- Find Left and Right columns
                local leftCol = pageFrame:FindFirstChild("Left")
                local rightCol = pageFrame:FindFirstChild("Right")
                
                -- Filter sections in both columns
                for _, col in ipairs({leftCol, rightCol}) do
                    if col then
                        for _, section in ipairs(col:GetChildren()) do
                            -- Only filter actual section frames (not layout constraints)
                            if section:IsA("Frame") then
                                if query == "" then
                                    section.Visible = true
                                else
                                    -- Check if ANY text in this section matches
                                    local matches = false
                                    for _, child in ipairs(section:GetDescendants()) do
                                        if (child:IsA("TextLabel") or child:IsA("TextButton")) and child.Text then
                                            if child.Text:lower():find(query, 1, true) then
                                                matches = true
                                                break
                                            end
                                        end
                                    end
                                    -- Show or hide the ENTIRE section
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
    
    -- Watermark
    local watermark = Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 14),
        Position = UDim2.new(0, 10, 1, -75), -- Above Profile
        BackgroundTransparency = 1,
        Text = "UI Library by Seisen",
        TextColor3 = theme.TextMuted,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        Parent = sidebar
    })
    
    self:RegisterElement(watermark, "TextMuted", "TextColor3")

    -- Player Profile Section (at bottom of sidebar)
    local profileSection = Create("Frame", {
        Name = "PlayerProfile",
        Size = UDim2.new(1, -10, 0, 50),
        Position = UDim2.new(0, 5, 1, -55),
        BackgroundColor3 = theme.Element,
        BackgroundTransparency = 0.5,
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
    
    -- Player Avatar
    local avatarImage = Create("ImageLabel", {
        Name = "Avatar",
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(0, 7, 0.5, -18),
        BackgroundColor3 = theme.ToggleOff,
        Image = "", -- Will be set below
        Parent = profileSection
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)})
    })
    
    -- Get player avatar
    pcall(function()
        local userId = LocalPlayer.UserId
        local thumbType = Enum.ThumbnailType.HeadShot
        local thumbSize = Enum.ThumbnailSize.Size100x100
        local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
        avatarImage.Image = content
    end)
    
    -- Player Name
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
    
    -- Player Username (smaller)
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
    
    -- Content Area
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
    
    -- Window Controls (Minimize/Close)
    -- Header Frame (Container for Title and Controls) - Draggable Area
    local header = Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = content,
    })

    -- Stats Widget (Minimized State)
    local widget = Create("Frame", {
        Size = UDim2.new(0, 120, 0, 60),
        Position = UDim2.new(0.1, 0, 0.1, 0),
        BackgroundTransparency = 1, -- Floating look
        Visible = false,
        Parent = gui,
        ZIndex = 200
    })
    
    
    -- Toggle Window Function (Minimize)
    local function toggleWindow(visible)
        main.Visible = visible
        widget.Visible = not visible
    end
    
    -- Maximize/Restore Toggle
    local isMaximized = false
    local normalSize = UDim2.new(0, 600, 0, 500)
    local normalPosition = UDim2.new(0.5, -300, 0.5, -250)
    
    local function toggleMaximize()
        if isMaximized then
            -- Restore to normal size
            Tween(main, {Size = normalSize, Position = normalPosition}, 0.3)
            isMaximized = false
        else
            -- Maximize (fill screen with small padding)
            local screenSize = gui.AbsoluteSize
            Tween(main, {
                Size = UDim2.new(0, screenSize.X - 40, 0, screenSize.Y - 40),
                Position = UDim2.new(0, 20, 0, 20)
            }, 0.3)
            isMaximized = true
        end
    end
    
    -- Connect Traffic Light Buttons
    -- Red: Close window
    -- Yellow: Minimize to widget
    minBtn.MouseButton1Click:Connect(function() toggleWindow(false) end)
    -- Green: Toggle Maximize/Restore
    maxBtn.MouseButton1Click:Connect(function() toggleMaximize() end)

    -- Make Widget Draggable with Click to Restore
    MakeDraggable(widget, widget, function() toggleWindow(true) end)
    
    -- Widget Logo
    local widgetLogo = Create("ImageLabel", {
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0.5, -20, 0, 0), -- Centered top
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.new(0, 0, 0), -- Black
        Parent = widget
    })
    
    -- Apply Icon from options or default
    local widgetIcon = options.Icon or "rbxassetid://7072718336"
    Library:ApplyIcon(widgetLogo, widgetIcon)
    
    -- Round Logo
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = widgetLogo})
    
    -- Seisenhub Text
    local widgetTitle = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 42), -- Below logo
        BackgroundTransparency = 1,
        Text = "Seisenhub",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextStrokeTransparency = 0.5,
        Parent = widget
    })
    
    -- Stats Text (FPS/Ping)
    local widgetStats = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 26),
        Position = UDim2.new(0, 0, 0, 56), -- Below title
        BackgroundTransparency = 1,
        Text = "60 fps\n50 ms",
        TextColor3 = Color3.fromRGB(200, 200, 200),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextStrokeTransparency = 0.5,
        Parent = widget
    })

    -- Buttons


    -- Stats Updater
    local RunService = game:GetService("RunService")
    local Stats = game:GetService("Stats")
    local lastUpdate = 0
    
    RunService.RenderStepped:Connect(function(dt)
        local now = tick()
        if now - lastUpdate > 0.5 and widget.Visible then -- Update every 0.5s when visible
            local fps = math.floor(1 / dt)
            local ping = math.round(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            widgetStats.Text = string.format("%d fps\n%d ms", fps, ping)
            lastUpdate = now
        end
    end)
    
    -- Cover left corners of content
    local contentCover = Create("Frame", {
        Size = UDim2.new(0, 10, 1, 0),
        BackgroundColor3 = theme.Content,
        BorderSizePixel = 0,
        Parent = content
    })
    
    self:RegisterElement(contentCover, "Content")
    
    -- Title
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
    
    -- Breadcrumb (Current Tab Subtitle)
    -- Breadcrumb Removed
    -- local breadcrumb = Create("TextLabel", { ... })
    
    -- self:RegisterElement(breadcrumb, "TextDim", "TextColor3")
    
    -- Badges (Version / SubTitle) - Right Aligned
    if options.Version or options.SubTitle then
        -- titleLabel.Visible = false -- Keep title visible
        
        local badgeContainer = Create("Frame", {
            Name = "BadgeContainer",
            AnchorPoint = Vector2.new(1, 0),
            Size = UDim2.new(0, 300, 1, 0),
            Position = UDim2.new(1, -15, 0, 0), -- Right aligned
            BackgroundTransparency = 1,
            Parent = header
        }, {
             Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal, 
                Padding = UDim.new(0, 8), 
                VerticalAlignment = Enum.VerticalAlignment.Center,
                HorizontalAlignment = Enum.HorizontalAlignment.Right, -- Push items to right
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
                 TextColor3 = Color3.new(0,0,0), -- Black text
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
             createBadge(options.Version, theme.Accent, 1) -- Uses Theme Accent
        end
        
        if options.SubTitle then
             createBadge(options.SubTitle, Color3.fromRGB(64, 164, 255), 2) -- Safe Soft Blue
        end
    end
    
    -- Notification Container (Top Center)
    local notificationContainer = Create("Frame", {
        Name = "NotificationContainer",
        Size = UDim2.new(0, 300, 1, 0),
        Position = UDim2.new(0.5, -150, 0, 10), -- Center Top alignment
        BackgroundTransparency = 1,
        Parent = gui,
        ZIndex = 500
    }, {
        Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Top, -- Start from top
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        }),
        Create("UIPadding", {PaddingTop = UDim.new(0, 10)})
    })

    -- Restore Missing Pages and Logic
    pages = Create("Folder", {Name = "Pages", Parent = content})
    
    MakeDraggable(sidebar, main)
    MakeDraggable(header, main) -- Restrict dragging to Header (Top 50px) only
    
    local resizeHandle = Create("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -16, 1, -16),
        BackgroundTransparency = 1,
        ImageColor3 = theme.TextDim,
        Parent = main,
        ZIndex = 200
    })
    
    Library:ApplyIcon(resizeHandle, "move-diagonal-2") -- Resize icon
    Library:RegisterElement(resizeHandle, "TextDim", "ImageColor3")
    
    local resizing = false
    local minSize = Vector2.new(400, 300)
    
    local ghostFrame = nil
    
    resizeHandle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            local startSize = main.AbsoluteSize
            local startPos = i.Position
            
            local connection
            connection = game:GetService("RunService").RenderStepped:Connect(function()
                if not resizing then
                    connection:Disconnect()
                    return
                end
                
                local mouseProxy = game:GetService("Players").LocalPlayer:GetMouse()
                local newX = startSize.X + (mouseProxy.X - startPos.X)
                local newY = startSize.Y + (mouseProxy.Y - startPos.Y)
                
                newX = math.max(newX, minSize.X)
                newY = math.max(newY, minSize.Y)
                
                main.Size = UDim2.fromOffset(newX, newY)
            end)
            
            -- Disconnect on release
            local releaseConnection
            releaseConnection = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    resizing = false
                    connection:Disconnect()
                    releaseConnection:Disconnect()
                end
            end)
        end
    end)
    
    function Library:Notify(notifyOpts)
        local nTitle = notifyOpts.Title or "Notification"
        local nContent = notifyOpts.Content or "Content"
        local nDuration = notifyOpts.Duration or 3
        local nImage = notifyOpts.Image or "rbxassetid://10709791437" -- Info icon
        
        local notifyFrame = Create("Frame", {
            Size = UDim2.new(0, 280, 0, 0), 
            AutomaticSize = Enum.AutomaticSize.XY, 
            BackgroundColor3 = theme.Background,
            BackgroundTransparency = 1, -- Start invisible for fade in
            Parent = notificationContainer,
            BorderSizePixel = 0,
            ClipsDescendants = true
        }, {
             Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
             Create("UIStroke", {Color = theme.Border, Thickness = 1}),
             Create("UIPadding", {PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)})
        })
        
        Library:RegisterElement(notifyFrame, "Background")
        Library:RegisterElement(notifyFrame:FindFirstChild("UIStroke"), "Border", "Color")
        
        -- Icon
        local icon = Create("ImageLabel", {
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 0, 0, 2),
            BackgroundTransparency = 1,
            ImageColor3 = theme.Accent,
            Parent = notifyFrame
        })
        Library:ApplyIcon(icon, nImage)
        
        -- Title
        local title = Create("TextLabel", {
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
        
        -- Content
        local content = Create("TextLabel", {
            Size = UDim2.new(1, -30, 0, 0), -- Auto Y
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
        
        -- Duration Bar (Generic passive logic)
        local barBg = Create("Frame", {
            Size = UDim2.new(1, 4, 0, 2),
            Position = UDim2.new(0, -2, 1, 10), -- Bottom relative to padding
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
        
        -- Animate In (Size + Transparency)
        -- Set initial width to ensure it renders, tween height/transparency
        notifyFrame.Size = UDim2.new(0, 280, 0, 0) 
        notifyFrame.BackgroundTransparency = 1 -- Start invisible
        title.TextTransparency = 1
        content.TextTransparency = 1
        icon.ImageTransparency = 1
        
        -- Fade In
        Tween(notifyFrame, {BackgroundTransparency = 0.1}, 0.3)
        Tween(title, {TextTransparency = 0}, 0.3)
        Tween(content, {TextTransparency = 0.2}, 0.3)
        Tween(icon, {ImageTransparency = 0}, 0.3)
        Tween(bar, {Size = UDim2.new(1, 0, 1, 0)}, nDuration)
        
        -- Auto Dismiss
        task.delay(nDuration, function()
             -- Animate out? 
             Tween(notifyFrame, {BackgroundTransparency = 1}, 0.5)
             Tween(title, {TextTransparency = 1}, 0.5)
             Tween(content, {TextTransparency = 1}, 0.5)
             Tween(icon, {ImageTransparency = 1}, 0.5)
             Tween(bar, {BackgroundTransparency = 1}, 0.5)
             Tween(barBg, {BackgroundTransparency = 1}, 0.5)
             Tween(notifyFrame:FindFirstChild("UIStroke"), {Transparency = 1}, 0.5)
             
             task.wait(0.5)
             notifyFrame:Destroy()
        end)
    end
    
    -- Window Proxy for Notify
    -- Window Proxy moved to after WindowFuncs definition

    -- Toggle Keybind Feature
    if options.ToggleKeybind then
        Library.ToggleKeybind = options.ToggleKeybind
    end
    
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and Library.ToggleKeybind and input.KeyCode == Library.ToggleKeybind then
            Library:Toggle()
        end
    end)
    
    -- Window Functions
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

    function WindowFuncs:CreateTab(tabOptions, subtitleArg, iconArg)
        -- Support: AddTab("Name", "Subtitle", "icon") or AddTab({Name="x", Subtitle="y", Icon="z"})
        local tabName, tabSubtitle, tabIconName
        if type(tabOptions) == "string" then
            tabName = tabOptions
            tabSubtitle = subtitleArg or tabOptions -- Default subtitle to tab name
            tabIconName = iconArg or "home"
        else
            tabName = tabOptions.Name or "Tab"
            tabSubtitle = tabOptions.Subtitle or tabName
            tabIconName = tabOptions.Icon or "home"
        end
        
        -- Get icon data (supports Lucide names or Roblox asset IDs)

        
        -- Tab Button
        -- Tab Button (Rounded styling)
        local tabBtn = Create("TextButton", {
            Name = tabName,
            Size = UDim2.new(1, -16, 0, 34),
            BackgroundColor3 = theme.Sidebar,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            Parent = tabList
        }, {
             Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
             Create("UIStroke", {Color = theme.Border, Thickness = 1, Transparency = 0.5})
        })
        
        Library:RegisterElement(tabBtn:FindFirstChild("UIStroke"), "Border", "Color")
        
        -- Icon
        local iconProps = {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 12, 0.5, -8),
            BackgroundTransparency = 1,
            ImageColor3 = theme.TextDim,
            Parent = tabBtn
        }
        
        Library:ApplyIcon(Create("ImageLabel", iconProps), tabIconName)
        

        
        -- Tab Name
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
        
        -- Page (Two Columns)
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
        
        -- Auto canvas size
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
        
        -- Activation
        local function activate()
            if activeTab == tabBtn then return end
            
            -- Deactivate all
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
            
            -- Activate this
            activeTab = tabBtn
            page.Visible = true
            -- breadcrumb.Text = "/ " .. tabSubtitle -- Update breadcrumb with subtitle
            Tween(tabBtn, {BackgroundTransparency = 0, BackgroundColor3 = theme.Element}) -- Active pill
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
        
        -- Tab Functions
        local TabFuncs = {}
        
        function TabFuncs:CreateSection(sectionOptions, sideArg)
            -- Support both: CreateSection({Name = "x", Side = "y"}) and AddSection("x", "Left")
            local sectionName, side
            if type(sectionOptions) == "string" then
                sectionName = sectionOptions
                side = sideArg or "Left"
            else
                sectionName = sectionOptions.Name or "Section"
                side = sectionOptions.Side or "Left"
            end
            local parent = (side == "Right") and rightCol or leftCol
            
            local section = Create("Frame", {
                Name = sectionName,
                Size = UDim2.new(1, 0, 0, 0), -- Auto height
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = theme.Element,
                BackgroundTransparency = 0.5,
                Parent = parent
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 6)})
            })
            
            local sectionStroke = Instance.new("UIStroke")
            sectionStroke.Color = theme.Border
            sectionStroke.Thickness = 1
            sectionStroke.Parent = section
            
            -- Padding for the entire section
            Create("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 8), Parent = section})
            
            Library:RegisterElement(section, "Element")
            Library:RegisterElement(sectionStroke, "Border", "Color")
            
            -- Section Title
            local titleLabel = Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Text = sectionName,
                TextColor3 = theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = section
            })
            
            -- Container for elements
            -- Container for elements (Grouped Box Style)
            local container = Create("Frame", {
                Name = "Container",
                Size = UDim2.new(1, 0, 0, 0), -- Auto height
                AutomaticSize = Enum.AutomaticSize.Y,
                Position = UDim2.new(0, 0, 0, 22), -- Below title
                BackgroundColor3 = theme.Sidebar, -- Box background
                BackgroundTransparency = 0.5, -- Subtle separation
                Parent = section
            }, {
                Create("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}),
                Create("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10)}),
                Create("UICorner", {CornerRadius = UDim.new(0, 8)})
            })
            Library:RegisterElement(container, "Sidebar")
            
            -- Manual resize listener removed (AutomaticSize handles it)
            
            local SectionFuncs = {}
            
            -- Toggle with Keybind
            function SectionFuncs:AddToggle(toggleOptions)
                return Library:CreateToggle(container, toggleOptions)
            end
            
            -- Button
            function SectionFuncs:AddButton(btnOptions)
                return Library:CreateButton(container, btnOptions)
            end
            
            -- Slider
            function SectionFuncs:AddSlider(sliderOptions)
                return Library:CreateSlider(container, sliderOptions)
            end
            
            -- Dropdown
            function SectionFuncs:AddDropdown(dropOptions)
                return Library:CreateDropdown(container, dropOptions)
            end
            
            -- Textbox
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
            
            -- Label
            -- Label
            function SectionFuncs:AddLabel(labelOptions)
                labelOptions.Height = labelOptions.Height or 18
                labelOptions.TextWrapped = true
                return Library:CreateLabel(container, labelOptions)
            end
            
            -- Checkbox (different from toggle - just a checkmark box)
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
                
                -- Inner Circle (Fill)
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
                        -- Box stays Element color
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
                        -- Animate inner circle instead of text/bg
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
            
            -- Standalone Keybind
            function SectionFuncs:AddKeybind(keybindOptions)
                local keybindName = keybindOptions.Name or "Keybind"
                local default = keybindOptions.Default or "NONE"
                local callback = keybindOptions.Callback or function() end
                local flag = keybindOptions.Flag
                local mode = keybindOptions.Mode or "Toggle" -- Toggle, Hold, Always
                local currentKey = default ~= "NONE" and Enum.KeyCode[default] or Enum.KeyCode.Unknown
                
                local keybind = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Parent = container
                })
                
                Create("TextLabel", {
                    Size = UDim2.new(0, 100, 1, 0),
                    BackgroundTransparency = 1,
                    Text = keybindName,
                    TextColor3 = theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = keybind
                })
                
                local keyBtn = Create("TextButton", {
                    Size = UDim2.new(0, 40, 0, 16),
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    BackgroundColor3 = theme.Element,
                    Text = default,
                    TextColor3 = theme.TextDim,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    AutoButtonColor = false,
                    Parent = keybind
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
                    Create("UIStroke", {Color = theme.Border, Thickness = 1})
                })
                
                Library:RegisterElement(keyBtn, "Element")
                
                local keybindObj = {
                    Value = currentKey,
                    Mode = mode,
                    SetValue = function(self, key)
                        currentKey = key
                        self.Value = key
                        keyBtn.Text = key.Name:upper()
                    end
                }
                
                local listening = false
                keyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    keyBtn.Text = "..."
                end)
                
                UserInputService.InputBegan:Connect(function(input, processed)
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        keyBtn.Text = input.KeyCode.Name:upper()
                        keybindObj.Value = input.KeyCode
                        listening = false
                    elseif currentKey ~= Enum.KeyCode.Unknown and input.KeyCode == currentKey and not processed then
                        callback()
                    end
                end)
                
                if flag then Library.Options[flag] = keybindObj end
            end
            
            -- Color Picker
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
                
                -- Simple color popup
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

                -- Preset colors
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
                        -- Update scale to match main UI
                        if mainScale then popupScale.Scale = mainScale.Scale end
                        
                        -- Position to the LEFT of the colorBox since it's now right-aligned
                        popup.Position = UDim2.fromOffset(
                            colorBox.AbsolutePosition.X - (popup.AbsoluteSize.X * popupScale.Scale) - 5, 
                            colorBox.AbsolutePosition.Y
                        )
                    end
                end

                colorBox.MouseButton1Click:Connect(function()
                    popup.Visible = not popup.Visible
                    if popup.Visible then
                        popup.Parent = gui -- Move to ScreenGui to bypass clipping
                        updatePosition()
                        connection = RunService.RenderStepped:Connect(updatePosition)
                    else
                        popup.Parent = colorBox -- Put back (optional, but keeps hierarchy clean)
                        if connection then connection:Disconnect() connection = nil end
                    end
                end)
                
                -- Cleanup if destroyed
                colorBox.Destroying:Connect(function()
                    if connection then connection:Disconnect() end
                    popup:Destroy()
                end)
                
                if flag then Library.Options[flag] = colorObj end
            end
            
            -- Divider
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
            
            -- Tabbox (sub-tabs within a section)
            function SectionFuncs:AddTabbox(tabboxOptions)
                local tabboxName = tabboxOptions.Name or "Tabbox"
                
                local tabbox = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = theme.Element,
                    BorderSizePixel = 0,
                    Parent = container
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 6)})
                })
                
                local tabHeader = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundTransparency = 1,
                    Parent = tabbox
                }, {
                    Create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDim.new(0, 2),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })
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
                        Size = UDim2.new(0, 60, 1, -4),
                        BackgroundColor3 = theme.ToggleOff,
                        BackgroundTransparency = 0.5,
                        Text = name,
                        TextColor3 = theme.TextDim,
                        Font = Enum.Font.Gotham,
                        TextSize = 11,
                        AutoButtonColor = false,
                        Parent = tabHeader
                    }, {Create("UICorner", {CornerRadius = UDim.new(0, 4)})})
                    
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
                    
                    tabBtn.MouseButton1Click:Connect(function()
                        for _, t in ipairs(tabs) do
                            t.page.Visible = false
                            t.btn.BackgroundTransparency = 0.5
                            t.btn.TextColor3 = theme.TextDim
                        end
                        tabPage.Visible = true
                        tabBtn.BackgroundTransparency = 0
                        tabBtn.TextColor3 = theme.Text
                        tabBtn.BackgroundColor3 = theme.Accent
                        activeTab = tabPage
                    end)
                    
                    -- Return tab-specific section funcs
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
            
            -- Dependency (show/hide based on toggle)
            function SectionFuncs:AddDependencyBox(dependencyOptions)
                local dependsOn = dependencyOptions.DependsOn -- Flag name
                
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
                
                -- Update visibility based on toggle
                local function updateVisibility()
                    local toggle = Library.Toggles[dependsOn]
                    if toggle then
                        local visible = toggle.Value
                        local layout = depBox:FindFirstChildOfClass("UIListLayout")
                        local height = visible and layout.AbsoluteContentSize.Y or 0
                        Tween(depBox, {Size = UDim2.new(1, 0, 0, height)})
                    end
                end
                
                -- Connect to toggle changes (delayed to allow toggle to be created)
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
            
            -- Image
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
            
            -- Video (simple implementation using viewport)
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
            
            -- UI Passthrough (embed custom UI)
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
        
        -- Alias for cleaner API: Tab:AddSection("SectionName", "Left")
        TabFuncs.AddSection = TabFuncs.CreateSection
        
        -- AddLeftTabbox - Creates a tabbox on the left column
        function TabFuncs:AddLeftTabbox(name)
            return createTabbox(name, leftCol, theme, gui, Create, Tween, Library)
        end
        
        -- AddRightTabbox - Creates a tabbox on the right column
        function TabFuncs:AddRightTabbox(name)
            return createTabbox(name, rightCol, theme, gui, Create, Tween, Library)
        end
        
        -- Explicit Section Methods (User Request)
        function TabFuncs:AddLeftSection(name)
            return TabFuncs:CreateSection(name, "Left")
        end
        
        function TabFuncs:AddRightSection(name)
            return TabFuncs:CreateSection(name, "Right")
        end
        
        return TabFuncs
    end
    
    -- Alias for cleaner API: Window:AddTab("TabName", "icon-name")
    WindowFuncs.AddTab = WindowFuncs.CreateTab
    
    return WindowFuncs
end

return Library
