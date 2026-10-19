extends Area2D

var can_interact = true
func burn_down():
	can_interact = false
	
	$Sprite2D.frame = 2
	var tween = get_tree().create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(set_passable)
	
func cut_down():
	can_interact = false
	set_passable()
	

func set_passable():
	$Sprite2D.frame = 1
	remove_child($StaticBody2D)
	
func _on_body_entered(body):
	# body is hero
	if can_interact:
		body.get_parent().on_entered_bush(self)


func _on_body_exited(body: Node2D) -> void:
	if can_interact:
		body.get_parent().on_leave_bush(self)


func _on_area_entered(area):
	cut_down()
