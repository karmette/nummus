extends Node

var mints: Array[Object] = []

func run_mint_effects():
	print(get_stack())
	for mint in mints:
		if mint != null:
			mint.run_effect()

func _ready():
	mints.resize(Globals.max_mint_size)
	print(Constants.MINTS["heads"] )
	add_mint(Constants.MINTS["heads"])

func add_mint(uid: String):
	for i in range(mints.size()):
		if mints[i] == null:
			var script = load(uid)
			var mint = script.new()
			mints[i] = mint
			return
