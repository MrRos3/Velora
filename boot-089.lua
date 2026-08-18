-- Velora public compatibility boot.
local RELEASE_URL = "https://raw.githubusercontent.com/MrRos3/Velora/main/release-089.lua?v=089-compat-boot-20260818"

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

local downloaded, source = pcall(function()
    return game:HttpGet(RELEASE_URL)
end)
if not downloaded or type(source) ~= "string" or source == "" then
    fail("download failed - " .. tostring(source))
end

local chunk, compileError = loadstring(source)
if type(chunk) ~= "function" then
    fail("compile failed - " .. tostring(compileError))
end

local started, result = pcall(chunk)
if not started then
    fail("runtime error - " .. tostring(result))
end

return result
