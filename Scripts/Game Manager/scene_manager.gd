extends Node

var scene_transition_screen = preload("res://ui/screen_transition/scene_transition_screen.tscn")

var scenes : Dictionary = { 
	"Tutorial": "res://Scenes/Dungeon/1st_tut_dungeon.tscn",
	"Level1": "res://Scenes/Dungeon/base_world_lvl_1.tscn",
	"Level2": "res://Scenes/Dungeon/base_world_lvl_2.tscn",
	"Level3": "res://Scenes/Dungeon/base_world_lvl_3.tscn",
	"Level4": "res://Scenes/Dungeon/base_world_lvl_4.tscn",
	"Level5": "res://Scenes/Dungeon/base_world_lvl_5.tscn",
	"Baseworld": "res://Scenes/Dungeon/base_world.tscn",
	"DungeonApi": "res://Scenes/Dungeon/dungeon_api.tscn",
	"DungeonEs": "res://Scenes/Dungeon/Dungeon_Tomas_Slebew.tscn",
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
