extends CharacterBody2D

var enemy_death_effect = preload("res://Scenes/Enemies/enemy_death_effect.tscn")

const NAME = "enemy"
var current_delta: float = 0.0

@export var patrol_points : Node
@export var speed : int = 1500
@export var wait_time : int = 3
@export var health_amount : int = 3
@export var damage_amount : int = 1

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var timer = $Timer

const GRAVITY = 1000

enum State { Idle, Walk }
var current_state : State
var direction : Vector2 = Vector2.LEFT
var number_of_points : int
var point_positions : Array[Vector2]
var current_point : Vector2
var current_point_position : int
var can_walk : bool

var direction_knockback = 1
var knockback_dir
var knockback = false
var player_dir
var knockback_velocity: Vector2 = Vector2.ZERO  # Variabel knockback
@export var knockback_strength: float = 5000.0  # Besar knockback
@export var knockback_decay: float = 50.0  # Kecepatan peluruhan knockback

func _ready():
	if patrol_points != null:
		number_of_points = patrol_points.get_children().size()
		for point in patrol_points.get_children():
			point_positions.append(point.global_position)
		current_point = point_positions[current_point_position]
	else:
		print("No patrol points")
	
	timer.wait_time = wait_time
	
	current_state = State.Idle


func _physics_process(delta : float):
	current_delta = delta
	enemy_gravity(delta)
	enemy_idle(delta)
	enemy_walk(delta)
	handle_knockback(delta)

	move_and_slide()
	
	enemy_animations()


func enemy_gravity(delta : float):
	velocity.y += GRAVITY * delta

func enemy_idle(delta : float):
	if !can_walk:
		velocity.x = move_toward(velocity.x, 0, speed * delta)
		current_state = State.Idle


func enemy_walk(delta : float):
	if !can_walk:
		return
	
	if abs(position.x - current_point.x) > 0.5:
		velocity.x = direction.x * speed * delta
		current_state = State.Walk
	else:
		current_point_position += 1

		if current_point_position >= number_of_points:
			current_point_position = 0

		current_point = point_positions[current_point_position];

		if current_point.x > position.x:
			direction = Vector2.RIGHT
		else:
			direction = Vector2.LEFT
		
		can_walk = false
		timer.start()
	
	animated_sprite_2d.flip_h = direction.x > 0


func enemy_animations():
	if current_state == State.Idle && !can_walk:
		animated_sprite_2d.play("idle")
	elif current_state == State.Walk && can_walk:
		animated_sprite_2d.play("walk")

func _on_timer_timeout():
	can_walk = true

func handle_knockback(delta):
	if knockback:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
		velocity += knockback_velocity
		if knockback_velocity.length() < 10:
			knockback = false
			knockback_velocity = Vector2.ZERO

func apply_knockback(delta: float):
	knockback = true
	if direction_knockback == player_dir:
		knockback_dir *= 1
	knockback_velocity.x = knockback_strength * knockback_dir * delta # Tentukan arah knockback

func _on_hurtbox_area_entered(area : Area2D):
	if area.get_parent().has_method("get_damage_amount"):
		print("Bullet area entered")
		var node = area.get_parent() as Node
		health_amount -= node.damage_amount
		print("Health amount: ", health_amount)
		if health_amount <= 0:
			var enemy_death_effect_instance = enemy_death_effect.instantiate() as Node2D
			enemy_death_effect_instance.global_position = global_position
			get_parent().add_child(enemy_death_effect_instance)
			HitStopManager.hit_stop_short()
			queue_free()
	if area.is_in_group("attack"):
		var node = area.get_parent() as Node
		health_amount -= node.damage_amount
		player_dir = node.dir
		knockback_dir = player_dir
		apply_knockback(current_delta)
		print("Health amount: ", health_amount)
		if health_amount <= 0:
			var enemy_death_effect_instance = enemy_death_effect.instantiate() as Node2D
			enemy_death_effect_instance.global_position = global_position
			get_parent().add_child(enemy_death_effect_instance)
			HitStopManager.hit_stop_short()
			queue_free()
