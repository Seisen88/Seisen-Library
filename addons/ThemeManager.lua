--[[
    ThemeManager - Adapted from Obsidian
    https://github.com/deividcomsono/Obsidian/blob/main/addons/ThemeManager.lua
]]

local cloneref = (cloneref or clonereference or function(instance) return instance end)
local HttpService = cloneref(game:GetService("HttpService"))
local isfolder, isfile, listfiles = isfolder, isfile, listfiles

local ThemeManager = {} do
    ThemeManager.Folder = "SeisenSettings"
    ThemeManager.Library = nil
    ThemeManager.BuiltInThemes = {
        ["Default"] = {
            1,
            { FontColor = "ffffff", MainColor = "191919", AccentColor = "5a5aa0", BackgroundColor = "0f0f0f", OutlineColor = "282828" },
        },
        ["BBot"] = {
            2,
            { FontColor = "ffffff", MainColor = "1e1e1e", AccentColor = "7e48a3", BackgroundColor = "232323", OutlineColor = "141414" },
        },
        ["Fatality"] = {
            3,
            { FontColor = "ffffff", MainColor = "1e1842", AccentColor = "c50754", BackgroundColor = "191335", OutlineColor = "3c355d" },
        },
        ["Jester"] = {
            4,
            { FontColor = "ffffff", MainColor = "242424", AccentColor = "db4467", BackgroundColor = "1c1c1c", OutlineColor = "373737" },
        },
        ["Mint"] = {
            5,
            { FontColor = "ffffff", MainColor = "242424", AccentColor = "3db488", BackgroundColor = "1c1c1c", OutlineColor = "373737" },
        },
        ["Tokyo Night"] = {
            6,
            { FontColor = "ffffff", MainColor = "191925", AccentColor = "6759b3", BackgroundColor = "16161f", OutlineColor = "323232" },
        },
        ["Ubuntu"] = {
            7,
            { FontColor = "ffffff", MainColor = "3e3e3e", AccentColor = "e2581e", BackgroundColor = "323232", OutlineColor = "191919" },
        },
        ["Quartz"] = {
            8,
            { FontColor = "ffffff", MainColor = "232330", AccentColor = "426e87", BackgroundColor = "1d1b26", OutlineColor = "27232f" },
        },
        ["Nord"] = {
            9,
            { FontColor = "eceff4", MainColor = "3b4252", AccentColor = "88c0d0", BackgroundColor = "2e3440", OutlineColor = "4c566a" },
        },
        ["Dracula"] = {
            10,
            { FontColor = "f8f8f2", MainColor = "44475a", AccentColor = "ff79c6", BackgroundColor = "282a36", OutlineColor = "6272a4" },
        },
        ["Monokai"] = {
            11,
            { FontColor = "f8f8f2", MainColor = "272822", AccentColor = "f92672", BackgroundColor = "1e1f1c", OutlineColor = "49483e" },
        },
        ["Gruvbox"] = {
            12,
            { FontColor = "ebdbb2", MainColor = "3c3836", AccentColor = "fb4934", BackgroundColor = "282828", OutlineColor = "504945" },
        },
        ["Solarized"] = {
            13,
            { FontColor = "839496", MainColor = "073642", AccentColor = "cb4b16", BackgroundColor = "002b36", OutlineColor = "586e75" },
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
        ["Oceanic Next"] = {
            17,
            { FontColor = "d8dee9", MainColor = "1b2b34", AccentColor = "6699cc", BackgroundColor = "16232a", OutlineColor = "343d46" },
        },
        ["Material"] = {
            18,
            { FontColor = "eeffff", MainColor = "212121", AccentColor = "82aaff", BackgroundColor = "151515", OutlineColor = "424242" },
        }
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
        if isfile(path) then
            local success, content = pcall(readfile, path)
            if success and self.BuiltInThemes[content] then
                return content
            end
        end
        return "Default"
    end

    function ThemeManager:GetCustomTheme(name)
        local path = self.Folder .. "/themes/" .. name .. ".json"
        if not isfile(path) then return nil end
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)
        return success and decoded or nil
    end

    function ThemeManager:SaveCustomTheme(name)
        if not name or name:gsub(" ", "") == "" then return end
        local theme = {}
        theme.FontColor = self.Library.Theme.Text:ToHex()
        theme.MainColor = self.Library.Theme.Content:ToHex()
        theme.AccentColor = self.Library.Theme.Accent:ToHex()
        theme.BackgroundColor = self.Library.Theme.Background:ToHex()
        theme.OutlineColor = self.Library.Theme.Border:ToHex()
        self:BuildFolderTree()
        writefile(self.Folder .. "/themes/" .. name .. ".json", HttpService:JSONEncode(theme))
    end

    function ThemeManager:ReloadCustomThemes()
        local list = {}
        local success, files = pcall(listfiles, self.Folder .. "/themes")
        if not success then return {} end
        for _, file in ipairs(files) do
            if file:sub(-5) == ".json" then
                local name = file:match("([^/\\]+)%.json$")
                if name then table.insert(list, name) end
            end
        end
        return list
    end

    function ThemeManager:Delete(name)
        if not name then return false, "no file" end
        local path = self.Folder .. "/themes/" .. name .. ".json"
        if not isfile(path) then return false, "invalid file" end
        pcall(delfile, path)
        return true
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

        section:AddDivider()

        section:AddTextbox({
            Name = "Custom Theme Name",
            Flag = "ThemeManager_CustomThemeName",
            Placeholder = "Enter theme name...",
            Callback = function() end
        })

        section:AddButton({
            Name = "Save Custom Theme",
            Callback = function()
                local name = self.Library.Options.ThemeManager_CustomThemeName
                if name and name.Value ~= "" then
                    self:SaveCustomTheme(name.Value)
                    print("[ThemeManager] Saved custom theme:", name.Value)
                end
            end
        })

        section:AddDivider()

        section:AddDropdown({
            Name = "Custom Themes",
            Options = self:ReloadCustomThemes(),
            Flag = "ThemeManager_CustomThemeList",
            Callback = function() end
        })

        section:AddButton({
            Name = "Load Custom Theme",
            Callback = function()
                local name = self.Library.Options.ThemeManager_CustomThemeList
                if name and name.Value then
                    local theme = self:GetCustomTheme(name.Value)
                    if theme then
                        self.Library.Theme.Background = Color3.fromHex(theme.BackgroundColor)
                        self.Library.Theme.Content = Color3.fromHex(theme.MainColor)
                        self.Library.Theme.Accent = Color3.fromHex(theme.AccentColor)
                        self.Library.Theme.Border = Color3.fromHex(theme.OutlineColor)
                        self.Library.Theme.Text = Color3.fromHex(theme.FontColor)
                        if self.Library.UpdateColorsUsingRegistry then
                            self.Library:UpdateColorsUsingRegistry()
                        end
                        print("[ThemeManager] Loaded custom theme:", name.Value)
                    end
                end
            end
        })

        section:AddButton({
            Name = "Delete Custom Theme",
            Callback = function()
                local name = self.Library.Options.ThemeManager_CustomThemeList
                if name and name.Value then
                    self:Delete(name.Value)
                    print("[ThemeManager] Deleted theme:", name.Value)
                end
            end
        })

        -- Apply default theme on load
        self:ApplyTheme(defaultTheme)
    end

    ThemeManager:BuildFolderTree()
end

return ThemeManager
