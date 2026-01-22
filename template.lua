-- Load Seisen UI Library
local Repo = "https://raw.githubusercontent.com/Seisen88/Seisen-Library/main/"
local Library = loadstring(game:HttpGet(Repo .. "SeisenUI.lua"))()

-- Create Window
local Window = Library:CreateWindow({
    Name = "My Script",
    Icon = "home",
    ConfigSettings = true, -- Enable built-in settings (WalkSpeed, Fly, etc.)
    ToggleKeybind = Enum.KeyCode.RightShift
})

-- Create Tab
local MainTab = Window:AddTab("Main", "star")

-- Create Section
local MainSection = MainTab:AddLeftSection("Main Features", "zap")

-- Add UI Elements
MainSection:AddLabel({
    Text = "Welcome to My Script!"
})

MainSection:AddButton({
    Name = "Click Me",
    Callback = function()
        print("Button clicked!")
    end
})

MainSection:AddToggle({
    Name = "Example Toggle",
    Default = false,
    Flag = "ExampleToggle",
    Callback = function(value)
        print("Toggle is now:", value)
    end
})

MainSection:AddSlider({
    Name = "Example Slider",
    Min = 0,
    Max = 100,
    Default = 50,
    Flag = "ExampleSlider",
    Callback = function(value)
        print("Slider value:", value)
    end
})

MainSection:AddDropdown({
    Name = "Example Dropdown",
    Options = {"Option 1", "Option 2", "Option 3"},
    Default = "Option 1",
    Flag = "ExampleDropdown",
    Callback = function(value)
        print("Selected:", value)
    end
})

-- Optional: Load SaveManager and ThemeManager
local SaveManager = loadstring(game:HttpGet(Repo .. "addons/SaveManager.lua"))()
local ThemeManager = loadstring(game:HttpGet(Repo .. "addons/ThemeManager.lua"))()

-- Create UI Settings tab
local UISettingsTab = Window:AddTab("UI Settings", "palette")

-- Configure SaveManager
SaveManager:SetLibrary(Library)
SaveManager:SetFolder("MyScript")
SaveManager:BuildConfigSection(UISettingsTab)

-- Configure ThemeManager
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("MyScript")
ThemeManager:BuildThemeSection(UISettingsTab)

-- Load autoload config
SaveManager:LoadAutoloadConfig()
