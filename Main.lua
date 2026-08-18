-- Velora v0.2 🥀🎹
-- Place the Velora folder in StarterPlayerScripts and make Main a LocalScript.
-- Velora only drives piano code that you explicitly bind in an experience you own.

local root = script.Parent
local src = root:WaitForChild("src")
local songsFolder = root:WaitForChild("songs")

local Parser = require(src:WaitForChild("Parser"))
local Player = require(src:WaitForChild("Player"))
local PianoAdapter = require(src:WaitForChild("PianoAdapter"))
local UI = require(src:WaitForChild("UI"))
local SongRegistry = require(root:WaitForChild("Songs"))

local adapter = PianoAdapter.new()
local timelinePlayer = Player.new(adapter)

local Controller = {}
Controller.__index = Controller

function Controller.new()
    local self = setmetatable({
        Version = "0.2",
        CurrentSong = nil,
        CurrentEntry = nil,
        CurrentBPM = nil,
        Favorites = {},
        Player = timelinePlayer,
        Adapter = adapter,
        Changed = Instance.new("BindableEvent"),
        UI = nil,
    }, Controller)

    timelinePlayer.OnStateChanged = function(reason)
        self.Changed:Fire(reason)
    end

    return self
end

function Controller:GetSongs()
    return SongRegistry
end

function Controller:GetSongById(id)
    for _, entry in ipairs(SongRegistry) do
        if entry.Id == id then
            return entry
        end
    end
    return nil
end

function Controller:LoadSong(id)
    local entry = self:GetSongById(id)
    if not entry then
        warn(("Velora: unknown song id %q"):format(tostring(id)))
        return false
    end

    local moduleName = entry.File and entry.File:match("([^/]+)%.lua$")
    local songModule = moduleName and songsFolder:FindFirstChild(moduleName)
    if not songModule then
        warn(("Velora: song module missing for %s (%s)"):format(entry.Name, tostring(entry.File)))
        return false
    end

    local success, song = pcall(require, songModule)
    if not success or type(song) ~= "table" then
        warn(("Velora: could not load %s: %s"):format(entry.Name, tostring(song)))
        return false
    end

    local bpm = tonumber(song.BPM or entry.BPM) or 120
    local timeline = Parser.parse(song.Notes or "", bpm, song.StepsPerBeat)

    timelinePlayer:Load(timeline)
    self.CurrentSong = song
    self.CurrentEntry = entry
    self.CurrentBPM = bpm
    self.Changed:Fire("selection")
    return true
end

function Controller:Play()
    return timelinePlayer:Play()
end

function Controller:Pause()
    timelinePlayer:Pause()
end

function Controller:Stop()
    timelinePlayer:Stop()
end

function Controller:Seek(progress)
    timelinePlayer:Seek(progress)
end

function Controller:SetLoop(enabled)
    timelinePlayer:SetLoop(enabled)
end

function Controller:SetSpeed(speed)
    return timelinePlayer:SetSpeed(speed)
end

function Controller:SetBPM(value)
    if not self.CurrentSong then
        return nil
    end

    local bpm = math.clamp(tonumber(value) or self.CurrentBPM or 120, 30, 300)
    local wasPlaying = timelinePlayer.Playing and not timelinePlayer.Paused
    local timeline = Parser.parse(self.CurrentSong.Notes or "", bpm, self.CurrentSong.StepsPerBeat)

    timelinePlayer:Load(timeline)
    self.CurrentBPM = bpm
    if wasPlaying then
        timelinePlayer:Play()
    end
    self.Changed:Fire("bpm")
    return bpm
end

function Controller:IsFavorite(id)
    return self.Favorites[id] == true
end

function Controller:ToggleFavorite(id)
    if not self:GetSongById(id) then
        return false
    end

    self.Favorites[id] = not self.Favorites[id]
    self.Changed:Fire("favorites")
    return self.Favorites[id]
end

function Controller:PickRandom(filter)
    local candidates = {}
    for _, entry in ipairs(SongRegistry) do
        if not filter or filter(entry) then
            table.insert(candidates, entry)
        end
    end

    if #candidates == 0 then
        return nil
    end

    local selected = candidates[math.random(1, #candidates)]
    self:LoadSong(selected.Id)
    return selected
end

function Controller:BindPiano(playNoteCallback)
    adapter:Bind(playNoteCallback)
    self.Changed:Fire("adapter")
end

function Controller:GetSnapshot()
    return {
        State = timelinePlayer:GetState(),
        Progress = timelinePlayer:GetProgress(),
        Position = timelinePlayer.Position,
        Duration = timelinePlayer.Timeline and timelinePlayer.Timeline.Duration or 0,
        Speed = timelinePlayer.Speed,
        Loop = timelinePlayer.Loop,
        IsBound = adapter:IsBound(),
    }
end

local controller = Controller.new()
controller.UI = UI.create(controller)

if SongRegistry[1] then
    controller:LoadSong(SongRegistry[1].Id)
end

return controller
