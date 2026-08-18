-- Velora v0.2 Studio test harness.
-- Make this a LocalScript beside Main, Songs, src, and songs.
-- This verifies the engine; run Main to test the complete GUI.

local root = script.Parent
local Parser = require(root.src.Parser)
local Player = require(root.src.Player)

print("[Velora v0.2 Test] starting")

local timeline = Parser.parse("a - [sd] | f g", 120, 2)
assert(timeline.BPM == 120, "BPM was not preserved")
assert(timeline.StepsPerBeat == 2, "StepsPerBeat was not preserved")
assert(#timeline.Events == 4, "Expected four note events")
assert(#timeline.Events[2].Notes == 2, "Chord parsing failed")
assert(timeline.Duration > 0, "Timeline duration must be positive")

local adapter = { Played = {} }
function adapter:PlayNote(note)
    table.insert(self.Played, note)
end

local playback = Player.new(adapter)
playback:Load(timeline)
playback:SetSpeed(2)
playback:SetLoop(false)
playback:Play()

local timeoutAt = os.clock() + 5
while playback.Playing and os.clock() < timeoutAt do
    task.wait()
end

assert(not playback.Playing, "Playback timed out")
assert(#adapter.Played == 5, "Expected five dispatched notes including the chord")

playback:Load(timeline)
playback:Seek(0.5)
assert(playback:GetProgress() >= 0.49, "Seek did not update progress")
playback:Stop()

print("[Velora v0.2 Test] PASS 🥀")
