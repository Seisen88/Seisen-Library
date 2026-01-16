--[[
    Seisen UI Library - Premium Edition
    Inspired by Rayfield's sleek design
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local Library = {
    Toggles = {},
    Options = {},
    Flags = {},
    Theme = {
        Background = Color3.fromRGB(15, 15, 15),
        Topbar = Color3.fromRGB(20, 20, 20),
        Sidebar = Color3.fromRGB(18, 18, 18),
        Card = Color3.fromRGB(22, 22, 22),
        Element = Color3.fromRGB(28, 28, 28),
        ElementHover = Color3.fromRGB(35, 35, 35),
        Border = Color3.fromRGB(40, 40, 40),
        Accent = Color3.fromRGB(100, 80, 255), -- Purple accent
        AccentDark = Color3.fromRGB(80, 60, 200),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(180, 180, 180),
        TextDim = Color3.fromRGB(120, 120, 120),
        Success = Color3.fromRGB(80, 200, 120),
        Error = Color3.fromRGB(255, 80, 80)
    }
}

-- Utility
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
    TweenService:Create(obj, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
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
            Tween(frame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05)
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
    
    -- Main Window
    local main = Create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 650, 0, 420),
        Position = UDim2.new(0.5, -325, 0.5, -210),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = gui
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
        Create("UIStroke", {Color = theme.Border, Thickness = 1})
    })
    
    -- Topbar
    local topbar = Create("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = theme.Topbar,
        BorderSizePixel = 0,
        Parent = main
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 10)})
    })
    
    -- Topbar bottom cover
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 15),
        Position = UDim2.new(0, 0, 1, -15),
        BackgroundColor3 = theme.Topbar,
        BorderSizePixel = 0,
        Parent = topbar
    })
    
    -- Title
    Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topbar
    })
    
    -- Accent Line under topbar
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        Parent = main
    })
    
    -- Tab Container (horizontal)
    local tabHolder = Create("Frame", {
        Name = "TabHolder",
        Size = UDim2.new(1, 0, 0, 35),
        Position = UDim2.new(0, 0, 0, 44),
        BackgroundColor3 = theme.Sidebar,
        BorderSizePixel = 0,
        Parent = main
    })
    
    local tabList = Create("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        Parent = tabHolder
    }, {
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8),
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder
        })
    })
    
    -- Content Area
    local content = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -20, 1, -95),
        Position = UDim2.new(0, 10, 0, 85),
        BackgroundTransparency = 1,
        Parent = main
    })
    
    local pages = Create("Folder", {Name = "Pages", Parent = content})
    
    MakeDraggable(topbar, main)
    
    -- Window Functions
    local WindowFuncs = {}
    local firstTab = true
    local activeTab = nil
    
    function WindowFuncs:CreateTab(tabOptions)
        local tabName = tabOptions.Name or "Tab"
        
        -- Tab Button
        local tabBtn = Create("TextButton", {
            Name = tabName,
            Size = UDim2.new(0, 0, 0, 28),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = theme.Element,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            Parent = tabList
        }, {
            Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
            Create("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)})
        })
        
        local tabLabel = Create("TextLabel", {
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = tabName,
            TextColor3 = theme.TextDim,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            Parent = tabBtn
        })
        
        -- Page
        local page = Create("ScrollingFrame", {
            Name = tabName,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = theme.Accent,
            Visible = false,
            Parent = pages
        })
        
        -- Two columns
        local leftCol = Create("Frame", {
            Name = "Left",
            Size = UDim2.new(0.5, -6, 1, 0),
            BackgroundTransparency = 1,
            Parent = page
        }, {Create("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder})})
        
        local rightCol = Create("Frame", {
            Name = "Right",
            Size = UDim2.new(0.5, -6, 1, 0),
            Position = UDim2.new(0.5, 6, 0, 0),
            BackgroundTransparency = 1,
            Parent = page
        }, {Create("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder})})
        
        -- Activation
        local function activate()
            if activeTab == tabBtn then return end
            
            -- Reset all
            for _, t in pairs(tabList:GetChildren()) do
                if t:IsA("TextButton") then
                    Tween(t, {BackgroundTransparency = 1})
                    local lbl = t:FindFirstChildOfClass("TextLabel")
                    if lbl then Tween(lbl, {TextColor3 = theme.TextDim}) end
                end
            end
            for _, p in pairs(pages:GetChildren()) do p.Visible = false end
            
            -- Activate this tab
            activeTab = tabBtn
            page.Visible = true
            Tween(tabBtn, {BackgroundTransparency = 0, BackgroundColor3 = theme.Accent})
            Tween(tabLabel, {TextColor3 = theme.Text})
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
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = theme.Card,
                BorderSizePixel = 0,
                Parent = parent
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                Create("UIStroke", {Color = theme.Border, Thickness = 1})
            })
            
            -- Section Title
            Create("TextLabel", {
                Size = UDim2.new(1, -24, 0, 32),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = sectionName,
                TextColor3 = theme.Accent,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = section
            })
            
            -- Container
            local container = Create("Frame", {
                Name = "Container",
                Size = UDim2.new(1, -16, 0, 0),
                Position = UDim2.new(0, 8, 0, 32),
                BackgroundTransparency = 1,
                Parent = section
            }, {
                Create("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder})
            })
            
            -- Auto resize
            container:FindFirstChildOfClass("UIListLayout"):GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                local h = container:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y
                container.Size = UDim2.new(1, -16, 0, h)
                section.Size = UDim2.new(1, 0, 0, h + 40)
            end)
            
            local SectionFuncs = {}
            
            -- Button
            function SectionFuncs:AddButton(btnOptions)
                local btnName = btnOptions.Name or "Button"
                local callback = btnOptions.Callback or function() end
                
                local btn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundColor3 = theme.Element,
                    Text = btnName,
                    TextColor3 = theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    AutoButtonColor = false,
                    Parent = container
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                    Create("UIStroke", {Color = theme.Border, Thickness = 1})
                })
                
                local stroke = btn:FindFirstChildOfClass("UIStroke")
                
                btn.MouseEnter:Connect(function()
                    Tween(btn, {BackgroundColor3 = theme.ElementHover})
                    Tween(stroke, {Color = theme.Accent})
                end)
                btn.MouseLeave:Connect(function()
                    Tween(btn, {BackgroundColor3 = theme.Element})
                    Tween(stroke, {Color = theme.Border})
                end)
                btn.MouseButton1Click:Connect(function()
                    Tween(btn, {BackgroundColor3 = theme.Accent})
                    task.wait(0.1)
                    Tween(btn, {BackgroundColor3 = theme.ElementHover})
                    callback()
                end)
            end
            
            -- Toggle
            function SectionFuncs:AddToggle(toggleOptions)
                local toggleName = toggleOptions.Name or "Toggle"
                local default = toggleOptions.Default or false
                local callback = toggleOptions.Callback or function() end
                local state = default
                
                local toggle = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundColor3 = theme.Element,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = container
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                    Create("UIStroke", {Color = theme.Border, Thickness = 1})
                })
                
                Create("TextLabel", {
                    Size = UDim2.new(1, -60, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = toggleName,
                    TextColor3 = theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = toggle
                })
                
                local switchBg = Create("Frame", {
                    Size = UDim2.new(0, 40, 0, 20),
                    Position = UDim2.new(1, -50, 0.5, -10),
                    BackgroundColor3 = state and theme.Accent or Color3.fromRGB(50, 50, 50),
                    BorderSizePixel = 0,
                    Parent = toggle
                }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
                
                local knob = Create("Frame", {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Parent = switchBg
                }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
                
                toggle.MouseButton1Click:Connect(function()
                    state = not state
                    callback(state)
                    Tween(switchBg, {BackgroundColor3 = state and theme.Accent or Color3.fromRGB(50, 50, 50)})
                    Tween(knob, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
                end)
                
                if default then callback(true) end
            end
            
            -- Slider
            function SectionFuncs:AddSlider(sliderOptions)
                local sliderName = sliderOptions.Name or "Slider"
                local min = sliderOptions.Min or 0
                local max = sliderOptions.Max or 100
                local default = sliderOptions.Default or min
                local callback = sliderOptions.Callback or function() end
                local value = default
                
                local slider = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundColor3 = theme.Element,
                    BorderSizePixel = 0,
                    Parent = container
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                    Create("UIStroke", {Color = theme.Border, Thickness = 1})
                })
                
                Create("TextLabel", {
                    Size = UDim2.new(1, -60, 0, 20),
                    Position = UDim2.new(0, 10, 0, 5),
                    BackgroundTransparency = 1,
                    Text = sliderName,
                    TextColor3 = theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = slider
                })
                
                local valLabel = Create("TextLabel", {
                    Size = UDim2.new(0, 50, 0, 20),
                    Position = UDim2.new(1, -60, 0, 5),
                    BackgroundTransparency = 1,
                    Text = tostring(value),
                    TextColor3 = theme.Accent,
                    Font = Enum.Font.GothamBold,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = slider
                })
                
                local bar = Create("TextButton", {
                    Size = UDim2.new(1, -20, 0, 8),
                    Position = UDim2.new(0, 10, 0, 32),
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
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
                
                local function update(input)
                    local pct = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    value = math.floor(min + (max - min) * pct)
                    fill.Size = UDim2.new(pct, 0, 1, 0)
                    valLabel.Text = tostring(value)
                    callback(value)
                end
                
                local sliding = false
                bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true; update(i) end end)
                UserInputService.InputChanged:Connect(function(i) if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
            end
            
            -- Dropdown
            function SectionFuncs:AddDropdown(dropOptions)
                local dropName = dropOptions.Name or "Dropdown"
                local options = dropOptions.Options or {}
                local default = dropOptions.Default or options[1]
                local callback = dropOptions.Callback or function() end
                
                local drop = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 56),
                    BackgroundColor3 = theme.Element,
                    BorderSizePixel = 0,
                    ClipsDescendants = false,
                    Parent = container
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                    Create("UIStroke", {Color = theme.Border, Thickness = 1})
                })
                
                Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 10, 0, 5),
                    BackgroundTransparency = 1,
                    Text = dropName,
                    TextColor3 = theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = drop
                })
                
                local selectBtn = Create("TextButton", {
                    Size = UDim2.new(1, -20, 0, 26),
                    Position = UDim2.new(0, 10, 0, 24),
                    BackgroundColor3 = theme.Card,
                    Text = default,
                    TextColor3 = theme.TextDark,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    Parent = drop
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
                    Create("UIPadding", {PaddingLeft = UDim.new(0, 8)})
                })
                
                local list = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 4),
                    BackgroundColor3 = theme.Card,
                    Visible = false,
                    ZIndex = 100,
                    ClipsDescendants = true,
                    Parent = selectBtn
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
                    Create("UIStroke", {Color = theme.Border, Thickness = 1}),
                    Create("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder})
                })
                
                local open = false
                selectBtn.MouseButton1Click:Connect(function()
                    open = not open
                    list.Visible = open
                    if open then
                        Tween(list, {Size = UDim2.new(1, 0, 0, math.min(#options * 28, 140))})
                    else
                        Tween(list, {Size = UDim2.new(1, 0, 0, 0)})
                    end
                end)
                
                for _, opt in pairs(options) do
                    local optBtn = Create("TextButton", {
                        Size = UDim2.new(1, -8, 0, 26),
                        BackgroundColor3 = theme.Card,
                        BackgroundTransparency = 1,
                        Text = opt,
                        TextColor3 = theme.TextDark,
                        Font = Enum.Font.Gotham,
                        TextSize = 13,
                        ZIndex = 101,
                        Parent = list
                    })
                    
                    optBtn.MouseEnter:Connect(function() optBtn.TextColor3 = theme.Accent end)
                    optBtn.MouseLeave:Connect(function() optBtn.TextColor3 = theme.TextDark end)
                    optBtn.MouseButton1Click:Connect(function()
                        selectBtn.Text = opt
                        callback(opt)
                        open = false
                        Tween(list, {Size = UDim2.new(1, 0, 0, 0)})
                        task.wait(0.2)
                        list.Visible = false
                    end)
                end
            end
            
            -- Textbox
            function SectionFuncs:AddTextbox(boxOptions)
                local boxName = boxOptions.Name or "Textbox"
                local default = boxOptions.Default or ""
                local placeholder = boxOptions.Placeholder or "..."
                local callback = boxOptions.Callback or function() end
                
                local box = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 56),
                    BackgroundColor3 = theme.Element,
                    BorderSizePixel = 0,
                    Parent = container
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                    Create("UIStroke", {Color = theme.Border, Thickness = 1})
                })
                
                Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 10, 0, 5),
                    BackgroundTransparency = 1,
                    Text = boxName,
                    TextColor3 = theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = box
                })
                
                local input = Create("TextBox", {
                    Size = UDim2.new(1, -20, 0, 26),
                    Position = UDim2.new(0, 10, 0, 24),
                    BackgroundColor3 = theme.Card,
                    Text = default,
                    PlaceholderText = placeholder,
                    TextColor3 = theme.Text,
                    PlaceholderColor3 = theme.TextDim,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    Parent = box
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
                    Create("UIPadding", {PaddingLeft = UDim.new(0, 8)})
                })
                
                local stroke = Create("UIStroke", {Color = theme.Border, Thickness = 1, Parent = input})
                
                input.Focused:Connect(function() Tween(stroke, {Color = theme.Accent}) end)
                input.FocusLost:Connect(function() Tween(stroke, {Color = theme.Border}); callback(input.Text) end)
            end
            
            return SectionFuncs
        end
        
        return TabFuncs
    end
    
    return WindowFuncs
end

return Library
