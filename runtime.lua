-- Velora runtime layer.
-- Fast flattened bootstrap: fetches the proven UI release + patch in parallel,
-- applies the public-library transform, then starts the UI atomically hidden.
local UI_REF = "3709c3eed7aeef1a636ce250a5553db231c7324e"

local RELEASE_URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/" .. UI_REF .. "/release.lua?v=velora-fast-runtime-1",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@" .. UI_REF .. "/release.lua?v=velora-fast-runtime-1",
}

local PATCH_URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/" .. UI_REF .. "/patches.lua?v=velora-fast-runtime-1",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@" .. UI_REF .. "/patches.lua?v=velora-fast-runtime-1",
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

local function fail(reason)
    error("Velora runtime could not load: " .. tostring(reason), 0)
end

if type(loadstring) ~= "function" then
    fail("this executor does not provide loadstring")
end

local function download(urls)
    local lastError
    for _, url in ipairs(urls) do
        local ok, result = pcall(function()
            return game:HttpGet(url)
        end)
        if ok and type(result) == "string" and result ~= "" then
            return result
        end
        lastError = result
    end
    return nil, lastError
end

local function replaceOnce(source, oldText, newText, label)
    local first, last = string.find(source, oldText, 1, true)
    if not first then
        fail("could not prepare " .. tostring(label))
    end
    return source:sub(1, first - 1) .. newText .. source:sub(last + 1)
end

local function replaceBetween(source, startMarker, endMarker, replacement, label)
    local first = string.find(source, startMarker, 1, true)
    if not first then
        fail("could not find " .. tostring(label) .. " start")
    end
    local endFirst = string.find(source, endMarker, first, true)
    if not endFirst then
        fail("could not find " .. tostring(label) .. " end")
    end
    return source:sub(1, first - 1) .. replacement .. source:sub(endFirst)
end

-- Fetch the two heavy core files concurrently instead of serially.
local pending = 2
local releaseSource, releaseError
local patchSource, patchError

task.spawn(function()
    releaseSource, releaseError = download(RELEASE_URLS)
    pending -= 1
end)

task.spawn(function()
    patchSource, patchError = download(PATCH_URLS)
    pending -= 1
end)

while pending > 0 do
    task.wait()
end

if not releaseSource then
    fail("release download failed - " .. tostring(releaseError))
end
if not patchSource then
    fail("patch download failed - " .. tostring(patchError))
end

-- Keep the proven UI, but route all songs to the live public library.
releaseSource = replaceOnce(
    releaseSource,
    'local RAW_BASE = "https://raw.githubusercontent.com/MrRos3/Velora/protected-playback-test/"',
    'local RAW_BASE = "https://raw.githubusercontent.com/MrRos3/Velora/main/"',
    "public song base"
)

-- Bust the public song registry/module cache whenever the live library changes.
releaseSource = replaceOnce(
    releaseSource,
    'AssetRevision = "0.10.21-seekfix1"',
    'AssetRevision = "0.10.21-native-ievan-1"',
    "song library revision"
)

-- Remove the protected-client startup from the public build.
releaseSource = replaceBetween(
    releaseSource,
    "local ProtectedClient\n",
    "-- Bundled LucideBlox mappings",
    "local ProtectedClient = nil\n\n",
    "protected playback block"
)

local patchChunk, patchCompileError = loadstring(patchSource)
if type(patchChunk) ~= "function" then
    fail("patch compile failed - " .. tostring(patchCompileError))
end

local patchLoaded, patcher = pcall(patchChunk)
if not patchLoaded or type(patcher) ~= "function" then
    fail("patch startup failed - " .. tostring(patcher))
end

local patched, patchedSource = pcall(patcher, releaseSource)
if not patched or type(patchedSource) ~= "string" then
    fail("patch apply failed - " .. tostring(patchedSource))
end

if atomicBootRequested() then
    patchedSource = string.gsub(
        patchedSource,
        'Name="Velora",ResetOnSpawn=false,IgnoreGuiInset=true',
        'Name="Velora",Enabled=false,ResetOnSpawn=false,IgnoreGuiInset=true',
        1
    )
    if not string.find(patchedSource, 'Name="Velora",Enabled=false', 1, true) then
        fail("could not prepare atomic hidden boot")
    end
end

local chunk, compileError = loadstring(patchedSource)
if type(chunk) ~= "function" then
    fail("compile failed - " .. tostring(compileError))
end

local started, result = pcall(chunk)
if not started then
    fail("runtime error - " .. tostring(result))
end

-- Preserve the proven smooth-build click audio behavior.
local function bindClickSounds(api)
    local gui = type(api) == "table" and api.UI and api.UI.Gui
    if not gui then return end

    local SoundService = game:GetService("SoundService")
    local function playClick()
        local sound = Instance.new("Sound")
        sound.Name = "VeloraClick"
        sound.SoundId = "rbxassetid://17582213219"
        sound.Volume = 0.12
        sound.Parent = SoundService
        sound:Play()
        sound.Ended:Connect(function()
            if sound.Parent then sound:Destroy() end
        end)
        task.delay(3, function()
            if sound.Parent then sound:Destroy() end
        end)
    end

    local function attach(button)
        if not button:IsA("TextButton") or button:GetAttribute("VeloraSmoothClickBound") then return end
        button:SetAttribute("VeloraSmoothClickBound", true)
        button.Activated:Connect(playClick)
    end

    for _, descendant in ipairs(gui:GetDescendants()) do
        if descendant:IsA("TextButton") then attach(descendant) end
    end
    gui.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("TextButton") then attach(descendant) end
    end)
end

pcall(bindClickSounds, result)
return result
