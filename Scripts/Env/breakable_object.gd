extends StaticBody2D
class_name BreakableObject

@export var tilemap : TileMapLayer

func break_object():
	tilemap.set_cellv(0, tilemap.local_to_map(global_position), -1)
	queue_free()
