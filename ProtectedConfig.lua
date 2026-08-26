-- Velora protected playback configuration.
-- This file is public by design. The API address is not a credential.
return {
    ApiBase = "https://velora-vault.velora-vault-backend.workers.dev/v1",
    RequestTimeout = 10,
    InitialChunks = 3,
    RetryCount = 3,
}
