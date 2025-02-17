extends Area2D


@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

var breaked=false
func _on_area_entered(body: Node2D) -> void:
	if not breaked:
		if body.is_in_group("sword"):
			audio_stream_player_2d.play()
			$AnimatedSprite2D.play("breaking ")
			audio_stream_player_2d.stop()
			
			breaked=true
