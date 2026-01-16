local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = {
    Connections = {},
    Flags = {},
    Theme = {
        MainColor = Color3.fromRGB(25, 25, 25),
        SecondaryColor = Color3.fromRGB(35, 35, 35),
        AccentColor = Color3.fromRGB(0, 150, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        PlaceholderColor = Color3.fromRGB(150, 150, 150),
        BorderColor = Color3.fromRGB(50, 50, 50)
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
		local Tween = TweenService:Create(Object, TweenInfo.new(0.15), {Position = Position})
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

    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SeisenUI"
    ScreenGui.Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game.CoreGui
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 650, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -325, 0.5, -200)
    MainFrame.BackgroundColor3 = Theme.MainColor
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 6)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.BorderColor
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame

    -- Top Bar (Draggable)
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 35)
    TopBar.BackgroundColor3 = Theme.SecondaryColor
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.CornerRadius = UDim.new(0, 6)
    TopBarCorner.Parent = TopBar

    -- Cover Bottom Corners of TopBar to make it look flush
    local TopBarCover = Instance.new("Frame")
    TopBarCover.Name = "Cover"
    TopBarCover.Size = UDim2.new(1, 0, 0, 10)
    TopBarCover.Position = UDim2.new(0, 0, 1, -10)
    TopBarCover.BackgroundColor3 = Theme.SecondaryColor
    TopBarCover.BorderSizePixel = 0
    TopBarCover.Parent = TopBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, -20, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Name
    TitleLabel.TextColor3 = Theme.TextColor
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    MakeDraggable(TopBar, MainFrame)

    -- Sidebar (Tabs)
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 160, 1, -45)
    Sidebar.Position = UDim2.new(0, 10, 0, 40)
    Sidebar.BackgroundColor3 = Theme.SecondaryColor
    Sidebar.BackgroundTransparency = 1
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 0
    Sidebar.Parent = MainFrame

    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Padding = UDim.new(0, 5)
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.Parent = Sidebar

    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -180, 1, -45)
    ContentArea.Position = UDim2.new(0, 175, 0, 40)
    ContentArea.BackgroundColor3 = Color3.new(0,0,0)
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel = 0
    ContentArea.Parent = MainFrame
    
    local ContentPages = Instance.new("Folder")
    ContentPages.Name = "Pages"
    ContentPages.Parent = ContentArea

    -- Window Table
    local WindowFunctions = {}
    local FirstTab = true

    function WindowFunctions:CreateTab(TabOptions)
        local TabName = TabOptions.Name or "Tab"
        -- local TabIcon = TabOptions.Icon -- Parsing icons later if needed
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = TabName
        TabButton.Size = UDim2.new(1, 0, 0, 32)
        TabButton.BackgroundColor3 = Theme.SecondaryColor
        TabButton.BackgroundTransparency = 1 
        TabButton.Text = TabName
        TabButton.TextColor3 = Theme.TextColor
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.TextSize = 13
        TabButton.TextTransparency = 0.5
        TabButton.Parent = Sidebar

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 4)
        TabCorner.Parent = TabButton
        
        -- Page Container
        local Page = Instance.new("ScrollingFrame")
        Page.Name = TabName
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.Visible = false -- Hidden by default
        Page.Parent = ContentPages
        
        -- Sections Layout (Left/Right) - We'll just use a vertical list for now or grid?
        -- The reference uses columns. Let's use two columns in the Page.
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

        -- Activation Logic
        local function Activate()
            for _, p in pairs(ContentPages:GetChildren()) do
                p.Visible = false
            end
            for _, b in pairs(Sidebar:GetChildren()) do
                if b:IsA("TextButton") then
                    TweenService:Create(b, TweenInfo.new(0.2), {TextTransparency = 0.5}):Play()
                end
            end
            
            Page.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
        end

        TabButton.MouseButton1Click:Connect(Activate)

        if FirstTab then
            Activate()
            FirstTab = false
        end

        -- Section Table
        local TabFunctions = {}

        function TabFunctions:CreateSection(SectionOptions)
            local SectionName = SectionOptions.Name or "Section"
            local Side = SectionOptions.Side or "Left"
            
            local ParentColumn = (Side == "Right") and RightColumn or LeftColumn
            
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = SectionName
            SectionFrame.BackgroundColor3 = Theme.SecondaryColor
            SectionFrame.BorderSizePixel = 0
            SectionFrame.Parent = ParentColumn
            
            -- We need to calculate size dynamically based on content, but for now fixed width, auto height
            -- Using UIAspectRatio or just Update event
            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 4)
            SectionCorner.Parent = SectionFrame
            
            local SectionStroke = Instance.new("UIStroke")
            SectionStroke.Color = Theme.BorderColor
            SectionStroke.Thickness = 1
            SectionStroke.Parent = SectionFrame

            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name = "Title"
            SectionTitle.Size = UDim2.new(1, -20, 0, 25)
            SectionTitle.Position = UDim2.new(0, 10, 0, 0)
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Text = SectionName
            SectionTitle.TextColor3 = Theme.TextColor
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.TextSize = 12
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.Parent = SectionFrame
            
            local Container = Instance.new("Frame")
            Container.Name = "Container"
            Container.Size = UDim2.new(1, -10, 0, 0)
            Container.Position = UDim2.new(0, 5, 0, 30)
            Container.BackgroundTransparency = 1
            Container.Parent = SectionFrame
            
            local ContainerLayout = Instance.new("UIListLayout")
            ContainerLayout.Padding = UDim.new(0, 5)
            ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ContainerLayout.Parent = Container

            -- Auto resize section
            ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Container.Size = UDim2.new(1, -10, 0, ContainerLayout.AbsoluteContentSize.Y)
                SectionFrame.Size = UDim2.new(1, 0, 0, ContainerLayout.AbsoluteContentSize.Y + 40)
            end)
            
            -- Initial Size
            SectionFrame.Size = UDim2.new(1, 0, 0, 40)

            local SectionFunctions = {}
            
            -- PLACEHOLDERS for Components
            function SectionFunctions:AddButton(BtnOptions)
                local BtnName = BtnOptions.Name or "Button"
                local Callback = BtnOptions.Callback or function() end
                
                local ButtonFrame = Instance.new("TextButton")
                ButtonFrame.Name = BtnName
                ButtonFrame.Size = UDim2.new(1, -10, 0, 32)
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
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.SecondaryColor}):Play()
                end)
                
                ButtonFrame.MouseLeave:Connect(function()
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.MainColor}):Play()
                end)

                ButtonFrame.MouseButton1Click:Connect(function()
                    Callback()
                    -- Click Effect
                    TweenService:Create(BtnLabel, TweenInfo.new(0.1), {TextSize = 11}):Play()
                    wait(0.1)
                    TweenService:Create(BtnLabel, TweenInfo.new(0.1), {TextSize = 13}):Play()
                end)
            end
            
            function SectionFunctions:AddToggle(ToggleOptions)
                local ToggleName = ToggleOptions.Name or "Toggle"
                local Default = ToggleOptions.Default or false
                local Callback = ToggleOptions.Callback or function() end
                
                local Toggled = Default
                
                local ToggleFrame = Instance.new("TextButton")
                ToggleFrame.Name = ToggleName
                ToggleFrame.Size = UDim2.new(1, -10, 0, 32)
                ToggleFrame.BackgroundColor3 = Color3.new(0,0,0)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Text = ""
                ToggleFrame.Parent = Container

                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.Size = UDim2.new(1, -40, 1, 0)
                ToggleLabel.Position = UDim2.new(0, 0, 0, 0)
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Text = ToggleName
                ToggleLabel.TextColor3 = Theme.TextColor
                ToggleLabel.Font = Enum.Font.Gotham
                ToggleLabel.TextSize = 13
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.Parent = ToggleFrame
                
                local ToggleBox = Instance.new("Frame")
                ToggleBox.Name = "Box"
                ToggleBox.Size = UDim2.new(0, 20, 0, 20)
                ToggleBox.Position = UDim2.new(1, -25, 0.5, -10)
                ToggleBox.BackgroundColor3 = Theme.MainColor
                ToggleBox.BorderSizePixel = 0
                ToggleBox.Parent = ToggleFrame
                
                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 4)
                BoxCorner.Parent = ToggleBox
                
                local BoxStroke = Instance.new("UIStroke")
                BoxStroke.Color = Theme.BorderColor
                BoxStroke.Thickness = 1
                BoxStroke.Parent = ToggleBox
                
                local Check = Instance.new("Frame")
                Check.Size = UDim2.new(1, -8, 1, -8)
                Check.Position = UDim2.new(0, 4, 0, 4)
                Check.BackgroundColor3 = Theme.AccentColor
                Check.BorderSizePixel = 0
                Check.Visible = Toggled
                Check.Parent = ToggleBox
                
                local CheckCorner = Instance.new("UICorner")
                CheckCorner.CornerRadius = UDim.new(0, 2)
                CheckCorner.Parent = Check

                ToggleFrame.MouseButton1Click:Connect(function()
                    Toggled = not Toggled
                    Check.Visible = Toggled
                    
                    if Toggled then
                        TweenService:Create(Check, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
                    else
                        TweenService:Create(Check, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                    end
                    
                    Callback(Toggled)
                end)
                
                -- Initialize Callback
                if Default then
                    Callback(true)
                end
            end
            
            function SectionFunctions:AddSlider(SliderOptions)
                local SliderName = SliderOptions.Name or "Slider"
                local Min = SliderOptions.Min or 0
                local Max = SliderOptions.Max or 100
                local Default = SliderOptions.Default or Min
                local Callback = SliderOptions.Callback or function() end
                
                local SliderVal = Default
                
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = SliderName
                SliderFrame.Size = UDim2.new(1, -10, 0, 45)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Parent = Container

                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.Size = UDim2.new(1, 0, 0, 20)
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Text = SliderName
                SliderLabel.TextColor3 = Theme.TextColor
                SliderLabel.Font = Enum.Font.Gotham
                SliderLabel.TextSize = 13
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.Parent = SliderFrame
                
                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Size = UDim2.new(1, 0, 0, 20)
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Text = tostring(SliderVal)
                ValueLabel.TextColor3 = Theme.TextColor
                ValueLabel.Font = Enum.Font.Gotham
                ValueLabel.TextSize = 13
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.Parent = SliderFrame
                
                local SliderBar = Instance.new("TextButton")
                SliderBar.Name = "Bar"
                SliderBar.Size = UDim2.new(1, 0, 0, 6)
                SliderBar.Position = UDim2.new(0, 0, 0, 30)
                SliderBar.BackgroundColor3 = Theme.MainColor
                SliderBar.BorderSizePixel = 0
                SliderBar.Text = ""
                SliderBar.AutoButtonColor = false
                SliderBar.Parent = SliderFrame
                
                local BarCorner = Instance.new("UICorner")
                BarCorner.CornerRadius = UDim.new(0, 3)
                BarCorner.Parent = SliderBar
                
                local Fill = Instance.new("Frame")
                Fill.Name = "Fill"
                Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
                Fill.BackgroundColor3 = Theme.AccentColor
                Fill.BorderSizePixel = 0
                Fill.Parent = SliderBar
                
                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(0, 3)
                FillCorner.Parent = Fill
                
                local function UpdateSlide(Input)
                    local SizeX = math.clamp((Input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    local NewValue = math.floor(Min + ((Max - Min) * SizeX))
                    
                    Fill.Size = UDim2.new(SizeX, 0, 1, 0)
                    ValueLabel.Text = tostring(NewValue)
                    Callback(NewValue)
                end
                
                local Sliding = false
                
                SliderBar.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Sliding = true
                        UpdateSlide(Input)
                    end
                end)
                
                SliderBar.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Sliding = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(Input)
                    if Sliding and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateSlide(Input)
                    end
                end)
            end

            function SectionFunctions:AddDropdown(DropdownOptions)
                local DropdownName = DropdownOptions.Name or "Dropdown"
                local Options = DropdownOptions.Options or {}
                local Default = DropdownOptions.Default or Options[1]
                local Callback = DropdownOptions.Callback or function() end
                
                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Name = DropdownName
                DropdownFrame.Size = UDim2.new(1, -10, 0, 60)
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.Parent = Container

                local Droplabel = Instance.new("TextLabel")
                Droplabel.Size = UDim2.new(1, 0, 0, 20)
                Droplabel.BackgroundTransparency = 1
                Droplabel.Text = DropdownName
                Droplabel.TextColor3 = Theme.TextColor
                Droplabel.Font = Enum.Font.Gotham
                Droplabel.TextSize = 13
                Droplabel.TextXAlignment = Enum.TextXAlignment.Left
                Droplabel.Parent = DropdownFrame

                local DropButton = Instance.new("TextButton")
                DropButton.Name = "DropButton"
                DropButton.Size = UDim2.new(1, 0, 0, 32)
                DropButton.Position = UDim2.new(0, 0, 0, 25)
                DropButton.BackgroundColor3 = Theme.MainColor
                DropButton.BorderSizePixel = 0
                DropButton.Text = Default
                DropButton.TextColor3 = Theme.TextColor
                DropButton.Font = Enum.Font.Gotham
                DropButton.TextSize = 13
                DropButton.AutoButtonColor = false
                DropButton.Parent = DropdownFrame
                
                local DropCorner = Instance.new("UICorner")
                DropCorner.CornerRadius = UDim.new(0, 4)
                DropCorner.Parent = DropButton
                
                local DropStroke = Instance.new("UIStroke")
                DropStroke.Color = Theme.BorderColor
                DropStroke.Thickness = 1
                DropStroke.Parent = DropButton
                
                local DropList = Instance.new("ScrollingFrame")
                DropList.Name = "List"
                DropList.Size = UDim2.new(1, 0, 0, 100)
                DropList.Position = UDim2.new(0, 0, 1, 5)
                DropList.BackgroundColor3 = Theme.MainColor
                DropList.BorderSizePixel = 0
                DropList.Visible = false
                DropList.ZIndex = 10
                DropList.ScrollBarThickness = 2
                DropList.Parent = DropButton
                
                local ListCorner = Instance.new("UICorner")
                ListCorner.CornerRadius = UDim.new(0, 4)
                ListCorner.Parent = DropList
                
                local ListLayout = Instance.new("UIListLayout")
                ListLayout.Padding = UDim.new(0, 2)
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ListLayout.Parent = DropList
                
                local Open = false
                
                DropButton.MouseButton1Click:Connect(function()
                    Open = not Open
                    DropList.Visible = Open
                    if Open then
                        TweenService:Create(DropButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.SecondaryColor}):Play()
                        SectionFrame.ZIndex = 20
                        DropdownFrame.ZIndex = 20
                        Droplabel.ZIndex = 20
                        DropButton.ZIndex = 20
                    else
                         TweenService:Create(DropButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.MainColor}):Play()
                         SectionFrame.ZIndex = 1
                         DropdownFrame.ZIndex = 1
                         Droplabel.ZIndex = 1
                         DropButton.ZIndex = 1
                    end
                end)
                
                local function RefreshList()
                    for _, child in pairs(DropList:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    
                    for _, option in pairs(Options) do
                        local OptBtn = Instance.new("TextButton")
                        OptBtn.Size = UDim2.new(1, -4, 0, 25)
                        OptBtn.BackgroundColor3 = Theme.MainColor
                        OptBtn.BackgroundTransparency = 1
                        OptBtn.Text = option
                        OptBtn.TextColor3 = Theme.TextColor
                        OptBtn.Font = Enum.Font.Gotham
                        OptBtn.TextSize = 13
                        OptBtn.Parent = DropList
                        OptBtn.ZIndex = 100 -- Ensure list items are on top
                        
                        OptBtn.MouseButton1Click:Connect(function()
                            DropButton.Text = option
                            Open = false
                            DropList.Visible = false
                            TweenService:Create(DropButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.MainColor}):Play()
                            SectionFrame.ZIndex = 1
                            DropdownFrame.ZIndex = 1
                            Droplabel.ZIndex = 1
                            DropButton.ZIndex = 1
                            Callback(option)
                        end)
                    end
                    
                    DropList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
                end
                
                RefreshList()
            end

            function SectionFunctions:AddTextbox(BoxOptions)
                local BoxName = BoxOptions.Name or "Textbox"
                local Default = BoxOptions.Default or ""
                local Placeholder = BoxOptions.Placeholder or "Input..."
                local Callback = BoxOptions.Callback or function() end
                
                local BoxFrame = Instance.new("Frame")
                BoxFrame.Name = BoxName
                BoxFrame.Size = UDim2.new(1, -10, 0, 60)
                BoxFrame.BackgroundTransparency = 1
                BoxFrame.Parent = Container

                local BoxLabel = Instance.new("TextLabel")
                BoxLabel.Size = UDim2.new(1, 0, 0, 20)
                BoxLabel.BackgroundTransparency = 1
                BoxLabel.Text = BoxName
                BoxLabel.TextColor3 = Theme.TextColor
                BoxLabel.Font = Enum.Font.Gotham
                BoxLabel.TextSize = 13
                BoxLabel.TextXAlignment = Enum.TextXAlignment.Left
                BoxLabel.Parent = BoxFrame
                
                local TextBox = Instance.new("TextBox")
                TextBox.Name = "Input"
                TextBox.Size = UDim2.new(1, 0, 0, 32)
                TextBox.Position = UDim2.new(0, 0, 0, 25)
                TextBox.BackgroundColor3 = Theme.MainColor
                TextBox.BorderSizePixel = 0
                TextBox.Text = Default
                TextBox.PlaceholderText = Placeholder
                TextBox.PlaceholderColor3 = Theme.PlaceholderColor
                TextBox.TextColor3 = Theme.TextColor
                TextBox.Font = Enum.Font.Gotham
                TextBox.TextSize = 13
                TextBox.Parent = BoxFrame
                
                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 4)
                BoxCorner.Parent = TextBox
                
                local BoxStroke = Instance.new("UIStroke")
                BoxStroke.Color = Theme.BorderColor
                BoxStroke.Thickness = 1
                BoxStroke.Parent = TextBox
                
                TextBox.Focused:Connect(function()
                    TweenService:Create(BoxStroke, TweenInfo.new(0.2), {Color = Theme.AccentColor}):Play()
                end)
                
                TextBox.FocusLost:Connect(function(EnterPressed)
                    TweenService:Create(BoxStroke, TweenInfo.new(0.2), {Color = Theme.BorderColor}):Play()
                    Callback(TextBox.Text)
                end)
            end

            return SectionFunctions
        end

        return TabFunctions
    end

    return WindowFunctions
end

return Library
