extends Node2D

signal request_disc_change(disc, abort_position)

var paused = false
func on_game_paused():
	$Hero.on_game_paused()
	paused = true
	
func on_game_continued():
	$Hero.on_game_continued()
	paused = false


var inventory
func set_inventory(_inventory):
	inventory = _inventory
	
func get_inventory():
	return inventory
	
var initialized = false
func _process(_delta):
	if not initialized:
		initialized = true
		$Hero.only_lr = true
		
		var assistant_final_pos = $Assistant.position
		$Assistant.position.x += 200.0
		
		var tween = get_tree().create_tween()
		tween.tween_interval(1.0)
		tween.tween_property($Assistant, "position", assistant_final_pos, 1.0)
		
	if paused:
		return
		
	if Input.is_action_just_pressed("Accept"):
		if $Hero.can_interact and ($Hero.interaction_callback != null):
			$Hero.interaction_callback.call()
		


func set_hero(pos):
	$Hero.position = $EntryLeft.position

func _on_exit_left_body_entered(body):
	request_disc_change.emit(1, "")


func _on_area_2d_body_entered(body):
	$Hero.enable_interact(Callable(self,"interact"))

func _on_area_2d_body_exited(body):
	$Hero.disable_interact()
	
	
	

var current_dialog_pos = 0
func next_dialog():
	if inventory.stats_increased:
		if current_dialog_pos == 0:
			$SpreadsheetBubble.visible = true
			$Label.visible = true
			$Label.text = "We already improved your data!\n\n<OK>"
		elif current_dialog_pos == 6:
			$Label.text = "Now your data is perfect!\n\n<OK>"
	else:
		if current_dialog_pos == 0:
			$SpreadsheetBubble.visible = true
			$Label.visible = true
			$Label.text = "Hi, I am Cutty, you office assistant\n\n<OK>"
			current_dialog_pos+=1
		elif current_dialog_pos == 1:
			$Label.text = "I see a lot of data...\n\n<OK>"
			current_dialog_pos+=1
		elif current_dialog_pos == 2:
			$Label.text = "I can help improve it, ok?\n\n<OK>"
			current_dialog_pos+=1
		elif current_dialog_pos == 3:
			$Label.text = "So, lets increase your budget...?\n\n<OK>"
			current_dialog_pos+=1
		elif current_dialog_pos == 4:
			$Label.text = "Higher Strength, larger numbers, ...\n\n<OK>"
			current_dialog_pos+=1
		elif current_dialog_pos == 5:
			$Label.text = "And... finished. Now your data is improved!\n\n<OK>"
			current_dialog_pos+=1
			
			inventory.stats_increased = true
			inventory.coins = 999999
			inventory.keys = 999
	
func interact():
	next_dialog()
	
	
