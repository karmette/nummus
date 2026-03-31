class_name MintHeads extends Mint

func _init():
	super(.1)

func run_effect():
	CommonEffects.WeightModifier.favor_heads(value)
