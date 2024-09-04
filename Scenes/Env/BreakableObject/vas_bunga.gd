extends Node2D

# Breakable object
func _on_breakable_object_area_entered(area):
	print("Area entered")
	if area is BreakableObject:
		print("Breakable object detected")
		area.break_object()
	elif area.get_parent() is BreakableObject:
		print("Breakable object detected (parent)")
		area.get_parent().break_object()
	else:
		print("Not a breakable object")
#
