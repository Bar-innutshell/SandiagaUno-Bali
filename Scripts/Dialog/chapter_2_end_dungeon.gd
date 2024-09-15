extends Area2D

@onready var cutscene : Node2D = $"../Cutscene"

var has_interacted = false
var cutscene_type = "chapter2_end_dungeon"

func _on_body_entered(body: CharacterBody2D) -> void:
	print("Here i am")
	
	if cutscene == null:
		print("?ilangers")
		return
	
	if not has_interacted:
		cutscene.set_cutscene_type(cutscene_type)
		cutscene.play_current_chapter()
		has_interacted = true
		
		self.queue_free()
