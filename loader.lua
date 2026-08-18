-- Stable loader. The release filename changes when a cache-breaking update is required.
local source = game:HttpGet("https://raw.githubusercontent.com/MrRos3/Velora/main/release-032.lua", true)
local chunk, compileError = loadstring(source, "Velora 0.3.2")
assert(chunk, "Velora failed to compile: " .. tostring(compileError))
return chunk()
