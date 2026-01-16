--[[
    Seisen UI - Icon Module
    Lucide Icons support via lucide-roblox-direct
]]

local Icons = {}

-- Load Lucide icons from lucide-roblox-direct
local FetchSuccess, IconModule = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/refs/heads/main/source.lua"))()
end)

-- Fallback icon data in case the fetch fails
Icons.Fallback = {
    Url = "",
    ImageRectOffset = Vector2.zero,
    ImageRectSize = Vector2.zero
}

-- Get a Lucide icon by name
function Icons:Get(iconName)
    if not FetchSuccess or not IconModule then
        warn("[Icons] Failed to load Lucide icons, using fallback")
        return self.Fallback
    end
    
    local success, icon = pcall(function()
        return IconModule.GetAsset(iconName)
    end)
    
    if success and icon then
        return icon
    else
        warn("[Icons] Icon not found:", iconName)
        return self.Fallback
    end
end

-- Check if a custom Roblox asset
function Icons:IsCustomAsset(iconString)
    if type(iconString) ~= "string" then return false end
    return iconString:match("rbxasset") 
        or iconString:match("roblox%.com/asset/%?id=")
        or iconString:match("rbxthumb://")
        or iconString:match("rbxassetid://")
end

-- Get icon - supports both Lucide names and Roblox asset IDs
function Icons:GetIcon(iconNameOrId)
    if not iconNameOrId or iconNameOrId == "" then
        return nil
    end
    
    -- If it's a custom Roblox asset
    if self:IsCustomAsset(iconNameOrId) then
        return {
            Url = iconNameOrId,
            ImageRectOffset = Vector2.zero,
            ImageRectSize = Vector2.zero,
            Custom = true
        }
    end
    
    -- Otherwise try to get from Lucide
    return self:Get(iconNameOrId)
end

-- List of commonly used icons for reference
Icons.CommonIcons = {
    -- Navigation
    "home", "menu", "search", "settings", "chevron-down", "chevron-up", "chevron-left", "chevron-right",
    "arrow-left", "arrow-right", "arrow-up", "arrow-down", "x", "check", "plus", "minus",
    
    -- Actions
    "edit", "trash", "save", "download", "upload", "copy", "clipboard", "refresh-cw",
    "play", "pause", "stop", "skip-forward", "skip-back", "volume", "volume-2", "volume-x",
    
    -- UI Elements
    "eye", "eye-off", "lock", "unlock", "bell", "star", "heart", "bookmark",
    "folder", "file", "image", "video", "music", "link", "external-link",
    
    -- Users & People
    "user", "users", "user-plus", "user-minus", "user-check", "user-x",
    
    -- Communication
    "message-circle", "message-square", "mail", "send", "phone", "at-sign",
    
    -- Gaming/Combat related
    "sword", "shield", "target", "crosshair", "zap", "flame", "skull", "trophy",
    "gamepad", "gamepad-2", "joystick", "dices",
    
    -- System
    "cpu", "hard-drive", "server", "database", "terminal", "code", "bug", "tool", "wrench",
    
    -- Misc
    "sun", "moon", "cloud", "globe", "map", "compass", "flag", "clock", "calendar",
    "paintbrush", "palette", "layers", "grid", "layout", "box", "package"
}

return Icons
