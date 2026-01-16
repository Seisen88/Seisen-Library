local Library = loadstring(readfile("seisenhubscript/SeisenUI.lua"))()

local Window = Library:CreateWindow({
    Name = "Seisen Hub Demo",
    Theme = {
        MainColor = Color3.fromRGB(20, 20, 20),
        SecondaryColor = Color3.fromRGB(30, 30, 30),
        AccentColor = Color3.fromRGB(0, 255, 128), -- Green Accent
        TextColor = Color3.fromRGB(255, 255, 255),
        PlaceholderColor = Color3.fromRGB(150, 150, 150),
        BorderColor = Color3.fromRGB(60, 60, 60)
    }
})

local MainTab = Window:CreateTab({
    Name = "Combat"
})

local SettingsTab = Window:CreateTab({
    Name = "Settings"
})

-- Combat Section
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

-- Visuals Section
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
    Options = {"Box", "Tracers", "Chams"},
    Default = "Box",
    Callback = function(Option)
        print("ESP Mode:", Option)
    end
})

-- Settings Tab
local ConfigSection = SettingsTab:CreateSection({
    Name = "Configuration",
    Side = "Left"
})

ConfigSection:AddTextbox({
    Name = "Execute Script",
    Default = "",
    Placeholder = "print('Hello')",
    Callback = function(Text)
        print("Executing:", Text)
    end
})

ConfigSection:AddButton({
    Name = "Unload UI",
    Callback = function()
        print("Unloaded")
        -- Since we didn't add a Destroy function in the library yet, just destroying the GUI manually if possible
        game.CoreGui.SeisenUI:Destroy()
    end
})
