extends Node

var mints: Array[Object] = []

func run_mint_effects():
	print(get_stack())
	for mint in mints:
		if mint != null:
			mint.run_effect()

func _ready():
	mints.resize(Globals.max_mint_size)
	add_mint(CommonEffects.WeightModifier.favor_heads.bind(.1), 1)

func add_mint(effect:Callable, value = 1, period_length:int = -1, isConditional:bool = false):
	for i in range(mints.size()):
		if mints[i] == null:
			mints[i] = MintObject.new(effect, value, period_length, isConditional)
			return

class MintObject:
	var effect: Callable
	var period_length: int # a negative period means it has infinite duration
	var hasConditional: bool 
	var value # allows multiplicative effects to exist lol
	
	func _init(given_effect:Callable, given_value, given_period_length:int, isConditional:bool):
		effect = given_effect
		value = given_value
		period_length = given_period_length
		hasConditional = isConditional
		
	func run_effect():
		effect.call()
