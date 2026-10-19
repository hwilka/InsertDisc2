extends Area2D


func _on_body_entered(body):
	# body is hero
	body.get_parent().on_coin_collected(self)
