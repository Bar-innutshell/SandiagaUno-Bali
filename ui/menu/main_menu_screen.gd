extends CanvasLayer

var settings_menu_screen = preload("res://ui/menu/settings_menu_screen.tscn")
@onready var play_button_sprite: AnimatedSprite2D = $MarginContainer/PanelContainer/PlayButtonSprite
@onready var settings_button_sprite: AnimatedSprite2D = $MarginContainer/PanelContainer/SettingsButtonSprite
@onready var exit_button_sprite: AnimatedSprite2D = $MarginContainer/PanelContainer/ExitButtonSprite

func _on_play_button_pressed():
	play_button_sprite.play("play")
	await play_button_sprite.animation_finished
	GameManager.start_game()
	queue_free()

func _on_exit_button_pressed():
	exit_button_sprite.play("quit")
	await exit_button_sprite.animation_finished
	GameManager.exit_game()

func _on_settings_button_pressed():
	settings_button_sprite.play("options")
	await settings_button_sprite.animation_finished
	var settings_menu_screen_instance = settings_menu_screen.instantiate()
	get_tree().get_root().add_child(settings_menu_screen_instance)
