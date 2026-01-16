--[[
    Seisen UI - ThemeManager
    Handles theme switching and custom themes
]]

local HttpService = game:GetService("HttpService")

local ThemeManager = {}
ThemeManager.Folder = "SeisenConfigs"
ThemeManager.Library = nil

-- Built-in themes
ThemeManager.BuiltInThemes = {
    ["Default"] = {
        Background = Color3.fromRGB(15, 15, 15),
        Topbar = Color3.fromRGB(20, 20, 20),
        Sidebar = Color3.fromRGB(18, 18, 18),
        Card = Color3.fromRGB(22, 22, 22),
        Element = Color3.fromRGB(28, 28, 28),
        ElementHover = Color3.fromRGB(35, 35, 35),
        Border = Color3.fromRGB(40, 40, 40),
        Accent = Color3.fromRGB(100, 80, 255),
        AccentDark = Color3.fromRGB(80, 60, 200),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(180, 180, 180),
        TextDim = Color3.fromRGB(120, 120, 120)
    },
    ["Mint"] = {
        Background = Color3.fromRGB(28, 28, 28),
        Topbar = Color3.fromRGB(30, 30, 30),
        Sidebar = Color3.fromRGB(26, 26, 26),
        Card = Color3.fromRGB(36, 36, 36),
        Element = Color3.fromRGB(40, 40, 40),
        ElementHover = Color3.fromRGB(50, 50, 50),
        Border = Color3.fromRGB(55, 55, 55),
        Accent = Color3.fromRGB(61, 180, 136),
        AccentDark = Color3.fromRGB(50, 150, 110),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(180, 180, 180),
        TextDim = Color3.fromRGB(120, 120, 120)
    },
    ["Rose"] = {
        Background = Color3.fromRGB(25, 20, 22),
        Topbar = Color3.fromRGB(30, 25, 27),
        Sidebar = Color3.fromRGB(28, 22, 25),
        Card = Color3.fromRGB(35, 28, 32),
        Element = Color3.fromRGB(42, 35, 38),
        ElementHover = Color3.fromRGB(55, 45, 50),
        Border = Color3.fromRGB(60, 50, 55),
        Accent = Color3.fromRGB(219, 68, 103),
        AccentDark = Color3.fromRGB(180, 55, 85),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(200, 180, 185),
        TextDim = Color3.fromRGB(140, 120, 125)
    },
    ["Ocean"] = {
        Background = Color3.fromRGB(15, 20, 25),
        Topbar = Color3.fromRGB(18, 25, 32),
        Sidebar = Color3.fromRGB(16, 22, 28),
        Card = Color3.fromRGB(22, 30, 38),
        Element = Color3.fromRGB(28, 38, 48),
        ElementHover = Color3.fromRGB(35, 48, 60),
        Border = Color3.fromRGB(40, 55, 70),
        Accent = Color3.fromRGB(66, 135, 245),
        AccentDark = Color3.fromRGB(50, 110, 200),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(180, 195, 210),
        TextDim = Color3.fromRGB(120, 140, 160)
    },
    ["Dracula"] = {
        Background = Color3.fromRGB(40, 42, 54),
        Topbar = Color3.fromRGB(50, 52, 66),
        Sidebar = Color3.fromRGB(45, 47, 60),
        Card = Color3.fromRGB(55, 58, 72),
        Element = Color3.fromRGB(68, 71, 90),
        ElementHover = Color3.fromRGB(80, 84, 105),
        Border = Color3.fromRGB(98, 114, 164),
        Accent = Color3.fromRGB(255, 121, 198),
        AccentDark = Color3.fromRGB(220, 100, 170),
        Text = Color3.fromRGB(248, 248, 242),
        TextDark = Color3.fromRGB(200, 200, 195),
        TextDim = Color3.fromRGB(150, 150, 145)
    },
    ["Nord"] = {
        Background = Color3.fromRGB(46, 52, 64),
        Topbar = Color3.fromRGB(59, 66, 82),
        Sidebar = Color3.fromRGB(52, 59, 72),
        Card = Color3.fromRGB(67, 76, 94),
        Element = Color3.fromRGB(76, 86, 106),
        ElementHover = Color3.fromRGB(90, 102, 125),
        Border = Color3.fromRGB(76, 86, 106),
        Accent = Color3.fromRGB(136, 192, 208),
        AccentDark = Color3.fromRGB(110, 160, 175),
        Text = Color3.fromRGB(236, 239, 244),
        TextDark = Color3.fromRGB(200, 210, 220),
        TextDim = Color3.fromRGB(150, 160, 170)
    },
    ["Monokai"] = {
        Background = Color3.fromRGB(30, 31, 28),
        Topbar = Color3.fromRGB(39, 40, 34),
        Sidebar = Color3.fromRGB(35, 36, 31),
        Card = Color3.fromRGB(49, 50, 42),
        Element = Color3.fromRGB(60, 62, 52),
        ElementHover = Color3.fromRGB(75, 77, 65),
        Border = Color3.fromRGB(73, 72, 62),
        Accent = Color3.fromRGB(249, 38, 114),
        AccentDark = Color3.fromRGB(210, 30, 95),
        Text = Color3.fromRGB(248, 248, 242),
        TextDark = Color3.fromRGB(200, 200, 195),
        TextDim = Color3.fromRGB(140, 140, 135)
    },
    ["Catppuccin"] = {
        Background = Color3.fromRGB(30, 30, 46),
        Topbar = Color3.fromRGB(36, 36, 55),
        Sidebar = Color3.fromRGB(33, 33, 50),
        Card = Color3.fromRGB(48, 45, 65),
        Element = Color3.fromRGB(58, 55, 78),
        ElementHover = Color3.fromRGB(70, 68, 95),
        Border = Color3.fromRGB(87, 82, 104),
        Accent = Color3.fromRGB(245, 194, 231),
        AccentDark = Color3.fromRGB(210, 165, 200),
        Text = Color3.fromRGB(217, 224, 238),
        TextDark = Color3.fromRGB(180, 188, 205),
        TextDim = Color3.fromRGB(130, 138, 155)
    },
    ["Gruvbox"] = {
        Background = Color3.fromRGB(40, 40, 40),
        Topbar = Color3.fromRGB(50, 48, 47),
        Sidebar = Color3.fromRGB(45, 44, 43),
        Card = Color3.fromRGB(60, 56, 54),
        Element = Color3.fromRGB(80, 73, 69),
        ElementHover = Color3.fromRGB(100, 92, 88),
        Border = Color3.fromRGB(80, 73, 69),
        Accent = Color3.fromRGB(251, 73, 52),
        AccentDark = Color3.fromRGB(210, 60, 45),
        Text = Color3.fromRGB(235, 219, 178),
        TextDark = Color3.fromRGB(200, 185, 150),
        TextDim = Color3.fromRGB(150, 138, 110)
    },
    ["Tokyo Night"] = {
        Background = Color3.fromRGB(22, 22, 31),
        Topbar = Color3.fromRGB(26, 27, 38),
        Sidebar = Color3.fromRGB(24, 25, 35),
        Card = Color3.fromRGB(30, 32, 45),
        Element = Color3.fromRGB(40, 42, 58),
        ElementHover = Color3.fromRGB(52, 55, 75),
        Border = Color3.fromRGB(50, 50, 50),
        Accent = Color3.fromRGB(103, 89, 179),
        AccentDark = Color3.fromRGB(85, 72, 150),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(180, 180, 195),
        TextDim = Color3.fromRGB(120, 120, 140)
    }
}

-- File system helpers
local function EnsureFolder(path)
    if isfolder and makefolder then
        if not isfolder(path) then makefolder(path) end
    end
end

local function FileExists(path)
    return isfile and isfile(path)
end

local function ReadFile(path)
    return readfile and readfile(path)
end

local function WriteFile(path, content)
    if writefile then writefile(path, content) return true end
    return false
end

local function ListFiles(path)
    return listfiles and listfiles(path) or {}
end

function ThemeManager:SetLibrary(library)
    self.Library = library
    library.ThemeManager = self
end

function ThemeManager:SetFolder(folder)
    self.Folder = folder
    EnsureFolder(folder)
    EnsureFolder(folder .. "/themes")
end

function ThemeManager:GetThemeNames()
    local names = {}
    for name in pairs(self.BuiltInThemes) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

function ThemeManager:GetTheme(name)
    return self.BuiltInThemes[name]
end

function ThemeManager:ApplyTheme(name)
    local theme = self:GetTheme(name)
    if not theme or not self.Library then return false end
    
    self.Library.Theme = theme
    -- Note: Full theme application would require updating existing UI elements
    -- This sets the theme for new elements
    print("[ThemeManager] Applied theme:", name)
    return true
end

function ThemeManager:SaveCustomTheme(name, theme)
    local path = self.Folder .. "/themes/" .. name .. ".json"
    local data = {}
    
    for key, color in pairs(theme) do
        if typeof(color) == "Color3" then
            data[key] = color:ToHex()
        end
    end
    
    EnsureFolder(self.Folder .. "/themes")
    return WriteFile(path, HttpService:JSONEncode(data))
end

function ThemeManager:LoadCustomTheme(name)
    local path = self.Folder .. "/themes/" .. name .. ".json"
    
    if not FileExists(path) then return nil end
    
    local success, data = pcall(function()
        return HttpService:JSONDecode(ReadFile(path))
    end)
    
    if not success then return nil end
    
    local theme = {}
    for key, hex in pairs(data) do
        theme[key] = Color3.fromHex(hex)
    end
    
    return theme
end

function ThemeManager:GetCustomThemes()
    local themes = {}
    local path = self.Folder .. "/themes"
    
    EnsureFolder(path)
    
    for _, file in ipairs(ListFiles(path)) do
        if file:match("%.json$") then
            local name = file:match("([^/\\]+)%.json$")
            if name then
                table.insert(themes, name)
            end
        end
    end
    
    return themes
end

function ThemeManager:BuildThemeSection(tab)
    if not tab then return end
    
    local section = tab:CreateSection({
        Name = "Themes",
        Side = "Left"
    })
    
    local themeNames = self:GetThemeNames()
    local selectedTheme = "Default"
    
    section:AddDropdown({
        Name = "Theme",
        Options = themeNames,
        Default = "Default",
        Callback = function(value)
            selectedTheme = value
            self:ApplyTheme(value)
        end
    })
    
    section:AddButton({
        Name = "Apply Theme",
        Callback = function()
            self:ApplyTheme(selectedTheme)
        end
    })
end

return ThemeManager
