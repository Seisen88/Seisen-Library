--[[
    Seisen UI Library - XEZIOS Style
    Modern minimalist design with responsive layout
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- Load Lucide icons (from our own source)
local IconsLoaded, Icons = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Ken-884/Seisen-Library/refs/heads/main/addons/source.lua"))()
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
        Background = Color3.fromRGB(30, 30, 35),
        Sidebar = Color3.fromRGB(25, 25, 30),
        SidebarActive = Color3.fromRGB(40, 40, 48),
        Content = Color3.fromRGB(35, 35, 42),
        Element = Color3.fromRGB(45, 45, 55),
        ElementHover = Color3.fromRGB(55, 55, 65),
        Border = Color3.fromRGB(75, 75, 90),
        Accent = Color3.fromRGB(90, 90, 160),
        AccentHover = Color3.fromRGB(110, 110, 180),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(150, 150, 160),
        TextMuted = Color3.fromRGB(100, 100, 110),
        Toggle = Color3.fromRGB(90, 90, 160),
        ToggleOff = Color3.fromRGB(65, 65, 78)
    }
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
end

-- Get Lucide icon by name
-- Returns: { Url, ImageRectOffset, ImageRectSize } or nil
function Library:GetIcon(iconName)
    if not iconName or iconName == "" then
        return nil
    end
    
    -- Check if it's a custom Roblox asset
    if type(iconName) == "string" then
        if iconName:match("rbxasset") or iconName:match("rbxassetid://") or iconName:match("roblox%.com/asset") then
            return {
                Url = iconName,
                ImageRectOffset = Vector2.zero,
                ImageRectSize = Vector2.zero,
                Custom = true
            }
        end
    end
    
    -- Try to get from Lucide icons
    if self.Icons then
        local success, icon = pcall(function()
            return self.Icons.GetAsset(iconName)
        end)
        if success and icon then
            return icon
        end
    end
    
    return nil
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

local function MakeDraggable(handle, frame)
    local dragging, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
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
        Create("UIPadding", {PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6)})
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
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = tabbox
    })
    
    local TabboxFuncs = {}
    local tabs = {}
    local activeTab = nil
    
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
        
        local tabPage = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = theme.Accent,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = tabContent
        }, {
            Create("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}),
            Create("UIPadding", {PaddingRight = UDim.new(0, 4)})
        })
        
        Library:RegisterElement(tabPage, "Accent", "ScrollBarImageColor3")
        
        table.insert(tabs, {btn = tabBtn, page = tabPage})
        
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
        end
        
        tabBtn.MouseButton1Click:Connect(activateTab)
        
        if #tabs == 1 then
            activateTab()
        end
        
        -- Return TabPageFuncs with element creation methods
        local TabPageFuncs = {}
        
        function TabPageFuncs:AddLabel(opts)
            local text = opts.Text or opts.Name or "Label"
            local label = Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = theme.TextDim,
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = tabPage
            })
            Library:RegisterElement(label, "TextDim", "TextColor3")
            return {SetText = function(self, t) label.Text = t end}
        end
        
        function TabPageFuncs:AddToggle(opts)
            local toggleName = opts.Name or "Toggle"
            local default = opts.Default or false
            local callback = opts.Callback or function() end
            local flag = opts.Flag
            local state = default
            
            local toggle = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Parent = tabPage
            })
            
            local tLabel = Create("TextLabel", {
                Size = UDim2.new(1, -45, 1, 0),
                BackgroundTransparency = 1,
                Text = toggleName,
                TextColor3 = theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toggle
            })
            Library:RegisterElement(tLabel, "Text", "TextColor3")
            
            local switchBg = Create("Frame", {
                Size = UDim2.new(0, 32, 0, 16),
                Position = UDim2.new(1, -32, 0.5, -8),
                BackgroundColor3 = state and theme.Toggle or theme.ToggleOff,
                Parent = toggle
            }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
            
            local knob = Create("Frame", {
                Size = UDim2.new(0, 12, 0, 12),
                Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = switchBg
            }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
            
            table.insert(Library.Registry, {
                Callback = function(theme)
                    local tTheme = theme or Library.Theme
                    Tween(switchBg, {BackgroundColor3 = state and tTheme.Toggle or tTheme.ToggleOff})
                    -- Knob is white, no theme update needed
                end
            })
            
            local toggleObj = {Value = state, SetValue = function(self, val) 
                state = val; self.Value = val
                local tTheme = Library.Theme
                Tween(switchBg, {BackgroundColor3 = val and tTheme.Toggle or tTheme.ToggleOff})
                Tween(knob, {Position = val and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)})
                callback(val)
            end}
            
            local btn = Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = toggle})
            btn.MouseButton1Click:Connect(function() toggleObj:SetValue(not state) end)
            
            if flag then Library.Toggles[flag] = toggleObj end
            return toggleObj
        end
        
        function TabPageFuncs:AddButton(opts)
            local buttonName = opts.Name or "Button"
            local callback = opts.Callback or function() end
            
            local btn = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = theme.Element,
                Text = buttonName,
                TextColor3 = theme.Text,
                Font = Enum.Font.GothamMedium,
                TextSize = 11,
                AutoButtonColor = false,
                Parent = tabPage
            }, {Create("UICorner", {CornerRadius = UDim.new(0, 4)})})
            
            local btnStroke = Instance.new("UIStroke")
            btnStroke.Color = theme.Border
            btnStroke.Thickness = 1
            btnStroke.Parent = btn
            
            Library:RegisterElement(btn, "Element")
            Library:RegisterElement(btn, "Text", "TextColor3")
            Library:RegisterElement(btnStroke, "Border", "Color")
            
            btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = Library.Theme.ElementHover}) end)
            btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = Library.Theme.Element}) end)
            btn.MouseButton1Click:Connect(callback)
        end
        
        function TabPageFuncs:AddSlider(opts)
            local sliderName = opts.Name or "Slider"
            local min, max = opts.Min or 0, opts.Max or 100
            local default = opts.Default or min
            local callback = opts.Callback or function() end
            local flag = opts.Flag
            local value = math.clamp(default, min, max)
            
            local slider = Create("Frame", {Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Parent = tabPage})
            local valueLabel = Create("TextLabel", {
                Size = UDim2.new(0, 40, 0, 14), Position = UDim2.new(1, -40, 0, 0),
                BackgroundTransparency = 1, Text = tostring(value),
                TextColor3 = theme.TextDim, Font = Enum.Font.Gotham, TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Right, Parent = slider
            })
            local nameLabel = Create("TextLabel", {
                Size = UDim2.new(1, -45, 0, 14), BackgroundTransparency = 1, Text = sliderName,
                TextColor3 = theme.Text, Font = Enum.Font.Gotham, TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = slider
            })
            
            Library:RegisterElement(valueLabel, "TextDim", "TextColor3")
            Library:RegisterElement(nameLabel, "Text", "TextColor3")
            
            local track = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0, 20),
                BackgroundColor3 = theme.ToggleOff, Parent = slider
            }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
            local fill = Create("Frame", {
                Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = theme.Accent, Parent = track
            }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
            
            Library:RegisterElement(track, "ToggleOff")
            Library:RegisterElement(fill, "Accent")
            
            local sliderObj = {Value = value}
            local dragging = false
            local input = Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = track})
            
            local function update(inputPos)
                local rel = math.clamp((inputPos.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                value = math.floor(min + rel * (max - min))
                sliderObj.Value = value
                fill.Size = UDim2.new(rel, 0, 1, 0)
                valueLabel.Text = tostring(value)
                callback(value)
            end
            
            input.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(i.Position) end end)
            input.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
            UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i.Position) end end)
            
            if flag then Library.Options[flag] = sliderObj end
            return sliderObj
        end
        
        return TabPageFuncs
    end
    
    -- Auto-resize tabbox based on content
    local function updateTabboxSize()
        local maxHeight = 0
        for _, t in ipairs(tabs) do
            local layout = t.page:FindFirstChildOfClass("UIListLayout")
            if layout then
                maxHeight = math.max(maxHeight, layout.AbsoluteContentSize.Y)
            end
        end
        tabbox.Size = UDim2.new(1, 0, 0, math.max(80, maxHeight + 50))
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
    local name = options.Name or "Seisen UI"
    local theme = options.Theme or self.Theme
    
    -- Screen GUI
    local gui = Create("ScreenGui", {
        Name = "SeisenUI",
        Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game.CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        ResetOnSpawn = false
    })
    
    self.ScreenGui = gui
    
    -- Main Frame
    local main = Create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 500, 0, 600), -- Taller default size (Length focus)
        Position = UDim2.new(0.5, -250, 0.5, -300),
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
        Size = UDim2.new(0, 130, 1, 0),
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
    
    -- Tab List (leave room for profile at bottom)
    local tabList = Create("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, 0, 1, -70),
        Position = UDim2.new(0, 0, 0, 10),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Parent = sidebar
    }, {
        Create("UIListLayout", {
            Padding = UDim.new(0, 2),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
    })
    
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
        Size = UDim2.new(1, -130, 1, 0),
        Position = UDim2.new(0, 130, 0, 0),
        BackgroundColor3 = theme.Content,
        BorderSizePixel = 0,
        Parent = main
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 8)})
    })
    
    self:RegisterElement(content, "Content")
    
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
        Size = UDim2.new(1, -20, 0, 40),
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
        Parent = content
    })
    
    -- Pages Container
    local pages = Create("Folder", {Name = "Pages", Parent = content})
    
    MakeDraggable(sidebar, main)
    
    local resizeHandle = Create("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -16, 1, -16),
        BackgroundTransparency = 1,
        Parent = main,
        ZIndex = 200
    })
    
    local resizing = false
    local minSize = Vector2.new(400, 300)
    
    resizeHandle.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then resizing = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end end)
    UserInputService.InputChanged:Connect(function(i)
        if resizing and i.UserInputType == Enum.UserInputType.MouseMovement then
             local newX = i.Position.X - main.AbsolutePosition.X + 5
             local newY = i.Position.Y - main.AbsolutePosition.Y + 5
             newX = math.max(newX, minSize.X)
             newY = math.max(newY, minSize.Y)
             main.Size = UDim2.new(0, newX, 0, newY)
        end
    end)
    
    -- Window Functions
    local WindowFuncs = {}
    local firstTab = true
    local activeTab = nil
    
    function WindowFuncs:SetScale(scale)
        mainScale.Scale = scale
    end
    
    function WindowFuncs:CreateTab(tabOptions, iconArg)
        -- Support both: CreateTab({Name = "x", Icon = "y"}) and AddTab("x", "y")
        local tabName, tabIconName
        if type(tabOptions) == "string" then
            tabName = tabOptions
            tabIconName = iconArg or "home"
        else
            tabName = tabOptions.Name or "Tab"
            tabIconName = tabOptions.Icon or "home"
        end
        
        -- Get icon data (supports Lucide names or Roblox asset IDs)
        local iconData = Library:GetIcon(tabIconName)
        
        -- Tab Button
        local tabBtn = Create("TextButton", {
            Name = tabName,
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = theme.Sidebar,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            Parent = tabList
        })
        
        -- Icon
        local iconProps = {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 12, 0.5, -8),
            BackgroundTransparency = 1,
            ImageColor3 = theme.TextDim,
            Parent = tabBtn
        }
        
        if iconData then
            iconProps.Image = iconData.Url
            iconProps.ImageRectOffset = iconData.ImageRectOffset or Vector2.zero
            iconProps.ImageRectSize = iconData.ImageRectSize or Vector2.zero
        else
            iconProps.Image = "rbxassetid://7733960981" -- Default fallback
        end
        
        Create("ImageLabel", iconProps)
        
        -- Tab Name
        local tabLabel = Create("TextLabel", {
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 35, 0, 0),
            BackgroundTransparency = 1,
            Text = tabName,
            TextColor3 = theme.TextDim,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
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
        local function updateCanvas()
            local leftH = leftCol:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y
            local rightH = rightCol:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y
            page.CanvasSize = UDim2.new(0, 0, 0, math.max(leftH, rightH) + 10)
        end
        
        leftCol:FindFirstChildOfClass("UIListLayout"):GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        rightCol:FindFirstChildOfClass("UIListLayout"):GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        
        -- Activation
        local function activate()
            if activeTab == tabBtn then return end
            
            -- Deactivate all
            for _, t in pairs(tabList:GetChildren()) do
                if t:IsA("TextButton") then
                    t.BackgroundTransparency = 1
                    local lbl = t:FindFirstChild("TextLabel")
                    local icon = t:FindFirstChildOfClass("ImageLabel")
                    if lbl then lbl.TextColor3 = theme.TextDim end
                    if icon then icon.ImageColor3 = theme.TextDim end
                end
            end
            for _, p in pairs(pages:GetChildren()) do p.Visible = false end
            
            -- Activate this
            activeTab = tabBtn
            page.Visible = true
            Tween(tabBtn, {BackgroundTransparency = 0, BackgroundColor3 = theme.SidebarActive})
            Tween(tabLabel, {TextColor3 = theme.Text})
            local icon = tabBtn:FindFirstChildOfClass("ImageLabel")
            if icon then Tween(icon, {ImageColor3 = theme.Text}) end
        end
        
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
            local container = Create("Frame", {
                Name = "Container",
                Size = UDim2.new(1, 0, 0, 0), -- Auto height
                AutomaticSize = Enum.AutomaticSize.Y,
                Position = UDim2.new(0, 0, 0, 22), -- Below title
                BackgroundTransparency = 1,
                Parent = section
            }, {
                Create("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder})
            })
            
            -- Manual resize listener removed (AutomaticSize handles it)
            
            local SectionFuncs = {}
            
            -- Toggle with Keybind
            function SectionFuncs:AddToggle(toggleOptions)
                local toggleName = toggleOptions.Name or "Toggle"
                local default = toggleOptions.Default or false
                local callback = toggleOptions.Callback or function() end
                local flag = toggleOptions.Flag
                local state = default
                local keybind = Enum.KeyCode.Unknown
                
                local toggle = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Parent = container
                })
                
                -- Label (takes up remaining space)
                local toggleLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -130, 1, 0), -- Leave room for right-side controls
                    BackgroundTransparency = 1,
                    Text = toggleName,
                    TextColor3 = Library.Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = toggle
                })
                Library:RegisterElement(toggleLabel, "Text", "TextColor3")
                
                -- Indicator (Rightmost)
                local indicator = Create("Frame", {
                    Size = UDim2.new(0, 8, 0, 8),
                    Position = UDim2.new(1, -14, 0.5, -4),
                    BackgroundColor3 = state and Library.Theme.Accent or Library.Theme.ToggleOff,
                    BorderSizePixel = 0,
                    Parent = toggle
                }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
                
                -- Switch (Left of Indicator)
                local switchBg = Create("Frame", {
                    Size = UDim2.new(0, 36, 0, 18),
                    Position = UDim2.new(1, -56, 0.5, -9), 
                    BackgroundColor3 = state and Library.Theme.Toggle or Library.Theme.ToggleOff,
                    BorderSizePixel = 0,
                    Parent = toggle
                }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
                
                local knob = Create("Frame", {
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Parent = switchBg
                }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
                
                -- Keybind Button (Left of Switch)
                local keybindBtn = Create("TextButton", {
                    Size = UDim2.new(0, 50, 0, 18),
                    Position = UDim2.new(1, -112, 0.5, -9), 
                    BackgroundColor3 = Library.Theme.Element,
                    Text = "NONE",
                    TextColor3 = Library.Theme.TextDim,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    AutoButtonColor = false,
                    Parent = toggle
                }, {Create("UICorner", {CornerRadius = UDim.new(0, 4)})})
                Library:RegisterElement(keybindBtn, "Element")
                
                table.insert(Library.Registry, {
                    Callback = function(theme)
                        local tTheme = theme or Library.Theme
                        Tween(switchBg, {BackgroundColor3 = state and tTheme.Toggle or tTheme.ToggleOff})
                        Tween(indicator, {BackgroundColor3 = state and tTheme.Accent or tTheme.ToggleOff})
                    end
                })
                
                -- Toggle Object
                local toggleObj = {
                    Value = state,
                    SetValue = function(self, val)
                        state = val
                        self.Value = val
                        Tween(switchBg, {BackgroundColor3 = val and Library.Theme.Toggle or Library.Theme.ToggleOff})
                        Tween(knob, {Position = val and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)})
                        Tween(indicator, {BackgroundColor3 = val and Library.Theme.Accent or Library.Theme.ToggleOff})
                        callback(val)
                    end
                }
                
                -- Click handlers (Full Size Button)
                local switchBtn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0), -- Full size for easy clicking
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = toggle
                })
                
                switchBtn.MouseButton1Click:Connect(function()
                    toggleObj:SetValue(not state)
                end)
                
                -- Keybind logic
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
                        toggleObj:SetValue(not state)
                    end
                end)
                
                if flag then
                    Library.Toggles[flag] = toggleObj
                end
                
                if default then callback(true) end
            end
            
            -- Button
            function SectionFuncs:AddButton(btnOptions)
                local btnName = btnOptions.Name or "Button"
                local callback = btnOptions.Callback or function() end
                
                local btn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundColor3 = Library.Theme.Element,
                    Text = btnName,
                    TextColor3 = Library.Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    AutoButtonColor = false,
                    Parent = container
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 4)})
                })
                
                local btnStroke = Instance.new("UIStroke")
                btnStroke.Color = Library.Theme.Border
                btnStroke.Thickness = 1
                btnStroke.Parent = btn
                
                -- Register for theme updates
                Library:RegisterElement(btn, "Element")
                Library:RegisterElement(btnStroke, "Border", "Color")
                Library:RegisterElement(btn, "Text", "TextColor3")
                
                btn.MouseEnter:Connect(function()
                    Tween(btn, {BackgroundColor3 = Library.Theme.ElementHover})
                end)
                btn.MouseLeave:Connect(function()
                    Tween(btn, {BackgroundColor3 = Library.Theme.Element})
                end)
                btn.MouseButton1Click:Connect(callback)
            end
            
            -- Slider
            function SectionFuncs:AddSlider(sliderOptions)
                local sliderName = sliderOptions.Name or "Slider"
                local min = sliderOptions.Min or 0
                local max = sliderOptions.Max or 100
                local default = sliderOptions.Default or min
                local callback = sliderOptions.Callback or function() end
                local flag = sliderOptions.Flag
                local value = default
                
                local slider = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundTransparency = 1,
                    Parent = container
                })
                
                Create("TextLabel", {
                    Size = UDim2.new(1, -40, 0, 16),
                    BackgroundTransparency = 1,
                    Text = sliderName,
                    TextColor3 = theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = slider
                })
                
                local valLabel = Create("TextLabel", {
                    Size = UDim2.new(0, 35, 0, 16),
                    Position = UDim2.new(1, -35, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(value),
                    TextColor3 = theme.TextDim,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = slider
                })
                
                local bar = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 0, 22),
                    BackgroundColor3 = theme.ToggleOff,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = slider
                }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
                
                local fill = Create("Frame", {
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = theme.Accent,
                    BorderSizePixel = 0,
                    Parent = bar
                }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
                
                Library:RegisterElement(bar, "ToggleOff")
                Library:RegisterElement(fill, "Accent")
                
                local sliderObj = {
                    Value = value,
                    Type = "Slider",
                    SetValue = function(self, val)
                        val = math.clamp(val, min, max)
                        value = val
                        self.Value = val
                        valLabel.Text = tostring(val)
                        fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
                        callback(val)
                    end
                }
                
                local function update(input)
                    local pct = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    sliderObj:SetValue(math.floor(min + (max - min) * pct))
                end
                
                local sliding = false
                bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true; update(i) end end)
                UserInputService.InputChanged:Connect(function(i) if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
                
                if flag then Library.Options[flag] = sliderObj end
            end
            
            -- Dropdown
            function SectionFuncs:AddDropdown(dropOptions)
                local dropName = dropOptions.Name or "Dropdown"
                local options = dropOptions.Options or {}
                local default = dropOptions.Default or options[1]
                local callback = dropOptions.Callback or function() end
                local flag = dropOptions.Flag
                
                local drop = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 45),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    Parent = container
                })
                
                Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text = dropName,
                    TextColor3 = theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = drop
                })
                
                local selectBtn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 24),
                    Position = UDim2.new(0, 0, 0, 18),
                    BackgroundColor3 = theme.Element,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = drop
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 4)})
                })
                
                local dropStroke = Instance.new("UIStroke")
                dropStroke.Color = theme.Border
                dropStroke.Thickness = 1
                dropStroke.Parent = selectBtn
                
                Library:RegisterElement(selectBtn, "Element")
                Library:RegisterElement(dropStroke, "Border", "Color")
                
                selectBtn.MouseEnter:Connect(function()
                    Tween(selectBtn, {BackgroundColor3 = Library.Theme.ElementHover})
                end)
                selectBtn.MouseLeave:Connect(function()
                    Tween(selectBtn, {BackgroundColor3 = Library.Theme.Element})
                end)
                
                local selectedLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -25, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = default or "",
                    TextColor3 = theme.TextDim,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = selectBtn
                })
                
                local arrowLabel = Create("TextLabel", {
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -20, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = theme.TextDim,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    Parent = selectBtn
                })
                
                Library:RegisterElement(selectedLabel, "TextDim", "TextColor3")
                Library:RegisterElement(arrowLabel, "TextDim", "TextColor3")
                
                -- Create dropdown list at GUI level for proper z-ordering
                local maxVisibleItems = 8
                local itemHeight = 22
                local list = Create("ScrollingFrame", {
                    Name = "DropdownList",
                    Size = UDim2.new(0, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundColor3 = theme.Element,
                    Visible = false,
                    ZIndex = 1000,
                    ScrollBarThickness = 4,
                    ScrollBarImageColor3 = theme.Accent,
                    CanvasSize = UDim2.new(0, 0, 0, #options * itemHeight),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    Parent = gui
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
                    Create("UIListLayout", {Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder})
                })
                
                local listStroke = Instance.new("UIStroke")
                listStroke.Color = theme.Border
                listStroke.Thickness = 1
                listStroke.ZIndex = 1000
                listStroke.Parent = list
                
                Library:RegisterElement(list, "Element")
                Library:RegisterElement(list, "Accent", "ScrollBarImageColor3")
                Library:RegisterElement(listStroke, "Border", "Color")
                
                local dropObj = {
                    Value = default,
                    Type = "Dropdown",
                    SetValue = function(self, val)
                        self.Value = val
                        selectedLabel.Text = val
                        callback(val)
                    end
                }
                
                local open = false
                local thisDropdown = {} -- Reference to this dropdown
                local positionConnection = nil
                
                local function updateListPosition()
                    local absPos = selectBtn.AbsolutePosition
                    local absSize = selectBtn.AbsoluteSize
                    list.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 2)
                    local targetHeight = math.min(#options, maxVisibleItems) * itemHeight
                    list.Size = UDim2.new(0, absSize.X, 0, targetHeight)
                end
                
                local function closeThisDropdown()
                    if open then
                        open = false
                        if positionConnection then
                            positionConnection:Disconnect()
                            positionConnection = nil
                        end
                        Tween(list, {Size = UDim2.new(0, selectBtn.AbsoluteSize.X, 0, 0)})
                        task.delay(0.15, function() if not open then list.Visible = false end end)
                    end
                end
                
                thisDropdown.Close = closeThisDropdown
                table.insert(Library.OpenDropdowns, thisDropdown)
                
                selectBtn.MouseButton1Click:Connect(function()
                    if open then
                        closeThisDropdown()
                    else
                        -- Close all OTHER dropdowns first
                        for _, dd in ipairs(Library.OpenDropdowns) do
                            if dd ~= thisDropdown and dd.Close then 
                                dd.Close() 
                            end
                        end
                        -- Then open this one
                        open = true
                        updateListPosition()
                        list.Visible = true
                        list.Size = UDim2.new(0, selectBtn.AbsoluteSize.X, 0, 0)
                        local targetHeight = math.min(#options, maxVisibleItems) * itemHeight
                        Tween(list, {Size = UDim2.new(0, selectBtn.AbsoluteSize.X, 0, targetHeight)})
                        
                        -- Continuously update position while open
                        positionConnection = game:GetService("RunService").RenderStepped:Connect(function()
                            if open then
                                local absPos = selectBtn.AbsolutePosition
                                local absSize = selectBtn.AbsoluteSize
                                list.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 2)
                            end
                        end)
                    end
                end)
                
                local optionButtons = {}
                
                local function updateOptionHighlights()
                    for _, data in ipairs(optionButtons) do
                        if data.value == dropObj.Value then
                            -- Selected option
                            data.btn.BackgroundColor3 = Library.Theme.Accent
                            data.btn.TextColor3 = Library.Theme.Text
                        else
                            -- Not selected
                            data.btn.BackgroundColor3 = Library.Theme.Element
                            data.btn.TextColor3 = Library.Theme.TextDim
                        end
                    end
                end
                
                for _, opt in ipairs(options) do
                    local isSelected = (opt == default)
                    local optBtn = Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 21),
                        BackgroundColor3 = isSelected and theme.Accent or theme.Element,
                        BackgroundTransparency = 0,
                        Text = opt,
                        TextColor3 = isSelected and theme.Text or theme.TextDim,
                        Font = Enum.Font.Gotham,
                        TextSize = 11,
                        ZIndex = 1001,
                        Parent = list
                    })
                    
                    table.insert(optionButtons, {btn = optBtn, value = opt})
                    
                    optBtn.MouseEnter:Connect(function()
                        if opt ~= dropObj.Value then
                            optBtn.BackgroundColor3 = Library.Theme.ElementHover
                        end
                    end)
                    optBtn.MouseLeave:Connect(function()
                        if opt == dropObj.Value then
                            optBtn.BackgroundColor3 = Library.Theme.Accent
                        else
                            optBtn.BackgroundColor3 = Library.Theme.Element
                        end
                    end)
                    optBtn.MouseButton1Click:Connect(function()
                        dropObj:SetValue(opt)
                        updateOptionHighlights()
                        open = false
                        Tween(list, {Size = UDim2.new(0, selectBtn.AbsoluteSize.X, 0, 0)})
                        task.delay(0.15, function() list.Visible = false end)
                    end)
                end
                
                table.insert(Library.Registry, {
                    Callback = function()
                        updateOptionHighlights()
                    end
                })
                
                if flag then Library.Options[flag] = dropObj end
            end
            
            -- Textbox
            function SectionFuncs:AddTextbox(boxOptions)
                local boxName = boxOptions.Name or "Input"
                local default = boxOptions.Default or ""
                local placeholder = boxOptions.Placeholder or ""
                local callback = boxOptions.Callback or function() end
                local flag = boxOptions.Flag
                
                local box = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 45),
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
                    Size = UDim2.new(1, 0, 0, 24),
                    Position = UDim2.new(0, 0, 0, 18),
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
            function SectionFuncs:AddLabel(labelOptions)
                local text = labelOptions.Text or labelOptions.Name or "Label"
                local flag = labelOptions.Flag
                
                local label = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = theme.TextDim,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    Parent = container
                })
                
                local labelObj = {
                    SetText = function(self, newText)
                        label.Text = newText
                    end
                }
                
                if flag then Library.Labels = Library.Labels or {}; Library.Labels[flag] = labelObj end
                return labelObj
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
                    BackgroundColor3 = state and theme.Accent or theme.Element,
                    Text = state and "✓" or "",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    AutoButtonColor = false,
                    Parent = check
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 4)})
                })
                
                local boxStroke = Instance.new("UIStroke")
                boxStroke.Color = theme.Border
                boxStroke.Thickness = 1
                boxStroke.Parent = box
                
                Library:RegisterElement(boxStroke, "Border", "Color")
                
                table.insert(Library.Registry, {
                    Callback = function(theme)
                        local tTheme = theme or Library.Theme
                        Tween(box, {BackgroundColor3 = state and tTheme.Accent or tTheme.Element})
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
                        box.Text = val and "✓" or ""
                        Tween(box, {BackgroundColor3 = val and theme.Accent or theme.Element})
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
                    Size = UDim2.new(1, 0, 0, 24),
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
                    Size = UDim2.new(0, 60, 0, 20),
                    Position = UDim2.new(0, 110, 0.5, -10),
                    BackgroundColor3 = theme.Element,
                    Text = default,
                    TextColor3 = theme.TextDim,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    AutoButtonColor = false,
                    Parent = keybind
                }, {Create("UICorner", {CornerRadius = UDim.new(0, 4)})})
                
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
                    Position = UDim2.new(0, 110, 0.5, -9),
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
                
                colorBox.MouseButton1Click:Connect(function()
                    popup.Visible = not popup.Visible
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
                    Size = UDim2.new(1, 0, 0, 120),
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
                    Size = UDim2.new(1, -10, 1, -32),
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
                    
                    local tabPage = Create("ScrollingFrame", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        ScrollBarThickness = 2,
                        Visible = false,
                        Parent = tabContent
                    }, {
                        Create("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder})
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
                    
                    if #tabs == 1 then
                        tabBtn.BackgroundTransparency = 0
                        tabBtn.TextColor3 = theme.Text
                        tabBtn.BackgroundColor3 = theme.Accent
                        tabPage.Visible = true
                        activeTab = tabPage
                    end
                    
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
        
        return TabFuncs
    end
    
    -- Alias for cleaner API: Window:AddTab("TabName", "icon-name")
    WindowFuncs.AddTab = WindowFuncs.CreateTab
    
    return WindowFuncs
end

return Library
