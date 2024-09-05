extends CharacterBody2D

var enemy_death_effect = preload("res://Scenes/Enemies/enemy_death_effect.tscn")

const SPEED = 80
var direction = 1
var canSwitch : bool = true
var health_amount : int = 3
@export var damage_amount : int = 1

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D

#buat bolak-balik tanpa perlu wall
func _physics_process(delta: float) -> void:
	if !$RayCast2D.is_colliding() and canSwitch:
		direction *= -1
		canSwitch = false
	else:
		canSwitch = true
	
	if direction < 0:
		velocity.x = SPEED * -1.0 * delta
		$RayCast2D.target_position = Vector2(-278, 250)
	else:
		velocity.x = SPEED * 1.0 * delta
		$RayCast2D.target_position = Vector2(278, 250)
	
	if direction > 0:
		animated_sprite.flip_h = true
	elif direction < 0:
		animated_sprite.flip_h = false
		
	if ray_cast_right.is_colliding():
		direction = -1
	if ray_cast_left.is_colliding():
		direction = 1
	position.x += direction * SPEED * delta
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
		print("Health amount: ", health_amount)
		if health_amount <= 0:
			var enemy_death_effect_instance = enemy_death_effect.instantiate() as Node2D
			enemy_death_effect_instance.global_position = global_position
			get_parent().add_child(enemy_death_effect_instance)
			queue_free()
