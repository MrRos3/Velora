-- Velora 0.10.21 protected playback transport.
-- Contains no GitHub credentials, backend secrets, or reusable private-repo tokens.

local ProtectedPlayback = {}
ProtectedPlayback.__index = ProtectedPlayback

local function findGlobal(name)
    local value = rawget(_G, name)
    if value ~= nil then
        return value
    end

    if type(getgenv) == "function" then
        local ok, environment = pcall(getgenv)
        if ok and type(environment) == "table" then
            return rawget(environment, name)
        end
    end

    return nil
end

local function findRequestFunction()
    for _, name in ipairs({ "request", "http_request" }) do
        local candidate = findGlobal(name)
        if type(candidate) == "function" then
            return candidate
        end
    end

    for _, namespaceName in ipairs({ "syn", "http" }) do
        local namespace = findGlobal(namespaceName)
        if type(namespace) == "table" and type(namespace.request) == "function" then
            return namespace.request
        end
    end

    return nil
end

local function responseStatus(response)
    return tonumber(response and (response.StatusCode or response.Status or response.status_code)) or 0
end

local function responseBody(response)
    local body = response and (response.Body or response.body)
    return type(body) == "string" and body or ""
end

local function validBaseUrl(value)
    value = tostring(value or ""):gsub("/+$", "")
    if not value:match("^https://") or value:find("REPLACE_WITH", 1, true) then
        return nil
    end
    return value
end

function ProtectedPlayback.new(options)
    assert(type(options) == "table", "ProtectedPlayback.new expects options")
    assert(options.HttpService, "ProtectedPlayback.new requires HttpService")

    local self = setmetatable({}, ProtectedPlayback)
    self.HttpService = options.HttpService
    self.ApiBase = validBaseUrl(options.ApiBase)
    self.Version = tostring(options.Version or "")
    self.InitialChunks = math.clamp(tonumber(options.InitialChunks) or 3, 1, 3)
    self.RetryCount = math.clamp(tonumber(options.RetryCount) or 3, 1, 4)
    self.RequestTimeout = math.clamp(tonumber(options.RequestTimeout) or 10, 3, 20)
    self.Request = type(options.Request) == "function" and options.Request or findRequestFunction()
    self.ClientId = self.HttpService:GenerateGUID(false):gsub("-", "")
    return self
end

function ProtectedPlayback:IsAvailable()
    if not self.ApiBase then
        return false, "Protected playback has not been deployed yet"
    end
    if type(self.Request) ~= "function" then
        return false, "This executor cannot make protected playback requests"
    end
    return true
end

function ProtectedPlayback:Post(path, body, token)
    local available, availabilityError = self:IsAvailable()
    if not available then
        return nil, availabilityError, "unavailable"
    end

    local encodedBody = self.HttpService:JSONEncode(body)
    local headers = {
        ["Content-Type"] = "application/json",
        ["Accept"] = "application/json",
        ["X-Velora-Client"] = self.ClientId,
    }
    if token then
        headers["Authorization"] = "Bearer " .. tostring(token)
    end

    local lastError = "Protected playback request failed"
    for attempt = 1, self.RetryCount do
        local ok, response = pcall(self.Request, {
            Url = self.ApiBase .. path,
            Method = "POST",
            Headers = headers,
            Body = encodedBody,
            Timeout = self.RequestTimeout,
        })

        if ok and type(response) == "table" then
            local status = responseStatus(response)
            local rawBody = responseBody(response)
            local decoded
            if rawBody ~= "" then
                pcall(function()
                    decoded = self.HttpService:JSONDecode(rawBody)
                end)
            end

            if status >= 200 and status < 300 and type(decoded) == "table" then
                return decoded
            end

            if status == 401 or status == 409 then
                return nil, "Protected playback session expired", "expired"
            end
            if status == 404 then
                return nil, "This protected song is unavailable", "unavailable"
            end

            local retryAfter = type(decoded) == "table" and tonumber(decoded.retryAfterMs) or nil
            if (status == 429 or status >= 500) and attempt < self.RetryCount then
                task.wait(math.clamp((retryAfter or (attempt * 350)) / 1000, 0.15, 3))
            else
                lastError = status == 429 and "Protected playback is busy; please wait a moment"
                    or "Protected playback service is unavailable"
                break
            end
        else
            lastError = tostring(response or lastError)
            if attempt < self.RetryCount then
                task.wait(attempt * 0.35)
            end
        end
    end

    return nil, lastError, "network"
end

function ProtectedPlayback:Open(entry, startSeconds)
    local protected = type(entry) == "table" and entry.Protected or nil
    if type(protected) ~= "table" or type(protected.Id) ~= "string" then
        return nil, "Song is missing protected playback metadata", "invalid"
    end

    local result, requestError, errorKind = self:Post("/sessions", {
        song = protected.Id,
        startMs = math.max(0, math.floor((tonumber(startSeconds) or 0) * 1000)),
        clientId = self.ClientId,
        version = self.Version,
    })
    if not result then
        return nil, requestError, errorKind
    end

    if type(result.token) ~= "string" or type(result.cursor) ~= "string"
        or tonumber(result.durationMs) == nil or tonumber(result.baseBpm) == nil then
        return nil, "Protected playback returned invalid session data", "invalid"
    end

    return {
        Token = result.token,
        Cursor = result.cursor,
        DurationMs = tonumber(result.durationMs),
        ChunkMs = tonumber(result.chunkMs) or tonumber(protected.ChunkMs) or 2500,
        BaseBPM = tonumber(result.baseBpm),
        BufferedUntilMs = 0,
        Ended = false,
        Fetching = false,
        Generation = 0,
    }
end

function ProtectedPlayback:Next(stream)
    if type(stream) ~= "table" or stream.Ended then
        return nil, "Protected playback stream has ended", "ended"
    end
    if type(stream.Cursor) ~= "string" or stream.Cursor == "" then
        return nil, "Protected playback cursor is missing", "expired"
    end

    local result, requestError, errorKind = self:Post("/chunks", {
        cursor = stream.Cursor,
    }, stream.Token)
    if not result then
        return nil, requestError, errorKind
    end

    if type(result.events) ~= "table" or tonumber(result.chunkEndMs) == nil then
        return nil, "Protected playback returned an invalid chunk", "invalid"
    end

    stream.Cursor = type(result.nextCursor) == "string" and result.nextCursor or nil
    stream.BufferedUntilMs = math.max(stream.BufferedUntilMs, tonumber(result.chunkEndMs) or 0)
    stream.Ended = result["end"] == true
    return result
end

function ProtectedPlayback:OpenAndPrime(entry, startSeconds)
    local stream, openError, errorKind = self:Open(entry, startSeconds)
    if not stream then
        return nil, nil, openError, errorKind
    end

    local chunks = {}
    for _ = 1, self.InitialChunks do
        local chunk, chunkError, chunkErrorKind = self:Next(stream)
        if not chunk then
            return nil, nil, chunkError, chunkErrorKind
        end
        table.insert(chunks, chunk)
        if stream.Ended then
            break
        end
    end
    return stream, chunks
end

return ProtectedPlayback
