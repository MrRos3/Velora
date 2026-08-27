-- Velora runtime layer.
-- Boots the proven runtime invisibly so users never see intermediate UI layers.
local SNAPSHOT = "41ff131a44c22e6225ffd8114dfabe416f59bab1"
local URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/" .. SNAPSHOT .. "/smooth.lua",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@" .. SNAPSHOT .. "/smooth.lua",
}

local function prepareHiddenBoot(source)
    -- smooth.lua patches release.lua before compiling it. Inject one final source
    -- transform at that point so Velora's ScreenGui exists from frame zero with
    -- Enabled=false. The main loader reveals it only after every visual layer is done.
    local marker = "local chunk, compileError = loadstring(patchedSource)"
    local first = string.find(source, marker, 1, true)
    if not first then
        return nil, "hidden-boot insertion point was not found"
    end

    local injection = [=[
patchedSource = string.gsub(
    patchedSource,
    'Name="Velora",ResetOnSpawn=false,IgnoreGuiInset=true',
    'Name="Velora",Enabled=false,ResetOnSpawn=false,IgnoreGuiInset=true',
    1
)
if not string.find(patchedSource, 'Name="Velora",Enabled=false', 1, true) then
    error("Velora runtime could not prepare invisible boot", 0)
end

]=]

    return source:sub(1, first - 1) .. injection .. source:sub(first)
end

local lastError
for _, url in ipairs(URLS) do
    local ok, source = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and type(source) == "string" and source ~= "" then
        local prepared, prepareError = prepareHiddenBoot(source)
        if prepared then
            local chunk, compileError = loadstring(prepared)
            if type(chunk) == "function" then
                return chunk()
            end
            lastError = compileError
        else
            lastError = prepareError
        end
    else
        lastError = source
    end
end

error("Velora runtime could not load: " .. tostring(lastError), 0)
