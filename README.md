# setbgm (Ashita v4)

Set FFXI background music from an ImGui window or commands. A native Ashita v4
implementation inspired by [svanheulen/setbgm-windower-addon](https://github.com/svanheulen/setbgm-windower-addon) (BSD-3), with a GUI and additional features.

## Features

- **In-game GUI:** Browse and change background music from an ImGui window, (or use chat commands, but this addon was developed with GUI in mind).

<img width="648" height="825" alt="image" src="https://github.com/user-attachments/assets/0b678d08-8e4e-44e3-b566-c460f32e7fe2" /> 
  
- **Expansion categories:** Filter the song catalog by soundtrack release or the dedicated **Battle** category.

<img width="556" height="227" alt="image" src="https://github.com/user-attachments/assets/2b96f432-b38e-4396-9333-27ef3c8d28c1" />

- **Favourites:** Save favourite tracks and filter the catalog to show only those songs.
- **Song usage details:** See where tracks are used, search by those uses, and hover over multi-use entries to view the full list.
- **Song Replacer:** Map one song ID to another so the replacement plays whenever the original track is used. Mappings persist, and each has an **Update** button to reapply it in the current zone.

<img width="932" height="566" alt="image" src="https://github.com/user-attachments/assets/5769bbd5-f2fc-4897-a939-9280474d0201" />

- **Zone Replacer:** Assign a song to a specific zone, including zones with no default theme, such as Zeruhn Mines. Assignments persist and apply on zone entry.

<img width="932" height="568" alt="image" src="https://github.com/user-attachments/assets/56ae496b-9553-4545-b247-736b8a7a262c" />

## Install
Copy this folder to `<Ashita>/addons/setbgm/`, so you have:

    addons/setbgm/setbgm.lua
    addons/setbgm/songs.lua
    addons/setbgm/zonemusic.lua

Load it: `/addon load setbgm`.

## Use
- `/setbgm`  toggle the window
- `/setbgm help`  list every command
- `/setbgm <song id> [type id]`  set music from chat
- `/setbgm reset`  clear saved choices and restore the zone music (uses the songs the server last sent; zone if it reports none)
- `/setbgm list`  list music types (0 Idle, 1 Battle Solo, 2 Battle Party, 3 Chocobo, 4 Mog House)
- Window: **Used for** shows Phoenix's song usage information. For multiple uses, it shows the first followed by **+N**; hover to see all uses. Search also matches these uses.
- Window: tick the box next to a song to favourite it, then click on **Show favourites only** to show your favs.
- Window: "Expansion" dropdown filters songs by soundtrack or the **Battle** category (dedicated battle, boss, and combat-event tracks; default: all songs)
- Window: **Set Battle Music to Current Zone Theme** copies the current zone idle song to both solo and party battle music choices
- Window: **Song Replacer** tab maps a song ID to another song ID, replacing it whenever the original plays; mappings are saved in the addon's settings. Each mapping has an **Update** button to force the replacement in matching current-zone music slots
- Window: **Zone Replacer** tab assigns a song to a zone, including zones with no default theme (for example, Zeruhn Mines); assignments are saved and applied when entering the zone

Choices are saved and re-applied after zoning and when the server switches music
(e.g. entering battle). Toggle that in the window with the **Re-apply after zoning / music changes**

## How it works

The addon lets you choose a song from the in-game window or `/setbgm` commands and assign it to an FFXI music type, such as idle, solo battle, party battle, Chocobo, or Mog House. The song catalog in `songs.lua` supplies the track names and expansion groups shown in the UI.

When FFXI receives a music packet (0x05F), the addon reads its music type and song ID. For a type with a saved choice, it creates a replacement music packet and passes it to Ashita's incoming packet manager so the local client plays the selected song. It does not send gameplay actions or modify outgoing gameplay packets.

The selected song IDs and favourites are saved in the addon's settings. With **Re-apply after zoning / music changes** enabled, the addon applies saved choices after zoning and when the server changes music, such as on entering battle.

**Reset** clears the saved song choices and restores the zone's normal music. The addon uses music packets it has observed from the server; if it has not seen a zone's music, it falls back to that zone's entries in `zonemusic.lua`.








## Zone default music
`zonemusic.lua` lists each zone's normal day, night, solo-battle and party-battle songs
(music types 0-3), generated from the upstream LandSandBoat data. That is what lets
Reset restores the zone music without zoning. The songs the server sends while
the addon is loaded take priority over this table.

## Song list credit

Song IDs, official titles, and their documented uses in `songs.lua` are based on
LandSandBoat's [MusicIDs.txt](https://github.com/LandSandBoat/server/blob/base/docs/MusicIDs.txt).
The Phoenix repository's copy of this data was used while preparing the addon's
catalog. The list and usage metadata are presented here with credit to LandSandBoat.

## AI usage

This addon was created with the assistance of AI tools.
