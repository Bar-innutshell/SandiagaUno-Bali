extends CharacterBody2D

const speed = 30
var dir: Vector2

var is_bat_chase: bool

func _on_timer_timeout():
	$Timer.wait_time = choose([1.0, 1.5, 2.0])
	if !is_bat_chase:
		dir = choose([Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT])
		print(dir)

func choose(array):
	array.shuffle()
	return array.front()
