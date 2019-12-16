UtilizenCommandAFK:
    type: command
    debug: false
    name: afk
    description: toggles afk
    usage: /afk
    permission: utilizen.afk
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if !<context.server>:
        - stop
    script:
        - if !<player.has_flag[afk]>:
            - narrate "<yaml[UtilizenLang].read[afk].parsed.parse_color>" targets:<server.list_online_players>
            - flag player afk
            - permission add smoothsleep.ignore
        - else:
            - narrate "<yaml[UtilizenLang].read[afkback].parsed.parse_color>" targets:<server.list_online_players>
            - flag player afk:!
            - permission remove smoothsleep.ignore
UtilizenCommandMail:
    type: command
    debug: false
    name: mail
    description: Read and Send mails!
    usage: /mail [send|read|remove] (Player) (Message)
    permission: utilizen.mail
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <list[send|read|remove]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <list[send|read|remove].filter[starts_with[<context.args.first>]]>
    - if <context.args.size> < 2 && <context.args.first> == send:
        - determine <server.list_online_players.parse[name]>
    - if <context.args.size> == 2 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.get[2]>]]>
    script:
    - if <context.args.size> >= 1:
        - choose <context.args.first>:
            - case send:
                - if <context.args.size> >= 2:
                    - if <server.player_is_valid[<context.args.get[2]>]>:
                        - if <context.args.size> > 2:
                            - flag server msgcnt:++
                            - yaml id:UtilizenPlayerdata set <server.match_offline_player[<context.args.get[2]>].uuid>.msg<server.flag[msgcnt]>:<list[<player.uuid>|<context.args.remove[1|2].space_separated>]>
                            - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                            - narrate "<yaml[UtilizenLang].read[mailsend].parsed.parse_color>"
                        - else:
                            - narrate "<yaml[UtilizenLang].read[mailempty].parsed.parse_color>"
                    - else:
                        - narrate "<yaml[UtilizenLang].read[mailplnoexist].parsed.parse_color>"
                - else:
                    - narrate "<yaml[UtilizenLang].read[mailneedplayer].parsed.parse_color>"
            - case read:
                - if <yaml[UtilizenPlayerdata].list_keys[<player.uuid>]||null> == null:
                    - narrate "<yaml[UtilizenLang].read[mailboxempty].parsed.parse_color>"
                    - stop
                - foreach <yaml[UtilizenPlayerdata].list_keys[<player.uuid>]>:
                    - narrate "<yaml[UtilizenLang].read[mailread].parsed.parse_color>"
            - case remove:
                - yaml id:UtilizenPlayerdata set <player.uuid>:!
                - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - narrate "<yaml[UtilizenLang].read[maildelete].parsed.parse_color>"
            - default:
                - narrate "<yaml[UtilizenLang].read[mailarguments].parsed.parse_color>"
    - else:
        - narrate "<yaml[UtilizenLang].read[mailallarguments].parsed.parse_color>"
UtilizenMeCommand:
    type: command
    debug: false
    name: me
    description: Me
    usage: /me [Message]
    permission: utilizen.me
    permission message: <&3>[Permission] You need the permission <&b>Utilizen.me

    tab complete:
    - if !<context.server>:
        - stop
    script:
    - if <context.args.size> > 0:
        - narrate "<yaml[UtilizenLang].read[me].parsed.parse_color>" targets:<server.list_online_players>
    - else:
        - narrate "<yaml[UtilizenLang].read[meempty].parsed.parse_color>"
UtilizenMSGCommand:
    type: command
    debug: false
    name: msg
    description: send private messages
    usage: /msg [Player] [Message]
    permission: utilizen.msg
    permission message: <&3>[Permission] You need the permission <&b>Utilizen.msg
    tab complete:
    - if <context.args.size> < 1:
        - determine <server.list_online_players.parse[name]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - if !<context.args.is_empty>:
        - if <server.player_is_valid[<context.args.first>]>:
            - if <context.args.size> != 1:
                - if <context.args.size> > 1:
                    - narrate "<yaml[UtilizenLang].read[msgsent].parsed.parse_color>" targets:<player>|<server.match_player[<context.args.first>]>
            - else:
                - narrate "<yaml[UtilizenLang].read[msgempty].parsed.parse_color>"
        - else:
            - narrate "<yaml[UtilizenLang].read[msgplnotexist].parsed.parse_color>"
    - else:
        - narrate "<yaml[UtilizenLang].read[msgsyntax].parsed.parse_color>"
UtilizenNickColor:
    type: command
    debug: false
    name: nickcolor
    description: changes nickcolor
    usage: /nickcolor
    permission: utilizen.nickcolor
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <list[aqua|black|blue|darkaqua|darkblue|darkgray|darkgreen|darkpurple|darkred|gold|gray|green|lightpurple|red|white|yellow]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <list[aqua|black|blue|darkaqua|darkblue|darkgray|darkgreen|darkpurple|darkred|gold|gray|green|lightpurple|red|white|yellow].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.args.size> >= 1:
        - if <list[aqua|black|blue|darkaqua|darkblue|darkgray|darkgreen|darkpurple|darkred|gold|gray|green|lightpurple|red|white|yellow].contains[<context.args.first>]>:
            - choose <context.args.first>:
                - case "aqua":
                    - narrate "<yaml[UtilizenLang].read[nickcolorchanged].parsed.parse_color>"
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&b><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                    - adjust <player> player_list_name:<&b><player.name>
                - case "black":
                    - adjust <player> player_list_name:<&0><player.name>
                    - narrate "<yaml[UtilizenLang].read[nickcolorchanged].parsed.parse_color>"
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&0><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case "blue":
                    - adjust <player> player_list_name:<&9><player.name>
                    - narrate "<yaml[UtilizenLang].read[nickcolorchanged].parsed.parse_color>"
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&9><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case "darkaqua":
                    - adjust <player> player_list_name:<&3><player.name>
                    - narrate "<yaml[UtilizenLang].read[nickcolorchanged].parsed.parse_color>"
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&3><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case "darkblue":
                    - adjust <player> player_list_name:<&1><player.name>
                    - narrate "<yaml[UtilizenLang].read[nickcolorchanged].parsed.parse_color>"
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&1><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case "darkgray":
                    - adjust <player> player_list_name:<&8><player.name>
                    - narrate "<yaml[UtilizenLang].read[nickcolorchanged].parsed.parse_color>"
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&8><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case "darkgreen":
                    - adjust <player> player_list_name:<&2><player.name>
                    - narrate "<yaml[UtilizenLang].read[nickcolorchanged].parsed.parse_color>"
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&2><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case "darkpurple":
                    - adjust <player> player_list_name:<&5><player.name>
                    - narrate "<yaml[UtilizenLang].read[nickcolorchanged].parsed.parse_color>"
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&5><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case "darkred":
                    - adjust <player> player_list_name:<&4><player.name>
                    - narrate "<yaml[UtilizenLang].read[nickcolorchanged].parsed.parse_color>"
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&4><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case "gold":
                    - adjust <player> player_list_name:<&6><player.name>
                    - narrate "<yaml[UtilizenLang].read[nickcolorchanged].parsed.parse_color>"
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&6><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case "gray":
                    - adjust <player> player_list_name:<&7><player.name>
                    - narrate "<yaml[UtilizenLang].read[nickcolorchanged].parsed.parse_color>"
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&7><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case "green":
                    - adjust <player> player_list_name:<&a><player.name>
                    - narrate "<yaml[UtilizenLang].read[nickcolorchanged].parsed.parse_color>"
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&a><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case "lightpurple":
                    - adjust <player> player_list_name:<&d><player.name>
                    - narrate "<yaml[UtilizenLang].read[nickcolorchanged].parsed.parse_color>"
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&d><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case "red":
                    - adjust <player> player_list_name:<&c><player.name>
                    - narrate "<yaml[UtilizenLang].read[nickcolorchanged].parsed.parse_color>"
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&c><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case "white"
                    - adjust <player> player_list_name:<player.name>
                    - narrate "<yaml[UtilizenLang].read[nickcolorchanged].parsed.parse_color>"
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - case "yellow"
                    - adjust <player> player_list_name:<&e><player.name>
                    - narrate "<yaml[UtilizenLang].read[nickcolorchanged].parsed.parse_color>"
                    - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<&e><player.name>
                    - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
        - else:
            - narrate "<yaml[UtilizenLang].read[nickcolorwrong].parsed.parse_color>"
    - else:
      - narrate "<yaml[UtilizenLang].read[nickcolornocolor].parsed.parse_color>"
UtilizenNickCommand:
    type: command
    debug: false
    name: nick
    description: nick people
    usage: /nick
    permission: Utilizen.nick
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <server.list_online_players.parse[name]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.args.size> >= 1:
        - if <server.player_is_valid[<context.args.first>]>:
            - if <context.args.size> != 1:
                - define and:<context.args.get[2].to_list.replace[&].with[<&ss>]>
                - adjust <server.match_player[<context.args.first>]> player_list_name:<[and].unseparated>
                - narrate "<yaml[UtilizenLang].read[nicksuccess].parsed.parse_color>"
                - narrate "<yaml[UtilizenLang].read[nickchanged].parsed.parse_color>"
                - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:<[and].unseparated>
                - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - stop
            - else:
                - adjust <server.match_player[<context.args.first>]> player_list_name:
                - narrate "<yaml[UtilizenLang].read[nickdelete].parsed.parse_color>"
                - yaml id:UtilizenPlayerdata set <player.uuid>.nickname:!
                - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
        - else:
            - narrate "<yaml[UtilizenLang].read[nickplnotexist].parsed.parse_color>"
    - else:
        - narrate "<yaml[UtilizenLang].read[nicksyntax].parsed.parse_color>"
UtilizenSetWarpCommand:
    type: command
    debug: false
    name: setwarp
    description: Creates a warp
    usage: /setwarp [Warpname]
    permission: Utilizen.setwarp
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if !<context.server>:
        - stop
    script:
    - if <context.args.size> >= 1:
        - yaml id:UtilizenServerdata set warps.<context.args.first>:<player.location>
        - yaml savefile:../Utilizen/serverdata.yml id:UtilizenServerdata
        - narrate "<yaml[UtilizenLang].read[warpcreate].parsed.parse_color>"
    - else:
        - narrate "<yaml[UtilizenLang].read[warpnoname].parsed.parse_color>"
UtilizenDelWarpCommand:
    type: command
    debug: false
    name: delwarp
    description: delete warps
    usage: /delwarp [Name]
    permission: Utilizen.delwarp
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <yaml[UtilizenServerdata].list_keys[warps]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <yaml[UtilizenServerdata].list_keys[warps].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.args.size> >= 1:
        - if <yaml[UtilizenServerdata].contains[<context.args.first>]>:
            - yaml id:UtilizenServerdata set <context.args.first>:!
            - yaml savefile:../Utilizen/serverdata.yml id:UtilizenServerdata
            - narrate "<yaml[UtilizenLang].read[warpdelete].parsed.parse_color>"
        - else:
            - narrate "<yaml[UtilizenLang].read[warpnotexist].parsed.parse_color>"
    - else:
        - narrate "<yaml[UtilizenLang].read[warpnoarg].parsed.parse_color>"
UtilizenWarpCommand:
    type: command
    debug: false
    name: warp
    description: warp to warp!
    usage: /warp [Name]
    permission: utilizen.warp
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <yaml[UtilizenServerdata].list_keys[warps]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <yaml[UtilizenServerdata].list_keys[warps].filter[starts_with[<context.args.first>]]>
    - if <context.args.size> < 2:
        - determine <server.list_online_players.parse[name]>
    - if <context.args.size> == 2 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.args.size> >= 1:
        - if <yaml[UtilizenServerdata].contains[warps.<context.args.first>]>:
            - if <context.args.size> == 1:
                - teleport <player> <yaml[UtilizenServerdata].read[warps.<context.args.first>]>
                - narrate "<yaml[UtilizenLang].read[warpsuccess].parsed.parse_color>"
                - stop
            - if <context.args.size> == 2:
                - if <server.player_is_valid[<context.args.get[2]>]>:
                    - teleport <server.match_player[<context.args.get[2]>]> <yaml[UtilizenServerdata].read[warps.<context.args.first>]>
                    - narrate "<yaml[UtilizenLang].read[warpedbyadmin].parsed.parse_color>" targets:<server.match_player[<context.args.get[2]>]>
                    - narrate "<yaml[UtilizenLang].read[warpedplayer].parsed.parse_color>"
        - else:
            - narrate "<yaml[UtilizenLang].read[warpnotexist].parsed.parse_color>"
    - else:
        - narrate "<yaml[UtilizenLang].read[warplist].parsed.parse_color>"
UtilizenJailCommand:
    type: command
    debug: false
    name: jail
    description: jail someone
    usage: /jail [Player] [Duration]
    permission: Utilizen.jail
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <server.list_online_players.parse[name]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    - if <context.args.size> < 2:
        - determine <yaml[UtilizenServerdata].list_keys[jailname]>
    - if <context.args.size> == 2 && "!<context.raw_args.ends_with[ ]>":
        - determine <yaml[UtilizenServerdata].list_keys[jailname].filter[starts_with[<context.args.get[2]>]]>
    - if <context.args.size> == 3 && "!<context.raw_args.ends_with[ ]>":
        - determine <list[<context.args.get[3]>s|<context.args.get[3]>m|<context.args.get[3]>h|<context.args.get[3]>d]>
    script:
    - if <context.args.size> >= 1:
        - if <server.player_is_valid[<context.args.first>]>:
            - if !<server.match_player[<context.args.first>].has_flag[jail]>:
                - if <context.args.size> >= 2:
                    - define playerlocation:<server.match_player[<context.args.first>].location>
                    - if <yaml[UtilizenServerdata].contains[jailname.<context.args.get[2]>]>:
                        - if <context.args.size> == 3:
                            - if <duration[<context.args.get[3]>]||null> != null:
                                - yaml id:UtilizenPlayerdata set <server.match_player[<context.args.first>].uuid>.jail.location:<[playerlocation]>
                                - yaml id:UtilizenPlayerdata set <server.match_player[<context.args.first>].uuid>.jail.group:<server.match_player[<context.args.first>].groups.first>
                                - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                                - group set jailed player:<server.match_player[<context.args.first>]>
                                - teleport <server.match_player[<context.args.first>]> <yaml[UtilizenServerdata].read[jailname.<context.args.get[2]>]>
                                - flag <server.match_player[<context.args.first>]> jail:true d:<context.args.get[3].as_duration>
                                - narrate "<yaml[UtilizenLang].read[jailjailedadmin].parsed.parse_color>"
                                - if <server.match_player[<context.args.first>].is_online> && <server.match_player[<context.args.first>]||null> != null:
                                    - waituntil rate:20t !<server.match_player[<context.args.first>].has_flag[jail]||null>
                                    - if <server.match_player[<context.args.first>]||null> == null:
                                        - stop
                                    - teleport <server.match_player[<context.args.first>]> <[playerlocation]>
                                    - group set <yaml[UtilizenPlayerdata].read[<server.match_player[<context.args.first>].uuid>.jail.group]> player:<server.match_player[<context.args.first>]>
                                    - narrate "<yaml[UtilizenLang].read[jailexit].parsed.parse_color>" targets:<server.match_player[<context.args.first>]>
                                    - stop
                            - else:
                                - narrate "<yaml[UtilizenLang].read[jailtimeinvalid].parsed.parse_color>"
                        - else:
                            - narrate "<yaml[UtilizenLang].read[jailnotime].parsed.parse_color>"
                    - else:
                        - narrate "<yaml[UtilizenLang].read[jailnotexist].parsed.parse_color>"
                - else:
                    - narrate "<yaml[UtilizenLang].read[jailwrongsyntax].parsed.parse_color>"
            - else:
                - narrate "<yaml[UtilizenLang].read[jailalreadyjailed].parsed.parse_color>"
        - else:
            - narrate "<yaml[UtilizenLang].read[jailplnotexist].parsed.parse_color>"
    - else:
        - narrate "<yaml[UtilizenLang].read[jailsyntax].parsed.parse_color>"
UtilizenSetJailCommand:
    type: command
    debug: false
    name: setjail
    description: creates a jail
    usage: /setjail [Name]
    permission: Utilizen.setjail
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if !<context.server>:
        - stop
    script:
    - if <context.args.size> >= 1:
        - yaml id:UtilizenServerdata set jailname.<context.args.first>:<player.location>
        - yaml savefile:../Utilizen/serverdata.yml id:UtilizenServerdata
        - narrate "<yaml[UtilizenLang].read[jailcreate].parsed.parse_color>"
    - else:
        - narrate "<yaml[UtilizenLang].read[jailnoname].parsed.parse_color>"
UtilizenDelJailCommand:
    type: command
    debug: false
    description: delete a jail
    usage: /deljail [Name]
    name: deljail
    permission: Utilizen.deljail
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <yaml[UtilizenServerdata].list_keys[jailname]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <yaml[UtilizenServerdata].list_keys[jailname].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.args.size> >= 1:
        - if <yaml[UtilizenServerdata].contains[jailname.<context.args.first>]>:
            - yaml id:dEsssentialsServerdata set jailname.<context.args.first>:!
            - yaml savefile:../Utilizen/serverdata.yml id:UtilizenServerdata
            - narrate "<yaml[UtilizenLang].read[jaildeleted].parsed.parse_color>"
        - else:
            - narrate "<yaml[UtilizenLang].read[notexist].parsed.parse_color>"
    - else:
        - narrate "<yaml[UtilizenLang].read[jailnojail].parsed.parse_color>"
UtilizenUnJailCommand:
    type: command
    debug: false
    name: unjail
    description: unjail a player
    usage: /unjail [Player]
    permission: utilizen.unjail
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <server.list_online_players.parse[name]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.args.size> >= 1:
        - if <server.player_is_valid[<context.args.first>]>:
            - if <server.match_player[<context.args.first>].has_flag[jail]>:
                - flag <server.match_player[<context.args.first>]> jail:!
            - else:
                - narrate "<yaml[UtilizenLang].read[jailnotinjail].parsed.parse_color>"
        - else:
            - narrate "<yaml[UtilizenLang].read[jailplnotexist].parsed.parse_color>"
    - else:
        - narrate "<yaml[UtilizenLang].read[jailnoplayer].parsed.parse_color>"
UtilizenJailQuitWorld:
    type: world
    debug: false
    events:
        on player quits:
        - if <player.has_flag[jail]>:
            - yaml id:UtilizenPlayerdata set <player.uuid>.jail.duration:<player.flag[jail].expiration>
            - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
            - flag <player> jail:!
        on player joins:
        - if <yaml[UtilizenPlayerdata].read[<player.uuid>.jail.duration]||null> != null:
            - flag <player> jail:true d:<yaml[UtilizenPlayerdata].read[<player.uuid>.jail.duration]>
            - teleport <player> <yaml[UtilizenServerdata].read[jailname.<yaml[UtilizenServerdata].list_keys[jailname].random>]>
            - narrate "<yaml[UtilizenLang].read[jailstilljailed].parsed.parse_color>"
            - if <player.is_online> && <player[<player>]||null> != null:
                - waituntil rate:20t !<player.has_flag[jail]||null>
                - if <server.match_player[<player.name>]||null> == null:
                    - stop
                - teleport <player> <yaml[UtilizenPlayerdata].read[<player.uuid>.jail.location]>
                - group set <yaml[UtilizenPlayerdata].read[<player.uuid>.jail.group]>
                - yaml id:UtilizenPlayerdata set <player.uuid>.jail:!
                - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - narrate "<yaml[UtilizenLang].read[jailexit].parsed.parse_color>"
                - stop
UtlizenSetHomeCommand:
    type: command
    debug: false
    description: Sets your home
    usage: /sethome [name]
    name: sethome
    permission: utilizen.sethome
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if !<context.server>:
        - stop
    script:
    - if <context.args.is_empty>:
        - narrate "<yaml[UtilizenLang].read[sethomenoargs].parsed.parse_color>"
        - stop
    - if <context.args.size> == 1:
        - if !<yaml[UtilizenPlayerdata].read[<player.uuid>.homes].get_sub_items[1].contains[<context.args.first>]>:
            - if <player.is_op>:
                - goto a
            - foreach <yaml[UtilizenConfig].list_keys[homes]>:
                - if <player.has_permission[utilizen.groups.<[value]>]>:
                    - if <yaml[UtilizenPlayerdata].read[<player.uuid>.homes].size||0> <= <yaml[UtilizenConfig].read[homes.<[value]>]>:
                        - mark a
                        - narrate "<yaml[UtilizenLang].read[sethomeset].parsed.parse_color>"
                        - yaml set id:UtilizenPlayerdata <player.uuid>.homes:->:<context.args.first>/<player.location.simple>
                        - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                        - stop
                    - else:
                        - narrate "<yaml[UtilizenLang].read[sethometomuchhome]>"
                        - stop
            - if <yaml[UtilizenPlayerdata].read[<player.uuid>.homes].size||0> <= <yaml[UtilizenConfig].read[default]>:
                - narrate "<yaml[UtilizenLang].read[sethomeset].parsed.parse_color>"
                - yaml set id:UtilizenPlayerdata <player.uuid>.homes:->:<context.args.first>/<player.location.simple>
                - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
        - else:
            - narrate "<yaml[UtilizenLang].read[sethomealreadyset].parsed.parse_color>"
UtilizenDelHomeCommand:
    type: command
    debug: false
    description: Delete your Home
    usage: /delhome [name]
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
            - if <yaml[UtilizenPlayerdata].read[<server.match_player[<context.args.get[2]>]>.homes].get_sub_items[1].contains[<context.args.first||null>]>:
                - yaml set id:UtilizenPlayerdata set <server.match_player[<context.args.get[2]>].uuid>.homes:!|:<yaml[UtilizenPlayerdata].read[<server.match_player[<context.args.get[2]>].uuid>.homes].remove[<yaml[UtilizenPlayerdata].read[<player.uuid>.homes].get_sub_items[1].find[<context.args.first>]>]>
                - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
                - narrate "<yaml[UtilizenLang].read[delhomedeleted].parsed.parse_color>"
                - stop
            - else:
                - narrate "<yaml[UtilizenLang].read[delhomeothernohomexist].parsed.parse_color>"
                - stop
    - if <yaml[UtilizenPlayerdata].read[<player.uuid>.homes].get_sub_items[1].contains[<context.args.first||null>]>:
        - yaml set id:UtilizenPlayerdata <player.uuid>.homes:!|:<yaml[UtilizenPlayerdata].read[<player.uuid>.homes].remove[<yaml[UtilizenPlayerdata].read[<player.uuid>.homes].get_sub_items[1].find[<context.args.first>]>]>
    - else:
        - narrate "<yaml[UtilizenLang].read[delhomenohomeexist].parsed.parse_color>"
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
        - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
            - determine <yaml[UtilizenPlayerdata].read[<player.uuid>.homes].get_sub_items[1].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.args.is_empty>:
        - if !<yaml[UtilizenPlayerdata].read[<player.uuid>.homes].size.is_empty||false>:
            - teleport <location[<yaml[UtilizenPlayerdata].read[<player.uuid>.homes].get_sub_items[2].first>]>
            - narrate "<yaml[UtilizenLang].read[homefirsthomed].parsed.parse_color>"
            - stop
    - if <yaml[UtilizenPlayerdata].read[<player.uuid>.homes].get_sub_items[1].contains[<context.args.first>]||false>:
        - teleport <location[<yaml[UtilizenPlayerdata].read[<player.uuid>.homes].map_get[<context.args.first>]>]>
        - narrate "<yaml[UtilizenLang].read[homehomed].parsed.parse_color>"
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
    - if <player.equipment.helmet.material.name> == air:
        - equip head:<player.item_in_hand>
        - inventory set slot:<player.item_in_hand.slot> o:air
    - else:
        - narrate "<yaml[UtilizenLang].read[hatoccupied].parsed.parse_color>"
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
    - narrate "<yaml[UtilizenLang].read[spawn].parsed.parse_color>"
    - teleport <player> <world[Test1].spawn_location>
UtilizenBackCommand:
    type: command
    debug: false
    name: back
    description: back to back!
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
        - narrate "<yaml[UtilizenLang].read[backinvalid].parsed.parse_color>"
UtilizenFlyCommand:
    type: command
    debug: false
    name: fly
    description: fly!
    usage: /fly
    permission: utilizen.fly
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if !<context.server>:
        - stop
    script:
    - if !<player.can_fly>:
        - adjust <player> can_fly:true
        - narrate "<yaml[UtilizenLang].read[flyactivated].parsed.parse_color>"
    - else:
        - adjust <player> can_fly:false
        - narrate "<yaml[UtilizenLang].read[flydeactivated].parsed.parse_color>"
UtilizenVanishCommand:
    type: command
    debug: false
    name: vanish
    description: makes you invisible
    usage: /vanish
    permission: Utilizen.vanish
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
        - if !<context.server>:
            - stop
    script:
    - invisible <player> toggle
    - narrate "<yaml[UtilizenLang].read[vanishactivated].parsed.parse_color>"
UtilizenBurnCommand:
    type: command
    debug: false
    name: burn
    description: burn some player!
    usage: /burn [Player] [Duration]
    permission: utilizen.burn
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <server.list_online_players.parse[name]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.args.size> >= 1:
        - if <server.player_is_valid[<context.args.first>]>:
            - if <context.args.size> == 2:
                - if <duration[<context.args.get[2]>]||null> != null:
                    - burn <server.match_player[<context.args.first>]> <context.args.get[2].as_duration>
                - else:
                    - narrate "<yaml[UtilizenLang].read[burntimeinvalid].parsed.parse_color>"
            - else:
                - narrate "<yaml[UtilizenLang].read[burnnotime].parsed.parse_color>"
        - else:
            - narrate "<yaml[UtilizenLang].read[burnplnotexist].parsed.parse_color>"
    - else:
        - narrate "<yaml[UtilizenLang].read[burnsyntax].parsed.parse_color>"
UtilizenHealCommand:
    type: command
    debug: false
    name: heal
    description: heals you
    usage: /heal (Player)
    permission: utilizen.heal
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <server.list_online_players.parse[name]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.args.size> == 0:
        - heal <player>
        - narrate "<yaml[UtilizenLang].read[healhealed].parsed.parse_color>"
        - stop
    - if <server.player_is_valid[<context.args.first>]>:
        - heal <server.match_player[<context.args.first>]>
        - narrate "<yaml[UtilizenLang].read[healadmin].parsed.parse_color>"
        - narrate "<yaml[UtilizenLang].read[healhealed].parsed.parse_color>" targets:<server.match_player[<context.args.first>]>
    - else:
        - narrate "<yaml[UtilizenLang].read[healplnotexist].parsed.parse_color>"
UtilizenFeedCommand:
    type: command
    debug: false
    name: feed
    description: feed someone!
    usage: /feed (Player)
    permission: utilizen.feed
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <server.list_online_players.parse[name]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.args.size> == 0:
        - while <player.food_level> != 20:
            - if <[loop_index]> >= 40:
                - stop
            - feed <player> amount:1
        - narrate "<yaml[UtilizenLang].read[feedfeeded].parsed.parse_color>"
        - stop
    - if <server.player_is_valid[<context.args.first>]>:
        - while <server.match_player[<context.args.first>].food_level> != 20:
            - if <[loop_index]> >= 40:
                - stop
            - feed <server.match_player[<context.args.first>]> amount:1
        - narrate "<yaml[UtilizenLang].read[feedadmin].parsed.parse_color>"
        - narrate "<yaml[UtilizenLang].read[feedfeeded].parsed.parse_color>" targets:<server.match_player[<context.args.first>]>
UtilizenMuteCommand:
    type: command
    debug: false
    name: mute
    description: mute a player!
    usage: /mute [Player] [Duration]
    permission: utilizen.mute
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <server.list_online_players.parse[name]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    - if <context.args.size> == 2 && "!<context.raw_args.ends_with[ ]>":
        - determine <list[<context.args.get[2]>s|<context.args.get[2]>m|<context.args.get[2]>h|<context.args.get[2]>d]>
    script:
    - if <context.args.size> >= 1:
        - if <server.player_is_valid[<context.args.first>]>:
            - if !<server.match_player[<context.args.first>].has_flag[mute]>:
                - if <context.args.size> >= 2:
                    - if <duration[<context.args.get[2]>]||null> != null:
                        - flag <server.match_player[<context.args.first>]> mute:true duration:<context.args.get[2].as_duration>
                        - narrate "<yaml[UtilizenLang].read[muteadmin].parsed.parse_color>"
                        - narrate "<yaml[UtilizenLang].read[mutewasmuted].parsed.parse_color>"
                    - else:
                        - narrate "<yaml[UtilizenLang].read[muteinvalidduration].parsed.parse_color>"
                - else:
                    - narrate "<yaml[UtilizenLang].read[mutenoduration].parsed.parse_color>"
            - else:
                - narrate "<yaml[UtilizenLang].read[mutealreadymute].parsed.parse_color>"
        - else:
            - narrate "<yaml[UtilizenLang].read[muteplnotexist].parsed.parse_color>"
    - else:
        - narrate "<yaml[UtilizenLang].read[mutesyntax].parsed.parse_color>"
UtilizenUnmuteCommand:
    type: command
    debug: false
    name: unmute
    description: unmute a player
    usage: /unmute [Player]
    permission: utilizen.unmute
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <server.list_online_players.parse[name]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.first>]]>
    script:
    - if <context.args.size> >= 1:
        - if <server.player_is_valid[<context.args.first>]>:
            - if <server.match_player[<context.args.first>].has_flag[mute]>:
                - flag <server.match_player[<context.args.first>]> mute:!
            - else:
                - narrate "<&3>[Unmute] Dieser Player ist nicht gemuted"
        - else:
            - narrate "<&3>[Unmute] Dieser Player existiert nicht"
    - else:
        - narrate "<&3>[Unmute] Die Syntax lautet <&b>/unmute [Player]"
UtilizenBanCommand:
    type: command
    debug: false
    name: ban
    description: Bans a player
    usage: /ban [Player] (Grund) (Duration)
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
                    - ban add <server.match_player[<context.args.first>]> "reason:<yaml[UtilizenLang].read[banstandard]>"
                - case 2:
                    - ban add <server.match_player[<context.args.first>]> "reason:<context.args.get[2]>"
                - case 3:
                    - if <duration[<context.args.get[3]>]||null> != null:
                        - ban add <server.match_player[<context.args.first>]> "reason:<context.args.get[2]>" duration:<context.args.get[3].as_duration>
                    - else:
                        - narrate "<yaml[UtilizenLang].read[bantimeinvalid].parsed.parse_color>"
        - else:
            - narrate "<yaml[UtilizenLang].read[plnotexist].parsed.parse_color>"
    - else:
        - narrate "<yaml[UtilizenLang].read[bansyntax].parsed.parse_color>"
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
                - narrate "<yaml[UtilizenLang].read[unbaned].parsed.parse_color>" targets:<server.list_online_players.filter[has_permission[Utilizen.ban]]>
            - else:
                - narrate "<yaml[UtilizenLang].read[unbannotbanned].parsed.parse_color>"
        - else:
            - narrate "<yaml[UtilizenLang].read[unbanplnotexist].parsed.parse_color>t"
    - else:
        - narrate "<yaml[UtilizenLang].read[unbansyntax].parsed.parse_color>"
UtilizenKickCommand:
    type: command
    debug: false
    name: kick
    description: kick a player
    usage: /kick [Player] (Grund)
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
                    - kick <server.match_player[<context.args.first>]> "reason:<yaml[UtilizenLang].read[kickedstandard]>"
                - case 2:
                    - kick <server.match_player[<context.args.first>]> "reason:<context.args.get[2]>"
            - default:
                - narrate "<yaml[UtilizenLang].read[kickwrongsyntax].parsed.parse_color>"
        - else:
            - narrate "<yaml[UtilizenLang].read[kickplnotexist].parsed.parse_color>"
    - else:
        - narrate "<yaml[UtilizenLang].read[kicksyntax].parsed.parse_color>"
UtilizenKickallCommand:
    type: command
    debug: false
    name: kickall
    description: kick everyone
    usage: /kickall
    permission: utilizen.kickall
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
        - if !<context.server>:
            - stop
    script:
    - kick <server.list_online_players> "reason:<yaml[UtilizenLang].read[kickedstandard]>"
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
                    - narrate "<yaml[UtilizenLang].read[gamemodechanged].parsed.parse_color>"
                - else:
                    - narrate "<yaml[UtilizenLang].read[gamemodeneedpermsurvival].parsed.parse_color>"
            - case "0":
                - if <player.has_permission[utilizen.gamemode.survival]>:
                    - adjust <player> gamemode:survival
                    - narrate "<yaml[UtilizenLang].read[gamemodechanged].parsed.parse_color>"
                - else:
                    - narrate "<yaml[UtilizenLang].read[gamemodeneedpermsurvival].parsed.parse_color>"
            - case "creative":
                - if <player.has_permission[utilizen.gamemode.creative]>:
                    - adjust <player> gamemode:creative
                    - narrate "<yaml[UtilizenLang].read[gamemodechanged].parsed.parse_color>"
                - else:
                    - narrate "<yaml[UtilizenLang].read[gamemodeneedpermcreative].parsed.parse_color>"
            - case "1":
                - if <player.has_permission[utilizen.gamemode.creative]>:
                    - adjust <player> gamemode:creative
                    - narrate "<yaml[UtilizenLang].read[gamemodechanged].parsed.parse_color>"
                - else:
                    - narrate "<yaml[UtilizenLang].read[gamemodeneedpermcreative].parsed.parse_color>"
            - case "adventure":
                - if <player.has_permission[utilizen.gamemode.adventure]>:
                    - adjust <player> gamemode:adventure
                    - narrate "<yaml[UtilizenLang].read[gamemodechanged].parsed.parse_color>"
                - else:
                    - narrate "<yaml[UtilizenLang].read[gamemodeneedpermadventure].parsed.parse_color>"
            - case "2":
                - if <player.has_permission[utilizen.gamemode.adventure]>:
                    - adjust <player> gamemode:adventure
                    - narrate "<yaml[UtilizenLang].read[gamemodechanged].parsed.parse_color>"
                - else:
                    - narrate "<yaml[UtilizenLang].read[gamemodeneedpermadventure].parsed.parse_color>"
            - case "spectator":
                - if <player.has_permission[utilizen.gamemode.spectator]>:
                    - adjust <player> gamemode:spectator
                    - narrate "<yaml[UtilizenLang].read[gamemodechanged].parsed.parse_color>"
                - else:
                    - narrate "<yaml[UtilizenLang].read[gamemodeneedpermspectator].parsed.parse_color>"
            - case "3":
                - if <player.has_permission[utilizen.gamemode.spectator]>:
                    - adjust <player> gamemode:spectator
                    - narrate "<yaml[UtilizenLang].read[gamemodechanged].parsed.parse_color>"
                - else:
                    - narrate "<yaml[UtilizenLang].read[gamemodeneedpermspectator].parsed.parse_color>"
        - stop
    - if <context.args.size> > 1:
        - if <server.player_is_valid[<context.args.get[2]>]>:
            - if <player.has_permission[utilizen.gamemode.others]>:
                - choose <context.args.first>:
                    - case "0":
                        - adjust <server.match_player[<context.args.get[2]>]> gamemode:survival
                        - narrate "<yaml[UtilizenLang].read[gamemodechangedother].parsed.parse_color>"
                        - narrate "<yaml[UtilizenLang].read[gamemodechanged].parsed.parse_color>" targets:<server.match_player[<context.args.get[2]>]>
                    - case "1":
                        - adjust <server.match_player[<context.args.get[2]>]> gamemode:creative
                        - narrate "<yaml[UtilizenLang].read[gamemodechangedother].parsed.parse_color>"
                        - narrate "<yaml[UtilizenLang].read[gamemodechanged].parsed.parse_color>" targets:<server.match_player[<context.args.get[2]>]>
                    - case "2":
                        - adjust <server.match_player[<context.args.get[2]>]> gamemode:adventure
                        - narrate "<yaml[UtilizenLang].read[gamemodechangedother].parsed.parse_color>"
                        - narrate "<yaml[UtilizenLang].read[gamemodechanged].parsed.parse_color>" targets:<server.match_player[<context.args.get[2]>]>
                    - case "3":
                        - adjust <server.match_player[<context.args.get[2]>]> gamemode:spectator
                        - narrate "<yaml[UtilizenLang].read[gamemodechangedother].parsed.parse_color>"
                        - narrate "<yaml[UtilizenLang].read[gamemodechanged].parsed.parse_color>" targets:<server.match_player[<context.args.get[2]>]>
                    - default:
                        - narrate "<yaml[UtilizenLang].read[gamemodenotexist].parsed.parse_color>"
                - stop
            - else:
                - narrate "<yaml[UtilizenLang].read[gamemodeneedpermother].parsed.parse_color>"
        - else:
            - narrate "<yaml[UtilizenLang].read[gamemodeplnotexist].parsed.parse_color>"
            - stop
    - if <context.args.size> != 1 || <context.args.size> != 2:
        - narrate "<yaml[UtilizenLang].read[gamemodesyntax].parsed.parse_color>"
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
                - narrate "<yaml[UtilizenLang].read[weathernotexist].parsed.parse_color>"
    - else:
        - narrate "<yaml[UtilizenLang].read[weathertypes].parsed.parse_color>"
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
                - narrate "<yaml[UtilizenLang].read[timeday].parsed.parse_color>"
            - case night:
                - time 13000t
                - narrate "<yaml[UtilizenLang].read[timenight].parsed.parse_color>"
            - case set:
                - if <context.args.get[2].is_integer> && <context.args.get[2]> < 24000:
                    - time <duration[<context.args.get[2]>].in_ticks>
                    - narrate "<yaml[UtilizenLang].read[timevariable].parsed.parse_color>"
                - else:
                    - narrate "<yaml[UtilizenLang].read[timetohigh].parsed.parse_color>"
            - default:
                - narrate "<yaml[UtilizenLang].read[timeargnotexist].parsed.parse_color>"
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
                - narrate "<yaml[UtilizenLang].read[teleporttoplayer].parsed.parse_color>"
            - else:
                - narrate "<yaml[UtilizenLang].read[teleportwrongsyntax1].parsed.parse_color>"
        - case 2:
            - if <server.player_is_valid[<context.args.first>]> && <server.player_is_valid[<context.args.get[2]>]>:
                - teleport <server.match_player[<context.args.first>]> <server.match_player[<context.args.get[2]>].location>
                - narrate "<yaml[UtilizenLang].read[teleportpltopl].parsed.parse_color>"
            - else:
                - narrate "<yaml[UtilizenLang].read[teleportwrongsyntax2].parsed.parse_color>"
        - case 3:
            - if <context.args.first.is_integer> && <context.args.get[2].is_integer> && <context.args.get[3].is_integer>:
                - teleport <player> <location[<context.args.first>,<context.args.get[2]>,<context.args.get[3]>,<player.location.world.name>]>
                - narrate "<yaml[UtilizenLang].read[teleporttopos].parsed.parse_color>"
            - else:
                - narrate "<yaml[UtilizenLang].read[teleportwrongsyntax3].parsed.parse_color>"
        - case 4:
            - if <context.args.first.is_integer> && <context.args.get[2].is_integer> && <context.args.get[3].is_integer> && <list[<server.list_worlds>].contains_text[<context.args.get[4]>]>:
                - teleport <player> <location[<context.args.first>,<context.args.get[2]>,<context.args.get[3]>,<context.args.get[4]>]>
                - narrate "<yaml[UtilizenLang].read[teleporttoworld].parsed.parse_color>"
            - else:
                - narrate "<yaml[UtilizenLang].read[teleportwrongsyntax4].parsed.parse_color>"
        - default:
            - narrate "<yaml[UtilizenLang].read[teleportsyntax].parsed.parse_color>"
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
            - narrate "<yaml[UtilizenLang].read[tphereadmin].parsed.parse_color>" targets:<server.match_player[<context.args.first>]>
        - else:
            - narrate "<yaml[UtilizenLang].read[tphereplnotexist].parsed.parse_color>"
    - else:
        - narrate "<yaml[UtilizenLang].read[tpheresyntax].parsed.parse_color>"
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
        - narrate "<yaml[UtilizenLang].read[godactivated].parsed.parse_color>"
    - else:
        - flag <player> god:!
        - narrate "<yaml[UtilizenLang].read[goddeactivated].parsed.parse_color>"
UtilizenMOTD:
    type: world
    debug: false
    events:
        on player joins:
        - foreach <yaml[UtilizenConfig].read[motd]>:
            - narrate <[value].parsed.parse_color>
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
            - narrate "<yaml[UtilizenLang].read[invseeplnotexist].parsed.parse_color>"
    - else:
        - narrate "<yaml[UtilizenLang].read[invseesyntax].parsed.parse_color>"
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
            - narrate "<yaml[UtilizenLang].read[clearinventoryadmin].parsed.parse_color>"
            - narrate "<yaml[UtilizenLang].read[clearinventoryadmincleared].parsed.parse_color>" targets:<server.match_player[<context.args.first>]>
        - else:
            - narrate "<yaml[UtilizenLang].read[clearinventoryplnotexist].parsed.parse_color>"
    - else:
        - inventory clear d:player[holder=<player>]
        - narrate "<yaml[UtilizenLang].read[clearinventorycleared].parsed.parse_color>"
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