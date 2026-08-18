-- Stable Velora loader.
local source = game:HttpGet("https://raw.githubusercontent.com/MrRos3/Velora/main/release-050.lua", true)
local chunk, compileError = loadstring(source, "Velora 0.5.0 Rose")
assert(chunk, "Velora failed to compile: " .. tostring(compileError))
return chunk()
