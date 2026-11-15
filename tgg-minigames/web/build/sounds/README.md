# 🔊 Minigame Sound Effects

This folder contains sound effects for the minigame system.

## Sound Files (Optional)

The sound system includes **built-in synthesized sounds** that work out of the box.
If you want to use custom sound files, place them here:

1. **success.mp3** or **success.wav** - Played on stage completion
2. **fail.mp3** or **fail.wav** - Played when a game fails
3. **click.mp3** or **click.wav** - Played on meaningful interactions (clicks, key presses)
4. **penalty.mp3** or **penalty.wav** - Played on wrong action when not instant fail (border flash)

**Supported formats:** MP3 and WAV (the system will try MP3 first, then WAV)

If these files are not present, the system will automatically use pleasant synthesized sounds:
- **Success**: A rising two-tone chime (C5 → E5)
- **Fail**: A low descending buzzer (A3 → A2)
- **Click**: A short, subtle tick sound
- **Penalty**: A quick warning buzz

## Recommended Sound Characteristics

### Success Sound
- Short duration (0.5-1.5 seconds)
- Uplifting, positive tone
- Clean, digital chime or notification sound
- Not too loud or jarring

### Fail Sound  
- Short duration (0.5-1.5 seconds)
- Subtle negative tone
- Low-pitched beep or buzz
- Not annoying or harsh

## Free Sound Sources

You can find suitable free sounds at:

1. **Orange Free Sounds** - https://orangefreesounds.com/
   - "Success Notification Tone" - Great for success
   - "Game Alert Sound" - Works for fail

2. **Freesound.org** - https://freesound.org/
   - Search for "UI success" or "game complete"
   - Search for "UI error" or "game fail"

3. **Mixkit** - https://mixkit.co/free-sound-effects/
   - Clean, royalty-free UI sounds

4. **Zapsplat** - https://www.zapsplat.com/
   - Large collection of game sounds

## Configuration

Sound settings are controlled in `config/soundConfig.lua`:

```lua
Config.SoundEnabled = true  -- Enable/disable all sounds
Config.SoundVolume = 0.5    -- Volume (0.0 to 1.0)
```

## Web Toggle

In the browser/development mode, there's a sound toggle in the UI controls overlay.

