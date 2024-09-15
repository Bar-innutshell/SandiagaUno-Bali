extends CharacterBody2D
class_name Player1

# Constants
const SPEED = 600
const MAX_HORIZONTAL_SPEED = 180
const SLOWDOWN_SPEED = 1800
const JUMP_VELOCITY = -100000
const MAX_VERTICAL_SPEED = 300
const WALL_JUMP = 700
const JUMP_WALL = -350
const WALL_SLIDE_GRAVITY = 10
const WALL_SLIDE_SPEED = 30
const DASH_SPEED = 400.0
const DASH_DURATION = 0.4
const KNOCKBACK_STRENGTH = 400.0
const KNOCKBACK_DURATION = 0.25
const SHOOT_COOLDOWN = 0.3

# Node references
@onready var animated_sprite = $AnimatedSprite2D
@onready var hit_animation_player = $HitAnimationPlayer
@onready var audio_stream_jumping: AudioStreamPlayer = $audio/AudioStreamPlayer2D_Jump
@onready var audio_stream_walking: AudioStreamPlayer = $audio/AudioStreamPlayer2D_walking
@onready var audio_stream_dashing: AudioStreamPlayer = $audio/AudioStreamPlayer2D_dash
@onready var audio_stream_hit: AudioStreamPlayer = $audio/AudioStreamPlayer2D_hit
@onready var audio_stream_died: AudioStreamPlayer = $audio/AudioStreamPlayer2D_died
@onready var audio_stream_mantul: AudioStreamPlayer = $audio/AudioStreamPlayer2D_mantul
@onready var audio_stream_attack: AudioStreamPlayer = $audio/AudioStreamPlayer2D_attack
@onready var audio_stream_shoot: AudioStreamPlayer = $audio/AudioStreamPlayer_fireball
@onready var muzzle: Marker2D = $Muzzle
@onready var can_dash_timer = $can_dash
@onready var attack_combo_reset: Timer = $attack_combo_reset

# Preloaded scenes
var bullet = preload("res://Scenes/Weapon/bullets.tscn")

# Movement variables
var has_double_jump : bool = false
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

# Define the combo sequence
var combo_animations = ["swing", "uppercut", "thrust"]
var current_combo_step = 0
var combo_input_count = 0

# New constants for wall detection
const WALL_DETECTION_DISTANCE = 10.0
const WALL_SLIDE_THRESHOLD = 5.0
var is_wall_slide_enabled = false  # Untuk menyimpan status wall slide

# Death flag
var is_dead = false

# Modify the knockback variables
var knockback_active: bool = false
var knockback_tween: Tween

func _ready():
	GameManager.playerBody = self
	GameManager.player = self
	GameManager.reset_checkpoint_status()
	set_safe_margin(1.0)  # Adjust as needed

func _physics_process(delta):
	if is_dead:
		return  # Skip processing if the player is dead
	
	handle_input()
	apply_gravity(delta)
	handle_jump(delta)
	handle_wall_slide(delta)
	handle_dash(delta)
	
	if not knockback_active:
		handle_movement(delta)
	
	update_animation()
	update_muzzle_position()
	move_and_slide()
	check_fall_death()
	
	# Update the shoot cooldown timer
	if shoot_cooldown_timer > 0:
		shoot_cooldown_timer -= delta

func handle_input():
	if is_dead:
		return  # Skip input handling if the player is dead
	
	direction = Input.get_axis("move_left", "move_right")
	
	if Input.is_action_just_pressed("attack"):
		combo_input_count += 1
		start_attack()
		attack_combo_reset.start(1.0)  # Restart the timer on each attack input
	
	if Input.is_action_just_pressed("shot") and shoot_cooldown_timer <= 0:
		shoot()

func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		has_double_jump = false

func handle_jump(delta):
	if is_dead:
		return  # Skip jump handling if the player is dead
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY * delta
			velocity.y = clamp(velocity.y, -MAX_VERTICAL_SPEED, MAX_VERTICAL_SPEED)
			audio_stream_jumping.play()
		elif not has_double_jump:
			# Double jump in air
			velocity.y = JUMP_VELOCITY * delta
			velocity.y = clamp(velocity.y, -MAX_VERTICAL_SPEED, MAX_VERTICAL_SPEED)
			has_double_jump = true

func handle_wall_slide(delta):
	# Check if the player is next to a wall and not on the floor
	if Input.is_action_pressed("wallslide") and nextToWall() and not is_on_floor():
		is_wall_sliding = true
	else:
		is_wall_sliding = false

	if is_wall_sliding:
		if velocity.y > WALL_SLIDE_SPEED:
			velocity.y = WALL_SLIDE_SPEED
		else:
			velocity.y += (WALL_SLIDE_GRAVITY * delta)
			velocity.y = min(velocity.y, WALL_SLIDE_GRAVITY)

	if Input.is_action_just_pressed("jump") and nextToWall() and !is_on_floor() and is_wall_sliding:
		wall_jump(delta)

func _on_WallSlideResetTimer_timeout():
	is_wall_slide_enabled = false  # Reset the wall slide state when the timer times out

func is_near_wall():
	return $RightWall.is_colliding() or $LeftWall.is_colliding() or \
		   $RightWall2.is_colliding() or $LeftWall2.is_colliding() or \
		   $RightWall3.is_colliding() or $LeftWall3.is_colliding()

func wall_jump(delta):
	velocity.y = JUMP_VELOCITY * delta
	velocity.y = clamp(velocity.y, -MAX_VERTICAL_SPEED, MAX_VERTICAL_SPEED)
	if nextToRightWall():
		velocity.x = -WALL_JUMP
	elif nextToLeftWall():
		velocity.x = WALL_JUMP
	audio_stream_mantul.play()
	is_wall_sliding = false

func handle_dash(delta):
	if is_dead:
		return  # Skip dash handling if the player is dead
	
	if Input.is_action_just_pressed("dash") and can_dash and direction != 0:
		audio_stream_dashing.play()
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

func handle_movement(delta):
	if is_dead:
		return  # Skip movement handling if the player is dead
	
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
		new_animation = "swing"
	elif knockback:
		new_animation = "hit"
	elif is_wall_sliding:
		new_animation = "wall_slide"
	elif dashing:
		new_animation = "dash"
	elif not is_on_floor():
		new_animation = "jump"
	elif shoot_cooldown_timer > 0:
		new_animation = "runshoot" if abs(velocity.x) > 0 else "shoot"
	elif abs(velocity.x) > 0:
		new_animation = "run"
	else:
		new_animation = "idle"
	
	if new_animation != current_animation:
		animated_sprite.play(new_animation)
		current_animation = new_animation
	
	animated_sprite.flip_h = direction < 0 if direction != 0 else animated_sprite.flip_h

func update_muzzle_position():
	muzzle.position.x = abs(muzzle.position.x) * sign(direction) if direction != 0 else muzzle.position.x

func shoot():
	if is_dead:
		return  # Skip shooting if the player is dead
	
	var bullet_instance = bullet.instantiate()
	bullet_instance.direction = 1 if not animated_sprite.flip_h else -1
	bullet_instance.global_position = muzzle.global_position
	get_parent().add_child(bullet_instance)
	shoot_cooldown_timer = SHOOT_COOLDOWN  # Reset the cooldown timer
	
	# Play shoot audio
	audio_stream_shoot.play()

func start_attack():
	if is_dead:
		return  # Skip attacking if the player is dead
	
	if not is_attacking:
		is_attacking = true
		play_next_combo_animation()

func play_next_combo_animation():
	if combo_input_count > 0 and current_combo_step < combo_animations.size():
		var animation_name = combo_animations[current_combo_step]
		audio_stream_attack.play()
		hit_animation_player.play("punch")
		animated_sprite.play(animation_name)
		current_combo_step += 1
		combo_input_count -= 1
		await animated_sprite.animation_finished
		play_next_combo_animation()
	else:
		# Reset combo
		current_combo_step = 0
		is_attacking = false

func _on_attack_combo_reset_timeout():
	# Reset combo if the timer times out
	combo_input_count = 0
	current_combo_step = 0
	is_attacking = false

func apply_knockback(attacker_position: Vector2):
	if is_dead or knockback_active:
		return  # Skip knockback if the player is dead or already in knockback

	var knockback_direction = (global_position - attacker_position).normalized()
	var knockback_force = knockback_direction * KNOCKBACK_STRENGTH
	
	knockback_active = true
	
	# Stop any existing knockback tween
	if knockback_tween:
		knockback_tween.kill()
	
	knockback_tween = create_tween()
	knockback_tween.tween_method(
		func(progress: float):
			var interpolation = 1.0 - progress
			velocity = knockback_force * interpolation,
		0.0, 1.0, KNOCKBACK_DURATION
	)
	knockback_tween.tween_callback(func():
		knockback_active = false
	)

func player_death():
	# Set the death flag
	is_dead = true
	
	# Reset knockback variables
	knockback = false
	knockback_velocity = Vector2.ZERO
	
	# Play animation and audio
	animated_sprite.play("death")
	audio_stream_died.play()
	await animated_sprite.animation_finished

	GameManager.check_checkpoint_status()
	# If the scene hasn't reloaded, respawn the player
	GameManager.respawn_player()
	HealthManager.set_health(1)  # Use the new set_health function

	# Reset the death flag
	is_dead = false

func check_fall_death():
	if position.y >= 1500:
		player_death()

func _on_hurtbox_body_entered(body: CharacterBody2D):
	if body.is_in_group("Enemy"):
		audio_stream_hit.play()
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