# weight_modifier.gd
class_name WeightModifier
extends RefCounted
# by being its own script we can check what type of effect an effect is
# we can check that favor_heads is a WeightModifier

func favor_heads(val: float):
	inc_favor(val, -val)
func favor_tails(val: float):
	inc_favor(-val, val)
static func inc_favor(head: float = 0, tail: float = 0):
	Globals.head_weight += head
	Globals.tail_weight += tail
static func set_favor(head: float = 0.5, tail: float = 0.5):
	Globals.head_weight = head
	Globals.tail_weight = tail
static func mult_favor(head: float = 1, tail: float = 1):
	Globals.head_weight *= head
	Globals.tail_weight *= tail
func favor_success(val: float):
	if Globals.chosen_state == Sides.HEADS:
		favor_heads(val)
	elif Globals.chosen_state == Sides.TAILS:
		favor_tails(val)
		