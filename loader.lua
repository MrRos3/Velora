local source = game:HttpGet("https://raw.githubusercontent.com/MrRos3/Velora/main/latest.lua?velora=0.3.0")
local chunk, compileError = loadstring(source)
assert(chunk, "Velora latest.lua failed to compile: " .. tostring(compileError))
local result = chunk()
assert(type(result) == "table", "Velora latest.lua did not return its API table")
return result
