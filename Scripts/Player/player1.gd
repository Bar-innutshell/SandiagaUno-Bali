extends CharacterBody2D

var current_delta: float = 0.0

#Audio
@onready var audio_stream_jumping: AudioStreamPlayer2D = $AudioStreamPlayer2D_Jumping
@onready var audio_stream_walking: AudioStreamPlayer2D = $AudioStreamPlayer2D_walking

#bullet
var bullet = preload("res://Scenes/Weapon/bullets.tscn")
var player_death_effect = preload("res://Scenes/Player/player_death_effect.tscn")
@onready var muzzle : Marker2D = $Muzzle
var muzzle_position

#speed
@export var SPEED = 1000
@export var max_horizontal_speed : int = 180
@export var slowdown_speed : int = 1800 

#jump
@export var JUMP_VELOCITY = -90000
@export var double_jump_velocity : float = -90000
@export var max_vertical_speed : int = 300
var has_double_jump : bool = false
@export var wallJump = 700
@export var jumpWall = -350
@export var wall_slide_gravity = 100
var is_wall_sliding = false

#dash
const DASH_SPEED = 1000.0
const DASH_DURATION = 0.2
var dashing = false
var can_dash = true
var dash_timer = 0.0
var dash_direction = Vector2.ZERO

#knockback
var knockback_dir
var knockback = false
var enemy_dir
var knockback_velocity: Vector2 = Vector2.ZERO  # Variabel knockback
@export var knockback_strength: float = 4000.0  # Besar knockback
@export var knockback_decay: float = 10.0  # Kecepatan peluruhan knockback
var direction = 0
var isAttacking: bool = false

@onready var animated_sprite = $AnimatedSprite2D
@onready var hit_animation_player = $HitAnimationPlayer

func _ready():
	muzzle_position = muzzle.position
	GameManager.playerBody = self

func _physics_process(delta):
	var playerGrassWalkingSound = load("res://Assets/Sound/SFX/player_walking.mp3")
	var playerSnowWalkingSound = load("res://Assets/Sound/SFX/player_jumping.mp3")
	current_delta = delta

	# Handle knockback
	if knockback:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
		velocity += knockback_velocity
		if knockback_velocity.length() < 10:
			knockback = false
			knockback_velocity = Vector2.ZERO

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
		if is_on_wall_only() and nextToRightWall():
			velocity.x -= wallJump
			velocity.y = jumpWall
		if is_on_wall_only() and nextToLeftWall():
			velocity.x += wallJump
			velocity.y = jumpWall
		audio_stream_jumping.play()
	wall_slide(delta)
	 
	if Input.is_action_just_pressed("attack"):
		isAttacking = true
		hit_animation_player.play("punch")
		animated_sprite.play("attack")

	if Input.is_action_pressed("move_left"):
		direction = -1
	elif Input.is_action_pressed("move_right"):
		direction = 1
	else:
		direction = 0
	
	# Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Play animations
	if not animated_sprite.animation == "hit":
		if is_on_floor():
			if direction == 0:
				if isAttacking:
					animated_sprite.play("attack")
					await animated_sprite.animation_finished
					isAttacking = false
				else:
					animated_sprite.play("idle")
			elif Input.is_action_pressed("shot"):
				animated_sprite.play("run-shot")
			else:
				animated_sprite.play("run")
		else:
			animated_sprite.play("jump")
	
	# Shooting
	if Input.is_action_just_pressed("shot"):
		var bullet_instance = bullet.instantiate() as Node2D
		bullet_instance.direction = muzzle.dir
		bullet_instance.global_position = muzzle.global_position
		get_parent().add_child(bullet_instance)
	
	# Muzzle position
	if direction > 0:
		muzzle.position.x = muzzle_position.x
	elif direction < 0:
		muzzle.position.x = -muzzle_position.x
	
	if knockback:
		knockback_velocity = lerp(knockback_velocity, Vector2.ZERO, knockback_decay * delta)
		velocity += knockback_velocity
		if knockback_velocity.length() < 10:
			knockback = false
			knockback_velocity = Vector2.ZERO
	
	# Apply movement right or left and dash
	if direction != 0:
		if Input.is_action_just_pressed("dash") and can_dash and is_on_floor_only():
			start_dash(direction)
		else:
			velocity.x += direction * SPEED * delta
			velocity.x = clamp(velocity.x, -max_horizontal_speed, max_horizontal_speed)
			if is_on_floor():
				if !audio_stream_walking.playing:
					audio_stream_walking.stream = (playerGrassWalkingSound)
					audio_stream_walking.play()
	else:
		velocity.x = move_toward(velocity.x, 0, slowdown_speed * delta)
		if !is_on_floor():
			audio_stream_walking.stop()

	#handle dash
	if dashing:
		dash_timer += delta
		if dash_timer < DASH_DURATION:
			velocity = dash_direction * DASH_SPEED
		else:
			end_dash()
	
	move_and_slide()

func start_dash(dir):
	dashing = true
	can_dash = false
	dash_timer = 0.0
	dash_direction = Vector2(dir, 0).normalized()
	$can_dash.start()

func end_dash():
	dashing = false
	velocity = dash_direction * max_horizontal_speed

func _on_can_dash_timeout() -> void:
	can_dash = true

func player_death():
	var player_death_effect_instance = player_death_effect.instantiate() as Node2D
	player_death_effect_instance.global_position = global_position
	get_parent().add_child(player_death_effect_instance)
	queue_free()

func _on_hurtbox_body_entered(body : CharacterBody2D):
	if body.is_in_group("Enemy"):
		print("Enemy Entered ", body.damage_amount)
		animated_sprite.play("hit")
		enemy_dir = body.direction
		knockback_dir = (global_position - body.global_position).normalized()
		apply_knockback(current_delta)
		HealthManager.decrease_health(body.damage_amount)
		
	if HealthManager.current_health == 0:
		player_death()


func nextToWall():
	return nextToRightWall() or nextToLeftWall()

func nextToRightWall():
	return $RightWall.is_colliding()

func nextToLeftWall():
	return $LeftWall.is_colliding()

func wall_slide(delta):
	if is_on_wall_only():
		if nextToRightWall() or nextToLeftWall():
			is_wall_sliding = true
		else :
			is_wall_sliding = false
	else:
		is_wall_sliding = false
	
	if is_wall_sliding:
		velocity.y += (wall_slide_gravity * delta)
		velocity.y = min(velocity.y, wall_slide_gravity)
	
func apply_knockback(delta: float):
	knockback = true
	knockback_velocity.y -= 25  # Add a small upward component to the knockback
	knockback_velocity = knockback_dir * knockback_strength * delta
	
