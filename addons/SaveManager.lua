--[[
    Seisen UI - SaveManager (Obsidian-style)
    Full config save/load with autoload support
]]

local HttpService = game:GetService("HttpService")

local SaveManager = {}
SaveManager.Folder = "SeisenConfigs"
SaveManager.SubFolder = nil
SaveManager.Library = nil
SaveManager.Ignore = {}

SaveManager.Parser = {
    Toggle = {
        Save = function(idx, object)
            return { type = "Toggle", idx = idx, value = object.Value }
        end,
        Load = function(idx, data)
            if SaveManager.Library.Toggles[idx] then
                SaveManager.Library.Toggles[idx]:SetValue(data.value)
            end
        end
    },
    Slider = {
        Save = function(idx, object)
            return { type = "Slider", idx = idx, value = object.Value }
        end,
        Load = function(idx, data)
            if SaveManager.Library.Options[idx] then
                SaveManager.Library.Options[idx]:SetValue(data.value)
            end
        end
    },
    Dropdown = {
        Save = function(idx, object)
            return { type = "Dropdown", idx = idx, value = object.Value }
        end,
        Load = function(idx, data)
            if SaveManager.Library.Options[idx] then
                SaveManager.Library.Options[idx]:SetValue(data.value)
            end
        end
    },
    Input = {
        Save = function(idx, object)
            return { type = "Input", idx = idx, value = object.Value }
        end,
        Load = function(idx, data)
            if SaveManager.Library.Options[idx] then
                SaveManager.Library.Options[idx]:SetValue(data.value)
            end
        end
    },
    ColorPicker = {
        Save = function(idx, object)
            return { type = "ColorPicker", idx = idx, value = object.Value:ToHex() }
        end,
        Load = function(idx, data)
            if SaveManager.Library.Options[idx] then
                SaveManager.Library.Options[idx]:SetValue(Color3.fromHex(data.value))
            end
        end
    },
    Keybind = {
        Save = function(idx, object)
            return { type = "Keybind", idx = idx, value = object.Value.Name }
        end,
        Load = function(idx, data)
            if SaveManager.Library.Options[idx] and Enum.KeyCode[data.value] then
                SaveManager.Library.Options[idx]:SetValue(Enum.KeyCode[data.value])
            end
        end
    }
}

function SaveManager:SetLibrary(library)
    self.Library = library
    library.SaveManager = self
end

function SaveManager:SetFolder(folder)
    self.Folder = folder
    self:BuildFolderTree()
end

function SaveManager:SetSubFolder(folder)
    self.SubFolder = folder
    self:BuildFolderTree()
end

function SaveManager:SetIgnoreIndexes(list)
    for _, key in pairs(list) do
        self.Ignore[key] = true
    end
end

function SaveManager:IgnoreThemeSettings()
    self:SetIgnoreIndexes({
        "BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor", "FontFace",
        "ThemeManager_ThemeList", "ThemeManager_CustomThemeList", "ThemeManager_CustomThemeName",
    })
end

-- Folder management
function SaveManager:BuildFolderTree()
    if not isfolder or not makefolder then return end
    
    local paths = {self.Folder, self.Folder .. "/settings", self.Folder .. "/themes"}
    if self.SubFolder then
        table.insert(paths, self.Folder .. "/settings/" .. self.SubFolder)
    end
    
    for _, path in ipairs(paths) do
        if not isfolder(path) then
            makefolder(path)
        end
    end
end

function SaveManager:GetSettingsPath()
    if self.SubFolder then
        return self.Folder .. "/settings/" .. self.SubFolder
    end
    return self.Folder .. "/settings"
end

-- Save/Load/Delete
function SaveManager:Save(name)
    if not name or name == "" then return false, "No config name" end
    
    self:BuildFolderTree()
    local path = self:GetSettingsPath() .. "/" .. name .. ".json"
    
    local data = { objects = {} }
    
    for idx, toggle in pairs(self.Library.Toggles or {}) do
        if not self.Ignore[idx] and toggle.Value ~= nil then
            table.insert(data.objects, self.Parser.Toggle.Save(idx, toggle))
        end
    end
    
    for idx, option in pairs(self.Library.Options or {}) do
        if not self.Ignore[idx] and option.Type and self.Parser[option.Type] then
            table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
        end
    end
    
    local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
    if not success then return false, "Encode error" end
    
    writefile(path, encoded)
    return true
end

function SaveManager:Load(name)
    if not name or name == "" then return false, "No config name" end
    
    local path = self:GetSettingsPath() .. "/" .. name .. ".json"
    if not isfile(path) then return false, "File not found" end
    
    local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(path))
    if not success then return false, "Decode error" end
    
    for _, obj in pairs(decoded.objects or {}) do
        if obj.type and self.Parser[obj.type] and not self.Ignore[obj.idx] then
            task.spawn(self.Parser[obj.type].Load, obj.idx, obj)
        end
    end
    
    return true
end

function SaveManager:Delete(name)
    if not name then return false end
    local path = self:GetSettingsPath() .. "/" .. name .. ".json"
    if isfile(path) then delfile(path) end
    return true
end

function SaveManager:GetConfigs()
    self:BuildFolderTree()
    local configs = {}
    local path = self:GetSettingsPath()
    
    if listfiles then
        for _, file in ipairs(listfiles(path)) do
            if file:sub(-5) == ".json" then
                local name = file:match("([^/\\]+)%.json$")
                if name then table.insert(configs, name) end
            end
        end
    end
    
    return configs
end

-- Autoload
function SaveManager:GetAutoloadConfig()
    local path = self:GetSettingsPath() .. "/autoload.txt"
    if isfile and isfile(path) then
        return readfile(path)
    end
    return nil
end

function SaveManager:SetAutoloadConfig(name)
    self:BuildFolderTree()
    local path = self:GetSettingsPath() .. "/autoload.txt"
    if name then
        writefile(path, name)
    elseif isfile(path) then
        delfile(path)
    end
end

function SaveManager:LoadAutoloadConfig()
    local name = self:GetAutoloadConfig()
    if name and name ~= "" then
        local success, err = self:Load(name)
        if success then
            print("[SaveManager] Auto-loaded config:", name)
        end
        return success
    end
    return false
end

-- Build UI
function SaveManager:BuildConfigSection(tab)
    if not tab then return end
    
    local section = tab:CreateSection({
        Name = "Configuration",
        Side = "Right"
    })
    
    local configs = self:GetConfigs()
    local selectedConfig = configs[1] or ""
    local autoloadConfig = self:GetAutoloadConfig() or ""
    
    section:AddDropdown({
        Name = "Config",
        Options = #configs > 0 and configs or {"none"},
        Default = selectedConfig ~= "" and selectedConfig or "none",
        Flag = "SaveManager_ConfigList",
        Callback = function(val)
            selectedConfig = val
        end
    })
    
    section:AddTextbox({
        Name = "Config Name",
        Default = "",
        Placeholder = "Enter config name...",
        Flag = "SaveManager_ConfigName",
        Callback = function(val)
            selectedConfig = val
        end
    })
    
    section:AddButton({
        Name = "Create Config",
        Callback = function()
            if selectedConfig and selectedConfig ~= "" and selectedConfig ~= "none" then
                local success = self:Save(selectedConfig)
                if success then
                    print("[SaveManager] Created config:", selectedConfig)
                end
            end
        end
    })
    
    section:AddButton({
        Name = "Load Config",
        Callback = function()
            if selectedConfig and selectedConfig ~= "" and selectedConfig ~= "none" then
                self:Load(selectedConfig)
                print("[SaveManager] Loaded config:", selectedConfig)
            end
        end
    })
    
    section:AddButton({
        Name = "Overwrite Config",
        Callback = function()
            if selectedConfig and selectedConfig ~= "" and selectedConfig ~= "none" then
                self:Save(selectedConfig)
                print("[SaveManager] Saved config:", selectedConfig)
            end
        end
    })
    
    section:AddDivider()
    
    section:AddButton({
        Name = "Set as Autoload",
        Callback = function()
            if selectedConfig and selectedConfig ~= "" and selectedConfig ~= "none" then
                self:SetAutoloadConfig(selectedConfig)
                print("[SaveManager] Set autoload:", selectedConfig)
            end
        end
    })
    
    section:AddButton({
        Name = "Clear Autoload",
        Callback = function()
            self:SetAutoloadConfig(nil)
            print("[SaveManager] Cleared autoload")
        end
    })
    
    section:AddDivider()
    
    section:AddButton({
        Name = "Refresh List",
        Callback = function()
            local newConfigs = self:GetConfigs()
            print("[SaveManager] Configs:", table.concat(newConfigs, ", "))
        end
    })
end

return SaveManager
