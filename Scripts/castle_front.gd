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
	if inventory.removed_lock_gold:
		remove_child($GoldenLock)
	
func get_inventory():
	return $AdventureUI.get_inventory()


func set_hero(pos):
	if pos == 'bottom':
		$Hero.position = $EntryBottom.position
	elif pos == 'castle':
		$Hero.position = $EntryCastle.position

func _process(_delta):
	if $Hero.is_paused:
		return
	
	if Input.is_action_just_pressed("Accept"):
		var callback = $Hero.get_interaction_callback()
		if not callback == null:
			callback.call()

func _on_exit_castle_body_entered(body):
	request_disc_change.emit(4, "castle")


func _on_exit_bottom_body_entered(body):
	request_adventure_scene_change.emit("forest", "top")
	
func interact_with_lock():
	if $AdventureUI.gold_key:
		$AdventureUI.gold_key = false
		$AdventureUI.removed_lock_gold = true
		$AdventureUI.update_screen()
		remove_child($GoldenLock)
		$Hero.disable_interact()
	else:
		$MessageBox.show_message("I need a golden key.")
		

func on_lock_entered(lock):
	$Hero.enable_interact(Callable(self, "interact_with_lock"))
	
func on_lock_left():
	$Hero.disable_interact()
