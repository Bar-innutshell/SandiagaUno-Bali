extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea2D

var current_delta: float = 0.0
var dir: Vector2
@export var speed = 30
@export var chase_speed = 60  # Separate speed for chasing
@export var health_amount : int = 3
@export var damage_amount : int = 1

var is_chasing: bool = false
var is_attacking: bool = false
var is_dying: bool = false

var player: CharacterBody2D

var knockback_dir
var knockback = false
var player_dir
var direction = 1
var knockback_velocity: Vector2 = Vector2.ZERO
@export var knockback_strength: float = 4000.0
@export var knockback_decay: float = 50.0

func _ready():
	$Timer.start()

func _physics_process(delta):
	current_delta = delta
	if is_dying:
		return

	if knockback:
		handle_knockback(delta)
	else:
		player = GameManager.playerBody
		if player != null and is_chasing:
			chase_player(delta)
		else:
			roam(delta)
	
	move_and_slide()
	handle_animation()

func handle_knockback(delta):
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
	velocity = knockback_velocity
	if knockback_velocity.length() < 10:
		knockback = false
		knockback_velocity = Vector2.ZERO

func chase_player(delta):
	velocity = position.direction_to(player.position) * chase_speed
	dir.x = sign(velocity.x)
	dir.y = sign(velocity.y)

func roam(delta):
	velocity = dir * speed

func _on_timer_timeout():
	$Timer.wait_time = choose([0.5, 0.8])
	if !is_chasing:
		dir = choose([Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT])

func handle_animation():
	if is_dying:
		animated_sprite.play("death")
	elif is_attacking:
		animated_sprite.play("attack")
	elif is_on_floor():
		animated_sprite.play("idle")
	else:
		animated_sprite.play("fly")
	
	animated_sprite.flip_h = dir.x < 0

func start_death():
	is_dying = true
	animated_sprite.play("death")
	await animated_sprite.animation_finished
	queue_free()

func choose(array):
	array.shuffle()
	return array.front()

func _on_hurtbox_area_entered(area):
	if is_dying:
		return
	if area.get_parent().has_method("get_damage_amount"):
		take_damage(area.get_parent().damage_amount)
	if area.is_in_group("attack"):
		take_damage(area.get_parent().damage_amount)
		player_dir = area.get_parent().dir
		knockback_dir = player_dir
		apply_knockback(current_delta)

func take_damage(amount):
	health_amount -= amount
	print("Health amount: ", health_amount)
	if health_amount <= 0:
		start_death()

func apply_knockback(delta: float):
	knockback = true
	if direction == player_dir:
		knockback_dir *= 1
	knockback_velocity = Vector2(knockback_strength * knockback_dir * delta, -knockback_strength * 0.5 * delta)

func _on_attack_area_2d_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		is_chasing = true
		is_attacking = true

func _on_attack_area_2d_body_exited(body: Node2D):
	if body.is_in_group("Player"):
		is_chasing = false
		is_attacking = false