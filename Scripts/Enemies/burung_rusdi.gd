extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var current_delta: float = 0.0
var dir: Vector2
@export var speed = 30
@export var health_amount : int = 3
@export var damage_amount : int = 1

var is_bird_chase: bool
var is_roaming: bool = true
var is_dying: bool = false

var player: CharacterBody2D

var knockback_dir
var knockback = false
var player_dir
var direction = 1
var knockback_velocity: Vector2 = Vector2.ZERO  # Variabel knockback
@export var knockback_strength: float = 4000.0  # Besar knockback
@export var knockback_decay: float = 50.0  # Kecepatan peluruhan knockback

func _ready():
	is_bird_chase = true

func _physics_process(delta):
	current_delta = delta
	# Handle knockback
	if is_dying:
		return

	if knockback:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
		velocity = knockback_velocity
		if knockback_velocity.length() < 10:
			knockback = false
			knockback_velocity = Vector2.ZERO
	else:
		player = GameManager.playerBody
		if player != null:
			move(delta)
	
	move_and_slide()
	handle_animation()

func move(delta):
	if is_bird_chase:
		if player != null:
			velocity = position.direction_to(player.position) * speed
			dir.x = abs(velocity.x) / velocity.x
	elif !is_bird_chase:
		velocity += dir * speed * delta

func _on_timer_timeout():
	$Timer.wait_time = choose([0.5, 0.8])
	if !is_bird_chase:
		dir = choose([Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT])

func handle_animation():
	if is_dying:
		animated_sprite.play("death")
	elif health_amount <= 0:
		start_death()
	else:
		animated_sprite.play("fly")
		if dir.x == -1:
			animated_sprite.flip_h = true
		elif dir.x == 1:
			animated_sprite.flip_h = false

func start_death():
	is_dying = true
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
	if area.get_parent().has_method("get_damage_amount"):
		print("Bullet area entered")
		var node = area.get_parent() as Node
		health_amount -= node.damage_amount
		print("Health amount: ", health_amount)
		if health_amount <= 0:
			start_death()
	if area.is_in_group("attack"):
		var node = area.get_parent() as Node
		health_amount -= node.damage_amount
		player_dir = node.dir
		knockback_dir = player_dir
		apply_knockback(current_delta)
		print("Health amount: ", health_amount)
		if health_amount <= 0:
			start_death()

func apply_knockback(delta: float):
	knockback = true
	if direction == player_dir:
		knockback_dir *= 1
	knockback_velocity.x = knockback_strength * knockback_dir * delta # Tentukan arah knockback
