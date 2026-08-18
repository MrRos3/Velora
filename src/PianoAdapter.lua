-- Velora v0.1
-- Adapter boundary between Velora and a piano implementation.
-- Replace Bind() with logic for a piano in an experience you control.

local PianoAdapter = {}
PianoAdapter.__index = PianoAdapter

function PianoAdapter.new()
    return setmetatable({
        _playNote = nil,
    }, PianoAdapter)
end

function PianoAdapter:Bind(playNoteCallback)
    assert(type(playNoteCallback) == "function", "Velora PianoAdapter: Bind expects a function")
    self._playNote = playNoteCallback
end

function PianoAdapter:PlayNote(note)
    if not self._playNote then
        warn("Velora PianoAdapter: no piano callback bound; note ignored:", note)
        return
    end

    self._playNote(note)
end

return PianoAdapter
