extends Node2D


@onready var interaction_area: InteractionArea = $InteractionArea
@onready var upgrade_box: CanvasLayer = $UpgradeBox

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")
	upgrade_box.visible = false

func _on_interact():
	if upgrade_box:
		upgrade_box.visible = not upgrade_box.visible