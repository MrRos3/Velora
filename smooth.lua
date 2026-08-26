-- Velora smooth public hybrid launcher.
-- Uses the latest proven Velora UI snapshot, but forces the old fast/local song path.
-- Protected playback code is disabled in this launcher on purpose.
local UI_REF = "3709c3eed7aeef1a636ce250a5553db231c7324e"

local RELEASE_URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/" .. UI_REF .. "/release.lua?v=public-smooth-ui1",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@" .. UI_REF .. "/release.lua?v=public-smooth-ui1",
}

local PATCH_URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/" .. UI_REF .. "/patches.lua?v=public-smooth-ui1",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@" .. UI_REF .. "/patches.lua?v=public-smooth-ui1",
}

local function fail(reason)
    local message = "Velora could not start: " .. tostring(reason)
    warn(message)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Velora could not start",
            Text = message,
            Duration = 12,
        })
    end)
    error(message, 0)
end

if type(loadstring) ~= "function" then
    fail("this executor does not provide loadstring")
end

local function download(urls, label)
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
    fail(label .. " download failed - " .. tostring(lastError))
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

local source = download(RELEASE_URLS, "latest UI release")
local patchSource = download(PATCH_URLS, "latest UI patch")

-- Keep the new UI, but point its registry/song loading to this isolated test branch.
source = replaceOnce(
    source,
    'local RAW_BASE = "https://raw.githubusercontent.com/MrRos3/Velora/protected-playback-test/"',
    'local RAW_BASE = "https://raw.githubusercontent.com/MrRos3/Velora/velora-upgrades-test/"',
    "test song base"
)

-- Completely remove protected-client startup from this smooth build.
-- The test branch keeps normal File= entries, so the runtime takes the fast local path.
source = replaceBetween(
    source,
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

local patched, patchedSource = pcall(patcher, source)
if not patched or type(patchedSource) ~= "string" then
    fail("patch apply failed - " .. tostring(patchedSource))
end

local chunk, compileError = loadstring(patchedSource)
if type(chunk) ~= "function" then
    fail("compile failed - " .. tostring(compileError))
end

local started, result = pcall(chunk)
if not started then
    fail("runtime error - " .. tostring(result))
end

-- Cleaner Creator Store UI click for the Upgrade Lab test build.
local function bindClickSounds(api)
    local gui = type(api) == "table" and api.UI and api.UI.Gui
    if not gui then return end

    local SoundService = game:GetService("SoundService")
    local function playClick()
        local sound = Instance.new("Sound")
        sound.Name = "VeloraClick"
        sound.SoundId = "rbxassetid://113397864512278"
        sound.Volume = 0.09
        sound.PlaybackSpeed = 1
        sound.Parent = SoundService
        sound:Play()
        sound.Ended:Connect(function()
            if sound.Parent then sound:Destroy() end
        end)
        task.delay(2, function()
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
