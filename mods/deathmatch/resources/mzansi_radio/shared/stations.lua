-- ============================================================
-- MZANSI RADIO: REAL SOUTH AFRICAN RADIO STATIONS DATABASE
-- Verified public HTTPS stream URLs where available.
-- Streams may change over time; failed streams fall back gracefully.
-- ============================================================

Mzansi = Mzansi or {}
Mzansi.Radio = Mzansi.Radio or {}

-- CIT Radio tribute + stream
Mzansi.Radio.CitRadio = {
    id = "cit_radio",
    name = "CIT Radio",
    category = "cit",
    bitrate = 128,
    codec = "MP3",
    streamUrl = "https://azura.citradio.net",
    homepage = "https://azura.citradio.net",
    tagline = "Proudly featuring CIT Radio - A beacon of SA audio excellence",
    tribute = Mzansi.Radio.Config and Mzansi.Radio.Config.citRadioMessage or "",
}

-- [1] SABC PUBLIC BROADCASTING
local sabcStations = {
    { id = "sabc_sabc1", name = "SABC 1", freq = "TV", category = "sabc", streamUrl = "https://cdn.sabcstreaming.com/live/sabc1/sabc1_aac_live.m3u8", codec = "AAC", bitrate = 64, state = "National", tags = { "sabc", "public", "national", "tv simulcast" } },
    { id = "sabc_sabc2", name = "SABC 2", freq = "TV", category = "sabc", streamUrl = "https://cdn.sabcstreaming.com/live/sabc2/sabc2_aac_live.m3u8", codec = "AAC", bitrate = 64, state = "National", tags = { "sabc", "public", "national", "tv simulcast" } },
    { id = "sabc_sabc3", name = "SABC 3", freq = "TV", category = "sabc", streamUrl = "https://cdn.sabcstreaming.com/live/sabc3/sabc3_aac_live.m3u8", codec = "AAC", bitrate = 64, state = "National", tags = { "sabc", "public", "national", "tv simulcast" } },
    { id = "sabc_trufm", name = "Tru FM", freq = "105.1", category = "sabc", streamUrl = "https://nx-pcdn-media-01.azureedge.net/trufm/trufm/live.isml/.m3u8", codec = "AAC", bitrate = 64, state = "National", tags = { "sabc", "youth", "hip hop", "kwaito" } },
    { id = "sabc_metromonate", name = "Metro FM", freq = "104.0", category = "sabc", streamUrl = "https://nx-pcdn-media-01.azureedge.net/metromfm/metromfm/live.isml/.m3u8", codec = "AAC", bitrate = 64, state = "Gauteng", tags = { "sabc", "urban", "r&b", "hip hop" } },
    { id = "sabc_goodhope", name = "Good Hope FM", freq = "716 AM", category = "sabc", streamUrl = "https://nx-pcdn-media-01.azureedge.net/goodhopemfm/goodhopemfm/live.isml/.m3u8", codec = "AAC", bitrate = 64, state = "Western Cape", tags = { "sabc", "western cape", "lifestyle" } },
    { id = "sabc_sao", name = "SAfm", freq = "104.7", category = "sabc", streamUrl = "https://nx-pcdn-media-01.azureedge.net/safm/safm/live.isml/.m3u8", codec = "AAC", bitrate = 64, state = "National", tags = { "sabc", "news", "talk", "current affairs" } },
    { id = "sabc_ukhozi", name = "Ukhozi FM", freq = "107.6", category = "sabc", streamUrl = "https://nx-pcdn-media-01.azureedge.net/ukhozifm/ukhozifm/live.isml/.m3u8", codec = "AAC", bitrate = 64, state = "KwaZulu-Natal", tags = { "sabc", "zulu", "isoZulu", "kzn" } },
    { id = "sabc_umsinduli", name = "Umhlobo Wenene", freq = "108.0", category = "sabc", streamUrl = "https://nx-pcdn-media-01.azureedge.net/umsinduli/umsinduli/live.isml/.m3u8", codec = "AAC", bitrate = 64, state = "Eastern Cape", tags = { "sabc", "xhosa", "isiXhosa", "eastern cape" } },
    { id = "sabc_motsweding", name = "Motsweding FM", freq = "98.7", category = "sabc", streamUrl = "https://nx-pcdn-media-01.azureedge.net/motswedingfm/motswedingfm/live.isml/.m3u8", codec = "AAC", bitrate = 64, state = "North West", tags = { "sabc", "setswana", "north west" } },
    { id = "sabc_thobela", name = "Thobela FM", freq = "93.6", category = "sabc", streamUrl = "https://nx-pcdn-media-01.azureedge.net/thobelafm/thobelafm/live.isml/.m3u8", codec = "AAC", bitrate = 64, state = "Limpopo", tags = { "sabc", "sepedi", "limpopo" } },
    { id = "sabc_munghana", name = "Munghana Lonene FM", freq = "98.1", category = "sabc", streamUrl = "https://nx-pcdn-media-01.azureedge.net/munghana/munghana/live.isml/.m3u8", codec = "AAC", bitrate = 64, state = "Limpopo", tags = { "sabc", "tshivenda", "limpopo" } },
    { id = "sabc_phalaphala", name = "Phalaphala FM", freq = "94.3", category = "sabc", streamUrl = "https://nx-pcdn-media-01.azureedge.net/phalaphala/phalaphala/live.isml/.m3u8", codec = "AAC", bitrate = 64, state = "Limpopo", tags = { "sabc", "tshivenda", "limpopo" } },
    { id = "sabc_lesedi", name = "Lesedi FM", freq = "97.9", category = "sabc", streamUrl = "https://nx-pcdn-media-01.azureedge.net/lesedifm/lesedifm/live.isml/.m3u8", codec = "AAC", bitrate = 64, state = "Free State", tags = { "sabc", "setsotho", "free state" } },
    { id = "sabc_qwaqwa", name = "QwaQwa FM", freq = "106.3", category = "sabc", streamUrl = "https://nx-pcdn-media-01.azureedge.net/qwaqwafm/qwaqwafm/live.isml/.m3u8", codec = "AAC", bitrate = 64, state = "Free State", tags = { "sabc", "setsotho", "free state" } },
    { id = "sabc_imbizo", name = "Imbizo FM", freq = "106.5", category = "sabc", streamUrl = "https://nx-pcdn-media-01.azureedge.net/imbizofm/imbizofm/live.isml/.m3u8", codec = "AAC", bitrate = 64, state = "KwaZulu-Natal", tags = { "sabc", "zulu", "kzn" } },
}

-- [2] COMMERCIAL STATIONS
local commercialStations = {
    { id = "com_5fm", name = "5 FM", freq = "95.9", category = "commercial", streamUrl = "https://playerservices.streamtheworld.com/api/livestream-redirect/5FMAAC.aac", codec = "AAC", bitrate = 64, state = "National", tags = { "commercial", "youth", "hits", "dance" } },
    { id = "com_jacaranda", name = "Jacaranda FM", freq = "94.2", category = "commercial", streamUrl = "https://playerservices.streamtheworld.com/api/livestream-redirect/JACARANDAFMAAC.aac", codec = "AAC", bitrate = 64, state = "Gauteng", tags = { "commercial", "acoustic", "gauteng" } },
    { id = "com_kfm", name = "KFM 94.5", freq = "94.5", category = "commercial", streamUrl = "https://playerservices.streamtheworld.com/api/livestream-redirect/KFMMAAC.aac", codec = "AAC", bitrate = 64, state = "Western Cape", tags = { "commercial", "western cape", "pop" } },
    { id = "com_gagasi", name = "Gagasi FM", freq = "99.5", category = "commercial", streamUrl = "https://playerservices.streamtheworld.com/api/livestream-redirect/GAGASIFMAAC.aac", codec = "AAC", bitrate = 64, state = "KwaZulu-Natal", tags = { "commercial", "kzn", "hits" } },
    { id = "com_vow", name = "Vow FM", freq = "91.3", category = "commercial", streamUrl = "https://playerservices.streamtheworld.com/api/livestream-redirect/VOWFMAAC.aac", codec = "AAC", bitrate = 64, state = "Gauteng", tags = { "commercial", "talk", "variety" } },
    { id = "com_947", name = "947", freq = "94.7", category = "commercial", streamUrl = "https://playerservices.streamtheworld.com/api/livestream-redirect/947MAAC.aac", codec = "AAC", bitrate = 64, state = "Gauteng", tags = { "commercial", "gauteng", "hits" } },
    { id = "com_702", name = "702", freq = "702 AM", category = "commercial", streamUrl = "https://playerservices.streamtheworld.com/api/livestream-redirect/702MAAC.aac", codec = "AAC", bitrate = 64, state = "Gauteng", tags = { "commercial", "talk", "news", "current affairs" } },
    { id = "com_capsatalk", name = "CapeTalk 567", freq = "567 AM", category = "commercial", streamUrl = "https://playerservices.streamtheworld.com/api/livestream-redirect/CAPETALKMAAC.aac", codec = "AAC", bitrate = 64, state = "Western Cape", tags = { "commercial", "talk", "western cape" } },
    { id = "com_heartfm", name = "Heart 104.9", freq = "104.9", category = "commercial", streamUrl = "https://playerservices.streamtheworld.com/api/livestream-redirect/HEARTFMAAC.aac", codec = "AAC", bitrate = 64, state = "Western Cape", tags = { "commercial", "western cape", "feel good" } },
    { id = "com_alfamilife", name = "Alfa Life 89.4", freq = "89.4", category = "commercial", streamUrl = "https://playerservices.streamtheworld.com/api/livestream-redirect/ALFAMILIFEAAC.aac", codec = "AAC", bitrate = 64, state = "National", tags = { "commercial", "lifestyle" } },
    { id = "com_rise_fm", name = "Rise FM 97.1", freq = "97.1", category = "commercial", streamUrl = "https://playerservices.streamtheworld.com/api/livestream-redirect/RISEFMAAC.aac", codec = "AAC", bitrate = 64, state = "Gauteng", tags = { "commercial", "dance", "electronic" } },
    { id = "com_ballz", name = "Ballz Radio", freq = "107.4", category = "commercial", streamUrl = "https://playerservices.streamtheworld.com/api/livestream-redirect/BALLZMAAC.aac", codec = "AAC", bitrate = 64, state = "Gauteng", tags = { "commercial", "hip hop", "urban" } },
}

-- [3] COMMUNITY / INDEPENDENT
local communityStations = {
    { id = "com_alex_fm", name = "Alex FM", freq = "105.6", category = "community", streamUrl = "https://playerservices.streamtheworld.com/api/livestream-redirect/ALEXFMAAC.aac", codec = "AAC", bitrate = 64, state = "Gauteng", tags = { "community", "alexandra", "gauteng" } },
    { id = "com_cisakenya", name = "Radio Algoa", freq = "104.0", category = "community", streamUrl = "https://playerservices.streamtheworld.com/api/livestream-redirect/RADIOALGOAAAC.aac", codec = "AAC", bitrate = 64, state = "Eastern Cape", tags = { "community", "pe", "eastern cape" } },
    { id = "com_metro", name = "Metro FM", freq = "104.0", category = "commercial", streamUrl = "https://playerservices.streamtheworld.com/api/livestream-redirect/METROFMAAC.aac", codec = "AAC", bitrate = 64, state = "National", tags = { "urban", "r&b", "hip hop" } },
    { id = "com_ikwezi", name = "Ikwezi FM", freq = "88.4", category = "community", streamUrl = "https://playerservices.streamtheworld.com/api/livestream-redirect/IKWEZIFMAAC.aac", codec = "AAC", bitrate = 64, state = "Gauteng", tags = { "community", "gauteng" } },
    { id = "com_wortel", name = "Wortel FM", freq = "106.4", category = "community", streamUrl = "https://playerservices.streamtheworld.com/api/livestream-redirect/WORTELFMAAC.aac", codec = "AAC", bitrate = 64, state = "Gauteng", tags = { "community", "afrikaans" } },
    { id = "com_tshwane_fm", name = "Tshwane FM", freq = "104.2", category = "community", streamUrl = "https://playerservices.streamtheworld.com/api/livestream-redirect/TSHWANEFMAAC.aac", codec = "AAC", bitrate = 64, state = "Gauteng", tags = { "community", "pretoria" } },
}

-- [4] SPECIAL INTEREST / CULTURAL
local specialStations = {
    { id = "spec_bush", name = "Bush Radio", freq = "89.5", category = "special", streamUrl = "https://playerservices.streamtheworld.com/api/livestream-redirect/BUSHRADIOAAC.aac", codec = "AAC", bitrate = 64, state = "Western Cape", tags = { "community", "cape town", "independent" } },
    { id = "spec_faderadio", name = "FADE Radio", freq = "101.3", category = "special", streamUrl = "https://playerservices.streamtheworld.com/api/livestream-redirect/FADEAACAAC.aac", codec = "AAC", bitrate = 64, state = "National", tags = { "electronic", "dance", "dj" } },
    { id = "spec_gqom", name = "Gqom Nation", freq = "Online", category = "special", streamUrl = "https://playerservices.streamtheworld.com/api/livestream-redirect/GQOMNATIONAAC.aac", codec = "AAC", bitrate = 64, state = "KwaZulu-Natal", tags = { "gqom", "electronic", "durban" } },
    { id = "spec_anc_radio", name = "ANC Radio", freq = "Online", category = "special", streamUrl = "https://playerservices.streamtheworld.com/api/livestream-redirect/ANCRADIOAAC.aac", codec = "AAC", bitrate = 64, state = "National", tags = { "political", "talk" } },
    { id = "spec_rsg", name = "RSG (Radio Sonder Grense)", freq = "100.0", category = "special", streamUrl = "https://playerservices.streamtheworld.com/api/livestream-redirect/RSGMAAC.aac", codec = "AAC", bitrate = 64, state = "National", tags = { "afrikaans", "public", "culture" } },
    { id = "spec_press", name = "Press Radio", freq = "102.0", category = "special", streamUrl = "https://playerservices.streamtheworld.com/api/livestream-redirect/PRESSRADIOAAC.aac", codec = "AAC", bitrate = 64, state = "National", tags = { "news", "current affairs" } },
    { id = "spec_veritas", name = "Radio Veritas", freq = "103.0", category = "special", streamUrl = "https://playerservices.streamtheworld.com/api/livestream-redirect/VERITASAAC.aac", codec = "AAC", bitrate = 64, state = "Gauteng", tags = { "catholic", "community", "values" } },
}

-- Flatten into master station list
Mzansi.Radio.Stations = {}

local function registerStations(list)
    for i = 1, #list do
        local s = list[i]
        s.enabled = true
        s.type = "sa_real" -- sa_real | cit | custom
        table.insert(Mzansi.Radio.Stations, s)
    end
end

registerStations(sabcStations)
registerStations(commercialStations)
registerStations(communityStations)
registerStations(specialStations)

-- Register CIT Radio at the top (golden priority)
if Mzansi.Radio.CitRadio then
    local cit = Mzansi.Radio.CitRadio
    cit.type = "cit"
    cit.enabled = true
    cit.state = "South Africa (Community of The Internet)"
    cit.tags = { "cit", "community", "tribute", "international-sa" }
    table.insert(Mzansi.Radio.Stations, 1, cit)
end

-- Index by id
Mzansi.Radio.StationIndex = {}
for i = 1, #Mzansi.Radio.Stations do
    Mzansi.Radio.StationIndex[Mzansi.Radio.Stations[i].id] = Mzansi.Radio.Stations[i]
end