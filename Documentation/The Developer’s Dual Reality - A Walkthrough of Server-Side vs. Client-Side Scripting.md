The Developer’s Dual Reality: A Walkthrough of Server-Side vs. Client-Side Scripting

1. The Tale of Two Engines: An Introduction

In a multiplayer framework like Multi Theft Auto (MTA), the game world does not exist in a single location. Instead, the architecture is a Deterministic, Server-Authoritative Simulation split between two distinct environments: the Server and the Client. These two sides engage in a constant, high-speed conversation to maintain a unified experience for every player.

The Server is the master process, the ultimate "Source of Truth" running the simulation for everyone. It handles the economy, the database, and the global state of every object. The Client is the local game instance running on the player’s computer, responsible for the sensory experience—the visuals, the input, and the immediate "feel" of the game.

Who Does What?	Server (Authority and Data)	Client (Visuals and Input)
Primary Goal	Maintaining a synchronized global state.	Rendering the game world for the individual.
Core Tasks	Database I/O, account security, and ACL logic.	User Interfaces (CEF), local physics, and Camera Matrix.
Mastery Role	The authoritative "Master" that validates every action.	The "Window" and GPU-bound rendering engine.

Note: Understanding this split is the "magic key" to becoming a successful scripter. If you place sensitive logic on the client, you invite exploits; if you offload heavy visual rendering to the server, you cause catastrophic lag for the entire community.

While these two worlds work together, one side must always be the final arbiter. In the world of multiplayer architecture, the server always wins.

2. The Server: The Fortress of Data

Sensitive logic—particularly "Player Authentication"—must reside exclusively on the server. As established in account system architecture, tasks like registration and login are strictly server-side responsibilities for three primary reasons:

1. Security: Plaintext passwords and sensitive hashes should never touch the player's local machine. While MTA defaults to MD5 hashing, a senior developer will override this with Bcrypt, a far better and more secure alternative implemented via account data.
2. Database Access: The server maintains the exclusive connection to storage systems like SQLite or MySQL. The Client cannot see the database directly, preventing users from tampering with global records.
3. Global Permissions: The server manages the Access Control List (ACL). Only the server can verify if a user belongs to a restricted group (like "Admin"), which in turn allows the players resource to execute privileged functions.

The Server-Side Logic Flow:

1. Receiving the Request: The server receives a login event with credentials.
2. Checking the Database: The server queries SQLite/MySQL to locate the account.
3. Verifying the Hash: The server compares the provided password against the Bcrypt hash stored in the database.
4. ACL Check: The server verifies the account’s permissions, granting access to restricted commands or administrative ranks.

Once the server authenticates the player, it signals the client to transition from a "Waiting" state to an active participant in the world.

3. The Client: The Window to the Game World

The client handles the "senses" of the game. A prime example is the "Flying Car" mod. This works by utilizing the setWorldSpecialPropertyEnabled function to enable "air cars"—a cheat property inherent to the single-player engine that scripters repurpose for administrative use. This must run on the client because it manipulates the local physics and rendering engine directly.

Client-Side Superpowers:

* Immediate UI/GUI Feedback: Rendering login menus and inventory screens via the Chromium Embedded Framework (CEF) happens instantly on the client’s screen.
* Rendering "Live GPU Textures": As demonstrated in the "Multiverse" mod, the client uses librw (a RenderWare reimplementation) to manage multiple spatial scenes. While the server tracks a portal's existence, only the client's GPU can handle the state preservation required to render two different game worlds (like Liberty City and San Andreas) simultaneously.
* Camera Matrix Manipulation: Controlling the player’s perspective, such as smooth cinematic sweeps during a login sequence, is a purely client-side visual task.

While these visual marvels happen locally, the client remains tethered to the server to ensure that actions—like firing a weapon through a Multiverse portal—properly sync ballistic trajectories across all engine boundaries.

4. The Bridge: How Server and Client Communicate

Without a bridge, a player might see their car flying on their screen (Client), but the Server (and other players) would see them stuck on the ground, leading to "Desynchronization." Data is moved across this bridge using two core functions:

* triggerServerEvent: The client sends a request to the server (e.g., "I clicked the login button").
* triggerClientEvent: The server sends an instruction to the client (e.g., "Authentication successful; close the menu").

For massive data structures like inventories or map updates, senior developers use Latent Events (triggerLatentClientEvent) to stream data across multiple frames, preventing the bandwidth spikes that disrupt real-time movement.

The Rule of Security: Never trust data sent from the client without server validation. To prevent spoofing, every server-side event handler must validate the global client variable, ensuring that source == client.

5. Summary: The Developer’s Decision Matrix

Before writing a single line of code, use this checklist to determine the home of your logic:

* [ ] Does this involve sensitive user data or a database? → Server
* [ ] Does this require immediate visual feedback or a menu? → Client
* [ ] Does this affect the global state seen by all players? → Server
* [ ] Does this involve GPU-heavy rendering or screen filters? → Client
* [ ] Is the data payload large (e.g., a full inventory)? → Use Latent Events

The Decision Matrix

Goal	Primary Location	Why?	Impact of Error
Saving Money/Score	Server	Prevents cheating; server is the "Source of Truth."	Economy Inflation/Exploits
Opening a Login Menu	Client	Instant visual interface via CEF.	Input Lag/UI Freezes
Spawning a Vehicle	Server	Ensures the car exists in the global simulation.	Desynchronization/Invisible Cars
Applying a Screen Filter	Client	Local visual effect for the local player.	Unnecessary Server Load
Managing ACL Groups	Server	Only the server can modify "Fortress" permissions.	Privilege Escalation / Security Breach

Every technical marvel, from the "Mzansi-ZA" South African roleplay assets to a complex "Multiverse" connecting three game engines, starts with mastering these simple boundaries. Welcome to the world of high-performance multiplayer architecture.
