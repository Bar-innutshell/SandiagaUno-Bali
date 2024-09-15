extends Node

var current_chapter = 1
var max_chapter = 20  

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ui: CanvasLayer = $UI

var chapters = ["Chapter_1", "Chapter_1.1", "Chapter_1.2"]
var intro_in = ["MC/intro","MC/intro_2","MC/intro_3"]
var intro_out = ["MC/intro_4","OwO/intro","MC/intro_5","OwO/intro_2","OwO/intro_3","OwO/intro_4","MC/intro_6","OwO/intro_5","MC/intro_7","OwO/intro_6","MC/intro_8","MC/intro_9","MC/intro_10","OwO/intro_7"]
var intro_tree = ["OwO/intro_8","OwO/intro_9","OwO/intro_10","OwO/intro_11","MC/intro_11","OwO/intro_12"]

var chapter1_bfr_dungeon = ["First_Chapter/chapter1_owo", "First_Chapter/chapter1_owo_2", "First_Chapter/chapter1_owo_3", "First_Chapter/chapter_1_mc", "First_Chapter/chapter1_owo_4"]
var chapter1_aftr_dungeon = ["First_Chapter/chapter_1_mc_2", "First_Chapter/chapter1_owo_5","First_Chapter/chapter_1_mc_3", "First_Chapter/chapter1_owo_6", "First_Chapter/chapter1_owo_7"]
var chapter1_arrived_pk = ["First_Chapter/chapter_1_mc_4", "First_Chapter/chapter1_owo_8", "First_Chapter/chapter_1_mc_5"]

var chapter2 = ["OwO/chapter2", "OwO/chapter2_2", "MC/chapter2", "OwO/chapter2_3", "MC/chapter2_2"]
var chapter2_menulusuri_dungeon = ["OwO/chapter2_4","MC/chapter2_3","OwO/chapter2_5"]
var chapter2_end_dungeon = ["MC/chapter2_4","OwO/chapter2_6"]
var chapter2_got_benih = ["OwO/chapter2_7", "MC/chapter2_5"]


var chapter3_outside_dungeon = ["Third_Chapter/chapter3_owo","Third_Chapter/chapter3_mc", "Third_Chapter/chapter3_owo_2"]
var chapter3_inside_dungeon = ["Third_Chapter/chapter3_mc_2","Third_Chapter/chapter3_owo_3", "Third_Chapter/chapter3_mc_3", "Third_Chapter/chapter3_owo_4", "Third_Chapter/chapter3_mc_4", "Third_Chapter/chapter3_owo_5"]

var chapter4 = ["Fourth_Chapter/chapter_4_mc","Fourth_Chapter/chapter4_owo", "Fourth_Chapter/chapter4_owo_2", "Fourth_Chapter/chapter4_owo_3", "Fourth_Chapter/chapter4_owo_4"]


var current_cutscene_list = chapters

func _ready():
	ui.visible = false
	
func play_current_chapter():
	ui.visible = true
	var chapter_name = current_cutscene_list[current_chapter - 1]
	
	# Cek apakah animasi ada di dalam AnimationPlayer
	if animation_player.has_animation(chapter_name):
		animation_player.play(chapter_name)
		# Pause manual node lain kecuali AnimationPlayer dan UI
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
	if type == "intro_in":
		current_cutscene_list = intro_in
		max_chapter = intro_in.size()
	elif type == "intro_out":
		current_cutscene_list = intro_out
		max_chapter = intro_out.size()
	elif type == "intro_tree":
		current_cutscene_list = intro_tree
		max_chapter = intro_tree.size()
	elif type == "chapter1_bfr_dungeon":
		current_cutscene_list = chapter1_bfr_dungeon
		max_chapter = chapter1_bfr_dungeon.size()
	elif type == "chapter1_aftr_dungeon":
		current_cutscene_list = chapter1_aftr_dungeon
		max_chapter = chapter1_aftr_dungeon.size()
	elif type == "chapter1_arrived_pk":
		current_cutscene_list = chapter1_arrived_pk
		max_chapter = chapter1_arrived_pk.size()
	elif type == "chapter2":
		current_cutscene_list = chapter2
		max_chapter = chapter2.size()
	elif type == "chapter2_menulusuri_dungeon":
		current_cutscene_list = chapter2_menulusuri_dungeon
		max_chapter = chapter2_menulusuri_dungeon.size()
	elif type == "chapter2_end_dungeon":
		current_cutscene_list = chapter2_end_dungeon
		max_chapter = chapter2_end_dungeon.size()
	elif type == "chapter2_got_benih":
		current_cutscene_list = chapter2_got_benih
		max_chapter = chapter2_got_benih.size()
	elif type == "chapter3_outside_dungeon":
		current_cutscene_list = chapter3_outside_dungeon
		max_chapter = chapter3_outside_dungeon.size()
	elif type == "chapter3_inside_dungeon":
		current_cutscene_list = chapter3_inside_dungeon
		max_chapter = chapter3_inside_dungeon.size()
	elif type == "chapter4":
		current_cutscene_list = chapter4
		max_chapter = chapter4.size()
	else:
		current_cutscene_list = chapters
		max_chapter = chapters.size()
		
func continue_game():
	# Kembalikan semua node ke proses normal
	pause_other_nodes(false)

# Fungsi untuk mem-pause semua node kecuali animasi dan UI
func pause_other_nodes(pause: bool):
	# Dapatkan semua node dalam scene tree
	for node in get_tree().get_nodes_in_group("pause_group"):
		if node != animation_player and node != ui:
			node.set_process(!pause)
			node.set_physics_process(!pause)
