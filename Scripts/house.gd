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
	
func get_inventory():
	return $AdventureUI.get_inventory()

func set_hero(_pos):
	$Hero.position = $EntryDoor.position


func _on_exit_door_body_entered(body):
	request_adventure_scene_change.emit('house_front', 'house')

func startup():
	mode = 2
	$MessageBox.show_message_unlimited("Oh no, you just received a message!")
	$Hero.on_game_paused()

var mode = -1
func _process(delta):
	if mode == -1:
		return
		
	if Input.is_action_just_pressed("Accept"):
		if mode == 2:
			$MessageBox.show_message_unlimited("The evil skeleton has kidnapped the princess!")
			mode = 3
		elif mode == 3:
			$MessageBox.show_message_unlimited("She is in the castle in the north east!")
			mode = 4
		elif mode == 4:
			$MessageBox.show_message_unlimited("You must rescue her!")
			mode = 5
		elif mode == 5:
			$MessageBox.hide_message()
			$Hero.on_game_continued()
			mode = -1
		
