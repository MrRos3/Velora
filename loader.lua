-- Stable Velora loader.
local source = game:HttpGet("https://raw.githubusercontent.com/MrRos3/Velora/main/release-087.lua?loader=087", true)
local chunk, compileError = loadstring(source, "Velora 0.8.7 Encore")
assert(chunk, "Velora failed to compile: " .. tostring(compileError))
return chunk()
