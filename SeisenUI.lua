local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = {
    Connections = {},
    Flags = {},
    Theme = {
        MainColor = Color3.fromRGB(18, 18, 18), -- Deep dark background
        SecondaryColor = Color3.fromRGB(28, 28, 28), -- Dark Sidebar/Header
        CardColor = Color3.fromRGB(35, 35, 35), -- Slightly lighter for sections
        AccentColor = Color3.fromRGB(0, 122, 255), -- Modern Blue
        TextColor = Color3.fromRGB(255, 255, 255),
        SubTextColor = Color3.fromRGB(180, 180, 180),
        BorderColor = Color3.fromRGB(45, 45, 45),
        SuccessColor = Color3.fromRGB(50, 205, 50),
        WarningColor = Color3.fromRGB(255, 180, 0),
        DangerColor = Color3.fromRGB(255, 60, 60)
    }
}

-- Utility Functions
local function MakeDraggable(TopBarObject, Object)
	local Dragging = nil
	local DragInput = nil
	local DragStart = nil
	local StartPosition = nil

	local function Update(Input)
		local Delta = Input.Position - DragStart
		local Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
		local Tween = TweenService:Create(Object, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Position = Position})
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

local function Ripple(Object)
    spawn(function()
        local Circle = Instance.new("ImageLabel")
        Circle.Parent = Object
        Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Circle.BackgroundTransparency = 1
        Circle.Image = "rbxassetid://266543268"
        Circle.ImageColor3 = Color3.fromRGB(210, 210, 210)
        Circle.ImageTransparency = 0.8
        Circle.ClipDescendants = true
        
        local MousePosition = UserInputService:GetMouseLocation()
        local RelativePosition = MousePosition - Object.AbsolutePosition
        
        Circle.Position = UDim2.new(0, RelativePosition.X, 0, RelativePosition.Y)
        Circle.Size = UDim2.new(0, 0, 0, 0)
        Circle.AnchorPoint = Vector2.new(0.5, 0.5)

        local Tween = TweenService:Create(Circle, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 500, 0, 500), ImageTransparency = 1})
        Tween:Play()
        Tween.Completed:Wait()
        Circle:Destroy()
    end)
end

function Library:CreateWindow(Options)
    local Name = Options.Name or "Seisen UI"
    local Theme = Options.Theme or Library.Theme

    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SeisenUI"
    ScreenGui.Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 700, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -350, 0.5, -225)
    MainFrame.BackgroundColor3 = Theme.MainColor
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.BorderColor
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame
    
    -- Drop Shadow (Simulated with ImageLabel usually, but using UIStroke for now or we can add a shadow holder)
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 200, 1, 0)
    Sidebar.BackgroundColor3 = Theme.SecondaryColor
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 8)
    SidebarCorner.Parent = Sidebar
    
    -- Fix Corner (Make right side flat for connection)
    local SidebarCover = Instance.new("Frame")
    SidebarCover.Name = "Cover"
    SidebarCover.Size = UDim2.new(0, 10, 1, 0)
    SidebarCover.Position = UDim2.new(1, -10, 0, 0)
    SidebarCover.BackgroundColor3 = Theme.SecondaryColor
    SidebarCover.BorderSizePixel = 0
    SidebarCover.Parent = Sidebar
    
    local SidebarLine = Instance.new("Frame")
    SidebarLine.Name = "Line"
    SidebarLine.Size = UDim2.new(0, 1, 1, 0)
    SidebarLine.Position = UDim2.new(1, 0, 0, 0)
    SidebarLine.BackgroundColor3 = Theme.BorderColor
    SidebarLine.BorderSizePixel = 0
    SidebarLine.Parent = Sidebar
    
    -- Title
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, -40, 0, 50)
    TitleLabel.Position = UDim2.new(0, 20, 0, 10)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Name
    TitleLabel.TextColor3 = Theme.TextColor
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 20
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Sidebar
    
    -- Tab Container
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 1, -70)
    TabContainer.Position = UDim2.new(0, 0, 0, 70)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Sidebar
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 8)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabListLayout.Parent = TabContainer

    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -200, 1, 0)
    ContentArea.Position = UDim2.new(0, 200, 0, 0)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame
    
    local ContentPages = Instance.new("Folder")
    ContentPages.Name = "Pages"
    ContentPages.Parent = ContentArea
    
    MakeDraggable(Sidebar, MainFrame) -- Drag from sidebar

    -- Window Logic
    local WindowFunctions = {}
    local FirstTab = true
    local CurrentTab = nil
    
    function WindowFunctions:CreateTab(TabOptions)
        local TabName = TabOptions.Name or "Tab"
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = TabName
        TabButton.Size = UDim2.new(0, 180, 0, 40)
        TabButton.BackgroundColor3 = Theme.SecondaryColor
        TabButton.BackgroundTransparency = 1
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabContainer
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton
        
        local TabTitle = Instance.new("TextLabel")
        TabTitle.Name = "Title"
        TabTitle.Size = UDim2.new(1, -20, 1, 0)
        TabTitle.Position = UDim2.new(0, 15, 0, 0)
        TabTitle.BackgroundTransparency = 1
        TabTitle.Text = TabName
        TabTitle.TextColor3 = Theme.SubTextColor
        TabTitle.Font = Enum.Font.GothamMedium
        TabTitle.TextSize = 14
        TabTitle.TextXAlignment = Enum.TextXAlignment.Left
        TabTitle.Parent = TabButton
        
        local TabIndicator = Instance.new("Frame")
        TabIndicator.Name = "Indicator"
        TabIndicator.Size = UDim2.new(0, 4, 0, 24)
        TabIndicator.Position = UDim2.new(0, 0, 0.5, -12)
        TabIndicator.BackgroundColor3 = Theme.AccentColor
        TabIndicator.BackgroundTransparency = 1
        TabIndicator.BorderSizePixel = 0
        TabIndicator.Parent = TabButton
        
        local TabIndCorner = Instance.new("UICorner")
        TabIndCorner.CornerRadius = UDim.new(0, 2)
        TabIndCorner.Parent = TabIndicator
        
        -- Page Frame
        local Page = Instance.new("ScrollingFrame")
        Page.Name = TabName
        Page.Size = UDim2.new(1, -20, 1, -20)
        Page.Position = UDim2.new(0, 10, 0, 10)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Theme.AccentColor
        Page.Visible = false
        Page.Parent = ContentPages
        
        -- Two Column Layout for Page
        local LeftColumn = Instance.new("Frame")
        LeftColumn.Name = "LeftColumn"
        LeftColumn.Size = UDim2.new(0.5, -5, 1, 0) 
        LeftColumn.BackgroundTransparency = 1
        LeftColumn.Parent = Page
        
        local RightColumn = Instance.new("Frame")
        RightColumn.Name = "RightColumn"
        RightColumn.Size = UDim2.new(0.5, -5, 1, 0)
        RightColumn.Position = UDim2.new(0.5, 5, 0, 0)
        RightColumn.BackgroundTransparency = 1
        RightColumn.Parent = Page
        
        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.Padding = UDim.new(0, 10)
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Parent = LeftColumn

        local RightLayout = Instance.new("UIListLayout")
        RightLayout.Padding = UDim.new(0, 10)
        RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightLayout.Parent = RightColumn
        
        -- Activation
        local function Activate()
            if CurrentTab == TabButton then return end
            
            -- Reset others
            for _, btn in pairs(TabContainer:GetChildren()) do
                if btn:IsA("TextButton") then
                    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.SecondaryColor}):Play()
                    TweenService:Create(btn:FindFirstChild("Title"), TweenInfo.new(0.2), {TextColor3 = Theme.SubTextColor}):Play()
                    TweenService:Create(btn:FindFirstChild("Indicator"), TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                end
            end
            for _, p in pairs(ContentPages:GetChildren()) do
                p.Visible = false
            end
            
            -- Activate Current
            CurrentTab = TabButton
            Page.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.CardColor}):Play()
            TweenService:Create(TabTitle, TweenInfo.new(0.2), {TextColor3 = Theme.TextColor}):Play()
            TweenService:Create(TabIndicator, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        end
        
        TabButton.MouseButton1Click:Connect(Activate)
        
        if FirstTab then
            Activate()
            FirstTab = false
        end
        
        -- Sections
        local TabFunctions = {}
        
        function TabFunctions:CreateSection(SectionOptions)
            local SectionName = SectionOptions.Name or "Section"
            local Side = SectionOptions.Side or "Left"
            
            local ParentColumn = (Side == "Right") and RightColumn or LeftColumn
            
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = SectionName
            SectionFrame.BackgroundColor3 = Theme.CardColor
            SectionFrame.BorderSizePixel = 0
            SectionFrame.Parent = ParentColumn
            
            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 6)
            SectionCorner.Parent = SectionFrame
            
            local SectionStroke = Instance.new("UIStroke")
            SectionStroke.Color = Theme.BorderColor
            SectionStroke.Thickness = 1
            SectionStroke.Parent = SectionFrame
            
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name = "Title"
            SectionTitle.Size = UDim2.new(1, -20, 0, 30)
            SectionTitle.Position = UDim2.new(0, 12, 0, 2)
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Text = SectionName
            SectionTitle.TextColor3 = Theme.TextColor
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.TextSize = 13
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.Parent = SectionFrame
            
            local Container = Instance.new("Frame")
            Container.Name = "Container"
            Container.Size = UDim2.new(1, -16, 0, 0)
            Container.Position = UDim2.new(0, 8, 0, 34)
            Container.BackgroundTransparency = 1
            Container.Parent = SectionFrame
            
            local ContainerLayout = Instance.new("UIListLayout")
            ContainerLayout.Padding = UDim.new(0, 6)
            ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ContainerLayout.Parent = Container
            
             -- Auto resize section
            ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Container.Size = UDim2.new(1, -16, 0, ContainerLayout.AbsoluteContentSize.Y)
                SectionFrame.Size = UDim2.new(1, 0, 0, ContainerLayout.AbsoluteContentSize.Y + 42)
            end)
            SectionFrame.Size = UDim2.new(1, 0, 0, 42) -- Init size
            
            local SectionFunctions = {}
            
            -- COMPONENTS
            
            -- Button
            function SectionFunctions:AddButton(BtnOptions)
                local BtnName = BtnOptions.Name or "Button"
                local Callback = BtnOptions.Callback or function() end
                
                local ButtonFrame = Instance.new("TextButton")
                ButtonFrame.Name = BtnName
                ButtonFrame.Size = UDim2.new(1, 0, 0, 34)
                ButtonFrame.BackgroundColor3 = Theme.MainColor
                ButtonFrame.BorderSizePixel = 0
                ButtonFrame.Text = ""
                ButtonFrame.AutoButtonColor = false
                ButtonFrame.Parent = Container
                
                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 4)
                BtnCorner.Parent = ButtonFrame
                
                local BtnStroke = Instance.new("UIStroke")
                BtnStroke.Color = Theme.BorderColor
                BtnStroke.Thickness = 1
                BtnStroke.Parent = ButtonFrame
                
                local BtnLabel = Instance.new("TextLabel")
                BtnLabel.Size = UDim2.new(1, 0, 1, 0)
                BtnLabel.BackgroundTransparency = 1
                BtnLabel.Text = BtnName
                BtnLabel.TextColor3 = Theme.TextColor
                BtnLabel.Font = Enum.Font.Gotham
                BtnLabel.TextSize = 13
                BtnLabel.Parent = ButtonFrame
                
                ButtonFrame.MouseEnter:Connect(function()
                    TweenService:Create(BtnStroke, TweenInfo.new(0.2), {Color = Theme.AccentColor}):Play()
                end)
                
                ButtonFrame.MouseLeave:Connect(function()
                    TweenService:Create(BtnStroke, TweenInfo.new(0.2), {Color = Theme.BorderColor}):Play()
                end)
                
                ButtonFrame.MouseButton1Click:Connect(function()
                    Ripple(ButtonFrame)
                    Callback()
                end)
            end
            
            -- Toggle
            function SectionFunctions:AddToggle(ToggleOptions)
                local ToggleName = ToggleOptions.Name or "Toggle"
                local Default = ToggleOptions.Default or false
                local Callback = ToggleOptions.Callback or function() end
                
                local Toggled = Default
                
                local ToggleFrame = Instance.new("TextButton")
                ToggleFrame.Name = ToggleName
                ToggleFrame.Size = UDim2.new(1, 0, 0, 34)
                ToggleFrame.BackgroundColor3 = Theme.MainColor
                ToggleFrame.BorderSizePixel = 0
                ToggleFrame.Text = ""
                ToggleFrame.AutoButtonColor = false
                ToggleFrame.Parent = Container
                
                local ToggleCorner = Instance.new("UICorner")
                ToggleCorner.CornerRadius = UDim.new(0, 4)
                ToggleCorner.Parent = ToggleFrame
                
                local ToggleStroke = Instance.new("UIStroke")
                ToggleStroke.Color = Theme.BorderColor
                ToggleStroke.Thickness = 1
                ToggleStroke.Parent = ToggleFrame
                
                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
                ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Text = ToggleName
                ToggleLabel.TextColor3 = Theme.TextColor
                ToggleLabel.Font = Enum.Font.Gotham
                ToggleLabel.TextSize = 13
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.Parent = ToggleFrame
                
                -- Switch Graphic
                local SwitchBg = Instance.new("Frame")
                SwitchBg.Name = "SwitchBg"
                SwitchBg.Size = UDim2.new(0, 34, 0, 18)
                SwitchBg.Position = UDim2.new(1, -40, 0.5, -9)
                SwitchBg.BackgroundColor3 = Toggled and Theme.AccentColor or Color3.fromRGB(60, 60, 60)
                SwitchBg.BorderSizePixel = 0
                SwitchBg.Parent = ToggleFrame
                
                local SwitchCorner = Instance.new("UICorner")
                SwitchCorner.CornerRadius = UDim.new(1, 0)
                SwitchCorner.Parent = SwitchBg
                
                local SwitchKnob = Instance.new("Frame")
                SwitchKnob.Name = "Knob"
                SwitchKnob.Size = UDim2.new(0, 14, 0, 14)
                SwitchKnob.Position = Toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                SwitchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SwitchKnob.BorderSizePixel = 0
                SwitchKnob.Parent = SwitchBg
                
                local KnobCorner = Instance.new("UICorner")
                KnobCorner.CornerRadius = UDim.new(1, 0)
                KnobCorner.Parent = SwitchKnob
                
                ToggleFrame.MouseButton1Click:Connect(function()
                    Toggled = not Toggled
                    Callback(Toggled)
                    
                    if Toggled then
                        TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Theme.AccentColor}):Play()
                        TweenService:Create(SwitchKnob, TweenInfo.new(0.2), {Position = UDim2.new(1, -16, 0.5, -7)}):Play()
                    else
                        TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
                        TweenService:Create(SwitchKnob, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -7)}):Play()
                    end
                end)
                
                if Default then Callback(true) end
            end
            
            -- Slider
            function SectionFunctions:AddSlider(SliderOptions)
                local SliderName = SliderOptions.Name or "Slider"
                local Min = SliderOptions.Min or 0
                local Max = SliderOptions.Max or 100
                local Default = SliderOptions.Default or Min
                local Callback = SliderOptions.Callback or function() end
                
                local Value = Default
                
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = SliderName
                SliderFrame.Size = UDim2.new(1, 0, 0, 50)
                SliderFrame.BackgroundColor3 = Theme.MainColor
                SliderFrame.BorderSizePixel = 0
                SliderFrame.Parent = Container
                
                local SliderCorner = Instance.new("UICorner")
                SliderCorner.CornerRadius = UDim.new(0, 4)
                SliderCorner.Parent = SliderFrame
                
                local SliderStroke = Instance.new("UIStroke")
                SliderStroke.Color = Theme.BorderColor
                SliderStroke.Thickness = 1
                SliderStroke.Parent = SliderFrame
                
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -20, 0, 20)
                Label.Position = UDim2.new(0, 10, 0, 5)
                Label.BackgroundTransparency = 1
                Label.Text = SliderName
                Label.TextColor3 = Theme.TextColor
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = SliderFrame
                
                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Size = UDim2.new(0, 40, 0, 20)
                ValueLabel.Position = UDim2.new(1, -50, 0, 5)
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Text = tostring(Value)
                ValueLabel.TextColor3 = Theme.SubTextColor
                ValueLabel.Font = Enum.Font.Gotham
                ValueLabel.TextSize = 13
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.Parent = SliderFrame
                
                local SlideBar = Instance.new("TextButton")
                SlideBar.Name = "Bar"
                SlideBar.Size = UDim2.new(1, -20, 0, 6)
                SlideBar.Position = UDim2.new(0, 10, 0, 32)
                SlideBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                SlideBar.AutoButtonColor = false
                SlideBar.Text = ""
                SlideBar.Parent = SliderFrame
                
                local BarCorner = Instance.new("UICorner")
                BarCorner.CornerRadius = UDim.new(1, 0)
                BarCorner.Parent = SlideBar
                
                local Fill = Instance.new("Frame")
                Fill.Name = "Fill"
                Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
                Fill.BackgroundColor3 = Theme.AccentColor
                Fill.BorderSizePixel = 0
                Fill.Parent = SlideBar
                
                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(1, 0)
                FillCorner.Parent = Fill
                
                local Circle = Instance.new("Frame")
                Circle.Name = "Circle"
                Circle.Size = UDim2.new(0, 12, 0, 12)
                Circle.Position = UDim2.new(1, -6, 0.5, -6)
                Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Circle.Parent = Fill
                
                local CircleCorner = Instance.new("UICorner")
                CircleCorner.CornerRadius = UDim.new(1, 0)
                CircleCorner.Parent = Circle
                
                local function Update(Input)
                    local SizeX = math.clamp((Input.Position.X - SlideBar.AbsolutePosition.X) / SlideBar.AbsoluteSize.X, 0, 1)
                    local NewValue = math.floor(Min + ((Max - Min) * SizeX))
                    Value = NewValue
                    
                    ValueLabel.Text = tostring(Value)
                    Fill.Size = UDim2.new(SizeX, 0, 1, 0)
                    Callback(Value)
                end
                
                local Sliding = false
                
                SlideBar.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Sliding = true
                        Update(Input)
                        TweenService:Create(Fill, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                    end
                end)
                
                SlideBar.InputEnded:Connect(function(Input)
                     if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Sliding = false
                        TweenService:Create(Fill, TweenInfo.new(0.1), {BackgroundColor3 = Theme.AccentColor}):Play()
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(Input)
                    if Sliding and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                        Update(Input)
                    end
                end)
            end
            
            -- Dropdown
            function SectionFunctions:AddDropdown(DropOptions)
                local DropName = DropOptions.Name or "Dropdown"
                local Options = DropOptions.Options or {}
                local Default = DropOptions.Default or Options[1]
                local Callback = DropOptions.Callback or function() end
                
                local DropFrame = Instance.new("Frame")
                DropFrame.Name = DropName
                DropFrame.Size = UDim2.new(1, 0, 0, 58)
                DropFrame.BackgroundTransparency = 1
                DropFrame.Parent = Container
                
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 0, 20)
                Label.BackgroundTransparency = 1
                Label.Text = DropName
                Label.TextColor3 = Theme.TextColor
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = DropFrame
                
                local Button = Instance.new("TextButton")
                Button.Size = UDim2.new(1, 0, 0, 32)
                Button.Position = UDim2.new(0, 0, 0, 24)
                Button.BackgroundColor3 = Theme.MainColor
                Button.Text = ""
                Button.AutoButtonColor = false
                Button.Parent = DropFrame
                
                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 4)
                BtnCorner.Parent = Button
                
                local BtnStroke = Instance.new("UIStroke")
                BtnStroke.Color = Theme.BorderColor
                BtnStroke.Thickness = 1
                BtnStroke.Parent = Button
                
                local SelectedLabel = Instance.new("TextLabel")
                SelectedLabel.Size = UDim2.new(1, -30, 1, 0)
                SelectedLabel.Position = UDim2.new(0, 10, 0, 0)
                SelectedLabel.BackgroundTransparency = 1
                SelectedLabel.Text = Default
                SelectedLabel.TextColor3 = Theme.SubTextColor
                SelectedLabel.Font = Enum.Font.Gotham
                SelectedLabel.TextSize = 13
                SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
                SelectedLabel.Parent = Button
                
                local Arrow = Instance.new("ImageLabel")
                Arrow.Size = UDim2.new(0, 20, 0, 20)
                Arrow.Position = UDim2.new(1, -25, 0.5, -10)
                Arrow.BackgroundTransparency = 1
                Arrow.Image = "rbxassetid://6034818372" -- Down Arrow
                Arrow.ImageColor3 = Theme.SubTextColor
                Arrow.Parent = Button
                
                local List = Instance.new("ScrollingFrame")
                List.Name = "List"
                List.Size = UDim2.new(1, 0, 0, 0)
                List.Position = UDim2.new(0, 0, 1, 5)
                List.BackgroundColor3 = Theme.MainColor
                List.BorderSizePixel = 0
                List.ZIndex = 50
                List.Visible = false
                List.ScrollBarThickness = 2
                List.Parent = Button
                
                local ListCorner = Instance.new("UICorner")
                ListCorner.CornerRadius = UDim.new(0, 4)
                ListCorner.Parent = List
                
                local ListStroke = Instance.new("UIStroke")
                ListStroke.Color = Theme.BorderColor
                ListStroke.Thickness = 1
                ListStroke.Parent = List
                
                local ListLayout = Instance.new("UIListLayout")
                ListLayout.Padding = UDim.new(0, 2)
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ListLayout.Parent = List
                
                local Open = false
                
                local function ToggleList()
                    Open = not Open
                    
                    if Open then
                        List.Visible = true
                        TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 180}):Play()
                         -- ZIndex handling hack: Ensure this dropdown renders above others
                         SectionFrame.ZIndex = 10
                         Container.ZIndex = 10
                         DropFrame.ZIndex = 10
                         Button.ZIndex = 10
                         
                         local ContentSize = ListLayout.AbsoluteContentSize.Y
                         local ClampSize = math.min(ContentSize, 150)
                         TweenService:Create(List, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, ClampSize)}):Play()
                    else
                         TweenService:Create(List, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                         TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
                         wait(0.2)
                         List.Visible = false
                         
                         SectionFrame.ZIndex = 1
                         Container.ZIndex = 1
                         DropFrame.ZIndex = 1
                         Button.ZIndex = 1
                    end
                end
                
                Button.MouseButton1Click:Connect(ToggleList)
                
                for _, opt in pairs(Options) do
                    local Item = Instance.new("TextButton")
                    Item.Size = UDim2.new(1, -10, 0, 25)
                    Item.BackgroundColor3 = Theme.MainColor
                    Item.BackgroundTransparency = 1
                    Item.Text = opt
                    Item.TextColor3 = Theme.SubTextColor
                    Item.Font = Enum.Font.Gotham
                    Item.TextSize = 13
                    Item.Parent = List
                    Item.ZIndex = 51
                    
                    Item.MouseEnter:Connect(function()
                        Item.TextColor3 = Theme.AccentColor
                    end)
                    Item.MouseLeave:Connect(function()
                        Item.TextColor3 = Theme.SubTextColor
                    end)
                    
                    Item.MouseButton1Click:Connect(function()
                        SelectedLabel.Text = opt
                        Callback(opt)
                        ToggleList()
                    end)
                end
            end
            
            -- Textbox
             function SectionFunctions:AddTextbox(BoxOptions)
                local BoxName = BoxOptions.Name or "Textbox"
                local Default = BoxOptions.Default or ""
                local Placeholder = BoxOptions.Placeholder or "Input..."
                local Callback = BoxOptions.Callback or function() end
                
                local BoxFrame = Instance.new("Frame")
                DropFrame = BoxFrame -- Copy paste safety
                BoxFrame.Name = BoxName
                BoxFrame.Size = UDim2.new(1, 0, 0, 58)
                BoxFrame.BackgroundTransparency = 1
                BoxFrame.Parent = Container
                
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 0, 20)
                Label.BackgroundTransparency = 1
                Label.Text = BoxName
                Label.TextColor3 = Theme.TextColor
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = BoxFrame
                
                local Input = Instance.new("TextBox")
                Input.Size = UDim2.new(1, 0, 0, 32)
                Input.Position = UDim2.new(0, 0, 0, 24)
                Input.BackgroundColor3 = Theme.MainColor
                Input.Text = Default
                Input.placeholderText = Placeholder
                Input.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
                Input.TextColor3 = Theme.TextColor
                Input.Font = Enum.Font.Gotham
                Input.TextSize = 13
                Input.Parent = BoxFrame
                
                local InputCorner = Instance.new("UICorner")
                InputCorner.CornerRadius = UDim.new(0, 4)
                InputCorner.Parent = Input
                
                local InputStroke = Instance.new("UIStroke")
                InputStroke.Color = Theme.BorderColor
                InputStroke.Thickness = 1
                InputStroke.Parent = Input
                
                Input.Focused:Connect(function()
                    TweenService:Create(InputStroke, TweenInfo.new(0.2), {Color = Theme.AccentColor}):Play()
                end)
                
                Input.FocusLost:Connect(function()
                    TweenService:Create(InputStroke, TweenInfo.new(0.2), {Color = Theme.BorderColor}):Play()
                    Callback(Input.Text)
                end)
            end
            
            return SectionFunctions
        end
        return TabFunctions
    end
    
    return WindowFunctions
end

return Library
