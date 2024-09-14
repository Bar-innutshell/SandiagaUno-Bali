extends CharacterBody2D

# Define the speed at which the player will move to the right
const SPEED = 3500

func _physics_process(delta):
	# Set the player's velocity to move to the right
	velocity.x = SPEED * delta
	
	# Apply the velocity to move the player
	move_and_slide()