--[[
    Seisen UI Demo Script
    Demonstrates all UI components and addon features
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
    Name = "Seisen Hub Demo"
})

-- Combat Tab
local MainTab = Window:CreateTab({
    Name = "Combat"
})

-- Settings Tab
local SettingsTab = Window:CreateTab({
    Name = "Settings"
})

-- Combat Section (Left)
local AimbotSection = MainTab:CreateSection({
    Name = "Aimbot",
    Side = "Left"
})

AimbotSection:AddToggle({
    Name = "Enabled",
    Default = false,
    Callback = function(Value)
        print("Aimbot Enabled:", Value)
    end
})

AimbotSection:AddSlider({
    Name = "FOV Radius",
    Min = 0,
    Max = 500,
    Default = 100,
    Callback = function(Value)
        print("FOV Radius:", Value)
    end
})

AimbotSection:AddButton({
    Name = "Lock Target",
    Callback = function()
        print("Target Locked!")
    end
})

-- Visuals Section (Right)
local VisualsSection = MainTab:CreateSection({
    Name = "Visuals",
    Side = "Right"
})

VisualsSection:AddToggle({
    Name = "ESP",
    Default = true,
    Callback = function(Value)
        print("ESP Enabled:", Value)
    end
})

VisualsSection:AddDropdown({
    Name = "ESP Mode",
    Options = {"Box", "Tracers", "Chams", "Highlight"},
    Default = "Box",
    Callback = function(Option)
        print("ESP Mode:", Option)
    end
})

VisualsSection:AddSlider({
    Name = "ESP Distance",
    Min = 100,
    Max = 2000,
    Default = 500,
    Callback = function(Value)
        print("ESP Distance:", Value)
    end
})

-- Settings Tab - Themes
ThemeManager:BuildThemeSection(SettingsTab)

-- Settings Tab - Config
SaveManager:BuildConfigSection(SettingsTab)

-- Settings Tab - Misc
local MiscSection = SettingsTab:CreateSection({
    Name = "Misc",
    Side = "Right"
})

MiscSection:AddTextbox({
    Name = "Execute Script",
    Default = "",
    Placeholder = "print('Hello')",
    Callback = function(Text)
        print("Executing:", Text)
    end
})

MiscSection:AddButton({
    Name = "Unload UI",
    Callback = function()
        print("Unloaded")
        game.CoreGui.SeisenUI:Destroy()
    end
})

print("[Seisen Demo] UI Loaded Successfully!")
