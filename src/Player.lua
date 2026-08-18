-- Velora v0.1
-- Timeline-based playback engine.

local RunService = game:GetService("RunService")

local Player = {}
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

function Player:SetLoop(enabled)
    self.Loop = enabled == true
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
            if self.Loop then
                self.Position = 0
                self._nextEvent = 1
            else
                self:Stop()
            end
        end
    end)
end

function Player:Pause()
    if self.Playing then
        self.Paused = not self.Paused
    end
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

return Player
