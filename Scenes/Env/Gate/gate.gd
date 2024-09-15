extends Node2D

@onready var collision_shape_2d = $CollisionShape2D

@export var next_scene :String

var door_open : bool

@onready var interaction_area: InteractionArea = $InteractionArea

func _ready():
    if interaction_area:
        interaction_area.interact = Callable(self, "_on_interact")
    else:
        print("Error: InteractionArea node not found")

func _on_interact():
    SceneManager.transition_to_scene(next_scene)

func _on_activate_door_area_2d_body_entered(body):
    if body.is_in_group("Player") and CollectibleManager.total_award_amount >= 5:
        if not door_open:
            door_open = true
            collision_shape_2d.set_deferred("disabled", true)