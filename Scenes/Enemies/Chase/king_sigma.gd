extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_stream_player_death: AudioStreamPlayer = $AudioStreamPlayer_death
@onready var audio_stream_player_jump: AudioStreamPlayer = $AudioStreamPlayer_jump
@onready var stun_timer: Timer = $StunTimer

@export var speed = 70
@export var key_id : String
var current_delta: float = 0.0
var dir: Vector2
var direction: int
const gravity = 900

var is_sigma_chase: bool = true
var is_roaming: bool = true
var is_dying: bool = false
var is_stunned: bool = false
var is_attacking: bool = false

@export var health_amount : int = 500
@export var damage_amount : int = 1

var player: CharacterBody2D

var knockback_dir: Vector2
var knockback = false
var player_dir: int
var knockback_velocity: Vector2 = Vector2.ZERO  # Variabel knockback
@export var knockback_strength: float = 2500.0  # Besar knockback
@export var knockback_decay: float = 38.0  # Kecepatan peluruhan knockback

@export var JUMP_VELOCITY : float = -800
@export var max_vertical_speed : int = 300

func _ready():
	is_sigma_chase = true

func _physics_process(delta):
	current_delta = delta
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0
	# Handle knockback
	if is_dying or is_stunned:
		return

	if knockback:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
		velocity += knockback_velocity
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
	if health_amount > 0:
		if !is_sigma_chase:
			velocity += dir * speed * delta
		elif is_sigma_chase:
			if player != null:
				var dir_to_player = position.direction_to(player.position) * speed
				velocity.x = dir_to_player.x
				dir.x = abs(velocity.x) / velocity.x
				
				# Jump and play attack animation
				if is_on_floor():
					velocity.y = JUMP_VELOCITY
					audio_stream_player_jump.play()
				velocity.y = clamp(velocity.y, -max_vertical_speed, max_vertical_speed)
				is_attacking = true
	else:
		velocity.x = 0
	
func _on_timer_timeout():
	$Timer.wait_time = choose([1.5, 2.0, 2.5])
	if !is_sigma_chase:
		dir = choose([Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT])
		velocity.x = 0

func handle_animation():
	if is_dying:
		animated_sprite.play("death")
	elif health_amount <= 0:
		start_death()
	elif is_attacking:
		animated_sprite.play("attack")
		is_attacking = false
	else:	
		animated_sprite.play("idle")
		if dir.x == -1:
			animated_sprite.flip_h = false
		elif dir.x == 1:
			animated_sprite.flip_h = true

func start_death():
	is_dying = true
	HitStopManager.hit_stop_long()
	animated_sprite.play("death")
	audio_stream_player_death.play()
	# Wait for the animation to finish
	await animated_sprite.animation_finished
	queue_free()

func choose(array):
	array.shuffle()
	return array.front()

func _on_hurtbox_area_entered(area):
	if is_dying:
		return

	# Check if the player has the required key
	var has_key = InventoryManager.has_inventory_item(key_id)
	if not has_key:
		print("Player doesn't have the required key. Enemy is invulnerable.")
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
		knockback_dir = Vector2(player_dir, 0)
		apply_knockback(current_delta)
		print("Health amount: ", health_amount)
		if health_amount <= 0:
			start_death()

func apply_knockback(delta: float):
	knockback = true
	knockback_dir = knockback_dir.normalized()  # Normalize the knockback direction
	knockback_velocity = knockback_dir * knockback_strength * delta  # Apply consistent knockback force

func _on_stun_timer_timeout():
	is_stunned = false

func _on_hurtbox_body_entered(body):
	if body.is_in_group("Player"):
		var has_key = InventoryManager.has_inventory_item(key_id)
		if not has_key:
			print("Player doesn't have the required key. Enemy is invulnerable.")
			return