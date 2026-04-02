extends Node3D

class_name Coin

# children
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var coin_mesh: MeshInstance3D = $CoinMesh
@onready var hoverable: Node3D = $Hoverable
@onready var area: Area3D = $Area3D

# flipping
var sides = [Sides.HEADS, Sides.TAILS]
var weights: Array[float] = [0.5, 0.5]

# coin stats
@export var coin_id: CoinStats
var coin_json_id: String
var coin_stats: Dictionary
var coin_effect: RefCounted
var coin_price: int
var period_increment: int

var position_markers: Dictionary[String, Vector3] # 0 is initial, 1 is floating

# coin state
@export var current_state: Constants.DisplayType
var is_mouse_over: bool = false
@export var current_coin: bool = false

var current_level

func _ready():
	
	# flip signal
	set_weights()

	if current_state == null:
		current_state = Constants.DisplayType.SHOP

	# signals
	Signalbus.coin_flipped.connect(flip)
	Inventory.replace_current_coin.connect(replace_me)
	#Signalbus.fly_out.connect(_fly_out)

	# instance of coin resources
	coin_mesh.material_override = StandardMaterial3D.new()
	coin_mesh.material_override.albedo_texture = coin_id.coin_texture
	coin_mesh.material_override.texture_filter = 0

	# stats and names
	coin_effect = coin_id.effect.new()
	coin_json_id = coin_id.json_id

	# change material
	coin_mesh.material_override.metallic_specular = 0.0

	set_state_transforms()
	parse_json()
	area.show()
	
	current_level = get_parent()


func set_state_transforms() -> void:
	# transform me
	if current_state == Constants.DisplayType.PLAY:
		scale = Vector3(1,1,1) # because shop
		rotation = Vector3(0, 0, 0)
		hoverable.visible = true
		init_anim() # really useless code/function
	elif current_state == Constants.DisplayType.SHOP:
		scale = Vector3(0.3, 0.3, 0.3)
		rotation = Vector3(0, 0, -PI / 2)
		hoverable.visible = true
	elif current_state == Constants.DisplayType.HAND: # unused state
		rotation = Vector3(0, 0, 0)
		hoverable.visible = false


func tween_pos(desired_position: Vector3, is_curved: bool):
	if is_curved:
		var center_point = position.lerp(desired_position, 0.5) + Vector3(0, 5, 0)
		tween_me(self, desired_position, 0.1, center_point)
	else:
		#print("This shouldnt happen")
		tween_me(self, desired_position, 0.1)


func init_anim():
	position_markers["not_floating"] = Vector3(0, 0, 0)
	position_markers["floating"] = Vector3(0, 0.4, 0)
	position_markers["playing"] = Vector3(2.3, 4, 0)


func parse_json() -> void:
	# json parse
	var json_object = ObjectManager.parse_json(Constants.JSON_PATHS.coins)
	for coin in json_object.data:
		if coin == coin_json_id:
			#print("matched " + coin)
			coin_stats = json_object.data.get(coin).get("coin_stats")
			self.name = json_object.data.get(coin).get("name")
			coin_price = json_object.data.get(coin).get("price")
			period_increment = json_object.data.get(coin).get("period")
			hoverable.title.text = json_object.data.get(coin).get("name") + " [color=yellow]$" + str(coin_price) + "[/color]"
			hoverable.description.text = json_object.data.get(coin).get("description") + generate_description(coin_stats)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"flip_heads_success":
			coin_effect.effect(coin_stats, Sides.HEADS)
		"flip_heads_fail": # IDEA: all fails do misfortune
			Globals.change_fortune(true, Globals.fortune_gain)
			Globals.change_misfortune(true, Globals.misfortune_gain)
		"flip_tails_success":
			coin_effect.effect(coin_stats, Sides.TAILS)
		"flip_tails_fail":
			Globals.change_fortune(true, Globals.fortune_gain)
			Globals.change_misfortune(true, Globals.misfortune_gain)
		"discard":
			Globals.flipping = false
			return
		"RESET":
			Globals.queue_action(discard_me)
			return

	Globals.reset_weights()
	
	animation_player.play("RESET")
	Globals.action_finished()


func check_flipped_side(flipped_side: int, state: int):
	#flipped side = index returned by weighted array
	#Signalbus.trigger_camera_coin_follow.emit()
	area.hide()
	if sides[flipped_side] == Sides.HEADS:
		if state == Sides.HEADS:
			animation_player.play("flip_heads_success")
		else:
			animation_player.play("flip_heads_fail")
	else:
		if state == Sides.TAILS:
			animation_player.play("flip_tails_success")
		else:
			animation_player.play("flip_tails_fail")
	


func set_weights():
	weights.set(sides.find(Sides.HEADS), Globals.head_weight)
	weights.set(sides.find(Sides.TAILS), Globals.tail_weight)
	#Signalbus.update_side_percent_ui.emit()


func flip(state: int): # the side you clicked
	if current_coin:
		Globals.chosen_state = state
		Globals.flipping = true
		Globals.input_locked = true
		GuiManager.toggle_coin_flip_ui.emit(false)
		
		if state == Sides.SKIP:
			current_level.amount_skipped += 1
			Globals.queue_action(discard_me)
			return
			
		coin_effect.pre_effect(coin_stats)
		#coin_stats = RecursiveEffect.run_recurring_effect(coin_stats, state)
		
		Globals.queue_action(run_chance_wheel)
		set_weights()
		
		#print(str(Globals.head_weight) + " " + str(Globals.tail_weight))
		var flipped_side = SeedManager.rng.rand_weighted(weights)
		
		Globals.queue_action(check_flipped_side.bind(flipped_side, state))
		
		await Signalbus.actions_finished

func run_chance_wheel():
	GuiManager.toggle_chance_wheel.emit(true)
	GuiManager.run_chance_wheel.emit()

func generate_description(stats: Dictionary) -> String:
	var s: String = "[br]"
	for i in stats:
		# look for on heads
		if i == "on_heads":
			s += "On Heads:[br]"
			for j in stats.get(i):
				for k in stats.get(i).values():
					s += get_stat_line(j, k)
		elif i == "on_tails" and stats.get(i).size() > 0:
			s += "On Tails:[br]"
			for j in stats.get(i):
				for k in stats.get(i).values():
					s += get_stat_line(j, k)
	return s


func get_stat_line(type: String, value: int):
	match type:
		"damage":
			return "[color=red]" + str(value) + " DMG[/color][br]"
		"heal":
			return "[color=green]" + str(value) + " HP[/color][br]"
		"money":
			return "[color=yellow]$" + str(value) + "[/color][br]"
	return "[color=light_blue]" + str(value) + " " + type + "[/color][br]"


func toggle_visible(on: bool):
	if on:
		hoverable.animation.play("fly_out")
	else:
		hoverable.animation.play_backwards("fly_out")


func _on_area_3d_mouse_entered() -> void:
	is_mouse_over = true
	if current_state == Constants.DisplayType.SHOP:
		toggle_visible(true)
	if current_state == Constants.DisplayType.PLAY: # make float
		if Globals.input_locked:
			await Signalbus.actions_finished
			
		if is_mouse_over: #so the coin hovers back up instantly after unlocking input
			tween_me(coin_mesh, position_markers.get("floating"), 0.1)
			toggle_visible(true)
	


func _input(event: InputEvent) -> void:
	if is_mouse_over and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and not Globals.input_locked:
		if current_state == Constants.DisplayType.SHOP:
			buy_me()
		if current_state == Constants.DisplayType.PLAY and Globals.flipping == false:
			if not current_coin:
				current_coin = Inventory.set_current_coin(self)
				if current_coin:
					tween_me(self, position_markers.get("playing"), 0.2)
			elif current_coin:
				#tween_me(self, tween_pos, 0.2)
				current_coin = false
				Inventory.delete_current_coin()


func _on_area_3d_mouse_exited() -> void:
	is_mouse_over = false
	toggle_visible(false)
	if current_state == Constants.DisplayType.PLAY:
		tween_me(coin_mesh, position_markers.get("not_floating"), 0.2)
	


#func tween_me(sprite: Node3D, pos: Vector3, time):
	#var tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	#tween.tween_property(sprite, "position", pos, time)

func tween_me(sprite: Node3D, end: Vector3, time: float = .1, control: Vector3 = Vector3.ZERO, start: Vector3 = Vector3.ZERO):
	if sprite.position.is_equal_approx(end):
		return
	#uses the objects current position by default
	if start == Vector3.ZERO: #uses the objects current position by default
		start = sprite.position
	if control == Vector3.ZERO: #if no centerpoint is given, object travels in a straight line
		control = start.lerp(end, 0.5)
		
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_method(
		func(t: float):
			var a = start.lerp(control, t)
			var b = control.lerp(end, t)
			sprite.position = a.lerp(b, t),
		0.0, 1.0, time
	)

func replace_me():
	if current_coin:
		#tween_me(self, tween_pos, 0.2)
		current_coin = false


func buy_me():
	if Globals.can_afford(coin_price):
		Inventory.add_item(self.duplicate())
		Globals.change_money(true, -coin_price)
		self.queue_free()
	else:
		print("you broke lol")


func discard_me():
	print("Hello, im %s and I just discarded" % self.name)
	if current_coin:
		var enemy_anim = get_parent().get_node("Enemy").get_node("AnimationPlayer")
		if enemy_anim.current_animation.find("idle") == -1:
			await enemy_anim.animation_finished
		current_coin = false;
		animation_player.play("discard")
		await animation_player.animation_finished
		GuiManager.toggle_chance_wheel.emit(false)
		Signalbus.decrease_period.emit(period_increment)
		Inventory.discard_coin()
		Globals.action_finished()
		
		
