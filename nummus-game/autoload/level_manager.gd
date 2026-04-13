extends Node

signal enter_level
const LEVEL_PROGRESSION: Array[String] = ['limbo', 'lust', 'gluttony', 'greed', 'anger', 'heresy', 'violence', 'fraud', 'treachery']
var current_stage: int # 1 - 3, 3 being the boss
var current_level: String # refers to the level array
var next_stage_scene: String
func _ready() -> void:
	current_stage = 0
	current_level  = LEVEL_PROGRESSION[0]
	# we're just gonna give the player his first coins here okay
	Inventory.add_coin(Constants.COINS.happy)

	for i in range(2):
		Inventory.add_coin(Constants.COINS.base)
	
	for i in range(2):
		Inventory.add_coin(Constants.COINS.guard)
	
func next_stage():
	if SceneManager.current_scene.name == "BaseLevel":
		next_stage_scene = Constants.SCENE_PATHS.shop
	elif SceneManager.current_scene.name == "Shop":
		if current_stage == 3:
			current_stage = 1
			current_level = LEVEL_PROGRESSION[LEVEL_PROGRESSION.find(current_level) + 1]
		elif current_level == LEVEL_PROGRESSION[-1]:
			print("you reached the last level")
		else:
			current_stage += 1
		next_stage_scene = Constants.SCENE_PATHS.base_level
		enter_level.emit()
		# set resource here
	Inventory.reset_inv()
	SceneManager.goto_scene(next_stage_scene)
