UtilizenAFKHandler:
    type: world
    debug: false
    events:
        on player walks flagged:afk:
        - if <player.has_flag[afk]>:
            - narrate "<yaml[UtilizenLang].read[afkback].parsed.parse_color>" targets:<server.list_online_players>
            - flag player afk:!
            - permission remove smoothsleep.ignore
        on player chats flagged:afk:
        - narrate "<yaml[UtilizenLang].read[afkback].parsed.parse_color>" targets:<server.list_online_players>
        - flag player afk:!
        - permission remove smoothsleep.ignore
UtilizenBedSpawnHandler:
    type: world
    debug: false
    events:
        on player right clicks *_BED:
        - if <yaml[UtilizenConfig].read[allow-bed]>:
            - yaml id:UtilizenPlayerdata set <player.uuid>.spawnlocation:<context.location>
            - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
            - adjust <player> bed_spawn_location:<context.location>
            - narrate "<yaml[UtilizenLang].read[bedspawnset].parsed.parse_color>"
        on player right clicks with COMPASS:
        - if <yaml[UtilizenPlayerdata].read[<player.uuid>.spawnlocation]||null> == null:
            - narrate "<yaml[UtilizenLang].read[comnobedspawn].parsed.parse_color>"
            - stop
        - if <player.compass_target> == <yaml[UtilizenPlayerdata].read[<player.uuid>.spawnlocation]>:
            - compass <world[test1].spawn_location>
            - narrate "<yaml[UtilizenLang].read[comspawn].parsed.parse_color>"
            - stop
        - else:
            - compass <yaml[UtilizenPlayerdata].read[<player.uuid>.spawnlocation]>
            - narrate "<yaml[UtilizenLang].read[combedspawn].parsed.parse_color>"
        on player respawns:
        - if <yaml[UtilizenConfig].read[allow-bed]>:
            - if <yaml[UtilizenPlayerdata].read[<player.uuid>.spawnlocation]||false>:
                - determine <yaml[UtilizenPlayerdata].read[<player.uuid>.spawnlocation]>
        - else:
            - determine <world[test1].spawn_location>
UtilizenNickHandler:
    type: world
    debug: false
    events:
        on player joins:
        - if <yaml[UtilizenPlayerdata].read[<player.uuid>.nickname]||null> == null:
            - stop
        - else:
            - adjust <player> player_list_name:<yaml[UtilizenPlayerdata].read[<player.uuid>.nickname]>
UtilizenBackHandler:
    type: world
    debug: false
    events:
        on player teleports:
        - yaml id:UtilizenPlayerdata set <player.uuid>.lastlocation:<context.origin>
        - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
        on player dies:
        - yaml id:UtilizenPlayerdata set <player.uuid>.lastlocation:<context.entity.location>
        - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
UtilizenMuteHandler:
    type: world
    debug: false
    events:
        on player chats priority:-1:
        - if <player.has_flag[mute]>:
            - narrate "<yaml[UtilizenLang].read[muteyouremuted].parse.parse_color>"
            - determine passively cancelled
UtilizenGodHandler:
    type: world
    debug: false
    events:
        on player damaged:
        - if <player.has_flag[god]>:
            - determine cancelled
UtilizenJailHandler:
    type: world
    debug: false
    events:
        on player teleports flagged:jailed:
        - narrate "<yaml[UtilizenLang].read[jailnopermission].parse.parse_color>"
        - determine cancelled