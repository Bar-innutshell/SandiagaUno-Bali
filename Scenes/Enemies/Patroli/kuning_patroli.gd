extends CharacterBody2D

const NAME = "enemy"

@export var patrol_points : Node
@export var speed : float = 50.0
@export var wait_time : float = 1.0
@export var health_amount : int = 50
@export var damage_amount : int = 1

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var timer = $Timer
@onready var audio_stream_player_death: AudioStreamPlayer = $AudioStreamPlayer_death
@onready var death_timer = Timer.new()

enum State { Idle, Move, Knockback, Dying }
var current_state : State = State.Idle
var point_positions : Array[Vector2] = []
var current_point_index : int = 0
var can_move : bool = true

# Common constants for all enemy types
const KNOCKBACK_STRENGTH = 400.0
const KNOCKBACK_DURATION = 0.25
var knockback_active: bool = false

const ARRIVAL_THRESHOLD : float = 0.1

func _ready():
	print("Bee enemy initialized")
	if patrol_points and patrol_points.get_child_count() > 0:
		for point in patrol_points.get_children():
			point_positions.append(point.global_position)
		print("Patrol points: ", point_positions)
		global_position = point_positions[0]
	else:
		print("No valid patrol points found")
	
	# Set up the death timer
	death_timer.one_shot = true
	death_timer.connect("timeout", Callable(self, "_on_death_timer_timeout"))
	add_child(death_timer)

func _physics_process(delta: float):
	if current_state == State.Dying:
		return

	if not knockback_active:
		match current_state:
			State.Move:
				if can_move:
					move_to_next_point(delta)
			State.Idle:
				velocity = Vector2.ZERO

	move_and_slide()
	update_animation()

func move_to_next_point(delta: float):
	var target_point = point_positions[current_point_index]
	var distance_to_target = global_position.distance_to(target_point)
	
	if distance_to_target > ARRIVAL_THRESHOLD:
		var direction = (target_point - global_position).normalized()
		var movement_this_frame = min(speed * delta, distance_to_target)
		velocity = direction * (movement_this_frame / delta)
	else:
		global_position = target_point
		velocity = Vector2.ZERO
		current_point_index = (current_point_index + 1) % point_positions.size()
		can_move = false
		current_state = State.Idle
		timer.start()

func update_animation():
	if animated_sprite_2d:
		match current_state:
			State.Idle:
				animated_sprite_2d.play("idle")
			State.Move:
				animated_sprite_2d.play("move")
			State.Knockback:
				animated_sprite_2d.play("hit")
			State.Dying:
				animated_sprite_2d.play("death")
		
		if velocity.x != 0:
			animated_sprite_2d.flip_h = velocity.x < 0

func _on_timer_timeout():
	can_move = true
	if current_state != State.Knockback and current_state != State.Dying:
		current_state = State.Move

func apply_knockback(attacker_position: Vector2) -> void:
	var knockback_direction = (global_position - attacker_position).normalized()
	var knockback_force = knockback_direction * KNOCKBACK_STRENGTH
	
	knockback_active = true
	current_state = State.Knockback
	var tween = create_tween()
	tween.tween_method(
		func(progress: float):
			var interpolation = 1.0 - progress
			velocity = knockback_force * interpolation, 0.0, 1.0, KNOCKBACK_DURATION
	)
	tween.tween_callback(func():
		knockback_active = false
		current_state = State.Move
	)


func _on_hurtbox_area_entered(area: Area2D):
	if current_state == State.Dying:
		return
	
	if area.get_parent().has_method("get_damage_amount") or area.is_in_group("attack"):
		var node = area.get_parent()
		health_amount -= node.damage_amount
		print("Health amount: ", health_amount)  # Add this line for debugging
		apply_knockback(area.global_position)
		
		if health_amount <= 0:
			die()

func die():
	current_state = State.Dying
	can_move = false
	knockback_active = false
	velocity = Vector2.ZERO
	audio_stream_player_death.play()
	animated_sprite_2d.play("death")
	
	# Start the death timer
	death_timer.start()

func _on_death_timer_timeout():
	queue_free()