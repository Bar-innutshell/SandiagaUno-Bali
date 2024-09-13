extends CharacterBody2D

var enemy_death_effect = preload("res://Scenes/Enemies/enemy_death_effect.tscn")

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

var knockback_dir
var knockback = false
var player_dir
var knockback_velocity: Vector2 = Vector2.ZERO
@export var knockback_strength: float = 8000.0
@export var knockback_decay: float = 50.0

func _ready():
	ray_cast_right.set_collision_mask_value(1, true)  # Detect walls in layer 1
	ray_cast_right.set_collision_mask_value(2, false)  # Do not detect player
	ray_cast_right.set_collision_mask_value(3, false)  # Do not detect platform

	ray_cast_left.set_collision_mask_value(1, true)  # Detect walls in layer 1
	ray_cast_left.set_collision_mask_value(2, false)  # Do not detect player
	ray_cast_left.set_collision_mask_value(3, false)  # Do not detect platform

func _physics_process(delta):
	current_delta = delta

	if not is_on_floor():
		velocity += get_gravity() * delta

	if !$RayCast2D.is_colliding() and canSwitch:
		direction *= -1
		canSwitch = false
	else:
		canSwitch = true

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

	# Handle knockback
	if knockback:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
		velocity += knockback_velocity
		if knockback_velocity.length() < 10:
			knockback = false
			knockback_velocity = Vector2.ZERO
	else:
		# Normal movement
		velocity.x = direction * SPEED * delta

	position.x += direction * SPEED * delta

	move_and_slide()

func _on_hurtbox_area_entered(area : Area2D):
	if area.get_parent().has_method("get_damage_amount"):
		print("Bullet area entered")
		var node = area.get_parent() as Node
		health_amount -= node.damage_amount
		print("Health amount: ", health_amount)
		if health_amount <= 0:
			var enemy_death_effect_instance = enemy_death_effect.instantiate() as Node2D
			enemy_death_effect_instance.global_position = global_position
			get_parent().add_child(enemy_death_effect_instance)
			HitStopManager.hit_stop_short()
			queue_free()
	if area.is_in_group("attack"):
		var node = area.get_parent() as Node
		health_amount -= node.damage_amount
		player_dir = node.dir
		knockback_dir = player_dir
		apply_knockback(current_delta)
		print("Health amount: ", health_amount)
		if health_amount <= 0:
			var enemy_death_effect_instance = enemy_death_effect.instantiate() as Node2D
			enemy_death_effect_instance.global_position = global_position
			get_parent().add_child(enemy_death_effect_instance)
			HitStopManager.hit_stop_short()
			queue_free()

func apply_knockback(delta: float):
	knockback = true
	if direction == player_dir:
		knockback_dir *= 1
	knockback_velocity.x = knockback_strength * knockback_dir * delta  # Determine knockback direction