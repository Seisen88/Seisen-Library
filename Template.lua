--[[
    Seisen UI Library Template
    This file serves as a complete template containing examples of every UI element.
    Use this as a starting point for your scripts.
]]

-- Load Library and Addons (using cache buster to ensure latest version)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ken-884/Seisen-Library/main/SeisenUI.lua?v="..os.time()))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ken-884/Seisen-Library/main/addons/SaveManager.lua?v="..os.time()))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ken-884/Seisen-Library/main/addons/ThemeManager.lua?v="..os.time()))()

-- Initialize Addons
SaveManager:SetLibrary(Library)
SaveManager:SetFolder("SeisenTemplate")
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("SeisenTemplate")

-- Create Window
local Window = Library:CreateWindow({
    Name = "Template Script",
    Icon = "rbxassetid://125926861378074", -- Replace with your icon
    Subtitle = "By Seisen",
    Author = "Seisen",
    Folder = "SeisenTemplate",
    Size = UDim2.fromOffset(580, 460),
    KeySystem = false -- Set to true to enable key system
})

-- Create Tabs
local MainTab = Window:CreateTab("Main", "Principal Features", "home")
local ElementsTab = Window:CreateTab("UI Elements", "Showcase of all items", "layers")
local SettingsTab = Window:CreateTab("Settings", "Theme & Config", "settings")

-- ==========================================
-- MAIN TAB EXAMPLES
-- ==========================================

local MainGroup = MainTab:CreateSection("Main Features", "Left")
local InfoGroup = MainTab:CreateSection("Information", "Right")

MainGroup:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Flag = "AutoFarm",
    Keybind = "F1", -- Optional built-in keybind
    Callback = function(val)
        print("Auto Farm set to:", val)
    end
})

MainGroup:AddSlider({
    Name = "WalkSpeed",
    Default = 16,
    Min = 16,
    Max = 500,
    decimals = 1,
    Flag = "WalkSpeed",
    Callback = function(val)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
})

InfoGroup:AddLabel({
    Text = "Welcome to the template script!\nThis demonstrates all library features.",
    Height = 40
})

InfoGroup:AddButton({
    Name = "Click Me",
    Callback = function()
        Library:Notify("Button Clicked!", "You clicked the button.", 3)
    end
})

-- ==========================================
-- UI ELEMENTS SHOWCASE
-- ==========================================

-- LEFT COLUMN
local TogglesGroup = ElementsTab:CreateSection("Toggles & Inputs", "Left")

TogglesGroup:AddToggle({Name = "Standard Toggle", Default = false})
TogglesGroup:AddCheckbox({Name = "Checkbox Style", Default = true})

TogglesGroup:AddDivider("Inputs")

TogglesGroup:AddTextbox({
    Name = "Text Input",
    Default = "Hello World",
    Placeholder = "Type here...",
    Flag = "MyTextbox",
    Callback = function(val)
        print("Input changed:", val)
    end
})

TogglesGroup:AddKeybind({
    Name = "Standalone Keybind",
    Default = "X",
    Mode = "Toggle", -- Toggle, Hold, Always
    Flag = "MyKeybind",
    Callback = function()
        print("Keybind activated!")
    end
})

-- RIGHT COLUMN
local SlidersGroup = ElementsTab:CreateSection("Sliders & Pickers", "Right")

SlidersGroup:AddSlider({
    Name = "Integer Slider",
    Default = 50, Min = 0, Max = 100,
    decimals = 0
})

SlidersGroup:AddDropdown({
    Name = "Single Selection",
    Options = {"Option 1", "Option 2", "Option 3"},
    Default = "Option 1",
    Flag = "Dropdown1",
    Callback = function(val) print(val) end
})

SlidersGroup:AddDropdown({
    Name = "Multi Selection",
    Options = {"Head", "Torso", "LeftArm", "RightArm"},
    Default = {"Head"},
    Multi = true,
    Flag = "MultiDropdown",
    Callback = function(val) print(table.concat(val, ", ")) end
})

SlidersGroup:AddColorPicker({
    Name = "Accent Color",
    Default = Color3.fromRGB(0, 255, 128),
    Flag = "ColorPicker1",
    Callback = function(color)
        print("Color changed")
    end
})

-- TABBOX EXAMPLE
local TabBox = ElementsTab:CreateTabbox({Name = "TabBox Example"}) -- Uses full width if no side specified? Or usually added to section? 
-- Wait, AddTabbox is usually a method of a Section in some libs, or Window in others.
-- Checking SeisenUI.lua line 2060: SectionFuncs:AddTabbox. So it must be inside a section.
-- Let's add a section for it.
local TabBoxSection = ElementsTab:CreateSection("TabBox Container", "Left")

-- Actually, in SeisenUI.lua:2060, AddTabbox puts it in `container` (which is the section container). 
-- BUT, in Demo.lua, it used `Window:AddLeftTabbox`??
-- Let's check Demo.lua usage of Tabbox.
-- In Demo.lua line 165: `local LeftTabBox = Window:AddLeftTabbox("TabBox Example")`
-- Wait, `AddLeftTabbox` is a method of `Window` (or `Library`).
-- Let's check `SeisenUI.lua` around Window creation.
-- Line 1464: `function WindowFuncs:AddLeftTabbox(name)`
-- Line 1475: `function WindowFuncs:AddRightTabbox(name)`
-- Ah, so there are two ways: Inside a section (`Section:AddTabbox`) or directly on the window columns (`Window:AddLeftTabbox`).
-- I will demonstrate `Window:AddLeftTabbox` in the Template as it's more clean for layout.

-- Correcting layout for Template
-- I'll use Window-level Tabboxes for the example.

local LeftBox = ElementsTab:AddLeftTabbox("Window TabBox")
local RightBox = ElementsTab:AddRightTabbox("Another TabBox")

local Tab1 = LeftBox:AddTab("Tab 1")
Tab1:AddToggle({Name = "Toggle inside TabBox"})
Tab1:AddSlider({Name = "Slider inside TabBox", Default=10, Min=0, Max=20})

local Tab2 = LeftBox:AddTab("Tab 2")
Tab2:AddLabel({Text = "This is a second tab"})

RightBox:AddTab("Settings"):AddButton({Name = "Reset", Callback = function() end})


-- ==========================================
-- SETTINGS TAB
-- ==========================================

SaveManager:BuildConfigSection(SettingsTab)
ThemeManager:ApplyToTab(SettingsTab)

-- Final Load
Library:Notify("Template Loaded", "Enjoy using Seisen UI!", 5)
