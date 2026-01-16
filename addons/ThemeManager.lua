--[[
    Seisen UI - ThemeManager (Obsidian-style)
    Full theme system with live UI updates
]]

local HttpService = game:GetService("HttpService")

local ThemeManager = {}
ThemeManager.Folder = "SeisenConfigs"
ThemeManager.Library = nil
ThemeManager.DefaultTheme = "Default"

-- 18 Built-in themes (Obsidian-style)
ThemeManager.BuiltInThemes = {
    ["Default"] = {
        Background = "1e1e23",
        Sidebar = "19191e",
        Content = "232328",
        Element = "373745",
        Border = "373745",
        Accent = "5a5aa0",
        Text = "ffffff",
        TextDim = "9696a0",
        TextMuted = "646470"
    },
    ["Mint"] = {
        Background = "1c1c1c",
        Sidebar = "181818",
        Content = "242424",
        Element = "373737",
        Border = "373737",
        Accent = "3db488",
        Text = "ffffff",
        TextDim = "aaaaaa",
        TextMuted = "666666"
    },
    ["Rose"] = {
        Background = "1c1c1c",
        Sidebar = "181818",
        Content = "242424",
        Element = "373737",
        Border = "373737",
        Accent = "db4467",
        Text = "ffffff",
        TextDim = "aaaaaa",
        TextMuted = "666666"
    },
    ["Dracula"] = {
        Background = "282a36",
        Sidebar = "21222c",
        Content = "44475a",
        Element = "6272a4",
        Border = "6272a4",
        Accent = "ff79c6",
        Text = "f8f8f2",
        TextDim = "bfc2d0",
        TextMuted = "6272a4"
    },
    ["Nord"] = {
        Background = "2e3440",
        Sidebar = "292e39",
        Content = "3b4252",
        Element = "4c566a",
        Border = "4c566a",
        Accent = "88c0d0",
        Text = "eceff4",
        TextDim = "d8dee9",
        TextMuted = "4c566a"
    },
    ["Monokai"] = {
        Background = "1e1f1c",
        Sidebar = "1a1b18",
        Content = "272822",
        Element = "49483e",
        Border = "49483e",
        Accent = "f92672",
        Text = "f8f8f2",
        TextDim = "c0c0c0",
        TextMuted = "75715e"
    },
    ["Gruvbox"] = {
        Background = "282828",
        Sidebar = "1d2021",
        Content = "3c3836",
        Element = "504945",
        Border = "504945",
        Accent = "fb4934",
        Text = "ebdbb2",
        TextDim = "bdae93",
        TextMuted = "665c54"
    },
    ["Catppuccin"] = {
        Background = "1e1e2e",
        Sidebar = "181825",
        Content = "302d41",
        Element = "575268",
        Border = "575268",
        Accent = "f5c2e7",
        Text = "d9e0ee",
        TextDim = "bac2de",
        TextMuted = "6c7086"
    },
    ["Tokyo Night"] = {
        Background = "16161f",
        Sidebar = "13131a",
        Content = "191925",
        Element = "323232",
        Border = "323232",
        Accent = "6759b3",
        Text = "ffffff",
        TextDim = "a9b1d6",
        TextMuted = "565f89"
    },
    ["One Dark"] = {
        Background = "21252b",
        Sidebar = "1e2227",
        Content = "282c34",
        Element = "5c6370",
        Border = "5c6370",
        Accent = "c678dd",
        Text = "abb2bf",
        TextDim = "8b929e",
        TextMuted = "5c6370"
    },
    ["Cyberpunk"] = {
        Background = "1a1a2e",
        Sidebar = "151528",
        Content = "262335",
        Element = "413c5e",
        Border = "413c5e",
        Accent = "00ff9f",
        Text = "f9f9f9",
        TextDim = "c0c0c0",
        TextMuted = "666699"
    },
    ["Ocean"] = {
        Background = "16232a",
        Sidebar = "121e24",
        Content = "1b2b34",
        Element = "343d46",
        Border = "343d46",
        Accent = "6699cc",
        Text = "d8dee9",
        TextDim = "a7adba",
        TextMuted = "65737e"
    },
    ["Material"] = {
        Background = "151515",
        Sidebar = "121212",
        Content = "212121",
        Element = "424242",
        Border = "424242",
        Accent = "82aaff",
        Text = "eeffff",
        TextDim = "b2ccd6",
        TextMuted = "546e7a"
    },
    ["Solarized"] = {
        Background = "002b36",
        Sidebar = "00252f",
        Content = "073642",
        Element = "586e75",
        Border = "586e75",
        Accent = "cb4b16",
        Text = "839496",
        TextDim = "657b83",
        TextMuted = "586e75"
    },
    ["Ubuntu"] = {
        Background = "323232",
        Sidebar = "2b2b2b",
        Content = "3e3e3e",
        Element = "191919",
        Border = "191919",
        Accent = "e2581e",
        Text = "ffffff",
        TextDim = "c0c0c0",
        TextMuted = "808080"
    },
    ["Quartz"] = {
        Background = "1d1b26",
        Sidebar = "18161f",
        Content = "232330",
        Element = "27232f",
        Border = "27232f",
        Accent = "426e87",
        Text = "ffffff",
        TextDim = "c0c0c0",
        TextMuted = "666680"
    },
    ["BBot"] = {
        Background = "232323",
        Sidebar = "1e1e1e",
        Content = "1e1e1e",
        Element = "141414",
        Border = "141414",
        Accent = "7e48a3",
        Text = "ffffff",
        TextDim = "c0c0c0",
        TextMuted = "808080"
    },
    ["Fatality"] = {
        Background = "191335",
        Sidebar = "14102c",
        Content = "1e1842",
        Element = "3c355d",
        Border = "3c355d",
        Accent = "c50754",
        Text = "ffffff",
        TextDim = "c0c0c0",
        TextMuted = "666680"
    }
}

function ThemeManager:SetLibrary(library)
    self.Library = library
    library.ThemeManager = self
end

function ThemeManager:SetFolder(folder)
    self.Folder = folder
    self:BuildFolderTree()
end

function ThemeManager:BuildFolderTree()
    if not isfolder or not makefolder then return end
    
    local paths = {self.Folder, self.Folder .. "/themes"}
    for _, path in ipairs(paths) do
        if not isfolder(path) then makefolder(path) end
    end
end

function ThemeManager:GetThemeNames()
    local names = {}
    for name in pairs(self.BuiltInThemes) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

function ThemeManager:ApplyTheme(themeName)
    local themeData = self.BuiltInThemes[themeName]
    if not themeData or not self.Library then return false end
    
    -- Update Library.Theme with new colors
    self.Library.Theme.Background = Color3.fromHex(themeData.Background)
    self.Library.Theme.Sidebar = Color3.fromHex(themeData.Sidebar)
    self.Library.Theme.Content = Color3.fromHex(themeData.Content)
    self.Library.Theme.Element = Color3.fromHex(themeData.Element)
    self.Library.Theme.ElementHover = Color3.fromHex(themeData.Element):Lerp(Color3.new(1,1,1), 0.1)
    self.Library.Theme.Border = Color3.fromHex(themeData.Border)
    self.Library.Theme.Accent = Color3.fromHex(themeData.Accent)
    self.Library.Theme.AccentHover = Color3.fromHex(themeData.Accent):Lerp(Color3.new(1,1,1), 0.15)
    self.Library.Theme.Text = Color3.fromHex(themeData.Text)
    self.Library.Theme.TextDim = Color3.fromHex(themeData.TextDim)
    self.Library.Theme.TextMuted = Color3.fromHex(themeData.TextMuted)
    self.Library.Theme.Toggle = Color3.fromHex(themeData.Accent)
    self.Library.Theme.ToggleOff = Color3.fromHex(themeData.Element)
    self.Library.Theme.SidebarActive = Color3.fromHex(themeData.Content)
    
    -- Update all registered UI elements
    self.Library:UpdateColorsUsingRegistry()
    
    print("[ThemeManager] Applied theme:", themeName)
    return true
end

-- Save/Load default theme
function ThemeManager:SaveDefault(themeName)
    self:BuildFolderTree()
    if writefile then
        writefile(self.Folder .. "/themes/default.txt", themeName)
    end
end

function ThemeManager:LoadDefault()
    local path = self.Folder .. "/themes/default.txt"
    if isfile and isfile(path) then
        local themeName = readfile(path)
        if self.BuiltInThemes[themeName] then
            return themeName
        end
    end
    return "Default"
end

-- Custom themes
function ThemeManager:SaveCustomTheme(name)
    if not name or name == "" then return false end
    
    local theme = {}
    for key, color in pairs(self.Library.Theme) do
        if typeof(color) == "Color3" then
            theme[key] = color:ToHex()
        end
    end
    
    self:BuildFolderTree()
    writefile(self.Folder .. "/themes/" .. name .. ".json", HttpService:JSONEncode(theme))
    return true
end

function ThemeManager:GetCustomThemes()
    local themes = {}
    local path = self.Folder .. "/themes"
    
    if listfiles and isfolder and isfolder(path) then
        for _, file in ipairs(listfiles(path)) do
            if file:sub(-5) == ".json" then
                local name = file:match("([^/\\]+)%.json$")
                if name then table.insert(themes, name) end
            end
        end
    end
    
    return themes
end

function ThemeManager:Delete(name)
    if not name then return false, "No name" end
    local path = self.Folder .. "/themes/" .. name .. ".json"
    if isfile and isfile(path) then
        delfile(path)
        return true
    end
    return false, "File not found"
end

-- Build UI
function ThemeManager:BuildThemeSection(tab)
    if not tab then return end
    
    local section = tab:CreateSection({
        Name = "Themes",
        Side = "Left"
    })
    
    local themeNames = self:GetThemeNames()
    local defaultTheme = self:LoadDefault()
    
    section:AddDropdown({
        Name = "Theme",
        Options = themeNames,
        Default = defaultTheme,
        Flag = "ThemeManager_ThemeList",
        Callback = function(val)
            self:ApplyTheme(val)
        end
    })
    
    section:AddButton({
        Name = "Set as Default",
        Callback = function()
            local current = self.Library.Options.ThemeManager_ThemeList
            if current then
                self:SaveDefault(current.Value)
                print("[ThemeManager] Set default:", current.Value)
            end
        end
    })
    
    -- Apply default theme on load
    self:ApplyTheme(defaultTheme)
end

return ThemeManager
