-- Velora v0.1 test harness
-- Put this beside Main/Songs/src in a Roblox place you control and run it as a LocalScript.
-- It does NOT interact with any piano game. It only verifies parsing and playback timing.

local root = script.Parent
local src = root:WaitForChild("src")

local Parser = require(src:WaitForChild("Parser"))
local Player = require(src:WaitForChild("Player"))

print("[Velora Test] starting")

local sheet = [[
    a s d f | [gj] - h j | [ad] [sf] g -
]]

local timeline = Parser.parse(sheet, 120, 2)

assert(timeline.BPM == 120, "BPM parse failed")
assert(timeline.StepsPerBeat == 2, "StepsPerBeat parse failed")
assert(#timeline.Events > 0, "No events were parsed")
assert(timeline.Duration > 0, "Timeline duration is invalid")

print(string.format(
    "[Velora Test] parsed %d events, duration %.2fs",
    #timeline.Events,
    timeline.Duration
))

for index, event in ipairs(timeline.Events) do
    print(string.format(
        "[Velora Test] event %02d @ %.2fs -> %s",
        index,
        event.Time,
        table.concat(event.Notes, "+")
    ))
end

local TestAdapter = {}
TestAdapter.__index = TestAdapter

function TestAdapter.new()
    return setmetatable({ Played = {} }, TestAdapter)
end

function TestAdapter:PlayNote(note)
    table.insert(self.Played, note)
    print(string.format("[Velora Test] PLAY %s", tostring(note)))
end

local adapter = TestAdapter.new()
local player = Player.new(adapter)
player:Load(timeline)
player:SetSpeed(2)

print("[Velora Test] playback test running at 2x speed")
player:Play()

local started = os.clock()
while player.Playing and os.clock() - started < 10 do
    task.wait(0.05)
end

assert(not player.Playing, "Playback did not finish within the test timeout")
assert(#adapter.Played > 0, "Playback produced no notes")
assert(player:GetProgress() == 0, "Player should reset progress after Stop()")

print(string.format(
    "[Velora Test] PASS - %d notes were dispatched",
    #adapter.Played
))
print("[Velora Test] Velora v0.1 core is alive 🥀")
