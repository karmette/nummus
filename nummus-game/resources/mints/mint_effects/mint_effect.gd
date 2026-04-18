@abstract 
class_name MintEffect

var effect: Callable
var effect_object: RefCounted
var value

func force_run_effect():
	effect.call(value)

func try_run_effect():
	if conditional():
		effect.call(value)

func conditional(): #default condition always returns true
	return true

