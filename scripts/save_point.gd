extends Area2D

signal save_point_activated(position: Vector2)

var is_active: bool = false
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _on_body_entered(body: Node2D) -> void:
	if not is_active:
		is_active = true
		animated_sprite.visible = true
		
		# Play sound when the sprite becomes visible
		if not audio_stream_player_2d.playing:
			audio_stream_player_2d.play()

		GameData.save_point = position
		emit_signal("save_point_activated", position)
