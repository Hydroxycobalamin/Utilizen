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
        - determine <server.list_online_players.parse[name]>
    - else:
        - stop
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
            - narrate <yaml[UtilizenLang].read[afkplnotonline].parsed> targets:<server.list_online_players>
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
    - if <context.args.is_empty>:
        - determine <list[send|read|remove|<tern[<player.has_permission[utilizen.mail.sendall]>].pass[sendall].fail[]>]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <list[send|read|remove|<tern[<player.has_permission[utilizen.mail.sendall]>].pass[sendall].fail[]>].filter[starts_with[<context.args.first>]]>
    - if <context.args.size> < 2 && <context.args.first> == send:
        - determine <server.list_online_players.parse[name]>
    - if <context.args.size> == 2 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.get[2]>]]>
    script:
    - choose <context.args.first||null>:
        - case send:
            - if <context.args.size> >= 2:
                - if <server.player_is_valid[<context.args.get[2]>]>:
                    - if <context.args.size> > 2:
                        - yaml id:UtilizenServerdata set msgcount:++
                        - yaml savefile:../Utilizen/serverdata.yml id:UtilizenServerdata
                        - yaml id:UtilizenPlayerdata set <server.match_offline_player[<context.args.get[2]>].uuid>.mailbox.msg<yaml[UtilizenServerdata].read[msgcount]||0>:<player.uuid>|<context.args.remove[1|2].space_separated>
                        - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                        - narrate <yaml[UtilizenLang].read[mailsend].parsed>
                    - else:
                        - narrate <yaml[UtilizenLang].read[mailempty].parsed>
                - else:
                    - narrate <yaml[UtilizenLang].read[mailplnotexist].parsed>
            - else:
                - narrate <yaml[UtilizenLang].read[mailneedplayer].parsed>
        - case read:
            - if <yaml[UtilizenPlayerdata].list_keys[<player.uuid>.mailbox]||true>:
                - narrate <yaml[UtilizenLang].read[mailboxempty].parsed>
                - stop
            - foreach <yaml[UtilizenPlayerdata].list_keys[<player.uuid>.mailbox]>:
                - narrate <yaml[UtilizenLang].read[mailread].parsed>
        - case remove:
            - yaml id:UtilizenPlayerdata set <player.uuid>.mailbox:!
            - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
            - narrate <yaml[UtilizenLang].read[maildelete].parsed>
        - case sendall:
            - if <player.has_permission[utilizen.mail.sendall]>:
                - if <context.args.size> > 1:
                    - foreach <server.list_players.parse[uuid]>:
                        - yaml id:UtilizenServerdata set msgcount:++
                        - yaml id:UtilizenPlayerdata set <[value]>.mailbox.msg<yaml[UtilizenServerdata].read[msgcount]||0>:<player.uuid>|<context.args.remove[1].space_separated>
                    - yaml savefile:../Utilizen/serverdata.yml id:UtilizenServerdata
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                    - narrate <yaml[UtilizenLang].read[mailsendall]>
        - default:
            - narrate <yaml[UtilizenLang].read[mailallarguments].parsed>
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
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - if !<context.args.is_empty>:
        - if <server.match_player[<context.args.first>].is_online>:
            - if <context.args.size> != 1:
                - if <context.args.size> > 1:
                    - narrate <yaml[UtilizenLang].read[msgsent].parsed> targets:<player>|<server.match_player[<context.args.first>]>
            - else:
                - narrate <yaml[UtilizenLang].read[msgempty].parsed>
        - else:
            - narrate <yaml[UtilizenLang].read[msgplnotonline].parsed>
    - else:
        - narrate <yaml[UtilizenLang].read[msgsyntax].parsed>
UtilizenNickColor:
    type: command
    debug: false
    name: nickcolor
    description: Changes your own nickcolor
    usage: /nickcolor
    permission: utilizen.nickcolor
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.is_empty>:
        - determine <list[aqua|black|blue|dark_aqua|dark_blue|dark_gray|dark_green|dark_purple|dark_red|gold|gray|green|lightpurple|red|white|yellow]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <list[aqua|black|blue|dark_aqua|dark_blue|dark_gray|dark_green|dark_purple|dark_red|gold|gray|green|lightpurple|red|white|yellow].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.args.size> >= 1:
        - if <list[aqua|black|blue|dark_aqua|dark_blue|dark_gray|dark_green|dark_purple|dark_red|gold|gray|green|lightpurple|red|white|yellow].contains[<context.args.first>]>:
            - choose <context.args.first>:
                - case aqua:
                    - narrate <yaml[UtilizenLang].read[nickcolorchanged].parsed>
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&b><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                    - adjust <player> player_list_name:<&b><player.name>
                - case black:
                    - adjust <player> player_list_name:<&0><player.name>
                    - narrate <yaml[UtilizenLang].read[nickcolorchanged].parsed>
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&0><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case blue:
                    - adjust <player> player_list_name:<&9><player.name>
                    - narrate <yaml[UtilizenLang].read[nickcolorchanged].parsed>
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&9><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case dark_aqua:
                    - adjust <player> player_list_name:<&3><player.name>
                    - narrate <yaml[UtilizenLang].read[nickcolorchanged].parsed>
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&3><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case dark_blue:
                    - adjust <player> player_list_name:<&1><player.name>
                    - narrate <yaml[UtilizenLang].read[nickcolorchanged].parsed>
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&1><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case dark_gray:
                    - adjust <player> player_list_name:<&8><player.name>
                    - narrate <yaml[UtilizenLang].read[nickcolorchanged].parsed>
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&8><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case dark_green:
                    - adjust <player> player_list_name:<&2><player.name>
                    - narrate <yaml[UtilizenLang].read[nickcolorchanged].parsed>
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&2><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case dark_purple:
                    - adjust <player> player_list_name:<&5><player.name>
                    - narrate <yaml[UtilizenLang].read[nickcolorchanged].parsed>
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&5><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case dark_red:
                    - adjust <player> player_list_name:<&4><player.name>
                    - narrate <yaml[UtilizenLang].read[nickcolorchanged].parsed>
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&4><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case gold:
                    - adjust <player> player_list_name:<&6><player.name>
                    - narrate <yaml[UtilizenLang].read[nickcolorchanged].parsed>
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&6><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case gray:
                    - adjust <player> player_list_name:<&7><player.name>
                    - narrate <yaml[UtilizenLang].read[nickcolorchanged].parsed>
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&7><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case green:
                    - adjust <player> player_list_name:<&a><player.name>
                    - narrate <yaml[UtilizenLang].read[nickcolorchanged].parsed>
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&a><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case lightpurple:
                    - adjust <player> player_list_name:<&d><player.name>
                    - narrate <yaml[UtilizenLang].read[nickcolorchanged].parsed>
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&d><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case red:
                    - adjust <player> player_list_name:<&c><player.name>
                    - narrate <yaml[UtilizenLang].read[nickcolorchanged].parsed>
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&c><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case white:
                    - adjust <player> player_list_name:<player.name>
                    - narrate <yaml[UtilizenLang].read[nickcolorchanged].parsed>
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case yellow:
                    - adjust <player> player_list_name:<&e><player.name>
                    - narrate <yaml[UtilizenLang].read[nickcolorchanged].parsed>
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&e><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
        - else:
            - narrate <yaml[UtilizenLang].read[nickcolorwrong].parsed>
    - else:
      - narrate <yaml[UtilizenLang].read[nickcolornocolor].parsed>
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
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.args.size> >= 1:
        - if <server.player_is_valid[<context.args.first>]>:
            - if <context.args.size> == 2:
                - foreach <list[<yaml[UtilizenPlayerdata].list_deep_keys[].filter[contains[nickname]]>|<player.uuid>.nickname].combine>:
                    - if <server.list_players.parse[name].contains[<context.args.get[2]>]> || <yaml[UtilizenPlayerdata].read[<[value]>]||<player.name>> == <context.args.get[2]>:
                        - narrate <yaml[UtilizenLang].read[nickinuse].parsed>
                        - stop
                - define nick:<context.args.get[2].parse_color>
                - adjust <server.match_player[<context.args.first>]> player_list_name:<[nick]>
                - narrate <yaml[UtilizenLang].read[nicksuccess].parsed>
                - narrate <yaml[UtilizenLang].read[nickchanged].parsed>
                - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<context.args.get[2]>
                - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
            - else:
                - adjust <server.match_player[<context.args.first>]> player_list_name:
                - narrate <yaml[UtilizenLang].read[nickdelete].parsed>
                - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:!
                - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
        - else:
            - narrate <yaml[UtilizenLang].read[nickplnotexist].parsed>
    - else:
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
    - foreach <yaml[UtilizenPlayerdata].list_deep_keys[].filter[contains[nickname]]>:
        - define nicklist:->:<yaml[UtilizenPlayerdata].read[<[value]>]>
    - if <[nicklist].is_empty||true>:
        - stop
    - else:
        - determine <[nicklist]>
    script:
    - foreach <yaml[UtilizenPlayerdata].list_deep_keys[].filter[contains[nickname]]>:
        - define nicklist:->:<yaml[Utilizenplayerdata].read[<[value]>]>
    - if <[nicklist].contains[<context.args.first>]||false>:
        - foreach <yaml[UtilizenPlayerdata].list_deep_keys[].filter[contains[nickname]]>:
            - if <yaml[UtilizenPlayerdata].read[<[value]>]> == <context.args.first>:
                - narrate <[value].as_player.name>
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
        - yaml savefile:../Utilizen/serverdata.yml id:UtilizenServerdata
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
            - yaml savefile:../Utilizen/serverdata.yml id:UtilizenServerdata
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
                                - yaml id:UtilizenPlayerdata set <server.match_player[<context.args.first>].uuid>.jail.location:<[playerlocation]>
                                - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
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
        - yaml savefile:../Utilizen/serverdata.yml id:UtilizenServerdata
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
            - yaml savefile:../Utilizen/serverdata.yml id:UtilizenServerdata
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
        - if !<yaml[UtilizenPlayerdata].read[<player.uuid>.homes].get_sub_items[1].contains[<context.args.first>]>:
            - if <player.is_op>:
                - if <yaml[UtilizenPlayerdata].read[<player.uuid>.homes].size||0> <= <yaml[UtilizenConfig].read[op-homes]>:
                        - narrate <yaml[UtilizenLang].read[sethomeset].parsed>
                        - yaml set id:UtilizenPlayerdata <player.uuid>.homes:->:<context.args.first>/<player.location.simple>
                        - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                        - stop
            - foreach <yaml[UtilizenConfig].list_keys[homes]>:
                - if <player.has_permission[utilizen.groups.<[value]>]>:
                    - if <yaml[UtilizenPlayerdata].read[<player.uuid>.homes].size||0> <= <yaml[UtilizenConfig].read[homes.<[value]>]>:
                        - narrate <yaml[UtilizenLang].read[sethomeset].parsed>
                        - yaml set id:UtilizenPlayerdata <player.uuid>.homes:->:<context.args.first>/<player.location.simple>
                        - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                        - stop
                    - else:
                        - narrate <yaml[UtilizenLang].read[sethometomuchhome]>
                        - stop
            - if <yaml[UtilizenPlayerdata].read[<player.uuid>.homes].size||0> <= <yaml[UtilizenConfig].read[default]>:
                - narrate <yaml[UtilizenLang].read[sethomeset].parsed>
                - yaml set id:UtilizenPlayerdata <player.uuid>.homes:->:<context.args.first>/<player.location.simple>
                - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
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
    - if <yaml[UtilizenPlayerdata].contains[<player.uuid>.homes]>:
        - if <context.args.size> < 1:
            - determine <yaml[UtilizenPlayerdata].read[<player.uuid>.homes].get_sub_items[1]>
        - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
            - determine <yaml[UtilizenPlayerdata].read[<player.uuid>.homes].get_sub_items[1].filter[starts_with[<context.args.first>]]>
    script:
    - if <player.has_permission[Utilizen.delhome.other]>:
        - if <context.args.size> == 2 && <server.player_is_valid[<context.args.get[2]>]>:
            - if <yaml[UtilizenPlayerdata].read[<server.match_player[<context.args.get[2]>].uuid>.homes].get_sub_items[1].contains[<context.args.first>]>:
                - yaml set id:UtilizenPlayerdata set <server.match_player[<context.args.get[2]>].uuid>.homes:!|:<yaml[UtilizenPlayerdata].read[<server.match_player[<context.args.get[2]>].uuid>.homes].remove[<yaml[UtilizenPlayerdata].read[<player.uuid>.homes].get_sub_items[1].find[<context.args.first>]>]>
                - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - narrate <yaml[UtilizenLang].read[delhomedeleted].parsed>
                - stop
            - else:
                - narrate <yaml[UtilizenLang].read[delhomeothernohomeexist].parsed>
                - stop
    - else if <yaml[UtilizenPlayerdata].read[<player.uuid>.homes].get_sub_items[1].contains[<context.args.first||null>]>:
        - yaml set id:UtilizenPlayerdata <player.uuid>.homes:!|:<yaml[UtilizenPlayerdata].read[<player.uuid>.homes].remove[<yaml[UtilizenPlayerdata].read[<player.uuid>.homes].get_sub_items[1].find[<context.args.first>]>]>
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
    - if <yaml[UtilizenPlayerdata].contains[<player.uuid>.homes]>:
        - if <context.args.size> < 1:
            - determine <yaml[UtilizenPlayerdata].read[<player.uuid>.homes].get_sub_items[1]>
        - else if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
            - determine <yaml[UtilizenPlayerdata].read[<player.uuid>.homes].get_sub_items[1].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.server>:
        - announce to_console "[Utilizen] This command can not be executed from console"
        - stop
    - if <context.args.is_empty>:
        - if <yaml[UtilizenPlayerdata].read[<player.uuid>.homes].is_empty||false>:
            - teleport <location[<yaml[UtilizenPlayerdata].read[<player.uuid>.homes].get_sub_items[2].first>]>
            - narrate <yaml[UtilizenLang].read[homefirsthomed].parsed>
    - else if <yaml[UtilizenPlayerdata].read[<player.uuid>.homes].get_sub_items[1].contains[<context.args.first>]||false>:
        - teleport <location[<yaml[UtilizenPlayerdata].read[<player.uuid>.homes].map_get[<context.args.first>]>]>
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
    - teleport <player> <world[Test1].spawn_location>
UtilizenBackCommand:
    type: command
    name: back
    description: Warp to your last Position you were teleported from
    usage: /back
    permission: utilizen.back
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if !<context.server>:
        - stop
    script:
    - if <yaml[UtilizenPlayerdata].contains[<player.uuid>.lastlocation]>:
        - teleport <player> <yaml[UtilizenPlayerdata].read[<player.uuid>.lastlocation]>
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
    - if <player.has_permission[utilizen.fly.other]>:
        - if <server.player_is_valid[<context.args.first>]||false>:
            - if !<server.match_player[<context.args.first>].can_fly>:
                - adjust <server.match_player[<context.args.first>]> can_fly:true
                - narrate <yaml[UtilizenLang].read[flyactivatedotherpl].parsed>
                - narrate <yaml[UtilizenLang].read[flyactivated].parsed> targets:<server.match_player[<context.args.first>]>
            - else:
                - adjust <server.match_player[<context.args.first>]> can_fly:false
                - narrate <yaml[UtilizenLang].read[flydeactivatedotherpl].parsed>
                - narrate <yaml[UtilizenLang].read[flydeactivated].parsed> targets:<server.match_player[<context.args.first>]>
    - else if !<player.can_fly>:
        - adjust <player> can_fly:true
        - narrate <yaml[UtilizenLang].read[flyactivated].parsed>
    - else:
        - adjust <player> can_fly:false
        - narrate <yaml[UtilizenLang].read[flydeactivated].parsed>
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
    - if <context.args.is_empty:
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
    - if <server.player_is_valid[<context.args.first>]>:
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
                    - ban add <server.match_player[<context.args.first>]> "reason:<yaml[UtilizenConfig].read[banreason]>"
                - case 2:
                    - ban add <server.match_player[<context.args.first>]> "reason:<context.args.get[2]>"
                - case 3:
                    - if <duration[<context.args.get[3]>]||null> != null:
                        - ban add <server.match_player[<context.args.first>]> "reason:<context.args.get[2]>" duration:<context.args.get[3].as_duration>
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
            - if <server.match_offline_player[<context.args.first>].is_banned>
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
                    - kick <server.match_player[<context.args.first>]> "reason:<yaml[UtilizenConfig].read[kickreason]>"
                - case 2:
                    - kick <server.match_player[<context.args.first>]> "reason:<context.args.get[2]>"
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
        - kick <server.list_online_players.exclude[<player>]> "reason:<yaml[UtilizenConfig].read[kickreason]>"
    - else:
        - kick <server.list_online_players.filter[is_op.not].exclude[<player>]> "reason:<yaml[UtilizenConfig].read[kickreason]>"
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
    - if <context.args.size> < 1:
        - determine <list[0|1|2|3|survival|creative|adventure|spectator]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <list[0|1|2|3|survival|creative|adventure|spectator].filter[starts_with[<context.args.first>]]>
    - if <context.args.size> < 2:
        - determine <server.list_online_players.parse[name]>
    - if <context.args.size> == 2 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.get[2]>]]>
    script:
    - if <context.args.size> == 1:
        - choose <context.args.first>:
            - case "survival":
                - if <player.has_permission[utilizen.gamemode.survival]>:
                    - adjust <player> gamemode:survival
                    - narrate "<yaml[UtilizenLang].read[gamemodechanged].parsed>"
                - else:
                    - narrate "<yaml[UtilizenLang].read[gamemodeneedpermsurvival].parsed>"
            - case "0":
                - if <player.has_permission[utilizen.gamemode.survival]>:
                    - adjust <player> gamemode:survival
                    - narrate "<yaml[UtilizenLang].read[gamemodechanged].parsed>"
                - else:
                    - narrate "<yaml[UtilizenLang].read[gamemodeneedpermsurvival].parsed>"
            - case "creative":
                - if <player.has_permission[utilizen.gamemode.creative]>:
                    - adjust <player> gamemode:creative
                    - narrate "<yaml[UtilizenLang].read[gamemodechanged].parsed>"
                - else:
                    - narrate "<yaml[UtilizenLang].read[gamemodeneedpermcreative].parsed>"
            - case "1":
                - if <player.has_permission[utilizen.gamemode.creative]>:
                    - adjust <player> gamemode:creative
                    - narrate "<yaml[UtilizenLang].read[gamemodechanged].parsed>"
                - else:
                    - narrate "<yaml[UtilizenLang].read[gamemodeneedpermcreative].parsed>"
            - case "adventure":
                - if <player.has_permission[utilizen.gamemode.adventure]>:
                    - adjust <player> gamemode:adventure
                    - narrate "<yaml[UtilizenLang].read[gamemodechanged].parsed>"
                - else:
                    - narrate "<yaml[UtilizenLang].read[gamemodeneedpermadventure].parsed>"
            - case "2":
                - if <player.has_permission[utilizen.gamemode.adventure]>:
                    - adjust <player> gamemode:adventure
                    - narrate "<yaml[UtilizenLang].read[gamemodechanged].parsed>"
                - else:
                    - narrate "<yaml[UtilizenLang].read[gamemodeneedpermadventure].parsed>"
            - case "spectator":
                - if <player.has_permission[utilizen.gamemode.spectator]>:
                    - adjust <player> gamemode:spectator
                    - narrate "<yaml[UtilizenLang].read[gamemodechanged].parsed>"
                - else:
                    - narrate "<yaml[UtilizenLang].read[gamemodeneedpermspectator].parsed>"
            - case "3":
                - if <player.has_permission[utilizen.gamemode.spectator]>:
                    - adjust <player> gamemode:spectator
                    - narrate "<yaml[UtilizenLang].read[gamemodechanged].parsed>"
                - else:
                    - narrate "<yaml[UtilizenLang].read[gamemodeneedpermspectator].parsed>"
        - stop
    - if <context.args.size> > 1:
        - if <server.player_is_valid[<context.args.get[2]>]>:
            - if <player.has_permission[utilizen.gamemode.others]>:
                - choose <context.args.first>:
                    - case "0":
                        - adjust <server.match_player[<context.args.get[2]>]> gamemode:survival
                        - narrate "<yaml[UtilizenLang].read[gamemodechangedother].parsed>"
                        - narrate "<yaml[UtilizenLang].read[gamemodechanged].parsed>" targets:<server.match_player[<context.args.get[2]>]>
                    - case "1":
                        - adjust <server.match_player[<context.args.get[2]>]> gamemode:creative
                        - narrate "<yaml[UtilizenLang].read[gamemodechangedother].parsed>"
                        - narrate "<yaml[UtilizenLang].read[gamemodechanged].parsed>" targets:<server.match_player[<context.args.get[2]>]>
                    - case "2":
                        - adjust <server.match_player[<context.args.get[2]>]> gamemode:adventure
                        - narrate "<yaml[UtilizenLang].read[gamemodechangedother].parsed>"
                        - narrate "<yaml[UtilizenLang].read[gamemodechanged].parsed>" targets:<server.match_player[<context.args.get[2]>]>
                    - case "3":
                        - adjust <server.match_player[<context.args.get[2]>]> gamemode:spectator
                        - narrate "<yaml[UtilizenLang].read[gamemodechangedother].parsed>"
                        - narrate "<yaml[UtilizenLang].read[gamemodechanged].parsed>" targets:<server.match_player[<context.args.get[2]>]>
                    - default:
                        - narrate "<yaml[UtilizenLang].read[gamemodenotexist].parsed>"
                - stop
            - else:
                - narrate "<yaml[UtilizenLang].read[gamemodeneedpermother].parsed>"
        - else:
            - narrate "<yaml[UtilizenLang].read[gamemodeplnotexist].parsed>"
            - stop
    - if <context.args.size> != 1 || <context.args.size> != 2:
        - narrate "<yaml[UtilizenLang].read[gamemodesyntax].parsed>"
UtilizenWeatherCommand:
    type: command
    debug: false
    name: weather
    description: change the weather
    usage: /weather [Type]
    permission: utilizen.weather
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> <= 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <list[sun|rain|storm]>
    script:
    - if <context.args.size> == 1:
        - choose <context.args.first>:
            - case sun:
                - weather sunny
            - case rain:
                - weather storm
            - case storm:
                - weather thunder
            - default:
                - narrate "<yaml[UtilizenLang].read[weathernotexist].parsed>"
    - else:
        - narrate "<yaml[UtilizenLang].read[weathertypes].parsed>"
UtilizenTimeCommand:
    type: command
    debug: false
    name: time
    description: change time
    usage: /time [day|night|set] (Zeit)
    permission: utilizen.time
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> <= 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <list[day|night|set]>
    script:
    - if <context.args.size> == 1:
        - choose <context.args.first>:
            - case day:
                - time 1000t
                - narrate "<yaml[UtilizenLang].read[timeday].parsed>"
            - case night:
                - time 13000t
                - narrate "<yaml[UtilizenLang].read[timenight].parsed>"
            - case set:
                - if <context.args.get[2].is_integer> && <context.args.get[2]> < 24000:
                    - time <duration[<context.args.get[2]>].in_ticks>
                    - narrate "<yaml[UtilizenLang].read[timevariable].parsed>"
                - else:
                    - narrate "<yaml[UtilizenLang].read[timetohigh].parsed>"
            - default:
                - narrate "<yaml[UtilizenLang].read[timeargnotexist].parsed>"
UtilizenTeleportCommand:
    type: command
    debug: false
    name: tp
    description: teleporting!
    usage: /tp [X Y Z|X Y Z World|Player] (Player)
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
                - narrate "<yaml[UtilizenLang].read[teleporttoplayer].parsed>"
            - else:
                - narrate "<yaml[UtilizenLang].read[teleportwrongsyntax1].parsed>"
        - case 2:
            - if <server.player_is_valid[<context.args.first>]> && <server.player_is_valid[<context.args.get[2]>]>:
                - teleport <server.match_player[<context.args.first>]> <server.match_player[<context.args.get[2]>].location>
                - narrate "<yaml[UtilizenLang].read[teleportpltopl].parsed>"
            - else:
                - narrate "<yaml[UtilizenLang].read[teleportwrongsyntax2].parsed>"
        - case 3:
            - if <context.args.first.is_integer> && <context.args.get[2].is_integer> && <context.args.get[3].is_integer>:
                - teleport <player> <location[<context.args.first>,<context.args.get[2]>,<context.args.get[3]>,<player.location.world.name>]>
                - narrate "<yaml[UtilizenLang].read[teleporttopos].parsed>"
            - else:
                - narrate "<yaml[UtilizenLang].read[teleportwrongsyntax3].parsed>"
        - case 4:
            - if <context.args.first.is_integer> && <context.args.get[2].is_integer> && <context.args.get[3].is_integer> && <list[<server.list_worlds>].contains_text[<context.args.get[4]>]>:
                - teleport <player> <location[<context.args.first>,<context.args.get[2]>,<context.args.get[3]>,<context.args.get[4]>]>
                - narrate "<yaml[UtilizenLang].read[teleporttoworld].parsed>"
            - else:
                - narrate "<yaml[UtilizenLang].read[teleportwrongsyntax4].parsed>"
        - default:
            - narrate "<yaml[UtilizenLang].read[teleportsyntax].parsed>"
UtilizenTphereCommand:
    type: command
    debug: false
    name: tphere
    description: teleport a player to you
    usage: /tphere [Player]
    permission: utilizen.tphere
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <server.list_online_players.parse[name]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.args.size> == 1:
        - if <server.player_is_valid[<context.args.first>]>:
            - teleport <server.match_player[<context.args.first>]> <player.location>
            - narrate "<yaml[UtilizenLang].read[tphereadmin].parsed>" targets:<server.match_player[<context.args.first>]>
        - else:
            - narrate "<yaml[UtilizenLang].read[tphereplnotexist].parsed>"
    - else:
        - narrate "<yaml[UtilizenLang].read[tpheresyntax].parsed>"
UtilizenGodCommand:
    type: command
    debug: false
    name: god
    description: activate godmode
    usage: /god
    permission: utilizen.tphere
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if !<context.server>:
        - stop
    script:
    - if !<player.has_flag[god]>:
        - flag <player> god:true
        - narrate "<yaml[UtilizenLang].read[godactivated].parsed>"
    - else:
        - flag <player> god:!
        - narrate "<yaml[UtilizenLang].read[goddeactivated].parsed>"
UtilizenMOTD:
    type: world
    debug: false
    events:
        on player joins:
        - foreach <yaml[UtilizenConfig].read[motd]>:
            - narrate <[value].parsed>
UtilizenInvseeCommand:
    type: command
    debug: false
    name: invsee
    description: open player inventory
    usage: /invsee [Player]
    permission: utilizen.invsee
    permission message: <&3>You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <server.list_online_players.parse[name]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.args.size> >= 1:
        - if <server.player_is_valid[<context.args.first>]>:
            - inventory open d:<server.match_player[<context.args.first>].inventory>
        - else:
            - narrate "<yaml[UtilizenLang].read[invseeplnotexist].parsed>"
    - else:
        - narrate "<yaml[UtilizenLang].read[invseesyntax].parsed>"
UtilizenClearinventoryCommand:
    type: command
    debug: false
    name: clearinventory
    description: delete your inventory
    usages: /clearinventory
    permission: utilizen.clearinventory
    permisson message: <&3>You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <server.list_online_players.parse[name]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.args.size> == 1:
        - if <server.player_is_valid[<context.args.first>]>:
            - inventory clear d:player[holder=<server.match_player[<context.args.first>]>]
            - narrate "<yaml[UtilizenLang].read[clearinventoryadmin].parsed>"
            - narrate "<yaml[UtilizenLang].read[clearinventoryadmincleared].parsed>" targets:<server.match_player[<context.args.first>]>
        - else:
            - narrate "<yaml[UtilizenLang].read[clearinventoryplnotexist].parsed>"
    - else:
        - inventory clear d:player[holder=<player>]
        - narrate "<yaml[UtilizenLang].read[clearinventorycleared].parsed>"
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
    - narrate "Uptime: <util.date.time.duration.sub[<server.start_time>].formatted>"
    - narrate "RAM Free: <&2><server.ram_free.div[1048576].round><&r>"
    - narrate "RAM Used: <&2><server.ram_usage.div[1048576].round>"
    - narrate "RAM Allocated <&2><server.ram_allocated.div[1048576].round>"
    - narrate "Current TPS: <server.recent_tps.first.add[<server.recent_tps.get[2].add[<server.recent_tps.get[3]>]>].div[3].round_to_precision[0.001]>
    - foreach <server.list_worlds.parse[name]>:
        - narrate "<[value]>: Chunks: <world[<[value]>].loaded_chunks.size> AIEntities:<world[<[value]>].living_entities.size> Tiles:<world[<[value]>].entities.size.sub[<world[<[value]>].living_entities.size>]>