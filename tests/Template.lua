local Repo = "https://raw.githubusercontent.com/Seisen88/Seisen-Library/main/"
local Library = loadstring(game:HttpGet(Repo .. "SeisenUI.lua?v=" .. tostring(os.time()) .. "_" .. math.random(1000,9999)))()
local ThemeManager = loadstring(game:HttpGet(Repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(Repo .. "addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Name = "SeisenUI",
    Icon = "rbxassetid://125926861378074", -- Example Asset ID (or use Lucide "home")
    Theme = Library.Theme, -- Optional: Use default theme
    ToggleKeybind = Enum.KeyCode.LeftAlt,
    Version = "v1.0.0",      -- New Feature: Yellow Pill
    SubTitle = "Seisen Library"   -- New Feature: Green Pill
})

-- Sidebar Additions
Window:AddSidebarSection("Main Navigation")

-- Tab 1: Home
local HomeTab = Window:AddTab("Home", "Welcome", "user")

local HomeSection = HomeTab:AddSection("Information", "Left")
HomeSection:AddLabel({ Text = "Welcome to the Seisen UI Template!" })
HomeSection:AddLabel({ Text = "This script demonstrates every feature." })
HomeSection:AddDivider("Controls")
HomeSection:AddLabel({ Text = "Left Alt to toggle UI" })

Window:AddSidebarDivider()
Window:AddSidebarSection("Components")

-- Tab 2: Basic Elements
local ElementsTab = Window:AddTab("Elements", "Inputs & Logic", "box")

-- Left Column: Toggles & Buttons
local ToggleBox = ElementsTab:AddLeftSection("Toggles & Actions")

ToggleBox:AddToggle({
    Name = "Standard Toggle",
    Default = false,
    Flag = "Toggle1",
    Callback = function(Value)
        print("Toggle 1:", Value)
        Window:Notify({
            Title = "Toggle Updated",
            Content = "Standard Toggle is now " .. tostring(Value),
            Duration = 2
        })
    end,
    Tooltip = "This is a standard toggle with a tooltip!"
})

ToggleBox:AddToggle({
    Name = "Toggle with Keybind",
    Default = true,
    Flag = "ToggleKey",
    Keybind = Enum.KeyCode.Q,
    Callback = function(Value)
        print("Toggle Key:", Value)
    end
})

ToggleBox:AddCheckbox({
    Name = "Checkbox Style",
    Default = false,
    Flag = "Check1",
    Callback = function(Value)
        print("Checkbox:", Value)
    end
})

ToggleBox:AddDivider()

ToggleBox:AddButton({
    Name = "Simple Button",
    Callback = function()
        print("Button Clicked")
    end,
    Tooltip = "This button also has a tooltip"
})

ToggleBox:AddButton({
    Name = "Button with Tooltip (Mock)",
    Callback = function()
        -- Tooltip implementation example if needed
        print("Button 2 Clicked")
    end
})

ToggleBox:AddButton({
    Name = "Trigger Notification",
    Callback = function()
        Window:Notify({
            Title = "Test Notification",
            Content = "This is a test notification with a longer description to see how it wraps.",
            Duration = 5
        })
    end
})

-- Keybinds Section
local KeybindBox = ElementsTab:AddLeftSection("Keybinds")
KeybindBox:AddKeybind({
    Name = "Standalone Keybind",
    Default = "E",
    Mode = "Toggle", -- Toggle, Hold, Always
    Flag = "Keybind1",
    Callback = function()
        print("Keybind Pressed")
    end
})

-- Right Column: Inputs
local InputBox = ElementsTab:AddRightSection("Values & Inputs")

InputBox:AddSlider({
    Name = "Integer Slider",
    Min = 0,
    Max = 100,
    Default = 50,
    Flag = "SliderInt",
    Callback = function(Value)
        print("Slider Int:", Value)
    end
})

-- Note: Library only supports integer steps currently via flooring
InputBox:AddSlider({
    Name = "Steps Slider (Mock)",
    Min = 0,
    Max = 10,
    Default = 5,
    Flag = "SliderStep",
    Callback = function(Value)
        print("Slider Step:", Value)
    end
})

InputBox:AddDivider("Selections")

InputBox:AddDropdown({
    Name = "Single Selection",
    Options = {"Option A", "Option B", "Option C"},
    Default = "Option A",
    Flag = "Drop1",
    Callback = function(Value)
        print("Dropdown:", Value)
        Window:Notify({
            Title = "Selection Changed",
            Content = "You selected: " .. tostring(Value),
            Duration = 3,
            Image = "rbxassetid://10723415903" -- List icon
        })
    end
})

InputBox:AddTextbox({
    Name = "Text Input",
    Default = "",
    Placeholder = "Type here...",
    Flag = "Text1",
    Callback = function(Value)
        print("Text Input:", Value)
    end
})

InputBox:AddColorPicker({
    Name = "Accent Color",
    Default = Color3.fromRGB(0, 200, 100),
    Flag = "Color1",
    Callback = function(Value)
        print("Color Picked:", Value)
    end
})

-- Tab 3: Advanced
local AdvancedTab = Window:AddTab("Advanced", "Complex Items", "layers")

-- Left: Tabboxes
local LeftTabbox = AdvancedTab:AddLeftTabbox("Nested Tabs")

local NestedTab1 = LeftTabbox:AddTab("Settings A")
NestedTab1:AddToggle({ Name = "Nested Toggle 1", Flag = "NestT1" })
NestedTab1:AddButton({ Name = "Nested Action", Callback = function() print("Nest 1") end })

local NestedTab2 = LeftTabbox:AddTab("Settings B")
NestedTab2:AddLabel({ Text = "This is a second tab inside a box." })
NestedTab2:AddSlider({ Name = "Nested Slider", Min = 0, Max = 10, Default = 1, Flag = "NestS1" })

-- Right: Dependency & Visuals
local VisualBox = AdvancedTab:AddRightSection("Visuals & Logic")

-- Internal Tabbox (Tabbox inside a Section)
local InternalTabbox = VisualBox:AddTabbox({ Name = "Internal Tabbox" })

local IT1 = InternalTabbox:AddTab("Tab 1")
IT1:AddLabel({ Text = "This is inside a section!" })
IT1:AddButton({ Name = "Click Me", Callback = function() print("Internal Tab 1") end })

local IT2 = InternalTabbox:AddTab("Tab 2")
IT2:AddLabel({ Text = "Tab 2 Content" })

VisualBox:AddDivider("Logic")

VisualBox:AddLabel({ Text = "Dependency Box Demo:" })
VisualBox:AddToggle({
    Name = "Enable Detail View",
    Default = false,
    Flag = "ShowDetails"
})

-- DependencyBox: Only visible when "ShowDetails" toggle is ON
local DepBox = VisualBox:AddDependencyBox({
    DependsOn = "ShowDetails"
})

DepBox:AddLabel({ Text = "You can only see this if the toggle above is ON." })
DepBox:AddButton({ Name = "Secret Action", Callback = function() print("Secret!") end })

VisualBox:AddDivider("Media")

-- Viewport (Simple Part)
local TestPart = Instance.new("Part")
TestPart.Color = Color3.fromRGB(0, 150, 255)
TestPart.Material = Enum.Material.Neon
local ViewportParams = VisualBox:AddViewport({
    Height = 100
})
ViewportParams:SetModel(TestPart)

-- Image using a placeholder
VisualBox:AddImage({
    Image = "rbxassetid://125926861378074", -- Example image
    Height = 80
})

-- Passthrough (Custom Element)
local params = VisualBox:AddPassthrough({
    Height = 30
})
local customLabel = Instance.new("TextLabel")
customLabel.Size = UDim2.new(1, 0, 1, 0)
customLabel.BackgroundTransparency = 1
customLabel.Text = "Custom Passthrough Element"
customLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
customLabel.Font = Enum.Font.Code
customLabel.Parent = params

-- Tab 4: Settings (Theme & Config)
local SettingsTab = Window:AddTab("Settings", "Theme & Config", "settings")

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder("SeisenTemplate")
SaveManager:SetFolder("SeisenTemplate/Main")

ThemeManager:BuildThemeSection(SettingsTab)
SaveManager:BuildConfigSection(SettingsTab)

-- UI Settings (Scale)
local UISettings = SettingsTab:AddRightSection("UI Settings")
UISettings:AddSlider({
    Name = "UI Scale",
    Min = 90,
    Max = 120,
    Default = 100,
    Callback = function(Value)
        Window:SetScale(Value / 100)
    end
})


-- Finish
print("Seisen UI Template Loaded")
