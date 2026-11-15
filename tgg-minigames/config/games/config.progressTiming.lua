Config = Config or {}

Config.ProgressTiming = {
    description = "İlerleme çubuğu noktaların üzerinden geçerken onları yakala!",

    numberOfPoints = 5,   -- Total points to hit (Max 7)
    progressDuration = 5, -- Seconds for progress bar to fill
    startDelay = 0.5,     -- Seconds before the progress bar starts
    minimalMode = false,  -- Hide container background and border
}
