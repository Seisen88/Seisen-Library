local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = {
    Connections = {},
    Flags = {},
    Theme = {
        MainColor = Color3.fromRGB(24, 24, 24), -- Clean Dark Gray
        SecondaryColor = Color3.fromRGB(32, 32, 32), -- Sidebar/Headers
        CardColor = Color3.fromRGB(40, 40, 40), -- Sections
        AccentColor = Color3.fromRGB(59, 130, 246), -- Bright Blue (#3B82F6)
        TextColor = Color3.fromRGB(240, 240, 240),
        SubTextColor = Color3.fromRGB(160, 160, 160),
        BorderColor = Color3.fromRGB(50, 50, 50),
        HoverColor = Color3.fromRGB(60, 60, 60)
    }
}

-- Utility: Rounded Corners
local function AddCorner(Parent, Radius)
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, Radius or 6)
    Corner.Parent = Parent
    return Corner
end

-- Utility: Stroke
local function AddStroke(Parent, Color, Thickness)
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color or Library.Theme.BorderColor
    Stroke.Thickness = Thickness or 1
    Stroke.Parent = Parent
    return Stroke
end

-- Utility: Draggable
local function MakeDraggable(TopBarObject, Object)
	local Dragging = nil
	local DragInput = nil
	local DragStart = nil
	local StartPosition = nil

	local function Update(Input)
		local Delta = Input.Position - DragStart
		local Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
		local Tween = TweenService:Create(Object, TweenInfo.new(0.05, Enum.EasingStyle.Sine), {Position = Position})
		Tween:Play()
	end

	TopBarObject.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = Input.Position
			StartPosition = Object.Position

			Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)

	TopBarObject.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
			DragInput = Input
		end
	end)

	UserInputService.InputChanged:Connect(function(Input)
		if Input == DragInput and Dragging then
			Update(Input)
		end
	end)
end

function Library:CreateWindow(Options)
    local Name = Options.Name or "Seisen UI"
    local Theme = Options.Theme or Library.Theme

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SeisenUI"
    ScreenGui.Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 750, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -375, 0.5, -250)
    MainFrame.BackgroundColor3 = Theme.MainColor
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true -- Important for rounded corners
    MainFrame.Parent = ScreenGui

    AddCorner(MainFrame, 10)
    AddStroke(MainFrame, Theme.BorderColor, 1)

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 220, 1, 0)
    Sidebar.BackgroundColor3 = Theme.SecondaryColor
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SidebarBorder = Instance.new("Frame")
    SidebarBorder.Size = UDim2.new(0, 1, 1, 0)
    SidebarBorder.Position = UDim2.new(1, -1, 0, 0)
    SidebarBorder.BackgroundColor3 = Theme.BorderColor
    SidebarBorder.BorderSizePixel = 0
    SidebarBorder.Parent = Sidebar

    -- Title Area
    local TitleArea = Instance.new("Frame")
    TitleArea.Size = UDim2.new(1, 0, 0, 60)
    TitleArea.BackgroundTransparency = 1
    TitleArea.Parent = Sidebar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -30, 1, 0)
    TitleLabel.Position = UDim2.new(0, 20, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Name
    TitleLabel.TextColor3 = Theme.TextColor
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 22
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleArea

    -- Tab Container
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, 0, 1, -70)
    TabContainer.Position = UDim2.new(0, 0, 0, 70)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 2
    TabContainer.Parent = Sidebar
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabContainer

    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -220, 1, 0)
    ContentArea.Position = UDim2.new(0, 220, 0, 0)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    local Pages = Instance.new("Folder")
    Pages.Name = "Pages"
    Pages.Parent = ContentArea

    MakeDraggable(Sidebar, MainFrame)

    local WindowFunctions = {}
    local FirstTab = true
    local ActiveTab = nil

    function WindowFunctions:CreateTab(TabOptions)
        local TabName = TabOptions.Name or "Tab"
        
        local TabButton = Instance.new("TextButton")
        TabButton.Name = TabName
        TabButton.Size = UDim2.new(0, 200, 0, 42)
        TabButton.BackgroundColor3 = Theme.SecondaryColor
        TabButton.BackgroundTransparency = 1
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabContainer

        AddCorner(TabButton, 8)

        local TabTitle = Instance.new("TextLabel")
        TabTitle.Size = UDim2.new(1, -40, 1, 0)
        TabTitle.Position = UDim2.new(0, 15, 0, 0)
        TabTitle.BackgroundTransparency = 1
        TabTitle.Text = TabName
        TabTitle.TextColor3 = Theme.SubTextColor
        TabTitle.Font = Enum.Font.GothamMedium
        TabTitle.TextSize = 14
        TabTitle.TextXAlignment = Enum.TextXAlignment.Left
        TabTitle.Parent = TabButton
        
        local ActiveBar = Instance.new("Frame")
        ActiveBar.Name = "ActiveBar"
        ActiveBar.Size = UDim2.new(0, 4, 0, 20)
        ActiveBar.Position = UDim2.new(0, 0, 0.5, -10)
        ActiveBar.BackgroundColor3 = Theme.AccentColor
        ActiveBar.BackgroundTransparency = 1 -- Hidden by default
        ActiveBar.BorderSizePixel = 0
        ActiveBar.Parent = TabButton
        AddCorner(ActiveBar, 2)

        -- Page
        local Page = Instance.new("ScrollingFrame")
        Page.Name = TabName
        Page.Size = UDim2.new(1, -30, 1, -30)
        Page.Position = UDim2.new(0, 15, 0, 15)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.Visible = false
        Page.Parent = Pages

        -- Columns
        local LeftCol = Instance.new("Frame")
        LeftCol.Size = UDim2.new(0.5, -8, 1, 0)
        LeftCol.BackgroundTransparency = 1
        LeftCol.Parent = Page
        
        local RightCol = Instance.new("Frame")
        RightCol.Size = UDim2.new(0.5, -8, 1, 0)
        RightCol.Position = UDim2.new(0.5, 8, 0, 0)
        RightCol.BackgroundTransparency = 1
        RightCol.Parent = Page
        
        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.Padding = UDim.new(0, 12)
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Parent = LeftCol
        
        local RightLayout = Instance.new("UIListLayout")
        RightLayout.Padding = UDim.new(0, 12)
        RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightLayout.Parent = RightCol

        -- Activation
        local function RotateTab()
            if ActiveTab == TabButton then return end
            
            -- Deactivate old
            for _, t in pairs(TabContainer:GetChildren()) do
                if t:IsA("TextButton") then
                    TweenService:Create(t, TweenInfo.new(0.2), {BackgroundColor3 = Theme.SecondaryColor}):Play()
                    TweenService:Create(t:FindFirstChild("TextLabel"), TweenInfo.new(0.2), {TextColor3 = Theme.SubTextColor}):Play()
                    TweenService:Create(t:FindFirstChild("ActiveBar"), TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                end
            end
            for _, p in pairs(Pages:GetChildren()) do p.Visible = false end

            -- Activate new
            ActiveTab = TabButton
            Page.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.CardColor}):Play()
            TweenService:Create(TabTitle, TweenInfo.new(0.2), {TextColor3 = Theme.TextColor}):Play()
            TweenService:Create(ActiveBar, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        end

        TabButton.MouseButton1Click:Connect(RotateTab)

        if FirstTab then
            RotateTab()
            FirstTab = false
        end

        local TabFuncs = {}
        
        function TabFuncs:CreateSection(SecOptions)
            local SecName = SecOptions.Name or "Section"
            local Side = SecOptions.Side or "Left"
            local Parent = (Side == "Right") and RightCol or LeftCol
            
            local Section = Instance.new("Frame")
            Section.BackgroundColor3 = Theme.CardColor
            Section.Parent = Parent
            AddCorner(Section, 8)
            
            local SecTitle = Instance.new("TextLabel")
            SecTitle.Size = UDim2.new(1, -20, 0, 35)
            SecTitle.Position = UDim2.new(0, 12, 0, 0)
            SecTitle.BackgroundTransparency = 1
            SecTitle.Text = SecName
            SecTitle.TextColor3 = Theme.TextColor
            SecTitle.Font = Enum.Font.GothamBold
            SecTitle.TextSize = 14
            SecTitle.TextXAlignment = Enum.TextXAlignment.Left
            SecTitle.Parent = Section
            
            local Divider = Instance.new("Frame")
            Divider.Size = UDim2.new(1, -24, 0, 1)
            Divider.Position = UDim2.new(0, 12, 0, 35)
            Divider.BackgroundColor3 = Theme.BorderColor
            Divider.BorderSizePixel = 0
            Divider.Parent = Section
            
            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, -20, 0, 0)
            Container.Position = UDim2.new(0, 10, 0, 45)
            Container.BackgroundTransparency = 1
            Container.Parent = Section
            
            local ContLayout = Instance.new("UIListLayout")
            ContLayout.Padding = UDim.new(0, 8)
            ContLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ContLayout.Parent = Container

            -- Auto-Resize
            ContLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Container.Size = UDim2.new(1, -20, 0, ContLayout.AbsoluteContentSize.Y)
                Section.Size = UDim2.new(1, 0, 0, ContLayout.AbsoluteContentSize.Y + 55)
            end)
            Section.Size = UDim2.new(1, 0, 0, 50) -- Init
            
            local SecFuncs = {}

            -- COMPONENTS

            function SecFuncs:AddButton(BtnOptions)
                local BtnName = BtnOptions.Name or "Button"
                local Callback = BtnOptions.Callback or function() end

                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 36)
                Btn.BackgroundColor3 = Theme.MainColor
                Btn.Text = BtnName
                Btn.TextColor3 = Theme.TextColor
                Btn.Font = Enum.Font.Gotham
                Btn.TextSize = 13
                Btn.AutoButtonColor = false
                Btn.Parent = Container
                AddCorner(Btn, 6)
                local Stroke = AddStroke(Btn, Theme.BorderColor, 1)

                Btn.MouseEnter:Connect(function()
                    TweenService:Create(Stroke, TweenInfo.new(0.2), {Color = Theme.AccentColor}):Play()
                    TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.HoverColor}):Play()
                end)
                Btn.MouseLeave:Connect(function()
                    TweenService:Create(Stroke, TweenInfo.new(0.2), {Color = Theme.BorderColor}):Play()
                    TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.MainColor}):Play()
                end)
                Btn.MouseButton1Click:Connect(Callback)
            end

            function SecFuncs:AddToggle(ToggleOptions)
                local Name = ToggleOptions.Name or "Toggle"
                local Callback = ToggleOptions.Callback or function() end
                local State = ToggleOptions.Default or false

                local Toggle = Instance.new("TextButton")
                Toggle.Size = UDim2.new(1, 0, 0, 36)
                Toggle.BackgroundColor3 = Theme.MainColor
                Toggle.Text = ""
                Toggle.AutoButtonColor = false
                Toggle.Parent = Container
                AddCorner(Toggle, 6)
                AddStroke(Toggle, Theme.BorderColor, 1)

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -50, 1, 0)
                Label.Position = UDim2.new(0, 12, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = Name
                Label.TextColor3 = Theme.TextColor
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = Toggle

                local Switch = Instance.new("Frame")
                Switch.Size = UDim2.new(0, 40, 0, 20)
                Switch.Position = UDim2.new(1, -50, 0.5, -10)
                Switch.BackgroundColor3 = State and Theme.AccentColor or Color3.fromRGB(60, 60, 60)
                Switch.Parent = Toggle
                AddCorner(Switch, 10)

                local Knob = Instance.new("Frame")
                Knob.Size = UDim2.new(0, 16, 0, 16)
                Knob.Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Knob.Parent = Switch
                AddCorner(Knob, 8)

                Toggle.MouseButton1Click:Connect(function()
                    State = not State
                    Callback(State)
                    TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = State and Theme.AccentColor or Color3.fromRGB(60, 60, 60)}):Play()
                    TweenService:Create(Knob, TweenInfo.new(0.2), {Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                end)
                
                if State then Callback(true) end
            end
            
            function SecFuncs:AddSlider(SlideOptions)
                local Name = SlideOptions.Name or "Slider"
                local Min = SlideOptions.Min or 0
                local Max = SlideOptions.Max or 100
                local Val = SlideOptions.Default or Min
                local Callback = SlideOptions.Callback or function() end

                local Slider = Instance.new("Frame")
                Slider.Size = UDim2.new(1, 0, 0, 55)
                Slider.BackgroundColor3 = Theme.MainColor
                Slider.Parent = Container
                AddCorner(Slider, 6)
                AddStroke(Slider, Theme.BorderColor, 1)

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 0, 20)
                Label.Position = UDim2.new(0, 12, 0, 8)
                Label.BackgroundTransparency = 1
                Label.Text = Name
                Label.TextColor3 = Theme.TextColor
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = Slider

                local ValLabel = Instance.new("TextLabel")
                ValLabel.Size = UDim2.new(0, 50, 0, 20)
                ValLabel.Position = UDim2.new(1, -60, 0, 8)
                ValLabel.BackgroundTransparency = 1
                ValLabel.Text = tostring(Val)
                ValLabel.TextColor3 = Theme.SubTextColor
                ValLabel.Font = Enum.Font.Gotham
                ValLabel.TextSize = 13
                ValLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValLabel.Parent = Slider

                local Bar = Instance.new("TextButton")
                Bar.Name = "Bar"
                Bar.Size = UDim2.new(1, -24, 0, 6)
                Bar.Position = UDim2.new(0, 12, 0, 36)
                Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                Bar.Text = ""
                Bar.AutoButtonColor = false
                Bar.Parent = Slider
                AddCorner(Bar, 3)

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new((Val - Min) / (Max - Min), 0, 1, 0)
                Fill.BackgroundColor3 = Theme.AccentColor
                Fill.Parent = Bar
                AddCorner(Fill, 3)

                local function Update(Input)
                    local P = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    Val = math.floor(Min + ((Max - Min) * P))
                    Fill.Size = UDim2.new(P, 0, 1, 0)
                    ValLabel.Text = tostring(Val)
                    Callback(Val)
                end

                local Active = false
                Bar.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Active = true
                        Update(Input)
                    end
                end)
                UserInputService.InputChanged:Connect(function(Input)
                    if Active and Input.UserInputType == Enum.UserInputType.MouseMovement then
                        Update(Input)
                    end
                end)
                UserInputService.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then Active = false end
                end)
            end

            function SecFuncs:AddDropdown(DropOptions)
                local Name = DropOptions.Name or "Dropdown"
                local List = DropOptions.Options or {}
                local Default = DropOptions.Default or List[1]
                local Callback = DropOptions.Callback or function() end

                local Drop = Instance.new("Frame")
                Drop.Size = UDim2.new(1, 0, 0, 56)
                Drop.BackgroundColor3 = Theme.MainColor
                Drop.Parent = Container
                AddCorner(Drop, 6)
                local Stroke = AddStroke(Drop, Theme.BorderColor, 1)

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 0, 20)
                Label.Position = UDim2.new(0, 12, 0, 6)
                Label.BackgroundTransparency = 1
                Label.Text = Name
                Label.TextColor3 = Theme.TextColor
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = Drop

                local SelectBtn = Instance.new("TextButton")
                SelectBtn.Size = UDim2.new(1, -24, 0, 26)
                SelectBtn.Position = UDim2.new(0, 12, 0, 24)
                SelectBtn.BackgroundColor3 = Theme.SecondaryColor
                SelectBtn.Text = Default
                SelectBtn.TextColor3 = Theme.SubTextColor
                SelectBtn.Font = Enum.Font.Gotham
                SelectBtn.TextSize = 13
                SelectBtn.TextXAlignment = Enum.TextXAlignment.Left
                SelectBtn.AutoButtonColor = false
                SelectBtn.Parent = Drop
                AddCorner(SelectBtn, 4)
                
                -- List Overlay
                local Overlay = Instance.new("Frame")
                Overlay.Name = "ListOverlay"
                Overlay.Size = UDim2.new(1, 0, 0, 0)
                Overlay.Position = UDim2.new(0, 0, 1, 5)
                Overlay.BackgroundColor3 = Theme.CardColor
                Overlay.Visible = false
                Overlay.ClipsDescendants = true
                Overlay.ZIndex = 100 -- Top
                Overlay.Parent = SelectBtn
                AddCorner(Overlay, 4)
                AddStroke(Overlay, Theme.BorderColor, 1)

                local ListLayout = Instance.new("UIListLayout")
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ListLayout.Parent = Overlay

                local Open = false
                SelectBtn.MouseButton1Click:Connect(function()
                    Open = not Open
                    Overlay.Visible = Open
                    if Open then
                         -- Calculate Height
                         local H = math.min(#List * 30, 150)
                         TweenService:Create(Overlay, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, H)}):Play()
                    else
                         TweenService:Create(Overlay, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                         wait(0.2)
                         Overlay.Visible = false
                    end
                end)

                for _, Opt in ipairs(List) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Size = UDim2.new(1, 0, 0, 30)
                    OptBtn.BackgroundColor3 = Theme.CardColor
                    OptBtn.Text = Opt
                    OptBtn.TextColor3 = Theme.SubTextColor
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.TextSize = 13
                    OptBtn.ZIndex = 101
                    OptBtn.Parent = Overlay
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        SelectBtn.Text = Opt
                        Callback(Opt)
                        Open = false
                        TweenService:Create(Overlay, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                        wait(0.2)
                        Overlay.Visible = false
                    end)
                end
            end
            
            function SecFuncs:AddTextbox(BoxOptions)
                local Name = BoxOptions.Name or "Textbox"
                local Default = BoxOptions.Default or ""
                local Placeholder = BoxOptions.Placeholder or "..."
                local Callback = BoxOptions.Callback or function() end

                local Box = Instance.new("Frame")
                Box.Size = UDim2.new(1, 0, 0, 56)
                Box.BackgroundColor3 = Theme.MainColor
                Box.Parent = Container
                AddCorner(Box, 6)
                AddStroke(Box, Theme.BorderColor, 1)

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 0, 20)
                Label.Position = UDim2.new(0, 12, 0, 6)
                Label.BackgroundTransparency = 1
                Label.Text = Name
                Label.TextColor3 = Theme.TextColor
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = Box

                local Input = Instance.new("TextBox")
                Input.Size = UDim2.new(1, -24, 0, 26)
                Input.Position = UDim2.new(0, 12, 0, 24)
                Input.BackgroundColor3 = Theme.SecondaryColor
                Input.Text = Default
                Input.PlaceholderText = Placeholder
                Input.TextColor3 = Theme.TextColor
                Input.PlaceholderColor3 = Theme.SubTextColor
                Input.Font = Enum.Font.Gotham
                Input.TextSize = 13
                Input.TextXAlignment = Enum.TextXAlignment.Left
                Input.Parent = Box
                AddCorner(Input, 4)

                Input.FocusLost:Connect(function()
                    Callback(Input.Text)
                end)
            end

            return SecFuncs
        end
        return TabFuncs
    end
    return WindowFunctions
end

return Library
