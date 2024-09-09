extends CanvasLayer


var upgrade_count : int = 0

func _on_upgrade_button_pressed():
	GameManager.upgrade_player()
	upgrade_count += 1
	if upgrade_count == 1:
		queue_free()
		upgrade_count = 0

func _on_close_button_pressed():
	queue_free()
