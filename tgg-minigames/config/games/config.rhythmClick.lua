Config = Config or {}

Config.RhythmClick = {
    description = "Hızlı ritim tabanlı beceri testi - daireler kapanmadan onlara sırayla tıkla!",

    numberOfCircles = 10,     -- Total circles to click
    spawnInterval = 0.7,      -- Seconds between spawning each circle
    startDelay = 0.5,         -- Seconds before the first circle starts closing
    perfectClickWindow = 0.4, -- Seconds window at end to click when circle is fully closed
}
