extends CharacterBody2D

class_name GoblinEnemy

@export var speed = 30
var dir: Vector2
var direction: int
const gravity = 900
var knockback_force = -50
var is_roaming: bool = true

@export var health_amount : int = 3
@export var damage_amount : int = 1
var is_goblin_chase: bool = true

var player: CharacterBody2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	is_goblin_chase = true

func _process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0
	
	player = GameManager.playerBody
	if player != null:
		move(delta)
	handle_animation()

func move(delta):
	if health_amount > 0:
		if !is_goblin_chase:
			velocity += dir * speed * delta
		elif is_goblin_chase:
			if player != null:
				var dir_to_player = position.direction_to(player.position) * speed
				velocity.x = dir_to_player.x
				dir.x = abs(velocity.x) / velocity.x
	elif health_amount <= 0:
		velocity.x = 0
		if !animated_sprite.is_playing() or animated_sprite.animation != "die":
			animated_sprite.play("die")
	move_and_slide()

func _on_timer_timeout():
	$Timer.wait_time = choose([1.5, 2.0, 2.5])
	if !is_goblin_chase:
		dir = choose([Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT])
		velocity.x = 0

func handle_animation():
	animated_sprite.play("idle")
	if dir.x == -1:
		animated_sprite.flip_h = false
	elif dir.x == 1:
		animated_sprite.flip_h = true

func choose(array):
	array.shuffle()
	return array.front()

func _on_hurtbox_area_entered(area):
	print("Bullet area entered")
	if area.get_parent().has_method("get_damage_amount"):
		var node = area.get_parent() as Node
		health_amount -= node.damage_amount
		var knockback_dir = position.direction_to(player.global_position) * knockback_force
		velocity.x = knockback_dir.x
		print("Health amount: ", health_amount)
		if health_amount <= 0:
			queue_free()
