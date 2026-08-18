-- Velora v0.1
-- Entrypoint for a Roblox experience you control.
-- Expected layout when installed in Roblox:
-- Velora
--   Main (LocalScript)
--   Songs (ModuleScript)
--   songs/VeloraDemo (ModuleScript)
--   src/Parser (ModuleScript)
--   src/Player (ModuleScript)
--   src/PianoAdapter (ModuleScript)
--   src/UI (ModuleScript)

local root = script.Parent
local src = root:WaitForChild("src")
local songsFolder = root:WaitForChild("songs")

local Parser = require(src:WaitForChild("Parser"))
local Player = require(src:WaitForChild("Player"))
local PianoAdapter = require(src:WaitForChild("PianoAdapter"))
local UI = require(src:WaitForChild("UI"))
local SongRegistry = require(root:WaitForChild("Songs"))

local adapter = PianoAdapter.new()

-- Bind this to your own piano system.
-- Example:
-- adapter:Bind(function(note)
--     MyPiano:PlayNote(note)
-- end)

local player = Player.new(adapter)

local Controller = {}
Controller.__index = Controller

function Controller.new()
    return setmetatable({
        CurrentSong = nil,
        UI = nil,
    }, Controller)
end

function Controller:LoadSong(id)
    local entry
    for _, song in ipairs(SongRegistry) do
        if song.Id == id then
            entry = song
            break
        end
    end

    assert(entry, ("Velora: unknown song id %q"):format(tostring(id)))

    local moduleName = entry.File:match("([^/]+)%.lua$")
    local songModule = songsFolder:WaitForChild(moduleName)
    local song = require(songModule)

    local timeline = Parser.parse(song.Notes, song.BPM, song.StepsPerBeat)
    player:Load(timeline)
    self.CurrentSong = song

    if self.UI then
        self.UI.Status.Text = string.format("%s • %s • %d BPM", song.Name, song.Artist, song.BPM)
    end
end

function Controller:Play()
    player:Play()
end

function Controller:Pause()
    player:Pause()
end

function Controller:Stop()
    player:Stop()
end

local controller = Controller.new()
controller.UI = UI.create(controller)

-- Load the first registry song by default for v0.1.
if SongRegistry[1] then
    controller:LoadSong(SongRegistry[1].Id)
end

return controller
