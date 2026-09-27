-- ============================================================
-- MZANSI RADIO: SHARED CONFIGURATION
-- Real South African Radio Stations Database
-- No conflict with game radio - completely custom implementation
-- ============================================================

Mzansi = Mzansi or {}
Mzansi.Radio = Mzansi.Radio or {}

Mzansi.Radio.Config = {
    -- Radio System Settings
    enableCustomRadio = true,
    disableGameRadio = true,           -- Disable SA's native radio when in vehicle
    useHTMLUI = true,                  -- Use CEF/HTML UI for radio
    maxVolume = 1.0,
    defaultVolume = 0.7,
    crossfadeTime = 1500,              -- ms for station switching
    bufferTime = 3000,                 -- ms buffer before playback
    
    -- CIT Radio Integration
    citRadioEnabled = true,
    citRadioTribute = true,
    citRadioMessage = "This server proudly features CIT Radio. The CIT Team inspires us with their dedication to quality South African radio streaming. We humbly request permission to integrate their stream to enhance our media experience. Thank you CIT Radio for being a beacon of SA audio excellence!",
    
    -- Vehicle Radio Settings
    vehicleRadioEnabled = true,
    radioRange = 50.0,                 -- meters for 3D radio in vehicles
    radio3DEnabled = true,
    
    -- Phone Integration
    phoneAppEnabled = true,
    phoneAppName = "Radio SA",
    
    -- Categories for UI filtering
    categories = {
        { id = "sabc", name = "SABC Public", icon = "📻", color = { 0, 150, 255 } },
        { id = "commercial", name = "Commercial", icon = "🎵", color = { 255, 100, 50 } },
        { id = "community", name = "Community", icon = "🏘️", color = { 50, 200, 100 } },
        { id = "special", name = "Special Interest", icon = "🎧", color = { 200, 50, 200 } },
        { id = "cit", name = "CIT Radio", icon = "🌟", color = { 255, 215, 0 } },
        { id = "international", name = "International", icon = "🌍", color = { 100, 100, 255 } },
    }
}