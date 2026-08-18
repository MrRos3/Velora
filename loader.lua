local source = game:HttpGet("https://raw.githubusercontent.com/MrRos3/Velora/main/latest.lua?velora=0.3.1")
local chunk, compileError = loadstring(source)
assert(chunk, "Velora failed to compile: " .. tostring(compileError))
local result = chunk()
assert(type(result) == "table", "Velora did not return its API table")
return result
