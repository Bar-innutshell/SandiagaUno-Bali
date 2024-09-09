extends Node2D

@onready var musicAudioStreamBG: AudioStreamPlayer2D = $AudioStreamPlayer_BGM
var backgroundMusicOn = true

func _process(delta):
	update_music_stats()

func update_music_stats():
	if backgroundMusicOn:
		if !musicAudioStreamBG.playing:
			musicAudioStreamBG.play()
	else:
		musicAudioStreamBG.stop()
