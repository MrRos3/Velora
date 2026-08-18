-- Stable Velora loader.
local source = game:HttpGet("https://raw.githubusercontent.com/MrRos3/Velora/main/release-084.lua", true)
local chunk, compileError = loadstring(source, "Velora 0.8.4 Encore")
assert(chunk, "Velora failed to compile: " .. tostring(compileError))
return chunk()
