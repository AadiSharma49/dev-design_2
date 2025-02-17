extends Node2D  # Use Node2D instead of CharacterBody2D

const SPEED = 755.0
const STOP_DISTANCE = 10.0  # Distance at which Betal stops following

@onready var player = get_parent().get_node("Player")
@onready var animated_sprite = $AnimatedSprite2D

func _process(delta):
	if not player:
		return  # Prevent errors if the player node is missing

	var distance_to_player = position.distance_to(player.position)  # Get distance to player

	if distance_to_player > STOP_DISTANCE:  # Only check distance, not player's movement
		var direction = (player.position - position).normalized()
		position += direction * SPEED * delta  # Move Betal towards the player
		animated_sprite.play("b_running")  # Play running animation
		animated_sprite.flip_h = direction.x < 0  # Flip animation based on direction
	else:
		animated_sprite.play("b_running")  # Play stop animation when close to the player
