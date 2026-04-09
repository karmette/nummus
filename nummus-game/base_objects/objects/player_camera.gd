extends Camera3D

@export var max_shake: float = .25
@export var shake_fade: float = 10

@onready var animation_player: AnimationPlayer = $AnimationPlayer


var _shake_strength: float = 0

func _ready():
	Signalbus.trigger_camera_shake.connect(trigger_shake)
	Signalbus.trigger_camera_coin_follow.connect(follow_flip)

func trigger_shake(max: float, fade: float) -> void:
	max_shake = max
	shake_fade = fade
	_shake_strength = max_shake

func _process(delta: float):
	if _shake_strength > 0:
		_shake_strength = lerp(_shake_strength, 0.0, shake_fade * delta)
		h_offset = randf_range(-_shake_strength , _shake_strength)
		v_offset = randf_range(-_shake_strength , _shake_strength)

func follow_flip():
	animation_player.play("flip_follow")
