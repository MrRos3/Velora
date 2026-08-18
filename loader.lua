-- Stable Velora loader.
local source = game:HttpGet("https://raw.githubusercontent.com/MrRos3/Velora/main/release-085.lua", true)
local chunk, compileError = loadstring(source, "Velora 0.8.5 Encore")
assert(chunk, "Velora failed to compile: " .. tostring(compileError))
return chunk()
