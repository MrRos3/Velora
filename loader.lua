-- Stable Velora loader.
local source = game:HttpGet("https://raw.githubusercontent.com/MrRos3/Velora/main/release-060.lua", true)
local chunk, compileError = loadstring(source, "Velora 0.6.0 Lucide")
assert(chunk, "Velora failed to compile: " .. tostring(compileError))
return chunk()
