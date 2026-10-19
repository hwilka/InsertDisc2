extends Area2D

@export_multiline var message: String = "I am a sign"

func _on_body_entered(body):
	# body is hero
	body.get_parent().on_sign_enter(self, message)


func _on_body_exited(body: Node2D) -> void:
	body.get_parent().on_sign_leave()
