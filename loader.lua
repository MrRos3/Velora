-- Stable Velora loader.
local source = game:HttpGet("https://raw.githubusercontent.com/MrRos3/Velora/main/release-051.lua", true)
local chunk, compileError = loadstring(source, "Velora 0.5.1 Rose")
assert(chunk, "Velora failed to compile: " .. tostring(compileError))
return chunk()
