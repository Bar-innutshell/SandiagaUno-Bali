# BreakableObject.gd
extends Area2D
class_name BreakableObject

@export var tilemap : TileMap
@export var layer : int = 0

func break_object():
	var local_pos = tilemap.local_to_map(global_position)
	tilemap.erase_cell(layer, local_pos)
	queue_free()
	
