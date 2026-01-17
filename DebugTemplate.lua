local Repo = "https://raw.githubusercontent.com/Seisen88/Seisen-Library/main/"

print("--- Starting Debug ---")
print("Repo URL:", Repo)

-- 1. Attempt to fetch SeisenUI.lua content
print("Fetching SeisenUI.lua...")
local success, content = pcall(function()
    return game:HttpGet(Repo .. "SeisenUI.lua?v=" .. tostring(math.random()))
end)

if not success then
    warn("Failed to fetch SeisenUI.lua: " .. tostring(content))
    return
end

print("Fetch successful. Content length:", #content)
print("Content preview:", string.sub(content, 1, 100))

-- 2. Attempt to loadstring the content
print("Attempting loadstring...")
local func, err = loadstring(content)

if not func then
    warn("Syntax Error in SeisenUI.lua: " .. tostring(err))
    return
end

print("Loadstring successful. Executing library...")

-- 3. Execute the library
local libSuccess, Library = pcall(func)

if not libSuccess then
    warn("Library execution failed: " .. tostring(Library))
    return
end

if not Library then
    warn("Library executed but returned nil!")
    return
end

print("Library loaded successfully:", tostring(Library))
print("--- Debug Complete ---")
