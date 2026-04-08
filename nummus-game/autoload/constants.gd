extends Node

const SCENE_PATHS: Dictionary[String, String] = {
	"base_level":"uid://vwukeorb6yvs",
	"base_coin":"uid://bgrch5de5xhey",
	"base_enemy":"uid://d3tgw7j1mag6w",
	"shop":"uid://smvg3nwqqw6x",
	"speech_bubble": "uid://bov88m8v4wj43",
	"base_mint": "uid://qmwg3w7gj4vw"
}

const UI_PATHS: Dictionary[String, String] = {
	"global_ui_path":"res://gui/global_ui.tscn",
	"game_ui_path":"res://gui/game_ui.tscn",
	"skill_check_path":"res://gui/skill_check.tscn",
	"debug_menu":"res://gui/debug.tscn",
	"main_menu":"uid://bydht7j8q5mvr",
	"achievement_row":"res://gui/achievement_row.tscn",
	"player_damage_text": "res://gui/damage_text.tscn",
	"ID_icon":"res://base_objects/objects/id_icon.tscn"
}

const COINS: Dictionary = {
	"base":"uid://d35ga8hv2jlvh",
	"1787":"uid://bgh5v2n073rl7",
	"old_abe":"uid://dj73eohb1fsui",
	"corrosive":"uid://b0vhhuw5oktg8",
	"guard":"uid://t3858517hbri",
	"happy":"uid://f8tgsgfdhc4c"
	#"lucky":"",
	#"healthy":"",
}

const MINTS: Dictionary = {
	"dizzy": "uid://y5cnfhut51qb",
	"waggy": "uid://ccbgug7ovonvw"
}

const JSON_PATHS: Dictionary = {
	"coins":"res://assets/resource_json/coins.json",
	"dialogue":"res://assets/resource_json/dialogue.json",
	"enemies":"res://assets/resource_json/enemies.json"
}

const ANIM_PATHS: Dictionary = {
	"coin_anim":"uid://cc420o0fj6ssr"
}

enum DisplayType{PLAY, SHOP, HAND}
