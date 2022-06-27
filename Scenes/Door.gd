extends StaticBody


func _process(delta: float) -> void:
	if get_parent().score == 6:
		queue_free()
