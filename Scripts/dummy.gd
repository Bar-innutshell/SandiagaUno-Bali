#buat perbandingan kode

extends CharacterBody2D

var bullet = preload("res://Scenes/Weapon/bullets.tscn")
var player_death_effect = preload("res://Scenes/Player/player_death_effect.tscn")
@onready var muzzle : Marker2D = $Muzzle
var muzzle_position

@export var SPEED = 1000
@export var max_horizontal_speed : int = 180
@export var slowdown_speed : int = 1800 

@export var JUMP_VELOCITY = -90000
@export var double_jump_velocity : float = -90000
@export var max_vertical_speed : int = 300
var has_double_jump : bool = false
@export var wallJump = 700
@export var jumpWall = -350
@export var wall_slide_gravity = 100
var is_wall_sliding = false

const DASHSPEED = 6000.0
var dashing = false
var can_dash = true
var isAttacking = false

var knockback_dir
var knockback = false
var enemy_dir
var knockback_velocity: Vector2 = Vector2.ZERO  # Variabel knockback
var knockback_strength: float = 100.0  # Besar knockback
var knockback_decay: float = 5.0  # Kecepatan peluruhan knockback
var direction = 0

@onready var animated_sprite = $AnimatedSprite2D
@onready var hit_animation_player = $HitAnimationPlayer

func _ready():
    muzzle_position = muzzle.position

func _physics_process(delta):
    # Add the gravity.
    if not is_on_floor():
        velocity += get_gravity() * delta
    else:
        has_double_jump = false

    # Handle jump.
    if Input.is_action_just_pressed("jump"):
        if is_on_floor():
            # Normal jump
            velocity.y = JUMP_VELOCITY * delta
            velocity.y = clamp(velocity.y, -max_vertical_speed, max_vertical_speed)
        elif not has_double_jump:
            # Double jump in air
            velocity.y = double_jump_velocity * delta
            velocity.y = clamp(velocity.y, -max_vertical_speed, max_vertical_speed)
            has_double_jump = true
        if is_on_wall_only() and nextToRightWall():
            velocity.x -= wallJump
            velocity.y = jumpWall
        if is_on_wall_only() and nextToLeftWall():
            velocity.x += wallJump
            velocity.y = jumpWall
    wall_slide(delta)
     
    if Input.is_action_just_pressed("attack"):
        isAttacking = true
        hit_animation_player.play("punch")
        animated_sprite.play("attack")
    
    # Handle Running
    var run_multiplier = 1
    
    if Input.is_action_pressed("run"):
        run_multiplier = 2

    if Input.is_action_pressed("move_left"):
        direction = -1
    elif Input.is_action_pressed("move_right"):
        direction = 1
    else:
        direction = 0

    # Flip the Sprite
    if direction > 0:
        animated_sprite.flip_h = false
    elif direction < 0:
        animated_sprite.flip_h = true
    
    # Play animations
    if is_on_floor():
        if direction == 0:
            if isAttacking:
                animated_sprite.play("attack")
            else:
                animated_sprite.play("idle")
        elif Input.is_action_pressed("shot"):
            animated_sprite.play("run-shot")
        else:
            animated_sprite.play("run")
    else:
        animated_sprite.play("jump")
        
    # Shooting
    if direction != 0 and Input.is_action_just_pressed("shot"):
        var bullet_instance = bullet.instantiate() as Node2D
        bullet_instance.direction = direction
        bullet_instance.global_position = muzzle.global_position
        get_parent().add_child(bullet_instance)
    
    # Muzzle position
    if direction > 0:
        muzzle.position.x = muzzle_position.x
    elif direction < 0:
        muzzle.position.x = -muzzle_position.x
    
    if knockback:
        knockback_velocity = lerp(knockback_velocity, Vector2.ZERO, knockback_decay * delta)
        velocity += knockback_velocity
        if knockback_velocity.length() < 10:
            knockback = false
            knockback_velocity = Vector2.ZERO
    
    # Apply movement
    if direction != 0:
        if Input.is_action_just_pressed("dash") and can_dash and is_on_floor_only():
            dashing = true
            velocity.x += direction * DASHSPEED
            can_dash = false
            $dash.start()
            $can_dash.start()
        else:
            velocity.x += direction * SPEED * run_multiplier * delta
            velocity.x = clamp(velocity.x, -max_horizontal_speed * run_multiplier, max_horizontal_speed * run_multiplier)
    else:
        velocity.x = move_toward(velocity.x, 0, slowdown_speed * delta)

    move_and_slide()

func player_death():
    var player_death_effect_instance = player_death_effect.instantiate() as Node2D
    player_death_effect_instance.global_position = global_position
    get_parent().add_child(player_death_effect_instance)
    queue_free()

func _on_hurtbox_body_entered(body : CharacterBody2D):
    if body.is_in_group("Enemy"):
        print("Enemy Entered ", body.damage_amount)
        animated_sprite.play("hit")  # Play "hit" animation from animated_sprite
        enemy_dir = body.direction
        knockback_dir = enemy_dir
        direction = knockback_dir * -1
        apply_knockback()
        HealthManager.decrease_health(body.damage_amount)
        
    if HealthManager.current_health == 0:
        player_death()

func nextToWall():
    return nextToRightWall() or nextToLeftWall()

func nextToRightWall():
    return $RightWall.is_colliding()

func nextToLeftWall():
    return $LeftWall.is_colliding()

func wall_slide(delta):
    if is_on_wall_only():
        if nextToRightWall() and Input.is_action_pressed("move_right") or nextToLeftWall() and Input.is_action_pressed("move_left"):
            is_wall_sliding = true
        else :
            is_wall_sliding = false
    else:
        is_wall_sliding = false
    
    if is_wall_sliding:
        velocity.y += (wall_slide_gravity * delta)
        velocity.y = min(velocity.y, wall_slide_gravity)

func _on_dash_timeout() -> void:
    dashing = false

func _on_can_dash_timeout() -> void:
    can_dash = true
    
func apply_knockback():
    knockback = true
    knockback_velocity.y = -25  # Knockback vertikal jika perlu
    knockback_velocity.x = knockback_strength * knockback_dir  # Tentukan arah knockback