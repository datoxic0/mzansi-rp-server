# **Technical Architecture, Network Engineering, and Custom Asset Infrastructure for Multi Theft Auto: San Andreas South African Roleplay Systems**

## **Executive Summary and Engine Architecture**

Deploying a high-performance, specialized *Multi Theft Auto: San Andreas* (MTA:SA) roleplay environment centered on modeling South African urban and sub-urban dynamics (*Mzansi-ZA*) requires a multi-layered software and network architecture. The foundation of MTA:SA relies on the MTA:BLUE core, a modified C/C++ engine wrapper around Rockstar Games' original RenderWare engine. MTA:SA couples this core with an embedded Lua 5.1/JIT scripting execution runtime, an asynchronous network stack powered by RakNet, and a secondary thread rendering engine powered by the Chromium Embedded Framework (CEF).  
To establish a multiplayer environment capable of serving localized South African content—such as custom vehicle fleets, regional architectural assets, police station infrastructure, and ambient environmental models—to an international player base, systems architects must carefully tune networking parameters, asset streaming pipelines, memory allocation models, and data persistence layers. The operational stability of a complex roleplay framework depends on decoupling heavy asset streaming and database operations from the main game loop, ensuring continuous state synchronization across high-latency international connections.

## **Network Infrastructure, Port Allocation, and Global Master Server Discovery**

Exposing a private or local MTA:SA server instance to the global Internet requires establishing explicit network routing, firewall rules, and port forwarding rules across edge gateways. The MTA:SA server uses a hybrid networking topology that separates real-time entity synchronization, administrative signaling, and high-volume resource delivery across specific UDP and TCP protocols.  
The primary game port defaults to UDP port 22003 and handles high-frequency player movement, vehicle position vectors, entity state updates, and remote procedure calls (RPCs) managed by RakNet. Resource file downloads, web administration panels, and HTTP REST endpoints operate over TCP port 22005\. For international client discovery, the server communicates with the MTA master server directory via the All-Seeing Eye (ASE) protocol. The ASE query port is calculated using the formula:  
\\text{Port}\_{\\text{ASE}} \= \\text{Port}\_{\\text{Server}} \+ 123  
When using the default game port of 22003, the corresponding ASE query port resolves to UDP port 22126\. Activating the \<ase\>1\</ase\> directive in the primary server configuration file (mods/deathmatch/mtaserver.conf) broadcasts periodic server heartbeat packets to global master servers, allowing international players to locate the server in the public in-game browser. Setting \<donotbroadcastlan\>0\</donotbroadcastlan\> ensures local network visibility remains enabled alongside public WAN broadcasting.

| Configuration Parameter | Default Value | Network Protocol | Functional Scope | Strategic System Configuration |
| :---- | :---- | :---- | :---- | :---- |
| serverport | 22003 | UDP | Core game state and entity synchronization | Assign top priority in host firewall Quality of Service (QoS) queues. |
| httpport | 22005 | TCP | Built-in HTTP resource server & Web Admin | Bound to HTTP web interface and asset transfer functions. |
| ase | 1 | UDP (22126\[span\_22\](start\_span)\[span\_22\](end\_span)\[span\_32\](start\_span)\[span\_32\](end\_span)) | Global Master Server Indexing | Value 1 enables master server pinging for server browser indexing. |
| donotbr\[span\_36\](start\_span)\[span\_36\](end\_span)\[span\_38\](start\_span)\[span\_38\](end\_span)\[span\_40\](start\_span)\[span\_40\](end\_span)oadcastlan | 0 | UDP | Subnet LAN broadcasting | Value 0 permits local subnet discovery concurrently with WAN discovery. |
| httpdownloadurl | "" | TCP (80/443) | External High-Speed HTTP Streaming | Offloads file delivery to an external web cluster (e.g., Nginx). |

To optimize download speeds for international players connecting from high-latency locations, servers offload resource delivery from the internal HTTP engine (httpport 22005\) to an external web cluster running Nginx or Apache. Configuring the \<httpdownloadurl\> setting in mtaserver.conf directs connecting clients to download asset bundles via parallel TCP streams directly from a high-bandwidth Content Delivery Network (CDN) or web host. This configuration prevents file transfers from consuming bandwidth reserved for UDP game-state packets.

## **Asset Customization Pipeline: South African Cultural and Architectural Localization**

Creating a South African roleplay environment (*Mzansi-ZA*) involves replacing default Grand Theft Auto: San Andreas models with regional assets. Localized assets typically deployed in Mzansi roleplay environments include:

> * **Commuter and Commercial Fleets:** Toyota Quantum minibus taxis, local commuter buses, logistics trucks, and customized utility vehicles.  
> * **Law Enforcement and Service Vehicles:** South African Police Service (SAPS) cruisers (such as Volkswagen Polo or BMW 3-Series interceptors), Metro Police vehicles, and regional Emergency Medical Services (EMS) ambulances.  
> * **Built Environment and Infrastructure:** SAPS station buildings, spaza shops, township housing styles, informal settlements, regional highway signage (N1, N3, R101 markers), and urban infrastructure modeled after Johannesburg, Cape Town, or Durban landmarks.  
> * **Character Skins:** Uniforms for SAPS officers, Metro Police, private security personnel, medical staff, and civilian apparel.

Importing custom assets requires adhering to a strict loading sequence to prevent rendering bugs, missing textures, memory corruption, or collision mismatches. The game engine processes asset replacements in a sequential three-step pipeline:

> 1. **Collision Injection (COL):** The collision boundary file (.col) is parsed into client RAM via engineLoadCOL and bound to the target model ID using engineReplaceCOL.  
> 2. **Texture Dictionary Import (TXD):** The RenderWare texture package (.txd) is loaded using engineLoadTXD and bound to the model slot via engineImportTXD.  
> 3. **Geometric Mesh Replacement (DFF):** The 3D model geometry (.dff) is loaded via engineLoadDFF and attached using engineReplaceModel.

When replacing world geometry across the base game map, developers must execute engineRestreamWorld immediately following model replacement. This flushes cached geometry buffers and forces the engine to render the updated 3D meshes and collision bounds within the player's immediate streaming radius.  
`-- C[span_63](start_span)[span_63](end_span)lient-Side Asset Import Pipeline for a Custom SAPS Cruiser`  
`local function loadSouthAfricanVehicle()`  
    `local modelID = 426 -- Premier model slot`  
      
    `-- Step 1: Load and replace collision bounds`  
    `if fileExists("assets/saps_premier.col") then`  
        `local colData = engineLoadCOL("assets/saps_premier.col")`  
        `if colData then`  
            `engineReplaceCOL(colData, modelID)`  
        `end`  
    `end`  
      
    `-- Step 2: Load and import texture dictionary`  
    `if fileExists("assets/saps_premier.txd") then`  
        `local txdData = engineLoadTXD("assets/saps_premier.txd", true)`  
        `if txdData then`  
            `engineImportTXD(txdData, modelID)`  
        `end`  
    `end`  
      
    `-- Step 3: Load and replace 3D mesh geometry`  
    `if fileExists("assets/saps_premier.dff") then`  
        `local dffData = engineLoadDFF("assets/saps_premier.dff")`  
        `if dffData then`  
            `engineReplaceModel(dffData, modelID, false)`  
        `end`  
    `end`  
`end`  
`addEventHandler("onClientResourceStart", resourceRoot, loadSouthAfricanVehicle)`

Modern MTA:SA environments utilize dynamic model allocation via engineRequestModel instead of overwriting base game vehicle slots (IDs 400 to 611\) or ped slots (IDs 7 to 312). Dynamic model allocation assigns unused ID slots to custom assets without altering base game elements.

| Function Name | Return Type | Primary Arguments | Operational Mechanics and Engine Impact |
| :---- | :---- | :---- | :---- |
| engineRequestModel | int / false | string elementType \[, int parentID\] | Allocates the next available dynamic ID slot for an element type ("vehicle", "ped", "object"). |
| engineLoadCOL | col | string colFilePath | Reads binary collision data into client RAM. |
| engineLoadTXD | txd | string txdFilePath\[span\_64\](start\_span)\[span\_64\](end\_span) \[, bool filtering\] | Parses RenderWare texture dictionary structures. |
| engineLoadDFF | dff | string dffFilePath\[span\_65\](start\_span)\[span\_65\](end\_span) | Loads 3D geometric mesh objects. |
| engineReplaceModel | bool | dff theModel\[span\_66\](start\_span)\[span\_66\](end\_span), int modelID \[, bool alpha\] | Binds loaded DFF geometry to a target static or dynamic model ID. |
| engineFreeModel | bool | int modelID | Releases allocated model IDs and frees associated client RAM when resources stop. |

Dynamic model allocation requires active resource life-cycle management. Unloading a resource does not automatically free dynamically allocated model IDs; scripts must call engineFreeModel inside onClientResourceStop handlers to release assigned slots back to the engine allocation pool and prevent memory leaks.

## **High-Performance Framework Architecture, Data Persistence, and Network Optimization**

A persistent roleplay server must track complex player states, including character identities, bank account balances, physical inventory items, vehicle titles, property deeds, and criminal records. Managing this state requires separating blocking disk I/O operations from the main game processing loop to maintain consistent tick rates.  
MTA:SA includes a native database interface supporting MySQL and SQLite backends through functions such as dbConnect, dbQuery, dbPoll, and dbExec. Executing database queries synchronously blocks the server thread while awaiting a response from the database engine, causing frame hitches and synchronization spikes for connected players. To prevent these bottlenecks, developers process database operations asynchronously using dbQuery callbacks or non-blocking polling loops (dbPoll with a timeout of 0).  
`-- Server-Side Asynchronous Database Retrieval`  
`local dbConnection = dbConnect("sqlite", "file=mta_roleplay.db")`

`function loadPlayerData(playerElement)`  
    `local accountID = getElementData(playerElement, "account:id")`  
    `if accountID and dbConnection then`  
        `-- Execute non-blocking asynchronous query`  
        `dbQuery(function(queryHandle, player)`  
            `local result, numAffectedRows, lastInsertID = dbPoll(queryHandle, 0)`  
            `if result and #result > 0 then`  
                `if isElement(player) then`  
                    `setElementData(player, "player:cash", result[1].cash)`  
                    `setElementData(player, "player:bank", result[1].bank)`  
                `end`  
            `end`  
        `end, {playerElement}, dbConnection, "SELECT cash, bank FROM characters WHERE id = ?", accountID)`  
    `end`  
`end`

Transmitting large data structures—such as full inventories, faction rosters, or regional map updates—using standard triggerClientEvent calls can saturate client network buffers. Standard events attempt to send data immediately, causing momentary bandwidth spikes that disrupt real-time player movement updates.  
To address packet queuing bottlenecks, developers route heavy payloads through triggerLatentClientEvent. Latent events throttle transmission rates to a specified byte limit per second (such as 50,000 bytes/sec), streaming data across multiple frames without blocking movement synchronization packets.

| Transmission Method | Syntax Signature | Thread Performance Impact | Network Synchronization Impact | Recommended Application |
| :---- | :---- | :---- | :---- | :---- |
| **Standard Event** | triggerClientEvent(player, "name", source, args...) | High CPU spikes during large payload transfers. | Can cause packet loss and temporary sync stutters. | Immediate, time-critical interactions (combat, weapons). |
| **Latent Event** | triggerLatentClientEvent(\[span\_94\](start\_span)\[span\_94\](end\_span)\[span\_97\](start\_span)\[span\_97\](end\_span)player, "name", rate, persist, source, args...) | Low CPU usage via background streaming. | Preserves steady movement and vehicle interpolation. | Heavy data structures (inventories, map updates). |

Long-running server instances can experience software aging—a process where unused memory allocations accumulate over extended uptime periods. On x86 and x64 server platforms, process memory usage approaching 1.2 GB increases the risk of Out Of Memory (OOM) crashes. Administrators mitigate software aging by regularly monitoring process memory through performancebrowser tools and scheduling automated restarts during low-traffic periods.

## **Web Interface Architecture via Embedded Chromium (CEF)**

MTA:SA replaces traditional single-color GUI widgets (CEGUI) with web interfaces powered by the Chromium Embedded Framework (CEF). CEF allows developers to build modern user interfaces—such as banking portals, mobile data terminals (MDT) for law enforcement, vehicle dashboards, and inventory menus—using standard HTML5, CSS3, and JavaScript frameworks.  
CEF operates under two distinct security modes within MTA:SA:

> 1. **Local Mode (isLocal \= true):** Renders HTML, CSS, and JS files stored directly within the server resource folder (e.g., http://mta/local/html/ui.html). Local mode allows bidirectional communication between Lua and JavaScript contexts using executeBrowserJavascript and mta.triggerEvent.  
> 2. **Remote Mode (isLocal \= false):** Loads external web domains (e.g., streaming services or external web applications). For security reasons, remote mode restricts direct JavaScript code execution and requires domains to be whitelisted via requestBrowserDomains.

`-- Client-Side CEF Web Interface Lifecycle Management`  
`local screenW, screenH = guiGetScreenSize()`  
`local webBrowserGUI = guiCreateBrowser(0, 0, screenW, screenH, true, true, false)`  
`local browserElement = guiGetBrowser(webBrowserGUI)`

`addEventHandler("onClientBrowserCreated", browserElement, function()`  
    `-- Load local HTML file packaged inside resource`  
    `loadBrowserURL(browserElement, "http://mta/local/ui/atm.html")`  
`end)`

`addEventHandler("onClientBrowserDocumentReady", browserElement, function()`  
    `local currentBalance = getElementData(localPlayer, "player:bank") or 0`  
    `-- Safely execute JavaScript function inside web environment`  
    `executeBrowserJavascript(browserElement, string.format("setBalanceDisplay(%d);", currentBalance))`  
`end)`

Communication from the CEF browser context back to the Lua engine relies on the embedded JavaScript mta namespace. Web pages trigger client-side Lua events by invoking mta.triggerEvent(eventName, parameters...). To optimize GPU utilization and client frame rates, developers must pause rendering on hidden browser elements using setBrowserRenderingPaused(browserElement, true) when the UI is not active on screen.

## **Security Engineering, Access Control Lists, and Event Hardening**

Exposing an MTA:SA server to public international networks requires implementing security controls to protect against unauthorized privilege escalation, remote code execution, and client event spoofing. Administrative access is configured using the Access Control List stored in mods/deathmatch/acl.xml.  
System administrators grant administrative permissions by registering account credentials via the server console (addaccount \<user\> \<pass\>) and assigning those accounts to privileged groups in acl.xml.  
`<!-- Hardened Group and ACL Configuration in acl.xml -->`  
`<group name="Admin">`  
    `<acl name="Admin"/>`  
    `<object name="user.Siphosethu"/>`  
`</group>`

`<acl name="Admin">`  
    `<right name="command.shutdown" access="false"/>`  
    `<right name="command.acl" access="true"/>`  
    `<right name="function.executeCommandHandler" access="false"/>`  
`</acl>`

A common security vulnerability in MTA:SA resource scripting occurs when server-side event handlers trust parameters supplied directly by client triggers. Attackers can craft custom client events to spoof parameters, such as altering payment values or granting items unauthorizedly.  
To secure remote events, server-side handlers must validate the global client variable and ensure source \== client before processing actions. The client variable is managed directly by the MTA C++ core and cannot be forged by client-side scripts, confirming the identity of the player who triggered the event.  
`-- VULNERABLE EVENT HANDLER (Insecure)`  
`addEvent("buyVehicle", true)`  
`addEventHandler("buyVehicle", root, function(targetPlayer, vehiclePrice)`  
    `-- VULNERABILITY: Directly trusts client-sent player and price arguments`  
    `takePlayerMoney(targetPlayer, vehiclePrice)`  
    `createVehicle(411, 0, 0, 3)`  
`end)`

`-- HARDENED EVENT HANDLER (Secured)`  
`addEvent("buyVehicleSecure", true)`  
`addEventHandler("buyVehicleSecure", resourceRoot, function(vehicleModel)`  
    `-- 1. Validate that the global client matches the event source`  
    `if not client or source ~= client then`  
        `return false`  
    `end`  
      
    `-- 2. Validate input parameter types`  
    `local model = tonumber(vehicleModel)`  
    `if not model or model < 400 or model > 611 then`  
        `return false`  
    `end`  
      
    `-- 3. Verify character state independently on the server`  
    `local price = 150000 -- Hardcoded server-side price check`  
    `if getPlayerMoney(client) >= price then`  
        `takePlayerMoney(client, price)`  
        `local x, y, z = getElementPosition(client)`  
        `local veh = createVehicle(model, x + 2, y, z)`  
        `warpPedIntoVehicle(client, veh)`  
    `else`  
        `outputChatBox("Insufficient funds.", client, 255, 0, 0)`  
    `end`  
`end)`

In addition to event hardening, Lua scripts should validate data types explicitly using tonumber() before executing mathematical operations, and use pairs() rather than ipairs() when iterating over non-sequential tables to prevent unhandled execution errors.

## **Strategic Implementation Roadmap and Deployment Protocols**

Building, testing, and deploying the *MTA: San Andreas Mzansi-ZA* roleplay server follows a four-phase operational roadmap:

### **Phase 1: Core Network Infrastructure and Hosting Configuration**

Deploy the MTA:SA dedicated server process on an enterprise Linux environment (e.g., Ubuntu Server or Debian) hosted in a datacenter with low-latency connections to key target regions. Open UDP port 22003 for game traffic, TCP port 22005 for HTTP services, and UDP port 22126 for ASE master server queries. Enable public discovery by setting \<ase\>1\</ase\> in mtaserver.conf and configure \<httpdownloadurl\> to route asset transfers to an external Nginx web server.

### **Phase 2: Asset Conversion and Localization Pipeline**

Convert South African vehicle models (e.g., Toyota Quantum, SAPS cruisers), regional building structures, and uniform textures into optimized .dff, .txd, and .col file formats. Implement dynamic model allocation using engineRequestModel to load assets into free memory slots without replacing base game entities. Ensure all custom assets release their allocated IDs via engineFreeModel during resource shutdowns.

### **Phase 3: Framework Development and UI Systems Integration**

Construct core roleplay systems—including character management, banking, inventory, and faction controls—using asynchronous database calls (dbQuery and dbPoll with a timeout of 0\) to avoid blocking the server execution thread. Optimize large data transfers using triggerLatentClien\[span\_68\](start\_span)\[span\_68\](end\_span)tEvent to stream payloads smoothly over background network channels. Develop custom user interfaces using CEF (guiCreateBrowser) operating in local mode to enable safe communication between Lua and JavaScript contexts.

### **Phase 4: Security Hardening and Production Deployment**

Harden server-side event logic by verifying the client global variable and source \== client conditions on all incoming network events. Restrict administrative permissions within acl.xml according to least-privilege principles. Run the server command openports to confirm network routing, and implement automated monitoring scripts to track memory usage and schedule restarts before process memory approaches the 1.2 GB software aging threshold.

#### **Works cited**

1\. Dryxio/mtasa-neon: Experimental Multi Theft Auto: San Andreas (MTA:SA) engine fork focused on larger worlds, expanded engine limits, and new Lua capabilities. \- GitHub, https://github.com/Dryxio/mtasa-neon 2\. Group :: Multi Theft Auto \- Steam Community, https://steamcommunity.com/groups/mta/announcements/listing?p=2 3\. CEF Tutorial \- Multi Theft Auto: Wiki, https://wiki.multitheftauto.com/wiki/CEF\_Tutorial 4\. Server Manual \- Multi Theft Auto: Wiki, https://wiki.multitheftauto.com/wiki/Server\_Manual 5\. engineReplaceModel \- Multi Theft Auto: Wiki, https://wiki.multitheftauto.com/wiki/EngineReplaceModel 6\. engineStreamingRequestModel \- Multi Theft Auto: Wiki, https://wiki.multitheftauto.com/wiki/EngineStreamingRequestModel 7\. triggerLatentClientEvent \- Multi Theft Auto: Wiki, https://wiki.multitheftauto.com/wiki/TriggerLatentClientEvent 8\. dbPoll \- Multi Theft Auto: Wiki, https://wiki.multitheftauto.com/wiki/DbPoll 9\. Server mtaserver.conf \- Multi Theft Auto: Wiki, https://wiki.multitheftauto.com/wiki/Server\_mtaserver.conf 10\. Run Multi Theft Auto San Andreas as a Windows Service \- FireDaemon Help Center and Support Portal, https://kb.firedaemon.com/support/solutions/articles/4000086987-multi-theft-auto-san-andreas 11\. mtasa-blue/Server/mods/deathmatch/mtaserver.conf at master \- GitHub, https://github.com/multitheftauto/mtasa-blue/blob/master/Server/mods/deathmatch/mtaserver.conf 12\. Installing and Configuring Nginx as an External Web Server \- Multi Theft Auto: Wiki, https://wiki.multitheftauto.com/wiki/Installing\_and\_Configuring\_Nginx\_as\_an\_External\_Web\_Server 13\. engineRequestModel \- Multi Theft Auto: Wiki, https://wiki.multitheftauto.com/wiki/EngineRequestModel 14\. MTA: San Andreas Development and and Book, uploaded:MTA: San Andreas Development and and Book 15\. engineFreeModel \- Multi Theft Auto: Wiki, https://wiki.multitheftauto.com/wiki/EngineFreeModel 16\. triggerServerEvent | Multi Theft Auto: Wiki, https://wiki.preview.multitheftauto.com/reference/triggerServerEvent 17\. triggerClientEvent \- Multi Theft Auto: Wiki, https://wiki.multitheftauto.com/wiki/TriggerClientEvent 18\. PL/Server Manual \- Multi Theft Auto: Wiki, https://wiki.multitheftauto.com/wiki/PL/Server\_Manual 19\. createBrowser \- Multi Theft Auto: Wiki, https://wiki.multitheftauto.com/wiki/CreateBrowser 20\. guiCreateBrowser \- Multi Theft Auto: Wiki, https://wiki.multitheftauto.com/wiki/GuiCreateBrowser 21\. executeBrowserJavascript \- Multi Theft Auto: Wiki, https://wiki.multitheftauto.com/wiki/ExecuteBrowserJavascript 22\. Cómo configurar un servidor MTA: San Andreas 2026 \- RDSNode, https://rdsnode.com/blog/configurar-servidor-mta-san-andreas/