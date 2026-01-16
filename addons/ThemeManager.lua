--[[
    Seisen UI - ThemeManager (Obsidian-style)
    Multiple themes with real-time color updates
]]

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local ThemeManager = {}
ThemeManager.Folder = "SeisenConfigs"
ThemeManager.Library = nil
ThemeManager.DefaultTheme = "Default"

-- 18 Built-in themes matching Obsidian
ThemeManager.BuiltInThemes = {
    ["Default"] = {
        FontColor = "ffffff",
        MainColor = "191919",
        AccentColor = "5a5aa0",
        BackgroundColor = "0f0f0f",
        OutlineColor = "282828"
    },
    ["Mint"] = {
        FontColor = "ffffff",
        MainColor = "242424",
        AccentColor = "3db488",
        BackgroundColor = "1c1c1c",
        OutlineColor = "373737"
    },
    ["Rose"] = {
        FontColor = "ffffff",
        MainColor = "242424",
        AccentColor = "db4467",
        BackgroundColor = "1c1c1c",
        OutlineColor = "373737"
    },
    ["Dracula"] = {
        FontColor = "f8f8f2",
        MainColor = "44475a",
        AccentColor = "ff79c6",
        BackgroundColor = "282a36",
        OutlineColor = "6272a4"
    },
    ["Nord"] = {
        FontColor = "eceff4",
        MainColor = "3b4252",
        AccentColor = "88c0d0",
        BackgroundColor = "2e3440",
        OutlineColor = "4c566a"
    },
    ["Monokai"] = {
        FontColor = "f8f8f2",
        MainColor = "272822",
        AccentColor = "f92672",
        BackgroundColor = "1e1f1c",
        OutlineColor = "49483e"
    },
    ["Gruvbox"] = {
        FontColor = "ebdbb2",
        MainColor = "3c3836",
        AccentColor = "fb4934",
        BackgroundColor = "282828",
        OutlineColor = "504945"
    },
    ["Catppuccin"] = {
        FontColor = "d9e0ee",
        MainColor = "302d41",
        AccentColor = "f5c2e7",
        BackgroundColor = "1e1e2e",
        OutlineColor = "575268"
    },
    ["Tokyo Night"] = {
        FontColor = "ffffff",
        MainColor = "191925",
        AccentColor = "6759b3",
        BackgroundColor = "16161f",
        OutlineColor = "323232"
    },
    ["One Dark"] = {
        FontColor = "abb2bf",
        MainColor = "282c34",
        AccentColor = "c678dd",
        BackgroundColor = "21252b",
        OutlineColor = "5c6370"
    },
    ["Cyberpunk"] = {
        FontColor = "f9f9f9",
        MainColor = "262335",
        AccentColor = "00ff9f",
        BackgroundColor = "1a1a2e",
        OutlineColor = "413c5e"
    },
    ["Ocean"] = {
        FontColor = "d8dee9",
        MainColor = "1b2b34",
        AccentColor = "6699cc",
        BackgroundColor = "16232a",
        OutlineColor = "343d46"
    },
    ["Material"] = {
        FontColor = "eeffff",
        MainColor = "212121",
        AccentColor = "82aaff",
        BackgroundColor = "151515",
        OutlineColor = "424242"
    },
    ["Solarized"] = {
        FontColor = "839496",
        MainColor = "073642",
        AccentColor = "cb4b16",
        BackgroundColor = "002b36",
        OutlineColor = "586e75"
    },
    ["Ubuntu"] = {
        FontColor = "ffffff",
        MainColor = "3e3e3e",
        AccentColor = "e2581e",
        BackgroundColor = "323232",
        OutlineColor = "191919"
    },
    ["Quartz"] = {
        FontColor = "ffffff",
        MainColor = "232330",
        AccentColor = "426e87",
        BackgroundColor = "1d1b26",
        OutlineColor = "27232f"
    },
    ["BBot"] = {
        FontColor = "ffffff",
        MainColor = "1e1e1e",
        AccentColor = "7e48a3",
        BackgroundColor = "232323",
        OutlineColor = "141414"
    },
    ["Fatality"] = {
        FontColor = "ffffff",
        MainColor = "1e1842",
        AccentColor = "c50754",
        BackgroundColor = "191335",
        OutlineColor = "3c355d"
    }
}

-- Registry for live updates
ThemeManager.Registry = {}

function ThemeManager:SetLibrary(library)
    self.Library = library
    library.ThemeManager = self
    
    -- Store original theme for reference
    self.OriginalTheme = {}
    for k, v in pairs(library.Theme) do
        self.OriginalTheme[k] = v
    end
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
    
    -- Convert hex to Color3 and update library theme
    local newTheme = {
        Background = Color3.fromHex(themeData.BackgroundColor),
        Sidebar = Color3.fromHex(themeData.BackgroundColor),
        SidebarActive = Color3.fromHex(themeData.MainColor),
        Content = Color3.fromHex(themeData.MainColor),
        Element = Color3.fromHex(themeData.OutlineColor),
        ElementHover = Color3.fromHex(themeData.OutlineColor):Lerp(Color3.new(1,1,1), 0.1),
        Border = Color3.fromHex(themeData.OutlineColor),
        Accent = Color3.fromHex(themeData.AccentColor),
        AccentHover = Color3.fromHex(themeData.AccentColor):Lerp(Color3.new(1,1,1), 0.15),
        Text = Color3.fromHex(themeData.FontColor),
        TextDim = Color3.fromHex(themeData.FontColor):Lerp(Color3.new(0,0,0), 0.3),
        TextMuted = Color3.fromHex(themeData.FontColor):Lerp(Color3.new(0,0,0), 0.5),
        Toggle = Color3.fromHex(themeData.AccentColor),
        ToggleOff = Color3.fromHex(themeData.OutlineColor)
    }
    
    -- Update library theme
    for k, v in pairs(newTheme) do
        self.Library.Theme[k] = v
    end
    
    -- Live update registered elements
    self:UpdateRegisteredElements(newTheme)
    
    print("[ThemeManager] Applied theme:", themeName)
    return true
end

function ThemeManager:RegisterElement(element, themeKey)
    table.insert(self.Registry, {element = element, key = themeKey})
end

function ThemeManager:UpdateRegisteredElements(theme)
    for _, reg in ipairs(self.Registry) do
        if reg.element and reg.element.Parent then
            local color = theme[reg.key]
            if color then
                pcall(function()
                    TweenService:Create(reg.element, TweenInfo.new(0.2), {
                        BackgroundColor3 = color
                    }):Play()
                end)
            end
        end
    end
end

-- Save/Load default theme
function ThemeManager:SaveDefaultTheme(themeName)
    self:BuildFolderTree()
    if writefile then
        writefile(self.Folder .. "/themes/default.txt", themeName)
    end
end

function ThemeManager:LoadDefaultTheme()
    local path = self.Folder .. "/themes/default.txt"
    if isfile and isfile(path) then
        local themeName = readfile(path)
        if self.BuiltInThemes[themeName] then
            self:ApplyTheme(themeName)
            return themeName
        end
    end
    return nil
end

-- Custom themes
function ThemeManager:SaveCustomTheme(name)
    if not name or name == "" then return false end
    
    local theme = {}
    theme.FontColor = self.Library.Theme.Text:ToHex()
    theme.MainColor = self.Library.Theme.Content:ToHex()
    theme.AccentColor = self.Library.Theme.Accent:ToHex()
    theme.BackgroundColor = self.Library.Theme.Background:ToHex()
    theme.OutlineColor = self.Library.Theme.Border:ToHex()
    
    self:BuildFolderTree()
    writefile(self.Folder .. "/themes/" .. name .. ".json", HttpService:JSONEncode(theme))
    return true
end

function ThemeManager:GetCustomThemes()
    local themes = {}
    local path = self.Folder .. "/themes"
    
    if listfiles and isfolder(path) then
        for _, file in ipairs(listfiles(path)) do
            if file:sub(-5) == ".json" then
                local name = file:match("([^/\\]+)%.json$")
                if name then table.insert(themes, name) end
            end
        end
    end
    
    return themes
end

-- Build UI
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
        Flag = "ThemeManager_ThemeList",
        Callback = function(val)
            selectedTheme = val
            self:ApplyTheme(val)
        end
    })
    
    section:AddButton({
        Name = "Set as Default",
        Callback = function()
            self:SaveDefaultTheme(selectedTheme)
            print("[ThemeManager] Set default theme:", selectedTheme)
        end
    })
    
    section:AddDivider("Custom Themes")
    
    local customThemeName = ""
    
    section:AddTextbox({
        Name = "Theme Name",
        Default = "",
        Placeholder = "Enter theme name...",
        Callback = function(val)
            customThemeName = val
        end
    })
    
    section:AddButton({
        Name = "Save Custom Theme",
        Callback = function()
            if customThemeName ~= "" then
                self:SaveCustomTheme(customThemeName)
                print("[ThemeManager] Saved custom theme:", customThemeName)
            end
        end
    })
end

return ThemeManager
