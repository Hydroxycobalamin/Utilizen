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
UtilizenYamlLoad:
    type: world
    debug: false
    events:
        on server start:
        - if !<server.has_file[../Utilizen/data/serverdata.yml]>:
            - yaml create id:UtilizenServerdata
            - ~yaml savefile:../Utilizen/data/serverdata.yml id:UtilizenServerdata
        - ~yaml load:../Utilizen/data/serverdata.yml id:UtilizenServerdata
        - ~yaml load:../Utilizen/config.yml id:UtilizenConfig
        - ~yaml load:../Utilizen/lang/<yaml[UtilizenConfig].read[lang]>.yml id:UtilizenLang
        on reload scripts:
        - announce to_console "[Utilizen] Reloading.."
        - ~yaml load:../Utilizen/config.yml id:UtilizenConfig
        - ~yaml load:../Utilizen/lang/<yaml[UtilizenConfig].read[lang]>.yml id:UtilizenLang
        - ~yaml savefile:../Utilizen/data/serverdata.yml id:UtilizenServerdata
        - ~yaml load:../Utilizen/data/serverdata.yml id:UtilizenServerdata
        - announce to_console "[Utilizen] Reload complete!"
        on player joins priority:-1:
        - if !<server.has_file[../Utilizen/data/players/<player.uuid>.yml]>:
            - yaml create id:Utilizen_<player.uuid>
            - ~yaml savefile:../Utilizen/data/players/<player.uuid>.yml id:Utilizen_<player.uuid>
        - else:
            - ~yaml load:../Utilizen/data/players/<player.uuid>.yml id:Utilizen_<player.uuid>
        on player quits priority:1:
        - ~yaml savefile:../Utilizen/data/players/<player.uuid>.yml id:Utilizen_<player.uuid>
        - yaml unload id:Utilizen_<player.uuid>
UtilizenPlayerTask:
    type: task
    debug: false
    definitions: uuid|key|value
    script:
    - if !<server.has_file[../Utilizen/data/players/<[uuid]>.yml]>:
        - announce to_console "[Utilizen-WARN] UUID <[uuid]> does not have a database yet, creating one.."
        - yaml create id:Utilizen_<[uuid]>
        - ~yaml savefile:../Utilizen/data/players/<[uuid]>.yml id:Utilizen_<[uuid]>
    - if <player[<[uuid]>].is_online>:
        - yaml id:Utilizen_<[uuid]> set <[key]>:<[value].unescaped>
        - ~yaml savefile:../Utilizen/data/players/<[uuid]>.yml id:Utilizen_<[uuid]>
    - else:
        - ~yaml load:../Utilizen/data/players/<[uuid]>.yml id:Utilizen_<[uuid]>
        - yaml id:Utilizen_<[uuid]> set <[key]>:<[value].unescaped>
        - ~yaml savefile:../Utilizen/data/players/<[uuid]>.yml id:Utilizen_<[uuid]>
        - yaml unload id:Utilizen_<[uuid]>
UtilizenSaveServerTask:
    type: task
    debug: false
    script:
    - ~yaml savefile:../Utilizen/data/serverdata.yml id:UtilizenServerdata
Utilizen:
    type: command
    debug: false
    name: utilizen
    description: main command
    usage: utilizen
    permission: utilizen.help
    permission message: <&3>[Permission] You need the permission <&b><permission>
    tab complete:
    - if <context.args.size> < 1:
        - determine <list[version]>
    - if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
        - determine <list[version].filter[starts_with[<context.args.first>]]>
    script:
    - choose <context.args.first||version>:
        - case version:
            - narrate "Author: <script[UtilizenYamlData].yaml_key[author]>"
            - narrate "Version: <script[UtilizenYamlData].yaml_key[version]>"
#Don't touch the lines below!
UtilizenYamlData:
    type: yaml data
    version: DEV-5
    author: Icecapade