extends Node

signal gui_spawned
signal update_fortune_bar_ui() 
signal update_misfortune_bar_ui()
signal update_health_ui()
@warning_ignore("unused_signal")
signal toggle_game_ui(show: bool)
signal toggle_global_ui(show: bool)
@warning_ignore("unused_signal")
signal toggle_coin_flip_ui(show: bool)
@warning_ignore("unused_signal")
signal toggle_bar_ui(show: bool)
signal toggle_level_completed_ui(show: bool)
signal update_side_percent_ui()
signal update_money_text()
signal update_shield_ui()
signal toggle_shield_ui(show: bool)
signal toggle_low_health_ui(show: bool)
signal show_misfortune_inflicted(effect_string: String)
signal update_inventory_patch(type: String)

#ENEMY GUI
signal update_period_text(amount: int)
signal update_enemy_health_text(amount: int, max_health: int)
signal update_action_text(text: String)
signal toggle_enemy_ui(show: bool)

#GAME GUI
signal run_chance_wheel()
signal toggle_chance_wheel(show: bool)
signal update_chance_wheel(heads: String, tails: String)

#INVENTORY GUI
signal update_inventory_icons()

var all_ui_path: Dictionary[String, String] = {
	"global_ui_path":"res://gui/global_ui.tscn",
	"game_ui_path":"res://gui/game_ui.tscn",
	"skill_check_path":"res://gui/skill_check.tscn",
	"debug_menu":"res://gui/debug.tscn"
}

var global_ui: Control
var game_ui: Control
var skill_check: Control
var uis: Array[Control] = [global_ui, game_ui, skill_check]

func _ready() -> void:
	spawn_all.call_deferred()

func spawn_all():
	for scene in all_ui_path.values():
		add_scene(scene)
	gui_spawned.emit()

func _deferred_add_scene(path):
	# make sure it frees itself after its done
	var new_scene = ResourceLoader.load(path).instantiate()
	get_tree().root.add_child(new_scene)
	return new_scene

func add_scene(path):
	_deferred_add_scene.call_deferred(path)
	
func refresh_purse_ui():
	update_inventory_patch.emit("Inventory")
	update_inventory_patch.emit("Discard")
