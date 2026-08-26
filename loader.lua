-- Velora public loader.
-- Clean permanent entrypoint for the current smooth hybrid build.
local SMOOTH_REF = "bed27c6ebba260d153f1aec7fe613aadf41c1652"
local URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/" .. SMOOTH_REF .. "/smooth.lua",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@" .. SMOOTH_REF .. "/smooth.lua",
}

local function fail(reason)
    local message = "Velora could not start: " .. tostring(reason)
    warn(message)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Velora could not start",
            Text = message,
            Duration = 12,
        })
    end)
    error(message, 0)
end

if type(loadstring) ~= "function" then
    fail("this executor does not provide loadstring")
end

local source
local lastError
for _, url in ipairs(URLS) do
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and type(result) == "string" and result ~= "" then
        source = result
        break
    end
    lastError = result
end

if not source then
    fail("smooth launcher download failed - " .. tostring(lastError))
end

local chunk, compileError = loadstring(source)
if type(chunk) ~= "function" then
    fail("smooth launcher compile failed - " .. tostring(compileError))
end

local started, result = pcall(chunk)
if not started then
    fail("smooth launcher runtime error - " .. tostring(result))
end

return result