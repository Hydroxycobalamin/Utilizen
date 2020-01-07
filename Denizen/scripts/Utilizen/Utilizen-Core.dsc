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
        - if !<server.has_file[../Utilizen/serverdata.yml]>:
            - yaml create id:UtilizenServerdata
            - ~yaml savefile:../Utilizen/serverdata.yml id:UtilizenServerdata
        - ~yaml load:../Utilizen/config.yml id:UtilizenConfig
        - ~yaml load:../Utilizen/lang/<yaml[UtilizenConfig].read[lang]>.yml id:UtilizenLang
        - ~yaml load:../Utilizen/serverdata.yml id:UtilizenServerdata
        on reload scripts:
        - ~yaml load:../Utilizen/config.yml id:UtilizenConfig
        - ~yaml load:../Utilizen/lang/<yaml[UtilizenConfig].read[lang]>.yml id:UtilizenLang
        - ~yaml savefile:../Utilizen/serverdata.yml id:UtilizenServerdata
        - ~yaml load:../Utilizen/serverdata.yml id:UtilizenServerdata
        on player joins:
        - if !<server.has_file[../Utilizen/data/<player.uuid>.yml]>:
            - yaml create id:Utilizen_<player.uuid>
            - ~yaml savefile:../Utilizen/data/players/<player.uuid>.yml id:Utilizen_<player.uuid>
        - else:
            - ~yaml load:../Utilizen/data/players/<player.uuid>.yml id:Utilizen_<player.uuid>
        on player quits:
        - ~yaml savefile:../Utilizen/data/players/<player.uuid>.yml id:Utilizen_<player.uuid>
        - yaml unload id:Utilizen_<player.uuid>
UtilizenSavePlayerTask:
    type: task
    definitions: uuid
    script:
    - ~yaml savefile:../Utilizen/data/players/<[uuid]>.yml id:Utilizen_<[uuid]>
UtilizenSaveServerTask:
    type: task
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
    version: DEV-3
    author: Icecapade