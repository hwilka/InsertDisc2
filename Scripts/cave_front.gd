extends Node2D

signal request_disc_change(disc, abort_position)
signal request_adventure_scene_change(scene_id, pos)

func on_game_paused():
	$Hero.on_game_paused()
	
func on_game_continued():
	$Hero.on_game_continued()

func set_inventory(inventory):
	$AdventureUI.set_inventory(inventory)
	$Hero.has_sword = inventory.sword
	if inventory.removed_lock_cave:
		remove_child($CaveLock)
	
func get_inventory():
	return $AdventureUI.get_inventory()

func set_hero(pos):
	if pos == 'right':
		$Hero.position = $EntryRight.position
	elif pos == 'cave':
		$Hero.position = $EntryCave.position

func _process(_delta):
	if $Hero.is_paused:
		return
	
	if Input.is_action_just_pressed("Accept"):
		var callback = $Hero.get_interaction_callback()
		if not callback == null:
			callback.call()

func _on_exit_cave_body_entered(body):
	request_disc_change.emit(3, "cave")


func _on_exit_right_body_entered(body):
	request_adventure_scene_change.emit("house_front", "left")

func interact_with_lock():
	if $AdventureUI.keys > 0:
		$AdventureUI.keys -= 1
		$AdventureUI.removed_lock_cave = true
		$AdventureUI.update_screen()
		remove_child($CaveLock)
		$Hero.disable_interact()
	else:
		$MessageBox.show_message("I need a key to access the cave.")
		

func on_lock_entered(lock):
	$Hero.enable_interact(Callable(self, "interact_with_lock"))
	
func on_lock_left():
	$Hero.disable_interact()
