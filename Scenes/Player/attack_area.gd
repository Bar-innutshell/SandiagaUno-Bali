extends Area2D

var direction = 1

func _process(delta):
	if Input.is_action_just_pressed("move_left"):
		direction = -1
	if Input.is_action_just_pressed("move_right"):
		direction = 1