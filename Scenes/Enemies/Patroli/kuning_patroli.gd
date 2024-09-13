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

enum State { Idle, Move, Knockback, Dying }
var current_state : State = State.Idle
var point_positions : Array[Vector2] = []
var current_point_index : int = 0
var can_move : bool = true

var knockback_velocity: Vector2 = Vector2.ZERO
@export var knockback_strength: float = 100.0
@export var knockback_decay: float = 200.0

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

func _physics_process(delta: float):
	match current_state:
		State.Knockback:
			handle_knockback(delta)
		State.Move:
			if can_move:
				move_to_next_point(delta)
		State.Idle:
			velocity = Vector2.ZERO
		State.Dying:
			velocity = Vector2.ZERO

	# Apply the calculated velocity
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

func handle_knockback(delta: float):
	if knockback_velocity.length() > 0:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
		velocity = knockback_velocity
		print("Applying knockback: ", knockback_velocity)
	else:
		current_state = State.Move
		can_move = true

func apply_knockback(knockback_direction: Vector2):
	knockback_velocity = knockback_direction.normalized() * knockback_strength
	current_state = State.Knockback
	can_move = false
	print("Knockback applied: ", knockback_velocity)

func _on_hurtbox_area_entered(area: Area2D):
	if current_state == State.Dying:
		return
	
	if area.get_parent().has_method("get_damage_amount") or area.is_in_group("attack"):
		print("Bullet area entered")
		var node = area.get_parent()
		health_amount -= node.damage_amount
		print("Health amount: ", health_amount)
		
		if area.get_parent().has_method("get_knockback_direction"):
			var knockback_direction = area.get_parent().get_knockback_direction()
			apply_knockback(knockback_direction)
		
		if health_amount <= 0:
			die()

func die():
	current_state = State.Dying
	can_move = false
	audio_stream_player_death.play()
	if animated_sprite_2d:
		animated_sprite_2d.play("death")
		animated_sprite_2d.connect("animation_finished", _on_death_animation_finished)

func _on_death_animation_finished():
	queue_free()