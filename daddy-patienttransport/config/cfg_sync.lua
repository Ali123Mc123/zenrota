Config = Config or {}

-- OneSync sync of the stretcher and wheelchair. Only change these if you know why.
Config.Sync = {
    equipmentStateKey = 'daddyPT:equipment',
    carrierStateKey = 'daddyPT:carrier',
    patientStateKey = 'daddyPT:patient',
    sessionStateKey = 'daddyPT:sessionToken',
    storedStateKey = 'daddyPT:storedStretcher',
    ackTimeoutMs = 2500,
    maxRetries = 3,
    spawnTimeoutMs = 1500,
    entityResolveTimeoutMs = 5000,
    ownerReconcileMs = 1000,
    watchdogMs = 1000,
    actionRateLimitMs = 500,
    maxActionDistance = 4.5,
    recoveryDistance = 15.0,
    idleCleanup = 900,                  -- seconds an unused stretcher/wheelchair may stand on the ground before it is removed, 0 = never
    maxRelationshipDistance = 20.0,
    diagnostics = false,                -- log every sync event to the server console
    debug = false,                      -- verbose debug prints
    diagnosticBufferSize = 256,
    diagnosticAce = 'daddypt.diag',     -- ACE for /emsdiag
}
