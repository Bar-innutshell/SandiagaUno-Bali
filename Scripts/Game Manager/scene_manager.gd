extends Node

var scene_transition_screen = preload("res://ui/screen_transition/scene_transition_screen.tscn")

var scenes : Dictionary = { 
	"Level1": "res://Scenes/Dungeon/base_world_lvl_1.tscn",
	"Baseworld": "res://Scenes/Dungeon/base_world.tscn",
	"Dungeon5-1": "res://Scenes/Dungeon/dungeon_corrupt.tscn",
	"Dungeon5-2": "res://Scenes/Dungeon/dungeon_corrupt_2.tscn"
}



func transition_to_scene(level : String):
	var scene_path : String = scenes.get(level)
	
	if scene_path != null:
		var scene_transition_screen_instance = scene_transition_screen.instantiate()
		get_tree().get_root().add_child(scene_transition_screen_instance)
		await get_tree().create_timer(2.5).timeout
		get_tree().change_scene_to_file(scene_path)
		scene_transition_screen_instance.queue_free()
