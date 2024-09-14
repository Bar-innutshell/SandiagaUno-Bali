extends Node

var main_menu_screen = preload("res://ui/menu/main_menu_screen.tscn")
var pause_menu_screen = preload("res://ui/menu/pause_menu_screen.tscn")

#checkpoint
var current_checkpoint : Checkpoint
var player : Player1
var checkpoint_touched : bool = false
var current_level : String = ""

#player upgrade
var damage_upgrade : int = 0
var health_upgrade : int = 0

#wave
var current_wave : int
var moving_to_next_wave : bool

#enemiesChasing
var playerBody: CharacterBody2D
var playerWeaponEquip: bool

func _ready():
	RenderingServer.set_default_clear_color(Color(0.44,0.12,0.53,1.00))
	
	SettingsManager.load_settings()

func start_game():
	if get_tree().paused:
		continue_game()
		return
	
	if current_checkpoint and current_checkpoint.scene_to_load:
		transition_to_scene(current_checkpoint.scene_to_load)

func exit_game():
	get_tree().quit()

func upgrade_player():
	damage_upgrade += 1
	health_upgrade += 1

func pause_game():
	get_tree().paused = true
	
	var pause_menu_screen_instance = pause_menu_screen.instantiate()
	get_tree().get_root().add_child(pause_menu_screen_instance)

func continue_game():
	get_tree().paused = false

func main_menu():
	var main_menu_screen_instance = main_menu_screen.instantiate()
	get_tree().get_root().add_child(main_menu_screen_instance)

func respawn_player():
	if current_checkpoint != null:
		player.position = current_checkpoint.global_position
	else:
		reload_current_scene()

func reload_current_scene():
	get_tree().reload_current_scene()

func reset_checkpoint_status():
	checkpoint_touched = false

func check_checkpoint_status():
	if not checkpoint_touched:
		reload_current_scene()

func transition_to_scene(level: String):
	current_level = level
	reset_checkpoint_status()
	SceneManager.transition_to_scene(level)