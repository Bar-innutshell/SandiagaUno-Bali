extends StaticBody2D

@onready var object: AnimatedSprite2D = $Object
@onready var breakable_collision: CollisionShape2D = $BreakableCollision

var health_amount : int = 1
var is_dying: bool = false

func _ready():
    # Connect the animation_finished signal to the _on_animation_finished function
    object.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _process(delta):
    if is_dying:
        return
    handle_animation()

func handle_animation():
    if health_amount <= 0 and not is_dying:
        start_death()

func start_death():
    is_dying = true
    object.play("Broken")

func _on_animation_finished():
    # Disable the collision shape
    breakable_collision.disabled = true

func _on_hurtbox_area_entered(area: Area2D):
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