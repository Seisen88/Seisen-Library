# SeisenUI

<p align="center">
  <strong>A modern, feature-rich UI library for Roblox</strong>
</p>

<p align="center">
  <img src="docs/public/images/Windows.png" alt="SeisenUI Window Example" width="600">
</p>

> [!WARNING]
> SeisenUI is currently in active development. While stable, new features and improvements are being added regularly. Please report any issues you encounter.

## ✨ Features

- **🎨 Modern Dark Theme** - Sleek, professional dark interface with customizable accent colors
- **🎯 Lucide Icons** - Beautiful, consistent iconography with 1000+ icons
- **🧩 Rich Components** - Toggles, sliders, dropdowns, buttons, color pickers, and more
- **🎭 Theme System** - Live theme updates with built-in theme manager
- **💾 Save Manager** - Persistent settings across sessions
- **✨ Smooth Animations** - Polished transitions using TweenService
- **⌨️ Keybind Support** - Customizable keybinds for toggles
- **💡 Tooltips** - Helpful hover tooltips for better UX
- **📱 Responsive Design** - Scales beautifully across different screen sizes

## 📦 Installation

### Basic Installation

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Seisen88/Seisen-Library/main/SeisenUI.lua"))()
```

### Quick Start Example

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Seisen88/Seisen-Library/main/SeisenUI.lua"))()

-- Create a window
local Window = Library:CreateWindow({
    Title = "My Script",
    SubTitle = "v1.0.0",
    Size = UDim2.fromOffset(580, 460),
    Icon = "home" -- Lucide icon name
})

-- Add a tab
local Tab = Window:AddTab({
    Name = "Main",
    Icon = "settings"
})

-- Add a toggle
Tab:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(value)
        print("Auto Farm:", value)
    end
})

-- Add a slider
Tab:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Increment = 1,
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})
```

For more examples, check out:

- [Template.lua](https://github.com/Seisen88/Seisen-Library/blob/main/Template.lua) - Full feature showcase

## 🎨 Components

SeisenUI includes a comprehensive set of UI components designed for modern Roblox scripts:

### Toggle Switches

<img src="docs/public/images/Toggle.png" alt="Toggle Component" width="500">

On/off switches with optional keybind support. Perfect for enabling/disabling features.

```lua
Tab:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Keybind = Enum.KeyCode.F,
    Callback = function(value)
        print("Toggled:", value)
    end
})
```

### Sliders

<img src="docs/public/images/Slider.png" alt="Slider Component" width="500">

Numeric input with customizable ranges, increments, and value formatting.

```lua
Tab:AddSlider({
    Name = "Speed",
    Min = 0,
    Max = 100,
    Default = 50,
    Increment = 5,
    Suffix = "%",
    Callback = function(value)
        print("Speed:", value)
    end
})
```

### Dropdowns

<img src="docs/public/images/Dropdown.png" alt="Dropdown Component" width="500">

Selection lists with search functionality for easy navigation.

```lua
Tab:AddDropdown({
    Name = "Select Weapon",
    Options = {"Sword", "Bow", "Staff"},
    Default = "Sword",
    Callback = function(value)
        print("Selected:", value)
    end
})
```

### Tab Boxes

<img src="docs/public/images/Tabbox.png" alt="TabBox Component" width="500">

Organize related content into tabbed containers for better organization.

```lua
local TabBox = Tab:AddTabBox()
local SubTab1 = TabBox:AddTab("Combat")
local SubTab2 = TabBox:AddTab("Movement")
```

### Additional Components

- **Buttons** - Clickable buttons with double-click and confirm options
- **TextBox** - Text input fields with placeholders
- **ColorPicker** - Full-featured color selection with RGB/HSV
- **Labels** - Text labels for organization and information
- **Dividers** - Visual separators for better layout
- **Sections** - Group related components together

<img src="docs/public/images/Section.png" alt="Section Component" width="500">

### Common Properties

All components support these properties for enhanced functionality:

- **`Tooltip`** - Hover tooltips for helpful information
- **`Disabled`** - Disable/enable state for conditional features
- **`Visible`** - Show/hide elements dynamically
- **`Risky`** - Visual warning for dangerous actions (red accent)
- **`Flag`** - Unique identifier for saving/loading values

## 🔧 Advanced Features

### Theme Manager

<img src="docs/public/images/Thememanager.png" alt="Theme Manager" width="500">

Customize the entire UI color scheme with the built-in theme manager:

```lua
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Seisen88/Seisen-Library/main/addons/ThemeManager.lua"))()
ThemeManager:SetLibrary(Library)
ThemeManager:ApplyToTab(Tab)
```

### Save Manager

<img src="docs/public/images/Savemanager.png" alt="Save Manager" width="500">

Automatically save and load user settings across sessions:

```lua
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Seisen88/Seisen-Library/main/addons/SaveManager.lua"))()
SaveManager:SetLibrary(Library)
SaveManager:SetFolder("MyScript")
SaveManager:BuildConfigSection(Tab)
SaveManager:LoadAutoloadConfig()
```

### Custom Icons

Use Lucide icons by name or custom Roblox asset IDs:

```lua
-- Lucide icon
Tab:AddTab({
    Name = "Settings",
    Icon = "settings"
})

-- Custom asset ID
Tab:AddTab({
    Name = "Custom",
    Icon = "rbxassetid://1234567890"
})
```

## 📚 Documentation

For detailed documentation, API reference, and advanced usage, visit:

**[SeisenUI Documentation](https://seisen88.github.io/Seisen-Library/)**

## 🙏 Credits

### Icons

- [Lucide Icons](https://github.com/lucide-icons/lucide) - Beautiful & consistent icon toolkit

### Inspiration

- Various Roblox UI libraries that paved the way for modern UI design

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- [GitHub Repository](https://github.com/Seisen88/Seisen-Library)
- [Documentation](https://seisen88.github.io/Seisen-Library/)
- [Changelog](CHANGELOG.md)
- [Report Issues](https://github.com/Seisen88/Seisen-Library/issues)

---

<p align="center">
  Made with ❤️ by Seisen88
</p>
