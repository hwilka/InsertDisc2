extends Node2D

const TIME_1 = 2.5
const TIME_2 = 2.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


var initialized = false
func _process(_delta: float) -> void:
	if not initialized:
		initialized = true
		
		var tween = get_tree().create_tween()
		tween.tween_interval(1.0)
		tween.tween_callback(show_title)
		tween.tween_interval(TIME_1)
		tween.tween_callback(show_thanks)
		tween.tween_interval(TIME_2)
		tween.tween_callback(to_menu)
		
func show_title():
	$TitleScale/Title.visible = true
	
	var tween = get_tree().create_tween()
	tween.tween_property($TitleScale, "scale", Vector2.ONE * 1.1, TIME_1+TIME_2)
	

func show_thanks():
	$Thanks.visible = true


func to_menu():
	Manager.to_main_menu()
