-- Velora runtime layer.
-- Loads the proven runtime snapshot and supports an atomic hidden startup when
-- loader.lua sets the VeloraAtomicBoot handshake flag.
local SNAPSHOT = "41ff131a44c22e6225ffd8114dfabe416f59bab1"
local URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/" .. SNAPSHOT .. "/smooth.lua",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@" .. SNAPSHOT .. "/smooth.lua",
}

local function atomicBootRequested()
    if rawget(_G, "VeloraAtomicBoot") == true then
        return true
    end
    if type(getgenv) == "function" then
        local ok, env = pcall(getgenv)
        if ok and type(env) == "table" and rawget(env, "VeloraAtomicBoot") == true then
            return true
        end
    end
    return false
end

local function prepareRuntime(source)
    if not atomicBootRequested() then
        return source
    end

    -- smooth.lua has already produced patchedSource at this point, but has not
    -- executed it yet. Inject a final transform that makes the Velora ScreenGui
    -- start disabled, so every upgrade/visual/polish pass happens off-screen.
    local marker = "local chunk, compileError = loadstring(patchedSource)"
    local first = string.find(source, marker, 1, true)
    if not first then
        return nil, "atomic-boot insertion point was not found"
    end

    local injection = [=[
patchedSource = string.gsub(
    patchedSource,
    'Name="Velora",ResetOnSpawn=false,IgnoreGuiInset=true',
    'Name="Velora",Enabled=false,ResetOnSpawn=false,IgnoreGuiInset=true',
    1
)
if not string.find(patchedSource, 'Name="Velora",Enabled=false', 1, true) then
    error("Velora runtime could not prepare atomic boot", 0)
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
        local prepared, prepareError = prepareRuntime(source)
        if prepared then
            local chunk, compileError = loadstring(prepared)
            if type(chunk) == "function" then
                local started, result = pcall(chunk)
                if started then
                    return result
                end
                lastError = result
            else
                lastError = compileError
            end
        else
            lastError = prepareError
        end
    else
        lastError = source
    end
end

error("Velora runtime could not load: " .. tostring(lastError), 0)