extends Node3D
class_name Table

@onready var markers: Node3D = $Markers
@onready var coin_endpoint_l: Marker3D = $Markers/EndpointL
@onready var coin_endpoint_r: Marker3D = $Markers/EndpointR
@onready var mint_endpoint_l: Marker3D = $MintMarkers/EndpointL
@onready var mint_endpoint_r: Marker3D = $MintMarkers/EndpointR
@onready var purse_inv: Node3D = $PurseInv
@onready var purse_discard: Node3D = $PurseDiscard
@onready var current_coin_marker: Marker3D = $CurrentCoinMarker

var increment: float
var coin_spawnpoint: Vector3

#mint movement data
var mint_busy: bool = false
var mint_movement_queue: Array[Mint] = []
var mint_tween_duration: float = .2
var mint_hover_height: Vector3 = Vector3(0,3,0)
var mint_curve_back_height: Vector3 = Vector3(0,2,0)

#coin movement data
var coin_arc_height: Vector3 = Vector3(0,7,0)
var coin_arc_tween_duration: float = 0.4 #time for coins drawn/ discarded
var coin_tween_duration: float = 0.2 #time for coins selected/ other stuff yknow
var flip_count: int = 2

#position data
var mint_positions: Array[Vector3] = []
var coin_hand_positions: Array[Vector3] = []

func _ready() -> void:
	Signalbus.calculate_coin_spacing.connect(calculate_coin_spacing)
	Signalbus.move_drawn_coin.connect(move_drawn_coin)
	Signalbus.move_coins_in_hand.connect(move_coins_in_hand)
	Signalbus.move_discarded_coin.connect(move_discarded_coin)

	Signalbus.queue_mint_movement.connect(queue_mint_movement)

	Signalbus.fire_game.connect(spawn_mints)

### COINS ###
func calculate_coin_spacing(hand_size: int, is_new_hand: bool = true):
	#calculates coin positions and gives them back to inventory
	if hand_size == 0:
		print("No coins to place!")
		return

	var positions: Array[Vector3] = []
	
	if is_new_hand: #equally spaces coins according to max hand size
		increment = (abs(coin_endpoint_l.position.z) + abs(coin_endpoint_r.position.z))/(Globals.max_hand - 1)
		for i in range(Globals.max_hand):
			positions.append(coin_endpoint_l.global_position - Vector3(0,0,increment*i))
	else:  #equally spaces coins according to current hand size
		if hand_size == 1:
			positions.append(Vector3(coin_endpoint_r.position.x, coin_endpoint_r.position.y, 0)) #center of coin row
			return
			
		increment = (abs(coin_endpoint_l.position.z) + abs(coin_endpoint_r.position.z))/(hand_size-1)
		for i in range(hand_size):
			positions.append(coin_endpoint_l.global_position - Vector3(0,0,increment*i))
	
	coin_hand_positions = positions


func spawn_coin(coin: Coin):
	coin.position = purse_inv.position
	SceneManager.current_scene.add_child.call_deferred(coin)


func move_drawn_coin(coin: Coin):
	spawn_coin(coin)
	var destination: Vector3 = coin_hand_positions[Inventory.current_hand.size() - 1]
	var center_point: Vector3 = coin.position.lerp(destination, 0.5) + coin_arc_height

	coin.tween_me(destination, coin_arc_tween_duration, center_point, flip_count)


func move_discarded_coin(coin: Coin):
	var center_point: Vector3 = coin.position.lerp(purse_discard.position, 0.5) + coin_arc_height
	print("tweening rn")
	coin.tween_me(purse_discard.position, coin_arc_tween_duration, center_point, flip_count)


func move_coins_in_hand():
	for i in range(Inventory.current_hand.size()):
		var coin = Inventory.current_hand[i]
		var destination: Vector3 = coin_hand_positions[i]
		coin.tween_me(destination, coin_tween_duration)



### MINTS ###
func calculate_mint_spacing():
	if Inventory.mints.size() == 0:
		print("No mints to place!")
		return

	var positions: Array[Vector3] = []

	increment = (abs(mint_endpoint_l.position.z) + abs(mint_endpoint_r.position.z))/(Globals.max_hand - 1)
	for i in range(Globals.max_mint_size):
		positions.append(mint_endpoint_l.global_position - Vector3(0,0,increment*i))
	
	mint_positions = positions

func reset_mint_positions():
	for i in range(Inventory.mints.size()):
		if Inventory.mints[i] != null:
			Inventory.mints[i].position = mint_positions[i]

func spawn_mints():
	calculate_mint_spacing()
	for i in range(Inventory.mints.size()):
		var new_mint: Mint = Inventory.mints[i].duplicate()
		Inventory.active_mints.append(new_mint)
		new_mint.position = mint_positions[i]
		SceneManager.current_scene.add_child.call_deferred(new_mint)

func queue_mint_movement(mint: Mint):
	mint_movement_queue.append(mint)
	if not mint_busy:
		move_next_mint()

func move_next_mint():
	if mint_movement_queue.is_empty():
		mint_busy = false
		return

	mint_busy = true
	var current_mint: Mint = mint_movement_queue.pop_front()
	var home_position: Vector3 = current_mint.position
	var center_position = home_position.lerp(current_coin_marker.position, 0.5)
	# places mint above coin
	current_mint.tween_me(current_coin_marker.position + mint_hover_height, mint_tween_duration, center_position + mint_hover_height*1.25)
	await get_tree().create_timer(mint_tween_duration + 0.05).timeout 

	#stamps down onto coin
	current_mint.tween_me(current_coin_marker.position, 0.05, Vector3.ZERO, false)
	Signalbus.coin_stamped.emit()
	Signalbus.trigger_camera_shake.emit(.1, 10)
	await get_tree().create_timer(.25).timeout
	
	#return to home position
	current_mint.tween_me(home_position, mint_tween_duration, center_position + mint_curve_back_height)
	move_next_mint()
