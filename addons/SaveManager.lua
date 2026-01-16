--[[
    Seisen UI - SaveManager
    Handles saving/loading UI configurations
]]

local HttpService = game:GetService("HttpService")

local SaveManager = {}
SaveManager.Folder = "SeisenConfigs"
SaveManager.Library = nil
SaveManager.Ignore = {}

-- File system functions (executor-specific)
local function EnsureFolder(path)
    if isfolder and makefolder then
        if not isfolder(path) then
            makefolder(path)
        end
    end
end

local function FileExists(path)
    if isfile then
        return isfile(path)
    end
    return false
end

local function ReadFile(path)
    if readfile then
        return readfile(path)
    end
    return nil
end

local function WriteFile(path, content)
    if writefile then
        writefile(path, content)
        return true
    end
    return false
end

local function ListFiles(path)
    if listfiles then
        return listfiles(path)
    end
    return {}
end

local function DeleteFile(path)
    if delfile then
        delfile(path)
        return true
    end
    return false
end

-- Parser for different element types
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
    Keybind = {
        Save = function(idx, object)
            return { type = "Keybind", idx = idx, value = object.Value }
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
    }
}

function SaveManager:SetLibrary(library)
    self.Library = library
    library.SaveManager = self
end

function SaveManager:SetFolder(folder)
    self.Folder = folder
    EnsureFolder(folder)
end

function SaveManager:SetSubFolder(subfolder)
    self.SubFolder = subfolder
    EnsureFolder(self.Folder .. "/" .. subfolder)
end

function SaveManager:SetIgnoreIndexes(list)
    for _, v in ipairs(list) do
        self.Ignore[v] = true
    end
end

function SaveManager:GetConfigPath()
    local path = self.Folder
    if self.SubFolder and self.SubFolder ~= "" then
        path = path .. "/" .. self.SubFolder
    end
    return path
end

function SaveManager:Save(name)
    if not self.Library then return false, "Library not set" end
    
    local data = { toggles = {}, options = {} }
    
    -- Save toggles
    for idx, toggle in pairs(self.Library.Toggles or {}) do
        if not self.Ignore[idx] then
            table.insert(data.toggles, self.Parser.Toggle.Save(idx, toggle))
        end
    end
    
    -- Save options (sliders, dropdowns, inputs, etc.)
    for idx, option in pairs(self.Library.Options or {}) do
        if not self.Ignore[idx] and option.Type then
            local parser = self.Parser[option.Type]
            if parser then
                table.insert(data.options, parser.Save(idx, option))
            end
        end
    end
    
    local path = self:GetConfigPath() .. "/" .. name .. ".json"
    local json = HttpService:JSONEncode(data)
    
    EnsureFolder(self:GetConfigPath())
    return WriteFile(path, json)
end

function SaveManager:Load(name)
    if not self.Library then return false, "Library not set" end
    
    local path = self:GetConfigPath() .. "/" .. name .. ".json"
    
    if not FileExists(path) then
        return false, "Config not found"
    end
    
    local success, data = pcall(function()
        return HttpService:JSONDecode(ReadFile(path))
    end)
    
    if not success then
        return false, "Failed to parse config"
    end
    
    -- Load toggles
    for _, toggleData in ipairs(data.toggles or {}) do
        self.Parser.Toggle.Load(toggleData.idx, toggleData)
    end
    
    -- Load options
    for _, optionData in ipairs(data.options or {}) do
        local parser = self.Parser[optionData.type]
        if parser then
            parser.Load(optionData.idx, optionData)
        end
    end
    
    return true
end

function SaveManager:Delete(name)
    local path = self:GetConfigPath() .. "/" .. name .. ".json"
    return DeleteFile(path)
end

function SaveManager:GetConfigs()
    local configs = {}
    local path = self:GetConfigPath()
    
    EnsureFolder(path)
    
    for _, file in ipairs(ListFiles(path)) do
        if file:match("%.json$") then
            local name = file:match("([^/\\]+)%.json$")
            if name then
                table.insert(configs, name)
            end
        end
    end
    
    return configs
end

function SaveManager:BuildConfigSection(tab)
    if not tab then return end
    
    local section = tab:CreateSection({
        Name = "Configuration",
        Side = "Right"
    })
    
    local configList = self:GetConfigs()
    local selectedConfig = configList[1] or ""
    
    section:AddDropdown({
        Name = "Config",
        Options = configList,
        Default = selectedConfig,
        Callback = function(value)
            selectedConfig = value
        end
    })
    
    section:AddTextbox({
        Name = "Config Name",
        Default = "",
        Placeholder = "Enter name...",
        Callback = function(value)
            selectedConfig = value
        end
    })
    
    section:AddButton({
        Name = "Save Config",
        Callback = function()
            if selectedConfig and selectedConfig ~= "" then
                self:Save(selectedConfig)
                print("[SaveManager] Saved config:", selectedConfig)
            end
        end
    })
    
    section:AddButton({
        Name = "Load Config",
        Callback = function()
            if selectedConfig and selectedConfig ~= "" then
                self:Load(selectedConfig)
                print("[SaveManager] Loaded config:", selectedConfig)
            end
        end
    })
    
    section:AddButton({
        Name = "Delete Config",
        Callback = function()
            if selectedConfig and selectedConfig ~= "" then
                self:Delete(selectedConfig)
                print("[SaveManager] Deleted config:", selectedConfig)
            end
        end
    })
    
    section:AddButton({
        Name = "Refresh List",
        Callback = function()
            -- Refresh would need dropdown update API
            print("[SaveManager] Configs:", table.concat(self:GetConfigs(), ", "))
        end
    })
end

return SaveManager
