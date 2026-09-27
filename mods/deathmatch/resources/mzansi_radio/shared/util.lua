-- ============================================================
-- MZANSI RADIO: SHARED UTILITIES
-- ============================================================

Mzansi = Mzansi or {}
Mzansi.Radio = Mzansi.Radio or {}
Mzansi.Radio.Util = Mzansi.Radio.Util or {}

function Mzansi.Radio.Util.getStationById(id)
    if not id then return nil end
    if Mzansi.Radio.StationIndex then
        return Mzansi.Radio.StationIndex[id]
    end
    for i = 1, #Mzansi.Radio.Stations do
        if Mzansi.Radio.Stations[i].id == id then
            return Mzansi.Radio.Stations[i]
        end
    end
    return nil
end

function Mzansi.Radio.Util.getStationsByCategory(categoryId)
    local result = {}
    if not categoryId or categoryId == "all" then
        for i = 1, #Mzansi.Radio.Stations do
            result[#result + 1] = Mzansi.Radio.Stations[i]
        end
        return result
    end
    for i = 1, #Mzansi.Radio.Stations do
        if Mzansi.Radio.Stations[i].category == categoryId then
            result[#result + 1] = Mzansi.Radio.Stations[i]
        end
    end
    return result
end

function Mzansi.Radio.Util.searchStations(query)
    local result = {}
    if not query or query == "" then
        return Mzansi.Radio.Util.getStationsByCategory("all")
    end
    local q = string.lower(query)
    for i = 1, #Mzansi.Radio.Stations do
        local s = Mzansi.Radio.Stations[i]
        local name = string.lower(s.name or "")
        local state = string.lower(s.state or "")
        local freq = string.lower(s.freq or "")
        local matched = string.find(name, q, 1, true)
            or string.find(state, q, 1, true)
            or string.find(freq, q, 1, true)
        if not matched and s.tags then
            for t = 1, #s.tags do
                if string.find(string.lower(s.tags[t]), q, 1, true) then
                    matched = true
                    break
                end
            end
        end
        if matched then
            result[#result + 1] = s
        end
    end
    return result
end

function Mzansi.Radio.Util.stationToDTO(station)
    if not station then return nil end
    return {
        id = station.id,
        name = station.name,
        freq = station.freq,
        category = station.category,
        state = station.state,
        codec = station.codec,
        bitrate = station.bitrate,
        tags = station.tags,
        type = station.type,
        homepage = station.homepage,
        tagline = station.tagline,
    }
end

function Mzansi.Radio.Util.listToDTO(list)
    local out = {}
    for i = 1, #list do
        out[#out + 1] = Mzansi.Radio.Util.stationToDTO(list[i])
    end
    return out
end

function Mzansi.Radio.Util.isHttpsUrl(url)
    if type(url) ~= "string" then return false end
    return string.sub(url, 1, 8) == "https://"
end