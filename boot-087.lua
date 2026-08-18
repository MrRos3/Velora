local source = game:HttpGet("https://raw.githubusercontent.com/MrRos3/Velora/main/release-087.lua?boot=087", true)
local chunk, compileError = loadstring(source, "Velora 0.8.7 Encore")
assert(chunk, "Velora failed to compile: " .. tostring(compileError))
local api = chunk()
assert(type(api) == "table", "Velora did not return its API table")
return api
