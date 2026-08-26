--[[
    Velora Upgrade Lab — Wave 2
    Test branch only. Additive/persistent workstation features.

    Adds:
      • Queue / Up Next
      • Playlists
      • Persistent Recent history
      • Song transition polish
      • Seek drag glow
      • Hold-to-accelerate BPM + double-click/select-all BPM editing
      • Difficulty display
      • Shuffle modes
      • Output/touch profile preference
      • Optional 3-2-1 countdown
      • Library sorting
      • Most-played statistics
      • NEW / FAVORITE / MIDI badges
      • Fast startup micro-animation
      • Empty search/filter states
      • Lab update indicator
      • Glass / glow / transparency controls
      • Performance mode
      • Future-ready runtime song import/admin scaffold

    This module deliberately does not replace Velora's local playback engine.
]]

return function(API)
    assert(type(API) == "table", "Velora Wave 2 expects the Velora API")

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local HttpService = game:GetService("HttpService")

    local VERSION = "0.2.0-test"
    local player = Players.LocalPlayer
    local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
    local gui = API.UI and API.UI.Gui
    if not gui and playerGui then
        gui = playerGui:FindFirstChild("Velora")
    end
    if not gui then return false, "Velora GUI not found" end

    if gui:FindFirstChild("VeloraWave2Marker") then
        return true
    end

    local window = gui:FindFirstChild("Aurora", true)
    local drawer = gui:FindFirstChild("UpgradeDrawer", true)
    local labButton = gui:FindFirstChild("VeloraUpgradeLab", true)
    local scroller = drawer and drawer:FindFirstChildWhichIsA("ScrollingFrame", true)
    if not window or not drawer or not labButton or not scroller then
        return false, "Velora Upgrade Lab must load before Wave 2"
    end

    local marker = Instance.new("Folder")
    marker.Name = "VeloraWave2Marker"
    marker.Parent = gui

    local COLORS = {
        Ink = Color3.fromRGB(8, 6, 7),
        Surface = Color3.fromRGB(18, 12, 14),
        Raised = Color3.fromRGB(29, 19, 22),
        Raised2 = Color3.fromRGB(43, 27, 31),
        Accent = Color3.fromRGB(211, 76, 90),
        Edge = Color3.fromRGB(118, 58, 65),
        Text = Color3.fromRGB(255, 247, 249),
        Sub = Color3.fromRGB(220, 198, 203),
        Muted = Color3.fromRGB(155, 126, 132),
    }

    local function make(className, props, parent)
        local object = Instance.new(className)
        for key, value in pairs(props or {}) do
            object[key] = value
        end
        object.Parent = parent
        return object
    end

    local function round(object, radius)
        make("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, object)
        return object
    end

    local function edge(object, transparency, thickness, color)
        make("UIStroke", {
            Color = color or COLORS.Edge,
            Transparency = transparency == nil and 0.62 or transparency,
            Thickness = thickness or 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }, object)
        return object
    end

    local function label(parent, value, size, color, bold)
        return make("TextLabel", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = size or UDim2.new(1, 0, 0, 18),
            Text = value or "",
            TextColor3 = color or COLORS.Text,
            TextSize = 9,
            Font = bold and Enum.Font.BuilderSansExtraBold or Enum.Font.BuilderSans,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextWrapped = false,
            ZIndex = 234,
        }, parent)
    end

    local function button(parent, value, size)
        local b = round(edge(make("TextButton", {
            BackgroundColor3 = COLORS.Raised,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = value or "",
            TextColor3 = COLORS.Sub,
            TextSize = 8,
            Font = Enum.Font.BuilderSansExtraBold,
            Size = size or UDim2.fromOffset(70, 28),
            ZIndex = 234,
        }, parent), 0.65, 1), 9)
        b.MouseEnter:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.11), {BackgroundColor3 = COLORS.Raised2, TextColor3 = COLORS.Text}):Play()
        end)
        b.MouseLeave:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.11), {BackgroundColor3 = COLORS.Raised, TextColor3 = COLORS.Sub}):Play()
        end)
        return b
    end

    local function section(titleText, height)
        local frame = round(edge(make("Frame", {
            Name = "Wave2Section",
            Size = UDim2.new(1, -7, 0, height),
            BackgroundColor3 = COLORS.Surface,
            BackgroundTransparency = 0.08,
            BorderSizePixel = 0,
            ZIndex = 232,
        }, scroller), 0.72, 1), 13)
        local t = label(frame, titleText, UDim2.new(1, -24, 0, 18), COLORS.Muted, true)
        t.Position = UDim2.fromOffset(12, 7)
        t.TextSize = 8
        return frame
    end

    local function formatTime(seconds)
        seconds = math.max(0, tonumber(seconds) or 0)
        return string.format("%d:%02d", math.floor(seconds / 60), math.floor(seconds % 60))
    end

    local function snapshot()
        local ok, snap = pcall(function() return API:GetSnapshot() end)
        return ok and type(snap) == "table" and snap or {}
    end

    local function registry()
        local ok, songs = pcall(function() return API:GetSongs() end)
        return ok and type(songs) == "table" and songs or {}
    end

    local function entryById(id)
        if not id then return nil end
        if type(API.GetSong) == "function" then
            local ok, entry = pcall(API.GetSong, API, id)
            if ok and type(entry) == "table" then return entry end
        end
        for _, entry in ipairs(registry()) do
            if entry.Id == id then return entry end
        end
        return nil
    end

    local function pickedId(snap)
        snap = snap or snapshot()
        return snap.SelectedId or snap.PendingId or (snap.Entry and snap.Entry.Id)
    end

    local function currentId(snap)
        snap = snap or snapshot()
        return snap.Entry and snap.Entry.Id or snap.SelectedId
    end

    local function nameFor(id)
        local entry = entryById(id)
        return entry and tostring(entry.Name or entry.Id) or tostring(id or "")
    end

    local function hasCategory(entry, wanted)
        if type(entry) ~= "table" or type(entry.Categories) ~= "table" then return false end
        for _, category in ipairs(entry.Categories) do
            if tostring(category) == wanted then return true end
        end
        return false
    end

    local function difficulty(entry)
        if not entry then return "—" end
        local id = tostring(entry.Id or "")
        local bpm = tonumber(entry.BPM) or 120
        if hasCategory(entry, "Starter") or bpm <= 55 then return "EASY" end
        if hasCategory(entry, "Virtuoso") or id == "fantaisie-impromptu" or id == "minute-waltz" then return "INSANE" end
        if bpm >= 165 or hasCategory(entry, "Fast") then return "HARD" end
        if bpm >= 125 or hasCategory(entry, "Classical") or hasCategory(entry, "Dramatic") then return "MEDIUM" end
        return "EASY"
    end

    -- ---------------------------------------------------------
    -- Persistent Wave 2 data
    -- ---------------------------------------------------------

    local DATA_KEY = "VeloraUpgradeWave2StateV1"
    local DATA_DIR = "Velora"
    local DATA_PATH = DATA_DIR .. "/wave2_state.json"

    local function environment()
        if type(getgenv) == "function" then
            local ok, env = pcall(getgenv)
            if ok and type(env) == "table" then return env end
        end
        return _G
    end

    local data = {
        Queue = {},
        Playlists = { ["My Playlist"] = {} },
        PlaylistOrder = {"My Playlist"},
        Recent = {},
        PlayCounts = {},
        Durations = {},
        SeenVersion = "",
        Settings = {
            Sort = "DEFAULT",
            Shuffle = "OFF",
            Output = "NORMAL",
            Countdown = 0,
            Glass = 0.5,
            Glow = 0.72,
            Transparency = 0.5,
            Performance = false,
        },
    }

    local function mergeLoaded(loaded)
        if type(loaded) ~= "table" then return end
        if type(loaded.Queue) == "table" then data.Queue = loaded.Queue end
        if type(loaded.Playlists) == "table" then data.Playlists = loaded.Playlists end
        if type(loaded.PlaylistOrder) == "table" then data.PlaylistOrder = loaded.PlaylistOrder end
        if type(loaded.Recent) == "table" then data.Recent = loaded.Recent end
        if type(loaded.PlayCounts) == "table" then data.PlayCounts = loaded.PlayCounts end
        if type(loaded.Durations) == "table" then data.Durations = loaded.Durations end
        if type(loaded.SeenVersion) == "string" then data.SeenVersion = loaded.SeenVersion end
        if type(loaded.Settings) == "table" then
            for key, value in pairs(loaded.Settings) do
                if data.Settings[key] ~= nil then data.Settings[key] = value end
            end
        end
    end

    do
        local env = environment()
        if type(env[DATA_KEY]) == "table" then mergeLoaded(env[DATA_KEY]) end
        pcall(function()
            if type(isfile) == "function" and type(readfile) == "function" and isfile(DATA_PATH) then
                mergeLoaded(HttpService:JSONDecode(readfile(DATA_PATH)))
            end
        end)
        env[DATA_KEY] = data
    end

    if #data.PlaylistOrder == 0 then
        data.Playlists["My Playlist"] = data.Playlists["My Playlist"] or {}
        data.PlaylistOrder = {"My Playlist"}
    end

    local saveToken = 0
    local function saveSoon()
        environment()[DATA_KEY] = data
        saveToken += 1
        local token = saveToken
        task.delay(0.55, function()
            if token ~= saveToken then return end
            pcall(function()
                if type(writefile) ~= "function" then return end
                if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder(DATA_DIR) then
                    makefolder(DATA_DIR)
                end
                writefile(DATA_PATH, HttpService:JSONEncode(data))
            end)
        end)
    end

    local function insertFrontUnique(list, value, maximum)
        for index = #list, 1, -1 do
            if list[index] == value then table.remove(list, index) end
        end
        table.insert(list, 1, value)
        while #list > (maximum or 20) do table.remove(list) end
    end

    -- Seed the built-in Recent filter with persisted history.
    if API.State and type(API.State.Recent) == "table" then
        for index = #API.State.Recent, 1, -1 do
            insertFrontUnique(data.Recent, API.State.Recent[index], 20)
        end
        table.clear(API.State.Recent)
        for _, id in ipairs(data.Recent) do table.insert(API.State.Recent, id) end
    end

    -- ---------------------------------------------------------
    -- Locate main Velora controls
    -- ---------------------------------------------------------

    local header
    local playerCard
    local discoverLabel
    local searchBox
    for _, descendant in ipairs(gui:GetDescendants()) do
        if descendant:IsA("TextLabel") then
            if descendant.Text == "VELORA" and not header then header = descendant.Parent end
            if descendant.Text == "NOW PLAYING" and not playerCard then playerCard = descendant.Parent end
            if descendant.Text == "DISCOVER" and not discoverLabel then discoverLabel = descendant end
        elseif descendant:IsA("TextBox") and descendant.PlaceholderText == "Search the library" then
            searchBox = descendant
        end
    end

    local browser = searchBox and searchBox.Parent
    local nav = discoverLabel and discoverLabel.Parent
    local songList
    if browser then
        for _, child in ipairs(browser:GetChildren()) do
            if child:IsA("ScrollingFrame") and child.Position.Y.Offset >= 80 then
                songList = child
                break
            end
        end
    end

    local ICON_LEFT = "7733717651"
    local ICON_RIGHT = "7733717755"
    local function findButtonByImage(root, fragment)
        if not root then return nil end
        for _, descendant in ipairs(root:GetDescendants()) do
            if descendant:IsA("ImageLabel") and string.find(descendant.Image or "", fragment, 1, true) then
                local node = descendant.Parent
                while node and node ~= root.Parent do
                    if node:IsA("TextButton") then return node end
                    if node == root then break end
                    node = node.Parent
                end
            end
        end
        return nil
    end

    local bpmDown = findButtonByImage(playerCard, ICON_LEFT)
    local bpmUp = findButtonByImage(playerCard, ICON_RIGHT)
    local bpmBox
    if playerCard then
        for _, descendant in ipairs(playerCard:GetDescendants()) do
            if descendant:IsA("TextBox") and descendant.Size.X.Offset >= 45 and descendant.Size.X.Offset <= 60 then
                bpmBox = descendant
                break
            end
        end
    end

    -- ---------------------------------------------------------
    -- Queue / Up Next
    -- ---------------------------------------------------------

    local queueSection = section("QUEUE • UP NEXT", 100)
    local queueText = label(queueSection, "Queue empty", UDim2.new(1, -24, 0, 28), COLORS.Sub, false)
    queueText.Position = UDim2.fromOffset(12, 25)
    queueText.TextSize = 8
    queueText.TextWrapped = true

    local addQueueButton = button(queueSection, "ADD SELECTED", UDim2.fromOffset(96, 28))
    addQueueButton.Position = UDim2.fromOffset(12, 62)
    local playNextButton = button(queueSection, "PLAY NEXT", UDim2.fromOffset(84, 28))
    playNextButton.Position = UDim2.fromOffset(114, 62)
    local clearQueueButton = button(queueSection, "CLEAR", UDim2.fromOffset(58, 28))
    clearQueueButton.Position = UDim2.fromOffset(204, 62)

    local function refreshQueue()
        if #data.Queue == 0 then
            queueText.Text = "Queue empty"
            return
        end
        local shown = {}
        for index = 1, math.min(3, #data.Queue) do
            table.insert(shown, tostring(index) .. ". " .. nameFor(data.Queue[index]))
        end
        queueText.Text = table.concat(shown, "   •   ") .. (#data.Queue > 3 and ("   +" .. tostring(#data.Queue - 3)) or "")
    end

    local function addToQueue(id)
        if not id or not entryById(id) then return false end
        table.insert(data.Queue, id)
        refreshQueue()
        saveSoon()
        return true
    end

    local function startSong(id, stopFirst)
        if not id or not entryById(id) then return false end
        if stopFirst and type(API.Stop) == "function" then pcall(API.Stop, API) end
        local ok = pcall(API.SelectSong, API, id)
        if not ok then return false end
        task.defer(function()
            pcall(API.Play, API)
        end)
        return true
    end

    local function takeQueue(autoplayAfterFinish)
        local id = table.remove(data.Queue, 1)
        refreshQueue()
        saveSoon()
        if not id then return false end
        return startSong(id, not autoplayAfterFinish)
    end

    addQueueButton.Activated:Connect(function()
        addToQueue(pickedId(snapshot()))
    end)
    playNextButton.Activated:Connect(function()
        takeQueue(false)
    end)
    clearQueueButton.Activated:Connect(function()
        table.clear(data.Queue)
        refreshQueue()
        saveSoon()
    end)

    -- ---------------------------------------------------------
    -- Playlists
    -- ---------------------------------------------------------

    local playlistSection = section("PLAYLISTS", 126)
    local playlistIndex = 1
    local previousPlaylist = button(playlistSection, "‹", UDim2.fromOffset(28, 28))
    previousPlaylist.Position = UDim2.fromOffset(12, 27)
    previousPlaylist.TextSize = 14

    local playlistName = round(edge(make("TextBox", {
        Position = UDim2.fromOffset(46, 27),
        Size = UDim2.fromOffset(218, 28),
        BackgroundColor3 = COLORS.Raised,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Text = "My Playlist",
        TextColor3 = COLORS.Text,
        TextSize = 9,
        Font = Enum.Font.BuilderSansExtraBold,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 234,
    }, playlistSection), 0.65, 1), 9)

    local nextPlaylist = button(playlistSection, "›", UDim2.fromOffset(28, 28))
    nextPlaylist.Position = UDim2.fromOffset(270, 27)
    nextPlaylist.TextSize = 14

    local playlistMeta = label(playlistSection, "0 songs", UDim2.new(1, -24, 0, 16), COLORS.Muted, false)
    playlistMeta.Position = UDim2.fromOffset(12, 58)
    playlistMeta.TextSize = 7

    local newPlaylist = button(playlistSection, "NEW", UDim2.fromOffset(54, 28))
    newPlaylist.Position = UDim2.fromOffset(12, 86)
    local addPlaylist = button(playlistSection, "ADD", UDim2.fromOffset(54, 28))
    addPlaylist.Position = UDim2.fromOffset(72, 86)
    local removePlaylist = button(playlistSection, "REMOVE", UDim2.fromOffset(66, 28))
    removePlaylist.Position = UDim2.fromOffset(132, 86)
    local playPlaylist = button(playlistSection, "PLAY", UDim2.fromOffset(54, 28))
    playPlaylist.Position = UDim2.fromOffset(204, 86)

    local function activePlaylistName()
        playlistIndex = math.clamp(playlistIndex, 1, math.max(1, #data.PlaylistOrder))
        return data.PlaylistOrder[playlistIndex]
    end

    local function activePlaylist()
        local name = activePlaylistName()
        data.Playlists[name] = data.Playlists[name] or {}
        return data.Playlists[name]
    end

    local function refreshPlaylist()
        local name = activePlaylistName()
        local list = activePlaylist()
        playlistName.Text = name or "My Playlist"
        local first = list[1] and nameFor(list[1]) or "Empty"
        playlistMeta.Text = tostring(#list) .. " songs  •  " .. first
    end

    previousPlaylist.Activated:Connect(function()
        playlistIndex -= 1
        if playlistIndex < 1 then playlistIndex = #data.PlaylistOrder end
        refreshPlaylist()
    end)
    nextPlaylist.Activated:Connect(function()
        playlistIndex += 1
        if playlistIndex > #data.PlaylistOrder then playlistIndex = 1 end
        refreshPlaylist()
    end)

    playlistName.FocusLost:Connect(function()
        local oldName = activePlaylistName()
        local newName = tostring(playlistName.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if newName == "" or newName == oldName or data.Playlists[newName] then
            refreshPlaylist()
            return
        end
        data.Playlists[newName] = data.Playlists[oldName] or {}
        data.Playlists[oldName] = nil
        data.PlaylistOrder[playlistIndex] = newName
        refreshPlaylist()
        saveSoon()
    end)

    newPlaylist.Activated:Connect(function()
        local number = 1
        local name
        repeat
            name = "Playlist " .. tostring(number)
            number += 1
        until not data.Playlists[name]
        data.Playlists[name] = {}
        table.insert(data.PlaylistOrder, name)
        playlistIndex = #data.PlaylistOrder
        refreshPlaylist()
        saveSoon()
    end)

    addPlaylist.Activated:Connect(function()
        local id = pickedId(snapshot())
        if not id then return end
        local list = activePlaylist()
        if not table.find(list, id) then table.insert(list, id) end
        refreshPlaylist()
        saveSoon()
    end)

    removePlaylist.Activated:Connect(function()
        local id = pickedId(snapshot())
        if not id then return end
        local list = activePlaylist()
        for index = #list, 1, -1 do
            if list[index] == id then table.remove(list, index) end
        end
        refreshPlaylist()
        saveSoon()
    end)

    playPlaylist.Activated:Connect(function()
        local list = activePlaylist()
        if #list == 0 then return end
        table.clear(data.Queue)
        for _, id in ipairs(list) do table.insert(data.Queue, id) end
        local first = table.remove(data.Queue, 1)
        refreshQueue()
        saveSoon()
        startSong(first, true)
    end)

    -- ---------------------------------------------------------
    -- Library sort / shuffle / stats / difficulty
    -- ---------------------------------------------------------

    local librarySection = section("LIBRARY • SORT • STATS", 132)
    local SORTS = {"DEFAULT", "A–Z", "RECENTLY ADDED", "BPM", "DURATION", "ARTIST", "MOST PLAYED"}
    local SHUFFLES = {"OFF", "ALL", "FAVORITES", "SIMILAR"}

    local sortButton = button(librarySection, "SORT: " .. tostring(data.Settings.Sort), UDim2.fromOffset(142, 28))
    sortButton.Position = UDim2.fromOffset(12, 27)
    local shuffleButton = button(librarySection, "SHUFFLE: " .. tostring(data.Settings.Shuffle), UDim2.fromOffset(142, 28))
    shuffleButton.Position = UDim2.fromOffset(160, 27)

    local selectedStats = label(librarySection, "Select a song", UDim2.new(1, -24, 0, 18), COLORS.Sub, true)
    selectedStats.Position = UDim2.fromOffset(12, 61)
    selectedStats.TextSize = 8

    local recentStats = label(librarySection, "RECENT • —", UDim2.new(1, -24, 0, 18), COLORS.Muted, false)
    recentStats.Position = UDim2.fromOffset(12, 82)
    recentStats.TextSize = 7

    local playStats = label(librarySection, "MOST PLAYED • —", UDim2.new(1, -24, 0, 18), COLORS.Muted, false)
    playStats.Position = UDim2.fromOffset(12, 102)
    playStats.TextSize = 7

    local registryOrder = {}
    local function refreshRegistryOrder()
        table.clear(registryOrder)
        for index, entry in ipairs(registry()) do registryOrder[entry.Id] = index end
    end
    refreshRegistryOrder()

    local function cycleValue(values, current)
        local index = table.find(values, current) or 1
        index = index % #values + 1
        return values[index]
    end

    sortButton.Activated:Connect(function()
        data.Settings.Sort = cycleValue(SORTS, data.Settings.Sort)
        sortButton.Text = "SORT: " .. data.Settings.Sort
        saveSoon()
    end)

    shuffleButton.Activated:Connect(function()
        data.Settings.Shuffle = cycleValue(SHUFFLES, data.Settings.Shuffle)
        shuffleButton.Text = "SHUFFLE: " .. data.Settings.Shuffle
        if type(API.SetShuffle) == "function" then pcall(API.SetShuffle, API, false) end
        saveSoon()
    end)

    local function sortedIds()
        local entries = {}
        for _, entry in ipairs(registry()) do table.insert(entries, entry) end
        local mode = data.Settings.Sort
        table.sort(entries, function(a, b)
            if mode == "A–Z" then
                return string.lower(tostring(a.Name or a.Id)) < string.lower(tostring(b.Name or b.Id))
            elseif mode == "RECENTLY ADDED" then
                return (registryOrder[a.Id] or 0) > (registryOrder[b.Id] or 0)
            elseif mode == "BPM" then
                local av, bv = tonumber(a.BPM) or 0, tonumber(b.BPM) or 0
                if av == bv then return tostring(a.Name or "") < tostring(b.Name or "") end
                return av < bv
            elseif mode == "DURATION" then
                local av = tonumber(data.Durations[a.Id]) or math.huge
                local bv = tonumber(data.Durations[b.Id]) or math.huge
                if av == bv then return tostring(a.Name or "") < tostring(b.Name or "") end
                return av < bv
            elseif mode == "ARTIST" then
                local av, bv = string.lower(tostring(a.Artist or "")), string.lower(tostring(b.Artist or ""))
                if av == bv then return tostring(a.Name or "") < tostring(b.Name or "") end
                return av < bv
            elseif mode == "MOST PLAYED" then
                local av, bv = tonumber(data.PlayCounts[a.Id]) or 0, tonumber(data.PlayCounts[b.Id]) or 0
                if av == bv then return tostring(a.Name or "") < tostring(b.Name or "") end
                return av > bv
            end
            return (registryOrder[a.Id] or 0) < (registryOrder[b.Id] or 0)
        end)
        local ids = {}
        for index, entry in ipairs(entries) do ids[entry.Id] = index end
        return ids
    end

    local NEW_IDS = { ["la-maritza-sylvie-vartan"] = true }
    local importedIds = {}

    local function cardEntry(card)
        for _, descendant in ipairs(card:GetDescendants()) do
            if descendant:IsA("TextLabel") then
                for _, entry in ipairs(registry()) do
                    if descendant.Text == tostring(entry.Name or "") then return entry end
                end
            end
        end
        return nil
    end

    local function decorateCards()
        if not songList or not songList.Parent then return end
        local orders = sortedIds()
        local snap = snapshot()
        local selected = pickedId(snap)
        for _, child in ipairs(songList:GetChildren()) do
            if child:IsA("TextButton") then
                local entry = cardEntry(child)
                if entry then
                    child.LayoutOrder = orders[entry.Id] or 9999

                    local badge = child:FindFirstChild("Wave2Badge")
                    if not badge then
                        badge = label(child, "", UDim2.fromOffset(40, 10), COLORS.Muted, true)
                        badge.Name = "Wave2Badge"
                        badge.Position = UDim2.fromOffset(68, 49)
                        badge.TextSize = 7
                        badge.ZIndex = child.ZIndex + 3
                    end
                    local badgeText = ""
                    if importedIds[entry.Id] or entry.Wave2Imported then
                        badgeText = "MIDI"
                    elseif NEW_IDS[entry.Id] then
                        badgeText = "NEW"
                    elseif type(API.IsFavorite) == "function" then
                        local ok, favorite = pcall(API.IsFavorite, API, entry.Id)
                        if ok and favorite then badgeText = "♥ FAVORITE" end
                    end
                    badge.Text = badgeText
                    badge.Visible = badgeText ~= ""

                    local diff = child:FindFirstChild("Wave2Difficulty")
                    if not diff then
                        diff = label(child, "", UDim2.fromOffset(58, 10), COLORS.Muted, true)
                        diff.Name = "Wave2Difficulty"
                        diff.Position = UDim2.fromOffset(112, 49)
                        diff.TextSize = 7
                        diff.ZIndex = child.ZIndex + 3
                    end
                    diff.Text = difficulty(entry)
                    diff.Visible = selected == entry.Id
                end
            end
        end
    end

    local function refreshStats()
        local snap = snapshot()
        local id = pickedId(snap)
        local entry = entryById(id)
        if entry then
            selectedStats.Text = string.format("%s  •  %s  •  %d BPM", tostring(entry.Name or entry.Id), difficulty(entry), tonumber(entry.BPM) or 120)
        else
            selectedStats.Text = "Select a song"
        end
        recentStats.Text = "RECENT • " .. (data.Recent[1] and nameFor(data.Recent[1]) or "—")
        local topId, topCount
        for songId, count in pairs(data.PlayCounts) do
            count = tonumber(count) or 0
            if not topCount or count > topCount then topId, topCount = songId, count end
        end
        playStats.Text = topId and ("MOST PLAYED • " .. nameFor(topId) .. "  ×" .. tostring(topCount)) or "MOST PLAYED • —"
    end

    -- ---------------------------------------------------------
    -- Playback feel: BPM hold/edit, output profile, countdown
    -- ---------------------------------------------------------

    local playbackSection = section("PLAYBACK FEEL", 124)
    local OUTPUTS = {"SOFT", "NORMAL", "STRONG"}
    local outputButton = button(playbackSection, "TOUCH: " .. tostring(data.Settings.Output), UDim2.fromOffset(132, 28))
    outputButton.Position = UDim2.fromOffset(12, 27)
    local countdownButton = button(playbackSection, data.Settings.Countdown == 3 and "COUNTDOWN: 3s" or "COUNTDOWN: OFF", UDim2.fromOffset(132, 28))
    countdownButton.Position = UDim2.fromOffset(150, 27)

    local bpmHint = label(playbackSection, "Hold the main BPM arrows to accelerate. Double-click the BPM number to select it for typing.", UDim2.new(1, -24, 0, 34), COLORS.Sub, false)
    bpmHint.Position = UDim2.fromOffset(12, 61)
    bpmHint.TextSize = 8
    bpmHint.TextWrapped = true

    local outputHint = label(playbackSection, "Touch profile is applied when the active piano output backend supports it.", UDim2.new(1, -24, 0, 18), COLORS.Muted, false)
    outputHint.Position = UDim2.fromOffset(12, 97)
    outputHint.TextSize = 7

    local function applyOutputProfile()
        local profile = data.Settings.Output
        gui:SetAttribute("VeloraOutputProfile", profile)
        if API.State then API.State.OutputProfile = profile end
        if type(API.SetOutputProfile) == "function" then
            pcall(API.SetOutputProfile, API, profile)
            outputHint.Text = "Touch profile active on the current output backend."
        else
            outputHint.Text = "Touch profile saved. Current keyboard backend has no velocity API."
        end
    end

    outputButton.Activated:Connect(function()
        data.Settings.Output = cycleValue(OUTPUTS, data.Settings.Output)
        outputButton.Text = "TOUCH: " .. data.Settings.Output
        applyOutputProfile()
        saveSoon()
    end)

    countdownButton.Activated:Connect(function()
        data.Settings.Countdown = data.Settings.Countdown == 3 and 0 or 3
        countdownButton.Text = data.Settings.Countdown == 3 and "COUNTDOWN: 3s" or "COUNTDOWN: OFF"
        saveSoon()
    end)

    local bpmHoldToken = 0
    local function bindMainBpmHold(control, delta)
        if not control or control:GetAttribute("VeloraWave2Hold") then return end
        control:SetAttribute("VeloraWave2Hold", true)
        control.MouseButton1Down:Connect(function()
            bpmHoldToken += 1
            local token = bpmHoldToken
            task.delay(0.36, function()
                local interval = 0.105
                while token == bpmHoldToken and control.Parent do
                    local snap = snapshot()
                    if tonumber(snap.BPM) then pcall(API.SetBPM, API, snap.BPM + delta) end
                    task.wait(interval)
                    interval = math.max(0.045, interval * 0.90)
                end
            end)
        end)
        local function stop() bpmHoldToken += 1 end
        control.MouseButton1Up:Connect(stop)
        control.MouseLeave:Connect(stop)
    end
    bindMainBpmHold(bpmDown, -1)
    bindMainBpmHold(bpmUp, 1)

    if bpmBox then
        local lastTap = 0
        bpmBox.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            local now = os.clock()
            if now - lastTap <= 0.34 then
                bpmBox:CaptureFocus()
                bpmBox.CursorPosition = #bpmBox.Text + 1
                bpmBox.SelectionStart = 1
            end
            lastTap = now
        end)
    end

    local countdownOverlay
    if playerCard then
        countdownOverlay = round(edge(make("TextLabel", {
            Name = "Wave2Countdown",
            Visible = false,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.48),
            Size = UDim2.fromOffset(82, 82),
            BackgroundColor3 = COLORS.Ink,
            BackgroundTransparency = 0.10,
            BorderSizePixel = 0,
            Text = "3",
            TextColor3 = COLORS.Text,
            TextSize = 34,
            Font = Enum.Font.BuilderSansExtraBold,
            ZIndex = 500,
        }, playerCard), 0.28, 1.2, COLORS.Accent), 24)
    end

    local rawPlay = API.Play
    local rawStop = API.Stop
    local countdownToken = 0
    local countdownActive = false

    local function hideCountdown()
        countdownActive = false
        if countdownOverlay then countdownOverlay.Visible = false end
    end

    if type(rawPlay) == "function" then
        API.Play = function(self, ...)
            local snap = snapshot()
            if data.Settings.Countdown ~= 3 or snap.Playing or snap.Paused then
                return rawPlay(self, ...)
            end
            if countdownActive then
                countdownToken += 1
                hideCountdown()
                return false, "countdown cancelled"
            end

            countdownToken += 1
            local token = countdownToken
            local startId = pickedId(snap)
            countdownActive = true
            task.spawn(function()
                for number = 3, 1, -1 do
                    if token ~= countdownToken or pickedId(snapshot()) ~= startId then hideCountdown(); return end
                    if countdownOverlay then
                        countdownOverlay.Text = tostring(number)
                        countdownOverlay.TextTransparency = 0
                        countdownOverlay.Visible = true
                        TweenService:Create(countdownOverlay, TweenInfo.new(0.72), {TextTransparency = 0.22}):Play()
                    end
                    task.wait(1)
                end
                if token ~= countdownToken or pickedId(snapshot()) ~= startId then hideCountdown(); return end
                hideCountdown()
                rawPlay(self, ...)
            end)
            return true, "countdown"
        end
    end

    if type(rawStop) == "function" then
        API.Stop = function(self, ...)
            countdownToken += 1
            hideCountdown()
            return rawStop(self, ...)
        end
    end

    -- ---------------------------------------------------------
    -- Seek drag glow
    -- ---------------------------------------------------------

    local seekHit
    local progressFrame
    if playerCard then
        for _, child in ipairs(playerCard:GetChildren()) do
            if child:IsA("TextButton") and child.Text == "" and child.Size.X.Offset >= 195 and child.Size.X.Offset <= 215 and child.Size.Y.Offset >= 20 and child.Size.Y.Offset <= 28 then
                seekHit = child
            elseif child:IsA("Frame") and child.Size.X.Offset >= 195 and child.Size.X.Offset <= 215 and child.Size.Y.Offset >= 6 and child.Size.Y.Offset <= 10 then
                progressFrame = child
            end
        end
    end

    local seekGlow
    if progressFrame then
        seekGlow = make("UIStroke", {
            Name = "Wave2SeekDragGlow",
            Color = COLORS.Accent,
            Transparency = 1,
            Thickness = 1.5,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }, progressFrame)
    end
    if seekHit and seekGlow then
        seekHit.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                TweenService:Create(seekGlow, TweenInfo.new(0.10), {Transparency = 0.18, Thickness = 2.0}):Play()
            end
        end)
        seekHit.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                TweenService:Create(seekGlow, TweenInfo.new(0.28), {Transparency = 1, Thickness = 1.5}):Play()
            end
        end)
    end

    -- ---------------------------------------------------------
    -- Appearance / update / performance
    -- ---------------------------------------------------------

    local appearanceSection = section("APPEARANCE • PERFORMANCE", 190)
    local performanceButton = button(appearanceSection, data.Settings.Performance and "PERFORMANCE: ON" or "PERFORMANCE: OFF", UDim2.fromOffset(142, 28))
    performanceButton.Position = UDim2.fromOffset(12, 27)
    local updateText = label(appearanceSection, "LAB " .. VERSION, UDim2.fromOffset(140, 28), COLORS.Muted, true)
    updateText.Position = UDim2.fromOffset(162, 27)
    updateText.TextXAlignment = Enum.TextXAlignment.Right
    updateText.TextSize = 7

    local sliderConnections = {}
    local function makeSliderRow(parent, titleText, y, initial, onChanged)
        local title = label(parent, titleText, UDim2.fromOffset(92, 18), COLORS.Sub, true)
        title.Position = UDim2.fromOffset(12, y)
        title.TextSize = 8

        local valueLabel = label(parent, tostring(math.floor(initial * 100 + 0.5)) .. "%", UDim2.fromOffset(38, 18), COLORS.Muted, true)
        valueLabel.Position = UDim2.new(1, -50, 0, y)
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.TextSize = 7

        local bar = round(make("Frame", {
            Position = UDim2.fromOffset(104, y + 6),
            Size = UDim2.new(1, -166, 0, 6),
            BackgroundColor3 = Color3.fromRGB(52, 33, 37),
            BorderSizePixel = 0,
            ZIndex = 234,
        }, parent), 3)
        local fill = round(make("Frame", {
            Size = UDim2.new(initial, 0, 1, 0),
            BackgroundColor3 = COLORS.Accent,
            BorderSizePixel = 0,
            ZIndex = 235,
        }, bar), 3)
        local knob = round(make("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(initial, 0, 0.5, 0),
            Size = UDim2.fromOffset(10, 10),
            BackgroundColor3 = COLORS.Text,
            BorderSizePixel = 0,
            ZIndex = 236,
        }, bar), 6)
        local hit = make("TextButton", {
            Position = UDim2.new(0, -8, 0, -8),
            Size = UDim2.new(1, 16, 1, 16),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "",
            ZIndex = 237,
        }, bar)

        local dragging = false
        local value = initial
        local function setFromX(x)
            local ratio = math.clamp((x - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X), 0, 1)
            value = ratio
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            knob.Position = UDim2.new(ratio, 0, 0.5, 0)
            valueLabel.Text = tostring(math.floor(ratio * 100 + 0.5)) .. "%"
            onChanged(ratio)
        end
        hit.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                setFromX(input.Position.X)
            end
        end)
        table.insert(sliderConnections, UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                setFromX(input.Position.X)
            end
        end))
        table.insert(sliderConnections, UserInputService.InputEnded:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                dragging = false
                saveSoon()
            end
        end))
        return function(newValue)
            value = math.clamp(newValue, 0, 1)
            fill.Size = UDim2.new(value, 0, 1, 0)
            knob.Position = UDim2.new(value, 0, 0.5, 0)
            valueLabel.Text = tostring(math.floor(value * 100 + 0.5)) .. "%"
        end
    end

    local panelBase = {}
    for _, panel in ipairs({nav, browser, playerCard}) do
        if panel and panel:IsA("GuiObject") then panelBase[panel] = panel.BackgroundTransparency end
    end
    local shellBase = {}
    for _, panel in ipairs({window, header}) do
        if panel and panel:IsA("GuiObject") then shellBase[panel] = panel.BackgroundTransparency end
    end

    local visualSection
    for _, descendant in ipairs(drawer:GetDescendants()) do
        if descendant:IsA("TextLabel") and descendant.Text == "LIVE PIANO • CURRENT CHORD" then
            visualSection = descendant.Parent
            break
        end
    end

    local function applyTheme()
        local glass = math.clamp(tonumber(data.Settings.Glass) or 0.5, 0, 1)
        local transparency = math.clamp(tonumber(data.Settings.Transparency) or 0.5, 0, 1)
        for panel, base in pairs(panelBase) do
            if panel.Parent then panel.BackgroundTransparency = math.clamp(base + (0.5 - glass) * 0.16, 0, 0.72) end
        end
        for panel, base in pairs(shellBase) do
            if panel.Parent then panel.BackgroundTransparency = math.clamp(base + (transparency - 0.5) * 0.16, 0, 0.72) end
        end
        if visualSection then visualSection.Visible = not data.Settings.Performance end
    end

    makeSliderRow(appearanceSection, "GLASS", 68, tonumber(data.Settings.Glass) or 0.5, function(value)
        data.Settings.Glass = value
        applyTheme()
    end)
    makeSliderRow(appearanceSection, "GLOW", 101, tonumber(data.Settings.Glow) or 0.72, function(value)
        data.Settings.Glow = value
    end)
    makeSliderRow(appearanceSection, "TRANSPARENCY", 134, tonumber(data.Settings.Transparency) or 0.5, function(value)
        data.Settings.Transparency = value
        applyTheme()
    end)

    local performanceHint = label(appearanceSection, "Performance mode disables breathing glow, live visualizer and extra transitions.", UDim2.new(1, -24, 0, 22), COLORS.Muted, false)
    performanceHint.Position = UDim2.fromOffset(12, 161)
    performanceHint.TextSize = 7
    performanceHint.TextWrapped = true

    performanceButton.Activated:Connect(function()
        data.Settings.Performance = not data.Settings.Performance
        performanceButton.Text = data.Settings.Performance and "PERFORMANCE: ON" or "PERFORMANCE: OFF"
        applyTheme()
        saveSoon()
    end)

    -- ---------------------------------------------------------
    -- Admin/import scaffold
    -- ---------------------------------------------------------

    local adminSection = section("SONG IMPORT • ADMIN SCAFFOLD", 118)
    local adminStatus = label(adminSection, "Runtime import API ready. Nothing is uploaded or persisted automatically.", UDim2.new(1, -24, 0, 34), COLORS.Sub, false)
    adminStatus.Position = UDim2.fromOffset(12, 25)
    adminStatus.TextSize = 8
    adminStatus.TextWrapped = true
    local adminButton = button(adminSection, "CHECK CURRENT", UDim2.fromOffset(106, 28))
    adminButton.Position = UDim2.fromOffset(12, 72)
    local adminApiLabel = label(adminSection, "API.UpgradeWave2.Admin", UDim2.fromOffset(160, 28), COLORS.Muted, true)
    adminApiLabel.Position = UDim2.fromOffset(130, 72)
    adminApiLabel.TextSize = 7

    local Admin = {}
    function Admin.Validate(entry, songData)
        if type(entry) ~= "table" then return false, "entry table required" end
        if type(entry.Id) ~= "string" or entry.Id == "" then return false, "entry.Id required" end
        if type(entry.Name) ~= "string" or entry.Name == "" then return false, "entry.Name required" end
        if tonumber(entry.BPM) == nil then return false, "entry.BPM required" end
        if songData ~= nil and type(songData) ~= "table" then return false, "songData must be a table" end
        return true
    end
    function Admin.AddRuntimeSong(entry, songData)
        local ok, reason = Admin.Validate(entry, songData)
        if not ok then return false, reason end
        if type(API.AddRuntimeSong) ~= "function" then return false, "runtime song API unavailable" end
        entry.Wave2Imported = true
        local added, result, detail = pcall(API.AddRuntimeSong, API, entry, songData)
        if not added then return false, result end
        if result == false then return false, detail end
        importedIds[entry.Id] = true
        refreshRegistryOrder()
        task.defer(decorateCards)
        return true
    end

    adminButton.Activated:Connect(function()
        local entry = entryById(pickedId(snapshot()))
        if not entry then
            adminStatus.Text = "Select a song first. Runtime import API is ready for future admin tooling."
            return
        end
        local ok, reason = Admin.Validate(entry)
        adminStatus.Text = ok and ("Metadata valid: " .. tostring(entry.Name) .. " • ready for admin pipeline") or tostring(reason)
    end)

    -- ---------------------------------------------------------
    -- Empty state and update indicator
    -- ---------------------------------------------------------

    local emptyLabel
    if browser then
        emptyLabel = label(browser, "No songs found\nTry another title, artist, or category", UDim2.new(1, -40, 0, 54), COLORS.Muted, true)
        emptyLabel.Name = "Wave2EmptyState"
        emptyLabel.Position = UDim2.fromOffset(20, 150)
        emptyLabel.TextSize = 10
        emptyLabel.TextWrapped = true
        emptyLabel.TextXAlignment = Enum.TextXAlignment.Center
        emptyLabel.Visible = false
        emptyLabel.ZIndex = 50
    end

    local updateDot = round(make("Frame", {
        Name = "Wave2UpdateDot",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, -3, 0, 3),
        Size = UDim2.fromOffset(7, 7),
        BackgroundColor3 = COLORS.Accent,
        BorderSizePixel = 0,
        Visible = data.SeenVersion ~= VERSION,
        ZIndex = labButton.ZIndex + 5,
    }, labButton), 4)

    labButton.Activated:Connect(function()
        if updateDot.Parent and updateDot.Visible then
            updateDot.Visible = false
            data.SeenVersion = VERSION
            updateText.Text = "LAB " .. VERSION .. " • CURRENT"
            saveSoon()
        end
    end)

    if data.SeenVersion ~= VERSION then
        updateText.Text = "LAB " .. VERSION .. " • NEW"
    else
        updateText.Text = "LAB " .. VERSION .. " • CURRENT"
    end

    -- ---------------------------------------------------------
    -- Helpers for shuffle and end-of-song continuation
    -- ---------------------------------------------------------

    local function randomFromPool(pool, avoid)
        if #pool == 0 then return nil end
        local candidates = {}
        for _, id in ipairs(pool) do
            if id ~= avoid then table.insert(candidates, id) end
        end
        if #candidates == 0 then candidates = pool end
        return candidates[math.random(1, #candidates)]
    end

    local function shuffleChoice(mode, snap)
        if mode == "OFF" then return nil end
        local songs = registry()
        local pool = {}
        local avoid = currentId(snap)
        local current = entryById(avoid)
        if mode == "ALL" then
            for _, entry in ipairs(songs) do table.insert(pool, entry.Id) end
        elseif mode == "FAVORITES" then
            for _, entry in ipairs(songs) do
                local ok, favorite = pcall(API.IsFavorite, API, entry.Id)
                if ok and favorite then table.insert(pool, entry.Id) end
            end
        elseif mode == "SIMILAR" and current then
            local wanted = {}
            for _, category in ipairs(current.Categories or {}) do
                if category ~= "Famous" and category ~= "Complete" and category ~= "Piano" then wanted[category] = true end
            end
            for _, entry in ipairs(songs) do
                if entry.Id ~= current.Id then
                    for _, category in ipairs(entry.Categories or {}) do
                        if wanted[category] then table.insert(pool, entry.Id); break end
                    end
                end
            end
        end
        return randomFromPool(pool, avoid)
    end

    -- ---------------------------------------------------------
    -- Transition polish and startup micro-animation
    -- ---------------------------------------------------------

    local function animateNowPlaying(snap)
        if data.Settings.Performance or not playerCard then return end
        local entry = snap.Entry
        if not entry then return end
        for _, descendant in ipairs(playerCard:GetDescendants()) do
            if descendant:IsA("TextLabel") and (descendant.Text == tostring(entry.Name or "") or descendant.Text == tostring(entry.Artist or "")) then
                descendant.TextTransparency = math.max(descendant.TextTransparency, 0.34)
                TweenService:Create(descendant, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
            end
        end
    end

    if not data.Settings.Performance then
        local veil = make("Frame", {
            Name = "Wave2StartupVeil",
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.fromRGB(4, 3, 4),
            BackgroundTransparency = 0.62,
            BorderSizePixel = 0,
            ZIndex = 900,
        }, window)
        round(veil, 20)
        TweenService:Create(veil, TweenInfo.new(0.42, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
        task.delay(0.46, function() if veil.Parent then veil:Destroy() end end)
    end

    -- ---------------------------------------------------------
    -- State wiring
    -- ---------------------------------------------------------

    local connections = {}
    local destroyed = false
    local lastDecorate = 0

    local function connect(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(connections, connection)
        return connection
    end

    local function syncRecent(id)
        if not id then return end
        insertFrontUnique(data.Recent, id, 20)
        if API.State and type(API.State.Recent) == "table" then
            table.clear(API.State.Recent)
            for _, recentId in ipairs(data.Recent) do table.insert(API.State.Recent, recentId) end
        end
        saveSoon()
    end

    if API.Changed then
        connect(API.Changed, function(reason)
            local snap = snapshot()
            local id = pickedId(snap)

            if id and (reason == "selection" or reason == "pending-selection" or reason == "playing" or reason == "pending-ready") then
                syncRecent(id)
            end

            local activeId = currentId(snap)
            if activeId and tonumber(snap.Duration) and snap.Duration > 0 then
                data.Durations[activeId] = snap.Duration
            end

            if reason == "playing" and activeId then
                data.PlayCounts[activeId] = (tonumber(data.PlayCounts[activeId]) or 0) + 1
                saveSoon()
            end

            if reason == "selection" or reason == "pending-ready" or reason == "playing" then
                task.defer(function() animateNowPlaying(snapshot()) end)
            end

            if reason == "finished" then
                local finishedSnap = snap
                if #data.Queue > 0 then
                    task.defer(function() takeQueue(true) end)
                elseif not finishedSnap.Loop then
                    local nextId = shuffleChoice(data.Settings.Shuffle, finishedSnap)
                    if nextId then task.defer(function() startSong(nextId, false) end) end
                end
            end

            refreshQueue()
            refreshPlaylist()
            refreshStats()
            task.defer(decorateCards)
        end)
    end

    if searchBox then
        connect(searchBox:GetPropertyChangedSignal("Text"), function()
            task.defer(decorateCards)
        end)
    end

    connect(RunService.Heartbeat, function()
        if destroyed then return end
        local now = os.clock()
        local interval = data.Settings.Performance and 1.15 or 0.42
        if now - lastDecorate < interval then return end
        lastDecorate = now

        decorateCards()
        refreshStats()

        if emptyLabel and songList and songList.Parent then
            local count = 0
            for _, child in ipairs(songList:GetChildren()) do
                if child:IsA("TextButton") and child.Visible then count += 1 end
            end
            emptyLabel.Visible = count == 0
        end
    end)

    connect(RunService.RenderStepped, function()
        if destroyed then return end
        local inner = playerCard and playerCard:FindFirstChild("VeloraLabAmbientGlowInner")
        local outer = playerCard and playerCard:FindFirstChild("VeloraLabAmbientGlowOuter")
        local glow = math.clamp(tonumber(data.Settings.Glow) or 0.72, 0, 1)
        local perf = data.Settings.Performance
        if inner and inner:IsA("UIStroke") then
            inner.Enabled = not perf and glow > 0.02
        end
        if outer and outer:IsA("UIStroke") then
            outer.Enabled = not perf and glow > 0.02
        end
        if not perf and glow > 0.02 then
            local snap = snapshot()
            local breath = (math.sin(os.clock() * 2.8) + 1) * 0.5
            if inner and inner:IsA("UIStroke") then
                local baseTransparency = snap.Playing and not snap.Paused and (0.44 - breath * 0.13) or (snap.Playing and 0.66 or 0.92)
                local baseThickness = snap.Playing and not snap.Paused and (1.35 + breath * 0.25) or (snap.Playing and 1.25 or 1.0)
                inner.Transparency = 1 - (1 - math.clamp(baseTransparency, 0.18, 0.97)) * glow
                inner.Thickness = 1 + (baseThickness - 1) * glow
            end
            if outer and outer:IsA("UIStroke") then
                local baseTransparency = snap.Playing and not snap.Paused and (0.80 - breath * 0.08) or (snap.Playing and 0.86 or 0.97)
                local baseThickness = snap.Playing and not snap.Paused and (2.15 + breath * 0.35) or (snap.Playing and 2.0 or 1.75)
                outer.Transparency = 1 - (1 - math.clamp(baseTransparency, 0.55, 0.99)) * glow
                outer.Thickness = 1 + (baseThickness - 1) * glow
            end
        end
    end)

    local function cleanup()
        if destroyed then return end
        destroyed = true
        countdownToken += 1
        hideCountdown()
        if API.Play == nil or API.Play ~= rawPlay then API.Play = rawPlay end
        if API.Stop == nil or API.Stop ~= rawStop then API.Stop = rawStop end
        for _, connection in ipairs(connections) do pcall(function() connection:Disconnect() end) end
        for _, connection in ipairs(sliderConnections) do pcall(function() connection:Disconnect() end) end
        table.clear(connections)
        table.clear(sliderConnections)
    end

    connect(gui.AncestryChanged, function(_, parent)
        if parent == nil then cleanup() end
    end)

    -- Public Wave 2 API for future admin tooling and tests.
    API.UpgradeWave2 = {
        Version = VERSION,
        Data = data,
        Admin = Admin,
        Queue = {
            Add = addToQueue,
            PlayNext = function() return takeQueue(false) end,
            Clear = function() table.clear(data.Queue); refreshQueue(); saveSoon() end,
        },
        SetPerformance = function(enabled)
            data.Settings.Performance = enabled == true
            performanceButton.Text = data.Settings.Performance and "PERFORMANCE: ON" or "PERFORMANCE: OFF"
            applyTheme()
            saveSoon()
        end,
        SetShuffleMode = function(mode)
            if table.find(SHUFFLES, mode) then
                data.Settings.Shuffle = mode
                shuffleButton.Text = "SHUFFLE: " .. mode
                saveSoon()
                return true
            end
            return false
        end,
        Save = saveSoon,
    }

    applyOutputProfile()
    applyTheme()
    refreshQueue()
    refreshPlaylist()
    refreshStats()
    decorateCards()

    return true
end
