-- Velora v0.2
-- Safe boundary between Velora and a piano system in an experience you own.

local PianoAdapter = {}
PianoAdapter.__index = PianoAdapter

function PianoAdapter.new()
    return setmetatable({
        _playNote = nil,
        _warned = false,
    }, PianoAdapter)
end

function PianoAdapter:Bind(playNoteCallback)
    assert(type(playNoteCallback) == "function", "Velora PianoAdapter: Bind expects a function")
    self._playNote = playNoteCallback
    self._warned = false
end

function PianoAdapter:IsBound()
    return self._playNote ~= nil
end

function PianoAdapter:PlayNote(note)
    if not self._playNote then
        if not self._warned then
            self._warned = true
            warn("Velora: no piano callback is bound. Playback is running in preview mode.")
        end
        return
    end

    local success, message = pcall(self._playNote, note)
    if not success then
        warn("Velora PianoAdapter callback failed:", message)
    end
end

return PianoAdapter
