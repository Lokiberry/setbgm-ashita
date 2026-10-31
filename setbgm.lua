--[[
setbgm for Ashita v4 - set the background music from a UI or commands. Inspired by svanheulen/setbgm-windower-addon

Commands (addon was made with GUI usage in mind):
    /setbgm                      toggle the window
    /setbgm help                 show all commands
    /setbgm <song id>            set all available music types
    /setbgm <song id> <type id>  set one music type (0-4, see /setbgm list)
    /setbgm reset                clear choices and restore the zone's normal music
    /setbgm defaults             show the zone songs the addon has cached
    /setbgm debug                toggle logging of music packets
    /setbgm color <n>            chat color code for the song name in "Now playing"
    /setbgm mute [type id]       stay silent until /setbgm reset
    /setbgm list                 print music types
--]]

addon.name     = 'setbgm'
addon.author   = 'Zibios'
addon.link     = 'https://github.com/danijrubio/setbgm-ashita'
addon.version  = '1.0'
addon.desc     = 'Set background music with a UI'
addon.commands = { '/setbgm' }

require('common')
local imgui    = require('imgui')
local settings = require('settings')
local data     = require('songs')
local zonemusic = require('zonemusic')   -- zone id -> { day, night, battle solo, battle party }

local defaults = T{
    chosen  = { -1, -1, -1, -1, -1, -1, -1, -1 }, -- song id per music type 0-7 (index = type + 1)
    reapply = true,                               -- re-apply after zoning / server music changes
    name_color = 2,                               -- FFXI chat color code (0x1E, n) used for the song name
    favourites = {},                              -- song ids starred in the window
    replacements = {},                            -- [original song id] = replacement song id
    zone_replacements = {},                       -- [zone id] = song id
}

local cfg = settings.load(defaults)

-- Favourites: cfg.favourites is a saved list of song ids; fav is a lookup set for the UI.
local fav = {}
local fav_box = {}            -- [song id] = { bool }, checkbox state for the list
local fav_count = 0

local function rebuild_fav()
    fav, fav_count = {}, 0
    for _, id in ipairs(cfg.favourites or {}) do
        if fav[id] == nil then fav[id] = true; fav_count = fav_count + 1 end
    end
end

local function set_favourite(id, on)
    if on then fav[id] = true else fav[id] = nil end
    local out = {}
    for k in pairs(fav) do out[#out + 1] = k end
    table.sort(out)
    cfg.favourites = out
    fav_count = #out
    settings.save()
end

rebuild_fav()

-- Remove saved overrides for unsupported music packet types and migrate mute settings.
local function sanitize_settings()
    local changed = false
    if cfg.mute_id ~= nil or cfg.silence_id ~= nil or cfg.silence_delay ~= nil then
        cfg.mute_id, cfg.silence_id, cfg.silence_delay = nil, nil, nil
        changed = true
    end
    if cfg.chosen[6] ~= -1 or cfg.chosen[8] ~= -1 then
        cfg.chosen[6], cfg.chosen[8] = -1, -1
        changed = true
    end
    for from, to in pairs(cfg.replacements or {}) do
        if data.songs[tonumber(from)] == nil or data.songs[tonumber(to)] == nil or tonumber(from) == tonumber(to) then
            cfg.replacements[from] = nil
            changed = true
        end
    end
    cfg.zone_replacements = cfg.zone_replacements or {}
    for zone, song in pairs(cfg.zone_replacements) do
        if zonemusic[tonumber(zone)] == nil or data.songs[tonumber(song)] == nil then
            cfg.zone_replacements[zone] = nil
            changed = true
        end
    end
    if changed then settings.save() end
end

settings.register('settings', 'setbgm_settings_update', function(s)
    if s ~= nil then
        cfg = s
        sanitize_settings()
        rebuild_fav()
    end
end)
sanitize_settings()

local USED_FOR_COLUMN_X = 360     -- x offset of the Used for column in the song list

-- UI state -----------------------------------------------------------------

local ui = {
    open   = { false },
    filter = { '' },
    type   = { -1 },          -- -1 = all types
    group  = 0,               -- 0 = all songs, otherwise index into data.groups
    favs_only = { false },    -- "Show favourites only" checkbox
    reapply = { cfg.reapply },
    replace_from = { 28 },
    replace_to = { 28 },
    replace_from_filter = { '' },
    replace_to_filter = { '' },
    selected_zone = { 172 },
    zone_filter = { '' },
    zone_song = { 28 },
    zone_song_filter = { '' },
}

local list = {}
for id, name in pairs(data.songs) do list[#list + 1] = { id = id, name = name } end
table.sort(list, function(a, b) return a.id < b.id end)

local zone_list = {}
local zone_names = {}
for id, row in pairs(zonemusic) do
    if type(row[5]) == 'string' then
        zone_list[#zone_list + 1] = { id = id, name = row[5] }
        zone_names[id] = row[5]
    end
end
table.sort(zone_list, function(a, b) return a.name < b.name end)

-- songs per group, for the dropdown labels
local group_count = {}
for _, s in ipairs(list) do
    local g = data.group_of[s.id]
    group_count[g] = (group_count[g] or 0) + 1
end

-- Phoenix's "Used for" descriptions, split into entries in songs.lua.
local used_for_label = {}
local used_for_search = {}
for id, entries in pairs(data.used_for or {}) do
    if #entries > 0 then
        used_for_label[id] = (#entries == 1) and entries[1] or ('%s (+%d)'):format(entries[1], #entries - 1)
        used_for_search[id] = table.concat(entries, ' '):lower()
    end
end
local pending = {}            -- [type] = re-apply time
local pending_song = {}       -- [type] = song to re-apply
local current_zone_theme = nil
local zone_replacer_pending = nil
local MUTE_SONG_ID = 0

-- Packet injection ---------------------------------------------------------

local function inject(packet)
    local ok = pcall(function()
        AshitaCore:GetPacketManager():AddIncomingPacket(0x5F, packet)
    end)
    if not ok then print('[setbgm] could not inject music packet') end
    return ok
end

local debug_log = false
local recent = {}             -- [type][song] = expiry time of packets we injected ourselves

local function replacement_for(song)
    return (cfg.replacements or {})[song] or (cfg.replacements or {})[tostring(song)] or song
end

local function set_music(mtype, song)
    song = replacement_for(song)
    recent[mtype] = recent[mtype] or {}
    recent[mtype][song] = os.clock() + 5.0
    -- Packet 0x5F: header, then type and song as little-endian uint16 values.
    local ok = inject({ 0x5F, 0x04, 0x00, 0x00,
                        mtype % 256, math.floor(mtype / 256),
                        song % 256, math.floor(song / 256) })
    if not ok then recent[mtype][song] = nil end
    return ok
end

local function song_name(id)
    if id == nil then return 'Zone default' end
    if data.songs[id] ~= nil then return data.songs[id] end
    if id == MUTE_SONG_ID then return 'Mute' end
    return tostring(id)
end

-- "Now playing: <song>", with the song name in its own chat color.
local function report(ok, name)
    if not ok then return end
    local colored = string.char(0x1E, cfg.name_color) .. name .. string.char(0x1E, 0x01)
    print('[setbgm] Now playing: ' .. colored)
end

-- Music types as the player sees them (ids used in commands and the UI).
-- Idle day and night are merged into one entry; packet_types are the 0x05F types
-- (0-7, see songs.lua) each entry applies to.
local managed_packet_types = { 0, 1, 2, 3, 4, 6 }
local music_types = {
    [0] = { name = 'Idle',           packet_types = { 0, 1 } },
    [1] = { name = 'Battle (Solo)',  packet_types = { 2 } },
    [2] = { name = 'Battle (Party)', packet_types = { 3 } },
    [3] = { name = 'Chocobo',        packet_types = { 4 } },
    [4] = { name = 'Mog House',      packet_types = { 6 } },
}
local last_music_type = 4

-- Packet types for a music type id. nil or -1 = all. An invalid id gives an empty list.
local function expand(g)
    local out = {}
    if g == nil or g == -1 then
        for _, t in ipairs(managed_packet_types) do out[#out + 1] = t end
    elseif music_types[g] ~= nil then
        for _, t in ipairs(music_types[g].packet_types) do out[#out + 1] = t end
    else
        print(('[setbgm] invalid type id: %s (use 0-%d, see /setbgm list)'):format(tostring(g), last_music_type))
    end
    return out
end

local function apply(song, mtype, allow_unknown)
    if data.songs[song] == nil and not allow_unknown then
        print(('[setbgm] invalid song id: %s'):format(tostring(song)))
        return
    end
    local ts, ok = expand(mtype), false
    for _, t in ipairs(ts) do
        pending[t], pending_song[t] = nil, nil
        cfg.chosen[t + 1] = song
        ok = set_music(t, song) or ok
    end
    if #ts > 0 then
        settings.save()
        report(ok, song_name(song))
    end
end

-- Last song the server itself sent for each music type (0-7), while the addon was loaded.
local server_song = {}

local function current_zone()
    local ok, zone = pcall(function()
        return AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0)
    end)
    if ok then return zone end
    return nil
end

local function zone_override_for(zone)
    local mappings = cfg.zone_replacements or {}
    return mappings[zone] or mappings[tostring(zone)]
end

local function apply_zone_override(zone)
    local song = zone_override_for(zone)
    if song == nil then return false end
    local ok = set_music(0, song)
    ok = set_music(1, song) or ok
    if debug_log then
        print(('[setbgm] zone %d music set to song %d'):format(zone, song))
    end
    return ok
end

local function restore_zone_override(zone)
    local row = zonemusic[zone]
    if row == nil then return end
    for t = 0, 1 do
        local original = row[t + 1] or 0
        set_music(t, original)
        if debug_log then
            print(('[setbgm] restoring zone %d default song %d (type %d)'):format(zone, original, t))
        end
    end
end

local function apply_zone_replacements(zone, force)
    local row = zone and zonemusic[zone]
    if row == nil then return end
    local zone_override = zone_override_for(zone) ~= nil
    for t = 0, 3 do
        local original = row[t + 1]
        if not (zone_override and t < 2) and (force or server_song[t] == nil) and original ~= nil and original ~= 0 then
            local replacement = replacement_for(original)
            if replacement ~= original then
                set_music(t, replacement)
                if debug_log then
                    print(('[setbgm] replacing zone %d song %d with %d (type %d)'):format(zone, original, replacement, t))
                end
            end
        end
    end
end

local function force_song_replacement(from, to)
    local zone = current_zone()
    local row = zone and zonemusic[zone]
    local applied = false
    for t = 0, 7 do
        local matches = server_song[t] == from or (t <= 3 and row ~= nil and row[t + 1] == from)
        if matches and not (t < 2 and zone_override_for(zone) ~= nil) then
            pending[t], pending_song[t] = nil, nil
            set_music(t, to)
            applied = true
        end
    end
    if not applied then
        print(('[setbgm] song %d is not a known music slot in the current zone'):format(from))
    end
end

local function restore_zone_song(from, replacement)
    local zone = current_zone()
    local row = zone and zonemusic[zone]
    if row == nil then return end
    local changed = false
    for t = 0, 3 do
        if row[t + 1] == from then
            if cfg.chosen[t + 1] == replacement then
                cfg.chosen[t + 1] = -1
                pending[t], pending_song[t] = nil, nil
                changed = true
            end
            set_music(t, from)
            if debug_log then
                print(('[setbgm] restoring zone %d song %d (type %d)'):format(zone, from, t))
            end
        end
    end
    if changed then settings.save() end
end

-- The zone's normal song for a music type, and where we learned it:
-- 'server' (seen in a packet) or 'table' (zonemusic.lua, from upstream LandSandBoat data).
-- Only types 0-3 (day, night, battle solo, battle party) are zone-specific.
local function default_for(t)
    if server_song[t] ~= nil then return server_song[t], 'server' end
    if t <= 3 then
        local z = current_zone()
        local row = z and zonemusic[z]
        if row then return row[t + 1], 'table' end
    end
    return nil, nil
end

-- Keep selected music types muted until they are changed or reset.
local function mute(mtype)
    print('[setbgm] muting selected music types until reset')
    apply(MUTE_SONG_ID, mtype, true)
end

local function set_battle_to_zone_theme()
    local song = current_zone_theme or server_song[0] or server_song[1]
    if song == nil or song == 0 then
        local zone = current_zone()
        local row = zone and zonemusic[zone]
        if row ~= nil then
            song = row[1]
            if song == nil or song == 0 then song = row[2] end
        end
    end
    if song == nil or song == 0 then
        print(('[setbgm] no idle music found for zone %s'):format(tostring(current_zone())))
        return
    end

    local ok = false
    for _, t in ipairs({ 2, 3 }) do
        pending[t], pending_song[t] = nil, nil
        cfg.chosen[t + 1] = song
        ok = set_music(t, song) or ok
    end
    settings.save()
    report(ok, song_name(song))
end

local function reset()
    local ok, shown = false, nil
    local zone = current_zone()
    local zone_song = zone_override_for(zone)
    for _, t in ipairs(managed_packet_types) do
        cfg.chosen[t + 1] = -1
        pending[t], pending_song[t] = nil, nil
        if not (zone_song ~= nil and (t == 0 or t == 1)) then
            local song = default_for(t)
            if song ~= nil then
                ok = set_music(t, song) or ok
                if shown == nil and song ~= 0 then shown = song end
            end
        end
    end
    if zone_song ~= nil then
        ok = apply_zone_override(zone) or ok
        shown = zone_song
    end
    settings.save()
    report(ok, song_name(shown))
end

-- ImGui helpers --------------------------------------------------------------

local function begin_table(id)
    if not imgui.BeginTable then return false, false end

    local flags = bit.bor(ImGuiTableFlags_RowBg or 0, ImGuiTableFlags_BordersInnerV or 0,
                          ImGuiTableFlags_Resizable or 0, ImGuiTableFlags_ScrollY or 0)
    local open = imgui.BeginTable(id, 3, flags, { 0, 0 })
    if open then
        imgui.TableSetupScrollFreeze(0, 1)
        imgui.TableSetupColumn('Fav',  ImGuiTableColumnFlags_WidthFixed or 0, 34)
        imgui.TableSetupColumn('Song', ImGuiTableColumnFlags_WidthStretch or 0, 3)
        imgui.TableSetupColumn('Used for', ImGuiTableColumnFlags_WidthStretch or 0, 2)
        imgui.TableHeadersRow()
    end
    return true, open
end

local function song_visible(s, f)
    local in_group = (ui.group == 0) or (data.group_of[s.id] == ui.group)
    if ui.favs_only[1] and not fav[s.id] then return false end
    return in_group and (f == '' or s.name:lower():find(f, 1, true) ~= nil
                         or (used_for_search[s.id] ~= nil and used_for_search[s.id]:find(f, 1, true) ~= nil))
end

local function fav_checkbox(s)
    fav_box[s.id] = fav_box[s.id] or { false }
    fav_box[s.id][1] = (fav[s.id] == true)
    if imgui.Checkbox('##fav' .. s.id, fav_box[s.id]) then
        set_favourite(s.id, fav_box[s.id][1])
    end
end

local function used_for_text(s)
    local entries = data.used_for[s.id]
    if used_for_label[s.id] ~= nil then
        imgui.TextDisabled(used_for_label[s.id])
        if #entries > 1 and imgui.IsItemHovered() then
            imgui.SetTooltip(table.concat(entries, '\n'))
        end
    end
end

-- one table row: Fav | Song | Zone
local function draw_table_row(s, sel)
    imgui.TableNextRow()
    imgui.TableNextColumn()
    fav_checkbox(s)
    imgui.TableNextColumn()
    if imgui.Selectable(('%d: %s'):format(s.id, s.name), sel == s.id) then
        apply(s.id, ui.type[1])
    end
    imgui.TableNextColumn()
    used_for_text(s)
end

-- fallback row for builds without ImGui tables
local function draw_plain_row(s, sel)
    fav_checkbox(s)
    imgui.SameLine()
    if imgui.Selectable(('%d: %s'):format(s.id, s.name), sel == s.id) then
        apply(s.id, ui.type[1])
    end
    if zone_label[s.id] ~= nil then
        imgui.SameLine(USED_FOR_COLUMN_X)
        used_for_text(s)
    end
end

local function song_combo(label, selected, filter)
    local id = selected[1]
    local title = ('%d: %s'):format(id, data.songs[id] or 'Select a song')
    if imgui.BeginCombo(label, title) then
        imgui.InputText('Search##' .. label, filter, 64)
        local query = filter[1]:lower()
        for _, song in ipairs(list) do
            local id_text = tostring(song.id)
            if query == '' or id_text:find(query, 1, true) or song.name:lower():find(query, 1, true)
                or (used_for_search[song.id] ~= nil and used_for_search[song.id]:find(query, 1, true)) then
                if imgui.Selectable(('%d: %s##%s%d'):format(song.id, song.name, label, song.id), id == song.id) then
                    selected[1] = song.id
                end
            end
        end
        imgui.EndCombo()
    end
end

local function draw_replacer_tab()
    imgui.TextWrapped('Replace a song ID anywhere it plays. The original song plays when no replacement is configured.')
    song_combo('Song to replace', ui.replace_from, ui.replace_from_filter)
    song_combo('Play instead', ui.replace_to, ui.replace_to_filter)
    if imgui.Button('Add / Update replacement') then
        local from, to = ui.replace_from[1], ui.replace_to[1]
        if from == to then
            print('[setbgm] choose two different songs')
        else
            cfg.replacements[from] = to
            settings.save()
            apply_zone_replacements(current_zone(), true)
        end
    end
    imgui.Separator()
    imgui.Text('Configured replacements')
    local sources = {}
    for from in pairs(cfg.replacements or {}) do sources[#sources + 1] = tonumber(from) end
    table.sort(sources)
    if #sources == 0 then imgui.TextDisabled('No replacements configured.') end
    for _, from in ipairs(sources) do
        local to = cfg.replacements[from] or cfg.replacements[tostring(from)]
        if imgui.SmallButton(('Remove##replacement%d'):format(from)) then
            cfg.replacements[from] = nil
            cfg.replacements[tostring(from)] = nil
            settings.save()
            restore_zone_song(from, tonumber(to))
        end
        imgui.SameLine()
        if imgui.SmallButton(('Update##replacement%d'):format(from)) then
            force_song_replacement(from, tonumber(to))
        end
        if imgui.IsItemHovered() then
            imgui.SetTooltip('Use this button if the replacement did not initially work.')
        end
        imgui.SameLine()
        imgui.Text(('%d: %s  ->  %d: %s'):format(from, song_name(from), to, song_name(to)))
    end
end

local function zone_combo(label, selected, filter)
    local id = selected[1]
    local title = zone_names[id] or ('Zone %d'):format(id)
    if imgui.BeginCombo(label, title) then
        imgui.InputText('Search##' .. label, filter, 64)
        local query = filter[1]:lower()
        for _, zone in ipairs(zone_list) do
            local id_text = tostring(zone.id)
            if query == '' or id_text:find(query, 1, true) or zone.name:lower():find(query, 1, true) then
                if imgui.Selectable(('%s##%s%d'):format(zone.name, label, zone.id), id == zone.id) then
                    selected[1] = zone.id
                end
            end
        end
        imgui.EndCombo()
    end
end

local function draw_zone_replacer_tab()
    imgui.TextWrapped('Choose a song to play as the zone theme. This works even when the zone has no default song.')
    zone_combo('Zone Name', ui.selected_zone, ui.zone_filter)
    song_combo('Play in this zone', ui.zone_song, ui.zone_song_filter)
    if imgui.Button('Set zone music') then
        local zone, song = ui.selected_zone[1], ui.zone_song[1]
        cfg.zone_replacements[zone] = song
        settings.save()
        if current_zone() == zone then
            for _, t in ipairs({ 0, 1 }) do pending[t], pending_song[t] = nil, nil end
            apply_zone_override(zone)
        end
    end
    imgui.Separator()
    imgui.Text('Configured zone music')
    local zones = {}
    for zone in pairs(cfg.zone_replacements or {}) do zones[#zones + 1] = tonumber(zone) end
    table.sort(zones, function(a, b)
        return (zone_names[a] or tostring(a)) < (zone_names[b] or tostring(b))
    end)
    if #zones == 0 then imgui.TextDisabled('No zone music configured.') end
    for _, zone in ipairs(zones) do
        local song = cfg.zone_replacements[zone] or cfg.zone_replacements[tostring(zone)]
        if imgui.SmallButton(('Remove##zone%d'):format(zone)) then
            cfg.zone_replacements[zone] = nil
            cfg.zone_replacements[tostring(zone)] = nil
            settings.save()
            if current_zone() == zone then
                for _, t in ipairs({ 0, 1 }) do pending[t], pending_song[t] = nil, nil end
                restore_zone_override(zone)
            end
        end
        imgui.SameLine()
        if imgui.SmallButton(('Update##zone%d'):format(zone)) then
            if current_zone() == zone then
                for _, t in ipairs({ 0, 1 }) do pending[t], pending_song[t] = nil, nil end
                apply_zone_override(zone)
            else
                print(('[setbgm] zone music can only be updated while in %s'):format(zone_names[zone] or tostring(zone)))
            end
        end
        if imgui.IsItemHovered() then
            imgui.SetTooltip('Reapply this zone\'s assigned song, use if the replacement did not initially work.')
        end
        imgui.SameLine()
        imgui.Text(('%s  ->  %d: %s'):format(zone_names[zone] or ('Zone %d'):format(zone), song, song_name(song)))
    end
end

-- Events -------------------------------------------------------------------

local help_lines = {
    { '/setbgm',                        'toggle the window' },
    { '/setbgm <song id>',              'set all available music types to a song' },
    { '/setbgm <song id> <type id>',    'set one music type (0-4) to a song' },
    { '/setbgm reset',                  "clear choices and restore the zone's normal music" },
    { '/setbgm mute [type id]',         'stay silent (also after zoning) until reset' },
    { '/setbgm color <n>',              'chat color code for the song name in "Now playing"' },
    { '/setbgm list',                   'list the music types (0-4)' },
    { '/setbgm defaults',               "show each type's zone default and your current choice" },
    { '/setbgm debug',                  'toggle logging of music packets sent by the server' },
    { '/setbgm help',                   'show this list' },
}

local function show_help()
    print('[setbgm] Commands:')
    for _, h in ipairs(help_lines) do
        print(('[setbgm]   %s - %s'):format(h[1], h[2]))
    end
end

ashita.events.register('command', 'setbgm_command', function(e)
    local args = e.command:args()
    if #args == 0 or args[1]:lower() ~= '/setbgm' then return end
    e.blocked = true
    local command = args[2] and args[2]:lower()

    if #args == 1 then
        ui.open[1] = not ui.open[1]
    elseif command == 'help' then
        show_help()
    elseif command == 'reset' then
        reset()
    elseif command == 'debug' then
        debug_log = not debug_log
        print(('[setbgm] debug logging %s'):format(debug_log and 'ON' or 'OFF'))
    elseif command == 'defaults' then
        print(('[setbgm] current zone id: %s'):format(tostring(current_zone())))
        for _, t in ipairs(managed_packet_types) do
            local song, src = default_for(t)
            print(('[setbgm] %d %-14s default=%s%s  chosen=%s'):format(
                t, data.types[t], song and tostring(song) or 'unknown', src and (' (' .. src .. ')') or '',
                tostring(cfg.chosen[t + 1])))
        end
    elseif command == 'color' and tonumber(args[3]) then
        cfg.name_color = math.floor(tonumber(args[3]))
        settings.save()
        report(true, 'song name color ' .. cfg.name_color)
    elseif command == 'mute' then
        mute(tonumber(args[3]))
    elseif command == 'list' then
        for g = 0, last_music_type do print(('[setbgm] %d: %s'):format(g, music_types[g].name)) end
    elseif tonumber(args[2]) then
        apply(tonumber(args[2]), tonumber(args[3]))
    else
        print('[setbgm] Unknown or incomplete command. Type /setbgm help for the list.')
    end
end)

ashita.events.register('packet_in', 'setbgm_packet_in', function(e)
    if e.id == 0x05F then
        local t    = e.data:byte(5) + e.data:byte(6) * 256
        local song = e.data:byte(7) + e.data:byte(8) * 256
        local mine = (recent[t] ~= nil and recent[t][song] ~= nil and os.clock() < recent[t][song])
        if debug_log and not (e.injected or mine) then
            print(('[setbgm] 0x05F from server: type=%d song=%d'):format(t, song))
        end
        if e.injected or mine then return end

        -- server set a music type (zone default, entering battle, ...)
        if t >= 0 and t <= 7 then
            server_song[t] = song
            if t == 0 or t == 1 then current_zone_theme = song end

            local chosen = cfg.chosen[t + 1]
            local replacement = replacement_for(song)
            local zone_song = (t == 0 or t == 1) and zone_override_for(current_zone()) or nil
            local play_song
            if zone_song ~= nil then
                play_song = zone_song
            elseif replacement ~= song then
                play_song = replacement
            elseif cfg.reapply and chosen ~= nil and chosen ~= -1 and song ~= chosen then
                play_song = chosen
            end
            if play_song ~= nil then
                -- Block the server's original packet and inject the selected/replacement song next frame.
                e.blocked = true
                pending[t], pending_song[t] = os.clock(), play_song
                if debug_log then
                    print(('[setbgm] replacing incoming song %d with %d (type %d)'):format(song, play_song, t))
                end
            end
        end
    elseif e.id == 0x00A and not e.injected then
        -- zoned: forget old defaults (the server sends new ones) and re-apply our choices after a delay
        if debug_log then print('[setbgm] zone-in packet; cleared cached defaults') end
        server_song = {}
        current_zone_theme = nil
        pending, pending_song = {}, {}
        local zone = e.data:byte(0x31) + e.data:byte(0x32) * 256
        zone_replacer_pending = zone
        local has_zone_override = zone_override_for(zone) ~= nil
        if cfg.reapply then
            for _, t in ipairs(managed_packet_types) do
                local zone_music_selected = has_zone_override and (t == 0 or t == 1)
                if cfg.chosen[t + 1] ~= -1 and not zone_music_selected then
                    pending[t] = os.clock() + 3.0
                end
            end
        end
    end
end)

ashita.events.register('d3d_present', 'setbgm_present', function()
    -- process deferred re-applies
    local now = os.clock()
    for t, when in pairs(pending) do
        if now >= when then
            pending[t] = nil
            local song = pending_song[t] or cfg.chosen[t + 1]
            pending_song[t] = nil
            if song ~= -1 then set_music(t, song) end
        end
    end

    if zone_replacer_pending ~= nil then
        local zone = zone_replacer_pending
        zone_replacer_pending = nil
        if zonemusic[zone] ~= nil then
            apply_zone_override(zone)
            apply_zone_replacements(zone, false)
        elseif debug_log then
            print(('[setbgm] no zone music row found for zone %s'):format(tostring(zone)))
        end
    end

    if not ui.open[1] then return end

    imgui.SetNextWindowSize({ 660, 500 }, ImGuiCond_FirstUseEver)
    if imgui.Begin('SetBGM', ui.open) then
        if imgui.BeginTabBar('setbgm_tabs') then
            if imgui.BeginTabItem('Main') then
        local label = (ui.type[1] == -1) and 'All types' or music_types[ui.type[1]].name
        if imgui.BeginCombo('Music type', label) then
            if imgui.Selectable('All types', ui.type[1] == -1) then ui.type[1] = -1 end
            for g = 0, last_music_type do
                if imgui.Selectable(music_types[g].name, ui.type[1] == g) then ui.type[1] = g end
            end
            imgui.EndCombo()
        end

        if imgui.Checkbox('Re-apply after zoning / music changes', ui.reapply) then
            cfg.reapply = ui.reapply[1]
            settings.save()
        end

        if imgui.Button('Set Battle Music to Current Zone Theme') then set_battle_to_zone_theme() end
        if imgui.IsItemHovered() then
            imgui.SetTooltip('Copies the current zone idle song to both solo and party battle music.')
        end

        imgui.SameLine()
        if imgui.Button('Reset') then reset() end
        imgui.SameLine()
        if imgui.Button('Mute') then mute(ui.type[1]) end
        if imgui.IsItemHovered() then imgui.SetTooltip('Stay silent (also after zoning) until Reset') end

        local glabel
        if ui.group == 0 then
            glabel = ('All songs (%d)'):format(#list)
        else
            glabel = ('%s (%d)'):format(data.groups[ui.group].name, group_count[ui.group] or 0)
        end
        if imgui.BeginCombo('Expansion', glabel) then
            if imgui.Selectable(('All songs (%d)'):format(#list), ui.group == 0) then ui.group = 0 end
            for gi, g in ipairs(data.groups) do
                if imgui.Selectable(('%s (%d)'):format(g.name, group_count[gi] or 0), ui.group == gi) then
                    ui.group = gi
                end
            end
            imgui.EndCombo()
        end

        imgui.Checkbox(('Show favourites only (%d)###favs_only'):format(fav_count), ui.favs_only)

        imgui.InputText('Search', ui.filter, 64)
        imgui.Separator()

        -- current selection per type
        for g = 0, last_music_type do
            local names = {}
            for _, t in ipairs(music_types[g].packet_types) do
                local s = cfg.chosen[t + 1]
                names[#names + 1] = (s == -1) and '(default)' or data.songs[s] or (s == MUTE_SONG_ID and '(mute)') or tostring(s)
            end
            -- merged entries (Idle) show one name unless day and night differ
            local label = names[1]
            for i = 2, #names do
                if names[i] ~= names[1] then
                    label = table.concat(names, ' / ')
                    break
                end
            end
            imgui.TextDisabled(('%s: %s'):format(music_types[g].name, label))
        end
        imgui.Separator()

        local f   = ui.filter[1]:lower()
        local sel = (ui.type[1] ~= -1) and cfg.chosen[music_types[ui.type[1]].packet_types[1] + 1] or nil

        local supported, open = begin_table('songtable')
        if supported then
            if open then
                for _, song in ipairs(list) do
                    if song_visible(song, f) then draw_table_row(song, sel) end
                end
                imgui.EndTable()
            end
        else
            if imgui.BeginChild('songlist', { 0, 0 }) then
                imgui.TextDisabled('Fav / Song')
                imgui.SameLine(USED_FOR_COLUMN_X)
                imgui.TextDisabled('Used for')
                for _, song in ipairs(list) do
                    if song_visible(song, f) then draw_plain_row(song, sel) end
                end
            end
            imgui.EndChild()
        end
            imgui.EndTabItem()
            end
            if imgui.BeginTabItem('Song Replacer') then
                draw_replacer_tab()
                imgui.EndTabItem()
            end
            if imgui.BeginTabItem('Zone Replacer') then
                draw_zone_replacer_tab()
                imgui.EndTabItem()
            end
            imgui.EndTabBar()
        end
    end
    imgui.End()
end)