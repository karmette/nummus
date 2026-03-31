@abstract
class_name Mint

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
