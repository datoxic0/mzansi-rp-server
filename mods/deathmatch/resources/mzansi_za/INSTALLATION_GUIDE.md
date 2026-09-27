# Mzansi-ZA Installation, Running, and Play Guide

This guide explains how to install, start, and play the Mzansi-ZA South African Roleplay environment in your Multi Theft Auto-style GTA SA server.

## 1. Installation

1. Copy the folder below into your server resource directory:
   - `mods/deathmatch/resources/mzansi_za`

2. Make sure the resource folder contains the following structure:
   - `meta.xml`
   - `server/`
   - `client/`
   - `shared/`
   - `ui/`

3. Ensure the resource is loaded by your server configuration.
   - Open your server config file such as `mods/deathmatch/mtaserver.conf`.
   - Add the resource name `mzansi_za` to the resource startup list if your server uses explicit starts.

4. If your server uses ACL-based permissions, confirm that the resource permissions are present in `mods/deathmatch/acl.xml`.
   - The resource depends on the ACL flow defined by the server setup.

## 2. Starting the Resource

1. Start your GTA SA server normally.
2. In the server console, verify that `mzansi_za` loads without errors.
3. If the resource is not loading automatically, start it with:
   ```
   start mzansi_za
   ```

4. If the server is running in a resource-configured setup, restart the server once after the first install so the new resource is registered properly.

## 3. First-Time Player Flow

1. Join the server with a valid account.
2. Login to your account normally.
3. Open the registration flow using the in-game command:
   ```
   /register
   ```
4. Enter your character details.
5. The server will create your saved character profile and spawn you to the default city area.

## 4. Core Commands

Use these commands while in-game:

- `/register` — open the character creation screen
- `/bank` — open the banking UI
- `/mdt` — open the MDT screen
- `/property` — open the property UI
- `/spawn` — respawn or teleport to the default city spawn area
- `/mza bank` — alternate bank command
- `/mza mdt` — alternate MDT command
- `/mza property` — alternate property command

## 5. Gameplay Notes

- The resource uses a shared character model backed by the SQLite database created under the server resource storage.
- Job and faction selection is stored on the player profile and influences what content the player can access.
- Businesses and properties are exposed through role-aware access rules.
- The browser UI is handled through the `ui/` folder and loaded by the CEF/browser bridge.

## 6. Troubleshooting

If the resource does not start correctly:

- Confirm that all resource files are present.
- Confirm that `meta.xml` lists the scripts and UI files in the correct order.
- Check the server console for missing script or file errors.
- Make sure your server has not blocked the resource or its browser UI.

## 7. Recommended Play Flow

1. Create your character.
2. Use `/bank` to check your account balance.
3. Use `/mdt` if you are in a faction role requiring law enforcement tools.
4. Use `/property` to view available property listings.
5. Progress through the roleplay economy with jobs, businesses, and faction enforcement.

## 8. Production Notes

This resource is structured as a modular roleplay foundation. Future expansion can add:

- deeper business ownership logic
- vehicle purchase and ownership systems
- property rent/lease actions
- custom faction workflows
- more South African map and roleplay content
