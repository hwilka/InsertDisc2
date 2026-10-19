extends Node2D

const CAM_Y_MAX = 500.0
const CAM_Y_MIN = 100.0

signal request_disc_change(disc, abort_position)
signal request_adventure_scene_change(scene_id, pos)

var current_bush = null

func on_game_paused():
	$Hero.on_game_paused()
	
func on_game_continued():
	$Hero.on_game_continued()

func set_inventory(inventory):
	$Camera2D/AdventureUI.set_inventory(inventory)
	$Hero.has_sword = inventory.sword
	
func get_inventory():
	return $Camera2D/AdventureUI.get_inventory()


func set_hero(pos):
	if pos == 'left':
		$Hero.position = $EntryLeft.position
	elif pos == 'shop':
		$Hero.position = $EntryShop.position
	elif pos == 'top':
		$Hero.position = $EntryTop.position
	elif pos == 'mid':
		$Hero.position = $EntryMid.position
		
func _process(_delta):
	$Camera2D.position.y = clamp($Hero.position.y, CAM_Y_MIN, CAM_Y_MAX)
	
	if $Hero.is_paused:
		return
	
	if Input.is_action_just_pressed("Accept"):
		var callback = $Hero.get_interaction_callback()
		if not callback == null:
			callback.call()


func _on_exit_left_body_entered(body):
	request_adventure_scene_change.emit("house_front", "right")


func _on_exit_shop_body_entered(body):
	request_adventure_scene_change.emit("shop", "")


func _on_exit_mid_body_entered(body):
	request_disc_change.emit(2, "mid")


func _on_exit_top_body_entered(body):
	request_adventure_scene_change.emit("castle_front", "bottom")

func on_leave_bush(bush):
	$Hero.disable_interact()
	
func show_bush_message():
	$Camera2D/MessageBox.show_message("The bush is blocking the way.\nI need to remove it.")

func interact_with_bush():
	if current_bush == null:
		return
	if $Camera2D/AdventureUI.sword:
		$Hero.disable_interact()
		$Hero.do_attack()
		current_bush.cut_down()
		current_bush = null
	elif $Camera2D/AdventureUI.lantern:
		current_bush.burn_down()
		$Hero.disable_interact()
		current_bush = null
	else:
		show_bush_message()
		
func on_entered_bush(bush):
	current_bush = bush
	$Hero.enable_interact(Callable(self, "interact_with_bush"))
	
	
func on_sign_enter(sign, message):
	$Hero.enable_interact(Callable($Camera2D/MessageBox, "show_message").bind(message))
	
func on_sign_leave():
	$Hero.disable_interact()
