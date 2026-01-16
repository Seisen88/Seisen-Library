--[[
    Seisen UI Demo Script
    XEZIOS-style modern minimalist design
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ken-884/Seisen-Library/refs/heads/main/SeisenUI.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ken-884/Seisen-Library/refs/heads/main/addons/SaveManager.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ken-884/Seisen-Library/refs/heads/main/addons/ThemeManager.lua"))()

-- Initialize addons
SaveManager:SetLibrary(Library)
SaveManager:SetFolder("SeisenDemo")
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("SeisenDemo")

-- Create Window
local Window = Library:CreateWindow({
    Name = "SEISEN PRIME"
})

-- Combat Tab (using Lucide icon name)
local CombatTab = Window:CreateTab({
    Name = "Combat",
    Icon = "sword"  -- Lucide icon name
})

-- Visuals Tab
local VisualsTab = Window:CreateTab({
    Name = "Visuals",
    Icon = "eye"  -- Lucide icon name
})

-- Players Tab
local PlayersTab = Window:CreateTab({
    Name = "Players",
    Icon = "users"  -- Lucide icon name
})

-- Settings Tab
local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Icon = "settings"  -- Lucide icon name
})

-- Combat Sections
local AimbotSection = CombatTab:CreateSection({
    Name = "Section",
    Side = "Left"
})

AimbotSection:AddToggle({
    Name = "Toggle",
    Default = false,
    Flag = "AimbotEnabled",
    Callback = function(Value)
        print("Toggle:", Value)
    end
})

AimbotSection:AddButton({
    Name = "Button",
    Callback = function()
        print("Button clicked!")
    end
})

local Section2 = CombatTab:CreateSection({
    Name = "Section",
    Side = "Left"
})

Section2:AddToggle({
    Name = "Toggle",
    Default = false,
    Callback = function(Value)
        print("Toggle 2:", Value)
    end
})

Section2:AddButton({
    Name = "Button",
    Callback = function()
        print("Button 2 clicked!")
    end
})

-- Right side sections
local RightSection1 = CombatTab:CreateSection({
    Name = "Section",
    Side = "Right"
})

RightSection1:AddToggle({
    Name = "Toggle",
    Default = false,
    Callback = function(Value)
        print("Right Toggle:", Value)
    end
})

RightSection1:AddButton({
    Name = "Button",
    Callback = function()
        print("Right Button!")
    end
})

RightSection1:AddToggle({
    Name = "Toggle",
    Default = false,
    Callback = function(Value)
        print("Toggle:", Value)
    end
})

RightSection1:AddButton({
    Name = "Button",
    Callback = function()
        print("Button!")
    end
})

RightSection1:AddToggle({
    Name = "Toggle",
    Default = false,
    Callback = function(Value)
        print("Toggle:", Value)
    end
})

RightSection1:AddButton({
    Name = "Button",
    Callback = function()
        print("Button!")
    end
})

RightSection1:AddSlider({
    Name = "Slider",
    Min = 0,
    Max = 100,
    Default = 10,
    Flag = "SliderValue",
    Callback = function(Value)
        print("Slider:", Value)
    end
})

RightSection1:AddDropdown({
    Name = "Hello!",
    Options = {"Option 1", "Option 2", "Option 3"},
    Default = "Option 1",
    Flag = "DropdownValue",
    Callback = function(Value)
        print("Dropdown:", Value)
    end
})

RightSection1:AddTextbox({
    Name = "Hi",
    Default = "hello theree!!",
    Placeholder = "Enter text...",
    Flag = "TextboxValue",
    Callback = function(Value)
        print("Textbox:", Value)
    end
})

-- Settings Tab
ThemeManager:BuildThemeSection(SettingsTab)
SaveManager:BuildConfigSection(SettingsTab)

local MiscSection = SettingsTab:CreateSection({
    Name = "Misc",
    Side = "Right"
})

MiscSection:AddButton({
    Name = "Unload UI",
    Callback = function()
        game.CoreGui.SeisenUI:Destroy()
    end
})

print("[Seisen Demo] UI Loaded!")
