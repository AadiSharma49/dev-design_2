extends Area2D

@onready var collision_shape_2d = $CollisionShape2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var audio_stream_player_2d = $AudioStreamPlayer2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.count_coin(1)
		# Disable collision and visibility
		collision_shape_2d.set_deferred("disabled", true)
		animated_sprite_2d.visible = false
		monitoring = false  # Disable further collision checks
		audio_stream_player_2d.play()

func _on_audio_stream_player_2d_finished() -> void:
	queue_free()
