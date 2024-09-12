extends Node

signal on_health_changed(new_health: int)

var max_health: int = 3
var current_health: int = max_health

func decrease_health(amount: int):
	current_health = max(0, current_health - amount)
	emit_signal("on_health_changed", current_health)

func increase_health(amount: int):
	current_health = min(max_health, current_health + amount)
	emit_signal("on_health_changed", current_health)

func set_health(new_health: int):
	current_health = clamp(new_health, 0, max_health)
	emit_signal("on_health_changed", current_health)

func reset_health():
	set_health(max_health)