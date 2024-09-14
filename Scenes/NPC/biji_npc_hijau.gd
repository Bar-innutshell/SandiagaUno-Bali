extends CharacterBody2D

@export var speed = 3000
var dir: Vector2

func _ready():
	$Timer.start()

func _physics_process(delta):
	roam(delta)
	
	move_and_slide()

func roam(delta):
	velocity = dir * speed * delta

func _on_timer_timeout():
	$Timer.wait_time = choose([1.0 , 1.2, 1.5, 1.8])
	dir = choose([Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT])

func choose(array):
	array.shuffle()
	return array.front()
