/* ============================================================
   MZANSI RADIO - UNIFIED BROADCAST & INTERNET APP CONTROLLER
   CEF <-> MTA:SA Bridge with Tab Switching & Custom Streams
   ============================================================ */

(function () {
    "use strict";

    const CATS = [
        { id: "all", name: "All", icon: "📻" },
        { id: "sabc", name: "SABC", icon: "🏛️" },
        { id: "commercial", name: "Commercial", icon: "🎵" },
        { id: "community", name: "Community", icon: "🏘️" },
        { id: "urban", name: "Urban / Youth", icon: "🔥" }
    ];

    const INTERNET_PRESETS = [
        {
            id: "cit_radio_live",
            name: "CIT Radio South Africa",
            frequency: "WEB",
            genre: "GTA SA Community Hits & Hip Hop",
            city: "Online Global",
            streamUrl: "https://cit2.net/radio/stream.mp3",
            badge: "COMMUNITY"
        },
        {
            id: "lofi_girl_radio",
            name: "Lofi Hip Hop Radio",
            frequency: "STREAM",
            genre: "Beats to Relax / Study to",
            city: "Online / Global",
            streamUrl: "https://play.streamafrica.net/lofi",
            badge: "CHILL"
        },
        {
            id: "synthwave_80s",
            name: "Nightride FM Synthwave",
            frequency: "RETRO",
            genre: "Synthwave, Cyberpunk, 80s Electro",
            city: "Global Stream",
            streamUrl: "https://stream.nightride.fm/nightride.m4a",
            badge: "RETRO"
        },
        {
            id: "defected_radio",
            name: "Defected House Radio",
            frequency: "CLUB",
            genre: "Deep House, Afro House, Nu-Disco",
            city: "London / Global",
            streamUrl: "https://stream.defected.com/radio",
            badge: "HOUSE"
        },
        {
            id: "bbc_world_news",
            name: "BBC World Service",
            frequency: "NEWS",
            genre: "International News & Documentaries",
            city: "United Kingdom",
            streamUrl: "https://stream.live.vc.bbcmedia.co.uk/bbc_world_service",
            badge: "TALK"
        }
    ];

    let stations = [];
    let activeCategory = "all";
    let activeTab = "broadcast";
    let currentPlaying = null;

    // ---------- Safe MTA Event Invoker ----------
    function mtaTrigger(eventName, ...args) {
        if (typeof mta !== "undefined" && mta.triggerEvent) {
            try {
                mta.triggerEvent(eventName, ...args);
                return true;
            } catch (err) {
                console.error("MTA error:", err);
            }
        }
        return false;
    }

    function showToast(msg) {
        const toast = document.getElementById("toast");
        if (!toast) return;
        toast.textContent = msg;
        toast.className = "toast show";
        setTimeout(() => { toast.className = "toast"; }, 2500);
    }

    // ---------- Tab Switching ----------
    function initTabs() {
        const btnBroadcast = document.getElementById("tabBroadcast");
        const btnInternet = document.getElementById("tabInternet");
        const contentBroadcast = document.getElementById("contentBroadcast");
        const contentInternet = document.getElementById("contentInternet");

        btnBroadcast.addEventListener("click", () => {
            activeTab = "broadcast";
            btnBroadcast.classList.add("active");
            btnInternet.classList.remove("active");
            contentBroadcast.classList.add("active");
            contentInternet.classList.remove("active");
        });

        btnInternet.addEventListener("click", () => {
            activeTab = "internet";
            btnInternet.classList.add("active");
            btnBroadcast.classList.remove("active");
            contentInternet.classList.add("active");
            contentBroadcast.classList.remove("active");
        });
    }

    // ---------- Categories ----------
    function renderCategories() {
        const container = document.getElementById("categoryPills");
        if (!container) return;
        container.innerHTML = "";
        CATS.forEach(c => {
            const pill = document.createElement("button");
            pill.className = "pill" + (c.id === activeCategory ? " active" : "");
            pill.textContent = c.icon + " " + c.name;
            pill.addEventListener("click", () => {
                activeCategory = c.id;
                renderCategories();
                filterAndRenderStations();
            });
            container.appendChild(pill);
        });
    }

    // ---------- Broadcast Station Card Builder ----------
    function filterAndRenderStations() {
        const grid = document.getElementById("stationGrid");
        if (!grid) return;
        grid.innerHTML = "";

        const search = (document.getElementById("searchBox").value || "").toLowerCase().trim();

        const filtered = stations.filter(s => {
            const matchesCat = activeCategory === "all" || (s.category && s.category.toLowerCase() === activeCategory);
            const matchesSearch = !search ||
                (s.name && s.name.toLowerCase().includes(search)) ||
                (s.frequency && s.frequency.toLowerCase().includes(search)) ||
                (s.genre && s.genre.toLowerCase().includes(search)) ||
                (s.city && s.city.toLowerCase().includes(search));
            return matchesCat && matchesSearch;
        });

        if (filtered.length === 0) {
            grid.innerHTML = '<div style="grid-column: 1/-1; text-align: center; padding: 40px; color: #94A3B8;">No broadcast stations match your search.</div>';
            return;
        }

        filtered.forEach(s => {
            const card = document.createElement("div");
            const isPlaying = currentPlaying && currentPlaying.id === s.id;
            card.className = "station-card" + (isPlaying ? " playing" : "");

            card.innerHTML = `
                <div class="card-top">
                    <span class="station-name">${s.name}</span>
                    <span class="station-freq">${s.frequency || "FM"}</span>
                </div>
                <div class="station-desc">${s.genre || s.city || "South Africa"}</div>
                <div class="card-bottom">
                    <span>📍 ${s.city || "National"}</span>
                    <span>${isPlaying ? "🟢 LIVE" : "▶ Play"}</span>
                </div>
            `;

            card.addEventListener("click", () => {
                tuneToStation(s);
            });
            grid.appendChild(card);
        });
    }

    // ---------- Internet Preset Stream Builder ----------
    function renderInternetPresets() {
        const grid = document.getElementById("internetPresetsGrid");
        if (!grid) return;
        grid.innerHTML = "";

        INTERNET_PRESETS.forEach(p => {
            const card = document.createElement("div");
            const isPlaying = currentPlaying && currentPlaying.id === p.id;
            card.className = "station-card" + (isPlaying ? " playing" : "");

            card.innerHTML = `
                <div class="card-top">
                    <span class="station-name">${p.name}</span>
                    <span class="station-freq">${p.badge}</span>
                </div>
                <div class="station-desc">${p.genre}</div>
                <div class="card-bottom">
                    <span>🌐 ${p.city}</span>
                    <span>${isPlaying ? "🟢 STREAMING" : "▶ Play"}</span>
                </div>
            `;

            card.addEventListener("click", () => {
                playCustomStream(p.streamUrl, p.name, p.id);
            });
            grid.appendChild(card);
        });
    }

    // ---------- Playback State & Controls ----------
    function tuneToStation(station) {
        currentPlaying = station;
        mtaTrigger("mzansi:radio:uiTune", station.id);
        updatePlayerUI(station);
        filterAndRenderStations();
        renderInternetPresets();
        showToast("Tuning: " + station.name);
    }

    function playCustomStream(url, title, customId) {
        if (!url || !url.startsWith("http")) {
            showToast("Error: Please provide a valid HTTP/HTTPS audio URL!");
            return;
        }
        currentPlaying = {
            id: customId || "custom_stream",
            name: title || "Internet Web Stream",
            frequency: "WEB",
            streamUrl: url
        };
        mtaTrigger("mzansi:radio:uiPlayCustom", url, currentPlaying.name);
        updatePlayerUI(currentPlaying);
        filterAndRenderStations();
        renderInternetPresets();
        showToast("Streaming: " + currentPlaying.name);
    }

    function stopPlayback() {
        currentPlaying = null;
        mtaTrigger("mzansi:radio:uiStop");
        updatePlayerUI(null);
        filterAndRenderStations();
        renderInternetPresets();
        showToast("Radio playback stopped");
    }

    function updatePlayerUI(station) {
        const npBadge = document.getElementById("npBadge");
        const npStation = document.getElementById("npStation");
        const npSub = document.getElementById("npSub");
        const playerStation = document.getElementById("playerStation");
        const playerFreq = document.getElementById("playerFreq");
        const soundBars = document.getElementById("soundBars");

        if (station) {
            npBadge.className = "np-badge live";
            npBadge.textContent = "ON AIR";
            npStation.textContent = station.name;
            npSub.textContent = station.frequency ? (station.frequency + " • " + (station.genre || "")) : "Streaming";
            playerStation.textContent = station.name;
            playerFreq.textContent = station.frequency || "LIVE STREAM";
            soundBars.className = "sound-bars active";
        } else {
            npBadge.className = "np-badge";
            npBadge.textContent = "OFF AIR";
            npStation.textContent = "Select a station";
            npSub.textContent = "Tap to listen";
            playerStation.textContent = "—";
            playerFreq.textContent = "Ready";
            soundBars.className = "sound-bars";
        }
    }

    // ---------- Lua Data Ingestion ----------
    window.__setStations = function (list) {
        if (Array.isArray(list)) {
            stations = list;
            filterAndRenderStations();
        }
    };

    // ---------- Initialization ----------
    document.addEventListener("DOMContentLoaded", () => {
        initTabs();
        renderCategories();
        renderInternetPresets();

        // Search Input
        document.getElementById("searchBox").addEventListener("input", () => {
            filterAndRenderStations();
        });

        // Close Button
        document.getElementById("btnClose").addEventListener("click", () => {
            mtaTrigger("mzansi:radio:uiClose");
        });

        // Stop Button
        document.getElementById("btnStop").addEventListener("click", () => {
            stopPlayback();
        });

        // CIT Dedicated Banner Button
        document.getElementById("btnCit").addEventListener("click", () => {
            const cit = stations.find(s => s.id === "cit_radio") || INTERNET_PRESETS[0];
            if (cit) {
                tuneToStation(cit);
            } else {
                playCustomStream("https://cit2.net/radio/stream.mp3", "CIT Radio South Africa", "cit_live");
            }
        });

        // Custom Stream Play Button
        document.getElementById("btnPlayCustom").addEventListener("click", () => {
            const url = document.getElementById("customUrlInput").value.trim();
            const title = document.getElementById("customTitleInput").value.trim() || "Web Audio Stream";
            playCustomStream(url, title);
        });

        // Volume Slider
        const volumeSlider = document.getElementById("volumeSlider");
        const volumeVal = document.getElementById("volumeVal");
        volumeSlider.addEventListener("input", (e) => {
            const val = e.target.value;
            volumeVal.textContent = val + "%";
            mtaTrigger("mzansi:radio:uiVolume", val / 100);
        });

        // Notify client Lua that UI is ready
        mtaTrigger("mzansi:radio:uiReady");
    });
})();