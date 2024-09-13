extends Node

@onready var bg_music_player: AudioStreamPlayer2D = $AudioStreamPlayer_BGM
var current_biome : String #grass, snow, etc

func _ready():
    current_biome = AudioGlobal.current_biome

func _process(delta):
    if current_biome != AudioGlobal.current_biome:
        current_biome = AudioGlobal.current_biome
        update_music_for_scene()

func update_music_for_scene():
    var current_biome_music = str(current_biome) + "Music"
    bg_music_player["parameters/switch_to_clip"] = current_biome_music
