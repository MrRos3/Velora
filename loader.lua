-- Stable Velora loader.
local source = game:HttpGet("https://raw.githubusercontent.com/MrRos3/Velora/main/release-040.lua", true)
local chunk, compileError = loadstring(source, "Velora 0.4.0 Aurora")
assert(chunk, "Velora failed to compile: " .. tostring(compileError))
return chunk()
