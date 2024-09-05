extends CharacterBody2D

var enemy_death_effect = preload("res://Scenes/Enemies/enemy_death_effect.tscn")

var dir: Vector2
@export var speed = 30
@export var health_amount : int = 3
@export var damage_amount : int = 1

var is_bat_chase: bool
var is_roaming: bool = true

var player: CharacterBody2D

func _ready():
	is_bat_chase = true

func _process(delta):
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
			var enemy_death_effect_instance = enemy_death_effect.instantiate() as Node2D
			enemy_death_effect_instance.global_position = global_position
			get_parent().add_child(enemy_death_effect_instance)
			queue_free()
