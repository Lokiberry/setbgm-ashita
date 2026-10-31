--[[
Music types and soundtrack groups adapted from setbgm for Windower.
Song IDs, titles, and documented uses are based on LandSandBoat's MusicIDs.txt:
https://github.com/LandSandBoat/server/blob/base/docs/MusicIDs.txt
Phoenix's copy of this catalog was used during preparation.
--]]

local types = {
    [0] = 'Idle (Day)',
    [1] = 'Idle (Night)',
    [2] = 'Battle (Solo)',
    [3] = 'Battle (Party)',
    [4] = 'Chocobo',
    [6] = 'Mog House',
}

-- Named song IDs and official titles based on LandSandBoat's MusicIDs.txt:
-- https://github.com/LandSandBoat/server/blob/base/docs/MusicIDs.txt
local songs = {
    [28]="The Destiny Destroyers", [40]="Cloister of Time and Souls", [41]="Royal Wanderlust", [42]="Snowdrift Waltz", [43]="Troubled Shadows", [44]="Where Lords Rule Not",
    [45]="Summers Lost", [46]="Goddess Divine", [47]="Echoes of Creation", [48]="Main Theme", [49]="Luck of the Mog", [50]="Feast of the Ladies",
    [51]="Scarlet Skies, Shadowed Plains", [52]="Melodies Errant", [53]="Shinryu", [54]="Everlasting Bonds", [55]="Provenance Watcher", [56]="Where it All Begins",
    [57]="Steel Sings, Blades Dance", [58]="A New Direction", [59]="The Pioneers", [60]="Into Lands Primeval", [61]="Water's Umbral Knell", [62]="Keepers of the Wild",
    [63]="The Sacred City of Adoulin", [64]="Breaking Ground", [65]="Hades", [66]="Arciela", [67]="Mog Resort", [68]="Worlds Away",
    [69]="Distant Worlds", [70]="Monstrosity", [71]="The Pioneers (Piano)", [72]="The Divine", [73]="The Serpentine Labyrinth", [74]="Clouds Over Ulbuka",
    [75]="The Price", [76]="Forever Today", [77]="Distant Worlds (Instrumental)", [78]="Forever Today (EP. Ver - Instrumental)", [79]="Iroha", [80]="The Boundless Black",
    [81]="Isle of the Gods", [82]="Wail of the Void", [83]="Rhapsodies of Vana'diel", [84]="Full Speed Ahead!", [85]="Ambuscade", [86]="Awakening",
    [87]="Unknown Title", [88]="Unknown Title", [89]="Unknown Title", [90]="Unknown Title", [101]="Battle Theme", [102]="Battle in the Dungeon #2",
    [103]="Battle Theme #2", [104]="A Road Once Travelled", [105]="Mhaura", [106]="Voyager", [107]="The Kingdom of San d'Oria", [108]="Van'diel March",
    [109]="Ronfaure", [110]="The Grand Duchy of Jeuno", [111]="Blackout", [112]="Selbina", [113]="Sarutabaruta", [114]="Batallia",
    [115]="Battle in the Dungeon", [116]="Gustaberg", [117]="Re'Lude Gardens", [118]="Rolanberry Fields", [119]="Awakening", [120]="Vana'diel March #2",
    [121]="Shadow Lord", [122]="One Last Time", [123]="Hopelessness", [124]="Recollection", [125]="Tough Battle", [126]="Mog House",
    [127]="Anxiety", [128]="Airship", [129]="Hook, Line and Sinker", [130]="Tarutaru Female", [131]="Elvaan Female", [132]="Elvaan Male",
    [133]="Hume Male", [134]="Yuhtunga Jungle", [135]="Kazham", [136]="The Big One", [137]="A Realm of Emptiness", [138]="Mercenaries' Delight",
    [139]="Delve", [140]="Wings of the Goddess", [141]="The Cosmic Wheel", [142]="Fated Strife", [143]="Hellriders", [144]="Rapid Onslaught",
    [145]="Encampment Dreams", [146]="The Colosseum", [147]="Eastward Bound", [148]="Forbidden Seal", [149]="Jeweled Boughs", [150]="Ululations from Beyond",
    [151]="The Federation of Windurst", [152]="The Republic of Bastok", [153]="Prelude", [154]="Metalworks", [155]="Castle Zvahl", [156]="Chateau d'Oraguille",
    [157]="Fury", [158]="Sauromugue Champaign", [159]="Sorrow", [160]="Repression (Memoro)", [161]="Despair (Memoro)", [162]="Heavens Tower",
    [163]="Sometime, Somewhere", [164]="Xarcabard", [165]="Galka", [166]="Mithra", [167]="Tarutaru Male", [168]="Hume Female",
    [169]="Regeneracy", [170]="Buccaneers", [171]="Altepa Desert", [172]="Black Coffin", [173]="Illusions in the Mist", [174]="Whispers of the Gods",
    [175]="Bandits' Market", [176]="Circuit de Chocobo", [177]="Run Chocobo, Run!", [178]="Bustle of the Capital", [179]="Vana'diel March #4", [180]="Thunder of the March",
    [181]="Dash de Chocobo", [182]="Stargazing", [183]="A Puppet's Slumber", [184]="Eternal Gravestone", [185]="Ever-turning Wheels", [186]="Iron Colossus",
    [187]="Ragnarok", [188]="Choc-a-bye Baby", [189]="An Invisible Crown", [190]="The Sanctuary of Zi'Tah", [191]="Battle Theme #3", [192]="Battle in the Dungeon #3",
    [193]="Tough Battle #2", [194]="Bloody Promises", [195]="Belief", [196]="Fighters of the Crystal", [197]="To the Heavens", [198]="Eald'narche",
    [199]="Grav'iton", [200]="Hidden Truths", [201]="End Theme", [202]="Moongate (Memoro)", [203]="Ancient Verse of Uggalepih", [204]="Ancient Verse of Ro'Maeve",
    [205]="Ancient Verse of Altepa", [206]="Revenant Maiden", [207]="Ve'Lugannon Palace", [208]="Rabao", [209]="Norg", [210]="Ru'Aun Gardens",
    [211]="Ro'Maeve", [212]="Dash de Chocobo", [213]="Hall of the Gods", [214]="Eternal Oath", [215]="Clash of Standards", [216]="On This Blade",
    [217]="Kindred Cry", [218]="Depths of the Soul", [219]="Onslaught", [220]="Turmoil", [221]="Moblin Menagerie", [222]="Faded Memories",
    [223]="March of the Hero", [224]="Dusk and Dawn", [225]="Words Unspoken", [226]="You Want to Live Forever?", [227]="Sunbreeze Shuffle", [228]="Gates of Paradise",
    [229]="Currents of Time", [230]="A New Horizon", [231]="Celestial Thunder", [232]="The Ruler of the Skies", [233]="The Celestial Capital", [234]="Happily Ever After",
    [235]="Nocturne of the Gods", [236]="Clouded Dawn", [237]="Memoria de la Stona", [238]="A New Morning", [239]="Starlight Celebration", [240]="Distant Promises",
    [241]="A Time for Prayer", [242]="Unity", [243]="Grav'iton", [244]="Revenant Maiden", [245]="The Forgotten City", [246]="March of the Allied Forces",
    [247]="Roar of the Battle Drums", [248]="Young Griffons in Flight", [249]="Run maggot, run!", [250]="Under a Clouded Moon", [251]="Autumn Footfalls", [252]="Flowers on the Battlefield",
    [253]="Echoes of a Zephyr", [254]="Griffons Never Die",
}


-- LandSandBoat's slash-separated "Used for" values, split for display in the UI.
-- Source: https://github.com/LandSandBoat/server/blob/base/docs/MusicIDs.txt
local used_for = {
    [28] = { "TVR" },
    [40] = { "CS" },
    [41] = { "Cait Sith Theme" },
    [42] = { "Xarcabard [S]" },
    [43] = { "Castle Zvahl Baileys [S]", "Castle Zvahl Keep [S]" },
    [44] = { "La Vaule [S]", "Beadeaux [S]", "Castle Oztroja [S]" },
    [45] = { "CS" },
    [46] = { "WotG Final Battle" },
    [47] = { "ACP Final Battle" },
    [48] = { "CS" },
    [49] = { "AMK Final Battle" },
    [50] = { "ASA Final Battle" },
    [51] = { "Abyssea" },
    [52] = { "Battle (Abyssea zones)" },
    [53] = { "Shinryu" },
    [54] = { "CS" },
    [55] = { "Provenance Watcher Battle" },
    [56] = { "Provenance" },
    [57] = { "Battle (Seekers zones)" },
    [58] = { "Title Screen 5 (Seekers)" },
    [59] = { "Western Adoulin" },
    [60] = { "Yahse Hunting Grounds", "Ceizak Battlegrounds", "Foret de Hennetiel", "Morimar Basalt Fields", "Marjami Ravine" },
    [61] = { "Rala Waterways", "Yorcia Weald" },
    [62] = { "Wildkeeper Reive, Seekers instances" },
    [63] = { "Eastern Adoulin", "Celennia Memorial Library" },
    [64] = { "Colonization Reive" },
    [65] = { "CS" },
    [66] = { "CS" },
    [67] = { "Mog Garden" },
    [68] = { "CS" },
    [69] = { "CS" },
    [70] = { "Monstrosity" },
    [71] = { "CS" },
    [72] = { "Kamihr Drifts" },
    [73] = { "Outer Ra'Kaznar" },
    [74] = { "Balamor's theme song" },
    [75] = { "Adoulin Final Battle" },
    [76] = { "Adoulin Ending Song" },
    [79] = { "Reisenjima, Rhapsodies CS music" },
    [80] = { "Escha Zi'Tah, Escha Ru'Aun" },
    [81] = { "Rhapsodies final boss" },
    [82] = { "Rhapsodies finale" },
    [83] = { "Ending Song" },
    [84] = { "Mount riding music" },
    [85] = { "Legion" },
    [86] = { "Dynamis, Shadow Lord Fight" },
    [87] = { "Omen" },
    [88] = { "Dynamis Divergence" },
    [89] = { "Dynamis Divergence" },
    [90] = { "???" },
    [101] = { "Battle (solo, outdoor, )" },
    [102] = { "Battle (party, dungeon, original zones)" },
    [103] = { "Battle (party, outdoor, )" },
    [104] = { "CS" },
    [105] = { "Mhaura" },
    [106] = { "Boats to/from Selbina/Mhaura" },
    [107] = { "Southern San dOria", "Northern San dOria", "Port San dOria" },
    [108] = { "Title Screen 1 (Original+Zilart)" },
    [109] = { "East Ronfaure", "West Ronfaure" },
    [110] = { "Upper Jeuno", "Lower Jeuno", "Port Jeuno" },
    [111] = { "Death" },
    [112] = { "Selbina" },
    [113] = { "East Sarutabaruta", "West Sarutabaruta" },
    [114] = { "Batallia Downs" },
    [115] = { "Battle (solo, dungeon, original zones)" },
    [116] = { "North Gustaberg", "South Gustaberg" },
    [117] = { "RuLude Gardens" },
    [118] = { "Rolanberry Fields" },
    [119] = { "Dynamis-Xarcabard", "Shadow Lord fight" },
    [120] = { "Nation Selection" },
    [121] = { "Dynamis-Valkurm", "Dynamis-Buburimu", "Dynamis-Qufim", "Dynamis-Tavnazia", "Dynamis-Beaucedine", "Dynamis-San dOria", "Dynamis-Bastok", "Dynamis-Windurst", "Dynamis-Jeuno" },
    [122] = { "CS" },
    [123] = { "CS" },
    [124] = { "CS" },
    [125] = { "BCNM (original)" },
    [126] = { "Mog House" },
    [127] = { "CS" },
    [128] = { "Airship" },
    [129] = { "Fishing 1" },
    [130] = { "Character Creation - Taru Female" },
    [131] = { "Character Creation - Elvaan Female" },
    [132] = { "Character Creation - ELvaan Male" },
    [133] = { "Character Creation - Hume Male" },
    [134] = { "Yuhtunga Jungle", "Yhoator Jungle" },
    [135] = { "Kazham" },
    [136] = { "Fishing 2" },
    [137] = { "CoP Final Boss" },
    [138] = { "Battle (party, Outdoor, Aht Urhgan Zones)" },
    [139] = { "Battle (party, indoor, Aht Urhgan Zones)" },
    [140] = { "Title Screen 4 (WotG)" },
    [141] = { "West Sarutabaruta [S]" },
    [142] = { "Besieged" },
    [143] = { "Einherjar" },
    [144] = { "Assault" },
    [145] = { "CS" },
    [146] = { "Pankration" },
    [147] = { "Boats to/from Nashmau/Al Zahbi" },
    [148] = { "Nyzul Isle", "Salvage" },
    [149] = { "Wajaom Woodlands", "Bhaflau Thickets" },
    [150] = { "Arrapago Reef" },
    [151] = { "Windurst Waters", "Windurst Walls", "Windurst Woods", "Port Windurst" },
    [152] = { "Bastok Mines", "Bastok Markets", "Port Bastok" },
    [153] = { "CS" },
    [154] = { "Metalworks" },
    [155] = { "Castle Zvahl Baileys", "Castle Zvahl Keep", "Throne Room" },
    [156] = { "Chateau dOraguille" },
    [157] = { "CS" },
    [158] = { "Sauromugue Champaign" },
    [159] = { "CS" },
    [160] = { "CS" },
    [161] = { "CS" },
    [162] = { "Heavens Tower" },
    [163] = { "CS" },
    [164] = { "Xarcabard" },
    [165] = { "Character Creation - Galka" },
    [166] = { "Character Creation - Mithra" },
    [167] = { "Character Creation - Taru Male" },
    [168] = { "Character Creation - Hume Female" },
    [169] = { "CS" },
    [170] = { "Pirate Attacks" },
    [171] = { "Eastern Altepa Desert", "Western Altepa Desert" },
    [172] = { "The Ashu Talif" },
    [173] = { "Caedarva Mire" },
    [174] = { "Aydeewa Subterrane" },
    [175] = { "Nashmau" },
    [176] = { "Chocobo Circuit" },
    [177] = { "Chocobo (full length)" },
    [178] = { "Al Zahbi", "Aht Urhgan Whitegate" },
    [179] = { "Title Screen 3 (ToAU)" },
    [180] = { "Bastok Markets [S]" },
    [181] = { "Chocobo (short)" },
    [182] = { "Windurst Waters [S]" },
    [183] = { "Aphmau's Theme" },
    [184] = { "Luzaf's Theme" },
    [185] = { "CS" },
    [186] = { "Odin's Theme" },
    [187] = { "Alexander's Theme" },
    [188] = { "CS" },
    [189] = { "CS" },
    [190] = { "The Sanctuary of Zi'Tah" },
    [191] = { "Battle (party, outdoor, zilart zone)" },
    [192] = { "Battle (party, dungeon, zilart zone)" },
    [193] = { "BCNM (Zilart)" },
    [194] = { "CS" },
    [195] = { "Eald'narche (phase 2)" },
    [196] = { "Ark angels", "Divine Might" },
    [197] = { "CS" },
    [198] = { "CS and Eald'narche (phase 1)" },
    [199] = { "CS" },
    [200] = { "CS" },
    [201] = { "Zilart Ending CS" },
    [202] = { "CS", "Memoria de la s^tona" },
    [203] = { "CS" },
    [204] = { "CS" },
    [205] = { "CS" },
    [206] = { "CS" },
    [207] = { "VeLugannon Palace", "The Shrine of RuAvitau" },
    [208] = { "Rabao" },
    [209] = { "Norg" },
    [210] = { "RuAun Gardens" },
    [211] = { "RoMaeve" },
    [212] = { "Chocobo (long)" },
    [213] = { "Hall of the Gods" },
    [214] = { "Wedding Music" },
    [215] = { "Battle (party, outdoor, WotG zones)" },
    [216] = { "Battle (party, dungeon, WotG zones)" },
    [217] = { "Spitewardens theme (CS and WotG BCNMs)" },
    [218] = { "Battle (party, dungeon, CoP zones)" },
    [219] = { "Battle (party, outdoor, CoP zones)" },
    [220] = { "BCNM (CoP)" },
    [221] = { "Oldton Movalpolos", "Newton Movalpolos" },
    [222] = { "Promyvion-Holla", "Promyvion-Dem", "Promyvion-Mea", "Promyvion-Vahzl" },
    [223] = { "Conflict" },
    [224] = { "Promathia phase 1" },
    [225] = { "PsoXja" },
    [226] = { "Conflict" },
    [227] = { "Summer Festival" },
    [228] = { "The Garden of RuHmet" },
    [229] = { "Phanauet Channel", "Manaclipper" },
    [230] = { "Lufaise Meadows", "Misareaux Coast" },
    [231] = { "CS" },
    [232] = { "Bahamut's Theme" },
    [233] = { "Al'Taieu" },
    [234] = { "CS" },
    [235] = { "CS" },
    [236] = { "CS" },
    [237] = { "CS" },
    [238] = { "CS" },
    [239] = { "Christmas in Jeuno" },
    [240] = { "CS" },
    [241] = { "CS" },
    [242] = { "Title Screen 2 (CoP)" },
    [243] = { "CS" },
    [244] = { "CS" },
    [245] = { "Tavnazian Safehold", "Sealions Den" },
    [246] = { "CS" },
    [247] = { "Campaign Battle" },
    [248] = { "CS" },
    [249] = { "Ghoyu's Reverie, everbloom Hollow, Ruhotz Silvermines" },
    [250] = { "CS" },
    [251] = { "East Ronfaure [S]" },
    [252] = { "Batallia Downs [S]", "Rolanberry Fields [S]", "Sauromugue Champaign [S]" },
    [253] = { "North Gustaberg [S]" },
    [254] = { "Southern San dOria [S]" },
}

-- Expansion groups follow soundtrack releases. Battle contains dedicated battle,
-- boss, BCNM, Reive, and combat-event tracks listed in Phoenix docs/MusicIDs.txt.
-- Expansion sources: Final Fantasy XI Original Soundtrack Premium Box and album track lists
-- on Wikipedia "Music of Final Fantasy XI". Unclassified tracks go to Other / unclassified.
local groups = {
    { name = 'FFXI - Base game',  ids = {
        
        105,106,107,108,109,110,111,112,113,114,116,117,118,120,123,124,126,127,128,130,131,132,133,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169
     } },
    { name = 'Rise of the Zilart',  ids = {
        
        134,135,171,181,190,199,201,207,208,209,210,211,212,213,243
     } },
    { name = 'Chains of Promathia',  ids = {
        
        221,222,224,225,228,229,230,233,234,235,236,237,238,240,241,242,245
     } },
    { name = 'Treasures of Aht Urhgan',  ids = {
        
        147,148,149,150,172,173,174,175,176,177,178,179,183,184,185
     } },
    { name = 'Unreleased Tracks (Premium Box)',  ids = {
        
        104,122,129,136,188,194,197,200,202,206,214,227,231,239,244
     } },
    { name = 'Wings of the Goddess (post-2007)', ids = {
        
        40,41,42,43,44,140,141,145,180,182,189,246,248,249,250,251,252,253,254
     } },
    { name = 'OST PLUS / Add-ons / Abyssea (post-2007)', ids = {
        
        45,48,51,54
     } },
    { name = 'Seekers of Adoulin (post-2007)', ids = {
        
        56,58,59,60,61,63,65,66,67,68,70,72,73,76
     } },
    { name = 'Rhapsodies of Vana\'diel (post-2007)', ids = {
        
        77,78,79,80,83
     } },
    { name = 'Battle', ids = {
        
        46,47,49,50,52,53,55,57,62,64,75,81,82,85,86,87,88,89,101,102,103,115,119,121,125,137,138,139,142,143,144,146,170,186,187,191,192,193,195,196,198,215,216,217,218,219,220,223,224,226,232,247
    
    } },
    { name = 'Other / unclassified', ids = {
        
        28,69,71,84,90,203,204,205
     } },
}

-- id -> group index; anything not listed falls into the last group
local group_of = {}
for gi, g in ipairs(groups) do
    for _, id in ipairs(g.ids) do group_of[id] = gi end
end
for id in pairs(songs) do
    if group_of[id] == nil then group_of[id] = #groups end
end

return { songs = songs, types = types, groups = groups, group_of = group_of, used_for = used_for }
