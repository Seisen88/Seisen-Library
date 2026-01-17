--[[
    Seisen UI Demo Script
    Comprehensive showcase of all UI elements
    test
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ken-884/Seisen-Library/aeca827/SeisenUI.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ken-884/Seisen-Library/main/addons/SaveManager.lua?v="..os.time()))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ken-884/Seisen-Library/main/addons/ThemeManager.lua?v="..os.time()))()

-- Initialize addons
SaveManager:SetLibrary(Library)
SaveManager:SetFolder("SeisenDemo")
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("SeisenDemo")

-- Create Window
local Window = Library:CreateWindow({
    Name = "SEISEN LIBRARY",
    Icon = "rbxassetid://125926861378074", -- Dragon Logo
    ToggleKeybind = Enum.KeyCode.LeftAlt,
})

--============================================================--
-- MAIN TAB - All Basic Elements
--============================================================--
Window:AddSidebarSection("General")
local MainTab = Window:AddTab("Home", "General Features", "home")

Window:AddSidebarDivider()
Window:AddSidebarSection("Elements")
local ElementsTab = Window:AddTab("UI Showcase", "Element Demos", "monitor")
local ConfigTab = Window:AddTab("Settings", "Configuration", "settings")

-- Left Section: Toggles & Buttons
local ToggleSection = MainTab:AddSection("Toggles & Buttons", "Left")

ToggleSection:AddToggle({
    Name = "Enable Feature",
    Default = false,
    Flag = "Feature1",
    Callback = function(Value)
        print("Feature:", Value)
    end
})

ToggleSection:AddToggle({
    Name = "Auto Mode",
    Default = true,
    Flag = "AutoMode",
    Callback = function(Value)
        print("Auto Mode:", Value)
    end
})

ToggleSection:AddButton({
    Name = "Execute Action",
    Callback = function()
        print("Action executed!")
    end
})

ToggleSection:AddButton({
    Name = "Reset Settings",
    Callback = function()
        print("Settings reset!")
    end
})

-- Right Section: Sliders & Dropdowns
local SliderSection = MainTab:AddRightSection("Sliders & Dropdowns")

SliderSection:AddSlider({
    Name = "Speed",
    Min = 0,
    Max = 100,
    Default = 50,
    Flag = "SpeedValue",
    Callback = function(Value)
        print("Speed:", Value)
    end
})

SliderSection:AddSlider({
    Name = "Distance",
    Min = 10,
    Max = 500,
    Default = 100,
    Flag = "DistanceValue",
    Callback = function(Value)
        print("Distance:", Value)
    end
})

-- Right Section: Dropdowns & Textboxes
local InputSection = MainTab:AddSection("Inputs", "Right")

InputSection:AddDropdown({
    Name = "Select Mode",
    Options = {"Mode A", "Mode B", "Mode C", "Mode D", "Mode E"},
    Default = "Mode A",
    Flag = "ModeSelect",
    Callback = function(Value)
        print("Mode:", Value)
    end
})

InputSection:AddDropdown({
    Name = "Target Type",
    Options = {"Players", "NPCs", "All", "Custom"},
    Default = "Players",
    Flag = "TargetType",
    Callback = function(Value)
        print("Target:", Value)
    end
})

InputSection:AddTextbox({
    Name = "Player Name",
    Default = "",
    Placeholder = "Enter name...",
    Flag = "PlayerName",
    Callback = function(Value)
        print("Name:", Value)
    end
})

InputSection:AddTextbox({
    Name = "Custom Value",
    Default = "100",
    Placeholder = "Enter value...",
    Flag = "CustomValue",
    Callback = function(Value)
        print("Value:", Value)
    end
})

-- Right Section: Labels & Checkboxes
local MiscSection = MainTab:AddLeftSection("Misc Elements", "Right")

MiscSection:AddLabel({Text = "Status: Ready"})
MiscSection:AddLabel({Text = "Version: 1.0.0"})

MiscSection:AddCheckbox({
    Name = "Enable Notifications",
    Default = true,
    Flag = "Notifications",
    Callback = function(Value)
        print("Notifications:", Value)
    end
})

MiscSection:AddDivider("Separator")

MiscSection:AddKeybind({
    Name = "Toggle Key",
    Default = "F",
    Flag = "ToggleKeybind",
    Callback = function()
        print("Keybind pressed!")
    end
})

--============================================================--
-- TABBOX TAB - Demonstrating TabBox Feature
--============================================================--
local TabBoxTab = Window:AddTab("TabBox Demo", "layers")

-- Left TabBox
local LeftTabBox = TabBoxTab:AddLeftTabbox("Left Options")

local GeneralTab = LeftTabBox:AddTab("General")
GeneralTab:AddToggle({Name = "Option 1", Flag = "TB_Opt1"})
GeneralTab:AddToggle({Name = "Option 2", Flag = "TB_Opt2"})
GeneralTab:AddSlider({Name = "Value", Min = 0, Max = 50, Default = 25, Flag = "TB_Val1"})

local AdvancedTab = LeftTabBox:AddTab("Advanced")
AdvancedTab:AddToggle({Name = "Advanced 1", Flag = "TB_Adv1"})
AdvancedTab:AddButton({Name = "Run Test", Callback = function() print("Test!") end})
AdvancedTab:AddLabel({Text = "Advanced settings here"})

-- Right TabBox
local RightTabBox = TabBoxTab:AddRightTabbox("Right Options")

local Tab1 = RightTabBox:AddTab("Config A")
Tab1:AddToggle({Name = "Config Toggle", Flag = "TB_CfgA"})
Tab1:AddSlider({Name = "Config Value", Min = 0, Max = 100, Default = 50, Flag = "TB_CfgAVal"})

local Tab2 = RightTabBox:AddTab("Config B")
Tab2:AddButton({Name = "Apply Config B", Callback = function() print("Applied!") end})
Tab2:AddToggle({Name = "Enable B", Flag = "TB_CfgB"})

-- Regular sections alongside TabBoxes
local InfoSection = TabBoxTab:AddSection("Info", "Left")
InfoSection:AddLabel({Text = "TabBoxes condense multiple"})
InfoSection:AddLabel({Text = "sections into one container"})

--============================================================--
-- VISUALS TAB - Color Pickers & More
--============================================================--
local VisualsTab = Window:AddTab("Visuals", "eye")

local ColorSection = VisualsTab:AddSection("Colors", "Left")

ColorSection:AddColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "ESPColor",
    Callback = function(Value)
        print("ESP Color:", Value)
    end
})

ColorSection:AddColorPicker({
    Name = "Highlight Color",
    Default = Color3.fromRGB(0, 255, 0),
    Flag = "HighlightColor",
    Callback = function(Value)
        print("Highlight:", Value)
    end
})

ColorSection:AddToggle({
    Name = "Show ESP",
    Default = false,
    Flag = "ShowESP"
})

local RenderSection = VisualsTab:AddSection("Render", "Right")

RenderSection:AddSlider({
    Name = "FOV",
    Min = 30,
    Max = 120,
    Default = 70,
    Flag = "FOVValue"
})

RenderSection:AddDropdown({
    Name = "Quality",
    Options = {"Low", "Medium", "High", "Ultra"},
    Default = "High",
    Flag = "Quality"
})

--============================================================--
-- SETTINGS TAB - Theme & Save Manager
--============================================================--
local SettingsTab = Window:AddTab("Settings", "settings")

-- Theme Manager builds on Left
ThemeManager:BuildThemeSection(SettingsTab)

-- Save Manager builds on Left
SaveManager:BuildConfigSection(SettingsTab)

-- Custom settings on Right
local UtilSection = SettingsTab:AddLeftSection("Utilities", "Right")

UtilSection:AddButton({
    Name = "Copy Discord",
    Callback = function()
        setclipboard("discord.gg/seisen")
        print("Copied to clipboard!")
    end
})

UtilSection:AddButton({
    Name = "Join Discord",
    Callback = function()
        print("Opening Discord...")
    end
})

UtilSection:AddDivider()

UtilSection:AddSlider({
    Name = "Scale (%)",
    Min = 80,
    Max = 150,
    Default = 100,
    Callback = function(val)
        Window:SetScale(val/100)
    end
})

UtilSection:AddButton({
    Name = "Unload UI",
    Callback = function()
        Library:CloseAllDropdowns()
        -- Handle Custom Cursor cleanup too if needed, or SetCustomCursor(false)
        if Library.ScreenGui then Library.ScreenGui:Destroy() end
    end
})

print("[Seisen Demo] UI Loaded with all elements!")
