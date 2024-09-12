extends CharacterBody2D

const NAME = "enemy"

@export var patrol_points : Node
@export var speed : float = 50.0
@export var wait_time : float = 1.0
@export var health_amount : int = 3
@export var damage_amount : int = 1

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var timer = $Timer

enum State { Idle, Move }
var current_state : State = State.Idle
var point_positions : Array[Vector2] = []
var current_point_index : int = 0
var can_move : bool = true

var knockback_velocity: Vector2 = Vector2.ZERO
@export var knockback_strength: float = 100.0
@export var knockback_decay: float = 200.0

const ARRIVAL_THRESHOLD : float = 0.1  # Increased precision

func _ready():
	print("Bee enemy initialized")
	if patrol_points and patrol_points.get_child_count() > 0:
		for point in patrol_points.get_children():
			point_positions.append(point.global_position)
		print("Patrol points: ", point_positions)
		global_position = point_positions[0]  # Start at the first patrol point
	else:
		print("No valid patrol points found")

func _physics_process(delta: float):
	handle_knockback(delta)
	
	if current_state == State.Move and can_move:
		move_to_next_point(delta)
	
	move_and_slide()
	update_animation()

func move_to_next_point(delta: float):
	var target_point = point_positions[current_point_index]
	var distance_to_target = global_position.distance_to(target_point)
	
	if distance_to_target > ARRIVAL_THRESHOLD:
		var direction = (target_point - global_position).normalized()
		
		# Use the minimum of the distance to target or full movement this frame
		var movement_this_frame = min(speed * delta, distance_to_target)
		velocity = direction * (movement_this_frame / delta)
	else:
		# We've reached the point, snap to it precisely
		global_position = target_point
		velocity = Vector2.ZERO
		current_point_index = (current_point_index + 1) % point_positions.size()
		can_move = false
		current_state = State.Idle
		timer.start()
	
	print("Moving to point: ", target_point, " Current position: ", global_position, " Distance: ", distance_to_target)

func update_animation():
	if animated_sprite_2d:
		animated_sprite_2d.play("idle")
		if velocity.length() > 0:
			animated_sprite_2d.flip_h = velocity.x < 0

func _on_timer_timeout():
	can_move = true
	current_state = State.Move
	print("Timer timeout, resuming movement to next point")

func handle_knockback(delta: float):
	if knockback_velocity.length() > 0:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
		velocity += knockback_velocity
		print("Applying knockback: ", knockback_velocity)

func apply_knockback(knockback_direction: Vector2):
	knockback_velocity = knockback_direction.normalized() * knockback_strength
	print("Knockback applied: ", knockback_velocity)

func _on_hurtbox_area_entered(area: Area2D):
	if area.get_parent().has_method("get_damage_amount") or area.is_in_group("attack"):
		print("Bullet area entered")
		var node = area.get_parent()
		health_amount -= node.damage_amount
		print("Health amount: ", health_amount)
		
		if area.get_parent().has_method("get_knockback_direction"):
			var knockback_direction = area.get_parent().get_knockback_direction()
			apply_knockback(knockback_direction)
		
		if health_amount <= 0:
			if animated_sprite_2d:
				animated_sprite_2d.play("death")
			print("Enemy died")
			queue_free()