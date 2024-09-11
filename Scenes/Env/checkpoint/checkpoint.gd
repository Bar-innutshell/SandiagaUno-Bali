extends Node2D

class_name Checkpoint

@export var spawnpoint = false

var activated = false

func _ready():
	if spawnpoint:
		activate()

func activate():
	GameManager.current_checkpoint = self
	activated = true

func _on_area_2d_area_entered(area:Area2D):
	if area.get_parent() is Player1 and not activated:
		activate()