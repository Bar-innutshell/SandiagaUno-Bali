extends Marker2D


var damage_amount: int = 100
var dir = 1


func _process(delta):
	if Input.is_action_just_pressed("move_left"):
		dir = -1
	if Input.is_action_just_pressed("move_right"):
		dir = 1
