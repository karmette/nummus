extends Node

@export var inventory: Array[Coin]
# In game
var discard: Array[Coin]
var current_inv: Array[Coin] = []
var current_hand: Array[Coin] = []
@export var coin_positions: Array[Vector3] = []

signal inventory_changed()
signal replace_current_coin()

var current_coin: Coin

func _ready() -> void:
	pass

func reset_inv():
	current_inv.clear()
	discard.clear()
	current_hand.clear()
	current_coin = null

func draw_coin():
	if current_inv.is_empty():
		await refill_current_inv_from_discard()
	
	var new_coin: Coin = Inventory.current_inv.pick_random()
	new_coin.current_state = Constants.DisplayType.PLAY
	new_coin.position = Vector3(2.044,4.0,-8.368)
	SceneManager.current_scene.add_child.call_deferred(new_coin)
	current_inv.remove_at(current_inv.find(new_coin))
	current_hand.append(new_coin)
	
	Signalbus.calculate_coin_spacing.emit(current_hand.size(), false)
	
	for i in current_hand.size() :
		if i == current_hand.size() - 1:
			current_hand[i].tween_pos(coin_positions[i], true)
		else:
			current_hand[i].tween_pos(coin_positions[i], false)
	
	GuiManager.update_inventory_patch.emit("Inventory")
	GuiManager.update_inventory_patch.emit("Discard")
	Globals.action_finished()
	
	

func refill_current_inv_from_discard():
	for i in range(Inventory.discard.size()):
		current_inv.append(discard[0].duplicate())
		discard.remove_at(0)
		
		await get_tree().create_timer(0.1).timeout
		
		GuiManager.update_inventory_patch.emit("Inventory")
		GuiManager.update_inventory_patch.emit("Discard")
	await get_tree().create_timer(0.5).timeout


func new_hand():
	await get_tree().create_timer(0.5).timeout #stylistic choice ong
	
	
	for i in range(Globals.max_hand): # Ideally, remove from inventory into hand!
		var new_coin: Coin = Inventory.current_inv.pick_random()
		new_coin.current_state = Constants.DisplayType.PLAY
		SceneManager.current_scene.add_child.call_deferred(new_coin)
		new_coin.position = Vector3(2.044,4.0,-8.368)
		current_inv.remove_at(current_inv.find(new_coin))
		current_hand.append(new_coin)
		
		Signalbus.calculate_coin_spacing.emit(current_hand.size(), true)
		
		current_hand[i].tween_pos(coin_positions[i], true)
		
		GuiManager.update_inventory_patch.emit("Inventory")
		GuiManager.update_inventory_patch.emit("Discard")
		await get_tree().create_timer(.1).timeout
	Globals.action_finished()
	#Signalbus.fly_out.emit()
	

func fire_game():
	reset_inv()
	for coin in inventory:
		current_inv.append(coin.duplicate())
	GuiManager.update_inventory_patch.emit("Inventory")
	GuiManager.update_inventory_patch.emit("Discard")
	Globals.queue_action(new_hand)

func add_item(item: Coin) -> bool:
	if inventory.size() <= 15:
		inventory.append(item)
		inventory_changed.emit()

		return true
	else:
		return false

#func set_coin_spacing(positions: Array[Vector3], is_curved: bool):
	## move coins to their requested positions
	## They SHOULD be the same
	#if positions.size() == 0:
		## print("Ran out of coins, attempting to get new hand")
		## new_hand()
		#return
#
	#for i in min(current_hand.size(), positions.size()):
		#current_hand[i].tween_pos = positions[i]
		#current_hand[i].tween_pos(is_curved)
		

func remove_item(item: Coin) -> bool:
	if inventory.find(item) != -1:
		inventory.remove_at(inventory.find(item))
		inventory_changed.emit()
		return true
	else:
		return false

func discard_coin():
	discard.append(current_coin.duplicate()) # needs to be visibly removed!
	current_coin.queue_free()
	Globals.queue_action(draw_coin)
	GuiManager.update_inventory_patch.emit("Inventory")
	GuiManager.update_inventory_patch.emit("Discard")

func set_current_coin(coin: Coin) -> bool: #sets what coin is in play
	if current_coin == null:
		current_coin = coin
		current_hand.remove_at(current_hand.find(current_coin))
		
		Signalbus.calculate_coin_spacing.emit(current_hand.size(), false)
		for i in min(current_hand.size(), coin_positions.size()):
			current_hand[i].tween_pos(coin_positions[i], false)
		
		return true
	else:
		current_hand.append(current_coin) # adds the current coin back into hand
		current_coin = coin # sets new current coin
		current_hand.remove_at(current_hand.find(current_coin))
		
		Signalbus.calculate_coin_spacing.emit(current_hand.size(), false)
		for i in min(current_hand.size(), coin_positions.size()):
			current_hand[i].tween_pos(coin_positions[i], false)

		replace_current_coin.emit()
		return true

func delete_current_coin():
	current_hand.append(current_coin)
	
	Signalbus.calculate_coin_spacing.emit(current_hand.size(), false)
	for i in min(current_hand.size(), coin_positions.size()):
			current_hand[i].tween_pos(coin_positions[i], false)
			
	current_coin = null
