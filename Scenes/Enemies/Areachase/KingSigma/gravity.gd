extends Node

@export var character_body : CharacterBody2D
@export var animated_sprite : AnimatedSprite2D

const GRAVITY : int = 1000

func _physics_process(delta):
	if !character_body.is_on_floor():
		character_body.velocity.y += GRAVITY * delta
	
	character_body.move_and_slide()
