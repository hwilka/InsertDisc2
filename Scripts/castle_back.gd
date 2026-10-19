extends Node2D

signal request_disc_change(disc, abort_position)
signal request_adventure_scene_change(scene_id, pos)

var initialized = false
var mode = 0
func _process(delta: float) -> void:
	if not initialized:
		initialized = true
		$Hero.set_right()
		$Hero.on_game_paused()
		$MessageBox.show_message_unlimited('Oh mighty hero, thank you for saving me.')
		mode = 1

	if Input.is_action_just_pressed("Accept"):
		if mode == 1:
			$MessageBox.show_message_unlimited("Let's leave this place and meet my father, the king!")
			mode = 2
		elif mode == 2:
			$MessageBox.show_message_unlimited("He will surely reward you well!")
			mode = 3
		elif mode == 3:
			$MessageBox.hide_message()
			mode = 4
			
			var tween = get_tree().create_tween()
			tween.tween_property($Princess, "position", $Princess.position +Vector2(0, -70.0), 1.0)
			tween.tween_interval(0.5)
			tween.tween_callback(unlock_hero)
			
func unlock_hero():
	$Princess.visible = false
	$Hero.on_game_continued()
	

func on_game_paused():
	$Hero.on_game_paused()
	
func on_game_continued():
	$Hero.on_game_continued()

func set_inventory(inventory):
	$AdventureUI.set_inventory(inventory)
	$Hero.has_sword = false
	
func get_inventory():
	return $AdventureUI.get_inventory()

func set_hero(_pos):
	pass

func _on_exit_body_entered(body: Node2D) -> void:
	request_disc_change.emit(5,"")
