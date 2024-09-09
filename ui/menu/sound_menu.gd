extends Control

@onready var bgButtonSprite: AnimatedSprite2D = $bgButtonSprite
@onready var sfxButtonSprite: AnimatedSprite2D = $sfxButtonSprite

@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")

func _ready():
	bgButtonSprite.play("unmute")
	sfxButtonSprite.play("unmute")


func _on_bg_button_pressed():
	if bgButtonSprite.animation == "mute":
		bgButtonSprite.play("unmute")
		AudioServer.set_bus_mute(MUSIC_BUS_ID, false)
	else:
		bgButtonSprite.play("mute")
		AudioServer.set_bus_mute(MUSIC_BUS_ID, true)


func _on_sfx_button_pressed():
	if sfxButtonSprite.animation == "mute":
		sfxButtonSprite.play("unmute")
		AudioServer.set_bus_mute(SFX_BUS_ID, false)
	else:
		sfxButtonSprite.play("mute")
		AudioServer.set_bus_mute(SFX_BUS_ID, true)
