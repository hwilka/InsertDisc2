extends Node2D

signal request_disc_change(disc, abort_position)
signal request_adventure_scene_change(scene_id, pos)

func _process(_delta):
	if $Hero.is_paused:
		return
	
	if Input.is_action_just_pressed("Accept"):
		var callback = $Hero.get_interaction_callback()
		if not callback == null:
			callback.call()

func on_game_paused():
	$Hero.on_game_paused()
	
func on_game_continued():
	$Hero.on_game_continued()

func set_inventory(inventory):
	$AdventureUI.set_inventory(inventory)
	$Hero.has_sword = inventory.sword
	
func get_inventory():
	return $AdventureUI.get_inventory()

func _on_exit_right_body_entered(body):
	request_adventure_scene_change.emit("forest", "left")


func _on_exit_left_body_entered(body):
	request_adventure_scene_change.emit("cave_front", "right")


func _on_house_entry_body_entered(body):
	request_adventure_scene_change.emit("house", "entry")

func set_hero(pos):
	if pos == 'left':
		$Hero.position = $EntryLeft.position
	elif pos == 'house':
		$Hero.position = $EntryHouse.position
	elif pos == 'right':
		$Hero.position = $EntryRight.position

func on_sign_enter(sign, message):
	$Hero.enable_interact(Callable($MessageBox, "show_message").bind(message))
	
func on_sign_leave():
	$Hero.disable_interact()
