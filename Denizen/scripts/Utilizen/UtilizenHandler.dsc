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
UtilizenSpawnHandler:
    type: world
    debug: false
    events:
        on player joins:
        - if !<yaml[Utilizen_<player.uuid>].contains[new]> && <yaml[UtilizenServerData].contains[newbie_location]>:
            - teleport <yaml[UtilizenServerData].read[newbie_location]>
            - yaml id:Utilizen_<player.uuid> set new:false
            - run UtilizenSavePlayerTask def:<player.uuid>
UtilizenBedSpawnHandler:
    type: world
    debug: false
    events:
        on player right clicks *_BED:
        - if <yaml[UtilizenConfig].read[allow-bed]>:
            - yaml id:Utilizen_<player.uuid> set <player.uuid>.spawnlocation:<context.location>
            - run UtilizenSavePlayerTask def:<player.uuid>
            - adjust <player> bed_spawn_location:<context.location>
            - narrate <yaml[UtilizenLang].read[bedspawnset].parsed>
            - flag player bedspawn d:1t
        on player receives message flagged:bedspawn priority:1:
        - if "<element[Respawn point set]>" == <context.message>:
            - determine cancelled
        on player right clicks with COMPASS:
        - if <yaml[UtilizenConfig].read[allow-compass-bed]>:
            - if <player.bed_spawn||null> == null:
                - narrate <yaml[UtilizenLang].read[comnobedspawn].parsed>
                - compass <player.world.spawn_location>
            - else if <player.compass_target> == <yaml[Utilizen_<player.uuid>].read[<player.uuid>.spawnlocation]>:
                - compass <player.world.spawn_location>
                - narrate <yaml[UtilizenLang].read[comspawn].parsed>
            - else:
                - compass <yaml[Utilizen_<player.uuid>].read[<player.uuid>.spawnlocation]>
                - narrate <yaml[UtilizenLang].read[combedspawn].parsed>
        - else:
            - compass <player.world.spawn_location>
            - narrate <yaml[UtilizenLang].read[comspawn].parsed>
        on player respawns at bed:
        - if <yaml[UtilizenConfig].read[allow-bed]>:
            - determine <server.list_worlds.first.spawn_location>
UtilizenNickHandler:
    type: world
    debug: false
    events:
        on player joins:
        - if <yaml[Utilizen_<player.uuid>].read[<player.uuid>.nickname]||null> == null:
            - stop
        - else:
            - if <yaml[UtilizenConfig].read[tablist]>:
                - foreach <yaml[UtilizenConfig].read[homes].parse[before[:]]>:
                    - if <player.has_permission[utilizen.group.<[value]>]>:
                        - define prefix:<server.group_prefix[<[value]>]||>
                        - define suffix:<server.group_suffix[<[value]>]||>
                        - foreach stop
            - adjust <player> player_list_name:<[prefix]||><yaml[Utilizen_<player.uuid>].read[<player.uuid>.nickname].parse_color><[suffix]||>
            - adjust <player> display_name:<yaml[Utilizen_<player.uuid>].read[<player.uuid>.nickname].parse_color>
UtilizenNickGetPermissionHandler:
    type: task
    debug: false
    script:
    - foreach <yaml[UtilizenConfig].read[homes].parse[before[:]]>:
        - if <server.match_player[<context.args.first>].has_permission[utilizen.group.<[value]>]>:
            - define prefix:<server.group_prefix[<[value]>]||>
            - define suffix:<server.group_suffix[<[value]>]||>
                - foreach stop
UtilizenBackHandler:
    type: world
    debug: false
    events:
        on player teleports:
        - yaml id:Utilizen_<player.uuid> set <player.uuid>.lastlocation:<context.origin>
        - run UtilizenSavePlayerTask def:<player.uuid>
        on player dies:
        - yaml id:Utilizen_<player.uuid> set <player.uuid>.lastlocation:<context.entity.location>
        - run UtilizenSavePlayerTask def:<player.uuid>
UtilizenMuteHandler:
    type: world
    debug: false
    events:
        on player chats flagged:mute:
        - narrate <yaml[UtilizenLang].read[muteyouremuted].parsed>
        - determine cancelled
UtilizenVanishHandler:
    type: world
    debug: false
    events:
        on player damaged flagged:vanish:
        - determine cancelled
UtilizenGodHandler:
    type: world
    debug: false
    events:
        on player damaged flagged:god:
        - determine cancelled
        on entity targets player flagged:god:
        - determine cancelled
#temp fix for broken uncancellable teleport event
UtilizenJailHandler:
    type: world
    debug: false
    events:
        on player teleports flagged:jailed:
        - ratelimit <player> 1t
        - yaml id:Utilizen_<player.uuid> set <player.uuid>.jail.duration:<player.flag[jailed].expiration>
        - run UtilizenSavePlayerTask def:<player.uuid>
        - flag player jailed:!
        - teleport <context.origin>
        - flag player jailed d:<yaml[Utilizen_<player.uuid>].read[<player.uuid>.jail.duration]>
        - narrate <yaml[UtilizenLang].read[jailnopermission].parsed>
        on player quits flagged:jailed:
        - yaml id:Utilizen_<player.uuid> set <player.uuid>.jail.duration:<player.flag[jailed].expiration>
        - run UtilizenSavePlayerTask def:<player.uuid>
        - flag player jailed:!
        on player breaks block flagged:jailed:
        - determine passively cancelled
        - narrate <yaml[UtilizenLang].read[jailnopermission].parsed>
        on player places block flagged:jailed:
        - determine passively cancelled
        - narrate <yaml[UtilizenLang].read[jailnopermission].parsed>
        on player joins:
        - if <yaml[Utilizen_<player.uuid>].contains[<player.uuid>.jail.duration]||false>:
            - teleport <player> <yaml[UtilizenServerdata].read[jailname.<yaml[UtilizenServerdata].list_keys[jailname].random>]>
            - wait 1t
            - flag player jailed d:<yaml[Utilizen_<player.uuid>].read[<player.uuid>.jail.duration]>
            - narrate <yaml[UtilizenLang].read[jailstilljailed].parsed>
            - if <player.is_online> && <player[<player>]||null> != null:
                - waituntil rate:20t !<player.has_flag[jailed]||null>
                - if <server.match_player[<player.name>]||null> == null:
                    - stop
                - teleport <yaml[Utilizen_<player.uuid>].read[<player.uuid>.jail.location]>
                - yaml id:Utilizen_<player.uuid> set <player.uuid>.jail:!
                - run UtilizenSavePlayerTask def:<player.uuid>
                - narrate <yaml[UtilizenLang].read[jailexit].parsed>
                