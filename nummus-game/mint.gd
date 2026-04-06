@abstract
class_name Mint extends Node3D

var period_length: int = -1
var value

func _init(given_value, given_period_length: int = -1):
	value = given_value
	period_length = given_period_length

@abstract func run_effect()

func condition_met() -> bool: # coins without a condition will always run
	return true

func try_run():
	if condition_met():
		run_effect()

func force_run():
	run_effect()

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
