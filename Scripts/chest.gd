extends Area2D

var has_content = true
func make_empty():
	$Sprite2D.frame = 1
	has_content = false
	

func _on_body_entered(body):
	# body is hero
	if has_content:
		body.get_parent().on_chest_enter(self)


func _on_body_exited(body: Node2D) -> void:
	if has_content:
		body.get_parent().on_chest_leave()
