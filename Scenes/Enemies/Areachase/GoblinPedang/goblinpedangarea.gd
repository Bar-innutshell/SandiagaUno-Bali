extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_stream_death: AudioStreamPlayer2D = $AudioStreamPlayer2D_death

@export var speed = 1000
@export var chase_speed = 4000  # Separate speed for chasing
var current_delta: float = 0.0
var dir: Vector2
var direction: int
const gravity = 900

var is_goblin_chase: bool = false
var is_attacking: bool = false
var is_dying: bool = false

@export var health_amount : int = 210
@export var damage_amount : int = 1

var player: CharacterBody2D

# Common constants for all enemy types
const KNOCKBACK_STRENGTH = 400.0
const KNOCKBACK_DURATION = 0.25
var knockback_active: bool = false

var spawn_position: Vector2
@export var roam_range: float = 100.0  # Range for horizontal roaming

func _ready():
	spawn_position = position
	$Timer.start()

func _physics_process(delta):
	current_delta = delta
	if is_dying:
		return
		
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0

	# Handle knockback
	if not knockback_active:
		player = GameManager.playerBody
		if player != null and is_goblin_chase:
			chase_player(delta)
		else:
			roam(delta)

	move_and_slide()
	handle_animation()

func chase_player(delta):
	if player != null:
		var dir_to_player = position.direction_to(player.position) * chase_speed * delta
		velocity.x = dir_to_player.x
		dir.x = abs(velocity.x) / velocity.x

func roam(delta):
	if abs(position.x - spawn_position.x) > roam_range:
		dir.x = -dir.x  # Change direction if out of range
	velocity = dir * speed * delta

func _on_timer_timeout():
	$Timer.wait_time = choose([0.5, 0.8])
	if !is_goblin_chase:
		dir = Vector2.RIGHT if randf() > 0.5 else Vector2.LEFT

func handle_animation():
	if is_dying:
		animated_sprite.play("death")
	elif is_attacking:
		animated_sprite.play("attack")
	else:	
		animated_sprite.play("idle")
	
	animated_sprite.flip_h = dir.x > 0

func start_death():
	is_dying = true
	audio_stream_death.play()
	animated_sprite.play("death")
	# Wait for the animation to finish
	await animated_sprite.animation_finished
	queue_free()

func choose(array):
	array.shuffle()
	return array.front()

func _on_hurtbox_area_entered(area):
	if is_dying:
		return
	if area.get_parent().has_method("get_damage_amount") or area.is_in_group("attack"):
		take_damage(area.get_parent().damage_amount)
		apply_knockback(area.global_position)

func take_damage(amount):
	health_amount -= amount
	print("Health amount: ", health_amount)
	if health_amount <= 0:
		start_death()

func apply_knockback(attacker_position: Vector2) -> void:
	var knockback_direction = (global_position - attacker_position).normalized()
	var knockback_force = knockback_direction * KNOCKBACK_STRENGTH
	
	knockback_active = true
	var tween = create_tween()
	tween.tween_method(
		func(progress: float):
			var interpolation = 1.0 - progress
			velocity = knockback_force * interpolation, 0.0, 1.0, KNOCKBACK_DURATION
	)
	tween.tween_callback(func(): knockback_active = false)

func _on_attack_area_2d_body_entered(body:Node2D):
	if body.is_in_group("Player"):
		is_goblin_chase = true
		is_attacking = true

func _on_attack_area_2d_body_exited(body:Node2D):
	if body.is_in_group("Player"):
		is_goblin_chase = false
		is_attacking = false