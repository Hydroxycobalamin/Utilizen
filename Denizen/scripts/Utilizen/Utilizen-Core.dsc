UtilizenYamlLoad:
    type: world
    debug: false
    events:
        on server start:
        - if !<server.has_file[../Utilizen/playerdata.yml]>:
            - yaml create id:UtilizenPlayerdata
            - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
        - if !<server.has_file[../Utilizen/serverdata.yml]>:
            - yaml create id:UtilizenServerdata
            - yaml savefile:../Utilizen/serverdata.yml id:UtilizenServerdata
        - yaml load:../Utilizen/config.yml id:UtilizenConfig
        - yaml load:../Utilizen/playerdata.yml id:UtilizenPlayerdata
        - yaml load:../Utilizen/<yaml[UtilizenConfig].read[lang]>.yml id:UtilizenLang
        - yaml load:../Utilizen/serverdata.yml id:UtilizenServerdata
        on reload scripts:
        - yaml load:../Utilizen/config.yml id:UtilizenConfig
        - yaml load:../Utilizen/<yaml[UtilizenConfig].read[lang]>.yml id:UtilizenLang
        - yaml savefile:../Utilizen/playerdata.yml id:UtilizenPlayerdata
        - yaml load:../Utilizen/playerdata.yml id:UtilizenPlayerdata
        - yaml savefile:../Utilizen/serverdata.yml id:UtilizenServerdata
        - yaml load:../Utilizen/serverdata.yml id:UtilizenServerdata
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
#Don't touch that!
UtilizenYamlData:
    type: yaml data
    version: DEV-1
    author: Icecapade