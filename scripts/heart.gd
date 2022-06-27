extends Spatial

func _on_Area_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		body.hp = 100
		queue_free()
