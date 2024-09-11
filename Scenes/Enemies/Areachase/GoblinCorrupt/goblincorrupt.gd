extends CharacterBody2D
var enemy_death_effect = preload("res://Scenes/Enemies/enemy_death_effect.tscn")
@export var health_amount : int = 400
@export var damage_amount : int = 1

var current_delta: float = 0.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var knockback_dir = 1
var knockback = false
var player_dir = 1
var direction = 1
var knockback_velocity: Vector2 = Vector2.ZERO  # Variabel knockback
@export var knockback_strength: float = 3000.0  # Besar knockback
@export var knockback_decay: float = 20.0  # Kecepatan peluruhan knockback

func _physics_process(delta):
	current_delta = delta
	# Handle knockback
	if knockback:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
		velocity += knockback_velocity
		if knockback_velocity.length() < 10:
			knockback = false
			knockback_velocity = Vector2.ZERO
	move_and_slide()

func _on_hurtbox_area_entered(area : Area2D):
	if area.get_parent().has_method("get_damage_amount"):
		print("Bullet area entered")
		var node = area.get_parent() as Node
		health_amount -= node.damage_amount
		print("Health amount: ", health_amount)
		if health_amount <= 0:
			var enemy_death_effect_instance = enemy_death_effect.instantiate() as Node2D
			enemy_death_effect_instance.global_position = global_position
			get_parent().add_child(enemy_death_effect_instance)
			queue_free()
	if area.is_in_group("attack"):
		var node = area.get_parent() as Node
		health_amount -= node.damage_amount
		player_dir = node.dir
		knockback_dir = player_dir
		apply_knockback(current_delta)
		print("Health amount: ", health_amount)
		if health_amount <= 0:
			var enemy_death_effect_instance = enemy_death_effect.instantiate() as Node2D
			enemy_death_effect_instance.global_position = global_position
			get_parent().add_child(enemy_death_effect_instance)
			queue_free()

func apply_knockback(delta: float):
	knockback = true
	if direction == player_dir:
		knockback_dir *= 1
	knockback_velocity.x = knockback_strength * knockback_dir * delta # Tentukan arah knockback