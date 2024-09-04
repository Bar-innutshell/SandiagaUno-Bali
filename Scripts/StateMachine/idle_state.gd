extends NodeState

@export var character_body : CharacterBody2D
@export var animated_sprite : AnimatedSprite2D
@export var slow_down_speed : int = 50

func on_process(delta : float):
	pass

func on_physics_process(delta : float):
	character_body.velocity.x = move_toward(character_body.velocity.x,0,slow_down_speed*delta)
	animated_sprite.play("idle")
	character_body.move_and_slide()

func enter():
	pass
	
func exit():
	pass
