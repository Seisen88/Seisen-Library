--[[
    Seisen UI Library - XEZIOS Style
    Modern minimalist design with responsive layout
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Library = {
    Toggles = {},
    Options = {},
    Flags = {},
    Theme = {
        Background = Color3.fromRGB(30, 30, 35),
        Sidebar = Color3.fromRGB(25, 25, 30),
        SidebarActive = Color3.fromRGB(40, 40, 48),
        Content = Color3.fromRGB(35, 35, 42),
        Element = Color3.fromRGB(45, 45, 55),
        ElementHover = Color3.fromRGB(55, 55, 65),
        Border = Color3.fromRGB(55, 55, 65),
        Accent = Color3.fromRGB(90, 90, 160),
        AccentHover = Color3.fromRGB(110, 110, 180),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(150, 150, 160),
        TextMuted = Color3.fromRGB(100, 100, 110),
        Toggle = Color3.fromRGB(90, 90, 160),
        ToggleOff = Color3.fromRGB(60, 60, 70)
    }
}

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

function Library:CreateWindow(options)
    local name = options.Name or "Seisen UI"
    local theme = options.Theme or self.Theme
    
    -- Screen GUI
    local gui = Create("ScreenGui", {
        Name = "SeisenUI",
        Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game.CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- Main Frame
    local main = Create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 630, 0, 450),
        Position = UDim2.new(0.5, -315, 0.5, -225),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Parent = gui
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 8)})
    })
    
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
    
    -- Cover right corners of sidebar
    Create("Frame", {
        Size = UDim2.new(0, 10, 1, 0),
        Position = UDim2.new(1, -10, 0, 0),
        BackgroundColor3 = theme.Sidebar,
        BorderSizePixel = 0,
        Parent = sidebar
    })
    
    -- Tab List
    local tabList = Create("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, 0, 1, -10),
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
    
    -- Cover left corners of content
    Create("Frame", {
        Size = UDim2.new(0, 10, 1, 0),
        BackgroundColor3 = theme.Content,
        BorderSizePixel = 0,
        Parent = content
    })
    
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
    
    -- Window Functions
    local WindowFuncs = {}
    local firstTab = true
    local activeTab = nil
    
    function WindowFuncs:CreateTab(tabOptions)
        local tabName = tabOptions.Name or "Tab"
        local tabIcon = tabOptions.Icon or "rbxassetid://7733960981"
        
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
        Create("ImageLabel", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 12, 0.5, -8),
            BackgroundTransparency = 1,
            Image = tabIcon,
            ImageColor3 = theme.TextDim,
            Parent = tabBtn
        })
        
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
        
        function TabFuncs:CreateSection(sectionOptions)
            local sectionName = sectionOptions.Name or "Section"
            local side = sectionOptions.Side or "Left"
            local parent = (side == "Right") and rightCol or leftCol
            
            local section = Create("Frame", {
                Name = sectionName,
                Size = UDim2.new(1, 0, 0, 25),
                BackgroundTransparency = 1,
                Parent = parent
            })
            
            -- Section Title
            Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Text = sectionName,
                TextColor3 = theme.TextDim,
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = section
            })
            
            -- Container
            local container = Create("Frame", {
                Name = "Container",
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 22),
                BackgroundTransparency = 1,
                Parent = section
            }, {
                Create("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder})
            })
            
            -- Auto resize
            container:FindFirstChildOfClass("UIListLayout"):GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                local h = container:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y
                container.Size = UDim2.new(1, 0, 0, h)
                section.Size = UDim2.new(1, 0, 0, h + 25)
            end)
            
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
                
                -- Label
                Create("TextLabel", {
                    Size = UDim2.new(0, 100, 1, 0),
                    BackgroundTransparency = 1,
                    Text = toggleName,
                    TextColor3 = theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = toggle
                })
                
                -- Switch
                local switchBg = Create("Frame", {
                    Size = UDim2.new(0, 36, 0, 18),
                    Position = UDim2.new(0, 110, 0.5, -9),
                    BackgroundColor3 = state and theme.Toggle or theme.ToggleOff,
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
                
                -- Keybind Button
                local keybindBtn = Create("TextButton", {
                    Size = UDim2.new(0, 50, 0, 18),
                    Position = UDim2.new(0, 155, 0.5, -9),
                    BackgroundColor3 = theme.Element,
                    Text = "NONE",
                    TextColor3 = theme.TextDim,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    AutoButtonColor = false,
                    Parent = toggle
                }, {Create("UICorner", {CornerRadius = UDim.new(0, 4)})})
                
                -- Toggle indicator
                local indicator = Create("Frame", {
                    Size = UDim2.new(0, 8, 0, 8),
                    Position = UDim2.new(1, -12, 0.5, -4),
                    BackgroundColor3 = state and theme.Accent or theme.ToggleOff,
                    BorderSizePixel = 0,
                    Parent = toggle
                }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
                
                -- Toggle Object
                local toggleObj = {
                    Value = state,
                    SetValue = function(self, val)
                        state = val
                        self.Value = val
                        Tween(switchBg, {BackgroundColor3 = val and theme.Toggle or theme.ToggleOff})
                        Tween(knob, {Position = val and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)})
                        Tween(indicator, {BackgroundColor3 = val and theme.Accent or theme.ToggleOff})
                        callback(val)
                    end
                }
                
                -- Click handlers
                local switchBtn = Create("TextButton", {
                    Size = UDim2.new(0, 150, 1, 0),
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
                    BackgroundColor3 = theme.Element,
                    Text = btnName,
                    TextColor3 = theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    AutoButtonColor = false,
                    Parent = container
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
                    Create("UIStroke", {Color = theme.Border, Thickness = 1})
                })
                
                btn.MouseEnter:Connect(function()
                    Tween(btn, {BackgroundColor3 = theme.ElementHover})
                end)
                btn.MouseLeave:Connect(function()
                    Tween(btn, {BackgroundColor3 = theme.Element})
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
                    Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
                    Create("UIStroke", {Color = theme.Border, Thickness = 1})
                })
                
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
                
                Create("TextLabel", {
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -20, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = theme.TextDim,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    Parent = selectBtn
                })
                
                local list = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 2),
                    BackgroundColor3 = theme.Element,
                    Visible = false,
                    ZIndex = 100,
                    ClipsDescendants = true,
                    Parent = selectBtn
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
                    Create("UIStroke", {Color = theme.Border, Thickness = 1, ZIndex = 100}),
                    Create("UIListLayout", {Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder})
                })
                
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
                selectBtn.MouseButton1Click:Connect(function()
                    open = not open
                    list.Visible = open
                    if open then
                        Tween(list, {Size = UDim2.new(1, 0, 0, math.min(#options * 22, 110))})
                    else
                        Tween(list, {Size = UDim2.new(1, 0, 0, 0)})
                    end
                end)
                
                for _, opt in ipairs(options) do
                    local optBtn = Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 21),
                        BackgroundColor3 = theme.Element,
                        BackgroundTransparency = 1,
                        Text = opt,
                        TextColor3 = theme.TextDim,
                        Font = Enum.Font.Gotham,
                        TextSize = 11,
                        ZIndex = 101,
                        Parent = list
                    })
                    
                    optBtn.MouseEnter:Connect(function() optBtn.TextColor3 = theme.Accent end)
                    optBtn.MouseLeave:Connect(function() optBtn.TextColor3 = theme.TextDim end)
                    optBtn.MouseButton1Click:Connect(function()
                        dropObj:SetValue(opt)
                        open = false
                        Tween(list, {Size = UDim2.new(1, 0, 0, 0)})
                        task.wait(0.15)
                        list.Visible = false
                    end)
                end
                
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
                    Create("UIStroke", {Color = theme.Border, Thickness = 1}),
                    Create("UIPadding", {PaddingLeft = UDim.new(0, 8)})
                })
                
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
            
            return SectionFuncs
        end
        
        return TabFuncs
    end
    
    return WindowFuncs
end

return Library
