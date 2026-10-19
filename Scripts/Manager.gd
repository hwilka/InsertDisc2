extends Node

var current_scene = null

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(-1)

func start_game():
	load_scene.call_deferred("game")
	
func to_main_menu():
	load_scene.call_deferred("main_menu")
	
func end_screen():
	load_scene.call_deferred("end")

func load_scene(scene_id):
	if scene_id == "main_menu":
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	elif scene_id == "game":
		get_tree().change_scene_to_file("res://Scenes/MainScene.tscn")
	elif scene_id == "end":
		get_tree().change_scene_to_file("res://Scenes/EndScene.tscn")
	else:
		assert(false, "UNKNOWN GLOBAL SCENE")
	
