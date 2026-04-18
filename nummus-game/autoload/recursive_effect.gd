extends Node

var effects: Dictionary[Callable, int]
var weight_effects: Array[Object] = []
var mint_weight_effects: Array[Object] = []
var weight_modifiers: Array[Object] = []

func add_recurring_effect(function: Callable, period_length: int):
	if function.get_object() == WeightModifier:
		weight_effects.append(RecursiveEffectObject.new(function, period_length))
	else:
		effects[function] = period_length
	print("The number of times I will recur is: " + str(period_length))

func run_weight_effects():
	for effect in weight_effects:
		if effect.period_length == 0:
			weight_effects.erase(effect)
			continue
			
		effect.period_length -= 1
		effect.run()
		GuiManager.update_chance_wheel.emit(Globals.head_weight, Globals.tail_weight)
		await get_tree().create_timer(0.5).timeout
		
	for i in range(Inventory.active_mints.size()):
		var current_mint = Inventory.active_mints[i]
		if current_mint.get_effect_type() == "WeightModifier":
			Signalbus.queue_mint_movement.emit(current_mint)
			await Signalbus.coin_stamped
			current_mint.run_effect()
			GuiManager.update_chance_wheel.emit(Globals.head_weight, Globals.tail_weight)
		
	if Globals.fortune_channeled:
		Globals.use_fortune()
		GuiManager.update_chance_wheel.emit(Globals.head_weight, Globals.tail_weight)
		await get_tree().create_timer(0.5).timeout

	await get_tree().create_timer(0.5).timeout

# func run_recurring_effect(stats: Dictionary, state: int):
# 	for effect in weight_effects:
# 		if effect.period_length == 0:
# 			weight_effects.erase(effect)
# 			continue
			
# 		effect.period_length -= 1
# 		effect.run()
	

class RecursiveEffectObject:
	var effect: Callable
	var period_length: int
	var hasConditional: bool = false
	
	func _init(given_effect: Callable, given_period_length: int):
		effect = given_effect
		period_length = given_period_length
		
	func run():
		effect.call()
