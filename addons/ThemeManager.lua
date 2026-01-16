--[[
    ThemeManager - Seisen UI
    All built-in themes only, no custom themes
]]

local cloneref = (cloneref or clonereference or function(instance) return instance end)
local HttpService = cloneref(game:GetService("HttpService"))
local isfolder, isfile = isfolder, isfile

local ThemeManager = {} do
    ThemeManager.Folder = "SeisenSettings"
    ThemeManager.Library = nil
    ThemeManager.BuiltInThemes = {
        ["Default"] = {
            1,
            { FontColor = "ffffff", MainColor = "232328", AccentColor = "5a5aa0", BackgroundColor = "1e1e23", OutlineColor = "373745" },
        },
        ["Mint"] = {
            2,
            { FontColor = "ffffff", MainColor = "242424", AccentColor = "3db488", BackgroundColor = "1c1c1c", OutlineColor = "373737" },
        },
        ["Rose"] = {
            3,
            { FontColor = "ffffff", MainColor = "242424", AccentColor = "db4467", BackgroundColor = "1c1c1c", OutlineColor = "373737" },
        },
        ["Ocean"] = {
            4,
            { FontColor = "ffffff", MainColor = "1b2b34", AccentColor = "6699cc", BackgroundColor = "16232a", OutlineColor = "343d46" },
        },
        ["Sunset"] = {
            5,
            { FontColor = "ffffff", MainColor = "2d1f3d", AccentColor = "ff6b6b", BackgroundColor = "1a1225", OutlineColor = "4a3560" },
        },
        ["Forest"] = {
            6,
            { FontColor = "e0e0e0", MainColor = "1e2a1e", AccentColor = "4caf50", BackgroundColor = "141a14", OutlineColor = "2d3e2d" },
        },
        ["BBot"] = {
            7,
            { FontColor = "ffffff", MainColor = "1e1e1e", AccentColor = "7e48a3", BackgroundColor = "232323", OutlineColor = "141414" },
        },
        ["Fatality"] = {
            8,
            { FontColor = "ffffff", MainColor = "1e1842", AccentColor = "c50754", BackgroundColor = "191335", OutlineColor = "3c355d" },
        },
        ["Tokyo Night"] = {
            9,
            { FontColor = "ffffff", MainColor = "191925", AccentColor = "6759b3", BackgroundColor = "16161f", OutlineColor = "323232" },
        },
        ["Nord"] = {
            10,
            { FontColor = "eceff4", MainColor = "3b4252", AccentColor = "88c0d0", BackgroundColor = "2e3440", OutlineColor = "4c566a" },
        },
        ["Dracula"] = {
            11,
            { FontColor = "f8f8f2", MainColor = "44475a", AccentColor = "ff79c6", BackgroundColor = "282a36", OutlineColor = "6272a4" },
        },
        ["Monokai"] = {
            12,
            { FontColor = "f8f8f2", MainColor = "272822", AccentColor = "f92672", BackgroundColor = "1e1f1c", OutlineColor = "49483e" },
        },
        ["Gruvbox"] = {
            13,
            { FontColor = "ebdbb2", MainColor = "3c3836", AccentColor = "fb4934", BackgroundColor = "282828", OutlineColor = "504945" },
        },
        ["Catppuccin"] = {
            14,
            { FontColor = "d9e0ee", MainColor = "302d41", AccentColor = "f5c2e7", BackgroundColor = "1e1e2e", OutlineColor = "575268" },
        },
        ["One Dark"] = {
            15,
            { FontColor = "abb2bf", MainColor = "282c34", AccentColor = "c678dd", BackgroundColor = "21252b", OutlineColor = "5c6370" },
        },
        ["Cyberpunk"] = {
            16,
            { FontColor = "f9f9f9", MainColor = "262335", AccentColor = "00ff9f", BackgroundColor = "1a1a2e", OutlineColor = "413c5e" },
        },
        ["Material"] = {
            17,
            { FontColor = "eeffff", MainColor = "212121", AccentColor = "82aaff", BackgroundColor = "151515", OutlineColor = "424242" },
        },
        ["Solarized"] = {
            18,
            { FontColor = "839496", MainColor = "073642", AccentColor = "cb4b16", BackgroundColor = "002b36", OutlineColor = "586e75" },
        },
        ["Ubuntu"] = {
            19,
            { FontColor = "ffffff", MainColor = "3e3e3e", AccentColor = "e2581e", BackgroundColor = "323232", OutlineColor = "191919" },
        },
        ["Midnight"] = {
            20,
            { FontColor = "ffffff", MainColor = "0d1117", AccentColor = "58a6ff", BackgroundColor = "010409", OutlineColor = "21262d" },
        },
        ["Blood"] = {
            21,
            { FontColor = "ffffff", MainColor = "1a0a0a", AccentColor = "8b0000", BackgroundColor = "0d0505", OutlineColor = "2d1515" },
        },
        ["Lavender"] = {
            22,
            { FontColor = "ffffff", MainColor = "2a2640", AccentColor = "b19cd9", BackgroundColor = "1e1a30", OutlineColor = "3d3660" },
        },
        ["Aqua"] = {
            23,
            { FontColor = "ffffff", MainColor = "1a2d3d", AccentColor = "00bcd4", BackgroundColor = "0f1a24", OutlineColor = "264050" },
        },
        ["Golden"] = {
            24,
            { FontColor = "ffffff", MainColor = "1f1a0f", AccentColor = "ffc107", BackgroundColor = "141008", OutlineColor = "3d3520" },
        },
    }

    function ThemeManager:SetLibrary(library)
        self.Library = library
    end

    function ThemeManager:SetFolder(folder)
        self.Folder = folder
        self:BuildFolderTree()
    end

    function ThemeManager:BuildFolderTree()
        local paths = {self.Folder, self.Folder .. "/themes"}
        for _, path in ipairs(paths) do
            if not isfolder(path) then
                pcall(makefolder, path)
            end
        end
    end

    function ThemeManager:ApplyTheme(themeName)
        local data = self.BuiltInThemes[themeName]
        if not data or not self.Library then return end

        local scheme = data[2]
        
        -- Update Library.Theme
        self.Library.Theme.Background = Color3.fromHex(scheme.BackgroundColor)
        self.Library.Theme.Sidebar = Color3.fromHex(scheme.BackgroundColor)
        self.Library.Theme.Content = Color3.fromHex(scheme.MainColor)
        self.Library.Theme.Element = Color3.fromHex(scheme.OutlineColor)
        self.Library.Theme.ElementHover = Color3.fromHex(scheme.OutlineColor):Lerp(Color3.new(1,1,1), 0.1)
        self.Library.Theme.Border = Color3.fromHex(scheme.OutlineColor)
        self.Library.Theme.Accent = Color3.fromHex(scheme.AccentColor)
        self.Library.Theme.AccentHover = Color3.fromHex(scheme.AccentColor):Lerp(Color3.new(1,1,1), 0.15)
        self.Library.Theme.Text = Color3.fromHex(scheme.FontColor)
        self.Library.Theme.TextDim = Color3.fromHex(scheme.FontColor):Lerp(Color3.new(0,0,0), 0.3)
        self.Library.Theme.TextMuted = Color3.fromHex(scheme.FontColor):Lerp(Color3.new(0,0,0), 0.5)
        self.Library.Theme.Toggle = Color3.fromHex(scheme.AccentColor)
        self.Library.Theme.ToggleOff = Color3.fromHex(scheme.OutlineColor)
        self.Library.Theme.SidebarActive = Color3.fromHex(scheme.MainColor)

        -- Update UI using registry
        if self.Library.UpdateColorsUsingRegistry then
            self.Library:UpdateColorsUsingRegistry()
        end

        print("[ThemeManager] Applied theme:", themeName)
    end

    function ThemeManager:SaveDefault(theme)
        self:BuildFolderTree()
        pcall(writefile, self.Folder .. "/themes/default.txt", theme)
    end

    function ThemeManager:LoadDefault()
        local path = self.Folder .. "/themes/default.txt"
        if isfile and isfile(path) then
            local success, content = pcall(readfile, path)
            if success and self.BuiltInThemes[content] then
                return content
            end
        end
        return "Default"
    end

    function ThemeManager:BuildThemeSection(tab)
        assert(self.Library, "Must set ThemeManager.Library")

        local section = tab:CreateSection({ Name = "Themes", Side = "Left" })

        -- Get sorted theme names
        local themeNames = {}
        for name, data in pairs(self.BuiltInThemes) do
            table.insert(themeNames, {name = name, order = data[1]})
        end
        table.sort(themeNames, function(a, b) return a.order < b.order end)
        
        local sortedNames = {}
        for _, t in ipairs(themeNames) do
            table.insert(sortedNames, t.name)
        end

        local defaultTheme = self:LoadDefault()

        section:AddDropdown({
            Name = "Theme",
            Options = sortedNames,
            Default = defaultTheme,
            Flag = "ThemeManager_ThemeList",
            Callback = function(value)
                self:ApplyTheme(value)
            end
        })

        section:AddButton({
            Name = "Set as Default",
            Callback = function()
                local current = self.Library.Options.ThemeManager_ThemeList
                if current then
                    self:SaveDefault(current.Value)
                    print("[ThemeManager] Set default theme:", current.Value)
                end
            end
        })

        -- Apply default theme on load
        self:ApplyTheme(defaultTheme)
    end

    ThemeManager:BuildFolderTree()
end

return ThemeManager
