extends CharacterBody2D
class_name Player1

# Constants
const SPEED = 1000
const MAX_HORIZONTAL_SPEED = 180
const SLOWDOWN_SPEED = 1800
const JUMP_VELOCITY = -100000
const MAX_VERTICAL_SPEED = 300
const WALL_JUMP = 700
const JUMP_WALL = -350
const WALL_SLIDE_GRAVITY = 10
const WALL_SLIDE_SPEED = 30
const DASH_SPEED = 800.0
const DASH_DURATION = 0.2
const KNOCKBACK_STRENGTH = 25.0
const KNOCKBACK_DECAY = 45.0
const SHOOT_COOLDOWN = 0.8

# Node references
@onready var animated_sprite = $AnimatedSprite2D
@onready var hit_animation_player = $HitAnimationPlayer
@onready var audio_stream_jumping = $AudioStreamPlayer2D_Jumping
@onready var audio_stream_walking = $AudioStreamPlayer2D_walking
@onready var muzzle: Marker2D = $Muzzle
@onready var can_dash_timer = $can_dash

# Preloaded scenes
var bullet = preload("res://Scenes/Weapon/bullets.tscn")
var player_death_effect = preload("res://Scenes/Player/player_death_effect.tscn")

# sound
var playerGrassWalkingSound = load("res://Assets/Sound/SFX/player_walking.mp3")
var playerSnowWalkingSound = load("res://Assets/Sound/SFX/player_jumping.mp3")

# Movement variables
var direction = 0
var is_wall_sliding = false

# Dash variables
var dashing = false
var can_dash = true
var dash_timer = 0.0
var dash_direction = Vector2.ZERO

# Knockback variables
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback = false

# Animation and action flags
var is_attacking = false
var current_animation = ""
var shoot_cooldown_timer = 0.0

func _ready():
	GameManager.playerBody = self
	GameManager.player = self
	set_collision_mask_value(1, true)  # Adjust the mask value as needed
	set_collision_layer_value(1, true)
	set_safe_margin(1.0)  # Adjust as needed

func _physics_process(delta):
	handle_input()
	apply_gravity(delta)
	handle_jump(delta)
	handle_wall_slide(delta)
	handle_dash(delta)
	handle_knockback(delta)
	handle_movement(delta)
	update_animation()
	update_muzzle_position()
	move_and_slide()
	check_fall_death()
	
	# Update the shoot cooldown timer
	if shoot_cooldown_timer > 0:
		shoot_cooldown_timer -= delta

func handle_input():
	direction = Input.get_axis("move_left", "move_right")
	
	if Input.is_action_just_pressed("attack"):
		start_attack()
	
	if Input.is_action_just_pressed("shot") and shoot_cooldown_timer <= 0:
		shoot()

func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

func handle_jump(delta):
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY * delta
			velocity.y = clamp(velocity.y, -MAX_VERTICAL_SPEED, MAX_VERTICAL_SPEED)
			audio_stream_jumping.play()

func handle_wall_slide(delta):
	is_wall_sliding = false

	if is_on_wall() and !is_on_floor():
		is_wall_sliding = true
	
	if is_wall_sliding:
		if velocity.y > WALL_SLIDE_SPEED:
			velocity.y = WALL_SLIDE_SPEED
		else:
			velocity.y += (WALL_SLIDE_GRAVITY * delta)
			velocity.y = min(velocity.y, WALL_SLIDE_GRAVITY)
	
	if Input.is_action_just_pressed("jump") and nextToWall() and !is_on_floor():
		wall_jump(delta)

func wall_jump(delta):
	velocity.y = JUMP_VELOCITY * delta
	velocity.y = clamp(velocity.y, -MAX_VERTICAL_SPEED, MAX_VERTICAL_SPEED)
	if nextToRightWall():
		velocity.x = -WALL_JUMP
	elif nextToLeftWall():
		velocity.x = WALL_JUMP
	is_wall_sliding = false

func handle_dash(delta):
	if Input.is_action_just_pressed("dash") and can_dash and is_on_floor():
		start_dash()
	
	if dashing:
		dash_timer += delta
		if dash_timer < DASH_DURATION:
			velocity = dash_direction * DASH_SPEED
		else:
			end_dash()

func start_dash():
	dashing = true
	can_dash = false
	dash_timer = 0.0
	dash_direction = Vector2(direction, 0).normalized()
	can_dash_timer.start()

func end_dash():
	dashing = false
	velocity = dash_direction * MAX_HORIZONTAL_SPEED

func handle_knockback(delta):
	if knockback:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, KNOCKBACK_DECAY * delta)
		velocity += knockback_velocity
		if knockback_velocity.length() < 10:
			knockback = false
			knockback_velocity = Vector2.ZERO

func handle_movement(delta):
	if not dashing and not knockback:
		if direction != 0:
			velocity.x += direction * SPEED * delta
			velocity.x = clamp(velocity.x, -MAX_HORIZONTAL_SPEED, MAX_HORIZONTAL_SPEED)
			if is_on_floor() and not audio_stream_walking.playing:
				audio_stream_walking.play()
		else:
			velocity.x = move_toward(velocity.x, 0, SLOWDOWN_SPEED * delta)
			if not is_on_floor() or velocity.x == 0:
				audio_stream_walking.stop()

func update_animation():
	var new_animation = ""
	
	if is_attacking:
		new_animation = "attack"
	elif knockback:
		new_animation = "hit"
	elif is_wall_sliding:
		new_animation = "wall_slide"
	elif not is_on_floor():
		new_animation = "jump"
	elif abs(velocity.x) > 0:
		new_animation = "run" if shoot_cooldown_timer > 0 else "run"
	else:
		new_animation = "idle"
	
	if new_animation != current_animation:
		animated_sprite.play(new_animation)
		current_animation = new_animation
	
	animated_sprite.flip_h = direction < 0 if direction != 0 else animated_sprite.flip_h

func update_muzzle_position():
	muzzle.position.x = abs(muzzle.position.x) * sign(direction) if direction != 0 else muzzle.position.x

func shoot():
	var bullet_instance = bullet.instantiate()
	bullet_instance.direction = 1 if not animated_sprite.flip_h else -1
	bullet_instance.global_position = muzzle.global_position
	get_parent().add_child(bullet_instance)
	shoot_cooldown_timer = SHOOT_COOLDOWN  # Reset the cooldown timer

func start_attack():
	if not is_attacking:
		is_attacking = true
		hit_animation_player.play("punch")
		animated_sprite.play("attack")
		await animated_sprite.animation_finished
		is_attacking = false

func apply_knockback(attacker_position: Vector2):
	knockback = true
	var knockback_direction = (global_position - attacker_position).normalized()
	knockback_velocity = knockback_direction * KNOCKBACK_STRENGTH 
	knockback_velocity.y -= 10

func player_death():
	# Reset knockback variables
	knockback = false
	knockback_velocity = Vector2.ZERO
	
	# Instantiate death effect
	var effect_instance = player_death_effect.instantiate()
	effect_instance.global_position = global_position
	get_parent().add_child(effect_instance)
	
	# Respawn player and reset health
	GameManager.respawn_player()
	HealthManager.current_health = 1

func check_fall_death():
	if position.y >= 1000:
		player_death()

func _on_hurtbox_body_entered(body: CharacterBody2D):
	if body.is_in_group("Enemy"):
		animated_sprite.play("hit")
		apply_knockback(body.global_position)
		HealthManager.decrease_health(body.damage_amount)
		
	if HealthManager.current_health == 0:
		player_death()

func nextToWall():
	return nextToRightWall() or nextToLeftWall()

func nextToRightWall():
	return $RightWall.is_colliding() or $RightWall2.is_colliding() or $RightWall3.is_colliding()

func nextToLeftWall():
	return $LeftWall.is_colliding() or $LeftWall2.is_colliding() or $LeftWall3.is_colliding()

func _on_can_dash_timeout():
	can_dash = true