-- Velora v0.2
-- Timeline playback with pause, seek, speed, looping, and state callbacks.

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
        OnStateChanged = nil,
        _connection = nil,
        _nextEvent = 1,
    }, Player)
end

function Player:_emit(reason)
    if self.OnStateChanged then
        self.OnStateChanged(reason, self)
    end
end

function Player:Load(timeline)
    self:Stop()
    self.Timeline = timeline
    self.Position = 0
    self._nextEvent = 1
    self:_emit("loaded")
end

function Player:SetSpeed(speed)
    self.Speed = math.clamp(tonumber(speed) or 1, 0.5, 2)
    self:_emit("speed")
    return self.Speed
end

function Player:SetLoop(enabled)
    self.Loop = enabled == true
    self:_emit("loop")
end

function Player:Seek(progress)
    if not self.Timeline then
        return
    end

    progress = math.clamp(tonumber(progress) or 0, 0, 1)
    self.Position = self.Timeline.Duration * progress
    self._nextEvent = 1

    while self._nextEvent <= #self.Timeline.Events
        and self.Timeline.Events[self._nextEvent].Time < self.Position do
        self._nextEvent += 1
    end

    self:_emit("seek")
end

function Player:Play()
    if not self.Timeline or #self.Timeline.Events == 0 then
        return false
    end

    if self.Playing then
        if self.Paused then
            self.Paused = false
            self:_emit("resumed")
        end
        return true
    end

    self.Playing = true
    self.Paused = false
    self:_emit("playing")

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
                self:_emit("looped")
            else
                self:Stop()
                self:_emit("finished")
            end
        end
    end)

    return true
end

function Player:Pause()
    if self.Playing then
        self.Paused = not self.Paused
        self:_emit(self.Paused and "paused" or "resumed")
    end
end

function Player:Stop()
    if self._connection then
        self._connection:Disconnect()
        self._connection = nil
    end

    local changed = self.Playing or self.Paused or self.Position > 0
    self.Playing = false
    self.Paused = false
    self.Position = 0
    self._nextEvent = 1

    if changed then
        self:_emit("stopped")
    end
end

function Player:GetProgress()
    if not self.Timeline or self.Timeline.Duration <= 0 then
        return 0
    end
    return math.clamp(self.Position / self.Timeline.Duration, 0, 1)
end

function Player:GetState()
    if self.Paused then
        return "Paused"
    elseif self.Playing then
        return "Playing"
    end
    return "Ready"
end

return Player
