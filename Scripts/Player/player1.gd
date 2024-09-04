extends CharacterBody2D

var bullet = preload("res://Scenes/Weapon/bullets.tscn")
var player_death_effect = preload("res://Scenes/Player/player_death_effect.tscn")
@onready var muzzle : Marker2D = $Muzzle
var muzzle_position

@export var SPEED = 1000
@export var max_horizontal_speed : int = 180
@export var slowdown_speed : int = 1800 

@export var JUMP_VELOCITY = -90000
@export var double_jump_velocity : float = -90000
@export var max_vertical_speed : int = 300
var has_double_jump : bool = false

@onready var animated_sprite = $AnimatedSprite2D
@onready var hit_animation_player = $HitAnimationPlayer

func _ready():
	muzzle_position = muzzle.position

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		has_double_jump = false

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			# Normal jump
			velocity.y = JUMP_VELOCITY * delta
			velocity.y = clamp(velocity.y, -max_vertical_speed, max_vertical_speed)
		elif not has_double_jump:
			# Double jump in air
			velocity.y = double_jump_velocity * delta
			velocity.y = clamp(velocity.y, -max_vertical_speed, max_vertical_speed)
			has_double_jump = true

	# Handle Running
	var run_multiplier = 1
	
	if Input.is_action_pressed("run"):
		run_multiplier = 2

	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
	# Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		elif Input.is_action_pressed("shot"):
			animated_sprite.play("run-shot")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	# Shooting
	if direction != 0 and Input.is_action_just_pressed("shot"):
		var bullet_instance = bullet.instantiate() as Node2D
		bullet_instance.direction = direction
		bullet_instance.global_position = muzzle.global_position
		get_parent().add_child(bullet_instance)
	
	# Muzzle position
	if direction > 0:
		muzzle.position.x = muzzle_position.x
	elif direction < 0:
		muzzle.position.x = -muzzle_position.x
			
	# Apply movement
	if direction != 0:
		velocity.x += direction * SPEED * run_multiplier * delta
		velocity.x = clamp(velocity.x, -max_horizontal_speed * run_multiplier, max_horizontal_speed * run_multiplier)
	else:
		velocity.x = move_toward(velocity.x, 0, slowdown_speed * delta)

	move_and_slide()

func player_death():
	var player_death_effect_instance = player_death_effect.instantiate() as Node2D
	player_death_effect_instance.global_position = global_position
	get_parent().add_child(player_death_effect_instance)
	queue_free()

func _on_hurtbox_body_entered(body : Node2D):
	if body.is_in_group("Enemy"):
		print("Enemy Entered ", body.damage_amount)
		hit_animation_player.play("hit")
		HealthManager.decrease_health(body.damage_amount)
		
	if HealthManager.current_health == 0:
		player_death()
