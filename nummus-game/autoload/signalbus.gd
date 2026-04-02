extends Node
@warning_ignore("unused_signal")
signal coin_flipped(state: String)
# @warning_ignore("unused_signal")
# signal skill_check_begin(time: float)
# signal skill_check_finish(success: bool)

### Scenes
@warning_ignore("unused_signal")
signal scene_changed()
@warning_ignore("unused_signal")
signal current_enemy_defeated()
@warning_ignore("unused_signal")
signal level_loaded

######## Change Values ########
@warning_ignore("unused_signal")
signal change_enemy_health(add: bool, amount: int)

######## UI ########
@warning_ignore("unused_signal")
signal add_achievement(achievement: String, reward: int)

## dialog lol ##
@warning_ignore("unused_signal")
signal shop_dialog(action: String)
@warning_ignore("unused_signal")
signal finished_displaying

######## VFX ########
@warning_ignore("unused_signal")
signal enemy_visuals()
@warning_ignore("unused_signal")
signal trigger_camera_shake(max: float, fade: float)
@warning_ignore("unused_signal")
signal trigger_camera_coin_follow()

# gameplay loop
@warning_ignore("unused_signal")
signal increase_period(inc: int)
@warning_ignore("unused_signal")
signal decrease_period(amount: int)
@warning_ignore("unused_signal")
signal calculate_coin_spacing(hand: int, is_new_hand: bool)
@warning_ignore("unused_signal")

signal actions_finished
# signal fly_out
# signal flew_out

# func _ready():
	# skill_check_finish.connect(_on_skill_check)
	# current_enemy_defeated.connect(on_current_enemy_defeated)
	
# func _on_skill_check(success: bool):
# 	if success:
# 		Globals.in_favor = true
# 	else: 
# 		Globals.in_favor = false
