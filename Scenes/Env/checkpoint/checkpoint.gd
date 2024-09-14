extends Node2D

class_name Checkpoint

@export var spawnpoint = false
@export var scene_to_load: String

var activated = false

func _ready():
	if spawnpoint:
		activate()

func activate():
	GameManager.current_checkpoint = self
	GameManager.checkpoint_touched = true
	GameManager.current_level = scene_to_load
	activated = true
	$Sprite2D.play("play")

func _on_area_2d_area_entered(area:Area2D):
	if area.get_parent() is Player1 and not activated:
		activate()