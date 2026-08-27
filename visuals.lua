-- Velora visual layer.
-- Clean public name for the previously named glassmorphism.lua module.
-- The implementation is pinned to the last proven snapshot for stability.
local SNAPSHOT = "41ff131a44c22e6225ffd8114dfabe416f59bab1"
local URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/" .. SNAPSHOT .. "/glassmorphism.lua",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@" .. SNAPSHOT .. "/glassmorphism.lua",
}

local lastError
for _, url in ipairs(URLS) do
    local ok, source = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and type(source) == "string" and source ~= "" then
        local chunk, compileError = loadstring(source)
        if type(chunk) == "function" then
            return chunk()
        end
        lastError = compileError
    else
        lastError = source
    end
end

error("Velora visuals could not load: " .. tostring(lastError), 0)
