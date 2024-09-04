extends CharacterBody2D

var enemy_death_effect = preload("res://Scenes/Enemies/enemy_death_effect.tscn")
@export var health_amount : int = 3
@export var damage_amount : int = 1
@export var key_id : String
const BULLETS = preload("res://Scenes/Weapon/bullets.tscn")

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

func take_damage(damage):
	health_amount -= damage
	print("Health amount: ", health_amount)
	if health_amount <= 0:
		var enemy_death_effect_instance = enemy_death_effect.instantiate() as Node2D
		enemy_death_effect_instance.global_position = global_position
		get_parent().add_child(enemy_death_effect_instance)
		queue_free()

func _on_hurtbox_body_entered(body):
	if body.is_in_group("Player"):
		var has_key = InventoryManager.has_inventory_item(key_id)
		if not has_key:
			print("Player doesn't have the required key. Enemy is invulnerable.")
			return
		# Add any player collision logic here if needed
