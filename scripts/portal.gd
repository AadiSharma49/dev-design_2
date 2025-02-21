extends Area2D

@onready var is_activated = false
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _on_body_entered(body: Node2D) -> void:
	if not is_activated and body.is_class("CharacterBody2D"):
		if body.keys >= 4:
			is_activated = true
			print("Player detected, opening portal...")
			animated_sprite_2d.play("open")
			audio_stream_player_2d.play()  # Play the sound when the portal opens
		else:
			body.show_ins("You need to find 4 keys to open this portal")

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "open":
		animated_sprite_2d.play("start")
		GameData.save_point = Vector2(-189, -105)
		get_tree().change_scene_to_file("res://scean/level.tscn")

func _on_body_exited(body: Node2D) -> void:
	if not is_activated and body.is_class("CharacterBody2D"):
		body.show_ins("")
