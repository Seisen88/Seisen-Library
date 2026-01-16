--[[
    SaveManager - Adapted from Obsidian
    https://github.com/deividcomsono/Obsidian/blob/main/addons/SaveManager.lua
]]

local cloneref = (cloneref or clonereference or function(instance) return instance end)
local HttpService = cloneref(game:GetService("HttpService"))
local isfolder, isfile, listfiles = isfolder, isfile, listfiles

local SaveManager = {} do
    SaveManager.Folder = "SeisenSettings"
    SaveManager.SubFolder = ""
    SaveManager.Ignore = {}
    SaveManager.Library = nil
    SaveManager.Parser = {
        Toggle = {
            Save = function(idx, object)
                return { type = "Toggle", idx = idx, value = object.Value }
            end,
            Load = function(idx, data)
                local object = SaveManager.Library.Toggles[idx]
                if object and object.Value ~= data.value then
                    object:SetValue(data.value)
                end
            end,
        },
        Slider = {
            Save = function(idx, object)
                return { type = "Slider", idx = idx, value = tostring(object.Value) }
            end,
            Load = function(idx, data)
                local object = SaveManager.Library.Options[idx]
                if object and object.Value ~= data.value then
                    object:SetValue(data.value)
                end
            end,
        },
        Dropdown = {
            Save = function(idx, object)
                return { type = "Dropdown", idx = idx, value = object.Value }
            end,
            Load = function(idx, data)
                local object = SaveManager.Library.Options[idx]
                if object and object.Value ~= data.value then
                    object:SetValue(data.value)
                end
            end,
        },
        ColorPicker = {
            Save = function(idx, object)
                return { type = "ColorPicker", idx = idx, value = object.Value:ToHex() }
            end,
            Load = function(idx, data)
                if SaveManager.Library.Options[idx] then
                    SaveManager.Library.Options[idx]:SetValue(Color3.fromHex(data.value))
                end
            end,
        },
        Input = {
            Save = function(idx, object)
                return { type = "Input", idx = idx, text = object.Value }
            end,
            Load = function(idx, data)
                local object = SaveManager.Library.Options[idx]
                if object and object.Value ~= data.text and type(data.text) == "string" then
                    SaveManager.Library.Options[idx]:SetValue(data.text)
                end
            end,
        },
    }

    function SaveManager:SetLibrary(library)
        self.Library = library
    end

    function SaveManager:IgnoreThemeSettings()
        self:SetIgnoreIndexes({
            "BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor", "FontFace",
            "ThemeManager_ThemeList", "ThemeManager_CustomThemeList", "ThemeManager_CustomThemeName",
        })
    end

    function SaveManager:SetIgnoreIndexes(list)
        for _, key in pairs(list) do
            self.Ignore[key] = true
        end
    end

    function SaveManager:SetFolder(folder)
        self.Folder = folder
        self:BuildFolderTree()
    end

    function SaveManager:SetSubFolder(folder)
        self.SubFolder = folder
        self:BuildFolderTree()
    end

    function SaveManager:CheckSubFolder(createFolder)
        if typeof(self.SubFolder) ~= "string" or self.SubFolder == "" then return false end
        if createFolder == true then
            if not isfolder(self.Folder .. "/settings/" .. self.SubFolder) then
                makefolder(self.Folder .. "/settings/" .. self.SubFolder)
            end
        end
        return true
    end

    function SaveManager:BuildFolderTree()
        local paths = {self.Folder, self.Folder .. "/themes", self.Folder .. "/settings"}
        if self:CheckSubFolder(false) then
            table.insert(paths, self.Folder .. "/settings/" .. self.SubFolder)
        end
        for _, path in ipairs(paths) do
            if not isfolder(path) then
                pcall(makefolder, path)
            end
        end
    end

    function SaveManager:Save(name)
        if not name then return false, "no config file is selected" end
        self:BuildFolderTree()

        local fullPath = self.Folder .. "/settings/" .. name .. ".json"
        if self:CheckSubFolder(true) then
            fullPath = self.Folder .. "/settings/" .. self.SubFolder .. "/" .. name .. ".json"
        end

        local data = { objects = {} }

        for idx, toggle in pairs(self.Library.Toggles) do
            if self.Ignore[idx] then continue end
            table.insert(data.objects, self.Parser.Toggle.Save(idx, toggle))
        end

        for idx, option in pairs(self.Library.Options) do
            if not option.Type then continue end
            if not self.Parser[option.Type] then continue end
            if self.Ignore[idx] then continue end
            table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
        end

        local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
        if not success then return false, "failed to encode data" end

        writefile(fullPath, encoded)
        return true
    end

    function SaveManager:Load(name)
        if not name then return false, "no config file is selected" end
        self:BuildFolderTree()

        local file = self.Folder .. "/settings/" .. name .. ".json"
        if self:CheckSubFolder(true) then
            file = self.Folder .. "/settings/" .. self.SubFolder .. "/" .. name .. ".json"
        end

        if not isfile(file) then return false, "invalid file" end

        local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(file))
        if not success then return false, "decode error" end

        for _, option in pairs(decoded.objects) do
            if not option.type then continue end
            if not self.Parser[option.type] then continue end
            if self.Ignore[option.idx] then continue end
            task.spawn(self.Parser[option.type].Load, option.idx, option)
        end

        return true
    end

    function SaveManager:Delete(name)
        if not name then return false, "no config file is selected" end
        local file = self.Folder .. "/settings/" .. name .. ".json"
        if self:CheckSubFolder(true) then
            file = self.Folder .. "/settings/" .. self.SubFolder .. "/" .. name .. ".json"
        end
        if not isfile(file) then return false, "invalid file" end
        local success = pcall(delfile, file)
        if not success then return false, "delete file error" end
        return true
    end

    function SaveManager:RefreshConfigList()
        self:BuildFolderTree()
        local list = {}
        local folder = self.Folder .. "/settings"
        if self:CheckSubFolder(true) then
            folder = self.Folder .. "/settings/" .. self.SubFolder
        end
        
        local success, files = pcall(listfiles, folder)
        if not success then return {} end
        
        for _, file in ipairs(files) do
            if file:sub(-5) == ".json" then
                local name = file:match("([^/\\]+)%.json$")
                if name then table.insert(list, name) end
            end
        end
        return list
    end

    function SaveManager:GetAutoloadConfig()
        self:BuildFolderTree()
        local path = self.Folder .. "/settings/autoload.txt"
        if self:CheckSubFolder(true) then
            path = self.Folder .. "/settings/" .. self.SubFolder .. "/autoload.txt"
        end
        if isfile(path) then
            local success, name = pcall(readfile, path)
            if success and name ~= "" then return name end
        end
        return "none"
    end

    function SaveManager:SaveAutoloadConfig(name)
        self:BuildFolderTree()
        local path = self.Folder .. "/settings/autoload.txt"
        if self:CheckSubFolder(true) then
            path = self.Folder .. "/settings/" .. self.SubFolder .. "/autoload.txt"
        end
        local success = pcall(writefile, path, name)
        if not success then return false, "write file error" end
        return true, ""
    end

    function SaveManager:DeleteAutoLoadConfig()
        self:BuildFolderTree()
        local path = self.Folder .. "/settings/autoload.txt"
        if self:CheckSubFolder(true) then
            path = self.Folder .. "/settings/" .. self.SubFolder .. "/autoload.txt"
        end
        local success = pcall(delfile, path)
        if not success then return false, "delete file error" end
        return true, ""
    end

    function SaveManager:LoadAutoloadConfig()
        local name = self:GetAutoloadConfig()
        if name and name ~= "none" then
            local success, err = self:Load(name)
            if success then
                print("[SaveManager] Auto loaded config:", name)
            end
        end
    end

    function SaveManager:BuildConfigSection(tab)
        assert(self.Library, "Must set SaveManager.Library")

        local section = tab:CreateSection({ Name = "Configuration", Side = "Right" })

        section:AddTextbox({
            Name = "Config Name",
            Flag = "SaveManager_ConfigName",
            Placeholder = "Enter config name...",
            Callback = function() end
        })

        section:AddButton({
            Name = "Create Config",
            Callback = function()
                local name = self.Library.Options.SaveManager_ConfigName and self.Library.Options.SaveManager_ConfigName.Value or ""
                if name:gsub(" ", "") == "" then
                    print("[SaveManager] Invalid config name (empty)")
                    return
                end
                local success, err = self:Save(name)
                if not success then
                    print("[SaveManager] Failed to create config:", err)
                    return
                end
                print("[SaveManager] Created config:", name)
            end
        })

        section:AddDivider()

        section:AddDropdown({
            Name = "Config List",
            Options = self:RefreshConfigList(),
            Flag = "SaveManager_ConfigList",
            Callback = function() end
        })

        section:AddButton({
            Name = "Load Config",
            Callback = function()
                local name = self.Library.Options.SaveManager_ConfigList and self.Library.Options.SaveManager_ConfigList.Value
                local success, err = self:Load(name)
                if not success then
                    print("[SaveManager] Failed to load config:", err)
                    return
                end
                print("[SaveManager] Loaded config:", name)
            end
        })

        section:AddButton({
            Name = "Overwrite Config",
            Callback = function()
                local name = self.Library.Options.SaveManager_ConfigList and self.Library.Options.SaveManager_ConfigList.Value
                local success, err = self:Save(name)
                if not success then
                    print("[SaveManager] Failed to overwrite config:", err)
                    return
                end
                print("[SaveManager] Overwrote config:", name)
            end
        })

        section:AddButton({
            Name = "Delete Config",
            Callback = function()
                local name = self.Library.Options.SaveManager_ConfigList and self.Library.Options.SaveManager_ConfigList.Value
                local success, err = self:Delete(name)
                if not success then
                    print("[SaveManager] Failed to delete config:", err)
                    return
                end
                print("[SaveManager] Deleted config:", name)
            end
        })

        section:AddButton({
            Name = "Refresh List",
            Callback = function()
                print("[SaveManager] Refreshed config list")
            end
        })

        section:AddDivider()

        section:AddButton({
            Name = "Set as Autoload",
            Callback = function()
                local name = self.Library.Options.SaveManager_ConfigList and self.Library.Options.SaveManager_ConfigList.Value
                local success, err = self:SaveAutoloadConfig(name)
                if not success then
                    print("[SaveManager] Failed to set autoload:", err)
                    return
                end
                print("[SaveManager] Set autoload to:", name)
            end
        })

        section:AddButton({
            Name = "Reset Autoload",
            Callback = function()
                local success, err = self:DeleteAutoLoadConfig()
                if not success then
                    print("[SaveManager] Failed to reset autoload:", err)
                    return
                end
                print("[SaveManager] Reset autoload")
            end
        })

        section:AddLabel({ Text = "Current autoload: " .. self:GetAutoloadConfig() })

        self:SetIgnoreIndexes({ "SaveManager_ConfigList", "SaveManager_ConfigName" })
    end

    SaveManager:BuildFolderTree()
end

return SaveManager
