extends CharacterBody2D

const NAME = "enemy"
var current_delta: float = 0.0

const SPEED = 60
var direction = 1
var canSwitch : bool = true
@export var health_amount : int = 110
@export var damage_amount : int = 1

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D
@onready var audio_stream_death: AudioStreamPlayer = $AudioStreamPlayer_death

# Common constants for all enemy types
const KNOCKBACK_STRENGTH = 400.0
const KNOCKBACK_DURATION = 0.25
var knockback_active: bool = false
var is_dead: bool = false

func _ready():
	ray_cast_right.set_collision_mask_value(1, true)  # Detect walls in layer 1
	ray_cast_right.set_collision_mask_value(2, false)  # Do not detect player
	ray_cast_right.set_collision_mask_value(3, false)  # Do not detect platform

	ray_cast_left.set_collision_mask_value(1, true)  # Detect walls in layer 1
	ray_cast_left.set_collision_mask_value(2, false)  # Do not detect player
	ray_cast_left.set_collision_mask_value(3, false)  # Do not detect platform

func _physics_process(delta):
	if is_dead:
		velocity = Vector2.ZERO
		return

	current_delta = delta

	if not is_on_floor():
		velocity += get_gravity() * delta

	if direction < 0:
		velocity.x = SPEED * -1.0 * delta
		$RayCast2D.target_position = Vector2(-278, 250)
	else:
		velocity.x = SPEED * 1.0 * delta
		$RayCast2D.target_position = Vector2(278, 250)

	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# Check for wall collisions, ignoring the player and platform
	if ray_cast_right.is_colliding():
		var collider = ray_cast_right.get_collider()
		if collider and not collider.is_in_group("Player") and not collider.is_in_group("Platform"):
			direction = -1
	if ray_cast_left.is_colliding():
		var collider = ray_cast_left.get_collider()
		if collider and not collider.is_in_group("Player") and not collider.is_in_group("Platform"):
			direction = 1

	if not knockback_active:
		if !$RayCast2D.is_colliding() and canSwitch:
			direction *= -1
			canSwitch = false
		else:
			canSwitch = true
			
		velocity.x = direction * SPEED * delta

	position.x += direction * SPEED * delta

	move_and_slide()

func _on_hurtbox_area_entered(area : Area2D):
	if area.get_parent().has_method("get_damage_amount") or area.is_in_group("attack"):
		var node = area.get_parent() as Node
		health_amount -= node.damage_amount
		apply_knockback(area.global_position)
		if health_amount <= 0:
			is_dead = true
			audio_stream_death.play()
			animated_sprite.play("death")
			await animated_sprite.animation_finished
			HitStopManager.hit_stop_short()
			queue_free()

func apply_knockback(attacker_position: Vector2) -> void:
	var knockback_direction = (global_position - attacker_position).normalized()
	var knockback_force = knockback_direction * KNOCKBACK_STRENGTH
	
	knockback_active = true
	var tween = create_tween()
	tween.tween_method(
		func(progress: float):
			var interpolation = 1.0 - progress
			velocity = knockback_force * interpolation
			move_and_slide()
	, 0.0, 1.0, KNOCKBACK_DURATION)
	tween.tween_callback(func(): knockback_active = false)
