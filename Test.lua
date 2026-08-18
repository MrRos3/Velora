-- Velora v0.1 standalone test harness
-- Works both as a Roblox LocalScript and as a standalone Luau chunk.
-- This test does NOT interact with any piano game. It only verifies Velora's
-- parser and playback timing core.

local RunService = game:GetService("RunService")

print("[Velora Test] starting")

-- Prefer the real repository modules when this file is installed as a normal
-- LocalScript beside the Velora src folder. If `script` is unavailable, fall
-- back to a self-contained copy of the v0.1 core so the test can still run.
local Parser
local Player

local hasStudioModules = false
if script and script.Parent then
    local src = script.Parent:FindFirstChild("src")
    if src and src:FindFirstChild("Parser") and src:FindFirstChild("Player") then
        Parser = require(src.Parser)
        Player = require(src.Player)
        hasStudioModules = true
    end
end

if hasStudioModules then
    print("[Velora Test] using installed src/Parser + src/Player modules")
else
    print("[Velora Test] no script.Parent modules found; using standalone core")

    Parser = {}

    function Parser.parse(sheet, bpm, stepsPerBeat)
        assert(type(sheet) == "string", "Velora Parser: sheet must be a string")

        bpm = tonumber(bpm) or 120
        stepsPerBeat = tonumber(stepsPerBeat) or 2

        local secondsPerStep = (60 / bpm) / stepsPerBeat
        local events = {}
        local cursor = 0

        for token in sheet:gmatch("%S+") do
            if token == "|" then
                -- visual bar separator only
            elseif token == "-" then
                cursor += secondsPerStep
            else
                local notes = {}

                if token:sub(1, 1) == "[" and token:sub(-1) == "]" then
                    local chord = token:sub(2, -2)
                    for i = 1, #chord do
                        table.insert(notes, chord:sub(i, i))
                    end
                else
                    table.insert(notes, token)
                end

                table.insert(events, {
                    Time = cursor,
                    Notes = notes,
                    Token = token,
                })

                cursor += secondsPerStep
            end
        end

        return {
            BPM = bpm,
            StepsPerBeat = stepsPerBeat,
            StepDuration = secondsPerStep,
            Duration = cursor,
            Events = events,
        }
    end

    Player = {}
    Player.__index = Player

    function Player.new(adapter)
        assert(adapter and adapter.PlayNote, "Velora Player: adapter with PlayNote() is required")

        return setmetatable({
            Adapter = adapter,
            Timeline = nil,
            Playing = false,
            Paused = false,
            Position = 0,
            Speed = 1,
            Loop = false,
            _connection = nil,
            _nextEvent = 1,
        }, Player)
    end

    function Player:Load(timeline)
        self:Stop()
        self.Timeline = timeline
        self.Position = 0
        self._nextEvent = 1
    end

    function Player:SetSpeed(speed)
        self.Speed = math.clamp(tonumber(speed) or 1, 0.25, 4)
    end

    function Player:Play()
        if not self.Timeline or self.Playing then
            return
        end

        self.Playing = true
        self.Paused = false

        self._connection = RunService.Heartbeat:Connect(function(dt)
            if self.Paused then
                return
            end

            self.Position += dt * self.Speed
            local events = self.Timeline.Events

            while self._nextEvent <= #events and events[self._nextEvent].Time <= self.Position do
                local event = events[self._nextEvent]
                for _, note in ipairs(event.Notes) do
                    self.Adapter:PlayNote(note)
                end
                self._nextEvent += 1
            end

            if self.Position >= self.Timeline.Duration then
                self:Stop()
            end
        end)
    end

    function Player:Stop()
        if self._connection then
            self._connection:Disconnect()
            self._connection = nil
        end

        self.Playing = false
        self.Paused = false
        self.Position = 0
        self._nextEvent = 1
    end

    function Player:GetProgress()
        if not self.Timeline or self.Timeline.Duration <= 0 then
            return 0
        end
        return math.clamp(self.Position / self.Timeline.Duration, 0, 1)
    end
end

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
