extends Node2D

extends Node2D

var current_wave : int
@export var crab_scene : PackedScene
@export var dino_scene : PackedScene

var starting_nodes : int
var current_nodes : int
var wave_spawn_ended

func _ready():
	current_wave = 0
	GameManager.current_wave = current_wave
	starting_nodes = get_child_count()
	current_nodes = get_child_count()
	position_to_next_wave()

func position_to_next_wave():
	if current_nodes == starting_nodes:
		if current_wave != 0:
			GameManager.moving_to_next_wave = true
		wave_spawn_ended = false
		current_wave += 1 
		GameManager.current_wave = current_wave
		await get_tree().create_timer(0.5).timeout
		prepare_spawn("mr_crab", 4.0, 4.0) #type, multiplier, spawns
		prepare_spawn("enemy_dino", 1.5, 2.0) #type, multiplier, spawns
		print(current_wave)

func prepare_spawn(type, multiplier, mob_spawns):
	var mob_amount = float(current_wave) * multiplier
	var mob_wait_time: float = 2.0
	print("mob_amount:", mob_amount)
	var mob_spawn_rounds = mob_amount/mob_spawns
	spawn_type(type, mob_spawn_rounds, mob_wait_time)
	
func spawn_type(type, mob_spawn_rounds, mob_wait_time):
	if type == "mr_crab":
		var spawn_1 = $CrabSpawn/spawn1
		var spawn_2 = $CrabSpawn/spawn2
		var spawn_3 = $CrabSpawn/spawn3
		var spawn_4 = $CrabSpawn/spawn4
		var spawn_5 = $CrabSpawn/spawn5
		var spawn_6 = $CrabSpawn/spawn6
		if mob_spawn_rounds >= 1:
			for i in mob_spawn_rounds:
				var crab1 = crab_scene.instantiate()
				crab1.global_position = spawn_1.global_position
				var crab2 = crab_scene.instantiate()
				crab2.global_position = spawn_2.global_position
				var crab3 = crab_scene.instantiate()
				crab3.global_position = spawn_3.global_position
				var crab4 = crab_scene.instantiate()
				crab4.global_position = spawn_4.global_position
				var crab5 = crab_scene.instantiate()
				crab5.global_position = spawn_5.global_position
				var crab6 = crab_scene.instantiate()
				crab6.global_position = spawn_6.global_position
				add_child(crab1)
				add_child(crab2)
				add_child(crab3)
				add_child(crab4)
				add_child(crab5)
				add_child(crab6)
				mob_spawn_rounds -= 1
				await get_tree().create_timer(mob_wait_time).timeout
	elif type == "enemy_dino":
		var dino_spawn_1 = $DinoSpawn/DinoSpawn1
		var dino_spawn_2 = $DinoSpawn/DinoSpawn2
		var dino_spawn_3 = $DinoSpawn/DinoSpawn3
		if mob_spawn_rounds >= 1:
			for i in mob_spawn_rounds:
				var dino1 = dino_scene.instantiate()
				dino1.global_position = dino_spawn_1.global_position
				var dino2 = dino_scene.instantiate()
				dino2.global_position = dino_spawn_2.global_position
				var dino3 = dino_scene.instantiate()
				dino3.global_position = dino_spawn_3.global_position
				add_child(dino1)
				add_child(dino2)
				add_child(dino3)
				mob_spawn_rounds -= 1
				await get_tree().create_timer(mob_wait_time).timeout
	wave_spawn_ended = true

func _process(delta):
	current_nodes = get_child_count()
	
	if wave_spawn_ended:
		position_to_next_wave()
				
			
