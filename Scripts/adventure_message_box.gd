extends ColorRect

func hide_message():
	visible = false
	#$Hero.on_game_continued()

func show_message(text,dur=3.0):
	visible = true
	$Label.text = text
	#$Hero.on_game_paused()
	var tween = get_tree().create_tween()
	tween.tween_interval(dur)
	tween.tween_callback(hide_message)

func show_message_unlimited(text):
	visible = true
	$Label.text = text
