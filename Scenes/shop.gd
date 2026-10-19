extends Node2D

signal request_disc_change(disc, abort_position)
signal request_adventure_scene_change(scene_id, pos)

var is_paused = false

var curent_arrow_pos = 0

func on_game_paused():
	is_paused = true
	
func on_game_continued():
	is_paused = false

func set_inventory(inventory):
	$AdventureUI.set_inventory(inventory)
	
	update_shop()
	
func update_shop():
	if $AdventureUI.key_bought:
		$item_key.texture = preload("res://img/sold.png")
		$item_key/Label.visible = false
		
	if $AdventureUI.sword:
		$item_sword.texture = preload("res://img/sold.png")
		$item_sword/Label.visible = false
		
	if $AdventureUI.oil or $AdventureUI.lantern:
		$item_oil.texture = preload("res://img/sold.png")
		$item_oil/Label.visible = false
	
	
func get_inventory():
	return $AdventureUI.get_inventory()

func set_hero(pos):
	if pos == 'right':
		$Hero.position = $EntryRight.position
	elif pos == 'cave':
		$Hero.position = $EntryCave.position

func message_to_player(msg):
	$ColorRect/Label.text = msg

func _process(_delta):
	if is_paused:
		return
		
	var old_arrow_pos = curent_arrow_pos
	if Input.is_action_just_pressed("Left"):
		curent_arrow_pos -= 1
	if Input.is_action_just_pressed("Right"):
		curent_arrow_pos += 1
	curent_arrow_pos = clamp(curent_arrow_pos, 0, 2)
	
	if curent_arrow_pos != old_arrow_pos:
		if curent_arrow_pos == 0:
			$arrow.position.x = $item_key.position.x
		elif curent_arrow_pos == 1:
			$arrow.position.x = $item_sword.position.x
		elif curent_arrow_pos == 2:
			$arrow.position.x = $item_oil.position.x
			
	if Input.is_action_just_pressed("Abort"):
		request_adventure_scene_change.emit("forest", "shop")
		return
	
	if Input.is_action_just_pressed("Accept"):
		if curent_arrow_pos == 0:
			if $AdventureUI.key_bought:
				message_to_player("You already bought this item")
			elif $AdventureUI.coins < 10:
				message_to_player("You don't have enough money")
			else:
				var inv = $AdventureUI.get_inventory()
				inv.keys += 1
				inv.key_bought = true
				inv.coins -= 10
				$AdventureUI.set_inventory(inv)
				update_shop()
				message_to_player("A key is always useful")
		elif curent_arrow_pos == 1:
			if $AdventureUI.sword:
				message_to_player("You already bought this item")
			elif $AdventureUI.coins < 100:
				message_to_player("You don't have enough money")
			else:
				var inv = $AdventureUI.get_inventory()
				inv.sword = true
				inv.coins -= 100
				$AdventureUI.set_inventory(inv)
				update_shop()
				message_to_player("Have fun with the sword")
		elif curent_arrow_pos == 2:
			if $AdventureUI.oil or $AdventureUI.lantern:
				message_to_player("You already bought this item")
			elif $AdventureUI.coins < 10:
				message_to_player("You don't have enough money")
			else:
				var inv = $AdventureUI.get_inventory()
				inv.oil = true
				inv.coins -= 10
				$AdventureUI.set_inventory(inv)
				update_shop()
				message_to_player("What do you do with the oil?")
	
