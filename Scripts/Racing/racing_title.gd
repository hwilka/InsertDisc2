extends Node2D

signal request_disc_change(disc, abort_position)
signal request_race_scene_change(scene_id, pos)

var inventory
var in_start_animation = false

var initialized = false
func _process(delta):
	if not initialized:
		initialized = true
		$Hero.only_lr = true

func update_scene ():
	if inventory.won_race:
		$Car.visible = false
		$Trophy1.visible = false
		$Trophy2.visible = true
	else:
		$Car.visible = true
		$Trophy1.visible = true
		$Trophy2.visible = false
		

func on_game_paused():
	$Hero.on_game_paused()
	
func on_game_continued():
	$Hero.on_game_continued()

func set_inventory(_inventory):
	inventory = _inventory
	update_scene()
	
func get_inventory():
	return inventory

func set_hero(pos):
	if pos == 'left':
		$Hero.position = $EntryLeft.position
	elif pos == 'right':
		$Hero.position = $EntryRace.position


func _on_exit_left_body_entered(body):
	request_disc_change.emit(1, "left")


func _on_exit_race_body_entered(body):
	if (not inventory.won_race) and (not in_start_animation):
		in_start_animation = true
		$Car.frame = 1
		
		$Hero.on_game_paused()
		$Hero.visible = false
		var tween = get_tree().create_tween()
		tween.tween_property($Car, "position", $Car.position + Vector2(140.0, 0.0), 2.0)
		tween.tween_callback(start_race)
		

func start_race():
	request_race_scene_change.emit('race', '')
