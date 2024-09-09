extends CharacterBody2D

var enemy_death_effect = preload("res://Scenes/Enemies/enemy_death_effect.tscn")
@export var health_amount : int = 3
@export var damage_amount : int = 1
@export var key_id : String

var current_delta: float = 0.0

var knockback_dir
var knockback = false
var player_dir
var direction = 1
var knockback_velocity: Vector2 = Vector2.ZERO  # Variabel knockback
@export var knockback_strength: float = 4000.0  # Besar knockback
@export var knockback_decay: float = 10.0  # Kecepatan peluruhan knockback

func _physics_process(delta):
	current_delta = delta
	# Handle knockback
	if knockback:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
		velocity += knockback_velocity
		if knockback_velocity.length() < 10:
			knockback = false
			knockback_velocity = Vector2.ZERO

func _on_hurtbox_area_entered(area):
	print("Bullet area entered")
	
	# Check if the player has the required key
	var has_key = InventoryManager.has_inventory_item(key_id)
	if not has_key:
		print("Player doesn't have the required key. Enemy is invulnerable.")
		return
	
	if area.has_method("get_damage_amount"):
		var damage = area.get_damage_amount()
		take_damage(damage)
	elif area.get_parent().has_method("get_damage_amount"):
		var node = area.get_parent()
		var damage = node.get_damage_amount()
		take_damage(damage)
	elif area.is_in_group("attack"):
		var damage = area.get_damage_amount()
		var node = area.get_parent() as Node
		take_damage(damage)
		player_dir = node.dir
		knockback_dir = player_dir
		apply_knockback(current_delta)

func take_damage(damage):
	health_amount -= damage
	print("Health amount: ", health_amount)
	if health_amount <= 0:
		var enemy_death_effect_instance = enemy_death_effect.instantiate() as Node2D
		enemy_death_effect_instance.global_position = global_position
		get_parent().add_child(enemy_death_effect_instance)
		HitStopManager.hit_stop_long()
		queue_free()

func _on_hurtbox_body_entered(body):
	if body.is_in_group("Player"):
		var has_key = InventoryManager.has_inventory_item(key_id)
		if not has_key:
			print("Player doesn't have the required key. Enemy is invulnerable.")
			return
		# Add any player collision logic here if needed

func apply_knockback(delta: float):
	knockback = true
	if direction == player_dir:
		knockback_dir *= -1
	knockback_velocity.y = -25  # Knockback vertikal jika perlu
	knockback_velocity.x = knockback_strength * knockback_dir * delta # Tentukan arah knockback
