-- Stable Velora loader.
local source = game:HttpGet("https://raw.githubusercontent.com/MrRos3/Velora/main/release-089.lua?loader=089", true)
local chunk, compileError = loadstring(source, "Velora 0.8.9 Encore")
assert(chunk, "Velora failed to compile: " .. tostring(compileError))
return chunk()
