extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var dir: Vector2
@export var speed = 30
@export var health_amount : int = 3
@export var damage_amount : int = 1

var is_bat_chase: bool
var is_roaming: bool = true
var is_dying: bool = false

var player: CharacterBody2D

func _ready():
	is_bat_chase = true

func _process(delta):
	if is_dying:
		return
	player = GameManager.playerBody
	if player != null:
		move(delta)
	handle_animation()

func move(delta):
	if is_bat_chase:
		if player != null:
			velocity = position.direction_to(player.position) * speed
			dir.x = abs(velocity.x) / velocity.x
	elif !is_bat_chase:
		velocity += dir * speed * delta
	move_and_slide()

func _on_timer_timeout():
	$Timer.wait_time = choose([0.5, 0.8])
	if !is_bat_chase:
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
		print("Health amount: ", health_amount)
		if health_amount <= 0:
			start_death()
