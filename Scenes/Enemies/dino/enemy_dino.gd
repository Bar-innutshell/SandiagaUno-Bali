extends CharacterBody2D
var enemy_death_effect = preload("res://Scenes/Enemies/enemy_death_effect.tscn")
@export var health_amount : int = 3
@export var damage_amount : int = 1

func _on_hurtbox_area_entered(area):
	print("Bullet area entered")
	if area.has_method("get_damage_amount"):
		var damage = area.get_damage_amount()
		health_amount -= damage
		print("Health amount: ", health_amount)
		if health_amount <= 0:
			var enemy_death_effect_instance = enemy_death_effect.instantiate() as Node2D
			enemy_death_effect_instance.global_position = global_position
			get_parent().add_child(enemy_death_effect_instance)
			queue_free()
	elif area.get_parent().has_method("get_damage_amount"):
		var node = area.get_parent()
		var damage = node.get_damage_amount()
		health_amount -= damage
		print("Health amount: ", health_amount)
		if health_amount <= 0:
			var enemy_death_effect_instance = enemy_death_effect.instantiate() as Node2D
			enemy_death_effect_instance.global_position = global_position
			get_parent().add_child(enemy_death_effect_instance)
			queue_free()
