extends Node2D

@onready var message_box = $SubViewport/CanvasLayer2/MessageBox
@onready var message_box_title = $SubViewport/CanvasLayer2/MessageBox/Title
@onready var message_box_body = $SubViewport/CanvasLayer2/MessageBox/Body

@onready var floppys = $Floppys
@onready var floppy_discs = $Floppys/Discs
@onready var disc_select = $Floppys/DiscSelect

@onready var camera = $Camera_Coordinates/Camera2D
@onready var cam_pos1 = $Camera_Coordinates/Position1
@onready var cam_pos2 = $Camera_Coordinates/Position2
const CAM_ZOOM_1 = Vector2(1.0, 1.0)
const CAM_ZOOM_2 = Vector2(0.7, 0.7)

@onready var sound_player = $SoundPlayer

var tracks: Array[AudioStream] = [
	preload("res://sounds/music_main.ogg"),
	preload("res://sounds/music_race.ogg"),
	preload("res://sounds/music_jump.ogg"),
]

var inventory := {"coins": 0, "keys": 0, "trophy": false, "sword": false, "oil": false, "lantern": false, "gold_key": false, "key_bought": false, "won_race": false, "stats_increased": false, "removed_lock_cave": false, "removed_lock_gold": false, "skeleton_hit": false}

var is_game_paused: bool = false
var is_messagebox_shown: bool = false

signal game_paused
signal game_continued

const DISCS = ['adv1', 'adv3', 'adv4', 'racer2', 'text2', 'jump3', 'business4']
var loaded_disc = DISCS[0]

var shown_discs: Array = []
var shown_discs_insts: Array = []
var is_selecting_floppy = false
var requested_disc = 0
var disc_abort_pos = ''
var disc_current_pos = 0

var current_game_scene = null
var loaded_game_scene_id = ''

const DISC_SELECTION_ELEV = -20

func _init():
	#call_deferred("setup_screen")
	
	pass

var end_lock = false
var end_timer = 5.0
var initialized = false

func _process(delta):
	if not initialized:
		initialized = true
		setup_screen()
	if end_lock:
		end_timer -= delta
		if end_timer <= 0:
			Manager.end_screen()
			return
			
	if is_selecting_floppy:
		var old_pos = disc_current_pos
		if Input.is_action_just_pressed("Left"):
			disc_current_pos -= 1
		if Input.is_action_just_pressed("Right"):
			disc_current_pos += 1
		disc_current_pos = clamp(disc_current_pos, 0, len(shown_discs)-1)
		if old_pos != disc_current_pos:
			shown_discs_insts[old_pos].position.y = 0
			shown_discs_insts[disc_current_pos].position.y = DISC_SELECTION_ELEV
			disc_select.position = shown_discs_insts[disc_current_pos].position
			disc_select.position = shown_discs_insts[disc_current_pos].position
			
		if Input.is_action_just_pressed("Accept"):
			on_check_disc_load()
		if Input.is_action_just_pressed("Abort"):
			if not end_lock:
				on_back_to_disc()
		
	

func setup_screen():
	on_request_adventure_scene_change('house', 'entry')
	call_deferred("house_startup")
	play_music_adventure()
	
func house_startup():
	current_game_scene.startup()
	
func play_music_adventure():
	$SoundPlayer.stream = tracks[0]
	$SoundPlayer.play()
	
func play_music_race():
	$SoundPlayer.stream = tracks[1]
	$SoundPlayer.play()
	
func play_music_jump():
	$SoundPlayer.stream = tracks[2]
	$SoundPlayer.play()
	
func unload_current_game():
	var vp := $SubViewport/scene
	
	if current_game_scene != null:
		var inv_test = current_game_scene.get_inventory()
		if inv_test != null:
			inventory = inv_test
	
	for c in vp.get_children():
		vp.remove_child(c)
		c.queue_free()
	
	
	

func show_message_box(title: String, body: String):
	message_box.visible = true
	message_box_title.text = title
	message_box_body.text = body
	is_messagebox_shown = true
	
func hide_message_box():
	message_box.visible = false
	is_messagebox_shown = false
	
func pause_game():
	if not is_game_paused:
		is_game_paused = true
		game_paused.emit()
		
func continue_game():
	if is_game_paused:
		is_game_paused = false
		game_continued.emit()

func prepare_discs():
	shown_discs = []
	for d in DISCS:
		if d == loaded_disc:
			continue
		shown_discs.push_back(d)
		
	for f in floppy_discs.get_children():
		floppy_discs.remove_child(f)
		f.queue_free()
		
	var i := 0
	shown_discs_insts = []
	for d in shown_discs:
		var inst = Sprite2D.new()
		if d == 'adv1':
			inst.texture = preload("res://img/floppys/floppy_adventure_1.png")
		elif d == 'adv3':
			inst.texture = preload("res://img/floppys/floppy_adventure_3.png")
		elif d == 'adv4':
			inst.texture = preload("res://img/floppys/floppy_adventure_4.png")
		elif d == 'text2':
			inst.texture = preload("res://img/floppys/floppy_text_2.png")
		elif d == 'racer2':
			inst.texture = preload("res://img/floppys/floppy_racing_2.png")
		elif d == 'jump3':
			inst.texture = preload("res://img/floppys/floppy_jump_3.png")
		elif d == 'business4':
			inst.texture = preload("res://img/floppys/floppy_spreadsheet_4.png")
		
		floppy_discs.add_child(inst)
		shown_discs_insts.push_back(inst)
		
		inst.position.x = 450.0*i
		
		i += 1
		
func zoom_out_to_floppys():
	is_selecting_floppy = true
	prepare_discs()
	disc_current_pos = 0
	shown_discs_insts[disc_current_pos].position.y = DISC_SELECTION_ELEV
	disc_select.position = floppy_discs.get_child(0).position
	var tween = get_tree().create_tween()
	tween.tween_property(camera, "position", cam_pos2.position, 0.4)
	
	tween = get_tree().create_tween()
	tween.tween_property(camera, "zoom", CAM_ZOOM_2, 0.4)
	
	
func zoom_in_to_screen():
	is_selecting_floppy = false
	prepare_discs()
	var tween = get_tree().create_tween()
	tween.tween_property(camera, "position", cam_pos1.position, 0.4)
	
	tween = get_tree().create_tween()
	tween.tween_property(camera, "zoom", CAM_ZOOM_1, 0.4)
	
func on_back_to_disc():
	if loaded_disc == 'adv1' or loaded_disc == 'adv3' or loaded_disc == 'adv4':
		$SoundPlayer.play()
		on_request_adventure_scene_change(loaded_game_scene_id, disc_abort_pos)
	if loaded_disc == 'racer2':
		$SoundPlayer.play()
		load_racing_game('title', 'left')
	if loaded_disc == 'jump3':
		$SoundPlayer.play()
		load_jump_game('title', 'left')
	if loaded_disc == 'business4':
		load_business()
	if loaded_disc == 'text2':
		load_text_game()
	else:
		pass
		
	continue_game()
	hide_message_box()
	zoom_in_to_screen()
	
func on_check_disc_load():
	var to_load = shown_discs[disc_current_pos]
	if requested_disc == 1:
		if to_load == 'adv1':
			if loaded_disc == 'adv3' or loaded_disc == 'jump3':
				play_music_adventure()
				on_request_adventure_scene_change('cave_front', 'cave')
			elif loaded_disc == 'racer2' or loaded_disc == 'text2':
				play_music_adventure()
				on_request_adventure_scene_change('forest', 'mid')
			elif loaded_disc == 'adv4' or loaded_disc == 'business4':
				play_music_adventure()
				on_request_adventure_scene_change('castle_front', 'castle')
		else:
			#TODO wrong sound
			show_messagebox_load_disc(true)
			return
	elif requested_disc == 2:
		if to_load == 'racer2':
			load_racing_game('title', 'left')
			play_music_race()
		elif to_load == 'text2':
			load_text_game()
		else:
			#TODO wrong sound
			show_messagebox_load_disc(true)
			return
	elif requested_disc == 3:
		if to_load == 'adv3':
			on_request_adventure_scene_change('cave', 'entry')
			play_music_adventure()
		elif to_load == 'jump3':
			load_jump_game("title", "left")
			play_music_jump()
		else:
			#TODO wrong sound
			show_messagebox_load_disc(true)
			return
	elif requested_disc == 4:
		if to_load == 'adv4':
			on_request_adventure_scene_change('castle', 'bottom')
			play_music_adventure()
		elif to_load == 'business4':
			load_business()
		else:
			#TODO wrong sound
			show_messagebox_load_disc(true)
			return
	elif requested_disc == 5:
		# TODO: End of game
		pass
	
	loaded_disc = to_load
	
			
			
func show_messagebox_load_disc(warn=false):
	if warn:
		show_message_box("WARNING", "Please insert disc " + str(requested_disc) + "\n\nONLY INSERT DISC " + str(requested_disc))
	else:
		show_message_box("Attention", "Please insert disc " + str(requested_disc))


func init_end():
	requested_disc = 5
	show_messagebox_load_disc()
	zoom_out_to_floppys()
	pause_game()
	end_lock = true
	
	
func on_request_disc_change(disc_num, abort_pos):
	$SoundPlayer.stop()
	if disc_num == 5:
		init_end()
		return
	requested_disc = disc_num
	show_messagebox_load_disc()
	disc_abort_pos = abort_pos
	pause_game()
	zoom_out_to_floppys()
	
func on_request_adventure_scene_change(scene_id, pos):
	unload_current_game()
	hide_message_box()
	
	var loaded_scene = null
	if scene_id == 'house_front':
		loaded_scene = preload("res://Scenes/HouseFront.tscn")
	elif scene_id == 'forest':
		loaded_scene = preload("res://Scenes/Forest.tscn")
	elif scene_id == 'castle_front':
		loaded_scene = preload("res://Scenes/CastleFront.tscn")
	elif scene_id == 'cave_front':
		loaded_scene = preload("res://Scenes/CaveFront.tscn")
	elif scene_id == 'house':
		loaded_scene = preload("res://Scenes/House.tscn")
	elif scene_id == 'cave':
		loaded_scene = preload("res://Scenes/Cave.tscn")
	elif scene_id == 'castle':
		loaded_scene = preload("res://Scenes/Castle.tscn")
	elif scene_id == 'castle_end':
		loaded_scene = preload("res://Scenes/CastleBack.tscn")
		pass
	elif scene_id == 'shop':
		loaded_scene = preload("res://Scenes/Shop.tscn")
	else:
		assert(false, "Unknwon scene!")
		
	loaded_game_scene_id = scene_id
		
	var inst = loaded_scene.instantiate()
	current_game_scene = inst
	
	game_paused.connect(inst.on_game_paused)
	game_continued.connect(inst.on_game_continued)
	
	inst.request_disc_change.connect(on_request_disc_change)
	inst.request_adventure_scene_change.connect(on_request_adventure_scene_change)
	
	inst.set_inventory(inventory)
	if scene_id != 'shop':
		inst.set_hero(pos)
	
	$SubViewport/scene.add_child(inst)
	continue_game()
	zoom_in_to_screen()
	
	
	
func load_racing_game(scene_id, pos):
	unload_current_game()
	hide_message_box()
	
	var loaded_scene = null
	if scene_id == 'title':
		loaded_scene = preload("res://Scenes/Racing/RacingTitle.tscn")
	elif scene_id == 'race':
		loaded_scene = preload("res://Scenes/Racing/Road.tscn")
	var inst = loaded_scene.instantiate()
	
	loaded_game_scene_id = scene_id
		
	current_game_scene = inst
	
	game_paused.connect(inst.on_game_paused)
	game_continued.connect(inst.on_game_continued)
	
	inst.request_disc_change.connect(on_request_disc_change)
	inst.request_race_scene_change.connect(load_racing_game)
	
	inst.set_inventory(inventory)
	
	$SubViewport/scene.add_child(inst)
	continue_game()
	zoom_in_to_screen()

	
func load_text_game():
	unload_current_game()
	hide_message_box()
	
	var loaded_scene := preload("res://Scenes/TextAdventure.tscn")
	var inst := loaded_scene.instantiate()
	
	loaded_game_scene_id = "text"
	current_game_scene = inst
	
	game_paused.connect(inst.on_game_paused)
	game_continued.connect(inst.on_game_continued)
	
	inst.request_disc_change.connect(on_request_disc_change)
	inst.set_inventory(inventory)
	
	$SubViewport/scene.add_child(inst)
	continue_game()
	zoom_in_to_screen()
	
	
func load_business():
	unload_current_game()
	hide_message_box()
	
	var loaded_scene := preload("res://Scenes/Spreadsheet.tscn")
	var inst := loaded_scene.instantiate()
	
	loaded_game_scene_id = "spreadsheet"
	current_game_scene = inst
	
	game_paused.connect(inst.on_game_paused)
	game_continued.connect(inst.on_game_continued)
	
	inst.request_disc_change.connect(on_request_disc_change)
	inst.set_inventory(inventory)
	
	$SubViewport/scene.add_child(inst)
	continue_game()
	zoom_in_to_screen()

	
func load_jump_game(scene_id, pos):
	unload_current_game()
	hide_message_box()
	
	var loaded_scene = null
	if scene_id == 'title':
		loaded_scene = preload("res://Scenes/Jumper/JumperTitle.tscn")
	elif scene_id == 'level':
		loaded_scene = preload("res://Scenes/Jumper/JumpLevel.tscn")
	var inst = loaded_scene.instantiate()
	
	loaded_game_scene_id = scene_id
	current_game_scene = inst
	
	game_paused.connect(inst.on_game_paused)
	game_continued.connect(inst.on_game_continued)
	
	inst.request_disc_change.connect(on_request_disc_change)
	inst.request_jumper_scene_change.connect(load_jump_game)
	
	inst.set_inventory(inventory)
	inst.set_hero(pos)
	
	$SubViewport/scene.add_child(inst)
	continue_game()
	zoom_in_to_screen()


func _on_sound_player_finished():
	$SoundPlayer.play()
