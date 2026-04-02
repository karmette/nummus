extends Node3D
class_name Table

@onready var markers: Node3D = $Markers
@onready var endpoint_l: Marker3D = $Markers/EndpointL
@onready var endpoint_r: Marker3D = $Markers/EndpointR
@onready var purse_inv: Node3D = $PurseInv

var increment: float
var coin_spawnpoint: Vector3

func _ready() -> void:
	Signalbus.calculate_coin_spacing.connect(calculate_spacing)

func calculate_spacing(hand_size: int, is_new_hand: bool = true):
	#calculates coin positions and gives them back to inventory
	var positions: Array[Vector3] = []
	if hand_size == 0:
		print("No coins to place!")
		return
	
	if is_new_hand: #equally spaces coins according to max hand size
		increment = (abs(endpoint_l.position.z) + abs(endpoint_r.position.z))/(Globals.max_hand - 1)
		for i in range(Globals.max_hand):
			positions.append(endpoint_l.global_position - Vector3(0,0,increment*i))
	else:  #equally spaces coins according to current hand size
		if hand_size == 1:
			positions.append(Vector3(endpoint_r.position.x, endpoint_r.position.y, 0)) #center of coin row
			return
			
		increment = (abs(endpoint_l.position.z) + abs(endpoint_r.position.z))/(hand_size-1)
		for i in range(hand_size):
			positions.append(endpoint_l.global_position - Vector3(0,0,increment*i))
	
	Inventory.coin_positions = positions
