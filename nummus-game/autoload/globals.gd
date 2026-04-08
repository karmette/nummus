extends Node

#Player Stats
var money: int = 0
var health: int = 20
var max_health: int = 20
var shield: int = 0

var in_favor: bool = false # winning the skill check apparently
var flipping: bool = false
var chosen_state: int 

# fortune
var fortune_channeled = false

var max_fortune: int = 20
var fortune: int = 0
var fortune_gain: int = 5

var max_misfortune: int = 50
var misfortune: int = 0
var misfortune_gain: int = 5

# signals that interact with GlobalUI
signal update_ui
var enemy_visuals_finished = false;
var input_locked = false

# luck
var head_weight: float = 0.5
var tail_weight: float = 0.5
var affect_player_success: bool = false
var success_weight: float = 0

# hand size
var max_coin_inventory_size:int = 15
var max_hand:int = 5


var max_mint_size:int = 5

#actions
var queued_actions: Array[Callable] = []
var is_busy: bool 

func queue_action(function: Callable):
	queued_actions.append(function)
	try_run_next()

func try_run_next():
	if is_busy:
		return

	if queued_actions.is_empty():
		GuiManager.toggle_coin_flip_ui.emit(true)
		input_locked = false
		Signalbus.actions_finished.emit()
		return

	is_busy = true
	var next_action: Callable = queued_actions.front()
	next_action.call()

func action_finished():
	is_busy = false
	queued_actions.pop_front()
	await get_tree().create_timer(0.1).timeout
	try_run_next()
		

func change_money(add: bool, amount: int):
	if add:
		money += amount
	else:
		money = amount
	GuiManager.update_money_text.emit()

func change_player_health(add: bool, amount:int):
	if add:
		if amount < 0: #if dealing damage
			if shield + amount >= 0: #if shield blacks the damage
				change_shield(true, amount)
			else:
				if health + (shield + amount) < 0:
					health = 0
				else:
					health += (shield + amount)
				change_shield(false, 0)
				Signalbus.trigger_camera_shake.emit(1, 10)
		else:
			if health + amount > max_health:
				health = max_health
			else:
				health += amount
	else:
		if amount < 0:
			health = 0
		elif amount > max_health:
			health = max_health
		else:
			health = amount
	GuiManager.update_health_ui.emit()
	
	if health < (.2 * max_health):
		GuiManager.toggle_low_health_ui.emit(true)
	else:
		GuiManager.toggle_low_health_ui.emit(false)
	
func reset_weights():
	head_weight = 0.5
	tail_weight = 0.5
	
	#Signalbus.update_side_percent_ui.emit(head_weight, tail_weight)

func use_fortune():
	if fortune >= 20:
		fortune -= 20
		CommonEffects.WeightModifier.set_favor(1,0)
	elif fortune >= 12:
		fortune -= 12
		CommonEffects.WeightModifier.favor_success(.2)
	elif fortune >= 8:
		fortune -= 8
		CommonEffects.WeightModifier.favor_success(.15)
	elif fortune >= 4:
		fortune -= 4
		CommonEffects.WeightModifier.favor_success(.1)
	
	GuiManager.update_fortune_bar_ui.emit()
	GuiManager.update_chance_wheel.emit(Globals.head_weight, Globals.tail_weight)
	await get_tree().create_timer(0.5).timeout
	
	fortune_channeled = false
	

func reset_misfortune():
	change_misfortune(false, 0)

func reset_success_weight():
	affect_player_success = false
	success_weight = 0

func can_afford(price:int):
	return price <= money

func change_fortune(add: bool, amount: int):
	if fortune + amount > max_fortune or amount > max_fortune:
		fortune = max_fortune
	elif fortune + amount < 0:
		fortune = 0
	elif add:
		fortune += amount
	else:
		fortune = amount
	GuiManager.update_fortune_bar_ui.emit()

func change_misfortune(add: bool, amount: int):
	if misfortune + amount > max_misfortune or misfortune + amount < 0 or amount > max_misfortune:
		misfortune = max_misfortune
	elif add:
		misfortune += amount
		if amount > 0:
			MisfortuneHandler.check_for_event()
	else:
		misfortune = amount
	GuiManager.update_misfortune_bar_ui.emit()

func change_shield(add: bool, amount: int):
	if add:
		if shield + amount < 0:
			shield = 0
		else:
			shield += amount
	else:
		if amount < 0:
			shield = 0
		else:
			shield = amount
		
	GuiManager.update_shield_ui.emit()
