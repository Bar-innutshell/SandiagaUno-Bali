extends AnimatedSprite2D

var bullet_impact_effect = preload("res://Scenes/Weapon/bullet_impact.tscn")

@export var speed : int = 300
var direction : int = 1  # Default direction is right
@export var damage_amount : int = 10

func _ready():
	update_sprite_direction()

func set_direction(new_direction: int):
	direction = new_direction
	update_sprite_direction()

func update_sprite_direction():
	# Flip the sprite when moving left
	flip_h = direction == -1

func _physics_process(delta):
	move_local_x(direction * speed * delta)
	
func _on_timer_timeout():
	queue_free()

func _on_hitbox_area_entered(area):
	print("Bullet area entered")
	bullet_impact()

func _on_hitbox_body_entered(body):
	print("Bullet body entered")
	bullet_impact()

func get_damage_amount() -> int:
	return damage_amount + GameManager.damage_upgrade

func bullet_impact():
	var bullet_impact_instance = bullet_impact_effect.instantiate() as Node2D
	bullet_impact_instance.global_position = global_position
	get_parent().add_child(bullet_impact_instance)
	queue_free()