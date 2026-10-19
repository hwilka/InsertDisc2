extends Node2D

signal request_disc_change(disc, abort_position)
signal request_jumper_scene_change(scene_id, pos)

const CAM_X_MIN = 160.0
const CAM_X_MAX = 1740.0

var initialized = false
var player_died = false
func _process(_delta):
	if not initialized:
		initialized = true
		$Hero.only_lr = true
		$Hero.can_jump = true
		
	var cam_pos_x = clamp($Hero.position.x, CAM_X_MIN, CAM_X_MAX)
	$Camera2D.position.x = cam_pos_x
		
	if $Hero.position.y > 280:
		if not player_died:
			player_died = true
			$Hero.on_game_paused()
			
			var tween = get_tree().create_tween()
			tween.tween_callback(screen_black)
			tween.tween_interval(1.0)
			tween.tween_callback(back_to_title)
		


func update_ui():
	if inventory.coins > 99:
		$Camera2D/CoinUI/Label.text = "##"
	else:
		$Camera2D/CoinUI/Label.text = str(inventory.coins)
		
func on_game_paused():
	$Hero.on_game_paused()
	
func on_game_continued():
	$Hero.on_game_continued()


var inventory = null
func set_inventory(_inventory):
	inventory = _inventory
	update_ui()
	
func get_inventory():
	return inventory

func set_hero(pos):
	if pos == 'left':
		$Hero.position = $EntryLeft.position

func show_one_up():
	pass

func _on_hero_hero_coin_collected(sender):
	if inventory.coins < 99:
		inventory.coins += 1
		if inventory.coins == 100:
			inventory.coins = 0
			show_one_up()
	update_ui()
	sender.get_parent().remove_child(sender)
	sender.queue_free()

func screen_black():
	$Camera2D/BlackScreen.visible = true

func back_to_title():
	request_jumper_scene_change.emit('title', "right")


func _on_win_area_body_entered(body):
	# TODO: Better
	back_to_title()
