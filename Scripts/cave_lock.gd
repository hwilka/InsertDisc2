extends Area2D


func _on_body_entered(body):
	# body is hero
	body.get_parent().on_lock_entered(self)


func _on_body_exited(body: Node2D) -> void:
	body.get_parent().on_lock_left()
