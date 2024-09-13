extends Node

var current_chapter = 1
var max_chapter = 3  

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ui: CanvasLayer = $UI

var chapters = ["Chapter_1", "Chapter_1.1", "Chapter_1.2"]
var dungeon = ["test"]

var current_cutscene_list = chapters

func _ready():
	ui.visible = false
	
func play_current_chapter():
	ui.visible = true
	var chapter_name = current_cutscene_list[current_chapter - 1]
	
	if animation_player.has_animation(chapter_name):
		animation_player.play(chapter_name)
		pause_other_nodes(true)
	else:
		print("Animasi tidak ditemukan: " + chapter_name)

func _process(delta):
	if Input.is_action_just_pressed("dialogue"): 
		go_to_next_chapter()

func go_to_next_chapter():
	if current_chapter < max_chapter:
		current_chapter += 1
		play_current_chapter()
	else:
		print("All chapters completed")
		animation_player.stop()
		ui.visible = false 
		continue_game()

func set_cutscene_type(type: String):
	current_chapter = 1  
	if type == "dungeon":
		current_cutscene_list = dungeon
		max_chapter = dungeon.size()
	else:
		current_cutscene_list = chapters
		max_chapter = chapters.size()
		
func continue_game():
	pause_other_nodes(false)

func pause_other_nodes(pause: bool):
	for node in get_tree().get_nodes_in_group("pause_group"):
		if node != animation_player and node != ui:
			node.set_process(!pause)
			node.set_physics_process(!pause)