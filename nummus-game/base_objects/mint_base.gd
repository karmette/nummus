extends Node3D

class_name Mint 

# children
@onready var mint_mesh: MeshInstance3D = $MintMesh

var period_length: int = -1
var value

@export var mint_id: MintStats
@onready var mint_effect: RefCounted
	
func _ready():
	#initialize texture
	mint_mesh.material_override = StandardMaterial3D.new()
	mint_mesh.material_override.albedo_texture = mint_id.mint_texture
	mint_mesh.material_override.texture_filter = 0

	#initialize effect
	mint_effect = mint_id.effect.new()

func run_effect():
	mint_effect.try_run_effect()

func get_effect_type(): #returns effect class as a string
	return mint_effect.effect.get_object().get_script().get_global_name()

func tween_me(end: Vector3, time: float = .1, control: Vector3 = Vector3.ZERO, start: Vector3 = Vector3.ZERO, object: Mint = self):
	if object.position.is_equal_approx(end):
		return
	#uses the objects current position by default
	if start == Vector3.ZERO: #uses the objects current position by default
		start = object.position
	if control == Vector3.ZERO: #if no centerpoint is given, object travels in a straight line
		control = start.lerp(end, 0.5)
		
	var tween = object.create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	tween.tween_method(
		func(t: float):
			var a = start.lerp(control, t)
			var b = control.lerp(end, t)
			object.position = a.lerp(b, t),
		0.0, 1.0, time
	)
