extends Node2D

const CAM_Y_MAX = 300.0
const CAM_Y_MIN = 100.0

signal request_disc_change(disc, abort_position)
signal request_adventure_scene_change(scene_id, pos)

func on_game_paused():
	$Hero.on_game_paused()
	
func on_game_continued():
	$Hero.on_game_continued()

func set_inventory(inventory):
	$Camera2D/AdventureUI.set_inventory(inventory)
	$Hero.has_sword = inventory.sword
	if inventory.skeleton_hit:
		remove_child($Skeleton)
	else:
		$Skeleton/AnimatedSprite2D.play()
	
func get_inventory():
	return $Camera2D/AdventureUI.get_inventory()

func set_hero(pos):
	if pos == 'bottom':
		$Hero.position = $EntryBottom.position
	elif pos == 'top':
		$Hero.position = $EntryTop.position
		
func _process(_delta):
	$Camera2D.position.y = clamp($Hero.position.y, CAM_Y_MIN, CAM_Y_MAX)


func _on_exit_bottom_body_entered(body):
	request_disc_change.emit(1, 'bottom')


func _on_exit_top_body_entered(body):
	request_adventure_scene_change.emit('castle_end', '')


func show_hit_message():
	$Camera2D/DarkScreen/Label.visible = true
	
func reset_scene():
	request_adventure_scene_change.emit('castle', "bottom")

func _on_skeleton_body_entered(body):
	$Hero.on_game_paused()
	$Camera2D/DarkScreen.visible = true
	
	var tween = get_tree().create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(show_hit_message)
	tween.tween_interval(3.0)
	tween.tween_callback(reset_scene)



func _on_area_2d_area_entered(area):
	remove_child($Skeleton)
	$Camera2D/AdventureUI.skeleton_hit = true
	$Camera2D/AdventureUI.update_screen()
