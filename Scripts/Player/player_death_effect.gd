extends Node2D



func _on_timer_timeout():
	queue_free()
	get_tree().reload_current_scene()
