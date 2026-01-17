--[[
    Seisen UI Window Demo
    Simple demo to inspect window elements without content
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ken-884/Seisen-Library/main/SeisenUI.lua?v="..os.time()))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ken-884/Seisen-Library/main/addons/SaveManager.lua?v="..os.time()))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ken-884/Seisen-Library/main/addons/ThemeManager.lua?v="..os.time()))()

-- Initialize addons
SaveManager:SetLibrary(Library)
SaveManager:SetFolder("SeisenWindowDemo")
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("SeisenWindowDemo")

-- Create Window
local Window = Library:CreateWindow({
    Name = "Window Demo",
    Icon = "rbxassetid://125926861378074", -- Dragon Logo
    Subtitle = "Element Inspection",
    Author = "Seisen",
    Folder = "WindowDemo",
    Size = UDim2.fromOffset(580, 460),
    KeySystem = false
})

-- Initialize managers without creating tabs
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"BackgroundColor3"})
ThemeManager:SetFolder("SeisenWindowDemo")
SaveManager:SetFolder("SeisenWindowDemo")
SaveManager:BuildConfigSection(Window:CreateTab("Settings"))
ThemeManager:ApplyToTab(Window:CreateTab("Settings"))
