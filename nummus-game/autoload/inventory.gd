extends Node

@export var inventory: Array[Coin]
# In game
var discard: Array[Coin]
var current_inv: Array[Coin] = []
var current_hand: Array[Coin] = []
var mints: Array[Object] = []

signal inventory_changed()
signal replace_current_coin()

var current_coin: Coin

func _ready() -> void:
	add_mint(Constants.MINTS.dizzy)
	add_mint(Constants.MINTS.waggy)
	add_mint(Constants.MINTS.dizzy)
	add_mint(Constants.MINTS.waggy)
	add_mint(Constants.MINTS.dizzy)
	

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
	current_inv.remove_at(current_inv.find(new_coin))
	current_hand.append(new_coin)
	
	Signalbus.calculate_coin_spacing.emit(current_hand.size(), true)
	Signalbus.move_coins_in_hand.emit()
	Signalbus.move_drawn_coin.emit(new_coin)
	GuiManager.refresh_purse_ui()

	Globals.action_finished()
	
	

func refill_current_inv_from_discard():
	for i in range(Inventory.discard.size()):
		current_inv.append(discard[0].duplicate())
		discard.remove_at(0)
		
		await get_tree().create_timer(0.1).timeout
		
		GuiManager.refresh_purse_ui()
	await get_tree().create_timer(0.5).timeout


func new_hand():
	for i in range(Globals.max_hand): # Ideally, remove from inventory into hand!
		draw_coin()
		await get_tree().create_timer(.15).timeout #interval between coins drawn
	Globals.action_finished()
	#Signalbus.fly_out.emit()
	

func fire_game():
	reset_inv()
	for coin in inventory:
		current_inv.append(coin.duplicate())
	GuiManager.refresh_purse_ui()
	await get_tree().create_timer(0.5).timeout #stylistic choice ong
	Globals.queue_action(new_hand)


func add_item(item: Coin) -> bool:
	inventory.append(item)
	inventory_changed.emit()
	return true


func discard_coin():
	GuiManager.toggle_chance_wheel.emit(false)
	Globals.flipping = false
	current_coin.current_coin = false
	
	#await current_coin.tween_pos(purse_discard.position, true)
	Signalbus.move_discarded_coin.emit(current_coin)
	await get_tree().create_timer(0.5).timeout
	discard.append(current_coin.duplicate()) # needs to be visibly removed!
	current_coin.queue_free()
	Globals.action_finished()
	
	Globals.queue_action(draw_coin)
	GuiManager.refresh_purse_ui()
	

func set_current_coin(coin: Coin) -> bool: #sets what coin is in play
	if current_coin == null:
		current_coin = coin
		current_hand.remove_at(current_hand.find(current_coin))
		
		Signalbus.calculate_coin_spacing.emit(current_hand.size(), false)
		Signalbus.move_coins_in_hand.emit()
		
		return true
	else:
		current_hand.append(current_coin) # adds the current coin back into hand
		current_coin = coin # sets new current coin
		current_hand.remove_at(current_hand.find(current_coin))
		
		Signalbus.calculate_coin_spacing.emit(current_hand.size(), false)
		Signalbus.move_coins_in_hand.emit()

		replace_current_coin.emit()
		return true


func delete_current_coin():
	current_hand.append(current_coin)
	current_coin = null

	Signalbus.calculate_coin_spacing.emit(current_hand.size(), false)
	Signalbus.move_coins_in_hand.emit()
			
	

func add_coin(coin_path: String) -> void:
	var new_coin = ObjectManager.create_coin(coin_path, Constants.DisplayType.PLAY)
	add_item(new_coin) #adds to coin inventory

	current_inv.append(inventory[-1].duplicate()) #adds to purse
	
	GuiManager.update_inventory_icons.emit()
	GuiManager.update_inventory_patch.emit("Inventory")


func add_mint(mint_path: String) -> void:
	var new_mint = ObjectManager.create_mint(mint_path, Constants.DisplayType.PLAY)
	mints.append(new_mint)


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
		

#func remove_item(item: Coin) -> bool:
	#if inventory.find(item) != -1:
		#inventory.remove_at(inventory.find(item))
		#inventory_changed.emit()
		#return true
	#else:
		#return false