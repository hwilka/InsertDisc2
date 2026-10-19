extends Node2D

const TITLE_WITH_BLINK = "Insert Disc 2_"
const TITLE_WITHOUT_BLINK = "Insert Disc 2"

var mode = 0
var current_select = 0
var locked = false


var blink_timer = 1.0
var show_line = false
func _process(delta):
	if locked:
		return
		
	if mode == 1:
		#Credits
		if Input.is_action_just_pressed("Abort") or Input.is_action_just_pressed("Accept"):
			locked = true
			var tween = get_tree().create_tween()
			$SubViewport/Content/Credits.visible = false
			tween.tween_interval(0.5)
			tween.tween_callback(show_main)
			
	elif mode == 0:
		blink_timer -= delta
		while blink_timer < 0:
			blink_timer += 1.0
		var show_line_pre = show_line
		show_line = blink_timer < 0.5
		if show_line != show_line_pre:
			if show_line:
				$SubViewport/Content/Main/Title.text = TITLE_WITH_BLINK
			else:
				$SubViewport/Content/Main/Title.text = TITLE_WITHOUT_BLINK
		
		if Input.is_action_just_pressed("Abort") or Input.is_action_just_pressed("Accept"):
			if current_select == 1:
				locked = true
				var tween = get_tree().create_tween()
				$SubViewport/Content/Main.visible = false
				tween.tween_interval(0.5)
				tween.tween_callback(show_credits)
			else:
				locked = true
				var tween = get_tree().create_tween()
				$SubViewport/Content/Main.visible = false
				tween.tween_interval(1.0)
				tween.tween_callback(start_game)
		
		var cp =current_select
		if Input.is_action_just_pressed("Up"):
			current_select -= 1
		if Input.is_action_just_pressed("Down"):
			current_select += 1
		current_select = clamp(current_select,0,1)
		if current_select != cp:
			update_main()
		
func update_main():
	if current_select == 0:
		$SubViewport/Content/Main/MenuItems/Arrow.position.y = $SubViewport/Content/Main/MenuItems/StartGame.position.y
	else:
		$SubViewport/Content/Main/MenuItems/Arrow.position.y = $SubViewport/Content/Main/MenuItems/Credits.position.y
	
func start_game():
	Manager.start_game()
			
func show_credits():
	locked = false
	mode = 1
	$SubViewport/Content/Credits.visible = true
	
func show_main():
	show_line = false
	blink_timer = 1.0
	$SubViewport/Content/Main/Title.text = TITLE_WITHOUT_BLINK
	locked = false
	mode = 0
	current_select = 0
	update_main()
	$SubViewport/Content/Main.visible = true
