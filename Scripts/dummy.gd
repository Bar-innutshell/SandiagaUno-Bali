extends CharacterBody2D

@export var health_amount : int = 3
@export var damage_amount : int = 1

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var knockback_velocity: Vector2 = Vector2.ZERO
@export var knockback_strength: float = 300.0
@export var knockback_decay: float = 30.0

func _physics_process(delta):
    # Handle knockback
    if knockback_velocity.length() > 0:
        knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
        velocity = knockback_velocity
        move_and_slide()
    
    # Transition to idle state when knockback ends
    if knockback_velocity.length() < 10:
        knockback_velocity = Vector2.ZERO

func _on_hurtbox_area_entered(area : Area2D):
    if area.get_parent().has_method("get_damage_amount"):
        take_damage(area.get_parent().damage_amount)
    elif area.is_in_group("attack"):
        take_damage(area.get_parent().damage_amount)
        apply_knockback(area.get_parent().global_position)

func take_damage(damage: int):
    health_amount -= damage
    print("Health amount: ", health_amount)
    if health_amount <= 0:
        die()
    else:
        animated_sprite.play("hit")

func die():
    animated_sprite.play("death")
    await animated_sprite.animation_finished
    queue_free()

func apply_knockback(attacker_position: Vector2):
    var knockback_direction = (global_position - attacker_position).normalized()
    knockback_velocity = knockback_direction * knockback_strength