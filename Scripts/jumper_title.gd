extends Node2D


signal request_disc_change(disc, abort_position)
signal request_jumper_scene_change(scene_id, pos)

var inventory

var initialized = false
func _process(_delta):
	if not initialized:
		initialized = true
		$Hero.only_lr = true
		$Hero.can_jump = true

		
func on_game_paused():
	$Hero.on_game_paused()
	
func on_game_continued():
	$Hero.on_game_continued()

func set_inventory(_inventory):
	inventory = _inventory
	
func get_inventory():
	return inventory

func set_hero(pos):
	if pos == 'left':
		$Hero.position = $EntryLeft.position
	elif pos == 'right':
		$Hero.position = $EntryRight.position


func _on_exit_left_body_entered(body):
	request_disc_change.emit(1, "left")


func _on_exit_right_body_entered(body):
	request_jumper_scene_change.emit("level", "left")
