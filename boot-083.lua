local source = game:HttpGet("https://raw.githubusercontent.com/MrRos3/Velora/main/release-083.lua", true)
local chunk, compileError = loadstring(source, "Velora 0.8.3 Encore")
assert(chunk, "Velora failed to compile: " .. tostring(compileError))
local api = chunk()
assert(type(api) == "table", "Velora did not return its API table")
return api
