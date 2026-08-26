# Protected playback architecture

Every shipped Velora track is protected. Each public registry entry contains only display metadata plus an opaque `Protected.Id`, duration, and chunk size. The runtime still supports a local entry type for development compatibility, but the public repository ships no local arrangement files.

## Request flow

1. The client opens a playback session for one opaque song ID and a start position.
2. The backend returns a short-lived bearer token and a signed cursor for the first 2.5-second chunk.
3. The client requests at most three initial chunks, then fetches the next chunk only when its forward buffer falls below five seconds.
4. Every cursor is bound to one session, sequence number, expiry, and nonce. The backend accepts only the next sequence and permits an identical retry of the most recent request.
5. The backend applies IP and client session limits, chunk request limits, bounded initial look-ahead, and real-time delivery pacing.
6. Played events are periodically discarded from client memory. Seeking, looping, stopping, tempo changes, or an expired cursor opens a new session at the required position.

The API has no song-list route and never returns a complete Lua source, MIDI, or whole-song response.

## Failure behavior

Network requests are retried three times. If a failure outlasts the current buffer, Velora stops the piano output before advancing further and shows a protected playback error. The library and controls remain intact, but no shipped song attempts to play without its protected stream. An undeployed placeholder endpoint causes the same clean failure.

## Secrets

`ProtectedConfig.lua` contains only the public HTTPS endpoint. The backend generates its HMAC signing key inside Cloudflare Durable Object storage on first deployment. No server secret or private GitHub credential is configured in or returned to the client.

## Deployment handoff

Keep `Velora-Vault-Backend` private. From that project, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\deploy-and-configure.ps1
```

The script tests and deploys the Worker, reads its `workers.dev` URL, and updates this repository's `ProtectedConfig.lua` automatically. Deployment is the only hosting step that requires the owner's Cloudflare login.

## Existing Git history

Deleting files from the current tree does not remove older public commits. Before calling the old arrangements private, use the guarded history-cleanup script in the private backend project, review the rewritten clone, and then replace the public remote history. Anyone who already downloaded a copy cannot be forced to delete it.
