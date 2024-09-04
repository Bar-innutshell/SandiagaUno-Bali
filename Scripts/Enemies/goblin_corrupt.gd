extends CharacterBody2D

class_name GoblinEnemy

@export var speed = 30
var dir: Vector2
const gravity = 900
var knockback_force = 200
var is_roaming: bool = true

@export var health_amount : int = 3
@export var damage_amount : int = 1
var is_goblin_chase: bool

var player: CharacterBody2D

func _ready():
	is_goblin_chase = true

func _process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0
	move(delta)
	handle_animation()

func move(delta):
	if is_goblin_chase:
		player = GameManager.playerBody
		velocity = position.direction_to(player.position) * speed
		dir.x = abs(velocity.x) / velocity.x
	elif !is_goblin_chase:
		velocity += dir * speed * delta
	move_and_slide()

func _on_timer_timeout():
	$Timer.wait_time = choose([1.5, 2.0, 2.5])
	if !is_goblin_chase:
		dir = choose([Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT])
		velocity.x = 0

func handle_animation():
	var animated_sprite = $AnimatedSprite2D
	animated_sprite.play("fly")
	if dir.x == -1:
		animated_sprite.flip_h = true
	elif dir.x == 1:
		animated_sprite.flip_h = false

func choose(array):
	array.shuffle()
	return array.front()

func _on_hurtbox_area_entered(area):
	print("Bullet area entered")
	if area.get_parent().has_method("get_damage_amount"):
		var node = area.get_parent() as Node
		health_amount -= node.damage_amount
		print("Health amount: ", health_amount)
		if health_amount <= 0:
			get_parent().add_child()
			queue_free()
