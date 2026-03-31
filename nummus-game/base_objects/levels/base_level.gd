extends Node3D

var flipping_history: PackedInt32Array = []

var amount_skipped: int = 0

func _ready() -> void:
	Inventory.fire_game()
	#Inventory.spawn_hand()
	ObjectManager.spawn_base_enemy()
	Signalbus.current_enemy_defeated.connect(_on_current_enemy_defeated)
	GuiManager.toggle_level_completed_ui.emit(false)
	GuiManager.toggle_coin_flip_ui.emit(false)
	GuiManager.toggle_chance_wheel.emit(false)

func _on_current_enemy_defeated():
	GuiManager.toggle_level_completed_ui.emit(true)
	Signalbus.add_achievement.emit("Enemy defeated", 3)
	Globals.change_shield(false, 0)
