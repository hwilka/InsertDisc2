extends Node2D

signal request_disc_change(disc, abort_position)

func on_game_paused():
	paused = true
	
func on_game_continued():
	paused = false
	
	
func set_inventory(_inventory):
	inventory = _inventory
	
func get_inventory():
	return inventory

var current_options = []
var option_pos = 0
var inventory
var paused = false
var initialized = false


func setup_options(list):
	current_options = list
	current_options.append(["inventory", show_inventory])
	current_options.append(["quit", quit_game])
	option_pos = 0
	update_options()

func update_options():
	var p0 = option_pos - 1
	if p0 >= 0:
		$Label0.text = current_options[p0][0]
	else:
		$Label0.text = ""
		
	$Label1.text = current_options[option_pos][0]
	
	var p1 = option_pos + 1
	if p1 <= len(current_options)-1:
		$Label2.text = current_options[p1][0]
	else:
		$Label2.text = ""
		
	
func spawn_text(text):
	$Log.text = $Log.text + "\n" + text
	
func clear_text():
	$Log.text = ""
	
func _process(_delta):
	if paused:
		return
	
	if not initialized:
		initialized = true
		scene_start()
	
	var old_pos = option_pos
	if Input.is_action_just_pressed("Up"):
		option_pos -= 1
	if Input.is_action_just_pressed("Down"):
		option_pos += 1
	
	option_pos = clamp(option_pos, 0, len(current_options)-1)
	if old_pos != option_pos:
		update_options()
		
	if Input.is_action_just_pressed("Accept"):
		current_options[option_pos][1].call()
	
	
func show_inventory():
	spawn_text("Coins: " + str(inventory.coins))
	if inventory.keys == 1:
		spawn_text("A key")
	elif inventory.keys > 1:
		spawn_text(str(inventory.keys) + " keys")
	if inventory.trophy:
		spawn_text("A golden trophy")
	if inventory.oil:
		spawn_text("Some lamp oil")
	if inventory.sword:
		spawn_text("A mighty sword")
	if inventory.lantern:
		spawn_text("A lantern")
	if inventory.gold_key:
		spawn_text("A golden key")
	spawn_text("")
	
	
func scene_start():
	clear_text()
	spawn_text("MYSTERY LAB 2\n")
	garden()

func garden():
	spawn_text("You are in the parc in front of a big mansion.")
	spawn_text("")
	setup_options([["Look around", garden], ["Go to door",  go_to_door]])
	


var door_is_cloded = true
func open_door():
	if door_is_cloded:
		spawn_text("You opened the door. Luckily it was not locked.")
		door_is_cloded = false
	else:
		spawn_text("The door is already open.")
	spawn_text("")
			
func go_inside():
	if door_is_cloded:
		spawn_text("The door is closed.")
		spawn_text("")
	else:
		is_inside()
		
		
func is_inside():
	spawn_text("You are inside a laboratory. In the center of the room is an old man.")
	spawn_text('"Greetings"')
	spawn_text('"I am looking for chemical elements. Especially metals and flamable substances would be of interest."')
	spawn_text("")
	lab_options()
		
func lab_options():
	var ops = [["Look around", is_inside], ['Go outside', go_to_door]]
	if inventory.trophy:
		ops.push_back(["Give golden trophy", give_trophy])
	if inventory.oil:
		ops.push_back(["Give oil", give_oil])
	if inventory.gold_key:
		ops.push_back(["Give golden key", give_golden_key])
	setup_options(ops)
	
		
func give_trophy():
	inventory.trophy = false
	inventory.keys += 1
	
	spawn_text('"That is exactly what I need."')
	spawn_text('"Here, take this"')
	spawn_text('You exchanged the golden trophy for a key')
	spawn_text("")
	
	lab_options()
	
func give_oil():
	inventory.oil = false
	inventory.lantern = true
	
	spawn_text('"That is exactly what I need."')
	spawn_text('"Here, take this"')
	spawn_text('You exchanged the oil for a lantern')
	spawn_text("")
	
	lab_options()
	
func give_golden_key():
	spawn_text('"I think that is not actually gold. I can not use it."')
	spawn_text("")


func quit_game():
	request_disc_change.emit(1, "")
	
func go_to_door():
	spawn_text("You are in front of the door to the mansion.")
	spawn_text("")
	setup_options([["Look around", go_to_door], ["Open door",  open_door], ["Go inside", go_inside], ["Go into the garden", garden]])
	pass
