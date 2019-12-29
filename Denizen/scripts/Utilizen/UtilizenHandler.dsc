##############################################
#Author: Icecapade aka. Hydroxycobalamin
#
#You may use and modify this script for
#your own use.
#
#If you want to publish your modified
#version read the LICENSE-Terms here:
#https://github.com/Hydroxycobalamin/Utilizen
##############################################
UtilizenAFKHandler:
    type: world
    debug: false
    events:
        on player walks flagged:afk:
        - narrate <yaml[UtilizenLang].read[afkback].parsed> targets:<server.list_online_players>
        - flag player afk:!
        - permission remove smoothsleep.ignore
        on player chats flagged:afk:
        - narrate <yaml[UtilizenLang].read[afkback].parsed> targets:<server.list_online_players>
        - flag player afk:!
        - permission remove smoothsleep.ignore
UtilizenMOTD:
    type: world
    debug: false
    events:
        on player joins:
        - foreach <yaml[UtilizenConfig].read[motd]>:
            - narrate <[value].parsed>
UtilizenBedSpawnHandler:
    type: world
    debug: false
    events:
        on player right clicks *_BED:
        - if <yaml[UtilizenConfig].read[allow-bed]>:
            - yaml id:UtilizenPlayerdata set <player.uuid>.spawnlocation:<context.location>
            - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
            - adjust <player> bed_spawn_location:<context.location>
            - narrate "<yaml[UtilizenLang].read[bedspawnset].parsed>"
        on player right clicks with COMPASS:
        - if <yaml[UtilizenPlayerdata].read[<player.uuid>.spawnlocation]||null> == null:
            - narrate "<yaml[UtilizenLang].read[comnobedspawn].parsed>"
            - stop
        - if <player.compass_target> == <yaml[UtilizenPlayerdata].read[<player.uuid>.spawnlocation]>:
            - compass <world[test1].spawn_location>
            - narrate "<yaml[UtilizenLang].read[comspawn].parsed>"
            - stop
        - else:
            - compass <yaml[UtilizenPlayerdata].read[<player.uuid>.spawnlocation]>
            - narrate "<yaml[UtilizenLang].read[combedspawn].parsed>"
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
        on player chats flagged:mute:
        - narrate <yaml[UtilizenLang].read[muteyouremuted].parsed>
        - determine cancelled
UtilizenGodHandler:
    type: world
    debug: false
    events:
        on player damaged:
        - if <player.has_flag[god]>:
            - determine cancelled
UtilizenGamemodeHandler:
    type: task
    debug: false
    script:
    - if <context.args.size> == 1:
        - if <player.has_permission[utilizen.gamemode.<context.args.first>]>:
            - adjust <player> gamemode:<context.args.first>
            - narrate <yaml[UtilizenLang].read[gamemodechanged].parsed>
        - else:
            - narrate <yaml[UtilizenLang].read[gamemodeneedperm<context.args.first>].parsed>
    - else:
        - adjust <server.match_player[<context.args.last>]> gamemode:<context.args.first>
        - narrate <yaml[UtilizenLang].read[gamemodechangedother].parsed>
        - narrate <yaml[UtilizenLang].read[gamemodechanged].parsed> targets:<server.match_player[<context.args.last>]>
UtilizenGamemodeHandlerNumber:
    type: task
    debug: false
    script:
    - define mode:<tern[<context.args.first.is[==].to[0]>].pass[survival].fail[<tern[<context.args.first.is[==].to[1]>].pass[creative].fail[<tern[<context.args.first.is[==].to[2]>].pass[adventure].fail[<tern[<context.args.first.is[==].to[3]>].pass[spectator].fail[null]>]>]>]>
    - if <context.args.size> == 1:
        - if <player.has_permission[utilizen.gamemode.<[mode]>]>:
            - adjust <player> gamemode:<[mode]>
            - narrate <yaml[UtilizenLang].read[gamemodechanged].parsed>
        - else:
            - narrate <yaml[UtilizenLang].read[gamemodeneedperm<[mode]>].parsed>
    - else:
        - adjust <server.match_player[<context.args.last>]> gamemode:<[mode]>
        - narrate <yaml[UtilizenLang].read[gamemodechangedother].parsed>
        - narrate <yaml[UtilizenLang].read[gamemodechanged].parsed> targets:<server.match_player[<context.args.last>]>

#temp fix for broken uncancellable teleport event
UtilizenJailHandler:
    type: world
    debug: false
    events:
        on player teleports flagged:jailed:
        - ratelimit <player> 1t
        - yaml id:UtilizenPlayerdata set <player.uuid>.jail.duration:<player.flag[jailed].expiration>
        - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
        - flag player jailed:!
        - teleport <context.origin>
        - flag player jailed d:<yaml[UtilizenPlayerdata].read[<player.uuid>.jail.duration]>
        - narrate <yaml[UtilizenLang].read[jailnopermission].parsed>
        on player quits flagged:jailed:
        - yaml id:UtilizenPlayerdata set <player.uuid>.jail.duration:<player.flag[jailed].expiration>
        - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
        - flag player jailed:!
        on player breaks block flagged:jailed:
        - determine passively cancelled
        - narrate <yaml[UtilizenLang].read[jailnopermission].parsed>
        on player places block flagged:jailed:
        - determine passivevly cancelled
        - narrate <yaml[UtilizenLang].read[jailnopermission].parsed>
        on player joins:
        - if <yaml[UtilizenPlayerdata].contains[<player.uuid>.jail.duration]||false>:
            - teleport <player> <yaml[UtilizenServerdata].read[jailname.<yaml[UtilizenServerdata].list_keys[jailname].random>]>
            - wait 1t
            - flag player jailed d:<yaml[UtilizenPlayerdata].read[<player.uuid>.jail.duration]>
            - narrate <yaml[UtilizenLang].read[jailstilljailed].parsed>
            - if <player.is_online> && <player[<player>]||null> != null:
                - waituntil rate:20t !<player.has_flag[jailed]||null>
                - if <server.match_player[<player.name>]||null> == null:
                    - stop
                - teleport <yaml[UtilizenPlayerdata].read[<player.uuid>.jail.location]>
                - yaml id:UtilizenPlayerdata set <player.uuid>.jail:!
                - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - narrate <yaml[UtilizenLang].read[jailexit].parsed>
                