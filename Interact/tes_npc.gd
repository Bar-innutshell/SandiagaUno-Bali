extends Node2D

@export var next_scene :String

@onready var interaction_area: InteractionArea = $InteractionArea

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	SceneManager.transition_to_scene(next_scene)