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

var mint_busy: bool = false
var mint_movement_queue: Array[Mint] = []
var mint_tween_duration: float = .3
var mint_arc_height: Vector3 = Vector3(0,5,0)

@export var mint_positions: Array[Vector3] = []

func _ready() -> void:
	Signalbus.calculate_coin_spacing.connect(calculate_coin_spacing)
	RecursiveEffect.table_handler_node = self
	Inventory.purse_inv = purse_inv
	Inventory.purse_discard = purse_discard
	spawn_coins()

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
	
	Inventory.coin_positions = positions

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

func spawn_coins():
	calculate_mint_spacing()
	for i in range(Inventory.mints.size()):
		SceneManager.current_scene.add_child.call_deferred(Inventory.mints[i])
	reset_mint_positions()
	
	await get_tree().create_timer(1).timeout 

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
	var center_arc_position = home_position.lerp(current_coin_marker.position, 0.5) + mint_arc_height
	# Send to target
	current_mint.tween_me(current_coin_marker.position, mint_tween_duration, center_arc_position)

	get_tree().create_timer(mint_tween_duration).timeout.connect(func():
		Signalbus.coin_stamped.emit()
		# Start return
		current_mint.tween_me(home_position, mint_tween_duration, center_arc_position)
		# Next object departs immediately as this one begins returning
		move_next_mint()
	)
