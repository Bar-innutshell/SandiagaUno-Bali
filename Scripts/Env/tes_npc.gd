extends Node2D


@onready var interaction_area: InteractionArea = $InteractionArea

const lines: Array[String] = [
	"hey there"
]

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	print("Hayoyo")
