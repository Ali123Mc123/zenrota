Config.Music = {
    volumeRange = {
        min = 5, -- min volume level
        max = 35, -- max volume level
    },

    useStereo = true, -- activates stereo effect
    useLPF = true, -- activates low pass filter when the doors or windows are closed

    muteRadioCommand = 'mute_music', -- command to mute/unmute the radio | set to false to disable

    bassRange = { -- bass range
        min = -10, -- min bass level
        max = 35, -- max bass level 
        -- do not increase the max bass level too much (max: 45), it can cause distortion & headphones damage
    },
    trebleRange = { -- treble range
        min = -10, -- min treble level
        max = 35, -- max treble level
    },

    -- ==========================================================================
    -- AUDIO OUTPUTS - play the music from a vehicle or a speaker prop
    -- ==========================================================================
    -- bass/treble are NOT absolute values: they are added on top of whatever the
    -- player set in the equaliser. 0 = no effect.
    -- rangeMul multiplies the hearing distance (volume * 0.5 * rangeMul).
    Outputs = {
        phone = {
            enabled = true,
            bass = 0, treble = 0, -- neutral on purpose: this is the baseline
            rangeMul = 1.0,       -- volume 35 -> 17.5m
        },

        vehicle = {
            enabled = true,       -- false = players cannot play music from a vehicle
            -- how far the owner may walk away before the connection drops.
            -- 15-20 is realistic (real bluetooth range), 150 lets you park the
            -- car and leave the music playing.
            disconnectDistance = 150.0,
            bass = 8, treble = 0,
            rangeMul = 1.6,       -- volume 35 -> 28m
        },

        prop = {
            enabled = true,       -- false = speaker props are disabled entirely
            pairDistance = 3.0,   -- you must walk up to a speaker to connect to it
            disconnectDistance = 150.0,
            bass = 12, treble = -2,
            rangeMul = 2.2,       -- volume 35 -> ~38m

            -- SPEAKER CABINET COLOURING (props only)
            -- What makes something sound like it comes out of a box rather than
            -- out of headphones: a small cabinet cannot reproduce sub bass, and
            -- cheap plastic boxes / PA horns resonate in the midrange.
            -- It scales with distance because in reality the sub and the treble
            -- are the first things you lose as you walk away - the midrange is
            -- what carries. Near values apply next to the speaker, far values at
            -- the edge of its range.
            speakerColor = true,  -- false = no cabinet colouring, clean audio
            highpassNear = 120.0, -- Hz, cabinet roll-off up close
            highpassFar  = 220.0, -- Hz, at the edge of the hearing range
            honkNear     = 3.0,   -- dB boost at 2kHz up close
            honkFar      = 7.0,   -- dB at the edge
        },
    },

    -- Models a player is allowed to connect to. Any object in the world with one
    -- of these models becomes a speaker, no matter which resource placed it - so
    -- you can point this at a prop you already spawn somewhere else.
    -- This list is also what the server validates against: without it a player
    -- could route their music to any random object standing next to them.
    SpeakerModels = {
        'prop_boombox_01',
        'ba_prop_battle_speaker_01a',
        'prop_speaker_01',
        -- 'test_prop',
    },

    -- Speakers placed by the server itself, always there, cannot be picked up.
    -- They are spawned server-side so they are networked, which means the full
    -- validation path applies to them.
    --
    -- jobs restricts who may connect (bar / club scenario). Always a list, even
    -- for a single job. Leave it out and anyone may connect.
    --   jobs = { 'barman' }
    --   jobs = { 'barman', 'dj' }

    --   no job means anyone may connect, but the speaker is still fixed and cannot be picked up.
    --   jobs = nil 
    FixedSpeakers = {
        { coords = vector3(-850.81, 172.41, 67.17), heading = 35.0, model = 'sf_prop_sf_speaker_l_01a', label = 'Test Speaker' },
        -- { coords = vector3(-1568.0, -3016.0, -75.0), heading = 0.0, model = 'prop_speaker_01', label = 'Club Speaker', jobs = { 'barman', 'dj' } },
    },

    -- AIR ABSORPTION - applies to every output (phone / vehicle / speaker)
    -- High frequencies fade with distance far faster than bass does. Without
    -- this, a source 30m away in an open field still carries full treble, which
    -- does not sound like distance at all. It reuses the existing low-pass node,
    -- so it costs nothing extra, and it is added on top of the door/window
    -- occlusion rather than replacing it.
    -- Higher = duller at range. 0.8 lands around 8.7kHz at the edge of the range.
    -- Set to false (or 0) to turn it off completely.
    AirAbsorption = 0.8,

    AllowTakeover = true,     -- a second person in the car may take the connection over
    TakeoverCooldown = 5,     -- seconds before the same output can change hands again
    OnDisconnect = 'pause',   -- 'pause' (iOS behaviour) | 'phone' | 'stop'

    -- Reconnect automatically to a vehicle you connected to before.
    -- It never starts the music, it only moves an already playing track to the
    -- car, and such a connection is "borrowed": it returns to the phone by
    -- itself when you step out. A connection you made yourself from the sheet
    -- stays on the car. Auto-connect never takes a device over from someone.
    AutoReconnect = false,

    -- CEF protection: how many music streams may play around you at once.
    -- Every audible source is a YouTube iframe inside the music DUI, and a
    -- crowded area is what makes that DUI crash.
    -- 0 = unlimited, which is how this resource always behaved. Your own radio
    -- never counts against the limit, and a stream that is already playing is
    -- never dropped for a newcomer (that would thrash the DUI at the boundary).
    MaxConcurrentStreams = 0,
}