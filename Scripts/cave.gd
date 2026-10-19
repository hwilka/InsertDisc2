extends Node2D

signal request_disc_change(disc, abort_position)
signal request_adventure_scene_change(scene_id, pos)


var hero_fell_off = false
var initialized = false
func _process(_delta):
	if not initialized:
		initialized = true
		$LightMap/LanternShine.visible = $AdventureUI.lantern
		
		if not $AdventureUI.lantern:
			var tween = get_tree().create_tween()
			tween.tween_interval(1.5)
			tween.tween_callback(message_1)
			tween.tween_interval(2.0)
			tween.tween_callback(message_2)
	
	if hero_fell_off:
		return
	
	if Input.is_action_just_pressed("Accept"):
		var callback = $Hero.get_interaction_callback()
		if not callback == null:
			callback.call()
	
	$LightMap/LanternShine.position = $Hero.position

func message_1():
	$LabelDark.text = "It is very dark."
	
func message_2():
	$LabelDark.text += "\nThe cave is dangerous without\na light source."

func on_game_paused():
	$Hero.on_game_paused()
	
func on_game_continued():
	$Hero.on_game_continued()

func set_inventory(inventory):
	$AdventureUI.set_inventory(inventory)
	$Hero.has_sword = inventory.sword
	if $AdventureUI.gold_key:
		$Chest.make_empty()
		
	
func get_inventory():
	return $AdventureUI.get_inventory()

func set_hero(_pos):
	$Hero.position = $Entry.position


func _on_exit_body_entered(body):
	request_disc_change.emit(1, "")

func fall_1():
	$Dark2.visible = true

func reset_cave():
	request_adventure_scene_change.emit("cave", "entry")

func _on_safe_path_body_exited(body):
	if hero_fell_off:
		return
	hero_fell_off = true
	$Hero.on_game_paused()
	$Hero.set_front()
	$LightMap/LanternShine.visible = false
	print("hero fell")
	var tween = get_tree().create_tween()
	tween.tween_property($Hero, "scale", Vector2(0.2, 0.2), 1.0)
	tween.tween_callback(fall_1)
	tween.tween_interval(2.0)
	tween.tween_callback(reset_cave)
	
	tween = get_tree().create_tween()
	tween.tween_property($Hero, "position", $Hero.position + Vector2(0.0, -16.0), 1.0)
	
	tween = get_tree().create_tween()
	tween.tween_property($Hero, "rotation_degrees", 45, 1.0)
	
func open_chest():
	$MessageBox.show_message("You found a golden key.")
	$AdventureUI.gold_key = true
	$Hero.disable_interact()
	$AdventureUI.update_screen()
	$Chest.make_empty()
	
func on_chest_enter(chest):
	$Hero.enable_interact(Callable(self, "open_chest"))
	
func on_chest_leave():
	$Hero.disable_interact()
	
	
