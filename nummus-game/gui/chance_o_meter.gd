extends TextureProgressBar

@onready var heads_percent: Label = $HeadsPercent
@onready var tails_percent: Label = $TailsPercent
@onready var chance_o_meter: TextureProgressBar = $"."
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var bar_tween: Tween

func _ready():
	GuiManager.run_chance_wheel.connect(on_wheel_ran)
	GuiManager.update_chance_wheel.connect(update_wheel)
	GuiManager.toggle_chance_wheel.connect(_on_chance_wheel_toggled)

func _on_chance_wheel_toggled(show: bool):
	if show:
		self.visible = show 
		animation_player.play("appear")
	else:
		animation_player.play_backwards("appear")
		await animation_player.animation_finished
		self.visible = show
		chance_o_meter.value = 0

func update_percentage(heads: int, tails: int):
	heads_percent.text = str(heads) + "%"
	tails_percent.text = str(tails) + "%"

func update_wheel(heads: float, tails: float):
	var int_heads = int(round(heads * 100))
	var tail_heads = int(round(tails * 100))
	
	update_percentage(int_heads, tail_heads)
	set_bar_value_smooth(int_heads)
	
func set_bar_value_smooth(new_value: float):
	if bar_tween:
		bar_tween.kill()

	bar_tween = get_tree().create_tween()
	bar_tween.tween_property(chance_o_meter, "value", new_value, 0.5)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)

func on_wheel_ran():
	update_wheel(Globals.head_weight, Globals.tail_weight)
	await get_tree().create_timer(0.5).timeout
	
	await RecursiveEffect.run_weight_effects()
	
	Globals.action_finished()
