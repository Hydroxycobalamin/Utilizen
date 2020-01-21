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
UtilizenCommandAFK:
    type: command
    debug: false
    name: afk
    description: Toggles AFK-Mode
    usage: /afk (Player)
    permission: utilizen.afk
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <player.has_permission[utilizen.afk.other]>:
        - choose <context.args.size>:
            - case 0:
                - determine <server.list_online_players.parse[name]>
            - case 1:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.server>:
        - announce to_console "[Utilizen] This command can not be executed from console"
        - stop
    - if <player.has_permission[utilizen.afk.other]> && <context.args.size> == 1:
        - if <server.match_player[<context.args.get[1]>].is_online>:
            - if !<server.match_player[<context.args.get[1]>].has_flag[afk]>:
                - narrate <yaml[UtilizenLang].read[afkother].parsed> targets:<server.list_online_players>
                - flag <server.match_player[<context.args.get[1]>]> afk
                - permission add smoothsleep.ignore players:<server.match_player[<context.args.get[1]>]>
                - stop
            - else:
                - narrate <yaml[UtilizenLang].read[afkotherback].parsed> targets:<server.list_online_players>
                - flag <server.match_player[<context.args.get[1]>]> afk:!
                - permission remove smoothsleep.ignore players:<server.match_player[<context.args.get[1]>]>
                - stop
        - else:
            - narrate <yaml[UtilizenLang].read[afkplnotonline].parsed>
    - if !<player.has_flag[afk]>:
        - narrate <yaml[UtilizenLang].read[afk].parsed> targets:<server.list_online_players>
        - flag player afk
        - permission add smoothsleep.ignore
    - else:
        - narrate <yaml[UtilizenLang].read[afkback].parsed> targets:<server.list_online_players>
        - flag player afk:!
        - permission remove smoothsleep.ignore
UtilizenCommandMail:
    type: command
    debug: false
    name: mail
    description: Read and Send mails!
    usage: /mail [send|read|remove|sendall] (Player) (Message)
    permission: utilizen.mail
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - choose <context.args.size>:
        - case 0:
            - determine <list[send|read|remove|<tern[<player.has_permission[utilizen.mail.sendall]>].pass[sendall].fail[]>]>
        - case 1:
            - if "!<context.raw_args.ends_with[ ]>":
                - determine <list[send|read|remove|<tern[<player.has_permission[utilizen.mail.sendall]>].pass[sendall].fail[]>].filter[starts_with[<context.args.first>]]>
            - else if <context.args.first> == send:
                - determine <server.list_online_players.parse[name]>
        - case 2:
            - if "!<context.raw_args.ends_with[ ]>":
                - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.get[2]>]]>
    script:
    - choose <context.args.first>:
        - case send:
            - if <context.args.size> >= 2:
                - if <server.player_is_valid[<context.args.get[2]>]>:
                    - if <context.args.size> > 2:
                        - yaml id:UtilizenServerdata set msgcount:++
                        - run UtilizenSaveServerTask
                        - if !<server.match_offline_player[<context.args.get[2]>].is_online>:
                            - ~yaml load:../Utilizen/data/players/<server.match_offline_player[<context.args.get[2]>].uuid>.yml id:Utilizen_<server.match_offline_player[<context.args.get[2]>].uuid>
                            - yaml id:Utilizen_<server.match_offline_player[<context.args.get[2]>].uuid> set mailbox.<yaml[UtilizenServerdata].read[msgcount]||0>:|:<player.uuid>|<context.args.remove[1|2].space_separated>
                            - ~yaml savefile:../Utilizen/data/players/<server.match_offline_player[<context.args.get[2]>].uuid>.yml id:Utilizen_<server.match_offline_player[<context.args.get[2]>].uuid>
                            - yaml unload id:Utilizen_<server.match_offline_player[<context.args.get[2]>].uuid>
                            - narrate <yaml[UtilizenLang].read[mailsend].parsed>
                            - stop
                        - narrate <yaml[UtilizenLang].read[mailsend].parsed>
                        - yaml id:Utilizen_<server.match_offline_player[<context.args.get[2]>].uuid> set mailbox.<yaml[UtilizenServerdata].read[msgcount]||0>:|:<player.uuid>|<context.args.remove[1|2].space_separated>
                        - ~yaml savefile:../Utilizen/data/players/<server.match_offline_player[<context.args.get[2]>].uuid>.yml id:Utilizen_<server.match_offline_player[<context.args.get[2]>].uuid>
                    - else:
                        - narrate <yaml[UtilizenLang].read[mailempty].parsed>
                - else:
                    - narrate <yaml[UtilizenLang].read[mailplnotexist].parsed>
            - else:
                - narrate <yaml[UtilizenLang].read[mailneedplayer].parsed>
        - case read:
            - if <yaml[Utilizen_<player.uuid>].list_keys[mailbox]||true>:
                - narrate <yaml[UtilizenLang].read[mailboxempty].parsed>
                - stop
            - foreach <yaml[Utilizen_<player.uuid>].list_keys[mailbox]>:
                - narrate <yaml[UtilizenLang].read[mailread].parsed>
        - case remove:
            - yaml id:Utilizen_<player.uuid> set mailbox:!
            - run UtilizenSavePlayerTask def:<player.uuid>
            - narrate <yaml[UtilizenLang].read[maildelete].parsed>
        - case sendall:
            - if <player.has_permission[utilizen.mail.sendall]>:
                - if <context.args.size> > 1:
                    - narrate <yaml[UtilizenLang].read[mailsendall].parsed>
                    - foreach <server.list_players.parse[uuid]>:
                        - if <[loop_index].mod[5]> == 0:
                            - wait 1t
                        - yaml id:UtilizenServerdata set msgcount:++
                        - if <player[<[value]>].is_online>:
                            - yaml id:Utilizen_<[value]> set mailbox.<yaml[UtilizenServerdata].read[msgcount]||0>:|:<player.uuid>|<context.args.remove[1].space_separated>
                            - run UtilizenSavePlayerTask def:<[value]>
                            - foreach next
                        - else:
                            - run MailHandlerTask def:<[value]>|<context.args.remove[1].space_separated>|<player.uuid>
                    - run UtilizenSaveServerTask
        - default:
            - narrate <yaml[UtilizenLang].read[mailallarguments].parsed>
MailHandlerTask:
    type: task
    debug: false
    definitions: uuid|text|puuid
    script:
    - if !<server.has_file[../Utilizen/data/players/<[uuid]>.yml]>:
        - yaml create id:Utilizen_<[uuid]>
        - ~yaml savefile:../Utilizen/data/players/<[uuid]>.yml id:Utilizen_<[uuid]>
    - ~yaml load:../Utilizen/data/players/<[uuid]>.yml id:Utilizen_<[uuid]>
    - yaml id:Utilizen_<[uuid]> set mailbox.<yaml[UtilizenServerdata].read[msgcount]||0>:|:<[puuid]>|<[text]>
    - ~yaml savefile:../Utilizen/data/players/<[uuid]>.yml id:Utilizen_<[uuid]>
    - if !<player[<[uuid]>].is_online>:
        - yaml unload id:Utilizen_<[uuid]>
UtilizenMeCommand:
    type: command
    debug: false
    name: me
    description: Me
    usage: /me [Message]
    permission: utilizen.me
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if !<context.server>:
        - stop
    script:
    - if <player.has_flag[mute]>:
        - narrate <yaml[UtilizenLang].read[muteyouremuted].parsed]>
        - stop
    - if !<context.args.is_empty>:
        - narrate <yaml[UtilizenLang].read[me].parsed> targets:<server.list_online_players>
    - else:
        - narrate <yaml[UtilizenLang].read[meempty].parsed>
UtilizenMSGCommand:
    type: command
    debug: false
    name: msg
    description: Send private Messages
    usage: /msg [Player] [Message]
    permission: utilizen.msg
    permission message: <&3>[Permission] You need the permission <&b>utilizen.msg
    tab complete:
    - if <context.args.is_empty>:
        - determine <server.list_online_players.parse[name]>
    - else if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.args.size> >= 1:
        - if <server.player_is_valid[<context.args.first>]>:
            - if <server.match_player[<context.args.first>].is_online>:
                - if <context.args.size> > 1:
                    - narrate <yaml[UtilizenLang].read[msgsent].parsed> targets:<player>|<server.match_player[<context.args.first>]>
                - else:
                    - narrate <yaml[UtilizenLang].read[msgempty].parsed>
            - else:
                - narrate <yaml[UtilizenLang].read[msgplnotonline].parsed>
        - else:
            - narrate <yaml[UtilizenLang].read[msgplnotexist].parsed>
    - else:
        - narrate <yaml[UtilizenLang].read[msgsyntax].parsed>
UtilizenNickCommand:
    type: command
    debug: false
    name: nick
    description: Nick people
    usage: /nick
    permission: utilizen.nick
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.is_empty>:
        - determine <server.list_online_players.parse[name]>
    - else if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - choose <context.args.size>:
        - case 1:
            - if <server.player_is_valid[<context.args.first>]>:
                - define uuid:<server.match_player[<context.args.first>].uuid>
                - inject UtilizenNickGetPermissionHandler
                - yaml id:UtilizenServerdata set nicknames:<-:<[uuid]>/<server.match_player[<context.args.first>].display_name>
                - run UtilizenSaveServerTask
                - adjust <server.match_player[<context.args.first>]> player_list_name:<[prefix]||><player.name><[suffix]||>
                - adjust <server.match_player[<context.args.first>]> display_name:<player.name>
                - narrate <yaml[UtilizenLang].read[nickdelete].parsed>
                - yaml id:Utilizen_<[uuid]> set <[uuid]>.nickname:!
                - run UtilizenSavePlayerTask def:<[uuid]>
            - else:
                - narrate <yaml[UtilizenLang].read[nickplnotexist].parsed>
        - case 2:
            - if <server.list_players.parse[name].contains[<context.args.get[2]>]> || <yaml[UtilizenServerdata].read[nicknames].contains[<context.args.get[2]>]>:
                - narrate <yaml[UtilizenLang].read[nickinuse].parsed>
                - stop
            - define uuid:<server.match_player[<context.args.first>].uuid>
            - inject UtilizenNickGetPermissionHandler
            - if <server.match_player[<context.args.first>].name> != <server.match_player[<context.args.first>].display_name>:
                - yaml id:UtilizenServerdata set nicknames:<-:<[uuid]>/<server.match_player[<context.args.first>].display_name>
            - define nick:<context.args.get[2].parse_color>
            - adjust <server.match_player[<context.args.first>]> player_list_name:<[prefix]||><[nick]><[suffix]||>
            - adjust <server.match_player[<context.args.first>]> display_name:<[nick]>
            - narrate <yaml[UtilizenLang].read[nicksuccess].parsed>
            - narrate <yaml[UtilizenLang].read[nickchanged].parsed>
            - yaml id:Utilizen_<[uuid]> set <[uuid]>.nickname:<context.args.get[2].parse_color>
            - run UtilizenSavePlayerTask def:<[uuid]>
            - yaml id:UtilizenServerdata set nicknames:->:<[uuid]>/<context.args.get[2].parse_color>
            - run UtilizenSaveServerTask
        - default:
            - narrate <yaml[UtilizenLang].read[nicksyntax].parsed>
UtilizenShowNickCommand:
    type: command
    debug: false
    name: shownick
    description: Shows the original name from nicked players
    usage: /shownick [Nickname]
    permission: utilizen.shownick
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.is_empty>:
        - determine <yaml[UtilizenServerdata].read[nicknames].get_sub_items[2]||>
    - else if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <yaml[UtilizenServerdata].read[nicknames].get_sub_items[2].filter[starts_with[<context.args.first>]]||>
    script:
    - if <context.args.size> == 1:
        - if <yaml[UtilizenServerdata].contains[nicknames]>:
            - if <yaml[UtilizenServerdata].read[nicknames].get_sub_items[2].contains[<context.args.first>]>:
                - narrate <player[<yaml[UtilizenServerdata].read[nicknames].map_find_key[<context.args.first>]>].name>
            - else:
                - narrate <yaml[UtilizenLang].read[shownicknonick].parsed>
        - else:
            - narrate <yaml[UtilizenLang].read[shownicknonicked].parsed>
    - else:
        - narrate <yaml[UtilizenLang].read[shownicksyntax].parsed>
UtilizenSetWarpCommand:
    type: command
    debug: false
    name: setwarp
    description: Create a Warp
    usage: /setwarp [Warpname]
    permission: utilizen.setwarp
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if !<context.server>:
        - stop
    script:
    - if <context.server>:
        - announce to_console "[Utilizen] This command can not be executed from console"
        - stop
    - if <context.args.size> == 1:
        - yaml id:UtilizenServerdata set warps.<context.args.first>:<player.location>
        - run UtilizenSaveServerTask
        - narrate <yaml[UtilizenLang].read[warpcreate].parsed>
    - else:
        - narrate <yaml[UtilizenLang].read[warpnoname].parsed>
UtilizenDelWarpCommand:
    type: command
    debug: false
    name: delwarp
    description: Delete Warps
    usage: /delwarp [Warpname]
    permission: utilizen.delwarp
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.is_empty>:
        - determine <yaml[UtilizenServerdata].list_keys[warps]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <yaml[UtilizenServerdata].list_keys[warps].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.args.size> >= 1:
        - if <yaml[UtilizenServerdata].contains[<context.args.first>]>:
            - yaml id:UtilizenServerdata set <context.args.first>:!
            - run UtilizenSaveServerTask
            - narrate <yaml[UtilizenLang].read[warpdelete].parsed>
        - else:
            - narrate <yaml[UtilizenLang].read[warpnotexist].parsed>
    - else:
        - narrate <yaml[UtilizenLang].read[warpnoarg].parsed>
UtilizenWarpCommand:
    type: command
    debug: false
    name: warp
    description: Teleport to a Warppoint
    usage: /warp [Warpname] (Player)
    permission: utilizen.warp
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.is_empty>:
        - determine <tern[<element[<yaml[UtilizenServerdata].list_keys[warps]||null>].is[!=].to[null]>].pass[<yaml[UtilizenServerdata].list_keys[warps]>].fail[]>
    - else if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <yaml[UtilizenServerdata].list_keys[warps].filter[starts_with[<context.args.first>]]>
    - if <player.has_permission[utilizen.warp.other]>:
        - if <context.args.size> < 2:
            - determine <server.list_online_players.parse[name]>
        - else if <context.args.size> == 2 && "!<context.raw_args.ends_with[ ]>":
            - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.server>:
        - announce to_console "[Utilizen] This command can not be executed from console"
        - stop
    - if <context.args.size> >= 1:
        - if <yaml[UtilizenServerdata].contains[warps.<context.args.first>]>:
            - if <context.args.size> == 2 && <player.has_permission[utilizen.warp.other]>:
                - teleport <server.match_player[<context.args.get[2]>]> <yaml[UtilizenServerdata].read[warps.<context.args.first>]>
                - narrate <yaml[UtilizenLang].read[warpedbyadmin].parsed> targets:<server.match_player[<context.args.get[2]>]>
                - narrate <yaml[UtilizenLang].read[warpedplayer].parsed>
            - else:
                - teleport <player> <yaml[UtilizenServerdata].read[warps.<context.args.first>]>
                - narrate <yaml[UtilizenLang].read[warpsuccess].parsed>
        - else:
            - narrate <yaml[UtilizenLang].read[warpnotexist].parsed>
    - else:
        - narrate <yaml[UtilizenLang].read[warplist].parsed>
UtilizenJailCommand:
    type: command
    debug: false
    name: jail
    description: Jail people
    usage: /jail [Player] [Jailname] [Duration]
    permission: utilizen.jail
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <server.list_online_players.parse[name]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    - if <context.args.size> < 2:
        - determine <yaml[UtilizenServerdata].list_keys[jailname]||Create_a_Jail_first>
    - if <context.args.size> == 2 && "!<context.raw_args.ends_with[ ]>":
        - determine <yaml[UtilizenServerdata].list_keys[jailname].filter[starts_with[<context.args.get[2]>]]||Create_a_Jail_first>
    - if <context.args.size> == 3 && "!<context.raw_args.ends_with[ ]>" && !<context.args.get[3].to_list.contains_any[s|m|h|d]>:
        - determine <list[<context.args.get[3]>s|<context.args.get[3]>m|<context.args.get[3]>h|<context.args.get[3]>d]>
    script:
    - if <context.args.size> >= 1:
        - if <server.player_is_valid[<context.args.first>]>:
            - if !<server.match_player[<context.args.first>].has_flag[jailed]>:
                - if <context.args.size> >= 2:
                    - define playerlocation:<server.match_player[<context.args.first>].location>
                    - if <yaml[UtilizenServerdata].contains[jailname.<context.args.get[2]>]>:
                        - if <context.args.size> == 3:
                            - if <duration[<context.args.get[3]>]||null> != null:
                                - yaml id:Utilizen_<server.match_player[<context.args.first>].uuid> set jail.location:<[playerlocation]>
                                - run UtilizenSavePlayerTask def:<server.match_player[<context.args.first>].uuid>
                                - teleport <server.match_player[<context.args.first>]> <yaml[UtilizenServerdata].read[jailname.<context.args.get[2]>]>
                                - wait 1t
                                - flag <server.match_player[<context.args.first>]> jailed d:<context.args.get[3].as_duration>
                                - narrate <yaml[UtilizenLang].read[jailjailedadmin].parsed>
                                - if <server.match_player[<context.args.first>].is_online> && <server.match_player[<context.args.first>]||null> != null:
                                    - waituntil rate:20t !<server.match_player[<context.args.first>].has_flag[jailed]||null>
                                    - if <server.match_player[<context.args.first>]||null> == null:
                                        - stop
                                    - teleport <server.match_player[<context.args.first>]> <[playerlocation]>
                                    - narrate <yaml[UtilizenLang].read[jailexit].parsed> targets:<server.match_player[<context.args.first>]>
                            - else:
                                - narrate <yaml[UtilizenLang].read[jailtimeinvalid].parsed>
                        - else:
                            - narrate <yaml[UtilizenLang].read[jailnotime].parsed>
                    - else:
                        - narrate <yaml[UtilizenLang].read[jailnotexist].parsed>
                - else:
                    - narrate <yaml[UtilizenLang].read[jailwrongsyntax].parsed>
            - else:
                - narrate <yaml[UtilizenLang].read[jailalreadyjailed].parsed>
        - else:
            - narrate <yaml[UtilizenLang].read[jailplnotexist].parsed>
    - else:
        - narrate <yaml[UtilizenLang].read[jailsyntax].parsed>
UtilizenSetJailCommand:
    type: command
    debug: false
    name: setjail
    description: Create a Jail
    usage: /setjail [Jailname]
    permission: utilizen.setjail
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if !<context.server>:
        - stop
    script:
    - if <context.args.size> == 1:
        - yaml id:UtilizenServerdata set jailname.<context.args.first>:<player.location>
        - run UtilizenSaveServerTask
        - narrate <yaml[UtilizenLang].read[jailcreate].parsed>
    - else:
        - narrate <yaml[UtilizenLang].read[jailnoname].parsed>
UtilizenDelJailCommand:
    type: command
    debug: false
    description: delete a jail
    usage: /deljail [Name]
    name: deljail
    permission: utilizen.deljail
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.is_empty>:
        - determine <yaml[UtilizenServerdata].list_keys[jailname]||Create_a_Jail_first>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <yaml[UtilizenServerdata].list_keys[jailname].filter[starts_with[<context.args.first>]]||Create_a_Jail_first>
    script:
    - if <context.args.size> == 1:
        - if <yaml[UtilizenServerdata].contains[jailname.<context.args.first>]>:
            - yaml id:UtilizenServerdata set jailname.<context.args.first>:!
            - run UtilizenSaveServerTask
            - narrate <yaml[UtilizenLang].read[jaildeleted].parsed>
        - else:
            - narrate <yaml[UtilizenLang].read[notexist].parsed>
    - else:
        - narrate <yaml[UtilizenLang].read[jailnojail].parsed>
UtilizenUnJailCommand:
    type: command
    debug: false
    name: unjail
    description: Unjail a Player
    usage: /unjail [Player]
    permission: utilizen.unjail
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <server.list_online_players.parse[name]>
    - else if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.args.size> == 1:
        - if <server.player_is_valid[<context.args.first>]>:
            - if <server.match_player[<context.args.first>].has_flag[jailed]>:
                - flag <server.match_player[<context.args.first>]> jailed:!
            - else:
                - narrate <yaml[UtilizenLang].read[jailnotinjail].parsed>
        - else:
            - narrate <yaml[UtilizenLang].read[jailplnotexist].parsed>
    - else:
        - narrate <yaml[UtilizenLang].read[jailnoplayer].parsed>
UtlizenSetHomeCommand:
    type: command
    debug: false
    description: Sets your home
    usage: /sethome [Homename]
    name: sethome
    permission: utilizen.sethome
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if !<context.server>:
        - stop
    script:
    - if <context.args.is_empty>:
        - narrate <yaml[UtilizenLang].read[sethomenoargs].parsed>
    - else if <context.args.size> == 1:
        - if !<yaml[Utilizen_<player.uuid>].read[homes].get_sub_items[1].contains[<context.args.first>]>:
            - if <player.is_op>:
                - if <yaml[Utilizen_<player.uuid>].read[homes].size||0> <= <yaml[UtilizenConfig].read[op-homes]>:
                        - narrate <yaml[UtilizenLang].read[sethomeset].parsed>
                        - yaml id:Utilizen_<player.uuid> set homes:->:<context.args.first>/<player.location.simple>
                        - run UtilizenSavePlayerTask def:<player.uuid>
                        - stop
            - foreach <yaml[UtilizenConfig].read[homes]>:
                - if <player.has_permission[utilizen.groups.<[value].before[:]>]>:
                    - if <yaml[Utilizen_<player.uuid>].read[homes].size||0> <= <[value].after[:]>:
                        - narrate <yaml[UtilizenLang].read[sethomeset].parsed>
                        - yaml id:Utilizen_<player.uuid> set homes:->:<context.args.first>/<player.location.simple>
                        - run UtilizenSavePlayerTask def:<player.uuid>
                        - stop
                    - else:
                        - narrate <yaml[UtilizenLang].read[sethometomuchhome]>
                        - stop
            - if <yaml[Utilizen_<player.uuid>].read[homes].size||0> <= <yaml[UtilizenConfig].read[default]>:
                - narrate <yaml[UtilizenLang].read[sethomeset].parsed>
                - yaml id:Utilizen_<player.uuid> set homes:->:<context.args.first>/<player.location.simple>
                - run UtilizenSavePlayerTask def:<player.uuid>
        - else:
            - narrate <yaml[UtilizenLang].read[sethomealreadyset].parsed>
UtilizenDelHomeCommand:
    type: command
    debug: false
    description: Delete your Home
    usage: /delhome [name] (player)
    name: delhome
    permission: utilizen.delhome
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <yaml[Utilizen_<player.uuid>].contains[homes]>:
        - if <context.args.size> < 1:
            - determine <yaml[Utilizen_<player.uuid>].read[homes].get_sub_items[1]>
        - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
            - determine <yaml[Utilizen_<player.uuid>].read[homes].get_sub_items[1].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.args.size> == 2 && <server.player_is_valid[<context.args.get[2]>]>:
        - if <player.has_permission[utilizen.delhome.other]>:
            - if <yaml[Utilizen_<server.match_player[<context.args.get[2]>].uuid>].read[homes].get_sub_items[1].contains[<context.args.first>]>:
                - yaml id:Utilizen_<server.match_player[<context.args.get[2]>].uuid> set homes:!|:<yaml[Utilizen_<server.match_player[<context.args.get[2]>].uuid>].read[homes].remove[<yaml[Utilizen_<player.uuid>].read[homes].get_sub_items[1].find[<context.args.first>]>]>
                - run UtilizenSavePlayerTask def:<server.match_player[<context.args.get[2]>].uuid>
                - narrate <yaml[UtilizenLang].read[delhomedeleted].parsed>
            - else:
                - narrate <yaml[UtilizenLang].read[delhomeothernohomeexist].parsed>
                - stop
    - else if <yaml[Utilizen_<player.uuid>].read[homes].get_sub_items[1].contains[<context.args.first||null>]>:
        - yaml id:Utilizen_<player.uuid> set homes:!|:<yaml[Utilizen_<player.uuid>].read[homes].remove[<yaml[Utilizen_<player.uuid>].read[homes].get_sub_items[1].find[<context.args.first>]>]>
        - run UtilizenSavePlayerTask def:<player.uuid>
        - narrate <yaml[UtilizenLang].read[delhomeowndelete].parsed>
    - else:
        - narrate <yaml[UtilizenLang].read[delhomenohomeexist].parsed>
UtlizenHomeCommand:
    type: command
    debug: false
    description: Home to your Home!
    usage: /home (name)
    name: home
    permission: utilizen.home
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <yaml[Utilizen_<player.uuid>].contains[homes]>:
        - if <context.args.size> < 1:
            - determine <yaml[Utilizen_<player.uuid>].read[homes].get_sub_items[1]>
        - else if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
            - determine <yaml[Utilizen_<player.uuid>].read[homes].get_sub_items[1].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.server>:
        - announce to_console "[Utilizen] This command can not be executed from console"
        - stop
    - if <context.args.is_empty>:
        - if <yaml[Utilizen_<player.uuid>].read[homes].is_empty||false>:
            - teleport <location[<yaml[Utilizen_<player.uuid>].read[homes].get_sub_items[2].first>]>
            - narrate <yaml[UtilizenLang].read[homefirsthomed].parsed>
    - else if <yaml[Utilizen_<player.uuid>].read[homes].get_sub_items[1].contains[<context.args.first>]||false>:
        - teleport <location[<yaml[Utilizen_<player.uuid>].read[homes].map_get[<context.args.first>]>]>
        - narrate <yaml[UtilizenLang].read[homehomed].parsed>
UtilizenHatCommand:
    type: command
    debug: false
    description: Set the block in your hand as hat.
    usage: /hat
    name: hat
    permission: utilizen.hat
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if !<context.server>:
        - stop
    script:
    - if <context.server>:
        - announce to_console "[Utilizen] This command can not be executed from console"
        - stop
    - else if <player.equipment.helmet.material.name> == air:
        - equip head:<player.item_in_hand>
        - inventory set slot:<player.item_in_hand.slot> o:air
    - else:
        - narrate <yaml[UtilizenLang].read[hatoccupied].parsed>
UtilizenSetSpawnCommand:
    type: command
    debug: false
    name: setspawn
    description: Sets the World Spawn
    usage: /setspawn
    permission: utilizen.setspawn
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <list[newbie]>
    - else if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <list[newbie].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.server>:
        - announce to_console "[Utilizen] This command can not be executed from console"
        - stop
    - if <context.args.is_empty>:
        - adjust <player.world> spawn_location:<player.location>
        - narrate <yaml[UtilizenLang].read[setspawnworld].parsed>
    - else if <context.args.size> == 1:
        - if <context.args.first> == newbie:
            - narrate <yaml[UtilizenLang].read[setspawnnewbie].parsed>
            - yaml id:UtilizenServerData set newbie_location:<player.location>
            - run UtilizenSaveServerTask
UtilizenSpawnCommand:
    type: command
    debug: false
    name: spawn
    description: teleport to spawn
    usage: /spawn
    permission: utilizen.spawn
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if !<context.server>:
        - stop
    script:
    - narrate <yaml[UtilizenLang].read[spawn].parsed>
    - teleport <player> <player.world.spawn_location>
UtilizenBackCommand:
    type: command
    debug: false
    name: back
    description: Warp to your last Position you were teleported from
    usage: /back
    permission: utilizen.back
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if !<context.server>:
        - stop
    script:
    - if <yaml[Utilizen_<player.uuid>].contains[lastlocation]>:
        - teleport <yaml[Utilizen_<player.uuid>].read[lastlocation]>
    - else:
        - narrate <yaml[UtilizenLang].read[backinvalid].parsed>
UtilizenFlyCommand:
    type: command
    debug: false
    name: fly
    description: Activates Flymode
    usage: /fly
    permission: utilizen.fly
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if !<context.server>:
        - stop
    script:
    - if <context.args.is_empty>:
        - if !<player.can_fly>:
            - adjust <player> can_fly:true
            - narrate <yaml[UtilizenLang].read[flyactivated].parsed>
        - else:
            - adjust <player> can_fly:false
            - narrate <yaml[UtilizenLang].read[flydeactivated].parsed>
    - else if <player.has_permission[utilizen.fly.other]>:
        - if <server.player_is_valid[<context.args.first>]||false>:
            - if !<server.match_player[<context.args.first>].can_fly>:
                - adjust <server.match_player[<context.args.first>]> can_fly:true
                - narrate <yaml[UtilizenLang].read[flyactivatedotherpl].parsed>
                - narrate <yaml[UtilizenLang].read[flyactivated].parsed> targets:<server.match_player[<context.args.first>]>
            - else:
                - adjust <server.match_player[<context.args.first>]> can_fly:false
                - narrate <yaml[UtilizenLang].read[flydeactivatedotherpl].parsed>
                - narrate <yaml[UtilizenLang].read[flydeactivated].parsed> targets:<server.match_player[<context.args.first>]>
UtilizenVanishCommand:
    type: command
    debug: false
    name: vanish
    description: Be Invisible!
    usage: /vanish
    permission: utilizen.vanish
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if !<context.server>:
        - stop
    script:
    - if <context.server>:
        - announce to_console "[Utilizen] This command can not be executed from console"
        - stop
    - else if !<player.has_flag[vanish]>:
        - flag player vanish
        - cast invisibility d:99999 hide_particles
        - adjust <player> hide_from_players
        - narrate <yaml[UtilizenLang].read[vanishactivated].parsed>
    - else:
        - flag player vanish:!
        - cast invisibility remove
        - adjust <player> show_to_players
        - narrate <yaml[UtilizenLang].read[vanishdeactivated].parsed>
UtilizenBurnCommand:
    type: command
    debug: false
    name: burn
    description: Burn a player
    usage: /burn [Player] [Duration]
    permission: utilizen.burn
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <server.list_online_players.parse[name]>
    - else if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.args.size> >= 1:
        - if <server.player_is_valid[<context.args.first>]>:
            - if <context.args.size> == 2:
                - if <duration[<context.args.get[2]>]||null> != null:
                    - burn <server.match_player[<context.args.first>]> <context.args.get[2].as_duration>
                - else:
                    - narrate <yaml[UtilizenLang].read[burntimeinvalid].parsed>
            - else:
                - narrate <yaml[UtilizenLang].read[burnnotime].parsed>
        - else:
            - narrate <yaml[UtilizenLang].read[burnplnotexist].parsed>
    - else:
        - narrate <yaml[UtilizenLang].read[burnsyntax].parsed>
UtilizenHealCommand:
    type: command
    debug: false
    name: heal
    description: Heal yourself or a player
    usage: /heal (Player)
    permission: utilizen.heal
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <server.list_online_players.parse[name]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.args.is_empty>:
        - heal <player>
        - narrate <yaml[UtilizenLang].read[healhealed].parsed>
    - else if <server.player_is_valid[<context.args.first>]>:
        - heal <server.match_player[<context.args.first>]>
        - narrate <yaml[UtilizenLang].read[healadmin].parsed>
        - narrate <yaml[UtilizenLang].read[healhealed].parsed> targets:<server.match_player[<context.args.first>]>
    - else:
        - narrate <yaml[UtilizenLang].read[healplnotexist].parsed>
UtilizenFeedCommand:
    type: command
    debug: false
    name: feed
    description: Feed someone!
    usage: /feed (Player)
    permission: utilizen.feed
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <server.list_online_players.parse[name]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.args.is_empty>:
        - adjust <player> food_level:20
        - narrate <yaml[UtilizenLang].read[feedfeeded].parsed>
    - else if <server.player_is_valid[<context.args.first>]>:
        - adjust <server.match_player[<context.args.first>]> food_level:20
        - narrate <yaml[UtilizenLang].read[feedadmin].parsed>
        - narrate <yaml[UtilizenLang].read[feedfeeded].parsed> targets:<server.match_player[<context.args.first>]>
UtilizenMuteCommand:
    type: command
    debug: false
    name: mute
    description: Mute a player!
    usage: /mute [Player] [Duration]
    permission: utilizen.mute
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <server.list_online_players.parse[name]>
    - else if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    - else if <context.args.size> == 2 && "!<context.raw_args.ends_with[ ]>" && !<context.args.get[2].to_list.contains_any[s|m|h|d]>:
        - determine <list[<context.args.get[2]>s|<context.args.get[2]>m|<context.args.get[2]>h|<context.args.get[2]>d]>
    script:
    - if <context.args.size> >= 1:
        - if <server.player_is_valid[<context.args.first>]>:
            - if !<server.match_player[<context.args.first>].has_flag[mute]>:
                - if <context.args.size> >= 2:
                    - if <duration[<context.args.get[2]>]||null> != null:
                        - flag <server.match_player[<context.args.first>]> mute duration:<context.args.get[2].as_duration>
                        - narrate <yaml[UtilizenLang].read[muteadmin].parsed>
                        - narrate <yaml[UtilizenLang].read[mutewasmuted].parsed>
                    - else:
                        - narrate <yaml[UtilizenLang].read[muteinvalidduration].parsed>
                - else:
                    - narrate <yaml[UtilizenLang].read[mutenoduration].parsed>
            - else:
                - narrate <yaml[UtilizenLang].read[mutealreadymute].parsed>
        - else:
            - narrate <yaml[UtilizenLang].read[muteplnotexist].parsed>
    - else:
        - narrate <yaml[UtilizenLang].read[mutesyntax].parsed>
UtilizenUnmuteCommand:
    type: command
    debug: false
    name: unmute
    description: Unmute a player
    usage: /unmute [Player]
    permission: utilizen.unmute
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <server.list_online_players.filter[has_flag[mute]].parse[name]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.filter[has_flag[mute]].parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.args.size> >= 1:
        - if <server.player_is_valid[<context.args.first>]>:
            - if <server.match_player[<context.args.first>].has_flag[mute]>:
                - flag <server.match_player[<context.args.first>]> mute:!
            - else:
                - narrate <yaml[UtilizenLang].read[unmutenomute]>
        - else:
            - narrate <yaml[UtilizenLang].read[muteplnotexist]>
    - else:
        - narrate <yaml[UtilizenLang].read[unmutesyntax]>
UtilizenBanCommand:
    type: command
    debug: false
    name: ban
    description: Bans a player
    usage: /ban [Player] (Reason) (Duration)
    permission: utilizen.ban
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <server.list_online_players.parse[name]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    - if <context.args.size> == 3 && "!<context.raw_args.ends_with[ ]>":
        - determine <list[<context.args.get[3]>s|<context.args.get[3]>m|<context.args.get[3]>h|<context.args.get[3]>d]>
    script:
    - if <context.args.size> >= 1:
        - if <server.player_is_valid[<context.args.first>]>:
            - choose <context.args.size>:
                - case 1:
                    - ban add <server.match_player[<context.args.first>]> reason:<yaml[UtilizenConfig].read[banreason]>
                - case 2:
                    - ban add <server.match_player[<context.args.first>]> reason:<context.args.get[2]>
                - case 3:
                    - if <duration[<context.args.get[3]>]||null> != null:
                        - ban add <server.match_player[<context.args.first>]> reason:<context.args.get[2]> duration:<context.args.get[3].as_duration>
                    - else:
                        - narrate <yaml[UtilizenLang].read[bantimeinvalid].parsed>
        - else:
            - narrate <yaml[UtilizenLang].read[plnotexist].parsed>
    - else:
        - narrate <yaml[UtilizenLang].read[bansyntax].parsed>
UtilizenUnbanCommand:
    type: command
    debug: false
    name: unban
    description: unban a player
    usage: /unban [Name]
    permission: utilizen.unban
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <server.list_banned_players.parse[name]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_banned_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.args.size> >= 1:
        - if <server.player_is_valid[<context.args.first>]>:
            - if <server.match_offline_player[<context.args.first>].is_banned>:
                - ban remove <server.match_offline_player[<context.args.first>]>
                - narrate <yaml[UtilizenLang].read[unbaned].parsed> targets:<server.list_online_players.filter[has_permission[Utilizen.ban]]>
            - else:
                - narrate <yaml[UtilizenLang].read[unbannotbanned].parsed>
        - else:
            - narrate <yaml[UtilizenLang].read[unbanplnotexist].parsed>
    - else:
        - narrate <yaml[UtilizenLang].read[unbansyntax].parsed>
UtilizenKickCommand:
    type: command
    debug: false
    name: kick
    description: Kick a player
    usage: /kick [Player] (Reason)
    permission: utilizen.kick
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <server.list_online_players.parse[name]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.args.size> >= 1:
        - if <server.player_is_valid[<context.args.first>]>:
            - choose <context.args.size>:
                - case 1:
                    - kick <server.match_player[<context.args.first>]> reason:<yaml[UtilizenConfig].read[kickreason]>
                - case 2:
                    - kick <server.match_player[<context.args.first>]> reason:<context.args.get[2]>
            - default:
                - narrate <yaml[UtilizenLang].read[kickwrongsyntax].parsed>
        - else:
            - narrate <yaml[UtilizenLang].read[kickplnotexist].parsed>
    - else:
        - narrate <yaml[UtilizenLang].read[kicksyntax].parsed>
UtilizenKickallCommand:
    type: command
    debug: false
    name: kickall
    description: Kick everyone
    usage: /kickall
    permission: utilizen.kickall
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if !<context.server>:
        - stop
    script:
    - if <yaml[UtilizenConfig].read[kickops]>:
        - kick <server.list_online_players.exclude[<player>]> reason:<yaml[UtilizenConfig].read[kickreason]>
    - else:
        - kick <server.list_online_players.filter[is_op.not].exclude[<player>]> reason:<yaml[UtilizenConfig].read[kickreason]>
UtilizenGamemodeCommand:
    type: command
    debug: false
    name: gamemode
    description: changes gamemode
    usage: /gamemode [Typ] (Player)
    aliases:
    - gm
    permission: utilizen.gamemode
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.is_empty>:
        - determine <list[0|1|2|3|survival|creative|adventure|spectator]>
    - else if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <list[0|1|2|3|survival|creative|adventure|spectator].filter[starts_with[<context.args.first>]]>
    - else if <player.has_permission[utilizen.gamemode.other]>:
        - if <context.args.size> < 2:
            - determine <server.list_online_players.parse[name]>
        - else if <context.args.size> == 2 && "!<context.raw_args.ends_with[ ]>":
            - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.get[2]>]]>
    script:
    - if <context.args.size> == 1:
        - choose <context.args.first>:
            - case 0 || survival:
                - define mode:survival
            - case 1 || creative:
                - define mode:creative
            - case 2 || adventure:
                - define mode:adventure
            - case 3 || spectator:
                - define mode:spectator
            - default:
                - narrate <yaml[UtilizenLang].read[gamemodevalidmode].parsed>
                - stop
        - if <player.has_permission[utilizen.gamemode.<[mode]>]>:
            - adjust <player> gamemode:<[mode]>
            - narrate <yaml[UtilizenLang].read[gamemodechanged].parsed>
        - else:
            - narrate <yaml[UtilizenLang].read[gamemodeneedperm<[mode]>].parsed>
    - else if <context.args.size> == 2:
        - if <server.player_is_valid[<context.args.get[2]>]>:
            - if <player.has_permission[utilizen.gamemode.other]>:
                - choose <context.args.first>:
                    - case 0 || survival:
                        - define mode:survival
                    - case 1 || creative:
                        - define mode:creative
                    - case 2 || adventure:
                        - define mode:adventure
                    - case 3 || spectator:
                        - define mode:spectator
                    - default:
                        - narrate <yaml[UtilizenLang].read[gamemodevalidmode].parsed>
                        - stop
                - adjust <server.match_player[<context.args.last>]> gamemode:<[mode]>
                - narrate <yaml[UtilizenLang].read[gamemodechangedother].parsed>
                - narrate <yaml[UtilizenLang].read[gamemodechanged].parsed> targets:<server.match_player[<context.args.last>]>
            - else:
                - narrate <yaml[UtilizenLang].read[gamemodeneedpermother].parsed>
        - else:
            - narrate <yaml[UtilizenLang].read[gamemodeplnotexist].parsed>
    - else:
        - narrate <yaml[UtilizenLang].read[gamemodesyntax].parsed>
UtilizenWeatherCommand:
    type: command
    debug: false
    name: weather
    description: Changes the weather
    usage: /weather [Type] (Duration)
    permission: utilizen.weather
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.is_empty>:
        - determine <list[sun|rain|storm]>
    - else if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <list[sun|rain|storm].filter[starts_with[<context.args.first>]]>:
    - else if <context.args.size> == 2 && "!<context.raw_args.ends_with[ ]>" && !<context.args.get[2].to_list.contains_any[s|m|h|d]>:
        - determine <list[<context.args.get[2]>s|<context.args.get[2]>m|<context.args.get[2]>h|<context.args.get[2]>d]>
    script:
    - if <context.args.size> == 1:
        - choose <context.args.first>:
            - case sun:
                - weather sunny
                - adjust <player.world> thunder_duration:0
                - narrate <yaml[UtilizenLang].read[weathersun].parsed>
            - case rain:
                - weather storm
                - adjust <player.world> thunder_duration:0
                - narrate <yaml[UtilizenLang].read[weatherrain].parsed>
            - case storm:
                - weather storm
                - weather thunder
                - wait 2t
                - adjust <player.world> thunder_duration:<player.world.weather_duration>
                - narrate <yaml[UtilizenLang].read[weatherstorm].parsed>
            - default:
                - narrate <yaml[UtilizenLang].read[weathernotexist].parsed>
    - else if <context.args.size> == 2:
        - if <duration[<context.args.last>]||null> != null:
            - choose <context.args.first>:
                - case sun:
                    - weather sunny
                    - adjust <player.world> thunder_duration:0
                    - adjust <player.world> weather_duration:<context.args.last>
                    - narrate <yaml[UtilizenLang].read[weathersunduration].parsed>
                - case rain:
                    - weather storm
                    - adjust <player.world> thunder_duration:0
                    - adjust <player.world> weather_duration:<context.args.last>
                    - narrate <yaml[UtilizenLang].read[weatherrainduration].parsed>
                - case storm:
                    - weather storm
                    - weather thunder
                    - adjust <player.world> weather_duration:<context.args.last>
                    - adjust <player.world> thunder_duration:<context.args.last>
                    - narrate <yaml[UtilizenLang].read[weatherstormduration].parsed>
                - default:
                    - narrate <yaml[UtilizenLang].read[weathernotexist].parsed>
    - else:
        - narrate <yaml[UtilizenLang].read[weathertypes].parsed>
UtilizenTimeCommand:
    type: command
    debug: false
    name: time
    description: change time
    usage: /time [day|night|set] (Time in Ticks)
    permission: utilizen.time
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.is_empty>:
        - determine <list[day|night|set]>
    - else if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <list[day|night|set].filter[starts_with[<context.args.first>]]>:
    script:
    - if <context.args.size> <= 2:
        - choose <context.args.first>:
            - case day:
                - time 0t
                - narrate <yaml[UtilizenLang].read[timeday].parsed>
            - case night:
                - time 14000t
                - narrate <yaml[UtilizenLang].read[timenight].parsed>
            - case set:
                - if <context.args.get[2].is_integer> && <context.args.get[2]> <= 24000:
                    - time <context.args.get[2]>t
                    - narrate <yaml[UtilizenLang].read[timevariable].parsed>
                - else:
                    - narrate <yaml[UtilizenLang].read[timetohigh].parsed>
            - default:
                - narrate <yaml[UtilizenLang].read[timeargnotexist].parsed>
UtilizenTeleportCommand:
    type: command
    debug: false
    name: tp
    description: Teleport players
    usage: /tp [Player] (Player)
    permission: utilizen.tp
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 2:
        - determine <server.list_online_players.parse[name]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    - if <context.args.size> == 2 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - choose <context.args.size>:
        - case 1:
            - if <server.player_is_valid[<context.args.first>]>:
                - teleport <player> <server.match_player[<context.args.first>].location>
                - narrate <yaml[UtilizenLang].read[teleporttoplayer].parsed>
            - else:
                - narrate <yaml[UtilizenLang].read[teleportwrongsyntax1].parsed>
        - case 2:
            - if <server.player_is_valid[<context.args.first>]> && <server.player_is_valid[<context.args.get[2]>]>:
                - teleport <server.match_player[<context.args.first>]> <server.match_player[<context.args.get[2]>].location>
                - narrate <yaml[UtilizenLang].read[teleportpltopl].parsed>
            - else:
                - narrate <yaml[UtilizenLang].read[teleportwrongsyntax2].parsed>
        - default:
            - narrate <yaml[UtilizenLang].read[teleportsyntax].parsed>
UtilizenTPPOSCommand:
    type: command
    debug: false
    name: tppos
    description: Teleport to position
    usage: /tppos [X] [Y] [Z] (World)
    permission: utilizen.tppos
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - choose <context.args.size>:
        - case 0:
            - determine <player.location.x.round>
        - case 1:
            - if "!<context.raw_args.ends_with[ ]>":
                - determine <player.location.x.round>
            - else:
                - determine <player.location.y.round>
        - case 2:
            - if "!<context.raw_args.ends_with[ ]>":
                - determine <player.location.y.round>
            - else:
                - determine <player.location.z.round>
        - case 3:
            - if "!<context.raw_args.ends_with[ ]>":
                - determine <player.location.z.round>
            - else:
                - determine <server.list_worlds.parse[name]>
        - case 4:
            - if "!<context.raw_args.ends_with[ ]>":
                - determine <server.list_worlds.parse[name].filter[starts_with[<context.args.get[4]>]]>
    script:
    - if <context.args.size> <= 4:
        - choose <context.args.size>:
            - case 3:
                - if <context.args.first.is_integer> && <context.args.get[2].is_integer> && <context.args.get[3].is_integer>:
                    - teleport <location[<context.args.first>,<context.args.get[2]>,<context.args.get[3]>,<player.location.world.name>]>
                    - narrate <yaml[UtilizenLang].read[teleporttopos].parsed>
                - else:
                    - narrate <yaml[UtilizenLang].read[teleportwrongsyntax3].parsed>
            - case 4:
                - if <context.args.first.is_integer> && <context.args.get[2].is_integer> && <context.args.get[3].is_integer> && <list[<server.list_worlds>].contains_text[<context.args.get[4]>]>:
                    - teleport <location[<context.args.first>,<context.args.get[2]>,<context.args.get[3]>,<context.args.get[4]>]>
                    - narrate <yaml[UtilizenLang].read[teleporttoworld].parsed>
                - else:
                    - narrate <yaml[UtilizenLang].read[teleportwrongsyntax4].parsed>
            - default:
                - narrate <yaml[UtilizenLang].read[teleportpossyntax].parsed>
    - else:
        - narrate <yaml[UtilizenLang].read[teleportpossyntax].parsed>
UtilizenTphereCommand:
    type: command
    debug: false
    name: tphere
    description: Teleports a player to your position
    usage: /tphere [Player]
    permission: utilizen.tphere
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.is_empty>:
        - determine <server.list_online_players.parse[name]>
    - else if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.server>:
        - announce to_console "[Utilizen] This command can not be executed from console"
        - stop
    - if <context.args.size> == 1:
        - if <server.player_is_valid[<context.args.first>]>:
            - teleport <server.match_player[<context.args.first>]> <player.location>
            - narrate <yaml[UtilizenLang].read[tphereadmin].parsed> targets:<server.match_player[<context.args.first>]>
        - else:
            - narrate <yaml[UtilizenLang].read[tphereplnotexist].parsed>
    - else:
        - narrate <yaml[UtilizenLang].read[tpheresyntax].parsed>
UtilizenGodCommand:
    type: command
    debug: false
    name: god
    description: Activate Godmode
    usage: /god
    permission: utilizen.god
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if !<context.server>:
        - stop
    script:
    - if !<player.has_flag[god]>:
        - flag <player> god
        - narrate <yaml[UtilizenLang].read[godactivated].parsed>
    - else:
        - flag <player> god:!
        - narrate <yaml[UtilizenLang].read[goddeactivated].parsed>
UtilizenInvseeCommand:
    type: command
    debug: false
    name: invsee
    description: open player inventory
    usage: /invsee [Player]
    permission: utilizen.invsee
    permission message: <&3>You need the permission <&b><permission>
    tab complete:
    - if <context.args.is_empty>:
        - determine <server.list_online_players.parse[name]>
    - else if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.server>:
        - announce to_console "[Utilizen] This command can not be executed from console"
        - stop
    - else if <context.args.size> == 1:
        - if <server.player_is_valid[<context.args.first>]> && <server.match_offline_player[<context.args.first>].is_online>:
            - if <server.match_player[<context.args.first>]> == <player>:
                - narrate <yaml[UtilizenLang].read[invseecantopenown].parsed>:
            - else:
                - inventory open d:<server.match_player[<context.args.first>].inventory>
        - else:
            - narrate <yaml[UtilizenLang].read[invseeplnotonline].parsed>
    - else:
        - narrate <yaml[UtilizenLang].read[invseesyntax].parsed>
UtilizenClearinventoryCommand:
    type: command
    debug: false
    name: clearinventory
    description: delete your inventory
    usage: /clearinventory (Player)
    permission: utilizen.clearinventory
    permisson message: <&3>You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <server.list_online_players.parse[name]>
    - else if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.server>:
        - announce to_console "[Utilizen] This command can not be executed from console"
        - stop
    - else if <context.args.size> == 1:
        - if <server.player_is_valid[<context.args.first>]>:
            - inventory clear d:player[holder=<server.match_player[<context.args.first>]>]
            - narrate <yaml[UtilizenLang].read[clearinventoryadmin].parsed>
            - narrate <yaml[UtilizenLang].read[clearinventoryadmincleared].parsed> targets:<server.match_player[<context.args.first>]>
        - else:
            - narrate <yaml[UtilizenLang].read[clearinventoryplnotexist].parsed>
    - else:
        - inventory clear d:player[holder=<player>]
        - narrate <yaml[UtilizenLang].read[clearinventorycleared].parsed>
UtilizenGCCommand:
    type: command
    debug: false
    name: gc
    description: shows server information
    usage: /gc
    permission: utilizen.gc
    permisson message: <&3>You need the permission <&b><permission>
    tab complete:
    - if !<context.server>:
        - stop
    script:
    - narrate "<yaml[UtilizenLang].read[gcuptime].parsed> <util.date.time.duration.sub[<server.start_time>].formatted>"
    - narrate "<yaml[UtilizenLang].read[gcramfree].parsed> <server.ram_free.div[1048576].round>"
    - narrate "<yaml[UtilizenLang].read[gcramused].parsed> <server.ram_usage.div[1048576].round>"
    - narrate "<yaml[UtilizenLang].read[gcramallocated].parsed> <server.ram_allocated.div[1048576].round>"
    - narrate "<yaml[UtilizenLang].read[gctps].parsed> <server.recent_tps.first.add[<server.recent_tps.get[2].add[<server.recent_tps.get[3]>]>].div[3].round_to_precision[0.001]>"
    - foreach <server.list_worlds.parse[name]>:
        - narrate "<yaml[UtilizenLang].read[gcworld].parsed> <yaml[UtilizenLang].read[gcchunks].parsed> <world[<[value]>].loaded_chunks.size> <yaml[UtilizenLang].read[gcaientities].parsed> <world[<[value]>].living_entities.size> <yaml[UtilizenLang].read[gctiles].parsed> <world[<[value]>].entities.size.sub[<world[<[value]>].living_entities.size>]>"
UtilizenEnchantCommand:
    type: command
    debug: false
    name: enchant
    description: Enchants Items in your Hand
    usage: /enchant
    permission: utilizen.enchant
    permission message: <&3>You need the permission <&b><permission>
    tab complete:
    - if <context.args.is_empty>:
        - determine <server.list_enchantment_keys>
    - else if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_enchantment_keys.filter[starts_with[<context.args.first>]]>
    script:
    - if <context.server>:
        - announce to_console "[Utilizen] This command can not be executed from console"
        - stop
    - choose <context.args.size>:
        - case 1:
            - if <server.list_enchantment_keys.contains[<context.args.first>]>:
                - inventory adjust slot:<player.held_item_slot> remove_enchantments:<context.args.first>
                - narrate <yaml[UtilizenLang].read[enchantremove].parsed>
        - case 2:
            - if <server.list_enchantment_keys.contains[<context.args.first>]>:
                - if <context.args.last.is_integer>:
                    - if <player.item_in_hand.material.name> != air:
                        - if <yaml[UtilizenConfig].read[enchants]>:
                            - if <context.args.last> > 0:
                                - inventory adjust slot:<player.held_item_slot> enchantments:<context.args.first>,<context.args.last>
                                - narrate <yaml[UtilizenLang].read[enchantadd].parsed>
                            - else:
                                - narrate <yaml[UtilizenLang].read[enchantnoint].parsed>
                        - else if <context.args.last.is_integer> && <context.args.last> <= <server.enchantment_max_level[<context.args.first>]> && <context.args.last> >= <server.enchantment_start_level[<context.args.first>]>:
                            - inventory adjust slot:<player.held_item_slot> enchantments:<context.args.first>,<context.args.last>
                            - narrate <yaml[UtilizenLang].read[enchantadd].parsed>
                        - else:
                            - narrate <yaml[UtilizenLang].read[enchantinttohigh].parsed>
                    - else:
                        - narrate <yaml[UtilizenLang].read[enchantnoitem].parsed>
                - else:
                    - narrate <yaml[UtilizenLang].read[enchantnoint].parsed>
            - else:
                - narrate <yaml[UtilizenLang].read[enchantnotvalid].parsed>
        - default:
            - narrate <yaml[UtilizenLang].read[enchantsyntax].parsed>
UtilizenItemDBCommand:
    type: command
    debug: false
    name: itemdb
    description: Shows Item Data
    usage: /itemdb
    permission: utilizen.itemdb
    permission message: <&3>You need the permission <&b><permission>
    tab complete:
    - if !<context.server>:
        - stop
    script:
    - if <context.server>:
        - announce to_console "[Utilizen] This command can not be executed from console"
        - stop
    - define item:<player.item_in_hand>
    - if <[item].is_enchanted>:
        - foreach <[item].enchantments.with_levels>:
            - define "enchlist:->:<&b><&translate[enchantment.minecraft.<[value].before[,]>]> <&f><[value].after[,]>"
    - if <[item].nbt.size> > 0:
        - foreach <[item].nbt>:
            - define "nbtlist:->:<&b><[value].before[/]><&3>/<&r><[value].after[/]>"
    - narrate "<&3>===================<&b>[<&3>ItemDB<&b>]<&3>===================<&nl><&3>Item: <&f><[item].material.name> <&3>Display: <tern[<[item].has_display>].pass[<&r><[item].display>].fail[<&f>NONE]><&nl><&3>dItem: <&b><tern[<[item].has_script>].pass[<&b>true <&3>Script: <&b><[item].script>].fail[<&b>false]><&nl><&3>Repairable: <tern[<[item].repairable>].pass[<&b>true <&3>Durability: <&b><[item].max_durability.sub[<[item].durability>]><&f>/<&b><[item].max_durability>].fail[<&b>false]><&nl><&3>Enchantments: <tern[<[item].is_enchanted>].pass[<[enchlist].separated_by[<&3>, ]>].fail[<&f>NONE]><&nl><&3>Lore: <tern[<[item].has_lore>].pass[<&r><[item].lore.separated_by[<&r> ]>].fail[<&f>NONE]><&nl><&3>dNBT: <tern[<[item].nbt.size.is[<&gt>].than[0]>].pass[<&r><[nbtlist].separated_by[<&3>, ]>].fail[<&f>NONE]>"
UtilizenSeenCommand:
    type: command
    debug: false
    name: seen
    description: Shows last login from a player
    usage: /seen [Player]
    permission: utilizen.seen
    permission message: <&3>You need the permission <&b><permission>
    tab complete:
    - if <context.args.is_empty>:
        - determine <server.list_offline_players.parse[name]>
    - else if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_offline_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.args.size> == 1:
        - if <server.player_is_valid[<context.args.first>]>:
            - if !<server.match_offline_player[<context.args.first>].is_online>:
                - ~yaml load:../Utilizen/data/players/<server.match_offline_player[<context.args.first>].uuid>.yml id:Utilizen_<server.match_offline_player[<context.args.first>].uuid>
            - if !<yaml[Utilizen_<server.match_offline_player[<context.args.first>].uuid>].contains[lastlogin]>:
                - narrate <yaml[UtilizenLang].read[seennever].parsed>
                - stop
            - narrate <yaml[UtilizenLang].read[seenplayer].parsed>
            - if !<server.match_offline_player[<context.args.first>].is_online>:
                - yaml unload id:Utilizen_<server.match_offline_player[<context.args.first>].uuid>
        - else:
            - narrate <yaml[UtilizenLang].read[seennever].parsed>
    - else:
        - narrate <yaml[UtilizenLang].read[seensyntax].parsed>
UtilizenNoteCommand:
    type: command
    debug: false
    name: note
    description: Add a note to a player
    usage: /note [Player] (add/remove) (Text/ID)
    permission: utilizen.note
    permission message: <&3>You need the permission <&b><permission>
    tab complete:
    - choose <context.args.size>:
        - case 0:
            - determine <server.list_players.parse[name]>
        - case 1:
            - if "!<context.raw_args.ends_with[ ]>":
                - determine <server.list_players.parse[name].filter[starts_with[<context.args.first>]]>
            - else:
                - determine <list[add|remove]>
        - case 2:
            - if "!<context.raw_args.ends_with[ ]>":
                - determine <list[add|remove].filter[starts_with[<context.args.get[2]>]]>
    script:
    - if !<context.args.is_empty>:
        - if <server.player_is_valid[<context.args.first>]>:
            - define uuid:<server.match_offline_player[<context.args.first>].uuid>
            - if !<server.match_offline_player[<context.args.first>].is_online>:
                - ~yaml load:../Utilizen/data/players/<[uuid]>.yml id:Utilizen_<[uuid]>
            - choose <context.args.get[2]||default>:
                - case add:
                    - narrate <yaml[UtilizenLang].read[noteadded].parsed>
                    - yaml id:Utilizen_<[uuid]> set noteid:++
                    - yaml id:Utilizen_<[uuid]> set "notes:->:<yaml[Utilizen_<[uuid]>].read[noteid]||1>/<player.name> - <context.args.remove[1|2].space_separated.parse_color><&r>"
                    - ~yaml savefile:../Utilizen/data/players/<[uuid]>.yml id:Utilizen_<[uuid]>
                    - if !<server.match_offline_player[<context.args.first>].is_online>:
                        - yaml unload id:Utilizen_<[uuid]>
                - case remove:
                    - if <context.args.size> == 3:
                        - narrate <yaml[UtilizenLang].read[noteremoved].parsed>
                        - if <yaml[Utilizen_<[uuid]>].read[notes].get_sub_items[1].contains[<context.args.last>]>:
                            - define entry:<yaml[Utilizen_<[uuid]>].read[notes].get_sub_items[1].find[<context.args.last>]>
                            - yaml id:Utilizen_<[uuid]> set notes:<-:<yaml[Utilizen_<[uuid]>].read[notes].get[<[entry]>]>
                        - ~yaml savefile:../Utilizen/data/players/<[uuid]>.yml id:Utilizen_<[uuid]>
                        - if !<server.match_offline_player[<context.args.first>].is_online>:
                            - yaml unload id:Utilizen_<[uuid]>
                - default:
                    - foreach <yaml[Utilizen_<[uuid]>].read[notes]>:
                        - define "notelist:->:[<[value].before[/]>] <[value].after[/]>"
                    - narrate "<yaml[UtilizenLang].read[notelist].parsed><&nl><[notelist].separated_by[<&nl>]||No Notes yet>"
                    - if !<server.match_offline_player[<context.args.first>].is_online>:
                        - yaml unload id:Utilizen_<[uuid]>
        - else:
            - narrate <yaml[UtilizenLang].read[noteplnotexist].parsed>
    - else:
        - narrate <yaml[UtilizenLang].read[notesyntax].parsed>